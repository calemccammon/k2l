-- Creates a class (or interface) table. Instances use it as their metatable; methods missing from
-- the class are looked up in the base class, then in interface default methods.
local function __K2L_Class(name, base, ...)
    local cls = {____name = name, ____super = base, ____interfaces = {}}
    cls.__index = cls
    if base ~= nil then
        cls.__tostring = rawget(base, "__tostring")
    end
    local interfaces = {...}
    for _, iface in ipairs(interfaces) do
        cls.____interfaces[iface] = true
        for super in pairs(iface.____interfaces) do
            cls.____interfaces[super] = true
        end
    end
    if #interfaces == 0 then
        if base ~= nil then
            setmetatable(cls, base)
        end
    else
        setmetatable(cls, {__index = function(_, key)
            if base ~= nil then
                local value = base[key]
                if value ~= nil then
                    return value
                end
            end
            for _, iface in ipairs(interfaces) do
                local value = iface[key]
                if value ~= nil then
                    return value
                end
            end
        end})
    end
    function cls.new(...)
        local self = setmetatable({}, cls)
        local init = cls.____init
        if init ~= nil then
            init(self, ...)
        end
        return self
    end
    return cls
end

-- Kotlin/JVM exception hierarchy. Each class carries its JVM name so toString() matches the JVM.
local __K2L_Throwable = __K2L_Class("java.lang.Throwable")

function __K2L_Throwable:____init(message, cause)
    if message == nil and cause ~= nil then
        message = cause:toString()
    end
    self.message = message
    self.cause = cause
end

function __K2L_Throwable:toString()
    local name = getmetatable(self).____name
    return self.message ~= nil and name .. ": " .. self.message or name
end

-- Lets uncaught exceptions print readably from the standalone interpreter.
__K2L_Throwable.__tostring = __K2L_Throwable.toString

local __K2L_Exception = __K2L_Class("java.lang.Exception", __K2L_Throwable)
local __K2L_Error = __K2L_Class("java.lang.Error", __K2L_Throwable)
local __K2L_RuntimeException = __K2L_Class("java.lang.RuntimeException", __K2L_Exception)
local __K2L_IllegalArgumentException = __K2L_Class("java.lang.IllegalArgumentException", __K2L_RuntimeException)
local __K2L_IllegalStateException = __K2L_Class("java.lang.IllegalStateException", __K2L_RuntimeException)
local __K2L_NullPointerException = __K2L_Class("java.lang.NullPointerException", __K2L_RuntimeException)
local __K2L_IndexOutOfBoundsException = __K2L_Class("java.lang.IndexOutOfBoundsException", __K2L_RuntimeException)
local __K2L_ArithmeticException = __K2L_Class("java.lang.ArithmeticException", __K2L_RuntimeException)
local __K2L_UnsupportedOperationException = __K2L_Class("java.lang.UnsupportedOperationException", __K2L_RuntimeException)
local __K2L_ClassCastException = __K2L_Class("java.lang.ClassCastException", __K2L_RuntimeException)
local __K2L_NumberFormatException = __K2L_Class("java.lang.NumberFormatException", __K2L_IllegalArgumentException)
local __K2L_NoSuchElementException = __K2L_Class("java.util.NoSuchElementException", __K2L_RuntimeException)
local __K2L_ConcurrentModificationException = __K2L_Class("java.util.ConcurrentModificationException", __K2L_RuntimeException)
local __K2L_NotImplementedError = __K2L_Class("kotlin.NotImplementedError", __K2L_Error)

-- Kotlin integer division truncates toward zero; Lua's // floors.
local function __K2L_IDiv(a, b)
    if b == 0 then
        error(__K2L_ArithmeticException.new("/ by zero"))
    end
    local q = a // b
    if q < 0 and q * b ~= a then
        q = q + 1
    end
    return q
end

-- Kotlin `is` for classes, objects and interfaces.
local function __K2L_InstanceOf(value, cls)
    if type(value) ~= "table" then
        return false
    end
    local c = rawget(value, "____name") ~= nil and value or getmetatable(value)
    while c ~= nil do
        if c == cls or rawget(c, "____interfaces")[cls] then
            return true
        end
        c = rawget(c, "____super")
    end
    return false
end

local function __K2L_NotNull(value)
    if value == nil then
        error(__K2L_NullPointerException.new())
    end
    return value
end

-- Kotlin/JVM Double.toString: shortest round-tripping digits, plain notation in [1e-3, 1e7).
local function __K2L_DoubleToString(x)
    if x ~= x then
        return "NaN"
    elseif x == math.huge then
        return "Infinity"
    elseif x == -math.huge then
        return "-Infinity"
    elseif x == 0 then
        return 1 / x < 0 and "-0.0" or "0.0"
    end
    local s
    for precision = 0, 16 do
        s = string.format("%." .. precision .. "e", x)
        if tonumber(s) == x then
            break
        end
    end
    local sign, int, frac, exp = string.match(s, "^(-?)(%d)%.?(%d*)e([-+]%d+)$")
    exp = tonumber(exp)
    local digits = (int .. frac):gsub("0+$", "")
    if digits == "" then
        digits = "0"
    end
    local ax = math.abs(x)
    if ax >= 1e-3 and ax < 1e7 then
        local point = exp + 1
        local whole, fraction
        if point <= 0 then
            whole, fraction = "0", string.rep("0", -point) .. digits
        elseif point >= #digits then
            whole, fraction = digits .. string.rep("0", point - #digits), "0"
        else
            whole, fraction = digits:sub(1, point), digits:sub(point + 1)
        end
        return sign .. whole .. "." .. fraction
    end
    local fraction = digits:sub(2)
    if fraction == "" then
        fraction = "0"
    end
    return sign .. digits:sub(1, 1) .. "." .. fraction .. "E" .. exp
end

local function __K2L_Str(value)
    if value == nil then
        return "null"
    end
    local t = type(value)
    if t == "number" then
        if math.type(value) == "integer" then
            return tostring(value)
        end
        return __K2L_DoubleToString(value)
    elseif t == "table" and value.toString then
        return value:toString()
    end
    return tostring(value)
end

-- A caught Lua error as a Kotlin exception: Lua runtime errors become RuntimeExceptions.
local function __K2L_ToThrowable(err)
    if __K2L_InstanceOf(err, __K2L_Throwable) then
        return err
    end
    return __K2L_RuntimeException.new(tostring(err))
end

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
            if __K2L_InstanceOf(____error, ValidationError) then
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
