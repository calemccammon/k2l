local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Unpack = ____lualib.__K2L_Unpack

local Polygon = __K2L_Class("Polygon")

function Polygon:____init(name, ...)
    local points = __K2L_ArrayOf(...)
    self.name = name
    self.points = points
end

function Polygon:____init1(...)
    local coords = __K2L_ArrayOf(...)
    local ____list = coords:toList():chunked(2)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = __K2L_Pair.new(it:get(0), it:get(1))
    end
    Polygon.____init(self, "poly", __K2L_Unpack(__K2L_ListWrap(____out, ____count):toTypedArray()))
end

function Polygon.new1(...)
    local self = setmetatable({}, Polygon)
    self:____init1(...)
    return self
end

function Polygon:getSize()
    return self.points.size
end

function Polygon:toString()
    return self.name .. __K2L_Str(self.points:toList())
end

local Triangle = __K2L_Class("Triangle", Polygon)

function Triangle:____init(a, b, c)
    Polygon.____init(self, "tri", a, b, c)
end

local Path = __K2L_Class("Path", Polygon)

function Path:____init(...)
    local steps = __K2L_ArrayOf(...)
    Polygon.____init(self, "path")
    self.steps = steps:joinToString(">")
end

local Chord = __K2L_Class("Chord")

function Chord:____init(name, ordinal, ...)
    local notes = __K2L_ArrayOf(...)
    self.name = name
    self.ordinal = ordinal
    self.notes = notes
end

function Chord:toString()
    return self.name
end

function Chord:compareTo(other)
    return self.ordinal - other.ordinal
end

Chord.C = Chord.new("C", 0, "c", "e", "g")
Chord.D7 = Chord.new("D7", 1, "d", "f#", "a", "c")
Chord.REST = Chord.new("REST", 2)
Chord.____values = {Chord.C, Chord.D7, Chord.REST}
local Outer = __K2L_Class("Outer")

function Outer:____init(tag)
    self.tag = tag
end

function Outer.new(tag)
    return setmetatable({tag = tag}, Outer)
end

Outer.Tagged = __K2L_Class("Outer$Tagged")

function Outer.Tagged:____init(____outer, ...)
    local items = __K2L_ArrayOf(...)
    self.____outer = ____outer
    self.items = items
end

function Outer.Tagged:toString()
    return self.____outer.tag .. __K2L_Str(self.items:toList())
end

local Bag = __K2L_Class("Bag")

function Bag:____init(...)
    local initial = __K2L_ArrayOf(...)
    self.items = initial:toMutableList()
end

function Bag:add(...)
    local more = __K2L_ArrayOf(...)
    self.items:addAll(more)
    return self
end

function Bag:toString()
    return __K2L_Str(self.items)
end

local function main()
    print(__K2L_Str(Polygon.new("square", __K2L_Pair.new(0, 0), __K2L_Pair.new(1, 0), __K2L_Pair.new(1, 1), __K2L_Pair.new(0, 1))))
    print(__K2L_Str(Polygon.new1(1, 2, 3, 4)))
    print(Polygon.new("empty"):getSize())
    print(Triangle.new(__K2L_Pair.new(0, 0), __K2L_Pair.new(2, 0), __K2L_Pair.new(1, 1)):getSize())
    local path = Path.new("a", "b", "c")
    print(path.steps .. " " .. path:getSize())
    local ____values = Chord.____values
    local ____out_1 = {}
    local ____count_1 = 0
    for ____i_1 = 1, #____values do
        local it = ____values[____i_1]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = it.name .. ":" .. it.notes.size .. ":" .. it.notes:joinToString("")
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
    print(__K2L_Str(Outer.Tagged.new(Outer.new("#"), 1, 2, 3)))
    local arr = __K2L_ArrayOf("x", "y")
    print(__K2L_Str(Bag.new(__K2L_Unpack(arr)):add("z", __K2L_Unpack(arr))))
    print(__K2L_Str(Bag.new():add()))
end

__K2L_RunMain(main)
return {Polygon = Polygon, Triangle = Triangle, Path = Path, Chord = Chord, Outer = Outer, Bag = Bag}
