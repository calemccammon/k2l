local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringCharAt = ____lualib.__K2L_StringCharAt
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringPadEnd = ____lualib.__K2L_StringPadEnd
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32

local function editDistance(a, b)
    local dp = __K2L_ListOfSize(#a + 1, function(it) return __K2L_ListOfSize(#b + 1, 0, true) end, true)
    for i = 0, #a do
        local ____object = dp:get(i)
        ____object:set(0, i)
    end
    for j = 0, #b do
        local ____object_1 = dp:get(0)
        ____object_1:set(j, j)
    end
    for i = 1, #a do
        for j = 1, #b do
            local cost = __K2L_StringCharAt(a, i - 1) == __K2L_StringCharAt(b, j - 1) and 0 or 1
            local ____object_2 = dp:get(i)
            ____object_2:set(j, math.min(dp:get(i - 1):get(j) + 1, dp:get(i):get(j - 1) + 1, dp:get(i - 1):get(j - 1) + cost))
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
            local ____object_3 = dp:get(i)
            ____object_3:set(j, __K2L_StringCharAt(a, i) == __K2L_StringCharAt(b, j) and dp:get(i + 1):get(j + 1) + 1 or math.max(dp:get(i + 1):get(j), dp:get(i):get(j + 1)))
        end
    end
    local ____builder = __K2L_StringBuilder.new()
    do
        local i = 0
        local j = 0
        while i < #a and j < #b do
            if __K2L_StringCharAt(a, i) == __K2L_StringCharAt(b, j) then
                ____builder:append(__K2L_StringCharAt(a, i))
                i = i + 1
                j = j + 1
            elseif dp:get(i + 1):get(j) >= dp:get(i):get(j + 1) then
                i = i + 1
            else
                j = j + 1
            end
        end
    end
    return ____builder:toString()
end

local Item = __K2L_Class("Item")

function Item:____init(name, weight, value)
    self.name = name
    self.weight = weight
    self.value = value
end

function Item:toString()
    return "Item(name=" .. self.name .. ", weight=" .. self.weight .. ", value=" .. self.value .. ")"
end

function Item:hashCode()
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.name) + __K2L_Hash(self.weight)) + __K2L_Hash(self.value))
end

function Item:equals(other)
    return getmetatable(other) == Item and self.name == other.name and self.weight == other.weight and self.value == other.value
end

local function knapsack(items, capacity)
    local n = items.size
    local best = __K2L_ListOfSize(n + 1, function(it)
        return __K2L_ListOfSize(capacity + 1, 0, true)
    end, true)
    for i = 0, items.size - 1 do
        local item = items[i + 1]
        for w = 0, capacity do
            local ____object_4 = best:get(i + 1)
            ____object_4:set(w, best:get(i):get(w))
            if item.weight <= w then
                local ____object_5 = best:get(i + 1)
                ____object_5:set(w, math.max(best:get(i + 1):get(w), best:get(i):get(w - item.weight) + item.value))
            end
        end
    end
    local chosen = __K2L_ListOf()
    local w = capacity
    for i = n, 1, -1 do
        if best:get(i):get(w) ~= best:get(i - 1):get(w) then
            chosen:add(items:get(i - 1))
            w = w - items:get(i - 1).weight
        end
    end
    return __K2L_Pair.new(best:get(n):get(capacity), chosen:reversed())
end

local function coinChangeWays(coins, amount)
    local ways = __K2L_ListOfSize(amount + 1, 0, true)
    ways:set(0, 1)
    for ____i = 1, coins.size do
        local coin = coins[____i]
        for v = coin, amount do
            ways:set(v, ways:get(v) + ways:get(v - coin))
        end
    end
    return ways:get(amount)
end

local function minCoins(coins, amount)
    local inf = 2147483647
    local dp = __K2L_ListOfSize(amount + 1, function(it) return it == 0 and 0 or inf end, true)
    for v = 1, amount do
        for _, c in ipairs(coins) do
            if c <= v and dp:get(v - c) ~= inf then
                dp:set(v, math.min(dp:get(v), dp:get(v - c) + 1))
            end
        end
    end
    local ____value = dp:get(amount)
    return ____value ~= inf and ____value or nil
end

local function longestIncreasingSubsequence(xs)
    local tails = __K2L_ListOf()
    local tailIndex = __K2L_ListOf()
    local parent = __K2L_ListOfSize(xs.size, function(it) return -1 end, true)
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
            parent:set(i, tailIndex:get(pos - 1))
        end
    end
    local result = __K2L_List.new()
    local ____value_1 = tailIndex:lastOrNull()
    if ____value_1 == nil then
        return __K2L_ReadOnlyListOf()
    end
    local k = ____value_1
    while k >= 0 do
        result:add(xs:get(k))
        k = parent:get(k)
    end
    return result:reversed()
end

local Arrangements = __K2L_Class("Arrangements")

function Arrangements:____init(pattern, groups)
    self.pattern = pattern
    self.groups = groups
    self.memo = __K2L_HashMap.new()
    self.hits = 0
end

function Arrangements:count()
    return self:count__1(0, 0)
end

function Arrangements:count__1(pos, group)
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
        local c = __K2L_StringCharAt(self.pattern, pos)
        if c == "." or c == "?" then
            total = total + self:count__1(pos + 1, group)
        end
        if (c == "#" or c == "?") and group < self.groups.size then
            local len = self.groups:get(group)
            local ____end = pos + len
            local fits = ____end <= #self.pattern and __K2L_IntRange.new(pos, ____end - 1):none(function(it)
                return __K2L_StringCharAt(self.pattern, it) == "."
            end) and (____end == #self.pattern or __K2L_StringCharAt(self.pattern, ____end) ~= "#")
            if fits then
                total = total + self:count__1(math.min(____end + 1, #self.pattern), group + 1)
            end
        end
        result = total
    end
    local ____object_6 = self.memo
    ____object_6:set(key, result)
    return result
end

local function unfold(line, times)
    local ____destructured = __K2L_StringSplit(line, " ")
    local springs, counts = ____destructured[1], ____destructured[2]
    local pattern = __K2L_ListOfSize(times, function(it) return springs end):joinToString("?")
    local groups = __K2L_StringSplit(counts, ","):map(function(____p1) return __K2L_StringToInt(____p1) end)
    return __K2L_Pair.new(pattern, __K2L_ListOfSize(times, function(it) return groups end):flatten())
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
        return row:mapIndexed(function(i, v)
            return v + math.max(below:get(i), below:get(i + 1))
        end)
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

local function main()
    for _, ____item in ipairs(__K2L_ReadOnlyListOf(__K2L_Pair.new("kitten", "sitting"), __K2L_Pair.new("flaw", "lawn"), __K2L_Pair.new("", "abc"), __K2L_Pair.new("intention", "execution"))) do
        local a, b = ____item.first, ____item.second
        print("edit(" .. a .. ", " .. b .. ") = " .. editDistance(a, b))
    end
    print("lcs = " .. longestCommonSubsequence("AGGTAB", "GXTXAYB") .. " / " .. longestCommonSubsequence("ABCBDAB", "BDCABA"))
    local items = __K2L_ReadOnlyListOf(Item.new("map", 9, 150), Item.new("compass", 13, 35), Item.new("water", 153, 200), Item.new("sandwich", 50, 160), Item.new("glucose", 15, 60), Item.new("tin", 68, 45), Item.new("banana", 27, 60), Item.new("apple", 39, 40), Item.new("cheese", 23, 30), Item.new("beer", 52, 10), Item.new("suntan", 11, 70), Item.new("camera", 32, 30))
    local ____destructured_1 = knapsack(items, 400)
    local value, chosen = ____destructured_1.first, ____destructured_1.second
    print("knapsack value=" .. value .. " weight=" .. chosen:sumOf(function(it) return it.weight end))
    print("  items: " .. chosen:joinToString(nil, nil, nil, nil, nil, function(it) return it.name end))
    print("ways(100) = " .. coinChangeWays(__K2L_ArrayOf(1, 5, 10, 25, 50), 100))
    print("ways(1000) = " .. coinChangeWays(__K2L_ArrayOf(1, 2, 5, 10, 20, 50, 100, 200), 1000))
    print("minCoins: " .. __K2L_Str(minCoins(__K2L_ReadOnlyListOf(1, 3, 4), 6)) .. " " .. __K2L_Str(minCoins(__K2L_SingletonListOf(2), 3)) .. " " .. __K2L_Str(minCoins(__K2L_ReadOnlyListOf(186, 419, 83, 408), 6249)))
    local seq = __K2L_ReadOnlyListOf(10, 9, 2, 5, 3, 7, 101, 18, 4, 8, 6, 12, 15)
    print("lis = " .. __K2L_Str(longestIncreasingSubsequence(seq)))
    print("lis(empty) = " .. __K2L_Str(longestIncreasingSubsequence(__K2L_ReadOnlyListOf())))
    local lines = __K2L_ReadOnlyListOf("???.### 1,1,3", ".??..??...?##. 1,1,3", "?#?#?#?#?#?#?#? 1,3,1,6", "?###???????? 3,2,1")
    local total = 0
    for _, line in ipairs(lines) do
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
    local triangle = __K2L_StringLines(__K2L_Text.trimIndent("\n        3\n        7 4\n        2 4 6\n        8 5 9 3\n    ")):map(function(row)
        return __K2L_StringSplit(row, " "):map(function(it) return __K2L_StringToInt(it) end)
    end)
    print("triangle max path = " .. triangleMaxPath(triangle))
    local parts = partitions(6)
    print("partitions(6): " .. parts.size .. " -> " .. parts:joinToString(" ", nil, nil, nil, nil, function(it) return it:joinToString("+") end))
    print("partition counts: " .. __K2L_Str(__K2L_IntRange.new(1, 12):map(function(it) return partitions(it).size end)))
end

main()
return {editDistance = editDistance, longestCommonSubsequence = longestCommonSubsequence, Item = Item, knapsack = knapsack, coinChangeWays = coinChangeWays, minCoins = minCoins, longestIncreasingSubsequence = longestIncreasingSubsequence, Arrangements = Arrangements, unfold = unfold, fibMemo = fibMemo, fib = fib, triangleMaxPath = triangleMaxPath, partitions = partitions}
