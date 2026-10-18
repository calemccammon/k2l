local ____lualib = require("lualib_bundle")
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function t(label, f)
    local ____ok, ____result = pcall(function()
        print(label .. " = " .. __K2L_Str(f()))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_Exception) then
            local e = ____error
            print(label .. " EXC: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
end

local function main()
    t("in-varargs", function()
        return __K2L_ListOf(5 >= 1 and 5 <= 10, not (5 >= 1 and 5 <= 4), "c" >= "a" and "c" <= "z", 9 >= 1 and 9 <= 3)
    end)
    t("setOf-in", function()
        return __K2L_SetOf(1 >= 0 and 1 <= 2, 3 >= 0 and 3 <= 2)
    end)
    t("dblHash", function()
        return __K2L_ListOf(__K2L_Hash(1.5), __K2L_Hash(-0.1))
    end)
    t("longHash", function()
        return __K2L_ListOf(__K2L_Hash(5000000000), __K2L_Hash(-5000000000), __K2L_Hash(7))
    end)
    t("mapHash", function()
        return __K2L_Hash(__K2L_MapOf(__K2L_Pair.new(1.5, "a")))
    end)
    t("digitToInt", function() return __K2L_Num.digitToInt("x") end)
    t("digitToInt16", function() return __K2L_Num.digitToInt("x", 16) end)
    t("windowed", function() return __K2L_Text.windowed("abc", 0) end)
    t("padStart", function() return __K2L_StringPadStart("abc", -1) end)
    t("repeat", function() return __K2L_Text.repeatCount("abc", -1) end)
end

main()
return {t = t}
