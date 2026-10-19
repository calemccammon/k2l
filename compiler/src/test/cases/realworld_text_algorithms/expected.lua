local ____lualib = require("lualib_bundle")
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_GenerateSequence = ____lualib.__K2L_GenerateSequence
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IRem = ____lualib.__K2L_IRem
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringCharAt = ____lualib.__K2L_StringCharAt
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringEqualsIgnoreCase = ____lualib.__K2L_StringEqualsIgnoreCase
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_StringIndexOf = ____lualib.__K2L_StringIndexOf
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ThenByDescending = ____lualib.__K2L_ThenByDescending

local swapCase

local function kmpTable(p)
    local fail = __K2L_ListOfSize(#p, 0, "[I")
    local k = 0
    for i = 1, #p - 1 do
        while k > 0 and __K2L_StringCharAt(p, i) ~= __K2L_StringCharAt(p, k) do
            k = fail:get(k - 1)
        end
        if __K2L_StringCharAt(p, i) == __K2L_StringCharAt(p, k) then
            k = k + 1
        end
        fail:set(i, k)
    end
    return fail
end

local function kmpSearch(text, p)
    local fail = kmpTable(p)
    local hits = __K2L_ListOf()
    local k = 0
    local ____collection = __K2L_StringToList(text):withIndex()
    local ____items, ____n = ____collection:____array()
    local ____mod = ____collection.____modCount
    for ____i = 1, ____n do
        local ____item = ____items[____i]
        local i, c = ____item.index, ____item.value
        while k > 0 and c ~= __K2L_StringCharAt(p, k) do
            k = fail:get(k - 1)
        end
        if c == __K2L_StringCharAt(p, k) then
            k = k + 1
        end
        if k == #p then
            hits:add(i - k + 1)
            k = fail:get(k - 1)
        end
        if ____collection.____modCount ~= ____mod and ____collection:____comodified(____i, ____n) then
            break
        end
    end
    return hits
end

local function rabinKarp(text, p, base, mod)
    if base == nil then
        base = 256
    end
    if mod == nil then
        mod = 1000000007
    end
    if #p > #text then
        return __K2L_ReadOnlyListOf()
    end
    local high = 1
    for it = 0, #p - 1 - 1 do
        high = __K2L_IRem(high * base, mod)
    end
    local hp = 0
    local ht = 0
    local ____range = __K2L_IntRange.new(0, #p - 1)
    for i = ____range.first, ____range.last, ____range.step do
        hp = __K2L_IRem(hp * base + p:sub(i + 1, i + 1):byte(), mod)
        ht = __K2L_IRem(ht * base + __K2L_StringCharAt(text, i):byte(), mod)
    end
    local hits = __K2L_ListOf()
    for i = 0, #text - #p do
        if hp == ht and __K2L_Text.regionMatches(text, i, p, 0, #p) then
            hits:add(i)
        end
        if i + #p < #text then
            ht = __K2L_IRem((ht - __K2L_IRem(__K2L_StringCharAt(text, i):byte() * high, mod) + mod) * base + __K2L_StringCharAt(text, i + #p):byte(), mod)
        end
    end
    return hits
end

local function zFunction(s)
    local z = __K2L_ListOfSize(#s, 0, "[I")
    local l = 0
    local r = 0
    for i = 1, #s - 1 do
        if i < r then
            z:set(i, math.min(r - i, z:get(i - l)))
        end
        while i + z:get(i) < #s and __K2L_StringCharAt(s, z:get(i)) == __K2L_StringCharAt(s, i + z:get(i)) do
            z:set(i, z:get(i) + 1)
        end
        if i + z:get(i) > r then
            l = i
            r = i + z:get(i)
        end
    end
    return z
end

local function levenshtein(a, b)
    local d = __K2L_ListOfSize(#a + 1, function(it) return __K2L_ListOfSize(#b + 1, 0, "[I") end, "[[I")
    for i = 0, #a do
        local ____object = d:get(i)
        ____object:set(0, i)
    end
    for j = 0, #b do
        local ____object_1 = d:get(0)
        ____object_1:set(j, j)
    end
    for i = 1, #a do
        for j = 1, #b do
            local cost = __K2L_StringEqualsIgnoreCase(__K2L_StringCharAt(a, i - 1), __K2L_StringCharAt(b, j - 1)) and 0 or 1
            local ____object_2 = d:get(i)
            ____object_2:set(j, math.min(d:get(i - 1):get(j) + 1, d:get(i):get(j - 1) + 1, d:get(i - 1):get(j - 1) + cost))
        end
    end
    local script = __K2L_StringBuilder.new()
    local i = #a
    local j = #b
    while i > 0 or j > 0 do
        if i > 0 and j > 0 and d:get(i):get(j) == d:get(i - 1):get(j - 1) + (__K2L_StringEqualsIgnoreCase(__K2L_StringCharAt(a, i - 1), __K2L_StringCharAt(b, j - 1)) and 0 or 1) then
            script:append(__K2L_StringEqualsIgnoreCase(__K2L_StringCharAt(a, i - 1), __K2L_StringCharAt(b, j - 1)) and "=" or "~")
            i = i - 1
            j = j - 1
        elseif i > 0 and d:get(i):get(j) == d:get(i - 1):get(j) + 1 then
            script:append("-")
            i = i - 1
        else
            script:append("+")
            j = j - 1
        end
    end
    return __K2L_Pair.new(d:get(#a):get(#b), script:reverse():toString())
end

local function lcs(a, b)
    local dp = __K2L_ListOfSize(#a + 1, function(it) return __K2L_ListOfSize(#b + 1, 0, "[I") end, "[[I")
    local ____range_1 = __K2L_IntRange.new(0, #a - 1):reversed()
    for i = ____range_1.first, ____range_1.last, ____range_1.step do
        local ____range_2 = __K2L_IntRange.new(0, #b - 1):reversed()
        for j = ____range_2.first, ____range_2.last, ____range_2.step do
            local ____object_3 = dp:get(i)
            ____object_3:set(j, __K2L_StringCharAt(a, i) == __K2L_StringCharAt(b, j) and dp:get(i + 1):get(j + 1) + 1 or math.max(dp:get(i + 1):get(j), dp:get(i):get(j + 1)))
        end
    end
    local sb = __K2L_StringBuilder.new()
    local i = 0
    local j = 0
    while i < #a and j < #b do
        if __K2L_StringCharAt(a, i) == __K2L_StringCharAt(b, j) then
            sb:append(__K2L_StringCharAt(a, i))
            i = i + 1
            j = j + 1
        elseif dp:get(i + 1):get(j) >= dp:get(i):get(j + 1) then
            i = i + 1
        else
            j = j + 1
        end
    end
    return sb:toString()
end

local function suffixArray(s)
    return __K2L_IntRange.new(0, #s - 1):sortedWith(function(x, y)
        return __K2L_Text.compare(__K2L_Text.substring(s, x), __K2L_Text.substring(s, y))
    end)
end

local function lcpArray(s, sa)
    local rank = __K2L_ListOfSize(#s, 0, "[I")
    local ____mod_1 = sa.____modCount
    for ____i_1 = 1, sa.size do
        local p = sa[____i_1]
        local i = ____i_1 - 1
        rank:set(p, i)
        if sa.____modCount ~= ____mod_1 and sa:____comodified(____i_1) then
            break
        end
    end
    local lcp = __K2L_ListOfSize(#s, 0, "[I")
    local h = 0
    local ____range_3 = __K2L_IntRange.new(0, #s - 1)
    for i = ____range_3.first, ____range_3.last, ____range_3.step do
        if rank:get(i) > 0 then
            local j = sa:get(rank:get(i) - 1)
            while i + h < #s and j + h < #s and __K2L_StringCharAt(s, i + h) == __K2L_StringCharAt(s, j + h) do
                h = h + 1
            end
            local ____key = rank:get(i)
            lcp:set(____key, h)
            if h > 0 then
                h = h - 1
            end
        else
            h = 0
        end
    end
    return lcp
end

local function longestPalindrome(s)
    local t = __K2L_Text.toCharArray(s):joinToString("#", "^#", "#$")
    local p = __K2L_ListOfSize(#t, 0, "[I")
    local center = 0
    local right = 0
    for i = 1, #t - 1 - 1 do
        if i < right then
            p:set(i, math.min(right - i, p:get(2 * center - i)))
        end
        while __K2L_StringCharAt(t, i + 1 + p:get(i)) == __K2L_StringCharAt(t, i - 1 - p:get(i)) do
            p:set(i, p:get(i) + 1)
        end
        if i + p:get(i) > right then
            center = i
            right = i + p:get(i)
        end
    end
    local ____value = p:withIndex():maxBy(function(it) return it.value end)
    local ____destructured = __K2L_Pair.new(____value.value, ____value.index)
    local len, c = ____destructured.first, ____destructured.second
    local start = __K2L_IDiv(c - len, 2)
    return __K2L_Text.substring(s, start, start + len)
end

local function surgery()
    local sb = __K2L_StringBuilder.new("Hello, World")
    sb:insert(0, ">> "):insert(sb:getLength(), "!"):insert(8, tostring(123)):insert(3, __K2L_Str(4.5)):insert(3, tostring(true))
    print(__K2L_Str(sb))
    sb:set(0, "<")
    sb:deleteCharAt(1)
    sb:delete(2, 9)
    sb:replace(0, 2, "[["):append("]"):append("]")
    print(__K2L_Str(sb) .. " len=" .. sb:getLength() .. " idx=" .. sb:indexOf("o") .. " last=" .. sb:lastIndexOf("o") .. " char=" .. sb:get(3) .. " sub=" .. __K2L_Str(sb:substring(2, 6)))
    sb:reverse()
    print(__K2L_Str(sb))
    sb:setLength(5)
    print("'" .. __K2L_Str(sb) .. "' " .. tostring(sb:isEmpty()) .. " " .. sb:toString():upper() .. " " .. tostring(__K2L_StringContains(sb:toString(), "d")))
    sb:clear()
    for i = 1, 5 do
        sb:append(tostring(i)):append(i < 5 and "," or "")
    end
    print(__K2L_Str(sb:toString():reverse()))
    local words = __K2L_StringSplit("the quick brown fox jumps over the lazy dog", " ")
    local capitalized = words:joinToString(" ", nil, nil, nil, nil, function(w)
        return __K2L_Text.replaceFirstChar(w, function(it) return it:upper() end)
    end)
    print(capitalized)
    print(words:map(function(it) return it:reverse() end):joinToString(" ") .. " | " .. words:reversed():joinToString(" "))
    print(__K2L_Text.filter(capitalized, function(it) return it:match("^%u$") ~= nil end) .. " " .. __K2L_StringToList(capitalized):count(function(it) return it:match("^%l$") ~= nil end) .. " " .. swapCase(capitalized))
end

function swapCase(self)
    return __K2L_StringToList(self):map(function(it)
        return it:match("^%u$") ~= nil and it:lower() or it:upper()
    end):joinToString("")
end

local function main()
    local text = "abracadabra abracadabra cadabra"
    local ____list = __K2L_ReadOnlyListOf("abra", "cad", "a", "zzz", "abracadabra c")
    for ____i_2 = 1, ____list.size do
        local p = ____list[____i_2]
        local k = kmpSearch(text, p)
        local r = rabinKarp(text, p)
        local builtin = __K2L_GenerateSequence(__K2L_StringIndexOf(text, p), function(prev)
            local ____value_1 = __K2L_StringIndexOf(text, p, prev + 1)
            return ____value_1 >= 0 and ____value_1 or nil
        end):takeWhile(function(it) return it >= 0 end):toList()
        print("'" .. p .. "': kmp=" .. __K2L_Str(k) .. " rk=" .. __K2L_Str(r) .. " same=" .. tostring(__K2L_Equals(k, r) and __K2L_Equals(r, builtin)))
    end
    print("kmp table of 'aabaaab': " .. kmpTable("aabaaab"):joinToString())
    print("z of 'aaabaab': " .. zFunction("aaabaab"):contentToString())
    local ____list_1 = __K2L_ReadOnlyListOf(__K2L_Pair.new("kitten", "sitting"), __K2L_Pair.new("Saturday", "sunday"), __K2L_Pair.new("", "abc"), __K2L_Pair.new("flaw", "lawn"), __K2L_Pair.new("same", "SAME"))
    for ____i_3 = 1, ____list_1.size do
        local ____item_1 = ____list_1[____i_3]
        local a, b = ____item_1.first, ____item_1.second
        local ____destructured_1 = levenshtein(a, b)
        local dist, script = ____destructured_1.first, ____destructured_1.second
        print("lev('" .. a .. "', '" .. b .. "') = " .. dist .. "  " .. script .. "  lcs='" .. lcs(a:lower(), b:lower()) .. "'")
    end
    local banana = "banana"
    local sa = suffixArray(banana)
    local lcp = lcpArray(banana, sa)
    local ____mod_2 = sa.____modCount
    for ____i_4 = 1, sa.size do
        local p = sa[____i_4]
        local i = ____i_4 - 1
        print(__K2L_StringFormat("%2d %d %-7s lcp=%d", i, p, __K2L_Text.substring(banana, p), lcp:get(i)))
        if sa.____modCount ~= ____mod_2 and sa:____comodified(____i_4) then
            break
        end
    end
    local ____value_2 = lcp:withIndex():maxBy(function(it) return it.value end)
    local longestRepeat = __K2L_Text.substring(banana, sa:get(____value_2.index), sa:get(____value_2.index) + ____value_2.value)
    print("longest repeated substring: " .. longestRepeat)
    local ____list_2 = __K2L_ReadOnlyListOf("babad", "forgeeksskeegfor", "a", "abacdfgdcaba", "racecar level")
    for ____i_5 = 1, ____list_2.size do
        local s = ____list_2[____i_5]
        print("palindrome(" .. s .. ") = " .. longestPalindrome(s))
    end
    local words = __K2L_ReadOnlyListOf("listen", "silent", "enlist", "google", "gooegl", "cat", "act", "tac", "dog", "Inlets")
    local groups = words:groupBy(function(it)
        return __K2L_Text.toCharArray(it:lower()):sorted():joinToString("")
    end)
    local ____collection_1 = groups:filterValues(function(it) return it.size > 1 end):toSortedMap()
    local ____items_1, ____n_1 = ____collection_1:____entryArray()
    local ____mod_3 = ____collection_1.____modCount
    for ____i_6 = 1, ____n_1 do
        local ____entry = ____items_1[____i_6]
        do
            local k, v = ____entry.key, ____entry.value
            print(__K2L_Str(k) .. " -> " .. __K2L_Str(v:sorted()))
        end
        if ____collection_1.____modCount ~= ____mod_3 and ____collection_1:____comodified(____i_6, ____n_1) then
            break
        end
    end
    print(words:sortedWith(__K2L_ThenByDescending(__K2L_CompareBy(function(it) return #it end), function(it) return it end)):joinToString())
    print(__K2L_Str(words:map(function(it) return it:lower() end):sortedWith(__K2L_Text.caseInsensitiveOrder):distinct():chunked(4)))
    surgery()
end

main()
return {kmpTable = kmpTable, kmpSearch = kmpSearch, rabinKarp = rabinKarp, zFunction = zFunction, levenshtein = levenshtein, lcs = lcs, suffixArray = suffixArray, lcpArray = lcpArray, longestPalindrome = longestPalindrome, surgery = surgery, swapCase = swapCase}
