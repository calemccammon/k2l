-- requires: Exceptions
-- Exact 64-bit Long and ULong without integers (--long64 emulate on Lua 5.1 and 5.2).
-- A value is a Lua number while it is a safe integer (|v| < 2^53) and a box {hi, lo} beyond: hi the signed high 32 bits,
-- lo the unsigned low 32 bits. The two forms never overlap (a value always has the same form), so == is exact.
-- A ULong is the same two's complement pattern as the Long with the same bits (ULong.MAX_VALUE is -1).
local __K2L_Long64 = {}

local B = {}
B.__index = B

local type, setmetatable, tostring = type, setmetatable, tostring
local floor, fmod = math.floor, math.fmod
local format = string.format
local T32, T31, LIM = 4294967296, 2147483648, 9007199254740992

local function divZero()
    error(__K2L_ArithmeticException.new("/ by zero"))
end

-- canonical value of the signed pair (hi in [-2^31, 2^31), lo in [0, 2^32))
local function make(hi, lo)
    if hi >= -2097152 and hi < 2097152 and (hi ~= -2097152 or lo ~= 0) then
        return hi * T32 + lo
    end
    return setmetatable({ hi, lo }, B)
end

local function parts(x)
    if type(x) == "number" then
        local lo = x % T32
        return (x - lo) / T32, lo
    end
    return x[1], x[2]
end

-- the same pair with an unsigned high half
local function uparts(x)
    local hi, lo = parts(x)
    if hi < 0 then
        hi = hi + T32
    end
    return hi, lo
end

local function makeU(hi, lo)
    if hi >= T31 then
        hi = hi - T32
    end
    return make(hi, lo)
end

local function wrapHi(hi)
    if hi >= T31 then
        return hi - T32
    elseif hi < -T31 then
        return hi + T32
    end
    return hi
end

local function addp(ah, al, bh, bl)
    local lo, hi = al + bl, ah + bh
    if lo >= T32 then
        lo, hi = lo - T32, hi + 1
    end
    return make(wrapHi(hi), lo)
end

local function subp(ah, al, bh, bl)
    local lo, hi = al - bl, ah - bh
    if lo < 0 then
        lo, hi = lo + T32, hi - 1
    end
    return make(wrapHi(hi), lo)
end

-- the low 64 bits of the product, from 16-bit limbs
local function mulp(ah, al, bh, bl)
    if ah < 0 then
        ah = ah + T32
    end
    if bh < 0 then
        bh = bh + T32
    end
    local a0 = al % 65536
    local a1 = (al - a0) / 65536
    local a2 = ah % 65536
    local a3 = (ah - a2) / 65536
    local b0 = bl % 65536
    local b1 = (bl - b0) / 65536
    local b2 = bh % 65536
    local b3 = (bh - b2) / 65536
    local c00 = a0 * b0
    local c16 = floor(c00 / 65536)
    c00 = c00 % 65536
    c16 = c16 + a1 * b0
    local c32 = floor(c16 / 65536)
    c16 = c16 % 65536
    c16 = c16 + a0 * b1
    c32 = c32 + floor(c16 / 65536)
    c16 = c16 % 65536
    c32 = c32 + a2 * b0
    local c48 = floor(c32 / 65536)
    c32 = c32 % 65536
    c32 = c32 + a1 * b1
    c48 = c48 + floor(c32 / 65536)
    c32 = c32 % 65536
    c32 = c32 + a0 * b2
    c48 = c48 + floor(c32 / 65536)
    c32 = c32 % 65536
    c48 = (c48 + a3 * b0 + a2 * b1 + a1 * b2 + a0 * b3) % 65536
    return makeU(c48 * 65536 + c32, c16 * 65536 + c00)
end

-- one step of the long division: the quotient limb and remainder of (r * 65536 + limb) / d
local function limbStep(r, limb, d)
    local cur = r * 65536 + limb
    local q = floor(cur / d)
    r = cur - q * d
    if r < 0 then
        return q - 1, r + d
    elseif r >= d then
        return q + 1, r - d
    end
    return q, r
end

-- unsigned a / d and a % d for 0 < d < 2^32, in 16-bit limbs: qh, ql, r
local function udivSmall(ah, al, d)
    local a0 = al % 65536
    local a2 = ah % 65536
    local q3, r = limbStep(0, (ah - a2) / 65536, d)
    local q2
    q2, r = limbStep(r, a2, d)
    local q1
    q1, r = limbStep(r, (al - a0) / 65536, d)
    local q0
    q0, r = limbStep(r, a0, d)
    return q3 * 65536 + q2, q1 * 65536 + q0, r
end

-- unsigned quotient and remainder of two pairs with unsigned high halves: qh, ql, rh, rl
local function udivmod(ah, al, bh, bl)
    if bh == 0 then
        if bl == 0 then
            divZero()
        end
        local qh, ql, r = udivSmall(ah, al, bl)
        return qh, ql, 0, r
    end
    -- the divisor is at least 2^32 and the quotient less than 2^32: restoring division
    local rh, rl, qh, ql = 0, 0, 0, 0
    for i = 63, 0, -1 do
        local bit
        if i >= 32 then
            bit = floor(ah / 2 ^ (i - 32)) % 2
        else
            bit = floor(al / 2 ^ i) % 2
        end
        rl = rl * 2 + bit
        rh = rh * 2
        if rl >= T32 then
            rl, rh = rl - T32, rh + 1
        end
        if rh > bh or (rh == bh and rl >= bl) then
            rl = rl - bl
            if rl < 0 then
                rl, rh = rl + T32, rh - 1
            end
            rh = rh - bh
            if i >= 32 then
                qh = qh + 2 ^ (i - 32)
            else
                ql = ql + 2 ^ i
            end
        end
    end
    return qh, ql, rh, rl
end

local function negp(hi, lo)
    return subp(0, 0, hi, lo)
end

-- the metamethods: a box on either side
local function slowAdd(a, b)
    local ah, al = parts(a)
    local bh, bl = parts(b)
    return addp(ah, al, bh, bl)
end

local function slowSub(a, b)
    local ah, al = parts(a)
    local bh, bl = parts(b)
    return subp(ah, al, bh, bl)
end

local function add(a, b)
    local r = a + b
    if type(r) == "number" and (r >= LIM or r <= -LIM) then
        return slowAdd(a, b)
    end
    return r
end

local function sub(a, b)
    local r = a - b
    if type(r) == "number" and (r >= LIM or r <= -LIM) then
        return slowSub(a, b)
    end
    return r
end

local function mul(a, b)
    if type(a) == "number" and type(b) == "number" then
        local r = a * b
        if r < LIM and r > -LIM then
            return r + 0
        end
    end
    local ah, al = parts(a)
    local bh, bl = parts(b)
    return mulp(ah, al, bh, bl)
end

local function neg(a)
    if type(a) == "number" then
        return 0 - a
    end
    return negp(a[1], a[2])
end

-- Kotlin's truncating division: magnitudes divide, the signs decide the result's sign
local function divmodSlow(a, b, wantRemainder)
    local ah, al = parts(a)
    local bh, bl = parts(b)
    if bh == 0 and bl == 0 then
        divZero()
    end
    local aneg, bneg = ah < 0, bh < 0
    if aneg then
        ah, al = parts(negp(ah, al))
    end
    if bneg then
        bh, bl = parts(negp(bh, bl))
    end
    if ah < 0 then
        ah = ah + T32
    end
    if bh < 0 then
        bh = bh + T32
    end
    local qh, ql, rh, rl = udivmod(ah, al, bh, bl)
    if wantRemainder then
        if aneg then
            return negp(rh >= T31 and rh - T32 or rh, rl)
        end
        return makeU(rh, rl)
    end
    if aneg ~= bneg then
        return negp(qh >= T31 and qh - T32 or qh, ql)
    end
    return makeU(qh, ql)
end

local function div(a, b)
    if type(a) == "number" and type(b) == "number" then
        if b == 0 then
            divZero()
        end
        local r = fmod(a, b)
        return (a - r) / b + 0
    end
    return divmodSlow(a, b, false)
end

local function rem(a, b)
    if type(a) == "number" and type(b) == "number" then
        if b == 0 then
            divZero()
        end
        return fmod(a, b) + 0
    end
    return divmodSlow(a, b, true)
end

local function udiv(a, b)
    local ah, al = uparts(a)
    local bh, bl = uparts(b)
    local qh, ql = udivmod(ah, al, bh, bl)
    return makeU(qh, ql)
end

local function urem(a, b)
    local ah, al = uparts(a)
    local bh, bl = uparts(b)
    local _, _, rh, rl = udivmod(ah, al, bh, bl)
    return makeU(rh, rl)
end

local function cmp(a, b)
    if type(a) == "number" and type(b) == "number" then
        return a < b and -1 or (a > b and 1 or 0)
    end
    local ah, al = parts(a)
    local bh, bl = parts(b)
    if ah ~= bh then
        return ah < bh and -1 or 1
    end
    return al < bl and -1 or (al > bl and 1 or 0)
end

local function ucmp(a, b)
    local ah, al = uparts(a)
    local bh, bl = uparts(b)
    if ah ~= bh then
        return ah < bh and -1 or 1
    end
    return al < bl and -1 or (al > bl and 1 or 0)
end

local function lt(a, b)
    if type(a) == "number" and type(b) == "number" then
        return a < b
    end
    return cmp(a, b) < 0
end

local function le(a, b)
    if type(a) == "number" and type(b) == "number" then
        return a <= b
    end
    return cmp(a, b) <= 0
end

-- 32-bit logic on doubles holding unsigned values
local band32, bor32, bxor32
if bit32 then
    band32, bor32, bxor32 = bit32.band, bit32.bor, bit32.bxor
else
    local AND, XOR = {}, {}
    for x = 0, 15 do
        for y = 0, 15 do
            local a, b, r, s, p = x, y, 0, 0, 1
            for _ = 1, 4 do
                local ba, bb = a % 2, b % 2
                if ba == 1 and bb == 1 then
                    r = r + p
                end
                if ba ~= bb then
                    s = s + p
                end
                a, b, p = (a - ba) / 2, (b - bb) / 2, p * 2
            end
            AND[x * 16 + y], XOR[x * 16 + y] = r, s
        end
    end
    local function logic(tbl, a, b)
        local result, p = 0, 1
        for _ = 1, 8 do
            local x, y = a % 16, b % 16
            result = result + tbl[x * 16 + y] * p
            a, b, p = (a - x) / 16, (b - y) / 16, p * 16
        end
        return result
    end
    band32 = function(a, b) return logic(AND, a, b) end
    bxor32 = function(a, b) return logic(XOR, a, b) end
    bor32 = function(a, b) return a + b - logic(AND, a, b) end
end

local function band(a, b)
    local ah, al = uparts(a)
    local bh, bl = uparts(b)
    return makeU(band32(ah, bh), band32(al, bl))
end

local function bor(a, b)
    local ah, al = uparts(a)
    local bh, bl = uparts(b)
    return makeU(bor32(ah, bh), bor32(al, bl))
end

local function bxor(a, b)
    local ah, al = uparts(a)
    local bh, bl = uparts(b)
    return makeU(bxor32(ah, bh), bxor32(al, bl))
end

local function bnot(a)
    local hi, lo = parts(a)
    return make(-1 - hi, T32 - 1 - lo)
end

local function shl(a, n)
    n = n % 64
    if n == 0 then
        return a
    end
    local hi, lo = uparts(a)
    if n < 32 then
        local p = 2 ^ n
        return makeU((hi * p) % T32 + floor(lo / (T32 / p)), (lo * p) % T32)
    end
    return makeU((lo * 2 ^ (n - 32)) % T32, 0)
end

local function ushr(a, n)
    n = n % 64
    if n == 0 then
        return a
    end
    local hi, lo = uparts(a)
    if n < 32 then
        local p = 2 ^ n
        return makeU(floor(hi / p), floor(lo / p) + (hi % p) * (T32 / p))
    end
    return makeU(0, floor(hi / 2 ^ (n - 32)))
end

local function shr(a, n)
    n = n % 64
    if n == 0 then
        return a
    end
    local hi, lo = parts(a)
    if n < 32 then
        local p = 2 ^ n
        return make(floor(hi / p), floor(lo / p) + (hi % p) * (T32 / p))
    end
    local low = floor(hi / 2 ^ (n - 32))
    return make(hi < 0 and -1 or 0, low % T32)
end

local function toInt(a)
    local lo
    if type(a) == "number" then
        lo = a % T32
    else
        lo = a[2]
    end
    if lo >= T31 then
        return lo - T32
    end
    return lo
end

local function toDouble(a)
    if type(a) == "number" then
        return a
    end
    return a[1] * T32 + a[2]
end

local function utoDouble(a)
    if type(a) == "number" and a >= 0 then
        return a
    end
    local hi, lo = uparts(a)
    return hi * T32 + lo
end

local TWO63, TWO64 = 9223372036854775808, 18446744073709551616

local MAX = setmetatable({ T31 - 1, T32 - 1 }, B)
local MIN = setmetatable({ -T31, 0 }, B)

local function fromDouble(x)
    if x ~= x then
        return 0
    elseif x >= TWO63 then
        return MAX
    elseif x <= -TWO63 then
        return MIN
    end
    local t = x >= 0 and floor(x) or -floor(-x)
    if t < LIM and t > -LIM then
        return t + 0
    end
    local hi = floor(t / T32)
    return make(hi, t - hi * T32)
end

local function ufromDouble(x)
    if x ~= x or x <= 0 then
        return 0
    elseif x >= TWO64 then
        return -1
    end
    local t = floor(x)
    if t < LIM then
        return t
    end
    local hi = floor(t / T32)
    return makeU(hi, t - hi * T32)
end

local function lit(hi, lo)
    return make(hi, lo)
end

-- the text of the unsigned pair in a radix
local function ustrPair(hi, lo, radix)
    if radix == 10 then
        -- seven decimal places at a time
        local chunks = {}
        while hi > 0 do
            local r
            hi, lo, r = udivSmall(hi, lo, 10000000)
            chunks[#chunks + 1] = format("%07d", r)
        end
        local text = format("%.0f", lo)
        for k = #chunks, 1, -1 do
            text = text .. chunks[k]
        end
        return text
    end
    local digits = {}
    local chars = "0123456789abcdefghijklmnopqrstuvwxyz"
    while hi > 0 or lo > 0 do
        local r
        hi, lo, r = udivSmall(hi, lo, radix)
        digits[#digits + 1] = chars:sub(r + 1, r + 1)
    end
    if #digits == 0 then
        return "0"
    end
    return string.reverse(table.concat(digits))
end

local function str(a, radix)
    radix = radix or 10
    if radix < 2 or radix > 36 then
        radix = 10
    end
    if type(a) == "number" and radix == 10 then
        return format("%.0f", a)
    end
    local hi, lo = parts(a)
    local sign = ""
    if hi < 0 then
        sign = "-"
        hi, lo = parts(negp(hi, lo))
        if hi < 0 then
            hi = hi + T32
        end
    end
    return sign .. ustrPair(hi, lo, radix)
end

local function ustr(a, radix)
    radix = radix or 10
    if radix < 2 or radix > 36 then
        radix = 10
    end
    if type(a) == "number" and a >= 0 and radix == 10 then
        return format("%.0f", a)
    end
    local hi, lo = uparts(a)
    return ustrPair(hi, lo, radix)
end

-- JVM Long.hashCode: (v xor (v ushr 32)).toInt()
local function hash(a)
    local hi, lo = uparts(a)
    local x = bxor32(hi, lo)
    if x >= T31 then
        return x - T32
    end
    return x
end

function B.toString(self)
    return str(self)
end

function B.hashCode(self)
    return hash(self)
end

function B.equals(self, other)
    return type(other) == "table" and other[1] == self[1] and other[2] == self[2]
end

function B.compareTo(self, other)
    return cmp(self, other)
end

B.__tostring = str
B.__concat = function(a, b)
    return tostring(a) .. tostring(b)
end
B.__add = slowAdd
B.__sub = slowSub
B.__mul = mul
B.__unm = neg
B.__lt = lt
B.__le = le
B.__eq = function(a, b)
    return a[1] == b[1] and a[2] == b[2]
end

local L = __K2L_Long64
L.make, L.parts, L.uparts, L.makeU = make, parts, uparts, makeU
L.add, L.sub, L.mul, L.neg, L.div, L.rem, L.udiv, L.urem = add, sub, mul, neg, div, rem, udiv, urem
L.band, L.bor, L.bxor, L.bnot, L.shl, L.shr, L.ushr = band, bor, bxor, bnot, shl, shr, ushr
L.cmp, L.ucmp, L.lt, L.le = cmp, ucmp, lt, le
L.toInt, L.toDouble, L.utoDouble, L.fromDouble, L.ufromDouble = toInt, toDouble, utoDouble, fromDouble, ufromDouble
L.str, L.ustr, L.hash, L.lit = str, ustr, hash, lit
L.udivSmall, L.udivmod = udivSmall, udivmod
L.MAX, L.MIN = MAX, MIN
L.box = B

-- A negative number as a box, for String.format: %x and %o show the 64 bits of a Long, not the 32 of an Int.
function L.boxed(x)
    if type(x) == "number" and x < 0 then
        local hi, lo = parts(x)
        return setmetatable({ hi, lo }, B)
    end
    return x
end

function L.isLong(x)
    return (type(x) == "number" and x % 1 == 0) or getmetatable(x) == B
end

local __K2L_LAdd = add
local __K2L_LSub = sub
local __K2L_LMul = mul
local __K2L_LNeg = neg
local __K2L_LDiv = div
local __K2L_LRem = rem
local __K2L_LLt = lt
local __K2L_LCmp = cmp
local __K2L_LLe = le
local __K2L_LAnd = band
local __K2L_LOr = bor
local __K2L_LXor = bxor
local __K2L_LNot = bnot
local __K2L_LShl = shl
local __K2L_LShr = shr
local __K2L_LUshr = ushr
local __K2L_LInt = toInt
local __K2L_LDouble = toDouble
local __K2L_LLit = lit
