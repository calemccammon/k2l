-- requires: Exceptions
-- The protected call of try blocks (and use, runCatching, ...). Lua allows only about 200 nested C calls, and each pcall
-- is one, so a recursion through a try would fail with "C stack overflow" after some 190 levels. Every LIMIT nested
-- protected calls, the next one instead runs in a fresh coroutine that the driver around main (__K2L_DeepMain) resumes:
-- the pcall it stands for waits in a yield, which unwinds its C frames (Lua 5.2+ yields across pcall), so the new
-- coroutine starts over from the C depth of the driver. Without the driver (Kotlin coroutines and sequences run in
-- coroutines of their own) or where a yield cannot cross a C call (a sort comparator, a gsub callback), it is a plain
-- pcall. MAX_SEGMENTS such coroutines (some 20000 levels) end in a StackOverflowError, as the JVM's stack would.
local __K2L_DeepPcall
local __K2L_DeepMain

do
    local pcall, yield, running, create, resume, status = pcall, coroutine.yield, coroutine.running, coroutine.create,
        coroutine.resume, coroutine.status
    local pack, unpack = table.pack, table.unpack
    local LIMIT, MAX_SEGMENTS = 100, 200
    local REQUEST = {}
    -- the nested protected calls since the bottom of the current coroutine's C stack, and the coroutines started for them
    local depth, segments = 0, 0
    local managed = setmetatable({}, {__mode = "k"})

    -- the driver resumes the waiting call with true and the results of the coroutine: those of a pcall
    local function resumed(saved, _, ...)
        depth, segments = saved, segments - 1
        return ...
    end

    local function deep(f)
        if not managed[running()] then
            return pcall(f)
        end
        if segments >= MAX_SEGMENTS then
            return false, __K2L_StackOverflowError.new()
        end
        local saved = depth
        depth, segments = 0, segments + 1
        -- false when the yield cannot cross a C call: then the call stays a plain pcall
        local yielded = pcall(yield, REQUEST)
        if yielded == false then
            depth, segments = saved, segments - 1
            return pcall(f)
        end
        return resumed(saved, yield(REQUEST, f))
    end

    function __K2L_DeepPcall(f)
        local d = depth + 1
        if d < LIMIT then
            depth = d
            local ok, a, b = pcall(f)
            depth = d - 1
            return ok, a, b
        end
        return deep(f)
    end

    -- Runs main in a coroutine and runs the functions its protected calls hand over, each in a coroutine of its own.
    function __K2L_DeepMain(main, ...)
        local waiting, n = {}, 0
        local co = create(main)
        managed[co] = true
        local r = pack(resume(co, ...))
        while true do
            local suspended = status(co) == "suspended"
            if r[1] and suspended and r[2] == REQUEST and r[3] ~= nil then
                n = n + 1
                waiting[n] = co
                co = create(r[3])
                managed[co] = true
                r = pack(resume(co))
            elseif r[1] and suspended then
                -- the probe of deep(), or a yield outside any coroutine of the program
                if r[2] ~= REQUEST then
                    error("attempt to yield from outside a coroutine", 0)
                end
                r = pack(resume(co))
            elseif n > 0 then
                -- the coroutine finished: its results (true, ...) or error (false, e) are those of the pcall
                co, waiting[n], n = waiting[n], nil, n - 1
                r = pack(resume(co, true, unpack(r, 1, r.n)))
            elseif r[1] then
                return unpack(r, 2, r.n)
            else
                error(r[2], 0)
            end
        end
    end
end
