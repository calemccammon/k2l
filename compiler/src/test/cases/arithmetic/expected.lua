local function __K2L_DoubleToInt(x)
    if x ~= x then
        return 0
    elseif x >= 2147483647 then
        return 2147483647
    elseif x <= -2147483648 then
        return -2147483648
    end
    return x >= 0 and math.floor(x) or math.ceil(x)
end

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

-- Wraps a Lua integer to Kotlin's 32-bit Int range, as Long.toInt() does.
local function __K2L_ToInt32(x)
    x = x & 0xFFFFFFFF
    if x >= 0x80000000 then
        return x - 0x100000000
    end
    return x
end

local function main()
    local a = 17
    local b = 5
    print(a + b)
    print(a - b)
    print(a * b)
    print(__K2L_IDiv(a, b))
    print(math.fmod(a, b))
    print(__K2L_IDiv(-a, b))
    print(math.fmod(-a, b))
    print(__K2L_IDiv(a, -b))
    print(math.fmod(a, -b))
    local x = 7.5
    local y = 2.0
    print(__K2L_Str(x + y))
    print(__K2L_Str(x / y))
    print(__K2L_Str(math.fmod(x, y)))
    print(__K2L_Str(x * a))
    print(__K2L_Str(a / y))
    print(__K2L_Str(1.0 / 3))
    print(__K2L_Str(1.0E10))
    print(__K2L_Str(1.0E-4))
    print(__K2L_Str(1.0 / 0.0))
    print(__K2L_Str(-(1.0 / 0.0)))
    print(__K2L_Str(0.0 / 0.0))
    print(a > b and b > 0)
    print(a < b or b ~= 5)
    print(a ~= b)
    print(2 - -3)
    print(-(-a))
    print(math.max(3, 9))
    print(__K2L_Str(math.min(2.5, 1.5)))
    print(__K2L_Str(math.sqrt(16.0)))
    print(math.abs(-4))
    print(__K2L_Str(math.floor(2.7) + 0.0))
    print(__K2L_DoubleToInt(x))
    print(__K2L_DoubleToInt(-x))
    print(__K2L_Str(a + 0.0))
    print(__K2L_ToInt32(3000000000))
    print(2147483647)
end

main()
