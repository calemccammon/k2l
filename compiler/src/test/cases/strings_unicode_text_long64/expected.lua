local ____lualib = require("lualib_bundle")
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_StringToUnsigned = ____lualib.__K2L_StringToUnsigned
local __K2L_StringToUnsignedOrNull = ____lualib.__K2L_StringToUnsignedOrNull
local __K2L_Unsigned = ____lualib.__K2L_Unsigned
local __K2L_Utf16 = ____lualib.__K2L_Utf16

local function main()
    print(__K2L_Utf16.out(__K2L_StringToInt("١٢٣", nil, true)))
    print(__K2L_Utf16.out(__K2L_StringToInt("-٩٩٩٩٩٩٩٩٩٩٩٩٩٩٩", nil, true)))
    print(__K2L_Utf16.out(__K2L_StringToInt("９２２３３７２０３６８５４７７５８０７", nil, true)))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_StringToIntOrNull("９２２３３７２０３６８５４７７５８０８", nil, true))))
    print(__K2L_Utf16.out(__K2L_StringToInt("-９２２３３７２０３６８５４７７５８０８", nil, true)))
    print(__K2L_Utf16.out(__K2L_Unsigned.toString(__K2L_StringToUnsigned("１８４４６７４４０７３７０９５５１６１５", nil, 64))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_StringToUnsignedOrNull("１８４４６７４４０７３７０９５５１６１６", nil, 64))))
    print(__K2L_Utf16.out(__K2L_Unsigned.toString(__K2L_StringToUnsigned("ｆｆｆｆｆｆｆｆｆｆｆｆｆｆｆｆ", 16, 64))))
    print(__K2L_Utf16.out(__K2L_StringToInt("ＦＦ", 16, true)))
    print(__K2L_Utf16.out(__K2L_StringToInt("٧٧٧", nil, true)))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_StringToIntOrNull("١x", nil, true))))
    print(__K2L_Utf16.out(__K2L_NotNull(__K2L_StringToInt("-٤", nil, true))))
end

__K2L_Main(main)
