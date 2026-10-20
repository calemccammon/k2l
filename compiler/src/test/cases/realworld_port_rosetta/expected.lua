local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_GenerateSequence = ____lualib.__K2L_GenerateSequence
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IRem = ____lualib.__K2L_IRem
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_StringPadEnd = ____lualib.__K2L_StringPadEnd
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringToDoubleOrNull = ____lualib.__K2L_StringToDoubleOrNull
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Triple = ____lualib.__K2L_Triple
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf
local __K2L_Unsigned = ____lualib.__K2L_Unsigned

local function toRoman(n)
    if not (n >= 1 and n <= 3999) then
        error(__K2L_IllegalArgumentException.new("out of range: " .. n))
    end
    local ____table = __K2L_ReadOnlyListOf(__K2L_Pair.new(1000, "M"), __K2L_Pair.new(900, "CM"), __K2L_Pair.new(500, "D"), __K2L_Pair.new(400, "CD"), __K2L_Pair.new(100, "C"), __K2L_Pair.new(90, "XC"), __K2L_Pair.new(50, "L"), __K2L_Pair.new(40, "XL"), __K2L_Pair.new(10, "X"), __K2L_Pair.new(9, "IX"), __K2L_Pair.new(5, "V"), __K2L_Pair.new(4, "IV"), __K2L_Pair.new(1, "I"))
    local rest = n
    local ____builder = __K2L_StringBuilder.new()
    do
        local ____mod = ____table.____modCount
        for ____i = 1, ____table.size do
            local ____item = ____table[____i]
            local v, s = ____item.first, ____item.second
            while rest >= v do
                ____builder:append(s)
                rest = rest - v
            end
            if ____table.____modCount ~= ____mod and ____table:____comodified(____i) then
                break
            end
        end
    end
    return ____builder:toString()
end

local function fromRoman(s)
    local values = __K2L_ReadOnlyMapOf(__K2L_Pair.new("I", 1), __K2L_Pair.new("V", 5), __K2L_Pair.new("X", 10), __K2L_Pair.new("L", 50), __K2L_Pair.new("C", 100), __K2L_Pair.new("D", 500), __K2L_Pair.new("M", 1000))
    local ____value_1 = __K2L_StringToList(s:upper()):map(function(it)
        local ____value = values:get(it)
        if ____value == nil then
            error(__K2L_IllegalArgumentException.new("bad numeral '" .. it .. "' in " .. s))
        end
        return ____value
    end)
    local ____result
    ____result = ____value_1:getIndices():sumOf(function(i)
        return i + 1 < ____value_1.size and ____value_1:get(i) < ____value_1:get(i + 1) and -____value_1:get(i) or ____value_1:get(i)
    end)
    return ____result
end

local SMALL = __K2L_ReadOnlyListOf("zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen")
local TENS = __K2L_ReadOnlyListOf("", "", "twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety")
local SCALES = __K2L_ReadOnlyListOf(__K2L_Pair.new("", 1), __K2L_Pair.new("thousand", 1000), __K2L_Pair.new("million", 1000000), __K2L_Pair.new("billion", 1000000000), __K2L_Pair.new("trillion", 1000000000000))

local function spell(n)
    if n < 0 then
        return "minus " .. spell(-n)
    end
    if n < 20 then
        return SMALL:get(__K2L_ToInt32(n))
    end
    if n < 100 then
        return TENS:get(__K2L_ToInt32(n >= 0 and n // 10 or (n + 9) // 10)) .. ((n >= 0 and n % 10 or (n % 10 - 10) % (-10)) ~= 0 and "-" .. SMALL:get(__K2L_ToInt32(n >= 0 and n % 10 or (n % 10 - 10) % (-10))) or "")
    end
    if n < 1000 then
        return SMALL:get(__K2L_ToInt32(n >= 0 and n // 100 or (n + 99) // 100)) .. " hundred" .. ((n >= 0 and n % 100 or (n % 100 - 100) % (-100)) ~= 0 and " and " .. spell(n >= 0 and n % 100 or (n % 100 - 100) % (-100)) or "")
    end
    local ____destructured = SCALES:last(function(it) return it.second <= n end)
    local name, size = ____destructured.first, ____destructured.second
    local rest = __K2L_IRem(n, size)
    local ____arg = spell(__K2L_IDiv(n, size)) .. " " .. name
    local ____temp
    if rest == 0 then
        ____temp = ""
    elseif rest < 100 then
        ____temp = " and " .. spell(rest)
    else
        ____temp = ", " .. spell(rest)
    end
    return ____arg .. ____temp
end

local function lookAndSay(s)
    local ____builder_1 = __K2L_StringBuilder.new()
    do
        local i = 0
        while i < #s do
            local j = i
            while j < #s and (j >= 0 and j < #s and s:sub(j + 1, j + 1) or __K2L_IndexError(j, #s, "string")) == (i >= 0 and i < #s and s:sub(i + 1, i + 1) or __K2L_IndexError(i, #s, "string")) do
                j = j + 1
            end
            ____builder_1:append(tostring(j - i)):append(i >= 0 and i < #s and s:sub(i + 1, i + 1) or __K2L_IndexError(i, #s, "string"))
            i = j
        end
    end
    return ____builder_1:toString()
end

local function balanced(s)
    local ____pairs = __K2L_ReadOnlyMapOf(__K2L_Pair.new(")", "("), __K2L_Pair.new("]", "["), __K2L_Pair.new("}", "{"), __K2L_Pair.new(">", "<"))
    local stack = __K2L_ArrayDeque.new()
    local ____collection = __K2L_StringToList(s):withIndex()
    local ____items, ____n = ____collection:____array()
    local ____mod_1 = ____collection.____modCount
    for ____i_1 = 1, ____n do
        local ____item_1 = ____items[____i_1]
        local i, c = ____item_1.index, ____item_1.value
        if ____pairs:getValues():contains(c) then
            stack:addLast(__K2L_Pair.new(c, i))
        elseif ____pairs:getKeys():contains(c) then
            local ____value_2 = stack:removeLastOrNull()
            if ____value_2 == nil then
                return "unexpected '" .. c .. "' at " .. i
            end
            local top = ____value_2
            if top.first ~= ____pairs:get(c) then
                return "mismatch '" .. top.first .. "'@" .. top.second .. " vs '" .. c .. "'@" .. i
            end
        end
        if ____collection.____modCount ~= ____mod_1 and ____collection:____comodified(____i_1, ____n) then
            break
        end
    end
    local ____receiver = stack:lastOrNull()
    return ____receiver and "unclosed '" .. ____receiver.first .. "' at " .. ____receiver.second or "ok"
end

local ____lambda_1 = function(it) return it:match("^%d$") ~= nil end
local ____lambda_2 = function(it) return __K2L_Num.digitToInt(it) end
local function luhn(number)
    local digits = __K2L_StringToList(__K2L_Text.filter(number, ____lambda_1)):map(____lambda_2)
    if digits.size < 2 then
        return false
    end
    local ____list = digits:reversed()
    local ____out = {}
    local ____count = 0
    local ____items_1, ____n_1 = ____list:____array()
    for ____i_2 = 1, ____n_1 do
        local d = ____items_1[____i_2]
        local i = ____i_2 - 1
        local ____result_1
        if (i >= 0 and i % 2 or 0 - -i % 2) == 1 then
            local ____value_3 = d * 2
            local ____result_2
            ____result_2 = ____value_3 > 9 and ____value_3 - 9 or ____value_3
            ____result_1 = ____result_2
        else
            ____result_1 = d
        end
        ____count = ____count + 1
        ____out[____count] = ____result_1
    end
    local ____dividend = __K2L_ListWrap(____out, ____count):sum()
    return (____dividend >= 0 and ____dividend % 10 or 0 - -____dividend % 10) == 0
end

local ____lambda_3 = function(____p1) return ____p1:match("^%d$") ~= nil end
local ____lambda_4 = function(i, c)
    return __K2L_Num.digitToInt(c) * ((i >= 0 and i % 2 or 0 - -i % 2) == 0 and 1 or 3)
end
local function isbn13(s)
    local d = __K2L_StringReplace(__K2L_StringReplace(s, "-", ""), " ", "")
    if #d ~= 13 or not __K2L_StringToList(d):all(____lambda_3) then
        return false
    end
    local ____dividend_1 = __K2L_StringToList(d):mapIndexed(____lambda_4):sum()
    return (____dividend_1 >= 0 and ____dividend_1 % 10 or 0 - -____dividend_1 % 10) == 0
end

local ____lambda_5 = function(it)
    return #it.value .. (0 >= 0 and 0 < #it.value and it.value:sub(0 + 1, 0 + 1) or __K2L_IndexError(0, #it.value, "string"))
end
local function rle(s)
    return __K2L_Sequence.new(__K2L_Regex.new("(.)\\1*"):findAllFactory(s)):joinToString("", nil, nil, nil, nil, ____lambda_5)
end

local ____lambda_6 = function(it)
    return __K2L_Text.repeatCount(it.groupValues:get(2), __K2L_StringToInt(it.groupValues:get(1)))
end
local function unrle(s)
    return __K2L_Sequence.new(__K2L_Regex.new("(\\d+)(\\D)"):findAllFactory(s)):joinToString("", nil, nil, nil, nil, ____lambda_6)
end

local function dayOfWeek(y, m, d)
    local ____destructured_1 = m < 3 and __K2L_Pair.new(y - 1, m + 12) or __K2L_Pair.new(y, m)
    local yy, mm = ____destructured_1.first, ____destructured_1.second
    local k = yy >= 0 and yy % 100 or 0 - -yy % 100
    local j = yy >= 0 and yy // 100 or 0 - -yy // 100
    local ____dividend_2 = 13 * (mm + 1)
    local ____dividend_3 = d + (____dividend_2 >= 0 and ____dividend_2 // 5 or 0 - -____dividend_2 // 5) + k + (k >= 0 and k // 4 or 0 - -k // 4) + (j >= 0 and j // 4 or 0 - -j // 4) + 5 * j
    return ____dividend_3 >= 0 and ____dividend_3 % 7 or 0 - -____dividend_3 % 7
end

local function isLeap(y)
    return (y >= 0 and y % 4 or 0 - -y % 4) == 0 and ((y >= 0 and y % 100 or 0 - -y % 100) ~= 0 or (y >= 0 and y % 400 or 0 - -y % 400) == 0)
end

local function calendar(year, month)
    local names = __K2L_ReadOnlyListOf("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December")
    local days = __K2L_TypedArrayOf("[I", 31, isLeap(year) and 29 or 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31):get(month - 1)
    local ____dividend_4 = dayOfWeek(year, month, 1) + 5
    local first = ____dividend_4 >= 0 and ____dividend_4 % 7 or 0 - -____dividend_4 % 7
    local title = names:get(month - 1) .. " " .. year
    local ____dividend_5 = 20 + #title
    local sb = __K2L_StringBuilder.new(__K2L_StringPadEnd(__K2L_StringPadStart(title, ____dividend_5 >= 0 and ____dividend_5 // 2 or 0 - -____dividend_5 // 2), 20)):append("\n"):append("Mo Tu We Th Fr Sa Su\n")
    sb:append(__K2L_Text.repeatCount("   ", first))
    for d = 1, days do
        sb:append(__K2L_StringPadStart(tostring(d), 2))
        local ____dividend_6 = first + d
        sb:append(((____dividend_6 >= 0 and ____dividend_6 % 7 or 0 - -____dividend_6 % 7) == 0 or d == days) and "\n" or " ")
    end
    return sb:toString()
end

local function isoDate(y, m, d, h, min)
    if h == nil then
        h = 0
    end
    if min == nil then
        min = 0
    end
    return __K2L_StringFormat("%04d-%02d-%02dT%02d:%02d", y, m, d, h, min) .. " (" .. __K2L_ReadOnlyListOf("Sat", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri"):get(dayOfWeek(y, m, d)) .. ")"
end

local ____lambda_7 = function(it) return it .. "=" .. toRoman(it) end
local ____lambda_8 = function(it) return #it end
local ____lambda_9 = function(it) return __K2L_Str(it) end
local ____lambda_10 = function(it)
    return it .. ":" .. (isLeap(it) and "leap" or "-")
end
local ____lambda_11 = function(it) return it.second end
local function main()
    local years = __K2L_ReadOnlyListOf(1, 4, 9, 14, 40, 90, 400, 1666, 1990, 2008, 2024, 3999)
    print(years:joinToString(nil, nil, nil, nil, nil, ____lambda_7))
    local ____result_3 = true
    local ____items_2, ____n_2 = years:____array()
    for ____i_3 = 1, ____n_2 do
        local it = ____items_2[____i_3]
        if fromRoman(toRoman(it)) ~= it then
            ____result_3 = false
            break
        end
    end
    print(____result_3)
    print(__K2L_Str(__K2L_ReadOnlyListOf("mcmxc", "MMXXIV", "iv", "MDCLXVI"):map(fromRoman)))
    local ____ok, ____result_4 = pcall(function()
        fromRoman("MXQ")
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_4)
        if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
            local e = ____error
            print(__K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    local ____ok_1, ____result_5 = pcall(function()
        toRoman(0)
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_5)
        if __K2L_InstanceOf(____error_1, __K2L_IllegalArgumentException) then
            local e = ____error_1
            print(__K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
    local ____list_1 = __K2L_ReadOnlyListOf(0, 7, 13, 42, 100, 101, 999, 1000, 1001, 12345, 1000000, 7654321, -15, 2147483648, 1000000000001)
    for ____i_4 = 1, ____list_1.size do
        local n = ____list_1[____i_4]
        print(__K2L_StringFormat("%,d: %s", n, spell(n)))
    end
    print(__K2L_Str(__K2L_GenerateSequence("1", lookAndSay):take(10):toList()))
    print(__K2L_GenerateSequence("1", lookAndSay):map(____lambda_8):take(20):joinToString(" "))
    local ____list_2 = __K2L_ReadOnlyListOf("([]{<>})", "([)]", "((", "())", "", "{[()()]<>}x", "a(b[c]d)e}")
    for ____i_5 = 1, ____list_2.size do
        local s = ____list_2[____i_5]
        print("'" .. s .. "' -> " .. balanced(s))
    end
    local ____list_3 = __K2L_ReadOnlyListOf("4539 3195 0343 6467", "8273 1232 7352 0569", "79927398713", "0", "4111-1111-1111-1111")
    for ____i_6 = 1, ____list_3.size do
        local card = ____list_3[____i_6]
        print("luhn(" .. card .. ") = " .. tostring(luhn(card)))
    end
    local ____list_4 = __K2L_ReadOnlyListOf("978-0596520687", "978 1734314502", "978-1734314509", "9781788399081", "978-17883-9908")
    for ____i_7 = 1, ____list_4.size do
        local isbn = ____list_4[____i_7]
        print("isbn13(" .. isbn .. ") = " .. tostring(isbn13(isbn)))
    end
    local samples = __K2L_ReadOnlyListOf(0, 1, 255, 4096, 65535, -1, 2147483647, -2147483648)
    local ____mod_2 = samples.____modCount
    for ____i_8 = 1, samples.size do
        local n = samples[____i_8]
        print(__K2L_StringFormat("%11d bin=%s oct=%s hex=%s b36=%s", n, __K2L_Num.toRadix(n, 2), __K2L_Num.toRadix(n, 8), __K2L_Num.toRadix(n, 16), __K2L_Num.toRadix(n, 36)))
        if samples.____modCount ~= ____mod_2 and samples:____comodified(____i_8) then
            break
        end
    end
    local ____list_5 = __K2L_ReadOnlyListOf(__K2L_Pair.new("ff", 16), __K2L_Pair.new("-1010", 2), __K2L_Pair.new("zz", 36), __K2L_Pair.new("777", 8), __K2L_Pair.new("+42", 10), __K2L_Pair.new("0x1F", 16), __K2L_Pair.new("12a", 10))
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_3, ____n_3 = ____list_5:____array()
    for ____i_9 = 1, ____n_3 do
        local ____it = ____items_3[____i_9]
        local ____result_6
        do
            local s, r = ____it.first, ____it.second
            ____result_6 = __K2L_StringToIntOrNull(s, r)
        end
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = ____result_6
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
    local ____arg_1 = __K2L_StringToInt("7fffffff", 16, true) + 1
    local ____dividend_7 = __K2L_StringToInt("-8000000000000000", 16, true)
    print(__K2L_Str(__K2L_Pair.new(____arg_1, ____dividend_7 >= 0 and ____dividend_7 // 2 or (____dividend_7 + 1) // 2)))
    local ____list_6 = __K2L_ReadOnlyListOf("3.14", "-0.0", "1e3", ".5", "5.", "NaN", "-Infinity", "1_000", "0x10", "  7  ", "1.5f", "2d")
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_4, ____n_4 = ____list_6:____array()
    for ____i_10 = 1, ____n_4 do
        local it = ____items_4[____i_10]
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = __K2L_StringToDoubleOrNull(it)
    end
    print(__K2L_ListWrap(____out_2, ____count_2):joinToString(nil, "[", "]", nil, nil, ____lambda_9))
    local ____list_7 = __K2L_ReadOnlyListOf("42", "-0", "+7", "0042", " 1", "1e2", "2147483648", "-2147483648")
    local ____out_3 = {}
    local ____count_3 = 0
    local ____items_5, ____n_5 = ____list_7:____array()
    for ____i_11 = 1, ____n_5 do
        local it = ____items_5[____i_11]
        ____count_3 = ____count_3 + 1
        ____out_3[____count_3] = __K2L_StringToIntOrNull(it)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_3, ____count_3)))
    print(__K2L_Str(__K2L_ReadOnlyListOf(tostring(2147483647), tostring(-9223372036854775807 - 1), tostring(1 << 40), __K2L_Num.toRadix(255, 16):upper(), __K2L_Num.toRadixUnsigned(-16, 16), __K2L_Unsigned.toRadix(10, 2))))
    local text = "WWWWWWWWWWWWBWWWWWWWWWWWWBBBWWWWWWWWWWWWWWWWWWWWWWWWBWWWWWWWWWWWWWW"
    local enc = rle(text)
    print(enc .. " " .. tostring(unrle(enc) == text) .. " " .. rle("aabcccccaaa") .. " " .. unrle("3x2y1z"))
    io.write(calendar(2024, 2))
    io.write(calendar(1969, 7))
    io.write(calendar(2023, 10))
    print(__K2L_ReadOnlyListOf(__K2L_Triple.new(2000, 1, 1), __K2L_Triple.new(1970, 1, 1), __K2L_Triple.new(2024, 2, 29), __K2L_Triple.new(1999, 12, 31)):joinToString(nil, nil, nil, nil, nil, function(____destructured_2)
        local y, m, d = ____destructured_2.first, ____destructured_2.second, ____destructured_2.third
        return isoDate(y, m, d, 23, 59)
    end))
    print(__K2L_Str(__K2L_IntRange.new(1900, 2100):withStep(50):map(____lambda_10)))
    print(__K2L_IntRange.new(1, 30):joinToString(" ", nil, nil, nil, nil, function(i)
        local ____list_8 = __K2L_ReadOnlyListOf(__K2L_Pair.new(3, "Fizz"), __K2L_Pair.new(5, "Buzz"), __K2L_Pair.new(7, "Baxx"))
        local ____out_4 = {}
        local ____count_4 = 0
        local ____items_6, ____n_6 = ____list_8:____array()
        for ____i_12 = 1, ____n_6 do
            local it = ____items_6[____i_12]
            if __K2L_IRem(i, it.first) == 0 then
                ____count_4 = ____count_4 + 1
                ____out_4[____count_4] = it
            end
        end
        return __K2L_Text.ifEmpty(__K2L_ListWrap(____out_4, ____count_4):joinToString("", nil, nil, nil, nil, ____lambda_11), function() return tostring(i) end)
    end))
end

main()
return {toRoman = toRoman, fromRoman = fromRoman, spell = spell, lookAndSay = lookAndSay, balanced = balanced, luhn = luhn, isbn13 = isbn13, rle = rle, unrle = unrle, dayOfWeek = dayOfWeek, isLeap = isLeap, calendar = calendar, isoDate = isoDate}
