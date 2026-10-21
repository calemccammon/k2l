local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str

local ____exports = {}
local Person = __K2L_Class("Person")

function Person:____init(name, age)
    self.name = name
    self.age = age
end

function Person.new(name, age)
    return setmetatable({name = name, age = age}, Person)
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

local ____lambda_1 = function(receiver) return receiver.name end
local ____lambda_2 = function(receiver) return receiver.age end
local ____lambda_3 = function(receiver) return receiver.name end
local ____lambda_4 = function(receiver) return receiver.age end
local ____lambda_5 = function(receiver) return receiver.name end
local ____lambda_6 = function(receiver) return receiver.age end
local ____lambda_7 = function() return ____exports.counter end
local ____lambda_8 = function() return label end
local function main()
    local people = __K2L_ReadOnlyListOf(Person.new("ann", 30), Person.new("bob", 25))
    local nameRef = __K2L_PropertyRef.new("name", "name@124", ____lambda_1)
    local ageRef = __K2L_PropertyRef.new("age", "age@142", ____lambda_2, function(receiver, value)
        receiver.age = value
    end)
    print(nameRef.name)
    print(ageRef.name)
    print(nameRef:get(people:get(0)))
    print(nameRef:get(people:get(1)))
    print(ageRef:get(people:get(1)))
    ageRef:set(people:get(1), 26)
    print(people:get(1).age)
    print(__K2L_Str(people:map(__K2L_PropertyRef.new("name", "name@124", ____lambda_3))))
    print(people:sumOf(__K2L_PropertyRef.new("age", "age@142", ____lambda_4, function(receiver, value)
        receiver.age = value
    end)))
    print(describe(__K2L_PropertyRef.new("name", "name@124", ____lambda_5), people:get(0)))
    print(describe(__K2L_PropertyRef.new("age", "age@142", ____lambda_6, function(receiver, value)
        receiver.age = value
    end), people:get(1)))
    local ____receiver = people:get(0)
    local bound = __K2L_PropertyRef.new("name", "name@124", function() return ____receiver.name end, nil, ____receiver)
    print(bound.name)
    print(bound:get())
    print(bound:get())
    local ____receiver_1 = people:get(0)
    local boundAge = __K2L_PropertyRef.new("age", "age@142", function() return ____receiver_1.age end, function(value)
        ____receiver_1.age = value
    end, ____receiver_1)
    boundAge:set(31)
    print(people:get(0).age)
    local ____receiver_2 = Config
    print("level")
    local ____receiver_3 = Config
    print(__K2L_PropertyRef.new("level", "/Config.level", function() return ____receiver_3.level end, function(value)
        ____receiver_3.level = value
    end, ____receiver_3):get())
    print("counter")
    print(__K2L_PropertyRef.new("counter", "/counter", ____lambda_7, function(value)
        ____exports.counter = value
    end):get())
    print(__K2L_PropertyRef.new("label", "/label", ____lambda_8):get())
    print("twice")
    print("greet")
    local ____receiver_4 = people:get(0)
    print("greet")
    print(__K2L_Str(__K2L_ReadOnlyListOf(1, 2):map(twice)))
end

____exports.Person = Person
____exports.Config = Config
____exports.label = label
____exports.twice = twice
____exports.describe = describe
__K2L_Main(main)
return ____exports
