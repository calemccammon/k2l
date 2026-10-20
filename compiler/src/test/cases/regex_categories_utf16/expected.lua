local ____lualib = require("lualib_bundle")
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_Utf16 = ____lualib.__K2L_Utf16

local CATEGORIES = __K2L_ReadOnlyListOf("Lu", "Ll", "Lt", "Lm", "Lo", "Mn", "Mc", "Me", "Nd", "Nl", "No", "Zs", "Zl", "Zp", "Cc", "Cf", "Co", "Cn", "Pd", "Ps", "Pe", "Pc", "Po", "Pi", "Pf", "Sm", "Sc", "Sk", "So", "L", "LC", "M", "N", "P", "S", "Z", "C")
local ____builder = __K2L_StringBuilder.new()
do
    local cp = 128
    while cp < 1114112 do
        local ____value = cp
        if not (____value >= 55296 and ____value <= 57343) then
            ____builder:appendCodePoint(cp)
        end
        cp = cp + (cp < 196608 and 7 or 4099)
    end
end
local SAMPLE = ____builder:toString()

local function summary(regex)
    local count = 0
    local sum = 0
    for _, m in __K2L_Sequence.new(regex:findAllFactory(SAMPLE)):iter() do
        count = count + 1
        local ____dividend = sum * 31 + __K2L_Hash(m.value)
        sum = ____dividend >= 0 and ____dividend % 1000000007 or (____dividend % 1000000007 - 1000000007) % (-1000000007)
    end
    return count .. " " .. sum
end

local ____lambda_1 = function(it) return it.value end
local ____lambda_2 = function(it) return it.value end
local function main()
    local ____list = CATEGORIES
    local ____mod = ____list.____modCount
    for ____i = 1, ____list.size do
        local name = ____list[____i]
        print(__K2L_Utf16.out(__K2L_Text.padEnd(name, 3) .. " " .. summary(__K2L_Regex.new("\\p{" .. name .. "}"))))
        if ____list.____modCount ~= ____mod and ____list:____comodified(____i) then
            break
        end
    end
    local ____list_1 = __K2L_ReadOnlyListOf("\\P{L}", "\\p{IsLu}", "\\p{gc=Nl}", "[\\p{Lu}\\p{Lt}]", "[^\\p{L}\\p{N}\\p{Cn}]", "(?i)\\p{Lt}", "\\pM")
    for ____i_1 = 1, ____list_1.size do
        local form = ____list_1[____i_1]
        print(__K2L_Utf16.out(__K2L_Text.padEnd(form, 22) .. " " .. summary(__K2L_Regex.new(form))))
    end
    local text = "Ⓐ ⓑ Ǆemal ǅuro: Ⅻ ½ ٣ ʰ 中 é ́ ‿ « » ‹ › ‐ ¢ ˆ ⊕ ©   ­  𝐀 𐍁 😀"
    local ____list_2 = __K2L_ReadOnlyListOf("Lu", "Ll", "Lt", "Lm", "Lo", "Nl", "No", "Nd", "Mn", "Pc", "Pi", "Pf", "Pd", "Sc", "Sk", "Sm", "So", "Zl", "Cf", "Co")
    for ____i_2 = 1, ____list_2.size do
        local name = ____list_2[____i_2]
        print(__K2L_Utf16.out(name .. ": " .. __K2L_Sequence.new(__K2L_Regex.new("\\p{" .. name .. "}"):findAllFactory(text)):map(____lambda_1):joinToString(" ")))
    end
    print(__K2L_Utf16.out(__K2L_Regex.new("[\\p{Z}\\p{P}]+"):replace(text, "|")))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("\\p{Lu}\\p{Ll}*"):findAllFactory("Ἀθῆναι Ελλάδα Ärger Öl")):map(____lambda_2):toList())))
end

main()
return {CATEGORIES = CATEGORIES, SAMPLE = SAMPLE, summary = summary}
