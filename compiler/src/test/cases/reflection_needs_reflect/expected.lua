local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
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

function Person.new(name, age)
    return setmetatable({name = name, age = age}, Person)
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
    local ____ok, ____result = __K2L_DeepPcall(function()
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

local ____lambda_1 = function()
    return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice))
end
local ____lambda_2 = function()
    return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice))
end
local ____lambda_3 = function()
    return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice))
end
local ____lambda_4 = function()
    return __K2L_NeedsReflect(__K2L_FunctionRef.new("later", "/later()", later))
end
local ____lambda_5 = function()
    return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice), 2)
end
local ____lambda_6 = function()
    return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice), __K2L_ReadOnlyMapOf())
end
local ____lambda_7 = function()
    return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice))
end
local ____lambda_8 = function()
    return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice))
end
local ____lambda_9 = function()
    return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice))
end
local ____lambda_10 = function()
    return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice))
end
local ____lambda_11 = function()
    return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice))
end
local ____lambda_12 = function()
    return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice))
end
local ____lambda_13 = function()
    return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice))
end
local ____lambda_14 = function()
    return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice))
end
local ____lambda_15 = function()
    return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice))
end
local ____lambda_16 = function()
    return __K2L_NeedsReflect(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice))
end
local ____lambda_17 = function(self, ...) return self:greet(...) end
local ____lambda_18 = function()
    return __K2L_NeedsReflect(__K2L_FunctionRef.new("greet", "/Person.greet(kotlin.String)", ____lambda_17))
end
local ____lambda_19 = function()
    return __K2L_NeedsReflect(__K2L_FunctionRef.new("<init>", "/Person.<init>(kotlin.String,kotlin.Int)", Person.new))
end
local ____lambda_20 = function() return "<init>" end
local ____lambda_21 = function() return "twice" end
local ____lambda_22 = function(receiver) return receiver.name end
local ____lambda_23 = function()
    return __K2L_NeedsReflect(__K2L_PropertyRef.new("name", "name@257", ____lambda_22))
end
local ____lambda_24 = function(receiver) return receiver.name end
local ____lambda_25 = function()
    return __K2L_NeedsReflect(__K2L_PropertyRef.new("name", "name@257", ____lambda_24))
end
local ____lambda_26 = function(receiver) return receiver.age end
local ____lambda_27 = function()
    return __K2L_NeedsReflect(__K2L_PropertyRef.new("age", "age@275", ____lambda_26, function(receiver, value)
        receiver.age = value
    end))
end
local ____lambda_28 = function(receiver) return receiver.name end
local ____lambda_29 = function()
    return __K2L_NeedsReflect(__K2L_PropertyRef.new("name", "name@257", ____lambda_28), Person.new("bob", 1))
end
local ____lambda_30 = function(receiver) return receiver.name end
local ____lambda_31 = function()
    return __K2L_NeedsReflect(__K2L_PropertyRef.new("name", "name@257", ____lambda_30))
end
local ____lambda_32 = function(receiver) return receiver.name end
local ____lambda_33 = function()
    return __K2L_NeedsReflect(__K2L_PropertyRef.new("name", "name@257", ____lambda_32))
end
local ____lambda_34 = function(receiver) return receiver.name end
local ____lambda_35 = function()
    return __K2L_NeedsReflect(__K2L_PropertyRef.new("name", "name@257", ____lambda_34))
end
local ____lambda_36 = function(receiver) return receiver.name end
local ____lambda_37 = function()
    return __K2L_NeedsReflect(__K2L_PropertyRef.new("name", "name@257", ____lambda_36), Person.new("bob", 1))
end
local ____lambda_38 = function() return LIMIT end
local ____lambda_39 = function()
    return __K2L_NeedsReflect(__K2L_PropertyRef.new("LIMIT", "/LIMIT", ____lambda_38))
end
local ____lambda_40 = function() return ____exports.late end
local ____lambda_41 = function()
    return __K2L_NeedsReflect(__K2L_PropertyRef.new("late", "/late", ____lambda_40, function(value)
        ____exports.late = value
    end))
end
local ____lambda_42 = function() return ____exports.counter end
local ____lambda_43 = function()
    return __K2L_NeedsReflect(__K2L_PropertyRef.new("counter", "/counter", ____lambda_42, function(value)
        ____exports.counter = value
    end))
end
local ____lambda_44 = function() return ____exports.counter end
local ____lambda_45 = function()
    return __K2L_NeedsReflect(__K2L_PropertyRef.new("counter", "/counter", ____lambda_44, function(value)
        ____exports.counter = value
    end))
end
local ____lambda_46 = function() return "age" end
local ____lambda_47 = function(____p1) return ____p1:upper() end
local ____lambda_48 = function(____p1) return #____p1 end
local ____lambda_49 = function()
    return __K2L_NeedsReflect(__K2L_PropertyRef.new("length", "kotlin/String.length", ____lambda_48))
end
local ____lambda_50 = function(____p1) return #____p1 end
local ____lambda_51 = function()
    return __K2L_NeedsReflect(__K2L_PropertyRef.new("length", "kotlin/String.length", ____lambda_50))
end
local ____lambda_52 = function() return "length" end
local function main()
    probe("parameters", ____lambda_1)
    probe("returnType", ____lambda_2)
    probe("isSuspend", ____lambda_3)
    probe("suspend isSuspend", ____lambda_4)
    probe("call", ____lambda_5)
    probe("callBy", ____lambda_6)
    probe("visibility", ____lambda_7)
    probe("isOpen", ____lambda_8)
    probe("isFinal", ____lambda_9)
    probe("isAbstract", ____lambda_10)
    probe("isInline", ____lambda_11)
    probe("isExternal", ____lambda_12)
    probe("isOperator", ____lambda_13)
    probe("isInfix", ____lambda_14)
    probe("typeParameters", ____lambda_15)
    probe("annotations", ____lambda_16)
    probe("method parameters", ____lambda_18)
    probe("constructor parameters", ____lambda_19)
    probe("constructor name", ____lambda_20)
    probe("name", ____lambda_21)
    probe("bound method returnType", function()
        local ____receiver = person()
        return __K2L_NeedsReflect(__K2L_FunctionRef.new("greet", "/Person.greet(kotlin.String)", function(...) return ____receiver:greet(...) end, ____receiver))
    end)
    print("receiver evaluated " .. ____exports.evaluated .. " time(s)")
    probe("property returnType", ____lambda_23)
    probe("property getter", ____lambda_25)
    probe("property setter", ____lambda_27)
    probe("property call", ____lambda_29)
    probe("property parameters", ____lambda_31)
    probe("property visibility", ____lambda_33)
    probe("property isSuspend", ____lambda_35)
    probe("property getDelegate", ____lambda_37)
    probe("isConst", ____lambda_39)
    probe("isLateinit", ____lambda_41)
    probe("top-level getter", ____lambda_43)
    probe("top-level setter", ____lambda_45)
    probe("property name", ____lambda_46)
    local f = __K2L_FunctionRef.new("uppercase", "kotlin.String.kotlin/text/uppercase()", ____lambda_47)
    probe("library function name", function() return f.name end)
    probe("library function parameters", function() return __K2L_NeedsReflect(f) end)
    probe("library function returnType", function() return __K2L_NeedsReflect(f) end)
    probe("library property returnType", ____lambda_49)
    probe("library property getter", ____lambda_51)
    probe("library property name", ____lambda_52)
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
__K2L_DeepMain(main)
return ____exports
