local ____lualib = require("lualib_bundle")
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CompareValues = ____lualib.__K2L_CompareValues
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringEndsWith = ____lualib.__K2L_StringEndsWith
local __K2L_StringIndexOf = ____lualib.__K2L_StringIndexOf
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringPadEnd = ____lualib.__K2L_StringPadEnd
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_Text = ____lualib.__K2L_Text

local ACCESS = __K2L_Regex.new("^(\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}) - (\\S+) \\[(\\d{2})/(\\w{3})/(\\d{4}):(\\d{2}):(\\d{2}):(\\d{2}) ([+-]\\d{4})] \"([A-Z]+) ([^ ?\"]+)(\\??)([^ \"]*) HTTP/([\\d.]+)\" (\\d{3}) ([\\d-]+)(.*)$", "^(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?) %- (%S+) %[(%d%d)/([%w_][%w_][%w_])/(%d%d%d%d):(%d%d):(%d%d):(%d%d) ([%+%-]%d%d%d%d)%] \"([A-Z]+) ([^ %?%\"]+)(%??)([^ %\"]*) HTTP/([%d%.]+)\" (%d%d%d) ([%d%-]+)([^\n\r]*)$")
local ACCESS_GROUPS = __K2L_MapOf(__K2L_Pair.new("ip", 1), __K2L_Pair.new("user", 2), __K2L_Pair.new("day", 3), __K2L_Pair.new("mon", 4), __K2L_Pair.new("year", 5), __K2L_Pair.new("h", 6), __K2L_Pair.new("m", 7), __K2L_Pair.new("s", 8), __K2L_Pair.new("tz", 9), __K2L_Pair.new("method", 10), __K2L_Pair.new("path", 11), __K2L_Pair.new("query", 13), __K2L_Pair.new("ver", 14), __K2L_Pair.new("status", 15), __K2L_Pair.new("bytes", 16))
local ACCESS_MS = __K2L_Regex.new(" (\\d+)ms", " (%d+)ms")

local function accessFields(line)
    local ____receiver = ACCESS:matchEntire(line)
    local ____value = ____receiver and ____receiver.groupValues
    if ____value == nil then
        return nil
    end
    local g = ____value
    local ms = ACCESS_MS:matchEntire(g:get(17))
    if #g:get(17) > 0 and ms == nil then
        return nil
    end
    local fields = ACCESS_GROUPS:mapValues(function(____destructured)
        local i = ____destructured.value
        return g:get(i)
    end):filter(function(____destructured_1)
        local k = ____destructured_1.key
        return k ~= "query" or #g:get(12) > 0
    end)
    return ms == nil and fields or fields:plus(__K2L_Pair.new("ms", ms.groupValues:get(1)))
end

local APP = __K2L_Regex.new("^(\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.?\\d*Z?)\\s+([A-Z]+)\\s+\\[([^\\]]+)]\\s+([\\w.$]+)\\s+-\\s+(.*)$", "^(%d%d%d%d%-%d%d%-%d%dT%d%d:%d%d:%d%d%.?%d*Z?)%s+([A-Z]+)%s+%[([^%]]+)%]%s+([%w_%.%$]+)%s+%-%s+([^\n\r]*)$")
local LEVELS = __K2L_SetOf("TRACE", "DEBUG", "INFO", "WARN", "ERROR")
local LOG = __K2L_Text.trimIndent("\n192.168.1.10 - alice [12/Mar/2024:09:15:02 +0000] \"GET /api/users?id=42&token=abc123 HTTP/1.1\" 200 512 12ms\n10.0.0.7 - - [12/Mar/2024:09:15:09 +0000] \"POST /api/login HTTP/1.1\" 401 87 140ms\n10.0.0.7 - - [12/Mar/2024:09:16:11 +0000] \"POST /api/login HTTP/1.1\" 401 87 133ms\n10.0.0.7 - - [12/Mar/2024:09:16:40 +0000] \"POST /api/login HTTP/1.1\" 200 1024 98ms\n2024-03-12T09:16:41.123Z INFO  [http-nio-8080-exec-3] com.example.auth.LoginService - user bob logged in from 10.0.0.7 password=hunter2\n172.16.0.3 - carol [12/Mar/2024:10:01:00 +0000] \"GET /static/app.js HTTP/2.0\" 304 - 3ms\n172.16.0.3 - carol [12/Mar/2024:10:01:01 +0000] \"GET /static/app.css HTTP/2.0\" 304 -\ngarbage line that matches nothing\n2024-03-12T10:02:00Z WARN  [scheduler-1] com.example.jobs.Cleanup" .. "$" .. "Worker - slow query took 2350ms: SELECT * FROM t WHERE email='dave@example.com'\n192.168.1.10 - alice [12/Mar/2024:10:30:59 +0000] \"DELETE /api/users/42 HTTP/1.1\" 500 0 2012ms\n2024-03-12T10:31:00Z ERROR [http-nio-8080-exec-1] com.example.api.UserController - failed to delete user 42: java.sql.SQLException: lock timeout (card 4111-1111-1111-1111)\n192.168.1.11 - alice [12/Mar/2024:11:05:00 +0000] \"GET /api/users?id=7&api_key=XYZ987&page=2 HTTP/1.1\" 200 2048 25ms\n2024-03-12T11:05:01.5Z DEBUG [main] com.example.Cache - hit ratio 0.875 for key users:7\n")
local Access = __K2L_Class("Access")

function Access.new(ip, user, hour, method, path, query, status, bytes, ms)
    return setmetatable({ip = ip, user = user, hour = hour, method = method, path = path, query = query, status = status, bytes = bytes, ms = ms}, Access)
end

__K2L_DataClass(Access, {"ip", "user", "hour", "method", "path", "query", "status", "bytes", "ms"})

local ____lambda_1 = function(kv)
    return __K2L_Pair.new(__K2L_Text.substringBefore(kv, "="), __K2L_Text.substringAfter(kv, "=", ""))
end
local function parseQuery(q)
    local ____receiver_1 = q and __K2L_StringSplit(q, "&")
    local ____result
    if ____receiver_1 ~= nil then
        local ____out = {}
        local ____count = 0
        local ____items, ____n = ____receiver_1:____array()
        for ____i = 1, ____n do
            local it = ____items[____i]
            if #it > 0 then
                ____count = ____count + 1
                ____out[____count] = it
            end
        end
        ____result = __K2L_ListWrap(____out, ____count)
    end
    local ____receiver_2 = ____result
    return ____receiver_2 and ____receiver_2:associate(____lambda_1) or __K2L_MapOf()
end

local PARAM = __K2L_Regex.new("(\\w+)=([^&\\s]+)", "([%w_]+)=([^%s%&]+)")
local SECRETS = __K2L_SetOf("token", "api_key", "password")
local EMAIL = __K2L_Regex.new("([\\w.+-]+)@([\\w-]+\\.[\\w.]*\\w)\\b", "([%w_%.%+%-]+)@([%w_%-]+%.[%w_%.]*[%w_])%f[^%w_]")
local CARD = __K2L_Regex.new("\\b\\d{4}-\\d{4}-\\d{4}-(\\d{4})\\b", "%f[%w_]%d%d%d%d%-%d%d%d%d%-%d%d%d%d%-(%d%d%d%d)%f[^%w_]")

local function isSecret(m)
    return SECRETS:contains(m.groupValues:get(1):lower())
end

local ____lambda_2 = function(m)
    return isSecret(m) and m.groupValues:get(1) .. "=" .. __K2L_Text.repeatCount("*", math.min(#m.groupValues:get(2), 6)) or m.value
end
local ____lambda_3 = function(m)
    return __K2L_Text.first(m.groupValues:get(1)) .. "***@" .. m.groupValues:get(2)
end
local function redact(s)
    local out = PARAM:replace(s, ____lambda_2)
    out = EMAIL:replace(out, ____lambda_3)
    out = CARD:replace(out, "****-****-****-$1")
    return out
end

local ____lambda_4 = function(it) return it.status // 100 end
local ____lambda_5 = function(it) return it end
local ____lambda_6 = function(____a, ____b)
    local ____x, ____y = -____a.value, -____b.value
    if ____x ~= ____y then
        return ____x < ____y and -1 or 1
    end
    return __K2L_CompareValues(____a.key, ____b.key)
end
local ____lambda_7 = function(it) return __K2L_Text.take(it, 1) end
local ____lambda_8 = function(it)
    return __K2L_StringToInt(it.groupValues:get(1))
end
local ____lambda_9 = function(it) return it.groupValues:get(1) end
local ____lambda_10 = function(it) return it.value end
local ____lambda_11 = function(it) return it.value .. "@" .. it.range.first end
local ____lambda_12 = function(it)
    return it.groupValues:get(2) .. it.groupValues:get(1):upper()
end
local function main()
    local accesses = __K2L_ListOf()
    local apps = __K2L_ListOf()
    local rejected = __K2L_ListOf()
    __K2L_AsSequence(__K2L_StringLines(LOG)):forEachIndexed(function(n, line)
        local g = accessFields(line)
        local p
        if g == nil then
            local ____receiver_3 = APP:find(line)
            p = ____receiver_3 and (LEVELS:contains(____receiver_3.groupValues:get(2)) and ____receiver_3 or nil)
        else
            p = nil
        end
        if g ~= nil then
            local ____arg = g:getValue("ip")
            local ____value_1 = g:getValue("user")
            local ____arg_1 = ____value_1 ~= "-" and ____value_1 or nil
            local ____arg_2 = __K2L_StringToInt(g:getValue("h"))
            local ____arg_3 = g:getValue("method")
            local ____arg_4 = g:getValue("path")
            local ____arg_5 = parseQuery(g:get("query"))
            local ____arg_6 = __K2L_StringToInt(g:getValue("status"))
            local ____arg_7 = __K2L_StringToIntOrNull(g:getValue("bytes"), nil, true) or 0
            local ____receiver_4 = g:get("ms")
            accesses:add(Access.new(____arg, ____arg_1, ____arg_2, ____arg_3, ____arg_4, ____arg_5, ____arg_6, ____arg_7, ____receiver_4 and __K2L_StringToInt(____receiver_4)))
        elseif p ~= nil then
            apps:add(p)
        else
            rejected:add(n + 1)
        end
    end)
    print("parsed " .. accesses.size .. " access lines, " .. apps.size .. " app lines, rejected lines " .. __K2L_Str(rejected))
    local first = __K2L_NotNull(ACCESS:find(__K2L_StringLines(LOG):get(0)))
    local named = __K2L_NotNull(accessFields(first.value))
    print("named groups of line 1: " .. __K2L_ListOf("ip", "user", "mon", "tz", "method", "path", "query", "ver", "ms"):joinToString(nil, nil, nil, nil, nil, function(it)
        return it .. "=" .. __K2L_Str(named:get(it))
    end))
    local path = __K2L_StringIndexOf(first.value, named:getValue("path"))
    print("group 0 range " .. __K2L_Str(first.range) .. ", path range " .. __K2L_Str(__K2L_IntRange.new(path, path + #named:getValue("path") - 1)))
    print("-- by status --")
    local ____collection = accesses:groupingBy(____lambda_4):eachCount():toSortedMap()
    local ____items_1, ____n_1 = ____collection:____entryArray()
    for ____i_1 = 1, ____n_1 do
        local ____entry = ____items_1[____i_1]
        do
            local k, v = ____entry.key, ____entry.value
            print(__K2L_Str(k) .. "xx: " .. __K2L_Str(v))
        end
    end
    print("-- by endpoint (ids collapsed) --")
    local id = __K2L_Regex.new("\\d+", "%d+")
    local ____result_1 = __K2L_Map.new()
    local ____items_2, ____n_2 = accesses:____array()
    for ____i_2 = 1, ____n_2 do
        local it = ____items_2[____i_2]
        local ____result_2
        ____result_2 = it.method .. " " .. __K2L_StringSplit(it.path, "/"):joinToString("/", nil, nil, nil, nil, function(part)
            return id:matches(part) and "{id}" or part
        end)
        local ____value_2 = ____result_2
        local ____group = ____result_1:get(____value_2)
        if ____group == nil then
            ____group = __K2L_List.new()
            ____result_1:put(____value_2, ____group)
        end
        ____group:add(it)
    end
    local ____collection_1 = ____result_1:mapValues(function(____destructured_2)
        local list = ____destructured_2.value
        local ____out_1 = {}
        local ____count_1 = 0
        local ____items_3, ____n_3 = list:____array()
        for ____i_3 = 1, ____n_3 do
            local it = ____items_3[____i_3]
            local ____value_3 = it.ms
            if ____value_3 ~= nil then
                ____count_1 = ____count_1 + 1
                ____out_1[____count_1] = ____value_3
            end
        end
        return __K2L_ListWrap(____out_1, ____count_1)
    end):toSortedMap()
    local ____items_4, ____n_4 = ____collection_1:____entryArray()
    for ____i_4 = 1, ____n_4 do
        local ____entry_1 = ____items_4[____i_4]
        do
            local k, times = ____entry_1.key, ____entry_1.value
            local avg = times:isEmpty() and "n/a" or string.format("%.1fms", times:average())
            print(string.format("%-28s n=%d avg=%s max=%s", __K2L_Str(k), times.size, avg, __K2L_Str(times:maxOrNull() or "-")))
        end
    end
    print("-- per hour --")
    local ____result_3 = __K2L_Map.new()
    local ____items_5, ____n_5 = accesses:____array()
    for ____i_5 = 1, ____n_5 do
        local it = ____items_5[____i_5]
        local ____value_4 = it.hour
        local ____group_1 = ____result_3:get(____value_4)
        if ____group_1 == nil then
            ____group_1 = __K2L_List.new()
            ____result_3:put(____value_4, ____group_1)
        end
        ____group_1:add(it)
    end
    local ____collection_2 = ____result_3:toSortedMap()
    local ____items_6, ____n_6 = ____collection_2:____entryArray()
    for ____i_7 = 1, ____n_6 do
        local ____entry_2 = ____items_6[____i_7]
        do
            local h, l = ____entry_2.key, ____entry_2.value
            local ____arg_8 = __K2L_Text.repeatCount("#", l.size)
            local ____sum = 0
            local ____items_7, ____n_7 = l:____array()
            for ____i_6 = 1, ____n_7 do
                local it = ____items_7[____i_6]
                ____sum = ____sum + it.bytes
            end
            print(string.format("%02d:00 %s %d bytes", h, ____arg_8, ____sum))
        end
    end
    print("-- query params --")
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_8, ____n_8 = accesses:____array()
    for ____i_8 = 1, ____n_8 do
        local it = ____items_8[____i_8]
        local ____inner, ____m = it.query:getKeys():____array()
        for ____j = 1, ____m do
            ____count_2 = ____count_2 + 1
            ____out_2[____count_2] = ____inner[____j]
        end
    end
    local ____list = __K2L_ListWrap(____out_2, ____count_2):groupingBy(____lambda_5):eachCount():getEntries():sortedWith(____lambda_6)
    for ____i_9 = 1, ____list.size do
        local it = ____list[____i_9]
        print(it.key .. ": " .. it.value)
    end
    print("-- brute force suspects --")
    local ____out_3 = {}
    local ____count_3 = 0
    local ____items_9, ____n_9 = accesses:____array()
    for ____i_10 = 1, ____n_9 do
        local it = ____items_9[____i_10]
        if __K2L_StringEndsWith(it.path, "/login") then
            ____count_3 = ____count_3 + 1
            ____out_3[____count_3] = it
        end
    end
    local ____list_1 = __K2L_ListWrap(____out_3, ____count_3)
    local ____result_4 = __K2L_Map.new()
    local ____items_10, ____n_10 = ____list_1:____array()
    for ____i_11 = 1, ____n_10 do
        local it = ____items_10[____i_11]
        local ____value_5 = it.ip
        local ____group_2 = ____result_4:get(____value_5)
        if ____group_2 == nil then
            ____group_2 = __K2L_List.new()
            ____result_4:put(____value_5, ____group_2)
        end
        ____group_2:add(it)
    end
    local ____items_11, ____n_11 = ____result_4:____entryArray()
    for ____i_13 = 1, ____n_11 do
        local ____entry_3 = ____items_11[____i_13]
        do
            local ip, l = ____entry_3.key, ____entry_3.value
            local ____result_5 = 0
            local ____items_12, ____n_12 = l:____array()
            for ____i_12 = 1, ____n_12 do
                local it = ____items_12[____i_12]
                if it.status == 401 then
                    ____result_5 = ____result_5 + 1
                end
            end
            local fails = ____result_5
            if fails >= 2 then
                print(ip .. " failed " .. fails .. " times, then " .. (l:last().status == 200 and "succeeded" or "gave up"))
            end
        end
    end
    print("-- application log --")
    for ____i_14 = 1, apps.size do
        local m = apps[____i_14]
        local logger = m.groupValues:get(4)
        local ____value_6 = __K2L_StringSplit(logger, ".")
        local ____result_6
        ____result_6 = ____value_6:dropLast(1):joinToString(".", nil, nil, nil, nil, ____lambda_7) .. "." .. ____value_6:last()
        local short = ____result_6
        local ____destructured_3 = m.destructured
        local ts, level = ____destructured_3[1], ____destructured_3[2]
        local time = __K2L_NotNull(__K2L_Regex.new("T(\\d{2}:\\d{2}:\\d{2})", "T(%d%d:%d%d:%d%d)"):find(ts)).groupValues:get(1)
        print(time .. " " .. __K2L_StringPadEnd(level, 5) .. " " .. __K2L_Text.substringAfter(short, "$", short) .. " " .. redact(m.groupValues:get(5)))
    end
    local durations = __K2L_Sequence.new(__K2L_Regex.new("(\\d+)ms", "(%d+)ms"):findAllFactory(LOG)):map(____lambda_8):toList()
    local ____arg_9 = __K2L_Str(durations)
    local ____out_4 = {}
    local ____count_4 = 0
    local ____items_13, ____n_13 = durations:____array()
    for ____i_15 = 1, ____n_13 do
        local it = ____items_13[____i_15]
        if it > 1000 then
            ____count_4 = ____count_4 + 1
            ____out_4[____count_4] = it
        end
    end
    print("all durations: " .. ____arg_9 .. ", slow (>1s): " .. __K2L_Str(__K2L_ListWrap(____out_4, ____count_4)))
    print("-- redaction --")
    local ____list_2 = __K2L_StringLines(LOG)
    local ____out_5 = {}
    local ____count_5 = 0
    local ____items_14, ____n_14 = ____list_2:____array()
    for ____i_16 = 1, ____n_14 do
        local it = ____items_14[____i_16]
        if __K2L_Sequence.new(PARAM:findAllFactory(it)):any(isSecret) or EMAIL:containsMatchIn(it) or CARD:containsMatchIn(it) then
            ____count_5 = ____count_5 + 1
            ____out_5[____count_5] = it
        end
    end
    local ____list_3 = __K2L_ListWrap(____out_5, ____count_5)
    for ____i_17 = 1, ____list_3.size do
        local line = ____list_3[____i_17]
        print(__K2L_Text.take(redact(line), 110))
    end
    print("-- misc regex --")
    local words = __K2L_Regex.new("[\\s,;]+", "[%s%,%;]+"):split("alpha, beta;gamma  delta,,epsilon")
    print(__K2L_Str(words))
    print(__K2L_Str(__K2L_Regex.new("\\d+", "%d+"):split("a1b22c333", 3)))
    print(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("@(\\w+)", "@([%w_]+)"):findAllFactory("x@foo y@bar z@")):map(____lambda_9):toList()))
    local hyphenated = "well-known self-made easy"
    print(__K2L_Sequence.new(__K2L_Regex.new("\\w+", "[%w_]+"):findAllFactory(hyphenated)):filter(function(it)
        return __K2L_Text.getOrNull(hyphenated, it.range.last + 1) ~= "-"
    end):map(____lambda_10):joinToString("|"))
    print(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("(\\w)\\1", "([%w_])%1"):findAllFactory("bookkeeper aardvark")):map(____lambda_11):toList()))
    print(__K2L_Regex.new("(\\d+)-(\\d+)-(\\d+)", "(%d+)%-(%d+)%-(%d+)"):replace("2024-03-12", "$3/$2/$1") .. " " .. __K2L_StringReplace("a.b.c", "\\Q.\\E", "\\$"))
    local ____list_4 = __K2L_StringLines("one two\nthree four\n five")
    local ____out_6 = {}
    local ____count_6 = 0
    local ____items_15, ____n_15 = ____list_4:____array()
    for ____i_18 = 1, ____n_15 do
        local it = ____items_15[____i_18]
        local ____result_7
        do
            local ____receiver_5 = __K2L_Regex.new("^\\w+", "^[%w_]+"):find(it)
            ____result_7 = ____receiver_5 and ____receiver_5.value
        end
        local ____value_7 = ____result_7
        if ____value_7 ~= nil then
            ____count_6 = ____count_6 + 1
            ____out_6[____count_6] = ____value_7
        end
    end
    print(__K2L_Str(__K2L_ListWrap(____out_6, ____count_6)))
    print(__K2L_Sequence.new(__K2L_Regex.new("error", "[eE][rR][rR][oO][rR]"):findAllFactory(LOG)):count())
    print(__K2L_Regex.new("([a-z]+)(\\d*)", "([a-z]+)(%d*)"):replace("abc12 de xyz9", ____lambda_12))
    local m = __K2L_Regex.new("\\d+", "%d+"):find("a1bb22ccc333")
    local seen = __K2L_ListOf()
    while m ~= nil do
        seen:add(m.value .. "@" .. __K2L_Str(m.range))
        m = m:next()
    end
    print(__K2L_Str(seen))
    print(__K2L_Regex.new("x*", "x*"):replace("abc", "-") .. " " .. __K2L_Str(__K2L_StringSplit("a,b,,c,", ",")) .. " " .. __K2L_Regex.new(",", ","):split("a,b,,c,").size)
    print(__K2L_Regex.new("[aeiou]", "[aeiou]"):replaceFirst("programming language", "_") .. " " .. __K2L_Regex.new("(?i)[^aeiou\\s]", "[^%saAeEiIoOuU]"):replace("Hello World", "."))
end

__K2L_RunMain(main)
return {ACCESS = ACCESS, ACCESS_GROUPS = ACCESS_GROUPS, ACCESS_MS = ACCESS_MS, accessFields = accessFields, APP = APP, LEVELS = LEVELS, LOG = LOG, Access = Access, parseQuery = parseQuery, PARAM = PARAM, SECRETS = SECRETS, EMAIL = EMAIL, CARD = CARD, isSecret = isSecret, redact = redact}
