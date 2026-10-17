-- requires: ToInt32
-- Kotlin Int bitwise operations (32-bit, signed) on Lua 5.3+.
local function __K2L_Shl(a, n) return __K2L_ToInt32(a << n) end
local function __K2L_Shr(a, n) return a // (1 << n) end
local function __K2L_Ushr(a, n) return __K2L_ToInt32((a & 0xFFFFFFFF) >> n) end
