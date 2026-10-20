local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Deque = ____lualib.__K2L_Deque
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_HashSet = ____lualib.__K2L_HashSet
local __K2L_HonorOverrides = ____lualib.__K2L_HonorOverrides
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_LinkedList = ____lualib.__K2L_LinkedList
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PriorityQueue = ____lualib.__K2L_PriorityQueue
local __K2L_PropertyOverride = ____lualib.__K2L_PropertyOverride
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_Set = ____lualib.__K2L_Set
local __K2L_SortedMap = ____lualib.__K2L_SortedMap
local __K2L_SortedSet = ____lualib.__K2L_SortedSet
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

local LL = __K2L_Class("LL", __K2L_LinkedList)
__K2L_ClassInfo(LL, "LL", "LL", "class")

function LL:____init()
    __K2L_LinkedList.____init(self, __K2L_ReadOnlyListOf(1, 2, 3))
end

function LL:getSize()
    log:add("size")
    return rawget(self, "____size") or self.size
end

function LL:iterator()
    log:add("iterator")
    return __K2L_LinkedList.iterator(self)
end

function LL:get(index)
    log:add("get(" .. index .. ")")
    return __K2L_LinkedList.get(self, index)
end

function LL:contains(element)
    log:add("contains")
    return __K2L_LinkedList.contains(self, element)
end

function LL:indexOf(element)
    log:add("indexOf")
    return __K2L_LinkedList.indexOf(self, element)
end

__K2L_HonorOverrides(LL, __K2L_LinkedList)
local TS = __K2L_Class("TS", __K2L_SortedSet)
__K2L_ClassInfo(TS, "TS", "TS", "class")

function TS:____init()
    __K2L_SortedSet.____init(self, __K2L_ReadOnlyListOf(3, 1, 2))
end

function TS:getSize()
    log:add("size")
    return rawget(self, "____size") or self.size
end

function TS:iterator()
    log:add("iterator")
    return __K2L_SortedSet.iterator(self)
end

function TS:contains(element)
    log:add("contains")
    return __K2L_SortedSet.contains(self, element)
end

__K2L_HonorOverrides(TS, __K2L_SortedSet)
local LS = __K2L_Class("LS", __K2L_Set)
__K2L_ClassInfo(LS, "LS", "LS", "class")

function LS:____init()
    __K2L_Set.____init(self, __K2L_ReadOnlyListOf(1, 2, 3))
end

function LS:getSize()
    log:add("size")
    return rawget(self, "____size") or self.size
end

function LS:iterator()
    log:add("iterator")
    return __K2L_Set.iterator(self)
end

function LS:isEmpty()
    log:add("isEmpty")
    return __K2L_Set.isEmpty(self)
end

__K2L_HonorOverrides(LS, __K2L_Set)
local PQ = __K2L_Class("PQ", __K2L_PriorityQueue)
__K2L_ClassInfo(PQ, "PQ", "PQ", "class")

function PQ:____init()
    __K2L_PriorityQueue.____init(self, __K2L_ReadOnlyListOf(3, 1, 2))
end

function PQ:getSize()
    log:add("size")
    return rawget(self, "____size") or self.size
end

function PQ:iterator()
    log:add("iterator")
    return __K2L_PriorityQueue.iterator(self)
end

__K2L_HonorOverrides(PQ, __K2L_PriorityQueue)
local JD = __K2L_Class("JD", __K2L_Deque)
__K2L_ClassInfo(JD, "JD", "JD", "class")

function JD:____init()
    __K2L_Deque.____init(self, __K2L_ReadOnlyListOf(1, 2, 3))
end

function JD:getSize()
    log:add("size")
    return rawget(self, "____size") or self.size
end

function JD:iterator()
    log:add("iterator")
    return __K2L_Deque.iterator(self)
end

__K2L_HonorOverrides(JD, __K2L_Deque)
local LM = __K2L_Class("LM", __K2L_Map)
__K2L_ClassInfo(LM, "LM", "LM", "class")

function LM:____init()
    __K2L_Map.____init(self, __K2L_ReadOnlyMapOf(__K2L_Pair.new(1, "a"), __K2L_Pair.new(2, "b")))
end

function LM:getSize()
    log:add("size")
    return rawget(self, "____size") or self.size
end

function LM:getEntries()
    log:add("entries")
    return __K2L_Map.getEntries(self)
end

function LM:get(key)
    log:add("get")
    return __K2L_Map.get(self, key)
end

__K2L_PropertyOverride(LM, "entries", "getEntries")
__K2L_HonorOverrides(LM, __K2L_Map)
local TM = __K2L_Class("TM", __K2L_SortedMap)
__K2L_ClassInfo(TM, "TM", "TM", "class")

function TM:____init()
    __K2L_SortedMap.____init(self, __K2L_ReadOnlyMapOf(__K2L_Pair.new(2, "b"), __K2L_Pair.new(1, "a")))
end

function TM:getSize()
    log:add("size")
    return rawget(self, "____size") or self.size
end

function TM:getEntries()
    log:add("entries")
    return __K2L_SortedMap.getEntries(self)
end

function TM:containsKey(key)
    log:add("containsKey")
    return __K2L_SortedMap.containsKey(self, key)
end

__K2L_PropertyOverride(TM, "entries", "getEntries")
__K2L_HonorOverrides(TM, __K2L_SortedMap)

local ____lambda_1 = function(it) return it + 1 end
local ____lambda_2 = function(it) return it > 1 end
local ____lambda_3 = function(it) return it > 2 end
local function coll(label, c)
    op(label .. " toString", function() return __K2L_Str(c) end)
    op(label .. " map", function() return c:map(____lambda_1) end)
    op(label .. " filter", function() return c:filter(____lambda_2) end)
    op(label .. " for", function()
        local s = 0
        local ____items, ____n = c:____array()
        for ____i = 1, ____n do
            local x = ____items[____i]
            s = s + x
        end
        return s
    end)
    op(label .. " isEmpty", function() return c:isEmpty() end)
    op(label .. " contains", function() return c:contains(2) end)
    op(label .. " containsAll", function()
        return c:containsAll(__K2L_ReadOnlyListOf(1, 3))
    end)
    op(label .. " first", function() return c:first() end)
    if not __K2L_InstanceOf(c, __K2L_SortedSet) then
        op(label .. " last", function() return c:last() end)
    end
    op(label .. " toList", function() return c:toList() end)
    op(label .. " toSet", function() return c:toSet() end)
    op(label .. " sorted", function() return c:sorted() end)
    op(label .. " count", function() return c:count() end)
    op(label .. " any", function() return c:any(____lambda_3) end)
    op(label .. " sum", function() return c:sum() end)
    if not __K2L_InstanceOf(c, __K2L_PriorityQueue) and not __K2L_InstanceOf(c, __K2L_Deque) then
        op(label .. " hashCode", function() return __K2L_Hash(c) end)
    end
    op(label .. " eq", function() return __K2L_Equals(c, c:toList()) end)
    op(label .. " eq set", function() return __K2L_Equals(c, c:toSet()) end)
    op(label .. " ArrayList", function() return c:toMutableList() end)
    op(label .. " HashSet", function() return __K2L_HashSet.new(c) end)
    op(label .. " plus", function() return c:plus(9) end)
    op(label .. " joinToString", function() return c:joinToString() end)
    op(label .. " single", function() return c:singleOrNull() end)
end

local ____lambda_4 = function(it) return it.key end
local ____lambda_5 = function(it) return it.key > 1 end
local ____lambda_6 = function() return "z" end
local function maps(label, m)
    op(label .. " toString", function() return __K2L_Str(m) end)
    op(label .. " for", function()
        local s = 0
        local ____keys, ____values, ____n_1 = m:____arrays()
        for ____i_1 = 1, ____n_1 do
            local k, _ = ____keys[____i_1], ____values[____i_1]
            s = s + k
        end
        return s
    end)
    op(label .. " map", function() return m:map(____lambda_4) end)
    op(label .. " filter", function() return m:filter(____lambda_5) end)
    op(label .. " eq", function()
        return __K2L_Equals(m, __K2L_ReadOnlyMapOf(__K2L_Pair.new(1, "a"), __K2L_Pair.new(2, "b")))
    end)
    op(label .. " eq2", function()
        return __K2L_Equals(__K2L_ReadOnlyMapOf(__K2L_Pair.new(1, "a"), __K2L_Pair.new(2, "b")), m)
    end)
    op(label .. " hashCode", function() return __K2L_Hash(m) end)
    op(label .. " getOrElse", function() return m:getOrElse(1, ____lambda_6) end)
    op(label .. " toList", function() return m:toList() end)
    op(label .. " HashMap", function() return __K2L_HashMap.new(m) end)
    op(label .. " count", function() return m:count() end)
    op(label .. " containsKey", function() return m:containsKey(1) end)
    op(label .. " getValue", function() return m:getValue(1) end)
    op(label .. " keys", function() return __K2L_Str(m:getKeys()) end)
    op(label .. " values", function() return __K2L_Str(m:getValues()) end)
    op(label .. " isEmpty", function() return m:isEmpty() end)
end

local function main()
    coll("LL", LL.new())
    coll("TS", TS.new())
    coll("LS", LS.new())
    coll("PQ", PQ.new())
    coll("JD", JD.new())
    maps("LM", LM.new())
    maps("TM", TM.new())
    local ll = LL.new()
    op("LL getOrNull", function() return ll:getOrNull(1) end)
    op("LL indexOf", function() return ll:indexOf(2) end)
    op("LL remove", function() return ll:remove(5) end)
    local pq = PQ.new()
    op("PQ isEmpty", function() return pq:isEmpty() end)
    op("PQ peek", function() return pq:peek() end)
end

__K2L_DeepMain(main)
return {log = log, op = op, LL = LL, TS = TS, LS = LS, PQ = PQ, JD = JD, LM = LM, TM = TM, coll = coll, maps = maps}
