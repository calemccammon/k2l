local ____lualib = require("lualib_bundle")
local __K2L_Bits = ____lualib.__K2L_Bits
local __K2L_Exact = ____lualib.__K2L_Exact
local __K2L_FdLibm = ____lualib.__K2L_FdLibm
local __K2L_FloorDiv = ____lualib.__K2L_FloorDiv
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_StrictMath = ____lualib.__K2L_StrictMath

local edges = __K2L_ReadOnlyListOf(0.0, -0.0, 4.9E-324, -4.9E-324, 1.0E-310, 2.2250738585072014E-308, 1.0E-300, 1.0E-20, 3.7E-9, 1.0E-5, 0.1, 0.25, 0.5, 0.6744, 0.7, 0.785, 0.7853981633974483, 0.9, 1.0, -1.0, 1.5, 1.5707963267948966, 2.0, 2.356194490192345, 3.0, 3.141592653589793, 4.71238898038469, 6.283185307179586, 10.0, 22.0, 100.0, 709.0, 709.78, 710.0, -745.0, -746.0, 100000.0, 411774.8, 823549.6, 1000000.0, 1.0E10, 1.0E15, 1.0E22, 1.0E100, 1.0E300, 1.7976931348623157E308, -1.0E300, -0.3, -2.5, -40.0, math.huge, -math.huge, 0.0 / 0.0)

local function line(name, values)
    print(name .. ": " .. values:joinToString(" "))
end

local function samples(count, scale, seed)
    if seed == nil then
        seed = 0.5
    end
    local x = seed
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

local function spread(count)
    local ____list = samples(count, 2.0, 0.25)
    local ____out_1 = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i_1 = 1, ____n do
        local x = ____items[____i_1]
        local i = ____i_1 - 1
        ____count = ____count + 1
        ____out_1[____count] = x * 2.0 ^ (__K2L_IDiv(i * 2093, count) - 1070)
    end
    return __K2L_ListWrap(____out_1, ____count)
end

local ____lambda_1 = function(____p1) return __K2L_StrictMath.sin(____p1) end
local ____lambda_2 = function(____p1) return __K2L_StrictMath.cos(____p1) end
local ____lambda_3 = function(____p1) return __K2L_StrictMath.tan(____p1) end
local ____lambda_4 = function(____p1) return __K2L_FdLibm.exp(____p1) end
local ____lambda_5 = function(____p1) return __K2L_StrictMath.log(____p1) end
local ____lambda_6 = function(____p1) return __K2L_StrictMath.log10(____p1) end
local ____lambda_7 = function(____p1) return __K2L_FdLibm.asin(____p1) end
local ____lambda_8 = function(____p1) return __K2L_FdLibm.acos(____p1) end
local ____lambda_9 = function(____p1) return __K2L_FdLibm.atan(____p1) end
local ____lambda_10 = function(____p1) return math.sqrt(____p1) end
local ____lambda_11 = function(____p1) return __K2L_FdLibm.cbrt(____p1) end
local ____lambda_12 = function(____p1) return __K2L_FdLibm.sinh(____p1) end
local ____lambda_13 = function(____p1) return __K2L_FdLibm.cosh(____p1) end
local ____lambda_14 = function(____p1) return __K2L_FdLibm.tanh(____p1) end
local ____lambda_15 = function(____p1) return __K2L_FdLibm.expm1(____p1) end
local ____lambda_16 = function(____p1) return __K2L_FdLibm.log1p(____p1) end
local ____lambda_17 = function(p, _) return p * 10.0 end
local ____lambda_18 = function(a, b)
    return __K2L_StrictMath.pow(math.abs(a), b)
end
local ____lambda_19 = function(it) return 2.0 ^ it end
local function main()
    local unary = __K2L_ReadOnlyListOf(__K2L_Pair.new("sin", ____lambda_1), __K2L_Pair.new("cos", ____lambda_2), __K2L_Pair.new("tan", ____lambda_3), __K2L_Pair.new("exp", ____lambda_4), __K2L_Pair.new("log", ____lambda_5), __K2L_Pair.new("log10", ____lambda_6), __K2L_Pair.new("asin", ____lambda_7), __K2L_Pair.new("acos", ____lambda_8), __K2L_Pair.new("atan", ____lambda_9), __K2L_Pair.new("sqrt", ____lambda_10), __K2L_Pair.new("cbrt", ____lambda_11), __K2L_Pair.new("sinh", ____lambda_12), __K2L_Pair.new("cosh", ____lambda_13), __K2L_Pair.new("tanh", ____lambda_14), __K2L_Pair.new("expm1", ____lambda_15), __K2L_Pair.new("log1p", ____lambda_16))
    local ____mod = unary.____modCount
    for ____i_2 = 1, unary.size do
        local ____item = unary[____i_2]
        local name, f = ____item.first, ____item.second
        line(name, edges:map(f))
        if unary.____modCount ~= ____mod and unary:____comodified(____i_2) then
            break
        end
    end
    local ____list_1 = __K2L_ReadOnlyListOf(unary:get(0), unary:get(1), unary:get(2))
    for ____i_3 = 1, ____list_1.size do
        local ____item_1 = ____list_1[____i_3]
        local name, f = ____item_1.first, ____item_1.second
        line(name .. "~1", samples(50, 2.0):map(f))
        line(name .. "~100", samples(50, 200.0):map(f))
        line(name .. "~1e6", samples(50, 2000000.0):map(f))
        line(name .. " huge", spread(80):map(f))
        line(name .. " k pi/2", __K2L_IntRange.new(1, 40):map(function(k) return f(k * k * 1.5707963267948966) end):plusAll(__K2L_IntRange.new(1, 20):map(function(k) return f(k * 100000.0 * 3.141592653589793) end)))
    end
    local ____list_2 = samples(60, 1400.0)
    local ____out_2 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_2:____array()
    for ____i_4 = 1, ____n_1 do
        local it = ____items_1[____i_4]
        ____count_1 = ____count_1 + 1
        ____out_2[____count_1] = __K2L_FdLibm.exp(it)
    end
    line("exp~", __K2L_ListWrap(____out_2, ____count_1))
    local ____list_3 = samples(60, 2.0)
    local ____out_3 = {}
    local ____count_2 = 0
    local ____items_2, ____n_2 = ____list_3:____array()
    for ____i_5 = 1, ____n_2 do
        local it = ____items_2[____i_5]
        ____count_2 = ____count_2 + 1
        ____out_3[____count_2] = __K2L_StrictMath.log(it + 1.0)
    end
    local ____arg = __K2L_ListWrap(____out_3, ____count_2)
    local ____list_4 = spread(80)
    local ____out_4 = {}
    local ____count_3 = 0
    local ____items_3, ____n_3 = ____list_4:____array()
    for ____i_6 = 1, ____n_3 do
        local it = ____items_3[____i_6]
        ____count_3 = ____count_3 + 1
        ____out_4[____count_3] = __K2L_StrictMath.log(math.abs(it))
    end
    line("log~", ____arg:plusAll(__K2L_ListWrap(____out_4, ____count_3)))
    local ____list_5 = samples(60, 2.0)
    local ____out_5 = {}
    local ____count_4 = 0
    local ____items_4, ____n_4 = ____list_5:____array()
    for ____i_7 = 1, ____n_4 do
        local it = ____items_4[____i_7]
        ____count_4 = ____count_4 + 1
        ____out_5[____count_4] = __K2L_StrictMath.log10(it + 1.0)
    end
    local ____arg_1 = __K2L_ListWrap(____out_5, ____count_4)
    local ____list_6 = spread(80)
    local ____out_6 = {}
    local ____count_5 = 0
    local ____items_5, ____n_5 = ____list_6:____array()
    for ____i_8 = 1, ____n_5 do
        local it = ____items_5[____i_8]
        ____count_5 = ____count_5 + 1
        ____out_6[____count_5] = __K2L_StrictMath.log10(math.abs(it))
    end
    local ____arg_2 = ____arg_1:plusAll(__K2L_ListWrap(____out_6, ____count_5))
    local ____list_7 = __K2L_IntRange.new(0, 22):runningFold(1.0, ____lambda_17)
    local ____out_7 = {}
    local ____count_6 = 0
    local ____items_6, ____n_6 = ____list_7:____array()
    for ____i_9 = 1, ____n_6 do
        local it = ____items_6[____i_9]
        ____count_6 = ____count_6 + 1
        ____out_7[____count_6] = __K2L_StrictMath.log10(it)
    end
    line("log10~", ____arg_2:plusAll(__K2L_ListWrap(____out_7, ____count_6)))
    local xs = samples(60, 6.0)
    local ys = samples(61, 40.0):drop(1)
    line("pow~", xs:zip(ys, ____lambda_18))
    local ____out_8 = {}
    local ____count_7 = 0
    local ____items_7, ____n_7 = xs:____array()
    for ____i_10 = 1, ____n_7 do
        local it = ____items_7[____i_10]
        ____count_7 = ____count_7 + 1
        ____out_8[____count_7] = __K2L_StrictMath.pow(-it - 3.0, 3.0)
    end
    local ____arg_3 = __K2L_ListWrap(____out_8, ____count_7)
    local ____out_9 = {}
    local ____count_8 = 0
    local ____items_8, ____n_8 = xs:____array()
    for ____i_11 = 1, ____n_8 do
        local it = ____items_8[____i_11]
        ____count_8 = ____count_8 + 1
        ____out_9[____count_8] = __K2L_StrictMath.pow(it, -2.0)
    end
    local ____arg_4 = ____arg_3:plusAll(__K2L_ListWrap(____out_9, ____count_8))
    local ____out_10 = {}
    local ____count_9 = 0
    local ____items_9, ____n_9 = xs:____array()
    for ____i_12 = 1, ____n_9 do
        local it = ____items_9[____i_12]
        ____count_9 = ____count_9 + 1
        ____out_10[____count_9] = __K2L_StrictMath.pow(it, 0.5)
    end
    line("pow neg", ____arg_4:plusAll(__K2L_ListWrap(____out_10, ____count_9)))
    local ____out_11 = {}
    local ____count_10 = 0
    local ____items_10, ____n_10 = xs:____array()
    for ____i_13 = 1, ____n_10 do
        local it = ____items_10[____i_13]
        ____count_10 = ____count_10 + 1
        ____out_11[____count_10] = __K2L_StrictMath.pow(1.0 + it * 1.0E-7, 3.0E9)
    end
    local ____arg_5 = __K2L_ListWrap(____out_11, ____count_10)
    local ____out_12 = {}
    local ____count_11 = 0
    local ____items_11, ____n_11 = xs:____array()
    for ____i_14 = 1, ____n_11 do
        local it = ____items_11[____i_14]
        ____count_11 = ____count_11 + 1
        ____out_12[____count_11] = __K2L_StrictMath.pow(math.abs(it) * 1.0E-160, 1.9)
    end
    local ____arg_6 = ____arg_5:plusAll(__K2L_ListWrap(____out_12, ____count_11))
    local ____out_13 = {}
    local ____count_12 = 0
    local ____items_12, ____n_12 = xs:____array()
    for ____i_15 = 1, ____n_12 do
        local it = ____items_12[____i_15]
        ____count_12 = ____count_12 + 1
        ____out_13[____count_12] = __K2L_StrictMath.pow(math.abs(it) + 1.0, 400.0)
    end
    local ____arg_7 = ____arg_6:plusAll(__K2L_ListWrap(____out_13, ____count_12))
    local ____out_14 = {}
    local ____count_13 = 0
    local ____items_13, ____n_13 = xs:____array()
    for ____i_16 = 1, ____n_13 do
        local it = ____items_13[____i_16]
        ____count_13 = ____count_13 + 1
        ____out_14[____count_13] = __K2L_StrictMath.pow(2.0, it * 180.0 - 1000.0)
    end
    line("pow big", ____arg_7:plusAll(__K2L_ListWrap(____out_14, ____count_13)))
    local ____list_8 = edges
    local ____out_15 = {}
    local ____count_14 = 0
    local ____items_14, ____n_14 = ____list_8:____array()
    for ____i_17 = 1, ____n_14 do
        local x = ____items_14[____i_17]
        local ____inner, ____m = __K2L_ReadOnlyListOf(__K2L_StrictMath.pow(x, 2.0), __K2L_StrictMath.pow(x, 0.5), __K2L_StrictMath.pow(x, -1.0), __K2L_StrictMath.pow(x, 3.0), __K2L_StrictMath.pow(x, -0.5), __K2L_StrictMath.pow(2.5, x), __K2L_StrictMath.pow(-2.0, x), __K2L_StrictMath.pow(x, math.huge), __K2L_StrictMath.pow(x, 1.0E300), __K2L_StrictMath.pow(x, -1.0E300), __K2L_StrictMath.pow(x, 0.0), __K2L_StrictMath.pow(x, 0.0 / 0.0)):____array()
        for ____j = 1, ____m do
            ____count_14 = ____count_14 + 1
            ____out_15[____count_14] = ____inner[____j]
        end
    end
    line("pow", __K2L_ListWrap(____out_15, ____count_14))
    local ____list_9 = edges
    local ____out_16 = {}
    local ____count_15 = 0
    local ____items_15, ____n_15 = ____list_9:____array()
    for ____i_18 = 1, ____n_15 do
        local y = ____items_15[____i_18]
        local ____inner_1, ____m_1 = __K2L_ReadOnlyListOf(__K2L_FdLibm.atan2(y, 1.0), __K2L_FdLibm.atan2(y, -2.0), __K2L_FdLibm.atan2(1.0, y)):____array()
        for ____j_1 = 1, ____m_1 do
            ____count_15 = ____count_15 + 1
            ____out_16[____count_15] = ____inner_1[____j_1]
        end
    end
    line("atan2", __K2L_ListWrap(____out_16, ____count_15))
    local ____list_10 = edges
    local ____out_17 = {}
    local ____count_16 = 0
    local ____items_16, ____n_16 = ____list_10:____array()
    for ____i_19 = 1, ____n_16 do
        local it = ____items_16[____i_19]
        ____count_16 = ____count_16 + 1
        ____out_17[____count_16] = __K2L_FdLibm.hypot(it, 3.0)
    end
    line("hypot", __K2L_ListWrap(____out_17, ____count_16))
    local ____list_11 = edges
    local ____out_18 = {}
    local ____count_17 = 0
    local ____items_17, ____n_17 = ____list_11:____array()
    for ____i_20 = 1, ____n_17 do
        local it = ____items_17[____i_20]
        ____count_17 = ____count_17 + 1
        ____out_18[____count_17] = __K2L_Num.IEEErem(it, 3.0)
    end
    local ____arg_8 = __K2L_ListWrap(____out_18, ____count_17)
    local ____list_12 = edges
    local ____out_19 = {}
    local ____count_18 = 0
    local ____items_18, ____n_18 = ____list_12:____array()
    for ____i_21 = 1, ____n_18 do
        local it = ____items_18[____i_21]
        ____count_18 = ____count_18 + 1
        ____out_19[____count_18] = __K2L_Num.IEEErem(1.0E300, it)
    end
    line("IEEEremainder", ____arg_8:plusAll(__K2L_ListWrap(____out_19, ____count_18)))
    line("2^k", __K2L_IntRange.new(-1074, 1023):withStep(13):map(____lambda_19):plusAll(__K2L_ReadOnlyListOf(2.0 ^ 710, 2.0 ^ (-1073), 2.0 ^ (-1060))))
    local plain = __K2L_ReadOnlyListOf(1.5, 2.5, -3.7, 1.0E17, 0.49999999999999994, 123.456, -1.0E-5, 7.0)
    local ____out_20 = {}
    local ____count_19 = 0
    local ____items_19, ____n_19 = plain:____array()
    for ____i_22 = 1, ____n_19 do
        local it = ____items_19[____i_22]
        local ____inner_2, ____m_2 = __K2L_ReadOnlyListOf(it == 0 and it * 1.0 or math.floor(it) + 0.0, __K2L_Num.ceil(it), __K2L_Num.round(it)):____array()
        for ____j_2 = 1, ____m_2 do
            ____count_19 = ____count_19 + 1
            ____out_20[____count_19] = ____inner_2[____j_2]
        end
    end
    line("floor ceil rint", __K2L_ListWrap(____out_20, ____count_19))
    local ____out_21 = {}
    local ____count_20 = 0
    local ____items_20, ____n_20 = plain:____array()
    for ____i_23 = 1, ____n_20 do
        local it = ____items_20[____i_23]
        local ____inner_3, ____m_3 = __K2L_ReadOnlyListOf(math.abs(it), __K2L_Num.signDouble(it), __K2L_Bits.ulp(it), it * 0.017453292519943295, it * 57.29577951308232):____array()
        for ____j_3 = 1, ____m_3 do
            ____count_20 = ____count_20 + 1
            ____out_21[____count_20] = ____inner_3[____j_3]
        end
    end
    line("abs signum ulp", __K2L_ListWrap(____out_21, ____count_20))
    local ____out_22 = {}
    local ____count_21 = 0
    local ____items_21, ____n_21 = plain:____array()
    for ____i_24 = 1, ____n_21 do
        local it = ____items_21[____i_24]
        local ____inner_4, ____m_4 = __K2L_ReadOnlyListOf(__K2L_Num.maxD(it, 2.0), __K2L_Num.minD(it, 2.0)):____array()
        for ____j_4 = 1, ____m_4 do
            ____count_21 = ____count_21 + 1
            ____out_22[____count_21] = ____inner_4[____j_4]
        end
    end
    line("max min", __K2L_ListWrap(____out_22, ____count_21))
    print("ints: " .. math.abs(-7) .. " " .. math.max(3, 9) .. " " .. math.min(3, -9) .. " " .. __K2L_Num.mod(-7, 3) .. " " .. __K2L_FloorDiv(-7, 3) .. " " .. __K2L_Num.roundToLong(2.5) .. " " .. __K2L_Num.roundToLong(-2.5) .. " " .. __K2L_Exact.add(2, 3))
end

__K2L_Main(main)
return {edges = edges, line = line, samples = samples, spread = spread}
