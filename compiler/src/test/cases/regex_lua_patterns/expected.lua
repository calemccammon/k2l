local ____lualib = require("lualib_bundle")
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_SimpleName = ____lualib.__K2L_SimpleName
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringToInt = ____lualib.__K2L_StringToInt

local function show(label, value)
    print(label .. ": " .. __K2L_Str(value))
end

local ____lambda_1 = function(it) return it.value end
local function values(regex, input)
    return __K2L_Sequence.new(regex:findAllFactory(input)):map(____lambda_1):toList()
end

local ____lambda_2 = function(it) return it.range.first end
local function constructs()
    show("magic", __K2L_Regex.new("a\\.b\\*c\\+d\\?e\\(f\\)g\\[h]i\\$j\\^k%l-m", "a%.b%*c%+d%?e%(f%)g%[h%]i%$j%^k%%l%-m"):matches("a.b*c+d?e(f)g[h]i$j^k%l-m"))
    show("dot", values(__K2L_Regex.new("a.c", "a[^\n\r]c"), "abc a\nc a.c"))
    show("class", values(__K2L_Regex.new("[a-c]+", "[a-c]+"), "aabbcc dd cab"))
    show("negated class", values(__K2L_Regex.new("[^aeiou\\s]+", "[^%saeiou]+"), "hello world"))
    show("class members", values(__K2L_Regex.new("[\\d.,-]+", "[%d%.%,%-]+"), "1,234.5 -7 x"):plusAll(values(__K2L_Regex.new("[-+*/]", "[%-%+%*%/]"), "1+2-3*4/5")))
    show("class ] and ^", values(__K2L_Regex.new("[\\]^]+", "[%]%^]+"), "a]^]b^"))
    local ____receiver = __K2L_Regex.new("\\d+", "%d+"):find("ab123c")
    local ____arg = __K2L_Str(____receiver and ____receiver.value)
    local ____receiver_1 = __K2L_Regex.new("\\D+", "%D+"):find("12ab3")
    show("\\d \\D", ____arg .. " " .. __K2L_Str(____receiver_1 and ____receiver_1.value))
    show("\\w \\W", values(__K2L_Regex.new("\\w+", "[%w_]+"), "snake_case, x2!"):plusAll(values(__K2L_Regex.new("\\W+", "[^%w_]+"), "a, b!")))
    show("\\s \\S", __K2L_Regex.new("\\s+", "%s+"):split("one  two\tthree"):plusAll(values(__K2L_Regex.new("\\S+", "%S+"), " a bc ")))
    show("\\w in a class", values(__K2L_Regex.new("[\\w-]+", "[%w_%-]+"), "well-known self_made!"))
    show("^", tostring(__K2L_Regex.new("^ab", "^ab"):containsMatchIn("abc")) .. " " .. tostring(__K2L_Regex.new("^ab", "^ab"):containsMatchIn("cab")) .. " " .. __K2L_Str(values(__K2L_Regex.new("^a", "^a"), "aaa")))
    show("$", tostring(__K2L_Regex.new("c$", "c$"):containsMatchIn("abc")) .. " " .. tostring(__K2L_Regex.new("c$", "c$"):containsMatchIn("cab")) .. " " .. tostring(__K2L_Regex.new("^$", "^$"):matches("")))
    show("?", values(__K2L_Regex.new("colou?r", "colou?r"), "color colour colouur"))
    show("*", values(__K2L_Regex.new("ab*", "ab*"), "a ab abbb"))
    show("+", values(__K2L_Regex.new("[0-9]+", "[0-9]+"), "1 22 x 333"))
    local ____arg_1 = __K2L_Str(values(__K2L_Regex.new("<.*?>", "<[^\n\r]->"), "<a><bb>"))
    local ____receiver_2 = __K2L_Regex.new("<.*>", "<[^\n\r]*>"):find("<a><bb>")
    show("lazy *?", ____arg_1 .. " " .. __K2L_Str(____receiver_2 and ____receiver_2.value))
    local ____receiver_3 = __K2L_Regex.new("a+?", "aa-"):find("aaa")
    local ____arg_2 = __K2L_Str(____receiver_3 and ____receiver_3.value)
    local ____receiver_4 = __K2L_Regex.new("<.+?>", "<[^\n\r][^\n\r]->"):find("<><a>")
    show("lazy +?", ____arg_2 .. " " .. __K2L_Str(____receiver_4 and ____receiver_4.value))
    local ____receiver_5 = __K2L_Regex.new("\\d{4}-\\d{2}-\\d{2}", "%d%d%d%d%-%d%d%-%d%d"):find("on 2024-03-15.")
    show("{n}", ____receiver_5 and ____receiver_5.value)
    show("{n,m}", values(__K2L_Regex.new("x{2,3}", "xxx?"), "x xx xxx xxxx"))
    show("{n,}", values(__K2L_Regex.new("a{2,}", "aaa*"), "a aa aaaa"))
    local ____receiver_6 = __K2L_Regex.new("(\\w+)@(\\w+)\\.com", "([%w_]+)@([%w_]+)%.com"):find("mail me@home.com")
    show("groups", ____receiver_6 and ____receiver_6.groupValues)
    local ____receiver_7 = __K2L_Regex.new("((\\w)(\\w*))!", "(([%w_])([%w_]*))!"):find("hey hello!")
    show("nested groups", ____receiver_7 and ____receiver_7.groupValues)
    show("back-reference", values(__K2L_Regex.new("(\\w)\\1", "([%w_])%1"), "bookkeeper aardvark"))
    show("\\b before", __K2L_Sequence.new(__K2L_Regex.new("\\bcat", "%f[%w_]cat"):findAllFactory("cat concat cat's bobcat")):map(____lambda_2):toList())
    show("\\b after", values(__K2L_Regex.new("\\w+ing\\b", "[%w_]+ing%f[^%w_]"), "singing kingdom ring"))
    show("\\b both", values(__K2L_Regex.new("\\b\\d+\\b", "%f[%w_]%d+%f[^%w_]"), "12 a34 56b 78"))
    show("ignore case", values(__K2L_Regex.new("hello [a-c]+", "[hH][eE][lL][lL][oO] [a-cA-C]+"), "Hello ABC hello cab HELLO d"))
    show("ignore case class", values(__K2L_Regex.new("[^a-z ]+", "[^a-zA-Z ]+"), "Hi 42 there!"))
    show("(?i)", values(__K2L_Regex.new("(?i)error", "[eE][rR][rR][oO][rR]"), "Error ERROR error eRRor"))
    show("LITERAL", tostring(__K2L_Regex.new("a.b*", "a%.b%*"):matches("a.b*")) .. " " .. tostring(__K2L_Regex.new("a.b*", "a%.b%*"):matches("axbb")))
    show("DOT_MATCHES_ALL", tostring(__K2L_Regex.new("a.c", "a.c"):matches("a\nc")) .. " " .. tostring(__K2L_Regex.new("a.c", "a[^\n\r]c"):matches("a\nc")))
    show("escapes", __K2L_Regex.new("\\t\\x41\\u0042\\n\\\\", "\tAB\n\\"):matches("\tAB\n\\"))
    show("\\Q...\\E", __K2L_Regex.new("\\Q1+1=2\\E!", "1%+1=2!"):containsMatchIn("so 1+1=2!"))
    local ____receiver_8 = __K2L_Regex.new("café", "café"):find("un café")
    show("non-ASCII", __K2L_Str(____receiver_8 and ____receiver_8.range) .. " " .. __K2L_Sequence.new(__K2L_Regex.new("[a-z]+", "[a-z]+"):findAllFactory("naïve")):count())
    show("options set", __K2L_Regex.new("a.c", "[aA].[cC]"):matches("A\nC"))
end

local WORD = "\\w+"

local function constants()
    local ____receiver_9 = __K2L_Regex.new("(\\w+)@(\\w+)\\.com", "([%w_]+)@([%w_]+)%.com"):find("mail me@home.com")
    show("const val", ____receiver_9 and ____receiver_9.groupValues)
    local ____receiver_10 = __K2L_Regex.new("[a-c]+", "[a-cA-C]+"):find("xxABCa")
    show("const ignore case", ____receiver_10 and ____receiver_10.value)
    local star = __K2L_ListOf("*", "+"):first()
    local ____receiver_11 = __K2L_Regex.fromLiteral(star .. "."):find("a**.b")
    show("fromLiteral at run time", __K2L_Str(____receiver_11 and ____receiver_11.range) .. " " .. tostring(__K2L_Regex.fromLiteral(star .. "%"):matches("*%")))
    show("escape at run time", __K2L_Regex.escape(star))
end

local ____lambda_3 = function(it) return it.value end
local ____lambda_4 = function(it)
    return tostring(__K2L_StringToInt(it.value) * 2)
end
local ____lambda_5 = function(it) return "-" end
local function api()
    local range = __K2L_Regex.new("(\\d+)-(\\d+)", "(%d+)%-(%d+)")
    local m = __K2L_NotNull(range:find("range 10-20 and 3-4"))
    show("value", m.value)
    show("range", m.range)
    show("groupValues", m.groupValues)
    local ____destructured = m.destructured
    local from, to = ____destructured[1], ____destructured[2]
    show("destructured", from .. " " .. to)
    local ____receiver_12 = m.groups:get(1)
    show("groups", __K2L_Str(____receiver_12 and ____receiver_12.value) .. " " .. m.groups.size)
    local ____receiver_13 = m:next()
    local ____arg_3 = __K2L_Str(____receiver_13 and ____receiver_13.value)
    local ____receiver_14 = m:next()
    show("next", ____arg_3 .. " " .. __K2L_Str(____receiver_14 and ____receiver_14:next()))
    local ____receiver_15 = __K2L_Regex.new("(\\w+)=(\\w+)", "([%w_]+)=([%w_]+)"):matchEntire("key=value")
    show("matchEntire", __K2L_Str(____receiver_15 and ____receiver_15.groupValues) .. " " .. __K2L_Str(__K2L_Regex.new("\\w+", "[%w_]+"):matchEntire("a b")))
    show("matches", tostring(range:matches("1-2")) .. " " .. tostring(range:matches("1-2x")) .. " " .. tostring(__K2L_Regex.new("a*?", "a-"):matches("aaa")))
    show("containsMatchIn", tostring(range:containsMatchIn("x 1-2 y")) .. " " .. tostring(range:containsMatchIn("1 2")))
    local ____receiver_16 = __K2L_Regex.new("\\d", "%d"):find("a1b2", 2)
    show("find from", ____receiver_16 and ____receiver_16.range)
    show("findAll from", values(__K2L_Regex.new("\\d", "%d"), "1a2b3"):plusAll(__K2L_Sequence.new(__K2L_Regex.new("\\d", "%d"):findAllFactory("1a2b3", 1)):map(____lambda_3):toList()))
    local ____receiver_17 = __K2L_Regex.new("\\d+", "%d+"):matchAt("ab12", 2)
    show("matchAt", __K2L_Str(____receiver_17 and ____receiver_17.value) .. " " .. tostring(__K2L_Regex.new("\\d+", "%d+"):matchesAt("ab12", 1)) .. " " .. tostring(__K2L_Regex.new("\\bb", "%f[%w_]b"):matchesAt("ab", 1)))
    show("replace", __K2L_Regex.new("(\\w+)@(\\w+)", "([%w_]+)@([%w_]+)"):replace("me@home you@work", "$2:$1"))
    show("replace %", __K2L_Regex.new("(\\d+)", "(%d+)"):replace("5 and 6", "$1%"))
    show("replace escapes", __K2L_Regex.new("\\d+", "%d+"):replace("cost 5", "\\$$0"))
    show("replace transform", __K2L_Regex.new("\\d+", "%d+"):replace("a1b22", ____lambda_4))
    show("replace empty matches", __K2L_Regex.new("x*", "x*"):replace("abc", "-") .. " " .. __K2L_Regex.new("x*", "x*"):replace("abc", ____lambda_5))
    show("replaceFirst", __K2L_Regex.new("o", "o"):replaceFirst("foo boo", "0"))
    show("split", __K2L_Regex.new(",\\s*", ",%s*"):split("a, b,c,,d"):plusAll(__K2L_Regex.new("\\d", "%d"):split("a1b2c", 2)))
    show("splitToSequence", __K2L_AsSequence(__K2L_Regex.new("-", "%-"):split("x-y-z")):toList())
    show("escape", "\\Q1+1\\E" .. " " .. tostring(__K2L_Regex.new("\\Q1+1\\E", "1%+1"):containsMatchIn("1+1=2")))
    show("escapeReplacement", __K2L_Regex.new("x", "x"):replace("axb", "\\$1\\\\"))
    show("pattern", __K2L_Regex.new("a+b", "a+b").pattern .. " " .. __K2L_Str(__K2L_Regex.new("a+b", "a+b")))
    local ____list = __K2L_ListOf("$", "\\", "$3")
    for ____i = 1, ____list.size do
        local bad = ____list[____i]
        local e = __K2L_RunCatching(function() return range:replace("1-2", bad) end):exceptionOrNull()
        print("  replacement '" .. bad .. "': " .. __K2L_Str(e and __K2L_SimpleName(e)))
    end
end

local ____lambda_6 = function(it) return it.value:upper() end
local function strings()
    show("String.split", __K2L_Regex.new("\\d+", "%d+"):split("a1b22c"))
    show("String.split limit", __K2L_Regex.new(" ", " "):split("a b c d", 2))
    show("String.replace", __K2L_Regex.new("(\\d+)-(\\d+)-(\\d+)", "(%d+)%-(%d+)%-(%d+)"):replace("2024-03-15", "$3/$2/$1"))
    show("String.replace transform", __K2L_Regex.new("[a-z]", "[a-z]"):replace("a-b", ____lambda_6))
    show("String.replaceFirst", __K2L_Regex.new("a", "a"):replaceFirst("aaa", "b"))
    show("String.matches", tostring(__K2L_Regex.new("[a-c]+", "[a-c]+"):matches("abc")) .. " " .. tostring(__K2L_Regex.new("[a-c]+", "[a-c]+"):matches("abd")))
    show("String.contains", tostring(__K2L_Regex.new("o w", "o w"):containsMatchIn("hello world")) .. " " .. tostring(__K2L_Regex.new("\\d", "%d"):containsMatchIn("hello")))
    show("toRegex", __K2L_Sequence.new(__K2L_Regex.new("\\d", "%d"):findAllFactory("1a2")):count() .. " " .. tostring(__K2L_Regex.new("AB", "[aA][bB]"):matches("ab")))
    show("plain", __K2L_StringSplit("a.b.c", "."):plus(__K2L_StringReplace("a.b", ".", "%")):plusAll(__K2L_StringSplit("x%y", "%")):plus(__K2L_StringReplace("a+b", "+", "$1")))
end

local function main()
    constructs()
    constants()
    api()
    strings()
end

__K2L_RunMain(main)
return {show = show, values = values, constructs = constructs, WORD = WORD, constants = constants, api = api, strings = strings}
