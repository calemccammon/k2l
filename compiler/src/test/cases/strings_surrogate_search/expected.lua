local ____lualib = require("lualib_bundle")
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringIndexOf = ____lualib.__K2L_StringIndexOf
local __K2L_StringLastIndexOf = ____lualib.__K2L_StringLastIndexOf
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_Utf16 = ____lualib.__K2L_Utf16

local function mark(s)
    return __K2L_Utf16.norm(__K2L_Text.toList(s):map(function(it)
        if __K2L_Utf16.isHighSurrogate(it) then
            return "<H>"
        elseif __K2L_Utf16.isLowSurrogate(it) then
            return "<L>"
        else
            return it
        end
    end):joinToString(""))
end

local function main()
    local high = "\237\160\189"
    local low = "\237\184\128"
    local s = "a😀b😀"
    print(__K2L_Utf16.out(mark(s)))
    print(__K2L_Utf16.out(__K2L_Utf16.len(s)))
    print(__K2L_Utf16.out(__K2L_Text.contains(s, high)))
    print(__K2L_Utf16.out(__K2L_Text.contains(s, low)))
    print(__K2L_Utf16.out(__K2L_Text.contains(s, "😀")))
    print(__K2L_Utf16.out(__K2L_Text.contains(s, "b" .. high)))
    print(__K2L_Utf16.out(__K2L_Text.contains(s, low .. "b")))
    print(__K2L_Utf16.out(__K2L_Text.contains("abc", high)))
    print(__K2L_Utf16.out(__K2L_StringIndexOf(s, high)))
    print(__K2L_Utf16.out(__K2L_StringIndexOf(s, low)))
    print(__K2L_Utf16.out(__K2L_StringIndexOf(s, low, 3)))
    print(__K2L_Utf16.out(__K2L_StringIndexOf(s, high, 2)))
    print(__K2L_Utf16.out(__K2L_StringLastIndexOf(s, high)))
    print(__K2L_Utf16.out(__K2L_StringLastIndexOf(s, low)))
    print(__K2L_Utf16.out(__K2L_StringIndexOf(s, "😀", 2)))
    print(__K2L_Utf16.out(mark(__K2L_StringReplace(s, high, "X"))))
    print(__K2L_Utf16.out(mark(__K2L_StringReplace(s, low, "Y"))))
    print(__K2L_Utf16.out(mark(__K2L_StringReplace(s, high, ""))))
    print(__K2L_Utf16.out(mark(__K2L_StringReplace(s, low, ""))))
    print(__K2L_Utf16.out(mark(__K2L_StringReplace(__K2L_StringReplace(s, high, ""), low, ""))))
    print(__K2L_Utf16.out(mark(__K2L_StringReplace(s, high, low))))
    print(__K2L_Utf16.out(mark(__K2L_StringReplace(s, "😀", "-"))))
    print(__K2L_Utf16.out(mark(__K2L_Text.replaceFirst(s, low, "Y"))))
    local ____list = __K2L_StringSplit(s, high)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = mark(it)
    end
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ListWrap(____out, ____count))))
    local ____list_1 = __K2L_StringSplit(s, low)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = mark(it)
    end
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1))))
    local ____list_2 = __K2L_Text.split(s, {high, low})
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_2, ____n_2 = ____list_2:____array()
    for ____i_2 = 1, ____n_2 do
        local it = ____items_2[____i_2]
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = mark(it)
    end
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ListWrap(____out_2, ____count_2))))
    local ____list_3 = __K2L_Text.split(s, {"b", low})
    local ____out_3 = {}
    local ____count_3 = 0
    local ____items_3, ____n_3 = ____list_3:____array()
    for ____i_3 = 1, ____n_3 do
        local it = ____items_3[____i_3]
        ____count_3 = ____count_3 + 1
        ____out_3[____count_3] = mark(it)
    end
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ListWrap(____out_3, ____count_3))))
    local ____list_4 = __K2L_Text.split(s, {low}, 2)
    local ____out_4 = {}
    local ____count_4 = 0
    local ____items_4, ____n_4 = ____list_4:____array()
    for ____i_4 = 1, ____n_4 do
        local it = ____items_4[____i_4]
        ____count_4 = ____count_4 + 1
        ____out_4[____count_4] = mark(it)
    end
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ListWrap(____out_4, ____count_4))))
    print(__K2L_Utf16.out(__K2L_Text.startsWithAt(s, high, 1)))
    print(__K2L_Utf16.out(__K2L_Text.startsWith(s, "a" .. high)))
    print(__K2L_Utf16.out(__K2L_Text.endsWith(s, low)))
    print(__K2L_Utf16.out(__K2L_Text.endsWith(s, high .. low)))
    print(__K2L_Utf16.out(__K2L_Text.endsWith(s, "b" .. high)))
    print(__K2L_Utf16.out(__K2L_Utf16.len(__K2L_Text.removePrefix(s, "a" .. high))))
    print(__K2L_Utf16.out(__K2L_Utf16.len(__K2L_Text.removeSuffix(s, high .. low))))
    print(__K2L_Utf16.out(mark(__K2L_Text.substringBefore(s, low))))
    print(__K2L_Utf16.out(mark(__K2L_Text.substringAfter(s, high))))
    print(__K2L_Utf16.out(mark(__K2L_Text.substringBeforeLast(s, high))))
    print(__K2L_Utf16.out(mark(__K2L_Text.substringAfterLast(s, low))))
    print(__K2L_Utf16.out(__K2L_Text.toList(s):count(function(it) return it == __K2L_Text.get(high, 0) end)))
    print(__K2L_Utf16.out(__K2L_Text.toList(s):indexOfFirst(function(it) return it == __K2L_Text.get(low, 0) end)))
    print(__K2L_Utf16.out(__K2L_Utf16.len(__K2L_Regex.new("b"):replace(s, "!"))))
    print(__K2L_Utf16.out(__K2L_Sequence.new(__K2L_Regex.new(high .. low):findAllFactory(s)):count()))
    print(__K2L_Utf16.out(mark(__K2L_StringReplace("x" .. high, high, "y"))))
    print(__K2L_Utf16.out(mark(__K2L_StringReplace("x" .. high, high .. "z", "y"))))
    print(__K2L_Utf16.out(mark(__K2L_StringReplace(__K2L_StringReplace(high .. low, high, "["), low, "]"))))
    local ____list_5 = __K2L_Text.split("a,b" .. high .. ",c", {",", high})
    local ____out_5 = {}
    local ____count_5 = 0
    local ____items_5, ____n_5 = ____list_5:____array()
    for ____i_5 = 1, ____n_5 do
        local it = ____items_5[____i_5]
        ____count_5 = ____count_5 + 1
        ____out_5[____count_5] = mark(it)
    end
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ListWrap(____out_5, ____count_5))))
end

__K2L_Main(main)
return {mark = mark}
