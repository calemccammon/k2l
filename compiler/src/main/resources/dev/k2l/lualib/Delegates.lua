-- requires: Class, Exceptions
-- kotlin.properties.Delegates. The `property` argument is a table with the property's `name`.
local ObservableProperty = __K2L_Class("kotlin.properties.ObservableProperty")

function ObservableProperty:____init(initial, onChange)
    self.value = initial
    self.onChange = onChange
end

function ObservableProperty:getValue()
    return self.value
end

function ObservableProperty:setValue(thisRef, property, newValue)
    local old = self.value
    self.value = newValue
    self.onChange(property, old, newValue)
end

local function __K2L_ObservableProperty(initial, onChange)
    return ObservableProperty.new(initial, onChange)
end

local VetoableProperty = __K2L_Class("kotlin.properties.ObservableProperty")

function VetoableProperty:____init(initial, beforeChange)
    self.value = initial
    self.beforeChange = beforeChange
end

function VetoableProperty:getValue()
    return self.value
end

function VetoableProperty:setValue(thisRef, property, newValue)
    if self.beforeChange(property, self.value, newValue) then
        self.value = newValue
    end
end

local function __K2L_VetoableProperty(initial, beforeChange)
    return VetoableProperty.new(initial, beforeChange)
end

local NotNullVar = __K2L_Class("kotlin.properties.NotNullVar")

function NotNullVar:getValue(thisRef, property)
    if self.value == nil then
        error(__K2L_IllegalStateException.new("Property " .. property.name .. " should be initialized before get."))
    end
    return self.value
end

function NotNullVar:setValue(thisRef, property, newValue)
    self.value = newValue
end

local function __K2L_NotNullProperty()
    return NotNullVar.new()
end

local ReadOnlyProperty = __K2L_Class("kotlin.properties.ReadOnlyProperty")

function ReadOnlyProperty:____init(getter)
    self.getter = getter
end

function ReadOnlyProperty:getValue(thisRef, property)
    return self.getter(thisRef, property)
end

local function __K2L_ReadOnlyProperty(getter)
    return ReadOnlyProperty.new(getter)
end

-- the SAM constructor PropertyDelegateProvider { thisRef, property -> delegate }
local DelegateProvider = __K2L_Class("kotlin.properties.PropertyDelegateProvider")

function DelegateProvider:____init(provide)
    self.provide = provide
end

function DelegateProvider:provideDelegate(thisRef, property)
    return self.provide(thisRef, property)
end

local function __K2L_DelegateProvider(provide)
    return DelegateProvider.new(provide)
end
