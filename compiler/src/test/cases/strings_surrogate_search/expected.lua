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
    print(__K2L_Utf16.out(__K2L_Str(__K2L_StringSplit(s, high):map(function(it) return mark(it) end))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_StringSplit(s, low):map(function(it) return mark(it) end))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Text.split(s, {high, low}):map(function(it) return mark(it) end))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Text.split(s, {"b", low}):map(function(it) return mark(it) end))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Text.split(s, {low}, 2):map(function(it) return mark(it) end))))
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
    print(__K2L_Utf16.out(__K2L_Regex.new(high .. low):findAll(s):count()))
    print(__K2L_Utf16.out(mark(__K2L_StringReplace("x" .. high, high, "y"))))
    print(__K2L_Utf16.out(mark(__K2L_StringReplace("x" .. high, high .. "z", "y"))))
    print(__K2L_Utf16.out(mark(__K2L_StringReplace(__K2L_StringReplace(high .. low, high, "["), low, "]"))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Text.split("a,b" .. high .. ",c", {",", high}):map(function(it) return mark(it) end))))
end

main()
return {mark = mark}
