local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_CompareValues = ____lualib.__K2L_CompareValues
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
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str

local ____lambda_1 = function(it) return -it end
local ____lambda_2 = function(____a, ____b)
    local ____x_1, ____y_1 = ____a % 2, ____b % 2
    if ____x_1 ~= ____y_1 then
        return ____x_1 < ____y_1 and -1 or 1
    end
    local ____x_2, ____y_2 = ____a, ____b
    if ____x_2 ~= ____y_2 then
        return ____x_2 < ____y_2 and -1 or 1
    end
    return 0
end
local ____lambda_3 = function(____a_1, ____b_1)
    local ____x_3, ____y_3 = ____b_1, ____a_1
    if ____x_3 ~= ____y_3 then
        return ____x_3 < ____y_3 and -1 or 1
    end
    return 0
end
local ____lambda_4 = function(a, b) return b - a end
local ____lambda_5 = function(____a_2, ____b_2)
    local ____x_4, ____y_4 = #____a_2, #____b_2
    if ____x_4 ~= ____y_4 then
        return ____x_4 < ____y_4 and -1 or 1
    end
    return __K2L_CompareValues(____a_2, ____b_2)
end
local ____lambda_6 = function(it) return #it end
local ____lambda_7 = function(it) return #it end
local ____lambda_8 = function(____a_3, ____b_3)
    local ____x_5, ____y_5 = #____a_3, #____b_3
    if ____x_5 ~= ____y_5 then
        return ____x_5 < ____y_5 and -1 or 1
    end
    return 0
end
local function ordering()
    local xs = __K2L_ListOf(3, 1, 2)
    local words = __K2L_ListOf("bb", "a", "ccc")
    print(__K2L_Str(xs:sortedBy(____lambda_1, true)))
    print(__K2L_Str(xs:sortedWith(____lambda_2)))
    print(__K2L_Str(xs:sortedWith(____lambda_3)))
    print(__K2L_Str(xs:sortedWith(____lambda_4)))
    print(__K2L_Str(words:sortedWith(____lambda_5)))
    print(__K2L_Str(__K2L_ListOf(3, nil, 1):sortedWith(__K2L_NullsFirst(__K2L_NaturalOrder))))
    print(__K2L_Str(__K2L_ListOf(3, nil, 1):sortedWith(__K2L_NullsLast(__K2L_NaturalOrder))))
    print(__K2L_Str(xs:sortedDescending()))
    print(words:maxBy(____lambda_6))
    print(__K2L_Str(words:minByOrNull(____lambda_7)))
    print(__K2L_Str(words:maxWithOrNull(____lambda_8)))
    print(__K2L_Str(xs:reversed()))
end

local ____lambda_9 = function(it) return #it end
local ____lambda_10 = function(it) return __K2L_Pair.new(it, #it) end
local ____lambda_11 = function(it) return #it > 1 end
local ____lambda_12 = function(it) return #it end
local function grouping()
    local words = __K2L_ListOf("bb", "a", "ccc", "dd")
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
    print(__K2L_Str(words:groupingBy(____lambda_9):eachCount()))
    local ____result_1 = __K2L_Map.new()
    local ____items_1, ____n_1 = words:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        local ____value_1 = #it
        ____result_1:put(____value_1, it)
    end
    print(__K2L_Str(____result_1))
    print(__K2L_Str(words:associate(____lambda_10)))
    print(__K2L_Str(words:partition(____lambda_11)))
    print(__K2L_Str(words:zip(__K2L_ListOf(1, 2, 3))))
    print(__K2L_Str(words:zip(__K2L_ListOf(1, 2, 3)):unzip()))
    print(__K2L_Str(words:distinctBy(____lambda_12)))
end

local ____lambda_13 = function(it) return it:sum() end
local ____lambda_14 = function(a, b) return a + b end
local ____lambda_15 = function(a, b) return a + b end
local ____lambda_16 = function(a, b) return a + b end
local ____lambda_17 = function(i, a, b) return a + b * i end
local ____lambda_18 = function(a, b) return a - b end
local ____lambda_19 = function(i, a, b) return a + b * i end
local ____lambda_20 = function(a, b) return a - b end
local ____lambda_21 = function(a, b) return a + b end
local function windows()
    local xs = __K2L_ListOf(3, 1, 2, 5, 4)
    print(__K2L_Str(xs:chunked(2)))
    print(__K2L_Str(xs:chunked(2, ____lambda_13)))
    print(__K2L_Str(xs:windowed(3)))
    print(__K2L_Str(xs:windowed(2, 2, true)))
    print(__K2L_Str(xs:zipWithNext()))
    print(__K2L_Str(xs:zipWithNext(____lambda_14)))
    print(__K2L_Str(xs:scan(0, ____lambda_15)))
    print(__K2L_Str(xs:runningReduce(____lambda_16)))
    print(xs:foldIndexed(0, ____lambda_17))
    print(xs:foldRight(0, ____lambda_18))
    print(xs:foldRightIndexed(0, ____lambda_19))
    print(xs:reduceRight(____lambda_20))
    print(__K2L_Str(xs:reduceOrNull(____lambda_21)))
end

local ____lambda_22 = function(it) return it > 1 end
local ____lambda_23 = function(it) return it > 1 end
local ____lambda_24 = function(it) return it > 1 end
local ____lambda_25 = function(it) return it > 1 end
local ____lambda_26 = function(it) return -1 end
local ____lambda_27 = function(it) return -2 end
local ____lambda_28 = function(it) return it > 2 end
local ____lambda_29 = function(it) return it > 2 end
local function slicing()
    local xs = __K2L_ListOf(3, 1, 2, 5, 4)
    print(__K2L_Str(xs:take(2)))
    print(__K2L_Str(xs:drop(2)))
    print(__K2L_Str(xs:takeLast(2)))
    print(__K2L_Str(xs:dropLast(2)))
    print(__K2L_Str(xs:takeWhile(____lambda_22)))
    print(__K2L_Str(xs:dropWhile(____lambda_23)))
    print(__K2L_Str(xs:takeLastWhile(____lambda_24)))
    print(__K2L_Str(xs:dropLastWhile(____lambda_25)))
    print(__K2L_Str(xs:slice(__K2L_IntRange.new(1, 3))))
    print(__K2L_Str(xs:slice(__K2L_ListOf(0, 4))))
    print(__K2L_Str(xs:elementAtOrNull(9)))
    print(xs:elementAtOrElse(9, ____lambda_26))
    print(xs:getOrElse(9, ____lambda_27))
    print(xs:indexOfFirst(____lambda_28))
    print(xs:indexOfLast(____lambda_29))
    print(xs:lastIndexOf(2))
    print(__K2L_Str(xs:asReversed()))
end

local ____lambda_30 = function(it) return it * 2 end
local ____lambda_31 = function(it) return "<" .. it .. ">" end
local ____lambda_32 = function(i, v) return i > 0 and v or nil end
local ____lambda_33 = function(i, v) return i + v end
local function aggregates()
    local xs = __K2L_ListOf(3, 1, 2)
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
    print(____sum_1)
    print(xs:average())
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
    print(__K2L_Str(xs:minOfOrNull(____lambda_30)))
    local ____result_2 = 0
    local ____items_5, ____n_5 = xs:____array()
    for ____i_5 = 1, ____n_5 do
        local it = ____items_5[____i_5]
        if it > 1 then
            ____result_2 = ____result_2 + 1
        end
    end
    print(____result_2)
    print(__K2L_Str(__K2L_ListOf():maxOrNull()))
    print(xs:joinToString(", ", "[", "]"))
    print(xs:joinToString("-", nil, nil, nil, nil, ____lambda_31))
    print(xs:joinToString(nil, nil, nil, 2, "..."))
    print(__K2L_Str(__K2L_ListOf(__K2L_ListOf(1), __K2L_ListOf(2, 3)):flatten()))
    local ____out = {}
    local ____count = 0
    local ____items_6, ____n_6 = xs:____array()
    for ____i_6 = 1, ____n_6 do
        local it = ____items_6[____i_6]
        local ____inner, ____m = __K2L_ListOf(it, it):____array()
        for ____j = 1, ____m do
            ____count = ____count + 1
            ____out[____count] = ____inner[____j]
        end
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    print(__K2L_Str(xs:mapIndexedNotNull(____lambda_32)))
    print(__K2L_Str(xs:mapIndexedTo(__K2L_ListOf(), ____lambda_33)))
    print(__K2L_Str(xs:plus(4)))
    print(__K2L_Str(xs:plusAll(__K2L_ListOf(4, 5))))
    print(__K2L_Str(xs:minus(1)))
    print(__K2L_Str(xs:minusAll(__K2L_ListOf(1, 2))))
    print(xs:containsAll(__K2L_ListOf(1, 2)))
end

local ____lambda_34 = function(it) return it > 3 end
local ____lambda_35 = function(it) return it + 1 end
local ____lambda_36 = function(it) return it > 100 end
local function mutation()
    local ml = __K2L_ListOf(5, 3, 4, 1)
    print(__K2L_Str(ml:removeFirstOrNull()))
    print(__K2L_Str(ml:removeLastOrNull()))
    print(__K2L_Str(ml))
    ml:addAll(__K2L_ListOf(9, 8))
    ml:retainAll(____lambda_34)
    print(__K2L_Str(ml))
    ml:sortDescending()
    print(__K2L_Str(ml))
    ml:addAt(1, 100)
    ml:removeAt(0)
    print(__K2L_Str(ml))
    ml:replaceAll(____lambda_35)
    print(__K2L_Str(ml))
    ml:removeAll(____lambda_36)
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

local ____lambda_37 = function(x) return math.type(x) == "integer" end
local ____lambda_38 = function(x) return type(x) == "string" end
local ____lambda_39 = function(it) return it.value > 1 end
local ____lambda_40 = function(it) return it.value > 1 end
local ____lambda_41 = function(it) return it.value * 2 end
local ____lambda_42 = function(it) return it.key:upper() end
local ____lambda_43 = function(it) return it.value end
local ____lambda_44 = function(it) return it.value end
local ____lambda_45 = function() return __K2L_MapOf(__K2L_Pair.new("e", 0)) end
local ____lambda_46 = function(it) return it end
local ____lambda_47 = function(it)
    return __K2L_ListOfSize(2, ____lambda_46, true)
end
local ____lambda_48 = function() return __K2L_ListOf(0) end
local function misc()
    local mixed = __K2L_ListOf(1, "a", 2, "b", 3.5)
    print(__K2L_Str(mixed:filter(____lambda_37)))
    print(__K2L_Str(mixed:filter(____lambda_38)))
    local mp = __K2L_MapOf(__K2L_Pair.new("a", 1), __K2L_Pair.new("b", 2), __K2L_Pair.new("c", 3))
    print(__K2L_Str(mp:filterTo(__K2L_MapOf(), ____lambda_39)))
    print(__K2L_Str(mp:filter(____lambda_40)))
    print(__K2L_Str(mp:mapValues(____lambda_41)))
    print(__K2L_Str(mp:mapKeys(____lambda_42)))
    local ____list = mp:getEntries():sortedByDescending(____lambda_43, true)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_7, ____n_7 = ____list:____array()
    for ____i_7 = 1, ____n_7 do
        local it = ____items_7[____i_7]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = it.key
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
    local ____receiver = mp:maxByOrNull(____lambda_44)
    print(__K2L_Str(____receiver and ____receiver.key))
    print(__K2L_Str(mp:toList()))
    print(mp:getOrDefault("z", 0))
    print(__K2L_Str(__K2L_MapOf():ifEmpty(____lambda_45)))
    print(__K2L_Str(mp:minus("a")))
    print(__K2L_Str(mp:plus(__K2L_Pair.new("d", 4))))
    print(__K2L_Str(__K2L_ArrayOf(3, 1, 2):sortedArray():toList()))
    print(__K2L_ArrayOf(3, 1, 2):sum())
    print(__K2L_ListOfSize(2, ____lambda_47, true):contentDeepToString())
    print(__K2L_Str(__K2L_ListOf():ifEmpty(____lambda_48)))
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

__K2L_RunMain(main)
return {ordering = ordering, grouping = grouping, windows = windows, slicing = slicing, aggregates = aggregates, mutation = mutation, misc = misc}
