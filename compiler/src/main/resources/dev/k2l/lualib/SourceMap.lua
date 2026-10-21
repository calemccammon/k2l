-- Source map runtime (only with --source-map): each generated file registers a compact Lua line -> Kotlin line
-- table, and Lua positions in tracebacks and error messages ("main.lua:42:") are rewritten to Kotlin ones
-- ("main.kt:17:"). The registry is a global so that inlined copies of this code share it.
local ____state = rawget(_G, "__k2l_sourcemaps")
if not ____state then
    ____state = { files = {}, decoded = {} }
    _G.__k2l_sourcemaps = ____state
end

-- deltas: "dLuaLine dKotlinLine" pairs, each relative to the previous pair.
local function __K2L_SourceMapRegister(luaFile, kotlinFile, deltas)
    ____state.files[luaFile] = { kotlin = kotlinFile, deltas = deltas }
    ____state.decoded[luaFile] = nil
end

local function ____decode(entry)
    if not entry.lua then
        local lua, kotlin = {}, {}
        local luaLine, kotlinLine = 0, 0
        for dl, dk in string.gmatch(entry.deltas, "(-?%d+) (-?%d+)") do
            luaLine = luaLine + tonumber(dl)
            kotlinLine = kotlinLine + tonumber(dk)
            lua[#lua + 1] = luaLine
            kotlin[#kotlin + 1] = kotlinLine
        end
        entry.lua, entry.kt = lua, kotlin
    end
    return entry
end

-- The registered file a chunk name such as "./util.lua" or "out/util.lua" refers to.
local function ____find(path)
    path = string.gsub(path, "\\", "/")
    path = string.gsub(path, "^%./", "")
    local files = ____state.files
    if files[path] then
        return files[path]
    end
    for key, entry in pairs(files) do
        if string.sub(path, -#key - 1) == "/" .. key then
            return entry
        end
    end
    return nil
end

-- The Kotlin file and line of the statement at or before the given Lua line.
local function ____lookup(path, line)
    local entry = ____find(path)
    if not entry then
        return nil
    end
    ____decode(entry)
    local lua, kotlin = entry.lua, entry.kt
    local low, high, found = 1, #lua, nil
    while low <= high do
        local mid = math.floor((low + high) / 2)
        if lua[mid] <= line then
            found = mid
            low = mid + 1
        else
            high = mid - 1
        end
    end
    if not found then
        return nil
    end
    return entry.kotlin, kotlin[found]
end

local function ____rewrite(text)
    return (string.gsub(text, "([^%s:\"'<>]+%.lua):(%d+)", function(path, line)
        local kotlinFile, kotlinLine = ____lookup(path, tonumber(line))
        if kotlinFile then
            return kotlinFile .. ":" .. kotlinLine
        end
    end))
end

if not ____state.installed and debug and debug.traceback then
    ____state.installed = true
    local original = debug.traceback
    -- The wrapper adds a stack level, so the default level moves down by one.
    debug.traceback = function(a, b, c)
        local isThread = type(a) == "thread"
        local message, level = a, b
        if isThread then
            message, level = b, c
        end
        if message ~= nil and type(message) ~= "string" and type(message) ~= "number" then
            return message
        end
        local result
        if isThread then
            result = original(a, message, level)
        else
            result = original(message, (level or 1) + 1)
        end
        return ____rewrite(result)
    end
end
