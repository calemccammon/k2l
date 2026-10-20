local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_CompareByDescending = ____lualib.__K2L_CompareByDescending
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_HashSet = ____lualib.__K2L_HashSet
local __K2L_JdkCollections = ____lualib.__K2L_JdkCollections
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_PriorityQueue = ____lualib.__K2L_PriorityQueue
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SortedSet = ____lualib.__K2L_SortedSet
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ThenBy = ____lualib.__K2L_ThenBy
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf

local ____lambda_1 = function(it) return -it end
local ____lambda_2 = function(it)
    return it >= 0 and it % 10 or (it % 10 - 10) % (-10)
end
local ____lambda_3 = function(it) return it end
local ____lambda_4 = function(it) return it end
local ____lambda_5 = function(it) return it end
local ____lambda_6 = function(a, b) return a + b end
local ____lambda_7 = function(a, b) return a + b end
local ____lambda_8 = function(a, b) return a ~ b end
local ____lambda_9 = function(it) return it > 0 end
local ____lambda_10 = function(it) return it ~= 5 end
local ____lambda_11 = function(it) return it < 0 end
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
    list:sortBy(____lambda_1, true)
    print(__K2L_Str(list))
    list:sortWith(__K2L_CompareBy(____lambda_2))
    print(__K2L_Str(list))
    print(__K2L_Str(list:sortedWith(__K2L_ThenBy(__K2L_CompareByDescending(____lambda_3), ____lambda_4))))
    print(__K2L_Str(list:sortedBy(____lambda_5, true)))
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
    local ____list = list:windowed(2)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = it:get(0) - it:get(1)
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    print(__K2L_Str(list:zipWithNext(____lambda_6)))
    print(__K2L_Str(list:runningFold(0, ____lambda_7)))
    print(__K2L_Str(list:scan(1, ____lambda_8)))
    print(__K2L_Str(list:partition(____lambda_9)))
    local ____result = __K2L_Map.new()
    local ____items_1, ____n_1 = list:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        local ____value = it > 0
        local ____group = ____result:get(____value)
        if ____group == nil then
            ____group = __K2L_List.new()
            ____result:put(____value, ____group)
        end
        ____group:add(it)
    end
    print(__K2L_Str(____result:mapValues(function(____destructured)
        local v = ____destructured.value
        return v:sum()
    end)))
    local ____result_1 = __K2L_Map.new()
    local ____items_2, ____n_2 = list:____array()
    for ____i_2 = 1, ____n_2 do
        local it = ____items_2[____i_2]
        local ____value_1 = it >= 0 and it % 7 or (it % 7 - 7) % (-7)
        ____result_1:put(____value_1, it)
    end
    print(__K2L_Str(____result_1))
    print(__K2L_Str(list:reversed()))
    print(__K2L_Str(list:takeWhile(____lambda_10)))
    local ____result_2
    local ____items_3, ____n_3 = list:____array()
    for ____i_3 = 1, ____n_3 do
        local it = ____items_3[____i_3]
        if it > big then
            ____result_2 = it
            break
        end
    end
    print(__K2L_Str(____result_2))
    print(list:last(____lambda_11))
    local ____sum = 0
    local ____items_4, ____n_4 = list:____array()
    for ____i_4 = 1, ____n_4 do
        local it = ____items_4[____i_4]
        ____sum = ____sum + it
    end
    print(____sum)
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
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_5, ____n_5 = arr:____array()
    for ____i_5 = 1, ____n_5 do
        local it = ____items_5[____i_5]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = it + 1
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_6, ____n_6 = arr:____array()
    for ____i_6 = 1, ____n_6 do
        local it = ____items_6[____i_6]
        if it > 0 then
            ____count_2 = ____count_2 + 1
            ____out_2[____count_2] = it
        end
    end
    print(__K2L_ListWrap(____out_2, ____count_2).size)
    print(arr:indexOf(big))
    print(arr:max())
    print(__K2L_Str(arr:copyOfSize(8, 0):toList()))
    print(__K2L_Str(arr:copyOfRange(1, 3):toList()))
    print(__K2L_Str(arr:reversedArray():toList()))
    local hm = __K2L_HashMap.new()
    local ____list_1 = __K2L_ReadOnlyListOf(big, max, 17, big + 1, min, 3, 1 << 40, 1 << 33, -(1 << 40))
    for i = 0, ____list_1.size - 1 do
        local k = ____list_1[i + 1]
        hm:set(k, i)
    end
    print(__K2L_Str(hm))
    print(__K2L_Str(hm:getKeys()))
    print(__K2L_Str(hm:getEntries():first()))
    local hs = __K2L_HashSet.new(hm:getKeys())
    print(__K2L_Str(hs))
    local ____out_3 = {}
    local ____count_3 = 0
    local ____items_7, ____n_7 = hs:____array()
    for ____i_7 = 1, ____n_7 do
        local it = ____items_7[____i_7]
        ____count_3 = ____count_3 + 1
        ____out_3[____count_3] = it >= 0 and it % 5 or (it % 5 - 5) % (-5)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_3, ____count_3):toSet()))
    local big2 = __K2L_ListOfSize(3, function(it) return big * it end, "[Ljava.lang.Long;")
    print(__K2L_Str(big2:toList()))
    print(big2:sum())
end

main()
