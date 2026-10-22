local ____lualib = require("lualib_bundle")
local __K2L_AssertionError = ____lualib.__K2L_AssertionError
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Error = ____lualib.__K2L_Error
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SimpleName = ____lualib.__K2L_SimpleName
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Throwable = ____lualib.__K2L_Throwable
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local CheckFailed = __K2L_Class("CheckFailed", __K2L_AssertionError)

function CheckFailed:____init(message)
    __K2L_AssertionError.____init(self, message)
end

local function verify(condition, message)
    if not condition then
        error(CheckFailed.new(message))
    end
end

local function describe(block)
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

local function main()
    print(describe(function()
        error(__K2L_AssertionError.new("plain"))
    end))
    print(describe(function()
        error(__K2L_AssertionError.new())
    end))
    print(describe(function()
        verify(1 + 1 == 2, "math")
    end))
    print(describe(function()
        verify(false, "expected <1>, actual <2>.")
    end))
    local e = __K2L_AssertionError.new("shown")
    print(__K2L_Str(e))
    print(__K2L_Str(e.message))
    print(__K2L_Str(CheckFailed.new("sub")))
    print(__K2L_Str(__K2L_AssertionError.new(tostring(42)).message))
    local nothing = nil
    print(__K2L_Str(__K2L_AssertionError.new(__K2L_Str(nothing)).message))
    local cause = __K2L_IllegalStateException.new("inner")
    local wrapped = __K2L_AssertionError.new(__K2L_Str(cause), cause)
    local ____receiver = wrapped.cause
    print(__K2L_Str(wrapped.message) .. " / " .. __K2L_Str(____receiver and ____receiver.message))
    local both = __K2L_AssertionError.new("outer", cause)
    print(__K2L_Str(both.message) .. " / " .. tostring(both.cause == cause))
    local ____ok_1, ____result_1 = pcall(function()
        verify(false, "rethrown")
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error_1, __K2L_AssertionError) then
            local e = ____error_1
            print("caught " .. __K2L_Str(e.message) .. " " .. tostring(getmetatable(e) == CheckFailed) .. " " .. tostring(__K2L_InstanceOf(e, __K2L_Throwable)))
        else
            error(____error_1, 0)
        end
    end
end

__K2L_RunMain(main)
return {CheckFailed = CheckFailed, verify = verify, describe = describe}
