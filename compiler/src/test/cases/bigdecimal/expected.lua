local ____lualib = require("lualib_bundle")
local __K2L_ArithmeticException = ____lualib.__K2L_ArithmeticException
local __K2L_BigDecimal = ____lualib.__K2L_BigDecimal
local __K2L_BigInteger = ____lualib.__K2L_BigInteger
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MathContext = ____lualib.__K2L_MathContext
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_RoundingMode = ____lualib.__K2L_RoundingMode
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local MODES = __K2L_ReadOnlyListOf(__K2L_RoundingMode.UP, __K2L_RoundingMode.DOWN, __K2L_RoundingMode.CEILING, __K2L_RoundingMode.FLOOR, __K2L_RoundingMode.HALF_UP, __K2L_RoundingMode.HALF_DOWN, __K2L_RoundingMode.HALF_EVEN)

local function construction()
    print("-- construction")
    print(__K2L_Str(__K2L_BigDecimal.parse("1.10")))
    print(__K2L_Str(__K2L_BigDecimal.parse("-0.000001")))
    print(__K2L_Str(__K2L_BigDecimal.parse("-0.0000001")))
    print(__K2L_Str(__K2L_BigDecimal.parse("1E+3")))
    print(__K2L_Str(__K2L_BigDecimal.parse("1.5e-10")))
    print(__K2L_Str(__K2L_BigDecimal.parse("123.456E5")))
    print(__K2L_Str(__K2L_BigDecimal.parse("0.00")))
    print(__K2L_Str(__K2L_BigDecimal.parse("0E-10")))
    print(__K2L_Str(__K2L_BigDecimal.parse("0E+10")))
    print(__K2L_Str(__K2L_BigDecimal.parse(".5")))
    print(__K2L_Str(__K2L_BigDecimal.parse("5.")))
    print(__K2L_Str(__K2L_BigDecimal.parse("+7.0")))
    print(__K2L_Str(__K2L_BigDecimal.fromLong(42)))
    print(__K2L_Str(__K2L_BigDecimal.fromLong(123456789012)))
    print(__K2L_Str(__K2L_BigDecimal.fromDouble(0.5)))
    print(__K2L_Str(__K2L_BigDecimal.fromDouble(0.1)))
    print(__K2L_Str(__K2L_BigDecimal.fromDouble(-2.75)))
    print(__K2L_Str(__K2L_BigDecimal.fromDouble(1.0E20)))
    print(__K2L_Str(__K2L_BigDecimal.fromDouble(3.0)))
    print(__K2L_Str(__K2L_BigDecimal.fromBigInteger(__K2L_BigInteger.parse("12345678901234567890"))))
    print(__K2L_Str(__K2L_BigDecimal.fromBigInteger(__K2L_BigInteger.parse("12345"), 3)))
    print(__K2L_Str(__K2L_BigDecimal.fromBigInteger(__K2L_BigInteger.parse("12345"), -3)))
    print(__K2L_Str(__K2L_BigDecimal.valueOfDouble(2.5)))
    print(__K2L_Str(__K2L_BigDecimal.valueOfDouble(0.1)))
    print(__K2L_Str(__K2L_BigDecimal.valueOfDouble(100.0)))
    print(__K2L_Str(__K2L_BigDecimal.valueOfDouble(1.0E-5)))
    print(__K2L_Str(__K2L_BigDecimal.valueOfDouble(1.0E10)))
    print(__K2L_Str(__K2L_BigDecimal.valueOf(12345)))
    print(__K2L_Str(__K2L_BigDecimal.valueOf(12345, 2)))
    print(__K2L_Str(__K2L_BigDecimal.valueOf(-5, -2)))
    print(__K2L_Str(__K2L_BigDecimal.fromLong(7)))
    print(__K2L_Str(__K2L_BigDecimal.fromLong(7)))
    print(__K2L_Str(__K2L_BigDecimal.valueOfDouble(1.5)))
    print(__K2L_Str(__K2L_BigDecimal.valueOfDouble(0.1)))
    print(__K2L_Str(__K2L_BigDecimal.parse("3.14159")))
    print(__K2L_Str(__K2L_BigDecimal.parseOrNull("abc")))
    print(__K2L_Str(__K2L_BigDecimal.parseOrNull("1.5")))
    print(__K2L_Str(__K2L_BigDecimal.fromBigInteger(__K2L_BigInteger.TEN)))
    print(__K2L_Str(__K2L_BigDecimal.fromBigInteger(__K2L_BigInteger.parse("1234"), 2)))
    print(__K2L_Str(__K2L_BigDecimal.ZERO))
    print(__K2L_Str(__K2L_BigDecimal.ONE))
    print(__K2L_Str(__K2L_BigDecimal.TEN))
end

local function arithmetic()
    print("-- arithmetic")
    local a = __K2L_BigDecimal.parse("1.10")
    local b = __K2L_BigDecimal.parse("2.505")
    print(__K2L_Str(a:add(b)))
    print(__K2L_Str(a:subtract(b)))
    print(__K2L_Str(a:multiply(b)))
    print(__K2L_Str(a:negate()))
    print(__K2L_Str(a:negate():abs()))
    print(a:add(b):scale())
    print(a:multiply(b):scale())
    print(a:multiply(b):precision())
    print(__K2L_Str(a:pow(3)))
    print(__K2L_Str(__K2L_BigDecimal.parse("0.5"):pow(10)))
    print(__K2L_Str(a:unscaledValue()))
    print(a:signum())
    print(__K2L_BigDecimal.parse("-3.00"):signum())
    print(__K2L_BigDecimal.parse("0.000"):signum())
    print(__K2L_Str(a:remainder(__K2L_BigDecimal.parse("0.3"))))
    print(__K2L_Str(__K2L_BigDecimal.parse("7"):remainder(__K2L_BigDecimal.parse("-3"))))
    print(__K2L_Str(__K2L_BigDecimal.parse("-7.5"):remainder(__K2L_BigDecimal.parse("2"))))
    print(__K2L_Str(__K2L_BigDecimal.parse("100"):divideToIntegralValue(__K2L_BigDecimal.parse("7"))))
    print(__K2L_Str(__K2L_BigDecimal.parse("100.0"):divideToIntegralValue(__K2L_BigDecimal.parse("0.7"))))
    print(__K2L_Str(__K2L_BigDecimal.parse("1"):divideToIntegralValue(__K2L_BigDecimal.parse("3"))))
    print(__K2L_Str(a:min(b)))
    print(__K2L_Str(a:max(b)))
    print(__K2L_Str(__K2L_BigDecimal.parse("123456789.123456789"):multiply(__K2L_BigDecimal.parse("987654321.987654321"))))
    local total = __K2L_BigDecimal.ZERO
    local ____list = __K2L_ReadOnlyListOf("19.99", "5.01", "0.10", "100")
    for ____i = 1, ____list.size do
        local price = ____list[____i]
        total = total:add(__K2L_BigDecimal.parse(price))
    end
    total = total:multiply(__K2L_BigDecimal.parse("1.0825"))
    print(__K2L_Str(total))
    print(__K2L_Str(total:setScale(2, __K2L_RoundingMode.HALF_UP)))
    local counter = __K2L_BigDecimal.parse("9.9")
    counter = counter:inc()
    print(__K2L_Str(counter))
    counter = counter:dec()
    counter = counter:dec()
    print(__K2L_Str(counter))
    print(__K2L_Str(a:movePointLeft(3)))
    print(__K2L_Str(a:movePointRight(3)))
    print(__K2L_Str(a:movePointRight(1)))
    print(__K2L_Str(a:scaleByPowerOfTen(5)))
    print(__K2L_Str(__K2L_BigDecimal.parse("1234.5678"):toBigInteger()))
    print(__K2L_Str(__K2L_BigDecimal.parse("-1234.5678"):toBigInteger()))
    print(__K2L_Str(__K2L_BigDecimal.parse("1E+5"):toBigInteger()))
end

local function scaling()
    print("-- setScale table")
    local values = __K2L_ReadOnlyListOf("5.5", "2.5", "1.6", "1.1", "1.0", "0.5", "-0.5", "-1.1", "-1.6", "-2.5", "-5.5", "0.05", "99.995")
    local ____mod = values.____modCount
    for ____i_1 = 1, values.size do
        local v = values[____i_1]
        local x = __K2L_BigDecimal.parse(v)
        local row = MODES:joinToString(" ", nil, nil, nil, nil, function(m)
            return m.name .. "=" .. __K2L_Str(x:setScale(0, m))
        end)
        print(v .. ": " .. row)
        local row2 = MODES:joinToString(" ", nil, nil, nil, nil, function(m) return x:setScale(1, m):toString() end)
        print("  scale 1: " .. row2)
        if values.____modCount ~= ____mod and values:____comodified(____i_1) then
            break
        end
    end
    print(__K2L_Str(__K2L_BigDecimal.parse("2.5"):setScale(3)))
    print(__K2L_Str(__K2L_BigDecimal.parse("2.500"):setScale(1)))
    print(__K2L_Str(__K2L_BigDecimal.parse("1E+3"):setScale(0)))
    print(__K2L_Str(__K2L_BigDecimal.parse("12345"):setScale(-2, __K2L_RoundingMode.HALF_UP)))
    print(__K2L_Str(__K2L_BigDecimal.parse("12355"):setScale(-1, __K2L_RoundingMode.HALF_EVEN)))
    local ____ok, ____result = pcall(function()
        print(__K2L_Str(__K2L_BigDecimal.parse("2.55"):setScale(1, __K2L_RoundingMode.UNNECESSARY)))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_ArithmeticException) then
            local e = ____error
            print("ArithmeticException: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    print(__K2L_Str(__K2L_RoundingMode.HALF_EVEN))
    print(__K2L_Str(__K2L_RoundingMode.valueOf("CEILING")))
    print(__K2L_RoundingMode.HALF_UP == __K2L_RoundingMode.HALF_UP)
    print(__K2L_RoundingMode.DOWN.ordinal)
end

local function division()
    print("-- division")
    local ____pairs = __K2L_ReadOnlyListOf(__K2L_Pair.new("1", "3"), __K2L_Pair.new("2", "3"), __K2L_Pair.new("10", "4"), __K2L_Pair.new("-10", "4"), __K2L_Pair.new("1", "7"), __K2L_Pair.new("22", "7"), __K2L_Pair.new("100", "-8"), __K2L_Pair.new("0.5", "3"), __K2L_Pair.new("1.00", "3"), __K2L_Pair.new("123456.789", "0.001"))
    local ____mod_1 = ____pairs.____modCount
    for ____i_2 = 1, ____pairs.size do
        local ____item = ____pairs[____i_2]
        local n, d = ____item.first, ____item.second
        local x = __K2L_BigDecimal.parse(n)
        local y = __K2L_BigDecimal.parse(d)
        print(n .. " / " .. d .. ": " .. __K2L_Str(x:div(y)) .. " | " .. __K2L_Str(x:divide(y, 5, __K2L_RoundingMode.HALF_UP)) .. " | " .. __K2L_Str(x:divide(y, 0, __K2L_RoundingMode.FLOOR)) .. " | " .. __K2L_Str(x:divide(y, 3, __K2L_RoundingMode.HALF_EVEN)) .. " | " .. __K2L_Str(x:divide(y, __K2L_MathContext.DECIMAL32)))
        print("  " .. __K2L_Str(x:divide(y, __K2L_MathContext.new(3))) .. " " .. __K2L_Str(x:divide(y, __K2L_MathContext.new(10, __K2L_RoundingMode.DOWN))) .. " " .. __K2L_Str(x:divide(y, __K2L_MathContext.new(1, __K2L_RoundingMode.UP))) .. " " .. __K2L_Str(x:divide(y, __K2L_RoundingMode.CEILING)))
        if ____pairs.____modCount ~= ____mod_1 and ____pairs:____comodified(____i_2) then
            break
        end
    end
    print(__K2L_Str(__K2L_BigDecimal.parse("1"):divide(__K2L_BigDecimal.parse("8"))))
    print(__K2L_Str(__K2L_BigDecimal.parse("1.00"):divide(__K2L_BigDecimal.parse("8"))))
    print(__K2L_Str(__K2L_BigDecimal.parse("100"):divide(__K2L_BigDecimal.parse("4"))))
    print(__K2L_Str(__K2L_BigDecimal.parse("1"):divide(__K2L_BigDecimal.parse("0.25"))))
    print(__K2L_Str(__K2L_BigDecimal.parse("3"):divide(__K2L_BigDecimal.parse("1.5"))))
    print(__K2L_Str(__K2L_BigDecimal.parse("1E+3"):divide(__K2L_BigDecimal.parse("4"))))
    print(__K2L_Str(__K2L_BigDecimal.parse("12.5"):divide(__K2L_BigDecimal.parse("0.05"))))
    local ____arg = __K2L_BigDecimal.parse("1")
    local ____arg_1 = __K2L_BigDecimal.parse("3")
    local ____value = __K2L_MathContext.UNLIMITED
    print(__K2L_Str(____arg:divide(____arg_1, __K2L_MathContext.new(20))))
    print(__K2L_Str(__K2L_BigDecimal.parse("2"):divide(__K2L_BigDecimal.parse("3"), __K2L_MathContext.DECIMAL64)))
    print(__K2L_Str(__K2L_BigDecimal.parse("2"):divide(__K2L_BigDecimal.parse("3"), __K2L_MathContext.DECIMAL128)))
    print(__K2L_Str(__K2L_BigDecimal.parse("10"):divide(__K2L_BigDecimal.parse("3"), __K2L_MathContext.new(3, __K2L_RoundingMode.HALF_UP))))
    print(__K2L_Str(__K2L_BigDecimal.parse("999.9"):divide(__K2L_BigDecimal.parse("1"), __K2L_MathContext.new(3, __K2L_RoundingMode.HALF_UP))))
    print(__K2L_Str(__K2L_BigDecimal.parse("0"):divide(__K2L_BigDecimal.parse("3.5"), __K2L_MathContext.new(5))))
    print(__K2L_Str(__K2L_BigDecimal.parse("100000000000"):divide(__K2L_BigDecimal.parse("1"), __K2L_MathContext.new(4))))
    print(__K2L_Str(__K2L_BigDecimal.parse("3.14159265358979"):round(__K2L_MathContext.new(5))))
    print(__K2L_Str(__K2L_BigDecimal.parse("3.14159265358979"):round(__K2L_MathContext.new(1, __K2L_RoundingMode.UP))))
    print(__K2L_Str(__K2L_BigDecimal.parse("999.99"):round(__K2L_MathContext.new(3, __K2L_RoundingMode.HALF_UP))))
    print(__K2L_Str(__K2L_BigDecimal.parse("1.23456"):add(__K2L_BigDecimal.parse("9.87654"), __K2L_MathContext.new(4))))
    print(__K2L_Str(__K2L_BigDecimal.parse("1.23456"):multiply(__K2L_BigDecimal.parse("9.87654"), __K2L_MathContext.new(4))))
    print(__K2L_Str(__K2L_MathContext.DECIMAL32))
    print(__K2L_Str(__K2L_MathContext.new(5, __K2L_RoundingMode.FLOOR)))
    print(__K2L_MathContext.DECIMAL64.precision)
    print(__K2L_Str(__K2L_MathContext.DECIMAL64.roundingMode))
end

local function formatting()
    print("-- formatting")
    local values = __K2L_ReadOnlyListOf("0", "0.0", "0.00", "1", "-1", "1.0", "12345.6789", "-0.5", "0.000001", "0.0000001", "1E+3", "1.23E+10", "-1.5E-7", "100", "1E-10", "123456789012345678901234567890.123456789", "0E+3", "1.000E+3")
    local ____mod_2 = values.____modCount
    for ____i_3 = 1, values.size do
        local v = values[____i_3]
        local x = __K2L_BigDecimal.parse(v)
        print(v .. ": toString=" .. __K2L_Str(x) .. " plain=" .. __K2L_Str(x:toPlainString()) .. " scale=" .. x:scale() .. " precision=" .. x:precision() .. " strip=" .. __K2L_Str(x:stripTrailingZeros()) .. " strip.plain=" .. __K2L_Str(x:stripTrailingZeros():toPlainString()))
        if values.____modCount ~= ____mod_2 and values:____comodified(____i_3) then
            break
        end
    end
    print(__K2L_Str(__K2L_BigDecimal.parse("1000"):stripTrailingZeros()))
    print(__K2L_BigDecimal.parse("1000"):stripTrailingZeros():scale())
    print(__K2L_Str(__K2L_BigDecimal.parse("10.50"):stripTrailingZeros()))
    print(__K2L_Str(__K2L_BigDecimal.parse("0.000"):stripTrailingZeros()))
    print("price: " .. __K2L_Str(__K2L_BigDecimal.parse("9.99")))
    print(__K2L_Str(__K2L_ReadOnlyListOf(__K2L_BigDecimal.parse("1.5"), __K2L_BigDecimal.parse("2.50"))))
end

local ____lambda_1 = function(acc, v) return acc:add(v) end
local ____lambda_2 = function(it) return __K2L_BigDecimal.parse(it) end
local function comparisons()
    print("-- comparisons")
    local a = __K2L_BigDecimal.parse("1.0")
    local b = __K2L_BigDecimal.parse("1.00")
    local c = __K2L_BigDecimal.parse("2")
    print(__K2L_Equals(a, b))
    print(a:equals(b))
    print(a:compareTo(b))
    print(a:compareTo(c))
    print(c:compareTo(a))
    print(__K2L_Compare(a, c) < 0)
    print(__K2L_Compare(a, b) >= 0)
    print(a:hashCode())
    print(b:hashCode())
    print(__K2L_BigDecimal.parse("123456789012345678901234567890.5"):hashCode())
    print(__K2L_BigDecimal.parse("-3.25"):hashCode())
    print(__K2L_BigDecimal.parse("0"):hashCode())
    print(__K2L_ReadOnlySetOf(a, b, __K2L_BigDecimal.parse("1.0")).size)
    local ____list_1 = __K2L_ReadOnlyListOf(a, b)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list_1:____array()
    for ____i_4 = 1, ____n do
        local it = ____items[____i_4]
        ____count = ____count + 1
        ____out[____count] = it:stripTrailingZeros()
    end
    print(__K2L_ListWrap(____out, ____count):toSet().size)
    print(__K2L_Str(__K2L_ReadOnlyListOf(c, a, __K2L_BigDecimal.parse("-3"), __K2L_BigDecimal.parse("1.5")):sorted()))
    print(__K2L_Str(__K2L_ReadOnlyListOf(c, a, __K2L_BigDecimal.parse("-3")):maxOrNull()))
    local ____list_2 = __K2L_ReadOnlyListOf("1.1", "2.2", "3.3")
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_2:____array()
    for ____i_5 = 1, ____n_1 do
        local it = ____items_1[____i_5]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = __K2L_BigDecimal.parse(it)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1):fold(__K2L_BigDecimal.ZERO, ____lambda_1)))
    print(__K2L_Str(__K2L_ReadOnlyListOf("1.1", "2.2", "3.3"):sumOf(____lambda_2, __K2L_BigDecimal.ZERO)))
end

local function conversions()
    print("-- conversions")
    local values = __K2L_ReadOnlyListOf("0", "1.5", "-1.5", "123.999", "1E+3", "123456789012345678901.5", "1e-5", "-2147483649.5", "0.1", "3.14159265358979323846")
    local ____mod_3 = values.____modCount
    for ____i_6 = 1, values.size do
        local v = values[____i_6]
        local x = __K2L_BigDecimal.parse(v)
        print(v .. ": int=" .. x:toInt() .. " double=" .. __K2L_Str(x:toDouble()))
        if values.____modCount ~= ____mod_3 and values:____comodified(____i_6) then
            break
        end
    end
    print(__K2L_BigDecimal.parse("12345678901.7"):toLong())
    print(__K2L_Str(__K2L_BigDecimal.parse("0.1"):toDouble() + __K2L_BigDecimal.parse("0.2"):toDouble()))
    print(__K2L_Str(__K2L_BigDecimal.parse("1e400"):toDouble()))
end

local ____lambda_3 = function()
    return __K2L_BigDecimal.ONE:div(__K2L_BigDecimal.ZERO)
end
local ____lambda_4 = function()
    return __K2L_BigDecimal.ZERO:divide(__K2L_BigDecimal.ZERO)
end
local ____lambda_5 = function()
    return __K2L_BigDecimal.ONE:divide(__K2L_BigDecimal.ZERO)
end
local ____lambda_6 = function()
    return __K2L_BigDecimal.ONE:divide(__K2L_BigDecimal.parse("3"))
end
local ____lambda_7 = function()
    return __K2L_BigDecimal.ONE:divide(__K2L_BigDecimal.ZERO, 2, __K2L_RoundingMode.HALF_UP)
end
local ____lambda_8 = function()
    return __K2L_BigDecimal.ONE:divide(__K2L_BigDecimal.ZERO, __K2L_MathContext.DECIMAL32)
end
local ____lambda_9 = function()
    return __K2L_BigDecimal.ONE:remainder(__K2L_BigDecimal.ZERO)
end
local ____lambda_10 = function()
    return __K2L_BigDecimal.fromBigInteger(__K2L_BigInteger.TEN:pow(30)):divide(__K2L_BigDecimal.ZERO, 2, __K2L_RoundingMode.UP)
end
local ____lambda_11 = function() return __K2L_BigDecimal.TEN:pow(-1) end
local ____lambda_12 = function() return __K2L_BigDecimal.parse("") end
local ____lambda_13 = function() return __K2L_BigDecimal.parse("-") end
local ____lambda_14 = function() return __K2L_BigDecimal.parse("abc") end
local ____lambda_15 = function() return __K2L_BigDecimal.parse("1.2.3") end
local ____lambda_16 = function() return __K2L_BigDecimal.parse("1e") end
local ____lambda_17 = function() return __K2L_BigDecimal.parse("1e+") end
local ____lambda_18 = function() return __K2L_BigDecimal.parse("1ex") end
local ____lambda_19 = function() return __K2L_BigDecimal.fromDouble(0.0 / 0.0) end
local ____lambda_20 = function() return __K2L_BigDecimal.fromDouble(math.huge) end
local ____lambda_21 = function()
    return __K2L_BigDecimal.valueOfDouble(0.0 / 0.0)
end
local ____lambda_22 = function() return __K2L_RoundingMode.valueOf("SIDEWAYS") end
local function failures()
    print("-- failures")
    local function attempt(label, block)
        local ____ok_1, ____result_1 = pcall(function()
            print(label .. ": " .. __K2L_Str(block()))
        end)
        if not ____ok_1 then
            local ____error_1 = __K2L_ToThrowable(____result_1)
            if __K2L_InstanceOf(____error_1, __K2L_Exception) then
                local e = ____error_1
                print(label .. ": " .. __K2L_Str(__K2L_KClassOfValue(e).simpleName) .. ": " .. __K2L_Str(e.message))
            else
                error(____error_1, 0)
            end
        end
    end
    attempt("div0", ____lambda_3)
    attempt("0div0", ____lambda_4)
    attempt("exact1", ____lambda_5)
    attempt("exact2", ____lambda_6)
    attempt("scaled0", ____lambda_7)
    attempt("mc0", ____lambda_8)
    attempt("rem0", ____lambda_9)
    attempt("big0", ____lambda_10)
    attempt("pow", ____lambda_11)
    attempt("empty", ____lambda_12)
    attempt("sign", ____lambda_13)
    attempt("letters", ____lambda_14)
    attempt("twoDots", ____lambda_15)
    attempt("exp", ____lambda_16)
    attempt("exp2", ____lambda_17)
    attempt("exp3", ____lambda_18)
    attempt("nan", ____lambda_19)
    attempt("inf", ____lambda_20)
    attempt("valueOfNan", ____lambda_21)
    attempt("enum", ____lambda_22)
end

local function main()
    construction()
    arithmetic()
    scaling()
    division()
    formatting()
    comparisons()
    conversions()
    failures()
end

main()
return {MODES = MODES, construction = construction, arithmetic = arithmetic, scaling = scaling, division = division, formatting = formatting, comparisons = comparisons, conversions = conversions, failures = failures}
