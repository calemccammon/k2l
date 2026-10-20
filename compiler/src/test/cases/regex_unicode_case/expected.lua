local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Utf16 = ____lualib.__K2L_Utf16

local ____lambda_1 = function(it) return it.value end
local function show(pattern, input, ...)
    local options = __K2L_ArrayOf(...)
    local regex = __K2L_Regex.new(pattern, options:toSet())
    local found = regex:find(input)
    return pattern .. " ~ " .. input .. ": " .. __K2L_Str(found and found.value) .. " at " .. __K2L_Str(found and found.range) .. " matches=" .. tostring(regex:matches(input)) .. " all=" .. __K2L_Str(__K2L_Sequence.new(regex:findAllFactory(input)):map(____lambda_1):toList())
end

local function main()
    local ic = "IGNORE_CASE"
    print(__K2L_Utf16.out(show("straße", "STRASSE", ic)))
    print(__K2L_Utf16.out(show("straße", "STRAßE", ic)))
    print(__K2L_Utf16.out(show("élan", "ÉLAN", ic)))
    print(__K2L_Utf16.out(show("ÉLAN", "élan", ic)))
    print(__K2L_Utf16.out(show("привет", "ПРИВЕТ", ic)))
    print(__K2L_Utf16.out(show("ΑΣ", "ας", ic)))
    print(__K2L_Utf16.out(show("ǆ", "ǅ", ic)))
    print(__K2L_Utf16.out(show("ǅ", "Ǆ", ic)))
    print(__K2L_Utf16.out(show("İ", "i", ic)))
    print(__K2L_Utf16.out(show("ı", "I", ic)))
    print(__K2L_Utf16.out(show("ſ", "S", ic)))
    print(__K2L_Utf16.out(show("k", "K", ic)))
    print(__K2L_Utf16.out(show("K", "k", ic)))
    print(__K2L_Utf16.out(show("s+", "SſsS", ic)))
    print(__K2L_Utf16.out(show("[äöü]+", "ÄÖÜäöü", ic)))
    print(__K2L_Utf16.out(show("[a-z]+", "abcKELVINK", ic)))
    print(__K2L_Utf16.out(show("[^é]+", "ÉéaÉ", ic)))
    print(__K2L_Utf16.out(show("[k]", "K", ic)))
    print(__K2L_Utf16.out(show("[K]", "K", ic)))
    print(__K2L_Utf16.out(show("[а-я]+", "привет мир")))
    print(__K2L_Utf16.out(show("[а-я]+", "ПРИВЕТ мир", ic)))
    print(__K2L_Utf16.out(show("[^α-ω]+", "abcαβγ")))
    print(__K2L_Utf16.out(show("[a-я]+", "abcприветXYZ")))
    print(__K2L_Utf16.out(show("(é)\\1", "éÉ", ic)))
    print(__K2L_Utf16.out(show("(ab)\\1", "abAB", ic)))
    print(__K2L_Utf16.out(show("(ab)\\1", "abAB")))
    print(__K2L_Utf16.out(show("(ß)\\1", "ßß", ic)))
    print(__K2L_Utf16.out(show("(?<w>[а-я]+) \\k<w>", "слово СЛОВО", ic)))
    print(__K2L_Utf16.out(show("é{2}", "éÉ", ic)))
    print(__K2L_Utf16.out(show("(?:é|ü)+", "ÉüÜé", ic)))
    print(__K2L_Utf16.out(show("élan", "ÉLAN")))
    print(__K2L_Utf16.out(show("élan", "élan")))
    print(__K2L_Utf16.out(show("abc", "ABC")))
    print(__K2L_Utf16.out(show("(?i)élan", "ÉLAN")))
    print(__K2L_Utf16.out(show("(?i)abc", "ABC")))
    print(__K2L_Utf16.out(show("(?iu)élan", "ÉLAN")))
    print(__K2L_Utf16.out(show("(?i)k", "K")))
    print(__K2L_Utf16.out(show("(?iu)k", "K")))
    print(__K2L_Utf16.out(show("(?i:é)l", "Él")))
    print(__K2L_Utf16.out(show("(?iu:é)l", "Él")))
    print(__K2L_Utf16.out(__K2L_Regex.new("é", ic):replace("Éé", "e")))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Regex.new("É", ic):split("aÉbéc"))))
    print(__K2L_Utf16.out(__K2L_Regex.new("àéî", ic):containsMatchIn("ÀÉÎ")))
    print(__K2L_Utf16.out(__K2L_Regex.new("ß", ic):containsMatchIn("SS")))
end

main()
return {show = show}
