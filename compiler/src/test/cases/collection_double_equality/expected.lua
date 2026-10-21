local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_Deque = ____lualib.__K2L_Deque
local __K2L_DoubleEquals = ____lualib.__K2L_DoubleEquals
local __K2L_DoubleToString = ____lualib.__K2L_DoubleToString
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exact = ____lualib.__K2L_Exact
local __K2L_FloatToString = ____lualib.__K2L_FloatToString
local __K2L_FloorDiv = ____lualib.__K2L_FloorDiv
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_HashSetOf = ____lualib.__K2L_HashSetOf
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_LinkedList = ____lualib.__K2L_LinkedList
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_SequenceOf = ____lualib.__K2L_SequenceOf
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_SortedMap = ____lualib.__K2L_SortedMap
local __K2L_SortedSet = ____lualib.__K2L_SortedSet
local __K2L_SortedSetOf = ____lualib.__K2L_SortedSetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Streams = ____lualib.__K2L_Streams
local __K2L_Triple = ____lualib.__K2L_Triple
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf

local Point = __K2L_Class("Point")

function Point:____init(x, y)
    self.x = x
    self.y = y
end

function Point.new(x, y)
    return setmetatable({x = x, y = y}, Point)
end

function Point:toString()
    return "Point(x=" .. __K2L_DoubleToString(self.x) .. ", y=" .. __K2L_DoubleToString(self.y) .. ")"
end

function Point:hashCode()
    return (31 * __K2L_Hash(self.x) + __K2L_Hash(self.y) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Point:equals(other)
    return getmetatable(other) == Point and __K2L_DoubleEquals(self.x, other.x) and __K2L_DoubleEquals(self.y, other.y)
end

local Reading = __K2L_Class("Reading")

function Reading:____init(name, value)
    self.name = name
    self.value = value
end

function Reading.new(name, value)
    return setmetatable({name = name, value = value}, Reading)
end

function Reading:toString()
    return "Reading(name=" .. self.name .. ", value=" .. __K2L_DoubleToString(self.value) .. ")"
end

function Reading:hashCode()
    return (31 * __K2L_Hash(self.name) + __K2L_Hash(self.value) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Reading:equals(other)
    return getmetatable(other) == Reading and self.name == other.name and __K2L_DoubleEquals(self.value, other.value)
end

local Ratio = __K2L_Class("Ratio")

function Ratio:____init(f)
    self.f = f
end

function Ratio.new(f)
    return setmetatable({f = f}, Ratio)
end

function Ratio:toString()
    return "Ratio(f=" .. __K2L_FloatToString(self.f) .. ")"
end

function Ratio:hashCode()
    return __K2L_Hash(self.f)
end

function Ratio:equals(other)
    return getmetatable(other) == Ratio and __K2L_DoubleEquals(self.f, other.f)
end

local Grid = __K2L_Class("Grid")

function Grid:____init(x, y)
    self.x = x
    self.y = y
end

function Grid.new(x, y)
    return setmetatable({x = x, y = y}, Grid)
end

function Grid:toString()
    return "Grid(x=" .. self.x .. ", y=" .. self.y .. ")"
end

function Grid:hashCode()
    return (31 * self.x + self.y + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Grid:equals(other)
    return getmetatable(other) == Grid and self.x == other.x and self.y == other.y
end

local Box = __K2L_Class("Box")

function Box:____init(value)
    self.value = value
end

function Box.new(value)
    return setmetatable({value = value}, Box)
end

function Box:same(other)
    return __K2L_Equals(self.value, other)
end

local function generic(a, b)
    return __K2L_Equals(a, b)
end

local function anyEquals(a, b)
    return __K2L_Equals(a, b)
end

local function describe(x)
    if __K2L_Equals(x, 0.0 / 0.0) then
        return "nan"
    elseif __K2L_Equals(x, -0.0) then
        return "negative zero"
    elseif __K2L_Equals(x, 0.0) then
        return "zero"
    else
        return "other"
    end
end

local function lists()
    local nan = 0.0 / 0.0
    local nz = -0.0
    local xs = __K2L_ReadOnlyListOf(1.0, nan, 0.0, 2.0, nan)
    print("contains NaN: " .. tostring(xs:contains(nan)) .. " " .. tostring(xs:contains(nan)))
    print("indexOf NaN: " .. xs:indexOf(nan) .. " lastIndexOf: " .. xs:lastIndexOf(nan))
    print("contains -0.0: " .. tostring(xs:contains(nz)) .. " indexOf -0.0: " .. xs:indexOf(nz) .. " indexOf 0.0: " .. xs:indexOf(0.0))
    local ys = __K2L_ListOf(nz, 0.0, nan, 1.0)
    print("remove 0.0: " .. tostring(ys:remove(0.0)) .. " -> " .. ys.size .. " " .. __K2L_DoubleToString(1.0 / ys:get(0)))
    print("remove NaN: " .. tostring(ys:remove(nan)) .. " -> " .. ys.size)
    print("remove NaN again: " .. tostring(ys:remove(nan)))
    print("list == list: " .. tostring(__K2L_Equals(__K2L_SingletonListOf(nan), __K2L_SingletonListOf(nan))) .. " " .. tostring(__K2L_Equals(__K2L_SingletonListOf(0.0), __K2L_SingletonListOf(nz))) .. " " .. tostring(__K2L_Equals(__K2L_ReadOnlyListOf(1.0, nan), __K2L_ReadOnlyListOf(1.0, nan))))
    print("list hash: " .. tostring(__K2L_Hash(__K2L_SingletonListOf(nan)) == __K2L_Hash(__K2L_SingletonListOf(nan))) .. " " .. __K2L_Hash(__K2L_SingletonListOf(0.0)) .. " " .. __K2L_Hash(__K2L_SingletonListOf(nz)))
    print("array: " .. __K2L_TypedArrayOf("[Ljava.lang.Double;", nan, 1.0):indexOf(nan) .. " " .. tostring(__K2L_TypedArrayOf("[Ljava.lang.Double;", nz):contains(0.0)) .. " " .. __K2L_TypedArrayOf("[Ljava.lang.Double;", 1.0, nz):indexOf(nz))
    print("distinct: " .. __K2L_ReadOnlyListOf(nan, nan, 0.0, nz, 0.0, 1.0):distinct().size)
    print("toSet: " .. __K2L_ReadOnlyListOf(nan, nz, 0.0, nan):toSet().size)
    print("minus: " .. __K2L_ReadOnlyListOf(nan, 1.0, nz, 0.0):minus(nan).size .. " " .. __K2L_ReadOnlyListOf(nz, 0.0):minus(0.0).size)
    print("containsAll: " .. tostring(__K2L_ReadOnlyListOf(nan, 1.0):containsAll(__K2L_SingletonListOf(nan))))
    print("intersect: " .. __K2L_ReadOnlyListOf(nan, 0.0, 1.0):intersect(__K2L_ReadOnlyListOf(nan, nz)).size)
    print("union: " .. __K2L_ReadOnlyListOf(nan, 0.0):union(__K2L_ReadOnlyListOf(nan, nz)).size)
    local ____result = 0
    local ____items, ____n = xs:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        if it == nan then
            ____result = ____result + 1
        end
    end
    local ____result_1 = 0
    local ____items_1, ____n_1 = xs:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        if it ~= it then
            ____result_1 = ____result_1 + 1
        end
    end
    print("count: " .. ____result .. " " .. ____result_1)
    print("ints: " .. tostring(__K2L_ReadOnlyListOf(0, 1, 2):contains(0)) .. " " .. __K2L_ReadOnlyListOf(1, 2):indexOf(2) .. " " .. tostring(__K2L_HashSetOf(0, 1):contains(0)))
end

local function sets()
    local nan = 0.0 / 0.0
    local nz = -0.0
    local s = __K2L_HashSetOf(0.0, nz, nan)
    print("set size: " .. s.size)
    print("set add NaN again: " .. tostring(s:add(nan)) .. " " .. s.size)
    print("set contains: " .. tostring(s:contains(nan)) .. " " .. tostring(s:contains(nz)) .. " " .. tostring(s:contains(0.0)) .. " " .. tostring(s:contains(1.0)))
    print("set remove -0.0: " .. tostring(s:remove(nz)) .. " " .. s.size .. " " .. tostring(s:contains(nz)) .. " " .. tostring(s:contains(0.0)))
    print("set remove NaN: " .. tostring(s:remove(nan)) .. " " .. s.size .. " " .. tostring(s:contains(nan)))
    local linked = __K2L_SetOf(1.0, nz, nan, 0.0, 2.0)
    linked:remove(nz)
    print("linked after remove: " .. linked.size .. " " .. tostring(linked:contains(nan)) .. " " .. tostring(linked:contains(0.0)) .. " " .. tostring(linked:contains(2.0)))
    linked:remove(1.0)
    print("linked after remove 1.0: " .. tostring(linked:contains(nan)) .. " " .. tostring(linked:contains(0.0)) .. " " .. tostring(linked:contains(2.0)))
    print("set equals: " .. tostring(__K2L_Equals(__K2L_ReadOnlySetOf(nan, nz), __K2L_ReadOnlySetOf(nz, nan))) .. " " .. tostring(__K2L_Equals(__K2L_ReadOnlySetOf(0.0), __K2L_ReadOnlySetOf(nz))))
    print("set hash: " .. __K2L_Hash(__K2L_ReadOnlySetOf(nan)) .. " " .. __K2L_Hash(__K2L_ReadOnlySetOf(nz)) .. " " .. __K2L_Hash(__K2L_ReadOnlySetOf(0.0)))
    local ints = __K2L_HashSetOf(1, 2, 3)
    ints:remove(2)
    print("int set: " .. tostring(ints:contains(1)) .. " " .. tostring(ints:contains(3)) .. " " .. ints.size)
end

local ____lambda_1 = function(it) return it end
local function maps()
    local nan = 0.0 / 0.0
    local nz = -0.0
    local m = __K2L_HashMap.new()
    m:set(nan, "nan")
    m:set(0.0, "zero")
    m:set(nz, "negative zero")
    m:set(nan, "nan again")
    print("map size: " .. m.size)
    print("map get: " .. __K2L_Str(m:get(nan)) .. " " .. __K2L_Str(m:get(0.0)) .. " " .. __K2L_Str(m:get(nz)) .. " " .. __K2L_Str(m:get(1.0)))
    print("map containsKey: " .. tostring(m:containsKey(nan)) .. " " .. tostring(m:containsKey(nz)))
    print("map remove: " .. __K2L_Str(m:remove(nz)) .. " " .. m.size .. " " .. __K2L_Str(m:get(0.0)) .. " " .. __K2L_Str(m:get(nan)))
    local values = __K2L_ReadOnlyMapOf(__K2L_Pair.new("a", nan), __K2L_Pair.new("b", nz))
    print("containsValue: " .. tostring(values:containsValue(nan)) .. " " .. tostring(values:containsValue(nz)) .. " " .. tostring(values:containsValue(0.0)))
    print("map equals: " .. tostring(__K2L_Equals(__K2L_SingletonMapOf(__K2L_Pair.new(nan, 1)), __K2L_SingletonMapOf(__K2L_Pair.new(nan, 1)))) .. " " .. tostring(__K2L_Equals(__K2L_SingletonMapOf(__K2L_Pair.new(1, nan)), __K2L_SingletonMapOf(__K2L_Pair.new(1, nan)))) .. " " .. tostring(__K2L_Equals(__K2L_SingletonMapOf(__K2L_Pair.new(1, 0.0)), __K2L_SingletonMapOf(__K2L_Pair.new(1, nz)))))
    local ____list = __K2L_ReadOnlyListOf(1.5, nan, -1.5, nan, 2.0)
    local ____result_2 = __K2L_Map.new()
    local ____items_2, ____n_2 = ____list:____array()
    for ____i_2 = 1, ____n_2 do
        local it = ____items_2[____i_2]
        local ____result_3
        if it ~= it then
            ____result_3 = it
        else
            ____result_3 = it < 0 and -0.0 or 0.0
        end
        local ____value = ____result_3
        local ____group = ____result_2:get(____value)
        if ____group == nil then
            ____group = __K2L_List.new()
            ____result_2:put(____value, ____group)
        end
        ____group:add(it)
    end
    local groups = ____result_2
    local ____arg = groups.size
    local ____receiver = groups:get(nan)
    local ____arg_1 = __K2L_Str(____receiver and ____receiver.size)
    local ____receiver_1 = groups:get(0.0)
    local ____arg_2 = __K2L_Str(____receiver_1 and ____receiver_1.size)
    local ____receiver_2 = groups:get(nz)
    print("groupBy: " .. ____arg .. " " .. ____arg_1 .. " " .. ____arg_2 .. " " .. __K2L_Str(____receiver_2 and ____receiver_2.size))
    local counts = __K2L_ReadOnlyListOf(nan, nan, 0.0, nz):groupingBy(____lambda_1):eachCount()
    print("eachCount: " .. counts.size .. " " .. __K2L_Str(counts:get(nan)) .. " " .. __K2L_Str(counts:get(0.0)) .. " " .. __K2L_Str(counts:get(nz)))
    local ____list_1 = __K2L_ReadOnlyListOf(nan, nz, 0.0)
    local ____result_4 = __K2L_Map.new()
    local ____items_3, ____n_3 = ____list_1:____array()
    for ____i_3 = 1, ____n_3 do
        local it = ____items_3[____i_3]
        local ____value_1 = __K2L_DoubleToString(it)
        ____result_4:put(it, ____value_1)
    end
    local assoc = ____result_4
    print("associateWith: " .. assoc.size .. " " .. __K2L_Str(assoc:get(nan)) .. " " .. __K2L_Str(assoc:get(nz)))
    local linked = __K2L_MapOf(__K2L_Pair.new(nz, "a"), __K2L_Pair.new(nan, "b"), __K2L_Pair.new(1.0, "c"))
    linked:remove(nz)
    print("linked map: " .. __K2L_Str(linked:get(nan)) .. " " .. __K2L_Str(linked:get(1.0)) .. " " .. linked.size)
end

local ____lambda_2 = function(it) return __K2L_DoubleToString(it) end
local ____lambda_3 = function(it) return __K2L_DoubleToString(it) end
local ____lambda_4 = function(it) return __K2L_DoubleToString(it) end
local ____lambda_5 = function(it) return __K2L_DoubleToString(it) end
local function trees()
    local nan = 0.0 / 0.0
    local nz = -0.0
    local t = __K2L_SortedSet.new()
    t:addAll(__K2L_ReadOnlyListOf(nan, 1.0, 0.0, nz, -math.huge, math.huge, nan, -1.0))
    print("tree set: " .. t.size .. " " .. t:joinToString(nil, nil, nil, nil, nil, ____lambda_2))
    print("tree first/last: " .. __K2L_DoubleToString(t:first()) .. " " .. __K2L_DoubleToString(t:last()) .. " " .. tostring(t:contains(nan)) .. " " .. tostring(t:contains(nz)))
    print("tree higher(-0.0): " .. __K2L_DoubleToString(t:higher(nz)) .. " lower(0.0): " .. __K2L_DoubleToString(t:lower(0.0)))
    local tm = __K2L_SortedMap.new()
    tm:set(nan, 1)
    tm:set(0.0, 2)
    tm:set(nz, 3)
    tm:set(nan, 4)
    print("tree map: " .. tm.size .. " " .. tm:getKeys():joinToString(nil, nil, nil, nil, nil, ____lambda_3) .. " " .. __K2L_Str(tm:get(nan)) .. " " .. __K2L_Str(tm:get(nz)))
    print("sorted: " .. __K2L_ReadOnlyListOf(nan, 1.0, 0.0, nz, -1.0):sorted():joinToString(nil, nil, nil, nil, nil, ____lambda_4))
    print("sortedDescending: " .. __K2L_ReadOnlyListOf(nan, 1.0, 0.0, nz):sortedDescending():joinToString(nil, nil, nil, nil, nil, ____lambda_5))
    print("max/min: " .. __K2L_DoubleToString(__K2L_ReadOnlyListOf(nz, 0.0):max()) .. " " .. __K2L_DoubleToString(__K2L_ReadOnlyListOf(0.0, nz):min()) .. " " .. __K2L_DoubleToString(__K2L_ReadOnlyListOf(1.0, nan):max()))
    print("compareTo: " .. __K2L_Compare(nan, nan) .. " " .. __K2L_Compare(nz, 0.0) .. " " .. __K2L_Compare(0.0, nz) .. " " .. __K2L_Compare(nan, math.huge))
end

local function boxed()
    local nan = 0.0 / 0.0
    local nz = -0.0
    local a = nan
    local b = nan
    local z = 0.0
    local n = nz
    print("Any ==: " .. tostring(__K2L_Equals(a, b)) .. " " .. tostring(__K2L_Equals(z, n)) .. " " .. tostring(__K2L_Equals(a, a)))
    print("Any equals(): " .. tostring(__K2L_Equals(a, b)) .. " " .. tostring(__K2L_Equals(z, n)) .. " " .. tostring(__K2L_DoubleEquals(nan, nan)) .. " " .. tostring(__K2L_DoubleEquals(nz, 0.0)))
    print("anyEquals: " .. tostring(anyEquals(nan, nan)) .. " " .. tostring(anyEquals(0.0, nz)) .. " " .. tostring(anyEquals(1.0, 1.0)) .. " " .. tostring(anyEquals(nil, nil)))
    print("generic: " .. tostring(generic(nan, nan)) .. " " .. tostring(generic(0.0, nz)) .. " " .. tostring(generic("a", "a")))
    print("Box: " .. tostring(Box.new(nan):same(nan)) .. " " .. tostring(Box.new(nz):same(0.0)) .. " " .. tostring(Box.new(2.0):same(2.0)))
    print("hashCode: " .. __K2L_Hash(nan) .. " " .. __K2L_Hash(nz) .. " " .. __K2L_Hash(0.0) .. " " .. __K2L_Hash(a) .. " " .. __K2L_Hash(n))
    print("Pair: " .. tostring(__K2L_Equals(__K2L_Pair.new(nan, 1), __K2L_Pair.new(nan, 1))) .. " " .. tostring(__K2L_Equals(__K2L_Pair.new(0.0, 1), __K2L_Pair.new(nz, 1))) .. " " .. tostring(__K2L_Pair.new(nan, nz):hashCode() == __K2L_Pair.new(nan, nz):hashCode()))
    print("Triple: " .. tostring(__K2L_Equals(__K2L_Triple.new(1, nan, 2), __K2L_Triple.new(1, nan, 2))))
    print("when Any: " .. describe(nan) .. " " .. describe(nz) .. " " .. describe(0.0) .. " " .. describe(1.0))
    print("Objects.equals: " .. tostring(__K2L_Equals(nan, nan)) .. " " .. tostring(__K2L_Equals(0.0, nz)))
end

local function dataClasses()
    local nan = 0.0 / 0.0
    local nz = -0.0
    print("Point: " .. tostring(Point.new(nan, 1.0):equals(Point.new(nan, 1.0))) .. " " .. tostring(Point.new(0.0, 1.0):equals(Point.new(nz, 1.0))) .. " " .. tostring(Point.new(1.0, 2.0):equals(Point.new(1.0, 2.0))))
    print("Point hash: " .. tostring(Point.new(nan, 0.0):hashCode() == Point.new(nan, 0.0):hashCode()) .. " " .. Point.new(0.0, 0.0):hashCode() .. " " .. Point.new(nz, 0.0):hashCode())
    print("Reading: " .. tostring(Reading.new("a", nan):equals(Reading.new("a", nan))) .. " " .. tostring(Reading.new("a", nil):equals(Reading.new("a", nil))) .. " " .. tostring(Reading.new("a", 0.0):equals(Reading.new("a", nz))))
    print("Ratio: " .. tostring(Ratio.new(0.0 / 0.0):equals(Ratio.new(0.0 / 0.0))) .. " " .. tostring(Ratio.new(0.0):equals(Ratio.new(-0.0))) .. " " .. tostring(Ratio.new(1.5):equals(Ratio.new(1.5))))
    print("in set: " .. tostring(__K2L_HashSetOf(Point.new(nan, nan)):contains(Point.new(nan, nan))) .. " " .. tostring(__K2L_HashSetOf(Point.new(0.0, 0.0)):contains(Point.new(nz, 0.0))))
    local dz = 0
    local g = Grid.new(-dz, dz * -1)
    print("Grid: " .. tostring(g:equals(Grid.new(0, 0))) .. " " .. tostring(__K2L_HashSetOf(Grid.new(0, 0)):contains(g)) .. " " .. __K2L_Str(g))
end

local function primitives()
    local nan = 0.0 / 0.0
    local nz = -0.0
    local x = nan
    local y = nan
    local p = nz
    print("primitive ==: " .. tostring(x == x) .. " " .. tostring(x == nan) .. " " .. tostring(y == y) .. " " .. tostring(y == x) .. " " .. tostring(p == 0.0) .. " " .. tostring(x ~= x))
    local list = __K2L_SingletonListOf(nan)
    print("element ==: " .. tostring(list:get(0) == list:get(0)) .. " " .. tostring(list:get(0) == nan) .. " " .. tostring(list:first() == x))
    local f = 0.0 / 0.0
    print("float ==: " .. tostring(f == f) .. " " .. tostring(__K2L_SingletonListOf(f):contains(f)) .. " " .. __K2L_HashSetOf(0.0, -0.0).size)
    local any = nan
    if math.type(any) == "float" then
        print("smart cast ==: " .. tostring(any == any) .. " " .. tostring(any == nan))
    end
    local zero = 0
    local negated = -zero
    local product = zero * -3
    local quotient = __K2L_IDiv(zero, -3)
    local compound = 0
    compound = compound * -1
    local long = 0
    local longNegated = -long
    print("ints: " .. negated .. " " .. product .. " " .. quotient .. " " .. compound .. " " .. longNegated .. " " .. __K2L_FloorDiv(zero, -3) .. " " .. __K2L_FloorDiv(zero, -3))
    print("exact: " .. __K2L_Exact.neg(zero) .. " " .. __K2L_Exact.mul(zero, -1) .. " " .. __K2L_Exact.negLong(long) .. " " .. -zero .. " " .. -(zero * 5))
    print("int sets:" .. __K2L_HashSetOf(0, negated, product, quotient, compound).size .. " " .. tostring(__K2L_SingletonListOf(0):contains(negated)))
    print("int as Any: " .. tostring(anyEquals(0, negated)) .. " " .. tostring(anyEquals(0, longNegated)) .. " " .. __K2L_SortedSet.new(__K2L_ReadOnlyListOf(0, negated, product)).size)
end

local function others()
    local nan = 0.0 / 0.0
    local nz = -0.0
    local seq = __K2L_SequenceOf(1.0, nan, nz)
    print("sequence: " .. tostring(seq:contains(nan)) .. " " .. seq:indexOf(nan) .. " " .. seq:indexOf(0.0) .. " " .. seq:distinct():count() .. " " .. seq:plus(nan):plus(0.0):toSet().size)
    local deque = __K2L_ArrayDeque.new(__K2L_ReadOnlyListOf(nan, nz, 1.0))
    print("ArrayDeque: " .. tostring(deque:contains(nan)) .. " " .. deque:indexOf(nz) .. " " .. tostring(deque:contains(0.0)) .. " " .. tostring(deque:remove(nan)) .. " " .. deque.size)
    local jdeque = __K2L_Deque.new(__K2L_ReadOnlyListOf(nan, nz))
    print("java ArrayDeque: " .. tostring(jdeque:contains(nan)) .. " " .. tostring(jdeque:contains(0.0)) .. " " .. tostring(jdeque:remove(nz)) .. " " .. jdeque.size)
    local linked = __K2L_LinkedList.new(__K2L_ReadOnlyListOf(nan, 1.0))
    print("LinkedList: " .. tostring(linked:contains(nan)) .. " " .. linked:indexOf(nan))
    local ml = __K2L_ListOf(nan, 1.0, nz, 0.0, nan)
    ml:removeAll(__K2L_ReadOnlyListOf(nan, 0.0))
    print("removeAll: " .. ml.size .. " " .. tostring(ml:contains(nz)))
    local rl = __K2L_ListOf(nan, 1.0, nz, 0.0)
    rl:retainAll(__K2L_ReadOnlyListOf(nan, nz))
    print("retainAll: " .. rl.size .. " " .. tostring(rl:contains(nan)) .. " " .. tostring(rl:contains(0.0)))
    print("array contentEquals: " .. tostring(__K2L_TypedArrayOf("[Ljava.lang.Double;", nan):contentEquals(__K2L_TypedArrayOf("[Ljava.lang.Double;", nan))) .. " " .. tostring(__K2L_TypedArrayOf("[Ljava.lang.Double;", 0.0):contentEquals(__K2L_TypedArrayOf("[Ljava.lang.Double;", nz))))
    print("sortedSetOf: " .. __K2L_SortedSetOf(nan, 0.0, nz, nan).size .. " " .. __K2L_DoubleToString(__K2L_SortedSetOf(nan, nz):first()))
    print("stream distinct: " .. __K2L_Streams.ofCollection(__K2L_ReadOnlyListOf(nan, nan, nz, 0.0)):distinct():count())
    print("minus list: " .. __K2L_ReadOnlyListOf(nan, nz, 0.0, 1.0):minusAll(__K2L_ReadOnlyListOf(nan, 0.0)).size)
    print("indexOf in Any list: " .. __K2L_ReadOnlyListOf("a", nan, 1):indexOf(nan) .. " " .. __K2L_ReadOnlyListOf(nil, nz):indexOf(nz))
    local m = __K2L_MapOf(__K2L_Pair.new(0.0, 1), __K2L_Pair.new("0", 2))
    m:set(nz, 3)
    print("Any keys: " .. m.size .. " " .. __K2L_Str(m:get(nz)) .. " " .. __K2L_Str(m:get(0.0)))
end

local function main()
    others()
    lists()
    sets()
    maps()
    trees()
    boxed()
    dataClasses()
    primitives()
end

__K2L_Main(main)
return {Point = Point, Reading = Reading, Ratio = Ratio, Grid = Grid, Box = Box, generic = generic, anyEquals = anyEquals, describe = describe, lists = lists, sets = sets, maps = maps, trees = trees, boxed = boxed, dataClasses = dataClasses, primitives = primitives, others = others}
