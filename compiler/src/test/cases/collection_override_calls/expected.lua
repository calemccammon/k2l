local ____lualib = require("lualib_bundle")
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_HashSet = ____lualib.__K2L_HashSet
local __K2L_HonorOverrides = ____lualib.__K2L_HonorOverrides
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_JdkCollections = ____lualib.__K2L_JdkCollections
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PropertyOverride = ____lualib.__K2L_PropertyOverride
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local log = __K2L_ListOf()

local function op(name, f)
    log:clear()
    local r
    local ____ok, ____result = __K2L_DeepPcall(function()
        r = f()
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_Exception) then
            local e = ____error
            r = __K2L_JavaClass(__K2L_KClassOfValue(e)).name
        else
            error(____error, 0)
        end
    end
    print(name .. " -> " .. __K2L_Str(r) .. " " .. log:joinToString(","))
end

local L = __K2L_Class("L", __K2L_List)
__K2L_ClassInfo(L, "L", "L", "class")

function L:____init()
    __K2L_List.____init(self, __K2L_ReadOnlyListOf(1, 2, 3))
end

function L:getSize()
    log:add("size")
    return rawget(self, "____size") or self.size
end

function L:iterator()
    log:add("iterator")
    return __K2L_List.iterator(self)
end

function L:get(index)
    log:add("get(" .. index .. ")")
    return __K2L_List.get(self, index)
end

function L:contains(element)
    log:add("contains(" .. element .. ")")
    return __K2L_List.contains(self, element)
end

function L:isEmpty()
    log:add("isEmpty")
    return __K2L_List.isEmpty(self)
end

function L:indexOf(element)
    log:add("indexOf")
    return __K2L_List.indexOf(self, element)
end

function L:listIterator()
    log:add("listIterator")
    return __K2L_JdkCollections.listIterator(self)
end

function L:listIteratorAt(index)
    log:add("listIterator(" .. index .. ")")
    return __K2L_JdkCollections.listIterator(self, index)
end

__K2L_HonorOverrides(L, __K2L_List)
local S = __K2L_Class("S", __K2L_HashSet)
__K2L_ClassInfo(S, "S", "S", "class")

function S:____init()
    __K2L_HashSet.____init(self, __K2L_ReadOnlyListOf(1, 2, 3))
end

function S:getSize()
    log:add("size")
    return rawget(self, "____size") or self.size
end

function S:iterator()
    log:add("iterator")
    return __K2L_HashSet.iterator(self)
end

function S:contains(element)
    log:add("contains(" .. element .. ")")
    return __K2L_HashSet.contains(self, element)
end

function S:isEmpty()
    log:add("isEmpty")
    return __K2L_HashSet.isEmpty(self)
end

__K2L_HonorOverrides(S, __K2L_HashSet)
local M = __K2L_Class("M", __K2L_HashMap)
__K2L_ClassInfo(M, "M", "M", "class")

function M:____init()
    __K2L_HashMap.____init(self, __K2L_ReadOnlyMapOf(__K2L_Pair.new(1, "a"), __K2L_Pair.new(2, "b")))
end

function M:getSize()
    log:add("size")
    return rawget(self, "____size") or self.size
end

function M:get(key)
    log:add("get(" .. key .. ")")
    return __K2L_HashMap.get(self, key)
end

function M:containsKey(key)
    log:add("containsKey(" .. key .. ")")
    return __K2L_HashMap.containsKey(self, key)
end

function M:getEntries()
    log:add("entries")
    return __K2L_HashMap.getEntries(self)
end

function M:getKeys()
    log:add("keys")
    return __K2L_HashMap.getKeys(self)
end

function M:getValues()
    log:add("values")
    return __K2L_HashMap.getValues(self)
end

function M:isEmpty()
    log:add("isEmpty")
    return __K2L_HashMap.isEmpty(self)
end

__K2L_PropertyOverride(M, "entries", "getEntries")
__K2L_PropertyOverride(M, "keys", "getKeys")
__K2L_PropertyOverride(M, "values", "getValues")
__K2L_HonorOverrides(M, __K2L_HashMap)

local ____lambda_1 = function(it) return it * 2 end
local ____lambda_2 = function(it) return it > 1 end
local ____lambda_3 = function(it) return it > 2 end
local ____lambda_4 = function(it) return it * 2 end
local ____lambda_5 = function()
    return S.new():removeAll(__K2L_SingletonListOf(1))
end
local ____lambda_6 = function()
    return S.new():retainAll(__K2L_SingletonListOf(1))
end
local ____lambda_7 = function(it) return it.key end
local ____lambda_8 = function(it) return it.key > 1 end
local ____lambda_9 = function() return "z" end
local ____lambda_10 = function() return "z" end
local ____lambda_11 = function(it) return it.value end
local ____lambda_12 = function(it) return it.key > 1 end
local ____lambda_13 = function(it) return it.key end
local ____lambda_14 = function(a, b) return a .. b end
local ____lambda_15 = function() return M.new():merge(1, "x", ____lambda_14) end
local ____lambda_16 = function() return M.new():putIfAbsent(1, "x") end
local ____lambda_17 = function(it) return "x" end
local ____lambda_18 = function()
    return M.new():computeIfAbsent(1, ____lambda_17)
end
local function main()
    local l = L.new()
    op("l toString", function() return __K2L_Str(l) end)
    op("l str", function() return __K2L_Str(l) end)
    op("l map", function() return l:map(____lambda_1) end)
    op("l filter", function() return l:filter(____lambda_2) end)
    op("l for", function()
        local s = 0
        local ____items, ____n = l:____array()
        for ____i = 1, ____n do
            local x = ____items[____i]
            s = s + x
        end
        return s
    end)
    op("l forEach", function()
        local s = 0
        local ____items_1, ____n_1 = l:____array()
        for ____i_1 = 1, ____n_1 do
            local it = ____items_1[____i_1]
            s = s + it
        end
        return s
    end)
    op("l isEmpty", function() return l:isEmpty() end)
    op("l isNotEmpty", function() return l:isNotEmpty() end)
    op("l containsAll", function()
        return l:containsAll(__K2L_ReadOnlyListOf(1, 2))
    end)
    op("l contains", function() return l:contains(2) end)
    op("l equals", function()
        return l:equals(__K2L_ReadOnlyListOf(1, 2, 3))
    end)
    op("l equals2", function()
        return __K2L_Equals(__K2L_ReadOnlyListOf(1, 2, 3), l)
    end)
    op("l hashCode", function() return l:hashCode() end)
    op("l sum", function() return l:sum() end)
    op("l first", function() return l:first() end)
    op("l last", function() return l:last() end)
    op("l joinToString", function() return l:joinToString() end)
    op("l toList", function() return l:toList() end)
    op("l toMutableList", function() return l:toMutableList() end)
    op("l toSet", function() return l:toSet() end)
    op("l indexOf", function() return l:indexOf(2) end)
    op("l sorted", function() return l:sorted() end)
    op("l reversed", function() return l:reversed() end)
    op("l count", function() return l:count() end)
    op("l any", function() return l:any(____lambda_3) end)
    op("l getOrNull", function() return l:getOrNull(1) end)
    op("l elementAt", function() return l:elementAt(1) end)
    op("l addAll to", function()
        local ____value = __K2L_List.new()
        ____value:addAll(l)
        return ____value
    end)
    op("l ArrayList(l)", function() return l:toMutableList() end)
    op("l HashSet(l)", function() return __K2L_HashSet.new(l) end)
    op("l subList", function() return __K2L_Str(l:subList(0, 2)) end)
    op("l remove", function() return l:remove(5) end)
    op("l size", function() return l:getSize() end)
    op("l max", function() return l:max() end)
    op("l take", function() return l:take(2) end)
    op("l drop", function() return l:drop(1) end)
    op("l zip", function() return l:zip(__K2L_SingletonListOf(1)) end)
    op("l withIndex", function() return l:withIndex():toList() end)
    op("l asSequence", function() return __K2L_AsSequence(l):toList() end)
    op("l plus", function() return l:plus(4) end)
    op("l lastIndex", function() return l:getLastIndex() end)
    op("l indices", function() return l:getIndices() end)
    op("l single", function()
        local ____value_1 = __K2L_SingletonListOf(1)
        return l:singleOrNull()
    end)
    local s = S.new()
    op("s toString", function() return __K2L_Str(s) end)
    op("s map", function() return s:map(____lambda_4) end)
    op("s for", function()
        local t = 0
        local ____items_2, ____n_2 = s:____array()
        for ____i_2 = 1, ____n_2 do
            local x = ____items_2[____i_2]
            t = t + x
        end
        return t
    end)
    op("s isEmpty", function() return s:isEmpty() end)
    op("s containsAll", function()
        return s:containsAll(__K2L_ReadOnlyListOf(1, 2))
    end)
    op("s equals", function() return s:equals(__K2L_ReadOnlySetOf(1, 2, 3)) end)
    op("s equals2", function()
        return __K2L_Equals(__K2L_ReadOnlySetOf(1, 2, 3), s)
    end)
    op("s hashCode", function() return s:hashCode() end)
    op("s toList", function() return s:toList() end)
    op("s first", function() return s:first() end)
    op("s count", function() return s:count() end)
    op("s joinToString", function() return s:joinToString() end)
    op("s addAll to", function()
        local ____value_2 = __K2L_List.new()
        ____value_2:addAll(s)
        return ____value_2
    end)
    op("s removeAll", ____lambda_5)
    op("s retainAll", ____lambda_6)
    local m = M.new()
    op("m toString", function() return __K2L_Str(m) end)
    op("m for", function()
        local t = 0
        local ____keys, ____values, ____n_3 = m:____arrays()
        for ____i_3 = 1, ____n_3 do
            local k, _ = ____keys[____i_3], ____values[____i_3]
            t = t + k
        end
        return t
    end)
    op("m forEach2", function()
        local t = 0
        local ____items_3, ____n_4 = m:____entryArray()
        for ____i_4 = 1, ____n_4 do
            local ____entry = ____items_3[____i_4]
            do
                local k = ____entry.key
                t = t + k
            end
        end
        return t
    end)
    op("m forEachkv", function()
        local t = 0
        for k, _ in m:iter(true) do
            t = t + k
        end
        return t
    end)
    op("m keys", function() return __K2L_Str(m:getKeys()) end)
    op("m map", function() return m:map(____lambda_7) end)
    op("m filter", function() return m:filter(____lambda_8) end)
    op("m equals", function()
        return m:equals(__K2L_ReadOnlyMapOf(__K2L_Pair.new(1, "a"), __K2L_Pair.new(2, "b")))
    end)
    op("m equals2", function()
        return __K2L_Equals(__K2L_ReadOnlyMapOf(__K2L_Pair.new(1, "a"), __K2L_Pair.new(2, "b")), m)
    end)
    op("m hashCode", function() return m:hashCode() end)
    op("m isEmpty", function() return m:isEmpty() end)
    op("m getValue", function() return m:getValue(1) end)
    op("m getOrDefault", function() return m:getOrDefault(1, "z") end)
    op("m getOrElse", function() return m:getOrElse(1, ____lambda_9) end)
    op("m getOrPut", function() return m:getOrPut(1, ____lambda_10) end)
    op("m contains", function() return m:containsKey(1) end)
    op("m containsValue", function() return m:containsValue("a") end)
    op("m toList", function() return m:toList() end)
    op("m toMap", function() return m:toMap() end)
    op("m HashMap(m)", function() return __K2L_HashMap.new(m) end)
    op("m putAll to", function()
        local ____value_3 = __K2L_HashMap.new()
        ____value_3:putAll(m)
        return ____value_3
    end)
    op("m mapValues", function() return m:mapValues(____lambda_11) end)
    op("m count", function() return m:count() end)
    op("m any", function() return m:any(____lambda_12) end)
    op("m size", function() return m:getSize() end)
    op("m entries size", function() return m:getEntries().size end)
    op("m keys size", function() return m:getKeys().size end)
    op("m plus", function() return m:plus(__K2L_Pair.new(3, "c")) end)
    op("m toSortedMap", function() return m:toSortedMap() end)
    op("m maxBy", function() return m:getEntries():maxBy(____lambda_13) end)
    op("m isNotEmpty", function() return m:isNotEmpty() end)
    op("m orEmpty", function() return m or __K2L_ReadOnlyMapOf() end)
    op("m merge", ____lambda_15)
    op("m putIfAbsent", ____lambda_16)
    op("m computeIfAbsent", ____lambda_18)
end

__K2L_DeepMain(main)
return {log = log, op = op, L = L, S = S, M = M}
