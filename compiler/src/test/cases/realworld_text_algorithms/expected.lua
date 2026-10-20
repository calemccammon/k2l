local ____lualib = require("lualib_bundle")
local __K2L_CompareValues = ____lualib.__K2L_CompareValues
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Fmod = ____lualib.__K2L_Fmod
local __K2L_GenerateSequence = ____lualib.__K2L_GenerateSequence
local __K2L_IRem = ____lualib.__K2L_IRem
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_IsLowerCase = ____lualib.__K2L_IsLowerCase
local __K2L_IsUpperCase = ____lualib.__K2L_IsUpperCase
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_LoopItems = ____lualib.__K2L_LoopItems
local __K2L_Map = ____lualib.__K2L_Map
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

local swapCase

local function kmpTable(p)
    local fail = __K2L_ListOfSize(#p, 0, "[I")
    local k = 0
    for i = 1, #p - 1 do
        while k > 0 and (i >= 0 and i < #p and p:sub(i + 1, i + 1) or __K2L_IndexError(i, #p, "string")) ~= (k >= 0 and k < #p and p:sub(k + 1, k + 1) or __K2L_IndexError(k, #p, "string")) do
            k = fail[k] or __K2L_IndexError(k - 1, fail.size, "array")
        end
        if (i >= 0 and i < #p and p:sub(i + 1, i + 1) or __K2L_IndexError(i, #p, "string")) == (k >= 0 and k < #p and p:sub(k + 1, k + 1) or __K2L_IndexError(k, #p, "string")) then
            k = k + 1
        end
        if i < 0 or i >= fail.size then
            __K2L_IndexError(i, fail.size, "array")
        end
        fail[i + 1] = k
    end
    return fail
end

local function kmpSearch(text, p)
    local fail = kmpTable(p)
    local hits = __K2L_ListOf()
    local k = 0
    local ____collection = __K2L_StringToList(text):withIndex()
    local ____items, ____n = __K2L_LoopItems(____collection)
    local ____mod = ____collection.____modCount
    for ____i = 1, ____n do
        local ____item = ____items[____i]
        local i, c = ____item.index, ____item.value
        while k > 0 and c ~= (k >= 0 and k < #p and p:sub(k + 1, k + 1) or __K2L_IndexError(k, #p, "string")) do
            k = fail[k] or __K2L_IndexError(k - 1, fail.size, "array")
        end
        if c == (k >= 0 and k < #p and p:sub(k + 1, k + 1) or __K2L_IndexError(k, #p, "string")) then
            k = k + 1
        end
        if k == #p then
            hits:add(i - k + 1)
            k = fail[k] or __K2L_IndexError(k - 1, fail.size, "array")
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
        high = mod ~= 0 and __K2L_Fmod(high * base, mod) + 0 or __K2L_IRem(high * base, mod)
    end
    local hp = 0
    local ht = 0
    local ____range = __K2L_IntRange.new(0, #p - 1)
    for i = ____range.first, ____range.last, ____range.step do
        hp = __K2L_IRem(hp * base + p:sub(i + 1, i + 1):byte(), mod)
        ht = __K2L_IRem(ht * base + (i >= 0 and i < #text and text:sub(i + 1, i + 1) or __K2L_IndexError(i, #text, "string")):byte(), mod)
    end
    local hits = __K2L_ListOf()
    for i = 0, #text - #p do
        if hp == ht and __K2L_Text.regionMatches(text, i, p, 0, #p) then
            hits:add(i)
        end
        if i + #p < #text then
            ht = __K2L_IRem((ht - __K2L_IRem((i >= 0 and i < #text and text:sub(i + 1, i + 1) or __K2L_IndexError(i, #text, "string")):byte() * high, mod) + mod) * base + __K2L_StringCharAt(text, i + #p):byte(), mod)
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
            local ____value = math.min(r - i, z[i - l + 1] or __K2L_IndexError(i - l, z.size, "array"))
            if i < 0 or i >= z.size then
                __K2L_IndexError(i, z.size, "array")
            end
            z[i + 1] = ____value
        end
        while i + (z[i + 1] or __K2L_IndexError(i, z.size, "array")) < #s and __K2L_StringCharAt(s, z[i + 1] or __K2L_IndexError(i, z.size, "array")) == __K2L_StringCharAt(s, i + (z[i + 1] or __K2L_IndexError(i, z.size, "array"))) do
            z[i + 1] = (z[i + 1] or __K2L_IndexError(i, z.size, "array")) + 1
        end
        if i + (z[i + 1] or __K2L_IndexError(i, z.size, "array")) > r then
            l = i
            r = i + (z[i + 1] or __K2L_IndexError(i, z.size, "array"))
        end
    end
    return z
end

local function levenshtein(a, b)
    local d = __K2L_ListOfSize(#a + 1, function(it) return __K2L_ListOfSize(#b + 1, 0, "[I") end, "[[I")
    for i = 0, #a do
        local ____object = d[i + 1] or __K2L_IndexError(i, d.size, "array")
        if 0 < 0 or 0 >= ____object.size then
            __K2L_IndexError(0, ____object.size, "array")
        end
        ____object[1] = i
    end
    for j = 0, #b do
        local ____object_1 = d[1] or __K2L_IndexError(0, d.size, "array")
        if j < 0 or j >= ____object_1.size then
            __K2L_IndexError(j, ____object_1.size, "array")
        end
        ____object_1[j + 1] = j
    end
    for i = 1, #a do
        for j = 1, #b do
            local cost = __K2L_StringEqualsIgnoreCase(i - 1 >= 0 and i - 1 < #a and a:sub(i - 1 + 1, i - 1 + 1) or __K2L_IndexError(i - 1, #a, "string"), j - 1 >= 0 and j - 1 < #b and b:sub(j - 1 + 1, j - 1 + 1) or __K2L_IndexError(j - 1, #b, "string")) and 0 or 1
            local ____object_2 = d[i + 1] or __K2L_IndexError(i, d.size, "array")
            local ____value_1 = math.min((d[i] or __K2L_IndexError(i - 1, d.size, "array")):get(j) + 1, (d[i + 1] or __K2L_IndexError(i, d.size, "array")):get(j - 1) + 1, (d[i] or __K2L_IndexError(i - 1, d.size, "array")):get(j - 1) + cost)
            if j < 0 or j >= ____object_2.size then
                __K2L_IndexError(j, ____object_2.size, "array")
            end
            ____object_2[j + 1] = ____value_1
        end
    end
    local script = __K2L_StringBuilder.new()
    local i = #a
    local j = #b
    while i > 0 or j > 0 do
        if i > 0 and j > 0 and (d[i + 1] or __K2L_IndexError(i, d.size, "array")):get(j) == (d[i] or __K2L_IndexError(i - 1, d.size, "array")):get(j - 1) + (__K2L_StringEqualsIgnoreCase(i - 1 >= 0 and i - 1 < #a and a:sub(i - 1 + 1, i - 1 + 1) or __K2L_IndexError(i - 1, #a, "string"), j - 1 >= 0 and j - 1 < #b and b:sub(j - 1 + 1, j - 1 + 1) or __K2L_IndexError(j - 1, #b, "string")) and 0 or 1) then
            script:append(__K2L_StringEqualsIgnoreCase(i - 1 >= 0 and i - 1 < #a and a:sub(i - 1 + 1, i - 1 + 1) or __K2L_IndexError(i - 1, #a, "string"), j - 1 >= 0 and j - 1 < #b and b:sub(j - 1 + 1, j - 1 + 1) or __K2L_IndexError(j - 1, #b, "string")) and "=" or "~")
            i = i - 1
            j = j - 1
        elseif i > 0 and (d[i + 1] or __K2L_IndexError(i, d.size, "array")):get(j) == (d[i] or __K2L_IndexError(i - 1, d.size, "array")):get(j) + 1 then
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
            local ____object_3 = dp[i + 1] or __K2L_IndexError(i, dp.size, "array")
            local ____value_2 = (i >= 0 and i < #a and a:sub(i + 1, i + 1) or __K2L_IndexError(i, #a, "string")) == (j >= 0 and j < #b and b:sub(j + 1, j + 1) or __K2L_IndexError(j, #b, "string")) and (dp[i + 1 + 1] or __K2L_IndexError(i + 1, dp.size, "array")):get(j + 1) + 1 or math.max((dp[i + 1 + 1] or __K2L_IndexError(i + 1, dp.size, "array")):get(j), (dp[i + 1] or __K2L_IndexError(i, dp.size, "array")):get(j + 1))
            if j < 0 or j >= ____object_3.size then
                __K2L_IndexError(j, ____object_3.size, "array")
            end
            ____object_3[j + 1] = ____value_2
        end
    end
    local sb = __K2L_StringBuilder.new()
    local i = 0
    local j = 0
    while i < #a and j < #b do
        if (i >= 0 and i < #a and a:sub(i + 1, i + 1) or __K2L_IndexError(i, #a, "string")) == (j >= 0 and j < #b and b:sub(j + 1, j + 1) or __K2L_IndexError(j, #b, "string")) then
            sb:append(i >= 0 and i < #a and a:sub(i + 1, i + 1) or __K2L_IndexError(i, #a, "string"))
            i = i + 1
            j = j + 1
        elseif (dp[i + 1 + 1] or __K2L_IndexError(i + 1, dp.size, "array")):get(j) >= (dp[i + 1] or __K2L_IndexError(i, dp.size, "array")):get(j + 1) then
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
        if p < 0 or p >= rank.size then
            __K2L_IndexError(p, rank.size, "array")
        end
        rank[p + 1] = i
        if sa.____modCount ~= ____mod_1 and sa:____comodified(____i_1) then
            break
        end
    end
    local lcp = __K2L_ListOfSize(#s, 0, "[I")
    local h = 0
    local ____range_3 = __K2L_IntRange.new(0, #s - 1)
    for i = ____range_3.first, ____range_3.last, ____range_3.step do
        if (rank[i + 1] or __K2L_IndexError(i, rank.size, "array")) > 0 then
            local j = sa:get((rank[i + 1] or __K2L_IndexError(i, rank.size, "array")) - 1)
            while i + h < #s and j + h < #s and (i + h >= 0 and i + h < #s and s:sub(i + h + 1, i + h + 1) or __K2L_IndexError(i + h, #s, "string")) == (j + h >= 0 and j + h < #s and s:sub(j + h + 1, j + h + 1) or __K2L_IndexError(j + h, #s, "string")) do
                h = h + 1
            end
            local ____key = rank[i + 1] or __K2L_IndexError(i, rank.size, "array")
            if ____key < 0 or ____key >= lcp.size then
                __K2L_IndexError(____key, lcp.size, "array")
            end
            lcp[____key + 1] = h
            if h > 0 then
                h = h - 1
            end
        else
            h = 0
        end
    end
    return lcp
end

local ____lambda_1 = function(it) return it.value end
local function longestPalindrome(s)
    local t = __K2L_Text.toCharArray(s):joinToString("#", "^#", "#$")
    local p = __K2L_ListOfSize(#t, 0, "[I")
    local center = 0
    local right = 0
    for i = 1, #t - 1 - 1 do
        if i < right then
            local ____value_3 = math.min(right - i, p[2 * center - i + 1] or __K2L_IndexError(2 * center - i, p.size, "array"))
            if i < 0 or i >= p.size then
                __K2L_IndexError(i, p.size, "array")
            end
            p[i + 1] = ____value_3
        end
        while __K2L_StringCharAt(t, i + 1 + (p[i + 1] or __K2L_IndexError(i, p.size, "array"))) == __K2L_StringCharAt(t, i - 1 - (p[i + 1] or __K2L_IndexError(i, p.size, "array"))) do
            p[i + 1] = (p[i + 1] or __K2L_IndexError(i, p.size, "array")) + 1
        end
        if i + (p[i + 1] or __K2L_IndexError(i, p.size, "array")) > right then
            center = i
            right = i + (p[i + 1] or __K2L_IndexError(i, p.size, "array"))
        end
    end
    local ____value_4 = p:withIndex():maxBy(____lambda_1)
    local ____destructured = __K2L_Pair.new(____value_4.value, ____value_4.index)
    local len, c = ____destructured.first, ____destructured.second
    local ____dividend = c - len
    local start = ____dividend >= 0 and ____dividend // 2 or 0 - -____dividend // 2
    return __K2L_Text.substring(s, start, start + len)
end

local ____lambda_2 = function(it) return it:upper() end
local ____lambda_3 = function(w)
    return __K2L_Text.replaceFirstChar(w, ____lambda_2)
end
local ____lambda_4 = function(it) return __K2L_IsUpperCase[it] == true end
local ____lambda_5 = function(it) return __K2L_IsLowerCase[it] == true end
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
    local capitalized = words:joinToString(" ", nil, nil, nil, nil, ____lambda_3)
    print(capitalized)
    local ____out = {}
    local ____count = 0
    local ____items_1, ____n_1 = words:____array()
    for ____i_2 = 1, ____n_1 do
        local it = ____items_1[____i_2]
        ____count = ____count + 1
        ____out[____count] = it:reverse()
    end
    print(__K2L_ListWrap(____out, ____count):joinToString(" ") .. " | " .. words:reversed():joinToString(" "))
    print(__K2L_Text.filter(capitalized, ____lambda_4) .. " " .. __K2L_StringToList(capitalized):count(____lambda_5) .. " " .. swapCase(capitalized))
end

local ____lambda_6 = function(it)
    return __K2L_IsUpperCase[it] == true and it:lower() or it:upper()
end
function swapCase(self)
    return __K2L_StringToList(self):map(____lambda_6):joinToString("")
end

local ____lambda_7 = function(it) return it >= 0 end
local ____lambda_8 = function(it) return it.value end
local ____lambda_9 = function(it) return it.size > 1 end
local ____lambda_10 = function(____a, ____b)
    local ____x_1, ____y_1 = #____a, #____b
    if ____x_1 ~= ____y_1 then
        return ____x_1 < ____y_1 and -1 or 1
    end
    return __K2L_CompareValues(____b, ____a)
end
local function main()
    local text = "abracadabra abracadabra cadabra"
    local ____list = __K2L_ReadOnlyListOf("abra", "cad", "a", "zzz", "abracadabra c")
    for ____i_3 = 1, ____list.size do
        local p = ____list[____i_3]
        local k = kmpSearch(text, p)
        local r = rabinKarp(text, p)
        local builtin = __K2L_GenerateSequence(__K2L_StringIndexOf(text, p), function(prev)
            local ____value_5 = __K2L_StringIndexOf(text, p, prev + 1)
            return ____value_5 >= 0 and ____value_5 or nil
        end):takeWhile(____lambda_7):toList()
        print("'" .. p .. "': kmp=" .. __K2L_Str(k) .. " rk=" .. __K2L_Str(r) .. " same=" .. tostring(__K2L_Equals(k, r) and __K2L_Equals(r, builtin)))
    end
    print("kmp table of 'aabaaab': " .. kmpTable("aabaaab"):joinToString())
    print("z of 'aaabaab': " .. zFunction("aaabaab"):contentToString())
    local ____list_1 = __K2L_ReadOnlyListOf(__K2L_Pair.new("kitten", "sitting"), __K2L_Pair.new("Saturday", "sunday"), __K2L_Pair.new("", "abc"), __K2L_Pair.new("flaw", "lawn"), __K2L_Pair.new("same", "SAME"))
    for ____i_4 = 1, ____list_1.size do
        local ____item_1 = ____list_1[____i_4]
        local a, b = ____item_1.first, ____item_1.second
        local ____destructured_1 = levenshtein(a, b)
        local dist, script = ____destructured_1.first, ____destructured_1.second
        print("lev('" .. a .. "', '" .. b .. "') = " .. dist .. "  " .. script .. "  lcs='" .. lcs(a:lower(), b:lower()) .. "'")
    end
    local banana = "banana"
    local sa = suffixArray(banana)
    local lcp = lcpArray(banana, sa)
    local ____mod_2 = sa.____modCount
    for ____i_5 = 1, sa.size do
        local p = sa[____i_5]
        local i = ____i_5 - 1
        print(__K2L_StringFormat("%2d %d %-7s lcp=%d", i, p, __K2L_Text.substring(banana, p), lcp[i + 1] or __K2L_IndexError(i, lcp.size, "array")))
        if sa.____modCount ~= ____mod_2 and sa:____comodified(____i_5) then
            break
        end
    end
    local ____value_6 = lcp:withIndex():maxBy(____lambda_8)
    local longestRepeat = __K2L_Text.substring(banana, sa:get(____value_6.index), sa:get(____value_6.index) + ____value_6.value)
    print("longest repeated substring: " .. longestRepeat)
    local ____list_2 = __K2L_ReadOnlyListOf("babad", "forgeeksskeegfor", "a", "abacdfgdcaba", "racecar level")
    for ____i_6 = 1, ____list_2.size do
        local s = ____list_2[____i_6]
        print("palindrome(" .. s .. ") = " .. longestPalindrome(s))
    end
    local words = __K2L_ReadOnlyListOf("listen", "silent", "enlist", "google", "gooegl", "cat", "act", "tac", "dog", "Inlets")
    local ____result = __K2L_Map.new()
    local ____items_2, ____n_2 = words:____array()
    for ____i_7 = 1, ____n_2 do
        local it = ____items_2[____i_7]
        local ____value_7 = __K2L_Text.toCharArray(it:lower()):sorted():joinToString("")
        local ____group = ____result:get(____value_7)
        if ____group == nil then
            ____group = __K2L_List.new()
            ____result:put(____value_7, ____group)
        end
        ____group:add(it)
    end
    local groups = ____result
    local ____collection_1 = groups:filterValues(____lambda_9):toSortedMap()
    local ____items_3, ____n_3 = ____collection_1:____entryArray()
    local ____mod_3 = ____collection_1.____modCount
    for ____i_8 = 1, ____n_3 do
        local ____entry = ____items_3[____i_8]
        do
            local k, v = ____entry.key, ____entry.value
            print(__K2L_Str(k) .. " -> " .. __K2L_Str(v:sorted()))
        end
        if ____collection_1.____modCount ~= ____mod_3 and ____collection_1:____comodified(____i_8, ____n_3) then
            break
        end
    end
    print(words:sortedWith(____lambda_10):joinToString())
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_4, ____n_4 = words:____array()
    for ____i_9 = 1, ____n_4 do
        local it = ____items_4[____i_9]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = it:lower()
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1):sortedWith(__K2L_Text.caseInsensitiveOrder):distinct():chunked(4)))
    surgery()
end

main()
return {kmpTable = kmpTable, kmpSearch = kmpSearch, rabinKarp = rabinKarp, zFunction = zFunction, levenshtein = levenshtein, lcs = lcs, suffixArray = suffixArray, lcpArray = lcpArray, longestPalindrome = longestPalindrome, surgery = surgery, swapCase = swapCase}
