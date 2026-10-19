-- requires: Class, Equals, Hash, Exceptions
-- Property references (`Person::name`, `obj::age`, `::counter`, `String::length`) and the `KProperty` passed to delegates: an
-- object with the property's name and its accessors. An unbound reference's accessors take the receiver first; a bound one's
-- close over it. It is callable like the JVM's KProperty1/KProperty0, so it can be passed where a function is expected.
-- `key` names the property (`Person.name`), and with the bound receiver it makes `==` and `hashCode` match the JVM's.
local __K2L_PropertyRef = __K2L_Class("kotlin.jvm.internal.PropertyReference")

-- The KProperty passed to a delegate has no accessors; only an unchecked cast reaches them.
local function noAccessor()
    error(__K2L_UnsupportedOperationException.new("The accessors of the KProperty passed to a delegate are not supported by k2l"))
end

function __K2L_PropertyRef:____init(name, key, getter, setter, receiver)
    self.name = name
    self.____key = key
    self.____getter = getter or noAccessor
    self.____setter = setter or noAccessor
    self.____receiver = receiver
end

function __K2L_PropertyRef:get(...)
    return self.____getter(...)
end

function __K2L_PropertyRef:set(...)
    return self.____setter(...)
end

function __K2L_PropertyRef:invoke(...)
    return self.____getter(...)
end

function __K2L_PropertyRef:getName()
    return self.name
end

function __K2L_PropertyRef:toString()
    return "property " .. self.name .. " (Kotlin reflection is not available)"
end

function __K2L_PropertyRef:equals(other)
    return type(other) == "table" and getmetatable(other) == __K2L_PropertyRef and other.____key == self.____key
        and __K2L_Equals(self.____receiver, other.____receiver)
end

function __K2L_PropertyRef:hashCode()
    return __K2L_Hash(self.____key)
end

function __K2L_PropertyRef.__call(self, ...)
    return self.____getter(...)
end

-- The KProperty passed to the delegate of a top-level or local property: one object per property, not one per access.
local __K2L_KPropertyCache = {}

local function __K2L_KProperty(name, key)
    local property = __K2L_KPropertyCache[key]
    if property == nil then
        property = __K2L_PropertyRef.new(name, key)
        __K2L_KPropertyCache[key] = property
    end
    return property
end
