local ____lualib = require("lualib_bundle")
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_CompareValues = ____lualib.__K2L_CompareValues
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Deque = ____lualib.__K2L_Deque
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_FunctionRef = ____lualib.__K2L_FunctionRef
local __K2L_HonorOverrides = ____lualib.__K2L_HonorOverrides
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_LinkedList = ____lualib.__K2L_LinkedList
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PriorityQueue = ____lualib.__K2L_PriorityQueue
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_ReverseOrder = ____lualib.__K2L_ReverseOrder
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_SortedMap = ____lualib.__K2L_SortedMap
local __K2L_SortedSet = ____lualib.__K2L_SortedSet
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Unit = ____lualib.__K2L_Unit

local ByLength, MaxFirst
local log = __K2L_ListOf()

local function l(s)
    log:add(s)
end

local function show(what, f)
    log:clear()
    local r
    local ____ok, ____result = __K2L_DeepPcall(function()
        r = f()
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_Exception) then
            local e = ____error
            r = __K2L_JavaClass(__K2L_KClassOfValue(e)).simpleName or ""
        else
            error(____error, 0)
        end
    end
    print(what .. " -> " .. __K2L_Str(r) .. " " .. __K2L_Str(log))
end

local PQ = __K2L_Class("PQ", __K2L_PriorityQueue)
__K2L_ClassInfo(PQ, "PQ", "PQ", "class")

function PQ:____init()
    __K2L_PriorityQueue.____init(self)
end

function PQ:add(element)
    l("add")
    return __K2L_PriorityQueue.add(self, element)
end

function PQ:offer(e)
    l("offer")
    return __K2L_PriorityQueue.offer(self, e)
end

function PQ:poll()
    l("poll")
    return __K2L_PriorityQueue.poll(self)
end

function PQ:peek()
    l("peek")
    return __K2L_PriorityQueue.peek(self)
end

function PQ:remove(element)
    l("remove(e)")
    return __K2L_PriorityQueue.remove(self, element)
end

function PQ:addAll(elements)
    l("addAll")
    return __K2L_PriorityQueue.addAll(self, elements)
end

function PQ:clear()
    l("clear")
    __K2L_PriorityQueue.clear(self)
end

function PQ:contains(element)
    l("contains")
    return __K2L_PriorityQueue.contains(self, element)
end

function PQ:removeAll(elements)
    l("removeAll")
    return __K2L_PriorityQueue.removeAll(self, elements)
end

__K2L_HonorOverrides(PQ, __K2L_PriorityQueue)
local AD = __K2L_Class("AD", __K2L_Deque)
__K2L_ClassInfo(AD, "AD", "AD", "class")

function AD:____init()
    __K2L_Deque.____init(self)
end

function AD:add(element)
    l("add")
    return __K2L_Deque.add(self, element)
end

function AD:addFirst(e)
    l("addFirst")
    __K2L_Deque.addFirst(self, e)
end

function AD:addLast(e)
    l("addLast")
    __K2L_Deque.addLast(self, e)
end

function AD:offerFirst(e)
    l("offerFirst")
    return __K2L_Deque.offerFirst(self, e)
end

function AD:offerLast(e)
    l("offerLast")
    return __K2L_Deque.offerLast(self, e)
end

function AD:pollFirst()
    l("pollFirst")
    return __K2L_Deque.pollFirst(self)
end

function AD:pollLast()
    l("pollLast")
    return __K2L_Deque.pollLast(self)
end

function AD:removeFirst()
    l("removeFirst")
    return __K2L_Deque.removeFirst(self)
end

function AD:removeLast()
    l("removeLast")
    return __K2L_Deque.removeLast(self)
end

function AD:peekFirst()
    l("peekFirst")
    return __K2L_Deque.peekFirst(self)
end

function AD:peekLast()
    l("peekLast")
    return __K2L_Deque.peekLast(self)
end

function AD:getFirst()
    l("getFirst")
    return __K2L_Deque.getFirst(self)
end

function AD:getLast()
    l("getLast")
    return __K2L_Deque.getLast(self)
end

function AD:addAll(elements)
    l("addAll")
    return __K2L_Deque.addAll(self, elements)
end

local LL = __K2L_Class("LL", __K2L_LinkedList)
__K2L_ClassInfo(LL, "LL", "LL", "class")

function LL:____init()
    __K2L_LinkedList.____init(self)
end

function LL:add(element)
    l("add")
    return __K2L_LinkedList.add(self, element)
end

function LL:addAt(index, element)
    l("add(i)")
    __K2L_LinkedList.addAt(self, index, element)
end

function LL:addFirst(e)
    l("addFirst")
    __K2L_LinkedList.addFirst(self, e)
end

function LL:addLast(e)
    l("addLast")
    __K2L_LinkedList.addLast(self, e)
end

function LL:removeFirst()
    l("removeFirst")
    return __K2L_LinkedList.removeFirst(self)
end

function LL:removeLast()
    l("removeLast")
    return __K2L_LinkedList.removeLast(self)
end

function LL:poll()
    l("poll")
    return __K2L_LinkedList.poll(self)
end

function LL:pollFirst()
    l("pollFirst")
    return __K2L_LinkedList.pollFirst(self)
end

function LL:offer(e)
    l("offer")
    return __K2L_LinkedList.offer(self, e)
end

function LL:get(index)
    l("get")
    return __K2L_LinkedList.get(self, index)
end

function LL:removeAt(index)
    l("removeAt")
    return __K2L_LinkedList.removeAt(self, index)
end

function LL:addAll(elements)
    l("addAll")
    return __K2L_LinkedList.addAll(self, elements)
end

function LL:addAllAt(index, elements)
    l("addAll(i)")
    return __K2L_LinkedList.addAllAt(self, index, elements)
end

function LL:peek()
    l("peek")
    return __K2L_LinkedList.peek(self)
end

function LL:getFirst()
    l("getFirst")
    return __K2L_LinkedList.getFirst(self)
end

__K2L_HonorOverrides(LL, __K2L_LinkedList)
local TM = __K2L_Class("TM", __K2L_SortedMap)
__K2L_ClassInfo(TM, "TM", "TM", "class")

function TM:____init()
    __K2L_SortedMap.____init(self)
end

function TM:put(key, value)
    l("put " .. key)
    return __K2L_SortedMap.put(self, key, value)
end

function TM:get(key)
    l("get")
    return __K2L_SortedMap.get(self, key)
end

function TM:putAll(from)
    l("putAll")
    __K2L_SortedMap.putAll(self, from)
end

function TM:containsKey(key)
    l("containsKey")
    return __K2L_SortedMap.containsKey(self, key)
end

function TM:remove(key)
    l("remove")
    return __K2L_SortedMap.remove(self, key)
end

function TM:firstKey()
    l("firstKey")
    return __K2L_SortedMap.firstKey(self)
end

__K2L_HonorOverrides(TM, __K2L_SortedMap)
local TS = __K2L_Class("TS", __K2L_SortedSet)
__K2L_ClassInfo(TS, "TS", "TS", "class")

function TS:____init()
    __K2L_SortedSet.____init(self)
end

function TS:add(element)
    l("add " .. element)
    return __K2L_SortedSet.add(self, element)
end

function TS:addAll(elements)
    l("addAll")
    return __K2L_SortedSet.addAll(self, elements)
end

function TS:remove(element)
    l("remove")
    return __K2L_SortedSet.remove(self, element)
end

function TS:contains(element)
    l("contains")
    return __K2L_SortedSet.contains(self, element)
end

function TS:first()
    l("first")
    return __K2L_SortedSet.first(self)
end

function TS:pollFirst()
    l("pollFirst")
    return __K2L_SortedSet.pollFirst(self)
end

__K2L_HonorOverrides(TS, __K2L_SortedSet)

local ____lambda_1 = function(it) return it > 100 end
local ____lambda_2 = function() return 6 end
local ____lambda_3 = function(____p1, ____p2) return ____p1 + ____p2 end
local ____lambda_4 = function(_, v) return __K2L_NotNull(v) + 1 end
local ____lambda_5 = function(it) return 7 end
local ____lambda_6 = function(it) return it.key end
local function main()
    local pq = PQ.new()
    show("pq.add", function() return pq:add(3) end)
    show("pq.offer", function() return pq:offer(1) end)
    show("pq.addAll", function() return pq:addAll(__K2L_ReadOnlyListOf(5, 2)) end)
    show("pq.remove()", function() return pq:removeHead() end)
    show("pq.element()", function() return pq:element() end)
    show("pq.remove(e)", function() return pq:remove(5) end)
    show("pq.toString", function() return __K2L_Str(pq) end)
    show("pq.contains", function() return pq:contains(3) end)
    show("pq.removeAll", function() return pq:removeAll(__K2L_SingletonListOf(3)) end)
    show("pq.removeIf", function() return pq:removeIf(____lambda_1) end)
    show("pq.isEmpty", function() return pq:isEmpty() end)
    show("pq.toList", function() return pq:toList() end)
    show("pq.clear", function()
        pq:clear()
        return __K2L_Unit
    end)
    show("pq.size", function() return pq.size end)
    local ad = AD.new()
    show("ad.add", function() return ad:add(1) end)
    show("ad.addFirst", function()
        ad:addFirst(0)
        return __K2L_Unit
    end)
    show("ad.addLast", function()
        ad:addLast(2)
        return __K2L_Unit
    end)
    show("ad.offer", function() return ad:offer(3) end)
    show("ad.offerFirst", function() return ad:offerFirst(-1) end)
    show("ad.push", function()
        ad:push(-2)
        return __K2L_Unit
    end)
    show("ad.addAll", function() return ad:addAll(__K2L_ReadOnlyListOf(7, 8)) end)
    show("ad.pop", function() return ad:pop() end)
    show("ad.poll", function() return ad:poll() end)
    show("ad.remove()", function() return ad:removeHead() end)
    show("ad.removeFirst", function() return ad:removeFirst() end)
    show("ad.removeLast", function() return ad:removeLast() end)
    show("ad.peek", function() return ad:peek() end)
    show("ad.element", function() return ad:element() end)
    show("ad.first", function() return ad:first() end)
    show("ad.last", function() return ad:last() end)
    show("ad.toString", function() return __K2L_Str(ad) end)
    show("ad.size", function() return ad.size end)
    show("ad.contains", function() return ad:contains(2) end)
    show("ad.pollLast", function() return ad:pollLast() end)
    show("ad.descending", function()
        return __K2L_AsSequence(ad:descendingIterator()):toList()
    end)
    show("ad.clear", function()
        ad:clear()
        return __K2L_Unit
    end)
    show("ad.removeFirst empty", function() return ad:removeFirst() end)
    local ll = LL.new()
    show("ll.add", function() return ll:add(1) end)
    show("ll.add(i)", function()
        ll:addAt(0, 0)
        return __K2L_Unit
    end)
    show("ll.addFirst", function()
        ll:addFirst(-1)
        return __K2L_Unit
    end)
    show("ll.push", function()
        ll:push(-2)
        return __K2L_Unit
    end)
    show("ll.offer", function() return ll:offer(2) end)
    show("ll.offerFirst", function() return ll:offerFirst(-3) end)
    show("ll.offerLast", function() return ll:offerLast(3) end)
    show("ll.addAll", function() return ll:addAll(__K2L_ReadOnlyListOf(7, 8)) end)
    show("ll.pop", function() return ll:pop() end)
    show("ll.poll", function() return ll:poll() end)
    show("ll.remove()", function() return ll:removeHead() end)
    show("ll.removeLast", function() return ll:removeLast() end)
    show("ll.peek", function() return ll:peek() end)
    show("ll.element", function() return ll:element() end)
    show("ll.get", function() return ll:get(1) end)
    show("ll.toString", function() return __K2L_Str(ll) end)
    show("ll.removeAt", function() return ll:removeAt(0) end)
    show("ll.indexOf", function() return ll:indexOf(7) end)
    show("ll.contains", function() return ll:contains(7) end)
    show("ll.equals", function()
        return ll:equals(__K2L_ReadOnlyListOf(2, 3, 7))
    end)
    show("ll.sum", function() return ll:sum() end)
    show("ll.clear", function()
        ll:clear()
        return __K2L_Unit
    end)
    local tm = TM.new()
    show("tm.put", function() return tm:put("b", 2) end)
    show("tm.set", function()
        tm:set("a", 1)
        return __K2L_Unit
    end)
    show("tm.putAll", function()
        tm:putAll(__K2L_ReadOnlyMapOf(__K2L_Pair.new("d", 4), __K2L_Pair.new("c", 3)))
        return __K2L_Unit
    end)
    show("tm.putIfAbsent", function() return tm:putIfAbsent("e", 5) end)
    show("tm.getOrPut", function() return tm:getOrPut("f", ____lambda_2) end)
    show("tm.merge", function()
        return tm:merge("a", 10, __K2L_FunctionRef.new("plus", "kotlin/Int.plus(kotlin.Int)", ____lambda_3))
    end)
    show("tm.compute", function() return tm:compute("a", ____lambda_4) end)
    show("tm.computeIfAbsent", function() return tm:computeIfAbsent("g", ____lambda_5) end)
    show("tm.get", function() return tm:get("a") end)
    show("tm.getValue", function() return tm:getValue("a") end)
    show("tm.contains", function() return tm:containsKey("a") end)
    show("tm.getOrDefault", function() return tm:getOrDefault("z", 0) end)
    show("tm.toString", function() return __K2L_Str(tm) end)
    show("tm.firstKey", function() return tm:firstKey() end)
    show("tm.firstEntry", function() return tm:firstEntry().key end)
    show("tm.remove", function() return tm:remove("g") end)
    show("tm.for", function()
        local ____keys, ____values, ____n = tm:____arrays()
        for ____i = 1, ____n do
            local k, v = ____keys[____i], ____values[____i]
        end
        return __K2L_Unit
    end)
    show("tm.forEach", function()
        local ____items, ____n_1 = tm:____entryArray()
        for ____i_1 = 1, ____n_1 do
            local ____entry = ____items[____i_1]
            do
                local k, v = ____entry.key, ____entry.value
            end
        end
        return __K2L_Unit
    end)
    show("tm.keys", function() return tm:getKeys():toList() end)
    show("tm.map", function() return tm:map(____lambda_6) end)
    show("tm.equals", function()
        return tm:equals(__K2L_SingletonMapOf(__K2L_Pair.new("a", 12)))
    end)
    show("tm.size", function() return tm.size end)
    show("tm.pollFirst", function() return tm:pollFirstEntry().key end)
    show("tm.headMap", function() return tm:headMap("d") end)
    local ts = TS.new()
    show("ts.add", function() return ts:add(5) end)
    show("ts.addAll", function()
        return ts:addAll(__K2L_ReadOnlyListOf(3, 9, 1))
    end)
    show("ts.plusAssign", function()
        ts:addAll(__K2L_SingletonListOf(4))
        return __K2L_Unit
    end)
    show("ts.contains", function() return ts:contains(3) end)
    show("ts.remove", function() return ts:remove(9) end)
    show("ts.first", function() return ts:first() end)
    show("ts.last", function() return ts:last() end)
    show("ts.pollFirst", function() return ts:pollFirst() end)
    show("ts.toString", function() return __K2L_Str(ts) end)
    show("ts.size", function() return ts.size end)
    show("ts.isEmpty", function() return ts:isEmpty() end)
    show("ts.toList", function() return ts:toList() end)
    show("ts.equals", function()
        return ts:equals(__K2L_ReadOnlySetOf(3, 4, 5))
    end)
    show("ts.removeAll", function() return ts:removeAll(__K2L_SingletonListOf(4)) end)
    show("ts.ceiling", function() return ts:ceiling(4) end)
    show("ts.headSet", function() return ts:headSet(5) end)
    show("ts.descendingSet", function() return ts:descendingSet() end)
    show("ts.clear", function()
        ts:clear()
        return __K2L_Unit
    end)
    log:clear()
    local ____object = __K2L_Class("MainKt$main$fromList$1", __K2L_SortedSet)
    __K2L_ClassInfo(____object, nil, "MainKt$main$fromList$1", "class", false)
    function ____object:____init()
        __K2L_SortedSet.____init(self, __K2L_ReadOnlyListOf(2, 1))
    end
    function ____object:add(element)
        l("ctor add " .. element)
        return __K2L_SortedSet.add(self, element)
    end
    ____object:____init()
    local fromList = ____object
    print("TreeSet(coll) " .. __K2L_Str(fromList) .. " " .. __K2L_Str(log))
    log:clear()
    local ____object_1 = __K2L_Class("MainKt$main$fromMap$1", __K2L_SortedMap)
    __K2L_ClassInfo(____object_1, nil, "MainKt$main$fromMap$1", "class", false)
    function ____object_1:____init()
        __K2L_SortedMap.____init(self, __K2L_ReadOnlyMapOf(__K2L_Pair.new("b", 1), __K2L_Pair.new("a", 2)))
    end
    function ____object_1:put(key, value)
        l("ctor put " .. key)
        return __K2L_SortedMap.put(self, key, value)
    end
    ____object_1:____init()
    local fromMap = ____object_1
    print("TreeMap(map) " .. __K2L_Str(fromMap) .. " " .. __K2L_Str(log))
    log:clear()
    local ____object_2 = __K2L_Class("MainKt$main$pqFrom$1", __K2L_PriorityQueue)
    __K2L_ClassInfo(____object_2, nil, "MainKt$main$pqFrom$1", "class", false)
    function ____object_2:____init()
        __K2L_PriorityQueue.____init(self, __K2L_ReadOnlyListOf(3, 1, 2))
    end
    function ____object_2:add(element)
        l("ctor add")
        return __K2L_PriorityQueue.add(self, element)
    end
    ____object_2:____init()
    local pqFrom = ____object_2
    print("PQ(coll) " .. __K2L_Str(pqFrom) .. " " .. __K2L_Str(log))
    local ____value = ByLength.new()
    ____value:addAll(__K2L_ReadOnlyListOf("ccc", "a", "bb", "dd"))
    local ____arg = __K2L_Str(____value)
    local ____value_1 = MaxFirst.new()
    ____value_1:addAll(__K2L_ReadOnlyListOf(1, 5, 3))
    print(____arg .. " " .. __K2L_Str(____value_1:poll()))
    local ____object_3 = __K2L_Class("MainKt$main$dq$1", __K2L_Deque)
    __K2L_ClassInfo(____object_3, nil, "MainKt$main$dq$1", "class", false)
    function ____object_3:____init()
        __K2L_Deque.____init(self, __K2L_ReadOnlyListOf(1, 2))
    end
    function ____object_3:addLast(e)
        l("ctor addLast " .. e)
        __K2L_Deque.addLast(self, e)
    end
    ____object_3:____init()
    local dq = ____object_3
    print("ArrayDeque(coll) " .. __K2L_Str(dq) .. " " .. __K2L_Str(log))
end

ByLength = __K2L_Class("ByLength", __K2L_SortedSet)
__K2L_ClassInfo(ByLength, "ByLength", "ByLength", "class")

local ____lambda_7 = function(____a, ____b)
    local ____x, ____y = #____a, #____b
    if ____x ~= ____y then
        return ____x < ____y and -1 or 1
    end
    return 0
end
function ByLength:____init()
    __K2L_SortedSet.____init(self, ____lambda_7)
end

MaxFirst = __K2L_Class("MaxFirst", __K2L_PriorityQueue)
__K2L_ClassInfo(MaxFirst, "MaxFirst", "MaxFirst", "class")

function MaxFirst:____init()
    __K2L_PriorityQueue.____init(self, __K2L_ReverseOrder)
end

__K2L_DeepMain(main)
return {log = log, l = l, show = show, PQ = PQ, AD = AD, LL = LL, TM = TM, TS = TS, ByLength = ByLength, MaxFirst = MaxFirst}
