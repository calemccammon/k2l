local ____lualib = require("lualib_bundle")
local __K2L_CharCategory = ____lualib.__K2L_CharCategory
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Utf16 = ____lualib.__K2L_Utf16
local __K2L_Utf16Case = ____lualib.__K2L_Utf16Case

local function t(label, f)
    local ____ok, ____result = __K2L_DeepPcall(function()
        print(__K2L_Utf16.out(label .. " = " .. __K2L_Str(f())))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_Exception) then
            local e = ____error
            print(__K2L_Utf16.out(label .. " EXC " .. __K2L_Str(__K2L_KClassOfValue(e).simpleName) .. ": " .. __K2L_Str(e.message)))
        else
            error(____error, 0)
        end
    end
end

local ____lambda_1 = function(it) return it ~= " " end
local ____lambda_2 = function()
    return __K2L_ReadOnlyListOf(__K2L_CharCategory.of(__K2L_Utf16.code("\237\160\189")), __K2L_CharCategory.of(__K2L_Utf16.code("\237\184\128")), __K2L_Utf16.isSurrogate("\237\160\189"), __K2L_Utf16.isLowSurrogate("\237\184\128"))
end
local ____lambda_3 = function(it)
    return tostring(__K2L_Utf16.isHighSurrogate(it)) .. "/" .. tostring(__K2L_Utf16.isLowSurrogate(it)) .. "/" .. tostring(__K2L_Utf16.isSurrogate(it))
end
local ____lambda_4 = function()
    return __K2L_Text.toList("😀"):map(____lambda_3)
end
local ____lambda_5 = function()
    return __K2L_ReadOnlyListOf(__K2L_Utf16Case.titlecaseChar("ǆ"), __K2L_Utf16Case.titlecase("ǆ"), __K2L_Utf16Case.isTitleCase("ǅ"), __K2L_Utf16Case.titlecase("ß"), __K2L_Utf16Case.titlecase("a"))
end
local ____lambda_6 = function()
    return __K2L_ReadOnlyListOf(__K2L_CharCategory.LOWERCASE_LETTER:contains(__K2L_Utf16.code("é")), __K2L_CharCategory.OTHER_LETTER:contains(__K2L_Utf16.code("中")), __K2L_CharCategory.MATH_SYMBOL:contains(__K2L_Utf16.code("€")))
end
local ____lambda_7 = function(it)
    return tostring(__K2L_CharCategory.isJavaIdentifierStart(__K2L_Utf16.code(it))) .. "/" .. tostring(__K2L_CharCategory.isJavaIdentifierPart(__K2L_Utf16.code(it))) .. "/" .. tostring(__K2L_CharCategory.isIdentifierIgnorable(__K2L_Utf16.code(it)))
end
local ____lambda_8 = function()
    return __K2L_Text.toList("é€_٣­́·"):map(____lambda_7)
end
local ____lambda_9 = function(it) return __K2L_Utf16.char(it) end
local ____lambda_10 = function(it)
    return __K2L_CharCategory.of(__K2L_Utf16.code(it)).code
end
local ____lambda_11 = function()
    return __K2L_IntRange.new(880, 1024 - 1):map(____lambda_9):groupingBy(____lambda_10):eachCount():toSortedMap()
end
local ____lambda_12 = function(it)
    return __K2L_CharCategory.typeOf(__K2L_Utf16.code(__K2L_Utf16.char(it))) ~= 0
end
local ____lambda_13 = function()
    return __K2L_IntRange.new(880, 1024 - 1):count(____lambda_12)
end
local function main()
    local samples = "Aa1 é Σ ǅ ٣ € « » ½ ʰ 中 Ⅻ ́ ⃝ ः ­      ͸  ￿"
    for c in __K2L_Utf16.each(__K2L_Text.filter(samples, ____lambda_1)) do
        local cat = __K2L_CharCategory.of(__K2L_Utf16.code(c))
        print(__K2L_Utf16.out("U+" .. __K2L_Text.padStart(__K2L_Num.toRadix(__K2L_Utf16.code(c), 16), 4, "0") .. " " .. __K2L_Str(cat) .. " " .. cat.code .. " " .. cat.value .. " defined=" .. tostring(__K2L_CharCategory.typeOf(__K2L_Utf16.code(c)) ~= 0) .. " title=" .. tostring(__K2L_Utf16Case.isTitleCase(c))))
    end
    t("surrogate", ____lambda_2)
    t("pair", ____lambda_4)
    t("titlecase", ____lambda_5)
    t("contains", ____lambda_6)
    t("identifier", ____lambda_8)
    t("count by category", ____lambda_11)
    t("defined in Greek", ____lambda_13)
end

__K2L_DeepMain(main)
return {t = t}
