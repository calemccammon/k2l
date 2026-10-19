local ____lualib = require("lualib_bundle")
local __K2L_DoubleToInt = ____lualib.__K2L_DoubleToInt
local __K2L_DoubleToLong = ____lualib.__K2L_DoubleToLong
local __K2L_DoubleToString = ____lualib.__K2L_DoubleToString
local __K2L_FloatToString = ____lualib.__K2L_FloatToString
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
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

local function main()
    print(__K2L_ReadOnlyListOf(-2147483648, -2147483648, -2147483647 - 1, -2147483647):joinToString())
    local min = -2147483648
    print(min .. " " .. __K2L_Num.toRadix(min, 16) .. " " .. tostring(min == -2147483648))
    print(__K2L_ReadOnlyListOf("-0.0", "-0", "0.0", "-0e5", "+0"):map(function(it) return __K2L_StringToDouble(it) end):joinToString(nil, nil, nil, nil, nil, function(it) return __K2L_DoubleToString(it) end))
    local ____value = __K2L_StringToDouble("-0.0")
    print(__K2L_DoubleToString(1 / ____value))
    local maybe = __K2L_StringToDoubleOrNull("2")
    local none = __K2L_StringToDoubleOrNull("x")
    print(__K2L_DoubleToString(maybe))
    print(__K2L_DoubleToString(none))
    print(__K2L_DoubleToString(maybe) .. " " .. __K2L_DoubleToString(none) .. " " .. __K2L_DoubleToString(maybe) .. " " .. __K2L_DoubleToString(none))
    local f = 1.5
    print(__K2L_FloatToString(f) .. " " .. __K2L_Str(__K2L_ReadOnlyListOf(maybe, none, 3.0):map(function(it) return __K2L_DoubleToString(it) end)))
    print(__K2L_Str(__K2L_ReadOnlyListOf(__K2L_Pair.new("a", "A"), __K2L_Pair.new("b", "b"), __K2L_Pair.new("c", "D"), __K2L_Pair.new("1", "1")):map(function(____destructured)
        local x, y = ____destructured.first, ____destructured.second
        return tostring(__K2L_StringEqualsIgnoreCase(x, y)) .. "/" .. tostring(x == y) .. "/" .. tostring(same(x, y, true))
    end)))
    local m = __K2L_SortedMap.new()
    m:set(1, "a")
    m:set(10, "b")
    print(__K2L_NotNull(m:higherKey(5)))
    local k = m:higherKey(50)
    print(__K2L_Str(k))
    print("key " .. __K2L_Str(m:higherKey(50)))
    local ____ok, ____result = pcall(function()
        print(__K2L_NotNull(m:higherKey(50)))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_NullPointerException) then
            local e = ____error
            print("NPE from println")
        else
            error(____error, 0)
        end
    end
    local ____ok_1, ____result_1 = pcall(function()
        local x = m:higherKey(50)
        io.write(__K2L_Str(__K2L_NotNull(x)))
        print()
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error_1, __K2L_NullPointerException) then
            local e = ____error_1
            print("NPE from print")
        else
            error(____error_1, 0)
        end
    end
    print(__K2L_Str(m:higherEntry(50)))
    print(__K2L_Str(m:ceilingKey(10)) .. "!")
    print(__K2L_ReadOnlyListOf("0x1p3", "0x1.8P-1", "-0X10p0d", "0x.8p1", "0x1", "0xp1"):joinToString(nil, nil, nil, nil, nil, function(it)
        return __K2L_DoubleToString(__K2L_StringToDoubleOrNull(it))
    end))
    print(__K2L_DoubleToLong(-0.5) .. " " .. __K2L_DoubleToInt(-0.4) .. " " .. __K2L_Num.roundToLong(-0.0) .. " " .. __K2L_Num.roundToInt(-0.2) .. " " .. __K2L_Num.roundToLong(-0.3))
    print(__K2L_StringFormat("%.3e %.1e %e %g", 4.9E-324, 4.9E-324, 2 * 4.9E-324, 4.9E-324))
    print(__K2L_Str(__K2L_ReadOnlyListOf(__K2L_Pair.new(true, true), __K2L_Pair.new(true, false), __K2L_Pair.new(false, true)):map(function(____destructured_1)
        local a, b = ____destructured_1.first, ____destructured_1.second
        return tostring(a ~= b) .. "/" .. tostring(not a)
    end)))
end

main()
return {same = same}
