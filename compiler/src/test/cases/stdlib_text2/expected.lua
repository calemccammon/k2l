local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_NumberFormatException = ____lualib.__K2L_NumberFormatException
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
local __K2L_StringToDouble = ____lualib.__K2L_StringToDouble
local __K2L_StringToDoubleOrNull = ____lualib.__K2L_StringToDoubleOrNull
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function searching()
    local s = "Hello, World, Hello"
    print(__K2L_StringIndexOf(s, "Hello", 1))
    print(__K2L_StringLastIndexOf(s, "Hello"))
    print(__K2L_StringIndexOf(s, "o", 5))
    print(__K2L_Text.indexOf(s, "hello", nil, true))
    print(s:sub(7 + 1, 7 + #"World") == "World")
    print(__K2L_StringEndsWith(s:lower(), ("HELLO"):lower()))
    print(__K2L_StringContains(s:lower(), ("world"):lower()))
    print(__K2L_Text.indexOfAny(s, __K2L_ListOf("W", "l")))
    print(__K2L_Text.commonPrefixWith(s, "Help"))
    print(__K2L_Text.commonSuffixWith(s, "Yellow Hello"))
    print(__K2L_Text.regionMatches("abc", 1, "xbc", 1, 2))
    print(__K2L_Text.regionMatches("ABC", 0, "abc", 0, 3, true))
end

local function splitting()
    print(__K2L_Str(__K2L_StringSplit("a,b,,c,", ",")))
    print(__K2L_Str(__K2L_Text.split("a,b;c", {",", ";"})))
    print(__K2L_Str(__K2L_Text.split("a,b,c", {","}, 2)))
    print(__K2L_Str(__K2L_Text.split("aXbxc", {"x"}, nil, true)))
    print(__K2L_Str(__K2L_StringSplit("a b  c", " ")))
    print(__K2L_Str(__K2L_StringSplit("abc", "")))
    print(__K2L_Str(__K2L_StringLines("a\r\nb\nc")))
    print(__K2L_Str(__K2L_AsSequence(__K2L_StringLines("l1\nl2")):toList()))
    print(__K2L_Str(__K2L_Text.chunked("abc", 2)))
    print(__K2L_Str(__K2L_Text.windowed("abcd", 2)))
    print(__K2L_Text.replaceFirst("a-b-c", "-", "+"))
    print(__K2L_Text.replace("aAbB", "a", "x", true))
    print(__K2L_StringReplace("abc", "", "-"))
end

local function substrings()
    local s = "Hello, World"
    print(__K2L_Text.substringBefore(s, ","))
    print(__K2L_Text.substringAfter(s, ", "))
    print(__K2L_Text.substringBeforeLast(s, "o"))
    print(__K2L_Text.substringAfterLast(s, "o"))
    print(__K2L_Text.substringAfter(s, "zz", "none"))
    print(__K2L_Text.take(s, 3) .. __K2L_Text.takeLast(s, 3))
    print(__K2L_Text.drop(s, 7) .. __K2L_Text.dropLast(s, 7))
    print(__K2L_Text.takeWhile(s, function(it) return it ~= "," end))
    print(__K2L_Text.dropWhile(s, function(it) return it ~= "," end))
    print(__K2L_Text.removePrefix(s, "Hello") .. __K2L_Text.removeSuffix(s, "World"))
    print(__K2L_Text.removeSurrounding("[x]", "[", "]"))
    print(__K2L_Text.removeRange(s, 0, 7))
    print(__K2L_Text.replaceRange(s, 0, 5, "Bye"))
    print(__K2L_Text.slice(s, __K2L_IntRange.new(0, 4)))
    print(s:sub(8))
    print(s:sub(1, 5))
    print(__K2L_Str(s:sub(3, 4)))
    print(s:sub(1, 1))
    print(s:sub(-1))
    print(__K2L_StringToList(s):single(function(it) return it == "W" end))
end

local function trimming()
    print("[" .. __K2L_StringTrim("  x  ") .. "]")
    print("[" .. __K2L_Text.trimChars("xxaxx", 3, "x") .. "]")
    print("[" .. __K2L_Text.trimChars("xxaxx", 1, "x") .. "]")
    print("[" .. __K2L_Text.trimChars("xxaxx", 2, "x") .. "]")
    print("[" .. __K2L_Text.trimWith("12ab34", 3, function(it) return it:match("^%d$") ~= nil end) .. "]")
    print(__K2L_Text.trimIndent("  a\n    b"))
    print(__K2L_Text.trimMargin("   |a\n   |b"))
    print(__K2L_Text.prependIndent("a\nb", ">"))
    print(__K2L_StringPadStart("7", 3, "0") .. __K2L_StringPadEnd("7", 3, "."))
    print(__K2L_Text.ifEmpty("", function() return "empty" end))
    print(__K2L_Text.ifBlank("  ", function() return "blank" end))
    print("x" == nil or "x" == "")
    local n = nil
    print(n == nil or __K2L_StringIsBlank(n))
    print(#(n or ""))
end

local function transforming()
    local s = "hello world"
    print(__K2L_Text.replaceFirstChar(s, function(it) return it:upper() end))
    print(__K2L_StringSplit(s, " "):joinToString(" ", nil, nil, nil, nil, function(w)
        return __K2L_Text.replaceFirstChar(w, function(it) return it:upper() end)
    end))
    print(__K2L_Text.filter(s, function(it)
        return not __K2L_StringContains("aeiou", it)
    end))
    print(__K2L_Text.filterNot(s, function(it) return it == "l" end))
    print(__K2L_Str(__K2L_StringToList(s):map(function(it) return it:upper() end)))
    print(__K2L_StringToList(s):count(function(it) return it == "o" end))
    print(__K2L_StringToList(s):distinct().size)
    print(__K2L_Str(__K2L_StringToList(s):groupBy(function(it) return it end):mapValues(function(it) return it.value.size end):filter(function(it) return it.value > 1 end)))
    print(__K2L_Str(__K2L_Text.partition(s, function(it) return __K2L_StringContains("aeiou", it) end)))
    print(s:reverse())
    print(__K2L_StringToList(s):any(function(it) return it == "w" end))
    print(__K2L_StringToList(s):all(function(it) return it:match("^%a$") ~= nil end))
    print(__K2L_StringToList(s):toSet().size)
    print(__K2L_Str(__K2L_StringToList(s):toSortedSet()))
    print(__K2L_Str(__K2L_StringToList(s):zip(__K2L_StringToList("abc"))))
    print(__K2L_AsSequence(s):filter(function(it) return it ~= " " end):take(3):joinToString(""))
    print(__K2L_Str(__K2L_StringToList(s):maxOrNull()))
    print(__K2L_Str(__K2L_IntRange.new(0, #s - 1)))
    print(#s - 1)
    print(__K2L_Text.compare(s, "hello"))
    print(__K2L_Text.compare("a", "b"))
    print("b" > "a")
    print(__K2L_StringEqualsIgnoreCase("abc", "ABC"))
end

local function conversions()
    print(__K2L_StringToInt("42") + __K2L_StringToInt("7"))
    print(__K2L_StringToInt("ff", 16))
    print(__K2L_StringToInt("-12", nil, true))
    print(__K2L_Str(__K2L_StringToIntOrNull("x")))
    print(__K2L_Str(__K2L_StringToIntOrNull("12")))
    print(__K2L_Str(__K2L_StringToDouble("3.5")))
    print(__K2L_Str(__K2L_StringToDoubleOrNull("3.5x")))
    print(__K2L_Str(__K2L_StringToDouble("1e3")))
    print(__K2L_Text.toBoolean("true"))
    print(__K2L_Text.toBoolean("TRUE"))
    print(__K2L_Text.toBoolean("yes"))
    print(__K2L_Str(__K2L_Text.toBooleanStrictOrNull("true")))
    print(__K2L_Str(__K2L_Text.toBooleanStrictOrNull("maybe")))
    print(__K2L_Text.toCharArray("abc").size)
    print(__K2L_Text.string(__K2L_ArrayOf("h", "i")))
    print(__K2L_StringFormat("%05.1f|%-5s|%5s|%x|%c", 3.14159, "ab", "cd", 255, "z"))
    print(__K2L_StringFormat("%,d", 1234567))
    print(__K2L_StringFormat("%08.3f", -2.5))
    print(__K2L_StringFormat("%e", 12345.678))
    print(__K2L_StringFormat("%b %s %10.4s|", true, nil, "truncated"))
    print(__K2L_StringFormat("%+d % d", 5, 5))
    local ____ok, ____result = pcall(function()
        __K2L_StringToInt("abc")
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_NumberFormatException) then
            local e = ____error
            print(__K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    local ____ok_1, ____result_1 = pcall(function()
        __K2L_StringToDouble("")
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error_1, __K2L_NumberFormatException) then
            local e = ____error_1
            print(__K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
end

local function builders()
    local sb = __K2L_StringBuilder.new("abc")
    sb:append(tostring(1)):append("x"):append("yz"):append(__K2L_Str(2.5))
    print(__K2L_Str(sb))
    sb:insert(0, "<<")
    print(__K2L_Str(sb))
    sb:deleteCharAt(0)
    sb:setLength(4)
    print(__K2L_Str(sb))
    sb:set(0, "Q")
    print(__K2L_Str(sb))
    print(sb:getLength())
    print(sb:indexOf("b"))
    print(__K2L_Str(sb:reverse()))
    sb:clear()
    sb:appendLine("x"):appendLine()
    print(#sb:toString())
    local ____builder = __K2L_StringBuilder.new()
    for i = 1, 3 do
        ____builder:append(tostring(i)):append(",")
    end
    ____builder:setLength(____builder:getLength() - 1)
    print(____builder:toString())
end

local function main()
    searching()
    splitting()
    substrings()
    trimming()
    transforming()
    conversions()
    builders()
end

main()
return {searching = searching, splitting = splitting, substrings = substrings, trimming = trimming, transforming = transforming, conversions = conversions, builders = builders}
