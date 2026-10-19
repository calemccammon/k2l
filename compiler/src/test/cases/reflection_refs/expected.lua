local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_Str = ____lualib.__K2L_Str

local ____exports = {}
local Person = __K2L_Class("Person")

function Person:____init(name, age)
    self.name = name
    self.age = age
end

function Person:greet(other)
    return "hi " .. other .. " from " .. self.name
end

local Config = __K2L_Class("Config")

function Config:____init()
    self.level = 3
    self.title = "cfg"
end

Config:____init()
____exports.counter = 10
local label = "top"

local function twice(x)
    return x * 2
end

local function describe(p, who)
    return p.name .. "=" .. __K2L_Str(p:get(who))
end

local function main()
    local people = __K2L_ListOf(Person.new("ann", 30), Person.new("bob", 25))
    local nameRef = __K2L_PropertyRef.new("name", function(receiver) return receiver.name end)
    local ageRef = __K2L_PropertyRef.new("age", function(receiver) return receiver.age end, function(receiver, value)
        receiver.age = value
    end)
    print(nameRef.name)
    print(ageRef.name)
    print(nameRef:get(people:get(0)))
    print(nameRef:get(people:get(1)))
    print(ageRef:get(people:get(1)))
    ageRef:set(people:get(1), 26)
    print(people:get(1).age)
    print(__K2L_Str(people:map(__K2L_PropertyRef.new("name", function(receiver) return receiver.name end))))
    print(people:sumOf(__K2L_PropertyRef.new("age", function(receiver) return receiver.age end, function(receiver, value)
        receiver.age = value
    end)))
    print(describe(__K2L_PropertyRef.new("name", function(receiver) return receiver.name end), people:get(0)))
    print(describe(__K2L_PropertyRef.new("age", function(receiver) return receiver.age end, function(receiver, value)
        receiver.age = value
    end), people:get(1)))
    local ____receiver = people:get(0)
    local bound = __K2L_PropertyRef.new("name", function() return ____receiver.name end)
    print(bound.name)
    print(bound:get())
    print(bound:get())
    local ____receiver_1 = people:get(0)
    local boundAge = __K2L_PropertyRef.new("age", function() return ____receiver_1.age end, function(value)
        ____receiver_1.age = value
    end)
    boundAge:set(31)
    print(people:get(0).age)
    local ____receiver_2 = Config
    print("level")
    local ____receiver_3 = Config
    print(__K2L_PropertyRef.new("level", function() return ____receiver_3.level end, function(value)
        ____receiver_3.level = value
    end):get())
    print("counter")
    print(__K2L_PropertyRef.new("counter", function() return ____exports.counter end, function(value)
        ____exports.counter = value
    end):get())
    print(__K2L_PropertyRef.new("label", function() return label end):get())
    print("twice")
    print("greet")
    local ____receiver_4 = people:get(0)
    print("greet")
    print(__K2L_Str(__K2L_ListOf(1, 2):map(twice)))
end

____exports.Person = Person
____exports.Config = Config
____exports.label = label
____exports.twice = twice
____exports.describe = describe
main()
return ____exports
