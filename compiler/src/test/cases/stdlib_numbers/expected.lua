local ____lualib = require("lualib_bundle")
local __K2L_CharRange = ____lualib.__K2L_CharRange
local __K2L_ClosedRange = ____lualib.__K2L_ClosedRange
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_DoubleToInt = ____lualib.__K2L_DoubleToInt
local __K2L_DoubleToString = ____lualib.__K2L_DoubleToString
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_IsDigit = ____lualib.__K2L_IsDigit
local __K2L_IsLetter = ____lualib.__K2L_IsLetter
local __K2L_IsLetterOrDigit = ____lualib.__K2L_IsLetterOrDigit
local __K2L_IsLowerCase = ____lualib.__K2L_IsLowerCase
local __K2L_IsUpperCase = ____lualib.__K2L_IsUpperCase
local __K2L_IsWhitespace = ____lualib.__K2L_IsWhitespace
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Random = ____lualib.__K2L_Random
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32

local function ints()
    print(2147483647)
    print(-2147483648)
    print(__K2L_Num.toRadix(255, 16))
    print(__K2L_Num.toRadix(255, 2))
    print(__K2L_Num.toRadix(-255, 16))
    print(__K2L_Str(__K2L_Num.toRadixUnsigned(10, 2)))
    print(__K2L_Num.toByte(10))
    print(__K2L_Num.toByte(300))
    print(__K2L_Num.toShort(70000))
    print(__K2L_DoubleToInt(3.9))
    print(__K2L_DoubleToInt(-3.9))
    print(__K2L_DoubleToInt(1.0E10))
    print(__K2L_ToInt32(5))
    print(2147483647 + 0)
    print(12345 * 1000)
    print(__K2L_Compare(7, 9))
    print(__K2L_Compare(9, 7))
    print(__K2L_Num.coerceIn(5, 1, 3))
    print(__K2L_Num.countOneBits(10))
    print(__K2L_Num.countTrailingZeroBits(8))
    print(__K2L_Num.countLeadingZeroBits(1))
    print(~11)
    print(5 ~ 3)
    print(5 & 3)
    print(5 | 3)
    print(((1 << 4) + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print(-16 // 4)
    print((-16 & 0xFFFFFFFF) >> 28)
    print(__K2L_Num.signInt(7))
    print(math.abs(-7))
    print(__K2L_Str((10 + 0.0) / 4))
    print(math.fmod(17, 5))
    print(2 * 3 + 4)
    print(2147483647 + 1)
end

local function chars()
    print(97)
    print(string.char(97))
    print(string.char(("a"):byte() + 1))
    print(("d"):byte() - ("a"):byte())
    print(("a"):upper())
    print(("Z"):lower())
    print(__K2L_Num.digitToInt("5"))
    print(__K2L_Num.digitToInt("f", 16))
    print(__K2L_Str(__K2L_Num.digitToIntOrNull("x")))
    print(__K2L_Num.digitToChar(7))
    print(__K2L_IsLetter.a == true)
    print(__K2L_IsDigit["1"] == true)
    print(__K2L_IsWhitespace[" "] == true)
    print(__K2L_IsUpperCase.A == true)
    print(__K2L_IsLowerCase.a == true)
    print(__K2L_IsLetterOrDigit._ == true)
    print(__K2L_Compare("a", "c"))
    print(__K2L_Str(__K2L_CharRange.new("a", "e"):toList()))
    print(__K2L_CharRange.new("a", "e"):joinToString(""))
    print("c" >= "a" and "c" <= "e")
    print("a" .. "b")
    print(("x"):upper())
end

local ____lambda_1 = function(it) return it * it end
local ____lambda_2 = function(a, b) return a * b end
local ____lambda_3 = function(it)
    return (it >= 0 and it % 2 or 0 - -it % 2) == 1
end
local ____lambda_4 = function(it) return it * 2 end
local ____lambda_5 = function(a)
    return __K2L_IntRange.new(1, a):map(function(it) return a * 10 + it end)
end
local function ranges()
    print(__K2L_IntRange.new(1, 5):sum())
    print(__K2L_Str(__K2L_IntRange.new(1, 5):map(____lambda_1)))
    print(__K2L_Str(__K2L_IntRange.new(5, 1, -1):toList()))
    print(__K2L_Str(__K2L_IntRange.new(1, 10):withStep(3):toList()))
    print(__K2L_Str(__K2L_IntRange.new(10, 1, -1):withStep(4):toList()))
    print(__K2L_Str(__K2L_IntRange.new(1, 5 - 1):toList()))
    print(__K2L_Str(__K2L_IntRange.new(1, 0):toList()))
    print(__K2L_Str(__K2L_IntRange.new(1, 5):reversed():toList()))
    print(__K2L_IntRange.new(1, 5):count())
    print(__K2L_IntRange.new(1, 5).first)
    print(__K2L_IntRange.new(1, 5).last)
    print(__K2L_IntRange.new(1, 10):withStep(2).last)
    print(3 >= 1 and 3 <= 5)
    print(not (7 >= 1 and 7 <= 5))
    print(__K2L_IntRange.new(1, 5):contains(5))
    print(__K2L_Str(__K2L_IntRange.new(1, 5):average()))
    print(__K2L_IntRange.new(1, 5):fold(1, ____lambda_2))
    local ____list = __K2L_IntRange.new(1, 3):toList()
    local ____sum = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____sum = ____sum + it
    end
    print(____sum)
    print(__K2L_Str(__K2L_IntRange.new(1, 5):filter(____lambda_3)))
    print(__K2L_IntRange.new(1, 5):min())
    print(__K2L_IntRange.new(1, 5):max())
    print(__K2L_IntRange.new(1, 5):isEmpty())
    print(__K2L_IntRange.new(1, 0):isEmpty())
    print(__K2L_ClosedRange.new(1.0, 2.0, __K2L_DoubleToString):contains(1.5))
    print(__K2L_Str(__K2L_ClosedRange.new(1.0, 2.0, __K2L_DoubleToString).last))
    print(__K2L_Str(__K2L_IntRange.new(1, 5)))
    print(__K2L_Str(__K2L_IntRange.new(1, 5):withStep(2)))
    print(__K2L_Str(__K2L_IntRange.new(1, 3):toList()))
    print(__K2L_Str(__K2L_IntRange.new(1, 5):zip(__K2L_IntRange.new(6, 10))))
    print(__K2L_Str(__K2L_IntRange.new(1, 4):associateWith(____lambda_4)))
    print(__K2L_Str(__K2L_IntRange.new(1, 6):chunked(4)))
    print(__K2L_Str(__K2L_IntRange.new(1, 3):flatMap(____lambda_5)))
    local ____value = __K2L_Random.seeded(3):nextIntRange(__K2L_IntRange.new(1, 5), false)
    print(____value >= 1 and ____value <= 5)
end

local function longs()
    local big = 1234567890123
    print(big)
    print(big + 1)
    print(big >= 0 and big // 1000 or (big + 999) // 1000)
    print(big >= 0 and big % 1000 or (big % 1000 - 1000) % (-1000))
    print(#tostring(big))
    print(big > 5)
    print(__K2L_StringToInt("123456789012", nil, true))
    print(math.max(big, 5))
    print(__K2L_Str(big + 0.0))
    print(-big)
end

local function main()
    ints()
    chars()
    ranges()
    longs()
end

__K2L_Main(main)
return {ints = ints, chars = chars, ranges = ranges, longs = longs}
