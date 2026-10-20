local ____lualib = require("lualib_bundle")
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringPadEnd = ____lualib.__K2L_StringPadEnd
local __K2L_StringToList = ____lualib.__K2L_StringToList

local function classify(regex, text)
    return __K2L_StringToList(text):map(function(it)
        return __K2L_Regex.new(regex):matches(it) and "1" or "0"
    end):joinToString("")
end

local ____lambda_1 = function(it) return string.char(it) end
local ____lambda_2 = function(it) return it.value end
local function main()
    local ____list = __K2L_IntRange.new(33, 126):map(____lambda_1)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        if it:match("^%w$") == nil then
            ____count = ____count + 1
            ____out[____count] = it
        end
    end
    local ascii = __K2L_ListWrap(____out, ____count):joinToString("")
    print(ascii)
    local ____list_1 = __K2L_ReadOnlyListOf("\\p{P}", "\\p{IsP}", "\\p{IsPunctuation}", "\\p{Punct}", "\\p{S}", "\\p{IsS}", "\\P{P}", "[\\p{P}\\p{S}]")
    for ____i_1 = 1, ____list_1.size do
        local regex = ____list_1[____i_1]
        print(__K2L_StringPadEnd(regex, 20) .. " " .. classify(regex, ascii))
    end
    print(__K2L_Regex.new("\\p{P}+"):replace("Hello, world! (a+b) = $5; x_y", ""))
    print(__K2L_Str(__K2L_Regex.new("[\\s\\p{P}]+"):split("Hello, world! (a+b) = $5; x_y")))
    print(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("\\p{S}"):findAllFactory("1+2<3 and $4|^")):map(____lambda_2):toList()))
end

main()
return {classify = classify}
