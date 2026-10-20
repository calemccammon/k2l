local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_DoubleToInt = ____lualib.__K2L_DoubleToInt
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_FunctionRef = ____lualib.__K2L_FunctionRef
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PatternSyntaxException = ____lualib.__K2L_PatternSyntaxException
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_StringIsBlank = ____lualib.__K2L_StringIsBlank
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Entry = __K2L_Class("Entry")
__K2L_ClassInfo(Entry, "Entry", "Entry", "class")

function Entry:____init(time, level, source, message, fields)
    self.time = time
    self.level = level
    self.source = source
    self.message = message
    self.fields = fields
end

function Entry.new(time, level, source, message, fields)
    return setmetatable({time = time, level = level, source = source, message = message, fields = fields}, Entry)
end

function Entry:toString()
    return "Entry(time=" .. self.time .. ", level=" .. self.level .. ", source=" .. self.source .. ", message=" .. self.message .. ", fields=" .. __K2L_Str(self.fields) .. ")"
end

function Entry:hashCode()
    return (31 * (31 * (31 * (31 * __K2L_Hash(self.time) + __K2L_Hash(self.level)) + __K2L_Hash(self.source)) + __K2L_Hash(self.message)) + __K2L_Hash(self.fields) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Entry:equals(other)
    return getmetatable(other) == Entry and self.time == other.time and self.level == other.level and self.source == other.source and self.message == other.message and __K2L_Equals(self.fields, other.fields)
end

local accessLine = __K2L_Regex.new("^(?<ip>\\d{1,3}(?:\\.\\d{1,3}){3}) - (?<user>\\S+) \\[(?<time>[^\\]]+)] \"(?<method>[A-Z]+) (?<path>\\S+) HTTP/[\\d.]+\" (?<status>\\d{3}) (?<bytes>\\d+|-)(?: (?<ms>\\d+)ms)?$")
local appLine = __K2L_Regex.new("^(?<time>\\d{2}:\\d{2}:\\d{2}(?:\\.\\d+)?)\\s+\\[(?<level>trace|debug|info|warn|error)]\\s+(?<src>[\\w.$]+):\\s*(?<msg>.*)$", "IGNORE_CASE")
local kvPair = __K2L_Regex.new("(\\w+)=(\"(?:[^\"\\\\]|\\\\.)*\"|\\S+)")
local traceLine = __K2L_Regex.new("^\\s+at\\s+([\\w.$<>]+)\\((\\w+\\.\\w+):(\\d+)\\)")
local emailish = __K2L_Regex.new("\\b([\\w.+-]+)@([\\w-]+(?:\\.[\\w-]+)+)\\b")
local token = __K2L_Regex.new("(?i)(token|password|secret)=\\S+")
local numberedPath = __K2L_Regex.new("/\\d+(?=/|$)")
local LogReport = __K2L_Class("LogReport")
__K2L_ClassInfo(LogReport, "LogReport", "LogReport", "class")

function LogReport:____init()
    self.entries = __K2L_ListOf()
    self.unparsed = __K2L_ListOf()
    self.traces = __K2L_MapOf()
    self.latency = __K2L_SortedMapOf()
    self.statuses = __K2L_MapOf()
end

local ____lambda_1 = function(m)
    return m.groupValues:get(1):lower() .. "=***"
end
local ____lambda_2 = function(m)
    return __K2L_Text.first(m.groupValues:get(1)) .. "…@" .. m.groupValues:get(2)
end
local function redact(s)
    return emailish:replace(token:replace(s, ____lambda_1), ____lambda_2)
end

local function parseFields(msg)
    return __K2L_Sequence.new(kvPair:findAllFactory(msg)):associate(function(m)
        local ____destructured = m.destructured
        local k, raw = ____destructured[1], ____destructured[2]
        return __K2L_Pair.new(k, __K2L_StringStartsWith(raw, "\"") and __K2L_StringReplace(__K2L_Text.substring(raw, 1, #raw - 1), "\\\"", "\"") or raw)
    end)
end

local ____lambda_3 = function(____p1, ____p2) return ____p1 + ____p2 end
local ____lambda_4 = function() return __K2L_ListOf() end
local ____lambda_5 = function() return __K2L_ListOf() end
local ____lambda_6 = function() return __K2L_ListOf() end
local function analyze(text)
    local r = LogReport.new()
    local lastApp = -1
    local ____list = __K2L_StringLines(text)
    for n = 0, ____list.size - 1 do
        local line = ____list[n + 1]
        do
            if __K2L_StringIsBlank(line) then
                goto ____continue
            end
            local access = accessLine:matchEntire(line)
            local app = appLine:matchEntire(line)
            local trace = traceLine:find(line)
            if access ~= nil then
                local g = access.groups
                local route = numberedPath:replace(__K2L_Text.substringBefore(__K2L_NotNull(g:getNamed("path")).value, "?"), "/{id}")
                local status = __K2L_StringToInt(__K2L_NotNull(g:getNamed("status")).value)
                r.statuses:merge((status >= 0 and status // 100 or 0 - -status // 100) * 100, 1, __K2L_FunctionRef.new("plus", "kotlin/Int.plus(kotlin.Int)", ____lambda_3))
                local ____receiver = g:getNamed("ms")
                if ____receiver ~= nil then
                    r.latency:getOrPut(__K2L_NotNull(g:getNamed("method")).value .. " " .. route, ____lambda_4):add(__K2L_StringToInt(____receiver.value))
                end
                local fields = __K2L_ReadOnlyMapOf(__K2L_Pair.new("ip", __K2L_NotNull(g:getNamed("ip")).value), __K2L_Pair.new("status", tostring(status)), __K2L_Pair.new("bytes", __K2L_StringReplace(__K2L_NotNull(g:getNamed("bytes")).value, "-", "0")))
                r.entries:add(Entry.new(__K2L_Text.substringBefore(__K2L_Text.substringAfter(__K2L_NotNull(g:getNamed("time")).value, ":"), " "), status >= 500 and "ERROR" or "INFO", "http", route, fields))
                lastApp = -1
            elseif app ~= nil then
                local msg = redact(__K2L_NotNull(app.groups:getNamed("msg")).value)
                r.entries:add(Entry.new(__K2L_NotNull(app.groups:getNamed("time")).value, __K2L_NotNull(app.groups:getNamed("level")).value:upper(), __K2L_NotNull(app.groups:getNamed("src")).value, msg, parseFields(msg)))
                lastApp = r.entries.size - 1
            elseif trace ~= nil and lastApp >= 0 then
                local ____destructured_1 = trace.destructured
                local method, file, lineNo = ____destructured_1[1], ____destructured_1[2], ____destructured_1[3]
                r.traces:getOrPut(lastApp, ____lambda_5):add(__K2L_Text.substringAfterLast(method, ".") .. "@" .. file .. ":" .. lineNo)
            elseif __K2L_StringStartsWith(line, "Caused by: ") and lastApp >= 0 then
                r.traces:getOrPut(lastApp, ____lambda_6):add("cause: " .. __K2L_Text.removePrefix(line, "Caused by: "))
            else
                r.unparsed:add(__K2L_Pair.new(n + 1, line))
            end
        end
        ::____continue::
    end
    return r
end

local function percentile(xs, p)
    local sorted = xs:sorted()
    local rank = __K2L_Num.coerceIn(__K2L_DoubleToInt(__K2L_Num.ceil(p / 100.0 * sorted.size)), 1, sorted.size)
    return sorted:get(rank - 1)
end

local sample = __K2L_Text.trimIndent("\n127.0.0.1 - - [10/Oct/2024:13:55:36 +0000] \"GET /api/users/42?verbose=1 HTTP/1.1\" 200 2326 12ms\n10.0.0.7 - alice [10/Oct/2024:13:55:37 +0000] \"POST /api/users HTTP/1.1\" 201 512 48ms\n10.0.0.7 - alice [10/Oct/2024:13:55:38 +0000] \"GET /api/users/7/orders/19 HTTP/2.0\" 200 9001 33ms\n13:55:39.120 [INFO] app.Server: started port=8080 workers=4 mode=\"blue green\"\n13:55:40 [warn] app.Auth: login failed user=bob@example.com token=abc123XYZ attempts=3\n192.168.1.20 - - [10/Oct/2024:13:55:41 +0000] \"GET /health HTTP/1.1\" 204 - 1ms\n13:55:42.5 [Error] app.Db" .. "$" .. "Pool: query failed sql=\"select * from \\\"users\\\"\" elapsed=1500\n    at app.Db" .. "$" .. "Pool.run(Db.kt:88)\n    at app.Service.load(Service.kt:12)\nCaused by: java.net.SocketTimeoutException: Read timed out\n    at java.net.Socket.read(Socket.java:204)\n10.0.0.9 - - [10/Oct/2024:13:55:43 +0000] \"DELETE /api/users/42 HTTP/1.1\" 500 87 230ms\ngarbage line with no format\n13:55:44 [DEBUG] app.Cache: evicted keys=17 Password=hunter2 contact=Ops.Team+pager@corp.example.org\n10.0.0.9 - - [10/Oct/2024:13:55:45 +0000] \"GET /api/users/1 HTTP/1.1\" 304 0 3ms\n13:55:46 [fatal] app.Main: unknown level\n    at app.Main.main(Main.kt:1)\n")

local ____lambda_7 = function(it) return it.key .. "=<" .. it.value .. ">" end
local ____lambda_8 = function(it)
    return "#" .. it.first .. " '" .. __K2L_Text.take(it.second, 20) .. "'"
end
local ____lambda_9 = function(it) return it.level end
local ____lambda_10 = function(it) return it.second end
local ____lambda_11 = function(it) return it.groupValues:get(1) end
local ____lambda_12 = function(____p1) return __K2L_StringToInt(____p1) end
local ____lambda_13 = function(it) return it.range.first .. ":" .. it.value end
local ____lambda_14 = function() return __K2L_Regex.new("(unclosed") end
local function main()
    local r = analyze(sample)
    local ____list_1 = r.entries
    for i = 0, ____list_1.size - 1 do
        local e = ____list_1[i + 1]
        print(__K2L_StringFormat("%-12s %-5s %-10s %s", e.time, e.level, e.source, e.message))
        if e.fields:isNotEmpty() then
            print("    fields " .. e.fields:getEntries():joinToString(", ", nil, nil, nil, nil, ____lambda_7))
        end
        local ____receiver_1 = r.traces:get(i)
        if ____receiver_1 ~= nil then
            for ____i = 1, ____receiver_1.size do
                local it = ____receiver_1[____i]
                print("    | " .. it)
            end
        end
    end
    print("unparsed: " .. r.unparsed:joinToString(nil, nil, nil, nil, nil, ____lambda_8))
    print("status classes: " .. __K2L_Str(r.statuses:toSortedMap()))
    local ____map = r.latency
    local ____keys, ____values, ____n = ____map:____arrays()
    local ____mod = ____map.____modCount
    for ____i_1 = 1, ____n do
        local route, ms = ____keys[____i_1], ____values[____i_1]
        print(__K2L_StringFormat("  %-28s n=%d p50=%d p90=%d max=%d avg=%.1f", route, ms.size, percentile(ms, 50), percentile(ms, 90), ms:max(), ms:average()))
        if ____map.____modCount ~= ____mod and ____map:____comodified(____i_1, ____n) then
            break
        end
    end
    local levels = r.entries:groupingBy(____lambda_9):eachCount():toList():sortedByDescending(____lambda_10, true)
    print(__K2L_Str(levels))
    local csvish = "a, b;c ;; d,e"
    print(__K2L_Str(__K2L_Regex.new("\\s*[,;]\\s*"):split(csvish)))
    print(__K2L_Str(__K2L_Regex.new("\\s*[,;]\\s*"):split(csvish, 3)))
    print(__K2L_Str(__K2L_Regex.new("(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])"):split("CamelCaseHTTPServerName")))
    print(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("^\\s*(\\w+):", "MULTILINE"):findAllFactory("one: 1\n  two: 2\nthree 3\nfour:4")):map(____lambda_11):toList()))
    print(__K2L_Regex.new("(\\d+)-(\\d+)"):replace("ranges 1-5, 10-12 and 7-7", function(m)
        local ____destructured_2 = m.destructured:toList():map(____lambda_12)
        local a, b = ____destructured_2[1], ____destructured_2[2]
        return a == b and tostring(a) or __K2L_IntRange.new(a, b):joinToString("+")
    end))
    local ____arg = __K2L_Regex.new("(\\d+)-(\\d+)-(\\d+)"):replace("2024-10-10", "$3/$2/$1") .. " "
    local ____value = __K2L_Regex.escape("a.b*c")
    print(____arg .. tostring(__K2L_Regex.new(____value):matches("a.b*c")))
    local m = __K2L_NotNull(__K2L_Regex.new("(?<key>\\w+)(?:=(?<value>\\w*))?"):find("  flag="))
    local ____arg_1 = __K2L_Str(m.range)
    local ____receiver_2 = m.groups:getNamed("key")
    local ____arg_2 = __K2L_Str(____receiver_2 and ____receiver_2.value)
    local ____receiver_3 = m.groups:getNamed("value")
    local ____arg_3 = __K2L_Str(____receiver_3 and ____receiver_3.value)
    local ____receiver_4 = m.groups:get(2)
    print(____arg_1 .. " " .. ____arg_2 .. " '" .. ____arg_3 .. "' " .. __K2L_Str(____receiver_4 and ____receiver_4.range))
    print(__K2L_Sequence.new(__K2L_Regex.new("x*"):findAllFactory("axxb")):map(____lambda_13):joinToString(" "))
    print(__K2L_Sequence.new(__K2L_Regex.new("[aeiou]", "IGNORE_CASE"):findAllFactory("Regular EXPRESSIONS")):count())
    local ____receiver_5 = __K2L_RunCatching(____lambda_14):exceptionOrNull()
    local ____receiver_6 = ____receiver_5 and __K2L_JavaClass(__K2L_KClassOfValue(____receiver_5))
    print(__K2L_Str(____receiver_6 and (____receiver_6.simpleName or "")))
    local ____list_2 = __K2L_ReadOnlyListOf("[a-", "(?<n>x)(?<n>y)", "ok+")
    for ____i_2 = 1, ____list_2.size do
        local bad = ____list_2[____i_2]
        local ____ok, ____result = __K2L_DeepPcall(function()
            print("compiled " .. __K2L_Regex.new(bad).pattern)
        end)
        if not ____ok then
            local ____error = __K2L_ToThrowable(____result)
            if __K2L_InstanceOf(____error, __K2L_PatternSyntaxException) then
                local e = ____error
                print("bad pattern: " .. tostring(__K2L_InstanceOf(e, __K2L_IllegalArgumentException)))
            else
                error(____error, 0)
            end
        end
    end
end

__K2L_DeepMain(main)
return {Entry = Entry, accessLine = accessLine, appLine = appLine, kvPair = kvPair, traceLine = traceLine, emailish = emailish, token = token, numberedPath = numberedPath, LogReport = LogReport, redact = redact, parseFields = parseFields, analyze = analyze, percentile = percentile, sample = sample}
