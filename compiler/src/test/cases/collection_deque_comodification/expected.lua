local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_CompareByDescending = ____lualib.__K2L_CompareByDescending
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Deque = ____lualib.__K2L_Deque
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_LinkedList = ____lualib.__K2L_LinkedList
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_LoopItems = ____lualib.__K2L_LoopItems
local __K2L_PriorityQueue = ____lualib.__K2L_PriorityQueue
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Unit = ____lualib.__K2L_Unit

local function t(label, f)
    local ____ok, ____result = __K2L_DeepPcall(function()
        print(label .. ": " .. __K2L_Str(f()))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        local e = ____error
        print(label .. ": " .. __K2L_Str(__K2L_KClassOfValue(e).simpleName) .. " " .. __K2L_Str(e.message))
    end
end

local function kd()
    return __K2L_ArrayDeque.new(__K2L_ReadOnlyListOf(1, 2, 3))
end

local function jd()
    return __K2L_Deque.new(__K2L_ReadOnlyListOf(1, 2, 3))
end

local function walk(d, change)
    local seen = __K2L_ListOf()
    local ____items, ____n = __K2L_LoopItems(d)
    local ____mod = d.____modCount
    for ____i = 1, ____n do
        local x = ____items[____i]
        seen:add(x)
        change(x)
        if d.____modCount ~= ____mod and d:____comodified(____i, ____n) then
            break
        end
    end
    return __K2L_Str(seen) .. " " .. __K2L_Str(d)
end

local Tracked = __K2L_Class("Tracked", __K2L_Deque)
__K2L_ClassInfo(Tracked, "Tracked", "Tracked", "class")

function Tracked:____init()
    __K2L_Deque.____init(self, 2)
    self.adds = 0
end

function Tracked:addLast(e)
    self.adds = self.adds + 1
    __K2L_Deque.addLast(self, e)
end

local ____lambda_1 = function(it) return it == 7 end
local ____lambda_2 = function(it) return it ~= 3 end
local ____lambda_3 = function(it) return it end
local ____lambda_4 = function(it) return -it end
local ____lambda_5 = function(it) return it * 10 end
local ____lambda_6 = function()
    return kd():addAllAt(-1, __K2L_SingletonListOf(1))
end
local ____lambda_7 = function()
    return walk(jd(), function(it)
        if __K2L_Equals(it, 1) then
            jd():addLast(0)
        end
    end)
end
local ____lambda_8 = function(e) return __K2L_Equals(e, 3) end
local ____lambda_9 = function()
    return __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(__K2L_IteratorOf(jd()))).name) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(jd():descendingIterator())).name)
end
local function main()
    t("kd addLast", function()
        local d = kd()
        local ____mod_1 = d.____modCount
        for ____i_1 = 1, d.size do
            local x = d[____i_1]
            if x == 1 then
                d:addLast(9)
            end
            if d.____modCount ~= ____mod_1 and d:____comodified(____i_1) then
                break
            end
        end
        return d
    end)
    t("kd addFirst", function()
        local d = kd()
        local ____mod_2 = d.____modCount
        for ____i_2 = 1, d.size do
            local x = d[____i_2]
            if x == 1 then
                d:addFirst(9)
            end
            if d.____modCount ~= ____mod_2 and d:____comodified(____i_2) then
                break
            end
        end
        return d
    end)
    t("kd removeFirst", function()
        local d = kd()
        local ____mod_3 = d.____modCount
        for ____i_3 = 1, d.size do
            local x = d[____i_3]
            if x == 1 then
                d:removeFirst()
            end
            if d.____modCount ~= ____mod_3 and d:____comodified(____i_3) then
                break
            end
        end
        return d
    end)
    t("kd removeLast at the end", function()
        local d = kd()
        local ____mod_4 = d.____modCount
        for ____i_4 = 1, d.size do
            local x = d[____i_4]
            if x == 2 then
                d:removeLast()
            end
            if d.____modCount ~= ____mod_4 and d:____comodified(____i_4) then
                break
            end
        end
        return d
    end)
    t("kd set", function()
        local d = kd()
        local ____mod_5 = d.____modCount
        for ____i_5 = 1, d.size do
            local x = d[____i_5]
            d:set(0, x)
            if d.____modCount ~= ____mod_5 and d:____comodified(____i_5) then
                break
            end
        end
        return d
    end)
    t("kd add(i)", function()
        local d = kd()
        local ____mod_6 = d.____modCount
        for ____i_6 = 1, d.size do
            local x = d[____i_6]
            if x == 1 then
                d:addAt(0, 5)
            end
            if d.____modCount ~= ____mod_6 and d:____comodified(____i_6) then
                break
            end
        end
        return d
    end)
    t("kd remove absent", function()
        local d = kd()
        local ____mod_7 = d.____modCount
        for ____i_7 = 1, d.size do
            local x = d[____i_7]
            if x == 1 then
                d:remove(7)
            end
            if d.____modCount ~= ____mod_7 and d:____comodified(____i_7) then
                break
            end
        end
        return d
    end)
    t("kd clear", function()
        local d = kd()
        local ____mod_8 = d.____modCount
        for ____i_8 = 1, d.size do
            local x = d[____i_8]
            if x == 1 then
                d:clear()
            end
            if d.____modCount ~= ____mod_8 and d:____comodified(____i_8) then
                break
            end
        end
        return d
    end)
    t("kd addAll", function()
        local d = kd()
        local ____mod_9 = d.____modCount
        for ____i_9 = 1, d.size do
            local x = d[____i_9]
            if x == 1 then
                d:addAll(__K2L_SingletonListOf(4))
            end
            if d.____modCount ~= ____mod_9 and d:____comodified(____i_9) then
                break
            end
        end
        return d
    end)
    t("kd addAll empty", function()
        local d = kd()
        local ____mod_10 = d.____modCount
        for ____i_10 = 1, d.size do
            local x = d[____i_10]
            if x == 1 then
                d:addAll(__K2L_ReadOnlyListOf())
            end
            if d.____modCount ~= ____mod_10 and d:____comodified(____i_10) then
                break
            end
        end
        return d
    end)
    t("kd addAll(i) empty", function()
        local d = kd()
        local ____mod_11 = d.____modCount
        for ____i_11 = 1, d.size do
            local x = d[____i_11]
            if x == 1 then
                d:addAllAt(1, __K2L_ReadOnlyListOf())
            end
            if d.____modCount ~= ____mod_11 and d:____comodified(____i_11) then
                break
            end
        end
        return d
    end)
    t("kd removeAll none", function()
        local d = kd()
        local ____mod_12 = d.____modCount
        for ____i_12 = 1, d.size do
            local x = d[____i_12]
            if x == 1 then
                d:removeAll(____lambda_1)
            end
            if d.____modCount ~= ____mod_12 and d:____comodified(____i_12) then
                break
            end
        end
        return d
    end)
    t("kd retainAll", function()
        local d = kd()
        local ____mod_13 = d.____modCount
        for ____i_13 = 1, d.size do
            local x = d[____i_13]
            if x == 1 then
                d:retainAll(____lambda_2)
            end
            if d.____modCount ~= ____mod_13 and d:____comodified(____i_13) then
                break
            end
        end
        return d
    end)
    t("kd sort", function()
        local d = __K2L_ArrayDeque.new(__K2L_ReadOnlyListOf(3, 1, 2))
        local ____mod_14 = d.____modCount
        for ____i_14 = 1, d.size do
            local x = d[____i_14]
            if x == 3 then
                d:sort()
            end
            if d.____modCount ~= ____mod_14 and d:____comodified(____i_14) then
                break
            end
        end
        return d
    end)
    t("kd sortWith", function()
        local d = __K2L_ArrayDeque.new(__K2L_ReadOnlyListOf(3, 1, 2))
        local ____mod_15 = d.____modCount
        for ____i_15 = 1, d.size do
            local x = d[____i_15]
            if x == 3 then
                d:sortWith(__K2L_CompareByDescending(____lambda_3))
            end
            if d.____modCount ~= ____mod_15 and d:____comodified(____i_15) then
                break
            end
        end
        return d
    end)
    t("kd sortBy", function()
        local d = __K2L_ArrayDeque.new(__K2L_ReadOnlyListOf(3, 1, 2))
        local ____mod_16 = d.____modCount
        for ____i_16 = 1, d.size do
            local x = d[____i_16]
            if x == 3 then
                d:sortBy(____lambda_4, true)
            end
            if d.____modCount ~= ____mod_16 and d:____comodified(____i_16) then
                break
            end
        end
        return d
    end)
    t("kd replaceAll", function()
        local d = kd()
        local ____mod_17 = d.____modCount
        for ____i_17 = 1, d.size do
            local x = d[____i_17]
            if x == 1 then
                d:replaceAll(____lambda_5)
            end
            if d.____modCount ~= ____mod_17 and d:____comodified(____i_17) then
                break
            end
        end
        return d
    end)
    t("kd reverse shuffle fill", function()
        local d = kd()
        local ____mod_18 = d.____modCount
        for ____i_18 = 1, d.size do
            local x = d[____i_18]
            if x == 1 then
                d:reverse()
                d:fill(4)
            end
            if d.____modCount ~= ____mod_18 and d:____comodified(____i_18) then
                break
            end
        end
        return d
    end)
    t("kd removeFirstOrNull", function()
        local d = kd()
        local ____mod_19 = d.____modCount
        for ____i_19 = 1, d.size do
            local x = d[____i_19]
            if x == 1 then
                d:removeFirstOrNull()
            end
            if d.____modCount ~= ____mod_19 and d:____comodified(____i_19) then
                break
            end
        end
        return d
    end)
    t("kd removeFirstOrNull empty", function()
        local d = __K2L_ArrayDeque.new()
        local it = __K2L_IteratorOf(d)
        d:removeFirstOrNull()
        d:clear()
        return it:hasNext()
    end)
    t("kd iterator after clear of empty", function()
        local d = __K2L_ArrayDeque.new()
        local it = __K2L_IteratorOf(d)
        d:clear()
        return it:next()
    end)
    t("kd iterator after add", function()
        local d = __K2L_ArrayDeque.new()
        local it = __K2L_IteratorOf(d)
        d:addLast(1)
        return it:next()
    end)
    t("kd iterator remove", function()
        local d = kd()
        local it = __K2L_IteratorOf(d)
        while it:hasNext() do
            if it:next() == 2 then
                it:remove()
            end
        end
        return d
    end)
    t("kd forEach", function()
        local d = kd()
        local ____mod_20 = d.____modCount
        for ____i_20 = 1, d.size do
            local it = d[____i_20]
            if it == 1 then
                d:addLast(4)
            end
            if d.____modCount ~= ____mod_20 and d:____comodified(____i_20) then
                break
            end
        end
        return d
    end)
    t("kd subList", function()
        local d = kd()
        local s = d:subList(0, 2)
        d:addLast(5)
        return s.size
    end)
    t("kd subList after sort", function()
        local d = kd()
        local s = d:subList(0, 2)
        d:sortDescending()
        return s
    end)
    t("kd add(i) index", function()
        kd():addAt(4, 1)
        return __K2L_Unit
    end)
    t("kd addAll(i) index", ____lambda_6)
    t("jd addLast", ____lambda_7)
    t("jd addLast grows", function()
        local d = jd()
        return walk(d, function(it)
            if __K2L_Equals(it, 1) then
                d:addLast(9)
            end
        end)
    end)
    t("jd addLast at the end", function()
        local d = jd()
        return walk(d, function(it)
            if __K2L_Equals(it, 3) then
                d:addLast(9)
            end
        end)
    end)
    t("jd addFirst grows", function()
        local d = jd()
        return walk(d, function(it)
            if __K2L_Equals(it, 1) then
                d:addFirst(9)
            end
        end)
    end)
    t("jd removeFirst", function()
        local d = jd()
        return walk(d, function(it)
            if __K2L_Equals(it, 1) then
                d:removeFirst()
            end
        end)
    end)
    t("jd poll", function()
        local d = jd()
        return walk(d, function(it)
            if __K2L_Equals(it, 2) then
                d:poll()
            end
        end)
    end)
    t("jd removeLast", function()
        local d = jd()
        return walk(d, function(it)
            if __K2L_Equals(it, 1) then
                d:removeLast()
            end
        end)
    end)
    t("jd pollLast at the end", function()
        local d = jd()
        return walk(d, function(it)
            if __K2L_Equals(it, 3) then
                d:pollLast()
            end
        end)
    end)
    t("jd clear", function()
        local d = jd()
        return walk(d, function(it)
            if __K2L_Equals(it, 1) then
                d:clear()
            end
        end)
    end)
    t("jd remove middle", function()
        local d = jd()
        return walk(d, function(it)
            if __K2L_Equals(it, 1) then
                d:remove(2)
            end
        end)
    end)
    t("jd remove first", function()
        local d = jd()
        return walk(d, function(it)
            if __K2L_Equals(it, 2) then
                d:remove(1)
            end
        end)
    end)
    t("jd removeIf", function()
        local d = jd()
        return walk(d, function(it)
            if __K2L_Equals(it, 1) then
                d:removeIf(____lambda_8)
            end
        end)
    end)
    t("jd push pop", function()
        local d = jd()
        return walk(d, function(it)
            if __K2L_Equals(it, 2) then
                d:push(7)
                d:pop()
            end
        end)
    end)
    t("jd roomy addLast", function()
        local d = __K2L_Deque.new()
        d:addAll(__K2L_ReadOnlyListOf(1, 2, 3))
        return walk(d, function(it)
            if it < 3 then
                d:addLast(it * 10)
            end
        end)
    end)
    t("jd roomy addFirst", function()
        local d = __K2L_Deque.new()
        d:addAll(__K2L_ReadOnlyListOf(1, 2, 3))
        return walk(d, function(it)
            if __K2L_Equals(it, 1) then
                d:addFirst(0)
            end
        end)
    end)
    t("jd capacity", function()
        local d = __K2L_Deque.new(8)
        for i = 1, 3 do
            d:addLast(i)
        end
        return walk(d, function(it)
            if __K2L_Equals(it, 1) then
                d:addLast(4)
            end
        end)
    end)
    t("jd wrapped", function()
        local d = __K2L_Deque.new(4)
        for i = 1, 4 do
            d:addLast(i)
        end
        d:pollFirst()
        d:pollFirst()
        d:addLast(5)
        d:addLast(6)
        return walk(d, function(it)
            if __K2L_Equals(it, 4) then
                d:addLast(7)
            end
        end)
    end)
    t("jd wrapped grows", function()
        local d = __K2L_Deque.new(4)
        for i = 1, 4 do
            d:addLast(i)
        end
        d:pollFirst()
        d:addLast(5)
        return walk(d, function(it)
            if __K2L_Equals(it, 3) then
                d:addLast(6)
            end
        end)
    end)
    t("jd many", function()
        local d = __K2L_Deque.new()
        for i = 1, 40 do
            if (i >= 0 and i % 3 or 0 - -i % 3) == 0 then
                d:addFirst(i)
            else
                d:addLast(i)
            end
        end
        for it = 0, 4 do
            d:pollFirst()
        end
        local steps = 0
        local ____items_1, ____n_1 = __K2L_LoopItems(d)
        local ____mod_21 = d.____modCount
        for ____i_21 = 1, ____n_1 do
            local x = ____items_1[____i_21]
            steps = steps + 1
            if (steps >= 0 and steps % 7 or 0 - -steps % 7) == 0 then
                d:addLast(x)
            end
            if d.____modCount ~= ____mod_21 and d:____comodified(____i_21, ____n_1) then
                break
            end
        end
        return steps .. " " .. d.size
    end)
    t("jd iterator remove", function()
        local d = jd()
        local it = __K2L_IteratorOf(d)
        while it:hasNext() do
            if not __K2L_Equals(it:next(), 2) then
                it:remove()
            end
        end
        return d
    end)
    t("jd iterator remove all", function()
        local d = __K2L_Deque.new(__K2L_IntRange.new(1, 9):toList())
        local it = __K2L_IteratorOf(d)
        while it:hasNext() do
            it:next()
            it:remove()
        end
        return d
    end)
    t("jd iterator twice", function()
        local d = jd()
        local it = __K2L_IteratorOf(d)
        it:next()
        it:remove()
        it:remove()
        return __K2L_Unit
    end)
    t("jd iterator class", ____lambda_9)
    t("jd iterator end", function()
        local i = __K2L_IteratorOf(jd())
        for it = 0, 2 do
            i:next()
        end
        return i:next()
    end)
    t("jd descending", function()
        local d = __K2L_Deque.new(__K2L_IntRange.new(1, 6):toList())
        local out = __K2L_ListOf()
        local it = d:descendingIterator()
        while it:hasNext() do
            local x = it:next()
            out:add(x)
            if (x >= 0 and x % 2 or 0 - -x % 2) == 0 then
                it:remove()
            end
        end
        return __K2L_Str(out) .. " " .. __K2L_Str(d)
    end)
    t("jd descending pollLast", function()
        local d = jd()
        local it = d:descendingIterator()
        it:next()
        d:pollLast()
        return it:next()
    end)
    t("jd descending pollFirst", function()
        local d = jd()
        local it = d:descendingIterator()
        it:next()
        d:pollFirst()
        return __K2L_Str(it:next()) .. " " .. tostring(it:hasNext())
    end)
    t("jd forEach", function()
        local d = jd()
        local ____items_2, ____n_2 = __K2L_LoopItems(d)
        local ____mod_22 = d.____modCount
        for ____i_22 = 1, ____n_2 do
            local it = ____items_2[____i_22]
            if __K2L_Equals(it, 1) then
                d:removeLast()
            end
            if d.____modCount ~= ____mod_22 and d:____comodified(____i_22, ____n_2) then
                break
            end
        end
        return d
    end)
    t("jd forEachIndexed", function()
        local d = jd()
        local ____items_3, ____n_3 = __K2L_LoopItems(d)
        local ____mod_23 = d.____modCount
        for ____i_23 = 1, ____n_3 do
            local x = ____items_3[____i_23]
            local i = ____i_23 - 1
            if i == 0 then
                d:addFirst(x)
            end
            if d.____modCount ~= ____mod_23 and d:____comodified(____i_23, ____n_3) then
                break
            end
        end
        return d
    end)
    t("Deque", function()
        local d = jd()
        local ____items_4, ____n_4 = __K2L_LoopItems(d)
        local ____mod_24 = d.____modCount
        for ____i_24 = 1, ____n_4 do
            local x = ____items_4[____i_24]
            if __K2L_Equals(x, 1) then
                d:removeLast()
            end
            if d.____modCount ~= ____mod_24 and d:____comodified(____i_24, ____n_4) then
                break
            end
        end
        return d
    end)
    t("Queue", function()
        local q = jd()
        local ____items_5, ____n_5 = __K2L_LoopItems(q)
        local ____mod_25 = q.____modCount
        for ____i_25 = 1, ____n_5 do
            local x = ____items_5[____i_25]
            if __K2L_Equals(x, 2) then
                q:poll()
            end
            if q.____modCount ~= ____mod_25 and q:____comodified(____i_25, ____n_5) then
                break
            end
        end
        return q
    end)
    t("Queue of a LinkedList", function()
        local q = __K2L_LinkedList.new(__K2L_ReadOnlyListOf(1, 2, 3))
        local ____items_6, ____n_6 = __K2L_LoopItems(q)
        local ____mod_26 = q.____modCount
        for ____i_26 = 1, ____n_6 do
            local x = ____items_6[____i_26]
            if __K2L_Equals(x, 2) then
                q:poll()
            end
            if q.____modCount ~= ____mod_26 and q:____comodified(____i_26, ____n_6) then
                break
            end
        end
        return q
    end)
    t("Queue of a PriorityQueue", function()
        local q = __K2L_PriorityQueue.new(__K2L_ReadOnlyListOf(3, 1, 2))
        local ____items_7, ____n_7 = __K2L_LoopItems(q)
        local ____mod_27 = q.____modCount
        for ____i_27 = 1, ____n_7 do
            local x = ____items_7[____i_27]
            if __K2L_Equals(x, 3) then
                q:add(0)
            end
            if q.____modCount ~= ____mod_27 and q:____comodified(____i_27, ____n_7) then
                break
            end
        end
        return q
    end)
    t("subclass", function()
        local d = Tracked.new()
        d:addAll(__K2L_ReadOnlyListOf("a", "b"))
        local seen = __K2L_ListOf()
        local ____items_8, ____n_8 = __K2L_LoopItems(d)
        local ____mod_28 = d.____modCount
        for ____i_28 = 1, ____n_8 do
            local x = ____items_8[____i_28]
            seen:add(x)
            if __K2L_Equals(x, "a") then
                d:addLast("c")
            end
            if d.____modCount ~= ____mod_28 and d:____comodified(____i_28, ____n_8) then
                break
            end
        end
        return __K2L_Str(seen) .. " " .. __K2L_Str(d) .. " " .. d.adds
    end)
end

__K2L_DeepMain(main)
return {t = t, kd = kd, jd = jd, walk = walk, Tracked = Tracked}
