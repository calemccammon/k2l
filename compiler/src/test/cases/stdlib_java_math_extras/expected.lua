local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_DoubleToString = ____lualib.__K2L_DoubleToString
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_FloatToString = ____lualib.__K2L_FloatToString
local __K2L_Fround = ____lualib.__K2L_Fround
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_JavaLongs = ____lualib.__K2L_JavaLongs
local __K2L_JavaNumbers = ____lualib.__K2L_JavaNumbers
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function t(label, f)
    local ____ok, ____result = __K2L_DeepPcall(function()
        print(label .. " = " .. __K2L_Str(f()))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_Exception) then
            local e = ____error
            print(label .. " EXC " .. __K2L_Str(__K2L_KClassOfValue(e).simpleName) .. ": " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
end

local function d(...)
    local xs = __K2L_ArrayOf(...)
    return xs:joinToString(nil, "[", "]", nil, nil, __K2L_DoubleToString)
end

local function fl(...)
    local xs = __K2L_ArrayOf(...)
    return xs:joinToString(nil, "[", "]", nil, nil, __K2L_FloatToString)
end

local ____lambda_1 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.ceilDiv(7, 2), __K2L_JavaNumbers.ceilDiv(-7, 2), __K2L_JavaNumbers.ceilDiv(7, -2), __K2L_JavaNumbers.ceilDiv(-7, -2), __K2L_JavaNumbers.ceilDiv(6, 3), __K2L_JavaNumbers.ceilDiv(-2147483648, -1))
end
local ____lambda_2 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaLongs.ceilDiv(7, 2), __K2L_JavaLongs.ceilDiv(-7, 2), __K2L_JavaLongs.ceilDiv(10000000001, 10), __K2L_JavaLongs.ceilDiv(9, 4))
end
local ____lambda_3 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.ceilMod(7, 2), __K2L_JavaNumbers.ceilMod(-7, 2), __K2L_JavaNumbers.ceilMod(7, -2), __K2L_JavaNumbers.ceilMod(-7, -2), __K2L_JavaNumbers.ceilMod(6, 3))
end
local ____lambda_4 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaLongs.ceilMod(7, 2), __K2L_JavaLongs.ceilMod(-7, 3), __K2L_JavaLongs.ceilMod(9, 4))
end
local ____lambda_5 = function() return __K2L_JavaNumbers.ceilDiv(1, 0) end
local ____lambda_6 = function() return __K2L_JavaLongs.ceilDiv(1, 0) end
local ____lambda_7 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.divideExact(7, 2), __K2L_JavaNumbers.divideExact(-7, 2), __K2L_JavaLongs.divideExact(7, -2), __K2L_JavaLongs.divideExact(-9, -2))
end
local ____lambda_8 = function()
    return __K2L_JavaNumbers.divideExact(-2147483648, -1)
end
local ____lambda_9 = function()
    return __K2L_JavaLongs.divideExact(-9223372036854775807 - 1, -1)
end
local ____lambda_10 = function() return __K2L_JavaNumbers.divideExact(3, 0) end
local ____lambda_11 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.floorDivExact(-7, 2), __K2L_JavaNumbers.floorDivExact(7, -2), __K2L_JavaLongs.floorDivExact(-7, 2))
end
local ____lambda_12 = function()
    return __K2L_JavaNumbers.floorDivExact(-2147483648, -1)
end
local ____lambda_13 = function()
    return __K2L_JavaLongs.floorDivExact(-9223372036854775807 - 1, -1)
end
local ____lambda_14 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.ceilDivExact(-7, 2), __K2L_JavaNumbers.ceilDivExact(7, 2), __K2L_JavaLongs.ceilDivExact(7, 2))
end
local ____lambda_15 = function()
    return __K2L_JavaNumbers.ceilDivExact(-2147483648, -1)
end
local ____lambda_16 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaLongs.clamp(5, 1, 10), __K2L_JavaLongs.clamp(-5, 1, 10), __K2L_JavaLongs.clamp(50, 1, 10), __K2L_JavaLongs.clamp(3000000000, 0, 2147483647))
end
local ____lambda_17 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaLongs.clamp(5, 1, 10), __K2L_JavaLongs.clamp(-5, 1, 10), __K2L_JavaLongs.clamp(50000000000, 1, 10000000000))
end
local ____lambda_18 = function()
    return d(__K2L_JavaNumbers.clampD(1.5, 0.0, 1.0, __K2L_DoubleToString), __K2L_JavaNumbers.clampD(-1.5, 0.0, 1.0, __K2L_DoubleToString), __K2L_JavaNumbers.clampD(0.25, 0.0, 1.0, __K2L_DoubleToString), __K2L_JavaNumbers.clampD(0.0 / 0.0, 0.0, 1.0, __K2L_DoubleToString), __K2L_JavaNumbers.clampD(-0.0, 0.0, 1.0, __K2L_DoubleToString), __K2L_JavaNumbers.clampD(0.0, -0.0, 0.0, __K2L_DoubleToString))
end
local ____lambda_19 = function()
    return fl(__K2L_JavaNumbers.clampD(2.5, 0.0, 1.0, __K2L_FloatToString), __K2L_JavaNumbers.clampD(0.10000000149011612, 0.0, 1.0, __K2L_FloatToString), __K2L_JavaNumbers.clampD(-3.0, -2.0, 2.0, __K2L_FloatToString))
end
local ____lambda_20 = function() return __K2L_JavaLongs.clamp(5, 10, 1) end
local ____lambda_21 = function() return __K2L_JavaLongs.clamp(5, 10, 1) end
local ____lambda_22 = function()
    return __K2L_JavaNumbers.clampD(5.0, 2.5, 1.0, __K2L_DoubleToString)
end
local ____lambda_23 = function()
    return __K2L_JavaNumbers.clampD(5.0, 0.0, -0.0, __K2L_DoubleToString)
end
local ____lambda_24 = function()
    return __K2L_JavaNumbers.clampD(5.0, 0.10000000149011612, 0.05000000074505806, __K2L_FloatToString)
end
local ____lambda_25 = function()
    return __K2L_JavaNumbers.clampD(5.0, 0.0 / 0.0, 1.0, __K2L_DoubleToString)
end
local ____lambda_26 = function()
    return __K2L_JavaNumbers.clampD(5.0, 1.0, 0.0 / 0.0, __K2L_DoubleToString)
end
local ____lambda_27 = function()
    return d(__K2L_JavaNumbers.fma(2.0, 3.0, 4.0), __K2L_JavaNumbers.fma(0.1, 10.0, -1.0), __K2L_JavaNumbers.fma(1.0 + 1.0E-15, 1.0 - 1.0E-15, -1.0), __K2L_JavaNumbers.fma(-0.0, 1.0, 0.0), __K2L_JavaNumbers.fma(math.huge, 0.0, 1.0))
end
local ____lambda_28 = function()
    return fl(__K2L_Fround(__K2L_JavaNumbers.fma(2.0, 3.0, 4.0)), __K2L_Fround(__K2L_JavaNumbers.fma(0.10000000149011612, 10.0, -1.0)), __K2L_Fround(__K2L_JavaNumbers.fma(1.5, 1.5, 0.25)))
end
local ____lambda_29 = function() return __K2L_DoubleToString(0.1 * 10.0 - 1.0) end
local ____lambda_30 = function()
    return d(__K2L_JavaNumbers.scalb(1.0, 10), __K2L_JavaNumbers.scalb(3.0, -1), __K2L_JavaNumbers.scalb(1.0, 1024), __K2L_JavaNumbers.scalb(1.0, -1074), __K2L_JavaNumbers.scalb(1.0, -1075), __K2L_JavaNumbers.scalb(1.7976931348623157E308, -2000), __K2L_JavaNumbers.scalb(1.5, -1073), __K2L_JavaNumbers.scalb(-0.0, 5))
end
local ____lambda_31 = function()
    return fl(__K2L_Fround(__K2L_JavaNumbers.scalbF(1.0, 10)), __K2L_Fround(__K2L_JavaNumbers.scalbF(3.0, -2)), __K2L_Fround(__K2L_JavaNumbers.scalbF(1.0, 128)), __K2L_Fround(__K2L_JavaNumbers.scalbF(1.0, -149)), __K2L_Fround(__K2L_JavaNumbers.scalbF(1.0, -150)), __K2L_Fround(__K2L_JavaNumbers.scalbF(1.0, 300)))
end
local ____lambda_32 = function()
    return __K2L_ReadOnlyListOf(100000 * 100000, -46341 * 46341, 7 * -6)
end
local ____lambda_33 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.multiplyHigh(1 << 40, 1 << 40), __K2L_JavaNumbers.multiplyHigh(-(1 << 40), 1 << 40), __K2L_JavaNumbers.multiplyHigh(3, 5), __K2L_JavaNumbers.multiplyHigh(-3, 5))
end
local ____lambda_34 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.unsignedMultiplyHigh(1 << 40, 1 << 40), __K2L_JavaNumbers.unsignedMultiplyHigh(3, 5), __K2L_JavaNumbers.unsignedMultiplyHigh(-3, 5))
end
local ____lambda_35 = function()
    return __K2L_JavaNumbers.ceilDiv(7, 2) .. " " .. __K2L_DoubleToString(__K2L_JavaNumbers.scalb(1.0, 3)) .. " " .. __K2L_JavaNumbers.getExponent(8.0)
end
local function main()
    t("ceilDiv", ____lambda_1)
    t("ceilDiv long", ____lambda_2)
    t("ceilMod", ____lambda_3)
    t("ceilMod long", ____lambda_4)
    t("ceilDiv zero", ____lambda_5)
    t("ceilDiv long zero", ____lambda_6)
    t("divideExact", ____lambda_7)
    t("divideExact overflow", ____lambda_8)
    t("divideExact long overflow", ____lambda_9)
    t("divideExact zero", ____lambda_10)
    t("floorDivExact", ____lambda_11)
    t("floorDivExact overflow", ____lambda_12)
    t("floorDivExact long overflow", ____lambda_13)
    t("ceilDivExact", ____lambda_14)
    t("ceilDivExact overflow", ____lambda_15)
    t("clamp int", ____lambda_16)
    t("clamp long", ____lambda_17)
    t("clamp double", ____lambda_18)
    t("clamp float", ____lambda_19)
    t("clamp reversed", ____lambda_20)
    t("clamp long reversed", ____lambda_21)
    t("clamp double reversed", ____lambda_22)
    t("clamp zeros", ____lambda_23)
    t("clamp float reversed", ____lambda_24)
    t("clamp NaN min", ____lambda_25)
    t("clamp NaN max", ____lambda_26)
    t("fma", ____lambda_27)
    t("fma float", ____lambda_28)
    t("fma vs plain", ____lambda_29)
    t("getExponent", function()
        local ____list = __K2L_ReadOnlyListOf(1.0, 2.0, 3.99, 0.5, 1.0E-300, 1.0E300, 0.0, 4.9E-324, 2.2250738585072014E-308, 0.0 / 0.0, -math.huge, -1024.0)
        local ____out = {}
        local ____count = 0
        local ____items, ____n = ____list:____array()
        for ____i = 1, ____n do
            local it = ____items[____i]
            ____count = ____count + 1
            ____out[____count] = __K2L_JavaNumbers.getExponent(it)
        end
        return __K2L_ListWrap(____out, ____count)
    end)
    t("getExponent float", function()
        local ____list_1 = __K2L_ReadOnlyListOf(1.0, 3.0, 0.10000000149011612, 0.0, 1.401298464324817E-45, 1.1754943508222875E-38, 3.4028234663852886E38, 0.0 / 0.0)
        local ____out_1 = {}
        local ____count_1 = 0
        local ____items_1, ____n_1 = ____list_1:____array()
        for ____i_1 = 1, ____n_1 do
            local it = ____items_1[____i_1]
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = __K2L_JavaNumbers.getExponent(it, true)
        end
        return __K2L_ListWrap(____out_1, ____count_1)
    end)
    t("scalb", ____lambda_30)
    t("scalb float", ____lambda_31)
    t("multiplyFull", ____lambda_32)
    t("multiplyHigh", ____lambda_33)
    t("unsignedMultiplyHigh", ____lambda_34)
    t("StrictMath", ____lambda_35)
end

__K2L_DeepMain(main)
return {t = t, d = d, fl = fl}
