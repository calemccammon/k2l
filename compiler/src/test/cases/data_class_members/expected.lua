local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str

local ____exports = {}
local Point = __K2L_Class("shapes.Point")

function Point.new(x, y)
    return setmetatable({x = x, y = y}, Point)
end

__K2L_DataClass(Point, {"x", "y"})
local Reading = __K2L_Class("shapes.Reading")

function Reading.new(label, value)
    return setmetatable({label = label, value = value}, Reading)
end

__K2L_DataClass(Reading, {"label", "value"})
local Entry = __K2L_Class("shapes.Entry")

function Entry.new(name, note)
    return setmetatable({name = name, note = note}, Entry)
end

__K2L_DataClass(Entry, {"name", "note"})
local Grid = __K2L_Class("shapes.Grid")

function Grid.new(cells, name)
    return setmetatable({cells = cells, name = name}, Grid)
end

__K2L_DataClass(Grid, {"cells", "name"})
local Line = __K2L_Class("shapes.Line")

function Line.new(from, to)
    return setmetatable({from = from, to = to}, Line)
end

__K2L_DataClass(Line, {"from", "to"})
local Empty = __K2L_Class("shapes.Empty")

function Empty:____init(id)
    self.id = id
    self.hits = 0
end

__K2L_DataClass(Empty, {"id"})
local Named = __K2L_Class("shapes.Named")

function Named.new(first, last)
    return setmetatable({first = first, last = last}, Named)
end

function Named:toString()
    return self.first .. " " .. self.last
end

__K2L_DataClass(Named, {"first", "last"})
local Loose = __K2L_Class("shapes.Loose")

function Loose.new(id, tag)
    return setmetatable({id = id, tag = tag}, Loose)
end

function Loose:equals(other)
    return getmetatable(other) == Loose and other.id == self.id
end

function Loose:hashCode()
    return self.id
end

__K2L_DataClass(Loose, {"id", "tag"})
local HasFirst = __K2L_Class("shapes.HasFirst")
local Pair3 = __K2L_Class("shapes.Pair3", nil, HasFirst)

function Pair3.new(a, b, c)
    return setmetatable({a = a, b = b, c = c}, Pair3)
end

__K2L_DataClass(Pair3, {"a", "b", "c"})

function Pair3:component1()
    return self.a
end

local Outer = __K2L_Class("shapes.Outer")
Outer.Inner = __K2L_Class("shapes.Outer$Inner")

function Outer.Inner.new(v)
    return setmetatable({v = v}, Outer.Inner)
end

__K2L_DataClass(Outer.Inner, {"v"})
local Meters = __K2L_Class("shapes.Meters")

function Meters.new(amount)
    return setmetatable({amount = amount}, Meters)
end

__K2L_DataClass(Meters, {"amount"})
____exports.calls = 0

local function ____next(label)
    ____exports.calls = ____exports.calls + 1
    print("arg " .. label)
    return ____exports.calls
end

local Counter = __K2L_Class("shapes.Counter")

function Counter.new(n, tag)
    return setmetatable({n = n, tag = tag}, Counter)
end

__K2L_DataClass(Counter, {"n", "tag"})

local function bump(c)
    c.n = c.n + 1
    return "b"
end

local function source()
    print("source")
    return Point.new(1, 2)
end

local Event = __K2L_Class("shapes.Event")
local Deleted = __K2L_Class("shapes.Deleted", nil, Event)

function Deleted.new(source, user)
    return setmetatable({source = source, user = user}, Deleted)
end

__K2L_DataClass(Deleted, {"source", "user"})

local ____lambda_1 = function(receiver) return receiver.c end
local ____lambda_2 = function(it) return it.x end
local function main()
    local p = Point.new(1, 2)
    print(__K2L_Str(p))
    print("template: " .. __K2L_Str(p))
    print(p:equals(Point.new(1, 2)))
    print(p:hashCode() == Point.new(1, 2):hashCode())
    print(p:equals("Point(x=1, y=2)"))
    local any = p
    print(__K2L_Str(any))
    print(__K2L_Equals(any, Point.new(1, 2)))
    local nan = Reading.new("nan", 0.0 / 0.0)
    print(nan.value ~= nan.value)
    print(nan:equals(Reading.new(nan.label, nan.value)))
    print(Reading.new("zero", 0.0):equals(Reading.new("zero", -0.0)))
    print(Reading.new("half", 0.5):hashCode() == Reading.new("half", 0.5):hashCode())
    print(__K2L_Str(Entry.new(nil)))
    print(Entry.new("a", "b"):equals(Entry.new("a", "b")))
    print(Entry.new(nil):hashCode() == Entry.new(nil, nil):hashCode())
    local cells = __K2L_ArrayOf(1, 2)
    local g = Grid.new(cells, "g")
    print(__K2L_Str(g))
    print(g:equals(Grid.new(cells, "g")))
    print(g:equals(Grid.new(__K2L_ArrayOf(1, 2), "g")))
    local line = Line.new(Point.new(0, 0), Point.new(3, 4))
    print(__K2L_Str(line))
    print(line:equals(Line.new(Point.new(0, 0), Point.new(3, 4))))
    print(line:hashCode() == Line.new(Point.new(0, 0), Point.new(3, 4)):hashCode())
    local e = Empty.new(7)
    e.hits = 3
    print(__K2L_Str(e))
    print(e:equals(Empty.new(7)))
    print(__K2L_Str(Named.new("Ada", "Lovelace")))
    print(Named.new("Ada", "Lovelace"):equals(Named.new("Ada", "Lovelace")))
    print(Loose.new(1, "x"):equals(Loose.new(1, "y")))
    print(__K2L_Str(Loose.new(1, "x")))
    print(Loose.new(5, "x"):hashCode())
    local ____source = source()
    local moved = Point.new(____source.x, ____next("y"))
    print(__K2L_Str(moved))
    local ____arg = ____next("first y")
    local ____arg_1 = ____next("then x")
    local both = Point.new(____arg_1, ____arg)
    print(__K2L_Str(both))
    local counter = Counter.new(1, "a")
    local ____arg_2 = bump(counter)
    print(__K2L_Str(Counter.new(counter.n, ____arg_2)))
    local a, b = both.x, both.y
    print(a + b)
    local onlyB = line.to
    print(__K2L_Str(onlyB))
    local first = Pair3.new(9, 8, 7)
    print(first:component1())
    local c1 = first:component1()
    print(c1)
    local component = __K2L_PropertyRef.new("c", "c@702", ____lambda_1)
    print(component(Pair3.new(1, 2, 3)))
    local counts = __K2L_Map.new()
    local ____key = Point.new(1, 1)
    counts:set(____key, 1)
    local ____key_1 = Point.new(1, 1)
    counts:set(____key_1, (counts:get(Point.new(1, 1)) or 0) + 1)
    print(__K2L_Str(counts))
    local set = __K2L_SetOf(Point.new(1, 1), Point.new(1, 1), Point.new(2, 2))
    print(set.size)
    print(set:contains(Point.new(2, 2)))
    print(__K2L_Str(__K2L_ListOf(Point.new(3, 3), Point.new(1, 1)):sortedBy(____lambda_2, true)))
    print(__K2L_Str(Outer.Inner.new(5)))
    print(__K2L_Str(Meters.new(2.5)))
    print(Meters.new(2.5):equals(Meters.new(2.5)))
    local Local = __K2L_Class("shapes.MainKt$main$Local")
    function Local:____init(n)
        self.n = n
    end
    __K2L_DataClass(Local, {"n"})
    print(__K2L_Str(Local.new(1)))
    print(Local.new(1):equals(Local.new(1)))
    local deleted = Deleted.new("web", "ann")
    print(__K2L_Str(deleted))
    print(deleted:equals(Deleted.new("web", "ann")))
    print(deleted:equals(Deleted.new("cli", "ann")))
    print(deleted:hashCode() == Deleted.new("web", "ann"):hashCode())
end

____exports.Point = Point
____exports.Reading = Reading
____exports.Entry = Entry
____exports.Grid = Grid
____exports.Line = Line
____exports.Empty = Empty
____exports.Named = Named
____exports.Loose = Loose
____exports.HasFirst = HasFirst
____exports.Pair3 = Pair3
____exports.Outer = Outer
____exports.Meters = Meters
____exports.____next = ____next
____exports.Counter = Counter
____exports.bump = bump
____exports.source = source
____exports.Event = Event
____exports.Deleted = Deleted
__K2L_RunMain(main)
return ____exports
