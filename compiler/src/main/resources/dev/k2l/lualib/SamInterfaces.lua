-- requires: Class
-- Library interfaces with a single abstract method (Comparator, Runnable, Callable, the function types) are Lua callables:
-- a lambda is a plain function, and an object of a class implementing one is callable through __call, which runs the
-- method. Their tables are interfaces of the implementing class (Class copies __call), so `is Comparator` works too.
local __K2L_ComparatorMixin = __K2L_Class("java.util.Comparator")
local __K2L_RunnableMixin = __K2L_Class("java.lang.Runnable")
local __K2L_CallableMixin = __K2L_Class("java.util.concurrent.Callable")
local __K2L_FunctionMixin = __K2L_Class("kotlin.Function")

__K2L_ComparatorMixin.__call = function(self, a, b) return self:compare(a, b) end
__K2L_RunnableMixin.__call = function(self) return self:run() end
__K2L_CallableMixin.__call = function(self) return self:call() end
__K2L_FunctionMixin.__call = function(self, ...) return self:invoke(...) end

-- `Check { x -> ... }` for a `fun interface Check` of the program: an object of the interface whose method calls `f`.
local function __K2L_FunInterface(cls, method, f)
    local object = setmetatable({}, cls)
    object[method] = function(_, ...)
        return f(...)
    end
    return object
end
