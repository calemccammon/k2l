local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Str = ____lualib.__K2L_Str

local Base = __K2L_Class("Base")

function Base:____init()
    self.size = 1
    self.label = "base"
    self.enabled = true
    self.ratio = 0.5
    self.note = "n"
    print("Base sees size=" .. self:getSize() .. " label=" .. self:getLabel() .. " enabled=" .. tostring(self:getEnabled()) .. " ratio=" .. __K2L_Str(self:getRatio()) .. " note=" .. __K2L_Str(self:getNote()))
    self:report()
end

function Base:getSize()
    return self.size
end

function Base:getLabel()
    return self.label
end

function Base:getEnabled()
    return self.enabled
end

function Base:getRatio()
    return self.ratio
end

function Base:getNote()
    return self.note
end

function Base:report()
    print("report: size=" .. self:getSize() + 1)
end

local Child = __K2L_Class("Child", Base)

function Child:____init()
    Base.____init(self)
    self.size__Child = 10
    self.label__Child = "child"
    self.enabled__Child = false
    self.ratio__Child = 2.5
    self.note__Child = "c"
    print("Child sees size=" .. self:getSize() .. " label=" .. self:getLabel() .. " enabled=" .. tostring(self:getEnabled()) .. " ratio=" .. __K2L_Str(self:getRatio()) .. " note=" .. __K2L_Str(self:getNote()))
end

function Child:getSize()
    return self.size__Child or 0
end

function Child:getLabel()
    return self.label__Child or "null"
end

function Child:getEnabled()
    return self.enabled__Child or false
end

function Child:getRatio()
    return self.ratio__Child or 0.0
end

function Child:getNote()
    return self.note__Child
end

local GrandChild = __K2L_Class("GrandChild", Base)

function GrandChild:____init()
    Base.____init(self)
    self.size__GrandChild = 20
end

function GrandChild:getSize()
    return self.size__GrandChild or 0
end

local Shape = __K2L_Class("Shape")

function Shape:____init(sides)
    self.sides = sides
    self.description = "shape with " .. self:getSides() .. " sides"
end

function Shape:getSides()
    return self.sides
end

local Triangle = __K2L_Class("Triangle", Shape)

function Triangle:____init(sides)
    Shape.____init(self, 3)
    self.sides__Triangle = sides
end

function Triangle:getSides()
    return self.sides__Triangle or 0
end

local Counter = __K2L_Class("Counter")

function Counter:____init()
    self.start = 1
    self.first = self:getStart()
end

function Counter:getStart()
    return self.start
end

local Offset = __K2L_Class("Offset", Counter)

function Offset:____init()
    Counter.____init(self)
end

function Offset:getStart()
    return 100
end

local Calm = __K2L_Class("Calm")

function Calm:____init()
    self.v = 1
end

function Calm:show()
    return "v=" .. self.v
end

local Calmer = __K2L_Class("Calmer", Calm)

function Calmer:____init()
    Calm.____init(self)
    self.v = 2
end

local function main()
    local c = Child.new()
    print("after: " .. c:getSize() .. " " .. c:getLabel() .. " " .. tostring(c:getEnabled()) .. " " .. __K2L_Str(c:getRatio()) .. " " .. __K2L_Str(c:getNote()))
    local g = GrandChild.new()
    print("after: " .. g:getSize())
    print(Triangle.new(5).description)
    print(Triangle.new(5):getSides())
    print(Offset.new().first)
    print(Calmer.new():show())
end

main()
return {Base = Base, Child = Child, GrandChild = GrandChild, Shape = Shape, Triangle = Triangle, Counter = Counter, Offset = Offset, Calm = Calm, Calmer = Calmer}
