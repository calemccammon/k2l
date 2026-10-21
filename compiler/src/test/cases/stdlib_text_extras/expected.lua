local ____lualib = require("lualib_bundle")
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_EnumValueOf = ____lualib.__K2L_EnumValueOf
local __K2L_EnumValues = ____lualib.__K2L_EnumValues
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Extras = ____lualib.__K2L_Extras
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_JavaUtil = ____lualib.__K2L_JavaUtil
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local ____exports = {}

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

local Level = __K2L_Class("Level")
__K2L_ClassInfo(Level, "Level", "Level", "class")

function Level:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Level:toString()
    return self.name
end

function Level:compareTo(other)
    return self.ordinal - other.ordinal
end

Level.LOW = Level.new("LOW", 0)
Level.MEDIUM = Level.new("MEDIUM", 1)
Level.HIGH = Level.new("HIGH", 2)
Level.____values = {Level.LOW, Level.MEDIUM, Level.HIGH}
____exports.calls = 0

local function touch(result)
    ____exports.calls = ____exports.calls + 1
    return result
end

local ____lambda_1 = function()
    return __K2L_ReadOnlyListOf(__K2L_Extras.toSmall("12", 8), __K2L_Extras.toSmall("-128", 8), __K2L_Extras.toSmall("7f", 8, 16))
end
local ____lambda_2 = function() return __K2L_Extras.toSmall("128", 8) end
local ____lambda_3 = function() return __K2L_Extras.toSmall("x1", 8) end
local ____lambda_4 = function()
    return __K2L_ReadOnlyListOf(__K2L_Extras.toSmall("32767", 16), __K2L_Extras.toSmall("-5", 16), __K2L_Extras.toSmall("ff", 16, 16))
end
local ____lambda_5 = function() return __K2L_Extras.toSmall("40000", 16) end
local ____lambda_6 = function()
    return __K2L_ReadOnlyListOf(__K2L_Extras.toSmallOrNull("100", 8), __K2L_Extras.toSmallOrNull("300", 8), __K2L_Extras.toSmallOrNull("x", 8), __K2L_Extras.toSmallOrNull("-32768", 16), __K2L_Extras.toSmallOrNull("40000", 16))
end
local ____lambda_7 = function(it) return #it > 0 end
local ____lambda_8 = function(it) return it:upper() end
local ____lambda_9 = function()
    return __K2L_AsSequence(__K2L_StringSplit("a,b,,c", ",")):filter(____lambda_7):map(____lambda_8):toList()
end
local ____lambda_10 = function()
    return __K2L_AsSequence(__K2L_Text.split("k=v;x=y", {";", "="})):toList()
end
local ____lambda_11 = function()
    return __K2L_AsSequence(__K2L_Regex.new("\\s+"):split("one  two three")):toList()
end
local ____lambda_12 = function()
    return __K2L_ReadOnlyListOf(__K2L_Extras.isISOControl(("\n"):byte()), __K2L_Extras.isISOControl(("\000"):byte()), __K2L_Extras.isISOControl(("a"):byte()), __K2L_Extras.isISOControl(("\127"):byte()))
end
local ____lambda_13 = function() return "UTF-8" end
local ____lambda_14 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaUtil.logicalAnd(true, false), __K2L_JavaUtil.logicalOr(true, false), __K2L_JavaUtil.logicalAnd(false, touch(true)), __K2L_JavaUtil.logicalOr(true, touch(false)), ____exports.calls)
end
local ____lambda_15 = function()
    return __K2L_EnumValueOf(Level, "MEDIUM").ordinal
end
local ____lambda_16 = function()
    return __K2L_ReadOnlyListOf(__K2L_ListOf(1, nil, 2, 1):filterNotNull():toSet(), __K2L_ListOf(nil):filterNotNull():toSet(), __K2L_ListOf("x"):filterNotNull():toSet())
end
local function main()
    local path = "dir/sub/file.tar.gz"
    t("replaceAfter", function()
        return __K2L_ReadOnlyListOf(__K2L_Extras.replaceAfter(path, "/", "X"), __K2L_Extras.replaceAfter(path, ".", "zip"), __K2L_Extras.replaceAfter(path, "#", "X", "none"))
    end)
    t("replaceBefore", function()
        return __K2L_ReadOnlyListOf(__K2L_Extras.replaceBefore(path, "/", "root"), __K2L_Extras.replaceBefore(path, "#", "X"))
    end)
    t("replaceAfterLast", function()
        return __K2L_ReadOnlyListOf(__K2L_Extras.replaceAfterLast(path, ".", "bz2"), __K2L_Extras.replaceAfterLast(path, "/", "other.txt"))
    end)
    t("replaceBeforeLast", function()
        return __K2L_ReadOnlyListOf(__K2L_Extras.replaceBeforeLast(path, "/", "home"), __K2L_Extras.replaceBeforeLast(path, "#", "X", "missing"))
    end)
    t("toByte", ____lambda_1)
    t("toByte range", ____lambda_2)
    t("toByte malformed", ____lambda_3)
    t("toShort", ____lambda_4)
    t("toShort range", ____lambda_5)
    t("OrNull", ____lambda_6)
    t("splitToSequence", ____lambda_9)
    t("splitToSequence chars", ____lambda_10)
    t("Regex.splitToSequence", ____lambda_11)
    t("isISOControl", ____lambda_12)
    local bytes = __K2L_Text.toByteArray("héllo")
    t("utf8 bytes", function() return bytes.size end)
    t("decode", function()
        return __K2L_ReadOnlyListOf(__K2L_Extras.decode(bytes), __K2L_Extras.decode(bytes), __K2L_Extras.decode(bytes), __K2L_Extras.decode(bytes))
    end)
    t("charset", ____lambda_13)
    t("and/or", ____lambda_14)
    local flags = 0
    local ____old = flags
    flags = flags + 1
    local ____arg = ____old > 5
    local ____old_1 = flags
    flags = flags + 1
    local both = __K2L_JavaUtil.logicalAnd(____arg, ____old_1 > 5)
    t("both evaluated", function() return tostring(both) .. " " .. flags end)
    local lazy = __K2L_Extras.lazyOf("ready")
    t("lazyOf", function()
        return __K2L_ReadOnlyListOf(lazy:isInitialized(), lazy:getValue(), __K2L_Str(lazy))
    end)
    t("enumValues", function()
        local ____result_1
        do
            local ____list = __K2L_EnumValues(Level)
            local ____out = {}
            local ____count = 0
            local ____items, ____n = ____list:____array()
            for ____i = 1, ____n do
                local it = ____items[____i]
                ____count = ____count + 1
                ____out[____count] = it.name
            end
            ____result_1 = __K2L_ListWrap(____out, ____count)
        end
        return ____result_1
    end)
    t("enumValueOf", function()
        local ____result_2
        do
            local default = Level.LOW
            local ____ok_1, ____result_3 = __K2L_DeepPcall(function()
                ____result_2 = __K2L_EnumValueOf(Level, "HIGH")
            end)
            if not ____ok_1 then
                local ____error_1 = __K2L_ToThrowable(____result_3)
                if __K2L_InstanceOf(____error_1, __K2L_IllegalArgumentException) then
                    local e = ____error_1
                    ____result_2 = default
                else
                    error(____error_1, 0)
                end
            end
        end
        local ____arg_1 = ____result_2
        local ____result_4
        do
            local default = Level.MEDIUM
            local ____ok_2, ____result_5 = __K2L_DeepPcall(function()
                ____result_4 = __K2L_EnumValueOf(Level, "nope")
            end)
            if not ____ok_2 then
                local ____error_2 = __K2L_ToThrowable(____result_5)
                if __K2L_InstanceOf(____error_2, __K2L_IllegalArgumentException) then
                    local e = ____error_2
                    ____result_4 = default
                else
                    error(____error_2, 0)
                end
            end
        end
        return __K2L_ReadOnlyListOf(____arg_1, ____result_4)
    end)
    t("enumValueOf direct", ____lambda_15)
    t("setOfNotNull", ____lambda_16)
end

____exports.t = t
____exports.Level = Level
____exports.touch = touch
__K2L_DeepMain(main)
return ____exports
