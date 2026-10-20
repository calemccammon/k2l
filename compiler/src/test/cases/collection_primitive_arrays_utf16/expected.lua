local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf
local __K2L_Utf16 = ____lualib.__K2L_Utf16

local function main()
    local chars = __K2L_Text.toList("a😀é")
    print(__K2L_Utf16.out(chars.size))
    local ca = chars:toCharArray()
    print(__K2L_Utf16.out(ca.size .. " " .. __K2L_Utf16.norm(ca:joinToString("")) .. " " .. __K2L_Text.string(ca)))
    print(__K2L_Utf16.out(__K2L_Equals(ca:toList(), chars)))
    print(__K2L_Utf16.out(__K2L_Utf16.norm(__K2L_ReadOnlySetOf("é", "ß"):toCharArray():joinToString(""))))
    print(__K2L_Utf16.out(__K2L_Utf16.norm(__K2L_TypedArrayOf("[Ljava.lang.Character;", "ä", "ö"):toCharArray():joinToString(""))))
    print(__K2L_Utf16.out(__K2L_Utf16.norm(__K2L_Text.toList("héllo"):sortedDescending():toCharArray():joinToString(""))))
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ca:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = __K2L_Utf16.code(it)
    end
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ListWrap(____out, ____count))))
    print(__K2L_Utf16.out(__K2L_Utf16.len(__K2L_Utf16.norm(ca:toTypedArray("[Ljava.lang.Character;"):toCharArray():joinToString("")))))
    print(__K2L_Utf16.out(__K2L_Utf16.norm(__K2L_ArrayDeque.new(__K2L_Text.toList("ü€")):toCharArray():joinToString("|"))))
end

main()
