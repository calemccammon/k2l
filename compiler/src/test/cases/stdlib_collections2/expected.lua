local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_CompareByDescending = ____lualib.__K2L_CompareByDescending
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NaturalOrder = ____lualib.__K2L_NaturalOrder
local __K2L_NullsFirst = ____lualib.__K2L_NullsFirst
local __K2L_NullsLast = ____lualib.__K2L_NullsLast
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ThenBy = ____lualib.__K2L_ThenBy

local function ordering()
    local xs = __K2L_ListOf(3, 1, 2)
    local words = __K2L_ListOf("bb", "a", "ccc")
    print(__K2L_Str(xs:sortedBy(function(it) return -it end)))
    print(__K2L_Str(xs:sortedWith(__K2L_ThenBy(__K2L_CompareBy(function(it) return math.fmod(it, 2) end), function(it) return it end))))
    print(__K2L_Str(xs:sortedWith(__K2L_CompareByDescending(function(it) return it end))))
    print(__K2L_Str(xs:sortedWith(function(a, b) return b - a end)))
    print(__K2L_Str(words:sortedWith(__K2L_CompareBy(function(it) return #it end, function(it) return it end))))
    print(__K2L_Str(__K2L_ListOf(3, nil, 1):sortedWith(__K2L_NullsFirst(__K2L_NaturalOrder))))
    print(__K2L_Str(__K2L_ListOf(3, nil, 1):sortedWith(__K2L_NullsLast(__K2L_NaturalOrder))))
    print(__K2L_Str(xs:sortedDescending()))
    print(words:maxBy(function(it) return #it end))
    print(__K2L_Str(words:minByOrNull(function(it) return #it end)))
    print(__K2L_Str(words:maxWithOrNull(__K2L_CompareBy(function(it) return #it end))))
    print(__K2L_Str(xs:reversed()))
end

local function grouping()
    local words = __K2L_ListOf("bb", "a", "ccc", "dd")
    print(__K2L_Str(words:groupBy(function(it) return #it end)))
    print(__K2L_Str(words:groupingBy(function(it) return #it end):eachCount()))
    print(__K2L_Str(words:associateBy(function(it) return #it end)))
    print(__K2L_Str(words:associate(function(it) return __K2L_Pair.new(it, #it) end)))
    print(__K2L_Str(words:partition(function(it) return #it > 1 end)))
    print(__K2L_Str(words:zip(__K2L_ListOf(1, 2, 3))))
    print(__K2L_Str(words:zip(__K2L_ListOf(1, 2, 3)):unzip()))
    print(__K2L_Str(words:distinctBy(function(it) return #it end)))
end

local function windows()
    local xs = __K2L_ListOf(3, 1, 2, 5, 4)
    print(__K2L_Str(xs:chunked(2)))
    print(__K2L_Str(xs:chunked(2, function(it) return it:sum() end)))
    print(__K2L_Str(xs:windowed(3)))
    print(__K2L_Str(xs:windowed(2, 2, true)))
    print(__K2L_Str(xs:zipWithNext()))
    print(__K2L_Str(xs:zipWithNext(function(a, b) return a + b end)))
    print(__K2L_Str(xs:scan(0, function(a, b) return a + b end)))
    print(__K2L_Str(xs:runningReduce(function(a, b) return a + b end)))
    print(xs:foldIndexed(0, function(i, a, b) return a + b * i end))
    print(xs:foldRight(0, function(a, b) return a - b end))
    print(xs:foldRightIndexed(0, function(i, a, b) return a + b * i end))
    print(xs:reduceRight(function(a, b) return a - b end))
    print(__K2L_Str(xs:reduceOrNull(function(a, b) return a + b end)))
end

local function slicing()
    local xs = __K2L_ListOf(3, 1, 2, 5, 4)
    print(__K2L_Str(xs:take(2)))
    print(__K2L_Str(xs:drop(2)))
    print(__K2L_Str(xs:takeLast(2)))
    print(__K2L_Str(xs:dropLast(2)))
    print(__K2L_Str(xs:takeWhile(function(it) return it > 1 end)))
    print(__K2L_Str(xs:dropWhile(function(it) return it > 1 end)))
    print(__K2L_Str(xs:takeLastWhile(function(it) return it > 1 end)))
    print(__K2L_Str(xs:dropLastWhile(function(it) return it > 1 end)))
    print(__K2L_Str(xs:slice(__K2L_IntRange.new(1, 3))))
    print(__K2L_Str(xs:slice(__K2L_ListOf(0, 4))))
    print(__K2L_Str(xs:elementAtOrNull(9)))
    print(xs:elementAtOrElse(9, function(it) return -1 end))
    print(xs:getOrElse(9, function(it) return -2 end))
    print(xs:indexOfFirst(function(it) return it > 2 end))
    print(xs:indexOfLast(function(it) return it > 2 end))
    print(xs:lastIndexOf(2))
    print(__K2L_Str(xs:asReversed()))
end

local function aggregates()
    local xs = __K2L_ListOf(3, 1, 2)
    print(xs:sumOf(function(it) return it * 2 end))
    print(__K2L_Str(xs:sumOf(function(it) return it + 0.0 end, 0.0)))
    print(__K2L_Str(xs:average()))
    print(xs:maxOf(function(it) return it * 2 end))
    print(__K2L_Str(xs:minOfOrNull(function(it) return it * 2 end)))
    print(xs:count(function(it) return it > 1 end))
    print(__K2L_Str(__K2L_ListOf():maxOrNull()))
    print(xs:joinToString(", ", "[", "]"))
    print(xs:joinToString("-", nil, nil, nil, nil, function(it) return "<" .. it .. ">" end))
    print(xs:joinToString(nil, nil, nil, 2, "..."))
    print(__K2L_Str(__K2L_ListOf(__K2L_ListOf(1), __K2L_ListOf(2, 3)):flatten()))
    print(__K2L_Str(xs:flatMap(function(it) return __K2L_ListOf(it, it) end)))
    print(__K2L_Str(xs:mapIndexedNotNull(function(i, v) return i > 0 and v or nil end)))
    print(__K2L_Str(xs:mapIndexedTo(__K2L_ListOf(), function(i, v) return i + v end)))
    print(__K2L_Str(xs:plus(4)))
    print(__K2L_Str(xs:plusAll(__K2L_ListOf(4, 5))))
    print(__K2L_Str(xs:minus(1)))
    print(__K2L_Str(xs:minusAll(__K2L_ListOf(1, 2))))
    print(xs:containsAll(__K2L_ListOf(1, 2)))
end

local function mutation()
    local ml = __K2L_ListOf(5, 3, 4, 1)
    print(__K2L_Str(ml:removeFirstOrNull()))
    print(__K2L_Str(ml:removeLastOrNull()))
    print(__K2L_Str(ml))
    ml:addAll(__K2L_ListOf(9, 8))
    ml:retainAll(function(it) return it > 3 end)
    print(__K2L_Str(ml))
    ml:sortDescending()
    print(__K2L_Str(ml))
    ml:addAt(1, 100)
    ml:removeAt(0)
    print(__K2L_Str(ml))
    ml:replaceAll(function(it) return it + 1 end)
    print(__K2L_Str(ml))
    ml:removeAll(function(it) return it > 100 end)
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

local function misc()
    local mixed = __K2L_ListOf(1, "a", 2, "b", 3.5)
    print(__K2L_Str(mixed:filter(function(x) return math.type(x) == "integer" end)))
    print(__K2L_Str(mixed:filter(function(x) return type(x) == "string" end)))
    local mp = __K2L_MapOf(__K2L_Pair.new("a", 1), __K2L_Pair.new("b", 2), __K2L_Pair.new("c", 3))
    print(__K2L_Str(mp:filterTo(__K2L_MapOf(), function(it) return it.value > 1 end)))
    print(__K2L_Str(mp:filter(function(it) return it.value > 1 end)))
    print(__K2L_Str(mp:mapValues(function(it) return it.value * 2 end)))
    print(__K2L_Str(mp:mapKeys(function(it) return it.key:upper() end)))
    print(__K2L_Str(mp:getEntries():sortedByDescending(function(it) return it.value end):map(function(it) return it.key end)))
    local ____receiver = mp:maxByOrNull(function(it) return it.value end)
    print(__K2L_Str(____receiver and ____receiver.key))
    print(__K2L_Str(mp:toList()))
    print(mp:getOrDefault("z", 0))
    print(__K2L_Str(__K2L_MapOf():ifEmpty(function() return __K2L_MapOf(__K2L_Pair.new("e", 0)) end)))
    print(__K2L_Str(mp:minus("a")))
    print(__K2L_Str(mp:plus(__K2L_Pair.new("d", 4))))
    print(__K2L_Str(__K2L_ArrayOf(3, 1, 2):sortedArray():toList()))
    print(__K2L_ArrayOf(3, 1, 2):sum())
    print(__K2L_ListOfSize(2, function(it)
        return __K2L_ListOfSize(2, function(it) return it end, true)
    end, true):contentDeepToString())
    print(__K2L_Str(__K2L_ListOf():ifEmpty(function() return __K2L_ListOf(0) end)))
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
