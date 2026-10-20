local ____lualib = require("lualib_bundle")
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Utf16 = ____lualib.__K2L_Utf16

local ____lambda_1 = function(it) return it.value end
local function show(pattern, text)
    local r = __K2L_Regex.new(pattern)
    print(__K2L_Utf16.out(__K2L_StringFormat("%-22s %s", pattern, __K2L_Sequence.new(r:findAllFactory(text)):map(____lambda_1):joinToString("|", "[", "]"))))
end

local ____lambda_2 = function(it)
    return __K2L_StringFormat("%04X", __K2L_Utf16.code(__K2L_Text.get(it.value, 0)))
end
local ____lambda_3 = function(it) return it.value end
local ____lambda_4 = function(it) return it.value end
local ____lambda_5 = function(it) return it.value end
local function main()
    local text = "Ça coûte 12€ — ǅemal Ünal, ΣΊΣΥΦΟΣ ١٢٣ x́ a\tb c d"
    local ____list = __K2L_ReadOnlyListOf("\\p{L}+", "\\p{Lu}", "\\p{Ll}+", "\\p{Lt}", "\\p{N}+", "\\p{Nd}+", "\\p{IsDigit}+", "\\p{M}", "\\p{IsLetter}+", "\\p{javaUpperCase}", "\\p{Alpha}+", "\\p{Upper}", "\\p{Digit}+", "[\\p{L}\\p{M}]+", "[^\\p{L}\\s]+", "\\P{L}+", "[\\p{Lu}\\d]+", "\\p{IsAlphabetic}{3,}", "\\p{javaLetterOrDigit}+", "[\\P{L}&&[^ ]]")
    for ____i = 1, ____list.size do
        local p = ____list[____i]
        local ____ok, ____result = pcall(function()
            show(p, text)
        end)
        if not ____ok then
            local ____error = __K2L_ToThrowable(____result)
            if __K2L_InstanceOf(____error, __K2L_Exception) then
                local e = ____error
                print(__K2L_Utf16.out(__K2L_StringFormat("%-22s %s", p, __K2L_KClassOfValue(e).simpleName)))
            else
                error(____error, 0)
            end
        end
    end
    local spaces = "a b\tc d e fg"
    local ____list_1 = __K2L_ReadOnlyListOf("\\p{Z}", "\\p{Zs}", "\\p{IsWhite_Space}", "\\p{javaWhitespace}", "\\s", "\\p{Space}")
    for ____i_1 = 1, ____list_1.size do
        local p = ____list_1[____i_1]
        print(__K2L_Utf16.out(__K2L_StringFormat("%-22s %s", p, __K2L_Sequence.new(__K2L_Regex.new(p):findAllFactory(spaces)):map(____lambda_2):toList())))
    end
    local dynamic = "\\p{" .. "Lu" .. "}"
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new(dynamic):findAllFactory("ÀbÇdÉ")):map(____lambda_3):toList():plus(" "):plus(__K2L_Regex.new("\\p{Ll}+"):replace("ÀbcÇdé", "_")))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("\\b\\p{Lu}\\p{Ll}+"):findAllFactory("Ärger über Öl und Ébène")):map(____lambda_4):toList())))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Regex.new("\\P{L}+"):split("Größe 12 straße"):plus(" "):plus(__K2L_Regex.new("^\\p{Lu}"):containsMatchIn("Éclair")))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("[\\p{L}&&[^aeiou]]+"):findAllFactory("crème brûlée")):map(____lambda_5):toList())))
end

main()
return {show = show}
