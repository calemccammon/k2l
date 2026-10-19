-- requires: Exceptions
-- Exact 64-bit Long and ULong on LuaJIT (--long64 emulate): FFI int64_t cdata.
-- A value is a Lua number while it is a safe integer (|v| < 2^53) and an int64_t cdata beyond, so a value always has the
-- same form and == is exact (cdata compare by value; cdata keys of tables are handled by Hash and the collections).
-- A ULong is the same two's complement pattern as the Long with the same bits (ULong.MAX_VALUE is -1).
local ffi = require("ffi")
local bit = require("bit")

local __K2L_Long64 = {}

local type, tonumber, tostring = type, tonumber, tostring
local floor, fmod = math.floor, math.fmod
local format = string.format
local cast = ffi.cast
local tobit, bnot_, band_, bor_, bxor_ = bit.tobit, bit.bnot, bit.band, bit.bor, bit.bxor
local lshift, rshift, arshift = bit.lshift, bit.rshift, bit.arshift
local T32, T31, LIM = 4294967296, 2147483648, 9007199254740992

local function divZero()
    error(__K2L_ArithmeticException.new("/ by zero"))
end

-- the canonical form of an int64_t: a number when it is a safe integer
local function norm(c)
    if c > -LIM and c < LIM then
        return tonumber(c)
    end
    return c
end

local function make(hi, lo)
    return norm(lshift(hi + 0LL, 32) + lo)
end

local function parts(x)
    if type(x) == "number" then
        local lo = x % T32
        return (x - lo) / T32, lo
    end
    return tonumber(arshift(x, 32)), tonumber(band_(x, 0xFFFFFFFFLL))
end

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

local function add(a, b)
    local r = a + b
    if type(r) == "number" then
        if r < LIM and r > -LIM then
            return r
        end
        return norm((a + 0LL) + b)
    end
    return norm(r)
end

local function sub(a, b)
    local r = a - b
    if type(r) == "number" then
        if r < LIM and r > -LIM then
            return r
        end
        return norm((a + 0LL) - b)
    end
    return norm(r)
end

local function mul(a, b)
    local r = a * b
    if type(r) == "number" then
        if r < LIM and r > -LIM then
            return r + 0
        end
        return norm((a + 0LL) * b)
    end
    return norm(r)
end

local function neg(a)
    if type(a) == "number" then
        return 0 - a
    end
    return norm(-a)
end

local function div(a, b)
    if b == 0 then
        divZero()
    end
    if type(a) == "number" and type(b) == "number" then
        local r = fmod(a, b)
        return (a - r) / b + 0
    end
    return norm((a + 0LL) / b)
end

local function rem(a, b)
    if b == 0 then
        divZero()
    end
    if type(a) == "number" and type(b) == "number" then
        return fmod(a, b) + 0
    end
    if b == -1 then
        return 0
    end
    return norm((a + 0LL) % b)
end

local function unsigned(x)
    return cast("uint64_t", x + 0LL)
end

local function udiv(a, b)
    if b == 0 then
        divZero()
    end
    return norm(cast("int64_t", unsigned(a) / unsigned(b)))
end

local function urem(a, b)
    if b == 0 then
        divZero()
    end
    return norm(cast("int64_t", unsigned(a) % unsigned(b)))
end

local function cmp(a, b)
    if a < b then
        return -1
    elseif a > b then
        return 1
    end
    return 0
end

local function ucmp(a, b)
    local x, y = unsigned(a), unsigned(b)
    if x < y then
        return -1
    elseif x > y then
        return 1
    end
    return 0
end

local function lt(a, b)
    return a < b
end

local function le(a, b)
    return a <= b
end

local function band(a, b)
    return norm(band_(a + 0LL, b))
end

local function bor(a, b)
    return norm(bor_(a + 0LL, b))
end

local function bxor(a, b)
    return norm(bxor_(a + 0LL, b))
end

local function bnot(a)
    return norm(bnot_(a + 0LL))
end

local function shl(a, n)
    return norm(lshift(a + 0LL, n % 64))
end

local function shr(a, n)
    return norm(arshift(a + 0LL, n % 64))
end

local function ushr(a, n)
    return norm(rshift(a + 0LL, n % 64))
end

local function toInt(a)
    if type(a) == "number" and a < 1125899906842624 and a > -1125899906842624 then
        return tobit(a)
    end
    return tobit(a + 0LL)
end

local function toDouble(a)
    return tonumber(a)
end

local function utoDouble(a)
    if type(a) == "number" and a >= 0 then
        return a
    end
    -- halving with the lowest bit kept makes the conversion round like a direct one
    local c = a + 0LL
    if c >= 0 then
        return tonumber(c)
    end
    return tonumber(bor_(rshift(c, 1), band_(c, 1))) * 2.0
end

local MAX = 9223372036854775807LL
local MIN = -9223372036854775807LL - 1
local TWO63, TWO64 = 9223372036854775808, 18446744073709551616

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
    return norm(cast("int64_t", t))
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
    return norm(cast("int64_t", cast("uint64_t", t)))
end

local function lit(hi, lo)
    return make(hi, lo)
end

local function str(a)
    if type(a) == "number" then
        return format("%.0f", a)
    end
    return (tostring(a):gsub("LL$", ""))
end

local function ustr(a)
    if type(a) == "number" and a >= 0 then
        return format("%.0f", a)
    end
    return (tostring(unsigned(a)):gsub("ULL$", ""))
end

-- JVM Long.hashCode: (v xor (v ushr 32)).toInt()
local function hash(a)
    local c = a + 0LL
    return tobit(bxor_(c, rshift(c, 32)))
end

local L = __K2L_Long64
L.make, L.parts, L.uparts, L.makeU = make, parts, uparts, makeU
L.add, L.sub, L.mul, L.neg, L.div, L.rem, L.udiv, L.urem = add, sub, mul, neg, div, rem, udiv, urem
L.band, L.bor, L.bxor, L.bnot, L.shl, L.shr, L.ushr = band, bor, bxor, bnot, shl, shr, ushr
L.cmp, L.ucmp, L.lt, L.le = cmp, ucmp, lt, le
L.toInt, L.toDouble, L.utoDouble, L.fromDouble, L.ufromDouble = toInt, toDouble, utoDouble, fromDouble, ufromDouble
L.str, L.ustr, L.hash, L.lit = str, ustr, hash, lit
L.MAX, L.MIN = MAX, MIN

function L.boxed(x)
    if type(x) == "number" and x < 0 then
        return x + 0LL
    end
    return x
end

function L.isLong(x)
    return (type(x) == "number" and x % 1 == 0) or ffi.istype("int64_t", x)
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
