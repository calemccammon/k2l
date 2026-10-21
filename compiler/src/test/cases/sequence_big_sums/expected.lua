local ____lualib = require("lualib_bundle")
local __K2L_BigDecimal = ____lualib.__K2L_BigDecimal
local __K2L_BigInteger = ____lualib.__K2L_BigInteger
local __K2L_GenerateSequence = ____lualib.__K2L_GenerateSequence
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SequenceOf = ____lualib.__K2L_SequenceOf
local __K2L_Str = ____lualib.__K2L_Str

local ____lambda_1 = function(it) return __K2L_BigInteger.valueOf(it):pow(20) end
local ____lambda_2 = function(it)
    return __K2L_BigDecimal.parse("0.1"):multiply(__K2L_BigDecimal.fromLong(it))
end
local ____lambda_3 = function(it) return __K2L_BigInteger.valueOf(it) end
local ____lambda_4 = function(it) return __K2L_BigDecimal.fromLong(it) end
local ____lambda_5 = function(it) return it + 1 end
local ____lambda_6 = function(it) return __K2L_BigInteger.TWO:pow(it) end
local ____lambda_7 = function(it) return __K2L_BigDecimal.parse("1.5") end
local function main()
    local nums = __K2L_SequenceOf(1, 2, 3)
    print(__K2L_Str(nums:sumOf(____lambda_1, __K2L_BigInteger.ZERO)))
    print(__K2L_Str(nums:sumOf(____lambda_2, __K2L_BigDecimal.ZERO)))
    print(__K2L_Str(__K2L_SequenceOf():sumOf(____lambda_3, __K2L_BigInteger.ZERO)))
    print(__K2L_Str(__K2L_SequenceOf():sumOf(____lambda_4, __K2L_BigDecimal.ZERO)))
    print(__K2L_Str(__K2L_GenerateSequence(1, ____lambda_5):take(30):sumOf(____lambda_6, __K2L_BigInteger.ZERO)))
    print(__K2L_Str(__K2L_ReadOnlyListOf(1, 2, 3):sumOf(____lambda_7, __K2L_BigDecimal.ZERO)))
end

__K2L_Main(main)
