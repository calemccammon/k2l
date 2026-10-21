-- requires: Strings, Collections, Exceptions, Compare
-- Strings with the JVM's UTF-16 semantics (--strings utf16). Lua strings stay UTF-8 (so they print and
-- concatenate normally), but `length`, indices and `Char`s count UTF-16 code units. A Char is the UTF-8
-- string of one code unit; a surrogate half (which UTF-8 cannot encode) is its 3-byte generalized form
-- (WTF-8), and two such halves are joined into the 4-byte form by `norm` (done wherever k2l builds strings
-- from chars). ASCII strings, checked once and cached, use the byte implementations of Strings.lua.
--
-- Loading this feature replaces the index-based members of __K2L_Text and of StringBuilder in place (and
-- the helpers of Utf16Case), so the rest of the lualib needs no changes.
local __K2L_Utf16 = {}

do
    local byte, char, sub, find, gsub, gmatch, concat, floor, rep =
        string.byte, string.char, string.sub, string.find, string.gsub, string.gmatch, table.concat, math.floor, string.rep
    local U = __K2L_Utf16
    local Text = __K2L_Text
    local SB = __K2L_StringBuilder
    local orig = {}
    for k, v in pairs(Text) do
        orig[k] = v
    end
    U.orig = orig

    local function illegalArgument(message)
        error(__K2L_IllegalArgumentException.new(message))
    end

    local function badIndex(message)
        error(__K2L_StringIndexOutOfBoundsException.new(message))
    end

    ---------------------------------------------------------------- UTF-8 <-> code units
    local function decode(s)
        local u, n, i, len = {}, 0, 1, #s
        while i <= len do
            local b = byte(s, i)
            if b < 0x80 then
                n = n + 1
                u[n] = b
                i = i + 1
            elseif b >= 0xF0 then
                local b2, b3, b4 = byte(s, i + 1, i + 3)
                local cp = (b - 0xF0) * 262144 + ((b2 or 0x80) - 0x80) * 4096 + ((b3 or 0x80) - 0x80) * 64 + ((b4 or 0x80) - 0x80) - 0x10000
                u[n + 1] = 0xD800 + floor(cp / 1024)
                u[n + 2] = 0xDC00 + cp % 1024
                n = n + 2
                i = i + 4
            elseif b >= 0xE0 then
                local b2, b3 = byte(s, i + 1, i + 2)
                n = n + 1
                u[n] = (b - 0xE0) * 4096 + ((b2 or 0x80) - 0x80) * 64 + ((b3 or 0x80) - 0x80)
                i = i + 3
            elseif b >= 0xC0 then
                n = n + 1
                u[n] = (b - 0xC0) * 64 + ((byte(s, i + 1) or 0x80) - 0x80)
                i = i + 2
            else
                n = n + 1
                u[n] = 0xFFFD
                i = i + 1
            end
        end
        -- clean: the last sequence ended at the end of s, so the units of s followed by another string are those of s
        -- followed by the other's (a StringBuilder adds up the units of its pieces)
        u.n, u.clean = n, i == len + 1
        return u
    end

    -- One code unit as a Char (a surrogate half becomes its 3-byte form).
    local function unitChar(c)
        if c < 0x80 then
            return char(c)
        elseif c < 0x800 then
            return char(0xC0 + floor(c / 64), 0x80 + c % 64)
        end
        return char(0xE0 + floor(c / 4096), 0x80 + floor(c / 64) % 64, 0x80 + c % 64)
    end

    local function pairChar(hi, lo)
        local cp = 0x10000 + (hi - 0xD800) * 1024 + (lo - 0xDC00)
        return char(0xF0 + floor(cp / 262144), 0x80 + floor(cp / 4096) % 64, 0x80 + floor(cp / 64) % 64, 0x80 + cp % 64)
    end

    -- Code units i..j (1-based, inclusive) as a string; a high surrogate followed by a low one becomes one character.
    local function encode(u, i, j)
        local out, n = {}, 0
        while i <= j do
            local c = u[i]
            n = n + 1
            if c >= 0xD800 and c <= 0xDBFF and i < j and u[i + 1] >= 0xDC00 and u[i + 1] <= 0xDFFF then
                out[n] = pairChar(c, u[i + 1])
                i = i + 2
            else
                out[n] = unitChar(c)
                i = i + 1
            end
        end
        return concat(out)
    end

    -- Joins surrogate halves that sit next to each other as two 3-byte sequences into the 4-byte form.
    local function norm(s)
        if not find(s, "\237", 1, true) then
            return s
        end
        return (gsub(s, "\237([\160-\175])([\128-\191])\237([\176-\191])([\128-\191])", function(a, b, c, d)
            local hi = 0xD000 + (byte(a) - 0x80) * 64 + (byte(b) - 0x80)
            local lo = 0xD000 + (byte(c) - 0x80) * 64 + (byte(d) - 0x80)
            return pairChar(hi, lo)
        end))
    end
    U.norm = norm

    ---------------------------------------------------------------- the per-string unit cache
    local cache, cacheSize = {}, 0
    local CACHE_LIMIT = 256

    -- The code units of s (an array with field n), or nil when s is ASCII.
    local function units(s)
        local c = cache[s]
        if c == nil then
            if find(s, "[\128-\255]") then
                c = decode(s)
            else
                c = true
            end
            if cacheSize >= CACHE_LIMIT then
                cache, cacheSize = {}, 0
            end
            cache[s] = c
            cacheSize = cacheSize + 1
        end
        if c == true then
            return nil
        end
        return c
    end

    -- The code units of any string, ASCII ones included, as (array, count).
    local function array(s)
        local u = units(s)
        if u then
            return u, u.n
        end
        local a = {}
        for i = 1, #s do
            a[i] = byte(s, i)
        end
        return a, #s
    end

    local function length(s)
        local c = cache[s]
        if c == true then
            return #s
        end
        local u = c or units(s)
        return u and u.n or #s
    end
    U.len = length
    Text.len = length
    U.units = units
    U.array = array
    U.encode = encode
    U.unitChar = unitChar

    ---------------------------------------------------------------- chars
    function U.char(code)
        return unitChar(code % 65536)
    end

    function U.code(c)
        local b, b2, b3 = byte(c, 1, 3)
        if b < 0x80 then
            return b
        elseif b < 0xE0 then
            return (b - 0xC0) * 64 + (b2 - 0x80)
        end
        return (b - 0xE0) * 4096 + (b2 - 0x80) * 64 + (b3 - 0x80)
    end

    function U.charAt(s, i)
        local u = units(s)
        if not u then
            if i < 0 or i >= #s then
                badIndex("Index " .. i .. " out of bounds for length " .. #s)
            end
            return sub(s, i + 1, i + 1)
        end
        if i < 0 or i >= u.n then
            badIndex("Index " .. i .. " out of bounds for length " .. u.n)
        end
        return unitChar(u[i + 1])
    end

    -- What print writes: the JVM encodes an unpaired surrogate as '?'
    function U.out(s)
        if type(s) == "string" and find(s, "\237", 1, true) then
            return (gsub(s, "\237[\160-\191][\128-\191]", "?"))
        end
        return s
    end

    -- s[i] when i is known to be in range
    function U.at(s, i)
        local u = units(s)
        if not u then
            return sub(s, i + 1, i + 1)
        end
        return unitChar(u[i + 1])
    end

    -- A Char as a code unit, for the loops over a string
    function U.each(s)
        local u = units(s)
        if not u then
            return gmatch(s, ".")
        end
        local i, n = 0, u.n
        return function()
            i = i + 1
            if i <= n then
                return unitChar(u[i])
            end
        end
    end
    Text.eachChar = U.each

    function Text.joinChars(chars)
        return U.norm(concat(chars))
    end

    -- The chars of s as a Lua array, and their count
    local function chars(s)
        local u = units(s)
        local out = {}
        if not u then
            for i = 1, #s do
                out[i] = sub(s, i, i)
            end
            return out, #s
        end
        for i = 1, u.n do
            out[i] = unitChar(u[i])
        end
        return out, u.n
    end
    U.chars = chars

    -- Chars [i, j] of an array of chars as a string
    local function joinChars(cs, i, j)
        return norm(concat(cs, "", i, j))
    end

    function U.isHighSurrogate(c) local x = U.code(c) return x >= 0xD800 and x <= 0xDBFF end
    function U.isLowSurrogate(c) local x = U.code(c) return x >= 0xDC00 and x <= 0xDFFF end
    function U.isSurrogate(c) local x = U.code(c) return x >= 0xD800 and x <= 0xDFFF end

    ---------------------------------------------------------------- order and hashing
    function Text.compare(a, b)
        local ua, ub = units(a), units(b)
        if not ua and not ub then
            return orig.compare(a, b)
        end
        local xa, na = array(a)
        local xb, nb = array(b)
        for i = 1, math.min(na, nb) do
            if xa[i] ~= xb[i] then
                return xa[i] - xb[i]
            end
        end
        return na - nb
    end

    ---------------------------------------------------------------- substrings
    local function checkSub(from, to, n)
        if from < 0 or from > to or to > n then
            badIndex("Range [" .. from .. ", " .. to .. ") out of bounds for length " .. n)
        end
    end

    function Text.substring(s, from, to)
        local u = units(s)
        if not u then
            return orig.substring(s, from, to)
        end
        to = to or u.n
        checkSub(from, to, u.n)
        return encode(u, from + 1, to)
    end

    local function checkCount(n)
        if n < 0 then
            illegalArgument("Requested character count " .. n .. " is less than zero.")
        end
    end

    function Text.take(s, n)
        local u = units(s)
        if not u then
            return orig.take(s, n)
        end
        checkCount(n)
        return encode(u, 1, math.min(n, u.n))
    end

    function Text.drop(s, n)
        local u = units(s)
        if not u then
            return orig.drop(s, n)
        end
        checkCount(n)
        return encode(u, n + 1, u.n)
    end

    function Text.takeLast(s, n)
        local u = units(s)
        if not u then
            return orig.takeLast(s, n)
        end
        checkCount(n)
        return encode(u, math.max(u.n - n + 1, 1), u.n)
    end

    function Text.dropLast(s, n)
        local u = units(s)
        if not u then
            return orig.dropLast(s, n)
        end
        checkCount(n)
        return encode(u, 1, math.max(u.n - n, 0))
    end

    function Text.takeWhile(s, predicate)
        local u = units(s)
        if not u then
            return orig.takeWhile(s, predicate)
        end
        for i = 1, u.n do
            if not predicate(unitChar(u[i])) then
                return encode(u, 1, i - 1)
            end
        end
        return s
    end

    function Text.dropWhile(s, predicate)
        local u = units(s)
        if not u then
            return orig.dropWhile(s, predicate)
        end
        for i = 1, u.n do
            if not predicate(unitChar(u[i])) then
                return encode(u, i, u.n)
            end
        end
        return ""
    end

    function Text.takeLastWhile(s, predicate)
        local u = units(s)
        if not u then
            return orig.takeLastWhile(s, predicate)
        end
        for i = u.n, 1, -1 do
            if not predicate(unitChar(u[i])) then
                return encode(u, i + 1, u.n)
            end
        end
        return s
    end

    function Text.dropLastWhile(s, predicate)
        local u = units(s)
        if not u then
            return orig.dropLastWhile(s, predicate)
        end
        for i = u.n, 1, -1 do
            if not predicate(unitChar(u[i])) then
                return encode(u, 1, i)
            end
        end
        return ""
    end

    function Text.filter(s, predicate)
        local u = units(s)
        if not u then
            return orig.filter(s, predicate)
        end
        local out, n = {}, 0
        for i = 1, u.n do
            local c = unitChar(u[i])
            if predicate(c) then
                n = n + 1
                out[n] = c
            end
        end
        return norm(concat(out))
    end

    function Text.filterNot(s, predicate)
        return Text.filter(s, function(c) return not predicate(c) end)
    end

    function Text.filterIndexed(s, predicate)
        local u = units(s)
        if not u then
            return orig.filterIndexed(s, predicate)
        end
        local out, n = {}, 0
        for i = 1, u.n do
            local c = unitChar(u[i])
            if predicate(i - 1, c) then
                n = n + 1
                out[n] = c
            end
        end
        return norm(concat(out))
    end

    function Text.partition(s, predicate)
        local u = units(s)
        if not u then
            return orig.partition(s, predicate)
        end
        local yes, no = {}, {}
        for i = 1, u.n do
            local c = unitChar(u[i])
            local into = predicate(c) and yes or no
            into[#into + 1] = c
        end
        return __K2L_Pair.new(norm(concat(yes)), norm(concat(no)))
    end

    local function checkRange(n, from, to)
        if to < from then
            error(__K2L_IndexOutOfBoundsException.new("End index (" .. to .. ") is less than start index (" .. from .. ")."))
        end
        if from < 0 or to > n then
            error(__K2L_IndexOutOfBoundsException.new("begin " .. from .. ", end " .. to .. ", length " .. n))
        end
    end

    function Text.removeRange(s, from, to)
        local u = units(s)
        if not u then
            return orig.removeRange(s, from, to)
        end
        checkRange(u.n, from, to)
        return norm(encode(u, 1, from) .. encode(u, to + 1, u.n))
    end

    function Text.replaceRange(s, from, to, replacement)
        local u = units(s)
        if not u then
            return orig.replaceRange(s, from, to, replacement)
        end
        checkRange(u.n, from, to)
        return norm(encode(u, 1, from) .. replacement .. encode(u, to + 1, u.n))
    end

    function Text.slice(s, indices)
        if type(indices.first) == "number" then
            return indices.last < indices.first and "" or Text.substring(s, indices.first, indices.last + 1)
        end
        local out = {}
        local arr, n = indices:____array()
        for i = 1, n do
            out[i] = U.charAt(s, arr[i])
        end
        return norm(concat(out))
    end

    function Text.get(s, index)
        return U.charAt(s, index)
    end

    function Text.getOrNull(s, index)
        if index < 0 or index >= length(s) then
            return nil
        end
        return U.charAt(s, index)
    end

    -- an ASCII first byte is the first unit; the last byte is the last unit when it and the three bytes before it are
    -- ASCII (no lead byte can reach it), without decoding (or caching) the string
    function Text.first(s)
        local b = byte(s, 1)
        if b ~= nil and b < 0x80 then
            return sub(s, 1, 1)
        end
        local u = units(s)
        if not u then
            return orig.first(s)
        end
        return unitChar(u[1])
    end

    function Text.last(s)
        local n = #s
        if n >= 4 then
            local b1, b2, b3, b4 = byte(s, n - 3, n)
            if b1 < 0x80 and b2 < 0x80 and b3 < 0x80 and b4 < 0x80 then
                return sub(s, n)
            end
        end
        local u = units(s)
        if not u then
            return orig.last(s)
        end
        return unitChar(u[u.n])
    end

    function Text.single(s)
        local u = units(s)
        if not u then
            return orig.single(s)
        elseif u.n > 1 then
            illegalArgument("Char sequence has more than one element.")
        end
        return unitChar(u[1])
    end

    function Text.toCharArray(s)
        local out, n = chars(s)
        out.size = n
        return setmetatable(out, __K2L_ArrayClassOf("[C"))
    end

    function Text.toList(s)
        local list = __K2L_List.new()
        local cs, n = chars(s)
        for i = 1, n do
            list:add(cs[i])
        end
        return list
    end

    -- String(chars): the chars are joined, and halves of surrogate pairs become one character.
    function Text.string(arr)
        return norm(arr:joinToString(""))
    end

    function Text.reversed(s)
        if not units(s) then
            return s:reverse()
        end
        -- reverse by characters, so that surrogate pairs stay in order
        local cs, n = {}, 0
        for ch in gmatch(s, "[\1-\127\194-\244][\128-\191]*") do
            n = n + 1
            cs[n] = ch
        end
        local out = {}
        for i = 1, n do
            out[i] = cs[n - i + 1]
        end
        return concat(out)
    end

    -- Does the string whose units are a (n of them) have a surrogate pair starting at the 0-based index idx?
    local function pairAt(a, n, idx)
        return idx >= 0 and idx <= n - 2 and a[idx + 1] >= 0xD800 and a[idx + 1] <= 0xDBFF and a[idx + 2] >= 0xDC00 and a[idx + 2] <= 0xDFFF
    end

    function Text.commonPrefixWith(a, b)
        if not units(a) and not units(b) then
            return orig.commonPrefixWith(a, b)
        end
        local xa, na = array(a)
        local xb, nb = array(b)
        local n = 0
        while n < na and n < nb and xa[n + 1] == xb[n + 1] do
            n = n + 1
        end
        if pairAt(xa, na, n - 1) or pairAt(xb, nb, n - 1) then
            n = n - 1
        end
        return encode(xa, 1, n)
    end

    function Text.commonSuffixWith(a, b)
        if not units(a) and not units(b) then
            return orig.commonSuffixWith(a, b)
        end
        local xa, na = array(a)
        local xb, nb = array(b)
        local n = 0
        while n < na and n < nb and xa[na - n] == xb[nb - n] do
            n = n + 1
        end
        if pairAt(xa, na, na - n - 1) or pairAt(xb, nb, nb - n - 1) then
            n = n - 1
        end
        return encode(xa, na - n + 1, na)
    end

    function Text.chunked(s, size, transform)
        local u = units(s)
        if not u then
            return orig.chunked(s, size, transform)
        end
        if size <= 0 then
            illegalArgument("size " .. size .. " must be greater than zero.")
        end
        local out = __K2L_List.new()
        for i = 1, u.n, size do
            local chunk = encode(u, i, math.min(i + size - 1, u.n))
            if transform ~= nil then
                chunk = transform(chunk)
            end
            out:add(chunk)
        end
        return out
    end

    function Text.windowed(s, size, step, partial, transform)
        local u = units(s)
        if not u then
            return orig.windowed(s, size, step, partial, transform)
        end
        step = step or 1
        if size <= 0 or step <= 0 then
            illegalArgument(size ~= step and "Both size " .. size .. " and step " .. step .. " must be greater than zero."
                or "size " .. size .. " must be greater than zero.")
        end
        local out = __K2L_List.new()
        local i = 1
        while i <= u.n and (partial or i + size - 1 <= u.n) do
            local window = encode(u, i, math.min(i + size - 1, u.n))
            if transform ~= nil then
                window = transform(window)
            end
            out:add(window)
            i = i + step
        end
        return out
    end

    function Text.replaceFirstChar(s, transform)
        local u = units(s)
        if not u then
            return orig.replaceFirstChar(s, transform)
        end
        return norm(transform(unitChar(u[1])) .. encode(u, 2, u.n))
    end

    ---------------------------------------------------------------- padding
    local function checkPadLength(length)
        if length < 0 then
            illegalArgument("Desired length " .. length .. " is less than zero.")
        end
    end

    function Text.padStart(s, n, pad)
        checkPadLength(n)
        return rep(pad or " ", n - length(s)) .. s
    end

    function Text.padEnd(s, n, pad)
        checkPadLength(n)
        return s .. rep(pad or " ", n - length(s))
    end

    ---------------------------------------------------------------- searching
    -- Text is searched by code units; ignoreCase compares units through U.foldUnit (Utf16Case replaces it).
    function U.foldUnit(c)
        if c >= 65 and c <= 90 then
            return c + 32
        end
        return c
    end

    local function unitsEqual(a, b, ignoreCase)
        return a == b or (ignoreCase and U.foldUnit(a) == U.foldUnit(b))
    end

    local function matchesAt(a, i, b, m, ignoreCase)
        for k = 1, m do
            if not unitsEqual(a[i + k - 1], b[k], ignoreCase) then
                return false
            end
        end
        return true
    end

    function Text.indexOf(s, part, from, ignoreCase)
        if not ignoreCase and not units(s) and not units(part) then
            return orig.indexOf(s, part, from)
        end
        local a, n = array(s)
        local b, m = array(part)
        local start = math.max(from or 0, 0)
        if m == 0 then
            return math.min(start, n)
        end
        for i = start + 1, n - m + 1 do
            if matchesAt(a, i, b, m, ignoreCase) then
                return i - 1
            end
        end
        return -1
    end

    function Text.lastIndexOf(s, part, from, ignoreCase)
        if not ignoreCase and not units(s) and not units(part) then
            return orig.lastIndexOf(s, part, from)
        end
        local a, n = array(s)
        local b, m = array(part)
        local last = n - m
        if from == nil then
            last = math.min(last, n - 1) -- the default start index is lastIndex
        elseif from < last then
            last = from
        end
        for i = last, 0, -1 do
            if m == 0 or matchesAt(a, i + 1, b, m, ignoreCase) then
                return i
            end
        end
        return -1
    end

    function Text.startsWithAt(s, prefix, start)
        return Text.regionMatches(s, start, prefix, 0, length(prefix))
    end

    function Text.regionMatches(s, thisOffset, other, otherOffset, len, ignoreCase)
        local a, n = array(s)
        local b, m = array(other)
        if otherOffset < 0 or thisOffset < 0 or thisOffset > n - len or otherOffset > m - len then
            return false
        end
        for k = 1, len do
            if not unitsEqual(a[thisOffset + k], b[otherOffset + k], ignoreCase) then
                return false
            end
        end
        return true
    end

    -- The empty delimiter splits between all chars; other delimiters work on the UTF-8 bytes.
    function Text.split(s, delimiters, limit, ignoreCase)
        local su = units(s)
        if su and ignoreCase and not (#delimiters == 1 and delimiters[1] == "") then
            limit = limit or 0
            local out = __K2L_List.new()
            local pos = 0
            while limit == 0 or out.size < limit - 1 do
                local best, bestLen
                for _, d in ipairs(delimiters) do
                    if d ~= "" then
                        local i = Text.indexOf(s, d, pos, true)
                        if i >= 0 and (best == nil or i < best) then
                            best, bestLen = i, length(d)
                        end
                    end
                end
                if best == nil then
                    break
                end
                out:add(encode(su, pos + 1, best))
                pos = best + bestLen
            end
            out:add(encode(su, pos + 1, su.n))
            return out
        end
        if not su or #delimiters ~= 1 or delimiters[1] ~= "" then
            return orig.split(s, delimiters, limit, ignoreCase)
        end
        limit = limit or 0
        if limit < 0 then
            illegalArgument("Limit must be non-negative, but was " .. limit)
        end
        local u = units(s)
        local out = __K2L_List.new()
        out:add("")
        local i = 1
        while i <= u.n and (limit == 0 or out.size < limit - 1) do
            out:add(encode(u, i, i))
            i = i + 1
        end
        out:add(i <= u.n and encode(u, i, u.n) or "")
        return out
    end

    function Text.replace(s, old, new, ignoreCase, onlyFirst)
        if ignoreCase and old ~= "" and units(s) then
            -- case-insensitive search by code units (the byte version lowercases the UTF-8)
            local u = units(s)
            local m = length(old)
            local out, pos = {}, 0
            while true do
                local i = Text.indexOf(s, old, pos, true)
                if i < 0 then
                    break
                end
                out[#out + 1] = encode(u, pos + 1, i)
                out[#out + 1] = new
                pos = i + m
                if onlyFirst then
                    break
                end
            end
            out[#out + 1] = encode(u, pos + 1, u.n)
            return norm(concat(out))
        end
        if old ~= "" or not units(s) then
            return orig.replace(s, old, new, ignoreCase, onlyFirst)
        end
        -- an empty old value matches between every pair of chars
        local u = units(s)
        local parts = {new}
        for i = 1, u.n do
            parts[#parts + 1] = unitChar(u[i])
            parts[#parts + 1] = (not onlyFirst or i == 1) and new or ""
        end
        return norm(concat(parts))
    end

    ---------------------------------------------------------------- one half of a surrogate pair as the needle
    -- A byte search cannot find one half of a pair inside the 4-byte character that the text holds. Searching a copy of
    -- the text with its pairs written as two halves can (like the JVM's search by code units); `norm` joins the halves
    -- that stay together in the result.
    local function hasLoneHalf(part)
        return type(part) == "string" and find(part, "\237[\160-\191]") ~= nil
    end

    local function halved(s)
        if not find(s, "[\240-\244]") then
            return s
        end
        return (gsub(s, "[\240-\244][\128-\191][\128-\191][\128-\191]", function(c)
            local b1, b2, b3, b4 = byte(c, 1, 4)
            local cp = (b1 - 0xF0) * 262144 + (b2 - 0x80) * 4096 + (b3 - 0x80) * 64 + (b4 - 0x80) - 0x10000
            return unitChar(0xD800 + floor(cp / 1024)) .. unitChar(0xDC00 + cp % 1024)
        end))
    end

    local function joined(result)
        if type(result) == "string" then
            return norm(result)
        elseif type(result) == "table" and result.size ~= nil then
            for i = 1, result.size do
                result[i] = norm(result[i])
            end
        end
        return result
    end

    -- a needle, or the delimiters of split (a plain Lua list)
    local function anyLoneHalf(needle)
        if type(needle) == "table" and needle.size == nil then
            for _, delimiter in ipairs(needle) do
                if hasLoneHalf(delimiter) then
                    return true
                end
            end
            return false
        end
        return hasLoneHalf(needle)
    end

    for _, name in ipairs({
        "replace", "replaceFirst", "split", "removePrefix", "removeSuffix", "removeSurrounding", "substringBefore", "substringAfter",
        "substringBeforeLast", "substringAfterLast",
    }) do
        local base = Text[name]
        Text[name] = function(s, needle, second, ...)
            if units(s) and (anyLoneHalf(needle) or (name == "removeSurrounding" and hasLoneHalf(second))) then
                return joined(base(halved(s), needle, second, ...))
            end
            return base(s, needle, second, ...)
        end
    end

    function Text.contains(s, part)
        if hasLoneHalf(part) and units(s) then
            s = halved(s)
        end
        return find(s, part, 1, true) ~= nil
    end

    function Text.startsWith(s, prefix)
        if hasLoneHalf(prefix) and units(s) then
            s = halved(s)
        end
        return sub(s, 1, #prefix) == prefix
    end

    function Text.endsWith(s, suffix)
        if hasLoneHalf(suffix) and units(s) then
            s = halved(s)
        end
        return suffix == "" or sub(s, -#suffix) == suffix
    end

    ---------------------------------------------------------------- trimming
    -- Character.isWhitespace or isSpaceChar for a code unit.
    function U.isSpaceUnit(c)
        if c < 128 then
            return c == 32 or (c >= 9 and c <= 13) or (c >= 28 and c <= 31)
        end
        -- the Zs, Zl and Zp separators (Character.isWhitespace or isSpaceChar)
        return c == 0xA0 or c == 0x1680 or (c >= 0x2000 and c <= 0x200A) or c == 0x2028 or c == 0x2029
            or c == 0x202F or c == 0x205F or c == 0x3000
    end

    local function trimUnits(u, first, last, mode, matches)
        if mode % 2 == 1 then
            while first <= last and matches(u[first]) do
                first = first + 1
            end
        end
        if mode >= 2 then
            while last >= first and matches(u[last]) do
                last = last - 1
            end
        end
        return first, last
    end

    -- mode: 1 trimStart, 2 trimEnd, 3 trim
    local function trimWhitespace(s, mode)
        local u = units(s)
        if not u then
            if mode == 3 then
                return (s:match("^[\9-\13\28-\32]*(.-)[\9-\13\28-\32]*$"))
            elseif mode == 1 then
                return (s:match("^[\9-\13\28-\32]*(.*)$"))
            end
            return (s:match("^(.-)[\9-\13\28-\32]*$"))
        end
        local first, last = trimUnits(u, 1, u.n, mode, U.isSpaceUnit)
        return encode(u, first, last)
    end

    function Text.trim(s) return trimWhitespace(s, 3) end
    function Text.trimStart(s) return trimWhitespace(s, 1) end
    function Text.trimEnd(s) return trimWhitespace(s, 2) end

    function Text.isBlank(s)
        local u = units(s)
        if not u then
            return s:match("^[\9-\13\28-\32]*$") ~= nil
        end
        for i = 1, u.n do
            if not U.isSpaceUnit(u[i]) then
                return false
            end
        end
        return true
    end

    function Text.ifBlank(s, default)
        if Text.isBlank(s) then
            return default()
        end
        return s
    end

    -- trimIndent, trimMargin and prependIndent measure indents in chars by Char.isWhitespace (Unicode), not by the ASCII spaces
    -- of the byte versions in Strings.lua.
    local function indentWidth(line)
        local u = units(line)
        if not u then
            return #line:match("^[\9-\13\28-\32]*")
        end
        for i = 1, u.n do
            if not U.isSpaceUnit(u[i]) then
                return i - 1
            end
        end
        return u.n
    end

    -- the first and last line numbers kept: a blank first or last line is dropped
    local function keptLines(lines)
        local first, last = 1, lines.size
        if first <= last and Text.isBlank(lines[first]) then
            first = first + 1
        end
        if last >= first and Text.isBlank(lines[last]) then
            last = last - 1
        end
        return first, last
    end

    function Text.trimIndent(s)
        local lines = Text.lines(s)
        local minIndent
        for i = 1, lines.size do
            if not Text.isBlank(lines[i]) then
                local width = indentWidth(lines[i])
                minIndent = minIndent and math.min(minIndent, width) or width
            end
        end
        local first, last = keptLines(lines)
        local out = {}
        for i = first, last do
            out[#out + 1] = Text.drop(lines[i], minIndent or 0)
        end
        return concat(out, "\n")
    end

    function Text.trimMargin(s, prefix)
        prefix = prefix or "|"
        if Text.isBlank(prefix) then
            illegalArgument("marginPrefix must be non-blank string.")
        end
        local lines = Text.lines(s)
        local first, last = keptLines(lines)
        local out = {}
        for i = first, last do
            local line = lines[i]
            local rest = Text.drop(line, indentWidth(line))
            if rest ~= "" and sub(rest, 1, #prefix) == prefix then
                out[#out + 1] = sub(rest, #prefix + 1)
            else
                out[#out + 1] = line
            end
        end
        return concat(out, "\n")
    end

    function Text.prependIndent(s, indent)
        local lines = Text.lines(s)
        local out = {}
        for i = 1, lines.size do
            local line = lines[i]
            if Text.isBlank(line) then
                out[i] = length(line) < length(indent) and indent or line
            else
                out[i] = indent .. line
            end
        end
        return norm(concat(out, "\n"))
    end

    local function trimByChars(s, mode, matches)
        local u = units(s)
        if not u then
            local first, last = 1, #s
            if mode % 2 == 1 then
                while first <= last and matches(sub(s, first, first)) do
                    first = first + 1
                end
            end
            if mode >= 2 then
                while last >= first and matches(sub(s, last, last)) do
                    last = last - 1
                end
            end
            return sub(s, first, last)
        end
        local first, last = trimUnits(u, 1, u.n, mode, function(c) return matches(unitChar(c)) end)
        return encode(u, first, last)
    end

    function Text.trimChars(s, mode, ...)
        local set = {}
        for _, c in ipairs({...}) do
            set[c] = true
        end
        return trimByChars(s, mode, function(c) return set[c] == true end)
    end

    function Text.trimWith(s, mode, predicate)
        return trimByChars(s, mode, predicate)
    end

    ---------------------------------------------------------------- code points
    local function codePointAtUnits(a, n, i)
        local hi = a[i + 1]
        if hi >= 0xD800 and hi <= 0xDBFF and i + 1 < n then
            local lo = a[i + 2]
            if lo >= 0xDC00 and lo <= 0xDFFF then
                return 0x10000 + (hi - 0xD800) * 1024 + (lo - 0xDC00)
            end
        end
        return hi
    end

    function U.codePointAt(s, i)
        local a, n = array(s)
        if i < 0 or i >= n then
            badIndex("Index " .. i .. " out of bounds for length " .. n)
        end
        return codePointAtUnits(a, n, i)
    end

    function U.codePointBefore(s, i)
        local a, n = array(s)
        if i < 1 or i > n then
            badIndex("Index " .. i .. " out of bounds for length " .. n)
        end
        local lo = a[i]
        if lo >= 0xDC00 and lo <= 0xDFFF and i >= 2 then
            local hi = a[i - 1]
            if hi >= 0xD800 and hi <= 0xDBFF then
                return 0x10000 + (hi - 0xD800) * 1024 + (lo - 0xDC00)
            end
        end
        return lo
    end

    -- The number of code points in [from, to)
    function U.codePointCount(s, from, to)
        local a, n = array(s)
        if from < 0 or to > n or from > to then
            error(__K2L_IndexOutOfBoundsException.new("begin " .. from .. ", end " .. to .. ", length " .. n))
        end
        local count, i = 0, from
        while i < to do
            local c = a[i + 1]
            if c >= 0xD800 and c <= 0xDBFF and i + 1 < to and a[i + 2] >= 0xDC00 and a[i + 2] <= 0xDFFF then
                i = i + 1
            end
            i = i + 1
            count = count + 1
        end
        return count
    end

    function U.offsetByCodePoints(s, index, offset)
        local a, n = array(s)
        local i = index
        for _ = 1, offset do
            if i >= n then
                error(__K2L_IndexOutOfBoundsException.new(""))
            end
            i = i + (a[i + 1] >= 0xD800 and a[i + 1] <= 0xDBFF and i + 1 < n and a[i + 2] >= 0xDC00 and a[i + 2] <= 0xDFFF and 2 or 1)
        end
        return i
    end

    -- The Unicode scalar values of s as an IntStream (see Streams.lua)
    function U.codePoints(s)
        local a, n = array(s)
        local out, count, i = {}, 0, 0
        while i < n do
            local cp = codePointAtUnits(a, n, i)
            count = count + 1
            out[count] = cp
            i = i + (cp >= 0x10000 and 2 or 1)
        end
        out.size = count
        local stream = __K2L_Streams.of(__K2L_IntStream, setmetatable(out, __K2L_List))
        stream.____size = nil -- codePoints() is not a SIZED stream
        return stream
    end

    function U.chars16(s)
        local a, n = array(s)
        local out = {}
        for i = 1, n do
            out[i] = a[i]
        end
        out.size = n
        return __K2L_Streams.of(__K2L_IntStream, setmetatable(out, __K2L_List))
    end

    -- Character.toChars(cp), appendCodePoint, Character.charCount
    local function codePointString(cp)
        if cp < 0 or cp > 0x10FFFF then
            illegalArgument(string.format("Not a valid Unicode code point: 0x%X", cp))
        end
        if cp < 0x10000 then
            return unitChar(cp)
        end
        local v = cp - 0x10000
        return pairChar(0xD800 + floor(v / 1024), 0xDC00 + v % 1024)
    end
    U.codePointString = codePointString

    function U.toChars(cp)
        if cp < 0 or cp > 0x10FFFF then
            illegalArgument(string.format("Not a valid Unicode code point: 0x%X", cp))
        end
        local out
        if cp < 0x10000 then
            out = {unitChar(cp), size = 1}
        else
            local v = cp - 0x10000
            out = {unitChar(0xD800 + floor(v / 1024)), unitChar(0xDC00 + v % 1024), size = 2}
        end
        return setmetatable(out, __K2L_ArrayClassOf("[C"))
    end

    function U.charCount(cp) return cp >= 0x10000 and 2 or 1 end
    function U.isSupplementaryCodePoint(cp) return cp >= 0x10000 and cp <= 0x10FFFF end
    function U.isBmpCodePoint(cp) return cp >= 0 and cp < 0x10000 end
    function U.isValidCodePoint(cp) return cp >= 0 and cp <= 0x10FFFF end
    function U.toCodePoint(hi, lo) return 0x10000 + (U.code(hi) - 0xD800) * 1024 + (U.code(lo) - 0xDC00) end
    function U.highSurrogate(cp) return unitChar(0xD800 + floor((cp - 0x10000) / 1024)) end
    function U.lowSurrogate(cp) return unitChar(0xDC00 + (cp - 0x10000) % 1024) end

    -- For Regex indices, kept with the units of s (built once, so that the indices of many matches in a long string take
    -- a lookup each): starts[j], the byte where the sequence decode read code unit j from starts, and ends[j], the length
    -- of encode(u, 1, j).
    local function offsets(s, u)
        local starts, ends = u.starts, u.ends
        if starts == nil then
            starts, ends = {}, {[0] = 0}
            local i, n, len = 1, 0, #s
            -- the steps of decode
            while i <= len do
                local b = byte(s, i)
                n = n + 1
                starts[n] = i
                if b >= 0xF0 then
                    n = n + 1
                    starts[n] = i
                    i = i + 4
                else
                    i = i + (b >= 0xE0 and 3 or b >= 0xC0 and 2 or 1)
                end
            end
            -- encode joins a high surrogate and the low one after it into 4 bytes; any other unit is unitChar
            for j = 1, u.n do
                local c = u[j]
                if c >= 0xDC00 and c <= 0xDFFF and j > 1 and u[j - 1] >= 0xD800 and u[j - 1] <= 0xDBFF then
                    ends[j] = ends[j - 2] + 4
                else
                    ends[j] = ends[j - 1] + (c < 0x80 and 1 or c < 0x800 and 2 or 3)
                end
            end
            u.starts, u.ends = starts, ends
        end
        return starts, ends
    end

    -- The UTF-16 index of the character after the first `bytes` bytes of s (the units decode reads from them), and the
    -- other way round (used by Regex)
    function U.byteToUnit(s, bytes)
        local u = bytes ~= 0 and units(s)
        if not u then
            return bytes
        end
        -- the number of units whose sequence starts within the first `bytes` bytes
        local starts = offsets(s, u)
        local low, high = 0, u.n
        while low < high do
            local mid = floor((low + high + 1) / 2)
            if starts[mid] <= bytes then
                low = mid
            else
                high = mid - 1
            end
        end
        return low
    end

    function U.unitToByte(s, index)
        local u = units(s)
        if not u then
            return index
        end
        local _, ends = offsets(s, u)
        return ends[math.max(0, math.min(index, u.n))]
    end

    ---------------------------------------------------------------- char ranges
    -- 'a'..'z' with the endpoints as Chars; the codes are UTF-16 units
    local CharRange = __K2L_Class("kotlin.ranges.CharRange", __K2L_CharRange)
    U.CharRange = CharRange

    function CharRange:____array()
        local out, n = {}, 0
        for c = U.code(self.first), U.code(self.last), self.step do
            n = n + 1
            out[n] = unitChar(c)
        end
        return out, n
    end

    function CharRange:contains(value)
        local c = U.code(value)
        local first, last = U.code(self.first), U.code(self.last)
        if self.step > 0 then
            return c >= first and c <= last and (c - first) % self.step == 0
        end
        return c <= first and c >= last and (first - c) % -self.step == 0
    end

    function CharRange:isEmpty()
        local first, last = U.code(self.first), U.code(self.last)
        return self.step > 0 and first > last or self.step < 0 and first < last
    end

    function CharRange:withStep(step)
        return CharRange.new(self.first, self.last, self.step > 0 and step or -step)
    end

    function CharRange:reversed()
        return CharRange.new(self.last, self.first, -self.step)
    end

    function CharRange:equals(other)
        return getmetatable(other) == CharRange and (self:isEmpty() and other:isEmpty() or
            self.first == other.first and self.last == other.last and self.step == other.step)
    end

    ---------------------------------------------------------------- StringBuilder
    local toString, append, setText = SB.toString, SB.append, SB.____setText

    function SB:toString()
        local s = toString(self)
        local fixed = norm(s)
        if fixed ~= s then
            -- joined surrogate halves: the same units
            local count = self.____units
            setText(self, fixed)
            self.____units = count
        end
        return fixed
    end

    SB.__tostring = SB.toString

    -- ____units is the length in UTF-16 units while it is known: the sum of the units of the pieces, as long as every
    -- piece is ASCII or a clean sequence of characters (see decode); unknown after the other edits, until measured
    function SB:append(text)
        local count = self.____units
        if count ~= nil then
            local u = units(text)
            if u == nil then
                self.____units = count + #text
            elseif u.clean then
                self.____units = count + u.n
            else
                self.____units = nil
            end
        end
        return append(self, text)
    end

    function SB:appendLine(text)
        return self:append((text or "") .. "\n")
    end

    function SB:getLength()
        local count = self.____units
        if count == nil then
            local s = self:toString()
            local u = units(s)
            if u == nil then
                count = #s
                self.____units = count
            else
                count = u.n
                if u.clean then
                    self.____units = count
                end
            end
        end
        return count
    end

    function SB:isEmpty() return self:getLength() == 0 end
    function SB:isNotEmpty() return self:getLength() > 0 end

    function SB:reverse()
        setText(self, Text.reversed(self:toString()))
        return self
    end

    local function outOfBounds(message)
        error(__K2L_IndexOutOfBoundsException.new(message))
    end

    function SB:get(index)
        local s = self:toString()
        local n = length(s)
        if index < 0 or index >= n then
            outOfBounds("index " .. index .. ",length " .. n)
        end
        return U.charAt(s, index)
    end

    -- the units of the content as a string: [from, to) with 0-based bounds
    local function part(s, from, to)
        return Text.substring(s, from, to)
    end

    function SB:set(index, c)
        local s = self:toString()
        local n = length(s)
        if index < 0 or index >= n then
            outOfBounds("index " .. index .. ",length " .. n)
        end
        setText(self, norm(part(s, 0, index) .. c .. part(s, index + 1, n)))
    end

    function SB:insert(index, text)
        local s = self:toString()
        local n = length(s)
        if index < 0 or index > n then
            outOfBounds("offset " .. index .. ", length " .. n)
        end
        setText(self, norm(part(s, 0, index) .. text .. part(s, index, n)))
        return self
    end

    function SB:deleteCharAt(index)
        local s = self:toString()
        local n = length(s)
        if index < 0 or index >= n then
            outOfBounds("index " .. index .. ",length " .. n)
        end
        setText(self, norm(part(s, 0, index) .. part(s, index + 1, n)))
        return self
    end

    function SB:delete(from, to)
        local s = self:toString()
        local n = length(s)
        to = math.min(to, n)
        if from < 0 or from > to then
            outOfBounds("start " .. from .. ", end " .. to .. ", length " .. n)
        end
        setText(self, norm(part(s, 0, from) .. part(s, to, n)))
        return self
    end

    function SB:replace(from, to, text)
        local s = self:toString()
        local n = length(s)
        to = math.min(to, n)
        if from < 0 or from > n or from > to then
            outOfBounds("start " .. from .. ", end " .. to .. ", length " .. n)
        end
        setText(self, norm(part(s, 0, from) .. text .. part(s, to, n)))
        return self
    end

    function SB:setLength(len)
        local s = self:toString()
        local n = length(s)
        if len < 0 then
            outOfBounds(tostring(len))
        end
        setText(self, n >= len and part(s, 0, len) or s .. rep("\0", len - n))
    end

    function SB:substring(from, to)
        local s = self:toString()
        local n = length(s)
        to = to or n
        if from < 0 or from > to or to > n then
            outOfBounds("start " .. from .. ", end " .. to .. ", length " .. n)
        end
        return part(s, from, to)
    end

    function SB:appendCodePoint(cp)
        return self:append(codePointString(cp))
    end

    -- Regex match ranges and start indices count UTF-16 units too (Regex.lua loads before this file when it is used)
    if __K2L_Regex ~= nil then
        __K2L_Regex.____units = {len = length, toUnit = U.byteToUnit, toByte = U.unitToByte}
        __K2L_Regex.____norm = norm
    end
end
