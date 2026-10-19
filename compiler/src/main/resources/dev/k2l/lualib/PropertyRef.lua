-- requires: Class
-- Property references (`Person::name`, `obj::age`, `::counter`): an object with the property's name and its accessors.
-- An unbound reference's accessors take the receiver first; a bound one's close over it. It is callable like the
-- JVM's KProperty1/KProperty0, so it can be passed where a function is expected.
local __K2L_PropertyRef = __K2L_Class("kotlin.jvm.internal.PropertyReference")

function __K2L_PropertyRef:____init(name, getter, setter)
    self.name = name
    self.____getter = getter
    self.____setter = setter
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
    return "property " .. self.name
end

function __K2L_PropertyRef.__call(self, ...)
    return self.____getter(...)
end
