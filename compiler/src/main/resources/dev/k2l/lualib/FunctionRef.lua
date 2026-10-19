-- requires: Class
-- A reference to a function whose `name` is read (`val f = ::greet; f.name`). Other references are plain Lua functions.
-- The object is callable, so it can be passed where a function is expected.
local __K2L_FunctionRef = __K2L_Class("kotlin.jvm.internal.FunctionReference")

function __K2L_FunctionRef:____init(name, fn)
    self.name = name
    self.____fn = fn
end

function __K2L_FunctionRef:invoke(...)
    return self.____fn(...)
end

function __K2L_FunctionRef:getName()
    return self.name
end

function __K2L_FunctionRef:toString()
    return "function " .. self.name
end

function __K2L_FunctionRef.__call(self, ...)
    return self.____fn(...)
end
