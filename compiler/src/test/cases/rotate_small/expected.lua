local ____lualib = require("lualib_bundle")
local __K2L_Bits = ____lualib.__K2L_Bits
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str

local function main()
    local b = -127
    print(__K2L_Num.rotateSmall(b, 1, 8, true))
    print(__K2L_Num.rotateSmall(b, 0, 8, true))
    print(__K2L_Num.rotateSmall(b, 4, 8, true))
    print(__K2L_Num.rotateSmall(b, 9, 8, true))
    print(__K2L_Num.rotateSmall(b, -1, 8, true))
    print(__K2L_Num.rotateSmall(b, -1, 8, true))
    print(__K2L_Num.rotateSmall(b, -3, 8, true))
    print(__K2L_Num.rotateSmall(b, -(-2), 8, true))
    print(__K2L_Num.rotateSmall(127, 1, 8, true))
    print(__K2L_Num.rotateSmall(-1, 3, 8, true))
    print(__K2L_Num.rotateSmall(0, -3, 8, true))
    local s = -32767
    print(__K2L_Num.rotateSmall(s, 1, 16, true))
    print(__K2L_Num.rotateSmall(s, 0, 16, true))
    print(__K2L_Num.rotateSmall(s, 8, 16, true))
    print(__K2L_Num.rotateSmall(s, 17, 16, true))
    print(__K2L_Num.rotateSmall(s, -1, 16, true))
    print(__K2L_Num.rotateSmall(s, -1, 16, true))
    print(__K2L_Num.rotateSmall(s, -6, 16, true))
    print(__K2L_Num.rotateSmall(32767, 1, 16, true))
    print(__K2L_Num.rotateSmall(-1, -5, 16, true))
    local bytes = __K2L_ListOf(1, 2, -128, 127)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = bytes:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = __K2L_Num.rotateSmall(it, -1, 8, true)
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    print(__K2L_Bits.rotl32(1, 31))
end

__K2L_RunMain(main)
