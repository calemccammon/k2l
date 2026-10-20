-- Sampling profiler for the benchmark harness: lua k2l_profiler.lua SCRIPT OUT_FILE [INTERVAL [REPEAT]]
-- (REPEAT runs the script that many times, for more samples)
-- PUC Lua (5.1 to 5.4): a count hook every INTERVAL VM instructions (time spent inside C functions is not sampled).
-- LuaJIT: jit.profile every millisecond, which keeps the JIT compiler on (a debug hook would turn it off).
-- Writes tab-separated records to OUT_FILE:
--   mode  <hook|jit.profile>
--   total <samples>
--   vm    <state> <samples>                                    (LuaJIT: N compiled, I interpreted, C, G gc, J jit)
--   self  <source> <line> <linedefined> <samples>              (the running function and line)
--   incl  <source> <linedefined> <samples>                     (each function on the stack, once per sample)
--   site  <source> <linedefined> <site source> <line> <samples> (a lualib/C sample and the nearest program line calling it)
local script, outFile, interval, repeats = arg[1], arg[2], tonumber(arg[3]) or 1000, tonumber(arg[4]) or 1
local getinfo, sethook = debug.getinfo, debug.sethook
local find, sub, format = string.find, string.sub, string.format
local MAX_DEPTH = 40

local selfCounts, inclCounts, siteCounts, vmCounts = {}, {}, {}, {}
local total = 0

local function clean(source)
    if sub(source, 1, 1) == "@" then source = sub(source, 2) end
    if sub(source, 1, 2) == "./" then source = sub(source, 3) end
    return source
end

-- a chunk loaded from a string (the lualib compiles some code with `load`) has its text as source: one name for all
local function named(source)
    local c = sub(source, 1, 1)
    if c == "@" or c == "=" then return source end
    return "[string]"
end

local function isProgram(source)
    return sub(source, 1, 1) == "@" and not find(source, "lualib_bundle", 1, true) and not find(source, "k2l_profiler", 1, true)
end

-- `first` is the stack level of the running function; `th` the profiled thread (LuaJIT) or nil.
local function record(th, first, samples, cName)
    local info
    if th then info = getinfo(th, first, "Sl") else info = getinfo(first, "Sl") end
    if not info then return end
    total = total + samples
    local src = info.what == "C" and ("[C]" .. (cName or "")) or named(info.source)
    local selfFn = src .. "\t" .. info.linedefined
    local key = src .. "\t" .. info.currentline .. "\t" .. info.linedefined
    selfCounts[key] = (selfCounts[key] or 0) + samples
    local seen = {}
    local site = isProgram(info.source) and "" or nil
    for level = first, first + MAX_DEPTH do
        local f
        if th then f = getinfo(th, level, "Sl") else f = getinfo(level, "Sl") end
        if not f then break end
        if f.what ~= "C" and not find(f.source, "k2l_profiler", 1, true) then
            local fn = named(f.source) .. "\t" .. f.linedefined
            if not seen[fn] then
                seen[fn] = true
                inclCounts[fn] = (inclCounts[fn] or 0) + samples
            end
            if not site and isProgram(f.source) then
                site = f.source .. "\t" .. f.currentline
            end
        end
    end
    if site and site ~= "" then
        local k = selfFn .. "\t" .. site
        siteCounts[k] = (siteCounts[k] or 0) + samples
    end
end

local mode
local stop
if jit then
    mode = "jit.profile"
    local profile = require("jit.profile")
    profile.start("li1", function(th, samples, vmstate)
        vmCounts[vmstate] = (vmCounts[vmstate] or 0) + samples
        local name
        local top = getinfo(th, 0, "S")
        if top and top.what == "C" then name = profile.dumpstack(th, "f", 1) end
        record(th, 0, samples, name)
    end)
    stop = profile.stop
else
    mode = "hook"
    -- Inside record (called from the hook), level 1 is record, 2 the hook and 3 the function that was running.
    sethook(function()
        record(nil, 3, 1)
    end, "", interval)
    stop = function() sethook() end
end

local ok, err
for _ = 1, repeats do
    ok, err = pcall(dofile, script)
    if not ok then break end
end
stop()
io.stdout:flush()

local out = assert(io.open(outFile, "w"))
out:write("mode\t", mode, "\n", "total\t", total, "\n")
for state, n in pairs(vmCounts) do out:write("vm\t", state, "\t", n, "\n") end
local function dump(kind, counts)
    for key, n in pairs(counts) do
        out:write(kind, "\t", (key:gsub("[^\t]+", function(field)
            if sub(field, 1, 1) == "@" then return clean(field) end
            return field
        end)), "\t", n, "\n")
    end
end
dump("self", selfCounts)
dump("incl", inclCounts)
dump("site", siteCounts)
out:close()
if not ok then
    io.stderr:write(format("%s\n", tostring(err)))
    os.exit(1)
end
