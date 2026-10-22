local ____lualib = require("lualib_bundle")
local __K2L_Bits = ____lualib.__K2L_Bits
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_RunMain = ____lualib.__K2L_RunMain

local function main()
    print(__K2L_Bits.withSign(3.5, -1.0))
    print(__K2L_Bits.withSign(-3.5, 1.0))
    print(__K2L_Bits.withSign(2.0, -0.0))
    print(__K2L_Bits.withSign(0.0, -2.0))
    print(__K2L_Bits.withSign(5.0, -3))
    print(__K2L_Bits.withSign(2.5, -1.0))
    print(__K2L_Bits.rotl32(305419896, 8))
    print(__K2L_Bits.rotl32(305419896, -8))
    print(__K2L_Bits.rotl32(-1, 5))
    print(__K2L_Bits.rotl32(1, -1))
    print(__K2L_Bits.rotl32(305419896, 0))
    print(__K2L_Bits.rotl32(305419896, 32))
    print(__K2L_Bits.rotl32(305419896, -4))
    print(__K2L_Bits.rotl32(1, 31))
    print(__K2L_Bits.highest32(100))
    print(__K2L_Bits.highest32(-5))
    print(__K2L_Bits.highest32(0))
    print(__K2L_Bits.lowest32(96))
    print(__K2L_Bits.lowest32(-2147483648))
    print(__K2L_Bits.lowest32(0))
    print(__K2L_Num.signInt(3))
    print(__K2L_Num.signDouble(-2.5))
end

__K2L_RunMain(main)
