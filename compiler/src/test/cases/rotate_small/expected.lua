local ____lualib = require("lualib_bundle")
local __K2L_Bits = ____lualib.__K2L_Bits
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str

local function main()
    local ub = 129
    print(__K2L_Num.rotateSmall(ub, 1, 8, false))
    print(__K2L_Num.rotateSmall(ub, 0, 8, false))
    print(__K2L_Num.rotateSmall(ub, 3, 8, false))
    print(__K2L_Num.rotateSmall(ub, 8, 8, false))
    print(__K2L_Num.rotateSmall(ub, 9, 8, false))
    print(__K2L_Num.rotateSmall(ub, -1, 8, false))
    print(__K2L_Num.rotateSmall(ub, -1, 8, false))
    print(__K2L_Num.rotateSmall(ub, -3, 8, false))
    print(__K2L_Num.rotateSmall(ub, -(-3), 8, false))
    print(__K2L_Num.rotateSmall(ub, -17, 8, false))
    print(__K2L_Num.rotateSmall(240 & 0xFF, 4, 8, false))
    print(__K2L_Num.rotateSmall(0 & 0xFF, 5, 8, false))
    print(__K2L_Num.rotateSmall(255 & 0xFF, -2, 8, false))
    local us = 32769
    print(__K2L_Num.rotateSmall(us, 1, 16, false))
    print(__K2L_Num.rotateSmall(us, 4, 16, false))
    print(__K2L_Num.rotateSmall(us, 16, 16, false))
    print(__K2L_Num.rotateSmall(us, -1, 16, false))
    print(__K2L_Num.rotateSmall(us, -1, 16, false))
    print(__K2L_Num.rotateSmall(us, -5, 16, false))
    print(__K2L_Num.rotateSmall(us, -20, 16, false))
    print(__K2L_Num.rotateSmall(4660 & 0xFFFF, 8, 16, false))
    print(__K2L_Num.rotateSmall(65535 & 0xFFFF, -3, 16, false))
    local b = -127
    print(__K2L_Num.rotateSmall(b, 1, 8, true))
    print(__K2L_Num.rotateSmall(b, 0, 8, true))
    print(__K2L_Num.rotateSmall(b, 4, 8, true))
    print(__K2L_Num.rotateSmall(b, 9, 8, true))
    print(__K2L_Num.rotateSmall(b, -1, 8, true))
    print(__K2L_Num.rotateSmall(b, -1, 8, true))
    print(__K2L_Num.rotateSmall(b, -3, 8, true))
    print(__K2L_Num.rotateSmall(b, -(-2), 8, true))
    print(__K2L_Num.rotateSmall(__K2L_Num.toByte(127), 1, 8, true))
    print(__K2L_Num.rotateSmall(__K2L_Num.toByte(-1), 3, 8, true))
    print(__K2L_Num.rotateSmall(__K2L_Num.toByte(0), -3, 8, true))
    local s = -32767
    print(__K2L_Num.rotateSmall(s, 1, 16, true))
    print(__K2L_Num.rotateSmall(s, 0, 16, true))
    print(__K2L_Num.rotateSmall(s, 8, 16, true))
    print(__K2L_Num.rotateSmall(s, 17, 16, true))
    print(__K2L_Num.rotateSmall(s, -1, 16, true))
    print(__K2L_Num.rotateSmall(s, -1, 16, true))
    print(__K2L_Num.rotateSmall(s, -6, 16, true))
    print(__K2L_Num.rotateSmall(__K2L_Num.toShort(32767), 1, 16, true))
    print(__K2L_Num.rotateSmall(__K2L_Num.toShort(-1), -5, 16, true))
    local values = __K2L_ReadOnlyListOf(1, 2, 128, 255)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = values:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = __K2L_Num.rotateSmall(it, 7, 8, false)
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    local bytes = __K2L_ReadOnlyListOf(1, 2, -(-128), 127)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = bytes:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = __K2L_Num.rotateSmall(it, -1, 8, true)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
    print(__K2L_Bits.rotl32(1, 31))
    print(__K2L_Bits.rotl32(2147483648, 1) & 0xFFFFFFFF)
end

main()
