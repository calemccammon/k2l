local ____lualib = require("lualib_bundle")
local __K2L_CharCategory = ____lualib.__K2L_CharCategory
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function t(label, f)
    local ____ok, ____result = __K2L_DeepPcall(function()
        print(label .. " = " .. __K2L_Str(f()))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_Exception) then
            local e = ____error
            print(label .. " EXC " .. __K2L_Str(__K2L_KClassOfValue(e).simpleName) .. ": " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
end

local function describe(c)
    local cat = __K2L_CharCategory.of(c:byte())
    return c:byte() .. ":" .. __K2L_Str(cat) .. "/" .. cat.code .. "/" .. cat.value
end

local function kind(c)
    local ____subject = __K2L_CharCategory.of(c:byte())
    if ____subject == __K2L_CharCategory.UPPERCASE_LETTER or ____subject == __K2L_CharCategory.LOWERCASE_LETTER then
        return "letter"
    elseif ____subject == __K2L_CharCategory.DECIMAL_DIGIT_NUMBER then
        return "digit"
    elseif ____subject == __K2L_CharCategory.SPACE_SEPARATOR or ____subject == __K2L_CharCategory.CONTROL then
        return "blank"
    elseif ____subject == __K2L_CharCategory.MATH_SYMBOL or ____subject == __K2L_CharCategory.CURRENCY_SYMBOL or ____subject == __K2L_CharCategory.MODIFIER_SYMBOL then
        return "symbol"
    else
        return "punctuation"
    end
end

local ____lambda_1 = function(it) return string.char(it) end
local ____lambda_2 = function(it) return string.char(it) end
local ____lambda_3 = function(it)
    return it .. __K2L_CharCategory.of(it:byte()).code
end
local ____lambda_4 = function()
    return __K2L_IntRange.new(32, 127 - 1):map(____lambda_2):joinToString(" ", nil, nil, nil, nil, ____lambda_3)
end
local ____lambda_5 = function()
    return __K2L_ReadOnlyListOf("A", "z", "5", " ", "\n", "$", "_", "(", ")", "-", "+", "^", "~", "\127"):map(describe)
end
local ____lambda_6 = function()
    return __K2L_StringToList("Hi, 42 + $5^2!"):map(kind)
end
local ____lambda_7 = function() return __K2L_CharCategory.values().size end
local ____lambda_8 = function() return __K2L_CharCategory.values():take(5) end
local ____lambda_9 = function()
    return __K2L_CharCategory.valueOf("MATH_SYMBOL")
end
local ____lambda_10 = function() return __K2L_CharCategory.valueOf("NOPE") end
local ____lambda_11 = function()
    return __K2L_ReadOnlyListOf(__K2L_CharCategory.LOWERCASE_LETTER:contains(("a"):byte()), __K2L_CharCategory.LOWERCASE_LETTER:contains(("A"):byte()), __K2L_CharCategory.DECIMAL_DIGIT_NUMBER:contains(("7"):byte()))
end
local ____lambda_12 = function()
    return __K2L_ReadOnlyListOf(__K2L_Compare(__K2L_CharCategory.CONTROL, __K2L_CharCategory.UPPERCASE_LETTER) > 0, __K2L_Compare(__K2L_CharCategory.FORMAT, __K2L_CharCategory.CONTROL))
end
local ____lambda_13 = function()
    return __K2L_CharCategory.CURRENCY_SYMBOL.name .. "/" .. __K2L_CharCategory.CURRENCY_SYMBOL.ordinal
end
local ____lambda_14 = function(it) return __K2L_CharCategory.of(it:byte()) end
local ____lambda_15 = function()
    return __K2L_StringToList("aA1 a"):map(____lambda_14):toSet()
end
local ____lambda_16 = function()
    return __K2L_ReadOnlyListOf(("a"):upper(), ("Z"):upper(), ("1"):upper())
end
local ____lambda_17 = function(it)
    return tostring(__K2L_CharCategory.isJavaIdentifierStart(it:byte())) .. "/" .. tostring(__K2L_CharCategory.isJavaIdentifierPart(it:byte()))
end
local ____lambda_18 = function()
    return __K2L_StringToList("a_1$-"):map(____lambda_17)
end
local function main()
    local all = __K2L_IntRange.new(0, 128 - 1):map(____lambda_1)
    t("ascii", function()
        local ____result_1 = __K2L_Map.new()
        local ____items, ____n = all:____array()
        for ____i = 1, ____n do
            local it = ____items[____i]
            local ____value = __K2L_CharCategory.of(it:byte())
            local ____group = ____result_1:get(____value)
            if ____group == nil then
                ____group = __K2L_List.new()
                ____result_1:put(____value, ____group)
            end
            ____group:add(it:byte())
        end
        return ____result_1:mapValues(function(____destructured)
            local codes = ____destructured.value
            return codes.size
        end)
    end)
    t("printable", ____lambda_4)
    t("describe", ____lambda_5)
    t("kinds", ____lambda_6)
    t("entries", ____lambda_7)
    t("first entries", ____lambda_8)
    t("values", function()
        local ____list = __K2L_CharCategory.values()
        local ____out = {}
        local ____count = 0
        local ____items_1, ____n_1 = ____list:____array()
        for ____i_1 = 1, ____n_1 do
            local it = ____items_1[____i_1]
            ____count = ____count + 1
            ____out[____count] = it.code
        end
        return __K2L_ListWrap(____out, ____count):joinToString(",")
    end)
    t("value numbers", function()
        local ____list_1 = __K2L_CharCategory.values()
        local ____out_1 = {}
        local ____count_1 = 0
        local ____items_2, ____n_2 = ____list_1:____array()
        for ____i_2 = 1, ____n_2 do
            local it = ____items_2[____i_2]
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = it.value
        end
        return __K2L_ListWrap(____out_1, ____count_1)
    end)
    t("ordinals", function()
        local ____list_2 = __K2L_CharCategory.values()
        local ____out_2 = {}
        local ____count_2 = 0
        local ____items_3, ____n_3 = ____list_2:____array()
        for ____i_3 = 1, ____n_3 do
            local it = ____items_3[____i_3]
            ____count_2 = ____count_2 + 1
            ____out_2[____count_2] = it.ordinal
        end
        return __K2L_ListWrap(____out_2, ____count_2):sum()
    end)
    t("valueOf", ____lambda_9)
    t("valueOf bad", ____lambda_10)
    t("contains", ____lambda_11)
    t("compare", ____lambda_12)
    t("name", ____lambda_13)
    t("set", ____lambda_15)
    t("isDefined", function()
        local ____result_2 = 0
        local ____items_4, ____n_4 = all:____array()
        for ____i_4 = 1, ____n_4 do
            local it = ____items_4[____i_4]
            if __K2L_CharCategory.typeOf(it:byte()) ~= 0 then
                ____result_2 = ____result_2 + 1
            end
        end
        return ____result_2
    end)
    t("isTitleCase", function()
        local ____result_3 = 0
        local ____items_5, ____n_5 = all:____array()
        for ____i_5 = 1, ____n_5 do
            local it = ____items_5[____i_5]
            if false then
                ____result_3 = ____result_3 + 1
            end
        end
        return ____result_3
    end)
    t("titlecase", ____lambda_16)
    t("surrogates", function()
        local ____result_4 = 0
        local ____items_6, ____n_6 = all:____array()
        for ____i_6 = 1, ____n_6 do
            local it = ____items_6[____i_6]
            if false or false or false then
                ____result_4 = ____result_4 + 1
            end
        end
        return ____result_4
    end)
    t("identifier start", function()
        local ____out_3 = {}
        local ____count_3 = 0
        local ____items_7, ____n_7 = all:____array()
        for ____i_7 = 1, ____n_7 do
            local it = ____items_7[____i_7]
            if __K2L_CharCategory.isJavaIdentifierStart(it:byte()) then
                ____count_3 = ____count_3 + 1
                ____out_3[____count_3] = it
            end
        end
        return __K2L_ListWrap(____out_3, ____count_3).size
    end)
    t("identifier part", function()
        local ____out_4 = {}
        local ____count_4 = 0
        local ____items_8, ____n_8 = all:____array()
        for ____i_8 = 1, ____n_8 do
            local it = ____items_8[____i_8]
            if __K2L_CharCategory.isJavaIdentifierPart(it:byte()) then
                ____count_4 = ____count_4 + 1
                ____out_4[____count_4] = it
            end
        end
        return __K2L_ListWrap(____out_4, ____count_4).size
    end)
    t("identifier ignorable", function()
        local ____out_5 = {}
        local ____count_5 = 0
        local ____items_9, ____n_9 = all:____array()
        for ____i_9 = 1, ____n_9 do
            local it = ____items_9[____i_9]
            if __K2L_CharCategory.isIdentifierIgnorable(it:byte()) then
                ____count_5 = ____count_5 + 1
                ____out_5[____count_5] = it
            end
        end
        local ____list_3 = __K2L_ListWrap(____out_5, ____count_5)
        local ____out_6 = {}
        local ____count_6 = 0
        local ____items_10, ____n_10 = ____list_3:____array()
        for ____i_10 = 1, ____n_10 do
            local it = ____items_10[____i_10]
            ____count_6 = ____count_6 + 1
            ____out_6[____count_6] = it:byte()
        end
        return __K2L_ListWrap(____out_6, ____count_6)
    end)
    t("identifier chars", ____lambda_18)
end

__K2L_DeepMain(main)
return {t = t, describe = describe, kind = kind}
