local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_LazyObject = ____lualib.__K2L_LazyObject
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str

local Square, Circle
local Shape = __K2L_Class("Shape")

function Shape:____initCompanion()
    print("Shape companion initialized")
    self.unit = Square.new(1)
    self.all = __K2L_ListOf(self.unit, Circle.new(2))
end

__K2L_LazyObject(Shape, "____initCompanion")
local Polygon = __K2L_Class("Polygon", nil, Shape)
local Regular = __K2L_Class("Regular", nil, Polygon)
Regular.____comparable = true

function Regular:compareTo(other)
    return __K2L_Compare(self:area(), other:area())
end

Square = __K2L_Class("Square", nil, Regular)

function Square:____init(side)
    self.side = side
    self.sides = 4
end

function Square:area()
    return self.side * self.side
end

Circle = __K2L_Class("Circle", nil, Shape)

function Circle.new(radius)
    return setmetatable({radius = radius}, Circle)
end

function Circle:area()
    return 3 * self.radius * self.radius
end

local function main()
    print("start")
    local square = Square.new(3)
    print(square:area())
    print(__K2L_InstanceOf(square, Shape))
    print(square.sides)
    print(__K2L_Compare(square, Square.new(2)) > 0)
    print(Shape.unit:area())
    local ____list = Shape.all
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = it:area()
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
end

__K2L_RunMain(main)
return {Shape = Shape, Polygon = Polygon, Regular = Regular, Square = Square, Circle = Circle}
