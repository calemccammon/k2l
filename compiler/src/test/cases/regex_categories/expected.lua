local ____lualib = require("lualib_bundle")
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringPadEnd = ____lualib.__K2L_StringPadEnd
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_Text = ____lualib.__K2L_Text

local CATEGORIES = __K2L_ReadOnlyListOf("Lu", "Ll", "Lt", "Lm", "Lo", "Mn", "Mc", "Me", "Nd", "Nl", "No", "Zs", "Zl", "Zp", "Cc", "Cf", "Co", "Cs", "Cn", "Pd", "Ps", "Pe", "Pc", "Po", "Pi", "Pf", "Sm", "Sc", "Sk", "So", "L", "LC", "M", "N", "P", "S", "Z", "C")
local ASCII = __K2L_IntRange.new(0, 128 - 1):map(function(it) return string.char(it) end):joinToString("")

local function members(regex)
    return __K2L_StringToList(__K2L_Text.filter(ASCII, function(it) return regex:matches(it) end)):map(function(it)
        if it < " " then
            return "^" .. string.char(it:byte() + 64)
        else
            return it == "\127" and "DEL" or it
        end
    end):joinToString("")
end

local ____lambda_1 = function(it) return it.value end
local function main()
    local ____list = CATEGORIES
    local ____mod = ____list.____modCount
    for ____i = 1, ____list.size do
        local name = ____list[____i]
        print(__K2L_StringPadEnd(name, 3) .. " " .. members(__K2L_Regex.new("\\p{" .. name .. "}")))
        if ____list.____modCount ~= ____mod and ____list:____comodified(____i) then
            break
        end
    end
    local forms = __K2L_ReadOnlyListOf("\\p{IsLu}", "\\p{gc=Lu}", "\\p{general_category=Nd}", "\\p{GC=Ps}", "\\pL", "\\pN", "\\P{L}", "\\PL", "\\P{IsN}", "[\\p{Lu}\\p{Nd}]", "[^\\p{Ll}\\p{Cc}]", "[\\P{L}&&[a-f0-5]]", "[\\p{Sm}\\p{Sc}]", "\\p{IsAlphabetic}", "\\p{IsUPPERCASE}", "\\p{Isuppercase}", "\\p{IsWhite_Space}", "\\p{IsPunctuation}", "\\p{IsAlpha}", "\\p{gc=Alnum}", "(?i)\\p{Lu}", "(?i)\\p{Ll}", "(?i)\\p{Lt}", "(?i)\\p{L}", "(?i)\\P{Lu}")
    local ____mod_1 = forms.____modCount
    for ____i_1 = 1, forms.size do
        local form = forms[____i_1]
        print(__K2L_StringPadEnd(form, 22) .. " " .. members(__K2L_Regex.new(form)))
        if forms.____modCount ~= ____mod_1 and forms:____comodified(____i_1) then
            break
        end
    end
    print(__K2L_Regex.new("\\p{Lu}"):replace("Hello, World! 42 (x+y)", "_"))
    print(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("\\p{Lu}\\p{Ll}+"):findAllFactory("Camel case: ParseHTTPRequest Now")):map(____lambda_1):toList()))
    print(__K2L_Str(__K2L_Regex.new("[\\p{Pd}\\p{Pc}\\p{Ps}\\p{Pe}]+"):split("a-b_c(d)[e]{f}")))
    print(__K2L_Str(__K2L_Pair.new(__K2L_Regex.new("^\\p{Nd}+$"):matches("2024"), __K2L_Regex.new("^\\p{Nd}+$"):matches("20x4"))))
    local ____list_1 = __K2L_ReadOnlyListOf("\\p{Xx}", "\\p{lu}", "\\p{IsGreekish}", "\\p{InNoSuchBlock}", "\\p{gc=Xx}", "\\p{foo=Lu}")
    for ____i_2 = 1, ____list_1.size do
        local bad = ____list_1[____i_2]
        local result = __K2L_RunCatching(function() return __K2L_Regex.new(bad) end)
        local ____value = result:exceptionOrNull()
        print(bad .. " -> " .. (__K2L_InstanceOf(____value, __K2L_IllegalArgumentException) and "rejected" or "accepted"))
    end
end

__K2L_DeepMain(main)
return {CATEGORIES = CATEGORIES, ASCII = ASCII, members = members}
