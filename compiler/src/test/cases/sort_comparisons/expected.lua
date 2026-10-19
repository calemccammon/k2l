local ____lualib = require("lualib_bundle")
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_CompareValues = ____lualib.__K2L_CompareValues
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IRem = ____lualib.__K2L_IRem
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_JavaRandom = ____lualib.__K2L_JavaRandom
local __K2L_JdkCollections = ____lualib.__K2L_JdkCollections
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_ReverseComparator = ____lualib.__K2L_ReverseComparator
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ThenBy = ____lualib.__K2L_ThenBy
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Log
local Item = __K2L_Class("Item")

function Item:____init(key, id)
    self.key = key
    self.id = id
end

function Item:compareTo(other)
    local ____object = Log
    ____object.calls = ____object.calls + 1
    local ____object_1 = Log
    ____object_1.hash = math.fmod(Log.hash * 31 + self.key * 7 + other.key, 999983)
    return __K2L_Compare(self.key, other.key)
end

function Item:toString()
    return "Item(key=" .. self.key .. ", id=" .. self.id .. ")"
end

function Item:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.key) + __K2L_Hash(self.id))
end

function Item:equals(other)
    return getmetatable(other) == Item and self.key == other.key and self.id == other.id
end

Log = __K2L_Class("Log")

function Log:____init()
    self.calls = 0
    self.hash = 0
end

function Log:reset()
    self.calls = 0
    self.hash = 0
end

function Log:record(a, b)
    self.calls = self.calls + 1
    self.hash = math.fmod(self.hash * 31 + a * 7 + b, 999983)
end

function Log:summary()
    return "calls=" .. self.calls .. " hash=" .. self.hash
end

Log:____init()
local Lcg = __K2L_Class("Lcg")

function Lcg:____init(state)
    self.state = state
end

function Lcg:next(bound)
    self.state = math.fmod(self.state * 75 + 74, 65537)
    return __K2L_IRem(self.state, bound)
end

local function shapes(n, seed)
    local rnd = Lcg.new(seed)
    return __K2L_ReadOnlyListOf(__K2L_ListOfSize(n, function(it) return rnd:next(1000) end), __K2L_ListOfSize(n, function(it) return rnd:next(4) end), __K2L_ListOfSize(n, function(it) return it end), __K2L_ListOfSize(n, function(it) return n - it end), __K2L_ListOfSize(n, function(it) return math.fmod(it * 7, 13) end), __K2L_ListOfSize(n, function(it)
        return math.fmod(it, 50) < 25 and it or n - it
    end), __K2L_ListOfSize(n, function(it)
        return rnd:next(10) == 0 and rnd:next(1000) or it
    end))
end

local byValue = function(a, b)
    Log:record(a, b)
    return __K2L_Compare(a, b)
end

local function smallSequence()
    local calls = __K2L_ListOf()
    local sorted = __K2L_ReadOnlyListOf(5, 2, 4, 1, 3):sortedWith(function(a, b)
        calls:add(a .. "-" .. b)
        return a - b
    end)
    print(__K2L_Str(sorted) .. " " .. calls:joinToString(" "))
    calls:clear()
    local desc = __K2L_ReadOnlyListOf(1, 2, 3, 4):sortedWith(function(a, b)
        calls:add(a .. "-" .. b)
        return b - a
    end)
    print(__K2L_Str(desc) .. " " .. calls:joinToString(" "))
end

local function counts()
    local sizes = __K2L_ReadOnlyListOf(0, 1, 2, 3, 7, 31, 32, 33, 64, 65, 100, 257, 1000, 3000)
    for _, n in ipairs(sizes) do
        local line = __K2L_StringBuilder.new("n=" .. n)
        local ____list = shapes(n, n + 11)
        for i = 0, ____list.size - 1 do
            local input = ____list[i + 1]
            Log:reset()
            local sorted = input:sortedWith(byValue)
            if not __K2L_Equals(sorted, input:sorted()) then
                error(__K2L_IllegalStateException.new("Check failed."))
            end
            line:append(" [" .. i .. " " .. Log:summary() .. "]")
        end
        print(__K2L_Str(line))
    end
end

local function selectors()
    local selected = 0
    local words = __K2L_ReadOnlyListOf("pear", "fig", "banana", "kiwi", "apple", "plum", "cherry", "date")
    local byLength = words:sortedBy(function(it)
        selected = selected + 1
        return #it
    end)
    print("sortedBy " .. __K2L_Str(byLength) .. " selector=" .. selected)
    selected = 0
    local desc = words:sortedByDescending(function(it)
        selected = selected + 1
        return #it
    end)
    print("sortedByDescending " .. __K2L_Str(desc) .. " selector=" .. selected)
    local order = __K2L_ListOf()
    __K2L_ReadOnlyListOf("b", "a", "c"):sortedBy(function(it)
        order:add(it)
        return it
    end)
    print("selector order " .. __K2L_Str(order))
    order:clear()
    __K2L_ReadOnlyListOf("b", "a", "c"):sortedByDescending(function(it)
        order:add(it)
        return it
    end)
    print("descending selector order " .. __K2L_Str(order))
    selected = 0
    local mutable = words:toMutableList()
    mutable:sortBy(function(it)
        selected = selected + 1
        return __K2L_Text.last(it)
    end)
    print("sortBy " .. __K2L_Str(mutable) .. " selector=" .. selected)
    selected = 0
    mutable:sortByDescending(function(it)
        selected = selected + 1
        return __K2L_Text.first(it)
    end)
    print("sortByDescending " .. __K2L_Str(mutable) .. " selector=" .. selected)
    selected = 0
    local single = __K2L_SingletonListOf("x"):sortedBy(function(it)
        selected = selected + 1
        return it
    end)
    print("one element " .. __K2L_Str(single) .. " selector=" .. selected)
    selected = 0
    local chained = words:sortedWith(__K2L_ThenBy(__K2L_CompareBy(function(it)
        selected = selected + 1
        return #it
    end), function(it)
        selected = selected + 1
        return it
    end))
    print("compareBy.thenBy " .. __K2L_Str(chained) .. " selector=" .. selected)
end

local function comparables()
    local rnd = Lcg.new(7)
    local items = __K2L_ListOfSize(80, function(it) return Item.new(rnd:next(20), it) end)
    Log:reset()
    local sorted = items:sorted()
    print("sorted() " .. Log:summary() .. " stable=" .. tostring(sorted:zipWithNext():all(function(____destructured)
        local a, b = ____destructured.first, ____destructured.second
        return a.key < b.key or a.key == b.key and a.id < b.id
    end)))
    Log:reset()
    local desc = items:sortedDescending()
    print("sortedDescending() " .. Log:summary() .. " first=" .. __K2L_Str(desc:first()))
    Log:reset()
    local mutable = items:toMutableList()
    mutable:sort()
    print("sort() " .. Log:summary() .. " " .. tostring(__K2L_Equals(mutable, sorted)))
    Log:reset()
    mutable:sortDescending()
    print("sortDescending() " .. Log:summary() .. " " .. tostring(__K2L_Equals(mutable, desc)))
    Log:reset()
    local array = items:toTypedArray()
    array:sort()
    print("Array.sort() " .. Log:summary() .. " " .. tostring(__K2L_Equals(array:toList(), sorted)))
    Log:reset()
    print("max " .. __K2L_Str(items:max()) .. " " .. Log:summary())
    Log:reset()
    print("maxOrNull " .. __K2L_Str(items:maxOrNull()) .. " minOrNull " .. __K2L_Str(items:minOrNull()) .. " " .. Log:summary())
    Log:reset()
    print("sortedBy item " .. __K2L_Str(items:sortedBy(function(it) return it end, true):first()) .. " " .. Log:summary())
    Log:reset()
    print("maxBy " .. __K2L_Str(items:maxBy(function(it) return it end)) .. " " .. Log:summary())
end

local function javaSorts()
    local rnd = Lcg.new(3)
    local values = __K2L_ListOfSize(150, function(it) return rnd:next(500) end)
    Log:reset()
    local list = values:toMutableList()
    __K2L_JdkCollections.sort(list, byValue)
    print("Collections.sort " .. Log:summary())
    Log:reset()
    local array = values:toTypedArray()
    __K2L_JdkCollections.sort_array(array, byValue)
    print("Arrays.sort " .. Log:summary() .. " " .. tostring(__K2L_Equals(array:toList(), list)))
    Log:reset()
    local part = values:toTypedArray()
    __K2L_JdkCollections.sort_array(part, 10, 120, byValue)
    print("Arrays.sort range " .. Log:summary() .. " " .. __K2L_Str(part:take(12)))
    Log:reset()
    local other = values:toTypedArray()
    other:sortWith(byValue)
    print("Array.sortWith " .. Log:summary())
    Log:reset()
    print("sortedArrayWith " .. __K2L_Str(values:toTypedArray():sortedArrayWith(byValue):take(5)) .. " " .. Log:summary())
    Log:reset()
    list:shuffle(__K2L_JavaRandom.new(5))
    list:sortWith(byValue)
    print("MutableList.sortWith " .. Log:summary())
    Log:reset()
    print("reversed comparator " .. __K2L_Str(values:sortedWith(__K2L_ReverseComparator(byValue)):take(5)) .. " " .. Log:summary())
    Log:reset()
    print("maxWith " .. values:maxWith(byValue) .. " " .. Log:summary())
    Log:reset()
    print("minWith " .. values:minWith(byValue) .. " " .. Log:summary())
    local ____pairs = __K2L_ListOf()
    __K2L_ReadOnlyListOf(3, 1, 2):maxWithOrNull(function(a, b)
        ____pairs:add(a .. "-" .. b)
        return a - b
    end)
    print("maxWith order " .. __K2L_Str(____pairs))
end

local function brokenComparators()
    for seed = 1, 6 do
        local rnd = Lcg.new(seed)
        local values = __K2L_ListOfSize(400, function(it) return rnd:next(100) end)
        local coin = Lcg.new(seed * 13)
        local result
        local ____ok, ____result = pcall(function()
            values:sortedWith(function(_, _) return coin:next(3) - 1 end)
            result = "sorted"
        end)
        if not ____ok then
            local ____error = __K2L_ToThrowable(____result)
            if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
                local e = ____error
                result = e.message
            else
                error(____error, 0)
            end
        end
        print("random comparator " .. seed .. ": " .. __K2L_Str(result))
    end
end

local Counted = __K2L_Class("Counted")

function Counted:____init(raw)
    self.raw = raw
end

function Counted:getKey()
    local ____object_2 = Log
    ____object_2.calls = ____object_2.calls + 1
    return math.fmod(self.raw, 5)
end

local Suit = __K2L_Class("Suit")

function Suit:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Suit:toString()
    return self.name
end

function Suit:compareTo(other)
    return self.ordinal - other.ordinal
end

Suit.CLUBS = Suit.new("CLUBS", 0)
Suit.HEARTS = Suit.new("HEARTS", 1)
Suit.SPADES = Suit.new("SPADES", 2)
Suit.____values = {Suit.CLUBS, Suit.HEARTS, Suit.SPADES}

local function pureSelectors()
    local rnd = Lcg.new(11)
    local items = __K2L_ListOfSize(60, function(it) return Item.new(rnd:next(9), it) end)
    print(__K2L_Str(items:sortedBy(function(it) return it.key end, true):take(6)))
    print(__K2L_Str(items:sortedByDescending(function(it) return it.key * 2 - it.id end, true):take(4)))
    print(__K2L_Str(items:sortedBy(__K2L_PropertyRef.new("id", "id@145", function(receiver) return receiver.id end), true):take(3)))
    print(__K2L_Str(__K2L_ReadOnlyListOf("bb", "a", "ccc", "dd"):sortedBy(function(it) return #it end, true)))
    print(__K2L_Str(__K2L_ReadOnlyListOf(__K2L_Pair.new(1, "z"), __K2L_Pair.new(0, "y"), __K2L_Pair.new(1, "x")):sortedBy(function(it) return it.first end, true)))
    print(__K2L_Str(__K2L_ReadOnlyListOf(Suit.SPADES, Suit.CLUBS, Suit.HEARTS):sortedByDescending(function(it) return it.ordinal end, true)))
    print(__K2L_ReadOnlyListOf(2.5, -0.0, 0.0, 0.0 / 0.0, -1.0):sortedBy(function(it) return it end, true):joinToString(nil, nil, nil, nil, nil, function(it) return __K2L_Str(it) end))
    print(__K2L_ReadOnlyListOf(0.0, 0.0 / 0.0, -0.0, -3.5):sorted():joinToString(nil, nil, nil, nil, nil, function(it) return __K2L_Str(it) end))
    print(__K2L_ListOfSize(40, function(it)
        if math.fmod(it, 7) == 0 then
            return 0.0 / 0.0
        else
            return math.fmod(it, 2) == 0 and -0.0 or 0.0
        end
    end):sortedDescending():joinToString(nil, nil, nil, nil, nil, function(it) return __K2L_Str(it) end))
    print(__K2L_Compare(-0.0, 0.0) .. " " .. __K2L_Compare(0.0 / 0.0, 1.0) .. " " .. __K2L_CompareValues(0.0 / 0.0, 0.0 / 0.0) .. " " .. __K2L_CompareValues(0.0, -0.0))
    print(__K2L_Str(__K2L_ReadOnlyMapOf(__K2L_Pair.new("b", 2), __K2L_Pair.new("a", 1)):getEntries():sortedBy(function(it) return it.value end, true):map(function(it) return it.key end)))
    local mutable = items:toMutableList()
    mutable:sortBy(function(it) return math.fmod(it.id, 7) end)
    print(__K2L_Str(mutable:take(5)))
    print(__K2L_Str(__K2L_AsSequence(items):sortedBy(function(it) return -it.id end, true):take(2):toList()))
    Log:reset()
    local counted = __K2L_ListOfSize(40, function(it) return Counted.new(math.fmod(it * 37, 41)) end):sortedBy(function(it) return it:getKey() end)
    print("getter selector calls=" .. Log.calls .. " " .. __K2L_Str(counted:take(5):map(function(it) return it.raw end)))
end

local function main()
    smallSequence()
    pureSelectors()
    counts()
    selectors()
    comparables()
    javaSorts()
    brokenComparators()
end

main()
return {Item = Item, Log = Log, Lcg = Lcg, shapes = shapes, byValue = byValue, smallSequence = smallSequence, counts = counts, selectors = selectors, comparables = comparables, javaSorts = javaSorts, brokenComparators = brokenComparators, Counted = Counted, Suit = Suit, pureSelectors = pureSelectors}
