local ____lualib = require("lualib_bundle")
local __K2L_CompareByWith = ____lualib.__K2L_CompareByWith
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringEndsWith = ____lualib.__K2L_StringEndsWith
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_Utf16 = ____lualib.__K2L_Utf16
local __K2L_Utf16Case = ____lualib.__K2L_Utf16Case

local capitalizeFirst

local function flags(c)
    local ____builder = __K2L_StringBuilder.new()
    if __K2L_Utf16Case.isLetter(c) then
        ____builder:append("L")
    end
    if __K2L_Utf16Case.isDigit(c) then
        ____builder:append("D")
    end
    if __K2L_Utf16Case.isLetterOrDigit(c) then
        ____builder:append("A")
    end
    if __K2L_Utf16Case.isWhitespace(c) then
        ____builder:append("W")
    end
    if __K2L_Utf16Case.isUpperCase(c) then
        ____builder:append("U")
    end
    if __K2L_Utf16Case.isLowerCase(c) then
        ____builder:append("l")
    end
    return ____builder:toString()
end

local function classification()
    local samples = __K2L_ReadOnlyListOf("a", "Z", "5", " ", "\t", "_", "é", "É", "ß", "ÿ", "Σ", "ς", "σ", "Ω", "ж", "Ж", "日", "テ", "ｱ", "한", "١", "٣", "²", "½", "٫", " ", " ", "​", "　", "", "\031", "ǅ", "ǆ", "Ⅷ", "ⅷ", "ⓐ", "Ⓐ", "ª", "º", "ʰ", "́", "€")
    local ____mod = samples.____modCount
    for ____i = 1, samples.size do
        local c = samples[____i]
        print(__K2L_Utf16.out("U+" .. __K2L_Text.padStart(__K2L_Num.toRadix(__K2L_Utf16.code(c), 16), 4, "0") .. " " .. flags(c)))
        if samples.____modCount ~= ____mod and samples:____comodified(____i) then
            break
        end
    end
end

local ____lambda_1 = function(it) return __K2L_Utf16Case.uppercase(it) end
local ____lambda_2 = function(it) return __K2L_Utf16Case.titlecase(it) end
local ____lambda_3 = function(it) return __K2L_Utf16Case.titlecase(it) end
local function caseMapping()
    print(__K2L_Utf16.out(__K2L_Utf16Case.uppercaseChar("é")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.lowercaseChar("É")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.uppercaseChar("ß")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.uppercase("ß")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.uppercaseChar("ǆ")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.titlecaseChar("ǆ")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.titlecase("ǆ")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.lowercaseChar("ǅ")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.uppercase("ŉ")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.titlecase("ŉ")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.uppercase("ΐ")))
    print(__K2L_Utf16.out(__K2L_Utf16.len(__K2L_Utf16Case.uppercase("ΐ"))))
    print(__K2L_Utf16.out(__K2L_Utf16Case.lowercase("İ")))
    print(__K2L_Utf16.out(__K2L_Utf16.len(__K2L_Utf16Case.lowercase("İ"))))
    print(__K2L_Utf16.out(__K2L_Utf16Case.uppercaseChar("ı")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.uppercaseChar("ÿ")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.uppercaseChar("µ")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.uppercaseChar("a")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.lowercase("Z")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.uppercase("ǈ")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.uppercase("ﬃ")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.titlecase("ﬃ")))
    print(__K2L_Utf16.out(__K2L_Text.replaceFirstChar("éa", ____lambda_1)))
    print(__K2L_Utf16.out(__K2L_Text.replaceFirstChar("ǆemal", ____lambda_2)))
    print(__K2L_Utf16.out(__K2L_Text.replaceFirstChar("ßtraße", ____lambda_3)))
end

local function stringCase()
    local words = __K2L_ReadOnlyListOf("straße", "Straße", "ǆ", "ﬃ", "άέή ώ", "ΐ", "ŉ", "İSTANBUL", "ÀÉÎÕÜ", "àéîõü", "日本語 abc", "Привет Мир", "ÿ", "µ", "a😀b", "𐐨𐐀", "ǅungla")
    local ____mod_1 = words.____modCount
    for ____i_1 = 1, words.size do
        local w = words[____i_1]
        print(__K2L_Utf16.out(w .. " -> " .. __K2L_Utf16Case.uppercase(w) .. " " .. __K2L_Utf16Case.lowercase(w) .. " " .. __K2L_Utf16.len(__K2L_Utf16Case.uppercase(w)) .. " " .. __K2L_Utf16.len(__K2L_Utf16Case.lowercase(w))))
        if words.____modCount ~= ____mod_1 and words:____comodified(____i_1) then
            break
        end
    end
    print(__K2L_Utf16.out(__K2L_Utf16Case.uppercase("ÀÉÎ")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.lowercase("ÀÉÎ")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.lowercase("ÀÉÎ")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.uppercase("straße")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.lowercase("ΑΣ")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.lowercase("ΑΣΑ")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.lowercase("ΣΑΣ")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.lowercase("Σ")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.lowercase("ΑΣ ΒΣ ΓΣΓ")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.lowercase("ΟΔΥΣΣΕΎΣ")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.lowercase("ΑΣ.")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.lowercase("ΑΣ!")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.lowercase("ΣΑΣ ΣΑΣ")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.lowercase("ΑΣ1")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.lowercase("Α-Σ")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.lowercase("ΑΣΣ")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.lowercase("αΣ")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.lowercase("aΣ")))
end

local ____lambda_4 = function(it) return it end
local function ignoreCase()
    print(__K2L_Utf16.out(__K2L_Utf16Case.equalsIgnoreCase("É", "é")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.equalsIgnoreCase("Straße", "STRASSE")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.equalsIgnoreCase("Σ", "ς")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.equalsIgnoreCase("ǅ", "ǆ")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.equalsIgnoreCase("ПРИВЕТ", "привет")))
    print(__K2L_Utf16.out(__K2L_Utf16Case.equalsIgnoreCase("abc", "ABD")))
    print(__K2L_Utf16.out(__K2L_StringStartsWith(__K2L_Utf16Case.fold("Éclair"), __K2L_Utf16Case.fold("éc"))))
    print(__K2L_Utf16.out(__K2L_StringEndsWith(__K2L_Utf16Case.fold("Éclair"), __K2L_Utf16Case.fold("AIR"))))
    print(__K2L_Utf16.out(__K2L_StringContains(__K2L_Utf16Case.fold("un ÉCLAIR"), __K2L_Utf16Case.fold("éclair"))))
    print(__K2L_Utf16.out(__K2L_Text.indexOf("un ÉCLAIR", "éclair", nil, true)))
    print(__K2L_Utf16.out(__K2L_Text.lastIndexOf("un ÉCLAIR é", "É", nil, true)))
    print(__K2L_Utf16.out(__K2L_Text.replace("un ÉCLAIR", "éclair", "tarte", true)))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Text.split("a É b é c", {"é"}, nil, true))))
    print(__K2L_Utf16.out(__K2L_Text.compare(__K2L_Utf16Case.fold("é"), __K2L_Utf16Case.fold("É"))))
    print(__K2L_Utf16.out(__K2L_Text.compare("é", "É")))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ReadOnlyListOf("zèbre", "Zèbre", "éclair", "Éclat", "apple", "Äpfel", "Zoo"):sortedWith(__K2L_Text.caseInsensitiveOrder))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ReadOnlyListOf("zèbre", "Zèbre", "éclair", "Éclat", "apple", "Äpfel", "Zoo"):sorted())))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ReadOnlyListOf("b", "é", "a", "É"):sortedWith(__K2L_CompareByWith(__K2L_Text.caseInsensitiveOrder, ____lambda_4)))))
    print(__K2L_Utf16.out("é" == "É"))
    print(__K2L_Utf16.out("é" == "É" or true and __K2L_Utf16Case.equalsIgnoreCase("é", "É")))
    print(__K2L_Utf16.out("a" == "b" or true and __K2L_Utf16Case.equalsIgnoreCase("a", "b")))
end

local function digits()
    print(__K2L_Utf16.out(__K2L_Num.digitToInt("٣")))
    print(__K2L_Utf16.out(__K2L_Num.digitToInt("a", 16)))
    print(__K2L_Utf16.out(__K2L_Num.digitToInt("F", 16)))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Num.digitToIntOrNull("x"))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Num.digitToIntOrNull("٣"))))
    print(__K2L_Utf16.out(__K2L_Num.digitToInt("9")))
    print(__K2L_Utf16.out(__K2L_Num.digitToInt("७")))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Num.digitToIntOrNull("²"))))
end

local ____lambda_5 = function(it) return __K2L_Utf16Case.isLetter(it) end
local ____lambda_6 = function(it) return __K2L_Utf16Case.isDigit(it) end
local ____lambda_7 = function(it) return __K2L_Utf16Case.isWhitespace(it) end
local ____lambda_8 = function(it) return __K2L_Utf16Case.isUpperCase(it) end
local ____lambda_9 = function(it) return __K2L_Utf16Case.isLowerCase(it) end
local ____lambda_10 = function(it) return __K2L_Utf16Case.isLetterOrDigit(it) end
local ____lambda_11 = function(it)
    return __K2L_Utf16Case.isLetter(it) and __K2L_Utf16Case.uppercaseChar(it) or it
end
local ____lambda_12 = function(it) return __K2L_Utf16.isSurrogate(it) end
local ____lambda_13 = function(it) return __K2L_Utf16Case.isLetter(it) end
local ____lambda_14 = function(it) return not __K2L_Utf16Case.isLetter(it) end
local ____lambda_15 = function(it)
    return __K2L_Utf16Case.isLowerCase(it) and __K2L_Utf16Case.titlecase(it) or it
end
local function predicates()
    local s = "Héllo, Wörld! 日本語 123 ١٢٣ 😀"
    print(__K2L_Utf16.out(__K2L_Text.toList(s):count(____lambda_5)))
    print(__K2L_Utf16.out(__K2L_Text.toList(s):count(____lambda_6)))
    print(__K2L_Utf16.out(__K2L_Text.toList(s):count(____lambda_7)))
    print(__K2L_Utf16.out(__K2L_Text.toList(s):count(____lambda_8)))
    print(__K2L_Utf16.out(__K2L_Text.toList(s):count(____lambda_9)))
    print(__K2L_Utf16.out(__K2L_Text.filter(s, ____lambda_10)))
    print(__K2L_Utf16.out(__K2L_Utf16.norm(__K2L_Text.toList(s):map(____lambda_11):joinToString(""))))
    print(__K2L_Utf16.out(__K2L_Text.toList(s):any(____lambda_12)))
    print(__K2L_Utf16.out(__K2L_Text.toList(s):all(____lambda_13)))
    print(__K2L_Utf16.out(__K2L_Text.trimWith(s, 3, ____lambda_14)))
    print(__K2L_Utf16.out(__K2L_Text.trim("  é 　")))
    print(__K2L_Utf16.out(__K2L_Utf16.len(__K2L_Text.trim("  é 　"))))
    print(__K2L_Utf16.out(__K2L_Text.isBlank("  ")))
    print(__K2L_Utf16.out(__K2L_Text.isBlank("​")))
    print(__K2L_Utf16.out(not __K2L_Text.isBlank(" é ")))
    print(__K2L_Utf16.out(__K2L_Utf16.len(__K2L_Text.trimStart(" é"))))
    print(__K2L_Utf16.out(__K2L_Utf16.len(__K2L_Text.trimEnd("é "))))
    print(__K2L_Utf16.out(capitalizeFirst("été")))
    print(__K2L_Utf16.out(__K2L_Text.replaceFirstChar(__K2L_Utf16Case.lowercase("ÉTÉ"), ____lambda_15)))
end

local ____lambda_16 = function(it) return __K2L_Utf16Case.uppercase(it) end
function capitalizeFirst(self)
    return __K2L_Text.replaceFirstChar(self, ____lambda_16)
end

local ____lambda_17 = function(it) return it.value end
local ____lambda_18 = function(it) return it.value end
local ____lambda_19 = function(it) return it.value end
local function regexClasses()
    local word = __K2L_Regex.new("\\w+")
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Sequence.new(word:findAllFactory("héllo wörld 日本語 abc")):map(____lambda_17):toList())))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("\\d+"):findAllFactory("a١٢٣b123")):map(____lambda_18):toList())))
    print(__K2L_Utf16.out(__K2L_Sequence.new(__K2L_Regex.new("\\s"):findAllFactory("a b c")):count()))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("[a-z]+"):findAllFactory("héllo")):map(____lambda_19):toList())))
    local ____receiver = __K2L_Regex.new("é"):find("héllo")
    print(__K2L_Utf16.out(__K2L_Str(____receiver and ____receiver.range)))
    local ____receiver_1 = __K2L_Regex.new("(.)(.)"):find("日本語")
    print(__K2L_Utf16.out(__K2L_Str(____receiver_1 and ____receiver_1.groupValues)))
    print(__K2L_Utf16.out(__K2L_Regex.new("[ÀÉ]B"):matches("ÀB")))
end

local function main()
    classification()
    caseMapping()
    stringCase()
    ignoreCase()
    digits()
    predicates()
    regexClasses()
end

__K2L_Main(main)
return {flags = flags, classification = classification, caseMapping = caseMapping, stringCase = stringCase, ignoreCase = ignoreCase, digits = digits, predicates = predicates, capitalizeFirst = capitalizeFirst, regexClasses = regexClasses}
