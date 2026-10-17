-- requires: ToInt32
-- Kotlin Int bitwise operations in plain Lua 5.1, one bit at a time.
local function __K2L_BitOp(a, b, keep)
    a, b = a % 4294967296, b % 4294967296
    local result, bit = 0, 1
    for _ = 1, 32 do
        local x, y = a % 2, b % 2
        if keep(x, y) then
            result = result + bit
        end
        a, b, bit = (a - x) / 2, (b - y) / 2, bit * 2
    end
    return __K2L_ToInt32(result)
end

local function __K2L_BAnd(a, b) return __K2L_BitOp(a, b, function(x, y) return x == 1 and y == 1 end) end
local function __K2L_BOr(a, b) return __K2L_BitOp(a, b, function(x, y) return x == 1 or y == 1 end) end
local function __K2L_BXor(a, b) return __K2L_BitOp(a, b, function(x, y) return x ~= y end) end
local function __K2L_BNot(a) return __K2L_ToInt32(4294967295 - a % 4294967296) end
local function __K2L_Shl(a, n) return __K2L_ToInt32(a * 2 ^ n) end
local function __K2L_Shr(a, n) return math.floor(a / 2 ^ n) end
local function __K2L_Ushr(a, n) return __K2L_ToInt32(math.floor((a % 4294967296) / 2 ^ n)) end
