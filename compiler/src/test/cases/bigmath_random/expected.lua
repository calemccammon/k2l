local ____lualib = require("lualib_bundle")
local __K2L_BigDecimal = ____lualib.__K2L_BigDecimal
local __K2L_BigInteger = ____lualib.__K2L_BigInteger
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IRem = ____lualib.__K2L_IRem
local __K2L_MathContext = ____lualib.__K2L_MathContext
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_RoundingMode = ____lualib.__K2L_RoundingMode
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_Text = ____lualib.__K2L_Text

local ____exports = {}
____exports.seed = 123457

local function ____next(bound)
    ____exports.seed = math.fmod(____exports.seed * 1103 + 12345, 1000003)
    return __K2L_IRem(__K2L_IDiv(____exports.seed, 7), bound)
end

local function digits(length)
    local sb = __K2L_StringBuilder.new()
    sb:append(string.char(("1"):byte() + ____next(9)))
    for it = 0, length - 1 - 1 do
        sb:append(string.char(("0"):byte() + ____next(10)))
    end
    return sb:toString()
end

local function randomInteger()
    local kind = ____next(10)
    local length = kind == 0 and 1 + ____next(3) or 1 + ____next(70)
    local text
    if kind == 1 then
        text = __K2L_Text.repeatCount("9", length)
    else
        text = kind == 2 and "1" .. __K2L_Text.repeatCount("0", length) or digits(length)
    end
    return __K2L_BigInteger.parse((____next(3) == 0 and "-" or "") .. text)
end

local function integers()
    print("-- integers")
    for i = 1, 150 do
        local a = randomInteger()
        local b = randomInteger()
        local sum = a:add(b)
        local diff = a:subtract(b)
        local product = a:multiply(b)
        local q = a:divide(b)
        local r = a:remainder(b)
        local check = __K2L_Equals(q:multiply(b):add(r), a) and __K2L_Compare(r:abs(), b:abs()) < 0
        local shift = ____next(80)
        print(i .. " " .. sum:hashCode() .. " " .. diff:hashCode() .. " " .. product:hashCode() .. " " .. q:hashCode() .. " " .. r:hashCode() .. " " .. tostring(check) .. " " .. a:gcd(b):hashCode() .. " " .. a:shiftLeft(shift):hashCode() .. " " .. a:shiftRight(shift):hashCode() .. " " .. a:band(b):hashCode() .. " " .. a:bor(b):hashCode() .. " " .. a:bxor(b):hashCode() .. " " .. a:compareTo(b) .. " " .. a:bitLength() .. " " .. tostring(a:mod(b:abs()):hashCode()))
        local text = a:toString(16)
        if not __K2L_Equals(__K2L_BigInteger.parse(text, 16), a) or not __K2L_Equals(__K2L_BigInteger.parse(a:toString(7), 7), a) then
            print("radix round trip failed for " .. __K2L_Str(a))
        end
        if __K2L_Compare(a:abs():sqrt():pow(2), a:abs()) > 0 then
            print("sqrt too big for " .. __K2L_Str(a))
        end
    end
    local a = randomInteger()
    local b = randomInteger()
    print(__K2L_Str(a:multiply(b)) .. " " .. __K2L_Str(a:divide(b)) .. " " .. __K2L_Str(a:remainder(b)))
end

local function decimals()
    print("-- decimals")
    local modes = __K2L_ReadOnlyListOf(__K2L_RoundingMode.UP, __K2L_RoundingMode.DOWN, __K2L_RoundingMode.CEILING, __K2L_RoundingMode.FLOOR, __K2L_RoundingMode.HALF_UP, __K2L_RoundingMode.HALF_DOWN, __K2L_RoundingMode.HALF_EVEN)
    for i = 1, 120 do
        local a = __K2L_BigDecimal.fromBigInteger(randomInteger(), ____next(12) - 3)
        local b = __K2L_BigDecimal.fromBigInteger(randomInteger(), ____next(12) - 3)
        local scale = ____next(8)
        local mode = modes:get(____next(modes.size))
        local precision = 1 + ____next(20)
        print(i .. " " .. __K2L_Str(a) .. " | " .. __K2L_Str(b) .. " | " .. __K2L_Str(a:add(b)) .. " | " .. __K2L_Str(a:subtract(b)) .. " | " .. __K2L_Str(a:multiply(b)))
        print("  " .. __K2L_Str(a:divide(b, scale, mode)) .. " " .. __K2L_Str(a:divide(b, __K2L_MathContext.new(precision, mode))) .. " " .. __K2L_Str(a:setScale(scale, mode)) .. " " .. __K2L_Str(a:round(__K2L_MathContext.new(precision, mode))))
        print("  " .. a:compareTo(b) .. " " .. tostring(__K2L_Equals(a, b)) .. " " .. a:hashCode() .. " " .. __K2L_Str(a:stripTrailingZeros()) .. " " .. __K2L_Str(a:toPlainString()) .. " " .. a:precision() .. " " .. a:negate():scale())
        print("  " .. __K2L_Str(a:remainder(b)) .. " " .. __K2L_Str(a:divideToIntegralValue(b)) .. " " .. __K2L_Str(a:toDouble()) .. " " .. __K2L_Str(a:toBigInteger()))
    end
end

local function main()
    integers()
    decimals()
end

____exports.____next = ____next
____exports.digits = digits
____exports.randomInteger = randomInteger
____exports.integers = integers
____exports.decimals = decimals
main()
return ____exports
