local ____lualib = require("lualib_bundle")
local __K2L_IsLetter = ____lualib.__K2L_IsLetter
local __K2L_StringFormat = ____lualib.__K2L_StringFormat

local function main()
    print(("Hello"):upper())
    print(("Hello"):lower())
    print(("Hello"):upper())
    print(__K2L_StringFormat("%5.2f|%s", 3.14159, "x"))
    print(__K2L_StringFormat("%d items", 3))
    print(__K2L_IsLetter.a == true)
    print(("b"):upper())
end

main()
