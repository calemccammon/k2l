local ____lualib = require("lualib_bundle")
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Shl = ____lualib.__K2L_Shl
local __K2L_Shr = ____lualib.__K2L_Shr
local __K2L_Ushr = ____lualib.__K2L_Ushr

local function main()
    local a = 12
    local b = 10
    print(a & b)
    print(a | b)
    print(a ~ b)
    print(~a)
    print(__K2L_Shl(1, 4))
    print(__K2L_Shr(-16, 2))
    print(__K2L_Ushr(-16, 28))
    print(-1 & 255)
    print(__K2L_Shl(2147483647, 1))
    local flags = __K2L_ReadOnlyListOf(1, 2, 4, 8)
    print(flags:fold(0, function(acc, f) return acc | f end))
    print(5 & 1 == 1)
end

main()
