-- Bit-level number helpers for Lua 5.3/5.4: rotations, single bits, bit counts of Long, and the IEEE 754 bit patterns.
local __K2L_Bits = {}

do

local pack, unpack = string.pack, string.unpack
local huge = math.huge
local MAX_DOUBLE_ULP = 1.9958403095347198e292 -- 2^971
local MIN_DOUBLE = 5e-324
local MIN_FLOAT = 1.401298464324817e-45

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

function __K2L_Bits.ones64(x)
    local count = 0
    while x ~= 0 do
        count = count + (x & 1)
        x = x >> 1
    end
    return count
end

function __K2L_Bits.ctz64(x)
    if x == 0 then
        return 64
    end
    local count = 0
    while (x & 1) == 0 do
        count = count + 1
        x = x >> 1
    end
    return count
end

function __K2L_Bits.clz64(x)
    local bits = 0
    while x ~= 0 do
        bits = bits + 1
        x = x >> 1
    end
    return 64 - bits
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

-- Double.toBits() (NaN is canonical) and toRawBits()
function __K2L_Bits.doubleBits(x)
    if x ~= x then
        return 0x7ff8000000000000
    end
    return (unpack("<i8", pack("<d", x)))
end

function __K2L_Bits.doubleRawBits(x)
    return (unpack("<i8", pack("<d", x)))
end

function __K2L_Bits.doubleFromBits(bits)
    return (unpack("<d", pack("<i8", bits)))
end

function __K2L_Bits.floatBits(x)
    if x ~= x then
        return 0x7fc00000
    end
    return (unpack("<i4", pack("<f", x)))
end

function __K2L_Bits.floatRawBits(x)
    return (unpack("<i4", pack("<f", x)))
end

function __K2L_Bits.floatFromBits(bits)
    return (unpack("<f", pack("<i4", bits)))
end

function __K2L_Bits.nextUp(x)
    if x ~= x or x == huge then
        return x
    elseif x == 0 then
        return MIN_DOUBLE
    end
    local bits = unpack("<i8", pack("<d", x))
    return (unpack("<d", pack("<i8", x > 0 and bits + 1 or bits - 1)))
end

function __K2L_Bits.nextDown(x)
    return -__K2L_Bits.nextUp(-x)
end

function __K2L_Bits.nextTowards(x, to)
    if x ~= x or to ~= to then
        return 0 / 0
    elseif x == to then
        return to
    elseif x < to then
        return __K2L_Bits.nextUp(x)
    end
    return __K2L_Bits.nextDown(x)
end

function __K2L_Bits.ulp(x)
    if x ~= x then
        return x
    end
    x = math.abs(x)
    if x == huge then
        return huge
    end
    local up = __K2L_Bits.nextUp(x)
    if up == huge then
        return MAX_DOUBLE_ULP
    end
    return up - x
end

function __K2L_Bits.nextUpF(x)
    if x ~= x or x == huge then
        return x
    elseif x == 0 then
        return MIN_FLOAT
    end
    local bits = unpack("<i4", pack("<f", x))
    return (unpack("<f", pack("<i4", x > 0 and bits + 1 or bits - 1)))
end

function __K2L_Bits.nextDownF(x)
    return -__K2L_Bits.nextUpF(-x)
end

function __K2L_Bits.nextTowardsF(x, to)
    if x ~= x or to ~= to then
        return 0 / 0
    elseif x == to then
        return to
    elseif x < to then
        return __K2L_Bits.nextUpF(x)
    end
    return __K2L_Bits.nextDownF(x)
end

function __K2L_Bits.ulpF(x)
    if x ~= x then
        return x
    end
    x = math.abs(x)
    if x == huge then
        return huge
    end
    local up = __K2L_Bits.nextUpF(x)
    if up == huge then
        return 2.028240960365167e31 -- 2^104
    end
    return up - x
end

end
