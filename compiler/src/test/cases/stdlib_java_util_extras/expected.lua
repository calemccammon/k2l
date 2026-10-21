local ____lualib = require("lualib_bundle")
local __K2L_CompareValues = ____lualib.__K2L_CompareValues
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_DoubleHash = ____lualib.__K2L_DoubleHash
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_JavaUtil = ____lualib.__K2L_JavaUtil
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_NaturalOrder = ____lualib.__K2L_NaturalOrder
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringJoiner = ____lualib.__K2L_StringJoiner
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

local function balanced(s)
    local stack = __K2L_List.new()
    for ____i = 1, #s do
        local c = s:sub(____i, ____i)
        if c == "(" or c == "[" or c == "{" then
            __K2L_JavaUtil.push(stack, c)
        elseif c == ")" then
            if stack:isEmpty() or not __K2L_Equals(__K2L_JavaUtil.pop(stack), "(") then
                return false
            end
        elseif c == "]" then
            if stack:isEmpty() or not __K2L_Equals(__K2L_JavaUtil.pop(stack), "[") then
                return false
            end
        elseif c == "}" then
            if stack:isEmpty() or not __K2L_Equals(__K2L_JavaUtil.pop(stack), "{") then
                return false
            end
        end
    end
    return stack:isEmpty()
end

local ____lambda_1 = function()
    return __K2L_ReadOnlyListOf(balanced("([]{})"), balanced("(]"), balanced("(("), balanced(""))
end
local ____lambda_2 = function() return __K2L_JavaUtil.requireNonNull("ok") end
local ____lambda_3 = function() return "supplied message" end
local ____lambda_4 = function() return __K2L_JavaUtil.checkIndex(2, 3) end
local ____lambda_5 = function() return __K2L_JavaUtil.checkIndex(3, 3) end
local ____lambda_6 = function(____a, ____b)
    local ____x, ____y = ____a, ____b
    if ____x ~= ____y then
        return ____x < ____y and -1 or 1
    end
    return 0
end
local ____lambda_7 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaUtil.compare("a", "b", __K2L_NaturalOrder), __K2L_JavaUtil.compare(2, 1, ____lambda_6))
end
local ____lambda_8 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaUtil.compareBooleans(true, false), __K2L_JavaUtil.compareBooleans(false, false), __K2L_JavaUtil.logicalAnd(true, false), __K2L_JavaUtil.logicalOr(true, false), true ~= true, string.lower("TRUE" or "") == "true", __K2L_Hash(true))
end
local ____lambda_9 = function()
    return __K2L_ReadOnlyListOf(string.char(__K2L_JavaUtil.forDigit(7, 10)), string.char(__K2L_JavaUtil.forDigit(11, 16)), __K2L_Num.digitToIntOrNull("7", 10) or -1, __K2L_Num.digitToIntOrNull("z", 10) or -1, __K2L_Num.digitToIntOrNull("f", 16) or -1)
end
local ____lambda_10 = function()
    return __K2L_ReadOnlyListOf(__K2L_Hash(-7), __K2L_Hash(5000000000), __K2L_DoubleHash(1.5), __K2L_Hash("A"))
end
local ____lambda_11 = function()
    return __K2L_ReadOnlyListOf(__K2L_Num.maxD(1.5, -2.5), __K2L_Num.minD(1.5, -2.5), 0.25 + 0.5)
end
local function main()
    local stack = __K2L_List.new()
    t("push", function()
        return __K2L_ReadOnlyListOf(__K2L_JavaUtil.push(stack, 1), __K2L_JavaUtil.push(stack, 2), __K2L_JavaUtil.push(stack, 3))
    end)
    t("stack", function() return stack end)
    t("peek", function() return __K2L_JavaUtil.peek(stack) end)
    t("search", function()
        return __K2L_ReadOnlyListOf(__K2L_JavaUtil.search(stack, 3), __K2L_JavaUtil.search(stack, 1), __K2L_JavaUtil.search(stack, 9))
    end)
    t("pop", function()
        return __K2L_ReadOnlyListOf(__K2L_JavaUtil.pop(stack), __K2L_JavaUtil.pop(stack))
    end)
    t("size/empty", function()
        return stack.size .. " " .. tostring(stack:isEmpty()) .. " " .. tostring(stack:isEmpty())
    end)
    t("as list", function()
        local ____out = {}
        local ____count = 0
        local ____items, ____n = stack:____array()
        for ____i_1 = 1, ____n do
            local it = ____items[____i_1]
            ____count = ____count + 1
            ____out[____count] = it * 10
        end
        return __K2L_ListWrap(____out, ____count):plus(stack.size)
    end)
    __K2L_JavaUtil.pop(stack)
    t("pop empty", function() return __K2L_JavaUtil.pop(stack) end)
    t("peek empty", function()
        local ____ok_1, ____result_1, ____returned_1 = __K2L_DeepPcall(function()
            return true, __K2L_JavaUtil.peek(stack)
        end)
        if ____ok_1 then
            if ____result_1 then
                return ____returned_1
            end
        else
            local ____error_1 = __K2L_ToThrowable(____result_1)
            if __K2L_InstanceOf(____error_1, __K2L_RuntimeException) then
                local e = ____error_1
                return "empty: " .. __K2L_Str(__K2L_KClassOfValue(e).simpleName)
            else
                error(____error_1, 0)
            end
        end
    end)
    t("balanced", ____lambda_1)
    local joiner = __K2L_StringJoiner.new(", ", "{", "}")
    t("empty joiner", function() return joiner:toString() end)
    joiner:add("a"):add("b")
    joiner:add("c")
    t("joiner", function() return joiner end)
    t("length", function() return joiner:length() end)
    local plain = __K2L_StringJoiner.new("-")
    plain:setEmptyValue("EMPTY")
    t("empty value", function() return __K2L_Str(plain) end)
    plain:add("x"):add("y")
    t("merge", function() return joiner:merge(plain):toString() end)
    local name = nil
    t("requireNonNull", ____lambda_2)
    t("requireNonNull null", function()
        return __K2L_JavaUtil.requireNonNull(name, "name is required")
    end)
    t("requireNonNull supplier", function()
        return __K2L_JavaUtil.requireNonNull(name, ____lambda_3)
    end)
    t("isNull/nonNull", function()
        return __K2L_ReadOnlyListOf(name == nil, name ~= nil, "x" ~= nil)
    end)
    t("toString", function()
        return __K2L_ReadOnlyListOf(__K2L_Str(name), __K2L_JavaUtil.toStringOr(name, "default"), __K2L_JavaUtil.toStringOr(42, "default"))
    end)
    t("requireNonNullElse", function()
        return __K2L_JavaUtil.requireNonNullElse(name, "fallback")
    end)
    t("checkIndex", ____lambda_4)
    t("checkIndex out", ____lambda_5)
    t("compare", ____lambda_7)
    t("Boolean", ____lambda_8)
    t("Character", ____lambda_9)
    t("hashCode", ____lambda_10)
    t("Double", ____lambda_11)
end

__K2L_DeepMain(main)
return {t = t, balanced = balanced}
