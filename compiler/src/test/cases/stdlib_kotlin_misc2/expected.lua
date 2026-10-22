local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_AutoCloseableOf = ____lualib.__K2L_AutoCloseableOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CloseAfter = ____lualib.__K2L_CloseAfter
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IdentityHash = ____lualib.__K2L_IdentityHash
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Object = ____lualib.__K2L_Object
local __K2L_Result = ____lualib.__K2L_Result
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SimpleName = ____lualib.__K2L_SimpleName
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_Text = ____lualib.__K2L_Text
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

local Color = __K2L_Class("Color")

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
    for ____i = 1, items.size do
        local i = items[____i]
        out:append(" "):append(tostring(i))
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
    return __K2L_ListOf(__K2L_IdentityHash(Color.RED) == __K2L_IdentityHash(Color.RED), __K2L_IdentityHash(Color.RED) == __K2L_IdentityHash(Color.GREEN))
end
local ____lambda_3 = function()
    return __K2L_ListOf(__K2L_Hash(__K2L_Result.success("x")) == __K2L_Hash("x"), __K2L_Hash(__K2L_Result.success(5)))
end
local ____lambda_4 = function()
    return __K2L_ListOf(__K2L_IteratorOf(__K2L_ArrayOf(3)):next(), __K2L_IteratorOf(__K2L_ArrayOf(4)):next(), __K2L_IteratorOf(__K2L_ArrayOf(2.5)):next())
end
local ____lambda_5 = function() return "q" end
local ____lambda_6 = function()
    return __K2L_Str(render(__K2L_StringBuilder.new(), __K2L_ListOf(1, 2, 3)))
end
local ____lambda_7 = function() return __K2L_ListOf(false, false) end
local function main()
    local lock = __K2L_Object.new()
    local other = __K2L_Object.new()
    t("Any", function()
        return __K2L_ListOf(__K2L_Equals(lock, lock), __K2L_Equals(lock, other), __K2L_Hash(lock) == __K2L_Hash(lock), __K2L_StringStartsWith(__K2L_Str(lock), "kotlin.Any@"))
    end)
    t("String()", ____lambda_1)
    local log = __K2L_ListOf()
    local resource = __K2L_AutoCloseableOf(function()
        log:add("closed")
    end)
    local ____result_1
    local ____ok_1, ____result_2 = pcall(function()
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
    t("enum hashCode", ____lambda_2)
    t("Result hashCode", ____lambda_3)
    local nothing = nil
    t("nullable hashCode", function()
        return __K2L_ListOf(__K2L_Hash(nothing), __K2L_Hash("a"))
    end)
    local ints = __K2L_IteratorOf(__K2L_ArrayOf(1, 2))
    local chars = __K2L_StringToList("xy"):iterator()
    local bools = __K2L_IteratorOf(__K2L_ArrayOf(true, false))
    local longs = __K2L_IteratorOf(__K2L_ArrayOf(7))
    local doubles = __K2L_IteratorOf(__K2L_ArrayOf(1.5))
    t("iterators", function()
        return __K2L_ListOf(ints:next(), ints:next(), chars:next(), bools:next(), bools:next(), longs:next(), doubles:next())
    end)
    t("more iterators", ____lambda_4)
    t("Char.toChar", ____lambda_5)
    t("Appendable", ____lambda_6)
    t("hasSurrogatePairAt", ____lambda_7)
end

__K2L_RunMain(main)
return {t = t, Color = Color, render = render}
