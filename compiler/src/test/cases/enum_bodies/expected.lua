local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_EnumValueOf = ____lualib.__K2L_EnumValueOf
local __K2L_EnumValues = ____lualib.__K2L_EnumValues
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Op = __K2L_Class("Op")

function Op:____init(name, ordinal, symbol)
    self.name = name
    self.ordinal = ordinal
    self.symbol = symbol
end

function Op:describe()
    return "op " .. self.symbol
end

function Op:toString()
    return self.name
end

function Op:compareTo(other)
    return self.ordinal - other.ordinal
end

do
    local ____PLUS = __K2L_Class("Op", Op)
    function ____PLUS:apply(a, b)
        return a + b
    end
    Op.PLUS = ____PLUS.new("PLUS", 0, "+")
end
do
    local ____TIMES = __K2L_Class("Op", Op)
    function ____TIMES:apply(a, b)
        return a * b
    end
    function ____TIMES:describe()
        return "multiply (" .. Op.describe(self) .. ")"
    end
    Op.TIMES = ____TIMES.new("TIMES", 1, "*")
end
do
    local ____MINUS = __K2L_Class("Op", Op)
    function ____MINUS:apply(a, b)
        return a - b
    end
    function ____MINUS:toString()
        return "minus!"
    end
    Op.MINUS = ____MINUS.new("MINUS", 2, "-")
end
Op.____values = {Op.PLUS, Op.TIMES, Op.MINUS}
local Level = __K2L_Class("Level")

function Level:____init(name, ordinal, weight)
    self.name = name
    self.ordinal = ordinal
    self.weight = weight
end

function Level:score()
    return self.weight
end

function Level:twice()
    return self:score() * 2
end

function Level:toString()
    return self.name
end

function Level:compareTo(other)
    return self.ordinal - other.ordinal
end

Level.LOW = Level.new("LOW", 0, 1)
do
    local ____MEDIUM = __K2L_Class("Level", Level)
    function ____MEDIUM:score()
        self.calls = self.calls + 1
        return self.weight * 10 + self.calls
    end
    function ____MEDIUM:____init(...)
        Level.____init(self, ...)
        self.calls = 0
        self.label = "mid-" .. self.weight
        self.calls = 100
    end
    Level.MEDIUM = ____MEDIUM.new("MEDIUM", 1, 5)
end
do
    local ____HIGH = __K2L_Class("Level", Level)
    function ____HIGH:score()
        return self.weight * 100
    end
    Level.HIGH = ____HIGH.new("HIGH", 2, 10)
end
Level.NONE = Level.new("NONE", 3, 0)
Level.____values = {Level.LOW, Level.MEDIUM, Level.HIGH, Level.NONE}
local Shape = __K2L_Class("Shape")

function Shape:____init(name, ordinal, sides)
    self.name = name
    self.ordinal = ordinal
    self.sides = sides
end

function Shape:____init1(name, ordinal, label)
    Shape.____init(self, name, ordinal, #label)
end

function Shape.new1(name, ordinal, label)
    local self = setmetatable({}, Shape)
    self:____init1(name, ordinal, label)
    return self
end

function Shape:name2()
    return "shape/" .. self.sides
end

function Shape:toString()
    return self.name
end

function Shape:compareTo(other)
    return self.ordinal - other.ordinal
end

Shape.DOT = Shape.new("DOT", 0, 1)
do
    local ____SQUARE = __K2L_Class("Shape", Shape)
    function ____SQUARE:name2()
        return "square/" .. self.doubled
    end
    function ____SQUARE:____init(...)
        Shape.____init(self, ...)
        self.doubled = self.sides * 2
    end
    Shape.SQUARE = ____SQUARE.new("SQUARE", 1, 4)
end
do
    local ____TRIANGLE = __K2L_Class("Shape", Shape)
    function ____TRIANGLE:name2()
        return "triangle/" .. self.sides
    end
    function ____TRIANGLE:____init(...)
        Shape.____init1(self, ...)
    end
    Shape.TRIANGLE = ____TRIANGLE.new("TRIANGLE", 2, "tri")
end
do
    local ____LINE = __K2L_Class("Shape", Shape)
    function ____LINE:name2()
        return "line"
    end
    function ____LINE:____init(...)
        Shape.____init1(self, ...)
    end
    Shape.LINE = ____LINE.new("LINE", 3, "ab")
end
Shape.____values = {Shape.DOT, Shape.SQUARE, Shape.TRIANGLE, Shape.LINE}
local Describable = __K2L_Class("Describable")
local Planet = __K2L_Class("Planet", nil, Describable)

function Planet:____init(name, ordinal, mass)
    self.name = name
    self.ordinal = ordinal
    self.mass = mass
end

function Planet:toString()
    return self.name
end

function Planet:compareTo(other)
    return self.ordinal - other.ordinal
end

do
    local ____EARTH = __K2L_Class("Planet", Planet)
    function ____EARTH:describe()
        return "home " .. self.mass
    end
    Planet.EARTH = ____EARTH.new("EARTH", 0, 5)
end
do
    local ____MARS = __K2L_Class("Planet", Planet)
    function ____MARS:describe()
        return "red " .. self.mass
    end
    Planet.MARS = ____MARS.new("MARS", 1, 1)
end
Planet.____values = {Planet.EARTH, Planet.MARS}
local Color = __K2L_Class("Color")

function Color:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Color:toString()
    return self.name
end

function Color:compareTo(other)
    return self.ordinal - other.ordinal
end

Color.RED = Color.new("RED", 0)
Color.GREEN = Color.new("GREEN", 1)
Color.____values = {Color.RED, Color.GREEN}

local function classify(op)
    if op == Op.PLUS then
        return "add"
    elseif op == Op.TIMES then
        return "mul"
    elseif op == Op.MINUS then
        return "sub"
    end
end

local function main()
    local ____list = __K2L_EnumValues(Op)
    for ____i = 1, ____list.size do
        local op = ____list[____i]
        print(op.name .. " " .. op.ordinal .. " " .. op.symbol .. " " .. op:apply(6, 3) .. " " .. op:describe() .. " " .. classify(op))
    end
    print(__K2L_Str(Op.PLUS))
    print(__K2L_Str(Op.MINUS))
    print(Op.MINUS.name)
    print(__K2L_Str(Op.TIMES))
    print(__K2L_Str(Op.MINUS))
    print(__K2L_Str(__K2L_EnumValues(Op)))
    print(__K2L_EnumValueOf(Op, "TIMES"):apply(7, 6))
    print(__K2L_EnumValueOf(Op, "PLUS") == Op.PLUS)
    print(Op.PLUS == Op.TIMES)
    local ____value = Op.PLUS
    print(__K2L_InstanceOf(____value, Op))
    local any = Op.TIMES
    print(__K2L_InstanceOf(any, Op))
    print(__K2L_InstanceOf(any, Level))
    print(__K2L_Str(__K2L_EnumValues(Op):map(function(it) return it.symbol end)))
    print(__K2L_EnumValues(Op).size)
    print("-- levels")
    print(Level.LOW:score())
    print(Level.MEDIUM:score())
    print(Level.MEDIUM:score())
    print(Level.MEDIUM:twice())
    print(Level.HIGH:score())
    print(Level.HIGH:twice())
    print(Level.NONE:twice())
    local total = __K2L_EnumValues(Level):sumOf(function(it) return it.weight end)
    print(total)
    local best = __K2L_EnumValues(Level):maxByOrNull(function(it) return it.weight end)
    print(__K2L_Str(best))
    print(__K2L_EnumValues(Level):joinToString(nil, nil, nil, nil, nil, function(it) return it.name:lower() end))
    print("-- shapes")
    local ____list_1 = __K2L_EnumValues(Shape)
    for ____i_1 = 1, ____list_1.size do
        local s = ____list_1[____i_1]
        print(s.name .. " " .. s.sides .. " " .. s:name2())
    end
    print("-- planets")
    local ____list_2 = __K2L_EnumValues(Planet)
    for ____i_2 = 1, ____list_2.size do
        local p = ____list_2[____i_2]
        print(p:describe())
    end
    local d = Planet.MARS
    print(d:describe())
    print(__K2L_EnumValueOf(Color, "GREEN").ordinal)
    print(__K2L_EnumValues(Color).size)
    local ____ok, ____result = pcall(function()
        __K2L_EnumValueOf(Color, "BLUE")
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
            local e = ____error
            print("no such color")
        else
            error(____error, 0)
        end
    end
end

main()
return {Op = Op, Level = Level, Shape = Shape, Describable = Describable, Planet = Planet, Color = Color, classify = classify}
