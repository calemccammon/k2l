local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CompareValues = ____lualib.__K2L_CompareValues
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_IsLetter = ____lualib.__K2L_IsLetter
local __K2L_IsLetterOrDigit = ____lualib.__K2L_IsLetterOrDigit
local __K2L_IsUpperCase = ____lualib.__K2L_IsUpperCase
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringCharAt = ____lualib.__K2L_StringCharAt
local __K2L_StringIsBlank = ____lualib.__K2L_StringIsBlank
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringPadEnd = ____lualib.__K2L_StringPadEnd
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_Text = ____lualib.__K2L_Text

local TEXT = __K2L_Text.trimIndent("\n    It was the best of times, it was the worst of times, it was the age of wisdom,\n    it was the age of foolishness, it was the epoch of belief, it was the epoch of\n    incredulity, it was the season of Light, it was the season of Darkness, it was\n    the spring of hope, it was the winter of despair.\n")

local function words(self)
    local ____list = __K2L_Regex.new("[^A-Za-z']+", "[^A-Za-z%']+"):split(self)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        if #it > 0 then
            ____count = ____count + 1
            ____out[____count] = it
        end
    end
    local ____list_1 = __K2L_ListWrap(____out, ____count)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = it:lower()
    end
    return __K2L_ListWrap(____out_1, ____count_1)
end

local function caesar(text, shift)
    return __K2L_StringToList(text):map(function(c)
        if c >= "a" and c <= "z" then
            return string.char(("a"):byte() + (c:byte() - ("a"):byte() + shift) % 26)
        elseif c >= "A" and c <= "Z" then
            return string.char(("A"):byte() + (c:byte() - ("A"):byte() + shift) % 26)
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
    for ____i_2 = 1, #text do
        local c = text:sub(____i_2, ____i_2)
        do
            if __K2L_IsLetter[c] ~= true then
                ____builder:append(c)
                goto ____continue
            end
            local base = __K2L_IsUpperCase[c] == true and "A" or "a"
            local ____old = k
            k = k + 1
            local shift = __K2L_StringCharAt(key, ____old % #key):lower():byte() - ("a"):byte()
            ____builder:append(string.char(base:byte() + (c:byte() - base:byte() + (decrypt and -shift or shift)) % 26))
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
        if i < #s and (i >= 0 and i < #s and s:sub(i + 1, i + 1) or __K2L_IndexError(i, #s, "string")) == (i - 1 >= 0 and i - 1 < #s and s:sub(i - 1 + 1, i - 1 + 1) or __K2L_IndexError(i - 1, #s, "string")) then
            run = run + 1
        else
            if run > 1 then
                sb:append(tostring(run))
            end
            sb:append(i - 1 >= 0 and i - 1 < #s and s:sub(i - 1 + 1, i - 1 + 1) or __K2L_IndexError(i - 1, #s, "string"))
            run = 1
        end
    end
    return sb:toString()
end

local ____lambda_1 = function() return "1" end
local function unRunLength(s)
    return __K2L_Sequence.new(__K2L_Regex.new("(\\d*)(\\D)", "(%d*)(%D)"):findAllFactory(s)):joinToString("", nil, nil, nil, nil, function(m)
        local ____destructured = m.destructured
        local count, ch = ____destructured[1], ____destructured[2]
        return __K2L_Text.repeatCount(ch, __K2L_StringToInt(__K2L_Text.ifEmpty(count, ____lambda_1)))
    end)
end

local ____lambda_2 = function(it) return __K2L_IsLetterOrDigit[it] == true end
local function isPalindrome(s)
    local cleaned = __K2L_Text.filter(s, ____lambda_2):lower()
    return cleaned == cleaned:reverse()
end

local function longestPalindrome(s)
    local best = ""
    for center = 0, 2 * #s - 1 - 1 do
        local lo = center // 2
        local hi = lo + center % 2
        while lo >= 0 and hi < #s and (lo >= 0 and lo < #s and s:sub(lo + 1, lo + 1) or __K2L_IndexError(lo, #s, "string")) == (hi >= 0 and hi < #s and s:sub(hi + 1, hi + 1) or __K2L_IndexError(hi, #s, "string")) do
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
    local ____list_2 = __K2L_Regex.new("\\s+", "%s+"):split(text)
    for ____i_3 = 1, ____list_2.size do
        local word = ____list_2[____i_3]
        if line:isNotEmpty() and line:getLength() + 1 + #word > width then
            lines:add(line:toString())
            line:clear()
        end
        if line:isNotEmpty() then
            line:append(" ")
        end
        line:append(word)
    end
    if line:isNotEmpty() then
        lines:add(line:toString())
    end
    return lines
end

local function justify(line, width)
    local ____words = __K2L_StringSplit(line, " ")
    if ____words.size == 1 then
        return __K2L_StringPadEnd(line, width)
    end
    local gaps = ____words.size - 1
    local ____sum = 0
    local ____items_2, ____n_2 = ____words:____array()
    for ____i_4 = 1, ____n_2 do
        local it = ____items_2[____i_4]
        ____sum = ____sum + #it
    end
    local spaces = width - ____sum
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_3, ____n_3 = ____words:____array()
    for ____i_5 = 1, ____n_3 do
        local w = ____items_3[____i_5]
        local i = ____i_5 - 1
        local ____result
        if i == gaps then
            ____result = w
        else
            ____result = w .. __K2L_Text.repeatCount(" ", spaces // gaps + (i < spaces % gaps and 1 or 0))
        end
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = ____result
    end
    return __K2L_ListWrap(____out_2, ____count_2):joinToString("")
end

local ____lambda_3 = function(it) return it:upper() end
local ____lambda_4 = function(w)
    return __K2L_Text.replaceFirstChar(w, ____lambda_3)
end
local function render(template, values)
    return __K2L_Regex.new("\\{\\{\\s*(\\w+)\\|?(\\w*)\\s*}}", "{{%s*([%w_]+)|?([%w_]*)%s*}}"):replace(template, function(m)
        local ____destructured_1 = m.destructured
        local name, filter = ____destructured_1[1], ____destructured_1[2]
        local ____receiver = values:get(name)
        local value = ____receiver and __K2L_Str(____receiver) or "<" .. name .. "?>"
        if filter == "" then
            return value
        elseif filter == "upper" then
            return value:upper()
        elseif filter == "title" then
            return __K2L_StringSplit(value, " "):joinToString(" ", nil, nil, nil, nil, ____lambda_4)
        elseif filter == "len" then
            return tostring(#value)
        else
            error(__K2L_IllegalArgumentException.new("unknown filter '" .. filter .. "'"))
        end
    end)
end

local LogEntry = __K2L_Class("LogEntry")

function LogEntry.new(time, level, component, message)
    return setmetatable({time = time, level = level, component = component, message = message}, LogEntry)
end

__K2L_DataClass(LogEntry, {"time", "level", "component", "message"})
local LOG = "\n    2024-05-01T10:00:01 INFO  [db] connection pool started (size=10)\n    2024-05-01T10:00:02 WARN  [http] slow request: GET /api/items took 1532ms\n    2024-05-01T10:00:05 ERROR [db] query failed: timeout after 3000ms\n    garbage line without structure\n    2024-05-01T10:00:07 INFO  [http] GET /api/items 200 in 87ms\n    2024-05-01T10:00:09 ERROR [auth] invalid token for user=alice\n    2024-05-01T10:00:12 INFO  [http] POST /api/orders 201 in 143ms\n"

local ____lambda_5 = function(____p1) return not __K2L_StringIsBlank(____p1) end
local function parseLog(text)
    local re = __K2L_Regex.new("^(\\S+)\\s+([A-Z]+)\\s+\\[(\\w+)]\\s+(.*)$", "^(%S+)%s+([A-Z]+)%s+%[([%w_]+)%]%s+([^\n\r]*)$")
    local levels = __K2L_SetOf("INFO", "WARN", "ERROR")
    local bad = 0
    local ____list_3 = __K2L_StringLines(__K2L_Text.trimIndent(text)):filter(____lambda_5)
    local ____out_3 = {}
    local ____count_3 = 0
    local ____items_4, ____n_4 = ____list_3:____array()
    for ____i_6 = 1, ____n_4 do
        local line = ____items_4[____i_6]
        local ____result_1
        do
            local ____receiver_1 = re:matchEntire(line)
            local ____receiver_2 = ____receiver_1 and ____receiver_1.groupValues
            local ____receiver_3 = ____receiver_2 and (levels:contains(____receiver_2:get(2)) and ____receiver_2 or nil)
            local ____result_3
            if ____receiver_3 ~= nil then
                local ____result_2
                do
                    local t, l, c, m = ____receiver_3[2], ____receiver_3[3], ____receiver_3[4], ____receiver_3[5]
                    ____result_2 = LogEntry.new(t, l, c, m)
                end
                ____result_3 = ____result_2
            end
            local ____value = ____result_3
            if ____value == nil then
                local ____result_4
                bad = bad + 1
                ____result_4 = nil
                ____value = ____result_4
            end
            ____result_1 = ____value
        end
        local ____value_1 = ____result_1
        if ____value_1 ~= nil then
            ____count_3 = ____count_3 + 1
            ____out_3[____count_3] = ____value_1
        end
    end
    local entries = __K2L_ListWrap(____out_3, ____count_3)
    return __K2L_Pair.new(entries, bad)
end

local ____lambda_6 = function(it) return it end
local ____lambda_7 = function(____a, ____b)
    local ____x_1, ____y_1 = ____b.value, ____a.value
    if ____x_1 ~= ____y_1 then
        return ____x_1 < ____y_1 and -1 or 1
    end
    return __K2L_CompareValues(____a.key, ____b.key)
end
local ____lambda_8 = function(it) return it.key .. "=" .. it.value end
local ____lambda_9 = function(it) return #it end
local ____lambda_10 = function(it) return it.value.size end
local ____lambda_11 = function(it) return __K2L_IsLetter[it] == true end
local ____lambda_12 = function(it) return it end
local ____lambda_13 = function(it) return it.value end
local ____lambda_14 = function(it) return it.value end
local ____lambda_15 = function(____p1) return ____p1:upper() end
local ____lambda_16 = function()
    return render("{{x|bogus}}", __K2L_MapOf(__K2L_Pair.new("x", 1)))
end
local ____lambda_17 = function(it) return it.level end
local ____lambda_18 = function(m)
    return __K2L_SetOf("GET", "POST"):contains(m.groupValues:get(1))
end
local ____lambda_19 = function(m) return m.groupValues:get(2) end
local ____lambda_20 = function(it)
    return __K2L_Pair.new(it.groupValues:get(1), it.groupValues:get(2))
end
local ____lambda_21 = function(it) return it:upper() end
local ____lambda_22 = function(it) return it:byte() end
local ____lambda_23 = function(it) return it.index % 2 == 0 end
local function main()
    local ____words_1 = words(TEXT)
    print("words=" .. ____words_1.size .. " distinct=" .. ____words_1:toSet().size .. " chars=" .. #TEXT .. " lines=" .. __K2L_StringLines(TEXT).size)
    local freq = ____words_1:groupingBy(____lambda_6):eachCount()
    local top = freq:getEntries():sortedWith(____lambda_7):take(5)
    print("top: " .. top:joinToString(nil, nil, nil, nil, nil, ____lambda_8))
    print("longest words: " .. __K2L_Str(____words_1:distinct():sortedByDescending(____lambda_9, true):take(3)))
    local ____list_4 = ____words_1:distinct()
    local ____result_5 = __K2L_Map.new()
    local ____items_5, ____n_5 = ____list_4:____array()
    for ____i_7 = 1, ____n_5 do
        local it = ____items_5[____i_7]
        local ____value_2 = #it
        local ____group = ____result_5:get(____value_2)
        if ____group == nil then
            ____group = __K2L_List.new()
            ____result_5:put(____value_2, ____group)
        end
        ____group:add(it)
    end
    print("by length: " .. __K2L_Str(____result_5:toSortedMap():mapValues(____lambda_10)))
    local ____list_5 = __K2L_StringToList(__K2L_Text.filter(TEXT:lower(), ____lambda_11)):groupingBy(____lambda_12):eachCount():getEntries():sortedByDescending(____lambda_13, true):take(4)
    local ____out_4 = {}
    local ____count_4 = 0
    local ____items_6, ____n_6 = ____list_5:____array()
    for ____i_8 = 1, ____n_6 do
        local it = ____items_6[____i_8]
        ____count_4 = ____count_4 + 1
        ____out_4[____count_4] = it.key .. ":" .. it.value
    end
    print("letters: " .. __K2L_Str(__K2L_ListWrap(____out_4, ____count_4)))
    print("capitalized: " .. __K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("\\b[A-Z]\\w*", "%f[%w_][A-Z][%w_]*"):findAllFactory(TEXT)):map(____lambda_14):toList()))
    local ____list_6 = __K2L_StringSplit(__K2L_StringLines(TEXT):first(), ", ")
    local ____out_5 = {}
    local ____count_5 = 0
    local ____items_7, ____n_7 = ____list_6:____array()
    for ____i_9 = 1, ____n_7 do
        local it = ____items_7[____i_9]
        ____count_5 = ____count_5 + 1
        ____out_5[____count_5] = __K2L_Text.replaceFirstChar(it, ____lambda_15)
    end
    print("sentence case: " .. __K2L_Str(__K2L_ListWrap(____out_5, ____count_5)))
    local list = __K2L_ListOf("listen", "silent", "enlist", "google", "gooegl", "cat", "act", "tac", "dog")
    local ____result_6 = __K2L_Map.new()
    local ____items_8, ____n_8 = list:____array()
    for ____i_10 = 1, ____n_8 do
        local it = ____items_8[____i_10]
        local ____value_3 = __K2L_Text.toCharArray(it):sorted():joinToString("")
        local ____group_1 = ____result_6:get(____value_3)
        if ____group_1 == nil then
            ____group_1 = __K2L_List.new()
            ____result_6:put(____value_3, ____group_1)
        end
        ____group_1:add(it)
    end
    local ____list_7 = ____result_6:getValues()
    local ____out_6 = {}
    local ____count_6 = 0
    local ____items_9, ____n_9 = ____list_7:____array()
    for ____i_11 = 1, ____n_9 do
        local it = ____items_9[____i_11]
        if it.size > 1 then
            ____count_6 = ____count_6 + 1
            ____out_6[____count_6] = it
        end
    end
    local anagrams = __K2L_ListWrap(____out_6, ____count_6)
    print("anagrams: " .. __K2L_Str(anagrams))
    local secret = caesar("Hello, World! xyz", 3)
    print("caesar: " .. secret .. " -> " .. caesar(secret, -3))
    local v = vigenere("Attack at dawn!", "Lemon")
    print("vigenere: " .. v .. " -> " .. vigenere(v, "Lemon", true))
    print("rot13 twice: " .. caesar(caesar("Why did the chicken cross the road?", 13), 13))
    local ____list_8 = __K2L_ListOf("WWWWWWWWWWWWBWWWWWWWWWWWWBBBWWWWWWWWWWWWWWWWWWWWWWWWBWWWWWWWWWWWWWW", "abc", "aabcccccaaa", "")
    for ____i_12 = 1, ____list_8.size do
        local s = ____list_8[____i_12]
        local enc = runLength(s)
        if unRunLength(enc) ~= s then
            error(__K2L_IllegalStateException.new("round trip failed for " .. s))
        end
        print("rle: '" .. __K2L_Text.take(s, 12) .. (#s > 12 and "…" or "") .. "' -> '" .. enc .. "'")
    end
    local phrases = __K2L_ListOf("A man, a plan, a canal: Panama", "race a car", "No 'x' in Nixon", "Was it a car or a cat I saw?")
    for ____i_13 = 1, phrases.size do
        local it = phrases[____i_13]
        print("palindrome? " .. __K2L_StringPadEnd(tostring(isPalindrome(it)), 5) .. " " .. it)
    end
    print("longest palindromes: " .. __K2L_Str(__K2L_ListOf("babad", "cbbd", "forgeeksskeegfor", "abacdfgdcaba"):map(longestPalindrome)))
    local lines = wrap(__K2L_StringReplace(TEXT, "\n", " "), 36)
    for ____i_14 = 1, lines.size do
        local l = lines[____i_14]
        local i = ____i_14 - 1
        print("|" .. (i == lines.size - 1 and __K2L_StringPadEnd(l, 36) or justify(l, 36)) .. "|")
    end
    local tpl = "Dear {{ name|title }}, your order #{{id}} of {{ count }} {{item|upper}} ships {{when}}. ({{name|len}})"
    print(render(tpl, __K2L_MapOf(__K2L_Pair.new("name", "ada lovelace"), __K2L_Pair.new("id", 1042), __K2L_Pair.new("count", 3), __K2L_Pair.new("item", "widgets"), __K2L_Pair.new("when", nil))))
    local ____receiver_4 = __K2L_RunCatching(____lambda_16):exceptionOrNull()
    print(__K2L_Str(____receiver_4 and ____receiver_4.message))
    local ____destructured_2 = parseLog(LOG)
    local entries, bad = ____destructured_2.first, ____destructured_2.second
    print("log: " .. entries.size .. " entries, " .. bad .. " malformed")
    print("levels: " .. __K2L_Str(entries:groupingBy(____lambda_17):eachCount()))
    local ____out_7 = {}
    local ____count_7 = 0
    local ____items_10, ____n_10 = entries:____array()
    for ____i_15 = 1, ____n_10 do
        local it = ____items_10[____i_15]
        local ____result_7
        do
            local ____receiver_5 = __K2L_Regex.new("(\\d+)ms", "(%d+)ms"):find(it.message)
            local ____receiver_6 = ____receiver_5 and ____receiver_5.groupValues
            local ____receiver_7 = ____receiver_6 and ____receiver_6:get(1)
            ____result_7 = ____receiver_7 and __K2L_StringToInt(____receiver_7)
        end
        local ____value_4 = ____result_7
        if ____value_4 ~= nil then
            ____count_7 = ____count_7 + 1
            ____out_7[____count_7] = ____value_4
        end
    end
    local durations = __K2L_ListWrap(____out_7, ____count_7)
    print("durations: " .. __K2L_Str(durations) .. " avg=" .. string.format("%.1f", durations:average()))
    local ____out_8 = {}
    local ____count_8 = 0
    local ____items_11, ____n_11 = entries:____array()
    for ____i_16 = 1, ____n_11 do
        local it = ____items_11[____i_16]
        if it.level == "ERROR" then
            ____count_8 = ____count_8 + 1
            ____out_8[____count_8] = it
        end
    end
    local ____list_9 = __K2L_ListWrap(____out_8, ____count_8)
    for ____i_17 = 1, ____list_9.size do
        local ____it_1 = ____list_9[____i_17]
        do
            local time, comp, msg = ____it_1.time, ____it_1.component, ____it_1.message
            print("  " .. __K2L_Text.substringAfter(time, "T") .. " " .. comp .. ": " .. __K2L_Text.substringBefore(msg, ":"))
        end
    end
    local ____out_9 = {}
    local ____count_9 = 0
    local ____items_12, ____n_12 = entries:____array()
    for ____i_18 = 1, ____n_12 do
        local it = ____items_12[____i_18]
        local ____result_8
        ____result_8 = __K2L_Sequence.new(__K2L_Regex.new("([A-Z]+) (\\S+)", "([A-Z]+) (%S+)"):findAllFactory(it.message)):filter(____lambda_18):map(____lambda_19):toList()
        local ____inner, ____m = ____result_8:____array()
        for ____j = 1, ____m do
            ____count_9 = ____count_9 + 1
            ____out_9[____count_9] = ____inner[____j]
        end
    end
    local paths = __K2L_ListWrap(____out_9, ____count_9)
    print("paths: " .. __K2L_Str(paths:distinct()) .. " kv: " .. __K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("(\\w+)=(\\w+)", "([%w_]+)=([%w_]+)"):findAllFactory(LOG)):associate(____lambda_20)))
    local ____arg = __K2L_Regex.new("([a-z])([A-Z])", "([a-z])([A-Z])"):replace("parseHttpResponseCode", "$1_$2"):lower()
    local ____list_10 = __K2L_StringSplit("max_retry_count", "_")
    local ____out_10 = {}
    local ____count_10 = 0
    local ____items_13, ____n_13 = ____list_10:____array()
    for ____i_19 = 1, ____n_13 do
        local p = ____items_13[____i_19]
        local i = ____i_19 - 1
        local ____result_9
        if i == 0 then
            ____result_9 = p
        else
            ____result_9 = __K2L_Text.replaceFirstChar(p, ____lambda_21)
        end
        ____count_10 = ____count_10 + 1
        ____out_10[____count_10] = ____result_9
    end
    print("snake: " .. ____arg .. " camel: " .. __K2L_ListWrap(____out_10, ____count_10):joinToString(""))
    local ____arg_1 = __K2L_Str(__K2L_StringToList("Hello"):map(____lambda_22))
    local ____list_11 = __K2L_StringToList("Kotlin"):withIndex():filter(____lambda_23)
    local ____out_11 = {}
    local ____count_11 = 0
    local ____items_14, ____n_14 = ____list_11:____array()
    for ____i_20 = 1, ____n_14 do
        local it = ____items_14[____i_20]
        ____count_11 = ____count_11 + 1
        ____out_11[____count_11] = it.value
    end
    print("chars: " .. ____arg_1 .. " " .. __K2L_Str(__K2L_ListWrap(____out_11, ____count_11)) .. " " .. __K2L_Str(__K2L_Text.split("a-b-c", {"-"}, 2)))
end

__K2L_RunMain(main)
return {TEXT = TEXT, words = words, caesar = caesar, vigenere = vigenere, runLength = runLength, unRunLength = unRunLength, isPalindrome = isPalindrome, longestPalindrome = longestPalindrome, wrap = wrap, justify = justify, render = render, LogEntry = LogEntry, LOG = LOG, parseLog = parseLog}
