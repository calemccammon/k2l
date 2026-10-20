local ____lualib = require("lualib_bundle")
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function t(label, f)
    local ____ok, ____result = __K2L_DeepPcall(function()
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

local ____lambda_1 = function()
    return __K2L_ReadOnlyListOf(5 >= 1 and 5 <= 10, not (5 >= 1 and 5 <= 4), "c" >= "a" and "c" <= "z", 9 >= 1 and 9 <= 3)
end
local ____lambda_2 = function()
    return __K2L_ReadOnlySetOf(1 >= 0 and 1 <= 2, 3 >= 0 and 3 <= 2)
end
local ____lambda_3 = function()
    return __K2L_ReadOnlyListOf(__K2L_Hash(1.5), __K2L_Hash(-0.1))
end
local ____lambda_4 = function()
    return __K2L_ReadOnlyListOf(__K2L_Hash(5000000000), __K2L_Hash(-5000000000), __K2L_Hash(7))
end
local ____lambda_5 = function()
    return __K2L_Hash(__K2L_SingletonMapOf(__K2L_Pair.new(1.5, "a")))
end
local ____lambda_6 = function() return __K2L_Num.digitToInt("x") end
local ____lambda_7 = function() return __K2L_Num.digitToInt("x", 16) end
local ____lambda_8 = function() return __K2L_Text.windowed("abc", 0) end
local ____lambda_9 = function() return __K2L_StringPadStart("abc", -1) end
local ____lambda_10 = function() return __K2L_Text.repeatCount("abc", -1) end
local function main()
    t("in-varargs", ____lambda_1)
    t("setOf-in", ____lambda_2)
    t("dblHash", ____lambda_3)
    t("longHash", ____lambda_4)
    t("mapHash", ____lambda_5)
    t("digitToInt", ____lambda_6)
    t("digitToInt16", ____lambda_7)
    t("windowed", ____lambda_8)
    t("padStart", ____lambda_9)
    t("repeat", ____lambda_10)
end

__K2L_DeepMain(main)
return {t = t}
