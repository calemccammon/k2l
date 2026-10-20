-- requires: ToInt32
-- Kotlin Int bitwise operations via bit32 (Lua 5.2), whose unsigned results are wrapped to a signed Int inline.
local band, bor, bxor, lshift, arshift, rshift = bit32.band, bit32.bor, bit32.bxor, bit32.lshift, bit32.arshift, bit32.rshift

local function __K2L_BAnd(a, b)
    local r = band(a, b)
    if r >= 2147483648 then
        return r - 4294967296
    end
    return r
end

local function __K2L_BOr(a, b)
    local r = bor(a, b)
    if r >= 2147483648 then
        return r - 4294967296
    end
    return r
end

local function __K2L_BXor(a, b)
    local r = bxor(a, b)
    if r >= 2147483648 then
        return r - 4294967296
    end
    return r
end

local function __K2L_BNot(a) return __K2L_ToInt32(bit32.bnot(a)) end

local function __K2L_Shl(a, n)
    local r = lshift(a, n)
    if r >= 2147483648 then
        return r - 4294967296
    end
    return r
end

local function __K2L_Shr(a, n)
    local r = arshift(a, n)
    if r >= 2147483648 then
        return r - 4294967296
    end
    return r
end

local function __K2L_Ushr(a, n)
    local r = rshift(a, n)
    if r >= 2147483648 then
        return r - 4294967296
    end
    return r
end
