local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_HashMapOf = ____lualib.__K2L_HashMapOf
local __K2L_HashSetOf = ____lualib.__K2L_HashSetOf
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_LinkedList = ____lualib.__K2L_LinkedList
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PriorityQueue = ____lualib.__K2L_PriorityQueue
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_SortedMap = ____lualib.__K2L_SortedMap
local __K2L_SortedSetOf = ____lualib.__K2L_SortedSetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf
local __K2L_Unit = ____lualib.__K2L_Unit

local function t(name, f)
    local r
    local ____ok, ____result = pcall(function()
        r = f()
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_Exception) then
            local e = ____error
            r = __K2L_JavaClass(__K2L_KClassOfValue(e)).name .. ": " .. __K2L_Str(e.message)
        else
            error(____error, 0)
        end
    end
    print(name .. " -> " .. __K2L_Str(r))
end

local function main()
    t("list add in for", function()
        local l = __K2L_ListOf(1, 2, 3)
        local seen = __K2L_ListOf()
        local ____mod = l.____modCount
        for ____i = 1, l.size do
            local x = l[____i]
            seen:add(x)
            if x == 1 then
                l:add(9)
            end
            if l.____modCount ~= ____mod and l:____comodified(____i) then
                break
            end
        end
        return seen
    end)
    t("list remove second-to-last", function()
        local l = __K2L_ListOf(1, 2, 3)
        local seen = __K2L_ListOf()
        local ____mod_1 = l.____modCount
        for ____i_1 = 1, l.size do
            local x = l[____i_1]
            seen:add(x)
            if x == 2 then
                l:remove(x)
            end
            if l.____modCount ~= ____mod_1 and l:____comodified(____i_1) then
                break
            end
        end
        return __K2L_Str(seen) .. " " .. __K2L_Str(l)
    end)
    t("list remove last", function()
        local l = __K2L_ListOf(1, 2, 3)
        local seen = __K2L_ListOf()
        local ____mod_2 = l.____modCount
        for ____i_2 = 1, l.size do
            local x = l[____i_2]
            seen:add(x)
            if x == 3 then
                l:remove(x)
            end
            if l.____modCount ~= ____mod_2 and l:____comodified(____i_2) then
                break
            end
        end
        return __K2L_Str(seen) .. " " .. __K2L_Str(l)
    end)
    t("list remove first", function()
        local l = __K2L_ListOf(1, 2, 3)
        local ____mod_3 = l.____modCount
        for ____i_3 = 1, l.size do
            local x = l[____i_3]
            if x == 1 then
                l:remove(x)
            end
            if l.____modCount ~= ____mod_3 and l:____comodified(____i_3) then
                break
            end
        end
        return l
    end)
    t("list add at last", function()
        local l = __K2L_ListOf(1, 2, 3)
        local ____mod_4 = l.____modCount
        for ____i_4 = 1, l.size do
            local x = l[____i_4]
            if x == 3 then
                l:add(4)
            end
            if l.____modCount ~= ____mod_4 and l:____comodified(____i_4) then
                break
            end
        end
        return l
    end)
    t("list remove two at second", function()
        local l = __K2L_ListOf(1, 2, 3, 4)
        local seen = __K2L_ListOf()
        local ____mod_5 = l.____modCount
        for ____i_5 = 1, l.size do
            local x = l[____i_5]
            seen:add(x)
            if x == 2 then
                l:removeAt(3)
                l:removeAt(2)
            end
            if l.____modCount ~= ____mod_5 and l:____comodified(____i_5) then
                break
            end
        end
        return __K2L_Str(seen) .. " " .. __K2L_Str(l)
    end)
    t("list add+remove", function()
        local l = __K2L_ListOf(1, 2, 3)
        local ____mod_6 = l.____modCount
        for ____i_6 = 1, l.size do
            local x = l[____i_6]
            if x == 1 then
                l:add(5)
                l:removeAt(3)
            end
            if l.____modCount ~= ____mod_6 and l:____comodified(____i_6) then
                break
            end
        end
        return l
    end)
    t("list sort in loop", function()
        local l = __K2L_ListOf(3, 2, 1)
        local ____mod_7 = l.____modCount
        for ____i_7 = 1, l.size do
            local x = l[____i_7]
            l:sort()
            if l.____modCount ~= ____mod_7 and l:____comodified(____i_7) then
                break
            end
        end
        return l
    end)
    t("list set in loop", function()
        local l = __K2L_ListOf(3, 2, 1)
        for i = 0, l.size - 1 do
            local x = l[i + 1]
            l:set(i, x * 2)
        end
        local ____mod_8 = l.____modCount
        for ____i_8 = 1, l.size do
            local x = l[____i_8]
            l:set(0, x)
            if l.____modCount ~= ____mod_8 and l:____comodified(____i_8) then
                break
            end
        end
        return l
    end)
    t("list forEach add", function()
        local l = __K2L_ListOf(1, 2)
        local ____mod_9 = l.____modCount
        for ____i_9 = 1, l.size do
            local it = l[____i_9]
            if it == 1 then
                l:add(3)
            end
            if l.____modCount ~= ____mod_9 and l:____comodified(____i_9) then
                break
            end
        end
        return l
    end)
    t("list forEachIndexed add", function()
        local l = __K2L_ListOf(1, 2)
        local ____mod_10 = l.____modCount
        for ____i_10 = 1, l.size do
            local x = l[____i_10]
            local i = ____i_10 - 1
            if i == 0 then
                l:add(x)
            end
            if l.____modCount ~= ____mod_10 and l:____comodified(____i_10) then
                break
            end
        end
        return l
    end)
    t("list break after add", function()
        local l = __K2L_ListOf(1, 2)
        local ____mod_11 = l.____modCount
        for ____i_11 = 1, l.size do
            local x = l[____i_11]
            l:add(x)
            do break end
            if l.____modCount ~= ____mod_11 and l:____comodified(____i_11) then
                break
            end
        end
        return l
    end)
    t("list continue after add", function()
        local l = __K2L_ListOf(1, 2)
        local seen = __K2L_ListOf()
        local ____mod_12 = l.____modCount
        for ____i_12 = 1, l.size do
            local x = l[____i_12]
            do
                seen:add(x)
                if x == 1 then
                    l:add(7)
                    goto ____continue
                end
                seen:add(100)
            end
            ::____continue::
            if l.____modCount ~= ____mod_12 and l:____comodified(____i_12) then
                break
            end
        end
        return seen
    end)
    t("iterator add", function()
        local l = __K2L_ListOf(1, 2, 3)
        local it = __K2L_IteratorOf(l)
        it:next()
        l:add(4)
        return it:next()
    end)
    t("iterator hasNext after remove", function()
        local l = __K2L_ListOf(1, 2, 3)
        local it = __K2L_IteratorOf(l)
        it:next()
        it:next()
        l:removeAt(0)
        return tostring(it:hasNext())
    end)
    t("iterator remove ok", function()
        local l = __K2L_ListOf(1, 2, 3, 4)
        local it = __K2L_IteratorOf(l)
        while it:hasNext() do
            if math.fmod(it:next(), 2) == 0 then
                it:remove()
            end
        end
        return l
    end)
    t("iterator remove twice", function()
        local l = __K2L_ListOf(1, 2, 3)
        local it = __K2L_IteratorOf(l)
        it:next()
        it:remove()
        it:remove()
        return __K2L_Unit
    end)
    t("removeIf in loop?", function()
        local l = __K2L_ListOf(1, 2, 3)
        local ____mod_13 = l.____modCount
        for ____i_13 = 1, l.size do
            local x = l[____i_13]
            if x == 1 then
                l:removeIf(function(it) return it == 99 end)
            end
            if l.____modCount ~= ____mod_13 and l:____comodified(____i_13) then
                break
            end
        end
        return l
    end)
    t("clear in loop", function()
        local l = __K2L_ListOf(1, 2, 3)
        local ____mod_14 = l.____modCount
        for ____i_14 = 1, l.size do
            local x = l[____i_14]
            l:clear()
            if l.____modCount ~= ____mod_14 and l:____comodified(____i_14) then
                break
            end
        end
        return l
    end)
    t("addAll empty", function()
        local l = __K2L_ListOf(1, 2, 3)
        local ____mod_15 = l.____modCount
        for ____i_15 = 1, l.size do
            local x = l[____i_15]
            l:addAll(__K2L_ReadOnlyListOf())
            if l.____modCount ~= ____mod_15 and l:____comodified(____i_15) then
                break
            end
        end
        return l
    end)
    t("sublist stale", function()
        local l = __K2L_ListOf(1, 2, 3, 4)
        local s = l:subList(1, 3)
        l:add(5)
        return s.size
    end)
    t("sublist stale print", function()
        local l = __K2L_ListOf(1, 2, 3, 4)
        local s = l:subList(1, 3)
        l:removeAt(0)
        return __K2L_Str(s)
    end)
    t("sublist stale get", function()
        local l = __K2L_ListOf(1, 2, 3, 4)
        local s = l:subList(1, 3)
        l:addAt(0, 0)
        return s:get(0)
    end)
    t("sublist set ok", function()
        local l = __K2L_ListOf(1, 2, 3, 4)
        local s = l:subList(1, 3)
        l:set(0, 100)
        return __K2L_Str(s) .. " " .. s.size
    end)
    t("sublist via sublist ok", function()
        local l = __K2L_ListOf(1, 2, 3, 4)
        local s = l:subList(1, 3)
        s:add(9)
        return __K2L_Str(s) .. " " .. __K2L_Str(l)
    end)
    t("sibling stale", function()
        local l = __K2L_ListOf(1, 2, 3, 4)
        local a = l:subList(0, 2)
        local b = l:subList(2, 4)
        a:add(7)
        return b.size
    end)
    t("parent of sub ok", function()
        local l = __K2L_ListOf(1, 2, 3, 4)
        local a = l:subList(0, 3)
        local b = a:subList(0, 2)
        b:add(7)
        return __K2L_Str(a) .. " " .. __K2L_Str(l)
    end)
    t("sub loop root change", function()
        local l = __K2L_ListOf(1, 2, 3, 4)
        local a = l:subList(0, 3)
        local ____mod_16 = a.____modCount
        for ____i_16 = 1, a.size do
            local x = a[____i_16]
            l:add(x)
            if a.____modCount ~= ____mod_16 and a:____comodified(____i_16) then
                break
            end
        end
        return l
    end)
    t("hashmap put in loop", function()
        local m = __K2L_HashMapOf(__K2L_Pair.new(1, 1), __K2L_Pair.new(2, 2), __K2L_Pair.new(3, 3))
        local ____keys, ____values, ____n = m:____arrays()
        local ____mod_17 = m.____modCount
        for ____i_17 = 1, ____n do
            local k, _ = ____keys[____i_17], ____values[____i_17]
            if k == 1 then
                m:set(10, 10)
            end
            if m.____modCount ~= ____mod_17 and m:____comodified(____i_17, ____n) then
                break
            end
        end
        return m
    end)
    t("hashmap put at last", function()
        local m = __K2L_HashMapOf(__K2L_Pair.new(1, 1), __K2L_Pair.new(2, 2), __K2L_Pair.new(3, 3))
        local ____keys_1, ____values_1, ____n_1 = m:____arrays()
        local ____mod_18 = m.____modCount
        for ____i_18 = 1, ____n_1 do
            local k, _ = ____keys_1[____i_18], ____values_1[____i_18]
            if k == 3 then
                m:set(10, 10)
            end
            if m.____modCount ~= ____mod_18 and m:____comodified(____i_18, ____n_1) then
                break
            end
        end
        return m
    end)
    t("hashmap remove at last", function()
        local m = __K2L_HashMapOf(__K2L_Pair.new(1, 1), __K2L_Pair.new(2, 2), __K2L_Pair.new(3, 3))
        local ____keys_2, ____values_2, ____n_2 = m:____arrays()
        local ____mod_19 = m.____modCount
        for ____i_19 = 1, ____n_2 do
            local k, _ = ____keys_2[____i_19], ____values_2[____i_19]
            if k == 3 then
                m:remove(1)
            end
            if m.____modCount ~= ____mod_19 and m:____comodified(____i_19, ____n_2) then
                break
            end
        end
        return m
    end)
    t("hashmap remove current second", function()
        local m = __K2L_HashMapOf(__K2L_Pair.new(1, 1), __K2L_Pair.new(2, 2), __K2L_Pair.new(3, 3))
        local ____items, ____n_3 = m:____keyArray()
        local ____mod_20 = m.____modCount
        for ____i_20 = 1, ____n_3 do
            local k = ____items[____i_20]
            if k == 2 then
                m:remove(k)
            end
            if m.____modCount ~= ____mod_20 and m:____comodified(____i_20, ____n_3) then
                break
            end
        end
        return m
    end)
    t("linked put in keys loop", function()
        local m = __K2L_MapOf(__K2L_Pair.new(1, 1), __K2L_Pair.new(2, 2))
        local ____items_1, ____n_4 = m:____keyArray()
        local ____mod_21 = m.____modCount
        for ____i_21 = 1, ____n_4 do
            local k = ____items_1[____i_21]
            local ____key = k + 10
            m:set(____key, 0)
            if m.____modCount ~= ____mod_21 and m:____comodified(____i_21, ____n_4) then
                break
            end
        end
        return m
    end)
    t("linked values loop remove", function()
        local m = __K2L_MapOf(__K2L_Pair.new(1, 1), __K2L_Pair.new(2, 2))
        local ____items_2, ____n_5 = m:____valueArray()
        local ____mod_22 = m.____modCount
        for ____i_22 = 1, ____n_5 do
            local v = ____items_2[____i_22]
            m:remove(1)
            if m.____modCount ~= ____mod_22 and m:____comodified(____i_22, ____n_5) then
                break
            end
        end
        return m
    end)
    t("linked entries setValue ok", function()
        local m = __K2L_MapOf(__K2L_Pair.new(1, 1), __K2L_Pair.new(2, 2))
        local ____items_3, ____n_6 = m:____entryArray()
        local ____mod_23 = m.____modCount
        for ____i_23 = 1, ____n_6 do
            local e = ____items_3[____i_23]
            e:setValue(5)
            if m.____modCount ~= ____mod_23 and m:____comodified(____i_23, ____n_6) then
                break
            end
        end
        local ____keys_3, ____values_3, ____n_7 = m:____arrays()
        local ____mod_24 = m.____modCount
        for ____i_24 = 1, ____n_7 do
            local k, _ = ____keys_3[____i_24], ____values_3[____i_24]
            m:set(k, 7)
            if m.____modCount ~= ____mod_24 and m:____comodified(____i_24, ____n_7) then
                break
            end
        end
        return m
    end)
    t("map forEach kv put", function()
        local m = __K2L_MapOf(__K2L_Pair.new(1, 1), __K2L_Pair.new(2, 2))
        local seen = __K2L_ListOf()
        for k, _ in m:iter(true) do
            seen:add(k)
            if k == 1 then
                m:set(3, 3)
            end
        end
        return __K2L_Str(seen) .. " " .. __K2L_Str(m)
    end)
    t("map forEach kv put last", function()
        local m = __K2L_MapOf(__K2L_Pair.new(1, 1), __K2L_Pair.new(2, 2))
        for k, _ in m:iter(true) do
            if k == 2 then
                m:set(3, 3)
            end
        end
        return m
    end)
    t("map forEach entry put", function()
        local m = __K2L_MapOf(__K2L_Pair.new(1, 1), __K2L_Pair.new(2, 2))
        local ____items_4, ____n_8 = m:____entryArray()
        local ____mod_25 = m.____modCount
        for ____i_25 = 1, ____n_8 do
            local e = ____items_4[____i_25]
            if e.key == 1 then
                m:set(3, 3)
            end
            if m.____modCount ~= ____mod_25 and m:____comodified(____i_25, ____n_8) then
                break
            end
        end
        return m
    end)
    t("map iterator remove", function()
        local m = __K2L_MapOf(__K2L_Pair.new(1, 1), __K2L_Pair.new(2, 2), __K2L_Pair.new(3, 3))
        local it = __K2L_IteratorOf(m:getEntries())
        while it:hasNext() do
            if it:next().key == 2 then
                it:remove()
            end
        end
        return m
    end)
    t("map keys iterator then put", function()
        local m = __K2L_MapOf(__K2L_Pair.new(1, 1), __K2L_Pair.new(2, 2), __K2L_Pair.new(3, 3))
        local it = __K2L_IteratorOf(m:getKeys())
        it:next()
        m:set(4, 4)
        return it:next()
    end)
    t("set add in loop", function()
        local s = __K2L_SetOf(1, 2, 3)
        local ____items_5, ____n_9 = s:____array()
        local ____mod_26 = s.____modCount
        for ____i_26 = 1, ____n_9 do
            local x = ____items_5[____i_26]
            if x == 1 then
                s:add(9)
            end
            if s.____modCount ~= ____mod_26 and s:____comodified(____i_26, ____n_9) then
                break
            end
        end
        return s
    end)
    t("hashset remove in loop at last", function()
        local s = __K2L_HashSetOf(1, 2, 3)
        local ____items_6, ____n_10 = s:____array()
        local ____mod_27 = s.____modCount
        for ____i_27 = 1, ____n_10 do
            local x = ____items_6[____i_27]
            if x == 3 then
                s:remove(1)
            end
            if s.____modCount ~= ____mod_27 and s:____comodified(____i_27, ____n_10) then
                break
            end
        end
        return s
    end)
    t("set clear in loop", function()
        local s = __K2L_SetOf(1, 2, 3)
        local ____items_7, ____n_11 = s:____array()
        local ____mod_28 = s.____modCount
        for ____i_28 = 1, ____n_11 do
            local x = ____items_7[____i_28]
            s:clear()
            if s.____modCount ~= ____mod_28 and s:____comodified(____i_28, ____n_11) then
                break
            end
        end
        return s
    end)
    t("treemap put in loop", function()
        local m = __K2L_SortedMap.new(__K2L_ReadOnlyMapOf(__K2L_Pair.new(1, 1), __K2L_Pair.new(2, 2)))
        local ____keys_4, ____values_4, ____n_12 = m:____arrays()
        local ____mod_29 = m.____modCount
        for ____i_29 = 1, ____n_12 do
            local k, _ = ____keys_4[____i_29], ____values_4[____i_29]
            if __K2L_Equals(k, 1) then
                m:set(0, 0)
            end
            if m.____modCount ~= ____mod_29 and m:____comodified(____i_29, ____n_12) then
                break
            end
        end
        return m
    end)
    t("treeset in loop", function()
        local s = __K2L_SortedSetOf(1, 2, 3)
        local ____items_8, ____n_13 = s:____array()
        local ____mod_30 = s.____modCount
        for ____i_30 = 1, ____n_13 do
            local x = ____items_8[____i_30]
            if x == 2 then
                s:add(0)
            end
            if s.____modCount ~= ____mod_30 and s:____comodified(____i_30, ____n_13) then
                break
            end
        end
        return s
    end)
    t("linkedlist add", function()
        local l = __K2L_LinkedList.new(__K2L_ReadOnlyListOf(1, 2))
        local ____mod_31 = l.____modCount
        for ____i_31 = 1, l.size do
            local x = l[____i_31]
            if __K2L_Equals(x, 1) then
                l:add(3)
            end
            if l.____modCount ~= ____mod_31 and l:____comodified(____i_31) then
                break
            end
        end
        return l
    end)
    t("linkedlist remove last", function()
        local l = __K2L_LinkedList.new(__K2L_ReadOnlyListOf(1, 2, 3))
        local ____mod_32 = l.____modCount
        for ____i_32 = 1, l.size do
            local x = l[____i_32]
            if __K2L_Equals(x, 3) then
                l:removeFirst()
            end
            if l.____modCount ~= ____mod_32 and l:____comodified(____i_32) then
                break
            end
        end
        return l
    end)
    t("arraydeque kotlin add", function()
        local d = __K2L_ArrayDeque.new(__K2L_ReadOnlyListOf(1, 2))
        local ____mod_33 = d.____modCount
        for ____i_33 = 1, d.size do
            local x = d[____i_33]
            if x == 1 then
                d:addLast(3)
            end
            if d.____modCount ~= ____mod_33 and d:____comodified(____i_33) then
                break
            end
        end
        return d
    end)
    t("pq add", function()
        local q = __K2L_PriorityQueue.new(__K2L_ReadOnlyListOf(1, 2, 3))
        local ____items_9, ____n_14 = q:____array()
        local ____mod_34 = q.____modCount
        for ____i_34 = 1, ____n_14 do
            local x = ____items_9[____i_34]
            if __K2L_Equals(x, 1) then
                q:add(0)
            end
            if q.____modCount ~= ____mod_34 and q:____comodified(____i_34, ____n_14) then
                break
            end
        end
        return q
    end)
    t("pq add at last", function()
        local q = __K2L_PriorityQueue.new(__K2L_ReadOnlyListOf(1, 2, 3))
        local ____items_10, ____n_15 = q:____array()
        local ____mod_35 = q.____modCount
        for ____i_35 = 1, ____n_15 do
            local x = ____items_10[____i_35]
            if __K2L_Equals(x, 3) then
                q:add(5)
            end
            if q.____modCount ~= ____mod_35 and q:____comodified(____i_35, ____n_15) then
                break
            end
        end
        return q:toList()
    end)
    t("map entries loop remove via entries", function()
        local m = __K2L_MapOf(__K2L_Pair.new(1, 1), __K2L_Pair.new(2, 2), __K2L_Pair.new(3, 3))
        local ____items_11, ____n_16 = m:____entryArray()
        local ____mod_36 = m.____modCount
        for ____i_36 = 1, ____n_16 do
            local e = ____items_11[____i_36]
            if e.key == 1 then
                m:getEntries():remove(e)
            end
            if m.____modCount ~= ____mod_36 and m:____comodified(____i_36, ____n_16) then
                break
            end
        end
        return m
    end)
    t("removeAll during keys loop", function()
        local m = __K2L_MapOf(__K2L_Pair.new(1, 1), __K2L_Pair.new(2, 2), __K2L_Pair.new(3, 3))
        local ____items_12, ____n_17 = m:____keyArray()
        local ____mod_37 = m.____modCount
        for ____i_37 = 1, ____n_17 do
            local k = ____items_12[____i_37]
            if k == 1 then
                m:getKeys():removeAll(__K2L_SingletonListOf(3))
            end
            if m.____modCount ~= ____mod_37 and m:____comodified(____i_37, ____n_17) then
                break
            end
        end
        return m
    end)
    t("getOrPut in loop existing", function()
        local m = __K2L_MapOf(__K2L_Pair.new(1, 1), __K2L_Pair.new(2, 2))
        local ____items_13, ____n_18 = m:____keyArray()
        local ____mod_38 = m.____modCount
        for ____i_38 = 1, ____n_18 do
            local k = ____items_13[____i_38]
            m:getOrPut(k, function() return 0 end)
            if m.____modCount ~= ____mod_38 and m:____comodified(____i_38, ____n_18) then
                break
            end
        end
        return m
    end)
    t("array no cme", function()
        local a = __K2L_TypedArrayOf("[Ljava.lang.Integer;", 1, 2, 3)
        for ____i_39 = 1, a.size do
            local x = a[____i_39]
            a:set(0, x)
        end
        return a:toList()
    end)
end

main()
return {t = t}
