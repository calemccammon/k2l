local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_Str = ____lualib.__K2L_Str

local arrayOfShapes
local Shape = __K2L_Class("Shape")

function Shape:describe()
    return self.name .. " with area " .. __K2L_Str(self:area())
end

local Named = __K2L_Class("Named")

function Named:label()
    return "named"
end

local Polygon = __K2L_Class("Polygon", nil, Shape, Named)

function Polygon:____init(name, sides)
    self.name = name
    self.sides = sides
end

function Polygon:perimeterHint()
    return self.sides .. " sides"
end

function Polygon:label()
    return "polygon " .. Named.label(self)
end

local Rect = __K2L_Class("Rect", Polygon)

function Rect:____init(w, h)
    Polygon.____init(self, "rect", 4)
    self.w = w
    self.h = h
end

function Rect:area()
    return self.w * self.h
end

function Rect:perimeterHint()
    return "rectangle with " .. Polygon.perimeterHint(self)
end

local Square = __K2L_Class("Square", Rect)

function Square:____init(side)
    Rect.____init(self, side, side)
end

function Square:describe()
    return "square! " .. Shape.describe(self)
end

local Circle = __K2L_Class("Circle", nil, Shape)

function Circle:____init(r)
    self.r = r
    self.name = "circle"
end

function Circle:area()
    return 3.0 * self.r * self.r
end

local Animal = __K2L_Class("Animal")

function Animal:____init(sound)
    self.sound = sound
end

function Animal:speak()
    return "The animal says " .. self.sound
end

local Dog = __K2L_Class("Dog", Animal)

function Dog:____init1()
    Animal.____init(self, "woof")
end

function Dog.new1()
    local self = setmetatable({}, Dog)
    self:____init1()
    return self
end

function Dog:speak()
    return Animal.speak(self) .. "!"
end

local function kind(s)
    if __K2L_InstanceOf(s, Square) then
        return "square"
    elseif __K2L_InstanceOf(s, Rect) then
        return "rect " .. __K2L_Str(s.w) .. "x" .. __K2L_Str(s.h)
    elseif __K2L_InstanceOf(s, Circle) then
        return "circle r=" .. __K2L_Str(s.r)
    else
        return "unknown"
    end
end

local function main()
    local shapes = arrayOfShapes()
    print(shapes:describe())
    local r = Rect.new(2.0, 3.0)
    print(r:describe())
    print(r:perimeterHint())
    print(r:label())
    local sq = Square.new(2.0)
    print(sq:describe())
    print(Circle.new(1.0):describe())
    print(kind(sq))
    print(kind(r))
    print(kind(Circle.new(2.0)))
    print(__K2L_InstanceOf(sq, Polygon))
    print(__K2L_InstanceOf(sq, Named))
    local shape = Circle.new(1.0)
    print(__K2L_InstanceOf(shape, Polygon))
    local asRect = __K2L_InstanceOf(shape, Rect) and shape or nil
    print(asRect == nil)
    print(Dog.new1():speak())
end

function arrayOfShapes()
    return Rect.new(1.0, 1.0)
end

main()
return {Shape = Shape, Named = Named, Polygon = Polygon, Rect = Rect, Square = Square, Circle = Circle, Animal = Animal, Dog = Dog, kind = kind, arrayOfShapes = arrayOfShapes}
