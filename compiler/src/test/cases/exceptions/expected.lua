local ____lualib = require("lualib_bundle")
local __K2L_ArithmeticException = ____lualib.__K2L_ArithmeticException
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_NullPointerException = ____lualib.__K2L_NullPointerException
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local ValidationError = __K2L_Class("ValidationError", __K2L_IllegalArgumentException)

function ValidationError:____init(field)
    __K2L_IllegalArgumentException.____init(self, "invalid " .. field)
    self.field = field
end

local function parsePositive(n)
    if n < 0 then
        error(__K2L_IllegalArgumentException.new("negative: " .. n))
    end
    return n
end

local function risky(mode)
    local ____ok, ____result, ____returned = pcall(function()
        if mode == 0 then
            return true, "ok"
        elseif mode == 1 then
            error(__K2L_IllegalStateException.new("bad state"))
        elseif mode == 2 then
            error(ValidationError.new("email"))
        else
            error(__K2L_IllegalStateException.new("unexpected mode " .. mode))
        end
    end)
    if not ____ok then
        ____ok, ____result, ____returned = pcall(function()
            local ____error = __K2L_ToThrowable(____result)
            if getmetatable(____error) == ValidationError then
                local e = ____error
                return true, "validation failed for " .. e.field .. ": " .. __K2L_Str(e.message)
            elseif __K2L_InstanceOf(____error, __K2L_IllegalStateException) then
                local e = ____error
                return true, "state: " .. __K2L_Str(e.message)
            else
                error(____error, 0)
            end
        end)
    end
    print("finally " .. mode)
    if not ____ok then
        error(____result, 0)
    end
    if ____result then
        return ____returned
    end
end

local function safeDivide(a, b)
    local ____ok_1, ____result_1, ____returned_1 = pcall(function()
        return true, __K2L_IDiv(a, b)
    end)
    if ____ok_1 then
        if ____result_1 then
            return ____returned_1
        end
    else
        local ____error_1 = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error_1, __K2L_ArithmeticException) then
            local e = ____error_1
            print("caught " .. __K2L_Str(e.message))
            return 0
        else
            error(____error_1, 0)
        end
    end
end

local function main()
    print(parsePositive(5))
    local ____ok_2, ____result_2 = pcall(function()
        parsePositive(-1)
    end)
    if not ____ok_2 then
        local ____error_2 = __K2L_ToThrowable(____result_2)
        if __K2L_InstanceOf(____error_2, __K2L_IllegalArgumentException) then
            local e = ____error_2
            print("caught: " .. __K2L_Str(e.message))
        else
            error(____error_2, 0)
        end
    end
    print(risky(0))
    print(risky(1))
    print(risky(2))
    local ____ok_3, ____result_3 = pcall(function()
        risky(3)
    end)
    if not ____ok_3 then
        local ____error_3 = __K2L_ToThrowable(____result_3)
        if __K2L_InstanceOf(____error_3, __K2L_Exception) then
            local e = ____error_3
            print("outer: " .. __K2L_Str(e))
        else
            error(____error_3, 0)
        end
    end
    print(safeDivide(10, 2))
    print(safeDivide(1, 0))
    local e = ValidationError.new("name")
    print(__K2L_InstanceOf(e, __K2L_IllegalArgumentException))
    print(__K2L_InstanceOf(e, __K2L_RuntimeException))
    print(__K2L_Str(e))
    local ____ok_4, ____result_4 = pcall(function()
        if not (1 > 2) then
            error(__K2L_IllegalArgumentException.new("one is not greater"))
        end
    end)
    if not ____ok_4 then
        local ____error_4 = __K2L_ToThrowable(____result_4)
        if __K2L_InstanceOf(____error_4, __K2L_IllegalArgumentException) then
            local e = ____error_4
            print(__K2L_Str(e.message))
        else
            error(____error_4, 0)
        end
    end
    local ____ok_5, ____result_5 = pcall(function()
        if true then
            error(__K2L_IllegalStateException.new("Check failed."))
        end
    end)
    if not ____ok_5 then
        local ____error_5 = __K2L_ToThrowable(____result_5)
        if __K2L_InstanceOf(____error_5, __K2L_IllegalStateException) then
            local e = ____error_5
            print(__K2L_Str(e.message))
        else
            error(____error_5, 0)
        end
    end
    local value = nil
    local ____ok_6, ____result_6 = pcall(function()
        print(#__K2L_NotNull(value))
    end)
    if not ____ok_6 then
        local ____error_6 = __K2L_ToThrowable(____result_6)
        if __K2L_InstanceOf(____error_6, __K2L_NullPointerException) then
            local e = ____error_6
            print("npe")
        else
            error(____error_6, 0)
        end
    end
    local attempts = 0
    while attempts < 3 do
        attempts = attempts + 1
        local ____ok_7, ____result_7 = pcall(function()
            if attempts < 3 then
                error(__K2L_RuntimeException.new("try again"))
            end
            print("succeeded after " .. attempts)
        end)
        if not ____ok_7 then
            local ____error_7 = __K2L_ToThrowable(____result_7)
            if __K2L_InstanceOf(____error_7, __K2L_RuntimeException) then
                local e = ____error_7
                print(__K2L_Str(e.message))
            else
                error(____error_7, 0)
            end
        end
    end
end

main()
return {ValidationError = ValidationError, parsePositive = parsePositive, risky = risky, safeDivide = safeDivide}
