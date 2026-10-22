local ____lualib = require("lualib_bundle")
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_Str = ____lualib.__K2L_Str

local ____lambda_1 = function(it) return it.value end
local ____lambda_2 = function(it) return "<" .. #it.value .. ">" end
local ____lambda_3 = function(it) return it.value end
local ____lambda_4 = function(it)
    return __K2L_Pair.new(it.groupValues:get(1), it.groupValues:get(2))
end
local ____lambda_5 = function(it) return it.value end
local ____lambda_6 = function(it) return it.value end
local function main()
    local digits = __K2L_Regex.new("\\d+", "%d+")
    print(digits:containsMatchIn("abc123"))
    print(digits:matches("123"))
    print(digits:matches("123a"))
    local ____receiver = digits:find("a12b345")
    print(__K2L_Str(____receiver and ____receiver.value))
    local ____receiver_1 = digits:find("a12b345")
    print(__K2L_Str(____receiver_1 and ____receiver_1.range))
    local ____receiver_2 = digits:find("a12b345", 3)
    print(__K2L_Str(____receiver_2 and ____receiver_2.value))
    print(__K2L_Str(__K2L_Sequence.new(digits:findAllFactory("a12b345c6")):map(____lambda_1):toList()))
    print(__K2L_Sequence.new(digits:findAllFactory("a12b345c6")):count())
    print(digits:replace("a1b22c333", "#"))
    print(digits:replace("a1b22c333", ____lambda_2))
    print(digits:replaceFirst("a1b22", "N"))
    print(__K2L_Str(digits:split("a1b22c")))
    print(__K2L_Regex.new("[0-9]", "[0-9]"):replace("a1b22", "_"))
    print(__K2L_Regex.new("o w", "o w"):containsMatchIn("hello world"))
    print(__K2L_Regex.new("[a-c]+", "[a-c]+"):matches("abc"))
    print(__K2L_Str(__K2L_Regex.new("\\s+", "%s+"):split("one two  three")))
    print(__K2L_Sequence.new(__K2L_Regex.new("a1b2", "a1b2"):findAllFactory("a1b2")):map(____lambda_3):joinToString("|"))
    local date = __K2L_Regex.new("(\\d{4})-(\\d{2})-(\\d{2})", "(%d%d%d%d)%-(%d%d)%-(%d%d)")
    local m = __K2L_NotNull(date:find("on 2024-03-15 ok"))
    print(m.value)
    print(__K2L_Str(m.groupValues))
    local ____receiver_3 = m.groups:get(1)
    print(__K2L_Str(____receiver_3 and ____receiver_3.value))
    print(m.groups.size)
    local ____destructured = m.destructured
    local y, mo, d = ____destructured[1], ____destructured[2], ____destructured[3]
    print(d .. "/" .. mo .. "/" .. y)
    print(m.range.first)
    print(__K2L_Str(date:find("none")))
    local named = __K2L_Regex.new("(\\w+)=(\\w+)", "([%w_]+)=([%w_]+)")
    local kv = __K2L_NotNull(named:find("a=1, b=2"))
    local ____receiver_4 = kv.groups:get(1)
    print(__K2L_Str(____receiver_4 and ____receiver_4.value))
    local ____receiver_5 = kv.groups:get(2)
    print(__K2L_Str(____receiver_5 and ____receiver_5.value))
    print(__K2L_Str(__K2L_Sequence.new(named:findAllFactory("a=1, b=2")):map(____lambda_4):toList()))
    print(named:replace("a=1, b=2", "$2:$1"))
    local opt = __K2L_Regex.new("(a)(b?)", "(a)(b?)")
    print(__K2L_Str(__K2L_NotNull(opt:find("a")).groupValues))
    local ____receiver_6 = __K2L_NotNull(opt:find("a")).groups:get(2)
    local ____receiver_7 = ____receiver_6 and ____receiver_6.value
    print(__K2L_Str(____receiver_7 and #____receiver_7 == 0))
    print(__K2L_Regex.new("a.c", "[aA][^\n\r][cC]"):matches("AbC"))
    print(__K2L_Sequence.new(__K2L_Regex.new("^b", "^b"):findAllFactory("b\nbb")):count())
    print(__K2L_Regex.new("a+b", "a+b").pattern)
    print("\\Qa.b*c\\E")
    print(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("colou?r", "colou?r"):findAllFactory("color colour colr")):map(____lambda_5):toList()))
    local ____receiver_8 = __K2L_Regex.new("(\\w)\\1", "([%w_])%1"):find("hello")
    print(__K2L_Str(____receiver_8 and ____receiver_8.value))
    print(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("[^aeiou\\s]+", "[^%saeiou]+"):findAllFactory("hello world")):map(____lambda_6):toList()))
    print(__K2L_Regex.new("\\bfoo\\b", "%f[%w_]foo%f[^%w_]"):containsMatchIn("a foo b"))
    print(__K2L_Str(__K2L_Regex.new("x*", "x*"):split("axxb")))
    local ____receiver_9 = __K2L_Regex.new("a+?", "aa-"):find("aaa")
    print(__K2L_Str(____receiver_9 and ____receiver_9.value))
    local ____receiver_10 = __K2L_Regex.new("\\$\\d+\\.\\d{2}", "%$%d+%.%d%d"):find("cost: $12.50 total")
    print(__K2L_Str(____receiver_10 and ____receiver_10.value))
end

__K2L_RunMain(main)
