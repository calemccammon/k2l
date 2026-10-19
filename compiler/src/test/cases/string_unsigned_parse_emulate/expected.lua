local ____lualib = require("lualib_bundle")
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_NotNull = ____lualib.__K2L_NotNull
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

local function main()
    print(__K2L_Unsigned.toString(__K2L_StringToUnsigned("18446744073709551615", nil, 64)))
    print(__K2L_Unsigned.toString(__K2L_StringToUnsigned("9223372036854775808", nil, 64)))
    print(__K2L_Unsigned.toString(__K2L_StringToUnsigned("9223372036854775807", nil, 64)))
    print(__K2L_Unsigned.toString(__K2L_StringToUnsigned("ffffffffffffffff", 16, 64)))
    print(__K2L_Unsigned.toString(__K2L_StringToUnsigned("8000000000000000", 16, 64)))
    print(__K2L_Str(__K2L_StringToUnsignedOrNull("18446744073709551616", nil, 64)))
    print(__K2L_Str(__K2L_StringToUnsignedOrNull("18446744073709551617", nil, 64)))
    print(__K2L_Str(__K2L_StringToUnsignedOrNull("ffffffffffffffff0", 16, 64)))
    print(__K2L_Str(__K2L_StringToUnsignedOrNull("-1", nil, 64)))
    print(__K2L_Unsigned.toString(__K2L_NotNull(__K2L_StringToUnsignedOrNull("+18446744073709551615", nil, 64))))
    attempt("overflow", function()
        return __K2L_StringToUnsigned("18446744073709551616", nil, 64)
    end)
    attempt("negative", function() return __K2L_StringToUnsigned("-1", nil, 64) end)
    print(__K2L_Unsigned.toRadix(0xffffffffffffffff, 16))
    print(__K2L_Unsigned.toRadix(0xffffffffffffffff, 36))
    print(__K2L_Unsigned.toRadix(0xffffffffffffffff, 2))
    print(__K2L_Unsigned.toRadix(0x8000000000000000, 10))
    print(__K2L_Unsigned.toRadix(0x8000000000000000, 16))
    print(__K2L_Unsigned.toRadix(__K2L_StringToUnsigned("zzzzzzzzzzzz", 36, 64), 36))
end

main()
return {attempt = attempt}
