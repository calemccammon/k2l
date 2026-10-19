local ____lualib = require("lualib_bundle")
local __K2L_ArithmeticException = ____lualib.__K2L_ArithmeticException
local __K2L_BigInteger = ____lualib.__K2L_BigInteger
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local longValueExactOrNull

local function main()
    local longs = __K2L_ReadOnlyListOf("9223372036854775807", "-9223372036854775808", "9223372036854775808", "12345678901234567890", "-9007199254740993")
    for _, a in ipairs(longs) do
        print(a .. ": long=" .. __K2L_BigInteger.parse(a):toLong() .. " hash=" .. __K2L_BigInteger.parse(a):hashCode())
    end
    print(__K2L_Str(__K2L_BigInteger.valueOf(-9007199254740993)))
    print(__K2L_Str(__K2L_BigInteger.valueOf(9223372036854775807)))
    print(__K2L_Str(__K2L_BigInteger.valueOf(-9223372036854775807 - 1)))
    print(__K2L_BigInteger.valueOf(9223372036854775807):toLong())
    print(__K2L_BigInteger.valueOf(-9223372036854775807 - 1):toLong() == -9223372036854775807 - 1)
    print(__K2L_Str(__K2L_BigInteger.valueOf(9223372036854775807):multiply(__K2L_BigInteger.valueOf(9223372036854775807))))
    print(__K2L_BigInteger.parse("123456789012345678"):toLong() * 10)
    print(__K2L_Str(longValueExactOrNull(__K2L_BigInteger.valueOf(9223372036854775807):add(__K2L_BigInteger.ONE))))
end

function longValueExactOrNull(self)
    local ____ok, ____result, ____returned = pcall(function()
        return true, self:longValueExact()
    end)
    if ____ok then
        if ____result then
            return ____returned
        end
    else
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_ArithmeticException) then
            local e = ____error
            return nil
        else
            error(____error, 0)
        end
    end
end

main()
return {longValueExactOrNull = longValueExactOrNull}
