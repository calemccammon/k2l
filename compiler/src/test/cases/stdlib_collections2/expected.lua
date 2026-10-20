local ____lualib = require("lualib_bundle")
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_CompareByDescending = ____lualib.__K2L_CompareByDescending
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NaturalOrder = ____lualib.__K2L_NaturalOrder
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_NullsFirst = ____lualib.__K2L_NullsFirst
local __K2L_NullsLast = ____lualib.__K2L_NullsLast
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ThenBy = ____lualib.__K2L_ThenBy
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf

local ____lambda_1 = function(it) return -it end
local ____lambda_2 = function(it) return it >= 0 and it % 2 or 0 - -it % 2 end
local ____lambda_3 = function(it) return it end
local ____lambda_4 = function(it) return it end
local ____lambda_5 = function(a, b) return b - a end
local ____lambda_6 = function(it) return #it end
local ____lambda_7 = function(it) return it end
local ____lambda_8 = function(it) return #it end
local ____lambda_9 = function(it) return #it end
local ____lambda_10 = function(it) return #it end
local function ordering()
    local xs = __K2L_ReadOnlyListOf(3, 1, 2)
    local words = __K2L_ReadOnlyListOf("bb", "a", "ccc")
    print(__K2L_Str(xs:sortedBy(____lambda_1, true)))
    print(__K2L_Str(xs:sortedWith(__K2L_ThenBy(__K2L_CompareBy(____lambda_2), ____lambda_3))))
    print(__K2L_Str(xs:sortedWith(__K2L_CompareByDescending(____lambda_4))))
    print(__K2L_Str(xs:sortedWith(____lambda_5)))
    print(__K2L_Str(words:sortedWith(__K2L_CompareBy(____lambda_6, ____lambda_7))))
    print(__K2L_Str(__K2L_ReadOnlyListOf(3, nil, 1):sortedWith(__K2L_NullsFirst(__K2L_NaturalOrder))))
    print(__K2L_Str(__K2L_ReadOnlyListOf(3, nil, 1):sortedWith(__K2L_NullsLast(__K2L_NaturalOrder))))
    print(__K2L_Str(xs:sortedDescending()))
    print(words:maxBy(____lambda_8))
    print(__K2L_Str(words:minByOrNull(____lambda_9)))
    print(__K2L_Str(words:maxWithOrNull(__K2L_CompareBy(____lambda_10))))
    print(__K2L_Str(xs:reversed()))
end

local ____lambda_11 = function(it) return #it end
local ____lambda_12 = function(it) return __K2L_Pair.new(it, #it) end
local ____lambda_13 = function(it) return #it > 1 end
local ____lambda_14 = function(it) return #it end
local function grouping()
    local words = __K2L_ReadOnlyListOf("bb", "a", "ccc", "dd")
    local ____result = __K2L_Map.new()
    local ____items, ____n = words:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        local ____value = #it
        local ____group = ____result:get(____value)
        if ____group == nil then
            ____group = __K2L_List.new()
            ____result:put(____value, ____group)
        end
        ____group:add(it)
    end
    print(__K2L_Str(____result))
    print(__K2L_Str(words:groupingBy(____lambda_11):eachCount()))
    local ____result_1 = __K2L_Map.new()
    local ____items_1, ____n_1 = words:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        local ____value_1 = #it
        ____result_1:put(____value_1, it)
    end
    print(__K2L_Str(____result_1))
    print(__K2L_Str(words:associate(____lambda_12)))
    print(__K2L_Str(words:partition(____lambda_13)))
    print(__K2L_Str(words:zip(__K2L_ReadOnlyListOf(1, 2, 3))))
    print(__K2L_Str(words:zip(__K2L_ReadOnlyListOf(1, 2, 3)):unzip()))
    print(__K2L_Str(words:distinctBy(____lambda_14)))
end

local ____lambda_15 = function(it) return it:sum() end
local ____lambda_16 = function(a, b) return a + b end
local ____lambda_17 = function(a, b) return a + b end
local ____lambda_18 = function(a, b) return a + b end
local ____lambda_19 = function(i, a, b) return a + b * i end
local ____lambda_20 = function(a, b) return a - b end
local ____lambda_21 = function(i, a, b) return a + b * i end
local ____lambda_22 = function(a, b) return a - b end
local ____lambda_23 = function(a, b) return a + b end
local function windows()
    local xs = __K2L_ReadOnlyListOf(3, 1, 2, 5, 4)
    print(__K2L_Str(xs:chunked(2)))
    print(__K2L_Str(xs:chunked(2, ____lambda_15)))
    print(__K2L_Str(xs:windowed(3)))
    print(__K2L_Str(xs:windowed(2, 2, true)))
    print(__K2L_Str(xs:zipWithNext()))
    print(__K2L_Str(xs:zipWithNext(____lambda_16)))
    print(__K2L_Str(xs:scan(0, ____lambda_17)))
    print(__K2L_Str(xs:runningReduce(____lambda_18)))
    print(xs:foldIndexed(0, ____lambda_19))
    print(xs:foldRight(0, ____lambda_20))
    print(xs:foldRightIndexed(0, ____lambda_21))
    print(xs:reduceRight(____lambda_22))
    print(__K2L_Str(xs:reduceOrNull(____lambda_23)))
end

local ____lambda_24 = function(it) return it > 1 end
local ____lambda_25 = function(it) return it > 1 end
local ____lambda_26 = function(it) return it > 1 end
local ____lambda_27 = function(it) return it > 1 end
local ____lambda_28 = function(it) return -1 end
local ____lambda_29 = function(it) return -2 end
local ____lambda_30 = function(it) return it > 2 end
local ____lambda_31 = function(it) return it > 2 end
local function slicing()
    local xs = __K2L_ReadOnlyListOf(3, 1, 2, 5, 4)
    print(__K2L_Str(xs:take(2)))
    print(__K2L_Str(xs:drop(2)))
    print(__K2L_Str(xs:takeLast(2)))
    print(__K2L_Str(xs:dropLast(2)))
    print(__K2L_Str(xs:takeWhile(____lambda_24)))
    print(__K2L_Str(xs:dropWhile(____lambda_25)))
    print(__K2L_Str(xs:takeLastWhile(____lambda_26)))
    print(__K2L_Str(xs:dropLastWhile(____lambda_27)))
    print(__K2L_Str(xs:slice(__K2L_IntRange.new(1, 3))))
    print(__K2L_Str(xs:slice(__K2L_ReadOnlyListOf(0, 4))))
    print(__K2L_Str(xs:elementAtOrNull(9)))
    print(xs:elementAtOrElse(9, ____lambda_28))
    print(xs:getOrElse(9, ____lambda_29))
    print(xs:indexOfFirst(____lambda_30))
    print(xs:indexOfLast(____lambda_31))
    print(xs:lastIndexOf(2))
    print(__K2L_Str(xs:asReversed()))
end

local ____lambda_32 = function(it) return it * 2 end
local ____lambda_33 = function(it) return "<" .. it .. ">" end
local ____lambda_34 = function(i, v) return i > 0 and v or nil end
local ____lambda_35 = function(i, v) return i + v end
local function aggregates()
    local xs = __K2L_ReadOnlyListOf(3, 1, 2)
    local ____sum = 0
    local ____items_2, ____n_2 = xs:____array()
    for ____i_2 = 1, ____n_2 do
        local it = ____items_2[____i_2]
        ____sum = ____sum + it * 2
    end
    print(____sum)
    local ____sum_1 = 0.0
    local ____items_3, ____n_3 = xs:____array()
    for ____i_3 = 1, ____n_3 do
        local it = ____items_3[____i_3]
        ____sum_1 = ____sum_1 + (it + 0.0)
    end
    print(__K2L_Str(____sum_1))
    print(__K2L_Str(xs:average()))
    local ____best
    local ____has = false
    local ____items_4, ____n_4 = xs:____array()
    for ____i_4 = 1, ____n_4 do
        local it = ____items_4[____i_4]
        local ____key = it * 2
        if not ____has or ____best < ____key then
            ____best = ____key
            ____has = true
        end
    end
    if not ____has then
        error(__K2L_NoSuchElementException.new(nil))
    end
    print(____best)
    print(__K2L_Str(xs:minOfOrNull(____lambda_32)))
    local ____result_2 = 0
    local ____items_5, ____n_5 = xs:____array()
    for ____i_5 = 1, ____n_5 do
        local it = ____items_5[____i_5]
        if it > 1 then
            ____result_2 = ____result_2 + 1
        end
    end
    print(____result_2)
    print(__K2L_Str(__K2L_ReadOnlyListOf():maxOrNull()))
    print(xs:joinToString(", ", "[", "]"))
    print(xs:joinToString("-", nil, nil, nil, nil, ____lambda_33))
    print(xs:joinToString(nil, nil, nil, 2, "..."))
    print(__K2L_Str(__K2L_ReadOnlyListOf(__K2L_SingletonListOf(1), __K2L_ReadOnlyListOf(2, 3)):flatten()))
    local ____out = {}
    local ____count = 0
    local ____items_6, ____n_6 = xs:____array()
    for ____i_6 = 1, ____n_6 do
        local it = ____items_6[____i_6]
        local ____inner, ____m = __K2L_ReadOnlyListOf(it, it):____array()
        for ____j = 1, ____m do
            ____count = ____count + 1
            ____out[____count] = ____inner[____j]
        end
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    print(__K2L_Str(xs:mapIndexedNotNull(____lambda_34)))
    print(__K2L_Str(xs:mapIndexedTo(__K2L_ListOf(), ____lambda_35)))
    print(__K2L_Str(xs:plus(4)))
    print(__K2L_Str(xs:plusAll(__K2L_ReadOnlyListOf(4, 5))))
    print(__K2L_Str(xs:minus(1)))
    print(__K2L_Str(xs:minusAll(__K2L_ReadOnlyListOf(1, 2))))
    print(xs:containsAll(__K2L_ReadOnlyListOf(1, 2)))
end

local ____lambda_36 = function(it) return it > 3 end
local ____lambda_37 = function(it) return it + 1 end
local ____lambda_38 = function(it) return it > 100 end
local function mutation()
    local ml = __K2L_ListOf(5, 3, 4, 1)
    print(__K2L_Str(ml:removeFirstOrNull()))
    print(__K2L_Str(ml:removeLastOrNull()))
    print(__K2L_Str(ml))
    ml:addAll(__K2L_ReadOnlyListOf(9, 8))
    ml:retainAll(____lambda_36)
    print(__K2L_Str(ml))
    ml:sortDescending()
    print(__K2L_Str(ml))
    ml:addAt(1, 100)
    ml:removeAt(0)
    print(__K2L_Str(ml))
    ml:replaceAll(____lambda_37)
    print(__K2L_Str(ml))
    ml:removeAll(____lambda_38)
    print(__K2L_Str(ml))
    local it = __K2L_IteratorOf(__K2L_ListOf(5, 3, 4))
    local kept = __K2L_ListOf()
    local all = __K2L_ListOf(5, 3, 4)
    local iter = __K2L_IteratorOf(all)
    while iter:hasNext() do
        local v = iter:next()
        if v == 3 then
            iter:remove()
        else
            kept:add(v)
        end
    end
    print(__K2L_Str(all))
    print(__K2L_Str(kept))
    print(it:next())
end

local ____lambda_39 = function(x) return math.type(x) == "integer" end
local ____lambda_40 = function(x) return type(x) == "string" end
local ____lambda_41 = function(it) return it.value > 1 end
local ____lambda_42 = function(it) return it.value > 1 end
local ____lambda_43 = function(it) return it.value * 2 end
local ____lambda_44 = function(it) return it.key:upper() end
local ____lambda_45 = function(it) return it.value end
local ____lambda_46 = function(it) return it.value end
local ____lambda_47 = function()
    return __K2L_SingletonMapOf(__K2L_Pair.new("e", 0))
end
local ____lambda_48 = function(it) return it end
local ____lambda_49 = function(it)
    return __K2L_ListOfSize(2, ____lambda_48, "[Ljava.lang.Integer;")
end
local ____lambda_50 = function() return __K2L_SingletonListOf(0) end
local function misc()
    local mixed = __K2L_ReadOnlyListOf(1, "a", 2, "b", 3.5)
    print(__K2L_Str(mixed:filter(____lambda_39)))
    print(__K2L_Str(mixed:filter(____lambda_40)))
    local mp = __K2L_ReadOnlyMapOf(__K2L_Pair.new("a", 1), __K2L_Pair.new("b", 2), __K2L_Pair.new("c", 3))
    print(__K2L_Str(mp:filterTo(__K2L_MapOf(), ____lambda_41)))
    print(__K2L_Str(mp:filter(____lambda_42)))
    print(__K2L_Str(mp:mapValues(____lambda_43)))
    print(__K2L_Str(mp:mapKeys(____lambda_44)))
    local ____list = mp:getEntries():sortedByDescending(____lambda_45, true)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_7, ____n_7 = ____list:____array()
    for ____i_7 = 1, ____n_7 do
        local it = ____items_7[____i_7]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = it.key
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
    local ____receiver = mp:maxByOrNull(____lambda_46)
    print(__K2L_Str(____receiver and ____receiver.key))
    print(__K2L_Str(mp:toList()))
    print(mp:getOrDefault("z", 0))
    print(__K2L_Str(__K2L_ReadOnlyMapOf():ifEmpty(____lambda_47)))
    print(__K2L_Str(mp:minus("a")))
    print(__K2L_Str(mp:plus(__K2L_Pair.new("d", 4))))
    print(__K2L_Str(__K2L_TypedArrayOf("[Ljava.lang.Integer;", 3, 1, 2):sortedArray():toList()))
    print(__K2L_TypedArrayOf("[I", 3, 1, 2):sum())
    print(__K2L_ListOfSize(2, ____lambda_49, "[[Ljava.lang.Integer;"):contentDeepToString())
    print(__K2L_Str(__K2L_ReadOnlyListOf():ifEmpty(____lambda_50)))
end

local function main()
    ordering()
    grouping()
    windows()
    slicing()
    aggregates()
    mutation()
    misc()
end

main()
return {ordering = ordering, grouping = grouping, windows = windows, slicing = slicing, aggregates = aggregates, mutation = mutation, misc = misc}
