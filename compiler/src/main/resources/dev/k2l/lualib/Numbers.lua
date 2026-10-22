-- requires: Exceptions, FloorDiv, Compare, Str
-- kotlin.math and number helpers that Lua's math library lacks or does differently.
local __K2L_Num = {}

do

local MIN_LONG = math.mininteger or -9223372036854775808
local exp, log, sqrt, abs, huge = math.exp, math.log, math.sqrt, math.abs, math.huge
local LN2 = log(2)

-- The functions of kotlin.math that Lua's math library lacks, as short formulas of k2l's own. They are accurate to a few
-- units in the last place, not the JVM's StrictMath bits.

-- exp(x) - 1 without the cancellation near 0 (Kahan): the error of exp(x) cancels in (u - 1) / log(u).
function __K2L_Num.expm1(x)
    local u = exp(x)
    if u == 1 then
        return x
    elseif u == huge then
        return u
    end
    local um1 = u - 1
    if um1 == -1 then
        return -1
    end
    return um1 * x / log(u)
end

-- log(1 + x) without the rounding of 1 + x (Kahan): x / (u - 1) corrects for it.
function __K2L_Num.log1p(x)
    local u = 1 + x
    if u == 1 then
        return x
    elseif u == huge then
        return u
    end
    return log(u) * x / (u - 1)
end

local expm1 = __K2L_Num.expm1

-- sinh, cosh and tanh by expm1 (accurate near 0); for large |x| exp(|x| - ln 2), which overflows only when the result does.
function __K2L_Num.sinh(x)
    local a = abs(x)
    local r
    if a > 20 then
        r = exp(a - LN2)
    else
        local e = expm1(a)
        r = (e + e / (e + 1)) / 2
    end
    return x < 0 and -r or r
end

function __K2L_Num.cosh(x)
    local a = abs(x)
    if a > 20 then
        return exp(a - LN2)
    end
    local e = exp(a)
    return (e + 1 / e) / 2
end

function __K2L_Num.tanh(x)
    local a = abs(x)
    local r
    if a > 20 then
        r = 1
    else
        local e = expm1(2 * a)
        r = e / (e + 2)
    end
    return x < 0 and -r or r
end

-- sqrt(x^2 + y^2) scaled by the larger one, so that neither the squares overflow nor underflow.
function __K2L_Num.hypot(x, y)
    x, y = abs(x), abs(y)
    if x == huge or y == huge then
        return huge
    elseif x < y then
        x, y = y, x
    end
    if x == 0 then
        return x
    end
    local r = y / x
    return x * sqrt(1 + r * r)
end

-- The real cube root: |x|^(1/3) with the sign of x, and one Newton step to correct the rounding of the power.
function __K2L_Num.cbrt(x)
    if x == 0 or x ~= x or x == huge or x == -huge then
        return x
    end
    local a = abs(x)
    local r = a ^ (1 / 3)
    r = r - (r * r * r - a) / (3 * r * r)
    return x < 0 and -r or r
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
    return x -- 0, or NaN
end

-- Round half to even, as kotlin.math.round and Math.rint do.
function __K2L_Num.round(x)
    local f = math.floor(x)
    local d = x - f
    if d > 0.5 or (d == 0.5 and f % 2 ~= 0) then
        return f + 1
    end
    return f
end

-- x.IEEErem(y) (Math.IEEEremainder): x - n * y for the integer n nearest x / y, ties to even (inexact when x / y is large)
function __K2L_Num.IEEErem(x, y)
    return x - y * __K2L_Num.round(x / y)
end

function __K2L_Num.isInfinite(x)
    return x == math.huge or x == -math.huge
end

function __K2L_Num.isFinite(x)
    return x == x and x ~= math.huge and x ~= -math.huge
end

local DIGITS = "0123456789abcdefghijklmnopqrstuvwxyz"

-- the radixes string.format writes (for magnitudes below 2^53, which every target formats exactly)
local RADIX_FORMATS = {[8] = "%o", [16] = "%x"}

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
    local fast = RADIX_FORMATS[radix]
    if fast ~= nil and n < 9007199254740992 then
        return (negative and "-" or "") .. string.format(fast, n)
    end
    while n > 0 do
        local digit = n % radix
        out[#out + 1] = DIGITS:sub(digit + 1, digit + 1)
        n = __K2L_FloorDiv(n - digit, radix)
    end
    return (negative and "-" or "") .. string.reverse(table.concat(out))
end

local POW2 = {[0] = 1}
for i = 1, 16 do
    POW2[i] = POW2[i - 1] * 2
end

-- Byte and Short .rotateLeft(n) within [bits] (8 or 16) bits; a negative n rotates right.
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

-- POP8[b + 1]: the number of one bits of the byte b
local POP8 = {}
for b = 0, 255 do
    POP8[b + 1] = b % 2 + (POP8[(b - b % 2) / 2 + 1] or 0)
end

function __K2L_Num.countOneBits(n)
    n = n % 4294967296
    local count = 0
    while n > 0 do
        local b = n % 256
        count, n = count + POP8[b + 1], (n - b) / 256
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
