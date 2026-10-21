local ____lualib = require("lualib_bundle")
local __K2L_CollectionExtras = ____lualib.__K2L_CollectionExtras
local __K2L_Extras = ____lualib.__K2L_Extras
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf
local __K2L_Utf16 = ____lualib.__K2L_Utf16

local ____lambda_1 = function(it) return __K2L_Utf16.code(it) end
local ____lambda_2 = function(it) return it ~= "ö" end
local ____lambda_3 = function(i, c, acc) return i == 1 and c or acc end
local function main()
    local text = "été 😀 naïve été"
    print(__K2L_Utf16.out(__K2L_Str(__K2L_CollectionExtras.findAnyOf(text, __K2L_ReadOnlyListOf("naïve", "😀"), nil, nil, false))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_CollectionExtras.findAnyOf(text, __K2L_SingletonListOf("été"), nil, nil, true))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_CollectionExtras.findAnyOf(text, __K2L_SingletonListOf("ÉTÉ"), 1, true, false))))
    print(__K2L_Utf16.out(__K2L_CollectionExtras.lastIndexOfAny(text, __K2L_TypedArrayOf("[C", "é", "ï"), nil, nil)))
    print(__K2L_Utf16.out(__K2L_CollectionExtras.lastIndexOfAny(text, __K2L_SingletonListOf("😀"), nil, nil)))
    print(__K2L_Utf16.out(__K2L_Text.toList(text):map(____lambda_1).size))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ReadOnlyListOf(__K2L_CollectionExtras.hasSurrogatePairAt(text, 4, __K2L_Utf16), __K2L_CollectionExtras.hasSurrogatePairAt(text, 5, __K2L_Utf16), __K2L_CollectionExtras.hasSurrogatePairAt(text, 0, __K2L_Utf16)))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_CollectionExtras.filterCharsTo(__K2L_Text.toList("äöü"), __K2L_StringBuilder.new(), ____lambda_2))))
    print(__K2L_Utf16.out(__K2L_Extras.reduceRight(__K2L_Text.toList("äöü"), ____lambda_3, true, false, "char sequence")))
    local seen = __K2L_StringBuilder.new()
    __K2L_CollectionExtras.onEachIndexedChars("日本", __K2L_Text.toList("日本"), function(i, c)
        seen:append(tostring(i)):append(c)
    end)
    print(__K2L_Utf16.out(__K2L_Str(seen)))
    print(__K2L_Utf16.out(__K2L_CollectionExtras.replaceIndent("  ñ\n    ö", "» ")))
    print(__K2L_Utf16.out(__K2L_CollectionExtras.replaceIndentByMargin("x|ñ\n |ö", "· ", nil)))
end

__K2L_Main(main)
