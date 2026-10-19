local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_FunctionRef = ____lualib.__K2L_FunctionRef
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_KProperty = ____lualib.__K2L_KProperty
local __K2L_NeedsReflect = ____lualib.__K2L_NeedsReflect
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local ____exports = {}
local Person = __K2L_Class("Person")
__K2L_ClassInfo(Person, "Person", "Person", "class")

function Person:____init(name, age)
    self.name = name
    self.age = age
end

function Person:greet(other)
    return "hi " .. other
end

local function twice(x)
    return x * 2
end

local function later()
    return 1
end

____exports.counter = 1
local LIMIT = 3

local function probe(what, f)
    local ____ok, ____result = pcall(function()
        print(what .. " = " .. __K2L_Str(f()))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        local e = ____error
        print(what .. " threw " .. __K2L_Str(__K2L_KClassOfValue(e).simpleName) .. ": " .. __K2L_Str(e.message))
    end
end

____exports.evaluated = 0

local function person()
    ____exports.evaluated = ____exports.evaluated + 1
    return Person.new("ann", 30)
end

local Logged = __K2L_Class("Logged")
__K2L_ClassInfo(Logged, "Logged", "Logged", "class")

function Logged:getValue(thisRef, property)
    print("get " .. property.name .. ": " .. __K2L_Str(property))
    probe("delegate returnType", function() return __K2L_NeedsReflect(property) end)
    probe("delegate getter", function() return __K2L_NeedsReflect(property) end)
    probe("delegate isConst", function() return __K2L_NeedsReflect(property) end)
    probe("delegate annotations", function() return __K2L_NeedsReflect(property) end)
    return 1
end

function Logged:setValue(thisRef, property, value)
    print("set " .. property.name .. " = " .. value .. ": " .. __K2L_Str(property))
end

local Holder = __K2L_Class("Holder")
__K2L_ClassInfo(Holder, "Holder", "Holder", "class")

function Holder:____init()
    self.____x_delegate = Logged.new()
    self.____y_delegate = Logged.new()
end

Holder.____x_property = __K2L_PropertyRef.new("x", "/Holder.x")

function Holder:getX()
    return self.____x_delegate:getValue(self, Holder.____x_property)
end

Holder.____y_property = __K2L_PropertyRef.new("y", "/Holder.y")

function Holder:getY()
    return self.____y_delegate:getValue(self, Holder.____y_property)
end

function Holder:setY(value)
    self.____y_delegate:setValue(self, Holder.____y_property, value)
end

local ____top_delegate = Logged.new()

local function main()
    probe("parameters", function()
        return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice))
    end)
    probe("returnType", function()
        return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice))
    end)
    probe("isSuspend", function()
        return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice))
    end)
    probe("suspend isSuspend", function()
        return __K2L_NeedsReflect(__K2L_FunctionRef.new("later", "/later()", later))
    end)
    probe("call", function()
        return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice), 2)
    end)
    probe("callBy", function()
        return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice), __K2L_ReadOnlyMapOf())
    end)
    probe("visibility", function()
        return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice))
    end)
    probe("isOpen", function()
        return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice))
    end)
    probe("isFinal", function()
        return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice))
    end)
    probe("isAbstract", function()
        return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice))
    end)
    probe("isInline", function()
        return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice))
    end)
    probe("isExternal", function()
        return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice))
    end)
    probe("isOperator", function()
        return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice))
    end)
    probe("isInfix", function()
        return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice))
    end)
    probe("typeParameters", function()
        return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice))
    end)
    probe("annotations", function()
        return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice))
    end)
    probe("method parameters", function()
        return __K2L_NeedsReflect(__K2L_FunctionRef.new("greet", "/Person.greet(kotlin.String)", function(self, ...) return self:greet(...) end))
    end)
    probe("constructor parameters", function()
        return __K2L_NeedsReflect(__K2L_FunctionRef.new("<init>", "/Person.<init>(kotlin.String,kotlin.Int)", Person.new))
    end)
    probe("constructor name", function() return "<init>" end)
    probe("name", function() return "twice" end)
    probe("bound method returnType", function()
        local ____receiver = person()
        return __K2L_NeedsReflect(__K2L_FunctionRef.new("greet", "/Person.greet(kotlin.String)", function(...) return ____receiver:greet(...) end, ____receiver))
    end)
    print("receiver evaluated " .. ____exports.evaluated .. " time(s)")
    probe("property returnType", function()
        return __K2L_NeedsReflect(__K2L_PropertyRef.new("name", "name@257", function(receiver) return receiver.name end))
    end)
    probe("property getter", function()
        return __K2L_NeedsReflect(__K2L_PropertyRef.new("name", "name@257", function(receiver) return receiver.name end))
    end)
    probe("property setter", function()
        return __K2L_NeedsReflect(__K2L_PropertyRef.new("age", "age@275", function(receiver) return receiver.age end, function(receiver, value)
            receiver.age = value
        end))
    end)
    probe("property call", function()
        return __K2L_NeedsReflect(__K2L_PropertyRef.new("name", "name@257", function(receiver) return receiver.name end), Person.new("bob", 1))
    end)
    probe("property parameters", function()
        return __K2L_NeedsReflect(__K2L_PropertyRef.new("name", "name@257", function(receiver) return receiver.name end))
    end)
    probe("property visibility", function()
        return __K2L_NeedsReflect(__K2L_PropertyRef.new("name", "name@257", function(receiver) return receiver.name end))
    end)
    probe("property isSuspend", function()
        return __K2L_NeedsReflect(__K2L_PropertyRef.new("name", "name@257", function(receiver) return receiver.name end))
    end)
    probe("property getDelegate", function()
        return __K2L_NeedsReflect(__K2L_PropertyRef.new("name", "name@257", function(receiver) return receiver.name end), Person.new("bob", 1))
    end)
    probe("isConst", function()
        return __K2L_NeedsReflect(__K2L_PropertyRef.new("LIMIT", "/LIMIT", function() return LIMIT end))
    end)
    probe("isLateinit", function()
        return __K2L_NeedsReflect(__K2L_PropertyRef.new("late", "/late", function() return ____exports.late end, function(value)
            ____exports.late = value
        end))
    end)
    probe("top-level getter", function()
        return __K2L_NeedsReflect(__K2L_PropertyRef.new("counter", "/counter", function() return ____exports.counter end, function(value)
            ____exports.counter = value
        end))
    end)
    probe("top-level setter", function()
        return __K2L_NeedsReflect(__K2L_PropertyRef.new("counter", "/counter", function() return ____exports.counter end, function(value)
            ____exports.counter = value
        end))
    end)
    probe("property name", function() return "age" end)
    local f = __K2L_FunctionRef.new("uppercase", "kotlin.String.kotlin/text/uppercase()", function(____p1) return ____p1:upper() end)
    probe("library function name", function() return f.name end)
    probe("library function parameters", function() return __K2L_NeedsReflect(f) end)
    probe("library function returnType", function() return __K2L_NeedsReflect(f) end)
    probe("library property returnType", function()
        return __K2L_NeedsReflect(__K2L_PropertyRef.new("length", "kotlin/String.length", function(____p1) return #____p1 end))
    end)
    probe("library property getter", function()
        return __K2L_NeedsReflect(__K2L_PropertyRef.new("length", "kotlin/String.length", function(____p1) return #____p1 end))
    end)
    probe("library property name", function() return "length" end)
    local holder = Holder.new()
    print(holder:getX())
    holder:setY(5)
    print(holder:getY())
    print(____top_delegate:getValue(nil, __K2L_KProperty("top", "/top")))
end

____exports.Person = Person
____exports.twice = twice
____exports.later = later
____exports.LIMIT = LIMIT
____exports.probe = probe
____exports.person = person
____exports.Logged = Logged
____exports.Holder = Holder
____exports.____top_delegate = ____top_delegate
main()
return ____exports
