local ____lualib = require("lualib_bundle")
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Extras = ____lualib.__K2L_Extras
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IsDigit = ____lualib.__K2L_IsDigit
local __K2L_IsLetter = ____lualib.__K2L_IsLetter
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Random = ____lualib.__K2L_Random
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_SortedSetOf = ____lualib.__K2L_SortedSetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf

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

local ____lambda_1 = function(c, acc) return acc .. c:upper() end
local ____lambda_2 = function(i, c, acc) return acc + i * c:byte() end
local ____lambda_3 = function(c, acc) return c > acc and c or acc end
local ____lambda_4 = function()
    return __K2L_StringToList("abc"):reduceRight(____lambda_3)
end
local ____lambda_5 = function(i, acc, c)
    return (i >= 0 and i % 2 or 0 - -i % 2) == 0 and acc or c
end
local ____lambda_6 = function()
    return __K2L_StringToList("abcd"):reduceIndexed(____lambda_5)
end
local ____lambda_7 = function(_, acc, _) return acc end
local ____lambda_8 = function(_, _, c) return c end
local ____lambda_9 = function()
    return __K2L_ReadOnlyListOf(__K2L_StringToList(""):reduceIndexedOrNull(____lambda_7), __K2L_StringToList("xy"):reduceIndexedOrNull(____lambda_8))
end
local ____lambda_10 = function(acc, c) return acc .. c end
local ____lambda_11 = function()
    return __K2L_StringToList("abc"):runningFold("", ____lambda_10)
end
local ____lambda_12 = function(acc, c) return acc + __K2L_Num.digitToInt(c) end
local ____lambda_13 = function()
    return __K2L_StringToList("123"):runningFold(0, ____lambda_12)
end
local ____lambda_14 = function(i, acc, c) return acc:plus(i + c:byte()) end
local ____lambda_15 = function()
    return __K2L_StringToList("ab"):runningFoldIndexed(__K2L_ReadOnlyListOf(), ____lambda_14)
end
local ____lambda_16 = function(i, acc, c) return acc .. i .. c end
local ____lambda_17 = function()
    return __K2L_StringToList("xyz"):runningFoldIndexed("", ____lambda_16)
end
local ____lambda_18 = function(acc, c) return c < acc and c or acc end
local ____lambda_19 = function()
    return __K2L_StringToList("aZb"):runningReduce(____lambda_18)
end
local ____lambda_20 = function(i, acc, c) return i == 1 and c:upper() or acc end
local ____lambda_21 = function()
    return __K2L_StringToList("abc"):runningReduceIndexed(____lambda_20)
end
local ____lambda_22 = function(i, c)
    return __K2L_IsDigit[c] == true and i .. ":" .. c or nil
end
local ____lambda_23 = function()
    return __K2L_StringToList("a1b2"):mapIndexedNotNull(____lambda_22)
end
local ____lambda_24 = function(i, c) return c .. i end
local ____lambda_25 = function()
    return __K2L_StringToList("ab"):mapIndexedTo(__K2L_ListOf("start"), ____lambda_24)
end
local ____lambda_26 = function(i, c)
    return __K2L_IsLetter[c] == true and i or nil
end
local ____lambda_27 = function()
    return __K2L_StringToList("a1"):mapIndexedNotNullTo(__K2L_SetOf(), ____lambda_26)
end
local ____lambda_28 = function(it) return it:byte() end
local ____lambda_29 = function()
    return __K2L_StringToList("hello"):mapTo(__K2L_SetOf(), ____lambda_28).size
end
local ____lambda_30 = function()
    return __K2L_StringToList("ab"):flatMapIndexed(function(i, c)
        local ____size = i + 1
        local ____out = {}
        for ____i = 1, ____size do
            local it = ____i - 1
            ____out[____i] = c
        end
        return __K2L_ListWrap(____out, ____size)
    end)
end
local ____lambda_31 = function(i, c) return __K2L_ReadOnlyListOf(i, c:byte()) end
local ____lambda_32 = function()
    return __K2L_StringToList("xy"):flatMapIndexedTo(__K2L_ListOf(0), ____lambda_31)
end
local ____lambda_33 = function(it) return it:upper() end
local ____lambda_34 = function()
    return __K2L_StringToList("abc"):associateByTo(__K2L_MapOf(), ____lambda_33)
end
local ____lambda_35 = function(it) return it:byte() end
local ____lambda_36 = function()
    return __K2L_StringToList("ab"):associateWithTo(__K2L_SortedMapOf(), ____lambda_35)
end
local ____lambda_37 = function()
    return __K2L_StringToList("banana"):toCollection(__K2L_SortedSetOf())
end
local ____lambda_38 = function()
    return __K2L_StringToList("mississippi"):toHashSet():sorted()
end
local ____lambda_39 = function(it) return it:byte() end
local ____lambda_40 = function(it) return it:byte() end
local ____lambda_41 = function()
    return __K2L_ReadOnlyListOf(__K2L_StringToList("abc"):maxOfOrNull(____lambda_39), __K2L_StringToList(""):minOfOrNull(____lambda_40))
end
local ____lambda_42 = function(it) return __K2L_Num.digitToIntOrNull(it) end
local ____lambda_43 = function()
    return __K2L_StringToList("ab3c4"):firstNotNullOf(____lambda_42, "char sequence")
end
local ____lambda_44 = function(it) return __K2L_Num.digitToIntOrNull(it) end
local ____lambda_45 = function()
    return __K2L_StringToList("abc"):firstNotNullOfOrNull(____lambda_44)
end
local ____lambda_46 = function(it) return __K2L_Num.digitToIntOrNull(it) end
local ____lambda_47 = function()
    return __K2L_StringToList("abc"):firstNotNullOf(____lambda_46, "char sequence")
end
local ____lambda_48 = function()
    return __K2L_ReadOnlyListOf(__K2L_StringToList(""):randomOrNull(__K2L_Random.default()), __K2L_StringToList("aaa"):randomOrNull(__K2L_Random.default()))
end
local ____lambda_49 = function()
    return __K2L_AsSequence(__K2L_Text.windowed("abcde", 3)):toList()
end
local ____lambda_50 = function(it) return it:reverse() end
local ____lambda_51 = function()
    return __K2L_AsSequence(__K2L_Text.windowed("abcdefg", 3, 2, true)):map(____lambda_50):toList()
end
local ____lambda_52 = function()
    return __K2L_AsSequence(__K2L_Text.chunked("abcdefgh", 3)):joinToString("|")
end
local ____lambda_53 = function(x, acc) return x - acc end
local ____lambda_54 = function(x, acc) return x + acc end
local ____lambda_55 = function(i, x, acc) return acc * 10 + x + i end
local ____lambda_56 = function(_, x, acc) return x + acc end
local ____lambda_57 = function()
    return __K2L_Extras.reduceRight(__K2L_ReadOnlyListOf(), ____lambda_56, true, false, "list")
end
local ____lambda_58 = function(i, s, acc) return acc .. s .. i end
local ____lambda_59 = function()
    return __K2L_Extras.reduceRight(__K2L_ReadOnlyListOf("a", "b", "c"), ____lambda_58, true, true, "list")
end
local ____lambda_60 = function(s, acc) return acc .. s end
local ____lambda_61 = function(i, x, acc) return acc - x * i end
local ____lambda_62 = function()
    return __K2L_Extras.reduceRight(__K2L_TypedArrayOf("[I", 5, 6, 7), ____lambda_61, true, false, "array")
end
local ____lambda_63 = function(_, s, acc) return s .. acc end
local ____lambda_64 = function()
    return __K2L_Extras.reduceRight(__K2L_TypedArrayOf("[Ljava.lang.String;"), ____lambda_63, true, false, "array")
end
local function main()
    local word = "kotlin"
    t("foldRight", function()
        return __K2L_StringToList(word):foldRight("", ____lambda_1)
    end)
    t("foldRightIndexed", function()
        return __K2L_StringToList(word):foldRightIndexed(0, ____lambda_2)
    end)
    t("reduceRight", ____lambda_4)
    t("reduceIndexed", ____lambda_6)
    t("reduceIndexedOrNull", ____lambda_9)
    t("runningFold", ____lambda_11)
    t("scan", ____lambda_13)
    t("runningFoldIndexed", ____lambda_15)
    t("scanIndexed", ____lambda_17)
    t("runningReduce", ____lambda_19)
    t("runningReduceIndexed", ____lambda_21)
    t("mapIndexedNotNull", ____lambda_23)
    t("mapIndexedTo", ____lambda_25)
    t("mapIndexedNotNullTo", ____lambda_27)
    t("mapTo", ____lambda_29)
    t("flatMapIndexed", ____lambda_30)
    t("flatMapIndexedTo", ____lambda_32)
    t("associateByTo", ____lambda_34)
    t("associateWithTo", ____lambda_36)
    t("toCollection", ____lambda_37)
    t("toHashSet", ____lambda_38)
    t("maxOfOrNull", ____lambda_41)
    t("firstNotNullOf", ____lambda_43)
    t("firstNotNullOfOrNull", ____lambda_45)
    t("firstNotNullOf none", ____lambda_47)
    t("randomOrNull", ____lambda_48)
    t("windowedSequence", ____lambda_49)
    t("windowedSequence step", ____lambda_51)
    t("chunkedSequence", ____lambda_52)
    local numbers = __K2L_ReadOnlyListOf(1, 2, 3, 4)
    t("reduceRightOrNull", function()
        return __K2L_ReadOnlyListOf(__K2L_Extras.reduceRight(numbers, ____lambda_53, false, true, "list"), __K2L_Extras.reduceRight(__K2L_ReadOnlyListOf(), ____lambda_54, false, true, "list"))
    end)
    t("reduceRightIndexed", function()
        return __K2L_Extras.reduceRight(numbers, ____lambda_55, true, false, "list")
    end)
    t("reduceRightIndexed empty", ____lambda_57)
    t("reduceRightIndexedOrNull", ____lambda_59)
    local array = __K2L_TypedArrayOf("[Ljava.lang.String;", "x", "y", "z")
    t("array reduceRightOrNull", function()
        return __K2L_Extras.reduceRight(array, ____lambda_60, false, true, "array")
    end)
    t("array reduceRightIndexed", ____lambda_62)
    t("array empty", ____lambda_64)
end

__K2L_DeepMain(main)
return {t = t}
