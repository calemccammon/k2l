local ____lualib = require("lualib_bundle")
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_CompareValues = ____lualib.__K2L_CompareValues
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Fmod = ____lualib.__K2L_Fmod
local __K2L_IRem = ____lualib.__K2L_IRem
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_JavaRandom = ____lualib.__K2L_JavaRandom
local __K2L_JdkCollections = ____lualib.__K2L_JdkCollections
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
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
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Log
local Item = __K2L_Class("Item")
Item.____comparable = true

function Item:____init(key, id)
    self.key = key
    self.id = id
end

function Item.new(key, id)
    return setmetatable({key = key, id = id}, Item)
end

function Item:compareTo(other)
    local ____object = Log
    ____object.calls = ____object.calls + 1
    local ____object_1 = Log
    local ____dividend = Log.hash * 31 + self.key * 7 + other.key
    ____object_1.hash = ____dividend >= 0 and ____dividend % 999983 or 0 - -____dividend % 999983
    return __K2L_Compare(self.key, other.key)
end

function Item:toString()
    return "Item(key=" .. self.key .. ", id=" .. self.id .. ")"
end

function Item:hashCode()
    return (31 * self.key + self.id + 0x80000000 & 0xFFFFFFFF) - 0x80000000
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
    local ____dividend_1 = self.hash * 31 + a * 7 + b
    self.hash = ____dividend_1 >= 0 and ____dividend_1 % 999983 or 0 - -____dividend_1 % 999983
end

function Log:summary()
    return "calls=" .. self.calls .. " hash=" .. self.hash
end

Log:____init()
local Lcg = __K2L_Class("Lcg")

function Lcg:____init(state)
    self.state = state
end

function Lcg.new(state)
    return setmetatable({state = state}, Lcg)
end

function Lcg:next(bound)
    local ____dividend_2 = self.state * 75 + 74
    self.state = ____dividend_2 >= 0 and ____dividend_2 % 65537 or 0 - -____dividend_2 % 65537
    return bound ~= 0 and __K2L_Fmod(self.state, bound) + 0 or __K2L_IRem(self.state, bound)
end

local function shapes(n, seed)
    local rnd = Lcg.new(seed)
    local ____out = {}
    for ____i = 1, n do
        local it = ____i - 1
        ____out[____i] = rnd:next(1000)
    end
    local ____arg = __K2L_ListWrap(____out, n)
    local ____out_1 = {}
    for ____i_1 = 1, n do
        local it = ____i_1 - 1
        ____out_1[____i_1] = rnd:next(4)
    end
    local ____arg_1 = __K2L_ListWrap(____out_1, n)
    local ____out_2 = {}
    for ____i_2 = 1, n do
        local it = ____i_2 - 1
        ____out_2[____i_2] = it
    end
    local ____arg_2 = __K2L_ListWrap(____out_2, n)
    local ____out_3 = {}
    for ____i_3 = 1, n do
        local it = ____i_3 - 1
        ____out_3[____i_3] = n - it
    end
    local ____arg_3 = __K2L_ListWrap(____out_3, n)
    local ____out_4 = {}
    for ____i_4 = 1, n do
        local it = ____i_4 - 1
        local ____result
        do
            local ____dividend_3 = it * 7
            ____result = ____dividend_3 >= 0 and ____dividend_3 % 13 or 0 - -____dividend_3 % 13
        end
        ____out_4[____i_4] = ____result
    end
    local ____arg_4 = __K2L_ListWrap(____out_4, n)
    local ____out_5 = {}
    for ____i_5 = 1, n do
        local it = ____i_5 - 1
        local ____result_1
        ____result_1 = (it >= 0 and it % 50 or 0 - -it % 50) < 25 and it or n - it
        ____out_5[____i_5] = ____result_1
    end
    local ____arg_5 = __K2L_ListWrap(____out_5, n)
    local ____out_6 = {}
    for ____i_6 = 1, n do
        local it = ____i_6 - 1
        local ____result_2
        ____result_2 = rnd:next(10) == 0 and rnd:next(1000) or it
        ____out_6[____i_6] = ____result_2
    end
    return __K2L_ReadOnlyListOf(____arg, ____arg_1, ____arg_2, ____arg_3, ____arg_4, ____arg_5, __K2L_ListWrap(____out_6, n))
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
    local ____mod = sizes.____modCount
    for ____i_7 = 1, sizes.size do
        local n = sizes[____i_7]
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
        if sizes.____modCount ~= ____mod and sizes:____comodified(____i_7) then
            break
        end
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

local ____lambda_1 = function(it) return it end
local ____lambda_2 = function(it) return it end
local function comparables()
    local rnd = Lcg.new(7)
    local ____out_7 = {}
    for ____i_8 = 1, 80 do
        local it = ____i_8 - 1
        ____out_7[____i_8] = Item.new(rnd:next(20), it)
    end
    local items = __K2L_ListWrap(____out_7, 80)
    Log:reset()
    local sorted = items:sorted()
    local ____arg_6 = Log:summary()
    local ____list_1 = sorted:zipWithNext()
    local ____result_3 = true
    local ____items, ____n = ____list_1:____array()
    for ____i_9 = 1, ____n do
        local ____it = ____items[____i_9]
        local ____result_4
        do
            local a, b = ____it.first, ____it.second
            ____result_4 = a.key < b.key or a.key == b.key and a.id < b.id
        end
        if not ____result_4 then
            ____result_3 = false
            break
        end
    end
    print("sorted() " .. ____arg_6 .. " stable=" .. tostring(____result_3))
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
    local array = items:toTypedArray("[LItem;")
    array:sort()
    print("Array.sort() " .. Log:summary() .. " " .. tostring(__K2L_Equals(array:toList(), sorted)))
    Log:reset()
    print("max " .. __K2L_Str(items:max()) .. " " .. Log:summary())
    Log:reset()
    print("maxOrNull " .. __K2L_Str(items:maxOrNull()) .. " minOrNull " .. __K2L_Str(items:minOrNull()) .. " " .. Log:summary())
    Log:reset()
    print("sortedBy item " .. __K2L_Str(items:sortedBy(____lambda_1, true):first()) .. " " .. Log:summary())
    Log:reset()
    print("maxBy " .. __K2L_Str(items:maxBy(____lambda_2)) .. " " .. Log:summary())
end

local function javaSorts()
    local rnd = Lcg.new(3)
    local ____out_8 = {}
    for ____i_10 = 1, 150 do
        local it = ____i_10 - 1
        ____out_8[____i_10] = rnd:next(500)
    end
    local values = __K2L_ListWrap(____out_8, 150)
    Log:reset()
    local list = values:toMutableList()
    __K2L_JdkCollections.sort(list, byValue)
    print("Collections.sort " .. Log:summary())
    Log:reset()
    local array = values:toTypedArray("[Ljava.lang.Integer;")
    __K2L_JdkCollections.sort_array(array, byValue)
    print("Arrays.sort " .. Log:summary() .. " " .. tostring(__K2L_Equals(array:toList(), list)))
    Log:reset()
    local part = values:toTypedArray("[Ljava.lang.Integer;")
    __K2L_JdkCollections.sort_array(part, 10, 120, byValue)
    print("Arrays.sort range " .. Log:summary() .. " " .. __K2L_Str(part:take(12)))
    Log:reset()
    local other = values:toTypedArray("[Ljava.lang.Integer;")
    other:sortWith(byValue)
    print("Array.sortWith " .. Log:summary())
    Log:reset()
    print("sortedArrayWith " .. __K2L_Str(values:toTypedArray("[Ljava.lang.Integer;"):sortedArrayWith(byValue):take(5)) .. " " .. Log:summary())
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
        local ____out_9 = {}
        for ____i_11 = 1, 400 do
            local it = ____i_11 - 1
            ____out_9[____i_11] = rnd:next(100)
        end
        local values = __K2L_ListWrap(____out_9, 400)
        local coin = Lcg.new(seed * 13)
        local result
        local ____ok, ____result_5 = __K2L_DeepPcall(function()
            values:sortedWith(function(_, _) return coin:next(3) - 1 end)
            result = "sorted"
        end)
        if not ____ok then
            local ____error = __K2L_ToThrowable(____result_5)
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

function Counted.new(raw)
    return setmetatable({raw = raw}, Counted)
end

function Counted:getKey()
    local ____object_2 = Log
    ____object_2.calls = ____object_2.calls + 1
    return self.raw >= 0 and self.raw % 5 or 0 - -self.raw % 5
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

local ____lambda_3 = function(it) return it.key end
local ____lambda_4 = function(it) return it.key * 2 - it.id end
local ____lambda_5 = function(receiver) return receiver.id end
local ____lambda_6 = function(it) return #it end
local ____lambda_7 = function(it) return it.first end
local ____lambda_8 = function(it) return it.ordinal end
local ____lambda_9 = function(it) return it end
local ____lambda_10 = function(it) return __K2L_Str(it) end
local ____lambda_11 = function(it) return __K2L_Str(it) end
local ____lambda_12 = function(it) return __K2L_Str(it) end
local ____lambda_13 = function(it) return it.value end
local ____lambda_14 = function(it)
    return it.id >= 0 and it.id % 7 or 0 - -it.id % 7
end
local ____lambda_15 = function(it) return -it.id end
local ____lambda_16 = function(it) return it:getKey() end
local function pureSelectors()
    local rnd = Lcg.new(11)
    local ____out_10 = {}
    for ____i_12 = 1, 60 do
        local it = ____i_12 - 1
        ____out_10[____i_12] = Item.new(rnd:next(9), it)
    end
    local items = __K2L_ListWrap(____out_10, 60)
    print(__K2L_Str(items:sortedBy(____lambda_3, true):take(6)))
    print(__K2L_Str(items:sortedByDescending(____lambda_4, true):take(4)))
    print(__K2L_Str(items:sortedBy(__K2L_PropertyRef.new("id", "id@145", ____lambda_5), true):take(3)))
    print(__K2L_Str(__K2L_ReadOnlyListOf("bb", "a", "ccc", "dd"):sortedBy(____lambda_6, true)))
    print(__K2L_Str(__K2L_ReadOnlyListOf(__K2L_Pair.new(1, "z"), __K2L_Pair.new(0, "y"), __K2L_Pair.new(1, "x")):sortedBy(____lambda_7, true)))
    print(__K2L_Str(__K2L_ReadOnlyListOf(Suit.SPADES, Suit.CLUBS, Suit.HEARTS):sortedByDescending(____lambda_8, true)))
    print(__K2L_ReadOnlyListOf(2.5, -0.0, 0.0, 0.0 / 0.0, -1.0):sortedBy(____lambda_9, true):joinToString(nil, nil, nil, nil, nil, ____lambda_10))
    print(__K2L_ReadOnlyListOf(0.0, 0.0 / 0.0, -0.0, -3.5):sorted():joinToString(nil, nil, nil, nil, nil, ____lambda_11))
    local ____out_11 = {}
    for ____i_13 = 1, 40 do
        local it = ____i_13 - 1
        local ____result_6
        if (it >= 0 and it % 7 or 0 - -it % 7) == 0 then
            ____result_6 = 0.0 / 0.0
        else
            ____result_6 = (it >= 0 and it % 2 or 0 - -it % 2) == 0 and -0.0 or 0.0
        end
        ____out_11[____i_13] = ____result_6
    end
    print(__K2L_ListWrap(____out_11, 40):sortedDescending():joinToString(nil, nil, nil, nil, nil, ____lambda_12))
    print(__K2L_Compare(-0.0, 0.0) .. " " .. __K2L_Compare(0.0 / 0.0, 1.0) .. " " .. __K2L_CompareValues(0.0 / 0.0, 0.0 / 0.0) .. " " .. __K2L_CompareValues(0.0, -0.0))
    local ____list_2 = __K2L_ReadOnlyMapOf(__K2L_Pair.new("b", 2), __K2L_Pair.new("a", 1)):getEntries():sortedBy(____lambda_13, true)
    local ____out_12 = {}
    local ____count = 0
    local ____items_1, ____n_1 = ____list_2:____array()
    for ____i_14 = 1, ____n_1 do
        local it = ____items_1[____i_14]
        ____count = ____count + 1
        ____out_12[____count] = it.key
    end
    print(__K2L_Str(__K2L_ListWrap(____out_12, ____count)))
    local mutable = items:toMutableList()
    mutable:sortBy(____lambda_14)
    print(__K2L_Str(mutable:take(5)))
    print(__K2L_Str(__K2L_AsSequence(items):sortedBy(____lambda_15, true):take(2):toList()))
    Log:reset()
    local ____out_13 = {}
    for ____i_15 = 1, 40 do
        local it = ____i_15 - 1
        local ____result_7
        do
            local ____dividend_4 = it * 37
            ____result_7 = Counted.new(____dividend_4 >= 0 and ____dividend_4 % 41 or 0 - -____dividend_4 % 41)
        end
        ____out_13[____i_15] = ____result_7
    end
    local counted = __K2L_ListWrap(____out_13, 40):sortedBy(____lambda_16)
    local ____arg_7 = Log.calls
    local ____list_3 = counted:take(5)
    local ____out_14 = {}
    local ____count_1 = 0
    local ____items_2, ____n_2 = ____list_3:____array()
    for ____i_16 = 1, ____n_2 do
        local it = ____items_2[____i_16]
        ____count_1 = ____count_1 + 1
        ____out_14[____count_1] = it.raw
    end
    print("getter selector calls=" .. ____arg_7 .. " " .. __K2L_Str(__K2L_ListWrap(____out_14, ____count_1)))
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

__K2L_DeepMain(main)
return {Item = Item, Log = Log, Lcg = Lcg, shapes = shapes, byValue = byValue, smallSequence = smallSequence, counts = counts, selectors = selectors, comparables = comparables, javaSorts = javaSorts, brokenComparators = brokenComparators, Counted = Counted, Suit = Suit, pureSelectors = pureSelectors}
