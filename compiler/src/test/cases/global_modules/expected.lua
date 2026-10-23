-- ==== core/std.lua ====
local __K2L_ListOf = ____lualib.__K2L_ListOf

____internal = ____internal or {}
local ____internal = ____internal
local secret, compute

function clamp(x, lo, hi)
    if x < lo then
        return lo
    else
        return x > hi and hi or x
    end
end

function format_hp(hp)
    return "HP " .. hp
end

LIMIT = 400

local function bump()
    counter = counter + 1
    return counter
end

____internal.bump = bump

function getGreeting()
    return "hello from " .. secret
end

local ____volume_field = 3

function getVolume()
    return ____volume_field
end

function setVolume(value)
    ____volume_field = clamp(value, 0, 10)
end

function compute()
    print("computing in core")
    return 42
end

sizes = __K2L_ListOf(10, 20)
counter = 0
secret = "core"
computed = compute()
-- ==== main.lua ====
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str

____internal = ____internal or {}
local ____internal = ____internal
Circle = __K2L_Class("app.Circle", Shape, Named)

function Circle:____init(r)
    Shape.____init(self, "circle")
    self.r = r
end

function Circle:area()
    return 3.0 * self.r * self.r
end

function Circle:getLabel()
    return "circle " .. self.r
end

local function main()
    print(width(5))
    print(width(1000))
    print(shrink(9))
    print(format_hp(10))
    ____internal.bump()
    ____internal.bump()
    print(counter)
    counter = 10
    print(____internal.bump())
    print(getGreeting())
    setVolume(50)
    print(getVolume())
    print(computed)
    print(__K2L_Str(sizes))
    print(getDoubled(7))
    print(describe())
    Registry:add(Square.new(2.0))
    Registry:add(Circle.new(1.0))
    print(Registry:count())
    print(Announcer:announce("hi"))
    print(Color.GREEN.ordinal)
    print(__K2L_Str(Point.new(1, 2)))
    Counter:make()
    print(Counter.made)
    print(Circle.new(2.0):getLabel())
end

__K2L_RunMain(main)
-- ==== model/shapes.lua ====
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_LazyObject = ____lualib.__K2L_LazyObject
local __K2L_ListOf = ____lualib.__K2L_ListOf

Named = __K2L_Class("model.Named")
Shape = __K2L_Class("model.Shape")

function Shape:____init(name)
    self.name = name
end

function Shape.new(name)
    return setmetatable({name = name}, Shape)
end

function Shape:area()
    return 0.0
end

Square = __K2L_Class("model.Square", Shape)

function Square:____init(side)
    Shape.____init(self, "square")
    self.side = side
end

function Square:area()
    return self.side * self.side
end

Registry = __K2L_Class("model.Registry")
local items

function Registry:____init()
    items = __K2L_ListOf()
end

function Registry:add(s)
    items:add(s)
end

function Registry:count()
    return items.size
end

Registry:____init()
Announcer = __K2L_Class("model.Announcer")

function Announcer:____init()
    print("Announcer ready")
end

function Announcer:announce(what)
    return "** " .. what .. " **"
end

__K2L_LazyObject(Announcer, "____init")
Color = __K2L_Class("model.Color")

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
Point = __K2L_Class("model.Point")

function Point.new(x, y)
    return setmetatable({x = x, y = y}, Point)
end

__K2L_DataClass(Point, {"x", "y"})
Counter = __K2L_Class("model.Counter")

function Counter:make()
    self.made = self.made + 1
    return Counter.new()
end

function Counter:____initCompanion()
    self.made = 0
end

Counter:____initCompanion()
-- ==== screens/Hotbar.lua ====
function width(w)
    return clamp(w, 10, LIMIT)
end

function shrink(____clamp)
    return clamp(____clamp, 0, 5)
end

function getDoubled(self)
    return self * 2
end

local function helper()
    return "private to Hotbar"
end

function describe()
    return helper()
end
