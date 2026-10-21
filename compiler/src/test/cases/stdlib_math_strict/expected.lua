local ____lualib = require("lualib_bundle")
local __K2L_DoubleToString = ____lualib.__K2L_DoubleToString
local __K2L_FdLibm = ____lualib.__K2L_FdLibm
local __K2L_FloatToString = ____lualib.__K2L_FloatToString
local __K2L_Fround = ____lualib.__K2L_Fround
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf

local edges = __K2L_ReadOnlyListOf(0.0, -0.0, 4.9E-324, -4.9E-324, 2.2250738585072014E-308, 1.0E-300, 1.0E-20, 3.0E-9, 1.0E-5, 0.1, 0.25, 0.4375, 0.5, 0.7, 0.9, 0.975, 1.0, -1.0, 1.1875, 1.5, 2.0, 2.4375, 3.0, 10.0, 21.9, 22.0, 30.0, 100.0, 709.0, 709.8, 710.0, 711.0, 1.0E10, 1.0E300, 1.7976931348623157E308, math.huge, -math.huge, 0.0 / 0.0, -0.3, -2.5, -40.0, -800.0)

local function line(name, values)
    print(name .. ": " .. values:joinToString(" ", nil, nil, nil, nil, __K2L_DoubleToString))
end

local function samples(count, scale)
    local x = 0.5
    local ____out = {}
    for ____i = 1, count do
        local it = ____i - 1
        local ____result
        x = math.fmod(x * 9301.0 + 49297.0, 233280.0)
        ____result = (x / 233280.0 - 0.5) * scale
        ____out[____i] = ____result
    end
    return __K2L_ListWrap(____out, count)
end

local ____lambda_1 = function(____p1) return __K2L_FdLibm.atan(____p1) end
local ____lambda_2 = function(____p1) return __K2L_FdLibm.asin(____p1) end
local ____lambda_3 = function(____p1) return __K2L_FdLibm.acos(____p1) end
local ____lambda_4 = function(____p1) return __K2L_FdLibm.cbrt(____p1) end
local ____lambda_5 = function(____p1) return __K2L_FdLibm.sinh(____p1) end
local ____lambda_6 = function(____p1) return __K2L_FdLibm.cosh(____p1) end
local ____lambda_7 = function(____p1) return __K2L_FdLibm.tanh(____p1) end
local ____lambda_8 = function(____p1) return __K2L_FdLibm.expm1(____p1) end
local ____lambda_9 = function(____p1) return __K2L_FdLibm.log1p(____p1) end
local ____lambda_10 = function(a, b) return __K2L_FdLibm.hypot(a, b) end
local ____lambda_11 = function(a, b) return __K2L_FdLibm.atan2(a, b) end
local ____lambda_12 = function(a, b)
    return __K2L_FdLibm.hypot(a * 1.0E-306, b * 1.0E-308)
end
local ____lambda_13 = function(a, b)
    return __K2L_FdLibm.hypot(a * 1.0E-160, b * 1.0E-162)
end
local ____lambda_14 = function(a, b)
    return __K2L_FdLibm.hypot(a * 1.0E303, b * 1.0E305)
end
local ____lambda_15 = function(a, b)
    return __K2L_FdLibm.hypot(a * 1.0E150, b * 1.0E152)
end
local function main()
    local one = __K2L_ReadOnlyListOf(__K2L_Pair.new("atan", ____lambda_1), __K2L_Pair.new("asin", ____lambda_2), __K2L_Pair.new("acos", ____lambda_3), __K2L_Pair.new("cbrt", ____lambda_4), __K2L_Pair.new("sinh", ____lambda_5), __K2L_Pair.new("cosh", ____lambda_6), __K2L_Pair.new("tanh", ____lambda_7), __K2L_Pair.new("expm1", ____lambda_8), __K2L_Pair.new("ln1p", ____lambda_9))
    local ____mod = one.____modCount
    for ____i_1 = 1, one.size do
        local ____item = one[____i_1]
        local name, f = ____item.first, ____item.second
        line(name, edges:map(f))
        if one.____modCount ~= ____mod and one:____comodified(____i_1) then
            break
        end
    end
    local ____mod_1 = one.____modCount
    for ____i_3 = 1, one.size do
        local ____item_1 = one[____i_3]
        local name, f = ____item_1.first, ____item_1.second
        local scale
        if name == "asin" or name == "acos" then
            scale = 2.0
        elseif name == "sinh" or name == "cosh" or name == "expm1" then
            scale = 60.0
        elseif name == "ln1p" then
            scale = 4.0
        else
            scale = 200.0
        end
        local ____arg = name .. "~"
        local ____list = samples(60, scale)
        local ____out_1 = {}
        local ____count = 0
        local ____items, ____n = ____list:____array()
        for ____i_2 = 1, ____n do
            local it = ____items[____i_2]
            local ____result_1
            ____result_1 = f(name == "ln1p" and math.abs(it) - 0.9 or it)
            ____count = ____count + 1
            ____out_1[____count] = ____result_1
        end
        line(____arg, __K2L_ListWrap(____out_1, ____count))
        if one.____modCount ~= ____mod_1 and one:____comodified(____i_3) then
            break
        end
    end
    local xs = samples(80, 300.0)
    local ys = samples(81, 7.0):drop(1)
    line("hypot~", xs:zip(ys, ____lambda_10))
    line("atan2~", xs:zip(ys, ____lambda_11))
    line("hypot tiny~", xs:zip(ys, ____lambda_12):plusAll(xs:zip(ys, ____lambda_13)))
    line("hypot huge~", xs:zip(ys, ____lambda_14):plusAll(xs:zip(ys, ____lambda_15)))
    local ____list_1 = edges
    local ____out_2 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_4 = 1, ____n_1 do
        local it = ____items_1[____i_4]
        ____count_1 = ____count_1 + 1
        ____out_2[____count_1] = __K2L_FdLibm.hypot(it, 3.0)
    end
    local ____arg_1 = __K2L_ListWrap(____out_2, ____count_1)
    local ____list_2 = edges
    local ____out_3 = {}
    local ____count_2 = 0
    local ____items_2, ____n_2 = ____list_2:____array()
    for ____i_5 = 1, ____n_2 do
        local it = ____items_2[____i_5]
        ____count_2 = ____count_2 + 1
        ____out_3[____count_2] = __K2L_FdLibm.hypot(1.0E-310, it)
    end
    line("hypot", ____arg_1:plusAll(__K2L_ListWrap(____out_3, ____count_2)):plusAll(__K2L_ReadOnlyListOf(__K2L_FdLibm.hypot(1.0E300, 1.0E300), __K2L_FdLibm.hypot(1.0E-300, 3.0E-310), __K2L_FdLibm.hypot(0.0 / 0.0, -math.huge))))
    local ____list_3 = edges
    local ____out_4 = {}
    local ____count_3 = 0
    local ____items_3, ____n_3 = ____list_3:____array()
    for ____i_6 = 1, ____n_3 do
        local y = ____items_3[____i_6]
        local ____inner, ____m = __K2L_ReadOnlyListOf(__K2L_FdLibm.atan2(y, 1.0), __K2L_FdLibm.atan2(y, -2.0), __K2L_FdLibm.atan2(y, 0.0), __K2L_FdLibm.atan2(y, -math.huge), __K2L_FdLibm.atan2(1.0, y)):____array()
        for ____j = 1, ____m do
            ____count_3 = ____count_3 + 1
            ____out_4[____count_3] = ____inner[____j]
        end
    end
    line("atan2", __K2L_ListWrap(____out_4, ____count_3))
    line("IEEErem", __K2L_ReadOnlyListOf(__K2L_Num.IEEErem(5.0, 3.0), __K2L_Num.IEEErem(-5.0, 3.0), __K2L_Num.IEEErem(7.5, 2.0), __K2L_Num.IEEErem(6.5, 2.0), __K2L_Num.IEEErem(-6.5, 2.0), __K2L_Num.IEEErem(1.0E300, 3.0), __K2L_Num.IEEErem(0.0, -1.0), __K2L_Num.IEEErem(-0.0, 5.0), __K2L_Num.IEEErem(4.9E-324, 9.9E-324), __K2L_Num.IEEErem(1.7976931348623157E308, 1.5), __K2L_Num.IEEErem(3.0, 1.7976931348623157E308), __K2L_Num.IEEErem(0.0 / 0.0, 1.0), __K2L_Num.IEEErem(1.0, 0.0)))
    line("pow", __K2L_ReadOnlyListOf(__K2L_Num.pow(1.0, 0.0 / 0.0), __K2L_Num.pow(-1.0, math.huge), __K2L_Num.pow(1.0, -math.huge), __K2L_Num.pow(2.0, 0.0 / 0.0), (0.0 / 0.0) ^ 0.0, __K2L_Num.pow(0.5, math.huge), __K2L_Num.pow(1.0, 0.0 / 0.0)))
    line("min/max", __K2L_ReadOnlyListOf(__K2L_Num.minD(0.0, -0.0), __K2L_Num.minD(-0.0, 0.0), __K2L_Num.maxD(0.0, -0.0), __K2L_Num.maxD(-0.0, 0.0), __K2L_Num.minD(1.0, 0.0 / 0.0), __K2L_Num.maxD(0.0 / 0.0, 1.0), __K2L_Num.minD(__K2L_Num.minD(__K2L_Num.minD(3.0, 1.0), -0.0), 0.0), __K2L_Num.maxD(__K2L_Num.maxD(-0.0, -1.0), 0.0), __K2L_Num.minD(-0.0, 0.0), __K2L_Num.maxD(-0.0, 0.0)))
    line("truncate", __K2L_ReadOnlyListOf(__K2L_Num.truncate(-0.5), __K2L_Num.truncate(-0.0), __K2L_Num.truncate(0.7), __K2L_Num.truncate(-1.0E300), __K2L_Num.ceil(-0.5), __K2L_Num.round(-0.4)))
    print("float: " .. __K2L_FloatToString(__K2L_Fround(__K2L_FdLibm.hypot(3.0, 4.0))) .. " " .. __K2L_FloatToString(__K2L_Fround(__K2L_FdLibm.atan2(1.0, 2.0))) .. " " .. __K2L_FloatToString(__K2L_Fround(__K2L_FdLibm.cbrt(10.0))) .. " " .. __K2L_FloatToString(__K2L_Fround(__K2L_FdLibm.tanh(0.5))) .. " " .. __K2L_FloatToString(__K2L_Fround(2.0 ^ 0.5)) .. " " .. __K2L_FloatToString(__K2L_Num.maxD(-0.0, 0.0)) .. " " .. __K2L_FloatToString(__K2L_Num.IEEErem(1.5, 1.0)))
    print("java: " .. __K2L_DoubleToString(__K2L_FdLibm.hypot(5.0, 12.0)) .. " " .. __K2L_DoubleToString(__K2L_FdLibm.atan(0.5)) .. " " .. __K2L_DoubleToString(__K2L_FdLibm.asin(0.3)) .. " " .. __K2L_DoubleToString(__K2L_FdLibm.acos(0.3)) .. " " .. __K2L_DoubleToString(__K2L_FdLibm.expm1(0.001)) .. " " .. __K2L_DoubleToString(__K2L_FdLibm.log1p(0.001)) .. " " .. __K2L_DoubleToString(__K2L_Num.IEEErem(10.0, 3.0)))
end

__K2L_Main(main)
return {edges = edges, line = line, samples = samples}
