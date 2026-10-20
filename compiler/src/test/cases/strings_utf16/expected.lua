local ____lualib = require("lualib_bundle")
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_IndexOutOfBoundsException = ____lualib.__K2L_IndexOutOfBoundsException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_StringIndexOf = ____lualib.__K2L_StringIndexOf
local __K2L_StringLastIndexOf = ____lualib.__K2L_StringLastIndexOf
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf
local __K2L_Utf16 = ____lualib.__K2L_Utf16
local __K2L_Utf16Case = ____lualib.__K2L_Utf16Case

local code0

local ____lambda_1 = function(it)
    return __K2L_Num.toRadix(__K2L_Utf16.code(it), 16)
end
local function hex(s)
    return __K2L_Utf16.norm(__K2L_Text.toList(s):map(____lambda_1):joinToString(" "))
end

local function lengthsAndIndexing()
    local words = __K2L_ReadOnlyListOf("hello", "héllo", "日本語テキスト", "a😀b😀c", "éx", "")
    local ____mod = words.____modCount
    for ____i = 1, words.size do
        local w = words[____i]
        print(__K2L_Utf16.out("'" .. w .. "' length=" .. __K2L_Utf16.len(w) .. " indices=" .. __K2L_Str(__K2L_IntRange.new(0, __K2L_Utf16.len(w) - 1)) .. " lastIndex=" .. __K2L_Utf16.len(w) - 1 .. " empty=" .. tostring(#w == 0)))
        if words.____modCount ~= ____mod and words:____comodified(____i) then
            break
        end
    end
    local s = "a😀b"
    print(__K2L_Utf16.out(hex(s)))
    print(__K2L_Utf16.out(__K2L_Text.get(s, 0)))
    print(__K2L_Utf16.out(__K2L_Text.get(s, 2) == "b"))
    print(__K2L_Utf16.out(__K2L_Utf16.code(__K2L_Text.get(s, 1))))
    print(__K2L_Utf16.out(__K2L_Utf16.code(__K2L_Text.get(s, 2))))
    print(__K2L_Utf16.out(__K2L_Text.get(s, 3)))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Text.getOrNull(s, 4))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Text.getOrNull(s, 2))))
    local ____ok, ____result = __K2L_DeepPcall(function()
        print(__K2L_Utf16.out(__K2L_Text.get(s, 4)))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_IndexOutOfBoundsException) then
            local e = ____error
            print(__K2L_Utf16.out("out of bounds"))
        else
            error(____error, 0)
        end
    end
    print(__K2L_Utf16.out(__K2L_Text.get("日本語", 1)))
    print(__K2L_Utf16.out(__K2L_Text.first("héllo")))
    print(__K2L_Utf16.out(__K2L_Text.last("héllo")))
    print(__K2L_Utf16.out(__K2L_Text.single("é")))
    print(__K2L_Utf16.out(hex("日本語")))
    print(__K2L_Utf16.out(code0("日本語")))
end

function code0(self)
    return __K2L_Utf16.code(__K2L_Text.get(self, 0))
end

local ____lambda_2 = function(it) return it ~= " " end
local ____lambda_3 = function(it) return it ~= " " end
local ____lambda_4 = function(it) return it ~= " " end
local ____lambda_5 = function(it) return it ~= " " end
local function substrings()
    local s = "héllo wörld 日本語 😀!"
    print(__K2L_Utf16.out(__K2L_Utf16.len(s)))
    print(__K2L_Utf16.out(__K2L_Text.substring(s, 1, 4)))
    print(__K2L_Utf16.out(__K2L_Text.substring(s, 12)))
    print(__K2L_Utf16.out(__K2L_Text.substring(s, 12, 15)))
    print(__K2L_Utf16.out(__K2L_Text.substring(s, 16, 18)))
    print(__K2L_Utf16.out(hex(__K2L_Text.substring(s, 16, 17))))
    print(__K2L_Utf16.out(hex(__K2L_Text.substring(s, 17, 18))))
    print(__K2L_Utf16.out(__K2L_Text.substringOf(s, __K2L_IntRange.new(1, 3))))
    print(__K2L_Utf16.out(__K2L_Text.take(s, 3)))
    print(__K2L_Utf16.out(__K2L_Text.drop(s, 12)))
    print(__K2L_Utf16.out(__K2L_Text.takeLast(s, 3)))
    print(__K2L_Utf16.out(__K2L_Text.dropLast(s, 3)))
    print(__K2L_Utf16.out(__K2L_Text.takeWhile(s, ____lambda_2)))
    print(__K2L_Utf16.out(__K2L_Text.dropWhile(s, ____lambda_3)))
    print(__K2L_Utf16.out(__K2L_Text.takeLastWhile(s, ____lambda_4)))
    print(__K2L_Utf16.out(__K2L_Text.dropLastWhile(s, ____lambda_5)))
    print(__K2L_Utf16.out(__K2L_Text.removeRange(s, 1, 5)))
    print(__K2L_Utf16.out(__K2L_Text.replaceRange(s, 0, 5, "HELLO")))
    print(__K2L_Utf16.out(__K2L_Text.slice(s, __K2L_IntRange.new(0, 4))))
    print(__K2L_Utf16.out(__K2L_Text.slice(s, __K2L_ReadOnlyListOf(1, 7, 13))))
    print(__K2L_Utf16.out(__K2L_Text.substringBefore(s, "w")))
    print(__K2L_Utf16.out(__K2L_Text.substringAfter(s, "w")))
    print(__K2L_Utf16.out(__K2L_Text.substringAfterLast(s, " ")))
    print(__K2L_Utf16.out(__K2L_Text.removePrefix(s, "hé")))
    print(__K2L_Utf16.out(__K2L_Text.removeSuffix(s, "😀!")))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Text.chunked(s, 5))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Text.windowed(s, 4, 4, true))))
    print(__K2L_Utf16.out(__K2L_Text.padStart(s, 25, "*")))
    print(__K2L_Utf16.out(__K2L_Text.padEnd(s, 25, "日")))
    print(__K2L_Utf16.out(__K2L_Text.padStart("日本", 5, "-")))
    print(__K2L_Utf16.out(__K2L_Text.reversed(s)))
    print(__K2L_Utf16.out(__K2L_Text.reversed("a😀b")))
    print(__K2L_Utf16.out(__K2L_Utf16.len(__K2L_Text.reversed("a😀b"))))
    print(__K2L_Utf16.out(__K2L_Utf16Case.uppercase("héllo")))
    local ____ok_1, ____result_1 = __K2L_DeepPcall(function()
        __K2L_Text.substring(s, 10, 40)
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error_1, __K2L_IndexOutOfBoundsException) then
            local e = ____error_1
            print(__K2L_Utf16.out("substring failed"))
        else
            error(____error_1, 0)
        end
    end
    print(__K2L_Utf16.out(__K2L_Text.commonPrefixWith(s, "héllo, there")))
    print(__K2L_Utf16.out(__K2L_Text.commonPrefixWith("😀a", "😁a")))
    print(__K2L_Utf16.out(__K2L_Text.commonSuffixWith("a😀", "b😀")))
end

local ____lambda_6 = function(it) return it == "a" end
local function searching()
    local s = "日本語 and 日本語 and 😀 and 😀"
    print(__K2L_Utf16.out(__K2L_StringIndexOf(s, "日本語")))
    print(__K2L_Utf16.out(__K2L_StringIndexOf(s, "日本語", 1)))
    print(__K2L_Utf16.out(__K2L_StringIndexOf(s, "a")))
    print(__K2L_Utf16.out(__K2L_StringIndexOf(s, "and", 10)))
    print(__K2L_Utf16.out(__K2L_StringLastIndexOf(s, "日本語")))
    print(__K2L_Utf16.out(__K2L_StringLastIndexOf(s, "😀")))
    print(__K2L_Utf16.out(__K2L_StringLastIndexOf(s, "and")))
    print(__K2L_Utf16.out(__K2L_StringIndexOf(s, "😀")))
    print(__K2L_Utf16.out(__K2L_StringIndexOf(s, "zzz")))
    print(__K2L_Utf16.out(__K2L_Text.contains(s, "😀")))
    print(__K2L_Utf16.out(__K2L_Text.indexOfAny(s, __K2L_ReadOnlyListOf("and", "😀"))))
    print(__K2L_Utf16.out(__K2L_Text.startsWithAt(s, "本語", 1)))
    print(__K2L_Utf16.out(__K2L_Text.startsWith(s, "本語")))
    print(__K2L_Utf16.out(__K2L_Text.endsWith(s, "😀")))
    print(__K2L_Utf16.out(__K2L_StringReplace(s, "日本語", "X")))
    print(__K2L_Utf16.out(__K2L_StringReplace(s, "and", "&")))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_StringSplit(s, " "))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_StringSplit("日本語", ""))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_StringSplit("a😀", ""))))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_StringSplit("é-😀-x", "-"))))
    print(__K2L_Utf16.out(__K2L_Text.toList(s):count(____lambda_6)))
    print(__K2L_Utf16.out(__K2L_Utf16.len(s)))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_StringLines(s))))
    print(__K2L_Utf16.out(__K2L_Text.regionMatches(s, 0, "日本語 x", 0, 3)))
end

local ____lambda_7 = function(it) return __K2L_Utf16.code(it) end
local function chars()
    for c in __K2L_Utf16.each("aé日😀") do
        print(__K2L_Utf16.out(__K2L_Utf16.norm(c .. " " .. __K2L_Utf16.code(c) .. " " .. tostring(__K2L_Utf16.isSurrogate(c)))))
    end
    print(__K2L_Utf16.out(233))
    print(__K2L_Utf16.out(__K2L_Utf16.char(233)))
    print(__K2L_Utf16.out(__K2L_Utf16.char(26085)))
    print(__K2L_Utf16.out(__K2L_Utf16.char(26085)))
    print(__K2L_Utf16.out(__K2L_Utf16.char(__K2L_Utf16.code("a") + 1)))
    print(__K2L_Utf16.out(__K2L_Utf16.char(__K2L_Utf16.code("é") + 1)))
    print(__K2L_Utf16.out(__K2L_Utf16.code("é") - __K2L_Utf16.code("a")))
    print(__K2L_Utf16.out(__K2L_Utf16.code("日") - __K2L_Utf16.code("本")))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Utf16.CharRange.new("a", "e"):toList())))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Utf16.CharRange.new("à", "å"):toList())))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Utf16.CharRange.new("à", "å"):map(____lambda_7))))
    print(__K2L_Utf16.out("é" >= "a" and "é" <= "z"))
    print(__K2L_Utf16.out("é" >= "a" and "é" <= "ÿ"))
    for ____code = __K2L_Utf16.code("α"), __K2L_Utf16.code("ε") do
        local c = __K2L_Utf16.char(____code)
        io.write(__K2L_Utf16.out(c))
    end
    print()
    for ____code_1 = __K2L_Utf16.code("ε"), __K2L_Utf16.code("α"), -1 do
        local c = __K2L_Utf16.char(____code_1)
        io.write(__K2L_Utf16.out(c))
    end
    print()
    local c = "é"
    c = __K2L_Utf16.char(__K2L_Utf16.code(c) + 1)
    print(__K2L_Utf16.out(c))
    c = __K2L_Utf16.char(__K2L_Utf16.code(c) - 1)
    c = __K2L_Utf16.char(__K2L_Utf16.code(c) - 1)
    print(__K2L_Utf16.out(c))
    print(__K2L_Utf16.out(__K2L_Utf16.norm("日" .. "本")))
    print(__K2L_Utf16.out(__K2L_Utf16.norm(__K2L_Utf16.norm("" .. "é") .. "日")))
    print(__K2L_Utf16.out("é" < "z"))
    print(__K2L_Utf16.out("é" > "z"))
    print(__K2L_Utf16.out(__K2L_Compare("é", "a")))
    print(__K2L_Utf16.out(__K2L_Text.compare("é", "a")))
    print(__K2L_Utf16.out(__K2L_Text.compare("日", "本")))
    print(__K2L_Utf16.out(__K2L_Text.compare("abc", "abd")))
    print(__K2L_Utf16.out(__K2L_Text.compare("a", "abc")))
end

local function builders()
    local sb = __K2L_StringBuilder.new("a😀b")
    print(__K2L_Utf16.out(sb:getLength()))
    sb:insert(1, "é")
    print(__K2L_Utf16.out(__K2L_Str(sb)))
    print(__K2L_Utf16.out(sb:getLength()))
    sb:set(0, "z")
    print(__K2L_Utf16.out(__K2L_Str(sb)))
    sb:deleteCharAt(1)
    print(__K2L_Utf16.out(__K2L_Str(sb)))
    sb:append("日"):append("本"):append(tostring(1))
    print(__K2L_Utf16.out(__K2L_Str(sb)))
    print(__K2L_Utf16.out(sb:getLength()))
    print(__K2L_Utf16.out(__K2L_Str(sb:reverse())))
    print(__K2L_Utf16.out(sb:get(0)))
    print(__K2L_Utf16.out(sb:indexOf("日")))
    print(__K2L_Utf16.out(__K2L_Str(sb:substring(1, 3))))
    sb:setLength(2)
    print(__K2L_Utf16.out(__K2L_Str(sb)))
    sb:delete(0, 1)
    print(__K2L_Utf16.out(__K2L_Str(sb)))
    sb:replace(0, 1, "ÿÿ")
    print(__K2L_Utf16.out(__K2L_Str(sb)))
    print(__K2L_Utf16.out(__K2L_Utf16.len(sb:toString())))
    local ____builder = __K2L_StringBuilder.new()
    ____builder:append("é")
    ____builder:append("日")
    ____builder:append("😀")
    ____builder:appendLine(tostring(____builder:getLength()))
    local built = ____builder:toString()
    io.write(__K2L_Utf16.out(built))
    local parts = __K2L_StringBuilder.new()
    local emoji = "😀"
    parts:append(__K2L_Text.get(emoji, 0)):append(__K2L_Text.get(emoji, 1))
    print(__K2L_Utf16.out(__K2L_Str(parts)))
    print(__K2L_Utf16.out(parts:getLength()))
    print(__K2L_Utf16.out(parts:toString() == emoji))
end

local ____lambda_8 = function(it) return __K2L_Utf16.code(it) end
local ____lambda_9 = function(it) return it ~= "x" end
local ____lambda_10 = function(it) return __K2L_Utf16.code(it) < 128 end
local ____lambda_11 = function(it) return __K2L_Utf16.code(it) < 128 end
local ____lambda_12 = function(it) return it end
local function templatesAndConversion()
    local s = "x😀y"
    print(__K2L_Utf16.out(__K2L_Utf16.norm(__K2L_Utf16.len(s) .. " " .. __K2L_Utf16.code(__K2L_Text.get(s, 1)) .. " " .. __K2L_Text.first(s) .. __K2L_Text.last(s))))
    local hi = __K2L_Text.get(s, 1)
    local lo = __K2L_Text.get(s, 2)
    print(__K2L_Utf16.out(__K2L_Utf16.norm(hi .. lo)))
    print(__K2L_Utf16.out(__K2L_Utf16.norm(__K2L_Utf16.norm("" .. hi) .. lo)))
    print(__K2L_Utf16.out(__K2L_Utf16.norm(hi .. lo)))
    print(__K2L_Utf16.out(__K2L_Utf16.norm(hi .. lo) == "😀"))
    print(__K2L_Utf16.out(__K2L_Text.toCharArray(s).size))
    print(__K2L_Utf16.out(__K2L_Text.string(__K2L_Text.toCharArray(s))))
    print(__K2L_Utf16.out(__K2L_Utf16.norm(__K2L_Text.toCharArray(s):joinToString(""))))
    print(__K2L_Utf16.out(__K2L_Text.toList(s).size))
    print(__K2L_Utf16.out(__K2L_Text.toList(s):map(____lambda_8).size))
    print(__K2L_Utf16.out(__K2L_Text.string(__K2L_TypedArrayOf("[C", "é", "日"))))
    print(__K2L_Utf16.out(__K2L_Text.filter(s, ____lambda_9)))
    print(__K2L_Utf16.out(__K2L_Text.filter(s, ____lambda_10)))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Text.partition(s, ____lambda_11))))
    print(__K2L_Utf16.out(__K2L_Utf16.len(__K2L_Utf16.norm(__K2L_Text.toList(s):map(____lambda_12):joinToString("|")))))
    print(__K2L_Utf16.out(__K2L_Text.toList(s):zip(__K2L_Text.toList("ab")).size))
end

local function ordering()
    local items = __K2L_ReadOnlyListOf("￿", "😀", "z", "é", "日", "", "𝄞")
    local ____list = items:sorted()
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i_1 = 1, ____n do
        local it = ____items[____i_1]
        ____count = ____count + 1
        ____out[____count] = hex(it)
    end
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ListWrap(____out, ____count))))
    local ____list_1 = items:sortedDescending()
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_2 = 1, ____n_1 do
        local it = ____items_1[____i_2]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = __K2L_Utf16.len(it)
    end
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1))))
    print(__K2L_Utf16.out(__K2L_Compare("😀", "￿") < 0))
    print(__K2L_Utf16.out(__K2L_Text.compare("😀", "￿") < 0))
    local ____receiver = items:maxOrNull()
    print(__K2L_Utf16.out(__K2L_Str(____receiver and __K2L_Utf16.len(____receiver))))
    local ____receiver_1 = items:minOrNull()
    print(__K2L_Utf16.out(__K2L_Str(____receiver_1 and __K2L_Utf16.len(____receiver_1))))
    print(__K2L_Utf16.out(__K2L_Utf16Case.equalsIgnoreCase("a", "A")))
    local map = __K2L_HashMap.new()
    local ____list_2 = __K2L_ReadOnlyListOf("héllo", "日本語", "😀", "wörld", "zebra", "café", "ñandú")
    for i = 0, ____list_2.size - 1 do
        local w = ____list_2[i + 1]
        map:set(w, i)
    end
    print(__K2L_Utf16.out(__K2L_Str(map)))
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ReadOnlySetOf("é", "日", "😀", "ab"):toList())))
    local ____list_3 = __K2L_ReadOnlyListOf("héllo", "日本語", "😀")
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_2, ____n_2 = ____list_3:____array()
    for ____i_3 = 1, ____n_2 do
        local it = ____items_2[____i_3]
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = __K2L_Hash(it)
    end
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ListWrap(____out_2, ____count_2))))
    print(__K2L_Utf16.out(__K2L_Hash("é")))
    print(__K2L_Utf16.out(__K2L_Hash("😀")))
    print(__K2L_Utf16.out(__K2L_Hash("日本語テキスト")))
    print(__K2L_Utf16.out(__K2L_Hash("")))
end

local function formatting()
    print(__K2L_Utf16.out(__K2L_StringFormat("%5s|%-5s|", "é", "日")))
    print(__K2L_Utf16.out(__K2L_StringFormat("%.2s|", "日本語")))
    print(__K2L_Utf16.out(__K2L_StringFormat("%3s|%-3s|", "😀", "😀")))
    print(__K2L_Utf16.out(__K2L_StringFormat("%s has %d chars", "日本語", __K2L_Utf16.len("日本語"))))
end

local function main()
    lengthsAndIndexing()
    substrings()
    searching()
    chars()
    builders()
    templatesAndConversion()
    ordering()
    formatting()
end

__K2L_DeepMain(main)
return {hex = hex, lengthsAndIndexing = lengthsAndIndexing, code0 = code0, substrings = substrings, searching = searching, chars = chars, builders = builders, templatesAndConversion = templatesAndConversion, ordering = ordering, formatting = formatting}
