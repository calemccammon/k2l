-- requires: Bit
-- Long bitwise operations where a Long is a double (Lua 5.1, 5.2 and LuaJIT without --long64 emulate): the two's
-- complement pattern is split into 32-bit halves, so the results are exact for values below 2^53 in magnitude
-- (`crc.toLong() and 0xFFFFFFFFL`, 40-bit masks). Shifts multiply and divide by powers of two.
local T32 = 4294967296

local function split(x)
    local hi = math.floor(x / T32)
    return hi, x - hi * T32
end

-- hi: the signed high half (as the 32-bit operations return it), lo: the low half in any 32-bit form
local function join(hi, lo)
    return hi * T32 + lo % T32
end

local function __K2L_LBAnd(a, b)
    local ah, al = split(a)
    local bh, bl = split(b)
    return join(__K2L_BAnd(ah, bh), __K2L_BAnd(al, bl))
end

local function __K2L_LBOr(a, b)
    local ah, al = split(a)
    local bh, bl = split(b)
    return join(__K2L_BOr(ah, bh), __K2L_BOr(al, bl))
end

local function __K2L_LBXor(a, b)
    local ah, al = split(a)
    local bh, bl = split(b)
    return join(__K2L_BXor(ah, bh), __K2L_BXor(al, bl))
end

local function __K2L_LBNot(a)
    return -a - 1
end

local function __K2L_LShl(a, n)
    return a * 2 ^ (n % 64)
end

local function __K2L_LShr(a, n)
    return math.floor(a / 2 ^ (n % 64))
end

local function __K2L_LUshr(a, n)
    n = n % 64
    if a >= 0 or n == 0 then
        return math.floor(a / 2 ^ n)
    end
    local hi, lo = split(a)
    hi = hi % T32
    if n >= 32 then
        return math.floor(hi / 2 ^ (n - 32))
    end
    return hi * 2 ^ (32 - n) + math.floor(lo / 2 ^ n)
end

-- bit counts of a Long, from its halves
local function ones32(n)
    n = n % T32
    local count = 0
    while n > 0 do
        local b = n % 2
        count = count + b
        n = (n - b) / 2
    end
    return count
end

local function length32(n)
    n = n % T32
    local length = 0
    while n > 0 do
        length = length + 1
        n = math.floor(n / 2)
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
