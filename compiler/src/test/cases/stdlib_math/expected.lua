local ____lualib = require("lualib_bundle")
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_FdLibm = ____lualib.__K2L_FdLibm
local __K2L_FloorDiv = ____lualib.__K2L_FloorDiv
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Str = ____lualib.__K2L_Str

local function basics()
    print(__K2L_Str(math.abs(-7.5)))
    print(math.abs(-7))
    print(__K2L_Str(__K2L_Num.signDouble(-3.0)))
    print(__K2L_Str(__K2L_Num.signDouble(0.0)))
    print(__K2L_Str(__K2L_Num.maxD(1.5, 2.5)))
    print(math.min(3, 4))
    print(math.max(1, 2, 3))
    print(__K2L_Str(__K2L_Num.minD(__K2L_Num.minD(5.0, 2.0), 9.0)))
    print(__K2L_Str(math.sqrt(81.0)))
    print(__K2L_Str(__K2L_FdLibm.cbrt(27.0)))
    print(__K2L_Str(__K2L_FdLibm.hypot(3.0, 4.0)))
    print(__K2L_Str(2.0 ^ 10))
    print(__K2L_Str(2.0 ^ 0.5))
    print(__K2L_Str(10.0 ^ (-2)))
    print(__K2L_Str(math.exp(0.0)))
    print(__K2L_Str(math.log(1.0)))
    print(__K2L_Str(__K2L_Num.log10(1000.0)))
    print(__K2L_Str(__K2L_Num.log2(8.0)))
    print(__K2L_Str(__K2L_Num.log(8.0, 2.0)))
    print(__K2L_Str(math.exp(1)))
    print(__K2L_Str(math.pi))
end

local function rounding()
    print(__K2L_Str(math.floor(2.7) + 0.0))
    print(__K2L_Str(__K2L_Num.ceil(2.1)))
    print(__K2L_Str(math.floor(-2.5) + 0.0))
    print(__K2L_Str(__K2L_Num.ceil(-2.5)))
    print(__K2L_Str(__K2L_Num.round(2.5)))
    print(__K2L_Str(__K2L_Num.round(3.5)))
    print(__K2L_Str(__K2L_Num.round(-2.5)))
    print(__K2L_Str(__K2L_Num.round(2.4)))
    print(__K2L_Str(__K2L_Num.truncate(-2.7)))
    print(__K2L_Num.roundToInt(2.7))
    print(__K2L_Num.roundToInt(-2.5))
    print(__K2L_Num.roundToInt(2.5))
    print(__K2L_Num.roundToLong(2.5))
    print(__K2L_Str((7 + 0.0) / 2))
    print(__K2L_IDiv(7, 2))
    local ____dividend = -7
    print(____dividend >= 0 and ____dividend // 2 or 0 - -____dividend // 2)
    local ____dividend_1 = -7
    print(____dividend_1 >= 0 and ____dividend_1 % 3 or 0 - -____dividend_1 % 3)
    print(__K2L_Num.mod(7, -3))
    print(__K2L_Num.mod(-7, 3))
    print(-__K2L_FloorDiv(7, 2))
    print(__K2L_Str(-7.5 % 2.0))
    print(__K2L_Str(math.fmod(7.5, 2)))
    print(__K2L_Str(math.abs(-0.0)))
end

local function trig()
    print(__K2L_Str(math.sin(0.0)))
    print(__K2L_Str(math.cos(0.0)))
    print(__K2L_Str(math.tan(0.0)))
    print(__K2L_Str(__K2L_FdLibm.atan2(1.0, 1.0)))
    print(__K2L_Str(__K2L_FdLibm.atan(1.0)))
    print(__K2L_Str(__K2L_FdLibm.asin(1.0)))
    print(__K2L_Str(__K2L_FdLibm.acos(1.0)))
    print(__K2L_Str(__K2L_FdLibm.sinh(0.0)))
    print(__K2L_Str(__K2L_FdLibm.cosh(0.0)))
    print(__K2L_Str(__K2L_FdLibm.tanh(0.0)))
    local ____value = math.pi / 2
    print(__K2L_Str(math.sin(____value)))
    print(__K2L_Str(math.pi * 57.29577951308232))
    print(__K2L_Str(180.0 * 0.017453292519943295))
end

local function special()
    print(__K2L_Str(1.0 / 0.0))
    print(__K2L_Str(-1.0 / 0.0))
    print(__K2L_Num.isNaN(0.0 / 0.0))
    print(0.0 / 0.0 == 0.0 / 0.0)
    print(__K2L_Num.isInfinite(math.huge))
    print(__K2L_Num.isFinite(1.5))
    print(__K2L_Str(1.7976931348623157E308))
    print(__K2L_Str(4.9E-324))
    print(__K2L_Num.isNaN(math.sqrt(-1.0)))
    print(__K2L_Str(0.1 + 0.2))
    print(__K2L_Str(1.0E21))
    print(__K2L_Str(1.0E-5))
    print(__K2L_Str(1.23456789E8 * 10))
    print(__K2L_Str(100.0))
    print(__K2L_Str(1.0E7))
    print(__K2L_Str(1.23456789E7))
    print(__K2L_Compare(1.0, 2.0))
    print(__K2L_Str(__K2L_Num.coerceIn(5.0, 0.0, 3.0)))
    print(math.max(5, 7))
    print(math.min(5, 3))
    print(__K2L_Num.coerceInRange(5, __K2L_IntRange.new(1, 3)))
end

local function main()
    basics()
    rounding()
    trig()
    special()
end

__K2L_Main(main)
return {basics = basics, rounding = rounding, trig = trig, special = special}
