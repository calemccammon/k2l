local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_GenerateSequence = ____lualib.__K2L_GenerateSequence
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Random = ____lualib.__K2L_Random
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_SequenceOf = ____lualib.__K2L_SequenceOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_Unit = ____lualib.__K2L_Unit

local function seq()
    return __K2L_SequenceOf(3, 1, 2)
end

local function nullableSeq()
    return __K2L_SequenceOf(3, nil, 2)
end

local function sequenceFunctions()
    print(seq():elementAtOrElse(5, function(it) return -it end))
    print(seq():firstNotNullOf(function(it) return it < 3 and it * 10 or nil end))
    print(__K2L_Str(seq():firstNotNullOfOrNull(function(it) return it > 5 and it or nil end)))
    print(seq():indexOfLast(function(it) return it > 1 end))
    print(seq():lastIndexOf(2))
    print(__K2L_Str(seq():filterIndexedTo(__K2L_ListOf(), function(i, _) return i > 0 end)))
    print(__K2L_Str(__K2L_SequenceOf(1, "a"):filter(function(x) return type(x) == "string" end):toList()))
    print(__K2L_Str(__K2L_SequenceOf(1, "a"):filterTo(__K2L_ListOf(), function(x) return math.type(x) == "integer" end)))
    print(__K2L_Str(nullableSeq():filterNotNullTo(__K2L_ListOf())))
    print(__K2L_Str(seq():filterNotTo(__K2L_ListOf(), function(it) return it > 2 end)))
    print(__K2L_Str(seq():filterTo(__K2L_ListOf(), function(it) return it > 2 end)))
    print(__K2L_Str(seq():associateByTo(__K2L_MapOf(), function(it) return it * 2 end)))
    print(__K2L_Str(seq():associateTo(__K2L_MapOf(), function(it) return __K2L_Pair.new(it, it) end)))
    print(__K2L_Str(seq():associateWithTo(__K2L_MapOf(), function(it) return it + 1 end)))
    print(__K2L_Str(seq():toHashSet()))
    print(__K2L_Str(seq():toMutableList()))
    print(__K2L_Str(seq():toMutableSet()))
    print(__K2L_Str(seq():flatMap(function(it) return __K2L_ReadOnlyListOf(it, it) end):toList()))
    print(__K2L_Str(seq():flatMapIndexed(function(i, x) return __K2L_ReadOnlyListOf(i, x) end):toList()))
    print(__K2L_Str(seq():flatMapTo(__K2L_ListOf(), function(it) return __K2L_SingletonListOf(it) end)))
    print(__K2L_Str(seq():flatMapIndexedTo(__K2L_ListOf(), function(i, x) return __K2L_SingletonListOf(i + x) end)))
    print(__K2L_Str(seq():groupByTo(__K2L_MapOf(), function(it) return math.fmod(it, 2) end)))
    print(__K2L_Str(seq():groupingBy(function(it) return math.fmod(it, 2) end):eachCount()))
    print(__K2L_Str(seq():mapIndexedNotNullTo(__K2L_ListOf(), function(i, x) return i > 0 and x or nil end)))
    print(__K2L_Str(seq():mapIndexedTo(__K2L_ListOf(), function(i, x) return i * x end)))
    print(__K2L_Str(seq():mapNotNullTo(__K2L_ListOf(), function(it) return it > 1 and it or nil end)))
    print(__K2L_Str(seq():mapTo(__K2L_ListOf(), function(it) return it * 3 end)))
    print(seq():maxOfWith(__K2L_CompareBy(function(it) return it end), function(it) return -it end))
    print(__K2L_Str(seq():maxOfWithOrNull(__K2L_CompareBy(function(it) return it end), function(it) return -it end)))
    print(seq():minOfWith(__K2L_CompareBy(function(it) return it end), function(it) return -it end))
    print(__K2L_Str(seq():minOfWithOrNull(__K2L_CompareBy(function(it) return it end), function(it) return -it end)))
    print(seq():maxWith(__K2L_CompareBy(function(it) return it end)))
    print(__K2L_Str(seq():maxWithOrNull(__K2L_CompareBy(function(it) return it end))))
    print(seq():minWith(__K2L_CompareBy(function(it) return it end)))
    print(__K2L_Str(seq():minWithOrNull(__K2L_CompareBy(function(it) return it end))))
    print(seq():reduceIndexed(function(i, a, x) return a + i * x end))
    print(__K2L_Str(seq():reduceIndexedOrNull(function(i, a, x) return a + i * x end)))
    print(__K2L_Str(seq():reduceOrNull(function(a, x) return a * x end)))
    print(__K2L_Str(__K2L_SequenceOf():reduceOrNull(function(a, x) return a * x end)))
    print(__K2L_Str(seq():runningFoldIndexed(0, function(i, a, x) return a + i + x end):toList()))
    print(__K2L_Str(seq():runningReduceIndexed(function(i, a, x) return a + i * x end):toList()))
    print(__K2L_Str(seq():scanIndexed(1, function(i, a, x) return a * x + i end):toList()))
    print(seq():sumBy(function(it) return it * 2 end))
    print(__K2L_Str(seq():sumByDouble(function(it) return it / 2.0 end)))
    print(seq():requireNoNulls():count())
    print(__K2L_Str(seq():minus(1):toList()))
    print(__K2L_Str(seq():minusAll(__K2L_ArrayOf(1, 2)):toList()))
    print(__K2L_Str(seq():minusAll(__K2L_SingletonListOf(3)):toList()))
    print(__K2L_Str(seq():minusAll(__K2L_SequenceOf(2)):toList()))
    print(__K2L_Str(seq():minus(3):toList()))
    print(__K2L_Str(seq():plusAll(__K2L_ArrayOf(7)):toList()))
    print(__K2L_Str(seq():plus(8):toList()))
    print(__K2L_Str(seq():joinTo(__K2L_StringBuilder.new(), "-")))
    print(seq():shuffled(__K2L_Random.seeded(1)):count())
    print(seq():elementAt(1))
    print(seq():take(2):sum())
    print(__K2L_Str(seq():scan(0, function(a, x) return a + x end):toList()))
    print(__K2L_Str(seq():zip(__K2L_SequenceOf("a", "b"), function(a, b) return a .. b end):toList()))
    print(__K2L_Str(seq():windowed(2, nil, nil, function(it) return it:sum() end):toList()))
    print(__K2L_Str(seq():chunked(2, function(it) return it.size end):toList()))
    seq():forEachIndexed(function(i, x)
        io.write(i .. x .. " ")
    end)
    print("kotlin.Unit")
    print(__K2L_Str(seq():sortedWith(__K2L_CompareBy(function(it) return -it end)):toList()))
    print(__K2L_ReadOnlyListOf(3, 1):maxOfWith(__K2L_CompareBy(function(it) return it end), function(it) return -it end))
    print(__K2L_ReadOnlyListOf(3, 1):minOfWith(__K2L_CompareBy(function(it) return it end), function(it) return -it end))
    print(__K2L_Str(__K2L_ReadOnlyListOf(3, 1):maxOfWithOrNull(__K2L_CompareBy(function(it) return it end), function(it) return -it end)))
    print(__K2L_Str(__K2L_ReadOnlyListOf():minOfWithOrNull(__K2L_CompareBy(function(it) return it end), function(it) return -it end)))
    print(__K2L_ArrayOf(3, 1):maxOfWith(__K2L_CompareBy(function(it) return it end), function(it) return -it end))
    print(__K2L_ArrayOf(3, 1):minOfWith(__K2L_CompareBy(function(it) return it end), function(it) return -it end))
    print(__K2L_SingletonMapOf(__K2L_Pair.new(1, 2)):getEntries():maxOfWith(__K2L_CompareBy(function(it) return it end), function(it) return it.value end))
    print(__K2L_StringToList("ab"):maxOfWith(__K2L_CompareBy(function(it) return it end), function(it) return it:byte() end))
    print(seq():count())
    print((seq() or __K2L_SequenceOf()):count())
    print(__K2L_Str(seq():map(function(it) return -it end):toSortedSet()))
end

local function list()
    return __K2L_ReadOnlyListOf(3, 1, 2)
end

local function nullableList()
    return __K2L_ReadOnlyListOf(3, nil, 2)
end

local function iterableFunctions()
    print(list():elementAtOrElse(5, function(it) return -it end))
    print(list():firstNotNullOf(function(it) return it < 3 and it * 10 or nil end))
    print(__K2L_Str(list():firstNotNullOfOrNull(function(it) return it > 5 and it or nil end)))
    print(list():indexOfLast(function(it) return it > 1 end))
    print(list():lastIndexOf(2))
    local ____list = list()
    local ____destination = __K2L_ListOf()
    for ____i = 1, ____list.size do
        local _ = ____list[____i]
        local i = ____i - 1
        if i > 0 then
            ____destination:add(_)
        end
    end
    print(__K2L_Str(____destination))
    print(__K2L_Str(__K2L_ReadOnlyListOf(1, "a"):filter(function(x) return type(x) == "string" end)))
    print(__K2L_Str(__K2L_ReadOnlyListOf(1, "a"):filterTo(__K2L_ListOf(), function(x) return math.type(x) == "integer" end)))
    print(__K2L_Str(nullableList():filterNotNullTo(__K2L_ListOf())))
    local ____list_1 = list()
    local ____destination_1 = __K2L_ListOf()
    for _, it in ipairs(____list_1) do
        if not (it > 2) then
            ____destination_1:add(it)
        end
    end
    print(__K2L_Str(____destination_1))
    print(__K2L_Str(list():filterTo(__K2L_ListOf(), function(it) return it > 2 end)))
    print(__K2L_Str(list():associateByTo(__K2L_MapOf(), function(it) return it * 2 end)))
    local ____list_2 = list()
    local ____destination_2 = __K2L_MapOf()
    for _, it in ipairs(____list_2) do
        local ____value = __K2L_Pair.new(it, it)
        ____destination_2:put(____value.first, ____value.second)
    end
    print(__K2L_Str(____destination_2))
    print(__K2L_Str(list():associateWithTo(__K2L_MapOf(), function(it) return it + 1 end)))
    print(__K2L_Str(list():toHashSet()))
    print(__K2L_Str(list():toMutableList()))
    print(__K2L_Str(list():toMutableSet()))
    print(__K2L_Str(list():flatMap(function(it) return __K2L_ReadOnlyListOf(it, it) end)))
    print(__K2L_Str(list():flatMapIndexed(function(i, x) return __K2L_ReadOnlyListOf(i, x) end)))
    local ____list_3 = list()
    local ____destination_3 = __K2L_ListOf()
    for _, it in ipairs(____list_3) do
        ____destination_3:addAll(__K2L_SingletonListOf(it))
    end
    print(__K2L_Str(____destination_3))
    print(__K2L_Str(list():flatMapIndexedTo(__K2L_ListOf(), function(i, x) return __K2L_SingletonListOf(i + x) end)))
    local ____list_4 = list()
    local ____destination_4 = __K2L_MapOf()
    for _, it in ipairs(____list_4) do
        local ____value_1 = math.fmod(it, 2)
        local ____group = ____destination_4:get(____value_1)
        if ____group == nil then
            ____group = __K2L_ListOf()
            ____destination_4:put(____value_1, ____group)
        end
        ____group:add(it)
    end
    print(__K2L_Str(____destination_4))
    print(__K2L_Str(list():groupingBy(function(it) return math.fmod(it, 2) end):eachCount()))
    print(__K2L_Str(list():mapIndexedNotNullTo(__K2L_ListOf(), function(i, x) return i > 0 and x or nil end)))
    print(__K2L_Str(list():mapIndexedTo(__K2L_ListOf(), function(i, x) return i * x end)))
    local ____list_5 = list()
    local ____destination_5 = __K2L_ListOf()
    for _, it in ipairs(____list_5) do
        local ____result
        ____result = it > 1 and it or nil
        local ____value_2 = ____result
        if ____value_2 ~= nil then
            ____destination_5:add(____result)
        end
    end
    print(__K2L_Str(____destination_5))
    print(__K2L_Str(list():mapTo(__K2L_ListOf(), function(it) return it * 3 end)))
    print(list():maxOfWith(__K2L_CompareBy(function(it) return it end), function(it) return -it end))
    print(__K2L_Str(list():maxOfWithOrNull(__K2L_CompareBy(function(it) return it end), function(it) return -it end)))
    print(list():minOfWith(__K2L_CompareBy(function(it) return it end), function(it) return -it end))
    print(__K2L_Str(list():minOfWithOrNull(__K2L_CompareBy(function(it) return it end), function(it) return -it end)))
    print(list():maxWith(__K2L_CompareBy(function(it) return it end)))
    print(__K2L_Str(list():maxWithOrNull(__K2L_CompareBy(function(it) return it end))))
    print(list():minWith(__K2L_CompareBy(function(it) return it end)))
    print(__K2L_Str(list():minWithOrNull(__K2L_CompareBy(function(it) return it end))))
    print(list():reduceIndexed(function(i, a, x) return a + i * x end))
    print(__K2L_Str(list():reduceIndexedOrNull(function(i, a, x) return a + i * x end)))
    print(__K2L_Str(list():reduceOrNull(function(a, x) return a * x end)))
    print(__K2L_Str(__K2L_ReadOnlyListOf():reduceOrNull(function(a, x) return a * x end)))
    print(__K2L_Str(list():runningFoldIndexed(0, function(i, a, x) return a + i + x end)))
    print(__K2L_Str(list():runningReduceIndexed(function(i, a, x) return a + i * x end)))
    print(__K2L_Str(list():scanIndexed(1, function(i, a, x) return a * x + i end)))
    local ____list_6 = list()
    local ____sum = 0
    for _, it in ipairs(____list_6) do
        ____sum = ____sum + it * 2
    end
    print(____sum)
    local ____list_7 = list()
    local ____sum_1 = 0.0
    for _, it in ipairs(____list_7) do
        ____sum_1 = ____sum_1 + it / 2.0
    end
    print(__K2L_Str(____sum_1))
    print(list():requireNoNulls():count())
    print(__K2L_Str(list():minus(1)))
    print(__K2L_Str(list():minusAll(__K2L_ArrayOf(1, 2))))
    print(__K2L_Str(list():minusAll(__K2L_SingletonListOf(3))))
    print(__K2L_Str(list():minusAll(__K2L_SequenceOf(2))))
    print(__K2L_Str(list():minus(3)))
    print(__K2L_Str(list():plusAll(__K2L_ArrayOf(7))))
    print(__K2L_Str(list():plus(8)))
    print(__K2L_Str(list():joinTo(__K2L_StringBuilder.new(), "-")))
    print(list():shuffled(__K2L_Random.seeded(1)):count())
    print(list():elementAt(1))
    print(list():take(2):sum())
    print(__K2L_Str(list():scan(0, function(a, x) return a + x end)))
    print(__K2L_Str(list():zip(__K2L_ReadOnlyListOf("a", "b"), function(a, b) return a .. b end)))
    print(__K2L_Str(list():windowed(2, nil, nil, function(it) return it:sum() end)))
    print(__K2L_Str(list():chunked(2, function(it) return it.size end)))
    local ____list_8 = list()
    for i = 0, ____list_8.size - 1 do
        local x = ____list_8[i + 1]
        io.write(i .. x .. " ")
    end
    print("kotlin.Unit")
    print(__K2L_Str(list():sortedWith(__K2L_CompareBy(function(it) return -it end))))
    print(__K2L_ReadOnlyListOf(3, 1):maxOfWith(__K2L_CompareBy(function(it) return it end), function(it) return -it end))
    print(__K2L_ReadOnlyListOf(3, 1):minOfWith(__K2L_CompareBy(function(it) return it end), function(it) return -it end))
    print(__K2L_Str(__K2L_ReadOnlyListOf(3, 1):maxOfWithOrNull(__K2L_CompareBy(function(it) return it end), function(it) return -it end)))
    print(__K2L_Str(__K2L_ReadOnlyListOf():minOfWithOrNull(__K2L_CompareBy(function(it) return it end), function(it) return -it end)))
    print(__K2L_ArrayOf(3, 1):maxOfWith(__K2L_CompareBy(function(it) return it end), function(it) return -it end))
    print(__K2L_ArrayOf(3, 1):minOfWith(__K2L_CompareBy(function(it) return it end), function(it) return -it end))
    print(__K2L_SingletonMapOf(__K2L_Pair.new(1, 2)):getEntries():maxOfWith(__K2L_CompareBy(function(it) return it end), function(it) return it.value end))
    print(__K2L_StringToList("ab"):maxOfWith(__K2L_CompareBy(function(it) return it end), function(it) return it:byte() end))
    print(list():count())
    print((list() or __K2L_ListOf()):count())
end

local function interleaving()
    local log = __K2L_ListOf()
    local dest = __K2L_SequenceOf(1, 2):map(function(it)
        log:add("map " .. it)
        return it * 10
    end):mapTo(__K2L_ListOf(), function(it)
        log:add("to " .. it)
        return it + 1
    end)
    print(__K2L_Str(dest) .. " " .. __K2L_Str(log))
    log:clear()
    local groups = __K2L_SequenceOf(1, 2, 3):onEach(function(it)
        log:add("each " .. it)
    end):groupingBy(function(it)
        log:add("key " .. it)
        return math.fmod(it, 2)
    end):eachCount()
    print(__K2L_Str(groups) .. " " .. __K2L_Str(log))
    log:clear()
    print(__K2L_GenerateSequence(1, function(it) return it + 1 end):firstNotNullOf(function(it)
        log:add("try " .. it)
        return it > 2 and it or nil
    end))
    print(__K2L_Str(log))
    print(__K2L_Str(__K2L_SequenceOf(1, nil):requireNoNulls():take(1):toList()))
    local ____value_3 = __K2L_RunCatching(function()
        return __K2L_SequenceOf(1, nil):requireNoNulls():toList()
    end):exceptionOrNull()
    print(__K2L_InstanceOf(____value_3, __K2L_IllegalArgumentException))
    print(__K2L_Str((__K2L_SequenceOf(1, 2) or __K2L_SequenceOf()):toList()))
    local none = nil
    print((none or __K2L_SequenceOf()):count())
end

local function falseValues()
    print(__K2L_Str(__K2L_SequenceOf(1, 2):zip(__K2L_SequenceOf(2, 1), function(a, b) return a > b end):toList()))
    print(__K2L_Str(__K2L_SequenceOf(1, 3, 2):zipWithNext(function(a, b) return a > b end):toList()))
    print(__K2L_Str(__K2L_SequenceOf(1, 2, 3):windowed(2, nil, nil, function(it) return it.size > 5 end):toList()))
    print(__K2L_Str(__K2L_SequenceOf(1, 2, 3):groupBy(function(it) return math.fmod(it, 2) end, function(it) return it > 1 end)))
    print(__K2L_Str(__K2L_SequenceOf(1, 2, 3):associateBy(function(it) return it end, function(it) return it > 2 end)))
    print(__K2L_SequenceOf(3, 1, 2):maxBy(function(it) return it < 2 end))
    print(__K2L_ReadOnlyListOf(3, 1, 2):maxBy(function(it) return it < 2 end))
    print(__K2L_Str(__K2L_ReadOnlyListOf(3, 1, 2):minByOrNull(function(it) return it > 2 end)))
    print(__K2L_Str(__K2L_Text.chunked("abcd", 2, function(it) return __K2L_Equals(it, "ab") end)))
    print(__K2L_Str(__K2L_Text.windowed("abcd", 2, nil, nil, function(it) return __K2L_Equals(it, "bc") end)))
end

local function main()
    falseValues()
    sequenceFunctions()
    iterableFunctions()
    interleaving()
end

main()
return {seq = seq, nullableSeq = nullableSeq, sequenceFunctions = sequenceFunctions, list = list, nullableList = nullableList, iterableFunctions = iterableFunctions, interleaving = interleaving, falseValues = falseValues}
