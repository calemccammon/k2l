-- requires: ToInt32
-- Bit-level number helpers for Lua 5.1, 5.2 and LuaJIT, where numbers are doubles. Long is a double there, so the
-- Long variants work on 32 bits like Long bitwise operations do.
local __K2L_Bits = {}

do

local frexp, floor = math.frexp, math.floor
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

end
