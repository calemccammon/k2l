local ____lualib = require("lualib_bundle")
local __K2L_AutoCloseableOf = ____lualib.__K2L_AutoCloseableOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassCastException = ____lualib.__K2L_ClassCastException
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_CloseAfter = ____lualib.__K2L_CloseAfter
local __K2L_CollectionExtras = ____lualib.__K2L_CollectionExtras
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Duration = ____lualib.__K2L_Duration
local __K2L_DurationUnit = ____lualib.__K2L_DurationUnit
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HexFormat = ____lualib.__K2L_HexFormat
local __K2L_IdentityHash = ____lualib.__K2L_IdentityHash
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_Instant = ____lualib.__K2L_Instant
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_KotlinNullPointerException = ____lualib.__K2L_KotlinNullPointerException
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_NoWhenBranchMatchedException = ____lualib.__K2L_NoWhenBranchMatchedException
local __K2L_NullPointerException = ____lualib.__K2L_NullPointerException
local __K2L_Object = ____lualib.__K2L_Object
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Result = ____lualib.__K2L_Result
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_TestTimeSource = ____lualib.__K2L_TestTimeSource
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_TypeCastException = ____lualib.__K2L_TypeCastException
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

local Color = __K2L_Class("Color")
__K2L_ClassInfo(Color, "Color", "Color", "class")

function Color:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Color:toString()
    return self.name
end

function Color:compareTo(other)
    return self.ordinal - other.ordinal
end

Color.RED = Color.new("RED", 0)
Color.GREEN = Color.new("GREEN", 1)
Color.____values = {Color.RED, Color.GREEN}

local function render(out, items)
    out:append("items:")
    local ____mod = items.____modCount
    for ____i = 1, items.size do
        local i = items[____i]
        out:append(" "):append(tostring(i))
        if items.____modCount ~= ____mod and items:____comodified(____i) then
            break
        end
    end
    out:append("\n")
    out:append(__K2L_Text.substring("abcdef", 1, 3))
    out:append("!"):append("\n")
    out:append(__K2L_Text.substring("0123456789", 7, 10))
    out:append(" and"):append(" more")
    return out
end

local ____lambda_1 = function() return "[" .. "" .. "]" end
local ____lambda_2 = function()
    return __K2L_ReadOnlyListOf(__K2L_IdentityHash(Color.RED) == __K2L_IdentityHash(Color.RED), __K2L_IdentityHash(Color.RED) == __K2L_IdentityHash(Color.GREEN))
end
local ____lambda_3 = function()
    return __K2L_ReadOnlyListOf(__K2L_Hash(__K2L_Result.success("x")) == __K2L_Hash("x"), __K2L_Hash(__K2L_Result.success(5)))
end
local ____lambda_4 = function()
    return __K2L_ReadOnlyListOf(__K2L_IteratorOf(__K2L_TypedArrayOf("[B", 3)):next(), __K2L_IteratorOf(__K2L_TypedArrayOf("[S", 4)):next(), __K2L_IteratorOf(__K2L_TypedArrayOf("[F", 2.5)):next())
end
local ____lambda_5 = function() return "q" end
local ____lambda_6 = function()
    return __K2L_Str(render(__K2L_StringBuilder.new(), __K2L_ReadOnlyListOf(1, 2, 3)))
end
local ____lambda_7 = function()
    return __K2L_ReadOnlyListOf(__K2L_HexFormat.number(255, 32, __K2L_HexFormat.Default), __K2L_HexFormat.number(255 & 0xFF, 8, __K2L_HexFormat.Default), __K2L_HexFormat.number(65535 & 0xFFFF, 16, __K2L_HexFormat.Default), __K2L_HexFormat.number(4000000000, 32, __K2L_HexFormat.Default))
end
local ____lambda_8 = function()
    return __K2L_ReadOnlyListOf(__K2L_HexFormat.number(0, 64, __K2L_HexFormat.Default), __K2L_HexFormat.number(255, 64, __K2L_HexFormat.Default))
end
local ____lambda_9 = function()
    return __K2L_ReadOnlyListOf(__K2L_HexFormat.parseNumber("ff", 8, __K2L_HexFormat.Default) & 0xFF, __K2L_HexFormat.parseNumber("ffff", 16, __K2L_HexFormat.Default) & 0xFFFF, __K2L_HexFormat.parseNumber("ffffffff", 32, __K2L_HexFormat.Default) & 0xFFFFFFFF, __K2L_HexFormat.parseNumber("ff", 64, __K2L_HexFormat.Default))
end
local ____lambda_10 = function()
    return __K2L_ReadOnlyListOf(__K2L_HexFormat.number(255, 32, __K2L_HexFormat.build(function(self)
        local ____object = self.number
        ____object.removeLeadingZeros = true
    end)), __K2L_HexFormat.parseNumber("0Xffh", 32, __K2L_HexFormat.build(function(____this)
        local ____object_1 = ____this.number
        ____object_1.prefix = "0x"
        local ____object_2 = ____this.number
        ____object_2.suffix = "H"
    end)) & 0xFFFFFFFF)
end
local ____lambda_11 = function()
    return __K2L_ReadOnlyListOf(__K2L_CollectionExtras.hasSurrogatePairAt("abc", 0, nil), __K2L_CollectionExtras.hasSurrogatePairAt("", 0, nil))
end
local function main()
    local lock = __K2L_Object.new()
    local other = __K2L_Object.new()
    t("Any", function()
        return __K2L_ReadOnlyListOf(__K2L_Equals(lock, lock), __K2L_Equals(lock, other), __K2L_Hash(lock) == __K2L_Hash(lock), __K2L_StringStartsWith(__K2L_Str(lock), "java.lang.Object@"))
    end)
    t("String()", ____lambda_1)
    local log = __K2L_ListOf()
    local resource = __K2L_AutoCloseableOf(function()
        log:add("closed")
    end)
    local ____result_1
    local ____ok_1, ____result_2 = __K2L_DeepPcall(function()
        log:add("used")
    end)
    if ____ok_1 then
        resource:close()
    else
        __K2L_CloseAfter(resource, ____result_2)
    end
    if not ____ok_1 then
        error(____result_2, 0)
    end
    t("AutoCloseable", function() return log end)
    local evaluated = 0
    local ____old = evaluated
    evaluated = evaluated + 1
    local _ = ____old == 100
    t("assert", function() return evaluated end)
    t("KotlinNullPointerException", function()
        error(__K2L_KotlinNullPointerException.new("knpe"))
    end)
    t("NoWhenBranchMatchedException", function()
        error(__K2L_NoWhenBranchMatchedException.new("no branch"))
    end)
    t("TypeCastException", function()
        error(__K2L_TypeCastException.new("bad cast"))
    end)
    t("hierarchy", function()
        local ____value = __K2L_KotlinNullPointerException.new()
        local ____arg = __K2L_InstanceOf(____value, __K2L_NullPointerException)
        local ____value_1 = __K2L_TypeCastException.new()
        local ____arg_1 = __K2L_InstanceOf(____value_1, __K2L_ClassCastException)
        local ____value_2 = __K2L_NoWhenBranchMatchedException.new()
        return __K2L_ReadOnlyListOf(____arg, ____arg_1, __K2L_InstanceOf(____value_2, __K2L_RuntimeException))
    end)
    t("enum hashCode", ____lambda_2)
    t("Result hashCode", ____lambda_3)
    local nothing = nil
    t("nullable hashCode", function()
        return __K2L_ReadOnlyListOf(__K2L_Hash(nothing), __K2L_Hash("a"))
    end)
    local ints = __K2L_IteratorOf(__K2L_TypedArrayOf("[I", 1, 2))
    local chars = __K2L_StringToList("xy"):iterator()
    local bools = __K2L_IteratorOf(__K2L_TypedArrayOf("[Z", true, false))
    local longs = __K2L_IteratorOf(__K2L_TypedArrayOf("[J", 7))
    local doubles = __K2L_IteratorOf(__K2L_TypedArrayOf("[D", 1.5))
    t("iterators", function()
        return __K2L_ReadOnlyListOf(ints:next(), ints:next(), chars:next(), bools:next(), bools:next(), longs:next(), doubles:next())
    end)
    t("more iterators", ____lambda_4)
    t("Char.toChar", ____lambda_5)
    t("Appendable", ____lambda_6)
    t("unsigned toHexString", ____lambda_7)
    t("ULong toHexString", ____lambda_8)
    t("hexToU", ____lambda_9)
    t("unsigned with format", ____lambda_10)
    t("hasSurrogatePairAt", ____lambda_11)
    local source = __K2L_TestTimeSource.new()
    local clock = __K2L_Instant.asClock(source, __K2L_Instant.fromEpochSeconds(100))
    t("asClock", function() return clock:now() end)
    source:plusAssign(__K2L_Duration.ofWhole(2, __K2L_DurationUnit.SECONDS))
    t("asClock later", function() return clock:now() end)
end

__K2L_DeepMain(main)
return {t = t, Color = Color, render = render}
