local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_RunMain = ____lualib.__K2L_RunMain

local Shape = __K2L_Class("Shape")

function Shape:getName()
    return "shape"
end

local Rect = __K2L_Class("Rect", nil, Shape)

function Rect:____init(w, h)
    self.w = w
    self.h = h
    self.label = "rect"
    self.count = 0
end

function Rect:getArea()
    return self.w * self.h
end

function Rect:getLabel()
    return self.label
end

function Rect:getCount()
    return self.count
end

function Rect:setCount(value)
    self.count = value
    print("set " .. value)
end

function Rect:describe()
    return self:getName() .. " " .. self:getLabel() .. " " .. self:getArea() .. " " .. self:getCount()
end

local Square = __K2L_Class("Square", Rect)

function Square:____init(s)
    Rect.____init(self, s, s)
end

function Square:getName()
    return "square"
end

function Square:getLabel()
    return "sq " .. Rect.getLabel(self)
end

local Base = __K2L_Class("Base")

function Base:getDesc()
    return "id=" .. self:getId()
end

local Impl = __K2L_Class("Impl", Base)

function Impl.new(id)
    return setmetatable({id = id}, Impl)
end

function Impl:getId()
    return self.id
end

local Fixed = __K2L_Class("Fixed", Base)

function Fixed:getId()
    return 7
end

local Counter = __K2L_Class("Counter")

function Counter:____init()
    self.n = 1
end

function Counter:getN()
    return self.n * 10
end

function Counter:setN(value)
    self.n = value
end

local Doubler = __K2L_Class("Doubler", Counter)

function Doubler:____init()
    Counter.____init(self)
    self.n__Doubler = 5
end

function Doubler:getN()
    return self.n__Doubler
end

function Doubler:setN(value)
    self.n__Doubler = value * 2
end

function Doubler:both()
    return Counter.getN(self) .. " " .. self:getN()
end

local Plain = __K2L_Class("Plain")

function Plain:____init(a)
    self.a = a
    self.b = 1
end

local PlainSub = __K2L_Class("PlainSub", Plain)

function PlainSub:____init(a)
    Plain.____init(self, a)
    self.a = 5
end

local function main()
    local shapes = __K2L_ListOf(Rect.new(2.0, 3.0), Square.new(4.0))
    for ____i = 1, shapes.size do
        local s = shapes[____i]
        print(s:getName() .. " " .. s:getArea())
    end
    local r = Square.new(2.0)
    print(r:getLabel())
    print(r:describe())
    r:setCount(3)
    r:setCount(r:getCount() + 1)
    r:setCount(r:getCount() + 10)
    print(r:getCount())
    local q = Rect.new(1.0, 1.0)
    q:setCount(q:getCount() + 2)
    print(q:describe())
    local bases = __K2L_ListOf(Impl.new(3), Fixed.new())
    for ____i_1 = 1, bases.size do
        local b = bases[____i_1]
        print(b:getId() .. " " .. b:getDesc())
    end
    local c = Doubler.new()
    print(c:getN())
    c:setN(4)
    print(c:getN())
    print(Doubler.new():both())
    print(Counter.new():getN())
    local p = PlainSub.new(2)
    p.b = p.b + 4
    print(p.a .. " " .. p.b)
end

__K2L_RunMain(main)
return {Shape = Shape, Rect = Rect, Square = Square, Base = Base, Impl = Impl, Fixed = Fixed, Counter = Counter, Doubler = Doubler, Plain = Plain, PlainSub = PlainSub}
