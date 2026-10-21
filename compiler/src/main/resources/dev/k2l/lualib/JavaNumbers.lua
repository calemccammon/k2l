-- requires: Exceptions, Strings, LongArith, Bit
-- The less common statics of java.lang.Integer, Long and Math: unsigned Int arithmetic, decode, the bit permutations of
-- Int and Long (Long ones on the two 32-bit halves of LongArith, so exact wherever a Long is), ceilDiv and the *Exact
-- divisions of Int, fma, scalb, getExponent, clamp and Double.toHexString. Written in arithmetic, so the one file serves
-- every target; the Long arithmetic that depends on the target is in JavaLongs.
local __K2L_JavaNumbers = {}

do

local J = __K2L_JavaNumbers
local floor, abs, fmod = math.floor, math.abs, math.fmod
local T32, T31, T16 = 4294967296, 2147483648, 65536
local INF = 1 / 0
local bxor = __K2L_BXor

local function int32(x)
    x = x % T32
    if x >= T31 then
        return x - T32
    end
    return x
end

local function divZero()
    error(__K2L_ArithmeticException.new("/ by zero"))
end

local function numberFormat(message)
    error(__K2L_NumberFormatException.new(message))
end

local function forInputString(s, radix)
    numberFormat("For input string: \"" .. s .. "\"" .. ((radix ~= nil and radix ~= 10) and " under radix " .. radix or ""))
end

------------------------------------------------------------------ unsigned Int

function J.compareUnsigned(a, b)
    a, b = a % T32, b % T32
    if a == b then
        return 0
    end
    return a < b and -1 or 1
end

function J.divideUnsigned(a, b)
    b = b % T32
    if b == 0 then
        divZero()
    end
    return int32(floor((a % T32) / b))
end

function J.remainderUnsigned(a, b)
    b = b % T32
    if b == 0 then
        divZero()
    end
    a = a % T32
    return int32(a - floor(a / b) * b)
end

function J.toUnsignedLong(a)
    return a % T32
end

-- whether `s` is an optional "+" and digits of the radix
local function isDigits(s, radix)
    local body = s:sub(1, 1) == "+" and s:sub(2) or s
    if body == "" then
        return false
    end
    for i = 1, #body do
        local d = tonumber(body:sub(i, i), 36)
        if d == nil or d >= (radix or 10) then
            return false
        end
    end
    return true
end

-- the exception of parseUnsignedInt and parseUnsignedLong (`kind` "int" or "long") for text that is not a number in range
function J.unsignedFailure(s, radix, kind)
    if isDigits(s, radix) then
        numberFormat("String value " .. s .. " exceeds range of unsigned " .. kind .. ".")
    end
    forInputString(s, radix)
end

local function checkUnsigned(s)
    if s == nil then
        numberFormat("Cannot parse null string: null")
    elseif s:sub(1, 1) == "-" then
        numberFormat("Illegal leading minus sign on unsigned string " .. s .. ".")
    end
end

J.checkUnsigned = checkUnsigned

-- Integer.parseUnsignedInt(s[, radix]), with the JDK's messages
function J.parseUnsignedInt(s, radix)
    checkUnsigned(s)
    local n = __K2L_StringToUnsignedOrNull(s, radix, 32)
    if n == nil then
        J.unsignedFailure(s, radix, "int")
    end
    return int32(n)
end

-- Integer.decode and Long.decode: the digits after the sign and the radix prefix (0x, 0X, # or 0), with the sign, and the radix
function J.decodePrep(s)
    if s == "" then
        numberFormat("Zero length string")
    end
    local i, sign, radix = 1, "", 10
    local first = s:sub(1, 1)
    if first == "-" or first == "+" then
        sign, i = first == "-" and "-" or "", 2
    end
    local rest = s:sub(i)
    if rest:sub(1, 2) == "0x" or rest:sub(1, 2) == "0X" then
        rest, radix = rest:sub(3), 16
    elseif rest:sub(1, 1) == "#" then
        rest, radix = rest:sub(2), 16
    elseif rest:sub(1, 1) == "0" and #rest > 1 then
        rest, radix = rest:sub(2), 8
    end
    local c = rest:sub(1, 1)
    if c == "-" or c == "+" then
        numberFormat("Sign character in wrong position")
    end
    return sign .. rest, radix
end

function J.decode(s, long)
    local digits, radix = J.decodePrep(s)
    return __K2L_StringToInt(digits, radix, long)
end

-- Character.isISOControl(codePoint)
function J.isISOControl(cp)
    return (cp >= 0 and cp <= 0x1F) or (cp >= 0x7F and cp <= 0x9F)
end

-- Character.reverseBytes: the two bytes of the code unit swapped
function J.reverseChar(code)
    return (code % 256) * 256 + floor(code / 256)
end

-- Integer.getInteger, Long.getLong and Boolean.getBoolean: Lua has no system properties
function J.property(_, default)
    return default
end

------------------------------------------------------------------ bit permutations

local function reverse32(x)
    local r = 0
    for _ = 1, 32 do
        local b = x % 2
        r = r * 2 + b
        x = floor(x / 2)
    end
    return r
end

local function bytes32(x)
    local b0 = x % 256
    x = floor(x / 256)
    local b1 = x % 256
    x = floor(x / 256)
    local b2 = x % 256
    return ((b0 * 256 + b1) * 256 + b2) * 256 + floor(x / 256)
end

function J.reverseBytes(a)
    return int32(bytes32(a % T32))
end

-- the bits of `x` where `mask` has ones, packed to the low end (compress), or spread to them (expand); `bits` is 32 or 64
local function permute(x, mask, bits, packing)
    local r, k, xp, kp = 0, 0, 1, 1
    for _ = 1, bits do
        local m = mask % 2
        mask = floor(mask / 2)
        if m == 1 then
            local source = packing and xp or kp
            local target = packing and kp or xp
            if floor(x / source) % 2 == 1 then
                r = r + target
            end
            k, kp = k + 1, kp * 2
        end
        xp = xp * 2
    end
    return r
end

function J.compress(x, mask)
    return int32(permute(x % T32, mask % T32, 32, true))
end

function J.expand(x, mask)
    return int32(permute(x % T32, mask % T32, 32, false))
end

local halves, fromHalves = __K2L_LongArith.halves, __K2L_LongArith.fromHalves

local function uhalves(x)
    local hi, lo = halves(x)
    return hi % T32, lo
end

local function long(hi, lo)
    return fromHalves(hi >= T31 and hi - T32 or hi, lo)
end

function J.reverseLong(x)
    local hi, lo = uhalves(x)
    return long(reverse32(lo), reverse32(hi))
end

function J.reverseBytesLong(x)
    local hi, lo = uhalves(x)
    return long(bytes32(lo), bytes32(hi))
end

-- compress and expand of a Long: the 64-bit pattern as a pair of words, permuted bit by bit
local function permuteLong(x, mask, packing)
    local xh, xl = uhalves(x)
    local mh, ml = uhalves(mask)
    local src, msk, out = {xl, xh}, {ml, mh}, {0, 0}
    local k = 0
    for i = 0, 63 do
        local mw = msk[floor(i / 32) + 1]
        if floor(mw / 2 ^ (i % 32)) % 2 == 1 then
            local from, to = packing and i or k, packing and k or i
            if floor(src[floor(from / 32) + 1] / 2 ^ (from % 32)) % 2 == 1 then
                local w = floor(to / 32) + 1
                out[w] = out[w] + 2 ^ (to % 32)
            end
            k = k + 1
        end
    end
    return long(floor(out[2]), floor(out[1]))
end

function J.compressLong(x, mask)
    return permuteLong(x, mask, true)
end

function J.expandLong(x, mask)
    return permuteLong(x, mask, false)
end

-- the 16-bit limbs of a 64-bit pattern, lowest first
local function limbs(x)
    local hi, lo = uhalves(x)
    return {lo % T16, floor(lo / T16), hi % T16, floor(hi / T16)}
end

-- the high 64 bits of the unsigned 128-bit product, as limbs; then a signed product subtracts the other factor for each
-- negative one (two's complement)
local function high64(a, b, signed)
    local x, y = limbs(a), limbs(b)
    local r = {0, 0, 0, 0, 0, 0, 0, 0, 0}
    for i = 1, 4 do
        local carry = 0
        for j = 1, 4 do
            local t = r[i + j - 1] + x[i] * y[j] + carry
            carry = floor(t / T16)
            r[i + j - 1] = t % T16
        end
        r[i + 4] = r[i + 4] + carry
    end
    local h = {r[5], r[6], r[7], r[8]}
    if signed then
        for _, pair in ipairs({{x, y}, {y, x}}) do
            if pair[1][4] >= 32768 then
                local borrow = 0
                for k = 1, 4 do
                    local t = h[k] - pair[2][k] - borrow
                    borrow = t < 0 and 1 or 0
                    h[k] = t % T16
                end
            end
        end
    end
    return long(h[4] * T16 + h[3], h[2] * T16 + h[1])
end

function J.multiplyHigh(a, b)
    return high64(a, b, true)
end

function J.unsignedMultiplyHigh(a, b)
    return high64(a, b, false)
end

------------------------------------------------------------------ Math of Int

local function overflow()
    error(__K2L_ArithmeticException.new("integer overflow"))
end

function J.ceilDiv(a, b)
    if b == 0 then
        divZero()
    end
    local q = floor(a / b)
    if q * b ~= a then
        q = q + 1
    end
    return q == T31 and -T31 or q
end

function J.ceilMod(a, b)
    return a - J.ceilDiv(a, b) * b
end

function J.divideExact(a, b)
    if a == -T31 and b == -1 then
        overflow()
    elseif b == 0 then
        divZero()
    end
    local q = a / b
    return q < 0 and -floor(-q) or floor(q)
end

function J.floorDivExact(a, b)
    if a == -T31 and b == -1 then
        overflow()
    elseif b == 0 then
        divZero()
    end
    return floor(a / b)
end

function J.ceilDivExact(a, b)
    if a == -T31 and b == -1 then
        overflow()
    end
    return J.ceilDiv(a, b)
end

------------------------------------------------------------------ Math of Double

-- Math.max and min as the JVM's: NaN wins, and 0.0 is above -0.0
local function maxD(a, b)
    if a ~= a then
        return a
    elseif a == 0 and b == 0 then
        return 1 / a < 0 and b or a
    end
    return a >= b and a or b
end

local function minD(a, b)
    if a ~= a then
        return a
    elseif a == 0 and b == 0 then
        return 1 / a < 0 and a or b
    end
    return a <= b and a or b
end

-- Math.clamp(value, min, max) of Doubles and Floats; `str` prints a bound for the message
function J.clampD(value, lo, hi, str)
    if not (lo < hi) then
        if lo ~= lo then
            error(__K2L_IllegalArgumentException.new("min is NaN"))
        elseif hi ~= hi then
            error(__K2L_IllegalArgumentException.new("max is NaN"))
        elseif lo > hi or (lo == 0 and hi == 0 and 1 / lo > 0 and 1 / hi < 0) then
            error(__K2L_IllegalArgumentException.new(str(lo) .. " > " .. str(hi)))
        end
    end
    return minD(hi, maxD(value, lo))
end

-- Math.clamp(value: Long, min: Int, max: Int) where the Long is a number
function J.clampI(value, lo, hi)
    if lo > hi then
        error(__K2L_IllegalArgumentException.new(lo .. " > " .. hi))
    end
    return value < lo and lo or value > hi and hi or value
end

local SPLIT = 134217729 -- 2^27 + 1

local function split(a)
    local c = SPLIT * a
    local high = c - (c - a)
    return high, a - high
end

-- a * b + c rounded once: the product's rounding error (Dekker) and the sum's (Knuth) are added back
function J.fma(a, b, c)
    local p = a * b
    if p ~= p or p == INF or p == -INF or c ~= c or c == INF or c == -INF or a == 0 or b == 0 or abs(a) > 1e300 or
        abs(b) > 1e300 then
        return p + c
    end
    local ah, al = split(a)
    local bh, bl = split(b)
    local e = ((ah * bh - p) + ah * bl + al * bh) + al * bl
    local s = p + c
    local bb = s - p
    local t = (p - (s - bb)) + (c - bb)
    return s + (t + e)
end

-- Math.getExponent: the unbiased exponent; `float` for a Float's range
function J.getExponent(x, float)
    local bias, minNormal = 1023, 2 ^ -1022
    if float then
        bias, minNormal = 127, 2 ^ -126
    end
    if x ~= x or x == INF or x == -INF then
        return bias + 1
    end
    x = abs(x)
    if x < minNormal then
        return -bias
    end
    local e = floor(math.log(x) / math.log(2))
    while 2 ^ e > x do
        e = e - 1
    end
    while 2 ^ (e + 1) <= x do
        e = e + 1
    end
    return e
end

-- Math.scalb(d, n) as the JDK computes it: d * 2^(n rem 512), then by 2^512 or 2^-512 at a time, rounding as it does
function J.scalb(d, n)
    if n < -2099 then
        n = -2099
    elseif n > 2099 then
        n = 2099
    end
    local adjust = fmod(n, 512)
    d = d * 2 ^ adjust
    n = n - adjust
    local step = n < 0 and -512 or 512
    local factor = 2 ^ step
    while n ~= 0 do
        d = d * factor
        n = n - step
    end
    return d
end

-- Math.scalb(f, n) of a Float: the double product, which the caller rounds to a float
function J.scalbF(f, n)
    if n < -278 then
        n = -278
    elseif n > 278 then
        n = 278
    end
    return f * 2 ^ n
end

local HEX = "0123456789abcdef"

-- Double.toHexString: 0x1.<hex digits>p<exponent>, subnormals 0x0.<digits>p-1022, the trailing zero digits dropped
function J.toHexString(x)
    if x ~= x then
        return "NaN"
    elseif x == INF then
        return "Infinity"
    elseif x == -INF then
        return "-Infinity"
    end
    local sign = (x < 0 or (x == 0 and 1 / x < 0)) and "-" or ""
    x = abs(x)
    if x == 0 then
        return sign .. "0x0.0p0"
    end
    local lead, e = "1", J.getExponent(x)
    local m
    if e == -1023 then
        lead, e, m = "0", -1022, x / 2 ^ -1074
    else
        m = (x / 2 ^ e - 1) * 2 ^ 52
    end
    local digits = {}
    for i = 13, 1, -1 do
        local d = m % 16
        digits[i] = HEX:sub(d + 1, d + 1)
        m = (m - d) / 16
    end
    local text = table.concat(digits):gsub("0+$", "")
    return sign .. "0x" .. lead .. "." .. (text == "" and "0" or text) .. "p" .. string.format("%d", e)
end

------------------------------------------------------------------ Long hash

-- Long.hashCode: the two halves xor-ed (OptionalLong.hashCode)
function J.longHash(x)
    local hi, lo = uhalves(x)
    return int32(bxor(hi, lo))
end

end
