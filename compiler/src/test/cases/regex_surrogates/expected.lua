local ____lualib = require("lualib_bundle")
local __K2L_Regex = ____lualib.__K2L_Regex
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

local function show(pattern, s)
    local regex = __K2L_Regex.new(pattern)
    local ranges = regex:findAll(s):map(function(it)
        return "[" .. it.range.first .. "," .. it.range.last + 1 .. "]"
    end):joinToString("")
    print(__K2L_Utf16.out("'" .. pattern .. "' on " .. mark(s) .. " (" .. __K2L_Utf16.len(s) .. "): " .. ranges .. " replace=" .. mark(regex:replace(s, "-")) .. " split=" .. __K2L_Str(regex:split(s):map(function(it) return mark(it) end))))
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
    print(__K2L_Utf16.out(__K2L_Str(__K2L_StringSplit("a,b", ""):map(function(it) return mark(it) end))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_StringSplit(smile, ""):map(function(it) return mark(it) end))))
    print(__K2L_Utf16.out(mark(__K2L_StringReplace(smile, "", "-"))))
    print(__K2L_Utf16.out(__K2L_StringIndexOf(smile, "") + __K2L_StringLastIndexOf(smile, "") + __K2L_StringIndexOf(smile, "", 2)))
end

main()
return {mark = mark, show = show}
