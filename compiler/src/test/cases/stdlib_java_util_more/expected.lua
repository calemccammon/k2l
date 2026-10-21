local ____lualib = require("lualib_bundle")
local __K2L_BitSet = ____lualib.__K2L_BitSet
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_CompareValues = ____lualib.__K2L_CompareValues
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Deque = ____lualib.__K2L_Deque
local __K2L_EnumMap = ____lualib.__K2L_EnumMap
local __K2L_EnumSets = ____lualib.__K2L_EnumSets
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_HashMapOf = ____lualib.__K2L_HashMapOf
local __K2L_HashSetOf = ____lualib.__K2L_HashSetOf
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_JavaUtil = ____lualib.__K2L_JavaUtil
local __K2L_JdkCollections = ____lualib.__K2L_JdkCollections
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_LinkedList = ____lualib.__K2L_LinkedList
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Optional = ____lualib.__K2L_Optional
local __K2L_OptionalDouble = ____lualib.__K2L_OptionalDouble
local __K2L_OptionalInt = ____lualib.__K2L_OptionalInt
local __K2L_OptionalLong = ____lualib.__K2L_OptionalLong
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_Set = ____lualib.__K2L_Set
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_SortedMap = ____lualib.__K2L_SortedMap
local __K2L_SortedSet = ____lualib.__K2L_SortedSet
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf
local __K2L_Unit = ____lualib.__K2L_Unit

local Color = __K2L_Class("Color")
__K2L_ClassInfo(Color, "Color", "Color", "class")

function Color:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Color:toString()
    return self.name
end

function Color:compareTo(other)
    return self.ordinal - other.ordinal
end

Color.RED = Color.new("RED", 0)
Color.GREEN = Color.new("GREEN", 1)
Color.BLUE = Color.new("BLUE", 2)
Color.____values = {Color.RED, Color.GREEN, Color.BLUE}

local function t(label, f)
    local ____ok, ____result = __K2L_DeepPcall(function()
        print(label .. " = " .. __K2L_Str(f()))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_Exception) then
            local e = ____error
            print(label .. " EXC " .. __K2L_Str(__K2L_KClassOfValue(e).simpleName) .. ": " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
end

local ____lambda_1 = function()
    return __K2L_JdkCollections.emptySortedSet():add(1)
end
local ____lambda_2 = function()
    return __K2L_JdkCollections.emptyIterator():hasNext()
end
local ____lambda_3 = function()
    return __K2L_JdkCollections.emptyIterator():next()
end
local ____lambda_4 = function()
    return __K2L_JdkCollections.newSetFromMap(__K2L_HashMapOf(__K2L_Pair.new("a", true)))
end
local ____lambda_5 = function() return __K2L_JdkCollections.nCopies(3, "ab") end
local ____lambda_6 = function(____a, ____b)
    local ____x, ____y = ____b, ____a
    if ____x ~= ____y then
        return ____x < ____y and -1 or 1
    end
    return 0
end
local ____lambda_7 = function(____a_1, ____b_1)
    local ____x_1, ____y_1 = #____a_1, #____b_1
    if ____x_1 ~= ____y_1 then
        return ____x_1 < ____y_1 and -1 or 1
    end
    return 0
end
local ____lambda_8 = function(____a_2, ____b_2)
    local ____x_2, ____y_2 = #____a_2, #____b_2
    if ____x_2 ~= ____y_2 then
        return ____x_2 < ____y_2 and -1 or 1
    end
    return 0
end
local ____lambda_9 = function()
    return __K2L_ReadOnlyListOf("bb", "a", "ccc"):sortedWith(__K2L_JdkCollections.reverseOrder(____lambda_8))
end
local ____lambda_10 = function() return __K2L_Optional.of(2) end
local ____lambda_11 = function() return __K2L_Optional.of(2) end
local ____lambda_12 = function()
    return __K2L_ReadOnlyListOf(__K2L_Optional.of(1):Or(____lambda_10), __K2L_Optional.empty():Or(____lambda_11))
end
local ____lambda_13 = function()
    return __K2L_ReadOnlyListOf(__K2L_Optional.of("x"):stream():toList(), __K2L_Optional.empty():stream():count())
end
local ____lambda_14 = function()
    return __K2L_ReadOnlyListOf(__K2L_Optional.of("ab"):hashCode(), __K2L_Optional.empty():hashCode(), __K2L_Optional.of(7):hashCode())
end
local ____lambda_15 = function()
    return __K2L_ReadOnlyListOf(__K2L_Optional.empty():isEmpty(), __K2L_Optional.of(1):isEmpty())
end
local ____lambda_16 = function() return __K2L_Optional.empty():orElseThrow() end
local ____lambda_17 = function()
    return __K2L_OptionalInt.of(5):hashCode() .. " " .. __K2L_OptionalInt.of(5):stream():sum() .. " " .. __K2L_OptionalInt.empty():stream():count()
end
local ____lambda_18 = function()
    return __K2L_OptionalLong.of(-1):hashCode() .. " " .. __K2L_OptionalLong.of(5000000000):hashCode() .. " " .. __K2L_OptionalLong.of(9):stream():sum()
end
local ____lambda_19 = function()
    return __K2L_OptionalDouble.of(1.5):hashCode() .. " " .. __K2L_Str(__K2L_OptionalDouble.of(2.5):stream():sum()) .. " " .. __K2L_OptionalDouble.empty():hashCode()
end
local ____lambda_20 = function()
    return __K2L_ReadOnlyListOf(__K2L_JdkCollections.compareArrays("Int", __K2L_TypedArrayOf("[I", 1, 2, 3), __K2L_TypedArrayOf("[I", 1, 2, 4)), __K2L_JdkCollections.compareArrays("Int", __K2L_TypedArrayOf("[I", 1, 2), __K2L_TypedArrayOf("[I", 1, 2, 3)), __K2L_JdkCollections.compareArrays("Int", __K2L_TypedArrayOf("[I", 5), __K2L_TypedArrayOf("[I", 5)), __K2L_JdkCollections.compareArrays("Byte", __K2L_TypedArrayOf("[B", 1, 9), __K2L_TypedArrayOf("[B", 1, 2)), __K2L_JdkCollections.compareArrays("Char", __K2L_TypedArrayOf("[C", "a", "z"), __K2L_TypedArrayOf("[C", "a", "b")), __K2L_JdkCollections.compareArrays("Boolean", __K2L_TypedArrayOf("[Z", true), __K2L_TypedArrayOf("[Z", false)), __K2L_JdkCollections.compareArrays("Double", __K2L_TypedArrayOf("[D", 0.0), __K2L_TypedArrayOf("[D", -0.0)), __K2L_JdkCollections.compareArrays("Object", __K2L_TypedArrayOf("[Ljava.lang.String;", "abc", "x"), __K2L_TypedArrayOf("[Ljava.lang.String;", "abd", "x")), __K2L_JdkCollections.compareArrays("Object", __K2L_TypedArrayOf("[Ljava.lang.String;", "b"), __K2L_TypedArrayOf("[Ljava.lang.String;", "a", "b")), __K2L_JdkCollections.compareArrays("Long", __K2L_TypedArrayOf("[J", 1, 5), __K2L_TypedArrayOf("[J", 1, 2, 3, 4)))
end
local ____lambda_21 = function()
    return __K2L_ReadOnlyListOf(__K2L_JdkCollections.compareArrays("Int", __K2L_TypedArrayOf("[I", 9, 1, 2), 1, 3, __K2L_TypedArrayOf("[I", 1, 2, 7), 0, 2), __K2L_JdkCollections.compareArrays("Int", __K2L_TypedArrayOf("[I", 1, 2, 3), 0, 3, __K2L_TypedArrayOf("[I", 1, 2), 0, 2))
end
local ____lambda_22 = function(____a_3, ____b_3)
    local ____x_3, ____y_3 = #____a_3, #____b_3
    if ____x_3 ~= ____y_3 then
        return ____x_3 < ____y_3 and -1 or 1
    end
    return 0
end
local ____lambda_23 = function()
    return __K2L_JdkCollections.compareArrays("Object", __K2L_TypedArrayOf("[Ljava.lang.String;", "aa", "b"), __K2L_TypedArrayOf("[Ljava.lang.String;", "c", "bbb"), ____lambda_22)
end
local ____lambda_24 = function()
    return __K2L_ReadOnlyListOf(__K2L_JdkCollections.compareArrays("Int", nil, __K2L_TypedArrayOf("[I")), __K2L_JdkCollections.compareArrays("Object", __K2L_TypedArrayOf("[Ljava.lang.String;", "a"), __K2L_TypedArrayOf("[Ljava.lang.String;", "a", "b")))
end
local ____lambda_25 = function()
    return __K2L_JdkCollections.compareArrays("Int", __K2L_TypedArrayOf("[I", 1), 0, 5, __K2L_TypedArrayOf("[I", 1), 0, 1)
end
local ____lambda_26 = function()
    return __K2L_ReadOnlyListOf(__K2L_JdkCollections.compareUnsignedArrays("Byte", __K2L_TypedArrayOf("[B", -1), __K2L_TypedArrayOf("[B", 1)), __K2L_JdkCollections.compareUnsignedArrays("Int", __K2L_TypedArrayOf("[I", -1), __K2L_TypedArrayOf("[I", 1)), __K2L_JdkCollections.compareUnsignedArrays("Long", __K2L_TypedArrayOf("[J", 1), __K2L_TypedArrayOf("[J", -1)))
end
local ____lambda_27 = function()
    return __K2L_ReadOnlyListOf(__K2L_JdkCollections.mismatchArrays("Int", __K2L_TypedArrayOf("[I", 1, 2, 3), __K2L_TypedArrayOf("[I", 1, 2, 4)), __K2L_JdkCollections.mismatchArrays("Int", __K2L_TypedArrayOf("[I", 1, 2), __K2L_TypedArrayOf("[I", 1, 2, 3)), __K2L_JdkCollections.mismatchArrays("Int", __K2L_TypedArrayOf("[I", 1, 2), __K2L_TypedArrayOf("[I", 1, 2)), __K2L_JdkCollections.mismatchArrays("Double", __K2L_TypedArrayOf("[D", 0.0 / 0.0), __K2L_TypedArrayOf("[D", 0.0 / 0.0)), __K2L_JdkCollections.mismatchArrays("Double", __K2L_TypedArrayOf("[D", 0.0), __K2L_TypedArrayOf("[D", -0.0)), __K2L_JdkCollections.mismatchArrays("Object", __K2L_TypedArrayOf("[Ljava.lang.String;", "a", nil), __K2L_TypedArrayOf("[Ljava.lang.String;", "a", "b")), __K2L_JdkCollections.mismatchArrays("Int", __K2L_TypedArrayOf("[I", 5, 1, 2), 1, 3, __K2L_TypedArrayOf("[I", 1, 2), 0, 2), __K2L_JdkCollections.mismatchArrays("Object", __K2L_TypedArrayOf("[Ljava.lang.String;", "A", "b"), __K2L_TypedArrayOf("[Ljava.lang.String;", "a", "c"), __K2L_Text.caseInsensitiveOrder))
end
local ____lambda_28 = function(a, b) return a + b end
local ____lambda_29 = function(a, b) return a * b end
local ____lambda_30 = function(it) return it * it end
local ____lambda_31 = function()
    return __K2L_JavaUtil.checkFromToIndex(1, 3, 5)
end
local ____lambda_32 = function()
    return __K2L_JavaUtil.checkFromToIndex(2, 1, 5)
end
local ____lambda_33 = function()
    return __K2L_JavaUtil.checkFromIndexSize(1, 3, 5)
end
local ____lambda_34 = function()
    return __K2L_JavaUtil.checkFromIndexSize(2, 4, 5)
end
local ____lambda_35 = function() return "b" end
local ____lambda_36 = function() return "b" end
local ____lambda_37 = function()
    return __K2L_ReadOnlyListOf(__K2L_JavaUtil.requireNonNullElseGet("a", ____lambda_35), __K2L_JavaUtil.requireNonNullElseGet(nil, ____lambda_36))
end
local ____lambda_38 = function() return nil end
local ____lambda_39 = function()
    return __K2L_JavaUtil.requireNonNullElseGet(nil, ____lambda_38)
end
local ____lambda_40 = function()
    return __K2L_ReadOnlyListOf(__K2L_JdkCollections.objectsDeepEquals(__K2L_TypedArrayOf("[[I", __K2L_TypedArrayOf("[I", 1)), __K2L_TypedArrayOf("[[I", __K2L_TypedArrayOf("[I", 1))), __K2L_JdkCollections.objectsDeepEquals("a", "a"), __K2L_JdkCollections.objectsDeepEquals(nil, 1), __K2L_JdkCollections.objectsDeepEquals(1.0, 1.0))
end
local ____lambda_41 = function(____a_4, ____b_4)
    local ____x_4, ____y_4 = #____a_4, #____b_4
    if ____x_4 ~= ____y_4 then
        return ____x_4 < ____y_4 and -1 or 1
    end
    return 0
end
local ____lambda_42 = function(____a_5, ____b_5)
    local ____x_5, ____y_5 = ____b_5, ____a_5
    if ____x_5 ~= ____y_5 then
        return ____x_5 < ____y_5 and -1 or 1
    end
    return 0
end
local ____lambda_43 = function()
    return __K2L_MapOf(__K2L_Pair.new("x", 1), __K2L_Pair.new("y", 2)):getKeys()
end
local ____lambda_44 = function() return __K2L_JdkCollections.unsupported() end
local ____lambda_45 = function()
    return __K2L_StringBuilder.new():append(__K2L_JavaUtil.repeatText("a", -1))
end
local function main()
    local tree = __K2L_SortedSet.new(__K2L_ReadOnlyListOf(5, 1, 3))
    local sorted = __K2L_JdkCollections.unmodifiableSortedSet(tree)
    t("unmodifiableSortedSet", function()
        return __K2L_Str(sorted) .. " " .. __K2L_Str(sorted:first()) .. " " .. __K2L_Str(sorted:last()) .. " " .. sorted.size .. " " .. tostring(sorted:contains(3))
    end)
    t("unmodifiableSortedSet add", function() return sorted:add(9) end)
    tree:add(4)
    t("view is live", function() return sorted end)
    local nav = __K2L_JdkCollections.unmodifiableNavigableSet(tree)
    t("unmodifiableNavigableSet", function()
        return __K2L_Str(nav:floor(2)) .. " " .. __K2L_Str(nav:ceiling(2)) .. " " .. __K2L_Str(nav:headSet(4))
    end)
    t("unmodifiableNavigableSet poll", function() return nav:pollFirst() end)
    local map = __K2L_SortedMap.new(__K2L_ReadOnlyMapOf(__K2L_Pair.new("b", 2), __K2L_Pair.new("a", 1), __K2L_Pair.new("c", 3)))
    local sortedMap = __K2L_JdkCollections.unmodifiableSortedMap(map)
    t("unmodifiableSortedMap", function()
        return __K2L_Str(sortedMap) .. " " .. __K2L_Str(sortedMap:firstKey()) .. " " .. __K2L_Str(sortedMap:get("b")) .. " " .. __K2L_Str(sortedMap:getKeys())
    end)
    t("unmodifiableSortedMap put", function()
        sortedMap:set("d", 4)
        return __K2L_Unit
    end)
    local navMap = __K2L_JdkCollections.unmodifiableNavigableMap(map)
    t("unmodifiableNavigableMap", function()
        return __K2L_Str(navMap:floorKey("bb")) .. " " .. __K2L_Str(navMap:lastEntry())
    end)
    t("unmodifiableNavigableMap poll", function() return navMap:pollFirstEntry() end)
    t("unmodifiableNavigableMap keys", function() return navMap:getKeys():remove("a") end)
    t("emptySortedSet", function()
        local ____value = __K2L_JdkCollections.emptySortedSet()
        return __K2L_Str(____value) .. " " .. ____value.size .. " " .. tostring(____value:isEmpty())
    end)
    t("emptySortedSet add", ____lambda_1)
    t("emptyNavigableMap", function()
        local ____value_1 = __K2L_JdkCollections.emptyNavigableMap()
        return __K2L_Str(____value_1) .. " " .. ____value_1.size
    end)
    t("emptySortedMap put", function()
        local ____object = __K2L_JdkCollections.emptySortedMap()
        ____object:set("x", 1)
        return __K2L_Unit
    end)
    t("emptyIterator", ____lambda_2)
    t("emptyListIterator", function()
        local ____value_2 = __K2L_JdkCollections.emptyListIterator()
        return tostring(____value_2:hasNext()) .. " " .. tostring(____value_2:hasPrevious()) .. " " .. ____value_2:nextIndex()
    end)
    t("emptyIterator next", ____lambda_3)
    t("synchronized", function()
        return __K2L_Str(__K2L_JdkCollections.identity(tree):first()) .. " " .. __K2L_Str(__K2L_JdkCollections.identity(map):lastKey())
    end)
    local source = __K2L_ReadOnlyListOf(1, 2, 3, 1, 2, 3, 4)
    t("indexOfSubList", function()
        return __K2L_ReadOnlyListOf(__K2L_JdkCollections.indexOfSubList(source, __K2L_ReadOnlyListOf(2, 3)), __K2L_JdkCollections.indexOfSubList(source, __K2L_ReadOnlyListOf(3, 2)), __K2L_JdkCollections.indexOfSubList(source, __K2L_ReadOnlyListOf()))
    end)
    t("lastIndexOfSubList", function()
        return __K2L_ReadOnlyListOf(__K2L_JdkCollections.lastIndexOfSubList(source, __K2L_ReadOnlyListOf(2, 3)), __K2L_JdkCollections.lastIndexOfSubList(source, __K2L_SingletonListOf(9)), __K2L_JdkCollections.lastIndexOfSubList(source, __K2L_ReadOnlyListOf()))
    end)
    local fromMap = __K2L_JdkCollections.newSetFromMap(__K2L_Map.new())
    fromMap:add("z")
    fromMap:add("a")
    fromMap:add("z")
    t("newSetFromMap", function() return fromMap end)
    t("newSetFromMap tree", function()
        local ____value_3 = __K2L_JdkCollections.newSetFromMap(__K2L_SortedMap.new())
        ____value_3:addAll(__K2L_ReadOnlyListOf("q", "b", "k"))
        return ____value_3
    end)
    t("newSetFromMap non-empty", ____lambda_4)
    t("nCopies", ____lambda_5)
    t("frequency/disjoint", function()
        return __K2L_JdkCollections.frequency(source, 3) .. " " .. tostring(__K2L_JdkCollections.disjoint(source, __K2L_ReadOnlyListOf(7, 8))) .. " " .. tostring(__K2L_JdkCollections.disjoint(source, __K2L_SingletonListOf(4)))
    end)
    t("rotate/swap", function()
        local ____value_4 = source:toMutableList()
        __K2L_JdkCollections.rotate(____value_4, 2)
        __K2L_JdkCollections.swap(____value_4, 0, 6)
        return ____value_4
    end)
    t("min/max comparator", function()
        return __K2L_Str(__K2L_JdkCollections.max(source, ____lambda_6)) .. " " .. __K2L_Str(__K2L_JdkCollections.min(__K2L_ReadOnlyListOf("bb", "a", "ccc"), ____lambda_7))
    end)
    t("reverseOrder comparator", ____lambda_9)
    t("Optional.or", ____lambda_12)
    t("Optional.stream", ____lambda_13)
    t("Optional.hashCode", ____lambda_14)
    t("Optional.isEmpty", ____lambda_15)
    t("Optional.orElseThrow", ____lambda_16)
    t("Optional.ifPresentOrElse", function()
        local out = __K2L_ListOf()
        __K2L_Optional.of(3):ifPresentOrElse(function(it)
            out:add("got " .. it)
        end, function()
            out:add("none")
        end)
        __K2L_Optional.empty():ifPresentOrElse(function(it)
            out:add("got " .. it)
        end, function()
            out:add("none")
        end)
        return out
    end)
    t("OptionalInt", ____lambda_17)
    t("OptionalLong", ____lambda_18)
    t("OptionalDouble", ____lambda_19)
    t("Arrays.compare", ____lambda_20)
    t("Arrays.compare ranges", ____lambda_21)
    t("Arrays.compare comparator", ____lambda_23)
    t("Arrays.compare nulls", ____lambda_24)
    t("Arrays.compare range error", ____lambda_25)
    t("Arrays.compareUnsigned", ____lambda_26)
    t("Arrays.mismatch", ____lambda_27)
    t("Arrays.parallelPrefix", function()
        local ____value_5 = __K2L_TypedArrayOf("[I", 1, 2, 3, 4, 5)
        __K2L_JdkCollections.parallelPrefix(____value_5, ____lambda_28)
        return ____value_5:toList()
    end)
    t("Arrays.parallelPrefix range", function()
        local ____value_6 = __K2L_TypedArrayOf("[I", 1, 2, 3, 4, 5)
        __K2L_JdkCollections.parallelPrefix(____value_6, 1, 4, ____lambda_29)
        return ____value_6:toList()
    end)
    t("Arrays.parallelSort", function()
        local ____value_7 = __K2L_TypedArrayOf("[I", 5, 3, 9, 1)
        __K2L_JdkCollections.sort_array(____value_7)
        return ____value_7:toList()
    end)
    t("Arrays.parallelSetAll", function()
        local ____value_8 = __K2L_ListOfSize(4, 0, "[I")
        __K2L_JdkCollections.setAll(____value_8, ____lambda_30)
        return ____value_8:toList()
    end)
    t("Objects.checkFromToIndex", ____lambda_31)
    t("Objects.checkFromToIndex bad", ____lambda_32)
    t("Objects.checkFromIndexSize", ____lambda_33)
    t("Objects.checkFromIndexSize bad", ____lambda_34)
    t("Objects.requireNonNullElseGet", ____lambda_37)
    t("Objects.requireNonNullElseGet null", ____lambda_39)
    t("Objects.deepEquals", ____lambda_40)
    local list = __K2L_ListOf(3, 1, 2)
    local ____cast = __K2L_JdkCollections.clone(list)
    if not __K2L_InstanceOf(____cast, __K2L_List) then
        __K2L_CastFail(____cast, "java.util.ArrayList", "java.util.ArrayList")
    end
    local copy = ____cast
    copy:add(9)
    __K2L_JdkCollections.identity(list)
    __K2L_JdkCollections.identity(list)
    t("ArrayList.clone", function()
        return __K2L_Str(list) .. " " .. __K2L_Str(copy)
    end)
    local byLength = __K2L_SortedMap.new(____lambda_41)
    byLength:set("ccc", 3)
    byLength:set("a", 1)
    local ____cast_1 = __K2L_JdkCollections.clone(byLength)
    if not __K2L_InstanceOf(____cast_1, __K2L_SortedMap) then
        __K2L_CastFail(____cast_1, "java.util.TreeMap", "java.util.TreeMap")
    end
    local mapCopy = ____cast_1
    mapCopy:set("bb", 2)
    t("TreeMap.clone", function()
        return __K2L_Str(byLength) .. " " .. __K2L_Str(mapCopy) .. " " .. tostring(__K2L_JdkCollections.comparator(mapCopy) ~= nil) .. " " .. __K2L_Str(__K2L_JdkCollections.comparator(__K2L_SortedMap.new()))
    end)
    local ____cast_2 = __K2L_JdkCollections.clone(__K2L_HashSetOf(1, 2))
    if not __K2L_InstanceOf(____cast_2, __K2L_Set) then
        __K2L_CastFail(____cast_2, "java.util.HashSet", "java.util.HashSet")
    end
    local setCopy = ____cast_2
    t("HashSet.clone", function() return setCopy.size end)
    t("TreeSet.comparator", function()
        local ____value_9 = __K2L_SortedSet.new(____lambda_42)
        ____value_9:addAll(__K2L_ReadOnlyListOf(1, 3, 2))
        local ____result_1
        do
            local ____arg = tostring(__K2L_JdkCollections.comparator(____value_9) ~= nil)
            local ____cast_3 = __K2L_JdkCollections.clone(____value_9)
            if not __K2L_InstanceOf(____cast_3, __K2L_SortedSet) then
                __K2L_CastFail(____cast_3, "java.util.TreeSet", "java.util.TreeSet")
            end
            ____result_1 = ____arg .. " " .. __K2L_Str(____cast_3)
        end
        return ____result_1
    end)
    local deque = __K2L_Deque.new(__K2L_ReadOnlyListOf(1, 2, 3, 2, 1))
    t("ArrayDeque.removeLastOccurrence", function()
        return tostring(__K2L_JdkCollections.removeLastOccurrence(deque, 2)) .. " " .. tostring(deque:remove(1)) .. " " .. tostring(__K2L_JdkCollections.removeLastOccurrence(deque, 7)) .. " " .. __K2L_Str(deque)
    end)
    local linked = __K2L_LinkedList.new(__K2L_ReadOnlyListOf("a", "b", "a", "c"))
    t("LinkedList.removeLastOccurrence", function()
        return tostring(__K2L_JdkCollections.removeLastOccurrence(linked, "a")) .. " " .. __K2L_Str(linked)
    end)
    t("toArray", function() return linked:toTypedArray():toList() end)
    local hm = __K2L_HashMapOf(__K2L_Pair.new("k", 1))
    t("HashMap.replace", function()
        return __K2L_Str(__K2L_JdkCollections.replace(hm, "k", 2)) .. " " .. __K2L_Str(__K2L_JdkCollections.replace(hm, "z", 3)) .. " " .. tostring(__K2L_JdkCollections.replaceIf(hm, "k", 2, 5)) .. " " .. tostring(__K2L_JdkCollections.replaceIf(hm, "k", 9, 7)) .. " " .. __K2L_Str(hm)
    end)
    t("newHashMap", function()
        local ____value_10 = __K2L_HashMap.new()
        ____value_10:put("a", 1)
        return ____value_10
    end)
    t("LinkedHashMap.putLast", function()
        local ____value_11 = __K2L_MapOf(__K2L_Pair.new("a", 1), __K2L_Pair.new("b", 2))
        __K2L_JdkCollections.putLast(____value_11, "a", 3)
        return ____value_11
    end)
    t("LinkedHashMap.sequencedKeySet", ____lambda_43)
    t("TreeMap.putFirst", ____lambda_44)
    local bits = __K2L_BitSet.new()
    bits:set(2, 6, true)
    bits:set(3, 4, false)
    t("BitSet range index", function()
        return __K2L_Str(bits) .. " " .. __K2L_Str(bits:get(0, 5))
    end)
    t("toArray(array)", function()
        return __K2L_ReadOnlyListOf(__K2L_JdkCollections.toArray(linked, __K2L_TypedArrayOf("[Ljava.lang.String;")):toList(), __K2L_JdkCollections.toArray(linked, __K2L_ListOfSize(5, nil, "[Ljava.lang.String;")):toList())
    end)
    local colors = __K2L_EnumSets.of(Color.BLUE)
    local ____value_12 = __K2L_EnumSets.copyOf(colors)
    ____value_12:add(Color.RED)
    local colorsCopy = ____value_12
    t("EnumSet.clone", function()
        return __K2L_Str(colors) .. " " .. __K2L_Str(colorsCopy)
    end)
    local counts = __K2L_EnumMap.new(__K2L_SingletonMapOf(__K2L_Pair.new(Color.GREEN, 1)))
    local ____value_13 = __K2L_EnumMap.new(counts)
    ____value_13:put(Color.RED, 2)
    local countsCopy = ____value_13
    t("EnumMap.clone", function()
        return __K2L_Str(counts) .. " " .. __K2L_Str(countsCopy)
    end)
    local sb = __K2L_StringBuilder.new("ab")
    sb:append(__K2L_JavaUtil.repeatText("xy", 2))
    sb:append(__K2L_JavaUtil.repeatCodePoint(122, 3))
    t("StringBuilder.repeat", function() return sb end)
    t("StringBuilder.repeat negative", ____lambda_45)
end

__K2L_DeepMain(main)
return {Color = Color, t = t}
