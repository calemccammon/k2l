local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Deque = ____lualib.__K2L_Deque
local __K2L_DequeInterface = ____lualib.__K2L_DequeInterface
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_Iterable = ____lualib.__K2L_Iterable
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_JdkCollections = ____lualib.__K2L_JdkCollections
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_LinkedList = ____lualib.__K2L_LinkedList
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_PriorityQueue = ____lualib.__K2L_PriorityQueue
local __K2L_QueueInterface = ____lualib.__K2L_QueueInterface
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Set = ____lualib.__K2L_Set
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function t(name, f)
    local r
    local ____ok, ____result = __K2L_DeepPcall(function()
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

local ____lambda_1 = function() return __K2L_Deque.new():first() end
local function main()
    local d = __K2L_Deque.new(__K2L_ReadOnlyListOf(1, 2, 3))
    local a = d
    t("is", function()
        return tostring(__K2L_InstanceOf(a, __K2L_List)) .. " " .. tostring(__K2L_InstanceOf(a, __K2L_List) and not a.____readOnly) .. " " .. tostring(__K2L_InstanceOf(a, __K2L_Iterable) and a.size ~= nil) .. " " .. tostring(__K2L_InstanceOf(a, __K2L_Iterable) and a.size ~= nil and not a.____readOnly) .. " " .. tostring(__K2L_InstanceOf(a, __K2L_Iterable)) .. " " .. tostring(__K2L_InstanceOf(a, __K2L_Set))
    end)
    t("is queue", function()
        return tostring(__K2L_InstanceOf(a, __K2L_QueueInterface)) .. " " .. tostring(__K2L_InstanceOf(a, __K2L_DequeInterface)) .. " " .. tostring(__K2L_InstanceOf(a, __K2L_Deque)) .. " " .. tostring(__K2L_InstanceOf(a, __K2L_LinkedList)) .. " " .. tostring(__K2L_InstanceOf(a, __K2L_ArrayDeque))
    end)
    t("as list", function()
        if not __K2L_InstanceOf(a, __K2L_List) then
            __K2L_CastFail(a, "java.util.List", "kotlin.collections.List")
        end
        return a
    end)
    t("as mutable list", function()
        if not (__K2L_InstanceOf(a, __K2L_List) and not a.____readOnly) then
            __K2L_CastFail(a, "java.util.List", "kotlin.collections.MutableList")
        end
        return a
    end)
    t("as queue", function()
        if not __K2L_InstanceOf(a, __K2L_QueueInterface) then
            __K2L_CastFail(a, "java.util.Queue", "java.util.Queue")
        end
        return a:peek()
    end)
    t("eq", function()
        return tostring(__K2L_Equals(d, __K2L_ReadOnlyListOf(1, 2, 3))) .. " " .. tostring(__K2L_Equals(__K2L_ReadOnlyListOf(1, 2, 3), d)) .. " " .. tostring(__K2L_Equals(d:toList(), __K2L_ReadOnlyListOf(1, 2, 3))) .. " " .. tostring(__K2L_Equals(d, d))
    end)
    t("first empty", ____lambda_1)
    t("single", function() return d:single() end)
    t("ops", function()
        local ____out = {}
        local ____count = 0
        local ____items, ____n = d:____array()
        for ____i = 1, ____n do
            local it = ____items[____i]
            ____count = ____count + 1
            ____out[____count] = it * 2
        end
        return __K2L_Str(__K2L_ListWrap(____out, ____count)) .. " " .. __K2L_Str(d:first()) .. " " .. __K2L_Str(d:last()) .. " " .. __K2L_Str(d:elementAt(1)) .. " " .. d:indexOf(2) .. " " .. tostring(d:contains(3)) .. " " .. d:sum()
    end)
    t("loop", function()
        local s = 0
        for ____i_1 = 1, d.size do
            local x = d[____i_1]
            s = s + x
        end
        return s
    end)
    t("toString", function() return __K2L_Str(d) end)
    t("unmodifiable", function()
        return __K2L_JavaClass(__K2L_KClassOfValue(__K2L_JdkCollections.unmodifiableCollection(d))).name
    end)
    local ll = __K2L_LinkedList.new(__K2L_SingletonListOf(1))
    t("linked", function()
        return tostring(__K2L_InstanceOf(ll, __K2L_List)) .. " " .. tostring(__K2L_InstanceOf(ll, __K2L_QueueInterface)) .. " " .. tostring(__K2L_InstanceOf(ll, __K2L_DequeInterface)) .. " " .. tostring(__K2L_InstanceOf(ll, __K2L_Deque))
    end)
    local kd = __K2L_ArrayDeque.new(__K2L_SingletonListOf(1))
    t("kotlin deque", function()
        return tostring(__K2L_InstanceOf(kd, __K2L_List)) .. " " .. tostring(__K2L_InstanceOf(kd, __K2L_QueueInterface)) .. " " .. tostring(__K2L_InstanceOf(kd, __K2L_DequeInterface)) .. " " .. tostring(__K2L_InstanceOf(kd, __K2L_ArrayDeque)) .. " " .. tostring(__K2L_InstanceOf(kd, __K2L_List) and not kd.____readOnly)
    end)
    local pq = __K2L_PriorityQueue.new(__K2L_SingletonListOf(1))
    t("pq", function()
        return tostring(__K2L_InstanceOf(pq, __K2L_QueueInterface)) .. " " .. tostring(__K2L_InstanceOf(pq, __K2L_DequeInterface)) .. " " .. tostring(__K2L_InstanceOf(pq, __K2L_List)) .. " " .. tostring(__K2L_InstanceOf(pq, __K2L_Iterable) and pq.size ~= nil) .. " " .. tostring(__K2L_InstanceOf(pq, __K2L_PriorityQueue))
    end)
    local al = __K2L_ListOf(1)
    t("arraylist", function()
        return tostring(__K2L_InstanceOf(al, __K2L_QueueInterface)) .. " " .. tostring(__K2L_InstanceOf(al, __K2L_DequeInterface)) .. " " .. tostring(__K2L_InstanceOf(al, __K2L_LinkedList)) .. " " .. tostring(__K2L_InstanceOf(al, __K2L_ArrayDeque)) .. " " .. tostring(__K2L_InstanceOf(al, __K2L_Deque))
    end)
end

__K2L_DeepMain(main)
return {t = t}
