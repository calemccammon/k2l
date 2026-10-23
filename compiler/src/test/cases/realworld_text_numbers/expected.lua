local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringEndsWith = ____lualib.__K2L_StringEndsWith
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_StringIndexOf = ____lualib.__K2L_StringIndexOf
local __K2L_StringIsBlank = ____lualib.__K2L_StringIsBlank
local __K2L_StringPadEnd = ____lualib.__K2L_StringPadEnd
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToDouble = ____lualib.__K2L_StringToDouble
local __K2L_StringToDoubleOrNull = ____lualib.__K2L_StringToDoubleOrNull
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Truncate = ____lualib.__K2L_Truncate

local function humanBytes(n, si)
    if si == nil then
        si = false
    end
    local unit = si and 1000 or 1024
    if math.abs(n) < unit then
        return n .. " B"
    end
    local units = si and "kMGTPE" or "KMGTPE"
    local value = n + 0.0
    local i = -1
    while math.abs(value) >= unit and i < #units - 1 do
        value = value / unit
        i = i + 1
    end
    return string.format("%.1f %s%sB", value, i >= 0 and i < #units and units:sub(i + 1, i + 1) or __K2L_IndexError(i, #units, "string"), si and "" or "i")
end

local function duration(totalSeconds)
    if totalSeconds == 0 then
        return "0s"
    end
    local parts = __K2L_ListOf()
    local rest = totalSeconds
    local ____list = __K2L_ListOf(__K2L_Pair.new("d", 86400), __K2L_Pair.new("h", 3600), __K2L_Pair.new("m", 60), __K2L_Pair.new("s", 1))
    for ____i = 1, ____list.size do
        local ____item = ____list[____i]
        local name, size = ____item.first, ____item.second
        local q = rest // size
        if q > 0 then
            parts:add(q .. name)
        end
        rest = rest % size
    end
    return parts:joinToString(" ")
end

local function ordinal(n)
    local suffix
    local ____value = n % 100
    if ____value >= 11 and ____value <= 13 then
        suffix = "th"
    else
        local ____subject = n % 10
        if ____subject == 1 then
            suffix = "st"
        elseif ____subject == 2 then
            suffix = "nd"
        elseif ____subject == 3 then
            suffix = "rd"
        else
            suffix = "th"
        end
    end
    return n .. suffix
end

local function group(n, sep)
    if sep == nil then
        sep = ","
    end
    local digits = tostring(math.abs(n))
    local grouped = __K2L_Text.chunked(digits:reverse(), 3):joinToString(sep):reverse()
    return n < 0 and "-" .. grouped or grouped
end

local function roundTo(x, places)
    local f = 10.0 ^ (places + 0.0)
    return math.floor(x * f + 0.5) / f
end

local function significant(x, digits)
    return __K2L_StringFormat("%." .. digits .. "g", x)
end

local function bar(fraction, width)
    if width == nil then
        width = 20
    end
    local filled = math.floor(__K2L_Num.coerceIn(fraction, 0.0, 1.0) * width + 0.5)
    return "[" .. __K2L_Text.repeatCount("#", filled) .. __K2L_Text.repeatCount(".", width - filled) .. "] " .. string.format("%5.1f%%", fraction * 100)
end

local ParseError = __K2L_Class("ParseError", __K2L_Exception)

function ParseError:____init(msg)
    __K2L_Exception.____init(self, msg)
end

local function parseSize(input)
    local ____receiver = __K2L_Regex.new("^\\s*([+-]?\\d+\\.?\\d*)\\s*([kmgt]?)(i?)b?\\s*$", "^%s*([%+%-]?%d+%.?%d*)%s*([kKmMgGtT]?)([iI]?)[bB]?%s*$"):matchEntire(input)
    local ____value_1 = ____receiver and (not __K2L_StringEndsWith(____receiver.groupValues:get(1), ".") and ____receiver or nil)
    if ____value_1 == nil then
        error(ParseError.new("cannot parse size '" .. input .. "'"))
    end
    local m = ____value_1
    local ____destructured = m.destructured
    local num, prefix, binary = ____destructured[1], ____destructured[2], ____destructured[3]
    local base = #binary > 0 and 1024.0 or 1000.0
    local exp = __K2L_StringIndexOf("kmgt", prefix:lower()) + 1
    return math.floor(__K2L_StringToDouble(num) * base ^ (exp + 0.0) + 0.5)
end

local function parseDuration(input)
    local re = __K2L_Regex.new("(\\d+)\\s*([a-z]+)\\b", "(%d+)%s*([a-z]+)%f[^%w_]")
    local units = __K2L_SetOf("d", "h", "m", "s", "ms")
    local matches = __K2L_Sequence.new(re:findAllFactory(input:lower())):toList()
    local ____cond = matches:isEmpty()
    if not ____cond then
        local ____result = false
        local ____items, ____n = matches:____array()
        for ____i_1 = 1, ____n do
            local it = ____items[____i_1]
            if not units:contains(it.groupValues:get(2)) then
                ____result = true
                break
            end
        end
        ____cond = ____result
    end
    if ____cond or not __K2L_StringIsBlank(re:replace(input:lower(), "")) then
        error(ParseError.new("cannot parse duration '" .. input .. "'"))
    end
    local ____sum = 0
    local ____items_1, ____n_1 = matches:____array()
    for ____i_2 = 1, ____n_1 do
        local m = ____items_1[____i_2]
        local ____result_1
        do
            local n = __K2L_StringToInt(m.groupValues:get(1), nil, true)
            local ____subject_1 = m.groupValues:get(2)
            if ____subject_1 == "d" then
                ____result_1 = n * 86400000
            elseif ____subject_1 == "h" then
                ____result_1 = n * 3600000
            elseif ____subject_1 == "m" then
                ____result_1 = n * 60000
            elseif ____subject_1 == "s" then
                ____result_1 = n * 1000
            else
                ____result_1 = n
            end
        end
        ____sum = ____sum + ____result_1
    end
    return ____sum
end

local Money = __K2L_Class("Money")

function Money.new(cents)
    return setmetatable({cents = cents}, Money)
end

function Money:plus(o)
    return Money.new(self.cents + o.cents)
end

function Money:times(q)
    return Money.new(self.cents * q)
end

function Money:percent(p)
    return Money.new(math.floor(self.cents * p / 100 + 0.5))
end

function Money:toString()
    local sign = self.cents < 0 and "-" or ""
    return sign .. "$" .. group(math.abs(self.cents) // 100) .. "." .. __K2L_StringPadStart(tostring(math.abs(self.cents) % 100), 2, "0")
end

__K2L_DataClass(Money, {"cents"})

function Money:parse(s)
    local clean = __K2L_StringReplace(__K2L_Text.removePrefix(__K2L_StringTrim(s), "$"), ",", "")
    local ____destructured_1 = __K2L_StringContains(clean, ".") and __K2L_Pair.new(__K2L_Text.substringBefore(clean, "."), __K2L_Text.take(__K2L_StringPadEnd(__K2L_Text.substringAfter(clean, "."), 2, "0"), 2)) or __K2L_Pair.new(clean, "00")
    local whole, frac = ____destructured_1.first, ____destructured_1.second
    local neg = __K2L_StringStartsWith(whole, "-")
    local c = __K2L_StringToInt(__K2L_Text.removePrefix(whole, "-"), nil, true) * 100 + __K2L_StringToInt(frac, nil, true)
    return Money.new(neg and -c or c)
end

local ____lambda_1 = function(it) return duration(it) end
local ____lambda_2 = function(it)
    return roundTo(it, 2) .. "/" .. roundTo(it, 0)
end
local ____lambda_3 = function(it) return tostring(it) end
local ____lambda_4 = function(it) return string.format("%.10f", it) end
local ____lambda_5 = function(it)
    return __K2L_Str(__K2L_StringToDoubleOrNull(it))
end
local function main()
    local ____list_1 = __K2L_ListOf(0, 999, 1023, 1024, 1536, 1000000, 1048576, 123456789, 9876543210, 1 << 50, -2048)
    for ____i_3 = 1, ____list_1.size do
        local n = ____list_1[____i_3]
        print(string.format("%14s  %-10s %-10s", group(n), humanBytes(n), humanBytes(n, true)))
    end
    print(__K2L_ListOf(0, 59, 61, 3600, 86399, 90061, 1000000):joinToString(" | ", nil, nil, nil, nil, ____lambda_1))
    print(__K2L_IntRange.new(1, 25):map(ordinal):joinToString(" ") .. " " .. __K2L_Str(__K2L_ListOf(101, 111, 112, 213, 1000, 1001):map(ordinal)))
    print(__K2L_ListOf(3.14159, 2.675, -1.005, 1.234E-4, 123456.789):joinToString(nil, nil, nil, nil, nil, ____lambda_2))
    local ____list_2 = __K2L_ListOf(3.14159, 2.675, 1.234E-4, 123456.789, 9.99999)
    local ____out = {}
    local ____count = 0
    local ____items_2, ____n_2 = ____list_2:____array()
    for ____i_4 = 1, ____n_2 do
        local it = ____items_2[____i_4]
        ____count = ____count + 1
        ____out[____count] = significant(it, 3)
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    local ____list_3 = __K2L_ListOf(0.0, 0.05, 0.333, 0.5, 0.875, 1.0, 1.2)
    for ____i_5 = 1, ____list_3.size do
        local f = ____list_3[____i_5]
        print(bar(f))
    end
    local ____list_4 = __K2L_ListOf("512", "1.5k", "10 MB", "2GiB", "0.5 TiB", " 7 kib ", "12 parsecs", "-3k")
    for ____i_6 = 1, ____list_4.size do
        local s = ____list_4[____i_6]
        local ____ok, ____result_2 = pcall(function()
            print(s .. " -> " .. parseSize(s) .. " (" .. humanBytes(parseSize(s)) .. ")")
        end)
        if not ____ok then
            local ____error = __K2L_ToThrowable(____result_2)
            if getmetatable(____error) == ParseError then
                local e = ____error
                print(__K2L_Str(e.message))
            else
                error(____error, 0)
            end
        end
    end
    local ____list_5 = __K2L_ListOf("1h 30m", "2d4h", "45s 500ms", "90m", "soon", "3 h")
    for ____i_7 = 1, ____list_5.size do
        local s = ____list_5[____i_7]
        local ____ok_1, ____result_3 = pcall(function()
            local ms = parseDuration(s)
            print(s .. " -> " .. ms .. "ms = " .. duration(ms // 1000))
        end)
        if not ____ok_1 then
            local ____error_1 = __K2L_ToThrowable(____result_3)
            if getmetatable(____error_1) == ParseError then
                local e = ____error_1
                print(__K2L_Str(e.message))
            else
                error(____error_1, 0)
            end
        end
    end
    local cart = __K2L_ListOf(__K2L_Pair.new("$1,299.99", 1), __K2L_Pair.new("4.5", 3), __K2L_Pair.new("$0.99", 12), __K2L_Pair.new("-5", 1))
    local total = Money.new(0)
    for ____i_8 = 1, cart.size do
        local ____item_1 = cart[____i_8]
        local price, qty = ____item_1.first, ____item_1.second
        local line = Money:parse(price):times(qty)
        total = total:plus(line)
        print(string.format("%-12s x%-3d %12s", price, qty, __K2L_Str(line)))
    end
    print("subtotal " .. __K2L_Str(total) .. ", tax " .. __K2L_Str(total:percent(8.875)) .. ", total " .. __K2L_Str(total:plus(total:percent(8.875))))
    local doubles = __K2L_ListOf(0.1 + 0.2, 1.0 / 3, 2.0 / 3, 100.0, 1.0E7, 0.001, 9.999E-4, 1.23456789E8, 1.0E21, 1.0E-7, 1.7976931348623157E308, 4.9E-324, -0.0, 4.35 * 100)
    for ____i_9 = 1, doubles.size do
        local d = doubles[____i_9]
        print(d .. " " .. tostring(__K2L_StringToDouble(tostring(d)) == d) .. " " .. d .. " " .. __K2L_Str(math.abs(d) < 1.0E15 and math.floor(d + 0.5) or "big") .. " " .. string.format("%.3e", d))
    end
    local floats = __K2L_ListOf(0.1, 1.0 / 3, 1.6777216E7, 3.4028235E38, 1.0E-10, 100.0, 0.5 + 0.25)
    local ____arg = floats:joinToString(nil, nil, nil, nil, nil, ____lambda_3) .. " | "
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_3, ____n_3 = floats:____array()
    for ____i_10 = 1, ____n_3 do
        local it = ____items_3[____i_10]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = it
    end
    print(____arg .. __K2L_ListWrap(____out_1, ____count_1):joinToString(nil, nil, nil, nil, nil, ____lambda_4))
    print(__K2L_ListOf("1e3", "0x1p3", "0x1.8P-1", "-0X10p0d", "1_000", "+.5", "-.5e-1", "Infinity", "1.7976931348623157E309", "4.9e-325"):joinToString(nil, nil, nil, nil, nil, ____lambda_5))
    local ____list_6 = __K2L_ListOf("9007199254740991", "-9007199254740991", "9223372036854775808", "0777", "-0", "12L")
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_4, ____n_4 = ____list_6:____array()
    for ____i_11 = 1, ____n_4 do
        local it = ____items_4[____i_11]
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = __K2L_StringToIntOrNull(it, nil, true)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_2, ____count_2)))
    print(math.floor(12.5 + 0.5) .. " " .. math.floor(13.5 + 0.5) .. " " .. math.floor(-12.5 + 0.5) .. " " .. math.floor(-2.5 + 0.5) .. " " .. __K2L_Num.round(2.5) .. " " .. __K2L_Num.round(3.5) .. " " .. __K2L_Truncate(2.5) .. " " .. __K2L_Truncate(-2.5))
    print(#__K2L_Num.toRadix(2147483647, 2) .. " " .. __K2L_Num.toRadix(-255, 16) .. " " .. __K2L_StringPadStart(__K2L_Num.toRadix(255, 2), 16, "0") .. " " .. __K2L_StringToInt("11111111", 2) .. " " .. __K2L_StringToInt("zz", 36, true) .. " " .. __K2L_StringToInt("-7f", 16))
end

__K2L_RunMain(main)
return {humanBytes = humanBytes, duration = duration, ordinal = ordinal, group = group, roundTo = roundTo, significant = significant, bar = bar, ParseError = ParseError, parseSize = parseSize, parseDuration = parseDuration, Money = Money}
