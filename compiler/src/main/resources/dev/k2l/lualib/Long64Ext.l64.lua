-- requires: Long64, Exceptions
-- The less common Long and ULong operations of --long64 emulate, written over the core (Long64.l64*.lua).
local __K2L_Long64X = {}

do

local L = __K2L_Long64
local parts, uparts, make, makeU = L.parts, L.uparts, L.make, L.makeU
local add, sub, mul, neg, div, rem = L.add, L.sub, L.mul, L.neg, L.div, L.rem
local lt, le = L.lt, L.le
local floor = math.floor
local T32, T31 = 4294967296, 2147483648
local MIN, MAX = L.MIN, L.MAX
local DIGITS = "0123456789abcdefghijklmnopqrstuvwxyz"

local function overflow(kind)
    error(__K2L_ArithmeticException.new(kind .. " overflow"))
end

local X = __K2L_Long64X

-- digits of an unsigned value in [0, 2^64) given as a canonical Long pattern
local function unsignedDigits(a, radix)
    if type(a) == "number" and a >= 0 then
        local out = {}
        if a == 0 then
            return "0"
        end
        while a > 0 do
            local d = a % radix
            out[#out + 1] = DIGITS:sub(d + 1, d + 1)
            a = (a - d) / radix
        end
        return string.reverse(table.concat(out))
    end
    local out = {}
    while a ~= 0 do
        local d = L.toInt(L.urem(a, radix))
        out[#out + 1] = DIGITS:sub(d + 1, d + 1)
        a = L.udiv(a, radix)
    end
    return string.reverse(table.concat(out))
end

-- Long.toString(radix)
function X.strRadix(a, radix)
    if radix < 2 or radix > 36 then
        radix = 10
    end
    if radix == 10 then
        return L.str(a)
    end
    if lt(a, 0) then
        return "-" .. unsignedDigits(neg(a), radix)
    end
    return unsignedDigits(a, radix)
end

-- ULong.toString(radix), Long.toHexString() and friends
function X.ustrRadix(a, radix)
    if radix < 2 or radix > 36 then
        radix = 10
    end
    if radix == 10 then
        return L.ustr(a)
    end
    return unsignedDigits(a, radix)
end

-- The sign and digit values of an integer literal (ASCII, or Unicode digits when Utf16Case.lua sets X.unicodeDigits)
local function digitValues(s, radix)
    local sign, digits = s:match("^([+-]?)(%w+)$")
    if digits == nil then
        if X.unicodeDigits ~= nil and s:find("[\128-\255]") then
            return X.unicodeDigits(s, radix)
        end
        return nil
    end
    local values = {}
    for i = 1, #digits do
        local d = tonumber(digits:sub(i, i), 36)
        if d == nil or d >= radix then
            return nil
        end
        values[i] = d
    end
    return sign, values
end

-- String.toLong(radix) / toULong(radix): the value, or nil when the text is not a number of that type
function X.parse(s, radix, unsigned)
    radix = radix or 10
    if unsigned and (radix < 2 or radix > 36) then
        error(__K2L_IllegalArgumentException.new("radix " .. radix .. " was not in valid range 2..36"))
    end
    if radix == 10 and #s <= 15 and s:match("^%d+$") then
        return tonumber(s)
    end
    local sign, values = digitValues(s, radix)
    if values == nil or (unsigned and sign == "-") then
        return nil
    end
    local hi, lo = 0, 0
    for i = 1, #values do
        lo = lo * radix + values[i]
        local carry = floor(lo / T32)
        lo = lo - carry * T32
        hi = hi * radix + carry
        if hi >= T32 then
            return nil
        end
    end
    if unsigned then
        return makeU(hi, lo)
    elseif sign == "-" then
        if hi > T31 or (hi == T31 and lo > 0) then
            return nil
        end
        return neg(makeU(hi, lo))
    elseif hi >= T31 then
        return nil
    end
    return makeU(hi, lo)
end

function X.parseOrThrow(s, radix, unsigned)
    local n = X.parse(s, radix, unsigned)
    if n == nil then
        if unsigned then
            error(__K2L_NumberFormatException.new("Invalid number format: '" .. s .. "'"))
        end
        local suffix = (radix ~= nil and radix ~= 10) and " under radix " .. radix or ""
        error(__K2L_NumberFormatException.new("For input string: \"" .. s .. "\"" .. suffix))
    end
    return n
end

-- POP8[b + 1]: the number of one bits of the byte b
local POP8 = {}
for b = 0, 255 do
    local n, x = 0, b
    while x > 0 do
        n, x = n + x % 2, floor(x / 2)
    end
    POP8[b + 1] = n
end

local function bitCount(x)
    local count = 0
    while x > 0 do
        local b = x % 256
        count, x = count + POP8[b + 1], (x - b) / 256
    end
    return count
end

local function bitLength(x)
    local n = 0
    while x > 0 do
        n, x = n + 1, floor(x / 2)
    end
    return n
end

function X.ones(a)
    local hi, lo = uparts(a)
    return bitCount(hi) + bitCount(lo)
end

function X.clz(a)
    local hi, lo = uparts(a)
    if hi > 0 then
        return 32 - bitLength(hi)
    end
    return 64 - bitLength(lo)
end

function X.ctz(a)
    local hi, lo = uparts(a)
    if lo == 0 and hi == 0 then
        return 64
    end
    local word, base = lo, 0
    if lo == 0 then
        word, base = hi, 32
    end
    local n = 0
    while word % 2 == 0 do
        n, word = n + 1, word / 2
    end
    return base + n
end

-- takeHighestOneBit / takeLowestOneBit
function X.highest(a)
    local hi, lo = uparts(a)
    if hi > 0 then
        return makeU(2 ^ (bitLength(hi) - 1), 0)
    elseif lo > 0 then
        return makeU(0, 2 ^ (bitLength(lo) - 1))
    end
    return 0
end

function X.lowest(a)
    local hi, lo = uparts(a)
    if lo > 0 then
        local p = 1
        while lo % (p * 2) == 0 do
            p = p * 2
        end
        return makeU(0, p)
    elseif hi > 0 then
        local p = 1
        while hi % (p * 2) == 0 do
            p = p * 2
        end
        return makeU(p, 0)
    end
    return 0
end

function X.rotl(a, n)
    n = n % 64
    if n == 0 then
        return a
    end
    return L.bor(L.shl(a, n), L.ushr(a, 64 - n))
end

function X.rotr(a, n)
    return X.rotl(a, -n)
end

function X.abs(a)
    if lt(a, 0) then
        return neg(a)
    end
    return a
end

function X.sign(a)
    return L.cmp(a, 0)
end

function X.floorDiv(a, b)
    local q = div(a, b)
    if (lt(a, 0) ~= lt(b, 0)) and rem(a, b) ~= 0 then
        return sub(q, 1)
    end
    return q
end

function X.floorMod(a, b)
    local r = rem(a, b)
    if r ~= 0 and (lt(r, 0) ~= lt(b, 0)) then
        return add(r, b)
    end
    return r
end

function X.min(a, b)
    return lt(b, a) and b or a
end

function X.max(a, b)
    return lt(a, b) and b or a
end

-- Math.addExact(long, long) and friends
function X.addExact(a, b)
    local r = add(a, b)
    if le(0, b) then
        if lt(r, a) then
            overflow("long")
        end
    elseif lt(a, r) then
        overflow("long")
    end
    return r
end

function X.subExact(a, b)
    local r = sub(a, b)
    if le(0, b) then
        if lt(a, r) then
            overflow("long")
        end
    elseif lt(r, a) then
        overflow("long")
    end
    return r
end

function X.mulExact(a, b)
    if a == 0 or b == 0 then
        return 0
    end
    local r = mul(a, b)
    if (a == -1 and b == MIN) or (b == -1 and a == MIN) or div(r, b) ~= a then
        overflow("long")
    end
    return r
end

function X.negExact(a)
    if a == MIN then
        overflow("long")
    end
    return neg(a)
end

function X.incExact(a)
    if a == MAX then
        overflow("long")
    end
    return add(a, 1)
end

function X.decExact(a)
    if a == MIN then
        overflow("long")
    end
    return sub(a, 1)
end

function X.absExact(a)
    if a == MIN then
        error(__K2L_ArithmeticException.new("Overflow to represent absolute value of Long.MIN_VALUE"))
    end
    return X.abs(a)
end

function X.toIntExact(a)
    if lt(a, -T31) or lt(2147483647, a) then
        overflow("integer")
    end
    return L.toInt(a)
end

-- Math.round(double): half up, saturating, NaN is 0
function X.round(x)
    if x ~= x then
        return 0
    end
    local f = floor(x)
    if x - f >= 0.5 then
        f = f + 1
    end
    return L.fromDouble(f)
end

-- Double.roundToLong()
function X.roundToLong(x)
    if x ~= x then
        error(__K2L_IllegalArgumentException.new("Cannot round NaN value."))
    end
    return X.round(x)
end

-- Double.toBits() / toRawBits(): the IEEE 754 pattern as a Long
function X.doubleBits(x)
    if x ~= x then
        return makeU(0x7FF80000, 0)
    end
    local sign = 0
    if x < 0 or (x == 0 and 1 / x < 0) then
        sign, x = 0x80000000, -x
    end
    if x == math.huge then
        return makeU(sign + 0x7FF00000, 0)
    elseif x == 0 then
        return makeU(sign, 0)
    end
    local m, e = math.frexp(x)
    local biased = e - 1 + 1023
    local frac
    if biased <= 0 then
        biased, frac = 0, x / 2 ^ -1074
    else
        frac = (m * 2 - 1) * 2 ^ 52
    end
    local hi = floor(frac / T32)
    return makeU(sign + biased * 0x100000 + hi, frac - hi * T32)
end

-- Double.fromBits(bits)
function X.doubleFromBits(bits)
    local hi, lo = uparts(bits)
    local negative = hi >= T31
    local exponent = floor(hi / 0x100000) % 2048
    local fraction = (hi % 0x100000) * T32 + lo
    local value
    if exponent == 2047 then
        value = fraction == 0 and math.huge or 0 / 0
    elseif exponent == 0 then
        value = math.ldexp(fraction, -1074)
    else
        value = math.ldexp(1 + fraction / 4503599627370496, exponent - 1023)
    end
    return negative and -value or value
end

-- BigInteger.toLong(): the low 64 bits of the value (wraps like the JVM); mag is little-endian base 10^7
function X.bigToLong(big)
    local acc = 0
    local mag = big.mag
    for i = #mag, 1, -1 do
        acc = add(mul(acc, 10000000), mag[i])
    end
    if big.sign < 0 then
        return neg(acc)
    end
    return acc
end

function X.bigToLongExact(big)
    if big:bitLength() > 63 then
        error(__K2L_ArithmeticException.new("BigInteger out of long range"))
    end
    return X.bigToLong(big)
end

-- maxOf / minOf / coerceAtLeast / coerceAtMost / coerceIn of ULong
function X.umax(a, b)
    return L.ucmp(a, b) < 0 and b or a
end

function X.umin(a, b)
    return L.ucmp(b, a) < 0 and b or a
end

function X.ucoerceIn(x, lo, hi)
    if L.ucmp(lo, hi) > 0 then
        error(__K2L_IllegalArgumentException.new("Cannot coerce value to an empty range: maximum " .. L.ustr(hi) ..
            " is less than minimum " .. L.ustr(lo) .. "."))
    end
    return X.umin(X.umax(x, lo), hi)
end

-- the first value, the number of elements and the (signed) step of a LongRange object
function X.rangeOf(r)
    local step = r.step
    local descending = lt(step, 0)
    local first, count = X.range(r.first, r.last, descending and neg(step) or step, true, descending, r.unsigned)
    return first, count, step
end

-- for (i in first..last): the first value and the number of elements, which is clamped to a safe integer
function X.range(first, last, step, inclusive, descending, unsigned)
    step = step or 1
    if lt(step, 1) then
        error(__K2L_IllegalArgumentException.new("Step must be positive, was: " .. L.str(step) .. "."))
    end
    local c = unsigned and L.ucmp or L.cmp
    local order = c(first, last)
    local diff
    if descending then
        if order < 0 then
            return first, 0
        end
        diff = sub(first, last)
    else
        if order > 0 or (not inclusive and order == 0) then
            return first, 0
        end
        diff = sub(last, first)
        if not inclusive then
            diff = sub(diff, 1)
        end
    end
    local q = L.udiv(diff, step)
    if type(q) ~= "number" or q < 0 or q >= 9007199254740990 then
        return first, 9007199254740991
    end
    return first, q + 1
end

end
