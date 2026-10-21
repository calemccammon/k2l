local ____lualib = require("lualib_bundle")
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_JavaLongs = ____lualib.__K2L_JavaLongs
local __K2L_JavaNumbers = ____lualib.__K2L_JavaNumbers
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
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

local ____lambda_1 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaLongs.compareUnsigned(-1, 1), __K2L_JavaLongs.compareUnsigned(-9223372036854775807 - 1, 9223372036854775807), __K2L_JavaLongs.compareUnsigned(1, -2))
end
local ____lambda_2 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaLongs.divideUnsigned(-1, 10), __K2L_JavaLongs.divideUnsigned(-1, -2), __K2L_JavaLongs.remainderUnsigned(-1, 10))
end
local ____lambda_3 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaLongs.toUnsignedString(-1), __K2L_JavaLongs.toUnsignedString(-9223372036854775807 - 1, 16), #__K2L_JavaLongs.toUnsignedString(-2, 2))
end
local ____lambda_4 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaLongs.parseUnsigned("18446744073709551615"), __K2L_JavaLongs.parseUnsigned("9223372036854775808"), __K2L_JavaLongs.parseUnsigned("ffffffffffffffff", 16))
end
local ____lambda_5 = function()
    return __K2L_JavaLongs.parseUnsigned("18446744073709551616")
end
local ____lambda_6 = function() return __K2L_JavaLongs.parseUnsigned("-1") end
local ____lambda_7 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.decode("0x7fffffffffffffff", true), __K2L_JavaNumbers.decode("-0x8000000000000000", true), __K2L_JavaNumbers.decode("-9223372036854775808", true), __K2L_JavaNumbers.decode("#123456789abcdef", true))
end
local ____lambda_8 = function()
    return __K2L_JavaNumbers.decode("0x8000000000000000", true)
end
local ____lambda_9 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.reverseLong(1), __K2L_JavaNumbers.reverseLong(-2), __K2L_JavaNumbers.reverseLong(81985529216486895))
end
local ____lambda_10 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.reverseBytesLong(1), __K2L_JavaNumbers.reverseBytesLong(81985529216486895), __K2L_JavaNumbers.reverseBytesLong(-256))
end
local ____lambda_11 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.compressLong(-1, -9223372036854775807 - 1 | 1), __K2L_JavaNumbers.compressLong(81985529216486895, -256), __K2L_JavaNumbers.compressLong(-9223372036854775807 - 1, -9223372036854775807 - 1))
end
local ____lambda_12 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.expandLong(3, -9223372036854775807 - 1 | 1), __K2L_JavaNumbers.expandLong(-1, 71776119061282560), __K2L_JavaNumbers.expandLong(5, -16))
end
local ____lambda_13 = function()
    return __K2L_JavaNumbers.toUnsignedLong(-2) + 1
end
local ____lambda_14 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaLongs.ceilDiv(9223372036854775807, 2), __K2L_JavaLongs.ceilDiv(-9223372036854775807 - 1, 3), __K2L_JavaLongs.ceilDiv(-9223372036854775807 - 1, -1), __K2L_JavaLongs.ceilDiv(-9007199254740993, 2))
end
local ____lambda_15 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaLongs.ceilMod(9223372036854775807, 10), __K2L_JavaLongs.ceilMod(-9223372036854775807 - 1, 7), __K2L_JavaLongs.ceilMod(9223372036854775807, 7))
end
local ____lambda_16 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaLongs.divideExact(9223372036854775807, -1), __K2L_JavaLongs.divideExact(-9223372036854775807 - 1, 2), __K2L_JavaLongs.floorDivExact(-9223372036854775807 - 1 + 1, 2), __K2L_JavaLongs.ceilDivExact(9223372036854775807, 3))
end
local ____lambda_17 = function()
    return __K2L_JavaLongs.divideExact(-9223372036854775807 - 1, -1)
end
local ____lambda_18 = function()
    return __K2L_JavaLongs.ceilDivExact(-9223372036854775807 - 1, -1)
end
local ____lambda_19 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaLongs.clamp(9223372036854775807, -9223372036854775807 - 1, 5), __K2L_JavaLongs.clamp(-9223372036854775807 - 1, -1, 1), __K2L_JavaLongs.clamp(9223372036854775807, 0, 9), __K2L_JavaLongs.clamp(9007199254740993, 0, 9223372036854775807))
end
local ____lambda_20 = function()
    return __K2L_JavaLongs.clamp(0, 9223372036854775807, -9223372036854775807 - 1)
end
local ____lambda_21 = function()
    return __K2L_ReadOnlyListOf(2147483647 * 2147483647, -2147483648 * (-2147483648), -2147483648 * 2147483647)
end
local ____lambda_22 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.multiplyHigh(9223372036854775807, 9223372036854775807), __K2L_JavaNumbers.multiplyHigh(-9223372036854775807 - 1, -9223372036854775807 - 1), __K2L_JavaNumbers.multiplyHigh(-9223372036854775807 - 1, 9223372036854775807), __K2L_JavaNumbers.multiplyHigh(-1, -1), __K2L_JavaNumbers.multiplyHigh(-1, 1))
end
local ____lambda_23 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.unsignedMultiplyHigh(-1, -1), __K2L_JavaNumbers.unsignedMultiplyHigh(-9223372036854775807 - 1, 2), __K2L_JavaNumbers.unsignedMultiplyHigh(81985529216486895, -81985529216486895))
end
local function main()
    t("compareUnsigned", ____lambda_1)
    t("divideUnsigned", ____lambda_2)
    t("toUnsignedString", ____lambda_3)
    t("parseUnsignedLong", ____lambda_4)
    t("parseUnsignedLong range", ____lambda_5)
    t("parseUnsignedLong minus", ____lambda_6)
    t("decode", ____lambda_7)
    t("decode range", ____lambda_8)
    t("reverse", ____lambda_9)
    t("reverseBytes", ____lambda_10)
    t("compress", ____lambda_11)
    t("expand", ____lambda_12)
    t("toUnsignedLong", ____lambda_13)
    t("ceilDiv", ____lambda_14)
    t("ceilMod", ____lambda_15)
    t("divideExact", ____lambda_16)
    t("divideExact overflow", ____lambda_17)
    t("ceilDivExact overflow", ____lambda_18)
    t("clamp", ____lambda_19)
    t("clamp reversed", ____lambda_20)
    t("multiplyFull", ____lambda_21)
    t("multiplyHigh", ____lambda_22)
    t("unsignedMultiplyHigh", ____lambda_23)
end

__K2L_DeepMain(main)
return {t = t}
