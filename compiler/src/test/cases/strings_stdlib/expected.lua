local ____lualib = require("lualib_bundle")
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringEndsWith = ____lualib.__K2L_StringEndsWith
local __K2L_StringEqualsIgnoreCase = ____lualib.__K2L_StringEqualsIgnoreCase
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_StringIndexOf = ____lualib.__K2L_StringIndexOf
local __K2L_StringIsBlank = ____lualib.__K2L_StringIsBlank
local __K2L_StringLastIndexOf = ____lualib.__K2L_StringLastIndexOf
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringPadEnd = ____lualib.__K2L_StringPadEnd
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToDouble = ____lualib.__K2L_StringToDouble
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_StringTrim = ____lualib.__K2L_StringTrim

local function main()
    local s = "Hello, World"
    print(s:sub(8))
    print(s:sub(1, 5))
    print(s:sub(5, 5))
    print(__K2L_StringStartsWith(s, "Hell"))
    print(__K2L_StringEndsWith(s, "x"))
    print(__K2L_StringContains(s, "lo, W"))
    print(__K2L_StringIndexOf(s, "o"))
    print(__K2L_StringLastIndexOf(s, "o"))
    print(__K2L_StringReplace(s, "l", "L"))
    print(__K2L_Str(__K2L_StringSplit("a,b,,c", ",")))
    print(__K2L_StringTrim("  padded  ") .. "|")
    print(__K2L_StringPadStart("7", 3, "0"))
    print(__K2L_StringPadEnd("ab", 4, ".") .. "|")
    print(("racecar"):reverse())
    print(__K2L_StringToInt("42") + 1)
    print(__K2L_Str(__K2L_StringToIntOrNull("x")))
    print(__K2L_Str(__K2L_StringToDouble("3.5") * 2))
    print(#"" == 0)
    print(__K2L_StringIsBlank("  "))
    print(("Kotlin"):lower():upper())
    print(__K2L_StringFormat("%d items at %.2f each, %s", 3, 1.5, "ok"))
    print(__K2L_Str(__K2L_StringToList("abc")))
    local c = "k"
    print(c:byte())
    print(string.char(("a"):byte() + 2))
    print(("z"):byte() - ("a"):byte())
    print(c:match("^%a$") ~= nil)
    print(("7"):match("^%d$") ~= nil)
    print(__K2L_Num.digitToInt("7") * 2)
    print(c:upper())
    print(string.char(97))
    for ____code = ("a"):byte(), ("e"):byte() do
        local ch = string.char(____code)
        io.write(ch)
    end
    print()
    local vowels = 0
    for ch in ("programming"):gmatch(".") do
        if __K2L_StringContains("aeiou", ch) then
            vowels = vowels + 1
        end
    end
    print(vowels)
    local sb = __K2L_StringBuilder.new()
    sb:append("one"):append(tostring(2)):append(tostring(true))
    print(sb:toString())
    local ____builder = __K2L_StringBuilder.new()
    ____builder:append("[")
    for i = 1, 3 do
        ____builder:append(tostring(i))
    end
    ____builder:append("]")
    local built = ____builder:toString()
    print(built)
    print(__K2L_Str(__K2L_StringLines("line1\nline2")))
    print(__K2L_StringSplit("a-b-c", "-"):joinToString("+"))
    print(__K2L_StringEqualsIgnoreCase("Hello", "hello"))
end

main()
