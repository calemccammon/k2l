local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Set = ____lualib.__K2L_Set
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Text = ____lualib.__K2L_Text

local Pt = __K2L_Class("Pt")

function Pt:____init(x, y)
    self.x = x
    self.y = y
end

function Pt.new(x, y)
    return setmetatable({x = x, y = y}, Pt)
end

function Pt:toString()
    return "Pt(x=" .. self.x .. ", y=" .. self.y .. ")"
end

function Pt:hashCode()
    return (31 * self.x + self.y + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Pt:equals(other)
    return getmetatable(other) == Pt and self.x == other.x and self.y == other.y
end

local Mutable = __K2L_Class("Mutable")

function Mutable:____init(v)
    self.v = v
end

function Mutable.new(v)
    return setmetatable({v = v}, Mutable)
end

function Mutable:hashCode()
    return self.v
end

function Mutable:equals(other)
    return getmetatable(other) == Mutable and other.v == self.v
end

function Mutable:toString()
    return "M" .. self.v
end

local ____lambda_1 = function(it) return #it end
local ____lambda_2 = function(it) return #it end
local ____lambda_3 = function(it) return __K2L_Text.first(it) end
local ____lambda_4 = function(it) return it.x end
local ____lambda_5 = function(it) return it end
local ____lambda_6 = function(it) return it end
local ____lambda_7 = function(it) return it end
local ____lambda_8 = function(it) return -it end
local function main()
    local m = __K2L_Map.new()
    for i = 0, 9 do
        m:set(i, "v" .. i)
    end
    print(__K2L_Str(m:remove(0)))
    print(__K2L_Str(m:remove(5)))
    print(__K2L_Str(m:remove(9)))
    print(__K2L_Str(m:remove(42)))
    print(__K2L_Str(m))
    print(__K2L_Str(m:get(6)))
    m:set(5, "again")
    print(__K2L_Str(m:getKeys():toList()))
    print(m:containsKey(3))
    local names = __K2L_MapOf(__K2L_Pair.new("a", 1), __K2L_Pair.new("b", 2), __K2L_Pair.new("c", 3), __K2L_Pair.new("d", 4))
    names:remove("b")
    print(__K2L_Str(names))
    print(__K2L_Str(names:get("d")))
    print(names:remove("c", 99))
    print(names:remove("c", 3))
    print(__K2L_Str(names))
    local pts = __K2L_Map.new()
    for i = 0, 5 do
        local ____key = Pt.new(i, i * i)
        pts:set(____key, i)
    end
    pts:remove(Pt.new(1, 1))
    pts:remove(Pt.new(4, 16))
    print(__K2L_Str(pts))
    print(__K2L_Str(pts:get(Pt.new(5, 25))))
    print(__K2L_Str(pts:get(Pt.new(2, 4))))
    print(pts:containsKey(Pt.new(1, 1)))
    local mixed = __K2L_Map.new()
    mixed:set(1, 1)
    local ____key_1 = Pt.new(0, 0)
    mixed:set(____key_1, 2)
    mixed:set(nil, 3)
    mixed:set("s", 4)
    mixed:remove(1)
    print(__K2L_Str(mixed))
    print(__K2L_Str(mixed:get(nil)))
    print(__K2L_Str(mixed:get(Pt.new(0, 0))))
    mixed:remove(nil)
    print(__K2L_Str(mixed))
    local set = __K2L_Set.new()
    for i = 0, 4 do
        set:add(Pt.new(i, 0))
    end
    set:remove(Pt.new(0, 0))
    set:remove(Pt.new(3, 0))
    print(__K2L_Str(set))
    print(set:contains(Pt.new(4, 0)))
    local ints = __K2L_SetOf(5, 3, 8, 1)
    ints:remove(3)
    ints:add(3)
    print(__K2L_Str(ints))
    local ms = __K2L_Set.new()
    local a = Mutable.new(1)
    ms:add(a)
    ms:add(Mutable.new(2))
    ms:add(Mutable.new(3))
    a.v = 10
    ms:remove(Mutable.new(2))
    print(ms.size)
    print(__K2L_Str(__K2L_ListOf(3, 1, 2, 1, 5):sorted()))
    print(__K2L_Str(__K2L_ListOf(3.5, -1.5, 2.25):sortedDescending()))
    print(__K2L_Str(__K2L_ListOf("pear", "apple", "fig"):sorted()))
    local words = __K2L_ListOf("bb", "a", "ccc", "dd", "e")
    print(__K2L_Str(words:sortedBy(____lambda_1, true)))
    print(__K2L_Str(words:sortedByDescending(____lambda_2, true)))
    print(__K2L_Str(words:sortedBy(____lambda_3)))
    print(__K2L_Str(__K2L_ListOf(Pt.new(2, 1), Pt.new(1, 5), Pt.new(2, 0), Pt.new(1, 2)):sortedBy(____lambda_4, true)))
    print(__K2L_Str(__K2L_ListOf(3, nil, 1):sortedBy(____lambda_5, true)))
    print(__K2L_Str(__K2L_ListOf(3, nil, 1):sortedByDescending(____lambda_6, true)))
    print(__K2L_Str(__K2L_ListOf(true, false, true):sortedBy(____lambda_7, true)))
    local calls = __K2L_List.new()
    local sortedWithCalls = __K2L_ListOf("x", "y"):sortedBy(function(it)
        calls:add(it)
        return it
    end)
    print(__K2L_Str(sortedWithCalls))
    local mutable = __K2L_ListOf(5, 2, 9)
    mutable:sortBy(____lambda_8, true)
    print(__K2L_Str(mutable))
end

__K2L_RunMain(main)
return {Pt = Pt, Mutable = Mutable}
