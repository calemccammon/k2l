-- requires: Bit
-- Long bitwise operations where a Long is a double (Lua 5.1, 5.2 and LuaJIT without --long64 emulate): the two's
-- complement pattern is split into 32-bit halves, so the results are exact for values below 2^53 in magnitude
-- (`crc.toLong() and 0xFFFFFFFFL`, 40-bit masks). Shifts multiply and divide by powers of two.
local T32 = 4294967296
local floor = math.floor

local function split(x)
    local lo = x % T32
    return (x - lo) / T32, lo
end

-- 2^k - 1 -> 2^k: x and (2^k - 1) is the floored x % 2^k, also for negative x. Not on LuaJIT, where the hash lookup
-- of an arbitrary number costs more than the two bit.band calls.
local MASKS
if not jit then
    MASKS = {}
    for k = 1, 53 do
        MASKS[2 ^ k - 1] = 2 ^ k
    end
end

local function __K2L_LBAnd(a, b)
    if MASKS ~= nil then
        local m = MASKS[b]
        if m ~= nil then
            return a % m
        end
    end
    -- split into halves and joined again: the signed high half (as the 32-bit operations return it) * 2^32 plus the
    -- low half in any 32-bit form
    local al, bl = a % T32, b % T32
    return __K2L_BAnd((a - al) / T32, (b - bl) / T32) * T32 + __K2L_BAnd(al, bl) % T32
end

local function __K2L_LBOr(a, b)
    local al, bl = a % T32, b % T32
    return __K2L_BOr((a - al) / T32, (b - bl) / T32) * T32 + __K2L_BOr(al, bl) % T32
end

local function __K2L_LBXor(a, b)
    local al, bl = a % T32, b % T32
    return __K2L_BXor((a - al) / T32, (b - bl) / T32) * T32 + __K2L_BXor(al, bl) % T32
end

local function __K2L_LBNot(a)
    return -a - 1
end

local function __K2L_LShl(a, n)
    return a * 2 ^ (n % 64)
end

local function __K2L_LShr(a, n)
    return floor(a / 2 ^ (n % 64))
end

local function __K2L_LUshr(a, n)
    n = n % 64
    if a >= 0 or n == 0 then
        return floor(a / 2 ^ n)
    end
    local hi, lo = split(a)
    hi = hi % T32
    if n >= 32 then
        return floor(hi / 2 ^ (n - 32))
    end
    return hi * 2 ^ (32 - n) + floor(lo / 2 ^ n)
end

-- bit counts of a Long, from its halves
-- POP8[b + 1]: the number of one bits of the byte b
local POP8 = {}
for b = 0, 255 do
    POP8[b + 1] = b % 2 + (POP8[(b - b % 2) / 2 + 1] or 0)
end

local function ones32(n)
    n = n % T32
    local count = 0
    while n > 0 do
        local b = n % 256
        count, n = count + POP8[b + 1], (n - b) / 256
    end
    return count
end

local function length32(n)
    n = n % T32
    local length = 0
    while n > 0 do
        length = length + 1
        n = floor(n / 2)
    end
    return length
end

local function ctz32(n)
    n = n % T32
    local count = 0
    while n % 2 == 0 do
        count = count + 1
        n = n / 2
    end
    return count
end

local function __K2L_LCountOneBits(a)
    local hi, lo = split(a)
    return ones32(hi) + ones32(lo)
end

local function __K2L_LCountTrailingZeroBits(a)
    local hi, lo = split(a)
    if lo ~= 0 then
        return ctz32(lo)
    end
    return hi % T32 == 0 and 64 or 32 + ctz32(hi)
end

local function __K2L_LCountLeadingZeroBits(a)
    local hi, lo = split(a)
    hi = hi % T32
    return hi ~= 0 and 32 - length32(hi) or 64 - length32(lo)
end

local function __K2L_LTakeHighestOneBit(a)
    if a < 0 then
        return -2 ^ 63
    end
    return a == 0 and 0 or 2 ^ (63 - __K2L_LCountLeadingZeroBits(a))
end

local function __K2L_LTakeLowestOneBit(a)
    return a == 0 and 0 or 2 ^ __K2L_LCountTrailingZeroBits(a)
end
