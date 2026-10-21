local ____lualib = require("lualib_bundle")
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_EmptyStackException = ____lualib.__K2L_EmptyStackException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_JavaUtil = ____lualib.__K2L_JavaUtil
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_List = ____lualib.__K2L_List
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringJoiner = ____lualib.__K2L_StringJoiner
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Utf16 = ____lualib.__K2L_Utf16

local function popOrNull(stack)
    local ____ok, ____result, ____returned = __K2L_DeepPcall(function()
        return true, __K2L_JavaUtil.pop(stack)
    end)
    if ____ok then
        if ____result then
            return ____returned
        end
    else
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_EmptyStackException) then
            local e = ____error
            return nil
        else
            error(____error, 0)
        end
    end
end

local function describe(e)
    if __K2L_InstanceOf(e, __K2L_EmptyStackException) then
        return "EmptyStackException message=" .. __K2L_Str(e.message)
    elseif __K2L_InstanceOf(e, __K2L_RuntimeException) then
        return "other RuntimeException"
    else
        return "other"
    end
end

local ____lambda_1 = function() return __K2L_JavaUtil.pop(__K2L_List.new()) end
local function main()
    local stack = __K2L_List.new()
    __K2L_JavaUtil.push(stack, "é")
    print(__K2L_Utf16.out("pop: " .. __K2L_Str(popOrNull(stack)) .. " then " .. __K2L_Str(popOrNull(stack))))
    local ____ok_1, ____result_1 = __K2L_DeepPcall(function()
        __K2L_JavaUtil.peek(stack)
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error_1, __K2L_EmptyStackException) then
            local e = ____error_1
            print(__K2L_Utf16.out("peek: caught " .. __K2L_Str(__K2L_KClassOfValue(e).simpleName) .. " " .. __K2L_Str(e.message) .. " " .. __K2L_Str(e)))
        else
            error(____error_1, 0)
        end
    end
    local ____ok_2, ____result_2 = __K2L_DeepPcall(function()
        __K2L_JavaUtil.pop(stack)
    end)
    if not ____ok_2 then
        local ____error_2 = __K2L_ToThrowable(____result_2)
        if __K2L_InstanceOf(____error_2, __K2L_RuntimeException) then
            local e = ____error_2
            print(__K2L_Utf16.out("pop as RuntimeException: " .. describe(e) .. " " .. tostring(__K2L_InstanceOf(e, __K2L_EmptyStackException)) .. " " .. tostring(__K2L_InstanceOf(e, __K2L_IllegalStateException))))
        else
            error(____error_2, 0)
        end
    end
    local made = __K2L_EmptyStackException.new()
    print(__K2L_Utf16.out("constructed: " .. __K2L_Str(made) .. " " .. __K2L_Str(made.message) .. " " .. tostring(__K2L_InstanceOf(made, __K2L_RuntimeException))))
    local result = __K2L_RunCatching(____lambda_1)
    local ____receiver = result:exceptionOrNull()
    local ____result_4
    if ____receiver ~= nil then
        local ____result_3
        ____result_3 = describe(____receiver)
        ____result_4 = ____result_3
    end
    print(__K2L_Utf16.out("runCatching: " .. __K2L_Str(____result_4)))
    local joiner = __K2L_StringJoiner.new("·", "«", "»")
    print(__K2L_Utf16.out("empty length: " .. __K2L_Utf16.len(joiner:toString()) .. " " .. __K2L_Str(joiner)))
    joiner:add("naïve"):add("😀")
    print(__K2L_Utf16.out("length: " .. __K2L_Utf16.len(joiner:toString()) .. " " .. __K2L_Utf16.len(joiner:toString()) .. " " .. __K2L_Str(joiner)))
    local plain = __K2L_StringJoiner.new(", ")
    plain:setEmptyValue("ø")
    print(__K2L_Utf16.out("empty value length: " .. __K2L_Utf16.len(plain:toString())))
    plain:add("abc")
    print(__K2L_Utf16.out("ascii length: " .. __K2L_Utf16.len(plain:toString())))
end

__K2L_DeepMain(main)
return {popOrNull = popOrNull, describe = describe}
