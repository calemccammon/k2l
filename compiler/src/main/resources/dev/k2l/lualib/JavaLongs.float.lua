-- requires: Exceptions, Unsigned, Strings, JavaNumbers
-- The Long statics of JavaLongs where a Long is a double (Lua 5.1, 5.2 and LuaJIT): exact while |values| < 2^53. An unsigned
-- value is the double 2^64 higher than a negative Long, as a ULong is there.
local __K2L_JavaLongs = {}

do

local L = __K2L_JavaLongs
local U = __K2L_Unsigned
local floor, fmod = math.floor, math.fmod
local MIN, T64, T63 = -2 ^ 63, 2 ^ 64, 2 ^ 63

local function divZero()
    error(__K2L_ArithmeticException.new("/ by zero"))
end

local function overflow()
    error(__K2L_ArithmeticException.new("long overflow"))
end

local function unsigned(a)
    return a < 0 and a + T64 or a
end

local function signed(a)
    return a >= T63 and a - T64 or a
end

function L.ceilDiv(a, b)
    if b == 0 then
        divZero()
    end
    local q = floor(a / b) + 0
    if q * b ~= a then
        q = q + 1
    end
    return q
end

function L.ceilMod(a, b)
    return a - L.ceilDiv(a, b) * b
end

function L.divideExact(a, b)
    if a == MIN and b == -1 then
        overflow()
    elseif b == 0 then
        divZero()
    end
    local r = fmod(a, b)
    return (a - r) / b + 0
end

function L.floorDivExact(a, b)
    if a == MIN and b == -1 then
        overflow()
    elseif b == 0 then
        divZero()
    end
    return floor(a / b) + 0
end

function L.ceilDivExact(a, b)
    if a == MIN and b == -1 then
        overflow()
    end
    return L.ceilDiv(a, b)
end

function L.clamp(value, lo, hi)
    if lo > hi then
        error(__K2L_IllegalArgumentException.new(string.format("%.0f > %.0f", lo, hi)))
    end
    return value < lo and lo or value > hi and hi or value
end

function L.compareUnsigned(a, b)
    return U.compare(unsigned(a), unsigned(b))
end

function L.divideUnsigned(a, b)
    return signed(U.udiv(unsigned(a), unsigned(b)))
end

function L.remainderUnsigned(a, b)
    return signed(U.urem(unsigned(a), unsigned(b)))
end

function L.toUnsignedString(a, radix)
    return U.toRadix(unsigned(a), radix or 10)
end

function L.parseUnsigned(s, radix)
    __K2L_JavaNumbers.checkUnsigned(s)
    local n = __K2L_StringToUnsignedOrNull(s, radix, 64)
    if n == nil then
        __K2L_JavaNumbers.unsignedFailure(s, radix, "long")
    end
    return signed(n)
end

end
