local ____lualib = require("lualib_bundle")
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringToDoubleOrNull = ____lualib.__K2L_StringToDoubleOrNull
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_StringToUnsigned = ____lualib.__K2L_StringToUnsigned
local __K2L_StringToUnsignedOrNull = ____lualib.__K2L_StringToUnsignedOrNull
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Unsigned = ____lualib.__K2L_Unsigned
local __K2L_Utf16 = ____lualib.__K2L_Utf16
local __K2L_Utf16Case = ____lualib.__K2L_Utf16Case

local ____lambda_1 = function(it)
    return __K2L_Utf16Case.isWhitespace(it) and it ~= "\n" and it ~= " " and "[" .. __K2L_Utf16.code(it) .. "]" or it
end
local function show(s)
    return __K2L_Utf16.norm(__K2L_Text.toList(s):map(____lambda_1):joinToString(""))
end

local function attempt(label, block)
    local ____ok, ____result = pcall(function()
        print(__K2L_Utf16.out(label .. ": " .. __K2L_Str(block())))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_Exception) then
            local e = ____error
            print(__K2L_Utf16.out(label .. ": " .. __K2L_Str(__K2L_KClassOfValue(e).simpleName) .. ": " .. __K2L_Str(e.message)))
        else
            error(____error, 0)
        end
    end
end

local ____lambda_2 = function() return __K2L_Text.trimMargin("a", " ") end
local function indents()
    local nbsp = " "
    local em = " "
    local ideographic = "　"
    print(__K2L_Utf16.out(show(__K2L_Text.trimIndent("\n" .. nbsp .. nbsp .. "line1\n" .. nbsp .. nbsp .. nbsp .. "line2\n" .. nbsp .. nbsp .. "\n" .. nbsp .. nbsp .. "line3\n"))))
    print(__K2L_Utf16.out(show(__K2L_Text.trimIndent(em .. em .. "a\n" .. em .. em .. em .. "b\n" .. em .. "c"))))
    print(__K2L_Utf16.out(show(__K2L_Text.trimIndent(ideographic .. "x\n" .. ideographic .. ideographic .. "y"))))
    print(__K2L_Utf16.out(show(__K2L_Text.trimIndent(nbsp .. " a\n   b"))))
    print(__K2L_Utf16.out(show(__K2L_Text.trimIndent("\028x\n\028\028y"))))
    print(__K2L_Utf16.out(show(__K2L_Text.trimIndent("   a\n    b"))))
    print(__K2L_Utf16.out(show(__K2L_Text.trimIndent("\n\n  a\n\n   b\n"))))
    print(__K2L_Utf16.out(show(__K2L_Text.trimMargin(nbsp .. nbsp .. "| a\n" .. em .. "|  b\n   | c"))))
    print(__K2L_Utf16.out(show(__K2L_Text.trimMargin(nbsp .. ">one\n" .. em .. ">two\n three", ">"))))
    print(__K2L_Utf16.out(show(__K2L_Text.trimMargin("\n" .. nbsp .. nbsp .. "|x\n" .. nbsp .. nbsp .. "|y\n"))))
    print(__K2L_Utf16.out(show(__K2L_Text.trimMargin(ideographic .. "|z\n " .. nbsp .. "|w", "|"))))
    attempt("margin", ____lambda_2)
    attempt("marginNbsp", function() return __K2L_Text.trimMargin("a", nbsp) end)
    print(__K2L_Utf16.out(show(__K2L_Text.prependIndent("a\n\n" .. nbsp .. "\nb", "> "))))
    print(__K2L_Utf16.out(show(__K2L_Text.prependIndent("a\n" .. nbsp .. nbsp .. "\n", ">>>"))))
    print(__K2L_Utf16.out(show(__K2L_Text.prependIndent("a\n" .. nbsp .. "\n", ">>>"))))
    print(__K2L_Utf16.out(show(__K2L_Text.prependIndent(nbsp .. "\nb", ""))))
    print(__K2L_Utf16.out(__K2L_Text.prependIndent("héllo\n  wörld", "→")))
    print(__K2L_Utf16.out(__K2L_Text.trimIndent("    ünï\n      cödé")))
end

local ____lambda_3 = function() return __K2L_StringToInt("١٢x") end
local ____lambda_4 = function() return __K2L_StringToInt("ｚ", 16) end
local ____lambda_5 = function() return __K2L_StringToInt("") end
local ____lambda_6 = function() return __K2L_StringToInt("٣٤٥٦٧٨٩٠١٢٣") end
local ____lambda_7 = function() return __K2L_StringToInt("٤٢") end
local ____lambda_8 = function() return __K2L_StringToInt("-٤٢٠", nil, true) end
local ____lambda_9 = function() return __K2L_StringToInt("٧") end
local function digits()
    print(__K2L_Utf16.out(__K2L_StringToInt("١٢٣")))
    print(__K2L_Utf16.out(__K2L_StringToInt("-١٢٣")))
    print(__K2L_Utf16.out(__K2L_StringToInt("+٤٥")))
    print(__K2L_Utf16.out(__K2L_StringToInt("１２３")))
    print(__K2L_Utf16.out(__K2L_StringToInt("१२३", nil, true)))
    print(__K2L_Utf16.out(__K2L_StringToInt("০১২")))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_StringToIntOrNull("๑๒๓"))))
    print(__K2L_Utf16.out(__K2L_StringToInt("12٣")))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_StringToIntOrNull("٣٣٣٣٣٣٣٣٣٣٣٣", nil, true))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_StringToIntOrNull("٣٣٣٣٣٣٣٣٣٣٣٣"))))
    print(__K2L_Utf16.out(__K2L_StringToInt("ａｂ", 16)))
    print(__K2L_Utf16.out(__K2L_StringToInt("ＡＢ", 16)))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_StringToIntOrNull("ａｂ", 10))))
    print(__K2L_Utf16.out(__K2L_StringToInt("ｚ", 36)))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_StringToIntOrNull("ｚ", 35))))
    print(__K2L_Utf16.out(__K2L_StringToInt("ff", 16)))
    print(__K2L_Utf16.out(__K2L_StringToInt("٣f", 16)))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_StringToIntOrNull("²"))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_StringToIntOrNull("ⅷ"))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_StringToIntOrNull("١ ٢"))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_StringToIntOrNull(" ١"))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_StringToIntOrNull("٢.٥"))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_StringToIntOrNull("-"))))
    print(__K2L_Utf16.out(__K2L_StringToInt("٧", nil, true)))
    print(__K2L_Utf16.out(__K2L_StringToUnsigned("٩٩٩", nil, 32)))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_StringToUnsignedOrNull("-٩", nil, 32))))
    print(__K2L_Utf16.out(__K2L_StringToUnsigned("٢٥٥", nil, 8)))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_StringToUnsignedOrNull("٢٥٦", nil, 8))))
    print(__K2L_Utf16.out(__K2L_StringToUnsigned("ＦＦ", 16, 32)))
    print(__K2L_Utf16.out(__K2L_Unsigned.toString(__K2L_StringToUnsigned("１２３４５６７８９０１２３", nil, 64))))
    print(__K2L_Utf16.out(__K2L_Num.digitToInt("٥")))
    print(__K2L_Utf16.out(__K2L_Num.digitToInt("５")))
    print(__K2L_Utf16.out(__K2L_Num.digitToInt("Ａ", 16)))
    print(__K2L_Utf16.out(__K2L_Num.digitToInt("ａ", 16)))
    print(__K2L_Utf16.out(__K2L_Num.digitToInt("ｚ", 36)))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Num.digitToIntOrNull("ｚ", 16))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Num.digitToIntOrNull("९"))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Num.digitToIntOrNull("²"))))
    attempt("bad", ____lambda_3)
    attempt("badRadix", ____lambda_4)
    attempt("empty", ____lambda_5)
    attempt("arabicMessage", ____lambda_6)
    attempt("parseInt", ____lambda_7)
    attempt("parseLong", ____lambda_8)
    attempt("valueOf", ____lambda_9)
    local ____receiver = __K2L_StringToIntOrNull("٤٢")
    print(__K2L_Utf16.out(__K2L_Str(____receiver and ____receiver + 1)))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_StringToDoubleOrNull("١٢٣"))))
end

local function main()
    indents()
    digits()
end

main()
return {show = show, attempt = attempt, indents = indents, digits = digits}
