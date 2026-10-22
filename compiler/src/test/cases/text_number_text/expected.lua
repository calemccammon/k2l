local ____lualib = require("lualib_bundle")
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringEqualsIgnoreCase = ____lualib.__K2L_StringEqualsIgnoreCase
local __K2L_StringToDouble = ____lualib.__K2L_StringToDouble
local __K2L_StringToDoubleOrNull = ____lualib.__K2L_StringToDoubleOrNull
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_Truncate = ____lualib.__K2L_Truncate

local function same(a, b, ignoreCase)
    return __K2L_Text.charEquals(a, b, ignoreCase)
end

local ____lambda_1 = function(it) return tostring(it) end
local ____lambda_2 = function(it)
    return __K2L_Str(__K2L_StringToDoubleOrNull(it))
end
local function main()
    print(__K2L_ListOf(-2147483648, -2147483648, -2147483647 - 1, -2147483647):joinToString())
    local min = -2147483648
    print(min .. " " .. __K2L_Num.toRadix(min, 16) .. " " .. tostring(min == -2147483648))
    local ____list = __K2L_ListOf("-0.0", "-0", "0.0", "-0e5", "+0")
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
    print(1 / ____value)
    local maybe = __K2L_StringToDoubleOrNull("2")
    local none = __K2L_StringToDoubleOrNull("x")
    print(__K2L_Str(maybe))
    print(__K2L_Str(none))
    print(__K2L_Str(maybe) .. " " .. __K2L_Str(none) .. " " .. __K2L_Str(maybe) .. " " .. __K2L_Str(none))
    local f = 1.5
    local ____arg = __K2L_Str(f)
    local ____list_1 = __K2L_ListOf(maybe, none, 3.0)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = __K2L_Str(it)
    end
    print(____arg .. " " .. __K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
    local ____list_2 = __K2L_ListOf(__K2L_Pair.new("a", "A"), __K2L_Pair.new("b", "b"), __K2L_Pair.new("c", "D"), __K2L_Pair.new("1", "1"))
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
    print(__K2L_ListOf("0x1p3", "0x1.8P-1", "-0X10p0d", "0x.8p1", "0x1", "0xp1"):joinToString(nil, nil, nil, nil, nil, ____lambda_2))
    print(__K2L_Truncate(-0.5) .. " " .. __K2L_Truncate(-0.4) .. " " .. math.floor(-0.0 + 0.5) .. " " .. math.floor(-0.2 + 0.5) .. " " .. math.floor(-0.3 + 0.5))
    print(string.format("%.3e %.1e %e %g", 4.9E-324, 4.9E-324, 2 * 4.9E-324, 4.9E-324))
    local ____list_3 = __K2L_ListOf(__K2L_Pair.new(true, true), __K2L_Pair.new(true, false), __K2L_Pair.new(false, true))
    local ____out_3 = {}
    local ____count_3 = 0
    local ____items_3, ____n_3 = ____list_3:____array()
    for ____i_3 = 1, ____n_3 do
        local ____it_1 = ____items_3[____i_3]
        local ____result_1
        do
            local a, b = ____it_1.first, ____it_1.second
            ____result_1 = tostring(a ~= b) .. "/" .. tostring(not a)
        end
        ____count_3 = ____count_3 + 1
        ____out_3[____count_3] = ____result_1
    end
    print(__K2L_Str(__K2L_ListWrap(____out_3, ____count_3)))
end

__K2L_RunMain(main)
return {same = same}
