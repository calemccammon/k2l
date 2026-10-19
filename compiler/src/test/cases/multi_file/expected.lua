-- ==== main.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str

local ____shapes = require("model.shapes")
local ____strings = require("util.strings")
local ____even = require("parity.even")
local Circle = __K2L_Class("app.Circle", ____shapes.Shape)

function Circle:____init(r)
    ____shapes.Shape.____init(self, "circle")
    self.r = r
end

function Circle:area()
    return 3.0 * self.r * self.r
end

local function main()
    print(____strings.shout(____strings.GREETING))
    ____strings.counted()
    ____strings.counted()
    print(____strings.calls)
    local shapes = __K2L_ReadOnlyListOf(____shapes.Square.new(2.0), Circle.new(1.0))
    for _, s in ipairs(shapes) do
        print(s.name .. ": " .. __K2L_Str(s:area()) .. " " .. s:describe())
    end
    ____shapes.Registry:add(____shapes.Square.new(3.0))
    print(____shapes.Registry:count())
    print(____shapes.Color.GREEN.ordinal)
    local p = ____shapes.Point.new(1, 2)
    print(__K2L_Str(____shapes.Point.new(p.x, 5)))
    print(____strings.twice(5))
    print(____even.isEven(10))
    print(____even.isEven(7))
end

main()
return {Circle = Circle}
-- ==== model/shapes.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32

local Shape = __K2L_Class("app.model.Shape")

function Shape:____init(name)
    self.name = name
end

function Shape:area()
    return 0.0
end

function Shape:describe()
    return "<" .. self.name .. ">"
end

local Square = __K2L_Class("app.model.Square", Shape)

function Square:____init(side)
    Shape.____init(self, "square")
    self.side = side
end

function Square:area()
    return self.side * self.side
end

local Registry = __K2L_Class("app.model.Registry")

function Registry:____init()
    self.shapes = __K2L_ListOf()
end

function Registry:add(s)
    self.shapes:add(s)
end

function Registry:count()
    return self.shapes.size
end

Registry:____init()
local Color = __K2L_Class("app.model.Color")

function Color:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Color:toString()
    return self.name
end

Color.RED = Color.new("RED", 0)
Color.GREEN = Color.new("GREEN", 1)
Color.____values = {Color.RED, Color.GREEN}
local Point = __K2L_Class("app.model.Point")

function Point:____init(x, y)
    self.x = x
    self.y = y
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

return {Shape = Shape, Square = Square, Registry = Registry, Color = Color, Point = Point}
-- ==== parity/even.lua ====
local ____exports = {}
package.loaded["parity.even"] = ____exports
local ____odd = require("parity.odd")

local function isEven(n)
    if n == 0 then
        return true
    else
        return ____odd.isOdd(n - 1)
    end
end

____exports.isEven = isEven
return ____exports
-- ==== parity/odd.lua ====
local ____exports = {}
package.loaded["parity.odd"] = ____exports
local ____even = require("parity.even")

local function isOdd(n)
    if n == 0 then
        return false
    else
        return ____even.isEven(n - 1)
    end
end

____exports.isOdd = isOdd
return ____exports
-- ==== util/strings.lua ====
local ____exports = {}
local GREETING = "hello"
____exports.calls = 0

local function counted()
    ____exports.calls = ____exports.calls + 1
    return ____exports.calls
end

local function shout(s)
    return s:upper() .. "!"
end

local function twice(self)
    return self * 2
end

____exports.GREETING = GREETING
____exports.counted = counted
____exports.shout = shout
____exports.twice = twice
return ____exports
