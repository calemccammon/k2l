-- requires: Class, Collections, Exceptions, Str, Pair
-- kotlin.text.Regex: a backtracking matcher for the commonly used part of Java's regex syntax
-- (classes, groups, named groups, alternation, greedy/lazy/possessive quantifiers, anchors, \b,
-- lookaround, backreferences, inline flags). Strings are byte strings; `.` and negated classes
-- consume a whole UTF-8 character. With --strings utf16 and Utf16Case loaded, IGNORE_CASE (and the inline flag (?u))
-- compares characters by their Unicode case folding, as Java's UNICODE_CASE does.
local __K2L_Regex = __K2L_Class("kotlin.text.Regex")
local __K2L_MatchGroup = __K2L_Class("kotlin.text.MatchGroup")
local __K2L_MatchResult = __K2L_Class("kotlin.text.MatchResult")
local __K2L_MatchGroups = __K2L_Class("kotlin.text.MatchGroupCollection", __K2L_List)

do

local function patternError(message, pattern)
    error(__K2L_IllegalArgumentException.new(message .. " near index in pattern " .. pattern))
end

local function isWordByte(b)
    return b ~= nil and (b >= 48 and b <= 57 or b >= 65 and b <= 90 or b >= 97 and b <= 122 or b == 95)
end

local function lowerByte(b)
    if b >= 65 and b <= 90 then
        return b + 32
    end
    return b
end

-- Number of bytes of the UTF-8 character starting with byte `b`.
local function charLength(b)
    if b < 0xC0 then
        return 1
    elseif b < 0xE0 then
        return 2
    elseif b < 0xF0 then
        return 3
    end
    return 4
end

-- The code point of the UTF-8 character of `len` bytes at index i of s.
local function decodeAt(s, i, len)
    local b, b2, b3, b4 = s:byte(i, i + len - 1)
    if len == 1 then
        return b
    elseif len == 2 then
        return (b - 0xC0) * 64 + (b2 - 0x80)
    elseif len == 3 then
        return (b - 0xE0) * 4096 + (b2 - 0x80) * 64 + (b3 - 0x80)
    end
    return (b - 0xF0) * 262144 + (b2 - 0x80) * 4096 + (b3 - 0x80) * 64 + (b4 - 0x80)
end

local CLASSES = {
    d = function(b) return b >= 48 and b <= 57 end,
    w = isWordByte,
    s = function(b) return b == 32 or (b >= 9 and b <= 13) end,
}

local PROPERTIES = {
    Alpha = function(b) return b >= 65 and b <= 90 or b >= 97 and b <= 122 end,
    Upper = function(b) return b >= 65 and b <= 90 end,
    Lower = function(b) return b >= 97 and b <= 122 end,
    Digit = CLASSES.d,
    Alnum = function(b) return b >= 48 and b <= 57 or b >= 65 and b <= 90 or b >= 97 and b <= 122 end,
    Punct = function(b) return b >= 33 and b <= 47 or b >= 58 and b <= 64 or b >= 91 and b <= 96 or b >= 123 and b <= 126 end,
    Space = CLASSES.s,
    ASCII = function(b) return b < 128 end,
    XDigit = function(b) return b >= 48 and b <= 57 or b >= 65 and b <= 70 or b >= 97 and b <= 102 end,
}
PROPERTIES.L, PROPERTIES.IsAlphabetic, PROPERTIES.IsLetter = PROPERTIES.Alpha, PROPERTIES.Alpha, PROPERTIES.Alpha
PROPERTIES.Lu, PROPERTIES.IsUppercase, PROPERTIES.javaUpperCase = PROPERTIES.Upper, PROPERTIES.Upper, PROPERTIES.Upper
PROPERTIES.Ll, PROPERTIES.IsLowercase, PROPERTIES.javaLowerCase = PROPERTIES.Lower, PROPERTIES.Lower, PROPERTIES.Lower
PROPERTIES.N, PROPERTIES.Nd, PROPERTIES.IsDigit = PROPERTIES.Digit, PROPERTIES.Digit, PROPERTIES.Digit
PROPERTIES.P, PROPERTIES.IsPunctuation = PROPERTIES.Punct, PROPERTIES.Punct
PROPERTIES.IsWhite_Space, PROPERTIES.Z = PROPERTIES.Space, PROPERTIES.Space

------------------------------------------------------------------ parser
-- Nodes: char, any, set, seq, alt, group, rep, bol, eol, wordb, look, backref, atomic

local ESCAPES = {n = 10, t = 9, r = 13, f = 12, e = 27, a = 7}

local function utf8Bytes(code)
    if code < 128 then
        return string.char(code)
    elseif code < 2048 then
        return string.char(192 + math.floor(code / 64), 128 + code % 64)
    elseif code < 65536 then
        return string.char(224 + math.floor(code / 4096), 128 + math.floor(code / 64) % 64, 128 + code % 64)
    end
    return string.char(240 + math.floor(code / 262144), 128 + math.floor(code / 4096) % 64,
        128 + math.floor(code / 64) % 64, 128 + code % 64)
end

local function parse(pattern, options)
    local pos = 1
    local groupCount = 0
    local names = {}
    local flags = {
        ci = options.IGNORE_CASE == true,
        uni = options.IGNORE_CASE == true and __K2L_Regex.____fold ~= nil,
        multiline = options.MULTILINE == true,
        dotall = options.DOT_MATCHES_ALL == true,
        comments = options.COMMENTS == true,
    }
    local parseAlternation

    local function peek()
        return pattern:sub(pos, pos)
    end

    local function fail(message)
        patternError(message, pattern)
    end

    local function literalNode(text)
        local items = {}
        local fold = __K2L_Regex.____fold
        local i = 1
        while i <= #text do
            local b = text:byte(i)
            if flags.ci and flags.uni and fold ~= nil and (b >= 0xC0 or (b >= 65 and b <= 90) or (b >= 97 and b <= 122)) then
                -- a letter compared by case folding: it also matches characters like the Kelvin sign
                local len = b >= 0xC0 and charLength(b) or 1
                items[#items + 1] = {t = "ufold", target = fold(decodeAt(text, i, len))}
                i = i + len
            else
                items[#items + 1] = {t = "char", c = b, ci = flags.ci}
                i = i + 1
            end
        end
        if #items == 1 then
            return items[1]
        end
        return {t = "seq", items = items}
    end

    -- A set node: ascii byte predicates, literal multi-byte characters and class functions.
    local function newSet()
        return {t = "set", bytes = {}, classes = {}, multi = {}, ranges = {}, cpRanges = {}, neg = false, ci = flags.ci, uni = flags.ci and flags.uni}
    end

    local function classNode(letter)
        local set = newSet()
        local lower = letter:lower()
        set.classes[1] = CLASSES[lower]
        set.neg = letter ~= lower
        return set
    end

    local function propertyNode(negated)
        local name
        if peek() == "{" then
            local close = pattern:find("}", pos, true)
            if close == nil then
                fail("Unclosed character family")
            end
            name = pattern:sub(pos + 1, close - 1)
            pos = close + 1
        else
            name = peek()
            pos = pos + 1
        end
        local fn = PROPERTIES[name]
        if fn == nil then
            fail("Unknown character property name {" .. name .. "}")
        end
        local set = newSet()
        set.classes[1] = fn
        set.neg = negated
        return set
    end

    -- escape after the backslash, shared by atoms and classes; returns a node or a literal byte string
    local function parseEscape(inClass)
        local c = peek()
        pos = pos + 1
        if c == "" then
            fail("Unexpected internal error")
        elseif c:match("[dDwWsS]") then
            return classNode(c)
        elseif c == "p" or c == "P" then
            return propertyNode(c == "P")
        elseif ESCAPES[c] then
            return string.char(ESCAPES[c])
        elseif c == "x" then
            local braced = pattern:match("^{(%x+)}", pos)
            if braced ~= nil then
                pos = pos + #braced + 2
                local code = tonumber(braced, 16)
                if code > 0x10FFFF then
                    fail("Hexadecimal codepoint is too big")
                end
                return utf8Bytes(code)
            end
            local hex = pattern:match("^%x%x", pos)
            if hex == nil then
                fail("Illegal hexadecimal escape sequence")
            end
            pos = pos + 2
            return utf8Bytes(tonumber(hex, 16))
        elseif c == "u" then
            local hex = pattern:match("^%x%x%x%x", pos)
            if hex == nil then
                fail("Illegal Unicode escape sequence")
            end
            pos = pos + 4
            local code = tonumber(hex, 16)
            -- a high and a low surrogate escape together are one supplementary character
            local low = code >= 0xD800 and code <= 0xDBFF and pattern:match("^\\u([dD][c-fC-F]%x%x)", pos)
            if low then
                pos = pos + 6
                code = 0x10000 + (code - 0xD800) * 1024 + (tonumber(low, 16) - 0xDC00)
            end
            return utf8Bytes(code)
        elseif c == "0" then
            return string.char(0)
        elseif not inClass and c == "b" then
            return {t = "wordb"}
        elseif not inClass and c == "B" then
            return {t = "wordb", neg = true}
        elseif not inClass and c == "A" then
            return {t = "bol", absolute = true}
        elseif not inClass and (c == "z" or c == "Z") then
            return {t = "eol", absolute = true, final = c == "Z"}
        elseif not inClass and c:match("%d") then
            return {t = "backref", index = tonumber(c), ci = flags.ci, uni = flags.ci and flags.uni}
        elseif not inClass and c == "k" then
            local name = pattern:match("^<([%w_]+)>", pos)
            if name == nil then
                fail("\\k is not followed by '<' for named capturing group")
            end
            pos = pos + #name + 2
            return {t = "backref", name = name, ci = flags.ci, uni = flags.ci and flags.uni}
        elseif c == "Q" then
            local close = pattern:find("\\E", pos, true)
            local text = pattern:sub(pos, (close or #pattern + 1) - 1)
            pos = close and close + 2 or #pattern + 1
            return text
        end
        return c
    end

    local function addToSet(set, text)
        -- text is one UTF-8 character (or a byte)
        if #text == 1 then
            set.bytes[text:byte()] = true
        else
            set.multi[#set.multi + 1] = text
        end
    end

    local function readClassChar()
        local c = peek()
        if c == "\\" then
            pos = pos + 1
            local e = parseEscape(true)
            return e
        end
        local len = charLength(c:byte())
        local text = pattern:sub(pos, pos + len - 1)
        pos = pos + len
        return text
    end

    local function parseSet()
        local set = newSet()
        if peek() == "^" then
            set.neg = true
            pos = pos + 1
        end
        local first = true
        while true do
            local c = peek()
            if c == "" then
                fail("Unclosed character class")
            elseif c == "]" and not first then
                pos = pos + 1
                break
            end
            first = false
            if c == "[" then
                pos = pos + 1
                local inner = parseSet()
                if inner.neg then
                    fail("Nested negated classes are not supported")
                end
                for b in pairs(inner.bytes) do
                    set.bytes[b] = true
                end
                for _, fn in ipairs(inner.classes) do
                    set.classes[#set.classes + 1] = fn
                end
                for _, text in ipairs(inner.multi) do
                    set.multi[#set.multi + 1] = text
                end
                for _, r in ipairs(inner.ranges) do
                    set.ranges[#set.ranges + 1] = r
                end
                for _, r in ipairs(inner.cpRanges) do
                    set.cpRanges[#set.cpRanges + 1] = r
                end
            elseif c == "&" and pattern:sub(pos, pos + 1) == "&&" then
                fail("Class intersection is not supported")
            else
                local item = readClassChar()
                if type(item) == "table" then
                    -- \d, \w, \s, \p{..} inside a class; a negated one (\D) matches by predicate
                    local fn = item.classes[1]
                    if item.neg then
                        set.classes[#set.classes + 1] = function(b) return not fn(b) end
                    else
                        set.classes[#set.classes + 1] = fn
                    end
                elseif peek() == "-" and pattern:sub(pos + 1, pos + 1) ~= "]" and pattern:sub(pos + 1, pos + 1) ~= "" then
                    pos = pos + 1
                    local last = readClassChar()
                    if type(last) == "table" or charLength(item:byte()) ~= #item or charLength(last:byte()) ~= #last then
                        fail("Illegal character range")
                    end
                    local lo, hi = decodeAt(item, 1, #item), decodeAt(last, 1, #last)
                    if hi < lo then
                        fail("Illegal character range")
                    elseif hi < 128 then
                        set.ranges[#set.ranges + 1] = {lo, hi}
                    elseif lo < 128 then
                        set.ranges[#set.ranges + 1] = {lo, 127}
                        set.cpRanges[#set.cpRanges + 1] = {128, hi}
                    else
                        set.cpRanges[#set.cpRanges + 1] = {lo, hi}
                    end
                else
                    addToSet(set, item)
                end
            end
        end
        return set
    end

    local function parseGroupStart()
        -- after "(": returns kind and data
        if peek() ~= "?" then
            groupCount = groupCount + 1
            return "capture", groupCount
        end
        pos = pos + 1
        local c = peek()
        if c == ":" then
            pos = pos + 1
            return "plain"
        elseif c == "=" then
            pos = pos + 1
            return "look", {ahead = true, neg = false}
        elseif c == "!" then
            pos = pos + 1
            return "look", {ahead = true, neg = true}
        elseif c == ">" then
            pos = pos + 1
            return "atomic"
        elseif c == "<" then
            local nextChar = pattern:sub(pos + 1, pos + 1)
            if nextChar == "=" then
                pos = pos + 2
                return "look", {ahead = false, neg = false}
            elseif nextChar == "!" then
                pos = pos + 2
                return "look", {ahead = false, neg = true}
            end
            local name = pattern:match("^<([%a][%w]*)>", pos)
            if name == nil then
                fail("Named capturing group is missing trailing '>'")
            end
            pos = pos + #name + 2
            groupCount = groupCount + 1
            names[name] = groupCount
            return "capture", groupCount
        end
        -- inline flags: (?i) (?s) (?m) (?x) or scoped (?i:...)
        local on, off = pattern:match("^([imsxu]*)%-?([imsx]*)", pos)
        local spec = pattern:match("^[imsxu%-]*", pos)
        pos = pos + #spec
        local saved = {ci = flags.ci, uni = flags.uni, multiline = flags.multiline, dotall = flags.dotall, comments = flags.comments}
        local function apply(letters, value)
            for letter in letters:gmatch(".") do
                if letter == "i" then
                    flags.ci = value
                elseif letter == "u" then
                    flags.uni = value and __K2L_Regex.____fold ~= nil
                elseif letter == "m" then
                    flags.multiline = value
                elseif letter == "s" then
                    flags.dotall = value
                elseif letter == "x" then
                    flags.comments = value
                end
            end
        end
        apply(on, true)
        apply(off, false)
        if peek() == ")" then
            return "flags"
        elseif peek() == ":" then
            pos = pos + 1
            return "scoped", saved
        end
        fail("Unknown inline modifier")
    end

    local function parseQuantifier(atom)
        local c = peek()
        local min, max
        if c == "*" then
            min, max = 0, math.huge
            pos = pos + 1
        elseif c == "+" then
            min, max = 1, math.huge
            pos = pos + 1
        elseif c == "?" then
            min, max = 0, 1
            pos = pos + 1
        elseif c == "{" then
            local a, b, close = pattern:match("^{(%d+)(,?%d*)}()", pos)
            if a == nil then
                return atom
            end
            min = tonumber(a)
            if b == "" then
                max = min
            elseif b == "," then
                max = math.huge
            else
                max = tonumber(b:sub(2))
            end
            pos = close
        else
            return atom
        end
        local lazy, possessive = false, false
        if peek() == "?" then
            lazy = true
            pos = pos + 1
        elseif peek() == "+" then
            possessive = true
            pos = pos + 1
        end
        local node = {t = "rep", node = atom, min = min, max = max, lazy = lazy}
        if possessive then
            node = {t = "atomic", node = node}
        end
        return node
    end

    local function parseAtom()
        local c = peek()
        pos = pos + 1
        if c == "(" then
            local kind, data = parseGroupStart()
            if kind == "flags" then
                pos = pos + 1
                return {t = "seq", items = {}}
            end
            local inner = parseAlternation()
            if peek() ~= ")" then
                fail("Unclosed group")
            end
            pos = pos + 1
            if kind == "capture" then
                return {t = "group", index = data, node = inner}
            elseif kind == "look" then
                return {t = "look", node = inner, ahead = data.ahead, neg = data.neg}
            elseif kind == "atomic" then
                return {t = "atomic", node = inner}
            elseif kind == "scoped" then
                flags.ci, flags.uni, flags.multiline, flags.dotall, flags.comments =
                    data.ci, data.uni, data.multiline, data.dotall, data.comments
            end
            return inner
        elseif c == "[" then
            return parseSet()
        elseif c == "." then
            return {t = "any", dotall = flags.dotall}
        elseif c == "^" then
            return {t = "bol", multiline = flags.multiline}
        elseif c == "$" then
            return {t = "eol", multiline = flags.multiline}
        elseif c == "\\" then
            local e = parseEscape(false)
            if type(e) == "string" then
                return literalNode(e)
            end
            return e
        elseif c == "*" or c == "+" or c == "?" then
            fail("Dangling meta character '" .. c .. "'")
        end
        local len = charLength(c:byte())
        local text = pattern:sub(pos - 1, pos - 2 + len)
        pos = pos - 1 + len
        return literalNode(text)
    end

    local function parseSequence()
        local items = {}
        while pos <= #pattern do
            local c = peek()
            if c == "|" or c == ")" then
                break
            end
            if flags.comments and c:match("%s") then
                pos = pos + 1
            elseif flags.comments and c == "#" then
                local nl = pattern:find("\n", pos, true)
                pos = nl and nl + 1 or #pattern + 1
            else
                items[#items + 1] = parseQuantifier(parseAtom())
            end
        end
        if #items == 1 then
            return items[1]
        end
        return {t = "seq", items = items}
    end

    function parseAlternation()
        local alts = {parseSequence()}
        while peek() == "|" do
            pos = pos + 1
            alts[#alts + 1] = parseSequence()
        end
        if #alts == 1 then
            return alts[1]
        end
        return {t = "alt", alts = alts}
    end

    if options.LITERAL then
        return literalNode(pattern), 0, names
    end
    local node = parseAlternation()
    if pos <= #pattern then
        fail("Unmatched closing ')'")
    end
    return node, groupCount, names
end

------------------------------------------------------------------ compiler
-- Every compiled node is function(st, i, k): match at byte index i, then continue with k(i2);
-- the result is the final end index, or nil.

local compile

local function singleStep(node)
    -- Returns function(st, i) -> next index or nil for nodes that always consume one character.
    local t = node.t
    if t == "char" then
        local c = node.c
        if node.ci then
            local lc = lowerByte(c)
            return function(st, i)
                local b = st.bytes[i]
                if b ~= nil and lowerByte(b) == lc then
                    return i + 1
                end
            end
        end
        return function(st, i)
            if st.bytes[i] == c then
                return i + 1
            end
        end
    elseif t == "ufold" then
        local target, fold = node.target, __K2L_Regex.____fold
        return function(st, i)
            local b = st.bytes[i]
            if b == nil then
                return nil
            end
            local cp, len = b, 1
            if b >= 0xC0 then
                len = charLength(b)
                cp = decodeAt(st.s, i, len)
            end
            if fold(cp) == target then
                return i + len
            end
        end
    elseif t == "any" then
        return function(st, i)
            local b = st.bytes[i]
            if b == nil or (not node.dotall and (b == 10 or b == 13)) then
                return nil
            end
            return i + charLength(b)
        end
    elseif t == "set" then
        local ranges, bytes, classes, multi, cpRanges, neg, ci =
            node.ranges, node.bytes, node.classes, node.multi, node.cpRanges, node.neg, node.ci
        local fold = node.uni and __K2L_Regex.____fold or nil
        local upperOf, lowerOf = __K2L_Regex.____upper, __K2L_Regex.____lower
        local multiCps = {}
        for j, m in ipairs(multi) do
            multiCps[j] = decodeAt(m, 1, #m)
        end
        local function hasByte(b)
            if bytes[b] then
                return true
            end
            for _, r in ipairs(ranges) do
                if b >= r[1] and b <= r[2] then
                    return true
                end
            end
            for _, fn in ipairs(classes) do
                if fn(b) then
                    return true
                end
            end
            return false
        end
        -- membership of a code point, with its case
        local function hasCodePoint(cp)
            if cp < 128 then
                return hasByte(cp)
            end
            for j = 1, #multiCps do
                if multiCps[j] == cp then
                    return true
                end
            end
            for j = 1, #cpRanges do
                if cp >= cpRanges[j][1] and cp <= cpRanges[j][2] then
                    return true
                end
            end
            return false
        end
        return function(st, i)
            local b = st.bytes[i]
            if b == nil then
                return nil
            end
            local hit
            local len = 1
            if fold ~= nil then
                -- compared by case folding, like Java's UNICODE_CASE: the char, its upper case and that one's lower case
                local cp = b
                if b >= 0xC0 then
                    len = charLength(b)
                    cp = decodeAt(st.s, i, len)
                end
                local up = upperOf(cp)
                local folded = fold(cp)
                hit = hasCodePoint(cp) or hasCodePoint(up) or hasCodePoint(lowerOf(up)) or
                    (folded >= 97 and folded <= 122 and hasCodePoint(folded - 32))
                for j = 1, #multiCps do
                    if not hit and fold(multiCps[j]) == folded then
                        hit = true
                    end
                end
            elseif b >= 0xC0 then
                len = charLength(b)
                local text = st.s:sub(i, i + len - 1)
                for _, m in ipairs(multi) do
                    if m == text then
                        hit = true
                        break
                    end
                end
                if not hit and #cpRanges > 0 then
                    hit = hasCodePoint(decodeAt(text, 1, len))
                end
            else
                hit = hasByte(b)
                if not hit and ci then
                    hit = hasByte(lowerByte(b)) or (b >= 97 and b <= 122 and hasByte(b - 32))
                end
            end
            if neg then
                if hit then
                    return nil
                end
                return i + len
            end
            if hit then
                return i + len
            end
        end
    end
    return nil
end

local function compileSequence(fns)
    if #fns == 0 then
        return function(st, i, k) return k(i) end
    end
    local f = fns[#fns]
    for j = #fns - 1, 1, -1 do
        local a, b = fns[j], f
        f = function(st, i, k)
            return a(st, i, function(i2) return b(st, i2, k) end)
        end
    end
    return f
end

local function compileRep(node)
    local min, max, lazy = node.min, node.max, node.lazy
    local step = singleStep(node.node)
    if step ~= nil then
        if lazy then
            return function(st, i, k)
                local count, pos = 0, i
                while count < min do
                    pos = step(st, pos)
                    if pos == nil then
                        return nil
                    end
                    count = count + 1
                end
                while true do
                    local r = k(pos)
                    if r then
                        return r
                    end
                    if count >= max then
                        return nil
                    end
                    pos = step(st, pos)
                    if pos == nil then
                        return nil
                    end
                    count = count + 1
                end
            end
        end
        return function(st, i, k)
            local positions = {i}
            local count, pos = 0, i
            while count < max do
                local nextPos = step(st, pos)
                if nextPos == nil then
                    break
                end
                count = count + 1
                pos = nextPos
                positions[count + 1] = pos
            end
            for c = count, min, -1 do
                local r = k(positions[c + 1])
                if r then
                    return r
                end
            end
            return nil
        end
    end
    local f = compile(node.node)
    return function(st, i, k)
        local function try(count, pos)
            if lazy and count >= min then
                local r = k(pos)
                if r then
                    return r
                end
            end
            if count < max then
                local r = f(st, pos, function(p2)
                    if p2 == pos and count >= min then
                        return nil
                    end
                    return try(count + 1, p2)
                end)
                if r then
                    return r
                end
            end
            if not lazy and count >= min then
                return k(pos)
            end
            return nil
        end
        return try(0, i)
    end
end

-- The index after the chars of `s` from index i that equal the chars of `text` ignoring case (ASCII, or by case folding when
-- `unicode`), or nil.
local function matchIgnoringCase(text, s, i, unicode)
    local fold = unicode and __K2L_Regex.____fold or nil
    local a, j = 1, i
    while a <= #text do
        local ca, cb = text:byte(a), s:byte(j)
        if cb == nil then
            return nil
        end
        local la, lb = 1, 1
        if fold ~= nil then
            if ca >= 0xC0 then la = charLength(ca) end
            if cb >= 0xC0 then lb = charLength(cb) end
            if fold(decodeAt(text, a, la)) ~= fold(decodeAt(s, j, lb)) then
                return nil
            end
        elseif lowerByte(ca) ~= lowerByte(cb) then
            return nil
        end
        a, j = a + la, j + lb
    end
    return j
end

function compile(node)
    local t = node.t
    local step = singleStep(node)
    if step ~= nil then
        return function(st, i, k)
            local nextPos = step(st, i)
            if nextPos then
                return k(nextPos)
            end
        end
    elseif t == "seq" then
        local fns = {}
        for j, item in ipairs(node.items) do
            fns[j] = compile(item)
        end
        return compileSequence(fns)
    elseif t == "alt" then
        local fns = {}
        for j, alt in ipairs(node.alts) do
            fns[j] = compile(alt)
        end
        return function(st, i, k)
            for _, f in ipairs(fns) do
                local r = f(st, i, k)
                if r then
                    return r
                end
            end
        end
    elseif t == "group" then
        local f, index = compile(node.node), node.index
        return function(st, i, k)
            return f(st, i, function(i2)
                local oldStart, oldEnd = st.starts[index], st.ends[index]
                st.starts[index], st.ends[index] = i, i2
                local r = k(i2)
                if not r then
                    st.starts[index], st.ends[index] = oldStart, oldEnd
                end
                return r
            end)
        end
    elseif t == "rep" then
        return compileRep(node)
    elseif t == "bol" then
        return function(st, i, k)
            if i == 1 or (node.multiline and st.bytes[i - 1] == 10) then
                return k(i)
            end
        end
    elseif t == "eol" then
        return function(st, i, k)
            local n = #st.s
            if i == n + 1 or (node.final and i == n and st.bytes[i] == 10)
                or (not node.absolute and (st.bytes[i] == 10 and (node.multiline or i == n))) then
                return k(i)
            end
        end
    elseif t == "wordb" then
        return function(st, i, k)
            local boundary = isWordByte(st.bytes[i - 1]) ~= isWordByte(st.bytes[i])
            if boundary ~= (node.neg == true) then
                return k(i)
            end
        end
    elseif t == "look" then
        local f = compile(node.node)
        return function(st, i, k)
            local found
            if node.ahead then
                found = f(st, i, function(i2) return i2 end)
            else
                for j = i, 1, -1 do
                    found = f(st, j, function(i2) if i2 == i then return i2 end end)
                    if found then
                        break
                    end
                end
            end
            if (found ~= nil and found ~= false) ~= node.neg then
                return k(i)
            end
        end
    elseif t == "atomic" then
        local f = compile(node.node)
        return function(st, i, k)
            local e = f(st, i, function(i2) return i2 end)
            if e then
                return k(e)
            end
        end
    elseif t == "backref" then
        return function(st, i, k)
            local index = node.index or st.names[node.name]
            local s, e = st.starts[index], st.ends[index]
            if s == nil then
                return nil
            end
            local text = st.s:sub(s, e - 1)
            if st.s:sub(i, i + #text - 1) == text then
                return k(i + #text)
            end
            if node.ci then
                local after = matchIgnoringCase(text, st.s, i, node.uni)
                if after then
                    return k(after)
                end
            end
        end
    end
    error("unsupported regex node " .. tostring(t))
end

------------------------------------------------------------------ MatchResult
-- The 4-byte character at i written as its two surrogate halves (3 bytes each), for a search that continues between them.
local function splitPair(s, i)
    local b1, b2, b3, b4 = s:byte(i, i + 3)
    local cp = (b1 - 0xF0) * 262144 + (b2 - 0x80) * 4096 + (b3 - 0x80) * 64 + (b4 - 0x80) - 0x10000
    return s:sub(1, i - 1) .. utf8Bytes(0xD800 + math.floor(cp / 1024)) .. utf8Bytes(0xDC00 + cp % 1024) .. s:sub(i + 4)
end

function __K2L_MatchGroup:____init(value, first, last)
    self.value = value
    self.range = __K2L_IntRange.new(first, last)
end

function __K2L_MatchGroup:toString()
    return "MatchGroup(value=" .. self.value .. ", range=" .. self.range:toString() .. ")"
end

function __K2L_MatchGroup:equals(other)
    return getmetatable(other) == __K2L_MatchGroup and self.value == other.value and self.range:equals(other.range)
end

-- groups[i] is the MatchGroup (nil for a group that did not take part in the match); groups["name"]
function __K2L_MatchGroups:getNamed(name)
    local index = self.names[name]
    if index == nil then
        error(__K2L_IllegalArgumentException.new("No group with name <" .. name .. "> exists"))
    end
    return self[index + 1]
end

function __K2L_MatchResult:____init(regex, input, first, after, st, groupCount)
    self.____regex, self.____input, self.____after = regex, input, after
    self.____empty = after == first
    self.____first = first
    local norm = __K2L_Regex.____norm or tostring
    self.value = norm(input:sub(first, after - 1))
    -- Indices are bytes, or UTF-16 units under --strings utf16 (see Utf16.lua)
    local units = __K2L_Regex.____units
    local function range(from, to)
        if units then
            return units.toUnit(input, from - 1), units.toUnit(input, to) - 1
        end
        return from - 1, to - 1
    end
    self.range = __K2L_IntRange.new(range(first, after - 1))
    local values, groups = {self.value}, {__K2L_MatchGroup.new(self.value, range(first, after - 1))}
    for g = 1, groupCount do
        local s, e = st.starts[g], st.ends[g]
        if s ~= nil then
            values[g + 1] = norm(input:sub(s, e - 1))
            groups[g + 1] = __K2L_MatchGroup.new(values[g + 1], range(s, e - 1))
        else
            values[g + 1] = ""
            groups[g + 1] = nil
        end
    end
    values.size, groups.size = groupCount + 1, groupCount + 1
    self.groupValues = setmetatable(values, __K2L_List)
    groups.names = regex.____names
    self.groups = setmetatable(groups, __K2L_MatchGroups)
    local rest = {}
    for g = 1, groupCount do
        rest[g] = values[g + 1]
    end
    rest.size = groupCount
    self.destructured = setmetatable(rest, __K2L_List)
end

function __K2L_MatchResult:next()
    local start, input = self.____after, self.____input
    if self.____empty then
        local b = input:byte(start)
        if __K2L_Regex.____units and b ~= nil and b >= 0xF0 then
            -- the next search starts one UTF-16 unit later, between the two halves of a surrogate pair
            input = splitPair(input, start)
            start = start + 3
        else
            start = start + 1
            if __K2L_Regex.____units then
                -- an empty match continues after the whole UTF-8 character
                b = input:byte(start)
                while b ~= nil and b >= 0x80 and b < 0xC0 do
                    start = start + 1
                    b = input:byte(start)
                end
            end
        end
    end
    return self.____regex:____find(input, start)
end

function __K2L_MatchResult:toString()
    return "MatchResult(value=" .. self.value .. ", range=" .. self.range:toString() .. ")"
end

------------------------------------------------------------------ Regex
local function optionSet(options)
    local set = {}
    if type(options) == "string" then
        set[options] = true
    elseif type(options) == "table" then
        local arr, n = options:____array()
        for i = 1, n do
            set[arr[i]] = true
        end
    end
    return set
end

-- Regex(pattern) and Regex(pattern, option or set of options)
-- Whether the node can match without consuming a character (so that Java also tries it between surrogate halves).
local function nullable(node)
    local t = node.t
    if t == "char" or t == "any" or t == "set" or t == "ufold" then
        return false
    elseif t == "seq" then
        for _, item in ipairs(node.items) do
            if not nullable(item) then
                return false
            end
        end
        return true
    elseif t == "alt" then
        for _, alt in ipairs(node.alts) do
            if nullable(alt) then
                return true
            end
        end
        return false
    elseif t == "group" or t == "atomic" then
        return nullable(node.node)
    elseif t == "rep" then
        return node.min == 0 or nullable(node.node)
    end
    return true
end

function __K2L_Regex:____init(pattern, options)
    -- two halves of a pair joined with + are one character
    pattern = (__K2L_Regex.____norm or tostring)(pattern)
    self.pattern = pattern
    local optionNames = optionSet(options)
    local node, groupCount, names = parse(pattern, optionNames)
    self.____nullable = nullable(node)
    self.____program = compile(node)
    self.____groups = groupCount
    self.____names = names
end

function __K2L_Regex:toString()
    return self.pattern
end

local function newState(self, s)
    -- st.bytes[i] is the byte at index i, filled lazily so long inputs are not copied
    local bytes = setmetatable({}, {__index = function(t, i)
        if i < 1 or i > #s then
            return nil
        end
        local b = s:byte(i)
        t[i] = b
        return b
    end})
    return {s = s, bytes = bytes, starts = {}, ends = {}, names = self.____names}
end

local function endsAtInputEnd(e, st)
    if e == #st.s + 1 then
        return e
    end
end

local function anyEnd(e)
    return e
end

function __K2L_Regex:____find(s, from)
    local st = newState(self, s)
    local utf8Aware = __K2L_Regex.____units ~= nil
    for i = from, #s + 1 do
        local b = utf8Aware and s:byte(i) or 0
        if b < 0x80 or b >= 0xC0 then
            local after = self.____program(st, i, anyEnd)
            if after then
                return __K2L_MatchResult.new(self, s, i, after, st, self.____groups)
            end
            if utf8Aware and self.____nullable and s:byte(i) ~= nil and s:byte(i) >= 0xF0 then
                -- Java also tries between the two halves of a surrogate pair
                local split = splitPair(s, i)
                local splitState = newState(self, split)
                after = self.____program(splitState, i + 3, anyEnd)
                if after then
                    return __K2L_MatchResult.new(self, split, i + 3, after, splitState, self.____groups)
                end
            end
        end
    end
    return nil
end

function __K2L_Regex:find(input, startIndex)
    startIndex = startIndex or 0
    local units = __K2L_Regex.____units
    local length = units and units.len(input) or #input
    if startIndex < 0 or startIndex > length then
        error(__K2L_IndexOutOfBoundsException.new("Start index out of bounds: " .. startIndex .. ", input length: " .. length))
    end
    return self:____find(input, (units and units.toByte(input, startIndex) or startIndex) + 1)
end

-- findAll's sequence: the factory of a generator that searches for each match when the previous one has been consumed
-- (after an empty match the search resumes one character later). The start index is checked right away, as in Kotlin.
function __K2L_Regex:findAllFactory(input, startIndex)
    startIndex = startIndex or 0
    local units = __K2L_Regex.____units
    local length = units and units.len(input) or #input
    if startIndex < 0 or startIndex > length then
        error(__K2L_IndexOutOfBoundsException.new("Start index out of bounds: " .. startIndex .. ", input length: " .. length))
    end
    return function()
        local match, started = nil, false
        return function()
            if not started then
                started = true
                match = self:find(input, startIndex)
            elseif match ~= nil then
                match = match:next()
                if match ~= nil and match.____first - 1 > #match.____input then
                    match = nil
                end
            end
            if match ~= nil then
                return true, match
            end
        end
    end
end

function __K2L_Regex:matchEntire(input)
    local st = newState(self, input)
    local after = self.____program(st, 1, function(e) return endsAtInputEnd(e, st) end)
    if after then
        return __K2L_MatchResult.new(self, input, 1, after, st, self.____groups)
    end
    return nil
end

function __K2L_Regex:matches(input)
    return self:matchEntire(input) ~= nil
end

function __K2L_Regex:containsMatchIn(input)
    return self:____find(input, 1) ~= nil
end

-- "$1", "${name}" and backslash escapes in a replacement string
local function expandReplacement(self, replacement, match)
    local out, i = {}, 1
    while i <= #replacement do
        local c = replacement:sub(i, i)
        if c == "\\" then
            i = i + 1
            if i > #replacement then
                error(__K2L_IllegalArgumentException.new("character to be escaped is missing"))
            end
            out[#out + 1] = replacement:sub(i, i)
            i = i + 1
        elseif c == "$" then
            i = i + 1
            local name = replacement:match("^{([%w_]+)}", i)
            local group
            if name ~= nil then
                i = i + #name + 2
                group = self.____names[name]
                if group == nil then
                    error(__K2L_IllegalArgumentException.new("No group with name {" .. name .. "}"))
                end
            else
                local digits = replacement:match("^%d", i)
                if digits == nil then
                    error(__K2L_IllegalArgumentException.new("Illegal group reference"))
                end
                group = tonumber(digits)
                i = i + 1
                -- further digits extend the reference while the group exists
                while true do
                    local more = replacement:match("^%d", i)
                    if more == nil or group * 10 + tonumber(more) > self.____groups then
                        break
                    end
                    group = group * 10 + tonumber(more)
                    i = i + 1
                end
                if group > self.____groups then
                    error(__K2L_IndexOutOfBoundsException.new("No group " .. group))
                end
            end
            out[#out + 1] = match.groupValues[group + 1]
        else
            out[#out + 1] = c
            i = i + 1
        end
    end
    return table.concat(out)
end

local function replaceMatches(self, input, replacement, onlyFirst)
    local out, last = {}, 1
    local match = self:____find(input, 1)
    while match ~= nil do
        input = match.____input -- a search between the halves of a pair continues on the string with them apart
        out[#out + 1] = input:sub(last, match.____first - 1)
        if type(replacement) == "function" then
            out[#out + 1] = __K2L_Str(replacement(match))
        else
            out[#out + 1] = expandReplacement(self, replacement, match)
        end
        last = match.____after
        if onlyFirst then
            break
        end
        match = match:next()
        if match ~= nil and match.____first - 1 >= #match.____input + 1 and match.____empty and last > #match.____input then
            break
        end
    end
    out[#out + 1] = input:sub(last)
    return (__K2L_Regex.____norm or tostring)(table.concat(out))
end

-- replacement: a string with $1 / ${name} references, or a function (MatchResult) -> String
function __K2L_Regex:replace(input, replacement)
    return replaceMatches(self, input, replacement, false)
end

function __K2L_Regex:replaceFirst(input, replacement)
    return replaceMatches(self, input, replacement, true)
end

function __K2L_Regex:split(input, limit)
    limit = limit or 0
    if limit < 0 then
        error(__K2L_IllegalArgumentException.new("Limit must be non-negative, but was " .. limit))
    end
    local match = self:____find(input, 1)
    if limit == 1 or match == nil then
        return __K2L_List.new():plus(input)
    end
    local out = __K2L_List.new()
    local last = 1
    local norm = __K2L_Regex.____norm or tostring
    repeat
        input = match.____input
        out:add(norm(input:sub(last, match.____first - 1)))
        last = match.____after
        if limit > 0 and out.size == limit - 1 then
            break
        end
        match = match:next()
    until match == nil
    out:add(norm(input:sub(last)))
    return out
end

function __K2L_Regex.escape(literal)
    return "\\Q" .. literal .. "\\E"
end

function __K2L_Regex.escapeReplacement(literal)
    return (literal:gsub("[\\$]", "\\%0"))
end

end
