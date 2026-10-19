-- requires: ToInt32
-- Bit-level number helpers for Lua 5.1, 5.2 and LuaJIT, where numbers are doubles. Long is a double there, so the
-- Long variants work on 32 bits like Long bitwise operations do, and a Double's 64-bit pattern is rounded to 53 bits.
local __K2L_Bits = {}

do

local frexp, ldexp, floor = math.frexp, math.ldexp, math.floor
local huge = math.huge
local TWO_32 = 4294967296

-- Int.rotateLeft(n); a negative n rotates right.
function __K2L_Bits.rotl32(x, n)
    n = n % 32
    local u = x % TWO_32
    local high = floor(u / 2 ^ (32 - n))
    return __K2L_ToInt32((u * 2 ^ n) % TWO_32 + high)
end

__K2L_Bits.rotl64 = __K2L_Bits.rotl32

function __K2L_Bits.highest32(x)
    local u = x % TWO_32
    if u == 0 then
        return 0
    end
    local _, e = frexp(u)
    return __K2L_ToInt32(2 ^ (e - 1))
end

__K2L_Bits.highest64 = __K2L_Bits.highest32

function __K2L_Bits.lowest32(x)
    local u = x % TWO_32
    if u == 0 then
        return 0
    end
    local bit = 1
    while u % 2 == 0 do
        u = u / 2
        bit = bit * 2
    end
    return __K2L_ToInt32(bit)
end

__K2L_Bits.lowest64 = __K2L_Bits.lowest32

-- Math.copySign for Double.withSign(sign): the sign of -0.0 counts.
function __K2L_Bits.withSign(x, sign)
    local negative = sign < 0 or (sign == 0 and 1 / sign < 0)
    local a = math.abs(x)
    if negative then
        return -a
    end
    return a
end

-- The spacing of numbers with `precision` significant bits, and the smallest exponent of their last place.
local function ulpOf(a, precision, minExponent)
    local _, e = frexp(a)
    local exponent = e - precision
    if exponent < minExponent then
        exponent = minExponent
    end
    return ldexp(1, exponent)
end

local function nextUpOf(x, precision, minExponent)
    if x ~= x or x == huge then
        return x
    elseif x == 0 then
        return ldexp(1, minExponent)
    elseif x > 0 then
        return x + ulpOf(x, precision, minExponent)
    end
    local a = -x
    local m, e = frexp(a)
    local step = ulpOf(a, precision, minExponent)
    -- below a power of two the spacing is halved
    if m == 0.5 and e - precision > minExponent then
        step = step / 2
    end
    local r = x + step
    if r == 0 then
        local zero = 0 -- a variable: Lua 5.1 folds -0.0 to 0
        return -zero
    end
    return r
end

local function ulpNumber(x, precision, minExponent, maxUlp)
    if x ~= x then
        return x
    end
    x = math.abs(x)
    if x == huge then
        return huge
    end
    local up = nextUpOf(x, precision, minExponent)
    if up == huge or up - x == 0 then
        return maxUlp
    end
    return up - x
end

local function nextTowardsOf(x, to, precision, minExponent)
    if x ~= x or to ~= to then
        return 0 / 0
    elseif x == to then
        return to
    elseif x < to then
        return nextUpOf(x, precision, minExponent)
    end
    return -nextUpOf(-x, precision, minExponent)
end

function __K2L_Bits.nextUp(x) return nextUpOf(x, 53, -1074) end
function __K2L_Bits.nextDown(x) return -nextUpOf(-x, 53, -1074) end
function __K2L_Bits.nextTowards(x, to) return nextTowardsOf(x, to, 53, -1074) end
function __K2L_Bits.ulp(x) return ulpNumber(x, 53, -1074, 1.9958403095347198e292) end
function __K2L_Bits.nextUpF(x) return nextUpOf(x, 24, -149) end
function __K2L_Bits.nextDownF(x) return -nextUpOf(-x, 24, -149) end
function __K2L_Bits.nextTowardsF(x, to) return nextTowardsOf(x, to, 24, -149) end
function __K2L_Bits.ulpF(x) return ulpNumber(x, 24, -149, 2.028240960365167e31) end

-- Float.toBits(): exact, a float pattern fits 32 bits.
function __K2L_Bits.floatBits(x)
    if x ~= x then
        return 0x7fc00000
    end
    local negative = x < 0 or (x == 0 and 1 / x < 0)
    local a = math.abs(x)
    local bits
    if a == huge then
        bits = 0x7f800000
    elseif a == 0 then
        bits = 0
    else
        local m, e = frexp(a)
        local biased = e + 126
        if biased <= 0 then
            bits = floor(ldexp(a, 149) + 0.5)
        else
            bits = biased * 8388608 + (floor(ldexp(m, 24)) - 8388608)
        end
    end
    if negative then
        bits = bits - 2147483648
    end
    return bits
end

__K2L_Bits.floatRawBits = __K2L_Bits.floatBits

function __K2L_Bits.floatFromBits(bits)
    local u = bits % TWO_32
    local negative = u >= 2147483648
    local magnitude = u % 2147483648
    local biased = floor(magnitude / 8388608)
    local fraction = magnitude % 8388608
    local value
    if biased == 255 then
        value = fraction == 0 and huge or 0 / 0
    elseif biased == 0 then
        value = ldexp(fraction, -149)
    else
        value = ldexp(1 + fraction / 8388608, biased - 127)
    end
    return negative and -value or value
end

-- Double.toBits(): the 64-bit pattern as a double, so only the top 53 bits survive.
function __K2L_Bits.doubleBits(x)
    if x ~= x then
        return 0x7ff8000000000000
    end
    local negative = x < 0 or (x == 0 and 1 / x < 0)
    local a = math.abs(x)
    local bits
    if a == huge then
        bits = 0x7ff0000000000000
    elseif a == 0 then
        bits = 0
    else
        local m, e = frexp(a)
        local biased = e + 1022
        if biased <= 0 then
            bits = floor(ldexp(a, 1074) + 0.5)
        else
            bits = biased * 4503599627370496 + (m * 9007199254740992 - 4503599627370496)
        end
    end
    if negative then
        bits = bits - 9223372036854775808
    end
    return bits
end

__K2L_Bits.doubleRawBits = __K2L_Bits.doubleBits

function __K2L_Bits.doubleFromBits(bits)
    local negative = bits < 0
    local magnitude = negative and bits + 9223372036854775808 or bits
    local biased = floor(magnitude / 4503599627370496)
    local fraction = magnitude - biased * 4503599627370496
    local value
    if biased == 2047 then
        value = fraction == 0 and huge or 0 / 0
    elseif biased == 0 then
        value = ldexp(fraction, -1074)
    else
        value = ldexp(1 + fraction / 4503599627370496, biased - 1023)
    end
    return negative and -value or value
end

end
