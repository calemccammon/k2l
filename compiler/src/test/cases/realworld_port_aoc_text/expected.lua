local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringCharAt = ____lualib.__K2L_StringCharAt
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_Text = ____lualib.__K2L_Text

local function niceOld(s)
    return __K2L_StringToList(s):count(function(it) return __K2L_StringContains("aeiou", it) end) >= 3 and __K2L_StringToList(s):zipWithNext():any(function(____destructured)
        local a, b = ____destructured.first, ____destructured.second
        return a == b
    end) and __K2L_ReadOnlyListOf("ab", "cd", "pq", "xy"):none(function(it) return __K2L_StringContains(s, it) end)
end

local function niceNew(s)
    return __K2L_Regex.new("(..).*\\1"):containsMatchIn(s) and __K2L_Regex.new("(.).\\1"):containsMatchIn(s)
end

local function passwordPolicies(lines)
    local re = __K2L_Regex.new("(\\d+)-(\\d+) (\\w): (\\w+)")
    local a = 0
    local b = 0
    local ____mod = lines.____modCount
    for ____i = 1, lines.size do
        local line = lines[____i]
        local ____destructured_1 = __K2L_NotNull(re:matchEntire(line)).destructured
        local lo, hi, ch, pw = ____destructured_1[1], ____destructured_1[2], ____destructured_1[3], ____destructured_1[4]
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
        if lines.____modCount ~= ____mod and lines:____comodified(____i) then
            break
        end
    end
    return __K2L_Pair.new(a, b)
end

local function validPassport(fields)
    local rules = __K2L_ReadOnlyMapOf(__K2L_Pair.new("byr", function(v)
        local ____value_1 = __K2L_StringToIntOrNull(v)
        return ____value_1 >= 1920 and ____value_1 <= 2002
    end), __K2L_Pair.new("iyr", function(v)
        local ____value_2 = __K2L_StringToIntOrNull(v)
        return ____value_2 >= 2010 and ____value_2 <= 2020
    end), __K2L_Pair.new("eyr", function(v)
        local ____value_3 = __K2L_StringToIntOrNull(v)
        return ____value_3 >= 2020 and ____value_3 <= 2030
    end), __K2L_Pair.new("hgt", function(v)
        local ____receiver = __K2L_Regex.new("(\\d+)(cm|in)"):matchEntire(v)
        local ____receiver_1 = ____receiver and ____receiver.destructured
        local ____result_1
        if ____receiver_1 ~= nil then
            local ____result
            do
                local n, u = ____receiver_1[1], ____receiver_1[2]
                if u == "cm" then
                    local ____value_4 = __K2L_StringToInt(n)
                    ____result = ____value_4 >= 150 and ____value_4 <= 193
                else
                    local ____value_5 = __K2L_StringToInt(n)
                    ____result = ____value_5 >= 59 and ____value_5 <= 76
                end
            end
            ____result_1 = ____result
        end
        local ____value_6 = ____result_1
        if ____value_6 == nil then
            ____value_6 = false
        end
        return ____value_6
    end), __K2L_Pair.new("hcl", function(v)
        return __K2L_Regex.new("#[0-9a-f]{6}"):matches(v)
    end), __K2L_Pair.new("ecl", function(v)
        return __K2L_ReadOnlySetOf("amb", "blu", "brn", "gry", "grn", "hzl", "oth"):contains(v)
    end), __K2L_Pair.new("pid", function(v)
        return #v == 9 and __K2L_StringToList(v):all(function(____p1) return ____p1:match("^%d$") ~= nil end)
    end))
    return rules:all(function(____destructured_2)
        local k, ok = ____destructured_2.key, ____destructured_2.value
        local ____receiver_2 = fields:get(k)
        local ____result_3
        if ____receiver_2 ~= nil then
            local ____result_2
            ____result_2 = ok(____receiver_2)
            ____result_3 = ____result_2
        end
        local ____value_7 = ____result_3
        if ____value_7 == nil then
            ____value_7 = false
        end
        return ____value_7
    end)
end

local function supportsTls(ip)
    local function abba(s)
        return __K2L_Text.windowed(s, 4):any(function(it)
            return __K2L_StringCharAt(it, 0) == __K2L_StringCharAt(it, 3) and __K2L_StringCharAt(it, 1) == __K2L_StringCharAt(it, 2) and __K2L_StringCharAt(it, 0) ~= __K2L_StringCharAt(it, 1)
        end)
    end
    local parts = __K2L_Text.split(ip, {"[", "]"})
    local outside = parts:filterIndexed(function(i, _) return math.fmod(i, 2) == 0 end)
    local inside = parts:filterIndexed(function(i, _) return math.fmod(i, 2) == 1 end)
    return outside:any(abba) and inside:none(abba)
end

local function syntaxScore(lines)
    local close = __K2L_ReadOnlyMapOf(__K2L_Pair.new("(", ")"), __K2L_Pair.new("[", "]"), __K2L_Pair.new("{", "}"), __K2L_Pair.new("<", ">"))
    local errorPoints = __K2L_ReadOnlyMapOf(__K2L_Pair.new(")", 3), __K2L_Pair.new("]", 57), __K2L_Pair.new("}", 1197), __K2L_Pair.new(">", 25137))
    local completePoints = __K2L_ReadOnlyMapOf(__K2L_Pair.new(")", 1), __K2L_Pair.new("]", 2), __K2L_Pair.new("}", 3), __K2L_Pair.new(">", 4))
    local errors = 0
    local completions = __K2L_ListOf()
    local ____mod_1 = lines.____modCount
    for ____i_1 = 1, lines.size do
        local line = lines[____i_1]
        do
            local stack = __K2L_ArrayDeque.new()
            for c in line:gmatch(".") do
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
        if lines.____modCount ~= ____mod_1 and lines:____comodified(____i_1) then
            break
        end
    end
    return __K2L_Pair.new(errors, completions:sorted():get(__K2L_IDiv(completions.size, 2)))
end

local function crates(input, multi)
    local ____destructured_3 = __K2L_StringSplit(input, "\n\n")
    local drawing, moves = ____destructured_3[1], ____destructured_3[2]
    local rows = __K2L_StringLines(drawing)
    local count = __K2L_Regex.new("\\s+"):split(__K2L_StringTrim(rows:last())).size
    local stacks = __K2L_ListOfSize(count, function(it) return __K2L_ArrayDeque.new() end)
    local ____list = rows:dropLast(1)
    local ____mod_2 = ____list.____modCount
    for ____i_2 = 1, ____list.size do
        local row = ____list[____i_2]
        for i = 0, count - 1 do
            local c = __K2L_Text.getOrNull(row, 1 + 4 * i)
            if c ~= nil and c ~= " " then
                stacks:get(i):addFirst(c)
            end
        end
        if ____list.____modCount ~= ____mod_2 and ____list:____comodified(____i_2) then
            break
        end
    end
    for _, m in __K2L_Sequence.new(__K2L_Regex.new("move (\\d+) from (\\d+) to (\\d+)"):findAllFactory(moves)):iter() do
        local ____destructured_4 = m.destructured:toList():map(function(it) return __K2L_StringToInt(it) end)
        local n, from, to = ____destructured_4[1], ____destructured_4[2], ____destructured_4[3]
        local taken = __K2L_IntRange.new(1, n):map(function(it) return stacks:get(from - 1):removeLast() end)
        local ____list_1 = multi and taken:reversed() or taken
        local ____mod_3 = ____list_1.____modCount
        for ____i_3 = 1, ____list_1.size do
            local it = ____list_1[____i_3]
            stacks:get(to - 1):addLast(it)
            if ____list_1.____modCount ~= ____mod_3 and ____list_1:____comodified(____i_3) then
                break
            end
        end
    end
    return stacks:map(function(it) return it:lastOrNull() or " " end):joinToString("")
end

local function stream(s)
    local depth = 0
    local score = 0
    local garbage = 0
    local inGarbage = false
    local i = 0
    while i < #s do
        local c = __K2L_StringCharAt(s, i)
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
    return #__K2L_Regex.new("\\\\x[0-9a-f]{2}|\\\\."):replace(__K2L_Text.substring(lit, 1, #lit - 1), function(it) return "_" end)
end

local function encodedLength(lit)
    return 2 + __K2L_StringToList(lit):sumOf(function(it)
        return (it == "\"" or it == "\\") and 2 or 1
    end)
end

local function nextPassword(current)
    local function inc(s)
        local i = s.size - 1
        while i >= 0 do
            if s:get(i) == "z" then
                local ____key = i
                s:set(____key, "a")
                i = i - 1
            else
                local ____key_1 = i
                s:set(____key_1, string.char(s:get(i):byte() + 1))
                break
            end
        end
        return s
    end
    local function valid(s)
        return __K2L_Text.windowed(s, 3):any(function(it)
            return __K2L_StringCharAt(it, 1) == string.char(__K2L_StringCharAt(it, 0):byte() + 1) and __K2L_StringCharAt(it, 2) == string.char(__K2L_StringCharAt(it, 1):byte() + 1)
        end) and __K2L_StringToList(s):none(function(it) return __K2L_StringContains("iol", it) end) and __K2L_Sequence.new(__K2L_Regex.new("(.)\\1"):findAllFactory(s)):map(function(it) return it.value end):distinct():count() >= 2
    end
    local p = inc(__K2L_Text.toCharArray(current))
    while not valid(__K2L_Text.string(p)) do
        p = inc(p)
    end
    return __K2L_Text.string(p)
end

local function calibration(line, words)
    local names = __K2L_ReadOnlyListOf("one", "two", "three", "four", "five", "six", "seven", "eight", "nine")
    local digits = __K2L_IntRange.new(0, #line - 1):mapNotNull(function(i)
        local ____value_9 = __K2L_Num.digitToIntOrNull(__K2L_StringCharAt(line, i))
        if ____value_9 == nil then
            local ____temp
            if words then
                local ____value_8 = names:indexOfFirst(function(it) return line:sub(i + 1, i + #it) == it end)
                local ____receiver_3 = ____value_8 >= 0 and ____value_8 or nil
                ____temp = ____receiver_3 and ____receiver_3 + 1
            else
                ____temp = nil
            end
            ____value_9 = ____temp
        end
        return ____value_9
    end)
    return digits:first() * 10 + digits:last()
end

local function main()
    local words = __K2L_ReadOnlyListOf("ugknbfddgicrmopn", "aaa", "jchzalrnumimnmhp", "haegwjzuvuyypxyu", "dvszwmarrgswjxmb", "qjhvhtzxzqqjkmpb", "xxyxx", "uurcxstgmygtbstg", "ieodomkazucvgmuy")
    print("nice: " .. words:count(niceOld) .. " / " .. words:count(niceNew) .. " -> " .. __K2L_Str(words:filter(niceNew)))
    print("passwords: " .. __K2L_Str(passwordPolicies(__K2L_ReadOnlyListOf("1-3 a: abcde", "1-3 b: cdefg", "2-9 c: ccccccccc", "3-4 x: xxyx", "2-2 z: zz"))))
    local passports = __K2L_Regex.new("\n\\s*\n"):split(__K2L_Text.trimIndent("\n        eyr:1972 cid:100\n        hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926\n\n        pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980\n        hcl:#623a2f\n\n        hcl:#888785\n        hgt:164cm byr:2001 iyr:2015 cid:88\n        pid:545766238 ecl:hzl\n        eyr:2022\n\n        iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719\n\n        hgt:59cm ecl:zzz eyr:2038 hcl:74454a iyr:2023 pid:3556412378 byr:2007\n    ")):map(function(block)
        return __K2L_Regex.new("\\s+"):split(block):associate(function(it)
            return __K2L_Pair.new(__K2L_Text.substringBefore(it, ":"), __K2L_Text.substringAfter(it, ":"))
        end)
    end)
    print("passports: present=" .. passports:count(function(it)
        return it:getKeys():containsAll(__K2L_ReadOnlyListOf("byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"))
    end) .. " valid=" .. passports:count(validPassport))
    local ips = __K2L_ReadOnlyListOf("abba[mnop]qrst", "abcd[bddb]xyyx", "aaaa[qwer]tyui", "ioxxoj[asdfgh]zxcvbn", "xyx[abc]ddmn[poop]q")
    print("tls: " .. __K2L_Str(ips:map(supportsTls)))
    local chunks = __K2L_StringLines(__K2L_Text.trimIndent("\n        [({(<(())[]>[[{[]{<()<>>\n        [(()[<>])]({[<{<<[]>>(\n        {([(<{}[<>[]}>{[]{[(<()>\n        (((({<>}<{<{<>}{[]{[]{}\n        [[<[([]))<([[{}[[()]]]\n        [{[{({}]{}}([{[{{{}}([]\n        {<[[]]>}<{[{[{[]{()[[[]\n        [<(<(<(<{}))><([]([]()\n        <{([([[(<>()){}]>(<<{{\n        <{([{{}}[<[[[<>{}]]]>[]]\n    "))
    print("syntax: " .. __K2L_Str(syntaxScore(chunks)))
    local crateInput = "    [D]    \n[N] [C]    \n[Z] [M] [P]\n 1   2   3 \n\nmove 1 from 2 to 1\nmove 3 from 1 to 3\nmove 2 from 2 to 1\nmove 1 from 1 to 2"
    print("crates: " .. crates(crateInput, false) .. " " .. crates(crateInput, true))
    local ____list_2 = __K2L_ReadOnlyListOf("{}", "{{{}}}", "{{<!!>},{<!!>},{<!!>},{<!!>}}", "{{<a!>},{<a!>},{<a!>},{<ab>}}", "<{o\"i!a,<{i<a>", "{{<ab>},{<ab>},{<ab>},{<ab>}}")
    for ____i_4 = 1, ____list_2.size do
        local s = ____list_2[____i_4]
        print("stream " .. s .. " -> " .. __K2L_Str(stream(s)))
    end
    local literals = __K2L_ReadOnlyListOf("\"\"", "\"abc\"", "\"aaa\\\"aaa\"", "\"\\x27\"", "\"\\\\x41\"")
    print("escapes: " .. __K2L_Str(literals:map(function(it)
        return #it .. "/" .. decodedLength(it) .. "/" .. encodedLength(it)
    end)) .. " total=" .. literals:sumOf(function(it) return #it - decodedLength(it) end) .. "," .. literals:sumOf(function(it) return encodedLength(it) - #it end))
    print("next passwords: " .. nextPassword("abcdfezz") .. " " .. nextPassword("ghjaabbz") .. " " .. nextPassword("abcdffaa"))
    local cal = __K2L_ReadOnlyListOf("1abc2", "pqr3stu8vwx", "a1b2c3d4e5f", "treb7uchet", "two1nine", "eightwothree", "abcone2threexyz", "xtwone3four", "4nineeightseven2", "zoneight234", "7pqrstsixteen", "oneight")
    print("calibration: " .. cal:take(4):sumOf(function(it) return calibration(it, false) end) .. " " .. cal:drop(4):sumOf(function(it) return calibration(it, true) end) .. " " .. __K2L_Str(cal:map(function(it) return calibration(it, true) end)))
end

main()
return {niceOld = niceOld, niceNew = niceNew, passwordPolicies = passwordPolicies, validPassport = validPassport, supportsTls = supportsTls, syntaxScore = syntaxScore, crates = crates, stream = stream, decodedLength = decodedLength, encodedLength = encodedLength, nextPassword = nextPassword, calibration = calibration}
