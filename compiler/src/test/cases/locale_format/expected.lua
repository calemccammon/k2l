local ____lualib = require("lualib_bundle")
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Locale = ____lualib.__K2L_Locale
local __K2L_LocaleFormat = ____lualib.__K2L_LocaleFormat
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringFormat = ____lualib.__K2L_StringFormat

local function line(locale, number, count)
    print(__K2L_LocaleFormat.format(locale, nil, "%,d|%,.2f|%.3f|%e|%12.1f|%012d|%,15d|%-12d|", count, number, number, number, number, count, count, count))
end

local function main()
    local locales = __K2L_ReadOnlyListOf("en_US", "", "en_GB", "de_DE", "fr_FR", "it_IT", "ja_JP", "zh_CN", "en_CA", "fr_CA", "ko_KR", __K2L_Locale.of("es", "ES"), __K2L_Locale.of("es", "MX"), __K2L_Locale.of("es", "AR"), __K2L_Locale.of("pt", "BR"), __K2L_Locale.of("pt", "PT"), __K2L_Locale.of("ru", "RU"), __K2L_Locale.of("pl", "PL"), __K2L_Locale.of("sv", "SE"), __K2L_Locale.of("nb", "NO"), __K2L_Locale.of("da", "DK"), __K2L_Locale.of("fi", "FI"), __K2L_Locale.of("cs", "CZ"), __K2L_Locale.of("nl", "NL"), __K2L_Locale.of("tr", "TR"), __K2L_Locale.of("de", "CH"), __K2L_Locale.of("de", "AT"), __K2L_Locale.of("fr", "CH"), __K2L_Locale.of("en", "IN"), __K2L_Locale.of("hi", "IN"), __K2L_Locale.of("ar", "EG"), __K2L_Locale.of("ar"), __K2L_Locale.of("fa", "IR"), __K2L_Locale.of("he", "IL"), __K2L_Locale.of("th", "TH"), __K2L_Locale.of("th", "TH", "TH"), __K2L_Locale.of("bn", "BD"), __K2L_Locale.of("mr", "IN"), __K2L_Locale.of("my", "MM"), __K2L_Locale.of("ne", "NP"), __K2L_Locale.of("hu", "HU"), __K2L_Locale.of("uk", "UA"), __K2L_Locale.of("bg", "BG"), __K2L_Locale.of("el", "GR"), __K2L_Locale.of("id", "ID"), __K2L_Locale.of("vi", "VN"), __K2L_Locale.of("de"), __K2L_Locale.of("fr"), __K2L_Locale.of("xx", "YY"), __K2L_Locale.of("zz"))
    local ____mod = locales.____modCount
    for ____i = 1, locales.size do
        local locale = locales[____i]
        io.write(__K2L_Str(__K2L_Locale.language(locale)) .. "_" .. __K2L_Str(__K2L_Locale.country(locale)) .. ": ")
        line(locale, 1234567.891, 9876543210)
        if locales.____modCount ~= ____mod and locales:____comodified(____i) then
            break
        end
    end
    local de = "de_DE"
    print(__K2L_LocaleFormat.format(de, nil, "%d", 1234567))
    print(__K2L_LocaleFormat.format(de, nil, "%,d", -1234567))
    print(__K2L_LocaleFormat.format(de, nil, "%,d", 999))
    print(__K2L_LocaleFormat.format(de, nil, "%,.2f", -9876.5))
    print(__K2L_LocaleFormat.format(de, nil, "%(,.2f", -9876.5))
    print(__K2L_LocaleFormat.format(de, nil, "%+,.1f", 9876.54))
    print(__K2L_LocaleFormat.format(de, nil, "% d", 42))
    print(__K2L_LocaleFormat.format(de, nil, "%08.2f", -3.14159))
    print(__K2L_LocaleFormat.format(de, nil, "%.0f", 2.5))
    print(__K2L_LocaleFormat.format(de, nil, "%#.0f", 2.5))
    print(__K2L_LocaleFormat.format(de, nil, "%10s|%-10s|", "ab", "cd"))
    print(__K2L_LocaleFormat.format(de, nil, "%x %o %X", 255, 255, 255))
    print(__K2L_LocaleFormat.format(de, nil, "%08x", 255))
    print(__K2L_LocaleFormat.format(de, nil, "%s %b %c", __K2L_Str(1.5), true, "x"))
    print(__K2L_LocaleFormat.format(de, nil, "%f %f %f", 0.0 / 0.0, math.huge, -math.huge))
    print(__K2L_LocaleFormat.format(de, nil, "%e", 1.23456E-4))
    print(__K2L_LocaleFormat.format(de, nil, "%E", 123456.789))
    print(__K2L_LocaleFormat.format(de, nil, "%g", 1.23456E-5))
    print(__K2L_LocaleFormat.format(de, nil, "%g", 1234.5678))
    print(__K2L_LocaleFormat.format(de, nil, "%.3g", 98765.4321))
    print(#__K2L_LocaleFormat.format(de, nil, "%n"))
    print(__K2L_LocaleFormat.format(de, nil, "%2$s %1$s", "a", "b"))
    print(__K2L_LocaleFormat.format(de, nil, "100%%"))
    print(__K2L_LocaleFormat.format("fr_FR", nil, "%,d items", 1234567))
    print(__K2L_LocaleFormat.format(__K2L_Locale.of("de", "CH"), nil, "%,.2f", 1234567.891))
    print(__K2L_LocaleFormat.format(__K2L_Locale.of("hi", "IN"), nil, "%,.2f", 1234567.891))
    print(__K2L_LocaleFormat.format(__K2L_Locale.of("ar", "EG"), nil, "%,d", -1234567))
    print(__K2L_StringFormat("%d%%", 50))
    print(__K2L_StringFormat("%,d", 1234567))
    print(__K2L_StringFormat("%,d", 1234567))
    print(__K2L_StringFormat("%,.1f", 1234567.25))
    print(__K2L_LocaleFormat.format(de, nil, "%s", 1234567))
    print(__K2L_LocaleFormat.format(de, nil, "%s %s", __K2L_Str(1.5), __K2L_ReadOnlyListOf(1.5, 2.5)))
    print(__K2L_LocaleFormat.format(de, nil, "%.2f%s", 0.5, "x"))
    print(__K2L_LocaleFormat.format(__K2L_Locale.of("ar", "EG"), nil, "%d-%d", 12, 34))
    print(__K2L_LocaleFormat.format(__K2L_Locale.of("fa"), nil, "%.2f", 3.14159))
    print(__K2L_LocaleFormat.format(__K2L_Locale.of("my"), nil, "%,d", 1234567))
    print(__K2L_LocaleFormat.format(__K2L_Locale.of("th", "TH", "TH"), nil, "%,.2f", 1234567.891))
    local ____list = __K2L_ReadOnlyListOf("de_DE", "en_US", "fr_FR")
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i_1 = 1, ____n do
        local it = ____items[____i_1]
        ____count = ____count + 1
        ____out[____count] = __K2L_LocaleFormat.format(it, nil, "%,.1f", 1234567.85)
    end
    local dynamic = __K2L_ListWrap(____out, ____count)
    print(__K2L_Str(dynamic))
    local chosen = dynamic.size > 2 and __K2L_Locale.of("it", "IT") or "en_US"
    print(__K2L_LocaleFormat.format(chosen, nil, "%,d", 1234567))
end

main()
return {line = line}
