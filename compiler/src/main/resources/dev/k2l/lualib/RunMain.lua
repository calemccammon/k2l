-- Runs main. An uncaught error ends the program as the standalone interpreter ends it, the same on every target: its string
-- (tostring, so an exception's __tostring, its toString()) and the traceback of where it was raised on stderr, then exit
-- status 1. The interpreters themselves print an exception differently ("(error object is not a string)" on Lua 5.1, no
-- traceback on 5.2 to 5.4), and their tracebacks do not go through debug.traceback, which --source-map rewrites to Kotlin
-- positions.
local function __K2L_RunMain(main, ...)
    local args, n = {...}, select("#", ...)
    local unpack = table.unpack or unpack
    local ok, report = xpcall(function()
        return main(unpack(args, 1, n))
    end, function(e)
        return debug.traceback(tostring(e), 2)
    end)
    if not ok then
        io.stderr:write(tostring(report), "\n")
        os.exit(1)
    end
end
