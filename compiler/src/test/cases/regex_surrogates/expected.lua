local ____lualib = require("lualib_bundle")
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
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

local ____lambda_1 = function(it)
    return "[" .. it.range.first .. "," .. it.range.last + 1 .. "]"
end
local function show(pattern, s)
    local regex = __K2L_Regex.new(pattern)
    local ranges = __K2L_Sequence.new(regex:findAllFactory(s)):map(____lambda_1):joinToString("")
    local ____arg = mark(s)
    local ____arg_1 = __K2L_Utf16.len(s)
    local ____arg_2 = mark(regex:replace(s, "-"))
    local ____list = regex:split(s)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = mark(it)
    end
    print(__K2L_Utf16.out("'" .. pattern .. "' on " .. ____arg .. " (" .. ____arg_1 .. "): " .. ranges .. " replace=" .. ____arg_2 .. " split=" .. __K2L_Str(__K2L_ListWrap(____out, ____count))))
end

local function main()
    local smile = "a😀b"
    show("", smile)
    show("x*", smile)
    show("a*", smile)
    show(".?", smile)
    show("\\b", smile)
    show("(?=b)", smile)
    show("^", smile)
    show("$", smile)
    show("", "😀")
    show("", "\237\184\128\237\160\189")
    show("", "\237\160\189x")
    show("x*", "😀😀")
    show("(?s).*?", "😀")
    show("\\x{1F600}*", smile)
    show("[\\x{1F600}]", smile)
    show(".", smile)
    show("(?<=a)", smile)
    show("(?<!a)", smile)
    show("", "")
    show("x*", "ab")
    local ____list_1 = __K2L_StringSplit("a,b", "")
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = mark(it)
    end
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1))))
    local ____list_2 = __K2L_StringSplit(smile, "")
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_2, ____n_2 = ____list_2:____array()
    for ____i_2 = 1, ____n_2 do
        local it = ____items_2[____i_2]
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = mark(it)
    end
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ListWrap(____out_2, ____count_2))))
    print(__K2L_Utf16.out(mark(__K2L_StringReplace(smile, "", "-"))))
    print(__K2L_Utf16.out(__K2L_StringIndexOf(smile, "") + __K2L_StringLastIndexOf(smile, "") + __K2L_StringIndexOf(smile, "", 2)))
end

main()
return {mark = mark, show = show}
