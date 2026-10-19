-- requires: Exceptions, FloorDiv, Compare, Str
-- kotlin.math and number helpers that Lua's math library lacks or does differently.
local __K2L_Num = {}

do

local atan2 = math.atan2 or math.atan
local LN2 = math.log(2)
local MAX_LONG = math.maxinteger or 9223372036854775807
local MIN_LONG = math.mininteger or -9223372036854775808

function __K2L_Num.atan2(y, x)
    return atan2(y, x)
end

-- math.log(x, 10) is not available before Lua 5.2, and math.log10 is gone in 5.4.
function __K2L_Num.log10(x)
    if math.log10 then
        return math.log10(x)
    end
    return math.log(x, 10)
end

function __K2L_Num.log2(x)
    return math.log(x) / LN2
end

function __K2L_Num.log(x, base)
    if base <= 0 or base == 1 then
        return 0 / 0
    end
    return math.log(x) / math.log(base)
end

function __K2L_Num.ln1p(x)
    local u = 1 + x
    if u == 1 then
        return x
    end
    return math.log(u) * x / (u - 1)
end

function __K2L_Num.expm1(x)
    local u = math.exp(x)
    if u == 1 then
        return x
    end
    local um1 = u - 1
    if um1 == -1 then
        return -1.0
    end
    return um1 * x / math.log(u)
end

function __K2L_Num.sinh(x)
    return (math.exp(x) - math.exp(-x)) / 2
end

function __K2L_Num.cosh(x)
    return (math.exp(x) + math.exp(-x)) / 2
end

function __K2L_Num.tanh(x)
    if x > 20 then
        return 1.0
    elseif x < -20 then
        return -1.0
    end
    local a, b = math.exp(x), math.exp(-x)
    return (a - b) / (a + b)
end

function __K2L_Num.hypot(x, y)
    if x ~= x and y ~= y then
        return x
    end
    return math.sqrt(x * x + y * y)
end

-- Cube root, exact for perfect cubes.
function __K2L_Num.cbrt(x)
    if x == 0 or x ~= x or x == math.huge or x == -math.huge then
        return x
    end
    local a = math.abs(x)
    local y = a ^ (1 / 3)
    y = y - (y * y * y - a) / (3 * y * y)
    local r = math.floor(y + 0.5)
    if r * r * r == a then
        y = r
    end
    y = y + 0.0
    return x < 0 and -y or y
end

-- Math.ceil(-0.5) is -0.0
function __K2L_Num.ceil(x)
    local r = math.ceil(x) + 0.0
    if r == 0 and (x < 0 or 1 / x < 0) then
        return -0.0
    end
    return r
end

function __K2L_Num.truncate(x)
    if x ~= x or x == math.huge or x == -math.huge then
        return x
    end
    return (x >= 0 and math.floor(x) or math.ceil(x)) + 0.0
end

function __K2L_Num.signInt(x)
    if x > 0 then
        return 1
    elseif x < 0 then
        return -1
    end
    return 0
end

function __K2L_Num.signDouble(x)
    if x > 0 then
        return 1.0
    elseif x < 0 then
        return -1.0
    end
    return x
end

-- Round half to even, as kotlin.math.round and Math.rint do.
function __K2L_Num.round(x)
    if x ~= x or x == math.huge or x == -math.huge then
        return x
    end
    local f = math.floor(x)
    local d = x - f
    local r
    if d < 0.5 then
        r = f
    elseif d > 0.5 then
        r = f + 1
    elseif f % 2 == 0 then
        r = f
    else
        r = f + 1
    end
    if r == 0 and (x < 0 or 1 / x < 0) then
        return -0.0
    end
    return r + 0.0
end

-- Round half up, as Math.round does.
local function roundHalfUp(x)
    local f = math.floor(x)
    if x - f >= 0.5 then
        return f + 1
    end
    -- + 0: math.floor(-0.0) is -0.0 where integers are doubles
    return f + 0
end

function __K2L_Num.roundToInt(x)
    if x ~= x then
        error(__K2L_IllegalArgumentException.new("Cannot round NaN value."))
    elseif x >= 2147483647 then
        return 2147483647
    elseif x <= -2147483648 then
        return -2147483648
    end
    return roundHalfUp(x)
end

function __K2L_Num.roundToLong(x)
    if x ~= x then
        error(__K2L_IllegalArgumentException.new("Cannot round NaN value."))
    elseif x >= 9223372036854775807 then
        return MAX_LONG
    elseif x <= -9223372036854775808 then
        return MIN_LONG
    end
    return roundHalfUp(x)
end

function __K2L_Num.isInfinite(x)
    return x == math.huge or x == -math.huge
end

function __K2L_Num.isFinite(x)
    return x == x and x ~= math.huge and x ~= -math.huge
end

local DIGITS = "0123456789abcdefghijklmnopqrstuvwxyz"

-- Integer.toString(n, radix)
function __K2L_Num.toRadix(n, radix)
    if radix < 2 or radix > 36 then
        radix = 10
    end
    if n == 0 then
        return "0"
    end
    local negative = n < 0
    local out = {}
    if negative and n == MIN_LONG then
        -- -n would overflow: take the last place first
        local place = -math.fmod(n, radix)
        out[1] = DIGITS:sub(place + 1, place + 1)
        n = -__K2L_FloorDiv(n + place, radix)
    elseif negative then
        n = -n
    end
    while n > 0 do
        local digit = n % radix
        out[#out + 1] = DIGITS:sub(digit + 1, digit + 1)
        n = __K2L_FloorDiv(n - digit, radix)
    end
    return (negative and "-" or "") .. string.reverse(table.concat(out))
end

-- Integer.toBinaryString / toHexString / toOctalString: the 32-bit two's complement.
function __K2L_Num.toRadixUnsigned(n, radix)
    return __K2L_Num.toRadix(n % 4294967296, radix)
end

-- Long.toBinaryString/toOctalString/toHexString where a Long is a double: the digits of the 64-bit two's complement
-- pattern, [shift] bits each (exact while |n| < 2^53).
function __K2L_Num.longToUnsignedRadix(n, shift)
    local hi = math.floor(n / 4294967296)
    local words = {n - hi * 4294967296, hi % 4294967296}
    local out = {}
    for first = 0, 63, shift do
        local d = 0
        for b = 0, shift - 1 do
            local i = first + b
            if i < 64 and math.floor(words[math.floor(i / 32) + 1] / 2 ^ (i % 32)) % 2 == 1 then
                d = d + 2 ^ b
            end
        end
        out[#out + 1] = ("0123456789abcdef"):sub(d + 1, d + 1)
    end
    local digits = string.reverse(table.concat(out)):gsub("^0+", "")
    return digits == "" and "0" or digits
end

-- Integer.reverse: the 32 bits in reverse order
function __K2L_Num.reverseInt(x)
    x = x % 4294967296
    local r = 0
    for _ = 1, 32 do
        local b = x % 2
        r = r * 2 + b
        x = math.floor((x - b) / 2)
    end
    return r >= 2147483648 and r - 4294967296 or r
end

-- Character.getNumericValue: digits and the Latin letters (a and A are 10, up to 35), -1 for other characters.
function __K2L_Num.numericValue(c)
    local b = string.byte(c)
    if b >= 48 and b <= 57 then
        return b - 48
    elseif b >= 97 and b <= 122 then
        return b - 87
    elseif b >= 65 and b <= 90 then
        return b - 55
    end
    return -1
end

local POW2 = {[0] = 1}
for i = 1, 16 do
    POW2[i] = POW2[i - 1] * 2
end

-- Byte, Short, UByte and UShort .rotateLeft(n) within [bits] (8 or 16) bits; a negative n rotates right.
function __K2L_Num.rotateSmall(x, n, bits, signed)
    local size = POW2[bits]
    local u = x % size
    n = n % bits
    if n ~= 0 then
        local high = math.floor(u / POW2[bits - n])
        u = (u - high * POW2[bits - n]) * POW2[n] + high
    end
    if signed and u >= POW2[bits - 1] then
        u = u - size
    end
    return u
end

function __K2L_Num.countOneBits(n)
    n = n % 4294967296
    local count = 0
    while n > 0 do
        count = count + n % 2
        n = __K2L_FloorDiv(n, 2)
    end
    return count
end

function __K2L_Num.countTrailingZeroBits(n)
    n = n % 4294967296
    if n == 0 then
        return 32
    end
    local count = 0
    while n % 2 == 0 do
        count = count + 1
        n = __K2L_FloorDiv(n, 2)
    end
    return count
end

function __K2L_Num.countLeadingZeroBits(n)
    n = n % 4294967296
    local bits = 0
    while n > 0 do
        bits = bits + 1
        n = __K2L_FloorDiv(n, 2)
    end
    return 32 - bits
end

function __K2L_Num.toByte(n)
    return (n + 128) % 256 - 128
end

function __K2L_Num.toShort(n)
    return (n + 32768) % 65536 - 32768
end

-- Int.mod / Math.floorMod: the result has the sign of the divisor, which is Lua's %.
function __K2L_Num.mod(a, b)
    if b == 0 then
        error(__K2L_ArithmeticException.new("/ by zero"))
    end
    return a % b
end

-- Second resolution only; measureTimeMillis uses the CPU clock instead.
function __K2L_Num.currentTimeMillis()
    return os.time() * 1000
end

function __K2L_Num.nanoTime()
    return math.floor(os.clock() * 1e9)
end

function __K2L_Num.isNaN(x)
    return x ~= x
end

-- maxOf / minOf for Comparable values that are not numbers.
function __K2L_Num.maxOf(a, b)
    return __K2L_Compare(a, b) >= 0 and a or b
end

function __K2L_Num.minOf(a, b)
    return __K2L_Compare(a, b) <= 0 and a or b
end

function __K2L_Num.coerceIn(x, lo, hi)
    if __K2L_Compare(lo, hi) > 0 then
        error(__K2L_IllegalArgumentException.new(
            "Cannot coerce value to an empty range: maximum " .. __K2L_Str(hi) .. " is less than minimum " .. __K2L_Str(lo) .. "."))
    end
    if __K2L_Compare(x, lo) < 0 then
        return lo
    elseif __K2L_Compare(x, hi) > 0 then
        return hi
    end
    return x
end

-- coerceAtLeast/coerceAtMost of Comparable values: x < minimum is x.compareTo(minimum) < 0
function __K2L_Num.coerceAtLeast(x, minimum)
    return __K2L_Compare(x, minimum) < 0 and minimum or x
end

function __K2L_Num.coerceAtMost(x, maximum)
    return __K2L_Compare(x, maximum) > 0 and maximum or x
end

function __K2L_Num.coerceInRange(x, range)
    return __K2L_Num.coerceIn(x, range.first, range.last)
end

-- Char.digitToInt(radix): the value of a decimal or letter digit, or nil.
local function digitValue(c, radix)
    local value = tonumber(c, 36)
    if value == nil or #c ~= 1 or value >= (radix or 10) then
        return nil
    end
    return value
end

function __K2L_Num.digitToIntOrNull(c, radix)
    return digitValue(c, radix)
end

function __K2L_Num.digitToInt(c, radix)
    local value = digitValue(c, radix)
    if value == nil then
        error(__K2L_IllegalArgumentException.new("Char " .. c .. (radix and " is not a digit in the given radix=" .. radix or " is not a decimal digit")))
    end
    return value
end

function __K2L_Num.digitToChar(n, radix)
    radix = radix or 10
    if n < 0 or n >= radix then
        error(__K2L_IllegalArgumentException.new("Int " .. n .. " is not a digit in the radix " .. radix))
    end
    return DIGITS:sub(n + 1, n + 1):upper()
end

function __K2L_Num.measureTimeMillis(block)
    local start = os.clock()
    block()
    return math.floor((os.clock() - start) * 1000)
end

function __K2L_Num.measureNanoTime(block)
    local start = os.clock()
    block()
    return math.floor((os.clock() - start) * 1e9)
end

end
