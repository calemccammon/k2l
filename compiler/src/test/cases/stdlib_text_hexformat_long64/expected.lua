local ____lualib = require("lualib_bundle")
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_HexFormat = ____lualib.__K2L_HexFormat
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf

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
    return __K2L_SingletonListOf(__K2L_HexFormat.number(11259375, 32, __K2L_HexFormat.build(function(____this_5)
        ____this_5.upperCase = true
        local ____object_5 = ____this_5.number
        ____object_5.removeLeadingZeros = true
    end)))
end
local function main()
    local data = __K2L_TypedArrayOf("[B", 0, 1, 15, 16, 127, -128, -1, 42, 7, 100)
    t("default", function()
        return __K2L_ReadOnlyListOf(__K2L_HexFormat.number(255, 32, __K2L_HexFormat.Default), __K2L_HexFormat.bytes(data, nil, nil, __K2L_HexFormat.Default))
    end)
    t("upper", function()
        return __K2L_ReadOnlyListOf(__K2L_HexFormat.number(255, 32, __K2L_HexFormat.UpperCase), __K2L_HexFormat.bytes(data, nil, nil, __K2L_HexFormat.UpperCase), __K2L_HexFormat.UpperCase.upperCase)
    end)
    local spaced = __K2L_HexFormat.build(function(self)
        self.upperCase = true
        __K2L_HexFormat.configure(self.bytes, function(____this)
            ____this.byteSeparator = " "
            ____this.bytesPerLine = 4
        end)
    end)
    t("spaced", function()
        return __K2L_HexFormat.bytes(data, nil, nil, spaced)
    end)
    t("spaced props", function()
        return __K2L_ReadOnlyListOf(spaced.upperCase, spaced.bytes.byteSeparator, spaced.bytes.bytesPerLine, spaced.bytes.bytesPerGroup)
    end)
    local grouped = __K2L_HexFormat.build(function(____this_1)
        local ____object = ____this_1.bytes
        ____object.bytesPerGroup = 2
        local ____object_1 = ____this_1.bytes
        ____object_1.groupSeparator = " | "
        local ____object_2 = ____this_1.bytes
        ____object_2.bytePrefix = "0x"
        local ____object_3 = ____this_1.bytes
        ____object_3.byteSuffix = ","
    end)
    t("grouped", function()
        return __K2L_HexFormat.bytes(data, nil, nil, grouped)
    end)
    t("grouped parse", function()
        return __K2L_HexFormat.parseBytes("0x00,0x01, | 0x0f,0x10,", grouped):toList()
    end)
    t("spaced parse", function()
        return __K2L_HexFormat.parseBytes("00 01 0F 10\n7F 80", spaced):toList()
    end)
    t("range", function()
        return __K2L_HexFormat.bytes(data, 2, 5, spaced)
    end)
    local numeric = __K2L_HexFormat.build(function(____this_2)
        __K2L_HexFormat.configure(____this_2.number, function(____this_3)
            ____this_3.prefix = "0x"
            ____this_3.suffix = "h"
            ____this_3.removeLeadingZeros = true
        end)
    end)
    t("number", function()
        return __K2L_ReadOnlyListOf(__K2L_HexFormat.number(255, 32, numeric), __K2L_HexFormat.number(0, 32, numeric), __K2L_HexFormat.number(-1, 64, numeric), __K2L_HexFormat.number(__K2L_Num.toByte(10), 8, numeric))
    end)
    t("number props", function()
        return __K2L_ReadOnlyListOf(numeric.number.prefix, numeric.number.suffix, numeric.number.removeLeadingZeros, numeric.number.minLength)
    end)
    t("number parse", function()
        return __K2L_ReadOnlyListOf(__K2L_HexFormat.parseNumber("0xffh", 32, numeric), __K2L_HexFormat.parseNumber("0x1h", 64, numeric), __K2L_HexFormat.parseNumber("0x7fh", 8, numeric))
    end)
    t("number parse bad", function()
        return __K2L_HexFormat.parseNumber("ff", 32, numeric)
    end)
    local padded = __K2L_HexFormat.build(function(____this_4)
        local ____object_4 = ____this_4.number
        ____object_4.minLength = 6
    end)
    t("minLength", function()
        return __K2L_ReadOnlyListOf(__K2L_HexFormat.number(255, 32, padded), __K2L_HexFormat.number(19088743, 32, padded), __K2L_HexFormat.number(__K2L_Num.toShort(5), 16, padded))
    end)
    t("upper number", ____lambda_1)
end

__K2L_DeepMain(main)
return {t = t}
