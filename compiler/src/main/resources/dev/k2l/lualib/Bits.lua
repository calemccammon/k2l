-- Bit-level number helpers for Lua 5.3/5.4: rotations, single bits, bit counts of Long, and Double.withSign.
local __K2L_Bits = {}

do

local function toInt32(x)
    x = x & 0xFFFFFFFF
    if x >= 0x80000000 then
        return x - 0x100000000
    end
    return x
end

-- Int.rotateLeft(n); a negative n rotates right.
function __K2L_Bits.rotl32(x, n)
    n = n & 31
    local u = x & 0xFFFFFFFF
    return toInt32((u << n) | (u >> (32 - n)))
end

function __K2L_Bits.rotl64(x, n)
    n = n & 63
    if n == 0 then
        return x
    end
    return (x << n) | (x >> (64 - n))
end

function __K2L_Bits.highest32(x)
    local u = x & 0xFFFFFFFF
    if u == 0 then
        return 0
    end
    local bit = 1
    while (u >> 1) ~= 0 do
        u = u >> 1
        bit = bit << 1
    end
    return toInt32(bit)
end

function __K2L_Bits.lowest32(x)
    local u = x & 0xFFFFFFFF
    return toInt32(u & -u)
end

function __K2L_Bits.highest64(x)
    if x == 0 then
        return 0
    end
    local bit = 1
    while (x >> 1) ~= 0 do
        x = x >> 1
        bit = bit << 1
    end
    return bit
end

function __K2L_Bits.lowest64(x)
    return x & -x
end

-- SWAR bit count: 2-, 4- and 8-bit partial sums, then the bytes added up by a multiplication (integers wrap)
local function ones64(x)
    x = x - ((x >> 1) & 0x5555555555555555)
    x = (x & 0x3333333333333333) + ((x >> 2) & 0x3333333333333333)
    x = (x + (x >> 4)) & 0x0F0F0F0F0F0F0F0F
    return (x * 0x0101010101010101) >> 56
end

__K2L_Bits.ones64 = ones64

function __K2L_Bits.ctz64(x)
    if x == 0 then
        return 64
    end
    return ones64((x & -x) - 1)
end

function __K2L_Bits.clz64(x)
    x = x | (x >> 1)
    x = x | (x >> 2)
    x = x | (x >> 4)
    x = x | (x >> 8)
    x = x | (x >> 16)
    x = x | (x >> 32)
    return 64 - ones64(x)
end

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
