local ____lualib = require("lualib_bundle")
local __K2L_CompareValues = ____lualib.__K2L_CompareValues
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringIndexOf = ____lualib.__K2L_StringIndexOf
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_Utf16 = ____lualib.__K2L_Utf16
local __K2L_Utf16Case = ____lualib.__K2L_Utf16Case

local FOLD = __K2L_ReadOnlyMapOf(__K2L_Pair.new("à", "a"), __K2L_Pair.new("á", "a"), __K2L_Pair.new("â", "a"), __K2L_Pair.new("ä", "ae"), __K2L_Pair.new("å", "a"), __K2L_Pair.new("ç", "c"), __K2L_Pair.new("è", "e"), __K2L_Pair.new("é", "e"), __K2L_Pair.new("ê", "e"), __K2L_Pair.new("ë", "e"), __K2L_Pair.new("í", "i"), __K2L_Pair.new("î", "i"), __K2L_Pair.new("ï", "i"), __K2L_Pair.new("ñ", "n"), __K2L_Pair.new("ó", "o"), __K2L_Pair.new("ô", "o"), __K2L_Pair.new("ö", "oe"), __K2L_Pair.new("ø", "o"), __K2L_Pair.new("ú", "u"), __K2L_Pair.new("ü", "ue"), __K2L_Pair.new("ß", "ss"), __K2L_Pair.new("œ", "oe"), __K2L_Pair.new("æ", "ae"), __K2L_Pair.new("ł", "l"), __K2L_Pair.new("ś", "s"), __K2L_Pair.new("ż", "z"), __K2L_Pair.new("ź", "z"), __K2L_Pair.new("č", "c"), __K2L_Pair.new("ř", "r"), __K2L_Pair.new("š", "s"))

local function slugify(s)
    local ____builder = __K2L_StringBuilder.new()
    for c in __K2L_Utf16.each(__K2L_Utf16Case.lowercase(s)) do
        if FOLD:containsKey(c) then
            ____builder:append(FOLD:getValue(c))
        elseif c >= "a" and c <= "z" or c >= "0" and c <= "9" then
            ____builder:append(c)
        elseif __K2L_Utf16Case.isLetterOrDigit(c) then
            ____builder:append("-u"):append(__K2L_Num.toRadix(__K2L_Utf16.code(c), 16)):append("-")
        elseif ____builder:isNotEmpty() and __K2L_Text.last(____builder:toString()) ~= "-" then
            ____builder:append("-")
        end
    end
    return __K2L_Regex.new("-{2,}"):replace(__K2L_Text.trimChars(____builder:toString(), 3, "-"), "-")
end

local function truncate(s, max)
    if __K2L_Utf16.codePointCount(s, 0, __K2L_Utf16.len(s)) <= max then
        return s
    end
    local ____end = __K2L_Utf16.offsetByCodePoints(s, 0, max - 1)
    return __K2L_Text.substring(s, 0, ____end) .. "…"
end

local function displayWidth(s)
    local width = 0
    local i = 0
    while i < __K2L_Utf16.len(s) do
        local cp = __K2L_Utf16.codePointAt(s, i)
        local ____temp
        if cp >= 4352 and cp <= 4447 or cp >= 11904 and cp <= 42191 or cp >= 44032 and cp <= 55203 or cp >= 63744 and cp <= 64255 or cp >= 65280 and cp <= 65376 then
            ____temp = 2
        elseif cp >= 127744 and cp <= 129791 then
            ____temp = 2
        elseif cp >= 768 and cp <= 879 then
            ____temp = 0
        else
            ____temp = 1
        end
        width = width + ____temp
        i = i + (cp >= 65536 and 2 or 1)
    end
    return width
end

local function padDisplay(s, width)
    return s .. __K2L_Text.repeatCount(" ", math.max(width - displayWidth(s), 0))
end

local ____lambda_1 = function(it) return __K2L_Utf16Case.isLetter(it) end
local ____lambda_2 = function(it) return __K2L_Utf16Case.isUpperCase(it) end
local ____lambda_3 = function(it) return __K2L_Utf16Case.isDigit(it) end
local ____lambda_4 = function(it) return __K2L_Utf16Case.isWhitespace(it) end
local ____lambda_5 = function(it) return __K2L_Utf16.isSurrogate(it) end
local function describe(s)
    local letters = __K2L_Text.toList(s):count(____lambda_1)
    local upper = __K2L_Text.toList(s):count(____lambda_2)
    local digits = __K2L_Text.toList(s):count(____lambda_3)
    local spaces = __K2L_Text.toList(s):count(____lambda_4)
    local surrogates = __K2L_Text.toList(s):count(____lambda_5)
    local cps = __K2L_Utf16.codePointCount(s, 0, __K2L_Utf16.len(s))
    return "len=" .. __K2L_Utf16.len(s) .. " cps=" .. cps .. " letters=" .. letters .. " upper=" .. upper .. " digits=" .. digits .. " spaces=" .. spaces .. " surrogates=" .. surrogates
end

local ____lambda_6 = function(it) return __K2L_Utf16Case.titlecase(it) end
local ____lambda_7 = function(w)
    return __K2L_Text.replaceFirstChar(w, ____lambda_6)
end
local ____lambda_8 = function(it)
    return "U+" .. __K2L_Utf16Case.uppercase(__K2L_Num.toRadix(it, 16))
end
local ____lambda_9 = function(it) return __K2L_Utf16Case.lowercase(it.value) end
local ____lambda_10 = function(it) return it end
local ____lambda_11 = function(____a, ____b)
    local ____x_1, ____y_1 = ____b.value, ____a.value
    if ____x_1 ~= ____y_1 then
        return ____x_1 < ____y_1 and -1 or 1
    end
    return __K2L_CompareValues(____a.key, ____b.key)
end
local ____lambda_12 = function(it) return it.key .. "=" .. it.value end
local ____lambda_13 = function(it) return __K2L_Utf16.code(it) > 127 end
local ____lambda_14 = function(it) return __K2L_Utf16.len(it) end
local function main()
    local titles = __K2L_ReadOnlyListOf("Crème brûlée à la française", "Straße & Größe: Ärger über Öl", "Łódź, Kraków — Gdańsk!", "naïve café déjà vu 2024", "Smörgåsbord för 4 personer", "東京タワー 2024 🗼", "Ελληνικά κείμενα", "  Ünïcödé   spaces\t\ttabs  ")
    local ____mod = titles.____modCount
    for ____i = 1, titles.size do
        local t = titles[____i]
        print(__K2L_Utf16.out(padDisplay(truncate(t, 18), 34) .. "|" .. slugify(t)))
        if titles.____modCount ~= ____mod and titles:____comodified(____i) then
            break
        end
    end
    print()
    local ____list = titles:take(4):plus(titles:get(6))
    local ____mod_1 = ____list.____modCount
    for ____i_1 = 1, ____list.size do
        local t = ____list[____i_1]
        print(__K2L_Utf16.out(__K2L_Utf16Case.uppercase(t) .. " / " .. __K2L_Utf16Case.lowercase(t) .. " / " .. __K2L_Utf16.norm(__K2L_StringSplit(t, " "):joinToString(" ", nil, nil, nil, nil, ____lambda_7))))
        if ____list.____modCount ~= ____mod_1 and ____list:____comodified(____i_1) then
            break
        end
    end
    print(__K2L_Utf16.out(__K2L_Utf16Case.uppercase("ß") .. " " .. __K2L_Utf16Case.uppercase("ǆ") .. " " .. __K2L_Utf16Case.titlecase("ǆ") .. " " .. __K2L_Utf16.len(__K2L_Utf16Case.lowercase("İstanbul")) .. " " .. __K2L_Utf16Case.lowercase("ΣΊΣΥΦΟΣ")))
    print()
    local emoji = "I ❤️ Kotlin 🎉🎉 and Lua 🌙! 👩‍💻"
    print(__K2L_Utf16.out(describe(emoji)))
    print(__K2L_Utf16.out(describe(titles:get(5))))
    print(__K2L_Utf16.out(truncate(emoji, 12) .. " | " .. truncate(emoji, 15) .. " | " .. __K2L_Text.reversed(emoji)))
    local cps = __K2L_Utf16.codePoints(emoji):toArray()
    local ____out = {}
    local ____count = 0
    local ____items, ____n = cps:____array()
    for ____i_2 = 1, ____n do
        local it = ____items[____i_2]
        if it > 65535 then
            ____count = ____count + 1
            ____out[____count] = it
        end
    end
    print(__K2L_Utf16.out(__K2L_Utf16.norm(__K2L_ListWrap(____out, ____count):joinToString(" ", nil, nil, nil, nil, ____lambda_8))))
    local ____result = 0
    local ____items_1, ____n_1 = cps:____array()
    for ____i_3 = 1, ____n_1 do
        local it = ____items_1[____i_3]
        if __K2L_Utf16Case.isLetterCp(it) then
            ____result = ____result + 1
        end
    end
    print(__K2L_Utf16.out(tostring(____result) .. " letters by code point, " .. __K2L_Utf16.len(emoji) .. " units"))
    local sb = __K2L_StringBuilder.new("héllo wörld")
    sb:set(0, "H")
    sb:insert(6, "schöne ")
    sb:appendCodePoint(127757)
    sb:deleteCharAt(sb:indexOf("ö"))
    sb:replace(sb:indexOf("w"), sb:indexOf("w") + 1, "W")
    print(__K2L_Utf16.out(__K2L_Str(sb) .. " (" .. sb:getLength() .. " units, last cp " .. __K2L_Str(__K2L_Num.toRadixUnsigned(__K2L_Utf16.codePointBefore(sb:toString(), sb:getLength()), 16)) .. ")"))
    sb:reverse()
    print(__K2L_Utf16.out(__K2L_Str(sb)))
    local text = __K2L_Text.trimIndent("\n        Le cœur a ses raisons que la raison ne connaît point. Où est la cathédrale? À côté du café!\n        L'été, l'été: déjà fini; ÉTÉ, Été — été.\n    ")
    local words = __K2L_Sequence.new(__K2L_Regex.new("[\\p{L}']+"):findAllFactory(text)):map(____lambda_9):toList()
    local freq = words:groupingBy(____lambda_10):eachCount():getEntries():sortedWith(____lambda_11)
    print(__K2L_Utf16.out(__K2L_Utf16.norm(freq:take(6):joinToString(nil, nil, nil, nil, nil, ____lambda_12))))
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_2, ____n_2 = words:____array()
    for ____i_4 = 1, ____n_2 do
        local w = ____items_2[____i_4]
        local ____result_1
        ____result_1 = __K2L_Text.toList(w):any(____lambda_13)
        if ____result_1 then
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = w
        end
    end
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1):distinct():sorted())))
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_3, ____n_3 = words:____array()
    for ____i_5 = 1, ____n_3 do
        local it = ____items_3[____i_5]
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = __K2L_Utf16.len(it)
    end
    print(__K2L_Utf16.out(tostring(__K2L_ListWrap(____out_2, ____count_2):sum()) .. " letters in " .. words.size .. " words; longest: " .. words:maxBy(____lambda_14)))
    print(__K2L_Utf16.out(tostring(__K2L_Num.signInt(__K2L_Text.compare("éa", "ez"))) .. " " .. __K2L_Str(__K2L_ReadOnlyListOf("zebra", "Äpfel", "apple", "École", "eclair"):sorted()) .. " " .. __K2L_Str(__K2L_ReadOnlyListOf("zebra", "Äpfel", "apple", "École", "eclair"):sortedWith(__K2L_Text.caseInsensitiveOrder))))
    print(__K2L_Utf16.out(tostring(__K2L_Utf16Case.equalsIgnoreCase("Ǆemal", "ǆemal")) .. " " .. tostring(__K2L_Utf16Case.equalsIgnoreCase("STRASSE", "straße")) .. " " .. tostring(__K2L_StringContains(__K2L_Utf16Case.fold("ÀB"), __K2L_Utf16Case.fold("àb"))) .. " " .. __K2L_StringIndexOf("Größe", "ö") .. " " .. __K2L_Text.padStart("Größe", 8, "·") .. " " .. __K2L_Text.padEnd("x", 3, "é") .. "|"))
end

main()
return {FOLD = FOLD, slugify = slugify, truncate = truncate, displayWidth = displayWidth, padDisplay = padDisplay, describe = describe}
