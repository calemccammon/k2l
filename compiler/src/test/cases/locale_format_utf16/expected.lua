local ____lualib = require("lualib_bundle")
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Locale = ____lualib.__K2L_Locale
local __K2L_LocaleFormat = ____lualib.__K2L_LocaleFormat
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_Utf16 = ____lualib.__K2L_Utf16
local __K2L_Utf16Case = ____lualib.__K2L_Utf16Case
local __K2L_Utf16Locale = ____lualib.__K2L_Utf16Locale

local function main()
    local tr = __K2L_Locale.of("tr", "TR")
    print(__K2L_Utf16.out(__K2L_LocaleFormat.format(tr, __K2L_Utf16Locale.uppercase, "%S", "istanbul iI")))
    print(__K2L_Utf16.out(__K2L_LocaleFormat.format(tr, nil, "%s", "istanbul iI")))
    print(__K2L_Utf16.out(__K2L_LocaleFormat.format(tr, __K2L_Utf16Locale.uppercase, "%10S|%-10S|", "ii", "ıİ")))
    print(__K2L_Utf16.out(__K2L_LocaleFormat.format(tr, __K2L_Utf16Locale.uppercase, "%C %c", "i", "i")))
    print(__K2L_Utf16.out(__K2L_LocaleFormat.format(tr, __K2L_Utf16Locale.uppercase, "%S and %S", "i", "ı")))
    print(__K2L_Utf16.out(__K2L_LocaleFormat.format(__K2L_Locale.of("az"), __K2L_Utf16Locale.uppercase, "%S", "iı")))
    print(__K2L_Utf16.out(__K2L_LocaleFormat.format(__K2L_Locale.of("lt"), __K2L_Utf16Locale.uppercase, "%S", "i̇")))
    print(__K2L_Utf16.out(__K2L_Text.formatWith(nil, __K2L_Utf16Case.uppercase, "%S", "istanbul straße")))
    print(__K2L_Utf16.out(__K2L_Text.formatWith(nil, __K2L_Utf16Case.uppercase, "%S %C", "straße ǆ", "ß")))
    print(__K2L_Utf16.out(__K2L_LocaleFormat.format("de_DE", __K2L_Utf16Case.uppercase, "%S", "ñandú straße")))
    print(__K2L_Utf16.out(__K2L_Text.formatWith(nil, __K2L_Utf16Case.uppercase, "%S", "ǰ ŉ ﬁ")))
    print(__K2L_Utf16.out(__K2L_Text.formatWith(nil, __K2L_Utf16Case.uppercase, "%S|%10S|%-8S|", "é", "ü", "ö")))
    print(__K2L_Utf16.out(__K2L_Text.formatWith(nil, __K2L_Utf16Case.uppercase, "%B %b", true, false)))
    print(__K2L_Utf16.out(__K2L_LocaleFormat.format(tr, __K2L_Utf16Locale.uppercase, "%B", "istanbul" == "istanbul")))
    print(__K2L_Utf16.out(__K2L_LocaleFormat.format("fr_FR", __K2L_Utf16Case.uppercase, "%S %,d", "été", 1234567)))
    print(__K2L_Utf16.out(__K2L_LocaleFormat.format(tr, __K2L_Utf16Locale.uppercase, "%S %,.2f", "i", 1234567.891)))
    local locales = __K2L_ReadOnlyListOf("en_US", tr, __K2L_Locale.of("az", "AZ"), "de_DE")
    local ____out = {}
    local ____count = 0
    local ____items, ____n = locales:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = __K2L_LocaleFormat.format(it, __K2L_Utf16Locale.uppercase, "%S", "iI")
    end
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ListWrap(____out, ____count))))
    print(__K2L_Utf16.out(__K2L_Text.formatWith(nil, __K2L_Utf16Case.uppercase, "%s %S", "ß", "ß")))
    print(__K2L_Utf16.out(__K2L_LocaleFormat.format(__K2L_Locale.of("ar", "EG"), __K2L_Utf16Locale.uppercase, "%S %d", "abc", 42)))
end

main()
