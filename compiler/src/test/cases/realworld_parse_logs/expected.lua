local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StrByte = ____lualib.__K2L_StrByte
local __K2L_StringIsBlank = ____lualib.__K2L_StringIsBlank
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_Text = ____lualib.__K2L_Text

local Entry = __K2L_Class("Entry")

function Entry.new(time, level, source, message, fields)
    return setmetatable({time = time, level = level, source = source, message = message, fields = fields}, Entry)
end

__K2L_DataClass(Entry, {"time", "level", "source", "message", "fields"})
local accessLine = __K2L_Regex.new("^(\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}) - (\\S+) \\[([^\\]]+)] \"([A-Z]+) (\\S+) HTTP/[\\d.]+\" (\\d{3}) ([\\d-]+)(.*)$", "^(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?) %- (%S+) %[([^%]]+)%] \"([A-Z]+) (%S+) HTTP/[%d%.]+\" (%d%d%d) ([%d%-]+)([^\n\r]*)$")
local accessMs = __K2L_Regex.new(" (\\d+)ms", " (%d+)ms")
local appLine = __K2L_Regex.new("^(\\d{2}:\\d{2}:\\d{2}\\.?\\d*)\\s+\\[([a-z]+)]\\s+([\\w.$]+):\\s*(.*)$", "^(%d%d:%d%d:%d%d%.?%d*)%s+%[([a-zA-Z]+)%]%s+([%w_%.%$]+):%s*([^\n\r]*)$")
local levels = __K2L_SetOf("trace", "debug", "info", "warn", "error")
local kvKey = __K2L_Regex.new("(\\w+)=", "([%w_]+)=")
local nonBlank = __K2L_Regex.new("\\S+", "%S+")
local traceLine = __K2L_Regex.new("^\\s+at\\s+([\\w.$<>]+)\\((\\w+\\.\\w+):(\\d+)\\)", "^%s+at%s+([%w_%.%$%<%>]+)%(([%w_]+%.[%w_]+):(%d+)%)")
local emailish = __K2L_Regex.new("([\\w.+-]+)@([\\w-]+\\.[\\w.-]*\\w)\\b", "([%w_%.%+%-]+)@([%w_%-]+%.[%w_%.%-]*[%w_])%f[^%w_]")
local assignment = __K2L_Regex.new("(\\w+)=\\S+", "([%w_]+)=%S+")
local secrets = __K2L_SetOf("token", "password", "secret")
local digits = __K2L_Regex.new("\\d+", "%d+")
local LogReport = __K2L_Class("LogReport")

function LogReport:____init()
    self.entries = __K2L_ListOf()
    self.unparsed = __K2L_ListOf()
    self.traces = __K2L_MapOf()
    self.latency = __K2L_SortedMapOf(nil)
    self.statuses = __K2L_MapOf()
end

local ____lambda_1 = function(m)
    return __K2L_Text.first(m.groupValues:get(1)) .. "…@" .. m.groupValues:get(2)
end
local function redact(s)
    return emailish:replace(assignment:replace(s, function(m)
        local key = m.groupValues:get(1):lower()
        return secrets:contains(key) and key .. "=***" or m.value
    end), ____lambda_1)
end

local function quotedAt(s, start)
    local i = start + 1
    while i < #s and (i >= 0 and __K2L_StrByte(s, i + 1) or __K2L_IndexError(i, #s, "string")) ~= 34 do
        i = i + ((i >= 0 and __K2L_StrByte(s, i + 1) or __K2L_IndexError(i, #s, "string")) == 92 and 2 or 1)
    end
    return i < #s and __K2L_Text.substring(s, start, i + 1) or nil
end

local function parseFields(msg)
    local fields = __K2L_MapOf()
    local from = 0
    while from < #msg do
        local ____value = kvKey:find(msg, from)
        if ____value == nil then
            break
        end
        local key = ____value
        local at = key.range.last + 1
        local ____temp
        if msg:sub(at + 1, at + #"\"") == "\"" then
            ____temp = quotedAt(msg, at)
        else
            ____temp = nil
        end
        local ____value_1 = ____temp
        if ____value_1 == nil then
            local ____receiver = nonBlank:matchAt(msg, at)
            ____value_1 = ____receiver and ____receiver.value
        end
        local raw = ____value_1
        if raw ~= nil then
            local ____key = key.groupValues:get(1)
            fields:set(____key, __K2L_StringStartsWith(raw, "\"") and __K2L_StringReplace(__K2L_Text.substring(raw, 1, #raw - 1), "\\\"", "\"") or raw)
        end
        from = at + (raw and #raw or 0)
    end
    return fields
end

local ____lambda_2 = function(it) return digits:matches(it) and "{id}" or it end
local function route(path)
    return __K2L_StringSplit(path, "/"):joinToString("/", nil, nil, nil, nil, ____lambda_2)
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
            local ____receiver_1 = accessLine:matchEntire(line)
            local access = ____receiver_1 and ((#____receiver_1.groupValues:get(8) == 0 or accessMs:matches(____receiver_1.groupValues:get(8))) and ____receiver_1 or nil)
            local ____receiver_2 = appLine:matchEntire(line)
            local app = ____receiver_2 and (levels:contains(____receiver_2.groupValues:get(2):lower()) and ____receiver_2 or nil)
            local trace = traceLine:find(line)
            if access ~= nil then
                local ____destructured_2 = access.destructured
                local ip, time, method, path = ____destructured_2[1], ____destructured_2[3], ____destructured_2[4], ____destructured_2[5]
                local g = access.groupValues
                local ____route = route(__K2L_Text.substringBefore(path, "?"))
                local status = __K2L_StringToInt(g:get(6))
                r.statuses:merge(status // 100 * 100, 1, ____lambda_3)
                local ____receiver_3 = accessMs:matchEntire(g:get(8))
                if ____receiver_3 ~= nil then
                    r.latency:getOrPut(method .. " " .. ____route, ____lambda_4):add(__K2L_StringToInt(____receiver_3.groupValues:get(1)))
                end
                local fields = __K2L_MapOf(__K2L_Pair.new("ip", ip), __K2L_Pair.new("status", tostring(status)), __K2L_Pair.new("bytes", __K2L_StringReplace(g:get(7), "-", "0")))
                r.entries:add(Entry.new(__K2L_Text.substringBefore(__K2L_Text.substringAfter(time, ":"), " "), status >= 500 and "ERROR" or "INFO", "http", ____route, fields))
                lastApp = -1
            elseif app ~= nil then
                local ____destructured_1 = app.destructured
                local time, level, source, message = ____destructured_1[1], ____destructured_1[2], ____destructured_1[3], ____destructured_1[4]
                local msg = redact(message)
                r.entries:add(Entry.new(time, level:upper(), source, msg, parseFields(msg)))
                lastApp = r.entries.size - 1
            elseif trace ~= nil and lastApp >= 0 then
                local ____destructured = trace.destructured
                local method, file, lineNo = ____destructured[1], ____destructured[2], ____destructured[3]
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
    local rank = __K2L_Num.coerceIn(math.ceil(p / 100.0 * sorted.size), 1, sorted.size)
    return sorted:get(rank - 1)
end

local sample = __K2L_Text.trimIndent("\n127.0.0.1 - - [10/Oct/2024:13:55:36 +0000] \"GET /api/users/42?verbose=1 HTTP/1.1\" 200 2326 12ms\n10.0.0.7 - alice [10/Oct/2024:13:55:37 +0000] \"POST /api/users HTTP/1.1\" 201 512 48ms\n10.0.0.7 - alice [10/Oct/2024:13:55:38 +0000] \"GET /api/users/7/orders/19 HTTP/2.0\" 200 9001 33ms\n13:55:39.120 [INFO] app.Server: started port=8080 workers=4 mode=\"blue green\"\n13:55:40 [warn] app.Auth: login failed user=bob@example.com token=abc123XYZ attempts=3\n192.168.1.20 - - [10/Oct/2024:13:55:41 +0000] \"GET /health HTTP/1.1\" 204 - 1ms\n13:55:42.5 [Error] app.Db" .. "$" .. "Pool: query failed sql=\"select * from \\\"users\\\"\" elapsed=1500\n    at app.Db" .. "$" .. "Pool.run(Db.kt:88)\n    at app.Service.load(Service.kt:12)\nCaused by: java.net.SocketTimeoutException: Read timed out\n    at java.net.Socket.read(Socket.java:204)\n10.0.0.9 - - [10/Oct/2024:13:55:43 +0000] \"DELETE /api/users/42 HTTP/1.1\" 500 87 230ms\ngarbage line with no format\n13:55:44 [DEBUG] app.Cache: evicted keys=17 Password=hunter2 contact=Ops.Team+pager@corp.example.org\n10.0.0.9 - - [10/Oct/2024:13:55:45 +0000] \"GET /api/users/1 HTTP/1.1\" 304 0 3ms\n13:55:46 [fatal] app.Main: unknown level\n    at app.Main.main(Main.kt:1)\n")

local ____lambda_7 = function(it) return it.key .. "=<" .. it.value .. ">" end
local ____lambda_8 = function(it)
    return "#" .. it.first .. " '" .. __K2L_Text.take(it.second, 20) .. "'"
end
local ____lambda_9 = function(it) return it.level end
local ____lambda_10 = function(it) return it.second end
local ____lambda_11 = function(____p1) return __K2L_StringToInt(____p1) end
local ____lambda_12 = function(it) return it.range.first .. ":" .. it.value end
local function main()
    local r = analyze(sample)
    local ____list_1 = r.entries
    for i = 0, ____list_1.size - 1 do
        local e = ____list_1[i + 1]
        print(string.format("%-12s %-5s %-10s %s", e.time, e.level, e.source, e.message))
        if e.fields:isNotEmpty() then
            print("    fields " .. e.fields:getEntries():joinToString(", ", nil, nil, nil, nil, ____lambda_7))
        end
        local ____receiver_4 = r.traces:get(i)
        if ____receiver_4 ~= nil then
            for ____i = 1, ____receiver_4.size do
                local it = ____receiver_4[____i]
                print("    | " .. it)
            end
        end
    end
    print("unparsed: " .. r.unparsed:joinToString(nil, nil, nil, nil, nil, ____lambda_8))
    print("status classes: " .. __K2L_Str(r.statuses:toSortedMap()))
    local ____map = r.latency
    local ____keys, ____values, ____n = ____map:____arrays()
    for ____i_1 = 1, ____n do
        local ____route_1, ms = ____keys[____i_1], ____values[____i_1]
        print(string.format("  %-28s n=%d p50=%d p90=%d max=%d avg=%.1f", __K2L_Str(____route_1), ms.size, percentile(ms, 50), percentile(ms, 90), ms:max(), ms:average()))
    end
    local levels = r.entries:groupingBy(____lambda_9):eachCount():toList():sortedByDescending(____lambda_10, true)
    print(__K2L_Str(levels))
    local csvish = "a, b;c ;; d,e"
    print(__K2L_Str(__K2L_Regex.new("\\s*[,;]\\s*", "%s*[%,%;]%s*"):split(csvish)))
    print(__K2L_Str(__K2L_Regex.new("\\s*[,;]\\s*", "%s*[%,%;]%s*"):split(csvish, 3)))
    print(__K2L_Str(__K2L_StringSplit(__K2L_Regex.new("([A-Z])([A-Z][a-z])", "([A-Z])([A-Z][a-z])"):replace(__K2L_Regex.new("([a-z])([A-Z])", "([a-z])([A-Z])"):replace("CamelCaseHTTPServerName", "$1 $2"), "$1 $2"), " ")))
    local ____list_2 = __K2L_StringLines("one: 1\n  two: 2\nthree 3\nfour:4")
    local ____out = {}
    local ____count = 0
    local ____items, ____n_1 = ____list_2:____array()
    for ____i_2 = 1, ____n_1 do
        local it = ____items[____i_2]
        local ____result
        do
            local ____receiver_5 = __K2L_Regex.new("^\\s*(\\w+):", "^%s*([%w_]+):"):find(it)
            local ____receiver_6 = ____receiver_5 and ____receiver_5.groupValues
            ____result = ____receiver_6 and ____receiver_6:get(1)
        end
        local ____value_2 = ____result
        if ____value_2 ~= nil then
            ____count = ____count + 1
            ____out[____count] = ____value_2
        end
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    print(__K2L_Regex.new("(\\d+)-(\\d+)", "(%d+)%-(%d+)"):replace("ranges 1-5, 10-12 and 7-7", function(m)
        local ____destructured_3 = m.destructured:toList():map(____lambda_11)
        local a, b = ____destructured_3[1], ____destructured_3[2]
        return a == b and tostring(a) or __K2L_IntRange.new(a, b):joinToString("+")
    end))
    print(__K2L_Regex.new("(\\d+)-(\\d+)-(\\d+)", "(%d+)%-(%d+)%-(%d+)"):replace("2024-10-10", "$3/$2/$1") .. " " .. tostring(__K2L_Regex.new("\\Qa.b*c\\E", "a%.b%*c"):matches("a.b*c")))
    local m = __K2L_NotNull(__K2L_Regex.new("(\\w+)=?(\\w*)", "([%w_]+)=?([%w_]*)"):find("  flag="))
    local ____arg = __K2L_Str(m.range)
    local ____receiver_7 = m.groups:get(1)
    local ____arg_1 = __K2L_Str(____receiver_7 and ____receiver_7.value)
    local ____receiver_8 = m.groups:get(2)
    print(____arg .. " " .. ____arg_1 .. " '" .. __K2L_Str(____receiver_8 and ____receiver_8.value) .. "'")
    print(__K2L_Sequence.new(__K2L_Regex.new("x*", "x*"):findAllFactory("axxb")):map(____lambda_12):joinToString(" "))
    print(__K2L_Sequence.new(__K2L_Regex.new("[aeiou]", "[aAeEiIoOuU]"):findAllFactory("Regular EXPRESSIONS")):count())
    local ____list_3 = __K2L_ListOf("(unclosed", "[a-", "a|b", "ok+")
    for ____i_3 = 1, ____list_3.size do
        local needle = ____list_3[____i_3]
        print("literal " .. needle .. ": " .. tostring(__K2L_Regex.fromLiteral(needle):containsMatchIn("x (unclosed a|b [a-")))
    end
end

__K2L_RunMain(main)
return {Entry = Entry, accessLine = accessLine, accessMs = accessMs, appLine = appLine, levels = levels, kvKey = kvKey, nonBlank = nonBlank, traceLine = traceLine, emailish = emailish, assignment = assignment, secrets = secrets, digits = digits, LogReport = LogReport, redact = redact, quotedAt = quotedAt, parseFields = parseFields, route = route, analyze = analyze, percentile = percentile, sample = sample}
