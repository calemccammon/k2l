-- requires: ToInt32
-- Kotlin Int bitwise operations via bit32 (Lua 5.2), whose unsigned results are wrapped to a signed Int.
local band, bor, bxor, bnot, lshift, arshift, rshift = bit32.band, bit32.bor, bit32.bxor, bit32.bnot, bit32.lshift, bit32.arshift,
    bit32.rshift

local function __K2L_BAnd(a, b) return __K2L_ToInt32(band(a, b)) end
local function __K2L_BOr(a, b) return __K2L_ToInt32(bor(a, b)) end
local function __K2L_BXor(a, b) return __K2L_ToInt32(bxor(a, b)) end
local function __K2L_BNot(a) return __K2L_ToInt32(bnot(a)) end
local function __K2L_Shl(a, n) return __K2L_ToInt32(lshift(a, n)) end
local function __K2L_Shr(a, n) return __K2L_ToInt32(arshift(a, n)) end
local function __K2L_Ushr(a, n) return __K2L_ToInt32(rshift(a, n)) end
