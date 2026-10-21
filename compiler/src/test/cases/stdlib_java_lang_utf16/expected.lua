local ____lualib = require("lualib_bundle")
local __K2L_Extras = ____lualib.__K2L_Extras
local __K2L_JavaNumbers = ____lualib.__K2L_JavaNumbers
local __K2L_JavaUtil = ____lualib.__K2L_JavaUtil
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_Utf16 = ____lualib.__K2L_Utf16

local function main()
    local text = "a😀b"
    local cp = 128512
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ReadOnlyListOf(__K2L_Utf16.code(__K2L_Utf16.highSurrogate(cp)), __K2L_Utf16.code(__K2L_Utf16.lowSurrogate(cp))))))
    print(__K2L_Utf16.out(__K2L_Utf16.norm(__K2L_Utf16.toChars(cp):joinToString("")) == "😀"))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ReadOnlyListOf(__K2L_Utf16.isHighSurrogate("\237\160\189") and __K2L_Utf16.isLowSurrogate("\237\184\128"), __K2L_Utf16.isHighSurrogate("a") and __K2L_Utf16.isLowSurrogate("\237\184\128"), __K2L_Utf16.isHighSurrogate("\237\184\128") and __K2L_Utf16.isLowSurrogate("\237\160\189")))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ReadOnlyListOf(__K2L_Utf16.codePointAt(text, 1), __K2L_Utf16.codePointAt(text, 2), __K2L_Utf16.codePointAt(text, 0)))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ReadOnlyListOf(__K2L_Utf16.codePointBefore(text, 3), __K2L_Utf16.codePointBefore(text, 1)))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ReadOnlyListOf(__K2L_Utf16.codePointCount(text, 0, __K2L_Utf16.len(text)), __K2L_Utf16.offsetByCodePoints(text, 0, 2)))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ReadOnlyListOf(__K2L_Utf16.code(__K2L_Utf16.char(__K2L_JavaNumbers.reverseChar(__K2L_Utf16.code("Ă")))), __K2L_Utf16.code(__K2L_Utf16.char(__K2L_JavaNumbers.reverseChar(__K2L_Utf16.code("A"))))))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ReadOnlyListOf(__K2L_JavaNumbers.isISOControl(133), __K2L_JavaNumbers.isISOControl(65), __K2L_Extras.isISOControl(__K2L_Utf16.code("\000"))))))
    local sb = __K2L_StringBuilder.new("x")
    sb:append(__K2L_JavaUtil.repeatCodePoint(cp, 2))
    sb:append(__K2L_JavaUtil.repeatText("é", 2))
    print(__K2L_Utf16.out(__K2L_Str(sb) .. " " .. sb:getLength()))
end

__K2L_Main(main)
