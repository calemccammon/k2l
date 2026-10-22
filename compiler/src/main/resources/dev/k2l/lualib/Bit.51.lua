-- requires: ToInt32
-- Kotlin Int bitwise operations in plain Lua 5.1. The and of two unsigned 32-bit patterns is read a byte at a time from a
-- table of the and of two bytes; xor and or follow from it (a + b = (a xor b) + 2 (a and b), a or b = a + b - (a and b)).
-- Results are wrapped back to a signed Int.
local floor = math.floor

-- AND8[x * 256 + y + 1] is the and of the bytes x and y, built from the and of two 4-bit values
local AND8 = {}
do
    local AND4 = {}
    for x = 0, 15 do
        for y = 0, 15 do
            local r, bit, a, b = 0, 1, x, y
            for _ = 1, 4 do
                local p, q = a % 2, b % 2
                if p == 1 and q == 1 then
                    r = r + bit
                end
                a, b, bit = (a - p) / 2, (b - q) / 2, bit * 2
            end
            AND4[x * 16 + y + 1] = r
        end
    end
    for x = 0, 255 do
        local xl, xh = x % 16 * 16 + 1, (x - x % 16) + 1
        for y = 0, 255 do
            local yl = y % 16
            AND8[x * 256 + y + 1] = AND4[xl + yl] + AND4[xh + (y - yl) / 16] * 16
        end
    end
end

-- the and of two unsigned 32-bit patterns, stopping when either operand has no bits left
local function uand(a, b)
    local r, scale = 0, 1
    while a ~= 0 and b ~= 0 do
        local x, y = a % 256, b % 256
        r = r + AND8[x * 256 + y + 1] * scale
        a, b, scale = (a - x) / 256, (b - y) / 256, scale * 256
    end
    return r
end

local function __K2L_BAnd(a, b) return __K2L_ToInt32(uand(a % 4294967296, b % 4294967296)) end

local function __K2L_BOr(a, b)
    a, b = a % 4294967296, b % 4294967296
    return __K2L_ToInt32(a + b - uand(a, b))
end

local function __K2L_BXor(a, b)
    a, b = a % 4294967296, b % 4294967296
    return __K2L_ToInt32(a + b - 2 * uand(a, b))
end

local function __K2L_BNot(a) return __K2L_ToInt32(4294967295 - a % 4294967296) end

local function __K2L_Shl(a, n) return __K2L_ToInt32(a * 2 ^ n) end

local function __K2L_Shr(a, n) return floor(a / 2 ^ n) end

local function __K2L_Ushr(a, n) return __K2L_ToInt32(floor(a % 4294967296 / 2 ^ n)) end
