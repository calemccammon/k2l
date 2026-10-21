local ____lualib = require("lualib_bundle")
local __K2L_DoubleToInt = ____lualib.__K2L_DoubleToInt
local __K2L_DoubleToString = ____lualib.__K2L_DoubleToString
local __K2L_FloatSum = ____lualib.__K2L_FloatSum
local __K2L_FloatToString = ____lualib.__K2L_FloatToString
local __K2L_Fround = ____lualib.__K2L_Fround
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringToDouble = ____lualib.__K2L_StringToDouble

local function main()
    local a = __K2L_Fround(1.0 / 3)
    print(__K2L_FloatToString(a))
    local d = 1.100000023841858
    print(__K2L_DoubleToString(d))
    print(__K2L_Str(__K2L_ReadOnlyListOf(1.5, a)))
    print("v=" .. __K2L_FloatToString(a))
    local s = 0.0
    for i = 1, 10 do
        s = __K2L_Fround(s + 0.10000000149011612)
    end
    print(__K2L_FloatToString(s))
    print(__K2L_FloatToString(3.4028234663852886E38))
    print(__K2L_FloatToString(1.401298464324817E-45))
    print(__K2L_FloatToString(0.0 / 0.0))
    print(__K2L_FloatToString(math.huge))
    print(__K2L_FloatToString(__K2L_Fround(math.sqrt(2.0))))
    print(__K2L_FloatToString(__K2L_Fround(16777217)))
    print(__K2L_FloatToString(__K2L_Fround(__K2L_StringToDouble("3.14159"))))
    print(__K2L_FloatToString(__K2L_Fround(3.14159)))
    print(__K2L_FloatToString(1.0E10))
    print(__K2L_FloatToString(9.999999747378752E-6))
    print(__K2L_FloatToString(100.0))
    print(__K2L_DoubleToInt(a))
    print(__K2L_DoubleToInt(__K2L_Fround(a * 100)))
    print(a < 0.3400000035762787)
    print(__K2L_FloatToString(__K2L_Fround(0.10000000149011612 + 0.20000000298023224)))
    print(__K2L_Fround(0.10000000149011612 + 0.20000000298023224) == 0.30000001192092896)
    print(__K2L_FloatToString(__K2L_Fround(10 / 4.0)))
    local x = 1.100000023841858
    x = __K2L_Fround(x + 1)
    print(__K2L_FloatToString(x))
    print(__K2L_FloatToString(-a))
    print(__K2L_FloatToString(__K2L_Fround(__K2L_Fround(a * a) * a)))
    print(__K2L_FloatToString(__K2L_Fround(3.4028234663852886E38 * 2)))
    print(__K2L_DoubleToString(3.4028234663852886E38))
    local xs = __K2L_ReadOnlyListOf(1.100000023841858, 2.200000047683716, 3.299999952316284)
    print(__K2L_FloatToString(__K2L_FloatSum(xs)))
    local ____out = {}
    local ____count = 0
    local ____items, ____n = xs:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = __K2L_Fround(it * 2)
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    print(__K2L_FloatToString(a) .. "!")
    print(__K2L_DoubleToString(a * 3))
end

__K2L_Main(main)
