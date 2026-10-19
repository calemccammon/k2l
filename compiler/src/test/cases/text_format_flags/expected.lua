local ____lualib = require("lualib_bundle")
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalFormatException = ____lualib.__K2L_IllegalFormatException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_MissingFormatArgumentException = ____lualib.__K2L_MissingFormatArgumentException
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function t(f)
    local ____ok, ____result = pcall(function()
        print(f())
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
            local e = ____error
            print(__K2L_Str(e))
        else
            error(____error, 0)
        end
    end
end

local function main()
    t(function()
        return __K2L_StringFormat("%2$s %1$s %2$s %<s %s %s", "a", "b")
    end)
    t(function()
        return __K2L_StringFormat("%s %<S %<10s| %d %<x %<o", "kotlin", 255)
    end)
    t(function()
        return __K2L_StringFormat("%h %h %h %H %h %h", "hello", 42, 1.5, "Kotlin", nil, true)
    end)
    t(function()
        return __K2L_StringFormat("%10h|%-10H|%.3h", "hello", "hello", "hello")
    end)
    t(function()
        return __K2L_StringFormat("%g %g %.2g %g %g %.3g", 999.9999, 99999.95, 9.9999E-5, 1.0E-5, 1.0E-4, 9.9951)
    end)
    t(function()
        return __K2L_StringFormat("%G %.1g %.0g %g %g", 1234567.0, 0.95, 5.5, -123.456, 100000.0)
    end)
    t(function()
        return __K2L_StringFormat("%#010x %#06X %#o %08X %#x", 48879, 255, 8, 48879, 0)
    end)
    local b = -1
    local s = -2
    local l = -3
    t(function()
        return __K2L_StringFormat("%x %x %x %o %o %X", __K2L_Text.sized(b, 8), __K2L_Text.sized(s, 16), __K2L_Text.sized(l, 64), __K2L_Text.sized(b, 8), __K2L_Text.sized(l, 64), __K2L_Text.sized(-9223372036854775807 - 1, 64))
    end)
    t(function()
        return __K2L_StringFormat("%x %x %d %d", __K2L_Text.sized(__K2L_Num.toByte(-128), 8), __K2L_Text.sized(-32768, 16), b, s)
    end)
    local nb = -16
    t(function()
        return __K2L_StringFormat("%02x:%02x:%02x", __K2L_Text.sized(nb, 8), __K2L_Text.sized(__K2L_Num.toByte(10), 8), __K2L_Text.sized(__K2L_Num.toByte(171), 8))
    end)
    t(function()
        return __K2L_StringFormat("%08x %x", __K2L_Text.sized(-1 << 4, 64), __K2L_Text.sized((1 << 52) - 1, 64))
    end)
    t(function()
        return __K2L_StringFormat("%c%c%c %c|%3c|%-3c|", 72, 233, 8364, 128512, "x", "y")
    end)
    t(function()
        return __K2L_StringFormat("%.2b %B %b %5b|", true, false, nil, "x")
    end)
    t(function() return __K2L_StringFormat("%s %s", 2) end)
    t(function() return __K2L_StringFormat("%s") end)
    t(function() return __K2L_StringFormat("[%s]", "x") end)
    t(function() return __K2L_StringFormat("%q", 1) end)
    t(function() return __K2L_StringFormat("abc %") end)
    t(function() return __K2L_StringFormat("%5%|%-5%|%n|") end)
    t(function() return __K2L_StringFormat("%-d", 1) end)
    t(function() return __K2L_StringFormat("%0s", "x") end)
    t(function() return __K2L_StringFormat("%d", "s") end)
    t(function() return __K2L_StringFormat("%f", "s") end)
    t(function() return __K2L_StringFormat("%x", true) end)
    t(function() return __K2L_StringFormat("%.2d", 1) end)
    t(function() return __K2L_StringFormat("%.2x", 1) end)
    t(function() return __K2L_StringFormat("%<s", 1) end)
    t(function() return __K2L_StringFormat("%s %s", 1) end)
    t(function() return __K2L_StringFormat("%3$s", 1) end)
    local ____ok_1, ____result_1 = pcall(function()
        __K2L_StringFormat("%s %s %s", "only one")
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error_1, __K2L_MissingFormatArgumentException) then
            local e = ____error_1
            print("caught MissingFormatArgumentException: " .. __K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
    local ____ok_2, ____result_2 = pcall(function()
        __K2L_StringFormat("%z")
    end)
    if not ____ok_2 then
        local ____error_2 = __K2L_ToThrowable(____result_2)
        if __K2L_InstanceOf(____error_2, __K2L_IllegalFormatException) then
            local e = ____error_2
            print("caught IllegalFormatException: " .. __K2L_Str(e.message))
        else
            error(____error_2, 0)
        end
    end
end

main()
return {t = t}
