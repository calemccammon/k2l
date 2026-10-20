local ____lualib = require("lualib_bundle")
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_DoubleToInt = ____lualib.__K2L_DoubleToInt
local __K2L_DoubleToLong = ____lualib.__K2L_DoubleToLong
local __K2L_DoubleToString = ____lualib.__K2L_DoubleToString
local __K2L_FloatToString = ____lualib.__K2L_FloatToString
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_NullPointerException = ____lualib.__K2L_NullPointerException
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SortedMap = ____lualib.__K2L_SortedMap
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringEqualsIgnoreCase = ____lualib.__K2L_StringEqualsIgnoreCase
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_StringToDouble = ____lualib.__K2L_StringToDouble
local __K2L_StringToDoubleOrNull = ____lualib.__K2L_StringToDoubleOrNull
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function same(a, b, ignoreCase)
    return __K2L_Text.charEquals(a, b, ignoreCase)
end

local ____lambda_1 = function(it) return __K2L_DoubleToString(it) end
local ____lambda_2 = function(it)
    return __K2L_DoubleToString(__K2L_StringToDoubleOrNull(it))
end
local function main()
    print(__K2L_ReadOnlyListOf(-2147483648, -2147483648, -2147483647 - 1, -2147483647):joinToString())
    local min = -2147483648
    print(min .. " " .. __K2L_Num.toRadix(min, 16) .. " " .. tostring(min == -2147483648))
    local ____list = __K2L_ReadOnlyListOf("-0.0", "-0", "0.0", "-0e5", "+0")
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = __K2L_StringToDouble(it)
    end
    print(__K2L_ListWrap(____out, ____count):joinToString(nil, nil, nil, nil, nil, ____lambda_1))
    local ____value = __K2L_StringToDouble("-0.0")
    print(__K2L_DoubleToString(1 / ____value))
    local maybe = __K2L_StringToDoubleOrNull("2")
    local none = __K2L_StringToDoubleOrNull("x")
    print(__K2L_DoubleToString(maybe))
    print(__K2L_DoubleToString(none))
    print(__K2L_DoubleToString(maybe) .. " " .. __K2L_DoubleToString(none) .. " " .. __K2L_DoubleToString(maybe) .. " " .. __K2L_DoubleToString(none))
    local f = 1.5
    local ____arg = __K2L_FloatToString(f)
    local ____list_1 = __K2L_ReadOnlyListOf(maybe, none, 3.0)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = __K2L_DoubleToString(it)
    end
    print(____arg .. " " .. __K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
    local ____list_2 = __K2L_ReadOnlyListOf(__K2L_Pair.new("a", "A"), __K2L_Pair.new("b", "b"), __K2L_Pair.new("c", "D"), __K2L_Pair.new("1", "1"))
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_2, ____n_2 = ____list_2:____array()
    for ____i_2 = 1, ____n_2 do
        local ____it = ____items_2[____i_2]
        local ____result
        do
            local x, y = ____it.first, ____it.second
            ____result = tostring(__K2L_StringEqualsIgnoreCase(x, y)) .. "/" .. tostring(x == y) .. "/" .. tostring(same(x, y, true))
        end
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = ____result
    end
    print(__K2L_Str(__K2L_ListWrap(____out_2, ____count_2)))
    local m = __K2L_SortedMap.new()
    m:set(1, "a")
    m:set(10, "b")
    print(__K2L_NotNull(m:higherKey(5)))
    local k = m:higherKey(50)
    print(__K2L_Str(k))
    print("key " .. __K2L_Str(m:higherKey(50)))
    local ____ok, ____result_1 = __K2L_DeepPcall(function()
        print(__K2L_NotNull(m:higherKey(50)))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error, __K2L_NullPointerException) then
            local e = ____error
            print("NPE from println")
        else
            error(____error, 0)
        end
    end
    local ____ok_1, ____result_2 = __K2L_DeepPcall(function()
        local x = m:higherKey(50)
        io.write(__K2L_Str(__K2L_NotNull(x)))
        print()
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_2)
        if __K2L_InstanceOf(____error_1, __K2L_NullPointerException) then
            local e = ____error_1
            print("NPE from print")
        else
            error(____error_1, 0)
        end
    end
    print(__K2L_Str(m:higherEntry(50)))
    print(__K2L_Str(m:ceilingKey(10)) .. "!")
    print(__K2L_ReadOnlyListOf("0x1p3", "0x1.8P-1", "-0X10p0d", "0x.8p1", "0x1", "0xp1"):joinToString(nil, nil, nil, nil, nil, ____lambda_2))
    print(__K2L_DoubleToLong(-0.5) .. " " .. __K2L_DoubleToInt(-0.4) .. " " .. __K2L_Num.roundToLong(-0.0) .. " " .. __K2L_Num.roundToInt(-0.2) .. " " .. __K2L_Num.roundToLong(-0.3))
    print(__K2L_StringFormat("%.3e %.1e %e %g", 4.9E-324, 4.9E-324, 2 * 4.9E-324, 4.9E-324))
    local ____list_3 = __K2L_ReadOnlyListOf(__K2L_Pair.new(true, true), __K2L_Pair.new(true, false), __K2L_Pair.new(false, true))
    local ____out_3 = {}
    local ____count_3 = 0
    local ____items_3, ____n_3 = ____list_3:____array()
    for ____i_3 = 1, ____n_3 do
        local ____it_1 = ____items_3[____i_3]
        local ____result_3
        do
            local a, b = ____it_1.first, ____it_1.second
            ____result_3 = tostring(a ~= b) .. "/" .. tostring(not a)
        end
        ____count_3 = ____count_3 + 1
        ____out_3[____count_3] = ____result_3
    end
    print(__K2L_Str(__K2L_ListWrap(____out_3, ____count_3)))
end

__K2L_DeepMain(main)
return {same = same}
