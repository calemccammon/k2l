local ____lualib = require("lualib_bundle")
local __K2L_DoubleToInt = ____lualib.__K2L_DoubleToInt
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32

local function main()
    local a = 17
    local b = 5
    print(a + b)
    print(a - b)
    print(a * b)
    print(__K2L_IDiv(a, b))
    print(math.fmod(a, b))
    print(__K2L_IDiv(-a, b))
    print(math.fmod(-a, b))
    print(__K2L_IDiv(a, -b))
    print(math.fmod(a, -b))
    local x = 7.5
    local y = 2.0
    print(__K2L_Str(x + y))
    print(__K2L_Str(x / y))
    print(__K2L_Str(math.fmod(x, y)))
    print(__K2L_Str(x * a))
    print(__K2L_Str(a / y))
    print(__K2L_Str(1.0 / 3))
    print(__K2L_Str(1.0E10))
    print(__K2L_Str(1.0E-4))
    print(__K2L_Str(1.0 / 0.0))
    print(__K2L_Str(-(1.0 / 0.0)))
    print(__K2L_Str(0.0 / 0.0))
    print(a > b and b > 0)
    print(a < b or b ~= 5)
    print(a ~= b)
    print(2 - -3)
    print(-(-a))
    print(math.max(3, 9))
    print(__K2L_Str(math.min(2.5, 1.5)))
    print(__K2L_Str(math.sqrt(16.0)))
    print(math.abs(-4))
    print(__K2L_Str(math.floor(2.7) + 0.0))
    print(__K2L_DoubleToInt(x))
    print(__K2L_DoubleToInt(-x))
    print(__K2L_Str(a + 0.0))
    print(__K2L_ToInt32(3000000000))
    print(2147483647)
end

main()
