local ____lualib = require("lualib_bundle")
local __K2L_ArithmeticException = ____lualib.__K2L_ArithmeticException
local __K2L_Bits = ____lualib.__K2L_Bits
local __K2L_Exact = ____lualib.__K2L_Exact
local __K2L_FloorDiv = ____lualib.__K2L_FloorDiv
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function attempt(label, block)
    local ____ok, ____result = pcall(function()
        print(label .. " = " .. __K2L_Str(block()))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_ArithmeticException) then
            local e = ____error
            print(label .. ": ArithmeticException " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
end

local function main()
    local max = 9223372036854775807
    local min = -9223372036854775807 - 1
    attempt("add", function() return __K2L_Exact.addLong(max - 1, 1) end)
    attempt("add overflow", function() return __K2L_Exact.addLong(max, 1) end)
    attempt("add underflow", function() return __K2L_Exact.addLong(min, -1) end)
    attempt("sub", function() return __K2L_Exact.subLong(min + 1, 1) end)
    attempt("sub overflow", function() return __K2L_Exact.subLong(min, 1) end)
    attempt("sub overflow 2", function() return __K2L_Exact.subLong(0, min) end)
    attempt("mul", function()
        return __K2L_Exact.mulLong(3037000499, 3037000499)
    end)
    attempt("mul overflow", function()
        return __K2L_Exact.mulLong(3037000500, 3037000500)
    end)
    attempt("mul min", function() return __K2L_Exact.mulLong(min, -1) end)
    attempt("mul min 2", function() return __K2L_Exact.mulLong(-1, min) end)
    attempt("mul zero", function() return __K2L_Exact.mulLong(min, 0) end)
    attempt("neg overflow", function() return __K2L_Exact.negLong(min) end)
    attempt("inc overflow", function() return __K2L_Exact.incLong(max) end)
    attempt("dec overflow", function() return __K2L_Exact.decLong(min) end)
    attempt("absExact overflow", function() return __K2L_Exact.absLong(min) end)
    attempt("toIntExact", function() return __K2L_Exact.toInt(max) end)
    print(__K2L_Num.mod(min, 7))
    print(__K2L_FloorDiv(min, 7))
    print(__K2L_Bits.rotl64(max, 1))
    print(__K2L_Bits.rotl64(1, -1))
    print(__K2L_Bits.rotl64(81985529216486895, 8))
    print(__K2L_Bits.rotl64(81985529216486895, -60))
    print(__K2L_Bits.highest64(12345678901234))
    print(__K2L_Bits.highest64(-5))
    print(__K2L_Bits.lowest64(12345678901232))
    print(__K2L_Bits.highest64(0))
    print(__K2L_Bits.ones64(max))
    print(__K2L_Bits.ones64(min))
    print(__K2L_Bits.clz64(1))
    print(__K2L_Bits.clz64(0))
    print(__K2L_Bits.clz64(min))
    print(__K2L_Bits.ctz64(8))
    print(__K2L_Bits.ctz64(0))
    print(__K2L_Bits.doubleBits(3.14))
    print(__K2L_Bits.doubleBits(-2.5))
    print(__K2L_Bits.doubleRawBits(1.0))
    print(__K2L_Str(__K2L_Bits.doubleFromBits(4614253070214989087)))
    print(__K2L_Str(__K2L_Bits.doubleFromBits(9218868437227405312)))
    print(__K2L_Bits.doubleBits(0.0 / 0.0))
    print(__K2L_Bits.doubleRawBits(0.0 / 0.0) ~= 0)
    print(__K2L_Bits.doubleBits(-0.0))
    print(__K2L_Bits.doubleBits(4.9E-324))
    print(__K2L_Bits.doubleBits(1.7976931348623157E308))
    print(__K2L_Str(__K2L_Bits.doubleFromBits(1)))
end

main()
return {attempt = attempt}
