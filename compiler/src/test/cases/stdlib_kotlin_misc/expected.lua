local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Bits = ____lualib.__K2L_Bits
local __K2L_CharRange = ____lualib.__K2L_CharRange
local __K2L_DeprecationLevel = ____lualib.__K2L_DeprecationLevel
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_LazyThreadSafetyMode = ____lualib.__K2L_LazyThreadSafetyMode
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SimpleName = ____lualib.__K2L_SimpleName
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function t(label, f)
    local ____ok, ____result = pcall(function()
        print(label .. " = " .. __K2L_Str(f()))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_Exception) then
            local e = ____error
            print(label .. " EXC " .. __K2L_Str(__K2L_SimpleName(e)) .. ": " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
end

local ____lambda_1 = function()
    return __K2L_ListOf(__K2L_ArrayOf(true):toTypedArray():toList(), __K2L_ArrayOf("x"):toTypedArray():toList(), __K2L_ArrayOf(5):toTypedArray():toList())
end
local ____lambda_2 = function()
    return __K2L_CharRange.new("a", string.char(("e"):byte() - 1)):joinToString("")
end
local ____lambda_3 = function() return __K2L_IntRange.new(1, 4 - 1):toList() end
local ____lambda_4 = function()
    return __K2L_ListOf(__K2L_Bits.highest32(-12 & 255), __K2L_Bits.highest32(12 & 255), __K2L_Bits.lowest32(12 & 255))
end
local ____lambda_5 = function()
    return __K2L_ListOf(__K2L_Bits.highest32(-1 & 65535), __K2L_Bits.lowest32(40 & 65535))
end
local ____lambda_6 = function()
    return __K2L_ListOf(__K2L_LazyThreadSafetyMode.values(), __K2L_LazyThreadSafetyMode.valueOf("NONE"), __K2L_LazyThreadSafetyMode.values().size)
end
local ____lambda_7 = function()
    return __K2L_ListOf(__K2L_DeprecationLevel.values(), __K2L_DeprecationLevel.valueOf("ERROR").ordinal)
end
local function main()
    local d = 1.5
    d = d + 1
    local f = 2.5
    f = f - 1
    t("inc/dec", function() return __K2L_ListOf(d, f, d + 1, f - 1) end)
    local ints = __K2L_ArrayOf(1, 2, 3)
    local copy = ints:toTypedArray()
    if 0 < 0 or 0 >= copy.size then
        __K2L_IndexError(0, copy.size, "array")
    end
    copy[1] = 99
    t("clone", function()
        return __K2L_ListOf(ints:toList(), copy:toList(), __K2L_ArrayOf("a", "b"):toTypedArray():toList())
    end)
    local doubles = __K2L_ArrayOf(1.0, 2.5):toTypedArray():toList()
    print("clone doubles = " .. __K2L_Str(doubles))
    t("clone others", ____lambda_1)
    local b1 = 1
    local b2 = 4
    local s1 = 10
    local s2 = 12
    t("byte range", function()
        return __K2L_ListOf(__K2L_IntRange.new(b1, b2):toList(), __K2L_IntRange.new(b1, b2 - 1):toList())
    end)
    t("short range", function()
        return __K2L_ListOf(__K2L_IntRange.new(s1, s2):toList(), __K2L_IntRange.new(s1, s2 - 1).last)
    end)
    t("char rangeUntil", ____lambda_2)
    t("long rangeUntil", ____lambda_3)
    t("Byte bits", ____lambda_4)
    t("Short bits", ____lambda_5)
    t("LazyThreadSafetyMode", ____lambda_6)
    t("DeprecationLevel", ____lambda_7)
end

__K2L_RunMain(main)
return {t = t}
