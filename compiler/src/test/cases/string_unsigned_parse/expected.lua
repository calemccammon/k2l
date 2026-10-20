local ____lualib = require("lualib_bundle")
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringToUnsigned = ____lualib.__K2L_StringToUnsigned
local __K2L_StringToUnsignedOrNull = ____lualib.__K2L_StringToUnsignedOrNull
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Unsigned = ____lualib.__K2L_Unsigned

local function attempt(label, block)
    local ____ok, ____result = pcall(function()
        print(label .. ": " .. __K2L_Str(block()))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_Exception) then
            local e = ____error
            print(label .. ": " .. __K2L_Str(__K2L_KClassOfValue(e).simpleName) .. ": " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
end

local ____lambda_1 = function() return __K2L_StringToUnsigned("abc", nil, 32) end
local ____lambda_2 = function() return __K2L_StringToUnsigned("-1", nil, 32) end
local ____lambda_3 = function()
    return __K2L_StringToUnsigned("4294967296", nil, 32)
end
local ____lambda_4 = function() return __K2L_StringToUnsigned("", nil, 32) end
local ____lambda_5 = function() return __K2L_StringToUnsigned("256", nil, 8) end
local ____lambda_6 = function()
    return __K2L_StringToUnsigned("65536", nil, 16)
end
local ____lambda_7 = function() return __K2L_StringToUnsigned("x", nil, 64) end
local ____lambda_8 = function() return __K2L_StringToUnsigned("19", 8, 32) end
local ____lambda_9 = function() return __K2L_StringToUnsigned("19", 40, 32) end
local ____lambda_10 = function()
    return __K2L_StringToUnsignedOrNull("19", 1, 32)
end
local function main()
    print(__K2L_StringToUnsigned("42", nil, 32))
    print(__K2L_StringToUnsigned("+42", nil, 32))
    print(__K2L_StringToUnsigned("4294967295", nil, 32))
    print(__K2L_StringToUnsigned("0", nil, 32))
    print(__K2L_StringToUnsigned("ff", 16, 32))
    print(__K2L_StringToUnsigned("FF", 16, 32))
    print(__K2L_StringToUnsigned("zz", 36, 32))
    print(__K2L_StringToUnsigned("11111111", 2, 32))
    print(__K2L_StringToUnsigned("255", nil, 8))
    print(__K2L_StringToUnsigned("65535", nil, 16))
    print(__K2L_Unsigned.toString(__K2L_StringToUnsigned("12345678901234", nil, 64)))
    print(__K2L_Unsigned.toString(__K2L_StringToUnsigned("1000000", nil, 64)))
    print(__K2L_Unsigned.toString(__K2L_StringToUnsigned("ff", 16, 64)))
    print(__K2L_Unsigned.toString(__K2L_StringToUnsigned("77", 8, 64)))
    print(__K2L_Str(__K2L_StringToUnsignedOrNull("4294967296", nil, 32)))
    print(__K2L_Str(__K2L_StringToUnsignedOrNull("-1", nil, 32)))
    print(__K2L_Str(__K2L_StringToUnsignedOrNull("-0", nil, 32)))
    print(__K2L_Str(__K2L_StringToUnsignedOrNull("", nil, 32)))
    print(__K2L_Str(__K2L_StringToUnsignedOrNull("+", nil, 32)))
    print(__K2L_Str(__K2L_StringToUnsignedOrNull("12a", nil, 32)))
    print(__K2L_Str(__K2L_StringToUnsignedOrNull("1_000", nil, 32)))
    print(__K2L_Str(__K2L_StringToUnsignedOrNull(" 1", nil, 32)))
    print(__K2L_Str(__K2L_StringToUnsignedOrNull("256", nil, 8)))
    print(__K2L_Str(__K2L_StringToUnsignedOrNull("255", nil, 8)))
    print(__K2L_Str(__K2L_StringToUnsignedOrNull("65536", nil, 16)))
    print(__K2L_Str(__K2L_StringToUnsignedOrNull("65535", nil, 16)))
    print(__K2L_Str(__K2L_StringToUnsignedOrNull("-5", nil, 64)))
    print(__K2L_Str(__K2L_StringToUnsignedOrNull("abc", nil, 64)))
    print(__K2L_Str(__K2L_StringToUnsignedOrNull("g", 16, 32)))
    print(__K2L_Str(__K2L_StringToUnsignedOrNull("7fffffff", 16, 32)))
    print(__K2L_Str(__K2L_StringToUnsignedOrNull("ffffffff", 16, 32)))
    print(__K2L_Str(__K2L_StringToUnsignedOrNull("100000000", 16, 32)))
    print(__K2L_Str(__K2L_StringToUnsignedOrNull("ff", 16, 8)))
    print(__K2L_Str(__K2L_StringToUnsignedOrNull("100", 16, 8)))
    print(__K2L_Str(__K2L_StringToUnsignedOrNull("ffff", 16, 16)))
    print(__K2L_Str(__K2L_StringToUnsignedOrNull("10000", 16, 16)))
    attempt("abc", ____lambda_1)
    attempt("neg", ____lambda_2)
    attempt("big", ____lambda_3)
    attempt("empty", ____lambda_4)
    attempt("byte", ____lambda_5)
    attempt("short", ____lambda_6)
    attempt("ulong", ____lambda_7)
    attempt("radix", ____lambda_8)
    attempt("badradix", ____lambda_9)
    attempt("badradix1", ____lambda_10)
    print(__K2L_Num.toRadix(255, 16))
    print(__K2L_Num.toRadix(255, 2))
    print(__K2L_Num.toRadix(4294967295, 36))
    print(__K2L_Num.toRadix(200 & 0xFF, 16))
    print(__K2L_Num.toRadix(65535 & 0xFFFF, 8))
    print(__K2L_Unsigned.toRadix(12345678901234, 7))
    print(__K2L_Num.toRadix(0, 2))
end

main()
return {attempt = attempt}
