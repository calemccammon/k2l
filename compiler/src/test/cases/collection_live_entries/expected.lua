local ____lualib = require("lualib_bundle")
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Entry = ____lualib.__K2L_Entry
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_HashSetOf = ____lualib.__K2L_HashSetOf
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapBuilderOf = ____lualib.__K2L_MapBuilderOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_SortedMap = ____lualib.__K2L_SortedMap
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

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

local Lru = __K2L_Class("Lru", __K2L_Map)
__K2L_ClassInfo(Lru, "Lru", "Lru", "class")

function Lru:____init(capacity)
    __K2L_Map.____init(self, nil, true)
    self.capacity = capacity
    self.eldestSeen = nil
end

function Lru:removeEldestEntry(eldest)
    self.eldestSeen = eldest
    return self.size > self.capacity
end

local function maps()
    return __K2L_ReadOnlyListOf(__K2L_Pair.new("HashMap", __K2L_HashMap.new(__K2L_ReadOnlyMapOf(__K2L_Pair.new(1, "a"), __K2L_Pair.new(2, "b"), __K2L_Pair.new(3, "c")))), __K2L_Pair.new("LinkedHashMap", __K2L_MapOf(__K2L_Pair.new(1, "a"), __K2L_Pair.new(2, "b"), __K2L_Pair.new(3, "c"))), __K2L_Pair.new("TreeMap", __K2L_SortedMap.new(__K2L_ReadOnlyMapOf(__K2L_Pair.new(1, "a"), __K2L_Pair.new(2, "b"), __K2L_Pair.new(3, "c")))), __K2L_Pair.new("mutableMapOf", __K2L_MapOf(__K2L_Pair.new(1, "a"), __K2L_Pair.new(2, "b"), __K2L_Pair.new(3, "c"))))
end

local ____lambda_1 = function(_, v) return __K2L_Str(v) .. "!" end
local ____lambda_2 = function(it) return it.key == 3 end
local ____lambda_3 = function(a, b) return a .. b end
local ____lambda_4 = function(k, v) return v .. k end
local ____lambda_5 = function(_, v) return v:upper() end
local ____lambda_6 = function(it) return it.key == 1 end
local function main()
    local ____list = maps()
    local ____mod = ____list.____modCount
    for ____i = 1, ____list.size do
        local ____item = ____list[____i]
        local name, m = ____item.first, ____item.second
        local first = m:getEntries():first()
        local all = m:getEntries():toList()
        m:set(1, "z")
        m:put(2, "y")
        m:compute(3, ____lambda_1)
        print(name .. ": " .. __K2L_Str(first) .. " " .. first.value .. " " .. __K2L_Str(all) .. " " .. tostring(first == m:getEntries():first()) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(first)).name))
        first:setValue("w")
        print(name .. " setValue: " .. __K2L_Str(m) .. " " .. __K2L_Str(m:get(1)))
        m:remove(1)
        m:set(1, "n")
        print(name .. " removed: " .. first.value .. " " .. first:setValue("q") .. " " .. __K2L_Str(first) .. " " .. __K2L_Str(m))
        local third = m:getEntries():first(____lambda_2)
        m:remove(1)
        m:set(3, "three")
        m:merge(3, "+", ____lambda_3)
        print(name .. " after remove: " .. __K2L_Str(third) .. " " .. __K2L_Str(m:getEntries()))
        m:replaceAll(____lambda_4)
        m:putIfAbsent(3, "ignored")
        m:computeIfPresent(3, ____lambda_5)
        print(name .. " replaceAll: " .. __K2L_Str(third) .. " " .. __K2L_Str(m))
        m:clear()
        m:set(3, "fresh")
        print(name .. " cleared: " .. __K2L_Str(third) .. " " .. __K2L_Str(m:getEntries():first()))
        if ____list.____modCount ~= ____mod and ____list:____comodified(____i) then
            break
        end
    end
    local hm = __K2L_HashMap.new()
    hm:set(1, "a")
    local e1 = hm:getEntries():first()
    for i = 2, 40 do
        local ____key = i * 16
        hm:set(____key, "x" .. i)
    end
    hm:set(1, "y")
    print("grown: " .. __K2L_Str(e1) .. " " .. tostring(hm:getEntries():first(____lambda_6) == e1))
    local tm = __K2L_SortedMap.new()
    tm:set(50, "fifty")
    local e50 = tm:getEntries():first()
    for i = 1, 20 do
        tm:set(i, "v" .. i)
    end
    tm:set(50, "FIFTY")
    print("tree: " .. __K2L_Str(e50) .. " " .. __K2L_Str(tm:lastEntry()) .. " " .. tostring(tm:getEntries():last() == e50))
    local scores = __K2L_MapOf(__K2L_Pair.new("ann", 1), __K2L_Pair.new("bob", 2))
    local seen = __K2L_ListOf()
    local ____items, ____n = scores:____entryArray()
    local ____mod_1 = scores.____modCount
    for ____i_1 = 1, ____n do
        local e = ____items[____i_1]
        seen:add(e)
        if scores.____modCount ~= ____mod_1 and scores:____comodified(____i_1, ____n) then
            break
        end
    end
    local ____items_1, ____n_1 = scores:____entryArray()
    local ____mod_2 = scores.____modCount
    for ____i_2 = 1, ____n_1 do
        local e = ____items_1[____i_2]
        seen:add(e)
        if scores.____modCount ~= ____mod_2 and scores:____comodified(____i_2, ____n_1) then
            break
        end
    end
    scores:set("ann", 10)
    scores:set("bob", 20)
    print("loops: " .. __K2L_Str(seen))
    local it = __K2L_IteratorOf(scores:getEntries())
    local head = it:next()
    scores:set("ann", 100)
    print("iterator: " .. __K2L_Str(head))
    local ____items_2, ____n_2 = scores:____entryArray()
    for ____i_3 = 1, ____n_2 do
        local ____item_1 = ____items_2[____i_3]
        local k, v = ____item_1.key, ____item_1.value
        io.write(k .. "=" .. v .. " ")
    end
    print()
    local lru = Lru.new(2)
    lru:set("a", 1)
    lru:set("b", 2)
    local a = lru:getEntries():first()
    lru:get("a")
    lru:set("a", 5)
    print("lru: " .. __K2L_Str(a) .. " " .. __K2L_Str(lru) .. " " .. __K2L_Str(lru.eldestSeen))
    lru:set("c", 3)
    local ____receiver = lru.eldestSeen
    print("lru evicted: " .. __K2L_Str(lru) .. " " .. __K2L_Str(lru.eldestSeen) .. " " .. __K2L_Str(____receiver and ____receiver.value))
    lru:set("a", 6)
    print("lru eldest live: " .. __K2L_Str(lru.eldestSeen))
    local built = nil
    local ____builder = __K2L_MapBuilderOf()
    ____builder:put(1, "a")
    built = ____builder:getEntries():first()
    ____builder:put(1, "b")
    local b = ____builder:____build()
    print("buildMap: " .. __K2L_Str(built) .. " " .. __K2L_Str(b))
    t("built setValue", function()
        local ____cast = b:getEntries():first()
        if not __K2L_InstanceOf(____cast, __K2L_Entry) then
            __K2L_CastFail(____cast, "java.lang.collections.MutableMap.MutableEntry", "kotlin.collections.MutableMap.MutableEntry")
        end
        return ____cast:setValue("c")
    end)
    local nav = __K2L_SortedMap.new(__K2L_ReadOnlyMapOf(__K2L_Pair.new(1, "a"), __K2L_Pair.new(2, "b"), __K2L_Pair.new(3, "c")))
    local fe = nav:firstEntry()
    local fl = nav:floorEntry(2)
    nav:set(1, "z")
    nav:set(2, "y")
    print("copies: " .. __K2L_Str(fe) .. " " .. __K2L_Str(fl) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(fe)).name) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(nav:getEntries():first())).name))
    t("firstEntry setValue", function() return nav:firstEntry():setValue("q") end)
    t("pollFirstEntry", function()
        local p = nav:pollFirstEntry()
        return __K2L_Str(p) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(p)).name) .. " " .. __K2L_Str(nav)
    end)
    t("lastEntry equals", function()
        return __K2L_Equals(nav:lastEntry(), nav:getEntries():last())
    end)
    local counts = __K2L_HashMap.new(__K2L_SingletonMapOf(__K2L_Pair.new("x", 1)))
    local ex = counts:getEntries():first()
    local set = __K2L_HashSetOf(ex)
    counts:set("x", 2)
    print("hash: " .. tostring(__K2L_Hash(ex) == __K2L_Hash("x") ~ 2) .. " " .. tostring(counts:getEntries():contains(ex)) .. " " .. set.size)
    local ____value = __K2L_SortedMap.new(__K2L_ReadOnlyMapOf(__K2L_Pair.new(1, "a"), __K2L_Pair.new(2, "b")))
    local dm = __K2L_Pair.new(____value, ____value:descendingMap())
    local de = dm.second:getEntries():first()
    local ____object = dm.first
    ____object:set(2, "z")
    de:setValue("w")
    print("descending: " .. __K2L_Str(de) .. " " .. __K2L_Str(dm.first))
end

__K2L_DeepMain(main)
return {t = t, Lru = Lru, maps = maps}
