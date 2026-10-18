local ____lualib = require("lualib_bundle")
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32

local function main()
    print(9223372036854775807)
    print(-9223372036854775807 - 1)
    print(__K2L_ToInt32(1 << 40))
    print(1 << 40)
    print(9223372036854775807 - 1)
    print(__K2L_IDiv(9223372036854775807, 3))
    print(1 << 62)
    print(1 << 40 | 5)
    print(3 << 33 ~ 1)
    print(#tostring(9223372036854775807))
    print(math.fmod(123456789012345678, 1000))
end

main()
