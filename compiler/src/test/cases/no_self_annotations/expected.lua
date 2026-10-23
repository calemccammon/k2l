-- ==== bindings/caller.lua ====
local ____exports = {}
package.loaded["bindings.caller"] = ____exports
return ____exports
-- ==== main.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_StringToInt = ____lualib.__K2L_StringToInt

local ____exports = {}
package.loaded.main = ____exports
local ____shapes = require("shapes")
local ____caller = require("lib.caller")
local Handler = __K2L_Class("app.Handler")
____exports.Handler = Handler
local Book = __K2L_Class("app.Book")

function Book.____init()
    Book.opened = 0
end

function Book.Initialize(title, page)
    Book.opened = Book.opened + 1
    print("open " .. title .. " at " .. page .. ", " .. Book.opened .. " opened")
end

function Book.reopen()
    Book.Initialize("again", Book.opened)
end

Book.____init()
____exports.Book = Book
local Doubler = __K2L_Class("app.Doubler", nil, Handler)

function Doubler.handle(value)
    return tostring(value * 2)
end

function Doubler:twice(value)
    return self.handle(__K2L_StringToInt(self.handle(value)))
end

____exports.Doubler = Doubler
local Counter = __K2L_Class("app.Counter", nil, Handler)

function Counter:____init(count)
    if rawget(self, "handle") == nil then
        self.handle = function(...)
            return getmetatable(self).handle(self, ...)
        end
    end
    self.count = count
end

function Counter:handle(value)
    self.count = self.count + value
    return tostring(self.count)
end

function Counter:current()
    return self.count
end

____exports.Counter = Counter
local LoudCounter = __K2L_Class("app.LoudCounter", Counter)

function LoudCounter:____init(start)
    Counter.____init(self, start)
end

function LoudCounter:handle(value)
    return Counter.handle(self, value) .. "!"
end

____exports.LoudCounter = LoudCounter
local Registry = __K2L_Class("app.Registry")

function Registry:____init()
    if rawget(self, "add") == nil then
        self.add = function(...) return getmetatable(self).add(self, ...) end
    end
    self.names = ""
end

function Registry:add(name)
    self.names = self.names .. "[" .. name .. "]"
end

function Registry:all()
    return self.names
end

____exports.Registry = Registry
local Config = __K2L_Class("app.Config")

function Config:____init(name)
    if rawget(self, "greet") == nil then
        self.greet = function(...) return getmetatable(self).greet(self, ...) end
    end
    self.name = name
end

function Config:greet()
    return "config " .. self.name
end

function Config.load(name)
    Config.loaded = Config.loaded + 1
    return Config.new(name)
end

function Config.____initCompanion()
    Config.loaded = 0
end

Config.____initCompanion()
____exports.Config = Config

local ____lambda_1 = function(value) return "inline " .. value end
local ____lambda_2 = function(receiver, ...) return receiver.handle(...) end
local ____lambda_3 = function(receiver, ...) return receiver.describe(...) end
local function main()
    Book.Initialize("Atlas", 3)
    Book.reopen()
    local square = ____shapes.Square.new(3)
    local rect = ____shapes.Rect.new(2, 5)
    local shapes = __K2L_ListOf(square, rect, ____shapes.Unit1)
    for ____i = 1, shapes.size do
        local s = shapes[____i]
        print(s.describe())
    end
    print(square.scaled(2) .. " " .. rect.scaled(2))
    local ____object = __K2L_Class("app.MainKt$main$inline$1", nil, Handler)
    function ____object.handle(value)
        return "inline " .. value
    end
    local inline = ____object
    print(____caller.callTwice(inline, 1))
    print(____caller.callTwice(Doubler, 4))
    print(Doubler:twice(3))
    local counter = LoudCounter.new(10)
    print(____caller.callTwice(counter, 5))
    print(counter:current())
    local registry = Registry.new()
    registry.add("a")
    registry.add("b")
    print(registry:all())
    local config = Config.load("main")
    print(config.greet() .. " " .. Config.loaded)
    print(____shapes.Money.of(2).plus(____shapes.Money.new(5)):toString() .. " " .. tostring(____shapes.Money.new(5):equals(____shapes.Money.new(5))) .. " " .. tostring(____shapes.Money.ZERO:equals(____shapes.Money.new(1))))
    local ____receiver = Book
    local open = function(...) return ____receiver.Initialize(...) end
    open("Ref", 9)
    local handle = ____lambda_2
    print(handle(Doubler, 21))
    local area = function(...) return square.area(...) end
    local describe = ____lambda_3
    print(area() .. " " .. describe(____shapes.Unit1))
    local add = function(...) return registry.add(...) end
    add("c")
    print(registry:all())
end

if ... ~= "main" then
    __K2L_RunMain(main)
end
return ____exports
-- ==== shapes.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class

local Shape = __K2L_Class("shapes.Shape")

function Shape:describe()
    return self.name() .. " of area " .. self.area()
end

local Base = __K2L_Class("shapes.Base", nil, Shape)

function Base:____init(kind)
    if rawget(self, "area") == nil then
        self.area = function(...) return getmetatable(self).area(self, ...) end
    end
    if rawget(self, "describe") == nil then
        self.describe = function(...)
            return getmetatable(self).describe(self, ...)
        end
    end
    if rawget(self, "name") == nil then
        self.name = function(...) return getmetatable(self).name(self, ...) end
    end
    if rawget(self, "scaled") == nil then
        self.scaled = function(...)
            return getmetatable(self).scaled(self, ...)
        end
    end
    self.kind = kind
end

function Base:name()
    return self.kind
end

function Base:scaled(k)
    return self.area() * k
end

local Square = __K2L_Class("shapes.Square", Base)

function Square:____init(side)
    Base.____init(self, "square")
    self.side = side
end

function Square:area()
    return self.side * self.side
end

local Rect = __K2L_Class("shapes.Rect", Base)

function Rect:____init(w, h)
    Base.____init(self, "rect")
    self.w = w
    self.h = h
end

function Rect:area()
    return self.w * self.h
end

function Rect:scaled(k)
    return Base.scaled(self, k) + 1
end

function Rect:describe()
    return "wide " .. Shape.describe(self)
end

local Unit1 = __K2L_Class("shapes.Unit1", nil, Shape)

function Unit1.area()
    return 1
end

function Unit1.name()
    return "unit"
end

function Unit1.describe(...)
    return Shape.describe(Unit1, ...)
end

local Money = __K2L_Class("shapes.Money")

function Money:____init(cents)
    if rawget(self, "plus") == nil then
        self.plus = function(...) return getmetatable(self).plus(self, ...) end
    end
    self.cents = cents
end

function Money:plus(other)
    return Money.new(self.cents + other.cents)
end

function Money:toString()
    return "$" .. self.cents // 100 .. "." .. self.cents % 100
end

function Money:equals(other)
    return getmetatable(other) == Money and other.cents == self.cents
end

function Money:hashCode()
    return self.cents
end

function Money.of(dollars)
    return Money.new(dollars * 100)
end

function Money.____initCompanion()
    Money.ZERO = Money.new(0)
end

Money.____initCompanion()
return {Shape = Shape, Base = Base, Square = Square, Rect = Rect, Unit1 = Unit1, Money = Money}
