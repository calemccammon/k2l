local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CompareByDescending = ____lualib.__K2L_CompareByDescending
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IRem = ____lualib.__K2L_IRem
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringCharAt = ____lualib.__K2L_StringCharAt
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_StringIsBlank = ____lualib.__K2L_StringIsBlank
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringPadEnd = ____lualib.__K2L_StringPadEnd
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ThenBy = ____lualib.__K2L_ThenBy
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32

local TEXT = __K2L_Text.trimIndent("\n    It was the best of times, it was the worst of times, it was the age of wisdom,\n    it was the age of foolishness, it was the epoch of belief, it was the epoch of\n    incredulity, it was the season of Light, it was the season of Darkness, it was\n    the spring of hope, it was the winter of despair.\n")

local function words(self)
    return __K2L_Regex.new("[^A-Za-z']+"):split(self):filter(function(it) return #it > 0 end):map(function(it) return it:lower() end)
end

local function caesar(text, shift)
    return __K2L_StringToList(text):map(function(c)
        if c >= "a" and c <= "z" then
            return string.char(("a"):byte() + __K2L_Num.mod(c:byte() - ("a"):byte() + shift, 26))
        elseif c >= "A" and c <= "Z" then
            return string.char(("A"):byte() + __K2L_Num.mod(c:byte() - ("A"):byte() + shift, 26))
        else
            return c
        end
    end):joinToString("")
end

local function vigenere(text, key, decrypt)
    if decrypt == nil then
        decrypt = false
    end
    local k = 0
    local ____builder = __K2L_StringBuilder.new()
    for c in text:gmatch(".") do
        do
            if c:match("^%a$") == nil then
                ____builder:append(c)
                goto ____continue
            end
            local base = c:match("^%u$") ~= nil and "A" or "a"
            local ____old = k
            k = k + 1
            local shift = __K2L_StringCharAt(key, __K2L_IRem(____old, #key)):lower():byte() - ("a"):byte()
            ____builder:append(string.char(base:byte() + __K2L_Num.mod(c:byte() - base:byte() + (decrypt and -shift or shift), 26)))
        end
        ::____continue::
    end
    return ____builder:toString()
end

local function runLength(s)
    if #s == 0 then
        return ""
    end
    local sb = __K2L_StringBuilder.new()
    local run = 1
    for i = 1, #s do
        if i < #s and __K2L_StringCharAt(s, i) == __K2L_StringCharAt(s, i - 1) then
            run = run + 1
        else
            if run > 1 then
                sb:append(tostring(run))
            end
            sb:append(__K2L_StringCharAt(s, i - 1))
            run = 1
        end
    end
    return sb:toString()
end

local function unRunLength(s)
    return __K2L_Sequence.new(__K2L_Regex.new("(\\d*)(\\D)"):findAllFactory(s)):joinToString("", nil, nil, nil, nil, function(m)
        local ____destructured = m.destructured
        local count, ch = ____destructured[1], ____destructured[2]
        return __K2L_Text.repeatCount(ch, __K2L_StringToInt(__K2L_Text.ifEmpty(count, function() return "1" end)))
    end)
end

local function isPalindrome(s)
    local cleaned = __K2L_Text.filter(s, function(it) return it:match("^%w$") ~= nil end):lower()
    return cleaned == cleaned:reverse()
end

local function longestPalindrome(s)
    local best = ""
    for center = 0, 2 * #s - 1 - 1 do
        local lo = __K2L_IDiv(center, 2)
        local hi = lo + math.fmod(center, 2)
        while lo >= 0 and hi < #s and __K2L_StringCharAt(s, lo) == __K2L_StringCharAt(s, hi) do
            lo = lo - 1
            hi = hi + 1
        end
        local candidate = __K2L_Text.substring(s, lo + 1, hi)
        if #candidate > #best then
            best = candidate
        end
    end
    return best
end

local function wrap(text, width)
    local lines = __K2L_ListOf()
    local line = __K2L_StringBuilder.new()
    local ____list = __K2L_Regex.new("\\s+"):split(text)
    local ____mod = ____list.____modCount
    for ____i = 1, ____list.size do
        local word = ____list[____i]
        if line:isNotEmpty() and line:getLength() + 1 + #word > width then
            lines:add(line:toString())
            line:clear()
        end
        if line:isNotEmpty() then
            line:append(" ")
        end
        line:append(word)
        if ____list.____modCount ~= ____mod and ____list:____comodified(____i) then
            break
        end
    end
    if line:isNotEmpty() then
        lines:add(line:toString())
    end
    return lines
end

local function justify(line, width)
    local words = __K2L_StringSplit(line, " ")
    if words.size == 1 then
        return __K2L_StringPadEnd(line, width)
    end
    local gaps = words.size - 1
    local spaces = width - words:sumOf(function(it) return #it end)
    return words:mapIndexed(function(i, w)
        if i == gaps then
            return w
        else
            return w .. __K2L_Text.repeatCount(" ", __K2L_IDiv(spaces, gaps) + (i < __K2L_IRem(spaces, gaps) and 1 or 0))
        end
    end):joinToString("")
end

local function render(template, values)
    return __K2L_Regex.new("\\{\\{\\s*(\\w+)(?:\\|(\\w+))?\\s*}}"):replace(template, function(m)
        local ____destructured_1 = m.destructured
        local name, filter = ____destructured_1[1], ____destructured_1[2]
        local ____receiver = values:get(name)
        local value = ____receiver and __K2L_Str(____receiver) or "<" .. name .. "?>"
        if filter == "" then
            return value
        elseif filter == "upper" then
            return value:upper()
        elseif filter == "title" then
            return __K2L_StringSplit(value, " "):joinToString(" ", nil, nil, nil, nil, function(w)
                return __K2L_Text.replaceFirstChar(w, function(it) return it:upper() end)
            end)
        elseif filter == "len" then
            return tostring(#value)
        else
            error(__K2L_IllegalArgumentException.new("unknown filter '" .. filter .. "'"))
        end
    end)
end

local LogEntry = __K2L_Class("LogEntry")

function LogEntry:____init(time, level, component, message)
    self.time = time
    self.level = level
    self.component = component
    self.message = message
end

function LogEntry:toString()
    return "LogEntry(time=" .. self.time .. ", level=" .. self.level .. ", component=" .. self.component .. ", message=" .. self.message .. ")"
end

function LogEntry:hashCode()
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.time) + __K2L_Hash(self.level)) + __K2L_Hash(self.component)) + __K2L_Hash(self.message))
end

function LogEntry:equals(other)
    return getmetatable(other) == LogEntry and self.time == other.time and self.level == other.level and self.component == other.component and self.message == other.message
end

local LOG = "\n    2024-05-01T10:00:01 INFO  [db] connection pool started (size=10)\n    2024-05-01T10:00:02 WARN  [http] slow request: GET /api/items took 1532ms\n    2024-05-01T10:00:05 ERROR [db] query failed: timeout after 3000ms\n    garbage line without structure\n    2024-05-01T10:00:07 INFO  [http] GET /api/items 200 in 87ms\n    2024-05-01T10:00:09 ERROR [auth] invalid token for user=alice\n    2024-05-01T10:00:12 INFO  [http] POST /api/orders 201 in 143ms\n"

local function parseLog(text)
    local re = __K2L_Regex.new("^(\\S+)\\s+(INFO|WARN|ERROR)\\s+\\[(\\w+)]\\s+(.*)$")
    local bad = 0
    local entries = __K2L_StringLines(__K2L_Text.trimIndent(text)):filter(function(____p1) return not __K2L_StringIsBlank(____p1) end):mapNotNull(function(line)
        local ____receiver_1 = re:matchEntire(line)
        local ____receiver_2 = ____receiver_1 and ____receiver_1.groupValues
        local ____result_1
        if ____receiver_2 ~= nil then
            local ____result
            do
                local t, l, c, m = ____receiver_2[2], ____receiver_2[3], ____receiver_2[4], ____receiver_2[5]
                ____result = LogEntry.new(t, l, c, m)
            end
            ____result_1 = ____result
        end
        local ____value = ____result_1
        if ____value == nil then
            local ____result_2
            bad = bad + 1
            ____result_2 = nil
            ____value = ____result_2
        end
        return ____value
    end)
    return __K2L_Pair.new(entries, bad)
end

local function main()
    local words = words(TEXT)
    print("words=" .. words.size .. " distinct=" .. words:toSet().size .. " chars=" .. #TEXT .. " lines=" .. __K2L_StringLines(TEXT).size)
    local freq = words:groupingBy(function(it) return it end):eachCount()
    local top = freq:getEntries():sortedWith(__K2L_ThenBy(__K2L_CompareByDescending(function(it) return it.value end), function(it) return it.key end)):take(5)
    print("top: " .. top:joinToString(nil, nil, nil, nil, nil, function(it) return it.key .. "=" .. it.value end))
    print("longest words: " .. __K2L_Str(words:distinct():sortedByDescending(function(it) return #it end, true):take(3)))
    print("by length: " .. __K2L_Str(words:distinct():groupBy(function(it) return #it end):toSortedMap():mapValues(function(it) return it.value.size end)))
    print("letters: " .. __K2L_Str(__K2L_StringToList(__K2L_Text.filter(TEXT:lower(), function(it) return it:match("^%a$") ~= nil end)):groupingBy(function(it) return it end):eachCount():getEntries():sortedByDescending(function(it) return it.value end, true):take(4):map(function(it) return it.key .. ":" .. it.value end)))
    print("capitalized: " .. __K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("\\b[A-Z]\\w*"):findAllFactory(TEXT)):map(function(it) return it.value end):toList()))
    print("sentence case: " .. __K2L_Str(__K2L_StringSplit(__K2L_StringLines(TEXT):first(), ", "):map(function(it)
        return __K2L_Text.replaceFirstChar(it, function(____p1) return ____p1:upper() end)
    end)))
    local list = __K2L_ReadOnlyListOf("listen", "silent", "enlist", "google", "gooegl", "cat", "act", "tac", "dog")
    local anagrams = list:groupBy(function(it)
        return __K2L_Text.toCharArray(it):sorted():joinToString("")
    end):getValues():filter(function(it) return it.size > 1 end)
    print("anagrams: " .. __K2L_Str(anagrams))
    local secret = caesar("Hello, World! xyz", 3)
    print("caesar: " .. secret .. " -> " .. caesar(secret, -3))
    local v = vigenere("Attack at dawn!", "Lemon")
    print("vigenere: " .. v .. " -> " .. vigenere(v, "Lemon", true))
    print("rot13 twice: " .. caesar(caesar("Why did the chicken cross the road?", 13), 13))
    local ____list_1 = __K2L_ReadOnlyListOf("WWWWWWWWWWWWBWWWWWWWWWWWWBBBWWWWWWWWWWWWWWWWWWWWWWWWBWWWWWWWWWWWWWW", "abc", "aabcccccaaa", "")
    for ____i_1 = 1, ____list_1.size do
        local s = ____list_1[____i_1]
        local enc = runLength(s)
        if unRunLength(enc) ~= s then
            error(__K2L_IllegalStateException.new("round trip failed for " .. s))
        end
        print("rle: '" .. __K2L_Text.take(s, 12) .. (#s > 12 and "…" or "") .. "' -> '" .. enc .. "'")
    end
    local phrases = __K2L_ReadOnlyListOf("A man, a plan, a canal: Panama", "race a car", "No 'x' in Nixon", "Was it a car or a cat I saw?")
    local ____mod_1 = phrases.____modCount
    for ____i_2 = 1, phrases.size do
        local it = phrases[____i_2]
        print("palindrome? " .. __K2L_StringPadEnd(tostring(isPalindrome(it)), 5) .. " " .. it)
        if phrases.____modCount ~= ____mod_1 and phrases:____comodified(____i_2) then
            break
        end
    end
    print("longest palindromes: " .. __K2L_Str(__K2L_ReadOnlyListOf("babad", "cbbd", "forgeeksskeegfor", "abacdfgdcaba"):map(longestPalindrome)))
    local lines = wrap(__K2L_StringReplace(TEXT, "\n", " "), 36)
    local ____mod_2 = lines.____modCount
    for ____i_3 = 1, lines.size do
        local l = lines[____i_3]
        local i = ____i_3 - 1
        print("|" .. (i == lines.size - 1 and __K2L_StringPadEnd(l, 36) or justify(l, 36)) .. "|")
        if lines.____modCount ~= ____mod_2 and lines:____comodified(____i_3) then
            break
        end
    end
    local tpl = "Dear {{ name|title }}, your order #{{id}} of {{ count }} {{item|upper}} ships {{when}}. ({{name|len}})"
    print(render(tpl, __K2L_ReadOnlyMapOf(__K2L_Pair.new("name", "ada lovelace"), __K2L_Pair.new("id", 1042), __K2L_Pair.new("count", 3), __K2L_Pair.new("item", "widgets"), __K2L_Pair.new("when", nil))))
    local ____receiver_3 = __K2L_RunCatching(function()
        return render("{{x|bogus}}", __K2L_SingletonMapOf(__K2L_Pair.new("x", 1)))
    end):exceptionOrNull()
    print(__K2L_Str(____receiver_3 and ____receiver_3.message))
    local ____destructured_2 = parseLog(LOG)
    local entries, bad = ____destructured_2.first, ____destructured_2.second
    print("log: " .. entries.size .. " entries, " .. bad .. " malformed")
    print("levels: " .. __K2L_Str(entries:groupingBy(function(it) return it.level end):eachCount()))
    local durations = entries:mapNotNull(function(it)
        local ____receiver_4 = __K2L_Regex.new("(\\d+)ms"):find(it.message)
        local ____receiver_5 = ____receiver_4 and ____receiver_4.groupValues
        local ____receiver_6 = ____receiver_5 and ____receiver_5:get(1)
        return ____receiver_6 and __K2L_StringToInt(____receiver_6)
    end)
    print("durations: " .. __K2L_Str(durations) .. " avg=" .. __K2L_StringFormat("%.1f", durations:average()))
    local ____list_2 = entries:filter(function(it) return it.level == "ERROR" end)
    local ____mod_3 = ____list_2.____modCount
    for ____i_4 = 1, ____list_2.size do
        local ____it_1 = ____list_2[____i_4]
        do
            local time, comp, msg = ____it_1.time, ____it_1.component, ____it_1.message
            print("  " .. __K2L_Text.substringAfter(time, "T") .. " " .. comp .. ": " .. __K2L_Text.substringBefore(msg, ":"))
        end
        if ____list_2.____modCount ~= ____mod_3 and ____list_2:____comodified(____i_4) then
            break
        end
    end
    local paths = entries:flatMap(function(it)
        return __K2L_Sequence.new(__K2L_Regex.new("(GET|POST) (\\S+)"):findAllFactory(it.message)):map(function(m) return m.groupValues:get(2) end):toList()
    end)
    print("paths: " .. __K2L_Str(paths:distinct()) .. " kv: " .. __K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("(\\w+)=(\\w+)"):findAllFactory(LOG)):associate(function(it)
        return __K2L_Pair.new(it.groupValues:get(1), it.groupValues:get(2))
    end)))
    print("snake: " .. __K2L_Regex.new("([a-z])([A-Z])"):replace("parseHttpResponseCode", "$1_$2"):lower() .. " camel: " .. __K2L_StringSplit("max_retry_count", "_"):mapIndexed(function(i, p)
        if i == 0 then
            return p
        else
            return __K2L_Text.replaceFirstChar(p, function(it) return it:upper() end)
        end
    end):joinToString(""))
    print("chars: " .. __K2L_Str(__K2L_StringToList("Hello"):map(function(it) return it:byte() end)) .. " " .. __K2L_Str(__K2L_StringToList("Kotlin"):withIndex():filter(function(it) return math.fmod(it.index, 2) == 0 end):map(function(it) return it.value end)) .. " " .. __K2L_Str(__K2L_Text.split("a-b-c", {"-"}, 2)))
end

main()
return {TEXT = TEXT, words = words, caesar = caesar, vigenere = vigenere, runLength = runLength, unRunLength = unRunLength, isPalindrome = isPalindrome, longestPalindrome = longestPalindrome, wrap = wrap, justify = justify, render = render, LogEntry = LogEntry, LOG = LOG, parseLog = parseLog}
