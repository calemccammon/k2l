-- requires: ToInt32
-- Kotlin Int bitwise operations (32-bit, signed) on Lua 5.3+.
local function __K2L_BAnd(a, b) return a & b end
local function __K2L_BOr(a, b) return a | b end
local function __K2L_BXor(a, b) return a ~ b end
local function __K2L_BNot(a) return ~a end
local function __K2L_Shl(a, n) return __K2L_ToInt32(a << n) end
local function __K2L_Shr(a, n) return a // (1 << n) end
local function __K2L_Ushr(a, n) return __K2L_ToInt32((a & 0xFFFFFFFF) >> n) end
