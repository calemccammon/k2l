-- requires: Class, Equals, Hash
-- A reference to a function that the program looks at as an object (`val f = ::greet; f.name`, `println(f)`, `f == g`).
-- Other references are plain Lua functions. The object is callable, so it can be passed where a function is expected.
-- `key` names the function and its signature; with the bound receiver it makes `==` and `hashCode` match the JVM's.
local __K2L_FunctionRef = __K2L_Class("kotlin.jvm.internal.FunctionReference")

function __K2L_FunctionRef:____init(name, key, fn, receiver)
    self.name = name
    self.____key = key
    self.____fn = fn
    self.____receiver = receiver
end

function __K2L_FunctionRef:invoke(...)
    return self.____fn(...)
end

function __K2L_FunctionRef:getName()
    return self.name
end

function __K2L_FunctionRef:toString()
    if self.name == "<init>" then
        return "constructor (Kotlin reflection is not available)"
    end
    return "function " .. self.name .. " (Kotlin reflection is not available)"
end

function __K2L_FunctionRef:equals(other)
    return type(other) == "table" and getmetatable(other) == __K2L_FunctionRef and other.____key == self.____key
        and __K2L_Equals(self.____receiver, other.____receiver)
end

function __K2L_FunctionRef:hashCode()
    return __K2L_Hash(self.____key)
end

function __K2L_FunctionRef.__call(self, ...)
    return self.____fn(...)
end
