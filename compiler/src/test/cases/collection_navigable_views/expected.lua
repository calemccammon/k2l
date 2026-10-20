local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_ReverseOrder = ____lualib.__K2L_ReverseOrder
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_SortedMap = ____lualib.__K2L_SortedMap
local __K2L_SortedSet = ____lualib.__K2L_SortedSet
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

local ____lambda_1 = function(it) return "v" .. it end
local function tm()
    return __K2L_SortedMap.new(__K2L_IntRange.new(1, 9):associateWith(____lambda_1))
end

local function ts()
    return __K2L_SortedSet.new(__K2L_IntRange.new(1, 9):toList())
end

local Audited = __K2L_Class("Audited", __K2L_SortedMap)
__K2L_ClassInfo(Audited, "Audited", "Audited", "class")

function Audited:____init()
    __K2L_SortedMap.____init(self)
    self.log = __K2L_ListOf()
end

function Audited:put(key, value)
    self.log:add("put " .. key)
    return __K2L_SortedMap.put(self, key, value)
end

local ____lambda_2 = function(a, b) return a .. b end
local ____lambda_3 = function(_, _) return "x" end
local ____lambda_4 = function(it) return "x" end
local ____lambda_5 = function(a, b) return a .. b end
local ____lambda_6 = function(k, v) return v .. k end
local ____lambda_7 = function() return tm():headMap(-1):firstKey() end
local ____lambda_8 = function() return tm():subMap(6, 3) end
local ____lambda_9 = function(it)
    return __K2L_JavaClass(__K2L_KClassOfValue(it)).name
end
local ____lambda_10 = function(it)
    return (it >= 0 and it % 2 or 0 - -it % 2) == 0
end
local ____lambda_11 = function(it) return it.key > 2 end
local ____lambda_12 = function(it) return it.value end
local ____lambda_13 = function(it)
    return (it >= 0 and it % 2 or 0 - -it % 2) == 0
end
local ____lambda_14 = function() return ts():headSet(0):first() end
local ____lambda_15 = function() return ts():subSet(6, 3) end
local ____lambda_16 = function() return ts():headSet(5, false):headSet(7) end
local ____lambda_17 = function()
    return ts():headSet(5, false):tailSet(6, true)
end
local ____lambda_18 = function()
    return ts():headSet(3, true):descendingSet():add(8)
end
local ____lambda_19 = function(it) return it * 2 end
local ____lambda_20 = function(it) return it > 3 end
local function main()
    local m = tm()
    local h = m:headMap(5)
    local nh = m:headMap(5, true)
    local tl = m:tailMap(7)
    local sub = m:subMap(3, 6)
    print(__K2L_Str(h) .. " " .. __K2L_Str(nh) .. " " .. __K2L_Str(tl) .. " " .. __K2L_Str(sub) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(h)).name))
    m:set(0, "zero")
    m:remove(4)
    m:set(10, "ten")
    print(__K2L_Str(h) .. " " .. h.size .. " " .. __K2L_Str(nh) .. " " .. nh.size .. " " .. __K2L_Str(tl) .. " " .. tl.size .. " " .. __K2L_Str(sub) .. " " .. sub.size)
    print(__K2L_Str(h:getKeys()) .. " " .. __K2L_Str(h:getValues()) .. " " .. __K2L_Str(h:getEntries()) .. " " .. __K2L_Str(nh:firstKey()) .. " " .. __K2L_Str(nh:lastKey()) .. " " .. __K2L_Str(tl:firstEntry()) .. " " .. tostring(sub:isEmpty()))
    t("get out", function()
        return __K2L_Str(h:get(8)) .. " " .. tostring(h:containsKey(8)) .. " " .. __K2L_Str(h:getOrDefault(8, "d")) .. " " .. __K2L_Str(h:remove(8)) .. " " .. tostring(h:getKeys():contains(8))
    end)
    t("put out", function()
        h:set(7, "x")
        return __K2L_Unit
    end)
    t("putIfAbsent out", function() return h:putIfAbsent(9, "x") end)
    t("merge out", function() return h:merge(9, "x", ____lambda_2) end)
    t("compute out", function() return h:compute(9, ____lambda_3) end)
    t("computeIfAbsent out", function() return h:computeIfAbsent(9, ____lambda_4) end)
    t("putAll partly out", function()
        local c = tm()
        local v = c:headMap(3)
        v:putAll(__K2L_ReadOnlyMapOf(__K2L_Pair.new(-1, "a"), __K2L_Pair.new(8, "b")))
        return c
    end)
    t("put in", function()
        local c = tm()
        local v = c:headMap(3)
        local ____key = -5
        v:set(____key, "m")
        v:putIfAbsent(0, "z")
        v:merge(1, "!", ____lambda_5)
        return c
    end)
    t("remove in", function()
        local c = tm()
        local v = c:subMap(3, 6)
        return __K2L_Str(v:remove(4)) .. " " .. tostring(v:remove(3, "nope")) .. " " .. tostring(v:remove(5, "v5")) .. " " .. __K2L_Str(c)
    end)
    t("replaceAll", function()
        local c = tm()
        c:tailMap(7):replaceAll(____lambda_6)
        return c
    end)
    t("clear", function()
        local c = tm()
        local v = c:subMap(2, 8)
        v:clear()
        return __K2L_Str(c) .. " " .. __K2L_Str(v) .. " " .. v.size
    end)
    t("poll", function()
        local c = tm()
        local v = c:headMap(4)
        local p = __K2L_Str(v:pollFirstEntry()) .. " " .. __K2L_Str(v:pollLastEntry()) .. " " .. __K2L_Str(c)
        local ____receiver = v:pollFirstEntry()
        local ____receiver_1 = ____receiver and __K2L_JavaClass(__K2L_KClassOfValue(____receiver))
        return p .. " " .. __K2L_Str(____receiver_1 and ____receiver_1.name) .. " " .. __K2L_Str(c)
    end)
    t("navigation", function()
        local v = tm():subMap(3, true, 6, true)
        return __K2L_Str(v:ceilingKey(7)) .. " " .. __K2L_Str(v:floorKey(100)) .. " " .. __K2L_Str(v:higherKey(5)) .. " " .. __K2L_Str(v:lowerKey(3)) .. " " .. __K2L_Str(v:floorEntry(4))
    end)
    t("empty view", function()
        local v = tm():subMap(4, 4)
        return __K2L_Str(v) .. " " .. v.size .. " " .. tostring(v:isEmpty()) .. " " .. __K2L_Str(v:firstEntry())
    end)
    t("empty firstKey", ____lambda_7)
    t("reversed bounds", ____lambda_8)
    t("equals", function()
        local v = tm():headMap(4)
        return tostring(__K2L_Equals(v, __K2L_ReadOnlyMapOf(__K2L_Pair.new(1, "v1"), __K2L_Pair.new(2, "v2"), __K2L_Pair.new(3, "v3")))) .. " " .. tostring(__K2L_Hash(v) == __K2L_SortedMap.new(v):hashCode()) .. " " .. __K2L_Str(__K2L_SortedMap.new(v))
    end)
    t("head of head", function() return m:headMap(5, false):headMap(3) end)
    t("head of head out", function() return m:headMap(5, false):headMap(7) end)
    t("tail of head", function() return m:headMap(5, false):tailMap(2, true) end)
    t("tail of head at the bound", function()
        return __K2L_Str(m:headMap(5, false):tailMap(5, false))
    end)
    t("tail of head past the bound", function() return m:headMap(5, false):tailMap(5, true) end)
    t("sub of tail", function()
        return m:tailMap(2, true):subMap(3, false, 8, true)
    end)
    t("sub of tail out", function()
        return m:tailMap(2, true):subMap(1, true, 8, true)
    end)
    t("view of view live", function()
        local c = tm()
        local v = c:tailMap(2, true):headMap(8, false):subMap(3, true, 6, true)
        c:remove(5)
        c:set(4, "four")
        return __K2L_Str(v) .. " " .. v.size
    end)
    local dm = m:descendingMap()
    print(__K2L_Str(dm) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(dm)).name) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(dm:descendingMap())).name) .. " " .. __K2L_Str(dm:firstKey()))
    t("descending head", function() return dm:headMap(5) end)
    t("descending tail", function() return dm:tailMap(5, false) end)
    t("descending sub", function() return dm:subMap(7, 3) end)
    t("descending sub reversed", function() return dm:subMap(3, 7) end)
    t("descending of a view", function()
        local v = m:subMap(2, true, 6, true):descendingMap()
        return __K2L_Str(v) .. " " .. __K2L_Str(v:headMap(3)) .. " " .. __K2L_Str(v:descendingMap()) .. " " .. __K2L_Str(v:ceilingKey(4))
    end)
    t("descending poll", function()
        local c = tm()
        local v = c:headMap(4, true):descendingMap()
        return __K2L_Str(v:pollFirstEntry()) .. " " .. __K2L_Str(c)
    end)
    t("descending put out", function()
        local ____object = tm():headMap(4, true):descendingMap()
        ____object:set(6, "x")
        return __K2L_Unit
    end)
    t("descending keys", function()
        return __K2L_Str(m:descendingKeySet()) .. " " .. __K2L_Str(m:headMap(3, true):descendingKeySet()) .. " " .. __K2L_Str(m:headMap(3, true):navigableKeySet())
    end)
    t("view classes", function()
        local v = m:headMap(4, true)
        return __K2L_ReadOnlyListOf(v:getKeys(), v:getValues(), v:getEntries(), __K2L_IteratorOf(v:getEntries()), __K2L_IteratorOf(v:getKeys()), dm:getEntries(), __K2L_IteratorOf(dm:getKeys()), __K2L_IteratorOf(dm:getEntries())):joinToString(nil, nil, nil, nil, nil, ____lambda_9)
    end)
    t("loop", function()
        local out = __K2L_ListOf()
        local ____map = m:subMap(1, 4)
        local ____keys, ____values, ____n = ____map:____arrays()
        local ____mod = ____map.____modCount
        for ____i = 1, ____n do
            local k, v = ____keys[____i], ____values[____i]
            out:add(__K2L_Str(k) .. __K2L_Str(v))
            if ____map.____modCount ~= ____mod and ____map:____comodified(____i, ____n) then
                break
            end
        end
        return out
    end)
    t("loop cme", function()
        local c = tm()
        local ____collection = c:headMap(3)
        local ____items, ____n_1 = ____collection:____keyArray()
        local ____mod_1 = ____collection.____modCount
        for ____i_1 = 1, ____n_1 do
            local k = ____items[____i_1]
            c:set(100, "x")
            if ____collection.____modCount ~= ____mod_1 and ____collection:____comodified(____i_1, ____n_1) then
                break
            end
        end
        return c
    end)
    t("loop change at the end", function()
        local c = tm()
        local ____collection_1 = c:headMap(3)
        local ____items_1, ____n_2 = ____collection_1:____entryArray()
        local ____mod_2 = ____collection_1.____modCount
        for ____i_2 = 1, ____n_2 do
            local e = ____items_1[____i_2]
            if __K2L_Equals(e.key, 2) then
                c:set(100, "x")
            end
            if ____collection_1.____modCount ~= ____mod_2 and ____collection_1:____comodified(____i_2, ____n_2) then
                break
            end
        end
        return c.size
    end)
    t("iterator remove", function()
        local c = tm()
        local it = __K2L_IteratorOf(c:headMap(4):getEntries())
        it:next()
        it:remove()
        it:next()
        it:remove()
        return c
    end)
    t("keys remove", function()
        local c = tm()
        local v = c:subMap(2, 6)
        v:getKeys():remove(3)
        v:getKeys():removeIf(____lambda_10)
        v:getValues():remove("v5")
        return __K2L_Str(c) .. " " .. __K2L_Str(v)
    end)
    t("entries live", function()
        local c = tm()
        local e = c:subMap(2, 6):getEntries():first()
        c:set(2, "two")
        e:setValue("TWO")
        return __K2L_Str(e) .. " " .. __K2L_Str(c:get(2))
    end)
    t("keys headSet", function()
        return __K2L_Str(m:navigableKeySet():headSet(3)) .. " " .. __K2L_Str(m:navigableKeySet():tailSet(8)) .. " " .. __K2L_Str(m:navigableKeySet():subSet(2, 4))
    end)
    t("copies", function()
        local v = tm():subMap(2, 5)
        return __K2L_Str(__K2L_SortedMap.new(v)) .. " " .. __K2L_Str(v:toSortedMap()) .. " " .. __K2L_Str(v:toMap()) .. " " .. __K2L_Str(v:filter(____lambda_11)) .. " " .. __K2L_Str(v:map(____lambda_12))
    end)
    t("subclass", function()
        local a = Audited.new()
        a:set(1, "a")
        local v = a:headMap(5)
        v:set(2, "b")
        v:putAll(__K2L_SingletonMapOf(__K2L_Pair.new(3, "c")))
        return __K2L_Str(a.log) .. " " .. __K2L_Str(a)
    end)
    t("comparator", function()
        local r = __K2L_SortedMap.new(__K2L_ReverseOrder)
        for i = 1, 6 do
            r:set(i, "r" .. i)
        end
        return __K2L_Str(r:headMap(4)) .. " " .. __K2L_Str(r:tailMap(4)) .. " " .. __K2L_Str(r:subMap(5, 2)) .. " " .. __K2L_Str(r:descendingMap():headMap(3))
    end)
    local s = ts()
    local hs = s:headSet(5)
    local ss = s:subSet(2, true, 6, true)
    print(__K2L_Str(hs) .. " " .. __K2L_Str(ss) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(hs)).name))
    s:add(0)
    s:remove(3)
    print(__K2L_Str(hs) .. " " .. hs.size .. " " .. __K2L_Str(ss) .. " " .. ss.size .. " " .. __K2L_Str(hs:first()) .. " " .. __K2L_Str(hs:last()) .. " " .. tostring(hs:contains(3)) .. " " .. tostring(hs:contains(8)))
    t("set add out", function() return hs:add(7) end)
    t("set add in", function()
        local c = ts()
        local v = c:headSet(5)
        return tostring(v:add(-1)) .. " " .. tostring(v:add(2)) .. " " .. __K2L_Str(c)
    end)
    t("set addAll partly out", function()
        local c = ts()
        local v = c:headSet(5)
        v:addAll(__K2L_ReadOnlyListOf(-3, 20))
        return c
    end)
    t("set remove", function()
        local c = ts()
        local v = c:headSet(5)
        return tostring(v:remove(8)) .. " " .. tostring(v:remove(2)) .. " " .. __K2L_Str(c)
    end)
    t("set removeAll", function()
        local c = ts()
        c:headSet(6):removeAll(__K2L_ReadOnlyListOf(1, 2, 8))
        return c
    end)
    t("set removeAll larger", function()
        local c = ts()
        c:headSet(3):removeAll(__K2L_ReadOnlyListOf(1, 5, 7, 8, 9))
        return c
    end)
    t("set retainAll", function()
        local c = ts()
        c:subSet(2, 7):retainAll(__K2L_ReadOnlySetOf(3, 4, 9))
        return c
    end)
    t("set removeIf", function()
        local c = ts()
        c:tailSet(4):removeIf(____lambda_13)
        return c
    end)
    t("set clear", function()
        local c = ts()
        local v = c:subSet(3, 6)
        v:clear()
        return __K2L_Str(c) .. " " .. __K2L_Str(v) .. " " .. tostring(v:isEmpty())
    end)
    t("set poll", function()
        local c = ts()
        local v = c:subSet(3, true, 7, false)
        return __K2L_Str(v:pollFirst()) .. " " .. __K2L_Str(v:pollLast()) .. " " .. __K2L_Str(c)
    end)
    t("set navigation", function()
        local v = ts():subSet(3, true, 7, false)
        return __K2L_Str(v:ceiling(8)) .. " " .. __K2L_Str(v:floor(100)) .. " " .. __K2L_Str(v:higher(5)) .. " " .. __K2L_Str(v:lower(3))
    end)
    t("set empty first", ____lambda_14)
    t("set empty", function()
        local v = ts():subSet(4, 4)
        return __K2L_Str(v) .. " " .. v.size .. " " .. tostring(v:isEmpty()) .. " " .. __K2L_Str(v:firstOrNull())
    end)
    t("set reversed bounds", ____lambda_15)
    t("set head of head out", ____lambda_16)
    t("set tail of head out", ____lambda_17)
    t("set view of view", function()
        local c = ts()
        local v = c:tailSet(1):headSet(7):subSet(2, 6)
        c:remove(4)
        c:add(4)
        c:remove(3)
        return __K2L_Str(v) .. " " .. v.size
    end)
    t("set descending", function()
        local c = ts()
        local d = c:descendingSet()
        c:add(50)
        return __K2L_Str(d) .. " " .. __K2L_Str(d:first()) .. " " .. __K2L_Str(d:headSet(4)) .. " " .. __K2L_Str(d:tailSet(4)) .. " " .. __K2L_Str(d:subSet(8, 5)) .. " " .. __K2L_Str(d:descendingSet()) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(d)).name)
    end)
    t("set descending add", function()
        local c = ts()
        local d = c:headSet(3, true):descendingSet()
        d:add(-7)
        return tostring(d:remove(9)) .. " " .. __K2L_Str(d) .. " " .. __K2L_Str(c)
    end)
    t("set descending out", ____lambda_18)
    t("set descendingIterator", function()
        local c = ts()
        local it = c:descendingIterator()
        local a = it:next()
        it:remove()
        return __K2L_Str(a) .. " " .. __K2L_Str(it:next()) .. " " .. __K2L_Str(c) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(it)).name)
    end)
    t("set iterators", function()
        return __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(__K2L_IteratorOf(hs))).name) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(__K2L_IteratorOf(s:headSet(5, false):descendingSet()))).name)
    end)
    t("set loop", function()
        local out = __K2L_ListOf()
        local ____items_2, ____n_3 = ss:____array()
        local ____mod_3 = ss.____modCount
        for ____i_3 = 1, ____n_3 do
            local x = ____items_2[____i_3]
            out:add(x * 10)
            if ss.____modCount ~= ____mod_3 and ss:____comodified(____i_3, ____n_3) then
                break
            end
        end
        return out
    end)
    t("set loop cme", function()
        local c = ts()
        local ____collection_2 = c:headSet(3)
        local ____items_3, ____n_4 = ____collection_2:____array()
        local ____mod_4 = ____collection_2.____modCount
        for ____i_4 = 1, ____n_4 do
            local x = ____items_3[____i_4]
            c:add(100)
            if ____collection_2.____modCount ~= ____mod_4 and ____collection_2:____comodified(____i_4, ____n_4) then
                break
            end
        end
        return c
    end)
    t("set loop cme outside the range", function()
        local c = ts()
        local ____collection_3 = c:headSet(3)
        local ____items_4, ____n_5 = ____collection_3:____array()
        local ____mod_5 = ____collection_3.____modCount
        for ____i_5 = 1, ____n_5 do
            local x = ____items_4[____i_5]
            c:remove(9)
            if ____collection_3.____modCount ~= ____mod_5 and ____collection_3:____comodified(____i_5, ____n_5) then
                break
            end
        end
        return c
    end)
    t("set iterator remove", function()
        local c = ts()
        local it = __K2L_IteratorOf(c:subSet(2, 5))
        it:next()
        it:remove()
        it:next()
        return __K2L_Str(c)
    end)
    t("set operations", function()
        local v = ts():subSet(2, 6)
        return __K2L_Str(v:toList()) .. " " .. __K2L_Str(v:map(____lambda_19)) .. " " .. __K2L_Str(v:filter(____lambda_20)) .. " " .. v:sum() .. " " .. __K2L_Str(v:toSortedSet()) .. " " .. __K2L_Str(__K2L_SortedSet.new(v))
    end)
    t("set equals", function()
        local v = ts():headSet(4)
        return tostring(__K2L_Equals(v, __K2L_ReadOnlySetOf(1, 2, 3))) .. " " .. tostring(__K2L_Equals(__K2L_ReadOnlySetOf(1, 2, 3), v)) .. " " .. __K2L_Hash(v)
    end)
    t("set comparator", function()
        local ____value = __K2L_SortedSet.new(__K2L_ReverseOrder)
        ____value:addAll(__K2L_IntRange.new(1, 6))
        local r = ____value
        return __K2L_Str(r:headSet(4)) .. " " .. __K2L_Str(r:subSet(5, 2)) .. " " .. __K2L_Str(r:descendingSet():tailSet(3))
    end)
end

__K2L_DeepMain(main)
return {t = t, tm = tm, ts = ts, Audited = Audited}
