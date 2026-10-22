-- requires: Class
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
local __K2L_StringIndexOutOfBoundsException = __K2L_Class("java.lang.StringIndexOutOfBoundsException", __K2L_IndexOutOfBoundsException)
local __K2L_ArrayIndexOutOfBoundsException = __K2L_Class("java.lang.ArrayIndexOutOfBoundsException", __K2L_IndexOutOfBoundsException)
local __K2L_ArithmeticException = __K2L_Class("java.lang.ArithmeticException", __K2L_RuntimeException)
local __K2L_UnsupportedOperationException = __K2L_Class("java.lang.UnsupportedOperationException", __K2L_RuntimeException)
local __K2L_ClassCastException = __K2L_Class("java.lang.ClassCastException", __K2L_RuntimeException)
local __K2L_NumberFormatException = __K2L_Class("java.lang.NumberFormatException", __K2L_IllegalArgumentException)
local __K2L_NoSuchElementException = __K2L_Class("java.util.NoSuchElementException", __K2L_RuntimeException)
local __K2L_NotImplementedError = __K2L_Class("kotlin.NotImplementedError", __K2L_Error)
local __K2L_AssertionError = __K2L_Class("java.lang.AssertionError", __K2L_Error)
local __K2L_VirtualMachineError = __K2L_Class("java.lang.VirtualMachineError", __K2L_Error)
-- Lua's "stack overflow" and "C stack overflow" errors (see ToThrowable.lua)
local __K2L_StackOverflowError = __K2L_Class("java.lang.StackOverflowError", __K2L_VirtualMachineError)
local __K2L_UninitializedPropertyAccessException = __K2L_Class("kotlin.UninitializedPropertyAccessException", __K2L_RuntimeException)

-- Kotlin's Throwable.addSuppressed (which ignores the exception itself): the exceptions are kept in `____suppressed`
-- (see Suppressed.lua)
function __K2L_Throwable:addSuppressed(exception)
    if exception == self then
        return
    end
    local suppressed = rawget(self, "____suppressed")
    if suppressed == nil then
        suppressed = {}
        rawset(self, "____suppressed", suppressed)
    end
    suppressed[#suppressed + 1] = exception
end

-- A read of an unset lateinit property or variable.
local function __K2L_Uninitialized(name)
    error(__K2L_UninitializedPropertyAccessException.new("lateinit property " .. name .. " has not been initialized"))
end
