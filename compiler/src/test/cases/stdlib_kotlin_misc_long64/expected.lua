local ____lualib = require("lualib_bundle")
local __K2L_Bits = ____lualib.__K2L_Bits
local __K2L_CharRange = ____lualib.__K2L_CharRange
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_DeprecationLevel = ____lualib.__K2L_DeprecationLevel
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Fmod = ____lualib.__K2L_Fmod
local __K2L_Fround = ____lualib.__K2L_Fround
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IRem = ____lualib.__K2L_IRem
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_KotlinVersion = ____lualib.__K2L_KotlinVersion
local __K2L_LazyThreadSafetyMode = ____lualib.__K2L_LazyThreadSafetyMode
local __K2L_ListBuilderOf = ____lualib.__K2L_ListBuilderOf
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf
local __K2L_Unsigned = ____lualib.__K2L_Unsigned

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
    return __K2L_KotlinVersion.new(1, 2, 3):hashCode()
end
local ____lambda_2 = function() return __K2L_KotlinVersion.new(1, 300) end
local ____lambda_3 = function()
    return __K2L_ReadOnlyListOf(__K2L_KotlinVersion.new(2, 0), __K2L_KotlinVersion.new(1, 9, 22), __K2L_KotlinVersion.new(1, 10)):sorted()
end
local ____lambda_4 = function()
    return __K2L_ReadOnlyListOf(__K2L_IDiv(17, 5), math.fmod(17, 5), __K2L_IDiv(4000000000, 3), math.fmod(4000000000, 7))
end
local ____lambda_5 = function()
    return __K2L_ReadOnlyListOf(__K2L_IDiv(200 & 0xFF, 7 & 0xFF), 7 & 0xFF ~= 0 and __K2L_Fmod(200 & 0xFF, 7 & 0xFF) + 0 or __K2L_IRem(200 & 0xFF, 7 & 0xFF), 7 & 0xFFFF ~= 0 and __K2L_Fmod(60000 & 0xFFFF, 7 & 0xFFFF) + 0 or __K2L_IRem(60000 & 0xFFFF, 7 & 0xFFFF))
end
local ____lambda_6 = function()
    return __K2L_ReadOnlyListOf(__K2L_Unsigned.udiv(100, 7), __K2L_Unsigned.urem(100, 7))
end
local ____lambda_7 = function() return __K2L_IntRange.new(0, 3 - 1):toList() end
local ____lambda_8 = function() return __K2L_IntRange.new(2, 4 - 1):toList() end
local ____lambda_9 = function()
    return __K2L_IntRange.new(250 & 0xFF, 255 & 0xFF):toList()
end
local ____lambda_10 = function()
    return __K2L_IntRange.new(1 & 0xFFFF, (3 & 0xFFFF) - 1):toList()
end
local ____lambda_11 = function()
    return __K2L_ReadOnlyListOf(__K2L_IntRange.new(10, 1, -1):withStep(3):toList(), __K2L_IntRange.new(1, 10):withStep(4).last, __K2L_IntRange.new(5, 1, -1).first)
end
local ____lambda_12 = function()
    return __K2L_ReadOnlyListOf(__K2L_TypedArrayOf("[Z", true):toTypedArray():toList(), __K2L_TypedArrayOf("[C", "x"):toTypedArray():toList(), __K2L_TypedArrayOf("[J", 5):toTypedArray():toList())
end
local ____lambda_13 = function()
    return __K2L_CharRange.new("a", string.char(("e"):byte() - 1)):joinToString("")
end
local ____lambda_14 = function() return __K2L_IntRange.new(1, 4 - 1):toList() end
local ____lambda_15 = function()
    return __K2L_ReadOnlyListOf(__K2L_Num.toByte(__K2L_Bits.highest32(__K2L_Num.toByte(-12) & 255)), __K2L_Num.toByte(__K2L_Bits.highest32(__K2L_Num.toByte(12) & 255)), __K2L_Num.toByte(__K2L_Bits.lowest32(__K2L_Num.toByte(12) & 255)))
end
local ____lambda_16 = function()
    return __K2L_ReadOnlyListOf(__K2L_Num.toShort(__K2L_Bits.highest32(__K2L_Num.toShort(-1) & 65535)), __K2L_Num.toShort(__K2L_Bits.lowest32(__K2L_Num.toShort(40) & 65535)))
end
local ____lambda_17 = function()
    return __K2L_ReadOnlyListOf(__K2L_Bits.highest32(100) & 0xFFFFFFFF, __K2L_Bits.lowest32(100) & 0xFFFFFFFF, __K2L_Bits.highest32(0) & 0xFFFFFFFF, __K2L_Bits.highest32(4000000000) & 0xFFFFFFFF)
end
local ____lambda_18 = function()
    return __K2L_ReadOnlyListOf(__K2L_Bits.highest32(200 & 0xFF) & 0xFF, __K2L_Bits.lowest32(200 & 0xFFFF) & 0xFFFF)
end
local ____lambda_19 = function()
    return __K2L_ReadOnlyListOf(__K2L_LazyThreadSafetyMode.values(), __K2L_LazyThreadSafetyMode.valueOf("NONE"), __K2L_LazyThreadSafetyMode.values().size)
end
local ____lambda_20 = function()
    return __K2L_ReadOnlyListOf(__K2L_DeprecationLevel.values(), __K2L_DeprecationLevel.valueOf("ERROR").ordinal)
end
local function main()
    local current = __K2L_KotlinVersion.new(2, 4, 21)
    t("current at least 2.0", function() return current:isAtLeast(2, 0) end)
    t("current parts", function()
        return current.major >= 2 and current.minor >= 0 and current.patch >= 0
    end)
    t("current string", function()
        return __K2L_Str(current) == current.major .. "." .. current.minor .. "." .. current.patch
    end)
    local v = __K2L_KotlinVersion.new(1, 9, 22)
    t("version", function()
        return __K2L_ReadOnlyListOf(v, __K2L_KotlinVersion.new(2, 1), v.major, v.minor, v.patch)
    end)
    t("isAtLeast", function()
        return __K2L_ReadOnlyListOf(v:isAtLeast(1, 9), v:isAtLeast(1, 9, 23), v:isAtLeast(1, 10), v:isAtLeast(1, 8, 99))
    end)
    t("compare", function()
        return __K2L_ReadOnlyListOf(__K2L_Compare(v, __K2L_KotlinVersion.new(1, 10)) < 0, __K2L_Compare(v, __K2L_KotlinVersion.new(1, 9, 22)), __K2L_Num.maxOf(v, __K2L_KotlinVersion.new(1, 9, 3)))
    end)
    t("equals", function()
        return __K2L_ReadOnlyListOf(__K2L_Equals(v, __K2L_KotlinVersion.new(1, 9, 22)), __K2L_Equals(v, __K2L_KotlinVersion.new(1, 9)), v:hashCode() == __K2L_KotlinVersion.new(1, 9, 22):hashCode())
    end)
    t("hashCode", ____lambda_1)
    t("bad version", ____lambda_2)
    t("sorted", ____lambda_3)
    t("UInt floorDiv/mod", ____lambda_4)
    t("UByte/UShort", ____lambda_5)
    t("ULong", ____lambda_6)
    local r = __K2L_IntRange.new(1, 5)
    t("UIntRange", function()
        return __K2L_ReadOnlyListOf(r, r.first, r.last, r.first, r.last, r:isEmpty(), r:contains(3), r:contains(9))
    end)
    t("until", ____lambda_7)
    t("rangeUntil", ____lambda_8)
    t("UByte range", ____lambda_9)
    t("UShort range", ____lambda_10)
    t("progression", ____lambda_11)
    t("reversed", function() return r:reversed():toList() end)
    t("empty", function()
        return __K2L_ReadOnlyListOf(__K2L_IntRange.new(1, 0):isEmpty(), __K2L_IntRange.new(5, 1):isEmpty(), __K2L_IntRange.new(5, 1):firstOrNull(), r:lastOrNull())
    end)
    t("sum", function() return r:sum() & 0xFFFFFFFF end)
    t("iterate", function()
        local ____builder = __K2L_ListBuilderOf()
        do
            local ____range = r:withStep(2)
            for x = ____range.first, ____range.last, ____range.step do
                ____builder:add(x * 10 & 0xFFFFFFFF)
            end
        end
        return ____builder:____build()
    end)
    local d = 1.5
    d = d + 1
    local f = 2.5
    f = __K2L_Fround(f - 1)
    t("inc/dec", function()
        return __K2L_ReadOnlyListOf(d, f, d + 1, __K2L_Fround(f - 1))
    end)
    local ints = __K2L_TypedArrayOf("[I", 1, 2, 3)
    local copy = ints:toTypedArray()
    if 0 < 0 or 0 >= copy.size then
        __K2L_IndexError(0, copy.size, "array")
    end
    copy[1] = 99
    t("clone", function()
        return __K2L_ReadOnlyListOf(ints:toList(), copy:toList(), __K2L_TypedArrayOf("[Ljava.lang.String;", "a", "b"):toTypedArray():toList())
    end)
    local doubles = __K2L_TypedArrayOf("[D", 1.0, 2.5):toTypedArray():toList()
    print("clone doubles = " .. __K2L_Str(doubles))
    t("clone others", ____lambda_12)
    local b1 = 1
    local b2 = 4
    local s1 = 10
    local s2 = 12
    t("byte range", function()
        return __K2L_ReadOnlyListOf(__K2L_IntRange.new(b1, b2):toList(), __K2L_IntRange.new(b1, b2 - 1):toList())
    end)
    t("short range", function()
        return __K2L_ReadOnlyListOf(__K2L_IntRange.new(s1, s2):toList(), __K2L_IntRange.new(s1, s2 - 1).last)
    end)
    t("char rangeUntil", ____lambda_13)
    t("long rangeUntil", ____lambda_14)
    t("Byte bits", ____lambda_15)
    t("Short bits", ____lambda_16)
    t("UInt bits", ____lambda_17)
    t("UByte/UShort bits", ____lambda_18)
    t("LazyThreadSafetyMode", ____lambda_19)
    t("DeprecationLevel", ____lambda_20)
end

__K2L_DeepMain(main)
return {t = t}
