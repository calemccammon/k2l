-- requires: Long64
-- Long arithmetic for the lualib's own Long code with --long64 emulate: exact two's complement 64-bit values (see Long64).
local __K2L_LongArith = {}

__K2L_LongArith.add = __K2L_LAdd
__K2L_LongArith.lt = __K2L_LLt
__K2L_LongArith.toDouble = __K2L_LDouble
__K2L_LongArith.MAX = __K2L_LLit(2147483647, 4294967295)
__K2L_LongArith.MIN = __K2L_LLit(-2147483648, 0)
__K2L_LongArith.fromHalves = __K2L_Long64.make
__K2L_LongArith.halves = __K2L_Long64.parts
