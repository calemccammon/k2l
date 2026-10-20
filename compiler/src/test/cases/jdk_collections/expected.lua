local ____lualib = require("lualib_bundle")
local __K2L_CompareValues = ____lualib.__K2L_CompareValues
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_IndexOutOfBoundsException = ____lualib.__K2L_IndexOutOfBoundsException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_JavaRandom = ____lualib.__K2L_JavaRandom
local __K2L_JdkCollections = ____lualib.__K2L_JdkCollections
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf
local __K2L_Unit = ____lualib.__K2L_Unit
local __K2L_Unpack = ____lualib.__K2L_Unpack

local function attempt(label, block)
    local ____ok, ____result = __K2L_DeepPcall(function()
        print(label .. ": " .. __K2L_Str(block()))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_Exception) then
            local e = ____error
            print(label .. ": " .. __K2L_Str(__K2L_KClassOfValue(e).simpleName) .. ": " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
end

local ____lambda_1 = function(____a, ____b)
    local ____x, ____y = ____a >= 0 and ____a % 4 or 0 - -____a % 4, ____b >= 0 and ____b % 4 or 0 - -____b % 4
    if ____x ~= ____y then
        return ____x < ____y and -1 or 1
    end
    return 0
end
local ____lambda_2 = function(a, b) return #a - #b end
local ____lambda_3 = function(a, b) return #a - #b end
local function sorting()
    print("-- sorting")
    local list = __K2L_ListOf(5, 3, 9, 1, 7, 3)
    __K2L_JdkCollections.sort(list)
    print(__K2L_Str(list))
    __K2L_JdkCollections.sort(list, __K2L_JdkCollections.reverseOrder())
    print(__K2L_Str(list))
    __K2L_JdkCollections.sort(list, ____lambda_1)
    print(__K2L_Str(list))
    local words = __K2L_ListOf("pear", "fig", "banana", "kiwi", "apple")
    __K2L_JdkCollections.sort(words)
    print(__K2L_Str(words))
    __K2L_JdkCollections.sort(words, ____lambda_2)
    print(__K2L_Str(words))
    __K2L_JdkCollections.sort(words, __K2L_JdkCollections.reverseOrder(____lambda_3))
    print(__K2L_Str(words))
    __K2L_JdkCollections.reverse(words)
    print(__K2L_Str(words))
    __K2L_JdkCollections.swap(words, 0, words.size - 1)
    print(__K2L_Str(words))
    attempt("swap", function()
        __K2L_JdkCollections.swap(words, 0, 10)
        return __K2L_Unit
    end)
    print(__K2L_JdkCollections.binarySearch_array(__K2L_ReadOnlyListOf(1, 3, 5, 7, 9), 7))
    print(__K2L_JdkCollections.binarySearch_array(__K2L_ReadOnlyListOf(1, 3, 5, 7, 9), 4))
    print(__K2L_JdkCollections.binarySearch_array(__K2L_ReadOnlyListOf("a", "c", "e"), "d"))
    print(__K2L_JdkCollections.binarySearch_array(__K2L_ReadOnlyListOf(9, 7, 5, 3, 1), 7, __K2L_JdkCollections.reverseOrder()))
end

local ____lambda_4 = function(____a_1, ____b_1)
    local ____x_1, ____y_1 = #____a_1, #____b_1
    if ____x_1 ~= ____y_1 then
        return ____x_1 < ____y_1 and -1 or 1
    end
    return 0
end
local ____lambda_5 = function()
    return __K2L_JdkCollections.max(__K2L_ReadOnlyListOf())
end
local ____lambda_6 = function()
    return __K2L_JdkCollections.min(__K2L_ReadOnlyListOf())
end
local function queries()
    print("-- queries")
    local list = __K2L_ReadOnlyListOf(4, 8, 15, 16, 23, 42, 8)
    print(__K2L_NotNull(__K2L_JdkCollections.max(list)))
    print(__K2L_NotNull(__K2L_JdkCollections.min(list)))
    print(__K2L_NotNull(__K2L_JdkCollections.max(list, __K2L_JdkCollections.reverseOrder())))
    print(__K2L_Str(__K2L_JdkCollections.max(__K2L_ReadOnlyListOf("b", "abc", "zz"), ____lambda_4)))
    print(__K2L_JdkCollections.frequency(list, 8))
    print(__K2L_JdkCollections.frequency(list, 99))
    print(__K2L_JdkCollections.frequency(__K2L_ReadOnlyListOf("a", "b", "a", nil), nil))
    print(__K2L_NotNull(__K2L_JdkCollections.max(__K2L_ReadOnlySetOf(3, 1, 2))))
    print(__K2L_JdkCollections.disjoint(__K2L_ReadOnlyListOf(1, 2), __K2L_ReadOnlyListOf(3, 4)))
    print(__K2L_JdkCollections.disjoint(__K2L_ReadOnlyListOf(1, 2), __K2L_ReadOnlyListOf(2, 4)))
    attempt("emptyMax", ____lambda_5)
    attempt("emptyMin", ____lambda_6)
end

local function mutations()
    print("-- mutations")
    local list = __K2L_ListOf(1, 2, 3, 4, 5)
    __K2L_JdkCollections.rotate(list, 2)
    print(__K2L_Str(list))
    __K2L_JdkCollections.rotate(list, -1)
    print(__K2L_Str(list))
    __K2L_JdkCollections.rotate(list, 7)
    print(__K2L_Str(list))
    __K2L_JdkCollections.fill(list, 0)
    print(__K2L_Str(list))
    local target = __K2L_ListOf(0, 0, 0, 0)
    __K2L_JdkCollections.copy(target, __K2L_ReadOnlyListOf(7, 8))
    print(__K2L_Str(target))
    attempt("copy", function()
        __K2L_JdkCollections.copy(__K2L_SingletonListOf(1):toMutableList(), __K2L_ReadOnlyListOf(1, 2))
        return __K2L_Unit
    end)
    print(__K2L_JdkCollections.replaceAll(target, 0, 9))
    print(__K2L_Str(target))
    print(__K2L_JdkCollections.addAll(target, 1, 2, 3))
    print(__K2L_Str(target))
    local set = __K2L_SetOf(1, 2)
    print(__K2L_JdkCollections.addAll(set, 2, 3))
    print(__K2L_Str(set))
    local shuffled = __K2L_IntRange.new(1, 10):toMutableList()
    __K2L_JdkCollections.shuffle(shuffled, __K2L_JavaRandom.new(42))
    print(__K2L_Str(shuffled))
    __K2L_JdkCollections.shuffle(shuffled, __K2L_JavaRandom.new(7))
    print(__K2L_Str(shuffled))
    __K2L_JdkCollections.shuffle(shuffled)
    print(__K2L_Str(shuffled:sorted()))
end

local ____lambda_7 = function() return __K2L_JdkCollections.nCopies(-1, 0) end
local ____lambda_8 = function()
    return __K2L_JdkCollections.emptyList():add(1)
end
local ____lambda_9 = function()
    return __K2L_JdkCollections.singletonList(1):add(1)
end
local function factories()
    print("-- factories")
    print(__K2L_Str(__K2L_JdkCollections.nCopies(3, "ab")))
    print(__K2L_Str(__K2L_JdkCollections.nCopies(0, 1)))
    print(__K2L_Str(__K2L_JdkCollections.emptyList()))
    print(__K2L_Str(__K2L_JdkCollections.emptySet()))
    print(__K2L_Str(__K2L_JdkCollections.emptyMap()))
    print(__K2L_Str(__K2L_JdkCollections.singletonList(5)))
    print(__K2L_Str(__K2L_JdkCollections.singleton("x")))
    print(__K2L_Str(__K2L_JdkCollections.singletonMap("k", 1)))
    print(__K2L_JdkCollections.nCopies(3, 1).size)
    print(__K2L_JdkCollections.nCopies(2, "z"):joinToString("+"))
    attempt("nCopies", ____lambda_7)
    local source = __K2L_ListOf(1, 2, 3)
    local view = __K2L_JdkCollections.unmodifiableList(source)
    print(__K2L_Str(view))
    print(view.size)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = view:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = it * 2
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    attempt("add", function() return view:add(4) end)
    attempt("set", function() return view:set(0, 9) end)
    attempt("remove", function() return view:removeAt(0) end)
    attempt("sort", function()
        __K2L_JdkCollections.sort(view)
        return __K2L_Unit
    end)
    attempt("emptyAdd", ____lambda_8)
    attempt("single", ____lambda_9)
    local set = __K2L_JdkCollections.unmodifiableSet(__K2L_SetOf(3, 1, 2))
    print(__K2L_Str(set))
    print(set:contains(3))
    attempt("setAdd", function() return set:add(4) end)
    local map = __K2L_JdkCollections.unmodifiableMap(__K2L_MapOf(__K2L_Pair.new("a", 1), __K2L_Pair.new("b", 2)))
    print(__K2L_Str(map))
    print(__K2L_Str(map:get("a")))
    attempt("mapPut", function() return map:put("c", 3) end)
    print(__K2L_Str(__K2L_JdkCollections.identity(__K2L_ListOf(1, 2))))
end

local ____lambda_10 = function(a, b) return #b - #a end
local ____lambda_11 = function(it) return it * it end
local function arrays()
    print("-- arrays")
    local ints = __K2L_TypedArrayOf("[I", 5, 2, 8, 1, 9, 3)
    __K2L_JdkCollections.sort_array(ints)
    print(__K2L_Str(__K2L_JdkCollections.arrayToString(ints)))
    local part = __K2L_TypedArrayOf("[I", 9, 8, 7, 6, 5, 4)
    __K2L_JdkCollections.sort_array(part, 1, 4)
    print(__K2L_Str(__K2L_JdkCollections.arrayToString(part)))
    local ____ok_1, ____result_1 = __K2L_DeepPcall(function()
        __K2L_JdkCollections.sort_array(part, 4, 9)
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error_1, __K2L_IndexOutOfBoundsException) then
            local e = ____error_1
            print("sortRange: " .. __K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
    attempt("sortRange2", function()
        __K2L_JdkCollections.sort_array(part, 3, 1)
        return __K2L_Unit
    end)
    local strings = __K2L_TypedArrayOf("[Ljava.lang.String;", "pear", "fig", "banana")
    __K2L_JdkCollections.sort_array(strings)
    print(__K2L_Str(__K2L_JdkCollections.arrayToString(strings)))
    __K2L_JdkCollections.sort_array(strings, ____lambda_10)
    print(__K2L_Str(__K2L_JdkCollections.arrayToString(strings)))
    local filled = __K2L_ListOfSize(5, 0, "[I")
    __K2L_JdkCollections.fill_array(filled, 7)
    print(__K2L_Str(__K2L_JdkCollections.arrayToString(filled)))
    __K2L_JdkCollections.fill_array(filled, 1, 3, 0)
    print(__K2L_Str(__K2L_JdkCollections.arrayToString(filled)))
    print(__K2L_Str(__K2L_JdkCollections.arrayToString(__K2L_JdkCollections.copyOf(ints, 3, 0))))
    print(__K2L_Str(__K2L_JdkCollections.arrayToString(__K2L_JdkCollections.copyOf(ints, 9, 0))))
    print(__K2L_Str(__K2L_JdkCollections.arrayToString(__K2L_JdkCollections.copyOfRange(ints, 2, 4, 0))))
    print(__K2L_Str(__K2L_JdkCollections.arrayToString(__K2L_JdkCollections.copyOfRange(ints, 4, 9, 0))))
    print(__K2L_Str(__K2L_JdkCollections.arrayToString(__K2L_JdkCollections.copyOf(strings, 5, nil))))
    print(__K2L_Str(__K2L_JdkCollections.arrayToString(__K2L_JdkCollections.copyOf(__K2L_TypedArrayOf("[Z", true), 3, false))))
    attempt("copyRange", function()
        return __K2L_JdkCollections.copyOfRange(ints, 5, 2, 0)
    end)
    print(__K2L_Str(__K2L_JdkCollections.arrayToString(nil)))
    print(__K2L_JdkCollections.arrayEquals(__K2L_TypedArrayOf("[I", 1, 2), __K2L_TypedArrayOf("[I", 1, 2)))
    print(__K2L_JdkCollections.arrayEquals(__K2L_TypedArrayOf("[I", 1, 2), __K2L_TypedArrayOf("[I", 2, 1)))
    print(__K2L_JdkCollections.arrayEquals(__K2L_TypedArrayOf("[I", 1, 2), __K2L_TypedArrayOf("[I", 1, 2, 3)))
    print(__K2L_JdkCollections.arrayHashCode(__K2L_TypedArrayOf("[I", 1, 2, 3)))
    print(__K2L_JdkCollections.arrayHashCode(__K2L_TypedArrayOf("[Ljava.lang.String;", "a", "b")))
    print(__K2L_JdkCollections.arrayHashCode(nil))
    print(__K2L_Str(__K2L_JdkCollections.deepToString(__K2L_TypedArrayOf("[[I", __K2L_TypedArrayOf("[I", 1, 2), __K2L_TypedArrayOf("[I", 3)))))
    print(__K2L_Str(__K2L_JdkCollections.deepToString(__K2L_TypedArrayOf("[[Ljava.io.Serializable;", __K2L_TypedArrayOf("[Ljava.lang.Integer;", 1, 2), __K2L_TypedArrayOf("[Ljava.io.Serializable;", 3, __K2L_TypedArrayOf("[Ljava.lang.Integer;", 4))))))
    local sorted = __K2L_TypedArrayOf("[I", 1, 3, 5, 7, 9, 11)
    print(__K2L_JdkCollections.binarySearch_array(sorted, 7))
    print(__K2L_JdkCollections.binarySearch_array(sorted, 4))
    print(__K2L_JdkCollections.binarySearch_array(sorted, 2, 5, 9))
    print(__K2L_JdkCollections.binarySearch_array(sorted, 2, 5, 11))
    print(__K2L_JdkCollections.binarySearch_array(__K2L_TypedArrayOf("[Ljava.lang.String;", "a", "c", "e"), "c"))
    local squares = __K2L_ListOfSize(5, 0, "[I")
    __K2L_JdkCollections.setAll(squares, ____lambda_11)
    print(__K2L_Str(__K2L_JdkCollections.arrayToString(squares)))
    local list = __K2L_JdkCollections.asList(3, 1, 2)
    print(__K2L_Str(list))
    list:set(0, 10)
    print(__K2L_Str(list))
    print(__K2L_Str(list:sorted()))
    __K2L_JdkCollections.sort(list)
    print(__K2L_Str(list))
    attempt("asListAdd", function() return list:add(4) end)
    attempt("asListRemove", function() return list:removeAt(0) end)
    print(__K2L_JdkCollections.asList("x", "y").size)
    print(__K2L_Str(__K2L_JdkCollections.asList(__K2L_Unpack(__K2L_TypedArrayOf("[Ljava.lang.Integer;", 1, 2, 3)))))
end

local function main()
    sorting()
    queries()
    mutations()
    factories()
    arrays()
end

__K2L_DeepMain(main)
return {attempt = attempt, sorting = sorting, queries = queries, mutations = mutations, factories = factories, arrays = arrays}
