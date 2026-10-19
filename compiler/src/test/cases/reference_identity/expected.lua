local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_FunctionRef = ____lualib.__K2L_FunctionRef
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_KProperty = ____lualib.__K2L_KProperty
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32

local ____exports = {}
local Person = __K2L_Class("Person")

function Person:____init(name, age)
    self.name = name
    self.age = age
end

function Person:greet(other)
    return "hi " .. other .. " from " .. self.name
end

local Point = __K2L_Class("Point")

function Point:____init(x, y)
    self.x = x
    self.y = y
end

function Point:norm()
    return self.x * self.x + self.y * self.y
end

function Point:toString()
    return "Point(x=" .. self.x .. ", y=" .. self.y .. ")"
end

function Point:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.x) + __K2L_Hash(self.y))
end

function Point:equals(other)
    return getmetatable(other) == Point and self.x == other.x and self.y == other.y
end

local Config = __K2L_Class("Config")

function Config:____init()
    self.level = 3
end

Config:____init()
____exports.counter = 10

local function twice(x)
    return x * 2
end

local function twice__1(s)
    return s .. s
end

local function negate(x)
    return -x
end

local function getShout(self)
    return self:upper() .. "!"
end

local Seen = __K2L_Class("Seen")

function Seen:____init()
    self.last = nil
end

function Seen:getValue(thisRef, property)
    self.last = property
    return __K2L_Str(property)
end

local seen = Seen.new()
local Box = __K2L_Class("Box")

function Box:____init()
    self.____content_delegate = seen
    self.____other_delegate = seen
end

Box.____content_property = __K2L_PropertyRef.new("content", "/Box.content")

function Box:getContent()
    return self.____content_delegate:getValue(self, Box.____content_property)
end

Box.____other_property = __K2L_PropertyRef.new("other", "/Box.other")

function Box:getOther()
    return self.____other_delegate:getValue(self, Box.____other_property)
end

local ____topLevel_delegate = seen

local function main()
    print(__K2L_Str(__K2L_PropertyRef.new("name", "name@292", function(receiver) return receiver.name end)))
    local ____receiver = Person.new("a", 1)
    print(__K2L_Str(__K2L_PropertyRef.new("age", "age@310", function() return ____receiver.age end, function(value)
        ____receiver.age = value
    end, ____receiver)))
    print(__K2L_Str(__K2L_PropertyRef.new("counter", "/counter", function() return ____exports.counter end, function(value)
        ____exports.counter = value
    end)))
    local ____receiver_1 = Config
    print(__K2L_Str(__K2L_PropertyRef.new("level", "/Config.level", function() return ____receiver_1.level end, function(value)
        ____receiver_1.level = value
    end, ____receiver_1)))
    print(__K2L_Str(__K2L_PropertyRef.new("shout", "kotlin.String./shout", getShout)))
    print(__K2L_Str(__K2L_PropertyRef.new("shout", "kotlin.String./shout", function() return getShout("x") end, nil, "x")))
    print(__K2L_Str(__K2L_PropertyRef.new("length", "kotlin/String.length", function(____p1) return #____p1 end)))
    print(__K2L_Str(__K2L_PropertyRef.new("length", "kotlin/String.length", function() return #"abc" end, nil, "abc")))
    print(__K2L_Str(__K2L_PropertyRef.new("size", "kotlin/collections/List.size", function(____p1) return ____p1.size end)))
    local t = __K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice)
    print(__K2L_Str(t))
    print(__K2L_Str(__K2L_FunctionRef.new("greet", "/Person.greet(kotlin.String)", function(self, ...) return self:greet(...) end)))
    print(__K2L_Str(__K2L_FunctionRef.new("negate", "/negate(kotlin.Int)", negate)))
    print(__K2L_Str(__K2L_FunctionRef.new("<init>", "/Person.<init>(kotlin.String,kotlin.Int)", Person.new)))
    local up = __K2L_FunctionRef.new("uppercase", "kotlin.String.kotlin/text/uppercase()", function(____p1) return ____p1:upper() end)
    print(__K2L_Str(up))
    local pl = __K2L_FunctionRef.new("plus", "kotlin/Int.plus(kotlin.Int)", function(____p1, ____p2) return ____p1 + ____p2 end)
    print(__K2L_Str(pl))
    local ____receiver_2 = __K2L_SingletonListOf(1)
    print(__K2L_Str(__K2L_FunctionRef.new("contains", "kotlin/collections/List.contains(E)", function(____p1) return ____receiver_2:contains(____p1) end, ____receiver_2)))
    local callables = __K2L_ReadOnlyListOf(__K2L_FunctionRef.new("negate", "/negate(kotlin.Int)", negate), __K2L_PropertyRef.new("name", "name@292", function(receiver) return receiver.name end), __K2L_PropertyRef.new("length", "kotlin/String.length", function(____p1) return #____p1 end))
    print(__K2L_Str(callables))
    print(__K2L_Equals(__K2L_PropertyRef.new("name", "name@292", function(receiver) return receiver.name end), __K2L_PropertyRef.new("name", "name@292", function(receiver) return receiver.name end)))
    print(__K2L_Equals(__K2L_PropertyRef.new("name", "name@292", function(receiver) return receiver.name end), __K2L_PropertyRef.new("age", "age@310", function(receiver) return receiver.age end, function(receiver, value)
        receiver.age = value
    end)))
    local ann = Person.new("ann", 30)
    print(__K2L_Equals(__K2L_PropertyRef.new("name", "name@292", function() return ann.name end, nil, ann), __K2L_PropertyRef.new("name", "name@292", function() return ann.name end, nil, ann)))
    local ____arg = __K2L_PropertyRef.new("name", "name@292", function() return ann.name end, nil, ann)
    local ____receiver_3 = Person.new("ann", 30)
    print(__K2L_Equals(____arg, __K2L_PropertyRef.new("name", "name@292", function() return ____receiver_3.name end, nil, ____receiver_3)))
    local ____receiver_4 = Point.new(1, 2)
    local ____arg_1 = __K2L_PropertyRef.new("x", "x@400", function() return ____receiver_4.x end, nil, ____receiver_4)
    local ____receiver_5 = Point.new(1, 2)
    print(__K2L_Equals(____arg_1, __K2L_PropertyRef.new("x", "x@400", function() return ____receiver_5.x end, nil, ____receiver_5)))
    local ____receiver_6 = Point.new(1, 2)
    local ____arg_2 = __K2L_FunctionRef.new("norm", "/Point.norm()", function(...) return ____receiver_6:norm(...) end, ____receiver_6)
    local ____receiver_7 = Point.new(1, 2)
    print(__K2L_Equals(____arg_2, __K2L_FunctionRef.new("norm", "/Point.norm()", function(...) return ____receiver_7:norm(...) end, ____receiver_7)))
    local ____receiver_8 = Point.new(1, 2)
    local ____arg_3 = __K2L_FunctionRef.new("norm", "/Point.norm()", function(...) return ____receiver_8:norm(...) end, ____receiver_8)
    local ____receiver_9 = Point.new(2, 1)
    print(__K2L_Equals(____arg_3, __K2L_FunctionRef.new("norm", "/Point.norm()", function(...) return ____receiver_9:norm(...) end, ____receiver_9)))
    local ____receiver_10 = Config
    local ____arg_4 = __K2L_PropertyRef.new("level", "/Config.level", function() return ____receiver_10.level end, function(value)
        ____receiver_10.level = value
    end, ____receiver_10)
    local ____receiver_11 = Config
    print(__K2L_Equals(____arg_4, __K2L_PropertyRef.new("level", "/Config.level", function() return ____receiver_11.level end, function(value)
        ____receiver_11.level = value
    end, ____receiver_11)))
    print(__K2L_Equals(__K2L_PropertyRef.new("counter", "/counter", function() return ____exports.counter end, function(value)
        ____exports.counter = value
    end), __K2L_PropertyRef.new("counter", "/counter", function() return ____exports.counter end, function(value)
        ____exports.counter = value
    end)))
    print(__K2L_Equals(__K2L_PropertyRef.new("length", "kotlin/String.length", function(____p1) return #____p1 end), __K2L_PropertyRef.new("length", "kotlin/String.length", function(____p1) return #____p1 end)))
    print(__K2L_Equals(__K2L_PropertyRef.new("length", "kotlin/String.length", function() return #"ab" end, nil, "ab"), __K2L_PropertyRef.new("length", "kotlin/String.length", function() return #"ab" end, nil, "ab")))
    print(__K2L_Equals(__K2L_PropertyRef.new("length", "kotlin/String.length", function() return #"ab" end, nil, "ab"), __K2L_PropertyRef.new("length", "kotlin/String.length", function() return #"cd" end, nil, "cd")))
    print(__K2L_Equals(__K2L_PropertyRef.new("shout", "kotlin.String./shout", getShout), __K2L_PropertyRef.new("shout", "kotlin.String./shout", getShout)))
    local t2 = __K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice)
    local ts = __K2L_FunctionRef.new("twice", "/twice(kotlin.String)", twice__1)
    print(__K2L_Equals(t, t2))
    print(__K2L_Equals(t, ts))
    print(not __K2L_Equals(t, __K2L_FunctionRef.new("negate", "/negate(kotlin.Int)", negate)))
    print(__K2L_Equals(__K2L_FunctionRef.new("greet", "/Person.greet(kotlin.String)", function(self, ...) return self:greet(...) end), __K2L_FunctionRef.new("greet", "/Person.greet(kotlin.String)", function(self, ...) return self:greet(...) end)))
    print(__K2L_Equals(__K2L_FunctionRef.new("greet", "/Person.greet(kotlin.String)", function(...) return ann:greet(...) end, ann), __K2L_FunctionRef.new("greet", "/Person.greet(kotlin.String)", function(...) return ann:greet(...) end, ann)))
    local up2 = __K2L_FunctionRef.new("uppercase", "kotlin.String.kotlin/text/uppercase()", function(____p1) return ____p1:upper() end)
    print(__K2L_Equals(up, up2))
    local pName = __K2L_PropertyRef.new("name", "name@292", function(receiver) return receiver.name end)
    print(__K2L_Equals(pName, __K2L_PropertyRef.new("name", "name@292", function(receiver) return receiver.name end)))
    print(__K2L_ReadOnlyListOf(__K2L_FunctionRef.new("negate", "/negate(kotlin.Int)", negate), __K2L_FunctionRef.new("negate", "/negate(kotlin.Int)", negate)):distinct().size)
    print(__K2L_ReadOnlySetOf(__K2L_PropertyRef.new("name", "name@292", function(receiver) return receiver.name end), __K2L_PropertyRef.new("name", "name@292", function(receiver) return receiver.name end), __K2L_PropertyRef.new("age", "age@310", function(receiver) return receiver.age end, function(receiver, value)
        receiver.age = value
    end)).size)
    print(__K2L_Hash(__K2L_FunctionRef.new("negate", "/negate(kotlin.Int)", negate)) == __K2L_Hash(__K2L_FunctionRef.new("negate", "/negate(kotlin.Int)", negate)))
    print(__K2L_Hash(__K2L_PropertyRef.new("name", "name@292", function(receiver) return receiver.name end)) == __K2L_Hash(__K2L_PropertyRef.new("name", "name@292", function(receiver) return receiver.name end)))
    print(__K2L_Hash(__K2L_PropertyRef.new("length", "kotlin/String.length", function(____p1) return #____p1 end)) == __K2L_Hash(__K2L_PropertyRef.new("length", "kotlin/String.length", function(____p1) return #____p1 end)))
    local box = Box.new()
    print(box:getContent())
    print(__K2L_Equals(seen.last, __K2L_PropertyRef.new("content", "/Box.content", function(receiver) return receiver:getContent() end)))
    print(__K2L_Equals(seen.last, __K2L_PropertyRef.new("other", "/Box.other", function(receiver) return receiver:getOther() end)))
    print(box:getOther())
    print(__K2L_Equals(seen.last, __K2L_PropertyRef.new("other", "/Box.other", function(receiver) return receiver:getOther() end)))
    print(____topLevel_delegate:getValue(nil, __K2L_KProperty("topLevel", "/topLevel")))
    print(__K2L_Equals(seen.last, __K2L_PropertyRef.new("topLevel", "/topLevel", function()
        return ____topLevel_delegate:getValue(nil, __K2L_KProperty("topLevel", "/topLevel"))
    end)))
    local ____receiver_12 = seen.last
    print(__K2L_Str(____receiver_12 and ____receiver_12.name))
end

____exports.Person = Person
____exports.Point = Point
____exports.Config = Config
____exports.twice = twice
____exports.twice__1 = twice__1
____exports.negate = negate
____exports.getShout = getShout
____exports.Seen = Seen
____exports.seen = seen
____exports.Box = Box
____exports.____topLevel_delegate = ____topLevel_delegate
main()
return ____exports
