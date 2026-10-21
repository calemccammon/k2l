local ____lualib = require("lualib_bundle")
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Extras = ____lualib.__K2L_Extras
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_JavaLongs = ____lualib.__K2L_JavaLongs
local __K2L_JavaNumbers = ____lualib.__K2L_JavaNumbers
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
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
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.compareUnsigned(1, 2), __K2L_JavaNumbers.compareUnsigned(-1, 2), __K2L_JavaNumbers.compareUnsigned(5, 5), __K2L_JavaNumbers.compareUnsigned(0, -2147483648))
end
local ____lambda_2 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.divideUnsigned(-1, 2), __K2L_JavaNumbers.divideUnsigned(-2, -1), __K2L_JavaNumbers.divideUnsigned(7, 2), __K2L_JavaNumbers.divideUnsigned(-7, 1000))
end
local ____lambda_3 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.remainderUnsigned(-1, 10), __K2L_JavaNumbers.remainderUnsigned(7, 3), __K2L_JavaNumbers.remainderUnsigned(-1, -2))
end
local ____lambda_4 = function() return __K2L_JavaNumbers.divideUnsigned(1, 0) end
local ____lambda_5 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.toUnsignedLong(-1), __K2L_JavaNumbers.toUnsignedLong(5), __K2L_JavaNumbers.toUnsignedLong(-2147483648))
end
local ____lambda_6 = function()
    return __K2L_ReadOnlyListOf(__K2L_Num.toRadixUnsigned(-1, 10), __K2L_Num.toRadixUnsigned(-16, 16), __K2L_Num.toRadixUnsigned(42, 10))
end
local ____lambda_7 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.parseUnsignedInt("4294967295"), __K2L_JavaNumbers.parseUnsignedInt("+17"), __K2L_JavaNumbers.parseUnsignedInt("ff", 16), __K2L_JavaNumbers.parseUnsignedInt("2147483648"))
end
local ____lambda_8 = function()
    return __K2L_JavaNumbers.parseUnsignedInt("-1")
end
local ____lambda_9 = function()
    return __K2L_JavaNumbers.parseUnsignedInt("4294967296")
end
local ____lambda_10 = function()
    return __K2L_JavaNumbers.parseUnsignedInt("12x")
end
local ____lambda_11 = function()
    return __K2L_JavaNumbers.parseUnsignedInt("zz", 16)
end
local ____lambda_12 = function() return __K2L_JavaNumbers.parseUnsignedInt("") end
local ____lambda_13 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.decode("42"), __K2L_JavaNumbers.decode("-0x1F"), __K2L_JavaNumbers.decode("#ff"), __K2L_JavaNumbers.decode("010"), __K2L_JavaNumbers.decode("+0X10"), __K2L_JavaNumbers.decode("0"), __K2L_JavaNumbers.decode("-2147483648"))
end
local ____lambda_14 = function() return __K2L_JavaNumbers.decode("") end
local ____lambda_15 = function() return __K2L_JavaNumbers.decode("0x-5") end
local ____lambda_16 = function() return __K2L_JavaNumbers.decode("0xZZ") end
local ____lambda_17 = function() return __K2L_JavaNumbers.decode("09") end
local ____lambda_18 = function() return __K2L_JavaNumbers.decode("2147483648") end
local ____lambda_19 = function() return __K2L_JavaNumbers.decode("-") end
local ____lambda_20 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.reverseBytes(305419896), __K2L_JavaNumbers.reverseBytes(1), __K2L_JavaNumbers.reverseBytes(-1), __K2L_JavaNumbers.reverseBytes(255))
end
local ____lambda_21 = function()
    return __K2L_ReadOnlyListOf(__K2L_Num.reverseInt(1), __K2L_Num.reverseInt(252645135), __K2L_Num.reverseInt(-2))
end
local ____lambda_22 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.compress(__K2L_ToInt32(3405691582), __K2L_ToInt32(4278255600)), __K2L_JavaNumbers.compress(11, 6), __K2L_JavaNumbers.compress(-1, -1), __K2L_JavaNumbers.compress(5, 0))
end
local ____lambda_23 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.expand(__K2L_ToInt32(3405691582), __K2L_ToInt32(4278255600)), __K2L_JavaNumbers.expand(3, 6), __K2L_JavaNumbers.expand(-1, 127))
end
local ____lambda_24 = function() return __K2L_ReadOnlyListOf(3 + 4, 5 + 6) end
local ____lambda_25 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.property("k2l.none", nil), __K2L_JavaNumbers.property("k2l.none", 7), __K2L_JavaNumbers.property("k2l.none", nil), __K2L_JavaNumbers.property("k2l.none", 8), __K2L_JavaNumbers.property("k2l.none", false))
end
local ____lambda_26 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaLongs.compareUnsigned(1, 2), __K2L_JavaLongs.compareUnsigned(-1, 2), __K2L_JavaLongs.compareUnsigned(3, 3))
end
local ____lambda_27 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaLongs.divideUnsigned(100, 7), __K2L_JavaLongs.remainderUnsigned(100, 7))
end
local ____lambda_28 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaLongs.toUnsignedString(12345), __K2L_JavaLongs.toUnsignedString(255, 2))
end
local ____lambda_29 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaLongs.parseUnsigned("123456789012"), __K2L_JavaLongs.parseUnsigned("ff", 16))
end
local ____lambda_30 = function() return __K2L_JavaLongs.parseUnsigned("-5") end
local ____lambda_31 = function() return __K2L_JavaLongs.parseUnsigned("5q") end
local ____lambda_32 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.decode("0x7fffffff", true), __K2L_JavaNumbers.decode("-#10", true), __K2L_JavaNumbers.decode("0777", true), __K2L_JavaNumbers.decode("123456789012", true))
end
local ____lambda_33 = function() return __K2L_JavaNumbers.decode("#g", true) end
local ____lambda_34 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.reverseBytesLong(256), __K2L_JavaNumbers.reverseBytesLong(4328719365))
end
local ____lambda_35 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.reverseLong(1 << 20), __K2L_JavaNumbers.reverseLong(1 << 63))
end
local ____lambda_36 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.compressLong(61680, 65280), __K2L_JavaNumbers.compressLong(4886718345, 64424509455))
end
local ____lambda_37 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaNumbers.expandLong(171, 61680), __K2L_JavaNumbers.expandLong(63, 4294967299))
end
local ____lambda_38 = function()
    return __K2L_ReadOnlyListOf(("a"):byte() - ("b"):byte(), ("z"):byte() - ("a"):byte(), ("q"):byte() - ("q"):byte())
end
local ____lambda_39 = function()
    return __K2L_ReadOnlyListOf(__K2L_Extras.isISOControl(("\n"):byte()), __K2L_Extras.isISOControl(("a"):byte()), __K2L_Extras.isISOControl(("\127"):byte()))
end
local function main()
    t("compareUnsigned", ____lambda_1)
    t("divideUnsigned", ____lambda_2)
    t("remainderUnsigned", ____lambda_3)
    t("divideUnsigned zero", ____lambda_4)
    t("toUnsignedLong", ____lambda_5)
    t("toUnsignedString", ____lambda_6)
    t("parseUnsignedInt", ____lambda_7)
    t("parseUnsignedInt minus", ____lambda_8)
    t("parseUnsignedInt range", ____lambda_9)
    t("parseUnsignedInt digits", ____lambda_10)
    t("parseUnsignedInt radix", ____lambda_11)
    t("parseUnsignedInt empty", ____lambda_12)
    t("decode", ____lambda_13)
    t("decode empty", ____lambda_14)
    t("decode sign", ____lambda_15)
    t("decode digits", ____lambda_16)
    t("decode octal", ____lambda_17)
    t("decode range", ____lambda_18)
    t("decode minus", ____lambda_19)
    t("reverseBytes", ____lambda_20)
    t("reverse", ____lambda_21)
    t("compress", ____lambda_22)
    t("expand", ____lambda_23)
    t("sum", ____lambda_24)
    t("getInteger", ____lambda_25)
    t("Long compareUnsigned", ____lambda_26)
    t("Long divideUnsigned", ____lambda_27)
    t("Long toUnsignedString", ____lambda_28)
    t("parseUnsignedLong", ____lambda_29)
    t("parseUnsignedLong minus", ____lambda_30)
    t("parseUnsignedLong digits", ____lambda_31)
    t("Long decode", ____lambda_32)
    t("Long decode digits", ____lambda_33)
    t("Long reverseBytes", ____lambda_34)
    t("Long reverse", ____lambda_35)
    t("Long compress", ____lambda_36)
    t("Long expand", ____lambda_37)
    t("Character.compare", ____lambda_38)
    t("Character.isISOControl", ____lambda_39)
    t("Double.toHexString", function()
        local ____list = __K2L_ReadOnlyListOf(1.0, -2.5, 0.1, 0.0, -0.0, 1.7976931348623157E308, 4.9E-324, 3.0E-310, 0.0 / 0.0, math.huge, 1.0E100)
        local ____out = {}
        local ____count = 0
        local ____items, ____n = ____list:____array()
        for ____i = 1, ____n do
            local it = ____items[____i]
            ____count = ____count + 1
            ____out[____count] = __K2L_JavaNumbers.toHexString(it)
        end
        return __K2L_ListWrap(____out, ____count)
    end)
end

__K2L_DeepMain(main)
return {t = t}
