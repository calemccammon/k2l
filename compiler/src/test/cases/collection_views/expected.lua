local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_HashMapOf = ____lualib.__K2L_HashMapOf
local __K2L_HashSetOf = ____lualib.__K2L_HashSetOf
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_Iterable = ____lualib.__K2L_Iterable
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_JdkCollections = ____lualib.__K2L_JdkCollections
local __K2L_KClassOfArray = ____lualib.__K2L_KClassOfArray
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListBase = ____lualib.__K2L_ListBase
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PriorityQueue = ____lualib.__K2L_PriorityQueue
local __K2L_PropertyOverride = ____lualib.__K2L_PropertyOverride
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_Set = ____lualib.__K2L_Set
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_SortedSetOf = ____lualib.__K2L_SortedSetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf

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

local Logged = __K2L_Class("Logged", __K2L_List)
__K2L_ClassInfo(Logged, "Logged", "Logged", "class")

function Logged:____init()
    __K2L_List.____init(self)
    self.log = __K2L_ListOf()
end

function Logged:addAt(index, element)
    self.log:add("add(" .. index .. ")")
    __K2L_List.addAt(self, index, element)
end

function Logged:removeAt(index)
    self.log:add("removeAt(" .. index .. ")")
    return __K2L_List.removeAt(self, index)
end

function Logged:set(index, element)
    self.log:add("set(" .. index .. ")")
    return __K2L_List.set(self, index, element)
end

local Fixed = __K2L_Class("Fixed", __K2L_ListBase)
__K2L_ClassInfo(Fixed, "Fixed", "Fixed", "class")
Fixed.____readOnly = true

function Fixed:____init(items)
    self.items = items
    self.____delegate_List = items
end

function Fixed:isEmpty()
    return self.____delegate_List:isEmpty()
end

function Fixed:contains(element)
    return self.____delegate_List:contains(element)
end

function Fixed:iterator()
    return __K2L_IteratorOf(self.____delegate_List)
end

function Fixed:containsAll(elements)
    return self.____delegate_List:containsAll(elements)
end

function Fixed:get(index)
    return self.____delegate_List:get(index)
end

function Fixed:indexOf(element)
    return self.____delegate_List:indexOf(element)
end

function Fixed:lastIndexOf(element)
    return self.____delegate_List:lastIndexOf(element)
end

function Fixed:listIterator()
    return __K2L_JdkCollections.listIterator(self.____delegate_List)
end

function Fixed:listIteratorAt(index)
    return __K2L_JdkCollections.listIterator(self.____delegate_List, index)
end

function Fixed:subList(fromIndex, toIndex)
    return self.____delegate_List:subList(fromIndex, toIndex)
end

function Fixed:getSize()
    return self.____delegate_List.size
end

__K2L_PropertyOverride(Fixed, "size", "getSize")
local Growing = __K2L_Class("Growing", __K2L_ListBase)
__K2L_ClassInfo(Growing, "Growing", "Growing", "class")

function Growing:____init(items)
    self.items = items
    self.____delegate_MutableList = items
end

function Growing:add(element)
    return self.____delegate_MutableList:add(element)
end

function Growing:addAt(index, element)
    return self.____delegate_MutableList:addAt(index, element)
end

function Growing:remove(element)
    return self.____delegate_MutableList:remove(element)
end

function Growing:addAll(elements)
    return self.____delegate_MutableList:addAll(elements)
end

function Growing:addAllAt(index, elements)
    return self.____delegate_MutableList:addAllAt(index, elements)
end

function Growing:removeAll(elements)
    return self.____delegate_MutableList:removeAll(elements)
end

function Growing:retainAll(elements)
    return self.____delegate_MutableList:retainAll(elements)
end

function Growing:clear()
    return self.____delegate_MutableList:clear()
end

function Growing:set(index, element)
    return self.____delegate_MutableList:set(index, element)
end

function Growing:removeAt(index)
    return self.____delegate_MutableList:removeAt(index)
end

function Growing:listIterator()
    return __K2L_JdkCollections.listIterator(self.____delegate_MutableList)
end

function Growing:listIteratorAt(index)
    return __K2L_JdkCollections.listIterator(self.____delegate_MutableList, index)
end

function Growing:subList(fromIndex, toIndex)
    return self.____delegate_MutableList:subList(fromIndex, toIndex)
end

function Growing:getSize()
    return self.____delegate_MutableList.size
end

__K2L_PropertyOverride(Growing, "size", "getSize")

function Growing:isEmpty()
    return self.____delegate_MutableList:isEmpty()
end

function Growing:contains(element)
    return self.____delegate_MutableList:contains(element)
end

function Growing:iterator()
    return __K2L_IteratorOf(self.____delegate_MutableList)
end

function Growing:containsAll(elements)
    return self.____delegate_MutableList:containsAll(elements)
end

function Growing:get(index)
    return self.____delegate_MutableList:get(index)
end

function Growing:indexOf(element)
    return self.____delegate_MutableList:indexOf(element)
end

function Growing:lastIndexOf(element)
    return self.____delegate_MutableList:lastIndexOf(element)
end

local ____lambda_1 = function(it) return it > 50 end
local function subLists()
    local list = __K2L_ListOf(1, 2, 3, 4, 5)
    local sub = list:subList(1, 4)
    t("sub", function() return sub end)
    sub:set(0, 20)
    t("write through", function() return list end)
    list:set(2, 30)
    t("read through", function() return sub end)
    sub:add(99)
    t("add", function()
        return __K2L_Str(list) .. " " .. __K2L_Str(sub) .. " " .. sub.size
    end)
    sub:removeAt(0)
    t("removeAt", function()
        return __K2L_Str(list) .. " " .. __K2L_Str(sub)
    end)
    sub:clear()
    t("clear", function()
        return __K2L_Str(list) .. " " .. __K2L_Str(sub) .. " " .. tostring(sub:isEmpty())
    end)
    sub:addAll(__K2L_ReadOnlyListOf(7, 8))
    t("addAll", function()
        return __K2L_Str(list) .. " " .. __K2L_Str(sub)
    end)
    local subsub = sub:subList(1, 2)
    subsub:add(100)
    t("subsub", function()
        return __K2L_Str(list) .. " " .. __K2L_Str(sub) .. " " .. __K2L_Str(subsub)
    end)
    t("sum", function() return sub:sum() end)
    t("eq", function()
        return __K2L_Equals(sub, __K2L_ReadOnlyListOf(7, 100, 8))
    end)
    sub:sort()
    t("sort", function() return list end)
    sub:removeAll(____lambda_1)
    t("removeAll", function()
        return __K2L_Str(list) .. " " .. __K2L_Str(sub)
    end)
    t("get out", function() return sub:get(5) end)
    t("bounds", function() return list:subList(2, 1) end)
    t("bounds2", function() return list:subList(0, 10) end)
    local s = 0
    for ____i = 1, sub.size do
        local x = sub[____i]
        s = s + x
    end
    t("loop", function() return s end)
    local l2 = __K2L_ListOf(5, 6, 7, 8, 9)
    l2:subList(1, 3):clear()
    t("remove range", function() return l2 end)
    local ro = __K2L_ReadOnlyListOf(1, 2, 3, 4)
    local rosub = ro:subList(1, 3)
    t("ro sub", function()
        return __K2L_Str(rosub) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(rosub)).name) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(list:subList(0, 1))).name) .. " " .. __K2L_Str(__K2L_ReadOnlyListOf():subList(0, 0))
    end)
    t("ro add", function()
        if not (__K2L_InstanceOf(rosub, __K2L_List) and not rosub.____readOnly) then
            __K2L_CastFail(rosub, "java.util.List", "kotlin.collections.MutableList")
        end
        return rosub:add(5)
    end)
    t("ro set", function()
        if not (__K2L_InstanceOf(rosub, __K2L_List) and not rosub.____readOnly) then
            __K2L_CastFail(rosub, "java.util.List", "kotlin.collections.MutableList")
        end
        rosub:set(0, 9)
        return ro
    end)
    local lg = Logged.new()
    lg:addAll(__K2L_ReadOnlyListOf(1, 2, 3, 4))
    local lsub = lg:subList(1, 3)
    lsub:add(9)
    lsub:removeAt(0)
    lsub:set(0, 5)
    lsub:addAt(0, 6)
    t("logged", function()
        return __K2L_Str(lg) .. " " .. __K2L_Str(lg.log)
    end)
end

local ____lambda_2 = function(it) return it + 1 end
local ____lambda_3 = function()
    return __K2L_JavaClass(__K2L_KClassOfValue(__K2L_TypedArrayOf("[C", "a", "b"):asList(8))).name
end
local function arrayViews()
    local arr = __K2L_TypedArrayOf("[Ljava.lang.Integer;", 1, 2, 3)
    local view = arr:asList()
    if 0 < 0 or 0 >= arr.size then
        __K2L_IndexError(0, arr.size, "array")
    end
    arr[1] = 10
    t("asList read", function() return view end)
    if not (__K2L_InstanceOf(view, __K2L_List) and not view.____readOnly) then
        __K2L_CastFail(view, "java.util.List", "kotlin.collections.MutableList")
    end
    view:set(1, 20)
    t("asList write", function() return arr:toList() end)
    t("asList add", function() return view:add(4) end)
    t("asList class", function()
        return __K2L_JavaClass(__K2L_KClassOfValue(view)).name
    end)
    t("asList eq", function()
        return __K2L_Equals(view, __K2L_ReadOnlyListOf(10, 20, 3))
    end)
    t("asList sub", function() return view:subList(0, 2) end)
    view:sortDescending()
    t("asList sort", function() return arr:toList() end)
    local vs = 0
    for ____i_1 = 1, view.size do
        local x = view[____i_1]
        vs = vs + x
    end
    t("asList loop", function()
        return vs .. " " .. view:indexOf(3) .. " " .. __K2L_Str(view:map(____lambda_2))
    end)
    local ints = __K2L_TypedArrayOf("[I", 3, 1, 2)
    local iview = ints:asList(3)
    if 0 < 0 or 0 >= ints.size then
        __K2L_IndexError(0, ints.size, "array")
    end
    ints[1] = 30
    t("int view", function()
        return __K2L_Str(iview) .. " " .. iview.size .. " " .. iview:get(0) .. " " .. iview:sum() .. " " .. tostring(__K2L_InstanceOf(iview, __K2L_List) and not iview.____readOnly) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(iview)).name)
    end)
    t("int view cast", function()
        if not (__K2L_InstanceOf(iview, __K2L_List) and not iview.____readOnly) then
            __K2L_CastFail(iview, "java.util.List", "kotlin.collections.MutableList")
        end
        return iview
    end)
    t("int view get", function() return iview:get(5) end)
    t("chars view", ____lambda_3)
end

local ____lambda_4 = function(it) return it > 5 end
local ____lambda_5 = function()
    return __K2L_MapOf(__K2L_Pair.new(1, 2)):getKeys():add(3)
end
local ____lambda_6 = function()
    return __K2L_MapOf(__K2L_Pair.new(1, 2)):getValues():add(3)
end
local function readOnly()
    t("emptyList as", function()
        local ____cast = __K2L_ReadOnlyListOf()
        if not (__K2L_InstanceOf(____cast, __K2L_List) and not ____cast.____readOnly) then
            __K2L_CastFail(____cast, "java.util.List", "kotlin.collections.MutableList")
        end
        return ____cast
    end)
    t("emptySet as", function()
        local ____cast_1 = __K2L_ReadOnlySetOf()
        if not (__K2L_InstanceOf(____cast_1, __K2L_Set) and not ____cast_1.____readOnly) then
            __K2L_CastFail(____cast_1, "java.util.Set", "kotlin.collections.MutableSet")
        end
        return ____cast_1
    end)
    t("emptyMap as", function()
        local ____cast_2 = __K2L_ReadOnlyMapOf()
        if not (__K2L_InstanceOf(____cast_2, __K2L_Map) and not ____cast_2.____readOnly) then
            __K2L_CastFail(____cast_2, "java.util.Map", "kotlin.collections.MutableMap")
        end
        return ____cast_2
    end)
    t("listOf() as", function()
        local ____cast_3 = __K2L_ReadOnlyListOf()
        if not (__K2L_InstanceOf(____cast_3, __K2L_List) and not ____cast_3.____readOnly) then
            __K2L_CastFail(____cast_3, "java.util.List", "kotlin.collections.MutableList")
        end
        return ____cast_3
    end)
    t("emptyList is", function()
        local ____value = __K2L_ReadOnlyListOf()
        return __K2L_InstanceOf(____value, __K2L_List) and not ____value.____readOnly
    end)
    t("emptyList is List", function()
        local ____value_1 = __K2L_ReadOnlyListOf()
        return __K2L_InstanceOf(____value_1, __K2L_List)
    end)
    t("empty filter is", function()
        local ____value_2 = __K2L_SingletonListOf(1):filter(____lambda_4)
        return __K2L_InstanceOf(____value_2, __K2L_Iterable) and ____value_2.size ~= nil and not ____value_2.____readOnly
    end)
    t("emptyMap keys is", function()
        local ____value_3 = __K2L_ReadOnlyMapOf():getKeys()
        return __K2L_InstanceOf(____value_3, __K2L_Set) and not ____value_3.____readOnly
    end)
    t("range is", function()
        local ____value_4 = __K2L_IntRange.new(1, 3)
        local ____arg = tostring(__K2L_InstanceOf(____value_4, __K2L_Iterable) and not ____value_4.____readOnly)
        local ____value_5 = __K2L_IntRange.new(1, 3)
        return ____arg .. " " .. tostring(__K2L_InstanceOf(____value_5, __K2L_Iterable))
    end)
    t("listOf2 as", function()
        local ____cast_4 = __K2L_ReadOnlyListOf(1, 2)
        if not (__K2L_InstanceOf(____cast_4, __K2L_List) and not ____cast_4.____readOnly) then
            __K2L_CastFail(____cast_4, "java.util.List", "kotlin.collections.MutableList")
        end
        local m = ____cast_4
        m:set(0, 5)
        return __K2L_Str(m) .. " " .. tostring(__K2L_InstanceOf(m, __K2L_List) and not m.____readOnly)
    end)
    t("listOf1 set", function()
        local ____cast_5 = __K2L_SingletonListOf(1)
        if not (__K2L_InstanceOf(____cast_5, __K2L_List) and not ____cast_5.____readOnly) then
            __K2L_CastFail(____cast_5, "java.util.List", "kotlin.collections.MutableList")
        end
        return ____cast_5:set(0, 2)
    end)
    t("setOf1 add", function()
        local ____cast_6 = __K2L_ReadOnlySetOf(1)
        if not (__K2L_InstanceOf(____cast_6, __K2L_Set) and not ____cast_6.____readOnly) then
            __K2L_CastFail(____cast_6, "java.util.Set", "kotlin.collections.MutableSet")
        end
        return ____cast_6:add(2)
    end)
    t("string as", function()
        if not (__K2L_InstanceOf("x", __K2L_List) and not ("x").____readOnly) then
            __K2L_CastFail("x", "java.util.List", "kotlin.collections.MutableList")
        end
        return "x"
    end)
    local fixed = Fixed.new(__K2L_SingletonListOf("a"))
    t("delegating is", function()
        local ____arg_1 = tostring(__K2L_InstanceOf(fixed, __K2L_List))
        local ____arg_2 = tostring(__K2L_InstanceOf(fixed, __K2L_List) and not fixed.____readOnly)
        local ____value_6 = Growing.new(__K2L_ListOf())
        return ____arg_1 .. " " .. ____arg_2 .. " " .. tostring(__K2L_InstanceOf(____value_6, __K2L_List) and not ____value_6.____readOnly)
    end)
    t("delegating as", function()
        if not (__K2L_InstanceOf(fixed, __K2L_List) and not fixed.____readOnly) then
            __K2L_CastFail(fixed, "java.util.List", "kotlin.collections.MutableList")
        end
        return fixed
    end)
    t("keys add", ____lambda_5)
    t("values add", ____lambda_6)
    local m = __K2L_MapOf(__K2L_Pair.new("a", 1), __K2L_Pair.new("b", 2))
    m:getKeys():remove("a")
    m:getValues():remove(2)
    t("views remove", function() return m end)
end

local ____lambda_7 = function(it)
    return __K2L_JavaClass(__K2L_KClassOfValue(it)).name
end
local function classNames()
    local linked = __K2L_MapOf(__K2L_Pair.new(1, 2))
    local hashed = __K2L_HashMapOf(__K2L_Pair.new(1, 2))
    local sorted = __K2L_SortedMapOf(__K2L_Pair.new(1, 2))
    local ____list = __K2L_ReadOnlyListOf(__K2L_Pair.new("linked", linked), __K2L_Pair.new("hashed", hashed), __K2L_Pair.new("sorted", sorted), __K2L_Pair.new("single", __K2L_SingletonMapOf(__K2L_Pair.new(1, 2))))
    for ____i_2 = 1, ____list.size do
        local ____item = ____list[____i_2]
        local name, map = ____item.first, ____item.second
        print(name .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(map:getKeys())).name) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(map:getValues())).name) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(map:getEntries())).name))
        print(name .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(map:getEntries():first())).name) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(__K2L_IteratorOf(map:getKeys()))).name) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(map:iterator())).name))
    end
    print("empty " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(__K2L_ReadOnlyMapOf():getKeys())).name) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(__K2L_ReadOnlyMapOf():getValues())).name))
    local iterators = __K2L_ReadOnlyListOf(__K2L_IteratorOf(__K2L_ListOf(1)), __K2L_IteratorOf(__K2L_ReadOnlyListOf(1, 2)), __K2L_IteratorOf(__K2L_SingletonListOf(1)), __K2L_IteratorOf(__K2L_ReadOnlyListOf()), __K2L_IteratorOf(__K2L_SetOf(1)), __K2L_IteratorOf(__K2L_HashSetOf(1)), __K2L_IteratorOf(__K2L_SortedSetOf(1)), __K2L_IteratorOf(__K2L_IntRange.new(1, 2)), __K2L_IteratorOf(__K2L_TypedArrayOf("[Ljava.lang.Integer;", 1)), __K2L_IteratorOf(__K2L_PriorityQueue.new(__K2L_SingletonListOf(1))), __K2L_IteratorOf(__K2L_ArrayDeque.new(__K2L_SingletonListOf(1))))
    print(__K2L_Str(iterators:map(____lambda_7)))
    local ints = __K2L_TypedArrayOf("[I", 1)
    local strings = __K2L_TypedArrayOf("[Ljava.lang.String;", "a")
    local nested = __K2L_TypedArrayOf("[[I", __K2L_TypedArrayOf("[I", 1))
    local objects = __K2L_ListOfSize(1, nil, true)
    print(__K2L_Str(__K2L_KClassOfArray("[I", "IntArray", "int[]", "kotlin.IntArray").simpleName) .. " " .. __K2L_Str(__K2L_KClassOfArray("[I", "IntArray", "int[]", "kotlin.IntArray").qualifiedName) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfArray("[I", "IntArray", "int[]", "kotlin.IntArray")).name) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfArray("[I", "IntArray", "int[]", "kotlin.IntArray")).simpleName or "") .. " " .. __K2L_Str(__K2L_KClassOfArray("[I", "IntArray", "int[]", "kotlin.IntArray")))
    print(__K2L_Str(__K2L_KClassOfArray("[Ljava.lang.String;", "Array", "String[]", "kotlin.Array").simpleName) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfArray("[Ljava.lang.String;", "Array", "String[]", "kotlin.Array")).name) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfArray("[Ljava.lang.String;", "Array", "String[]", "kotlin.Array")).simpleName or "") .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfArray("[Ljava.lang.String;", "Array", "String[]", "kotlin.Array"))))
    local ____arg_3 = __K2L_Str(__K2L_JavaClass(__K2L_KClassOfArray("[[I", "Array", "int[][]", "kotlin.Array")).name)
    local ____arg_4 = __K2L_Str(__K2L_JavaClass(__K2L_KClassOfArray("[[I", "Array", "int[][]", "kotlin.Array")).simpleName or "")
    local ____arg_5 = __K2L_Str(__K2L_JavaClass(__K2L_KClassOfArray("[Ljava.lang.Object;", "Array", "Object[]", "kotlin.Array")).name)
    local ____unused = __K2L_TypedArrayOf("[D", 1.0)
    print(____arg_3 .. " " .. ____arg_4 .. " " .. ____arg_5 .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfArray("[D", "DoubleArray", "double[]", "kotlin.DoubleArray")).name))
    local ____arg_6 = __K2L_KClassOfArray("[I", "IntArray", "int[]", "kotlin.IntArray")
    local ____unused_1 = __K2L_ListOfSize(2, 0, "[I")
    local ____arg_8 = tostring(__K2L_Equals(____arg_6, __K2L_KClassOfArray("[I", "IntArray", "int[]", "kotlin.IntArray")))
    local ____arg_7 = __K2L_KClassOfArray("[Ljava.lang.String;", "Array", "String[]", "kotlin.Array")
    local ____unused_2 = __K2L_TypedArrayOf("[Ljava.lang.Integer;", 1)
    local ____arg_9 = tostring(__K2L_Equals(____arg_7, __K2L_KClassOfArray("[Ljava.lang.Integer;", "Array", "Integer[]", "kotlin.Array")))
    local ____unused_3 = __K2L_SingletonListOf("a"):toTypedArray("[Ljava.lang.String;")
    print(____arg_8 .. " " .. ____arg_9 .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfArray("[Ljava.lang.String;", "Array", "String[]", "kotlin.Array")).name))
    local ____unused_4 = __K2L_TypedArrayOf("[Z")
    local ____arg_10 = __K2L_Str(__K2L_JavaClass(__K2L_KClassOfArray("[Z", "BooleanArray", "boolean[]", "kotlin.BooleanArray")).name)
    local ____unused_5 = __K2L_TypedArrayOf("[J")
    local ____arg_11 = __K2L_Str(__K2L_JavaClass(__K2L_KClassOfArray("[J", "LongArray", "long[]", "kotlin.LongArray")).name)
    local ____unused_6 = __K2L_TypedArrayOf("[C")
    local ____arg_12 = __K2L_Str(__K2L_JavaClass(__K2L_KClassOfArray("[C", "CharArray", "char[]", "kotlin.CharArray")).name)
    local ____unused_7 = __K2L_TypedArrayOf("[Ljava.util.List;", __K2L_SingletonListOf(1))
    print(____arg_10 .. " " .. ____arg_11 .. " " .. ____arg_12 .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfArray("[Ljava.util.List;", "Array", "List[]", "kotlin.Array")).name))
end

local function main()
    subLists()
    arrayViews()
    readOnly()
    classNames()
end

__K2L_DeepMain(main)
return {t = t, Logged = Logged, Fixed = Fixed, Growing = Growing, subLists = subLists, arrayViews = arrayViews, readOnly = readOnly, classNames = classNames}
