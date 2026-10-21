local ____lualib = require("lualib_bundle")
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Locale = ____lualib.__K2L_Locale
local __K2L_LocaleNames = ____lualib.__K2L_LocaleNames
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str

local ____exports = {}
____exports.count = 0

local function show(locale)
    ____exports.count = ____exports.count + 1
    print("#" .. ____exports.count .. " " .. __K2L_Str(__K2L_LocaleNames.language(locale)) .. " | " .. __K2L_Str(__K2L_LocaleNames.country(locale)) .. " | " .. __K2L_Str(__K2L_LocaleNames.name(locale)))
end

local function main()
    show("en_US")
    show("en_GB")
    show("de_DE")
    show("fr_FR")
    show("ja_JP")
    show("zh_CN")
    show("en_CA")
    show("it")
    show("ko_KR")
    show("")
    show("en_US")
    show(__K2L_Locale.of("tr", "TR"))
    show(__K2L_Locale.of("pt", "BR"))
    show(__K2L_Locale.of("es", "419"))
    show(__K2L_Locale.of("sr", "RS", "Latn"))
    show(__K2L_Locale.of("de", "CH"))
    show(__K2L_Locale.of("fil", "PH"))
    show(__K2L_Locale.of("ast"))
    show(__K2L_Locale.of("haw", "US"))
    show(__K2L_Locale.of("xx", "YY"))
    show(__K2L_Locale.of("", "US"))
    show(__K2L_Locale.of("en", "US", "POSIX"))
    show(__K2L_Locale.of("en", "", "POSIX"))
    show(__K2L_Locale.of("ja", "JP", "JP"))
    show(__K2L_Locale.of("th", "TH", "TH"))
    show(__K2L_Locale.of("he"))
    show(__K2L_Locale.of("iw", "IL"))
    show(__K2L_Locale.of("in", "ID"))
    show(__K2L_Locale.of("zh", "TW"))
    show(__K2L_Locale.of("eng"))
    show(__K2L_Locale.forLanguageTag("zh-Hans-CN"))
    show(__K2L_Locale.forLanguageTag("zh-Hant-TW"))
    show(__K2L_Locale.forLanguageTag("sr-Cyrl-RS"))
    show(__K2L_Locale.forLanguageTag("az-Latn-AZ"))
    show(__K2L_Locale.forLanguageTag("en-001"))
    show(__K2L_Locale.forLanguageTag("ca-ES-valencia"))
    local de = "de"
    print(__K2L_Str(__K2L_LocaleNames.language("fr", "en")))
    print(__K2L_Str(__K2L_LocaleNames.country("fr_FR", "en_US")))
    print(__K2L_Str(__K2L_LocaleNames.name("fr_FR", "en_GB")))
    print(__K2L_Str(__K2L_LocaleNames.name("ja_JP", "")))
    print(__K2L_Str(__K2L_LocaleNames.script(__K2L_Locale.forLanguageTag("zh-Hans-CN"))))
    print(__K2L_Str(__K2L_LocaleNames.script(__K2L_Locale.forLanguageTag("zh-Hans-CN"))))
    print(__K2L_Str(__K2L_LocaleNames.variant(__K2L_Locale.of("en", "US", "POSIX"))))
    print(#__K2L_LocaleNames.variant("en_US") == 0)
    print(#__K2L_LocaleNames.script("en_US") == 0)
    print(__K2L_Str(__K2L_LocaleNames.language(de)))
    local ____list = __K2L_ReadOnlyListOf("en", "de", "fr")
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = __K2L_LocaleNames.language(it)
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    local ____list_1 = __K2L_ReadOnlyListOf("fr", "ja", "ru", "ar", "ko")
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = __K2L_LocaleNames.language(__K2L_Locale.of(it))
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1):sorted()))
end

____exports.show = show
__K2L_Main(main)
return ____exports
