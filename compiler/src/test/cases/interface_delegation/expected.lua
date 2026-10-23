local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_LazyObject = ____lualib.__K2L_LazyObject
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Text = ____lualib.__K2L_Text

local Named = __K2L_Class("Named")

function Named:shout()
    return self:greet("everyone"):upper()
end

function Named:describe()
    return "Named(" .. self:getName() .. ")"
end

local Person = __K2L_Class("Person", nil, Named)

function Person:____init(name)
    self.name = name
    self.nickname = __K2L_Text.take(self:getName(), 2)
end

function Person:getName()
    return self.name
end

function Person:getNickname()
    return self.nickname
end

function Person:setNickname(value)
    self.nickname = value
end

function Person:greet(other)
    return self:getName() .. " greets " .. other
end

function Person:describe()
    return "Person " .. self:getName()
end

function Person:toString()
    return "Person(" .. self:getName() .. ")"
end

local Polite = __K2L_Class("Polite", nil, Named)

function Polite.new(impl)
    return setmetatable({____delegate_Named = impl}, Polite)
end

function Polite:greet(other)
    return "Dear " .. other .. ", from " .. self:getName()
end

function Polite:getName(...)
    return self.____delegate_Named:getName(...)
end

function Polite:getNickname(...)
    return self.____delegate_Named:getNickname(...)
end

function Polite:setNickname(...)
    return self.____delegate_Named:setNickname(...)
end

function Polite:shout(...)
    return self.____delegate_Named:shout(...)
end

function Polite:describe(...)
    return self.____delegate_Named:describe(...)
end

local Stack = __K2L_Class("Stack")

function Stack:peek()
    local ____value = self:pop()
    self:push(____value)
    return ____value
end

local ListStack = __K2L_Class("ListStack", nil, Stack)

function ListStack:____init()
    self.items = __K2L_ListOf()
end

function ListStack:getSize()
    return self.items.size
end

function ListStack:push(x)
    self.items:add(x)
end

function ListStack:pop()
    return self.items:removeAt(self.items.size - 1)
end

local Counter = __K2L_Class("Counter")
local Ticker = __K2L_Class("Ticker", nil, Counter)

function Ticker:____init()
    self.n = 0
end

function Ticker:count()
    self.n = self.n + 1
    return self.n
end

local function makeStack()
    print("makeStack")
    return ListStack.new()
end

local Logged = __K2L_Class("Logged", nil, Stack, Counter)

function Logged:____init(label)
    self.label = label
    self.____delegate_Stack = makeStack()
    self.____delegate_Counter = Ticker.new()
    print("init " .. self.label)
end

function Logged:push(x)
    print(self.label .. " push " .. x .. " (" .. self:count() .. ")")
end

function Logged:getSize(...)
    return self.____delegate_Stack:getSize(...)
end

function Logged:pop(...)
    return self.____delegate_Stack:pop(...)
end

function Logged:peek(...)
    return self.____delegate_Stack:peek(...)
end

function Logged:count(...)
    return self.____delegate_Counter:count(...)
end

local Wrapper = __K2L_Class("Wrapper", nil, Named)

function Wrapper:____init(inner)
    self.inner = inner
    self.____delegate_Named = inner
    self.calls = 0
end

function Wrapper:describe()
    self.calls = self.calls + 1
    return "Wrapper[" .. self.inner:describe() .. "]"
end

function Wrapper:getName(...)
    return self.____delegate_Named:getName(...)
end

function Wrapper:getNickname(...)
    return self.____delegate_Named:getNickname(...)
end

function Wrapper:setNickname(...)
    return self.____delegate_Named:setNickname(...)
end

function Wrapper:greet(...)
    return self.____delegate_Named:greet(...)
end

function Wrapper:shout(...)
    return self.____delegate_Named:shout(...)
end

local Shape = __K2L_Class("Shape")
local Square = __K2L_Class("Square", nil, Shape)

function Square.new(side)
    return setmetatable({side = side}, Square)
end

function Square:getArea()
    return self.side * self.side
end

function Square:toString()
    return "Square(" .. self.side .. ")"
end

local Framed = __K2L_Class("Framed", nil, Shape)

function Framed.new(s)
    return setmetatable({____delegate_Shape = s}, Framed)
end

function Framed:getArea(...)
    return self.____delegate_Shape:getArea(...)
end

function Framed:toString(...)
    return self.____delegate_Shape:toString(...)
end

local Base = __K2L_Class("Base")
local Derived = __K2L_Class("Derived", nil, Base)

function Derived:full()
    return "derived " .. self:id()
end

local Impl = __K2L_Class("Impl", nil, Derived)

function Impl:id()
    return "impl"
end

local Via = __K2L_Class("Via", nil, Derived)

function Via.new(d)
    return setmetatable({____delegate_Derived = d}, Via)
end

function Via:id(...)
    return self.____delegate_Derived:id(...)
end

function Via:full(...)
    return self.____delegate_Derived:full(...)
end

local IntStack = __K2L_Class("IntStack", nil, Stack)

function IntStack:____init()
    self.____delegate_Stack = ListStack.new()
end

function IntStack:getSize(...)
    return self.____delegate_Stack:getSize(...)
end

function IntStack:push(...)
    return self.____delegate_Stack:push(...)
end

function IntStack:pop(...)
    return self.____delegate_Stack:pop(...)
end

function IntStack:peek(...)
    return self.____delegate_Stack:peek(...)
end

local Defaults = __K2L_Class("Defaults", nil, Counter)

function Defaults:count()
    return 42
end

local function makeTicker()
    print("makeTicker")
    return Ticker.new()
end

local Shared = __K2L_Class("Shared", nil, Counter)

function Shared:____init()
    self.____delegate_Counter = makeTicker()
end

function Shared:count(...)
    return self.____delegate_Counter:count(...)
end

__K2L_LazyObject(Shared, "____init")
local Point = __K2L_Class("Point")

function Point.new(x, y)
    return setmetatable({x = x, y = y}, Point)
end

__K2L_DataClass(Point, {"x", "y"})
local Located = __K2L_Class("Located")
local Here = __K2L_Class("Here", nil, Located)

function Here:____init()
    self.point = Point.new(1, 2)
end

function Here:getPoint()
    return self.point
end

local Pin = __K2L_Class("Pin", nil, Located)

function Pin:____init(tag, at)
    self.tag = tag
    self.at = at
    self.____delegate_Located = at
end

function Pin:getPoint(...)
    return self.____delegate_Located:getPoint(...)
end

__K2L_DataClass(Pin, {"tag", "at"})
local Holder = __K2L_Class("Holder")
Holder.Companion = __K2L_Class("Holder$Companion", nil, Counter)

function Holder.Companion:____init()
    self.____delegate_Counter = Defaults
end

function Holder.Companion:count(...)
    return self.____delegate_Counter:count(...)
end

Holder.Companion:____init()

local function main()
    local p = Person.new("Alice")
    local polite = Polite.new(p)
    print(polite:greet("Bob"))
    print(polite:shout())
    print(polite:describe())
    print(polite:getName() .. " " .. polite:getNickname())
    polite:setNickname("Al")
    print(p:getNickname() .. " " .. polite:getNickname())
    print(__K2L_InstanceOf(polite, Named))
    print(__K2L_Str(polite) == p:toString())
    print(polite == Polite.new(p))
    print(__K2L_Equals(polite, polite))
    local logged = Logged.new("log")
    logged:push("a")
    logged:push("b")
    print(logged:getSize() .. " " .. logged:count() .. " " .. logged:count())
    local s = Logged.new("second")
    print(s:getSize())
    local delegated = IntStack.new()
    delegated:push(1)
    delegated:push(2)
    print(delegated:peek() .. " " .. delegated:pop() .. " " .. delegated:getSize())
    local w = Wrapper.new(p)
    print(w:describe() .. " " .. w.calls .. " " .. w:greet("Carol"))
    local framed = Framed.new(Square.new(2.0))
    print(__K2L_Str(framed) .. " " .. framed:getArea())
    local via = Via.new(Impl.new())
    print(via:full() .. " " .. via:id() .. " " .. tostring(__K2L_InstanceOf(via, Base)))
    print(Holder.Companion:count() + Holder.Companion:count())
    print("before Shared")
    print(Shared:count() + Shared:count())
    local here = Here.new()
    print(__K2L_Str(Pin.new("a", here):getPoint()))
    print(tostring(Pin.new("a", here):equals(Pin.new("a", here))) .. " " .. tostring(Pin.new("a", here):equals(Pin.new("a", Here.new()))))
end

__K2L_RunMain(main)
return {Named = Named, Person = Person, Polite = Polite, Stack = Stack, ListStack = ListStack, Counter = Counter, Ticker = Ticker, makeStack = makeStack, Logged = Logged, Wrapper = Wrapper, Shape = Shape, Square = Square, Framed = Framed, Base = Base, Derived = Derived, Impl = Impl, Via = Via, IntStack = IntStack, Defaults = Defaults, makeTicker = makeTicker, Shared = Shared, Point = Point, Located = Located, Here = Here, Pin = Pin, Holder = Holder}
