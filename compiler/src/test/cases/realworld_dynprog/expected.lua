local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StrByte = ____lualib.__K2L_StrByte
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringPadEnd = ____lualib.__K2L_StringPadEnd
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_Text = ____lualib.__K2L_Text

local function editDistance(a, b)
    local dp = __K2L_ListOfSize(#a + 1, function(it) return __K2L_ListOfSize(#b + 1, 0, true) end, true)
    for i = 0, #a do
        local ____object = dp[i + 1] or __K2L_IndexError(i, dp.size, "array")
        if 0 < 0 or 0 >= ____object.size then
            __K2L_IndexError(0, ____object.size, "array")
        end
        ____object[1] = i
    end
    for j = 0, #b do
        local ____object_1 = dp[1] or __K2L_IndexError(0, dp.size, "array")
        if j < 0 or j >= ____object_1.size then
            __K2L_IndexError(j, ____object_1.size, "array")
        end
        ____object_1[j + 1] = j
    end
    for i = 1, #a do
        for j = 1, #b do
            local cost = (i - 1 >= 0 and i - 1 < #a and a:sub(i - 1 + 1, i - 1 + 1) or __K2L_IndexError(i - 1, #a, "string")) == (j - 1 >= 0 and j - 1 < #b and b:sub(j - 1 + 1, j - 1 + 1) or __K2L_IndexError(j - 1, #b, "string")) and 0 or 1
            local ____object_2 = dp[i + 1] or __K2L_IndexError(i, dp.size, "array")
            local ____value = math.min((dp[i] or __K2L_IndexError(i - 1, dp.size, "array")):get(j) + 1, (dp[i + 1] or __K2L_IndexError(i, dp.size, "array")):get(j - 1) + 1, (dp[i] or __K2L_IndexError(i - 1, dp.size, "array")):get(j - 1) + cost)
            if j < 0 or j >= ____object_2.size then
                __K2L_IndexError(j, ____object_2.size, "array")
            end
            ____object_2[j + 1] = ____value
        end
    end
    return dp:get(#a):get(#b)
end

local function longestCommonSubsequence(a, b)
    local dp = __K2L_ListOfSize(#a + 1, function(it) return __K2L_ListOfSize(#b + 1, 0, true) end, true)
    local ____range = __K2L_IntRange.new(0, #a - 1):reversed()
    for i = ____range.first, ____range.last, ____range.step do
        local ____range_1 = __K2L_IntRange.new(0, #b - 1):reversed()
        for j = ____range_1.first, ____range_1.last, ____range_1.step do
            local ____object_3 = dp[i + 1] or __K2L_IndexError(i, dp.size, "array")
            local ____value_1 = (i >= 0 and i < #a and a:sub(i + 1, i + 1) or __K2L_IndexError(i, #a, "string")) == (j >= 0 and j < #b and b:sub(j + 1, j + 1) or __K2L_IndexError(j, #b, "string")) and (dp[i + 1 + 1] or __K2L_IndexError(i + 1, dp.size, "array")):get(j + 1) + 1 or math.max((dp[i + 1 + 1] or __K2L_IndexError(i + 1, dp.size, "array")):get(j), (dp[i + 1] or __K2L_IndexError(i, dp.size, "array")):get(j + 1))
            if j < 0 or j >= ____object_3.size then
                __K2L_IndexError(j, ____object_3.size, "array")
            end
            ____object_3[j + 1] = ____value_1
        end
    end
    local ____builder = __K2L_StringBuilder.new()
    do
        local i = 0
        local j = 0
        while i < #a and j < #b do
            if (i >= 0 and i < #a and a:sub(i + 1, i + 1) or __K2L_IndexError(i, #a, "string")) == (j >= 0 and j < #b and b:sub(j + 1, j + 1) or __K2L_IndexError(j, #b, "string")) then
                ____builder:append(i >= 0 and i < #a and a:sub(i + 1, i + 1) or __K2L_IndexError(i, #a, "string"))
                i = i + 1
                j = j + 1
            elseif (dp[i + 1 + 1] or __K2L_IndexError(i + 1, dp.size, "array")):get(j) >= (dp[i + 1] or __K2L_IndexError(i, dp.size, "array")):get(j + 1) then
                i = i + 1
            else
                j = j + 1
            end
        end
    end
    return ____builder:toString()
end

local Item = __K2L_Class("Item")

function Item.new(name, weight, value)
    return setmetatable({name = name, weight = weight, value = value}, Item)
end

__K2L_DataClass(Item, {"name", "weight", "value"})

local function knapsack(items, capacity)
    local n = items.size
    local best = __K2L_ListOfSize(n + 1, function(it)
        return __K2L_ListOfSize(capacity + 1, 0, true)
    end, true)
    for i = 0, items.size - 1 do
        local item = items[i + 1]
        for w = 0, capacity do
            local ____object_4 = best[i + 1 + 1] or __K2L_IndexError(i + 1, best.size, "array")
            local ____value_2 = (best[i + 1] or __K2L_IndexError(i, best.size, "array")):get(w)
            if w < 0 or w >= ____object_4.size then
                __K2L_IndexError(w, ____object_4.size, "array")
            end
            ____object_4[w + 1] = ____value_2
            if item.weight <= w then
                local ____object_5 = best[i + 1 + 1] or __K2L_IndexError(i + 1, best.size, "array")
                local ____value_3 = math.max((best[i + 1 + 1] or __K2L_IndexError(i + 1, best.size, "array")):get(w), (best[i + 1] or __K2L_IndexError(i, best.size, "array")):get(w - item.weight) + item.value)
                if w < 0 or w >= ____object_5.size then
                    __K2L_IndexError(w, ____object_5.size, "array")
                end
                ____object_5[w + 1] = ____value_3
            end
        end
    end
    local chosen = __K2L_ListOf()
    local w = capacity
    for i = n, 1, -1 do
        if (best[i + 1] or __K2L_IndexError(i, best.size, "array")):get(w) ~= (best[i] or __K2L_IndexError(i - 1, best.size, "array")):get(w) then
            chosen:add(items:get(i - 1))
            w = w - items:get(i - 1).weight
        end
    end
    return __K2L_Pair.new((best[n + 1] or __K2L_IndexError(n, best.size, "array")):get(capacity), chosen:reversed())
end

local function coinChangeWays(coins, amount)
    local ways = __K2L_ListOfSize(amount + 1, 0, true)
    if 0 < 0 or 0 >= ways.size then
        __K2L_IndexError(0, ways.size, "array")
    end
    ways[1] = 1
    for ____i = 1, coins.size do
        local coin = coins[____i]
        for v = coin, amount do
            ways[v + 1] = (ways[v + 1] or __K2L_IndexError(v, ways.size, "array")) + (ways[v - coin + 1] or __K2L_IndexError(v - coin, ways.size, "array"))
        end
    end
    return ways[amount + 1] or __K2L_IndexError(amount, ways.size, "array")
end

local function minCoins(coins, amount)
    local inf = 2147483647
    local dp = __K2L_ListOfSize(amount + 1, function(it) return it == 0 and 0 or inf end, true)
    for v = 1, amount do
        for ____i_1 = 1, coins.size do
            local c = coins[____i_1]
            if c <= v and (dp[v - c + 1] or __K2L_IndexError(v - c, dp.size, "array")) ~= inf then
                local ____value_4 = math.min(dp[v + 1] or __K2L_IndexError(v, dp.size, "array"), (dp[v - c + 1] or __K2L_IndexError(v - c, dp.size, "array")) + 1)
                if v < 0 or v >= dp.size then
                    __K2L_IndexError(v, dp.size, "array")
                end
                dp[v + 1] = ____value_4
            end
        end
    end
    local ____value_5 = dp[amount + 1] or __K2L_IndexError(amount, dp.size, "array")
    return ____value_5 ~= inf and ____value_5 or nil
end

local ____lambda_1 = function(it) return -1 end
local function longestIncreasingSubsequence(xs)
    local tails = __K2L_ListOf()
    local tailIndex = __K2L_ListOf()
    local parent = __K2L_ListOfSize(xs.size, ____lambda_1, true)
    for i = 0, xs.size - 1 do
        local x = xs[i + 1]
        local pos = tails:binarySearch(x)
        if pos < 0 then
            pos = -(pos + 1)
        end
        if pos == tails.size then
            tails:add(x)
            tailIndex:add(i)
        else
            local ____key = pos
            tails:set(____key, x)
            local ____key_1 = pos
            tailIndex:set(____key_1, i)
        end
        if pos > 0 then
            local ____value_6 = tailIndex:get(pos - 1)
            if i < 0 or i >= parent.size then
                __K2L_IndexError(i, parent.size, "array")
            end
            parent[i + 1] = ____value_6
        end
    end
    local result = __K2L_List.new()
    local ____value_7 = tailIndex:lastOrNull()
    if ____value_7 == nil then
        return __K2L_ListOf()
    end
    local k = ____value_7
    while k >= 0 do
        result:add(xs:get(k))
        k = parent[k + 1] or __K2L_IndexError(k, parent.size, "array")
    end
    return result:reversed()
end

local Arrangements = __K2L_Class("Arrangements")

local function count__1(self, pos, group)
    local key = __K2L_Pair.new(pos, group)
    local ____receiver = self.memo:get(key)
    if ____receiver ~= nil then
        local ____result
        self.hits = self.hits + 1
        return ____receiver
    end
    local result
    if pos >= #self.pattern then
        result = group == self.groups.size and 1 or 0
    else
        local total = 0
        local c = pos >= 0 and pos < #self.pattern and self.pattern:sub(pos + 1, pos + 1) or __K2L_IndexError(pos, #self.pattern, "string")
        if c == "." or c == "?" then
            total = total + count__1(self, pos + 1, group)
        end
        if (c == "#" or c == "?") and group < self.groups.size then
            local len = self.groups:get(group)
            local ____end = pos + len
            local fits = ____end <= #self.pattern and __K2L_IntRange.new(pos, ____end - 1):none(function(it)
                return (it >= 0 and __K2L_StrByte(self.pattern, it + 1) or __K2L_IndexError(it, #self.pattern, "string")) == 46
            end) and (____end == #self.pattern or (____end >= 0 and __K2L_StrByte(self.pattern, ____end + 1) or __K2L_IndexError(____end, #self.pattern, "string")) ~= 35)
            if fits then
                total = total + count__1(self, math.min(____end + 1, #self.pattern), group + 1)
            end
        end
        result = total
    end
    local ____object_6 = self.memo
    ____object_6:set(key, result)
    return result
end

function Arrangements:____init(pattern, groups)
    self.pattern = pattern
    self.groups = groups
    self.memo = __K2L_Map.new()
    self.hits = 0
end

function Arrangements:count()
    return count__1(self, 0, 0)
end

local ____lambda_2 = function(____p1) return __K2L_StringToInt(____p1) end
local function unfold(line, times)
    local ____destructured = __K2L_StringSplit(line, " ")
    local springs, counts = ____destructured[1], ____destructured[2]
    local ____out = {}
    for ____i_2 = 1, times do
        local it = ____i_2 - 1
        ____out[____i_2] = springs
    end
    local pattern = __K2L_ListWrap(____out, times):joinToString("?")
    local groups = __K2L_StringSplit(counts, ","):map(____lambda_2)
    local ____out_1 = {}
    for ____i_3 = 1, times do
        local it = ____i_3 - 1
        ____out_1[____i_3] = groups
    end
    return __K2L_Pair.new(pattern, __K2L_ListWrap(____out_1, times):flatten())
end

local fibMemo = __K2L_MapOf()

local function fib(n)
    if n < 2 then
        return n
    else
        return fibMemo:getOrPut(n, function() return fib(n - 1) + fib(n - 2) end)
    end
end

local function triangleMaxPath(rows)
    return rows:reversed():reduce(function(below, row)
        local ____out_2 = {}
        local ____count = 0
        local ____items, ____n = row:____array()
        for ____i_4 = 1, ____n do
            local v = ____items[____i_4]
            local i = ____i_4 - 1
            ____count = ____count + 1
            ____out_2[____count] = v + math.max(below:get(i), below:get(i + 1))
        end
        return __K2L_ListWrap(____out_2, ____count)
    end):single()
end

local function partitions(n)
    local out = __K2L_ListOf()
    local function go(remaining, max, acc)
        if remaining == 0 then
            out:add(acc:toList())
            return
        end
        for k = math.min(max, remaining), 1, -1 do
            acc:add(k)
            go(remaining - k, k, acc)
            acc:removeAt(acc.size - 1)
        end
    end
    go(n, n, __K2L_ListOf())
    return out
end

local ____lambda_3 = function(it) return it.name end
local ____lambda_4 = function(it) return it:joinToString("+") end
local ____lambda_5 = function(it) return partitions(it).size end
local function main()
    local ____list = __K2L_ListOf(__K2L_Pair.new("kitten", "sitting"), __K2L_Pair.new("flaw", "lawn"), __K2L_Pair.new("", "abc"), __K2L_Pair.new("intention", "execution"))
    for ____i_5 = 1, ____list.size do
        local ____item = ____list[____i_5]
        local a, b = ____item.first, ____item.second
        print("edit(" .. a .. ", " .. b .. ") = " .. editDistance(a, b))
    end
    print("lcs = " .. longestCommonSubsequence("AGGTAB", "GXTXAYB") .. " / " .. longestCommonSubsequence("ABCBDAB", "BDCABA"))
    local items = __K2L_ListOf(Item.new("map", 9, 150), Item.new("compass", 13, 35), Item.new("water", 153, 200), Item.new("sandwich", 50, 160), Item.new("glucose", 15, 60), Item.new("tin", 68, 45), Item.new("banana", 27, 60), Item.new("apple", 39, 40), Item.new("cheese", 23, 30), Item.new("beer", 52, 10), Item.new("suntan", 11, 70), Item.new("camera", 32, 30))
    local ____destructured_1 = knapsack(items, 400)
    local value, chosen = ____destructured_1.first, ____destructured_1.second
    local ____sum = 0
    local ____items_1, ____n_1 = chosen:____array()
    for ____i_6 = 1, ____n_1 do
        local it = ____items_1[____i_6]
        ____sum = ____sum + it.weight
    end
    print("knapsack value=" .. value .. " weight=" .. ____sum)
    print("  items: " .. chosen:joinToString(nil, nil, nil, nil, nil, ____lambda_3))
    print("ways(100) = " .. coinChangeWays(__K2L_ArrayOf(1, 5, 10, 25, 50), 100))
    print("ways(1000) = " .. coinChangeWays(__K2L_ArrayOf(1, 2, 5, 10, 20, 50, 100, 200), 1000))
    print("minCoins: " .. __K2L_Str(minCoins(__K2L_ListOf(1, 3, 4), 6)) .. " " .. __K2L_Str(minCoins(__K2L_ListOf(2), 3)) .. " " .. __K2L_Str(minCoins(__K2L_ListOf(186, 419, 83, 408), 6249)))
    local seq = __K2L_ListOf(10, 9, 2, 5, 3, 7, 101, 18, 4, 8, 6, 12, 15)
    print("lis = " .. __K2L_Str(longestIncreasingSubsequence(seq)))
    print("lis(empty) = " .. __K2L_Str(longestIncreasingSubsequence(__K2L_ListOf())))
    local lines = __K2L_ListOf("???.### 1,1,3", ".??..??...?##. 1,1,3", "?#?#?#?#?#?#?#? 1,3,1,6", "?###???????? 3,2,1")
    local total = 0
    for ____i_7 = 1, lines.size do
        local line = lines[____i_7]
        local ____destructured_2 = unfold(line, 1)
        local pattern, groups = ____destructured_2.first, ____destructured_2.second
        local ____destructured_3 = unfold(line, 5)
        local p5, g5 = ____destructured_3.first, ____destructured_3.second
        local a = Arrangements.new(pattern, groups):count()
        local big = Arrangements.new(p5, g5)
        local b = big:count()
        total = total + b
        print(__K2L_StringPadEnd(line, 26) .. " -> " .. a .. " / " .. b .. " (memo hits " .. big.hits .. ")")
    end
    print("total unfolded = " .. total)
    print("fib(78) = " .. fib(78) .. ", memo size " .. fibMemo.size)
    local ____list_1 = __K2L_StringLines(__K2L_Text.trimIndent("\n        3\n        7 4\n        2 4 6\n        8 5 9 3\n    "))
    local ____out_3 = {}
    local ____count_1 = 0
    local ____items_3, ____n_3 = ____list_1:____array()
    for ____i_9 = 1, ____n_3 do
        local row = ____items_3[____i_9]
        local ____result_1
        do
            local ____list_2 = __K2L_StringSplit(row, " ")
            local ____out_4 = {}
            local ____count_2 = 0
            local ____items_2, ____n_2 = ____list_2:____array()
            for ____i_8 = 1, ____n_2 do
                local it = ____items_2[____i_8]
                ____count_2 = ____count_2 + 1
                ____out_4[____count_2] = __K2L_StringToInt(it)
            end
            ____result_1 = __K2L_ListWrap(____out_4, ____count_2)
        end
        ____count_1 = ____count_1 + 1
        ____out_3[____count_1] = ____result_1
    end
    local triangle = __K2L_ListWrap(____out_3, ____count_1)
    print("triangle max path = " .. triangleMaxPath(triangle))
    local parts = partitions(6)
    print("partitions(6): " .. parts.size .. " -> " .. parts:joinToString(" ", nil, nil, nil, nil, ____lambda_4))
    print("partition counts: " .. __K2L_Str(__K2L_IntRange.new(1, 12):map(____lambda_5)))
end

__K2L_RunMain(main)
return {editDistance = editDistance, longestCommonSubsequence = longestCommonSubsequence, Item = Item, knapsack = knapsack, coinChangeWays = coinChangeWays, minCoins = minCoins, longestIncreasingSubsequence = longestIncreasingSubsequence, Arrangements = Arrangements, unfold = unfold, fibMemo = fibMemo, fib = fib, triangleMaxPath = triangleMaxPath, partitions = partitions}
