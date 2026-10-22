local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Extras = ____lualib.__K2L_Extras
local __K2L_IndexOutOfBoundsException = ____lualib.__K2L_IndexOutOfBoundsException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SimpleName = ____lualib.__K2L_SimpleName
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringEndsWith = ____lualib.__K2L_StringEndsWith
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function t(label, f)
    local ____ok, ____result = pcall(function()
        print(label .. " = " .. __K2L_Str(f()))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_Exception) then
            local e = ____error
            print(label .. " EXC " .. __K2L_Str(__K2L_SimpleName(e)))
        else
            error(____error, 0)
        end
    end
end

local function matches(name, suffix, loose)
    return loose and __K2L_StringEndsWith(name:lower(), suffix:lower()) or __K2L_StringEndsWith(name, suffix)
end

local ____lambda_1 = function()
    return __K2L_ListOf(__K2L_Extras.toHex(255, 32), __K2L_Extras.toHex(-1, 32), __K2L_Extras.toHex(0, 32), __K2L_Extras.toHex(-2147483648, 32))
end
local ____lambda_2 = function()
    return __K2L_ListOf(__K2L_Extras.toHex(255, 64), __K2L_Extras.toHex(-2, 64), __K2L_Extras.toHex(20015998343868, 64))
end
local ____lambda_3 = function()
    return __K2L_ListOf(__K2L_Extras.toHex(10, 16), __K2L_Extras.toHex(-1, 16), __K2L_Extras.toHex(127, 8), __K2L_Extras.toHex(-128, 8))
end
local ____lambda_4 = function()
    return __K2L_ListOf(__K2L_Extras.hexTo("ff", 32), __K2L_Extras.hexTo("ffffffff", 32), __K2L_Extras.hexTo("7fffffff", 32), __K2L_Extras.hexTo("0", 32))
end
local ____lambda_5 = function()
    return __K2L_ListOf(__K2L_Extras.hexTo("10", 64), __K2L_Extras.hexTo("ffffffffffffffff", 64), __K2L_Extras.hexTo("123456789abc", 64))
end
local ____lambda_6 = function()
    return __K2L_ListOf(__K2L_Extras.hexTo("ffff", 16), __K2L_Extras.hexTo("7f", 8), __K2L_Extras.hexTo("80", 8))
end
local ____lambda_7 = function() return __K2L_Extras.hexTo("xyz", 32) end
local ____lambda_8 = function() return __K2L_Extras.hexTo("123456789", 32) end
local ____lambda_9 = function()
    return __K2L_Extras.hexToBytes("000f10ff7f80"):toList()
end
local ____lambda_10 = function()
    return true, __K2L_StringBuilder.new("ab"):deleteCharAt(5)
end
local ____lambda_11 = function()
    return __K2L_ListOf(matches("Photo.JPG", ".jpg", true), matches("Photo.JPG", ".jpg", false), matches("a.jpg", ".jpg", false))
end
local function main()
    t("Int.toHexString", ____lambda_1)
    t("Long.toHexString", ____lambda_2)
    t("Short/Byte", ____lambda_3)
    local bytes = __K2L_ArrayOf(0, 15, 16, -1, 127, -128)
    t("ByteArray.toHexString", function() return __K2L_Extras.bytesToHex(bytes) end)
    t("hexToInt", ____lambda_4)
    t("hexToLong", ____lambda_5)
    t("hexToShort/Byte", ____lambda_6)
    t("hexToInt bad", ____lambda_7)
    t("hexToInt long", ____lambda_8)
    t("hexToByteArray", ____lambda_9)
    t("round trip", function()
        return __K2L_Extras.hexToBytes(__K2L_Extras.bytesToHex(bytes)):contentEquals(bytes)
    end)
    local sb = __K2L_StringBuilder.new("hello, world")
    sb:deleteCharAt(5)
    t("deleteAt", function() return sb:toString() end)
    sb:delete(0, 6)
    t("deleteRange", function() return sb:toString() end)
    sb:replace(0, 1, "W")
    t("setRange", function() return sb:toString() end)
    t("deleteAt out of range", function()
        local ____ok_1, ____result_1, ____returned_1 = pcall(____lambda_10)
        if ____ok_1 then
            if ____result_1 then
                return ____returned_1
            end
        else
            local ____error_1 = __K2L_ToThrowable(____result_1)
            if __K2L_InstanceOf(____error_1, __K2L_IndexOutOfBoundsException) then
                local e = ____error_1
                return "out of range"
            else
                error(____error_1, 0)
            end
        end
    end)
    t("endsWith", ____lambda_11)
    local loose = true
    local strict = false
    local name = "Kotlin"
    local prefix = "kot"
    t("startsWith", function()
        return __K2L_ListOf(loose and __K2L_StringStartsWith(name:lower(), prefix:lower()) or __K2L_StringStartsWith(name, prefix), strict and __K2L_StringStartsWith(name:lower(), prefix:lower()) or __K2L_StringStartsWith(name, prefix))
    end)
    local part = "TLI"
    t("contains", function()
        return __K2L_ListOf(loose and __K2L_StringContains(name:lower(), part:lower()) or __K2L_StringContains(name, part), strict and __K2L_StringContains(name:lower(), part:lower()) or __K2L_StringContains(name, part))
    end)
end

__K2L_RunMain(main)
return {t = t, matches = matches}
