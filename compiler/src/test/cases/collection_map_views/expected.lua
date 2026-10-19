local ____lualib = require("lualib_bundle")
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HashMapOf = ____lualib.__K2L_HashMapOf
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_Iterable = ____lualib.__K2L_Iterable
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_JdkCollections = ____lualib.__K2L_JdkCollections
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_Set = ____lualib.__K2L_Set
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_SortedMap = ____lualib.__K2L_SortedMap
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

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

local function views(label, m)
    local keys = m:getKeys()
    local values = m:getValues()
    local entries = m:getEntries()
    t(label .. " start", function()
        return __K2L_Str(keys) .. " " .. __K2L_Str(values) .. " " .. __K2L_Str(entries) .. " " .. keys.size .. " " .. values.size .. " " .. entries.size
    end)
    m:set("d", 4)
    t(label .. " after put", function()
        return __K2L_Str(keys) .. " " .. __K2L_Str(values) .. " " .. __K2L_Str(entries) .. " " .. keys.size .. " " .. values.size .. " " .. entries.size
    end)
    m:remove("a")
    t(label .. " after remove", function()
        return __K2L_Str(keys) .. " " .. __K2L_Str(values) .. " " .. __K2L_Str(entries) .. " " .. tostring(keys:isEmpty()) .. " " .. tostring(keys:contains("b")) .. " " .. tostring(values:contains(2))
    end)
    t(label .. " keys.remove", function()
        return tostring(keys:remove("b")) .. " " .. tostring(keys:remove("zz")) .. " " .. __K2L_Str(m)
    end)
    m:set("e", 5)
    m:set("f", 6)
    t(label .. " values.removeIf", function()
        return tostring(values:removeIf(function(it) return math.fmod(it, 2) == 0 end)) .. " " .. __K2L_Str(m)
    end)
    m:set("g", 7)
    m:set("h", 8)
    t(label .. " entries.removeIf", function()
        return tostring(entries:removeIf(function(it) return it.key == "g" end)) .. " " .. __K2L_Str(m)
    end)
    local it = m:iterator()
    it:next()
    it:remove()
    t(label .. " iterator remove", function() return __K2L_Str(m) .. " " .. __K2L_Str(keys) end)
    local ____items, ____n = m:____entryArray()
    local ____mod = m.____modCount
    for ____i = 1, ____n do
        local e = ____items[____i]
        e:setValue(e.value * 10)
        if m.____modCount ~= ____mod and m:____comodified(____i, ____n) then
            break
        end
    end
    t(label .. " setValue", function()
        return __K2L_Str(m) .. " " .. __K2L_Str(values)
    end)
    t(label .. " same view", function()
        return tostring(m:getKeys() == m:getKeys()) .. " " .. tostring(m:getValues() == m:getValues()) .. " " .. tostring(m:getEntries() == m:getEntries())
    end)
    t(label .. " is", function()
        local v = values
        local e = entries
        return tostring(__K2L_InstanceOf(v, __K2L_List)) .. " " .. tostring(__K2L_InstanceOf(v, __K2L_Iterable) and v.size ~= nil) .. " " .. tostring(__K2L_InstanceOf(v, __K2L_Set)) .. " " .. tostring(__K2L_InstanceOf(e, __K2L_Set)) .. " " .. tostring(__K2L_InstanceOf(e, __K2L_List)) .. " " .. tostring(__K2L_InstanceOf(keys, __K2L_Set) and not keys.____readOnly)
    end)
    t(label .. " keys add", function() return keys:add("x") end)
    t(label .. " values add", function() return values:add(1) end)
    t(label .. " entries contains", function()
        return tostring(entries:contains(m:getEntries():first())) .. " " .. tostring(entries:any(function(it) return it.key == "h" end))
    end)
    t(label .. " keys eq", function()
        return tostring(__K2L_Equals(keys, m:getKeys():toSet())) .. " " .. tostring(__K2L_Hash(keys) == __K2L_Hash(m:getKeys():toSet())) .. " " .. tostring(__K2L_Equals(values, values))
    end)
    t(label .. " values eq", function()
        return tostring(__K2L_Equals(values, m:getValues())) .. " " .. tostring(__K2L_Equals(values:toList(), m:getValues():toList()))
    end)
    t(label .. " entries eq", function()
        return tostring(__K2L_Equals(entries, m:getEntries())) .. " " .. tostring(__K2L_Hash(entries) == __K2L_Hash(m))
    end)
    t(label .. " classes", function()
        return __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(keys)).name) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(values)).name) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(entries)).name) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(entries:first())).name)
    end)
    t(label .. " iterators", function()
        return __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(__K2L_IteratorOf(keys))).name) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(__K2L_IteratorOf(values))).name) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(__K2L_IteratorOf(entries))).name)
    end)
    t(label .. " keys ops", function()
        return __K2L_Str(keys:map(function(it) return it:upper() end)) .. " " .. __K2L_Str(keys:sorted()) .. " " .. keys:first() .. " " .. keys:joinToString("|") .. " " .. __K2L_Str(keys:toList())
    end)
    t(label .. " values ops", function()
        return values:sum() .. " " .. __K2L_Str(values:maxOrNull()) .. " " .. __K2L_Str(values:filter(function(it) return it > 50 end)) .. " " .. tostring(values:contains(80))
    end)
    t(label .. " keys retainAll", function()
        return tostring(keys:retainAll(__K2L_ReadOnlyListOf("h", "e"))) .. " " .. __K2L_Str(m)
    end)
    t(label .. " values remove", function()
        return tostring(values:remove(50)) .. " " .. tostring(values:remove(999)) .. " " .. __K2L_Str(m)
    end)
    t(label .. " clear", function()
        keys:clear()
        return __K2L_Str(m) .. " " .. keys.size .. " " .. tostring(values:isEmpty()) .. " " .. __K2L_Str(entries)
    end)
    m:set("z", 26)
    t(label .. " after clear put", function()
        return __K2L_Str(keys) .. " " .. __K2L_Str(values) .. " " .. __K2L_Str(entries)
    end)
    t(label .. " minus", function()
        return __K2L_Str(keys:plus("q")) .. " " .. __K2L_Str(keys:minus("z")) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(keys:plus("q"))).name)
    end)
end

local function main()
    views("linked", __K2L_MapOf(__K2L_Pair.new("a", 1), __K2L_Pair.new("b", 2), __K2L_Pair.new("c", 3)))
    views("hash", __K2L_HashMapOf(__K2L_Pair.new("a", 1), __K2L_Pair.new("b", 2), __K2L_Pair.new("c", 3)))
    views("tree", __K2L_SortedMap.new(__K2L_ReadOnlyMapOf(__K2L_Pair.new("a", 1), __K2L_Pair.new("b", 2), __K2L_Pair.new("c", 3))))
    views("mutable", __K2L_MapOf(__K2L_Pair.new("a", 1), __K2L_Pair.new("b", 2), __K2L_Pair.new("c", 3)))
    local tm = __K2L_SortedMap.new(__K2L_ReadOnlyMapOf(__K2L_Pair.new(3, "c"), __K2L_Pair.new(1, "a"), __K2L_Pair.new(2, "b")))
    local nk = tm:navigableKeySet()
    local dk = tm:descendingKeySet()
    local dm = tm:descendingMap()
    t("tree views", function()
        return __K2L_Str(nk) .. " " .. __K2L_Str(dk) .. " " .. __K2L_Str(dm) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(nk)).name) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(dk)).name) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(dm)).name)
    end)
    t("dm", function()
        return __K2L_Str(dm:firstKey()) .. " " .. __K2L_Str(dm:lastKey()) .. " " .. __K2L_Str(dm:getKeys()) .. " " .. __K2L_Str(dm:getValues()) .. " " .. __K2L_Str(dm:getEntries()) .. " " .. dm.size .. " " .. __K2L_Str(dm:get(2))
    end)
    tm:set(4, "d")
    t("tree live", function()
        return __K2L_Str(nk) .. " " .. __K2L_Str(dk) .. " " .. __K2L_Str(dm) .. " " .. dm.size .. " " .. dk.size
    end)
    nk:remove(1)
    t("nk remove", function() return tm end)
    dm:set(0, "z")
    t("dm put", function() return __K2L_Str(tm) .. " " .. __K2L_Str(dm) end)
    dm:remove(4)
    t("dm remove", function() return __K2L_Str(tm) .. " " .. __K2L_Str(dm) end)
    t("dm poll", function()
        return __K2L_Str(dm:pollFirstEntry()) .. " " .. __K2L_Str(tm)
    end)
    dk:remove(2)
    t("dk remove", function() return __K2L_Str(tm) .. " " .. __K2L_Str(dk) end)
    local ____items_1, ____n_1 = dm:____entryArray()
    local ____mod_1 = dm.____modCount
    for ____i_1 = 1, ____n_1 do
        local e = ____items_1[____i_1]
        e:setValue(e.value .. "!")
        if dm.____modCount ~= ____mod_1 and dm:____comodified(____i_1, ____n_1) then
            break
        end
    end
    t("dm setValue", function() return tm end)
    t("dm iterate", function()
        return dm:map(function(it)
            return __K2L_Str(it.key) .. ":" .. __K2L_Str(it.value)
        end)
    end)
    t("dm headMap", function()
        return __K2L_Str(dm:headMap(0)) .. " " .. __K2L_Str(dm:ceilingKey(1)) .. " " .. __K2L_Str(dm:higherKey(3)) .. " " .. __K2L_Str(dm:floorKey(1))
    end)
    local sm = __K2L_SingletonMapOf(__K2L_Pair.new("x", 1))
    t("single views", function()
        local ____arg = sm:getKeys()
        local ____arg_1 = sm:getValues()
        local ____arg_2 = sm:getEntries()
        local ____value = sm:getValues()
        return __K2L_Str(____arg) .. " " .. __K2L_Str(____arg_1) .. " " .. __K2L_Str(____arg_2) .. " " .. tostring(__K2L_InstanceOf(____value, __K2L_Set)) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(sm:getValues())).name)
    end)
    t("single remove", function()
        local ____cast = sm:getKeys()
        if not (__K2L_InstanceOf(____cast, __K2L_Set) and not ____cast.____readOnly) then
            __K2L_CastFail(____cast, "java.util.Set", "kotlin.collections.MutableSet")
        end
        return ____cast:remove("x")
    end)
    local em = __K2L_ReadOnlyMapOf()
    t("empty views", function()
        local ____arg_3 = em:getKeys()
        local ____arg_4 = em:getValues()
        local ____arg_5 = em:getEntries()
        local ____value_1 = em:getValues()
        return __K2L_Str(____arg_3) .. " " .. __K2L_Str(____arg_4) .. " " .. __K2L_Str(____arg_5) .. " " .. tostring(__K2L_InstanceOf(____value_1, __K2L_List)) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(em:getKeys())).name)
    end)
    local um = __K2L_JdkCollections.unmodifiableMap(__K2L_MapOf(__K2L_Pair.new("a", 1)))
    t("unmodifiable keys", function()
        return __K2L_Str(um:getKeys()) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(um:getKeys())).name) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(um:getValues())).name)
    end)
    t("unmodifiable keys remove", function() return um:getKeys():remove("a") end)
    t("unmodifiable values remove", function() return um:getValues():remove(1) end)
    local m = __K2L_MapOf(__K2L_Pair.new(1, "a"), __K2L_Pair.new(2, "b"))
    local k = m:getKeys()
    m:putAll(__K2L_SingletonMapOf(__K2L_Pair.new(3, "c")))
    m:getOrPut(4, function() return "d" end)
    m:compute(1, function(_, _) return nil end)
    t("compute live", function()
        return __K2L_Str(k) .. " " .. __K2L_Str(m:getValues())
    end)
    m:getKeys():removeAll(__K2L_ReadOnlyListOf(2, 3))
    t("minusAssign", function() return __K2L_Str(m) .. " " .. __K2L_Str(k) end)
    local nested = __K2L_MapOf(__K2L_Pair.new("x", __K2L_ListOf(1)))
    nested:getValues():first():add(2)
    t("nested", function() return nested end)
    local sum = 0
    local ____items_2, ____n_2 = m:____keyArray()
    for ____i_2 = 1, ____n_2 do
        local key = ____items_2[____i_2]
        sum = sum + key
    end
    local ____items_3, ____n_3 = m:____valueArray()
    for ____i_3 = 1, ____n_3 do
        local value = ____items_3[____i_3]
        sum = sum + #value
    end
    local ____keys, ____values, ____n_4 = m:____arrays()
    for ____i_4 = 1, ____n_4 do
        local key, value = ____keys[____i_4], ____values[____i_4]
        sum = sum + (key + #value)
    end
    t("loops", function() return sum end)
    local counts = __K2L_MapOf()
    local ____list = __K2L_StringSplit("a b a c b a", " ")
    local ____mod_2 = ____list.____modCount
    for ____i_5 = 1, ____list.size do
        local w = ____list[____i_5]
        counts:set(w, (counts:get(w) or 0) + 1)
        if ____list.____modCount ~= ____mod_2 and ____list:____comodified(____i_5) then
            break
        end
    end
    t("counts", function()
        return __K2L_Str(counts:getEntries():sortedByDescending(function(it) return it.value end):map(function(it) return it.key end)) .. " " .. __K2L_Str(counts:getValues():sorted())
    end)
end

main()
return {t = t, views = views}
