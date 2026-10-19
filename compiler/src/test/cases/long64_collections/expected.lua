local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_CompareByDescending = ____lualib.__K2L_CompareByDescending
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_HashSet = ____lualib.__K2L_HashSet
local __K2L_JdkCollections = ____lualib.__K2L_JdkCollections
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_PriorityQueue = ____lualib.__K2L_PriorityQueue
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SortedSet = ____lualib.__K2L_SortedSet
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ThenBy = ____lualib.__K2L_ThenBy
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf

local function main()
    local big = 5000000000000000000
    local max = 9223372036854775807
    local min = -9223372036854775807 - 1
    local arr = __K2L_TypedArrayOf("[J", max, 5, min, big, -3, 0)
    arr:sort()
    print(__K2L_Str(arr:toList()))
    arr:sortDescending()
    print(__K2L_Str(arr:toList()))
    local list = __K2L_ListOf(max, 5, min, big, -3, 0)
    list:sort()
    print(__K2L_Str(list))
    list:sortDescending()
    print(__K2L_Str(list))
    list:sortBy(function(it) return -it end, true)
    print(__K2L_Str(list))
    list:sortWith(__K2L_CompareBy(function(it) return math.fmod(it, 10) end))
    print(__K2L_Str(list))
    print(__K2L_Str(list:sortedWith(__K2L_ThenBy(__K2L_CompareByDescending(function(it) return it end), function(it) return it end))))
    print(__K2L_Str(list:sortedBy(function(it) return it end, true)))
    print(list:binarySearch(5))
    print(list:sorted():binarySearch(big))
    print(__K2L_NotNull(__K2L_JdkCollections.max(list)))
    print(__K2L_NotNull(__K2L_JdkCollections.min(list)))
    local ts = __K2L_SortedSet.new()
    ts:addAll(list)
    print(__K2L_Str(ts))
    print(__K2L_NotNull(ts:first()))
    print(__K2L_NotNull(ts:last()))
    print(__K2L_NotNull(ts:higher(5)))
    print(__K2L_NotNull(ts:lower(big)))
    local pq = __K2L_PriorityQueue.new()
    pq:addAll(list)
    local out = __K2L_ListOf()
    while pq:isNotEmpty() do
        out:add(pq:poll())
    end
    print(__K2L_Str(out))
    local dq = __K2L_ArrayDeque.new()
    dq:addLast(big)
    dq:addFirst(max)
    print(dq:removeFirst() - dq:removeLast())
    print(list:min())
    print(list:max())
    print(__K2L_Str(list:minOrNull()))
    print(list:indexOf(min))
    print(list:lastIndexOf(max))
    print(list:remove(big))
    print(__K2L_Str(list))
    print(list:contains(big))
    print(list:plus(big):distinct().size)
    print(list:toSet().size)
    print(__K2L_Str(list:chunked(2)))
    print(__K2L_Str(list:windowed(2):map(function(it) return it:get(0) - it:get(1) end)))
    print(__K2L_Str(list:zipWithNext(function(a, b) return a + b end)))
    print(__K2L_Str(list:runningFold(0, function(a, b) return a + b end)))
    print(__K2L_Str(list:scan(1, function(a, b) return a ~ b end)))
    print(__K2L_Str(list:partition(function(it) return it > 0 end)))
    print(__K2L_Str(list:groupBy(function(it) return it > 0 end):mapValues(function(____destructured)
        local v = ____destructured.value
        return v:sum()
    end)))
    print(__K2L_Str(list:associateBy(function(it) return math.fmod(it, 7) end)))
    print(__K2L_Str(list:reversed()))
    print(__K2L_Str(list:takeWhile(function(it) return it ~= 5 end)))
    print(__K2L_Str(list:firstOrNull(function(it) return it > big end)))
    print(list:last(function(it) return it < 0 end))
    print(list:sumOf(function(it) return it end))
    print(__K2L_Num.roundToLong(1.0E19))
    print(-__K2L_Num.roundToLong(1.0E19))
    print(__K2L_Num.roundToLong(4.611686018427388E18))
    print(__K2L_Num.roundToLong(2.5))
    print(__K2L_Num.roundToLong(1.0E19))
    print(__K2L_Num.roundToLong(-2.5))
    print(__K2L_Num.roundToLong(4.611686018427388E18))
    print(__K2L_Str(__K2L_JdkCollections.arrayToString(arr)))
    __K2L_JdkCollections.sort_array(arr)
    print(__K2L_Str(arr:toList()))
    print(arr:joinToString())
    print(__K2L_Str(arr:map(function(it) return it + 1 end)))
    print(arr:filter(function(it) return it > 0 end).size)
    print(arr:indexOf(big))
    print(arr:max())
    print(__K2L_Str(arr:copyOfSize(8, 0):toList()))
    print(__K2L_Str(arr:copyOfRange(1, 3):toList()))
    print(__K2L_Str(arr:reversedArray():toList()))
    local hm = __K2L_HashMap.new()
    local ____list = __K2L_ReadOnlyListOf(big, max, 17, big + 1, min, 3, 1 << 40, 1 << 33, -(1 << 40))
    for i = 0, ____list.size - 1 do
        local k = ____list[i + 1]
        hm:set(k, i)
    end
    print(__K2L_Str(hm))
    print(__K2L_Str(hm:getKeys()))
    print(__K2L_Str(hm:getEntries():first()))
    local hs = __K2L_HashSet.new(hm:getKeys())
    print(__K2L_Str(hs))
    print(__K2L_Str(hs:map(function(it) return math.fmod(it, 5) end):toSet()))
    local big2 = __K2L_ListOfSize(3, function(it) return big * it end, "[Ljava.lang.Long;")
    print(__K2L_Str(big2:toList()))
    print(big2:sum())
end

main()
