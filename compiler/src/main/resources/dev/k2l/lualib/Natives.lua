-- Library functions that generated code calls in hot paths, as locals (one upvalue read instead of a global and a field):
-- the byte of each Char in `for (c in s)` loops that need no more, and the integer remainder (see IntOverflow.kt).
local __K2L_StrByte = string.byte
local __K2L_Fmod = math.fmod
