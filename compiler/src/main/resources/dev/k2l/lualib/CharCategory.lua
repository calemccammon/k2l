-- requires: Class, EnumValues, EnumValueOf, Exceptions
-- kotlin.text.CharCategory, and the general category of a character code. Without --strings utf16 a Char is a byte:
-- the ASCII characters have their Unicode category and the bytes from 0x80 on are UNASSIGNED. With it,
-- CharCategoryUnicode.lua looks the other characters up in the table of UnicodeCategories.lua.
local __K2L_CharCategory = __K2L_Class("kotlin.text.CharCategory")

-- name, Character.getType value and the two-letter code of each entry, in declaration order
local ENTRIES = {
    {"UNASSIGNED", 0, "Cn"}, {"UPPERCASE_LETTER", 1, "Lu"}, {"LOWERCASE_LETTER", 2, "Ll"}, {"TITLECASE_LETTER", 3, "Lt"},
    {"MODIFIER_LETTER", 4, "Lm"}, {"OTHER_LETTER", 5, "Lo"}, {"NON_SPACING_MARK", 6, "Mn"}, {"ENCLOSING_MARK", 7, "Me"},
    {"COMBINING_SPACING_MARK", 8, "Mc"}, {"DECIMAL_DIGIT_NUMBER", 9, "Nd"}, {"LETTER_NUMBER", 10, "Nl"}, {"OTHER_NUMBER", 11, "No"},
    {"SPACE_SEPARATOR", 12, "Zs"}, {"LINE_SEPARATOR", 13, "Zl"}, {"PARAGRAPH_SEPARATOR", 14, "Zp"}, {"CONTROL", 15, "Cc"},
    {"FORMAT", 16, "Cf"}, {"PRIVATE_USE", 18, "Co"}, {"SURROGATE", 19, "Cs"}, {"DASH_PUNCTUATION", 20, "Pd"},
    {"START_PUNCTUATION", 21, "Ps"}, {"END_PUNCTUATION", 22, "Pe"}, {"CONNECTOR_PUNCTUATION", 23, "Pc"},
    {"OTHER_PUNCTUATION", 24, "Po"}, {"MATH_SYMBOL", 25, "Sm"}, {"CURRENCY_SYMBOL", 26, "Sc"}, {"MODIFIER_SYMBOL", 27, "Sk"},
    {"OTHER_SYMBOL", 28, "So"}, {"INITIAL_QUOTE_PUNCTUATION", 29, "Pi"}, {"FINAL_QUOTE_PUNCTUATION", 30, "Pf"},
}

local values, byType = {}, {}
for i, e in ipairs(ENTRIES) do
    local entry = setmetatable({name = e[1], ordinal = i - 1, value = e[2], code = e[3]}, __K2L_CharCategory)
    __K2L_CharCategory[e[1]] = entry
    values[i] = entry
    byType[e[2]] = entry
end
__K2L_CharCategory.____values = values
__K2L_CharCategory.____byType = byType

function __K2L_CharCategory:toString()
    return self.name
end

__K2L_CharCategory.__tostring = __K2L_CharCategory.toString

function __K2L_CharCategory:compareTo(other)
    return self.ordinal - other.ordinal
end

function __K2L_CharCategory.values()
    return __K2L_EnumValues(__K2L_CharCategory)
end

function __K2L_CharCategory.valueOf(name)
    return __K2L_EnumValueOf(__K2L_CharCategory, name)
end

-- CharCategory.valueOf(category: Int), by Character.getType value
function __K2L_CharCategory.ofType(value)
    local entry = byType[value]
    if entry == nil then
        error(__K2L_IllegalArgumentException.new("Category #" .. tostring(value) .. " is not defined."))
    end
    return entry
end

-- the Character.getType value of each ASCII code, as runs of {type, count}
local ascii = {}
do
    local RUNS = {
        {15, 32}, {12, 1}, {24, 3}, {26, 1}, {24, 3}, {21, 1}, {22, 1}, {24, 1}, {25, 1}, {24, 1}, {20, 1}, {24, 2}, {9, 10},
        {24, 2}, {25, 3}, {24, 2}, {1, 26}, {21, 1}, {24, 1}, {22, 1}, {27, 1}, {23, 1}, {27, 1}, {2, 26}, {21, 1}, {25, 1},
        {22, 1}, {25, 1}, {15, 1},
    }
    for _, run in ipairs(RUNS) do
        for _ = 1, run[2] do
            ascii[#ascii + 1] = run[1]
        end
    end
end

-- Character.getType of a character code; `unicode` looks up the codes from 0x80 on (else UNASSIGNED)
function __K2L_CharCategory.typeOf(code)
    if code < 128 then
        return ascii[code + 1]
    end
    local unicode = __K2L_CharCategory.____unicode
    return unicode ~= nil and unicode(code) or 0
end

function __K2L_CharCategory.of(code)
    return byType[__K2L_CharCategory.typeOf(code)]
end

function __K2L_CharCategory:contains(code)
    return __K2L_CharCategory.typeOf(code) == self.value
end

local LETTER = {[1] = true, [2] = true, [3] = true, [4] = true, [5] = true}

-- Character.isIdentifierIgnorable
function __K2L_CharCategory.isIdentifierIgnorable(code)
    return code <= 8 or (code >= 14 and code <= 27) or (code >= 127 and code <= 159) or __K2L_CharCategory.typeOf(code) == 16
end

-- Character.isJavaIdentifierStart: letters, letter numbers, currency symbols and connector punctuation
function __K2L_CharCategory.isJavaIdentifierStart(code)
    local t = __K2L_CharCategory.typeOf(code)
    return LETTER[t] == true or t == 10 or t == 26 or t == 23
end

-- Character.isJavaIdentifierPart: also digits, marks and the ignorable characters
function __K2L_CharCategory.isJavaIdentifierPart(code)
    local t = __K2L_CharCategory.typeOf(code)
    return LETTER[t] == true or t == 10 or t == 26 or t == 23 or t == 9 or t == 6 or t == 8
        or __K2L_CharCategory.isIdentifierIgnorable(code)
end

------------------------------------------------------------------ CharDirectionality

local __K2L_CharDirectionality = __K2L_Class("kotlin.text.CharDirectionality")

local DIRECTIONALITIES = {
    "UNDEFINED", "LEFT_TO_RIGHT", "RIGHT_TO_LEFT", "RIGHT_TO_LEFT_ARABIC", "EUROPEAN_NUMBER", "EUROPEAN_NUMBER_SEPARATOR",
    "EUROPEAN_NUMBER_TERMINATOR", "ARABIC_NUMBER", "COMMON_NUMBER_SEPARATOR", "NONSPACING_MARK", "BOUNDARY_NEUTRAL",
    "PARAGRAPH_SEPARATOR", "SEGMENT_SEPARATOR", "WHITESPACE", "OTHER_NEUTRALS", "LEFT_TO_RIGHT_EMBEDDING",
    "LEFT_TO_RIGHT_OVERRIDE", "RIGHT_TO_LEFT_EMBEDDING", "RIGHT_TO_LEFT_OVERRIDE", "POP_DIRECTIONAL_FORMAT",
}

local directionalities, byValue = {}, {}
for i, name in ipairs(DIRECTIONALITIES) do
    local entry = setmetatable({name = name, ordinal = i - 1, value = i - 2}, __K2L_CharDirectionality)
    __K2L_CharDirectionality[name] = entry
    directionalities[i] = entry
    byValue[i - 2] = entry
end
__K2L_CharDirectionality.____values = directionalities

__K2L_CharDirectionality.toString = __K2L_CharCategory.toString
__K2L_CharDirectionality.__tostring = __K2L_CharCategory.toString
__K2L_CharDirectionality.compareTo = __K2L_CharCategory.compareTo

function __K2L_CharDirectionality.values()
    return __K2L_EnumValues(__K2L_CharDirectionality)
end

function __K2L_CharDirectionality.valueOf(name)
    return __K2L_EnumValueOf(__K2L_CharDirectionality, name)
end

-- CharDirectionality.valueOf(directionality: Int), by Character.getDirectionality value
function __K2L_CharDirectionality.ofValue(value)
    local entry = byValue[value]
    if entry == nil then
        error(__K2L_IllegalArgumentException.new("Directionality #" .. tostring(value) .. " is not defined."))
    end
    return entry
end

-- the Character.getDirectionality value of each ASCII code, as runs of {value, count}
local asciiDirections = {}
do
    local RUNS = {
        {9, 9}, {11, 1}, {10, 1}, {11, 1}, {12, 1}, {10, 1}, {9, 14}, {10, 3}, {11, 1}, {12, 1}, {13, 2}, {5, 3}, {13, 5},
        {4, 1}, {7, 1}, {4, 1}, {7, 2}, {3, 10}, {7, 1}, {13, 6}, {0, 26}, {13, 6}, {0, 26}, {13, 4}, {9, 1},
    }
    for _, run in ipairs(RUNS) do
        for _ = 1, run[2] do
            asciiDirections[#asciiDirections + 1] = run[1]
        end
    end
end

-- Char.directionality of a character code; UnicodeDirectionality.lua sets `____unicode` for the codes from 0x80 on
-- (without it they are UNDEFINED)
function __K2L_CharDirectionality.of(code)
    if code < 128 then
        return byValue[asciiDirections[code + 1]]
    end
    local unicode = __K2L_CharDirectionality.____unicode
    return __K2L_CharDirectionality.ofValue(unicode ~= nil and unicode(code) or -1)
end
