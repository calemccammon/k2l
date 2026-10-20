local ____lualib = require("lualib_bundle")
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CompareValues = ____lualib.__K2L_CompareValues
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringEndsWith = ____lualib.__K2L_StringEndsWith
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringPadEnd = ____lualib.__K2L_StringPadEnd
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_Text = ____lualib.__K2L_Text

local ACCESS = __K2L_Regex.new("^(?<ip>\\d{1,3}(?:\\.\\d{1,3}){3}) - (?<user>\\S+) \\[(?<day>\\d{2})/(?<mon>\\w{3})/(?<year>\\d{4}):(?<h>\\d{2}):(?<m>\\d{2}):(?<s>\\d{2}) (?<tz>[+-]\\d{4})] \"(?<method>[A-Z]+) (?<path>[^ ?\"]+)(?:\\?(?<query>[^ \"]*))? HTTP/(?<ver>[\\d.]+)\" (?<status>\\d{3}) (?<bytes>\\d+|-)(?: (?<ms>\\d+)ms)?$")
local APP = __K2L_Regex.new("^(?<ts>\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(?:\\.\\d+)?Z?)\\s+(?<level>TRACE|DEBUG|INFO|WARN|ERROR)\\s+\\[(?<thread>[^\\]]+)]\\s+(?<logger>[\\w.$]+)\\s+-\\s+(?<msg>.*)$")
local LOG = __K2L_Text.trimIndent("\n192.168.1.10 - alice [12/Mar/2024:09:15:02 +0000] \"GET /api/users?id=42&token=abc123 HTTP/1.1\" 200 512 12ms\n10.0.0.7 - - [12/Mar/2024:09:15:09 +0000] \"POST /api/login HTTP/1.1\" 401 87 140ms\n10.0.0.7 - - [12/Mar/2024:09:16:11 +0000] \"POST /api/login HTTP/1.1\" 401 87 133ms\n10.0.0.7 - - [12/Mar/2024:09:16:40 +0000] \"POST /api/login HTTP/1.1\" 200 1024 98ms\n2024-03-12T09:16:41.123Z INFO  [http-nio-8080-exec-3] com.example.auth.LoginService - user bob logged in from 10.0.0.7 password=hunter2\n172.16.0.3 - carol [12/Mar/2024:10:01:00 +0000] \"GET /static/app.js HTTP/2.0\" 304 - 3ms\n172.16.0.3 - carol [12/Mar/2024:10:01:01 +0000] \"GET /static/app.css HTTP/2.0\" 304 -\ngarbage line that matches nothing\n2024-03-12T10:02:00Z WARN  [scheduler-1] com.example.jobs.Cleanup" .. "$" .. "Worker - slow query took 2350ms: SELECT * FROM t WHERE email='dave@example.com'\n192.168.1.10 - alice [12/Mar/2024:10:30:59 +0000] \"DELETE /api/users/42 HTTP/1.1\" 500 0 2012ms\n2024-03-12T10:31:00Z ERROR [http-nio-8080-exec-1] com.example.api.UserController - failed to delete user 42: java.sql.SQLException: lock timeout (card 4111-1111-1111-1111)\n192.168.1.11 - alice [12/Mar/2024:11:05:00 +0000] \"GET /api/users?id=7&api_key=XYZ987&page=2 HTTP/1.1\" 200 2048 25ms\n2024-03-12T11:05:01.5Z DEBUG [main] com.example.Cache - hit ratio 0.875 for key users:7\n")
local Access = __K2L_Class("Access")

function Access:____init(ip, user, hour, method, path, query, status, bytes, ms)
    self.ip = ip
    self.user = user
    self.hour = hour
    self.method = method
    self.path = path
    self.query = query
    self.status = status
    self.bytes = bytes
    self.ms = ms
end

function Access.new(ip, user, hour, method, path, query, status, bytes, ms)
    return setmetatable({ip = ip, user = user, hour = hour, method = method, path = path, query = query, status = status, bytes = bytes, ms = ms}, Access)
end

function Access:toString()
    return "Access(ip=" .. self.ip .. ", user=" .. __K2L_Str(self.user) .. ", hour=" .. self.hour .. ", method=" .. self.method .. ", path=" .. self.path .. ", query=" .. __K2L_Str(self.query) .. ", status=" .. self.status .. ", bytes=" .. self.bytes .. ", ms=" .. __K2L_Str(self.ms) .. ")"
end

function Access:hashCode()
    return (31 * (31 * (31 * (31 * (31 * (31 * (31 * (31 * __K2L_Hash(self.ip) + __K2L_Hash(self.user)) + self.hour) + __K2L_Hash(self.method)) + __K2L_Hash(self.path)) + __K2L_Hash(self.query)) + self.status) + __K2L_Hash(self.bytes)) + __K2L_Hash(self.ms) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Access:equals(other)
    return getmetatable(other) == Access and self.ip == other.ip and self.user == other.user and self.hour == other.hour and self.method == other.method and self.path == other.path and __K2L_Equals(self.query, other.query) and self.status == other.status and self.bytes == other.bytes and self.ms == other.ms
end

local ____lambda_1 = function(kv)
    return __K2L_Pair.new(__K2L_Text.substringBefore(kv, "="), __K2L_Text.substringAfter(kv, "=", ""))
end
local function parseQuery(q)
    local ____receiver = q and __K2L_StringSplit(q, "&")
    local ____result
    if ____receiver ~= nil then
        local ____out = {}
        local ____count = 0
        local ____items, ____n = ____receiver:____array()
        for ____i = 1, ____n do
            local it = ____items[____i]
            if #it > 0 then
                ____count = ____count + 1
                ____out[____count] = it
            end
        end
        ____result = __K2L_ListWrap(____out, ____count)
    end
    local ____receiver_1 = ____result
    return ____receiver_1 and ____receiver_1:associate(____lambda_1) or __K2L_ReadOnlyMapOf()
end

local SECRET_PARAM = __K2L_Regex.new("(?i)(token|api_key|password)=([^&\\s]+)")
local EMAIL = __K2L_Regex.new("\\b([\\w.+-]+)@([\\w-]+\\.[\\w.]+)\\b")
local CARD = __K2L_Regex.new("\\b(?:\\d{4}-){3}(\\d{4})\\b")

local ____lambda_2 = function(m)
    return m.groupValues:get(1) .. "=" .. __K2L_Text.repeatCount("*", math.min(#m.groupValues:get(2), 6))
end
local ____lambda_3 = function(m)
    return __K2L_Text.first(m.groupValues:get(1)) .. "***@" .. m.groupValues:get(2)
end
local function redact(s)
    local out = SECRET_PARAM:replace(s, ____lambda_2)
    out = EMAIL:replace(out, ____lambda_3)
    out = CARD:replace(out, "****-****-****-$1")
    return out
end

local ____lambda_4 = function(it)
    return it.status >= 0 and it.status // 100 or 0 - -it.status // 100
end
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
local ____lambda_9 = function(it) return it.value end
local ____lambda_10 = function(it) return it.value end
local ____lambda_11 = function(it) return it.value .. "@" .. it.range.first end
local ____lambda_12 = function(it) return it.value end
local ____lambda_13 = function(it)
    return __K2L_NotNull(it.groups:getNamed("num")).value .. __K2L_NotNull(it.groups:getNamed("word")).value:upper()
end
local function main()
    local accesses = __K2L_ListOf()
    local apps = __K2L_ListOf()
    local rejected = __K2L_ListOf()
    __K2L_AsSequence(__K2L_StringLines(LOG)):forEachIndexed(function(n, line)
        local a = ACCESS:matchEntire(line)
        local p
        if a == nil then
            p = APP:find(line)
        else
            p = nil
        end
        if a ~= nil then
            local g = a.groups
            local ____arg = __K2L_NotNull(g:getNamed("ip")).value
            local ____value = __K2L_NotNull(g:getNamed("user")).value
            local ____arg_1 = ____value ~= "-" and ____value or nil
            local ____arg_2 = __K2L_StringToInt(__K2L_NotNull(g:getNamed("h")).value)
            local ____arg_3 = __K2L_NotNull(g:getNamed("method")).value
            local ____arg_4 = __K2L_NotNull(g:getNamed("path")).value
            local ____receiver_2 = g:getNamed("query")
            local ____arg_5 = parseQuery(____receiver_2 and ____receiver_2.value)
            local ____arg_6 = __K2L_StringToInt(__K2L_NotNull(g:getNamed("status")).value)
            local ____arg_7 = __K2L_StringToIntOrNull(__K2L_NotNull(g:getNamed("bytes")).value, nil, true) or 0
            local ____receiver_3 = g:getNamed("ms")
            local ____receiver_4 = ____receiver_3 and ____receiver_3.value
            accesses:add(Access.new(____arg, ____arg_1, ____arg_2, ____arg_3, ____arg_4, ____arg_5, ____arg_6, ____arg_7, ____receiver_4 and __K2L_StringToInt(____receiver_4)))
        elseif p ~= nil then
            apps:add(p)
        else
            rejected:add(n + 1)
        end
    end)
    print("parsed " .. accesses.size .. " access lines, " .. apps.size .. " app lines, rejected lines " .. __K2L_Str(rejected))
    local first = __K2L_NotNull(ACCESS:find(__K2L_StringLines(LOG):get(0)))
    print("named groups of line 1: " .. __K2L_ReadOnlyListOf("ip", "user", "mon", "tz", "method", "path", "query", "ver", "ms"):joinToString(nil, nil, nil, nil, nil, function(it)
        local ____receiver_5 = first.groups:getNamed(it)
        return it .. "=" .. __K2L_Str(____receiver_5 and ____receiver_5.value)
    end))
    local ____arg_8 = __K2L_Str(first.range)
    local ____receiver_6 = first.groups:getNamed("path")
    print("group 0 range " .. ____arg_8 .. ", path range " .. __K2L_Str(____receiver_6 and ____receiver_6.range))
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
    local endpoint = __K2L_Regex.new("/\\d+(?=/|$)")
    local ____result_1 = __K2L_Map.new()
    local ____items_2, ____n_2 = accesses:____array()
    for ____i_2 = 1, ____n_2 do
        local it = ____items_2[____i_2]
        local ____value_1 = it.method .. " " .. endpoint:replace(it.path, "/{id}")
        local ____group = ____result_1:get(____value_1)
        if ____group == nil then
            ____group = __K2L_List.new()
            ____result_1:put(____value_1, ____group)
        end
        ____group:add(it)
    end
    local ____collection_1 = ____result_1:mapValues(function(____destructured)
        local list = ____destructured.value
        local ____out_1 = {}
        local ____count_1 = 0
        local ____items_3, ____n_3 = list:____array()
        for ____i_3 = 1, ____n_3 do
            local it = ____items_3[____i_3]
            local ____value_2 = it.ms
            if ____value_2 ~= nil then
                ____count_1 = ____count_1 + 1
                ____out_1[____count_1] = ____value_2
            end
        end
        return __K2L_ListWrap(____out_1, ____count_1)
    end):toSortedMap()
    local ____items_4, ____n_4 = ____collection_1:____entryArray()
    local ____mod = ____collection_1.____modCount
    for ____i_4 = 1, ____n_4 do
        local ____entry_1 = ____items_4[____i_4]
        do
            local k, times = ____entry_1.key, ____entry_1.value
            local avg = times:isEmpty() and "n/a" or __K2L_StringFormat("%.1fms", times:average())
            print(__K2L_StringFormat("%-28s n=%d avg=%s max=%s", k, times.size, avg, times:maxOrNull() or "-"))
        end
        if ____collection_1.____modCount ~= ____mod and ____collection_1:____comodified(____i_4, ____n_4) then
            break
        end
    end
    print("-- per hour --")
    local ____result_2 = __K2L_Map.new()
    local ____items_5, ____n_5 = accesses:____array()
    for ____i_5 = 1, ____n_5 do
        local it = ____items_5[____i_5]
        local ____value_3 = it.hour
        local ____group_1 = ____result_2:get(____value_3)
        if ____group_1 == nil then
            ____group_1 = __K2L_List.new()
            ____result_2:put(____value_3, ____group_1)
        end
        ____group_1:add(it)
    end
    local ____collection_2 = ____result_2:toSortedMap()
    local ____items_6, ____n_6 = ____collection_2:____entryArray()
    local ____mod_1 = ____collection_2.____modCount
    for ____i_7 = 1, ____n_6 do
        local ____entry_2 = ____items_6[____i_7]
        do
            local h, l = ____entry_2.key, ____entry_2.value
            local ____arg_9 = __K2L_Text.repeatCount("#", l.size)
            local ____sum = 0
            local ____items_7, ____n_7 = l:____array()
            for ____i_6 = 1, ____n_7 do
                local it = ____items_7[____i_6]
                ____sum = ____sum + it.bytes
            end
            print(__K2L_StringFormat("%02d:00 %s %d bytes", h, ____arg_9, ____sum))
        end
        if ____collection_2.____modCount ~= ____mod_1 and ____collection_2:____comodified(____i_7, ____n_6) then
            break
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
    local ____result_3 = __K2L_Map.new()
    local ____items_10, ____n_10 = ____list_1:____array()
    for ____i_11 = 1, ____n_10 do
        local it = ____items_10[____i_11]
        local ____value_4 = it.ip
        local ____group_2 = ____result_3:get(____value_4)
        if ____group_2 == nil then
            ____group_2 = __K2L_List.new()
            ____result_3:put(____value_4, ____group_2)
        end
        ____group_2:add(it)
    end
    local ____items_11, ____n_11 = ____result_3:____entryArray()
    local ____mod_2 = ____result_3.____modCount
    for ____i_13 = 1, ____n_11 do
        local ____entry_3 = ____items_11[____i_13]
        do
            local ip, l = ____entry_3.key, ____entry_3.value
            local ____result_4 = 0
            local ____items_12, ____n_12 = l:____array()
            for ____i_12 = 1, ____n_12 do
                local it = ____items_12[____i_12]
                if it.status == 401 then
                    ____result_4 = ____result_4 + 1
                end
            end
            local fails = ____result_4
            if fails >= 2 then
                print(ip .. " failed " .. fails .. " times, then " .. (l:last().status == 200 and "succeeded" or "gave up"))
            end
        end
        if ____result_3.____modCount ~= ____mod_2 and ____result_3:____comodified(____i_13, ____n_11) then
            break
        end
    end
    print("-- application log --")
    local ____mod_3 = apps.____modCount
    for ____i_14 = 1, apps.size do
        local m = apps[____i_14]
        local logger = __K2L_NotNull(m.groups:getNamed("logger")).value
        local ____value_5 = __K2L_StringSplit(logger, ".")
        local ____result_5
        ____result_5 = ____value_5:dropLast(1):joinToString(".", nil, nil, nil, nil, ____lambda_7) .. "." .. ____value_5:last()
        local short = ____result_5
        local ____destructured_1 = m.destructured
        local ts, level = ____destructured_1[1], ____destructured_1[2]
        local time = __K2L_NotNull(__K2L_Regex.new("T(\\d{2}:\\d{2}:\\d{2})"):find(ts)).groupValues:get(1)
        print(time .. " " .. __K2L_StringPadEnd(level, 5) .. " " .. __K2L_Text.substringAfter(short, "$", short) .. " " .. redact(__K2L_NotNull(m.groups:getNamed("msg")).value))
        if apps.____modCount ~= ____mod_3 and apps:____comodified(____i_14) then
            break
        end
    end
    local durations = __K2L_Sequence.new(__K2L_Regex.new("(\\d+)ms"):findAllFactory(LOG)):map(____lambda_8):toList()
    local ____arg_10 = __K2L_Str(durations)
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
    print("all durations: " .. ____arg_10 .. ", slow (>1s): " .. __K2L_Str(__K2L_ListWrap(____out_4, ____count_4)))
    print("-- redaction --")
    local ____list_2 = __K2L_StringLines(LOG)
    local ____out_5 = {}
    local ____count_5 = 0
    local ____items_14, ____n_14 = ____list_2:____array()
    for ____i_16 = 1, ____n_14 do
        local it = ____items_14[____i_16]
        if SECRET_PARAM:containsMatchIn(it) or EMAIL:containsMatchIn(it) or CARD:containsMatchIn(it) then
            ____count_5 = ____count_5 + 1
            ____out_5[____count_5] = it
        end
    end
    local ____list_3 = __K2L_ListWrap(____out_5, ____count_5)
    local ____mod_4 = ____list_3.____modCount
    for ____i_17 = 1, ____list_3.size do
        local line = ____list_3[____i_17]
        print(__K2L_Text.take(redact(line), 110))
        if ____list_3.____modCount ~= ____mod_4 and ____list_3:____comodified(____i_17) then
            break
        end
    end
    print("-- misc regex --")
    local words = __K2L_Regex.new("[\\s,;]+"):split("alpha, beta;gamma  delta,,epsilon")
    print(__K2L_Str(words))
    print(__K2L_Str(__K2L_Regex.new("\\d+"):split("a1b22c333", 3)))
    print(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("(?<=@)\\w+"):findAllFactory("x@foo y@bar z@")):map(____lambda_9):toList()))
    print(__K2L_Sequence.new(__K2L_Regex.new("\\b\\w+(?!\\w|-)"):findAllFactory("well-known self-made easy")):map(____lambda_10):joinToString("|"))
    print(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("(\\w)\\1"):findAllFactory("bookkeeper aardvark")):map(____lambda_11):toList()))
    print(__K2L_Regex.new("(\\d+)-(\\d+)-(\\d+)"):replace("2024-03-12", "$3/$2/$1") .. " " .. __K2L_StringReplace("a.b.c", __K2L_Regex.escape("."), "\\$"))
    print(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("^\\w+", "MULTILINE"):findAllFactory("one two\nthree four\n five")):map(____lambda_12):toList()))
    print(__K2L_Sequence.new(__K2L_Regex.new("error", "IGNORE_CASE"):findAllFactory(LOG)):count())
    print(__K2L_Regex.new("(?<word>[a-z]+)(?<num>\\d*)"):replace("abc12 de xyz9", ____lambda_13))
    local m = __K2L_Regex.new("\\d+"):find("a1bb22ccc333")
    local seen = __K2L_ListOf()
    while m ~= nil do
        seen:add(m.value .. "@" .. __K2L_Str(m.range))
        m = m:next()
    end
    print(__K2L_Str(seen))
    print(__K2L_Regex.new("x*"):replace("abc", "-") .. " " .. __K2L_Str(__K2L_StringSplit("a,b,,c,", ",")) .. " " .. __K2L_Regex.new(","):split("a,b,,c,").size)
    print(__K2L_Regex.new("[aeiou]"):replaceFirst("programming language", "_") .. " " .. __K2L_Regex.new("(?i)[^aeiou\\s]"):replace("Hello World", "."))
end

main()
return {ACCESS = ACCESS, APP = APP, LOG = LOG, Access = Access, parseQuery = parseQuery, SECRET_PARAM = SECRET_PARAM, EMAIL = EMAIL, CARD = CARD, redact = redact}
