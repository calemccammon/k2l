-- An error that ends main prints as on the JVM, the same on every target: `Exception in thread "main" <toString()>`
-- and a `Caused by: <toString()>` line for each cause, then the Lua traceback of the stack it was raised from (with
-- Kotlin positions under --source-map, whose debug.traceback rewrites them). A Lua error (a string) prints its message
-- and the traceback. Then the program exits with status 1. Lua's standalone interpreters print an exception on their
-- own differently: Lua 5.1 as "(error object is not a string)", 5.2 to 5.4 its toString() only, LuaJIT with a traceback.
local __K2L_Uncaught
local __K2L_UncaughtIn
local __K2L_Main

do
    -- k2l exceptions by class name, so that copies of the runtime inlined into other files are recognized too
    local function isThrowable(e)
        if type(e) ~= "table" then
            return false
        end
        local c = getmetatable(e)
        while type(c) == "table" do
            if rawget(c, "____name") == "java.lang.Throwable" then
                return true
            end
            c = rawget(c, "____super")
        end
        return false
    end

    -- toString() as the JVM's Throwable.printStackTrace prints it
    local function describe(e)
        local ok, text = pcall(e.toString, e)
        if ok and type(text) == "string" then
            return text
        end
        return tostring(getmetatable(e).____name)
    end

    local function header(e)
        if not isThrowable(e) then
            local mt = getmetatable(e)
            if type(mt) == "table" and mt.__tostring ~= nil then
                return tostring(e)
            end
            return "(error object is a " .. type(e) .. " value)"
        end
        local lines, seen = { "Exception in thread \"main\" " .. describe(e) }, { [e] = true }
        local cause = e.cause
        while isThrowable(cause) do
            if seen[cause] then
                lines[#lines + 1] = "Caused by: [CIRCULAR REFERENCE: " .. describe(cause) .. "]"
                break
            end
            seen[cause] = true
            lines[#lines + 1] = "Caused by: " .. describe(cause)
            cause = cause.cause
        end
        return table.concat(lines, "\n")
    end

    local function isMessage(e)
        return type(e) == "string" or type(e) == "number"
    end

    -- The message of a Lua error (an exception has its header instead) and the traceback of the coroutine `co`.
    local function tracebackOf(e, co)
        local message = isMessage(e) and tostring(e) or ""
        local traceback = debug and debug.traceback
        if traceback == nil then
            return message
        end
        return (string.gsub(traceback(co, message, 0), "^\n", ""))
    end

    -- Prints the uncaught error `e` and its traceback (which starts with the message of a Lua error) and exits with
    -- status 1.
    function __K2L_Uncaught(e, traceback)
        local text = traceback or tostring(e)
        if type(e) == "string" and string.find(e, "stack overflow$") then
            -- Lua's "stack overflow" (or "C stack overflow"): the JVM's StackOverflowError, then the message with its
            -- position, as when a catch receives it (ToThrowable.lua)
            text = "Exception in thread \"main\" java.lang.StackOverflowError\n" .. text
        elseif not isMessage(e) then
            local ok, lines = pcall(header, e)
            text = (ok and lines or tostring(e)) .. ((traceback or "") ~= "" and "\n" .. traceback or "")
        end
        -- what the program printed comes first, as on the JVM, whose System.out flushes every line
        pcall(io.stdout.flush, io.stdout)
        io.stderr:write(text, "\n")
        os.exit(1)
    end

    -- The error `e` that ended the coroutine `co`.
    function __K2L_UncaughtIn(e, co)
        __K2L_Uncaught(e, tracebackOf(e, co))
    end

    -- The traceback from the frame that raised `e` (`error`). It runs where the error happened, so it calls as little as
    -- it can: after a stack overflow LuaJIT has little stack left for the handler.
    local function capture(e)
        local traceback = debug and debug.traceback
        local message = (type(e) == "string" or type(e) == "number") and tostring(e) or ""
        local captured = { e, traceback and traceback(message, 2) or message }
        return captured
    end

    -- What capture found, without what runs main: the closure in __K2L_Main, xpcall and the main chunk.
    local function uncaught(captured)
        local text = string.gsub(captured[2], "^\n", "")
        local cut = string.find(text, "\n\t[^\n]*xpcall")
        if cut then
            text = string.gsub(string.sub(text, 1, cut - 1), "\n[^\n]*$", "")
        end
        __K2L_Uncaught(captured[1], text)
    end

    local onJit = type(rawget(_G, "jit")) == "table"

    -- Runs main (or __K2L_RunSuspend with main), through a closure since Lua 5.1's xpcall passes no arguments. On LuaJIT
    -- main runs in a coroutine instead: when a stack overflow happens in compiled code (a trace), LuaJIT unwinds without
    -- calling the handler of xpcall, so only "stack overflow" printed; a coroutine stopped by an error keeps its stack,
    -- whose traceback is read after the resume.
    function __K2L_Main(main, a, b)
        if onJit then
            local co = coroutine.create(main)
            local ok, e = coroutine.resume(co, a, b)
            if not ok then
                __K2L_UncaughtIn(e, co)
            elseif coroutine.status(co) ~= "dead" then
                __K2L_UncaughtIn("attempt to yield from outside a coroutine", co)
            end
            return
        end
        local ok, failure = xpcall(function()
            main(a, b)
        end, capture)
        if not ok then
            -- the error itself when capture did not run, or failed too ("error in error handling")
            if type(failure) == "table" then
                uncaught(failure)
            end
            __K2L_Uncaught(failure)
        end
    end
end
