local ____lualib = require("lualib_bundle")
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_Utf16 = ____lualib.__K2L_Utf16

local function classify(regex, text)
    return __K2L_Utf16.norm(__K2L_Text.toList(text):map(function(it)
        return __K2L_Regex.new(regex):matches(it) and "1" or "0"
    end):joinToString(""))
end

local ____lambda_1 = function(it) return it.value end
local function main()
    local text = "¡¿«»—–…‘’“”·§¶†€£¥©®°±×÷≠∞→★♥€ｦ、。「」"
    local ____list = __K2L_ReadOnlyListOf("\\p{P}", "\\p{IsPunctuation}", "\\p{Punct}", "\\p{S}", "\\P{P}", "[\\p{P}\\p{S}]", "[^\\p{P}]")
    for ____i = 1, ____list.size do
        local regex = ____list[____i]
        print(__K2L_Utf16.out(__K2L_Text.padEnd(regex, 20) .. " " .. classify(regex, text)))
    end
    print(__K2L_Utf16.out(__K2L_Regex.new("\\p{P}"):replace("«Bonjour», dit-il… “¿Qué?” — ¡sí!", "")))
    local ____list_1 = __K2L_Regex.new("\\p{S}+"):split("Prix: 5€ ± 2£ → ★")
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list_1:____array()
    for ____i_1 = 1, ____n do
        local it = ____items[____i_1]
        ____count = ____count + 1
        ____out[____count] = __K2L_Text.trim(it)
    end
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ListWrap(____out, ____count))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("[\\p{L}\\p{P}]+"):findAllFactory("naïve—café, ok? 😀 «x»")):map(____lambda_1):toList())))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Pair.new(__K2L_Regex.new("\\p{P}"):containsMatchIn("𐄀"), __K2L_Regex.new("\\p{S}"):containsMatchIn("😀")))))
end

main()
return {classify = classify}
