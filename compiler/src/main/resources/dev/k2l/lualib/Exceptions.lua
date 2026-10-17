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
local __K2L_ArithmeticException = __K2L_Class("java.lang.ArithmeticException", __K2L_RuntimeException)
local __K2L_UnsupportedOperationException = __K2L_Class("java.lang.UnsupportedOperationException", __K2L_RuntimeException)
local __K2L_ClassCastException = __K2L_Class("java.lang.ClassCastException", __K2L_RuntimeException)
local __K2L_NumberFormatException = __K2L_Class("java.lang.NumberFormatException", __K2L_IllegalArgumentException)
local __K2L_NoSuchElementException = __K2L_Class("java.util.NoSuchElementException", __K2L_RuntimeException)
local __K2L_ConcurrentModificationException = __K2L_Class("java.util.ConcurrentModificationException", __K2L_RuntimeException)
local __K2L_NotImplementedError = __K2L_Class("kotlin.NotImplementedError", __K2L_Error)
