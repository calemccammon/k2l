local ____lualib = require("lualib_bundle")
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_ListOf = ____lualib.__K2L_ListOf
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
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32

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

function Access:toString()
    return "Access(ip=" .. self.ip .. ", user=" .. __K2L_Str(self.user) .. ", hour=" .. self.hour .. ", method=" .. self.method .. ", path=" .. self.path .. ", query=" .. __K2L_Str(self.query) .. ", status=" .. self.status .. ", bytes=" .. self.bytes .. ", ms=" .. __K2L_Str(self.ms) .. ")"
end

function Access:hashCode()
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.ip) + __K2L_Hash(self.user)) + __K2L_Hash(self.hour)) + __K2L_Hash(self.method)) + __K2L_Hash(self.path)) + __K2L_Hash(self.query)) + __K2L_Hash(self.status)) + __K2L_Hash(self.bytes)) + __K2L_Hash(self.ms))
end

function Access:equals(other)
    return getmetatable(other) == Access and self.ip == other.ip and self.user == other.user and self.hour == other.hour and self.method == other.method and self.path == other.path and __K2L_Equals(self.query, other.query) and self.status == other.status and self.bytes == other.bytes and self.ms == other.ms
end

local function parseQuery(q)
    local ____receiver = q and __K2L_StringSplit(q, "&")
    local ____receiver_1 = ____receiver and ____receiver:filter(function(it) return #it > 0 end)
    return ____receiver_1 and ____receiver_1:associate(function(kv)
        return __K2L_Pair.new(__K2L_Text.substringBefore(kv, "="), __K2L_Text.substringAfter(kv, "=", ""))
    end) or __K2L_ReadOnlyMapOf()
end

local SECRET_PARAM = __K2L_Regex.new("(?i)(token|api_key|password)=([^&\\s]+)")
local EMAIL = __K2L_Regex.new("\\b([\\w.+-]+)@([\\w-]+\\.[\\w.]+)\\b")
local CARD = __K2L_Regex.new("\\b(?:\\d{4}-){3}(\\d{4})\\b")

local function redact(s)
    local out = SECRET_PARAM:replace(s, function(m)
        return m.groupValues:get(1) .. "=" .. __K2L_Text.repeatCount("*", math.min(#m.groupValues:get(2), 6))
    end)
    out = EMAIL:replace(out, function(m)
        return __K2L_Text.first(m.groupValues:get(1)) .. "***@" .. m.groupValues:get(2)
    end)
    out = CARD:replace(out, "****-****-****-$1")
    return out
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
    local ____arg_8 = first.range
    local ____receiver_6 = first.groups:getNamed("path")
    print("group 0 range " .. __K2L_Str(____arg_8) .. ", path range " .. __K2L_Str(____receiver_6 and ____receiver_6.range))
    print("-- by status --")
    local ____collection = accesses:groupingBy(function(it) return __K2L_IDiv(it.status, 100) end):eachCount():toSortedMap()
    local ____items, ____n = ____collection:____entryArray()
    for ____i = 1, ____n do
        local ____entry = ____items[____i]
        do
            local k, v = ____entry.key, ____entry.value
            print(__K2L_Str(k) .. "xx: " .. __K2L_Str(v))
        end
    end
    print("-- by endpoint (ids collapsed) --")
    local endpoint = __K2L_Regex.new("/\\d+(?=/|$)")
    local ____collection_1 = accesses:groupBy(function(it)
        return it.method .. " " .. endpoint:replace(it.path, "/{id}")
    end):mapValues(function(____destructured)
        local list = ____destructured.value
        return list:mapNotNull(function(it) return it.ms end)
    end):toSortedMap()
    local ____items_1, ____n_1 = ____collection_1:____entryArray()
    local ____mod = ____collection_1.____modCount
    for ____i_1 = 1, ____n_1 do
        local ____entry_1 = ____items_1[____i_1]
        do
            local k, times = ____entry_1.key, ____entry_1.value
            local avg = times:isEmpty() and "n/a" or __K2L_StringFormat("%.1fms", times:average())
            print(__K2L_StringFormat("%-28s n=%d avg=%s max=%s", k, times.size, avg, times:maxOrNull() or "-"))
        end
        if ____collection_1.____modCount ~= ____mod and ____collection_1:____comodified(____i_1, ____n_1) then
            break
        end
    end
    print("-- per hour --")
    local ____collection_2 = accesses:groupBy(function(it) return it.hour end):toSortedMap()
    local ____items_2, ____n_2 = ____collection_2:____entryArray()
    local ____mod_1 = ____collection_2.____modCount
    for ____i_2 = 1, ____n_2 do
        local ____entry_2 = ____items_2[____i_2]
        do
            local h, l = ____entry_2.key, ____entry_2.value
            print(__K2L_StringFormat("%02d:00 %s %d bytes", h, __K2L_Text.repeatCount("#", l.size), l:sumOf(function(it) return it.bytes end)))
        end
        if ____collection_2.____modCount ~= ____mod_1 and ____collection_2:____comodified(____i_2, ____n_2) then
            break
        end
    end
    print("-- query params --")
    local ____list = accesses:flatMap(function(it) return it.query:getKeys() end):groupingBy(function(it) return it end):eachCount():getEntries():sortedWith(__K2L_CompareBy(function(it) return -it.value end, function(it) return it.key end))
    for ____i_3 = 1, ____list.size do
        local it = ____list[____i_3]
        print(it.key .. ": " .. it.value)
    end
    print("-- brute force suspects --")
    local ____collection_3 = accesses:filter(function(it)
        return __K2L_StringEndsWith(it.path, "/login")
    end):groupBy(function(it) return it.ip end)
    local ____items_3, ____n_3 = ____collection_3:____entryArray()
    local ____mod_2 = ____collection_3.____modCount
    for ____i_4 = 1, ____n_3 do
        local ____entry_3 = ____items_3[____i_4]
        do
            local ip, l = ____entry_3.key, ____entry_3.value
            local fails = l:count(function(it) return it.status == 401 end)
            if fails >= 2 then
                print(ip .. " failed " .. fails .. " times, then " .. (l:last().status == 200 and "succeeded" or "gave up"))
            end
        end
        if ____collection_3.____modCount ~= ____mod_2 and ____collection_3:____comodified(____i_4, ____n_3) then
            break
        end
    end
    print("-- application log --")
    local ____mod_3 = apps.____modCount
    for ____i_5 = 1, apps.size do
        local m = apps[____i_5]
        local logger = __K2L_NotNull(m.groups:getNamed("logger")).value
        local ____value_1 = __K2L_StringSplit(logger, ".")
        local ____result
        ____result = ____value_1:dropLast(1):joinToString(".", nil, nil, nil, nil, function(it) return __K2L_Text.take(it, 1) end) .. "." .. ____value_1:last()
        local short = ____result
        local ____destructured_1 = m.destructured
        local ts, level = ____destructured_1[1], ____destructured_1[2]
        local time = __K2L_NotNull(__K2L_Regex.new("T(\\d{2}:\\d{2}:\\d{2})"):find(ts)).groupValues:get(1)
        print(time .. " " .. __K2L_StringPadEnd(level, 5) .. " " .. __K2L_Text.substringAfter(short, "$", short) .. " " .. redact(__K2L_NotNull(m.groups:getNamed("msg")).value))
        if apps.____modCount ~= ____mod_3 and apps:____comodified(____i_5) then
            break
        end
    end
    local durations = __K2L_Sequence.new(__K2L_Regex.new("(\\d+)ms"):findAllFactory(LOG)):map(function(it)
        return __K2L_StringToInt(it.groupValues:get(1))
    end):toList()
    print("all durations: " .. __K2L_Str(durations) .. ", slow (>1s): " .. __K2L_Str(durations:filter(function(it) return it > 1000 end)))
    print("-- redaction --")
    local ____list_1 = __K2L_StringLines(LOG):filter(function(it)
        return SECRET_PARAM:containsMatchIn(it) or EMAIL:containsMatchIn(it) or CARD:containsMatchIn(it)
    end)
    local ____mod_4 = ____list_1.____modCount
    for ____i_6 = 1, ____list_1.size do
        local line = ____list_1[____i_6]
        print(__K2L_Text.take(redact(line), 110))
        if ____list_1.____modCount ~= ____mod_4 and ____list_1:____comodified(____i_6) then
            break
        end
    end
    print("-- misc regex --")
    local words = __K2L_Regex.new("[\\s,;]+"):split("alpha, beta;gamma  delta,,epsilon")
    print(__K2L_Str(words))
    print(__K2L_Str(__K2L_Regex.new("\\d+"):split("a1b22c333", 3)))
    print(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("(?<=@)\\w+"):findAllFactory("x@foo y@bar z@")):map(function(it) return it.value end):toList()))
    print(__K2L_Sequence.new(__K2L_Regex.new("\\b\\w+(?!\\w|-)"):findAllFactory("well-known self-made easy")):map(function(it) return it.value end):joinToString("|"))
    print(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("(\\w)\\1"):findAllFactory("bookkeeper aardvark")):map(function(it) return it.value .. "@" .. it.range.first end):toList()))
    print(__K2L_Regex.new("(\\d+)-(\\d+)-(\\d+)"):replace("2024-03-12", "$3/$2/$1") .. " " .. __K2L_StringReplace("a.b.c", __K2L_Regex.escape("."), "\\$"))
    print(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("^\\w+", "MULTILINE"):findAllFactory("one two\nthree four\n five")):map(function(it) return it.value end):toList()))
    print(__K2L_Sequence.new(__K2L_Regex.new("error", "IGNORE_CASE"):findAllFactory(LOG)):count())
    print(__K2L_Regex.new("(?<word>[a-z]+)(?<num>\\d*)"):replace("abc12 de xyz9", function(it)
        return __K2L_NotNull(it.groups:getNamed("num")).value .. __K2L_NotNull(it.groups:getNamed("word")).value:upper()
    end))
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
