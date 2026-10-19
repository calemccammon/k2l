local ____lualib = require("lualib_bundle")
local __K2L_ArrayIndexOutOfBoundsException = ____lualib.__K2L_ArrayIndexOutOfBoundsException
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IndexOutOfBoundsException = ____lualib.__K2L_IndexOutOfBoundsException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_JdkCollections = ____lualib.__K2L_JdkCollections
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_Set = ____lualib.__K2L_Set
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Unit = ____lualib.__K2L_Unit
local __K2L_Unpack = ____lualib.__K2L_Unpack

local function show(label, x)
    print(label .. ": " .. __K2L_Str(__K2L_KClassOfValue(x).simpleName) .. " " .. __K2L_Str(__K2L_KClassOfValue(x).qualifiedName) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(x)).name) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(x)).simpleName or "") .. " " .. __K2L_Str(x))
end

local function tryIt(label, f)
    local ____ok, ____result = pcall(function()
        print(label .. " = " .. __K2L_Str(f()))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        local e = ____error
        print(label .. " threw " .. __K2L_Str(__K2L_KClassOfValue(e).qualifiedName) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(e)).name) .. ": " .. __K2L_Str(e.message))
    end
end

local function factories()
    show("listOf()", __K2L_ReadOnlyListOf())
    show("emptyList", __K2L_ReadOnlyListOf())
    show("listOf(1)", __K2L_SingletonListOf(1))
    show("listOf(1,2)", __K2L_ReadOnlyListOf(1, 2))
    local arr = __K2L_ArrayOf(1)
    show("listOf(*arr)", __K2L_ReadOnlyListOf(__K2L_Unpack(arr)))
    show("asList", __K2L_ArrayOf(1, 2):asList())
    show("mutableListOf", __K2L_ListOf(1))
    show("arrayListOf", __K2L_ListOf(1))
    show("listOfNotNull(1)", __K2L_ListOf(1):filterNotNull():toList())
    show("listOfNotNull(null)", __K2L_ListOf(nil):filterNotNull():toList())
    show("listOfNotNull(1,null)", __K2L_ListOf(1, nil):filterNotNull())
    show("setOf()", __K2L_ReadOnlySetOf())
    show("emptySet", __K2L_ReadOnlySetOf())
    show("setOf(1)", __K2L_ReadOnlySetOf(1))
    show("setOf(*arr)", __K2L_ReadOnlySetOf(__K2L_Unpack(arr)))
    show("setOf(1,1)", __K2L_ReadOnlySetOf(1, 1))
    show("setOf(1,2)", __K2L_ReadOnlySetOf(1, 2))
    show("mutableSetOf", __K2L_SetOf(1))
    show("mapOf()", __K2L_ReadOnlyMapOf())
    show("emptyMap", __K2L_ReadOnlyMapOf())
    show("mapOf(1)", __K2L_SingletonMapOf(__K2L_Pair.new(1, 2)))
    local ____pairs = __K2L_ArrayOf(__K2L_Pair.new(1, 2))
    show("mapOf(*pairs)", __K2L_ReadOnlyMapOf(__K2L_Unpack(____pairs)))
    show("mapOf(2)", __K2L_ReadOnlyMapOf(__K2L_Pair.new(1, 2), __K2L_Pair.new(3, 4)))
    show("mutableMapOf", __K2L_MapOf(__K2L_Pair.new(1, 2)))
    show("Collections.emptyList", __K2L_JdkCollections.emptyList())
    show("Collections.singletonList", __K2L_JdkCollections.singletonList(1))
    show("Collections.singleton", __K2L_JdkCollections.singleton(1))
    show("Collections.emptySet", __K2L_JdkCollections.emptySet())
    show("Collections.emptyMap", __K2L_JdkCollections.emptyMap())
    show("Collections.singletonMap", __K2L_JdkCollections.singletonMap(1, 2))
    show("Collections.nCopies", __K2L_JdkCollections.nCopies(2, 0))
end

local function operations()
    local xs = __K2L_ReadOnlyListOf(1, 2, 3)
    show("toList0", xs:filter(function(it) return it > 5 end):toList())
    show("toList1", xs:filter(function(it) return it > 2 end):toList())
    show("toList2", xs:filter(function(it) return it > 1 end):toList())
    show("toMutableList", __K2L_SingletonListOf(1):toMutableList())
    show("toSet0", xs:filter(function(it) return it > 5 end):toSet())
    show("toSet1", __K2L_SingletonListOf(1):toSet())
    show("toSet2", xs:toSet())
    show("toMutableSet", __K2L_SingletonListOf(1):toMutableSet())
    show("toMap1", __K2L_SingletonListOf(__K2L_Pair.new(1, 2)):toMap())
    show("toMap2", __K2L_ReadOnlyListOf(__K2L_Pair.new(1, 2), __K2L_Pair.new(1, 3)):toMap())
    show("map.toMap", __K2L_ReadOnlyMapOf(__K2L_Pair.new(1, 2), __K2L_Pair.new(2, 3)):filter(function(it) return it.key == 1 end):toMap())
    show("map.toList", __K2L_SingletonMapOf(__K2L_Pair.new(1, 2)):toList())
    show("sorted", __K2L_ReadOnlyListOf(2, 1):sorted())
    show("sorted1", __K2L_SingletonListOf(2):sorted())
    show("sortedWith", xs:sortedWith(__K2L_CompareBy(function(it) return -it end)))
    show("sortedBy", xs:sortedBy(function(it) return -it end, true))
    show("sortedDescending", xs:sortedDescending())
    show("array.sorted", __K2L_ArrayOf(1):sorted())
    show("filter", xs:filter(function(it) return true end))
    show("map", xs:map(function(it) return it end))
    show("take1", xs:take(1))
    show("take5", xs:take(5))
    show("take0", xs:take(0))
    show("drop2", xs:drop(2))
    show("drop1", xs:drop(1))
    show("takeLast1", xs:takeLast(1))
    show("dropLast2", xs:dropLast(2))
    show("distinct1", __K2L_ReadOnlyListOf(1, 1):distinct())
    show("distinct2", __K2L_ReadOnlyListOf(1, 2):distinct())
    show("reversed1", __K2L_SingletonListOf(1):reversed())
    show("reversed2", __K2L_ReadOnlyListOf(1, 2):reversed())
    show("plus", __K2L_SingletonListOf(1):plus(2))
    show("union", __K2L_ReadOnlySetOf(1):union(__K2L_ReadOnlySetOf(1)))
    show("set plus", __K2L_ReadOnlySetOf(1):plus(1))
    show("map plus", __K2L_SingletonMapOf(__K2L_Pair.new(1, 2)):plus(__K2L_Pair.new(1, 3)))
end

local function indexes()
    tryIt("listOf()[0]", function() return __K2L_ReadOnlyListOf():get(0) end)
    tryIt("listOf(1)[1]", function() return __K2L_SingletonListOf(1):get(1) end)
    tryIt("listOf(1)[-1]", function() return __K2L_SingletonListOf(1):get(-1) end)
    tryIt("listOf(1,2)[2]", function() return __K2L_ReadOnlyListOf(1, 2):get(2) end)
    tryIt("listOf(1,2)[-1]", function() return __K2L_ReadOnlyListOf(1, 2):get(-1) end)
    tryIt("arr[2]", function() return __K2L_ArrayOf(1, 2):get(2) end)
    tryIt("intarr[2]", function() return __K2L_ArrayOf(1, 2):get(2) end)
    tryIt("arr set", function()
        local a = __K2L_ArrayOf(1)
        a:set(3, 4)
        return __K2L_Unit
    end)
    tryIt("mutable[2]", function() return __K2L_ListOf(1, 2):get(2) end)
    tryIt("mutable[-1]", function() return __K2L_ListOf(1, 2):get(-1) end)
    tryIt("asList.get", function() return __K2L_ArrayOf(1):asList():get(3) end)
    tryIt("sorted get", function()
        return __K2L_ReadOnlyListOf(2, 1):sorted():get(2)
    end)
    tryIt("Collections.emptyList get", function()
        return __K2L_JdkCollections.emptyList():get(0)
    end)
    tryIt("nCopies get", function()
        return __K2L_JdkCollections.nCopies(2, 0):get(5)
    end)
    tryIt("singletonList get", function()
        return __K2L_JdkCollections.singletonList(0):get(5)
    end)
    tryIt("elementAt listOf(1)", function() return __K2L_SingletonListOf(1):elementAt(4) end)
    tryIt("elementAt listOf(1, 2)", function()
        return __K2L_ReadOnlyListOf(1, 2):elementAt(4)
    end)
    tryIt("elementAt emptyList", function() return __K2L_ReadOnlyListOf():elementAt(4) end)
    tryIt("elementAt mutable", function() return __K2L_ListOf(1, 2):elementAt(5) end)
    tryIt("elementAt via Iterable", function()
        return __K2L_ReadOnlyListOf(1, 2):elementAt(5)
    end)
    tryIt("elementAt set", function() return __K2L_ReadOnlySetOf(1, 2):elementAt(4) end)
    tryIt("elementAt set -1", function()
        return __K2L_ReadOnlySetOf(1, 2):elementAt(-1)
    end)
    tryIt("catch IndexOutOfBounds", function()
        local ____ok_1, ____result_1, ____returned_1 = pcall(function()
            return true, __K2L_SingletonListOf(1):get(3)
        end)
        if ____ok_1 then
            if ____result_1 then
                return ____returned_1
            end
        else
            local ____error_1 = __K2L_ToThrowable(____result_1)
            if __K2L_InstanceOf(____error_1, __K2L_IndexOutOfBoundsException) then
                local e = ____error_1
                return "caught " .. __K2L_Str(e.message)
            else
                error(____error_1, 0)
            end
        end
    end)
    tryIt("catch for an array", function()
        local ____ok_2, ____result_2, ____returned_2 = pcall(function()
            return true, __K2L_ArrayOf(1):get(3)
        end)
        if ____ok_2 then
            if ____result_2 then
                return ____returned_2
            end
        else
            local ____error_2 = __K2L_ToThrowable(____result_2)
            if __K2L_InstanceOf(____error_2, __K2L_IndexOutOfBoundsException) then
                local e = ____error_2
                return "caught " .. __K2L_Str(__K2L_KClassOfValue(e).simpleName) .. " " .. __K2L_Str(e.message)
            else
                error(____error_2, 0)
            end
        end
    end)
    tryIt("catch ArrayIndexOutOfBounds", function()
        local ____ok_3, ____result_3, ____returned_3 = pcall(function()
            return true, __K2L_ReadOnlyListOf(1, 2):get(3)
        end)
        if ____ok_3 then
            if ____result_3 then
                return ____returned_3
            end
        else
            local ____error_3 = __K2L_ToThrowable(____result_3)
            if __K2L_InstanceOf(____error_3, __K2L_ArrayIndexOutOfBoundsException) then
                local e = ____error_3
                return "caught " .. __K2L_Str(e.message)
            else
                error(____error_3, 0)
            end
        end
    end)
    tryIt("not caught as ArrayIndexOutOfBounds", function()
        local ____ok_4, ____result_4, ____returned_4 = pcall(function()
            return true, __K2L_ListOf(1):get(3)
        end)
        if ____ok_4 then
            if ____result_4 then
                return ____returned_4
            end
        else
            local ____error_4 = __K2L_ToThrowable(____result_4)
            if __K2L_InstanceOf(____error_4, __K2L_ArrayIndexOutOfBoundsException) then
                local e = ____error_4
                return "wrong"
            elseif __K2L_InstanceOf(____error_4, __K2L_IndexOutOfBoundsException) then
                local e = ____error_4
                return "caught " .. __K2L_Str(__K2L_KClassOfValue(e).simpleName)
            else
                error(____error_4, 0)
            end
        end
    end)
    tryIt("is", function()
        local ____cond = __K2L_ReadOnlyListOf(1, 2):getOrNull(5) == nil
        if ____cond then
            local ____value = __K2L_IndexOutOfBoundsException.new()
            ____cond = not __K2L_InstanceOf(____value, __K2L_ArrayIndexOutOfBoundsException)
        end
        return ____cond
    end)
end

local function mutation()
    tryIt("removeFirst", function() return __K2L_ListOf():removeFirst() end)
    tryIt("removeLast", function() return __K2L_ListOf():removeLast() end)
    tryIt("ArrayList removeFirst", function() return __K2L_List.new():removeFirst() end)
    tryIt("removeFirstOrNull", function() return __K2L_ListOf():removeFirstOrNull() end)
    tryIt("first", function() return __K2L_ListOf():first() end)
    tryIt("add listOf(1,2)", function()
        local ____cast = __K2L_ReadOnlyListOf(1, 2)
        if not (__K2L_InstanceOf(____cast, __K2L_List) and not ____cast.____readOnly) then
            __K2L_CastFail(____cast, "java.util.List", "kotlin.collections.MutableList")
        end
        return ____cast:add(3)
    end)
    tryIt("set listOf(1,2)", function()
        local ____cast_1 = __K2L_ReadOnlyListOf(1, 2)
        if not (__K2L_InstanceOf(____cast_1, __K2L_List) and not ____cast_1.____readOnly) then
            __K2L_CastFail(____cast_1, "java.util.List", "kotlin.collections.MutableList")
        end
        return ____cast_1:set(0, 5)
    end)
    tryIt("set listOf(1,2) bad", function()
        local ____cast_2 = __K2L_ReadOnlyListOf(1, 2)
        if not (__K2L_InstanceOf(____cast_2, __K2L_List) and not ____cast_2.____readOnly) then
            __K2L_CastFail(____cast_2, "java.util.List", "kotlin.collections.MutableList")
        end
        return ____cast_2:set(5, 1)
    end)
    tryIt("sort listOf(3,1,2)", function()
        local l = __K2L_ReadOnlyListOf(3, 1, 2)
        if not (__K2L_InstanceOf(l, __K2L_List) and not l.____readOnly) then
            __K2L_CastFail(l, "java.util.List", "kotlin.collections.MutableList")
        end
        l:sort()
        return l
    end)
    tryIt("remove listOf(1,2)", function()
        local ____cast_3 = __K2L_ReadOnlyListOf(1, 2)
        if not (__K2L_InstanceOf(____cast_3, __K2L_List) and not ____cast_3.____readOnly) then
            __K2L_CastFail(____cast_3, "java.util.List", "kotlin.collections.MutableList")
        end
        return ____cast_3:remove(1)
    end)
    tryIt("remove absent listOf(1,2)", function()
        local ____cast_4 = __K2L_ReadOnlyListOf(1, 2)
        if not (__K2L_InstanceOf(____cast_4, __K2L_List) and not ____cast_4.____readOnly) then
            __K2L_CastFail(____cast_4, "java.util.List", "kotlin.collections.MutableList")
        end
        return ____cast_4:remove(5)
    end)
    tryIt("removeAt listOf(1,2)", function()
        local ____cast_5 = __K2L_ReadOnlyListOf(1, 2)
        if not (__K2L_InstanceOf(____cast_5, __K2L_List) and not ____cast_5.____readOnly) then
            __K2L_CastFail(____cast_5, "java.util.List", "kotlin.collections.MutableList")
        end
        return ____cast_5:removeAt(0)
    end)
    tryIt("clear listOf(1,2)", function()
        local ____cast_6 = __K2L_ReadOnlyListOf(1, 2)
        if not (__K2L_InstanceOf(____cast_6, __K2L_List) and not ____cast_6.____readOnly) then
            __K2L_CastFail(____cast_6, "java.util.List", "kotlin.collections.MutableList")
        end
        ____cast_6:clear()
        return __K2L_Unit
    end)
    tryIt("addAll empty listOf(1,2)", function()
        local ____cast_7 = __K2L_ReadOnlyListOf(1, 2)
        if not (__K2L_InstanceOf(____cast_7, __K2L_List) and not ____cast_7.____readOnly) then
            __K2L_CastFail(____cast_7, "java.util.List", "kotlin.collections.MutableList")
        end
        return ____cast_7:addAll(__K2L_ReadOnlyListOf())
    end)
    tryIt("removeFirst listOf(1,2)", function()
        local ____cast_8 = __K2L_ReadOnlyListOf(1, 2)
        if not (__K2L_InstanceOf(____cast_8, __K2L_List) and not ____cast_8.____readOnly) then
            __K2L_CastFail(____cast_8, "java.util.List", "kotlin.collections.MutableList")
        end
        return ____cast_8:removeFirst()
    end)
    tryIt("add listOf(1)", function()
        local ____cast_9 = __K2L_SingletonListOf(1)
        if not (__K2L_InstanceOf(____cast_9, __K2L_List) and not ____cast_9.____readOnly) then
            __K2L_CastFail(____cast_9, "java.util.List", "kotlin.collections.MutableList")
        end
        return ____cast_9:add(3)
    end)
    tryIt("set listOf(1)", function()
        local ____cast_10 = __K2L_SingletonListOf(1)
        if not (__K2L_InstanceOf(____cast_10, __K2L_List) and not ____cast_10.____readOnly) then
            __K2L_CastFail(____cast_10, "java.util.List", "kotlin.collections.MutableList")
        end
        return ____cast_10:set(0, 3)
    end)
    tryIt("remove listOf(1)", function()
        local ____cast_11 = __K2L_SingletonListOf(1)
        if not (__K2L_InstanceOf(____cast_11, __K2L_List) and not ____cast_11.____readOnly) then
            __K2L_CastFail(____cast_11, "java.util.List", "kotlin.collections.MutableList")
        end
        return ____cast_11:remove(1)
    end)
    tryIt("remove absent listOf(1)", function()
        local ____cast_12 = __K2L_SingletonListOf(1)
        if not (__K2L_InstanceOf(____cast_12, __K2L_List) and not ____cast_12.____readOnly) then
            __K2L_CastFail(____cast_12, "java.util.List", "kotlin.collections.MutableList")
        end
        return ____cast_12:remove(2)
    end)
    tryIt("clear listOf(1)", function()
        local ____cast_13 = __K2L_SingletonListOf(1)
        if not (__K2L_InstanceOf(____cast_13, __K2L_List) and not ____cast_13.____readOnly) then
            __K2L_CastFail(____cast_13, "java.util.List", "kotlin.collections.MutableList")
        end
        ____cast_13:clear()
        return __K2L_Unit
    end)
    tryIt("removeAt listOf(1)", function()
        local ____cast_14 = __K2L_SingletonListOf(1)
        if not (__K2L_InstanceOf(____cast_14, __K2L_List) and not ____cast_14.____readOnly) then
            __K2L_CastFail(____cast_14, "java.util.List", "kotlin.collections.MutableList")
        end
        return ____cast_14:removeAt(0)
    end)
    tryIt("sort listOf(1)", function()
        local ____cast_15 = __K2L_SingletonListOf(1)
        if not (__K2L_InstanceOf(____cast_15, __K2L_List) and not ____cast_15.____readOnly) then
            __K2L_CastFail(____cast_15, "java.util.List", "kotlin.collections.MutableList")
        end
        ____cast_15:sort()
        return "ok"
    end)
    tryIt("add sorted", function()
        local ____cast_16 = __K2L_ReadOnlyListOf(2, 1):sorted()
        if not (__K2L_InstanceOf(____cast_16, __K2L_List) and not ____cast_16.____readOnly) then
            __K2L_CastFail(____cast_16, "java.util.List", "kotlin.collections.MutableList")
        end
        return ____cast_16:add(3)
    end)
    tryIt("add setOf(1)", function()
        local ____cast_17 = __K2L_ReadOnlySetOf(1)
        if not (__K2L_InstanceOf(____cast_17, __K2L_Set) and not ____cast_17.____readOnly) then
            __K2L_CastFail(____cast_17, "java.util.Set", "kotlin.collections.MutableSet")
        end
        return ____cast_17:add(3)
    end)
    tryIt("remove setOf(1)", function()
        local ____cast_18 = __K2L_ReadOnlySetOf(1)
        if not (__K2L_InstanceOf(____cast_18, __K2L_Set) and not ____cast_18.____readOnly) then
            __K2L_CastFail(____cast_18, "java.util.Set", "kotlin.collections.MutableSet")
        end
        return ____cast_18:remove(1)
    end)
    tryIt("clear setOf(1)", function()
        local ____cast_19 = __K2L_ReadOnlySetOf(1)
        if not (__K2L_InstanceOf(____cast_19, __K2L_Set) and not ____cast_19.____readOnly) then
            __K2L_CastFail(____cast_19, "java.util.Set", "kotlin.collections.MutableSet")
        end
        ____cast_19:clear()
        return __K2L_Unit
    end)
    tryIt("add setOf(1,2)", function()
        local ____cast_20 = __K2L_ReadOnlySetOf(1, 2)
        if not (__K2L_InstanceOf(____cast_20, __K2L_Set) and not ____cast_20.____readOnly) then
            __K2L_CastFail(____cast_20, "java.util.Set", "kotlin.collections.MutableSet")
        end
        return ____cast_20:add(3)
    end)
    tryIt("put mapOf(1)", function()
        local ____cast_21 = __K2L_SingletonMapOf(__K2L_Pair.new(1, 2))
        if not (__K2L_InstanceOf(____cast_21, __K2L_Map) and not ____cast_21.____readOnly) then
            __K2L_CastFail(____cast_21, "java.util.Map", "kotlin.collections.MutableMap")
        end
        return ____cast_21:put(3, 3)
    end)
    tryIt("remove mapOf(1)", function()
        local ____cast_22 = __K2L_SingletonMapOf(__K2L_Pair.new(1, 2))
        if not (__K2L_InstanceOf(____cast_22, __K2L_Map) and not ____cast_22.____readOnly) then
            __K2L_CastFail(____cast_22, "java.util.Map", "kotlin.collections.MutableMap")
        end
        return ____cast_22:remove(1)
    end)
    tryIt("clear mapOf(1)", function()
        local ____cast_23 = __K2L_SingletonMapOf(__K2L_Pair.new(1, 2))
        if not (__K2L_InstanceOf(____cast_23, __K2L_Map) and not ____cast_23.____readOnly) then
            __K2L_CastFail(____cast_23, "java.util.Map", "kotlin.collections.MutableMap")
        end
        ____cast_23:clear()
        return __K2L_Unit
    end)
    tryIt("Collections.emptyList add", function()
        return __K2L_JdkCollections.emptyList():add(1)
    end)
    tryIt("toMutableList of listOf(1)", function()
        local ____value_1 = __K2L_SingletonListOf(1):toMutableList()
        ____value_1:add(2)
        return ____value_1
    end)
    tryIt("ArrayList(listOf(1))", function()
        local ____value_2 = __K2L_SingletonListOf(1):toMutableList()
        ____value_2:add(2)
        return ____value_2
    end)
    tryIt("LinkedHashSet(setOf(1))", function()
        local ____value_3 = __K2L_ReadOnlySetOf(1):toMutableSet()
        ____value_3:add(2)
        return ____value_3
    end)
    tryIt("LinkedHashMap(mapOf(1))", function()
        local ____value_4 = __K2L_SingletonMapOf(__K2L_Pair.new(1, 2)):toMutableMap()
        ____value_4:put(3, 4)
        return ____value_4
    end)
    tryIt("toMutableMap of mapOf(1)", function()
        local ____value_5 = __K2L_SingletonMapOf(__K2L_Pair.new(1, 2)):toMutableMap()
        ____value_5:put(3, 4)
        return ____value_5
    end)
end

local function equality()
    tryIt("eq", function()
        return __K2L_Equals(__K2L_SingletonListOf(1), __K2L_ListOf(1)) and __K2L_Equals(__K2L_ReadOnlySetOf(1), __K2L_SetOf(1)) and __K2L_Equals(__K2L_SingletonMapOf(__K2L_Pair.new(1, 2)), __K2L_MapOf(__K2L_Pair.new(1, 2)))
    end)
    tryIt("eq empty", function()
        return __K2L_Equals(__K2L_ReadOnlyListOf(), __K2L_ListOf()) and __K2L_Equals(__K2L_ReadOnlySetOf(), __K2L_SetOf()) and __K2L_Equals(__K2L_ReadOnlyMapOf(), __K2L_MapOf())
    end)
    tryIt("hash", function()
        return __K2L_Hash(__K2L_ReadOnlyListOf(1, 2)) + __K2L_Hash(__K2L_ReadOnlySetOf(1)) + __K2L_Hash(__K2L_SingletonMapOf(__K2L_Pair.new(1, 2))) + __K2L_Hash(__K2L_ReadOnlyListOf())
    end)
    tryIt("same empty", function()
        return __K2L_ReadOnlyListOf() == __K2L_ReadOnlyListOf() and __K2L_ReadOnlySetOf() == __K2L_ReadOnlySetOf() and __K2L_ReadOnlyMapOf() == __K2L_ReadOnlyMapOf()
    end)
    tryIt("toString", function()
        return __K2L_Str(__K2L_ReadOnlyListOf()) .. __K2L_Str(__K2L_ReadOnlySetOf()) .. __K2L_Str(__K2L_ReadOnlyMapOf()) .. __K2L_Str(__K2L_SingletonListOf(1)) .. __K2L_Str(__K2L_ReadOnlySetOf(1)) .. __K2L_Str(__K2L_SingletonMapOf(__K2L_Pair.new(1, 2)))
    end)
    tryIt("class equality", function()
        return __K2L_Equals(__K2L_KClassOfValue(__K2L_SingletonListOf(1)), __K2L_KClassOfValue(__K2L_JdkCollections.singletonList(2)))
    end)
    tryIt("contains", function()
        return __K2L_SingletonListOf(1):contains(1) and __K2L_ReadOnlyListOf(1, 2):contains(2) and __K2L_ReadOnlySetOf(1):contains(1) and __K2L_SingletonMapOf(__K2L_Pair.new(1, 2)):containsKey(1)
    end)
    local single = __K2L_SingletonListOf(5)
    local total = 0
    for ____i = 1, single.size do
        local x = single[____i]
        total = total + x
    end
    local ____list = __K2L_ReadOnlyListOf()
    for ____i_1 = 1, ____list.size do
        local x = ____list[____i_1]
        total = total + x
    end
    local ____list_1 = __K2L_ReadOnlySetOf(7):toList()
    for ____i_2 = 1, ____list_1.size do
        local x = ____list_1[____i_2]
        total = total + x
    end
    for k, v in __K2L_SingletonMapOf(__K2L_Pair.new(1, 2)):iter() do
        total = total + (k + v)
    end
    print("loops " .. total .. " " .. __K2L_Str(single:map(function(it) return it * 2 end)) .. " " .. __K2L_Str(__K2L_ReadOnlySetOf(3):map(function(it) return it end)) .. " " .. __K2L_Str(__K2L_SingletonMapOf(__K2L_Pair.new(1, 2)):map(function(it) return it.value end)))
end

local function main()
    factories()
    operations()
    indexes()
    mutation()
    equality()
end

main()
return {show = show, tryIt = tryIt, factories = factories, operations = operations, indexes = indexes, mutation = mutation, equality = equality}
