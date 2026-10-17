-- requires: ToInt32
-- Kotlin Int bitwise operations via bit32 (Lua 5.2), whose results are unsigned.
local function __K2L_BAnd(a, b) return __K2L_ToInt32(bit32.band(a, b)) end
local function __K2L_BOr(a, b) return __K2L_ToInt32(bit32.bor(a, b)) end
local function __K2L_BXor(a, b) return __K2L_ToInt32(bit32.bxor(a, b)) end
local function __K2L_BNot(a) return __K2L_ToInt32(bit32.bnot(a)) end
local function __K2L_Shl(a, n) return __K2L_ToInt32(bit32.lshift(a, n)) end
local function __K2L_Shr(a, n) return __K2L_ToInt32(bit32.arshift(a, n)) end
local function __K2L_Ushr(a, n) return __K2L_ToInt32(bit32.rshift(a, n)) end
