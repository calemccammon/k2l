local ____lualib = require("lualib_bundle")
local __K2L_CharDirectionality = ____lualib.__K2L_CharDirectionality
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_Utf16 = ____lualib.__K2L_Utf16

local ____lambda_1 = function(it) return __K2L_Utf16.char(it) end
local ____lambda_2 = function(it)
    return __K2L_CharDirectionality.of(__K2L_Utf16.code(it))
end
local function main()
    for c in __K2L_Utf16.each("aא١٣̀‎‪‮‬  €￿") do
        print(__K2L_Utf16.out("U+" .. __K2L_Text.padStart(__K2L_Num.toRadix(__K2L_Utf16.code(c), 16), 4, "0") .. " " .. __K2L_Str(__K2L_CharDirectionality.of(__K2L_Utf16.code(c))) .. " " .. __K2L_CharDirectionality.of(__K2L_Utf16.code(c)).value))
    end
    print(__K2L_Utf16.out(__K2L_Str(__K2L_IntRange.new(1424, 1792 - 1):map(____lambda_1):groupingBy(____lambda_2):eachCount())))
end

__K2L_Main(main)
