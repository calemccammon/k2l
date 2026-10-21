local ____lualib = require("lualib_bundle")
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Locale = ____lualib.__K2L_Locale
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_Utf16 = ____lualib.__K2L_Utf16
local __K2L_Utf16Case = ____lualib.__K2L_Utf16Case
local __K2L_Utf16Locale = ____lualib.__K2L_Utf16Locale

local ____lambda_1 = function(it)
    return __K2L_Num.toRadix(__K2L_Utf16.code(it), 16)
end
local function hex(s)
    return __K2L_Utf16.norm(__K2L_Text.toList(s):map(____lambda_1):joinToString(" "))
end

local ____lambda_2 = function(it) return __K2L_Utf16Case.titlecase(it) end
local function main()
    local tr = __K2L_Locale.of("tr")
    local trTR = __K2L_Locale.of("tr", "TR")
    local az = __K2L_Locale.forLanguageTag("az-Latn-AZ")
    local lt = __K2L_Locale.of("LT", "lt")
    local others = __K2L_ReadOnlyListOf("", "en", "en_US", "de_DE", __K2L_Locale.of("el"), "fr_FR")
    print(__K2L_Utf16.out(__K2L_Utf16Locale.uppercase("Iİıi", tr)))
    print(__K2L_Utf16.out(__K2L_Utf16Locale.lowercase("Iİıi", trTR)))
    print(__K2L_Utf16.out(__K2L_Utf16Locale.lowercase("TITLE İSTANBUL", tr)))
    print(__K2L_Utf16.out(__K2L_Utf16Locale.uppercase("title istanbul", az)))
    print(__K2L_Utf16.out(hex(__K2L_Utf16Locale.lowercase("İx", tr))))
    print(__K2L_Utf16.out(hex(__K2L_Utf16Locale.lowercase("IỊ̇", tr))))
    print(__K2L_Utf16.out(hex(__K2L_Utf16Locale.lowercase("Ị̇", trTR))))
    print(__K2L_Utf16.out(hex(__K2L_Utf16Locale.lowercase("Í̇", tr))))
    print(__K2L_Utf16.out(hex(__K2L_Utf16Locale.lowercase("̇", tr))))
    print(__K2L_Utf16.out(hex(__K2L_Utf16Locale.uppercase("Iß", tr))))
    print(__K2L_Utf16.out(hex(__K2L_Utf16Locale.uppercase("ıÇ", tr))))
    local ____mod = others.____modCount
    for ____i = 1, others.size do
        local locale = others[____i]
        print(__K2L_Utf16.out(hex(__K2L_Utf16Locale.lowercase("Iİıi", locale)) .. " | " .. hex(__K2L_Utf16Locale.uppercase("Iİıi", locale))))
        if others.____modCount ~= ____mod and others:____comodified(____i) then
            break
        end
    end
    print(__K2L_Utf16.out(hex(__K2L_Utf16Locale.lowercase("Ì", lt))))
    print(__K2L_Utf16.out(hex(__K2L_Utf16Locale.lowercase("J́x", lt))))
    print(__K2L_Utf16.out(hex(__K2L_Utf16Locale.lowercase("Į̃", lt))))
    print(__K2L_Utf16.out(hex(__K2L_Utf16Locale.lowercase("Ix", lt))))
    print(__K2L_Utf16.out(hex(__K2L_Utf16Locale.lowercase("Ì̖", lt))))
    print(__K2L_Utf16.out(hex(__K2L_Utf16Locale.lowercase("Ị", lt))))
    print(__K2L_Utf16.out(hex(__K2L_Utf16Locale.lowercase("ÌÍĨ", lt))))
    print(__K2L_Utf16.out(hex(__K2L_Utf16Locale.uppercase("i̇", lt))))
    print(__K2L_Utf16.out(hex(__K2L_Utf16Locale.uppercase("j̣̇", lt))))
    print(__K2L_Utf16.out(hex(__K2L_Utf16Locale.uppercase("̇", lt))))
    print(__K2L_Utf16.out(hex(__K2L_Utf16Locale.uppercase("ȧ", lt))))
    print(__K2L_Utf16.out(hex(__K2L_Utf16Case.uppercase("i̇"))))
    print(__K2L_Utf16.out(hex(__K2L_Utf16Locale.lowercase("ΑΣ ΣΑΣ", tr))))
    print(__K2L_Utf16.out(hex(__K2L_Utf16Case.lowercase("İ"))))
    print(__K2L_Utf16.out(hex(__K2L_Utf16Locale.lowercase("İ", tr))))
    print(__K2L_Utf16.out(__K2L_Text.replaceFirstChar("istanbul", function(it) return __K2L_Utf16Locale.titlecase(it, tr) end)))
    print(__K2L_Utf16.out(__K2L_Text.replaceFirstChar("istanbul", ____lambda_2)))
    print(__K2L_Utf16.out(__K2L_Utf16Case.titlecase("ǆ")))
    local ____list = __K2L_ReadOnlyListOf("i", "I", "ı", "İ", "ß", "ŉ", "ǆ", "a", "ǰ")
    for ____i_1 = 1, ____list.size do
        local c = ____list[____i_1]
        print(__K2L_Utf16.out(__K2L_Utf16.norm(c .. " " .. hex(__K2L_Utf16Locale.titlecase(c, tr)) .. " " .. hex(__K2L_Utf16Locale.titlecase(c, lt)) .. " " .. hex(__K2L_Utf16Case.titlecase(c)) .. " " .. hex(__K2L_Utf16Case.titlecase(c)))))
    end
    print(__K2L_Utf16.out(__K2L_Locale.language(tr) .. " " .. __K2L_Str(__K2L_Locale.country(trTR)) .. " " .. __K2L_Str(trTR) .. " " .. __K2L_Str(lt) .. " " .. __K2L_Str(az)))
    print(__K2L_Utf16.out(__K2L_Locale.languageTag("") .. " " .. __K2L_Str(__K2L_Locale.languageTag(trTR)) .. " " .. __K2L_Str(__K2L_Locale.languageTag(__K2L_Locale.of("", "US")))))
    print(__K2L_Utf16.out(__K2L_Locale.forLanguageTag("de-CH-1996") .. " " .. __K2L_Str(__K2L_Locale.forLanguageTag("und")) .. "|"))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Locale.variant(__K2L_Locale.of("en", "us", "posix")))))
    print(__K2L_Utf16.out(__K2L_Utf16.len(__K2L_Locale.language("en_US"))))
    print(__K2L_Utf16.out(__K2L_Equals(tr, __K2L_Locale.of("TR")) and not __K2L_Equals(tr, trTR) and __K2L_Equals(trTR, __K2L_Locale.of("tr", "tr"))))
end

__K2L_Main(main)
return {hex = hex}
