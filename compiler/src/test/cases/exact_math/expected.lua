local ____lualib = require("lualib_bundle")
local __K2L_ArithmeticException = ____lualib.__K2L_ArithmeticException
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

local ____lambda_1 = function() return __K2L_Exact.add(1, 2) end
local ____lambda_2 = function() return __K2L_Exact.sub(5, 7) end
local ____lambda_3 = function() return __K2L_Exact.mul(46340, 46340) end
local ____lambda_4 = function() return __K2L_Exact.mul(46341, 46341) end
local ____lambda_5 = function() return __K2L_Exact.neg(5) end
local ____lambda_6 = function() return __K2L_Exact.inc(41) end
local ____lambda_7 = function() return __K2L_Exact.dec(41) end
local ____lambda_8 = function() return __K2L_Exact.toInt(123456) end
local ____lambda_9 = function() return __K2L_Exact.toInt(3000000000) end
local ____lambda_10 = function() return __K2L_Exact.toInt(-3000000000) end
local ____lambda_11 = function() return __K2L_Exact.abs(-9) end
local ____lambda_12 = function() return __K2L_Num.mod(5, 0) end
local ____lambda_13 = function() return __K2L_FloorDiv(5, 0) end
local function main()
    local max = 2147483647
    local min = -2147483648
    attempt("add", ____lambda_1)
    attempt("add overflow", function() return __K2L_Exact.add(max, 1) end)
    attempt("add underflow", function() return __K2L_Exact.add(min, -1) end)
    attempt("sub", ____lambda_2)
    attempt("sub overflow", function() return __K2L_Exact.sub(min, 1) end)
    attempt("mul", ____lambda_3)
    attempt("mul overflow", ____lambda_4)
    attempt("mul overflow 2", function() return __K2L_Exact.mul(max, 2) end)
    attempt("neg", ____lambda_5)
    attempt("neg overflow", function() return __K2L_Exact.neg(min) end)
    attempt("inc", ____lambda_6)
    attempt("inc overflow", function() return __K2L_Exact.inc(max) end)
    attempt("dec", ____lambda_7)
    attempt("dec overflow", function() return __K2L_Exact.dec(min) end)
    attempt("toIntExact", ____lambda_8)
    attempt("toIntExact overflow", ____lambda_9)
    attempt("toIntExact negative overflow", ____lambda_10)
    attempt("absExact", ____lambda_11)
    attempt("absExact overflow", function() return __K2L_Exact.abs(min) end)
    local big = 3000000000
    attempt("long add", function() return __K2L_Exact.addLong(big, big) end)
    attempt("long sub", function() return __K2L_Exact.subLong(big, big * 2) end)
    attempt("long mul", function() return __K2L_Exact.mulLong(big, 1000) end)
    attempt("long neg", function() return __K2L_Exact.negLong(big) end)
    attempt("long inc", function() return __K2L_Exact.incLong(big) end)
    attempt("long dec", function() return __K2L_Exact.decLong(big) end)
    attempt("mixed", function() return __K2L_Exact.addLong(max, 5) end)
    print(__K2L_Num.mod(-7, 3))
    print(__K2L_Num.mod(7, -3))
    print(__K2L_Num.mod(-7, 3))
    print(__K2L_FloorDiv(-7, 3))
    print(__K2L_FloorDiv(7, -3))
    print(__K2L_FloorDiv(-7, 3))
    attempt("floorMod zero", ____lambda_12)
    attempt("floorDiv zero", ____lambda_13)
end

main()
return {attempt = attempt}
