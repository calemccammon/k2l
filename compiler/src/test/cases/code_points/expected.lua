local ____lualib = require("lualib_bundle")
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_Utf16 = ____lualib.__K2L_Utf16
local __K2L_Utf16Case = ____lualib.__K2L_Utf16Case

local ____lambda_1 = function(it) return it > 65535 end
local ____lambda_2 = function(it) return it + 1 end
local function codePoints()
    local s = "a😀b𝄞é"
    print(__K2L_Utf16.out(__K2L_Utf16.len(s)))
    print(__K2L_Utf16.out(__K2L_Utf16.codePointAt(s, 0)))
    print(__K2L_Utf16.out(__K2L_Utf16.codePointAt(s, 1)))
    print(__K2L_Utf16.out(__K2L_Utf16.codePointAt(s, 2)))
    print(__K2L_Utf16.out(__K2L_Utf16.codePointAt(s, 3)))
    print(__K2L_Utf16.out(__K2L_Utf16.codePointBefore(s, 3)))
    print(__K2L_Utf16.out(__K2L_Utf16.codePointCount(s, 0, __K2L_Utf16.len(s))))
    print(__K2L_Utf16.out(__K2L_Utf16.codePointCount(s, 1, 3)))
    print(__K2L_Utf16.out(__K2L_Utf16.offsetByCodePoints(s, 0, 3)))
    print(__K2L_Utf16.out(__K2L_Utf16.codePoints(s):count()))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Utf16.codePoints(s):toArray():toList())))
    print(__K2L_Utf16.out(__K2L_Utf16.chars16(s):count()))
    print(__K2L_Utf16.out(__K2L_Utf16.chars16(s):sum()))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Utf16.codePoints(s):boxed():toList())))
    __K2L_Utf16.codePoints(s):forEach(function(it)
        print(__K2L_Utf16.out(__K2L_Str(__K2L_Num.toRadixUnsigned(it, 16))))
    end)
    print(__K2L_Utf16.out(__K2L_Utf16.codePoints(s):filter(____lambda_1):count()))
    print(__K2L_Utf16.out(__K2L_Utf16.codePoints(s):map(____lambda_2):sum()))
end

local function surrogates()
    print(__K2L_Utf16.out(128512 >= 65536 and 128512 <= 1114111))
    print(__K2L_Utf16.out(65 >= 65536 and 65 <= 1114111))
    print(__K2L_Utf16.out(128512 >= 65536 and 2 or 1))
    print(__K2L_Utf16.out(65 >= 65536 and 2 or 1))
    local chars = __K2L_Utf16.toChars(128512)
    print(__K2L_Utf16.out(chars.size))
    print(__K2L_Utf16.out(__K2L_Utf16.code(chars:get(0))))
    print(__K2L_Utf16.out(__K2L_Utf16.code(chars:get(1))))
    print(__K2L_Utf16.out(__K2L_Text.string(chars)))
    print(__K2L_Utf16.out(__K2L_Utf16.len(__K2L_Text.string(chars))))
    print(__K2L_Utf16.out(__K2L_Utf16.toChars(65).size))
    print(__K2L_Utf16.out(__K2L_Utf16.isSurrogate("a")))
    print(__K2L_Utf16.out(__K2L_Utf16.isSurrogate(chars:get(0))))
    print(__K2L_Utf16.out(__K2L_Utf16.isHighSurrogate(chars:get(0))))
    print(__K2L_Utf16.out(__K2L_Utf16.isLowSurrogate(chars:get(0))))
    print(__K2L_Utf16.out(__K2L_Utf16.isLowSurrogate(chars:get(1))))
    print(__K2L_Utf16.out(__K2L_Utf16.isHighSurrogate(chars:get(0))))
    print(__K2L_Utf16.out(__K2L_Utf16.toCodePoint(chars:get(0), chars:get(1))))
    local sb = __K2L_StringBuilder.new()
    sb:appendCodePoint(128512)
    sb:appendCodePoint(98)
    sb:appendCodePoint(119070)
    print(__K2L_Utf16.out(__K2L_Str(sb)))
    print(__K2L_Utf16.out(sb:getLength()))
    print(__K2L_Utf16.out(__K2L_Utf16Case.isLetter("é")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.isLetterCp(26085)))
    print(__K2L_Utf16.out(__K2L_Utf16Case.isDigitCp(1635)))
    print(__K2L_Utf16.out(__K2L_Utf16Case.isUpperCaseCp(201)))
    print(__K2L_Utf16.out(__K2L_Utf16Case.uppercaseChar("é")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.toUpperCaseCp(233)))
    print(__K2L_Utf16.out(__K2L_Utf16Case.toLowerCaseCp(66560)))
    print(__K2L_Utf16.out(__K2L_Utf16Case.isWhitespaceCp(8195)))
    print(__K2L_Utf16.out(__K2L_Utf16Case.isLetterOrDigit("_")))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Utf16.codePointString(128512))))
    local half = __K2L_Text.substring("😀", 0, 1)
    print(__K2L_Utf16.out(__K2L_Utf16.len(half)))
    print(__K2L_Utf16.out(__K2L_Utf16.isHighSurrogate(__K2L_Text.first(half))))
end

local function locales()
    print(__K2L_Utf16.out(__K2L_Utf16.len(__K2L_Utf16Case.lowercase("İI"))))
    print(__K2L_Utf16.out(__K2L_Utf16Case.uppercase("ß")))
    print(__K2L_Utf16.out(__K2L_StringFormat("%5.1f|%d|%s", 3.14159, 42, "é")))
    print(__K2L_Utf16.out(__K2L_StringFormat("%08.3f", 3.14159)))
    print(__K2L_Utf16.out(__K2L_StringFormat("%s-%s", 1, "x")))
end

local ____lambda_3 = function(it) return it.range end
local ____lambda_4 = function(it) return it.range.first end
local function regexIndices()
    local s = "a😀b😀c"
    local emoji = __K2L_Regex.new("😀")
    local ____receiver = emoji:find(s)
    print(__K2L_Utf16.out(__K2L_Str(____receiver and ____receiver.range)))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Sequence.new(emoji:findAllFactory(s)):map(____lambda_3):toList())))
    local ____receiver_1 = emoji:find(s, 2)
    print(__K2L_Utf16.out(__K2L_Str(____receiver_1 and ____receiver_1.range)))
    local ____receiver_2 = __K2L_Regex.new("b."):find(s)
    print(__K2L_Utf16.out(__K2L_Str(____receiver_2 and ____receiver_2.value)))
    local ____receiver_3 = __K2L_Regex.new("(.)(😀)"):find(s)
    local ____receiver_4 = ____receiver_3 and ____receiver_3.groups
    local ____receiver_5 = ____receiver_4 and ____receiver_4:get(2)
    print(__K2L_Utf16.out(__K2L_Str(____receiver_5 and ____receiver_5.range)))
    print(__K2L_Utf16.out(__K2L_Sequence.new(__K2L_Regex.new("."):findAllFactory(s)):count()))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("[a-c]"):findAllFactory(s)):map(____lambda_4):toList())))
    print(__K2L_Utf16.out(emoji:replace(s, "<>")))
    print(__K2L_Utf16.out(__K2L_Str(emoji:split(s))))
    print(__K2L_Utf16.out(__K2L_Regex.new("[^a-z]"):replace(s, "?")))
end

local function main()
    codePoints()
    surrogates()
    locales()
    regexIndices()
end

main()
return {codePoints = codePoints, surrogates = surrogates, locales = locales, regexIndices = regexIndices}
