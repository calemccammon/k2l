local ____lualib = require("lualib_bundle")
local __K2L_AssertionError = ____lualib.__K2L_AssertionError
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Error = ____lualib.__K2L_Error
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_SimpleName = ____lualib.__K2L_SimpleName
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Throwable = ____lualib.__K2L_Throwable
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function check(ok, message)
    if not ok then
        error(__K2L_AssertionError.new(__K2L_Str(message)))
    end
end

local CheckFailed = __K2L_Class("CheckFailed", __K2L_AssertionError)

function CheckFailed:____init(message)
    __K2L_AssertionError.____init(self, message)
end

local function verify(condition, message)
    if not condition then
        error(CheckFailed.new(message))
    end
end

local function outcome(block)
    local ____ok, ____result, ____returned = pcall(function()
        block()
        return true, "no error"
    end)
    if ____ok then
        if ____result then
            return ____returned
        end
    else
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_Exception) then
            local e = ____error
            return "exception " .. __K2L_Str(e)
        elseif __K2L_InstanceOf(____error, __K2L_Error) then
            local e = ____error
            return "error " .. __K2L_Str(__K2L_SimpleName(e)) .. ": " .. __K2L_Str(e.message) .. " (assertion: " .. tostring(__K2L_InstanceOf(e, __K2L_AssertionError)) .. ")"
        else
            error(____error, 0)
        end
    end
end

local function describe(e)
    if __K2L_InstanceOf(e, __K2L_AssertionError) then
        return "assertion: " .. __K2L_Str(e.message)
    elseif __K2L_InstanceOf(e, __K2L_RuntimeException) then
        return "runtime: " .. __K2L_Str(e.message)
    else
        return "other: " .. __K2L_Str(e)
    end
end

local function main()
    local ____ok_1, ____result_1 = pcall(function()
        check(false, "values differ")
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error_1, __K2L_AssertionError) then
            local e = ____error_1
            print(__K2L_Str(e))
            print(__K2L_Str(e.message))
            print(__K2L_InstanceOf(e, __K2L_Error))
            print(__K2L_InstanceOf(e, __K2L_Exception))
        else
            error(____error_1, 0)
        end
    end
    print(describe(__K2L_AssertionError.new("x")))
    print(describe(__K2L_IllegalStateException.new("y")))
    print(__K2L_Str(__K2L_AssertionError.new().message))
    print(__K2L_Str(__K2L_AssertionError.new(tostring(42)).message))
    print(__K2L_Str(__K2L_AssertionError.new(__K2L_Str(nil)).message))
    local cause = __K2L_IllegalArgumentException.new("bad")
    local wrapped = __K2L_AssertionError.new(__K2L_Str(cause), cause)
    print(__K2L_Str(wrapped.message))
    print(wrapped.cause == cause)
    print(__K2L_AssertionError.new("with cause", cause).cause == cause)
    local ____ok_2, ____result_2 = pcall(function()
        check(false, 7)
    end)
    if not ____ok_2 then
        local ____error_2 = __K2L_ToThrowable(____result_2)
        if __K2L_InstanceOf(____error_2, __K2L_Error) then
            local e = ____error_2
            print("caught as Error: " .. __K2L_Str(e.message))
        else
            error(____error_2, 0)
        end
    end
    local caught
    local ____ok_3, ____result_3 = pcall(function()
        error(__K2L_AssertionError.new("t"))
    end)
    if not ____ok_3 then
        local ____error_3 = __K2L_ToThrowable(____result_3)
        local e = ____error_3
        caught = e
    end
    print(__K2L_InstanceOf(caught, __K2L_AssertionError))
    print(outcome(function()
        verify(1 + 1 == 2, "math")
    end))
    print(outcome(function()
        verify(false, "expected <1>, actual <2>.")
    end))
    print(__K2L_Str(CheckFailed.new("sub")))
    local ____ok_4, ____result_4 = pcall(function()
        verify(false, "rethrown")
    end)
    if not ____ok_4 then
        local ____error_4 = __K2L_ToThrowable(____result_4)
        if __K2L_InstanceOf(____error_4, __K2L_AssertionError) then
            local e = ____error_4
            print("caught " .. __K2L_Str(e.message) .. " " .. tostring(getmetatable(e) == CheckFailed) .. " " .. tostring(__K2L_InstanceOf(e, __K2L_Throwable)))
        else
            error(____error_4, 0)
        end
    end
end

__K2L_RunMain(main)
return {check = check, CheckFailed = CheckFailed, verify = verify, outcome = outcome, describe = describe}
