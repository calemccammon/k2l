local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str

local Counter = __K2L_Class("Counter")

function Counter:____init(name)
    self.name = name
    self.total = 0
    self.log = __K2L_ListOf()
end

function Counter:record(msg)
    self.log:add(self.name .. ": " .. msg)
end

function Counter:history()
    return self.log
end

Counter.Handle = __K2L_Class("Counter$Handle")

function Counter.Handle:____init(____outer, step)
    self.____outer = ____outer
    self.step = step
    self.uses = 0
end

function Counter.Handle:bump()
    self.____outer.total = self.____outer.total + self.step
    self.uses = self.uses + 1
    self.____outer:record("bump by " .. self.step)
    return self.____outer.total
end

function Counter.Handle:owner()
    return self.____outer
end

function Counter.Handle:ownerName()
    return self.____outer.name
end

function Counter.Handle:toString()
    return "Handle(" .. self.step .. ") of " .. self.____outer.name .. " uses=" .. self.uses .. " total=" .. self.____outer.total
end

Counter.Named = __K2L_Class("Counter$Named")

function Counter.Named:____init(____outer, label)
    self.____outer = ____outer
    self.label = label
end

function Counter.Named:____init1(____outer)
    self.____outer = ____outer
    Counter.Named.____init(self, ____outer, "unnamed")
end

function Counter.Named.new1(____outer)
    local self = setmetatable({}, Counter.Named)
    self:____init1(____outer)
    return self
end

function Counter.Named:____init2(____outer, a, b)
    self.____outer = ____outer
    Counter.Named.____init(self, ____outer, "sum" .. a + b)
end

function Counter.Named.new2(____outer, a, b)
    local self = setmetatable({}, Counter.Named)
    self:____init2(____outer, a, b)
    return self
end

function Counter.Named:show()
    return self.label .. "@" .. self.____outer.name
end

function Counter:newHandle(step)
    return Counter.Handle.new(self, step)
end

function Counter:makeNamed()
    return Counter.Named.new(self, "made")
end

local Outer = __K2L_Class("Outer")

function Outer:____init(tag)
    self.tag = tag
    self.depth = 0
end

function Outer:tagged(s)
    return self.tag .. "/" .. s
end

Outer.Middle = __K2L_Class("Outer$Middle")

function Outer.Middle:____init(____outer, m)
    self.____outer = ____outer
    self.m = m
end

function Outer.Middle:middleValue()
    return self.m * 2
end

Outer.Middle.Leaf = __K2L_Class("Outer$Middle$Leaf")

function Outer.Middle.Leaf:____init(____outer, leaf)
    self.____outer = ____outer
    self.leaf = leaf
end

function Outer.Middle.Leaf:describe()
    self.____outer.____outer.depth = self.____outer.____outer.depth + 1
    return self.____outer.____outer:tagged("leaf " .. self.leaf .. " in middle " .. self.____outer.m) .. " depth=" .. self.____outer.____outer.depth
end

function Outer.Middle.Leaf:outers()
    return self.____outer.m .. " " .. self.____outer.____outer.tag .. " " .. self.____outer:middleValue()
end

function Outer.Middle.Leaf:viaThis()
    return self.leaf + self.leaf
end

function Outer.Middle:makeLeaf(n)
    return Outer.Middle.Leaf.new(self, n + self.m)
end

function Outer:middle(m)
    return Outer.Middle.new(self, m)
end

local Shape = __K2L_Class("Shape")

function Shape:____init(name)
    self.name = name
end

function Shape.new(name)
    return setmetatable({name = name}, Shape)
end

function Shape:sides()
    return 0
end

Shape.Part = __K2L_Class("Shape$Part")

function Shape.Part:____init(____outer, index)
    self.____outer = ____outer
    self.index = index
end

function Shape.Part:label()
    return self.____outer.name .. " part " .. self.index
end

Shape.SpecialPart = __K2L_Class("Shape$SpecialPart", Shape.Part)

function Shape.SpecialPart:____init(____outer, index, extra)
    self.____outer = ____outer
    Shape.Part.____init(self, self.____outer, index)
    self.extra = extra
end

function Shape.SpecialPart:label()
    return Shape.Part.label(self) .. " (" .. self.extra .. ")"
end

Shape.Marked = __K2L_Class("Shape$Marked", Shape.Part)

function Shape.Marked:____init(____outer)
    self.____outer = ____outer
    Shape.Part.____init(self, self.____outer, 99)
end

function Shape.Marked:label()
    return "marked " .. Shape.Part.label(self)
end

Shape.Late = __K2L_Class("Shape$Late", Shape.Part)

function Shape.Late:____init1(____outer, i)
    self.____outer = ____outer
    Shape.Part.____init(self, self.____outer, i + 100)
end

function Shape.Late.new1(____outer, i)
    local self = setmetatable({}, Shape.Late)
    self:____init1(____outer, i)
    return self
end

function Shape.Late:____init2(____outer)
    self.____outer = ____outer
    Shape.Part.____init(self, self.____outer, -1)
end

function Shape.Late.new2(____outer)
    local self = setmetatable({}, Shape.Late)
    self:____init2(____outer)
    return self
end

function Shape:parts()
    return __K2L_ListOf(Shape.Part.new(self, 1), Shape.SpecialPart.new(self, 2, "x"), Shape.Marked.new(self), Shape.Late.new1(self, 3), Shape.Late.new2(self))
end

local Square = __K2L_Class("Square", Shape)

function Square:____init()
    Shape.____init(self, "square")
end

function Square:sides()
    return 4
end

function Square:squarePart()
    return Shape.Part.new(self, 7)
end

Square.Corner = __K2L_Class("Square$Corner")

function Square.Corner:____init(____outer, which)
    self.____outer = ____outer
    self.which = which
end

function Square.Corner:report()
    return self.____outer.name .. " corner " .. self.which .. " of " .. self.____outer:sides()
end

local Wrapper = __K2L_Class("Wrapper")

function Wrapper:____init()
    self.items = 0
end

Wrapper.Counted = __K2L_Class("Wrapper$Counted")

function Wrapper.Counted:____init(____outer)
    self.____outer = ____outer
    self.____outer.items = self.____outer.items + 1
    self.id = self.____outer.items
end

Wrapper.Lazy = __K2L_Class("Wrapper$Lazy")

function Wrapper.Lazy:____init(____outer, factor, tag)
    self.____outer = ____outer
    if factor == nil then
        factor = 3
    end
    if tag == nil then
        tag = "t"
    end
    self.factor = factor
    self.tag = tag
end

function Wrapper.Lazy:scaled()
    return self.____outer.items * self.factor
end

local function main()
    local counter = Counter.new("main")
    local h1 = Counter.Handle.new(counter, 2)
    local h2 = Counter.Handle.new(counter, 5)
    print(h1:bump())
    print(h2:bump())
    print(h1:bump())
    print(counter.total)
    print(__K2L_Str(h1))
    print(__K2L_Str(h2))
    print(h1:owner() == counter)
    print(h2:ownerName())
    local h3 = counter:newHandle(10)
    print(h3:bump())
    print(__K2L_Str(counter:history()))
    local other = Counter.new("other")
    local oh = Counter.Handle.new(other, 1)
    oh:bump()
    print(other.total)
    print(counter.total)
    print(Counter.Named.new1(counter):show())
    print(Counter.Named.new(counter, "x"):show())
    print(Counter.Named.new2(counter, 2, 3):show())
    print(counter:makeNamed():show())
    local outer = Outer.new("T")
    local mid = outer:middle(4)
    local leaf = mid:makeLeaf(1)
    print(leaf:describe())
    print(leaf:describe())
    print(leaf:outers())
    print(leaf:viaThis())
    local leaf2 = Outer.Middle.Leaf.new(Outer.Middle.new(outer, 10), 3)
    print(leaf2:describe())
    print(outer.depth)
    print(leaf2:outers())
    local sq = Square.new()
    local ____list = sq:parts()
    for ____i = 1, ____list.size do
        local p = ____list[____i]
        print(p:label())
    end
    print(sq:squarePart():label())
    print(Square.Corner.new(sq, 2):report())
    local part = Shape.SpecialPart.new(sq, 5, "y")
    print(part:label())
    print(__K2L_InstanceOf(part, Shape.Part))
    print(getmetatable(part) == Shape.SpecialPart)
    local w = Wrapper.new()
    local a = Wrapper.Counted.new(w)
    local b = Wrapper.Counted.new(w)
    local c = Wrapper.Counted.new(Wrapper.new())
    print(a.id .. " " .. b.id .. " " .. c.id .. " " .. w.items)
    print(Wrapper.Lazy.new(w):scaled())
    print(Wrapper.Lazy.new(w, 10):scaled())
    print(Wrapper.Lazy.new(w, 2, "z"):scaled())
    local ____list_1 = __K2L_ListOf(1, 2, 3)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list_1:____array()
    for ____i_1 = 1, ____n do
        local it = ____items[____i_1]
        ____count = ____count + 1
        ____out[____count] = Counter.Handle.new(counter, it)
    end
    local handles = __K2L_ListWrap(____out, ____count)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = handles:____array()
    for ____i_2 = 1, ____n_1 do
        local it = ____items_1[____i_2]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = it:bump()
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
    local ____sum = 0
    local ____items_2, ____n_2 = handles:____array()
    for ____i_3 = 1, ____n_2 do
        local it = ____items_2[____i_3]
        ____sum = ____sum + it.step
    end
    local total = ____sum
    print(total)
end

__K2L_RunMain(main)
return {Counter = Counter, Outer = Outer, Shape = Shape, Square = Square, Wrapper = Wrapper}
