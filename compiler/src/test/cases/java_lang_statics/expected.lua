local ____lualib = require("lualib_bundle")
local __K2L_Bits = ____lualib.__K2L_Bits
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringToDouble = ____lualib.__K2L_StringToDouble
local __K2L_Unsigned = ____lualib.__K2L_Unsigned

local function main()
    print(__K2L_Num.countOneBits(255) .. " " .. __K2L_Num.countOneBits(-1) .. " " .. __K2L_Bits.highest32(100) .. " " .. __K2L_Bits.lowest32(96))
    print(__K2L_Num.countTrailingZeroBits(96) .. " " .. __K2L_Num.countLeadingZeroBits(1) .. " " .. __K2L_Num.countTrailingZeroBits(0))
    print(__K2L_Bits.rotl32(1, 33) .. " " .. __K2L_Bits.rotl32(1, -1) .. " " .. __K2L_Num.signInt(-5) .. " " .. __K2L_Num.signInt(0) .. " " .. __K2L_Num.signInt(9))
    print(math.max(3, 4) .. " " .. math.min(3, 4) .. " " .. __K2L_Str(__K2L_Num.toRadixUnsigned(-1, 10)) .. " " .. __K2L_Str(__K2L_Num.toRadixUnsigned(255, 16)))
    print(__K2L_Bits.ones64(255) .. " " .. __K2L_Bits.ctz64(1 << 20) .. " " .. __K2L_Bits.highest64(1000))
    print(__K2L_Str(__K2L_Unsigned.toRadix(10, 2)) .. " " .. __K2L_Str(__K2L_Unsigned.toRadix(255, 16)) .. " " .. __K2L_Str(__K2L_Unsigned.toRadix(64, 8)))
    print(__K2L_Str(__K2L_Unsigned.toRadix(-1, 16)) .. " " .. #__K2L_Unsigned.toRadix(-8, 2) .. " " .. __K2L_Str(__K2L_Unsigned.toRadix(-4096, 16)))
    print(math.max(3, 4) .. " " .. math.min(-3, 4) .. " " .. __K2L_Num.signInt(-5))
    print(__K2L_Num.numericValue("7") .. " " .. __K2L_Num.numericValue("a") .. " " .. __K2L_Num.numericValue("Z") .. " " .. __K2L_Num.numericValue("-"))
    print(tostring(__K2L_Num.isNaN(0.0 / 0.0)) .. " " .. tostring(1.0 ~= 1.0) .. " " .. tostring(__K2L_Num.isInfinite(1.0 / 0.0)) .. " " .. tostring(__K2L_Num.isFinite(2.0)))
    print(__K2L_Str(__K2L_StringToDouble("2.5") + 1) .. " " .. __K2L_Str(4.0) .. " " .. __K2L_Str(__K2L_Str(2.0)) .. " " .. __K2L_Str(__K2L_Str(0.1)))
    print(tostring(string.lower("TRUE" or "") == "true") .. " " .. tostring(string.lower("yes" or "") == "true") .. " " .. __K2L_Str(tostring(false)) .. " " .. __K2L_Str("x"))
    print(__K2L_Str(__K2L_Str(3.5)) .. " " .. __K2L_Str(tostring(7)) .. " " .. __K2L_Str(tostring(true)) .. " " .. __K2L_Str("c"))
    print(__K2L_Str(table.concat({"x", "y", "z"}, "-")) .. " " .. __K2L_Str(__K2L_ReadOnlyListOf("a", "b"):joinToString(", ")) .. " [" .. __K2L_Str(table.concat({}, "/")) .. "]")
end

__K2L_Main(main)
