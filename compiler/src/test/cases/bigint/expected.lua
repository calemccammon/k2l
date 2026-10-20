local ____lualib = require("lualib_bundle")
local __K2L_BigInteger = ____lualib.__K2L_BigInteger
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function factorial(n)
    local result = __K2L_BigInteger.ONE
    for i = 2, n do
        result = result:multiply(__K2L_BigInteger.valueOf(i))
    end
    return result
end

local function fibonacci(n)
    local a = __K2L_BigInteger.ZERO
    local b = __K2L_BigInteger.ONE
    for it = 0, n - 1 do
        do
            local ____next = a:add(b)
            a = b
            b = ____next
        end
    end
    return a
end

local function construction()
    print("-- construction")
    print(__K2L_Str(__K2L_BigInteger.parse("123456789012345678901234567890")))
    print(__K2L_Str(__K2L_BigInteger.parse("-0042")))
    print(__K2L_Str(__K2L_BigInteger.parse("+17")))
    print(__K2L_Str(__K2L_BigInteger.parse("ff", 16)))
    print(__K2L_Str(__K2L_BigInteger.parse("-FF", 16)))
    print(__K2L_Str(__K2L_BigInteger.parse("101101", 2)))
    print(__K2L_Str(__K2L_BigInteger.parse("zz", 36)))
    print(__K2L_Str(__K2L_BigInteger.parse("0")))
    print(__K2L_Str(__K2L_BigInteger.parse("-0")))
    print(__K2L_Str(__K2L_BigInteger.valueOf(-9007199254740991)))
    print(__K2L_Str(__K2L_BigInteger.valueOf(42)))
    print(__K2L_Str(__K2L_BigInteger.valueOf(-7)))
    print(__K2L_Str(__K2L_BigInteger.parse("98765432109876543210")))
    print(__K2L_Str(__K2L_BigInteger.parse("1f", 16)))
    print(__K2L_Str(__K2L_BigInteger.parseOrNull("12x")))
    print(__K2L_Str(__K2L_BigInteger.parseOrNull("-12")))
    print(__K2L_Str(__K2L_BigInteger.parseOrNull("+12")))
    print(__K2L_Str(__K2L_BigInteger.parseOrNull("")))
    print(__K2L_Str(__K2L_BigInteger.ZERO))
    print(__K2L_Str(__K2L_BigInteger.ONE))
    print(__K2L_Str(__K2L_BigInteger.TWO))
    print(__K2L_Str(__K2L_BigInteger.TEN))
end

local function big()
    print("-- big values")
    print(__K2L_Str(factorial(50)))
    print(__K2L_Str(factorial(25):toString(16)))
    print(__K2L_Str(factorial(30):toString(2)))
    print(__K2L_Str(factorial(20):toString(36)))
    print(__K2L_Str(__K2L_BigInteger.TWO:pow(200)))
    print(__K2L_Str(__K2L_BigInteger.TWO:pow(200):toString(16)))
    print(__K2L_Str(__K2L_BigInteger.TWO:pow(64):subtract(__K2L_BigInteger.ONE)))
    print(__K2L_Str(fibonacci(300)))
    print(__K2L_Str(__K2L_BigInteger.TEN:pow(40):add(__K2L_BigInteger.ONE)))
    print(__K2L_Str(factorial(40):divide(factorial(38))))
    print(__K2L_Str(factorial(60):remainder(__K2L_BigInteger.parse("1000000007"))))
    print(__K2L_Str(factorial(22):negate():toString(7)))
end

local function divisions()
    print("-- division")
    local values = __K2L_ReadOnlyListOf("7", "-7", "1000000000000000000000", "-1000000000000000000001")
    local divisors = __K2L_ReadOnlyListOf("2", "-2", "3", "123456789123456789", "-99999999999999999999")
    local ____mod_1 = values.____modCount
    for ____i_1 = 1, values.size do
        local a = values[____i_1]
        local ____mod = divisors.____modCount
        for ____i = 1, divisors.size do
            local b = divisors[____i]
            local x = __K2L_BigInteger.parse(a)
            local y = __K2L_BigInteger.parse(b)
            local qr = x:divideAndRemainder(y)
            print(a .. " / " .. b .. " = " .. __K2L_Str(x:divide(y)) .. " rem " .. __K2L_Str(x:remainder(y)) .. " mod " .. __K2L_Str(x:mod(y:abs())) .. " qr=" .. __K2L_Str(qr:get(0)) .. "," .. __K2L_Str(qr:get(1)) .. " " .. tostring(__K2L_Equals(x:divide(y):multiply(y):add(x:remainder(y)), x)))
            if divisors.____modCount ~= ____mod and divisors:____comodified(____i) then
                break
            end
        end
        if values.____modCount ~= ____mod_1 and values:____comodified(____i_1) then
            break
        end
    end
    local huge = __K2L_BigInteger.parse("98765432109876543210987654321098765432109876543210")
    local divisor = __K2L_BigInteger.parse("12345678901234567890123")
    print(__K2L_Str(huge:divide(divisor)))
    print(__K2L_Str(huge:remainder(divisor)))
    print(__K2L_Str(huge:remainder(divisor:negate())))
    print(__K2L_Str(huge:divide(__K2L_BigInteger.valueOf(10000000))))
    print(__K2L_Str(__K2L_BigInteger.parse("100000000000000000000000000000000"):divide(__K2L_BigInteger.parse("10000000000000000"))))
    print(__K2L_Str(__K2L_BigInteger.parse("99999999999999999999999999999999"):divide(__K2L_BigInteger.parse("99999999999999999"))))
end

local function bits()
    print("-- bits")
    local values = __K2L_ReadOnlyListOf("0", "1", "-1", "255", "-256", "123456789012345678901234567890", "-123456789012345678901234567890")
    local ____mod_2 = values.____modCount
    for ____i_2 = 1, values.size do
        local a = values[____i_2]
        local x = __K2L_BigInteger.parse(a)
        print(a .. ": bitLength=" .. x:bitLength() .. " bitCount=" .. x:bitCount() .. " lowest=" .. x:getLowestSetBit() .. " not=" .. __K2L_Str(x:bnot()) .. " signum=" .. x:signum())
        print("  shl 5=" .. __K2L_Str(x:shiftLeft(5)) .. " shr 5=" .. __K2L_Str(x:shiftRight(5)) .. " shl 100=" .. __K2L_Str(x:shiftLeft(100)) .. " shr 100=" .. __K2L_Str(x:shiftRight(100)) .. " shr -3=" .. __K2L_Str(x:shiftRight(-3)))
        if values.____modCount ~= ____mod_2 and values:____comodified(____i_2) then
            break
        end
    end
    local ____pairs = __K2L_ReadOnlyListOf(__K2L_Pair.new("12345678901234567890", "-987654321"), __K2L_Pair.new("-5", "3"), __K2L_Pair.new("-123456789012345678901234567890", "-7"), __K2L_Pair.new("0", "-1"))
    local ____mod_3 = ____pairs.____modCount
    for ____i_3 = 1, ____pairs.size do
        local ____item = ____pairs[____i_3]
        local a, b = ____item.first, ____item.second
        local x = __K2L_BigInteger.parse(a)
        local y = __K2L_BigInteger.parse(b)
        print(a .. ", " .. b .. ": and=" .. __K2L_Str(x:band(y)) .. " or=" .. __K2L_Str(x:bor(y)) .. " xor=" .. __K2L_Str(x:bxor(y)) .. " andNot=" .. __K2L_Str(x:andNot(y)))
        if ____pairs.____modCount ~= ____mod_3 and ____pairs:____comodified(____i_3) then
            break
        end
    end
    local m = __K2L_BigInteger.parse("-1000000000000000000000")
    print(m:testBit(0))
    print(m:testBit(70))
    print(m:testBit(200))
    print(__K2L_Str(m:setBit(3)))
    print(__K2L_Str(m:clearBit(69)))
    print(__K2L_Str(m:flipBit(100)))
    print(__K2L_BigInteger.ONE:shiftLeft(100):bitLength())
    print(__K2L_BigInteger.ONE:shiftLeft(100):subtract(__K2L_BigInteger.ONE):bitLength())
    print(__K2L_BigInteger.ONE:shiftLeft(100):negate():bitLength())
end

local function conversions()
    print("-- conversions")
    local values = __K2L_ReadOnlyListOf("0", "1", "-1", "2147483647", "2147483648", "-2147483649", "4294967296", "123456789012345678901234567890", "-123456789012345678901234567890")
    local ____mod_4 = values.____modCount
    for ____i_4 = 1, values.size do
        local a = values[____i_4]
        local x = __K2L_BigInteger.parse(a)
        print(a .. ": int=" .. x:toInt() .. " hash=" .. x:hashCode() .. " double=" .. __K2L_Str(x:toDouble()))
        if values.____modCount ~= ____mod_4 and values:____comodified(____i_4) then
            break
        end
    end
    local longs = __K2L_ReadOnlyListOf("4503599627370496", "-4503599627370497", "123456789012", "9007199254740992", "4294967295")
    local ____mod_5 = longs.____modCount
    for ____i_5 = 1, longs.size do
        local a = longs[____i_5]
        print(a .. ": long=" .. __K2L_BigInteger.parse(a):toLong() .. " hash=" .. __K2L_BigInteger.parse(a):hashCode())
        if longs.____modCount ~= ____mod_5 and longs:____comodified(____i_5) then
            break
        end
    end
    print(__K2L_BigInteger.parse("18446744073709551616"):toLong())
    print(__K2L_BigInteger.parse("18446744073709551617"):toLong())
    print(__K2L_Str(__K2L_BigInteger.parse("1" .. ("0"):rep(400)):toDouble()))
    print(__K2L_Str(__K2L_BigInteger.parse("123456789012345678901234567890123456789"):toDouble()))
end

local function numberTheory()
    print("-- number theory")
    local a = __K2L_BigInteger.parse("123456789012345678901234567890")
    local b = __K2L_BigInteger.parse("987654321098765432109876543210")
    print(__K2L_Str(a:gcd(b)))
    print(__K2L_Str(a:gcd(__K2L_BigInteger.ZERO)))
    print(__K2L_Str(__K2L_BigInteger.ZERO:gcd(__K2L_BigInteger.ZERO)))
    print(__K2L_Str(a:negate():gcd(b)))
    print(__K2L_Str(__K2L_BigInteger.valueOf(3):modPow(__K2L_BigInteger.valueOf(200), __K2L_BigInteger.parse("1000000007"))))
    print(__K2L_Str(a:modPow(b, __K2L_BigInteger.parse("1000000000000000000000007"))))
    print(__K2L_Str(__K2L_BigInteger.valueOf(7):modPow(__K2L_BigInteger.valueOf(-1), __K2L_BigInteger.valueOf(40))))
    print(__K2L_Str(__K2L_BigInteger.valueOf(17):modInverse(__K2L_BigInteger.valueOf(3120))))
    print(__K2L_Str(a:sqrt()))
    print(__K2L_Str(__K2L_BigInteger.TEN:pow(41):sqrt()))
    print(__K2L_Str(__K2L_BigInteger.valueOf(99):sqrt()))
    print(__K2L_Str(__K2L_BigInteger.valueOf(100):sqrt()))
    print(__K2L_Str(__K2L_BigInteger.ZERO:sqrt()))
    print(__K2L_BigInteger.valueOf(1000000007):isProbablePrime(20))
    print(__K2L_BigInteger.valueOf(1000000011):isProbablePrime(20))
    print(__K2L_BigInteger.parse("170141183460469231731687303715884105727"):isProbablePrime(20))
    print(__K2L_BigInteger.parse("170141183460469231731687303715884105729"):isProbablePrime(20))
    print(__K2L_Str(__K2L_BigInteger.valueOf(100):nextProbablePrime()))
    print(__K2L_Str(__K2L_BigInteger.valueOf(-5):pow(3)))
    print(__K2L_Str(__K2L_BigInteger.valueOf(0):pow(0)))
    print(__K2L_Str(a:abs():min(b):max(__K2L_BigInteger.TEN)))
    print(__K2L_Equals(a:negate():abs(), a))
    print(a:signum())
end

local ____lambda_1 = function(it) return it end
local function comparisons()
    print("-- comparisons")
    local a = __K2L_BigInteger.parse("100000000000000000000")
    local b = __K2L_BigInteger.parse("99999999999999999999")
    local c = __K2L_BigInteger.parse("100000000000000000000")
    print(__K2L_Compare(a, b) > 0)
    print(__K2L_Compare(a, b) < 0)
    print(__K2L_Compare(a, c) >= 0)
    print(__K2L_Compare(a, b) <= 0)
    print(__K2L_Equals(a, c))
    print(not __K2L_Equals(a, c))
    print(a:equals(c))
    print(a:equals(b))
    print(a:compareTo(b))
    print(b:compareTo(a))
    print(a:compareTo(c))
    print(a:negate():compareTo(b))
    print(a:hashCode() == c:hashCode())
    local sorted = __K2L_ReadOnlyListOf(a, b, __K2L_BigInteger.ZERO, a:negate(), __K2L_BigInteger.TEN):sorted()
    print(__K2L_Str(sorted))
    print(__K2L_ReadOnlyListOf(a, b, c):distinct().size)
    print(__K2L_ReadOnlySetOf(a, c, b).size)
    local counts = __K2L_MapOf()
    local ____list = __K2L_ReadOnlyListOf(a, b, c, a)
    for ____i_6 = 1, ____list.size do
        local x = ____list[____i_6]
        counts:set(x, (counts:get(x) or 0) + 1)
    end
    print(__K2L_Str(counts))
    print(__K2L_Str(__K2L_ReadOnlyListOf(a, b):maxOrNull()))
    print(__K2L_Str(__K2L_ReadOnlyListOf(a, b):minByOrNull(____lambda_1)))
    print(__K2L_Str(__K2L_Num.maxOf(a, b)))
end

local ____lambda_2 = function(acc, v) return acc:multiply(v) end
local ____lambda_3 = function(it) return __K2L_BigInteger.parse(it) end
local ____lambda_4 = function(it) return __K2L_BigInteger.valueOf(it) end
local ____lambda_5 = function(acc, v) return acc:multiply(v) end
local function operators()
    print("-- operators")
    local x = __K2L_BigInteger.parse("5")
    x = x:inc()
    print(__K2L_Str(x))
    x = x:dec()
    x = x:dec()
    print(__K2L_Str(x))
    x = x:add(__K2L_BigInteger.TEN)
    x = x:multiply(x)
    x = x:subtract(__K2L_BigInteger.ONE)
    x = x:divide(__K2L_BigInteger.TWO)
    x = x:remainder(__K2L_BigInteger.valueOf(50))
    print(__K2L_Str(x))
    print(__K2L_Str(x:negate()))
    print(__K2L_Str(x:bnot()))
    local y = __K2L_BigInteger.parse("-12")
    print(__K2L_Str(y) .. " " .. __K2L_Str(x) .. " " .. __K2L_Str(y:multiply(x)) .. " " .. __K2L_Str(y:add(x)) .. " " .. __K2L_Str(y:subtract(x)))
    local ____list_1 = __K2L_ReadOnlyListOf(1, 2, 3, 4, 5)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list_1:____array()
    for ____i_7 = 1, ____n do
        local it = ____items[____i_7]
        ____count = ____count + 1
        ____out[____count] = __K2L_BigInteger.valueOf(it)
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count):fold(__K2L_BigInteger.ONE, ____lambda_2)))
    print(__K2L_Str(__K2L_ReadOnlyListOf("1", "2", "3"):sumOf(____lambda_3, __K2L_BigInteger.ZERO)))
    print(__K2L_Str(__K2L_IntRange.new(1, 5):map(____lambda_4):reduce(____lambda_5)))
end

local ____lambda_6 = function()
    return __K2L_BigInteger.TEN:divide(__K2L_BigInteger.ZERO)
end
local ____lambda_7 = function()
    return __K2L_BigInteger.TEN:remainder(__K2L_BigInteger.ZERO)
end
local ____lambda_8 = function()
    return __K2L_BigInteger.TEN:mod(__K2L_BigInteger.ZERO)
end
local ____lambda_9 = function()
    return __K2L_BigInteger.TEN:mod(__K2L_BigInteger.valueOf(-3))
end
local ____lambda_10 = function() return __K2L_BigInteger.valueOf(-4):sqrt() end
local ____lambda_11 = function() return __K2L_BigInteger.TEN:pow(-1) end
local ____lambda_12 = function()
    return __K2L_BigInteger.valueOf(4):modInverse(__K2L_BigInteger.valueOf(8))
end
local ____lambda_13 = function() return __K2L_BigInteger.parse("") end
local ____lambda_14 = function() return __K2L_BigInteger.parse("-") end
local ____lambda_15 = function() return __K2L_BigInteger.parse("abc") end
local ____lambda_16 = function() return __K2L_BigInteger.parse("12-3") end
local ____lambda_17 = function() return __K2L_BigInteger.parse("--3") end
local ____lambda_18 = function()
    return __K2L_BigInteger.parse("12345678901234567890x")
end
local ____lambda_19 = function() return __K2L_BigInteger.parse("12", 99) end
local ____lambda_20 = function() return __K2L_BigInteger.parse("xyz", 16) end
local ____lambda_21 = function() return __K2L_BigInteger.TEN:testBit(-1) end
local ____lambda_22 = function()
    return __K2L_BigInteger.parse("12345678901"):intValueExact()
end
local ____lambda_23 = function()
    return __K2L_BigInteger.parse("123456789012345678901"):longValueExact()
end
local function failures()
    print("-- failures")
    local function attempt(label, block)
        local ____ok, ____result = __K2L_DeepPcall(function()
            print(label .. ": " .. __K2L_Str(block()))
        end)
        if not ____ok then
            local ____error = __K2L_ToThrowable(____result)
            if __K2L_InstanceOf(____error, __K2L_Exception) then
                local e = ____error
                print(label .. ": " .. __K2L_Str(__K2L_KClassOfValue(e).simpleName) .. ": " .. __K2L_Str(e.message))
            else
                error(____error, 0)
            end
        end
    end
    attempt("div0", ____lambda_6)
    attempt("rem0", ____lambda_7)
    attempt("mod0", ____lambda_8)
    attempt("modNeg", ____lambda_9)
    attempt("sqrtNeg", ____lambda_10)
    attempt("powNeg", ____lambda_11)
    attempt("inverse", ____lambda_12)
    attempt("empty", ____lambda_13)
    attempt("sign only", ____lambda_14)
    attempt("letters", ____lambda_15)
    attempt("embedded", ____lambda_16)
    attempt("double sign", ____lambda_17)
    attempt("digit", ____lambda_18)
    attempt("radix", ____lambda_19)
    attempt("hex", ____lambda_20)
    attempt("bit", ____lambda_21)
    attempt("intExact", ____lambda_22)
    attempt("longExact", ____lambda_23)
end

local function main()
    construction()
    big()
    divisions()
    bits()
    conversions()
    numberTheory()
    comparisons()
    operators()
    failures()
end

__K2L_DeepMain(main)
return {factorial = factorial, fibonacci = fibonacci, construction = construction, big = big, divisions = divisions, bits = bits, conversions = conversions, numberTheory = numberTheory, comparisons = comparisons, operators = operators, failures = failures}
