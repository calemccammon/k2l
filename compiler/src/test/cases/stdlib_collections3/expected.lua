local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CollectionExtras = ____lualib.__K2L_CollectionExtras
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Extras = ____lualib.__K2L_Extras
local __K2L_GenerateSequence = ____lualib.__K2L_GenerateSequence
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_IndexedValue = ____lualib.__K2L_IndexedValue
local __K2L_IsDigit = ____lualib.__K2L_IsDigit
local __K2L_Iterator = ____lualib.__K2L_Iterator
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NaturalOrder = ____lualib.__K2L_NaturalOrder
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReverseOrder = ____lualib.__K2L_ReverseOrder
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SequenceOf = ____lualib.__K2L_SequenceOf
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_Text = ____lualib.__K2L_Text

local Sale = __K2L_Class("Sale")

function Sale:____init(region, amount)
    self.region = region
    self.amount = amount
end

function Sale.new(region, amount)
    return setmetatable({region = region, amount = amount}, Sale)
end

function Sale:toString()
    return "Sale(region=" .. self.region .. ", amount=" .. self.amount .. ")"
end

function Sale:hashCode()
    return (31 * __K2L_Hash(self.region) + self.amount + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Sale:equals(other)
    return getmetatable(other) == Sale and self.region == other.region and self.amount == other.amount
end

local ____lambda_1 = function(it) return __K2L_Text.take(it, 1) end
local ____lambda_2 = function(it) return #it end
local ____lambda_3 = function(acc, w) return acc + #w end
local ____lambda_4 = function(it)
    return 0 >= 0 and 0 < #it and it:sub(0 + 1, 0 + 1) or __K2L_IndexError(0, #it, "string")
end
local ____lambda_5 = function(k, _) return k .. ":" end
local ____lambda_6 = function(_, acc, w) return acc .. #w end
local ____lambda_7 = function(it)
    return 0 >= 0 and 0 < #it and it:sub(0 + 1, 0 + 1) or __K2L_IndexError(0, #it, "string")
end
local ____lambda_8 = function(_, acc, w) return #w > #acc and w or acc end
local ____lambda_9 = function(it) return __K2L_Text.first(it) end
local ____lambda_10 = function(key, acc, w, first)
    return first and key .. "=" .. w or __K2L_Str(acc) .. "," .. w
end
local ____lambda_11 = function(it) return it.region end
local ____lambda_12 = function(acc, s) return acc + s.amount end
local ____lambda_13 = function(it) return it end
local ____lambda_14 = function(it) return #it end
local ____lambda_15 = function(it) return #it end
local ____lambda_16 = function(it) return #it end
local ____lambda_17 = function(it) return #it end
local ____lambda_18 = function(it) return it * 2 end
local ____lambda_19 = function(it) return it end
local ____lambda_20 = function(it) return it.value == 1 end
local ____lambda_21 = function(it) return __K2L_IsDigit[it] == true end
local ____lambda_22 = function(c, acc) return c > acc and c or acc end
local ____lambda_23 = function(c, _) return c end
local ____lambda_24 = function(i, c, acc) return i == 0 and c or acc end
local ____lambda_25 = function(i, c, acc) return i == 1 and c or acc end
local function main()
    local words = __K2L_ListOf("apple", "avocado", "banana", "blueberry", "cherry", "apricot")
    local counts = __K2L_MapOf(__K2L_Pair.new("z", 100))
    local returned = __K2L_CollectionExtras.eachCountTo(words:groupingBy(____lambda_1), counts)
    print("eachCountTo: " .. __K2L_Str(counts) .. ", same=" .. tostring(returned == counts))
    print("foldTo: " .. __K2L_Str(__K2L_CollectionExtras.foldTo(words:groupingBy(____lambda_2), __K2L_SortedMapOf(nil), 0, ____lambda_3, false)))
    print("foldTo init: " .. __K2L_Str(__K2L_CollectionExtras.foldTo(words:groupingBy(____lambda_4), __K2L_MapOf(), ____lambda_5, ____lambda_6, true)))
    print("reduceTo: " .. __K2L_Str(__K2L_CollectionExtras.reduceTo(words:groupingBy(____lambda_7), __K2L_MapOf(), ____lambda_8)))
    local agg = __K2L_CollectionExtras.aggregateTo(words:groupingBy(____lambda_9), __K2L_MapOf(), ____lambda_10)
    print("aggregateTo: " .. __K2L_Str(agg))
    local sales = __K2L_ListOf(Sale.new("north", 10), Sale.new("south", 5), Sale.new("north", 7))
    local totals = __K2L_Map.new()
    __K2L_CollectionExtras.foldTo(sales:groupingBy(____lambda_11), totals, 0, ____lambda_12, false)
    print("totals: " .. __K2L_Str(totals:toSortedMap()))
    local grouping = __K2L_StringToList("mississippi"):asIterable():groupingBy(____lambda_13)
    print("keyOf: " .. grouping.keySelector("s") .. ", " .. __K2L_AsSequence(__K2L_CollectionExtras.sourceIterator(grouping)):count())
    print("isSorted: " .. tostring(__K2L_CollectionExtras.isSorted(__K2L_ListOf(1, 2, 2, 5), "")) .. " " .. tostring(__K2L_CollectionExtras.isSorted(__K2L_ListOf(3, 1), "")) .. " " .. tostring(__K2L_CollectionExtras.isSorted(__K2L_ListOf(), "")))
    print("isSortedDescending: " .. tostring(__K2L_CollectionExtras.isSorted(__K2L_ListOf(5, 3, 3, 1), "Descending")) .. " " .. tostring(__K2L_CollectionExtras.isSorted(__K2L_ListOf(1, 2), "Descending")))
    print("isSortedBy: " .. tostring(__K2L_CollectionExtras.isSorted(words, "By", ____lambda_14)) .. " " .. tostring(__K2L_CollectionExtras.isSorted(__K2L_ListOf("a", "bb", "ccc"), "By", ____lambda_15)))
    print("isSortedByDescending: " .. tostring(__K2L_CollectionExtras.isSorted(__K2L_ListOf("ccc", "bb", "a"), "ByDescending", ____lambda_16)))
    print("isSortedWith: " .. tostring(__K2L_CollectionExtras.isSorted(__K2L_ListOf("B", "a", "C"), "With", __K2L_Text.caseInsensitiveOrder)) .. " " .. tostring(__K2L_CollectionExtras.isSorted(words, "With", __K2L_NaturalOrder)))
    print("arrays: " .. tostring(__K2L_CollectionExtras.isSorted(__K2L_ArrayOf(1, 2, 3), "")) .. " " .. tostring(__K2L_CollectionExtras.isSorted(__K2L_ArrayOf("b", "a"), "")) .. " " .. tostring(__K2L_CollectionExtras.isSorted(__K2L_ArrayOf(3.0, 1.0), "Descending")))
    print("array by: " .. tostring(__K2L_CollectionExtras.isSorted(__K2L_ArrayOf("x", "yy"), "By", ____lambda_17)) .. " " .. tostring(__K2L_CollectionExtras.isSorted(__K2L_ArrayOf("c", "a"), "With", __K2L_ReverseOrder)))
    print("sequence: " .. tostring(__K2L_CollectionExtras.isSorted(__K2L_GenerateSequence(1, ____lambda_18):take(10), "")) .. " " .. tostring(__K2L_CollectionExtras.isSorted(__K2L_SequenceOf(2, 1), "By", ____lambda_19)))
    local seen = __K2L_ListOf()
    local map = __K2L_MapOf(__K2L_Pair.new("a", 1), __K2L_Pair.new("b", 2))
    local same = __K2L_CollectionExtras.onEachIndexed(map, function(i, ____destructured)
        local k, v = ____destructured.key, ____destructured.value
        seen:add(i .. ":" .. k .. "=" .. v)
    end)
    print("map onEachIndexed: " .. __K2L_Str(seen) .. " " .. tostring(same == map))
    local chars = __K2L_StringBuilder.new()
    print("string onEachIndexed: " .. __K2L_CollectionExtras.onEachIndexedChars("hey", __K2L_StringToList("hey"), function(i, c)
        chars:append(c):append(tostring(i))
    end) .. " " .. __K2L_Str(chars))
    print("mapTo: " .. __K2L_Str(__K2L_CollectionExtras.mapTo(map, __K2L_ListOf("start"), function(____destructured_1)
        local k, v = ____destructured_1.key, ____destructured_1.value
        return k .. v
    end)))
    print("filterNotTo: " .. __K2L_Str(__K2L_CollectionExtras.filterNotTo(map, __K2L_MapOf(__K2L_Pair.new("z", 0)), ____lambda_20)))
    local indexed = __K2L_CollectionExtras.withIndex(__K2L_IteratorOf(__K2L_ListOf("x", "y")))
    for _, ____item in __K2L_Iterator.iter(indexed) do
        local i, v = ____item.index, ____item.value
        print("withIndex " .. i .. " " .. v)
    end
    local iv = __K2L_IndexedValue.new(3, "three")
    print("IndexedValue: " .. __K2L_Str(iv) .. " " .. __K2L_Str(__K2L_CollectionExtras.copyIndexed(iv, 4)) .. " " .. tostring(__K2L_Equals(iv, __K2L_IndexedValue.new(3, "three"))) .. " " .. tostring(__K2L_Hash(iv) == __K2L_Hash(__K2L_IndexedValue.new(3, "three"))))
    local ____destructured_2 = __K2L_SequenceOf(__K2L_Pair.new("a", 1), __K2L_Pair.new("b", 2)):toList():unzip()
    local letters, numbers = ____destructured_2.first, ____destructured_2.second
    print("unzip: " .. __K2L_Str(letters) .. " " .. __K2L_Str(numbers))
    local text = "one two three two one"
    print("findAnyOf: " .. __K2L_Str(__K2L_CollectionExtras.findAnyOf(text, __K2L_ListOf("two", "three"), nil, nil, false)) .. " " .. __K2L_Str(__K2L_CollectionExtras.findAnyOf(text, __K2L_ListOf("TWO"), nil, true, false)) .. " " .. __K2L_Str(__K2L_CollectionExtras.findAnyOf(text, __K2L_ListOf("x"), nil, nil, false)))
    print("findLastAnyOf: " .. __K2L_Str(__K2L_CollectionExtras.findAnyOf(text, __K2L_ListOf("one", "two"), nil, nil, true)) .. " " .. __K2L_Str(__K2L_CollectionExtras.findAnyOf(text, __K2L_ListOf("two"), 10, nil, true)))
    print("lastIndexOfAny: " .. __K2L_CollectionExtras.lastIndexOfAny(text, __K2L_ListOf("two", "one"), nil, nil) .. " " .. __K2L_CollectionExtras.lastIndexOfAny(text, __K2L_ArrayOf("t", "w"), nil, nil) .. " " .. __K2L_CollectionExtras.lastIndexOfAny(text, __K2L_ListOf("z"), nil, nil))
    print("filterTo: " .. __K2L_Str(__K2L_CollectionExtras.filterCharsTo(__K2L_StringToList("a1b2c3"), __K2L_StringBuilder.new("#"), ____lambda_21)))
    print("reduceRightOrNull: " .. __K2L_Str(__K2L_Extras.reduceRight(__K2L_StringToList("abc"), ____lambda_22, false, true, "char sequence")) .. " " .. __K2L_Str(__K2L_Extras.reduceRight(__K2L_StringToList(""), ____lambda_23, false, true, "char sequence")))
    print("reduceRightIndexed: " .. __K2L_Extras.reduceRight(__K2L_StringToList("abc"), ____lambda_24, true, false, "char sequence"))
    print("reduceRightIndexedOrNull: " .. __K2L_Str(__K2L_Extras.reduceRight(__K2L_StringToList("xyz"), ____lambda_25, true, true, "char sequence")))
    print("replaceIndent: [" .. __K2L_CollectionExtras.replaceIndent("    a\n      b\n", "> ") .. "]")
    print("replaceIndentByMargin: [" .. __K2L_CollectionExtras.replaceIndentByMargin("  |x\n  |  y", "- ", nil) .. "]")
end

__K2L_RunMain(main)
return {Sale = Sale}
