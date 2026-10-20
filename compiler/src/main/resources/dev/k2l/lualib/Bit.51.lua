-- requires: ToInt32, UAnd32
-- Kotlin Int bitwise operations in plain Lua 5.1, from the table-driven and of UAnd32: xor and or follow from it
-- (a + b = (a xor b) + 2 (a and b), a or b = a + b - (a and b)). Operands are taken as unsigned 32-bit patterns; results
-- are wrapped back to a signed Int.
local floor = math.floor

-- 2^k - 1 -> 2^k, for masks wider than a byte: x and (2^k - 1) is x % 2^k
local MASKS = {}
for k = 9, 32 do
    MASKS[2 ^ k - 1] = 2 ^ k
end

local POW2 = {}
for n = 0, 64 do
    POW2[n] = 2 ^ n
end

local AND8 = __K2L_AND8

-- (and, or and xor do the steps of __K2L_UAnd32 in place: a call less per operation)
local function __K2L_BAnd(a, b)
    a, b = a % 4294967296, b % 4294967296
    local m = MASKS[b]
    local r
    if m ~= nil then
        r = a % m
    else
        local x, y = a % 256, b % 256
        r = AND8[x * 256 + y + 1]
        local p, q = (a - x) / 256, (b - y) / 256
        if p ~= 0 and q ~= 0 then
            x, y = p % 256, q % 256
            r = r + AND8[x * 256 + y + 1] * 256
            p, q = (p - x) / 256, (q - y) / 256
            if p ~= 0 and q ~= 0 then
                x, y = p % 256, q % 256
                r = r + AND8[x * 256 + y + 1] * 65536
                p, q = (p - x) / 256, (q - y) / 256
                r = r + AND8[p * 256 + q + 1] * 16777216
            end
        end
    end
    if r >= 2147483648 then
        return r - 4294967296
    end
    return r
end

local function __K2L_BOr(a, b)
    a, b = a % 4294967296, b % 4294967296
    -- the and of a and b, as __K2L_UAnd32 computes it
    local x, y = a % 256, b % 256
    local n = AND8[x * 256 + y + 1]
    local p, q = (a - x) / 256, (b - y) / 256
    if p ~= 0 and q ~= 0 then
        x, y = p % 256, q % 256
        n = n + AND8[x * 256 + y + 1] * 256
        p, q = (p - x) / 256, (q - y) / 256
        if p ~= 0 and q ~= 0 then
            x, y = p % 256, q % 256
            n = n + AND8[x * 256 + y + 1] * 65536
            p, q = (p - x) / 256, (q - y) / 256
            n = n + AND8[p * 256 + q + 1] * 16777216
        end
    end
    local r = a + b - n
    if r >= 2147483648 then
        return r - 4294967296
    end
    return r
end

local function __K2L_BXor(a, b)
    a, b = a % 4294967296, b % 4294967296
    -- the and of a and b, as __K2L_UAnd32 computes it
    local x, y = a % 256, b % 256
    local n = AND8[x * 256 + y + 1]
    local p, q = (a - x) / 256, (b - y) / 256
    if p ~= 0 and q ~= 0 then
        x, y = p % 256, q % 256
        n = n + AND8[x * 256 + y + 1] * 256
        p, q = (p - x) / 256, (q - y) / 256
        if p ~= 0 and q ~= 0 then
            x, y = p % 256, q % 256
            n = n + AND8[x * 256 + y + 1] * 65536
            p, q = (p - x) / 256, (q - y) / 256
            n = n + AND8[p * 256 + q + 1] * 16777216
        end
    end
    local r = a + b - 2 * n
    if r >= 2147483648 then
        return r - 4294967296
    end
    return r
end

local function __K2L_BNot(a) return __K2L_ToInt32(4294967295 - a % 4294967296) end

local function __K2L_Shl(a, n)
    local r = a * (POW2[n] or 2 ^ n) % 4294967296
    if r >= 2147483648 then
        return r - 4294967296
    end
    return r
end

local function __K2L_Shr(a, n) return floor(a / (POW2[n] or 2 ^ n)) end

local function __K2L_Ushr(a, n)
    local r = floor(a % 4294967296 / (POW2[n] or 2 ^ n))
    if r >= 2147483648 then
        return r - 4294967296
    end
    return r
end
