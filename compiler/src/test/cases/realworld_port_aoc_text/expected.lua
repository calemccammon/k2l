local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_IsDigit = ____lualib.__K2L_IsDigit
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StrByte = ____lualib.__K2L_StrByte
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_Text = ____lualib.__K2L_Text

local ____lambda_1 = function(it) return __K2L_StringContains("aeiou", it) end
local function niceOld(s)
    local ____cond = __K2L_StringToList(s):count(____lambda_1) >= 3
    if ____cond then
        local ____list = __K2L_StringToList(s):zipWithNext()
        local ____result = false
        local ____items, ____n = ____list:____array()
        for ____i = 1, ____n do
            local ____it = ____items[____i]
            local ____result_1
            do
                local a, b = ____it.first, ____it.second
                ____result_1 = a == b
            end
            if ____result_1 then
                ____result = true
                break
            end
        end
        ____cond = ____result
    end
    local ____cond_1 = ____cond
    if ____cond_1 then
        local ____list_1 = __K2L_ListOf("ab", "cd", "pq", "xy")
        local ____result_2 = true
        local ____items_1, ____n_1 = ____list_1:____array()
        for ____i_1 = 1, ____n_1 do
            local it = ____items_1[____i_1]
            if __K2L_StringContains(s, it) then
                ____result_2 = false
                break
            end
        end
        ____cond_1 = ____result_2
    end
    return ____cond_1
end

local function niceNew(s)
    return __K2L_Regex.new("(..).*\\1", "([^\n\r][^\n\r])[^\n\r]*%1"):containsMatchIn(s) and __K2L_Regex.new("(.).\\1", "([^\n\r])[^\n\r]%1"):containsMatchIn(s)
end

local function passwordPolicies(lines)
    local re = __K2L_Regex.new("(\\d+)-(\\d+) (\\w): (\\w+)", "(%d+)%-(%d+) ([%w_]): ([%w_]+)")
    local a = 0
    local b = 0
    for ____i_2 = 1, lines.size do
        local line = lines[____i_2]
        local ____destructured = __K2L_NotNull(re:matchEntire(line)).destructured
        local lo, hi, ch, pw = ____destructured[1], ____destructured[2], ____destructured[3], ____destructured[4]
        local c = __K2L_Text.single(ch)
        local ____bound = __K2L_StringToInt(lo)
        local ____bound_1 = __K2L_StringToInt(hi)
        local ____value = __K2L_StringToList(pw):count(function(it) return it == c end)
        if ____value >= ____bound and ____value <= ____bound_1 then
            a = a + 1
        end
        if __K2L_Text.getOrNull(pw, __K2L_StringToInt(lo) - 1) == c ~= (__K2L_Text.getOrNull(pw, __K2L_StringToInt(hi) - 1) == c) then
            b = b + 1
        end
    end
    return __K2L_Pair.new(a, b)
end

local ____lambda_2 = function(v)
    return __K2L_Regex.new("#[0-9a-f]{6}", "#[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]"):matches(v)
end
local ____lambda_3 = function(v)
    return __K2L_SetOf("amb", "blu", "brn", "gry", "grn", "hzl", "oth"):contains(v)
end
local ____lambda_4 = function(____p1) return __K2L_IsDigit[____p1] == true end
local ____lambda_5 = function(v)
    return #v == 9 and __K2L_StringToList(v):all(____lambda_4)
end
local function validPassport(fields)
    local rules = __K2L_MapOf(__K2L_Pair.new("byr", function(v)
        local ____value_1 = __K2L_StringToIntOrNull(v)
        return ____value_1 >= 1920 and ____value_1 <= 2002
    end), __K2L_Pair.new("iyr", function(v)
        local ____value_2 = __K2L_StringToIntOrNull(v)
        return ____value_2 >= 2010 and ____value_2 <= 2020
    end), __K2L_Pair.new("eyr", function(v)
        local ____value_3 = __K2L_StringToIntOrNull(v)
        return ____value_3 >= 2020 and ____value_3 <= 2030
    end), __K2L_Pair.new("hgt", function(v)
        local ____receiver = __K2L_Regex.new("(\\d+)([a-z]+)", "(%d+)([a-z]+)"):matchEntire(v)
        local ____receiver_1 = ____receiver and ____receiver.destructured
        local ____result_4
        if ____receiver_1 ~= nil then
            local ____result_3
            do
                local n, u = ____receiver_1[1], ____receiver_1[2]
                if u == "cm" then
                    local ____value_5 = __K2L_StringToInt(n)
                    ____result_3 = ____value_5 >= 150 and ____value_5 <= 193
                elseif u == "in" then
                    local ____value_4 = __K2L_StringToInt(n)
                    ____result_3 = ____value_4 >= 59 and ____value_4 <= 76
                else
                    ____result_3 = false
                end
            end
            ____result_4 = ____result_3
        end
        local ____value_6 = ____result_4
        if ____value_6 == nil then
            ____value_6 = false
        end
        return ____value_6
    end), __K2L_Pair.new("hcl", ____lambda_2), __K2L_Pair.new("ecl", ____lambda_3), __K2L_Pair.new("pid", ____lambda_5))
    return rules:all(function(____destructured_1)
        local k, ok = ____destructured_1.key, ____destructured_1.value
        local ____receiver_2 = fields:get(k)
        local ____result_6
        if ____receiver_2 ~= nil then
            local ____result_5
            ____result_5 = ok(____receiver_2)
            ____result_6 = ____result_5
        end
        local ____value_7 = ____result_6
        if ____value_7 == nil then
            ____value_7 = false
        end
        return ____value_7
    end)
end

local function supportsTls(ip)
    local function abba(s)
        local ____list_2 = __K2L_Text.windowed(s, 4)
        local ____result_7 = false
        local ____items_2, ____n_2 = ____list_2:____array()
        for ____i_3 = 1, ____n_2 do
            local it = ____items_2[____i_3]
            if (0 >= 0 and 0 < #it and it:sub(0 + 1, 0 + 1) or __K2L_IndexError(0, #it, "string")) == (3 >= 0 and 3 < #it and it:sub(3 + 1, 3 + 1) or __K2L_IndexError(3, #it, "string")) and (1 >= 0 and 1 < #it and it:sub(1 + 1, 1 + 1) or __K2L_IndexError(1, #it, "string")) == (2 >= 0 and 2 < #it and it:sub(2 + 1, 2 + 1) or __K2L_IndexError(2, #it, "string")) and (0 >= 0 and 0 < #it and it:sub(0 + 1, 0 + 1) or __K2L_IndexError(0, #it, "string")) ~= (1 >= 0 and 1 < #it and it:sub(1 + 1, 1 + 1) or __K2L_IndexError(1, #it, "string")) then
                ____result_7 = true
                break
            end
        end
        return ____result_7
    end
    local parts = __K2L_Text.split(ip, {"[", "]"})
    local ____out = {}
    local ____count = 0
    local ____items_3, ____n_3 = parts:____array()
    for ____i_4 = 1, ____n_3 do
        local _ = ____items_3[____i_4]
        local i = ____i_4 - 1
        if i % 2 == 0 then
            ____count = ____count + 1
            ____out[____count] = _
        end
    end
    local outside = __K2L_ListWrap(____out, ____count)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_4, ____n_4 = parts:____array()
    for ____i_5 = 1, ____n_4 do
        local _ = ____items_4[____i_5]
        local i = ____i_5 - 1
        if i % 2 == 1 then
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = _
        end
    end
    local inside = __K2L_ListWrap(____out_1, ____count_1)
    return outside:any(abba) and inside:none(abba)
end

local function syntaxScore(lines)
    local close = __K2L_MapOf(__K2L_Pair.new("(", ")"), __K2L_Pair.new("[", "]"), __K2L_Pair.new("{", "}"), __K2L_Pair.new("<", ">"))
    local errorPoints = __K2L_MapOf(__K2L_Pair.new(")", 3), __K2L_Pair.new("]", 57), __K2L_Pair.new("}", 1197), __K2L_Pair.new(">", 25137))
    local completePoints = __K2L_MapOf(__K2L_Pair.new(")", 1), __K2L_Pair.new("]", 2), __K2L_Pair.new("}", 3), __K2L_Pair.new(">", 4))
    local errors = 0
    local completions = __K2L_ListOf()
    for ____i_7 = 1, lines.size do
        local line = lines[____i_7]
        do
            local stack = __K2L_ArrayDeque.new()
            for ____i_6 = 1, #line do
                local c = line:sub(____i_6, ____i_6)
                if close:containsKey(c) then
                    stack:addLast(close:getValue(c))
                elseif stack:removeLastOrNull() ~= c then
                    errors = errors + errorPoints:getValue(c)
                    goto ____continue
                end
            end
            completions:add(stack:reversed():fold(0, function(acc, c)
                return acc * 5 + completePoints:getValue(c)
            end))
        end
        ::____continue::
    end
    return __K2L_Pair.new(errors, completions:sorted():get(completions.size // 2))
end

local function crates(input, multi)
    local ____destructured_2 = __K2L_StringSplit(input, "\n\n")
    local drawing, moves = ____destructured_2[1], ____destructured_2[2]
    local rows = __K2L_StringLines(drawing)
    local count = __K2L_Regex.new("\\s+", "%s+"):split(__K2L_StringTrim(rows:last())).size
    local ____out_2 = {}
    for ____i_8 = 1, count do
        local it = ____i_8 - 1
        ____out_2[____i_8] = __K2L_ArrayDeque.new()
    end
    local stacks = __K2L_ListWrap(____out_2, count)
    local ____list_3 = rows:dropLast(1)
    for ____i_9 = 1, ____list_3.size do
        local row = ____list_3[____i_9]
        for i = 0, count - 1 do
            local c = __K2L_Text.getOrNull(row, 1 + 4 * i)
            if c ~= nil and c ~= " " then
                stacks:get(i):addFirst(c)
            end
        end
    end
    for _, m in __K2L_Sequence.new(__K2L_Regex.new("move (\\d+) from (\\d+) to (\\d+)", "move (%d+) from (%d+) to (%d+)"):findAllFactory(moves)):iter() do
        local ____list_4 = m.destructured:toList()
        local ____out_3 = {}
        local ____count_2 = 0
        local ____items_5, ____n_5 = ____list_4:____array()
        for ____i_10 = 1, ____n_5 do
            local it = ____items_5[____i_10]
            ____count_2 = ____count_2 + 1
            ____out_3[____count_2] = __K2L_StringToInt(it)
        end
        local ____destructured_3 = __K2L_ListWrap(____out_3, ____count_2)
        local n, from, to = ____destructured_3[1], ____destructured_3[2], ____destructured_3[3]
        local taken = __K2L_IntRange.new(1, n):map(function(it) return stacks:get(from - 1):removeLast() end)
        local ____list_5 = multi and taken:reversed() or taken
        for ____i_11 = 1, ____list_5.size do
            local it = ____list_5[____i_11]
            stacks:get(to - 1):addLast(it)
        end
    end
    local ____out_4 = {}
    local ____count_3 = 0
    local ____items_6, ____n_6 = stacks:____array()
    for ____i_12 = 1, ____n_6 do
        local it = ____items_6[____i_12]
        local ____result_8
        ____result_8 = it:lastOrNull() or " "
        ____count_3 = ____count_3 + 1
        ____out_4[____count_3] = ____result_8
    end
    return __K2L_ListWrap(____out_4, ____count_3):joinToString("")
end

local function stream(s)
    local depth = 0
    local score = 0
    local garbage = 0
    local inGarbage = false
    local i = 0
    while i < #s do
        local c = i >= 0 and i < #s and s:sub(i + 1, i + 1) or __K2L_IndexError(i, #s, "string")
        if c == "!" then
            i = i + 1
        elseif inGarbage and c == ">" then
            inGarbage = false
        elseif inGarbage then
            garbage = garbage + 1
        elseif c == "<" then
            inGarbage = true
        elseif c == "{" then
            depth = depth + 1
            score = score + depth
        elseif c == "}" then
            depth = depth - 1
        end
        i = i + 1
    end
    return __K2L_Pair.new(score, garbage)
end

local function decodedLength(lit)
    local body = __K2L_Text.substring(lit, 1, #lit - 1)
    local i = 0
    local n = 0
    while i < #body do
        local ____temp
        if (i >= 0 and __K2L_StrByte(body, i + 1) or __K2L_IndexError(i, #body, "string")) ~= 92 then
            ____temp = 1
        else
            ____temp = __K2L_Regex.new("\\\\x[0-9a-f]{2}", "\\x[0-9a-f][0-9a-f]"):matchesAt(body, i) and 4 or 2
        end
        i = i + ____temp
        n = n + 1
    end
    return n
end

local ____lambda_6 = function(it)
    return (it == "\"" or it == "\\") and 2 or 1
end
local function encodedLength(lit)
    return 2 + __K2L_StringToList(lit):sumOf(____lambda_6)
end

local ____lambda_7 = function(it) return __K2L_StringContains("iol", it) end
local ____lambda_8 = function(it) return it.value end
local function nextPassword(current)
    local function inc(s)
        local i = s.size - 1
        while i >= 0 do
            if (s[i + 1] or __K2L_IndexError(i, s.size, "array")) == "z" then
                local ____key = i
                if ____key < 0 or ____key >= s.size then
                    __K2L_IndexError(____key, s.size, "array")
                end
                s[____key + 1] = "a"
                i = i - 1
            else
                local ____key_1 = i
                local ____value_8 = string.char((s[i + 1] or __K2L_IndexError(i, s.size, "array")):byte() + 1)
                if ____key_1 < 0 or ____key_1 >= s.size then
                    __K2L_IndexError(____key_1, s.size, "array")
                end
                s[____key_1 + 1] = ____value_8
                break
            end
        end
        return s
    end
    local function valid(s)
        local ____list_6 = __K2L_Text.windowed(s, 3)
        local ____result_9 = false
        local ____items_7, ____n_7 = ____list_6:____array()
        for ____i_13 = 1, ____n_7 do
            local it = ____items_7[____i_13]
            if (1 >= 0 and 1 < #it and it:sub(1 + 1, 1 + 1) or __K2L_IndexError(1, #it, "string")) == string.char((0 >= 0 and 0 < #it and it:sub(0 + 1, 0 + 1) or __K2L_IndexError(0, #it, "string")):byte() + 1) and (2 >= 0 and 2 < #it and it:sub(2 + 1, 2 + 1) or __K2L_IndexError(2, #it, "string")) == string.char((1 >= 0 and 1 < #it and it:sub(1 + 1, 1 + 1) or __K2L_IndexError(1, #it, "string")):byte() + 1) then
                ____result_9 = true
                break
            end
        end
        return ____result_9 and __K2L_StringToList(s):none(____lambda_7) and __K2L_Sequence.new(__K2L_Regex.new("(.)\\1", "([^\n\r])%1"):findAllFactory(s)):map(____lambda_8):distinct():count() >= 2
    end
    local p = inc(__K2L_Text.toCharArray(current))
    while not valid(__K2L_Text.string(p)) do
        p = inc(p)
    end
    return __K2L_Text.string(p)
end

local function calibration(line, words)
    local names = __K2L_ListOf("one", "two", "three", "four", "five", "six", "seven", "eight", "nine")
    local digits = __K2L_IntRange.new(0, #line - 1):mapNotNull(function(i)
        local ____value_10 = __K2L_Num.digitToIntOrNull(i >= 0 and i < #line and line:sub(i + 1, i + 1) or __K2L_IndexError(i, #line, "string"))
        if ____value_10 == nil then
            local ____temp_1
            if words then
                local ____value_9 = names:indexOfFirst(function(it) return line:sub(i + 1, i + #it) == it end)
                local ____receiver_3 = ____value_9 >= 0 and ____value_9 or nil
                ____temp_1 = ____receiver_3 and ____receiver_3 + 1
            else
                ____temp_1 = nil
            end
            ____value_10 = ____temp_1
        end
        return ____value_10
    end)
    return digits:first() * 10 + digits:last()
end

local ____lambda_9 = function(it)
    return __K2L_Pair.new(__K2L_Text.substringBefore(it, ":"), __K2L_Text.substringAfter(it, ":"))
end
local function main()
    local words = __K2L_ListOf("eeiou", "sootheabout", "rrr", "lomolomo", "uvwuvwkk", "aeiouxxtyty", "babkkeeoi", "momoxoxo", "ffiiuunnoo")
    print("nice: " .. words:count(niceOld) .. " / " .. words:count(niceNew) .. " -> " .. __K2L_Str(words:filter(niceNew)))
    print("passwords: " .. __K2L_Str(passwordPolicies(__K2L_ListOf("2-4 k: kakkm", "1-2 r: tqrs", "3-5 m: mmmmmm", "1-4 j: jxyj", "2-3 w: awwb"))))
    local ____list_7 = __K2L_Regex.new("\n\\s*\n", "\n%s*\n"):split(__K2L_Text.trimIndent("\n        ecl:gry pid:000123456 eyr:2025 hcl:#a1b2c3\n        byr:1950 iyr:2015 cid:7 hgt:180cm\n\n        iyr:2011 hgt:65in ecl:oth hcl:#00ff00\n        pid:987654321 byr:1999\n\n        hcl:#123abc byr:1985 eyr:2029 pid:111222333 ecl:hzl iyr:2019 hgt:70in\n\n        byr:2010 iyr:2009 eyr:2031 hgt:190 hcl:123abc ecl:xyz pid:12345\n\n        pid:555666777 hgt:150cm ecl:amb\n        hcl:#ffffff\n        iyr:2020 byr:1920 eyr:2020\n\n        hgt:194cm ecl:blu byr:1970 iyr:2014 eyr:2024 hcl:#abcdeg pid:0123456789\n    "))
    local ____out_5 = {}
    local ____count_4 = 0
    local ____items_8, ____n_8 = ____list_7:____array()
    for ____i_14 = 1, ____n_8 do
        local block = ____items_8[____i_14]
        local ____result_10
        ____result_10 = __K2L_Regex.new("\\s+", "%s+"):split(block):associate(____lambda_9)
        ____count_4 = ____count_4 + 1
        ____out_5[____count_4] = ____result_10
    end
    local passports = __K2L_ListWrap(____out_5, ____count_4)
    local ____result_11 = 0
    local ____items_9, ____n_9 = passports:____array()
    for ____i_15 = 1, ____n_9 do
        local it = ____items_9[____i_15]
        if it:getKeys():containsAll(__K2L_ListOf("byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid")) then
            ____result_11 = ____result_11 + 1
        end
    end
    print("passports: present=" .. ____result_11 .. " valid=" .. passports:count(validPassport))
    local ips = __K2L_ListOf("kxxk[abcd]efgh", "mnop[qrrq]stts", "zzzz[abcd]efgh", "abcdeffe[xyz]qq", "pqr[stu]vwwvx[lmml]z")
    print("tls: " .. __K2L_Str(ips:map(supportsTls)))
    local chunks = __K2L_StringLines(__K2L_Text.trimIndent("\n        [<>({}){}[([])<>]]\n        {([(<>)]\n        <{[()]}>)\n        [(<{}>]\n        <([]){}}\n        ({<[]>}\n        [[<{(\n        {<(>\n        <<[]{()}\n        (<[{}]>{[]}]\n    "))
    print("syntax: " .. __K2L_Str(syntaxScore(chunks)))
    local crateInput = "[Q]         [T]\n[R] [W]     [U]\n[S] [X] [Y] [V]\n 1   2   3   4 \n\n" .. "move 2 from 4 to 3\nmove 1 from 1 to 2\nmove 3 from 3 to 1\nmove 2 from 2 to 4"
    print("crates: " .. crates(crateInput, false) .. " " .. crates(crateInput, true))
    local ____list_8 = __K2L_ListOf("{}", "{{}{}}", "{<x!>y>,{}}", "{{<!!!>>},{<abc>}}", "<!!!!>", "{{{<{}>}},{<>}}", "<a{b!c>")
    for ____i_16 = 1, ____list_8.size do
        local s = ____list_8[____i_16]
        print("stream " .. s .. " -> " .. __K2L_Str(stream(s)))
    end
    local literals = __K2L_ListOf("\"hi\"", "\"a\\\"b\"", "\"\\x4f\\x6b\"", "\"\\\\\\\\\"", "\"z\\\\x41\"")
    local ____out_6 = {}
    local ____count_5 = 0
    local ____items_10, ____n_10 = literals:____array()
    for ____i_17 = 1, ____n_10 do
        local it = ____items_10[____i_17]
        ____count_5 = ____count_5 + 1
        ____out_6[____count_5] = #it .. "/" .. decodedLength(it) .. "/" .. encodedLength(it)
    end
    local ____arg = "escapes: " .. __K2L_Str(__K2L_ListWrap(____out_6, ____count_5)) .. " total="
    local ____sum = 0
    local ____items_11, ____n_11 = literals:____array()
    for ____i_18 = 1, ____n_11 do
        local it = ____items_11[____i_18]
        ____sum = ____sum + (#it - decodedLength(it))
    end
    local ____arg_1 = ____arg .. ____sum .. ","
    local ____sum_1 = 0
    local ____items_12, ____n_12 = literals:____array()
    for ____i_19 = 1, ____n_12 do
        local it = ____items_12[____i_19]
        ____sum_1 = ____sum_1 + (encodedLength(it) - #it)
    end
    print(____arg_1 .. ____sum_1)
    print("next passwords: " .. nextPassword("qrsuuvwz") .. " " .. nextPassword("tuvaacfz") .. " " .. nextPassword("pqrhhmmz"))
    local cal = __K2L_ListOf("k4m9", "77", "x1y2z3", "nope5here", "sixabc3", "nineight", "q2threefour", "fivesevenine", "8kseven", "twoone", "threeeight5", "abfour")
    local ____list_9 = cal:take(4)
    local ____sum_2 = 0
    local ____items_13, ____n_13 = ____list_9:____array()
    for ____i_20 = 1, ____n_13 do
        local it = ____items_13[____i_20]
        ____sum_2 = ____sum_2 + calibration(it, false)
    end
    local ____list_10 = cal:drop(4)
    local ____sum_3 = 0
    local ____items_14, ____n_14 = ____list_10:____array()
    for ____i_21 = 1, ____n_14 do
        local it = ____items_14[____i_21]
        ____sum_3 = ____sum_3 + calibration(it, true)
    end
    local ____out_7 = {}
    local ____count_6 = 0
    local ____items_15, ____n_15 = cal:____array()
    for ____i_22 = 1, ____n_15 do
        local it = ____items_15[____i_22]
        ____count_6 = ____count_6 + 1
        ____out_7[____count_6] = calibration(it, true)
    end
    print("calibration: " .. ____sum_2 .. " " .. ____sum_3 .. " " .. __K2L_Str(__K2L_ListWrap(____out_7, ____count_6)))
end

__K2L_RunMain(main)
return {niceOld = niceOld, niceNew = niceNew, passwordPolicies = passwordPolicies, validPassport = validPassport, supportsTls = supportsTls, syntaxScore = syntaxScore, crates = crates, stream = stream, decodedLength = decodedLength, encodedLength = encodedLength, nextPassword = nextPassword, calibration = calibration}
