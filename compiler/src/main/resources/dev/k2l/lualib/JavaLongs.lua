-- requires: Exceptions, Unsigned, Strings, JavaNumbers
-- The Long statics of java.lang.Long and Math that need 64-bit arithmetic, on Lua 5.3/5.4 (integers): ceilDiv, ceilMod, the
-- *Exact divisions, clamp and the unsigned functions. JavaLongs.float serves 5.1, 5.2 and LuaJIT, JavaLongs.l64 --long64 emulate.
local __K2L_JavaLongs = {}

do

local L = __K2L_JavaLongs
local U = __K2L_Unsigned
local MIN = math.mininteger

local function divZero()
    error(__K2L_ArithmeticException.new("/ by zero"))
end

local function overflow()
    error(__K2L_ArithmeticException.new("long overflow"))
end

function L.ceilDiv(a, b)
    if b == 0 then
        divZero()
    end
    local q = a // b
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
    local q = a // b
    if q * b ~= a and (a < 0) ~= (b < 0) then
        q = q + 1
    end
    return q
end

function L.floorDivExact(a, b)
    if a == MIN and b == -1 then
        overflow()
    elseif b == 0 then
        divZero()
    end
    return a // b
end

function L.ceilDivExact(a, b)
    if a == MIN and b == -1 then
        overflow()
    end
    return L.ceilDiv(a, b)
end

function L.clamp(value, lo, hi)
    if lo > hi then
        error(__K2L_IllegalArgumentException.new(lo .. " > " .. hi))
    end
    return value < lo and lo or value > hi and hi or value
end

L.compareUnsigned, L.divideUnsigned, L.remainderUnsigned = U.compare, U.udiv, U.urem

function L.toUnsignedString(a, radix)
    return U.toRadix(a, radix or 10)
end

-- Long.parseUnsignedLong(s[, radix]), with the JDK's messages
function L.parseUnsigned(s, radix)
    __K2L_JavaNumbers.checkUnsigned(s)
    local n = __K2L_StringToUnsignedOrNull(s, radix, 64)
    if n == nil then
        __K2L_JavaNumbers.unsignedFailure(s, radix, "long")
    end
    return n
end

end
