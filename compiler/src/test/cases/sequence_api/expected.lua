local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_CompareValues = ____lualib.__K2L_CompareValues
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_GenerateSequence = ____lualib.__K2L_GenerateSequence
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Random = ____lualib.__K2L_Random
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SequenceOf = ____lualib.__K2L_SequenceOf
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

local ____lambda_1 = function(it) return -it end
local ____lambda_2 = function(it) return it < 3 and it * 10 or nil end
local ____lambda_3 = function(it) return it > 5 and it or nil end
local ____lambda_4 = function(it) return it > 1 end
local ____lambda_5 = function(i, _) return i > 0 end
local ____lambda_6 = function(x) return type(x) == "string" end
local ____lambda_7 = function(x) return math.type(x) == "integer" end
local ____lambda_8 = function(it) return it > 2 end
local ____lambda_9 = function(it) return it > 2 end
local ____lambda_10 = function(it) return it * 2 end
local ____lambda_11 = function(it) return __K2L_Pair.new(it, it) end
local ____lambda_12 = function(it) return it + 1 end
local ____lambda_13 = function(it) return __K2L_ListOf(it, it) end
local ____lambda_14 = function(i, x) return __K2L_ListOf(i, x) end
local ____lambda_15 = function(it) return __K2L_ListOf(it) end
local ____lambda_16 = function(i, x) return __K2L_ListOf(i + x) end
local ____lambda_17 = function(it) return it % 2 end
local ____lambda_18 = function(it) return it % 2 end
local ____lambda_19 = function(i, x) return i > 0 and x or nil end
local ____lambda_20 = function(i, x) return i * x end
local ____lambda_21 = function(it) return it > 1 and it or nil end
local ____lambda_22 = function(it) return it * 3 end
local ____lambda_23 = function(____a, ____b)
    local ____x, ____y = ____a, ____b
    if ____x ~= ____y then
        return ____x < ____y and -1 or 1
    end
    return 0
end
local ____lambda_24 = function(it) return -it end
local ____lambda_25 = function(____a_1, ____b_1)
    local ____x_1, ____y_1 = ____a_1, ____b_1
    if ____x_1 ~= ____y_1 then
        return ____x_1 < ____y_1 and -1 or 1
    end
    return 0
end
local ____lambda_26 = function(it) return -it end
local ____lambda_27 = function(____a_2, ____b_2)
    local ____x_2, ____y_2 = ____a_2, ____b_2
    if ____x_2 ~= ____y_2 then
        return ____x_2 < ____y_2 and -1 or 1
    end
    return 0
end
local ____lambda_28 = function(it) return -it end
local ____lambda_29 = function(____a_3, ____b_3)
    local ____x_3, ____y_3 = ____a_3, ____b_3
    if ____x_3 ~= ____y_3 then
        return ____x_3 < ____y_3 and -1 or 1
    end
    return 0
end
local ____lambda_30 = function(it) return -it end
local ____lambda_31 = function(____a_4, ____b_4)
    local ____x_4, ____y_4 = ____a_4, ____b_4
    if ____x_4 ~= ____y_4 then
        return ____x_4 < ____y_4 and -1 or 1
    end
    return 0
end
local ____lambda_32 = function(____a_5, ____b_5)
    local ____x_5, ____y_5 = ____a_5, ____b_5
    if ____x_5 ~= ____y_5 then
        return ____x_5 < ____y_5 and -1 or 1
    end
    return 0
end
local ____lambda_33 = function(____a_6, ____b_6)
    local ____x_6, ____y_6 = ____a_6, ____b_6
    if ____x_6 ~= ____y_6 then
        return ____x_6 < ____y_6 and -1 or 1
    end
    return 0
end
local ____lambda_34 = function(____a_7, ____b_7)
    local ____x_7, ____y_7 = ____a_7, ____b_7
    if ____x_7 ~= ____y_7 then
        return ____x_7 < ____y_7 and -1 or 1
    end
    return 0
end
local ____lambda_35 = function(i, a, x) return a + i * x end
local ____lambda_36 = function(i, a, x) return a + i * x end
local ____lambda_37 = function(a, x) return a * x end
local ____lambda_38 = function(a, x) return a * x end
local ____lambda_39 = function(i, a, x) return a + i + x end
local ____lambda_40 = function(i, a, x) return a + i * x end
local ____lambda_41 = function(i, a, x) return a * x + i end
local ____lambda_42 = function(it) return it * 2 end
local ____lambda_43 = function(it) return it / 2.0 end
local ____lambda_44 = function(a, x) return a + x end
local ____lambda_45 = function(a, b) return a .. b end
local ____lambda_46 = function(it) return it:sum() end
local ____lambda_47 = function(it) return it.size end
local ____lambda_48 = function(____a_8, ____b_8)
    local ____x_8, ____y_8 = -____a_8, -____b_8
    if ____x_8 ~= ____y_8 then
        return ____x_8 < ____y_8 and -1 or 1
    end
    return 0
end
local ____lambda_49 = function(____a_9, ____b_9)
    local ____x_9, ____y_9 = ____a_9, ____b_9
    if ____x_9 ~= ____y_9 then
        return ____x_9 < ____y_9 and -1 or 1
    end
    return 0
end
local ____lambda_50 = function(it) return -it end
local ____lambda_51 = function(____a_10, ____b_10)
    local ____x_10, ____y_10 = ____a_10, ____b_10
    if ____x_10 ~= ____y_10 then
        return ____x_10 < ____y_10 and -1 or 1
    end
    return 0
end
local ____lambda_52 = function(it) return -it end
local ____lambda_53 = function(____a_11, ____b_11)
    local ____x_11, ____y_11 = ____a_11, ____b_11
    if ____x_11 ~= ____y_11 then
        return ____x_11 < ____y_11 and -1 or 1
    end
    return 0
end
local ____lambda_54 = function(it) return -it end
local ____lambda_55 = function(____a_12, ____b_12)
    local ____x_12, ____y_12 = ____a_12, ____b_12
    if ____x_12 ~= ____y_12 then
        return ____x_12 < ____y_12 and -1 or 1
    end
    return 0
end
local ____lambda_56 = function(it) return -it end
local ____lambda_57 = function(____a_13, ____b_13)
    local ____x_13, ____y_13 = ____a_13, ____b_13
    if ____x_13 ~= ____y_13 then
        return ____x_13 < ____y_13 and -1 or 1
    end
    return 0
end
local ____lambda_58 = function(it) return -it end
local ____lambda_59 = function(____a_14, ____b_14)
    local ____x_14, ____y_14 = ____a_14, ____b_14
    if ____x_14 ~= ____y_14 then
        return ____x_14 < ____y_14 and -1 or 1
    end
    return 0
end
local ____lambda_60 = function(it) return -it end
local ____lambda_61 = function(____a_15, ____b_15)
    local ____x_15, ____y_15 = ____a_15, ____b_15
    if ____x_15 ~= ____y_15 then
        return ____x_15 < ____y_15 and -1 or 1
    end
    return 0
end
local ____lambda_62 = function(it) return it.value end
local ____lambda_63 = function(____a_16, ____b_16)
    local ____x_16, ____y_16 = ____a_16, ____b_16
    if ____x_16 ~= ____y_16 then
        return ____x_16 < ____y_16 and -1 or 1
    end
    return 0
end
local ____lambda_64 = function(it) return it:byte() end
local ____lambda_65 = function(it) return -it end
local function sequenceFunctions()
    print(seq():elementAtOrElse(5, ____lambda_1))
    print(seq():firstNotNullOf(____lambda_2))
    print(__K2L_Str(seq():firstNotNullOfOrNull(____lambda_3)))
    print(seq():indexOfLast(____lambda_4))
    print(seq():lastIndexOf(2))
    print(__K2L_Str(seq():filterIndexedTo(__K2L_ListOf(), ____lambda_5)))
    print(__K2L_Str(__K2L_SequenceOf(1, "a"):filter(____lambda_6):toList()))
    print(__K2L_Str(__K2L_SequenceOf(1, "a"):filterTo(__K2L_ListOf(), ____lambda_7)))
    print(__K2L_Str(nullableSeq():filterNotNullTo(__K2L_ListOf())))
    print(__K2L_Str(seq():filterNotTo(__K2L_ListOf(), ____lambda_8)))
    print(__K2L_Str(seq():filterTo(__K2L_ListOf(), ____lambda_9)))
    print(__K2L_Str(seq():associateByTo(__K2L_MapOf(), ____lambda_10)))
    print(__K2L_Str(seq():associateTo(__K2L_MapOf(), ____lambda_11)))
    print(__K2L_Str(seq():associateWithTo(__K2L_MapOf(), ____lambda_12)))
    print(__K2L_Str(seq():toHashSet()))
    print(__K2L_Str(seq():toMutableList()))
    print(__K2L_Str(seq():toMutableSet()))
    print(__K2L_Str(seq():flatMap(____lambda_13):toList()))
    print(__K2L_Str(seq():flatMapIndexed(____lambda_14):toList()))
    print(__K2L_Str(seq():flatMapTo(__K2L_ListOf(), ____lambda_15)))
    print(__K2L_Str(seq():flatMapIndexedTo(__K2L_ListOf(), ____lambda_16)))
    print(__K2L_Str(seq():groupByTo(__K2L_MapOf(), ____lambda_17)))
    print(__K2L_Str(seq():groupingBy(____lambda_18):eachCount()))
    print(__K2L_Str(seq():mapIndexedNotNullTo(__K2L_ListOf(), ____lambda_19)))
    print(__K2L_Str(seq():mapIndexedTo(__K2L_ListOf(), ____lambda_20)))
    print(__K2L_Str(seq():mapNotNullTo(__K2L_ListOf(), ____lambda_21)))
    print(__K2L_Str(seq():mapTo(__K2L_ListOf(), ____lambda_22)))
    print(seq():maxOfWith(____lambda_23, ____lambda_24))
    print(__K2L_Str(seq():maxOfWithOrNull(____lambda_25, ____lambda_26)))
    print(seq():minOfWith(____lambda_27, ____lambda_28))
    print(__K2L_Str(seq():minOfWithOrNull(____lambda_29, ____lambda_30)))
    print(seq():maxWith(____lambda_31))
    print(__K2L_Str(seq():maxWithOrNull(____lambda_32)))
    print(seq():minWith(____lambda_33))
    print(__K2L_Str(seq():minWithOrNull(____lambda_34)))
    print(seq():reduceIndexed(____lambda_35))
    print(__K2L_Str(seq():reduceIndexedOrNull(____lambda_36)))
    print(__K2L_Str(seq():reduceOrNull(____lambda_37)))
    print(__K2L_Str(__K2L_SequenceOf():reduceOrNull(____lambda_38)))
    print(__K2L_Str(seq():runningFoldIndexed(0, ____lambda_39):toList()))
    print(__K2L_Str(seq():runningReduceIndexed(____lambda_40):toList()))
    print(__K2L_Str(seq():scanIndexed(1, ____lambda_41):toList()))
    print(seq():sumBy(____lambda_42))
    print(seq():sumByDouble(____lambda_43))
    print(seq():requireNoNulls():count())
    print(__K2L_Str(seq():minus(1):toList()))
    print(__K2L_Str(seq():minusAll(__K2L_ArrayOf(1, 2)):toList()))
    print(__K2L_Str(seq():minusAll(__K2L_ListOf(3)):toList()))
    print(__K2L_Str(seq():minusAll(__K2L_SequenceOf(2)):toList()))
    print(__K2L_Str(seq():minus(3):toList()))
    print(__K2L_Str(seq():plusAll(__K2L_ArrayOf(7)):toList()))
    print(__K2L_Str(seq():plus(8):toList()))
    print(__K2L_Str(seq():joinTo(__K2L_StringBuilder.new(), "-")))
    print(seq():shuffled(__K2L_Random.seeded(1)):count())
    print(seq():elementAt(1))
    print(seq():take(2):sum())
    print(__K2L_Str(seq():scan(0, ____lambda_44):toList()))
    print(__K2L_Str(seq():zip(__K2L_SequenceOf("a", "b"), ____lambda_45):toList()))
    print(__K2L_Str(seq():windowed(2, nil, nil, ____lambda_46):toList()))
    print(__K2L_Str(seq():chunked(2, ____lambda_47):toList()))
    seq():forEachIndexed(function(i, x)
        io.write(i .. x .. " ")
    end)
    print("kotlin.Unit")
    print(__K2L_Str(seq():sortedWith(____lambda_48):toList()))
    print(__K2L_ListOf(3, 1):maxOfWith(____lambda_49, ____lambda_50))
    print(__K2L_ListOf(3, 1):minOfWith(____lambda_51, ____lambda_52))
    print(__K2L_Str(__K2L_ListOf(3, 1):maxOfWithOrNull(____lambda_53, ____lambda_54)))
    print(__K2L_Str(__K2L_ListOf():minOfWithOrNull(____lambda_55, ____lambda_56)))
    print(__K2L_ArrayOf(3, 1):maxOfWith(____lambda_57, ____lambda_58))
    print(__K2L_ArrayOf(3, 1):minOfWith(____lambda_59, ____lambda_60))
    print(__K2L_MapOf(__K2L_Pair.new(1, 2)):getEntries():maxOfWith(____lambda_61, ____lambda_62))
    print(__K2L_StringToList("ab"):maxOfWith(____lambda_63, ____lambda_64))
    print(seq():count())
    print((seq() or __K2L_SequenceOf()):count())
    print(__K2L_Str(seq():map(____lambda_65):toSortedSet()))
end

local function list()
    return __K2L_ListOf(3, 1, 2)
end

local function nullableList()
    return __K2L_ListOf(3, nil, 2)
end

local ____lambda_66 = function(it) return -it end
local ____lambda_67 = function(it) return it < 3 and it * 10 or nil end
local ____lambda_68 = function(it) return it > 5 and it or nil end
local ____lambda_69 = function(it) return it > 1 end
local ____lambda_70 = function(x) return type(x) == "string" end
local ____lambda_71 = function(x) return math.type(x) == "integer" end
local ____lambda_72 = function(it) return it > 2 end
local ____lambda_73 = function(it) return it * 2 end
local ____lambda_74 = function(it) return it + 1 end
local ____lambda_75 = function(i, x) return __K2L_ListOf(i, x) end
local ____lambda_76 = function(i, x) return __K2L_ListOf(i + x) end
local ____lambda_77 = function(it) return it % 2 end
local ____lambda_78 = function(i, x) return i > 0 and x or nil end
local ____lambda_79 = function(i, x) return i * x end
local ____lambda_80 = function(it) return it * 3 end
local ____lambda_81 = function(____a_17, ____b_17)
    local ____x_17, ____y_17 = ____a_17, ____b_17
    if ____x_17 ~= ____y_17 then
        return ____x_17 < ____y_17 and -1 or 1
    end
    return 0
end
local ____lambda_82 = function(it) return -it end
local ____lambda_83 = function(____a_18, ____b_18)
    local ____x_18, ____y_18 = ____a_18, ____b_18
    if ____x_18 ~= ____y_18 then
        return ____x_18 < ____y_18 and -1 or 1
    end
    return 0
end
local ____lambda_84 = function(it) return -it end
local ____lambda_85 = function(____a_19, ____b_19)
    local ____x_19, ____y_19 = ____a_19, ____b_19
    if ____x_19 ~= ____y_19 then
        return ____x_19 < ____y_19 and -1 or 1
    end
    return 0
end
local ____lambda_86 = function(it) return -it end
local ____lambda_87 = function(____a_20, ____b_20)
    local ____x_20, ____y_20 = ____a_20, ____b_20
    if ____x_20 ~= ____y_20 then
        return ____x_20 < ____y_20 and -1 or 1
    end
    return 0
end
local ____lambda_88 = function(it) return -it end
local ____lambda_89 = function(____a_21, ____b_21)
    local ____x_21, ____y_21 = ____a_21, ____b_21
    if ____x_21 ~= ____y_21 then
        return ____x_21 < ____y_21 and -1 or 1
    end
    return 0
end
local ____lambda_90 = function(____a_22, ____b_22)
    local ____x_22, ____y_22 = ____a_22, ____b_22
    if ____x_22 ~= ____y_22 then
        return ____x_22 < ____y_22 and -1 or 1
    end
    return 0
end
local ____lambda_91 = function(____a_23, ____b_23)
    local ____x_23, ____y_23 = ____a_23, ____b_23
    if ____x_23 ~= ____y_23 then
        return ____x_23 < ____y_23 and -1 or 1
    end
    return 0
end
local ____lambda_92 = function(____a_24, ____b_24)
    local ____x_24, ____y_24 = ____a_24, ____b_24
    if ____x_24 ~= ____y_24 then
        return ____x_24 < ____y_24 and -1 or 1
    end
    return 0
end
local ____lambda_93 = function(i, a, x) return a + i * x end
local ____lambda_94 = function(i, a, x) return a + i * x end
local ____lambda_95 = function(a, x) return a * x end
local ____lambda_96 = function(a, x) return a * x end
local ____lambda_97 = function(i, a, x) return a + i + x end
local ____lambda_98 = function(i, a, x) return a + i * x end
local ____lambda_99 = function(i, a, x) return a * x + i end
local ____lambda_100 = function(a, x) return a + x end
local ____lambda_101 = function(a, b) return a .. b end
local ____lambda_102 = function(it) return it:sum() end
local ____lambda_103 = function(it) return it.size end
local ____lambda_104 = function(____a_25, ____b_25)
    local ____x_25, ____y_25 = -____a_25, -____b_25
    if ____x_25 ~= ____y_25 then
        return ____x_25 < ____y_25 and -1 or 1
    end
    return 0
end
local ____lambda_105 = function(____a_26, ____b_26)
    local ____x_26, ____y_26 = ____a_26, ____b_26
    if ____x_26 ~= ____y_26 then
        return ____x_26 < ____y_26 and -1 or 1
    end
    return 0
end
local ____lambda_106 = function(it) return -it end
local ____lambda_107 = function(____a_27, ____b_27)
    local ____x_27, ____y_27 = ____a_27, ____b_27
    if ____x_27 ~= ____y_27 then
        return ____x_27 < ____y_27 and -1 or 1
    end
    return 0
end
local ____lambda_108 = function(it) return -it end
local ____lambda_109 = function(____a_28, ____b_28)
    local ____x_28, ____y_28 = ____a_28, ____b_28
    if ____x_28 ~= ____y_28 then
        return ____x_28 < ____y_28 and -1 or 1
    end
    return 0
end
local ____lambda_110 = function(it) return -it end
local ____lambda_111 = function(____a_29, ____b_29)
    local ____x_29, ____y_29 = ____a_29, ____b_29
    if ____x_29 ~= ____y_29 then
        return ____x_29 < ____y_29 and -1 or 1
    end
    return 0
end
local ____lambda_112 = function(it) return -it end
local ____lambda_113 = function(____a_30, ____b_30)
    local ____x_30, ____y_30 = ____a_30, ____b_30
    if ____x_30 ~= ____y_30 then
        return ____x_30 < ____y_30 and -1 or 1
    end
    return 0
end
local ____lambda_114 = function(it) return -it end
local ____lambda_115 = function(____a_31, ____b_31)
    local ____x_31, ____y_31 = ____a_31, ____b_31
    if ____x_31 ~= ____y_31 then
        return ____x_31 < ____y_31 and -1 or 1
    end
    return 0
end
local ____lambda_116 = function(it) return -it end
local ____lambda_117 = function(____a_32, ____b_32)
    local ____x_32, ____y_32 = ____a_32, ____b_32
    if ____x_32 ~= ____y_32 then
        return ____x_32 < ____y_32 and -1 or 1
    end
    return 0
end
local ____lambda_118 = function(it) return it.value end
local ____lambda_119 = function(____a_33, ____b_33)
    local ____x_33, ____y_33 = ____a_33, ____b_33
    if ____x_33 ~= ____y_33 then
        return ____x_33 < ____y_33 and -1 or 1
    end
    return 0
end
local ____lambda_120 = function(it) return it:byte() end
local function iterableFunctions()
    print(list():elementAtOrElse(5, ____lambda_66))
    print(list():firstNotNullOf(____lambda_67))
    print(__K2L_Str(list():firstNotNullOfOrNull(____lambda_68)))
    print(list():indexOfLast(____lambda_69))
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
    print(__K2L_Str(__K2L_ListOf(1, "a"):filter(____lambda_70)))
    print(__K2L_Str(__K2L_ListOf(1, "a"):filterTo(__K2L_ListOf(), ____lambda_71)))
    print(__K2L_Str(nullableList():filterNotNullTo(__K2L_ListOf())))
    local ____list_1 = list()
    local ____destination_1 = __K2L_ListOf()
    for _, it in ipairs(____list_1) do
        if not (it > 2) then
            ____destination_1:add(it)
        end
    end
    print(__K2L_Str(____destination_1))
    print(__K2L_Str(list():filterTo(__K2L_ListOf(), ____lambda_72)))
    print(__K2L_Str(list():associateByTo(__K2L_MapOf(), ____lambda_73)))
    local ____list_2 = list()
    local ____destination_2 = __K2L_MapOf()
    for _, it in ipairs(____list_2) do
        local ____value = __K2L_Pair.new(it, it)
        ____destination_2:put(____value.first, ____value.second)
    end
    print(__K2L_Str(____destination_2))
    print(__K2L_Str(list():associateWithTo(__K2L_MapOf(), ____lambda_74)))
    print(__K2L_Str(list():toHashSet()))
    print(__K2L_Str(list():toMutableList()))
    print(__K2L_Str(list():toMutableSet()))
    local ____list_3 = list()
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list_3:____array()
    for ____i_1 = 1, ____n do
        local it = ____items[____i_1]
        local ____inner, ____m = __K2L_ListOf(it, it):____array()
        for ____j = 1, ____m do
            ____count = ____count + 1
            ____out[____count] = ____inner[____j]
        end
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    print(__K2L_Str(list():flatMapIndexed(____lambda_75)))
    local ____list_4 = list()
    local ____destination_3 = __K2L_ListOf()
    for _, it in ipairs(____list_4) do
        ____destination_3:addAll(__K2L_ListOf(it))
    end
    print(__K2L_Str(____destination_3))
    print(__K2L_Str(list():flatMapIndexedTo(__K2L_ListOf(), ____lambda_76)))
    local ____list_5 = list()
    local ____destination_4 = __K2L_MapOf()
    for _, it in ipairs(____list_5) do
        local ____value_1 = it % 2
        local ____group = ____destination_4:get(____value_1)
        if ____group == nil then
            ____group = __K2L_ListOf()
            ____destination_4:put(____value_1, ____group)
        end
        ____group:add(it)
    end
    print(__K2L_Str(____destination_4))
    print(__K2L_Str(list():groupingBy(____lambda_77):eachCount()))
    print(__K2L_Str(list():mapIndexedNotNullTo(__K2L_ListOf(), ____lambda_78)))
    print(__K2L_Str(list():mapIndexedTo(__K2L_ListOf(), ____lambda_79)))
    local ____list_6 = list()
    local ____destination_5 = __K2L_ListOf()
    for _, it in ipairs(____list_6) do
        local ____result
        ____result = it > 1 and it or nil
        local ____value_2 = ____result
        if ____value_2 ~= nil then
            ____destination_5:add(____result)
        end
    end
    print(__K2L_Str(____destination_5))
    print(__K2L_Str(list():mapTo(__K2L_ListOf(), ____lambda_80)))
    print(list():maxOfWith(____lambda_81, ____lambda_82))
    print(__K2L_Str(list():maxOfWithOrNull(____lambda_83, ____lambda_84)))
    print(list():minOfWith(____lambda_85, ____lambda_86))
    print(__K2L_Str(list():minOfWithOrNull(____lambda_87, ____lambda_88)))
    print(list():maxWith(____lambda_89))
    print(__K2L_Str(list():maxWithOrNull(____lambda_90)))
    print(list():minWith(____lambda_91))
    print(__K2L_Str(list():minWithOrNull(____lambda_92)))
    print(list():reduceIndexed(____lambda_93))
    print(__K2L_Str(list():reduceIndexedOrNull(____lambda_94)))
    print(__K2L_Str(list():reduceOrNull(____lambda_95)))
    print(__K2L_Str(__K2L_ListOf():reduceOrNull(____lambda_96)))
    print(__K2L_Str(list():runningFoldIndexed(0, ____lambda_97)))
    print(__K2L_Str(list():runningReduceIndexed(____lambda_98)))
    print(__K2L_Str(list():scanIndexed(1, ____lambda_99)))
    local ____list_7 = list()
    local ____sum = 0
    for _, it in ipairs(____list_7) do
        ____sum = ____sum + it * 2
    end
    print(____sum)
    local ____list_8 = list()
    local ____sum_1 = 0.0
    for _, it in ipairs(____list_8) do
        ____sum_1 = ____sum_1 + it / 2.0
    end
    print(____sum_1)
    print(list():requireNoNulls():count())
    print(__K2L_Str(list():minus(1)))
    print(__K2L_Str(list():minusAll(__K2L_ArrayOf(1, 2))))
    print(__K2L_Str(list():minusAll(__K2L_ListOf(3))))
    print(__K2L_Str(list():minusAll(__K2L_SequenceOf(2))))
    print(__K2L_Str(list():minus(3)))
    print(__K2L_Str(list():plusAll(__K2L_ArrayOf(7))))
    print(__K2L_Str(list():plus(8)))
    print(__K2L_Str(list():joinTo(__K2L_StringBuilder.new(), "-")))
    print(list():shuffled(__K2L_Random.seeded(1)):count())
    print(list():elementAt(1))
    print(list():take(2):sum())
    print(__K2L_Str(list():scan(0, ____lambda_100)))
    print(__K2L_Str(list():zip(__K2L_ListOf("a", "b"), ____lambda_101)))
    print(__K2L_Str(list():windowed(2, nil, nil, ____lambda_102)))
    print(__K2L_Str(list():chunked(2, ____lambda_103)))
    local ____list_9 = list()
    for ____i_2 = 1, ____list_9.size do
        local x = ____list_9[____i_2]
        local i = ____i_2 - 1
        io.write(i .. x .. " ")
    end
    print("kotlin.Unit")
    print(__K2L_Str(list():sortedWith(____lambda_104)))
    print(__K2L_ListOf(3, 1):maxOfWith(____lambda_105, ____lambda_106))
    print(__K2L_ListOf(3, 1):minOfWith(____lambda_107, ____lambda_108))
    print(__K2L_Str(__K2L_ListOf(3, 1):maxOfWithOrNull(____lambda_109, ____lambda_110)))
    print(__K2L_Str(__K2L_ListOf():minOfWithOrNull(____lambda_111, ____lambda_112)))
    print(__K2L_ArrayOf(3, 1):maxOfWith(____lambda_113, ____lambda_114))
    print(__K2L_ArrayOf(3, 1):minOfWith(____lambda_115, ____lambda_116))
    print(__K2L_MapOf(__K2L_Pair.new(1, 2)):getEntries():maxOfWith(____lambda_117, ____lambda_118))
    print(__K2L_StringToList("ab"):maxOfWith(____lambda_119, ____lambda_120))
    print(list():count())
    print((list() or __K2L_ListOf()):count())
end

local ____lambda_121 = function(it) return it + 1 end
local ____lambda_122 = function()
    return __K2L_SequenceOf(1, nil):requireNoNulls():toList()
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
        return it % 2
    end):eachCount()
    print(__K2L_Str(groups) .. " " .. __K2L_Str(log))
    log:clear()
    print(__K2L_GenerateSequence(1, ____lambda_121):firstNotNullOf(function(it)
        log:add("try " .. it)
        return it > 2 and it or nil
    end))
    print(__K2L_Str(log))
    print(__K2L_Str(__K2L_SequenceOf(1, nil):requireNoNulls():take(1):toList()))
    local ____value_3 = __K2L_RunCatching(____lambda_122):exceptionOrNull()
    print(__K2L_InstanceOf(____value_3, __K2L_IllegalArgumentException))
    print(__K2L_Str((__K2L_SequenceOf(1, 2) or __K2L_SequenceOf()):toList()))
    local none = nil
    print((none or __K2L_SequenceOf()):count())
end

local ____lambda_123 = function(a, b) return a > b end
local ____lambda_124 = function(a, b) return a > b end
local ____lambda_125 = function(it) return it.size > 5 end
local ____lambda_126 = function(it) return it % 2 end
local ____lambda_127 = function(it) return it > 1 end
local ____lambda_128 = function(it) return it end
local ____lambda_129 = function(it) return it > 2 end
local ____lambda_130 = function(it) return it < 2 end
local ____lambda_131 = function(it) return it < 2 end
local ____lambda_132 = function(it) return it > 2 end
local ____lambda_133 = function(it) return __K2L_Equals(it, "ab") end
local ____lambda_134 = function(it) return __K2L_Equals(it, "bc") end
local function falseValues()
    print(__K2L_Str(__K2L_SequenceOf(1, 2):zip(__K2L_SequenceOf(2, 1), ____lambda_123):toList()))
    print(__K2L_Str(__K2L_SequenceOf(1, 3, 2):zipWithNext(____lambda_124):toList()))
    print(__K2L_Str(__K2L_SequenceOf(1, 2, 3):windowed(2, nil, nil, ____lambda_125):toList()))
    print(__K2L_Str(__K2L_SequenceOf(1, 2, 3):groupBy(____lambda_126, ____lambda_127)))
    print(__K2L_Str(__K2L_SequenceOf(1, 2, 3):associateBy(____lambda_128, ____lambda_129)))
    print(__K2L_SequenceOf(3, 1, 2):maxBy(____lambda_130))
    print(__K2L_ListOf(3, 1, 2):maxBy(____lambda_131))
    print(__K2L_Str(__K2L_ListOf(3, 1, 2):minByOrNull(____lambda_132)))
    print(__K2L_Str(__K2L_Text.chunked("abcd", 2, ____lambda_133)))
    print(__K2L_Str(__K2L_Text.windowed("abcd", 2, nil, nil, ____lambda_134)))
end

local function main()
    falseValues()
    sequenceFunctions()
    iterableFunctions()
    interleaving()
end

__K2L_RunMain(main)
return {seq = seq, nullableSeq = nullableSeq, sequenceFunctions = sequenceFunctions, list = list, nullableList = nullableList, iterableFunctions = iterableFunctions, interleaving = interleaving, falseValues = falseValues}
