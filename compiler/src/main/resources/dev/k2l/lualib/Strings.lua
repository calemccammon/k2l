-- requires: Collections, Exceptions, Str, Compare, Numbers, Pair
-- Kotlin String functions. Strings are Lua byte strings; indices count bytes.

local function __K2L_PatternEscape(s)
    return (s:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0"))
end

-- s[i] and s.get(i): Java's charAt.
local function __K2L_StringCharAt(s, i)
    if i < 0 or i >= #s then
        error(__K2L_StringIndexOutOfBoundsException.new("Index " .. i .. " out of bounds for length " .. #s))
    end
    return s:sub(i + 1, i + 1)
end

local function __K2L_StringStartsWith(s, prefix)
    return s:sub(1, #prefix) == prefix
end

local function __K2L_StringEndsWith(s, suffix)
    return suffix == "" or s:sub(-#suffix) == suffix
end

local function __K2L_StringContains(s, part)
    return s:find(part, 1, true) ~= nil
end

-- Kotlin's String.indexOf, lastIndexOf, replace, split(String) and lines(), see __K2L_Text below.
local __K2L_Text = {}

local function __K2L_StringIndexOf(s, part, from)
    return __K2L_Text.indexOf(s, part, from)
end

local function __K2L_StringLastIndexOf(s, part)
    return __K2L_Text.lastIndexOf(s, part)
end

local function __K2L_StringReplace(s, old, new)
    return __K2L_Text.replace(s, old, new)
end

local function __K2L_StringSplit(s, delimiter)
    return __K2L_Text.split(s, {delimiter})
end

local function __K2L_StringLines(s)
    return __K2L_Text.lines(s)
end

local function __K2L_StringTrim(s)
    return (s:match("^%s*(.-)%s*$"))
end

local function __K2L_StringTrimStart(s)
    return (s:match("^%s*(.*)$"))
end

local function __K2L_StringTrimEnd(s)
    return (s:match("^(.-)%s*$"))
end

local function __K2L_StringIsBlank(s)
    return s:match("^%s*$") ~= nil
end

local function checkPadLength(length)
    if length < 0 then
        error(__K2L_IllegalArgumentException.new("Desired length " .. length .. " is less than zero."))
    end
end

local function __K2L_StringPadStart(s, length, pad)
    checkPadLength(length)
    pad = pad or " "
    return string.rep(pad, length - #s) .. s
end

local function __K2L_StringPadEnd(s, length, pad)
    checkPadLength(length)
    pad = pad or " "
    return s .. string.rep(pad, length - #s)
end

-- String.toInt / toLong (radix 10 unless given); returns nil for malformed or out-of-range text.
local function __K2L_StringToIntOrNull(s, radix, long)
    radix = radix or 10
    local sign, digits = s:match("^([+-]?)(%w+)$")
    if digits == nil then
        return nil
    end
    local acc, facc = 0, 0.0
    for i = 1, #digits do
        local d = tonumber(digits:sub(i, i), 36)
        if d == nil or d >= radix then
            return nil
        end
        acc = acc * radix + d
        facc = facc * radix + d
    end
    if long and math.type then
        if facc >= 9.3e18 or (acc < 0 and not (sign == "-" and acc == math.mininteger)) then
            return nil
        end
    else
        local limit = long and 9223372036854775807 or 2147483647
        if facc > (sign == "-" and limit + 1 or limit) then
            return nil
        end
    end
    if acc == 0 then
        return 0
    end
    return sign == "-" and -acc or acc
end

local function __K2L_StringToInt(s, radix, long)
    local n = __K2L_StringToIntOrNull(s, radix, long)
    if n == nil then
        local suffix = (radix ~= nil and radix ~= 10) and " under radix " .. radix or ""
        error(__K2L_NumberFormatException.new("For input string: \"" .. s .. "\"" .. suffix))
    end
    return n
end

local function __K2L_StringToDoubleOrNull(s)
    local trimmed = __K2L_StringTrim(s)
    if trimmed == "NaN" then
        return 0 / 0
    elseif trimmed == "Infinity" or trimmed == "+Infinity" then
        return math.huge
    elseif trimmed == "-Infinity" then
        return -math.huge
    end
    trimmed = trimmed:gsub("^(.*%d)[fFdD]$", "%1")
    if trimmed == "" or trimmed:match("^[+-]?0[xX]") or trimmed:match("[nN]") then
        return nil
    end
    local n = tonumber(trimmed)
    return n and n + 0.0
end

local function __K2L_StringToDouble(s)
    local n = __K2L_StringToDoubleOrNull(s)
    if n == nil then
        local trimmed = __K2L_StringTrim(s)
        error(__K2L_NumberFormatException.new(trimmed == "" and "empty String" or "For input string: \"" .. s .. "\""))
    end
    return n
end

local function __K2L_StringToList(s)
    local out = __K2L_List.new()
    for i = 1, #s do
        out:add(s:sub(i, i))
    end
    return out
end

local function __K2L_StringEqualsIgnoreCase(a, b)
    return a ~= nil and b ~= nil and a:lower() == b:lower()
end

------------------------------------------------------------------ String helpers
-- Functions of kotlin.text taking a String receiver first; chars are one-character strings.
local __K2L_StringFormat

do

local function illegalArgument(message)
    error(__K2L_IllegalArgumentException.new(message))
end

local function chars(s)
    local out = {}
    for i = 1, #s do
        out[i] = s:sub(i, i)
    end
    return out
end

-- Java's String.compareTo: the difference of the first differing chars, else of the lengths.
function __K2L_Text.compare(a, b)
    local n = math.min(#a, #b)
    for i = 1, n do
        local x, y = a:byte(i), b:byte(i)
        if x ~= y then
            return x - y
        end
    end
    return #a - #b
end

function __K2L_Text.substring(s, from, to)
    to = to or #s
    if from < 0 or from > to or to > #s then
        error(__K2L_StringIndexOutOfBoundsException.new("Range [" .. from .. ", " .. to .. ") out of bounds for length " .. #s))
    end
    return s:sub(from + 1, to)
end

function __K2L_Text.take(s, n)
    if n < 0 then
        illegalArgument("Requested character count " .. n .. " is less than zero.")
    end
    return s:sub(1, n)
end

function __K2L_Text.drop(s, n)
    if n < 0 then
        illegalArgument("Requested character count " .. n .. " is less than zero.")
    end
    return s:sub(n + 1)
end

function __K2L_Text.takeLast(s, n)
    if n < 0 then
        illegalArgument("Requested character count " .. n .. " is less than zero.")
    end
    return n == 0 and "" or s:sub(-n)
end

function __K2L_Text.dropLast(s, n)
    if n < 0 then
        illegalArgument("Requested character count " .. n .. " is less than zero.")
    end
    return s:sub(1, math.max(#s - n, 0))
end

function __K2L_Text.takeWhile(s, predicate)
    for i = 1, #s do
        if not predicate(s:sub(i, i)) then
            return s:sub(1, i - 1)
        end
    end
    return s
end

function __K2L_Text.dropWhile(s, predicate)
    for i = 1, #s do
        if not predicate(s:sub(i, i)) then
            return s:sub(i)
        end
    end
    return ""
end

function __K2L_Text.takeLastWhile(s, predicate)
    for i = #s, 1, -1 do
        if not predicate(s:sub(i, i)) then
            return s:sub(i + 1)
        end
    end
    return s
end

function __K2L_Text.dropLastWhile(s, predicate)
    for i = #s, 1, -1 do
        if not predicate(s:sub(i, i)) then
            return s:sub(1, i)
        end
    end
    return ""
end

function __K2L_Text.filter(s, predicate)
    local out = {}
    for i = 1, #s do
        local c = s:sub(i, i)
        if predicate(c) then
            out[#out + 1] = c
        end
    end
    return table.concat(out)
end

function __K2L_Text.filterNot(s, predicate)
    return __K2L_Text.filter(s, function(c) return not predicate(c) end)
end

function __K2L_Text.filterIndexed(s, predicate)
    local out = {}
    for i = 1, #s do
        local c = s:sub(i, i)
        if predicate(i - 1, c) then
            out[#out + 1] = c
        end
    end
    return table.concat(out)
end

function __K2L_Text.partition(s, predicate)
    local yes, no = {}, {}
    for i = 1, #s do
        local c = s:sub(i, i)
        local into = predicate(c) and yes or no
        into[#into + 1] = c
    end
    return __K2L_Pair.new(table.concat(yes), table.concat(no))
end

function __K2L_Text.substringBefore(s, delimiter, missing)
    local i = s:find(delimiter, 1, true)
    if i == nil then
        return missing or s
    end
    return s:sub(1, i - 1)
end

function __K2L_Text.substringAfter(s, delimiter, missing)
    local _, j = s:find(delimiter, 1, true)
    if j == nil then
        return missing or s
    end
    return s:sub(j + 1)
end

local function lastIndexOf(s, part)
    local last
    local i = s:find(part, 1, true)
    while i do
        last = i
        i = s:find(part, i + 1, true)
    end
    return last
end

function __K2L_Text.substringBeforeLast(s, delimiter, missing)
    local i = lastIndexOf(s, delimiter)
    if i == nil then
        return missing or s
    end
    return s:sub(1, i - 1)
end

function __K2L_Text.substringAfterLast(s, delimiter, missing)
    local i = lastIndexOf(s, delimiter)
    if i == nil then
        return missing or s
    end
    return s:sub(i + #delimiter)
end

function __K2L_Text.removePrefix(s, prefix)
    if s:sub(1, #prefix) == prefix then
        return s:sub(#prefix + 1)
    end
    return s
end

function __K2L_Text.removeSuffix(s, suffix)
    if suffix ~= "" and s:sub(-#suffix) == suffix then
        return s:sub(1, #s - #suffix)
    end
    return s
end

function __K2L_Text.removeSurrounding(s, prefix, suffix)
    suffix = suffix or prefix
    if #s >= #prefix + #suffix and s:sub(1, #prefix) == prefix and (suffix == "" or s:sub(-#suffix) == suffix) then
        return s:sub(#prefix + 1, #s - #suffix)
    end
    return s
end

local function checkRange(s, from, to)
    if to < from then
        error(__K2L_IndexOutOfBoundsException.new("End index (" .. to .. ") is less than start index (" .. from .. ")."))
    end
    if from < 0 or to > #s then
        error(__K2L_IndexOutOfBoundsException.new("begin " .. from .. ", end " .. to .. ", length " .. #s))
    end
end

function __K2L_Text.removeRange(s, from, to)
    checkRange(s, from, to)
    return s:sub(1, from) .. s:sub(to + 1)
end

function __K2L_Text.removeRangeOf(s, range)
    return __K2L_Text.removeRange(s, range.first, range.last + 1)
end

function __K2L_Text.replaceRange(s, from, to, replacement)
    checkRange(s, from, to)
    return s:sub(1, from) .. replacement .. s:sub(to + 1)
end

function __K2L_Text.replaceRangeOf(s, range, replacement)
    return __K2L_Text.replaceRange(s, range.first, range.last + 1, replacement)
end

function __K2L_Text.substringOf(s, range)
    return __K2L_Text.substring(s, range.first, range.last + 1)
end

function __K2L_Text.slice(s, indices)
    if type(indices.first) == "number" then
        return indices.last < indices.first and "" or __K2L_Text.substringOf(s, indices)
    end
    local out = {}
    local arr, n = indices:____array()
    for i = 1, n do
        out[i] = s:sub(arr[i] + 1, arr[i] + 1)
    end
    return table.concat(out)
end

-- trim / trimStart / trimEnd with a char set or a predicate. `mode` is 1 (start), 2 (end) or 3 (both).
local function trimBy(s, mode, matches)
    local from, to = 1, #s
    if mode % 2 == 1 then
        while from <= to and matches(s:sub(from, from)) do
            from = from + 1
        end
    end
    if mode >= 2 then
        while to >= from and matches(s:sub(to, to)) do
            to = to - 1
        end
    end
    return s:sub(from, to)
end

function __K2L_Text.trimChars(s, mode, ...)
    local set = {}
    for _, c in ipairs({...}) do
        set[c] = true
    end
    return trimBy(s, mode, function(c) return set[c] == true end)
end

function __K2L_Text.trimWith(s, mode, predicate)
    return trimBy(s, mode, predicate)
end

function __K2L_Text.first(s)
    if s == "" then
        error(__K2L_NoSuchElementException.new("Char sequence is empty."))
    end
    return s:sub(1, 1)
end

function __K2L_Text.last(s)
    if s == "" then
        error(__K2L_NoSuchElementException.new("Char sequence is empty."))
    end
    return s:sub(-1)
end

function __K2L_Text.single(s)
    if s == "" then
        error(__K2L_NoSuchElementException.new("Char sequence is empty."))
    elseif #s > 1 then
        illegalArgument("Char sequence has more than one element.")
    end
    return s
end

function __K2L_Text.getOrNull(s, index)
    if index < 0 or index >= #s then
        return nil
    end
    return s:sub(index + 1, index + 1)
end

function __K2L_Text.get(s, index)
    return __K2L_StringCharAt(s, index)
end

function __K2L_Text.first(s)
    if s == "" then
        error(__K2L_NoSuchElementException.new("Char sequence is empty."))
    end
    return s:sub(1, 1)
end

function __K2L_Text.last(s)
    if s == "" then
        error(__K2L_NoSuchElementException.new("Char sequence is empty."))
    end
    return s:sub(-1)
end

function __K2L_Text.repeatCount(s, n)
    if n < 0 then
        illegalArgument("Count 'n' must be non-negative, but was " .. n .. ".")
    end
    return s:rep(n)
end

function __K2L_Text.toCharArray(s)
    local out = chars(s)
    out.size = #s
    return setmetatable(out, __K2L_Array)
end

function __K2L_Text.toByteArray(s)
    local out = {}
    for i = 1, #s do
        local b = s:byte(i)
        out[i] = b >= 128 and b - 256 or b
    end
    out.size = #s
    return setmetatable(out, __K2L_Array)
end

function __K2L_Text.ifEmpty(s, default)
    if s == "" then
        return default()
    end
    return s
end

function __K2L_Text.ifBlank(s, default)
    if s:match("^%s*$") then
        return default()
    end
    return s
end

function __K2L_Text.commonPrefixWith(a, b)
    local n = math.min(#a, #b)
    for i = 1, n do
        if a:byte(i) ~= b:byte(i) then
            return a:sub(1, i - 1)
        end
    end
    return a:sub(1, n)
end

function __K2L_Text.commonSuffixWith(a, b)
    local n = math.min(#a, #b)
    for i = 1, n do
        if a:byte(-i) ~= b:byte(-i) then
            return a:sub(#a - i + 2)
        end
    end
    return a:sub(#a - n + 1)
end

function __K2L_Text.chunked(s, size, transform)
    if size <= 0 then
        illegalArgument("size " .. size .. " must be greater than zero.")
    end
    local out = __K2L_List.new()
    for i = 1, #s, size do
        local chunk = s:sub(i, i + size - 1)
        out:add(transform and transform(chunk) or chunk)
    end
    return out
end

function __K2L_Text.windowed(s, size, step, partial, transform)
    step = step or 1
    if size <= 0 or step <= 0 then
        illegalArgument(size ~= step and "Both size " .. size .. " and step " .. step .. " must be greater than zero."
            or "size " .. size .. " must be greater than zero.")
    end
    local out = __K2L_List.new()
    local i = 1
    while i <= #s and (partial or i + size - 1 <= #s) do
        local window = s:sub(i, i + size - 1)
        out:add(transform and transform(window) or window)
        i = i + step
    end
    return out
end

function __K2L_Text.caseInsensitiveOrder(a, b)
    return __K2L_Compare(a:lower(), b:lower())
end

-- Replacement without regex semantics; `limit` of 1 replaces only the first match.
function __K2L_Text.replace(s, old, new, ignoreCase, onlyFirst)
    local haystack = ignoreCase and s:lower() or s
    local needle = ignoreCase and old:lower() or old
    local out, pos = {}, 1
    if needle == "" then
        -- an empty old value matches between every pair of characters
        local parts = {new}
        for i = 1, #s do
            parts[#parts + 1] = s:sub(i, i)
            if not onlyFirst or i == 1 then
                parts[#parts + 1] = new
            else
                parts[#parts + 1] = ""
            end
        end
        return table.concat(parts)
    end
    while true do
        local i, j = haystack:find(needle, pos, true)
        if i == nil then
            break
        end
        out[#out + 1] = s:sub(pos, i - 1)
        out[#out + 1] = new
        pos = j + 1
        if onlyFirst then
            break
        end
    end
    out[#out + 1] = s:sub(pos)
    return table.concat(out)
end

function __K2L_Text.replaceFirst(s, old, new, ignoreCase)
    return __K2L_Text.replace(s, old, new, ignoreCase, true)
end

function __K2L_Text.replaceFirstChar(s, transform)
    if s == "" then
        return s
    end
    return transform(s:sub(1, 1)) .. s:sub(2)
end

-- split(vararg delimiters, ignoreCase, limit)
function __K2L_Text.split(s, delimiters, limit, ignoreCase)
    limit = limit or 0
    if limit < 0 then
        illegalArgument("Limit must be non-negative, but was " .. limit)
    end
    local out = __K2L_List.new()
    if #delimiters == 1 and delimiters[1] == "" then
        out:add("")
        local i = 1
        while i <= #s and (limit == 0 or out.size < limit - 1) do
            out:add(s:sub(i, i))
            i = i + 1
        end
        out:add(i <= #s and s:sub(i) or "")
        return out
    end
    local haystack = ignoreCase and s:lower() or s
    local pos = 1
    while limit == 0 or out.size < limit - 1 do
        local bestI, bestJ
        for _, d in ipairs(delimiters) do
            if d ~= "" then
                local i, j = haystack:find(ignoreCase and d:lower() or d, pos, true)
                if i ~= nil and (bestI == nil or i < bestI) then
                    bestI, bestJ = i, j
                end
            end
        end
        if bestI == nil then
            break
        end
        out:add(s:sub(pos, bestI - 1))
        pos = bestJ + 1
    end
    out:add(s:sub(pos))
    return out
end

function __K2L_Text.indexOf(s, part, from, ignoreCase)
    if ignoreCase then
        s, part = s:lower(), part:lower()
    end
    local i = s:find(part, math.max((from or 0), 0) + 1, true)
    return i and i - 1 or -1
end

function __K2L_Text.lastIndexOf(s, part, from, ignoreCase)
    if ignoreCase then
        s, part = s:lower(), part:lower()
    end
    local last = -1
    local i = s:find(part, 1, true)
    while i and (from == nil or i - 1 <= from) do
        last = i - 1
        i = s:find(part, i + 1, true)
    end
    return last
end

function __K2L_Text.indexOfAny(s, candidates, from)
    local best = -1
    local arr, n = candidates:____array()
    for i = 1, n do
        local at = __K2L_Text.indexOf(s, arr[i], from)
        if at >= 0 and (best < 0 or at < best) then
            best = at
        end
    end
    return best
end

function __K2L_Text.toBoolean(s)
    return s ~= nil and s:lower() == "true"
end

function __K2L_Text.toBooleanStrict(s)
    if s == "true" then
        return true
    elseif s == "false" then
        return false
    end
    illegalArgument("The string doesn't represent a boolean value: " .. s)
end

function __K2L_Text.toBooleanStrictOrNull(s)
    if s == "true" then
        return true
    elseif s == "false" then
        return false
    end
    return nil
end

function __K2L_Text.string(array)
    return array:joinToString("")
end

function __K2L_Text.lines(s)
    return __K2L_Text.split((s:gsub("\r\n", "\n"):gsub("\r", "\n")), {"\n"})
end

-- trimIndent / trimMargin / prependIndent
local function lineList(s)
    return __K2L_Text.lines(s)
end

local function isBlankLine(line)
    return line:match("^%s*$") ~= nil
end

local function dropEdgeBlanks(lines)
    local first, last = 1, lines.size
    if first <= last and isBlankLine(lines[first]) then
        first = first + 1
    end
    if last >= first and isBlankLine(lines[last]) then
        last = last - 1
    end
    return first, last
end

function __K2L_Text.trimIndent(s)
    local lines = lineList(s)
    local minIndent
    for i = 1, lines.size do
        if not isBlankLine(lines[i]) then
            local indent = #lines[i]:match("^%s*")
            minIndent = minIndent and math.min(minIndent, indent) or indent
        end
    end
    local first, last = dropEdgeBlanks(lines)
    local out = {}
    for i = first, last do
        out[#out + 1] = lines[i]:sub((minIndent or 0) + 1)
    end
    return table.concat(out, "\n")
end

function __K2L_Text.trimMargin(s, prefix)
    prefix = prefix or "|"
    local lines = lineList(s)
    local first, last = dropEdgeBlanks(lines)
    local out = {}
    for i = first, last do
        local line = lines[i]
        local indent = line:match("^%s*")
        if line:sub(#indent + 1, #indent + #prefix) == prefix then
            out[#out + 1] = line:sub(#indent + #prefix + 1)
        else
            out[#out + 1] = line
        end
    end
    return table.concat(out, "\n")
end

-- prependIndent(indent): blank lines shorter than the indent become the indent.
function __K2L_Text.prependIndent(s, indent)
    local lines = __K2L_Text.lines(s)
    local out = {}
    for i = 1, lines.size do
        local line = lines[i]
        if isBlankLine(line) then
            out[i] = #line < #indent and indent or line
        else
            out[i] = indent .. line
        end
    end
    return table.concat(out, "\n")
end

-- regionMatches(thisOffset, other, otherOffset, length, ignoreCase)
function __K2L_Text.regionMatches(s, thisOffset, other, otherOffset, length, ignoreCase)
    if otherOffset < 0 or thisOffset < 0 or thisOffset > #s - length or otherOffset > #other - length then
        return false
    end
    local a, b = s:sub(thisOffset + 1, thisOffset + length), other:sub(otherOffset + 1, otherOffset + length)
    if ignoreCase then
        a, b = a:lower(), b:lower()
    end
    return a == b
end

------------------------------------------------------------------ String.format
-- java.util.Formatter: %[index$][flags][width][.precision]conversion

-- Shortest round-tripping decimal digits of |x| and the decimal exponent of the first digit.
local function decimalDigits(x)
    x = math.abs(x)
    if x == 0 then
        return "0", 0
    end
    local s
    for precision = 0, 16 do
        s = string.format("%." .. precision .. "e", x)
        if tonumber(s) == x then
            break
        end
    end
    local int, frac, exp = s:match("^(%d)%.?(%d*)e([-+]%d+)$")
    local digits = (int .. frac):gsub("0+$", "")
    if digits == "" then
        digits = "0"
    end
    return digits, tonumber(exp)
end

-- Adds one to a string of decimal digits: "199" -> "200", "99" -> "100".
local function incrementDecimal(str)
    local i = #str
    while i >= 1 do
        if str:sub(i, i) == "9" then
            i = i - 1
        else
            return str:sub(1, i - 1) .. string.char(str:byte(i) + 1) .. string.rep("0", #str - i)
        end
    end
    return "1" .. string.rep("0", #str)
end

-- Rounds the digits half up to `keep` digits (0 or more) and returns the kept digits.
local function roundDigits(digits, keep)
    if keep >= #digits then
        return digits .. string.rep("0", keep - #digits)
    end
    local kept = digits:sub(1, keep)
    if digits:byte(keep + 1) >= 53 then
        return keep == 0 and "1" or incrementDecimal(kept)
    end
    return keep == 0 and "0" or kept
end

-- |x| as integer and fractional digit strings, rounded half up on the shortest decimal digits (as Java does).
local function fixedNotation(x, precision)
    local digits, exp = decimalDigits(x)
    local scaled
    if x == 0 then
        scaled = "0"
    else
        -- x = D * 10^(exp + 1 - #digits); we want round(x * 10^precision)
        local keep = exp + 1 + precision
        if keep < 0 then
            scaled = "0"
        else
            scaled = roundDigits(digits, keep)
            if keep > #digits then
                scaled = digits .. string.rep("0", keep - #digits)
            end
        end
    end
    if #scaled <= precision then
        scaled = string.rep("0", precision - #scaled + 1) .. scaled
    end
    return scaled:sub(1, #scaled - precision), scaled:sub(#scaled - precision + 1)
end

local function scientificNotation(x, precision, upper)
    local digits, exp = decimalDigits(x)
    local rounded = roundDigits(digits, precision + 1)
    if #rounded > precision + 1 then
        exp = exp + 1
        rounded = rounded:sub(1, precision + 1)
    end
    if x == 0 then
        exp = 0
    end
    local mantissa = rounded:sub(1, 1)
    if precision > 0 then
        mantissa = mantissa .. "." .. rounded:sub(2)
    end
    return mantissa .. (upper and "E" or "e") .. string.format("%s%02d", exp < 0 and "-" or "+", math.abs(exp))
end

local function groupThousands(int)
    local out = int:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    return (out:gsub("^,", ""))
end

-- Applies sign, grouping, zero padding and width to a formatted magnitude.
local function finishNumber(body, negative, flags, width)
    local sign = ""
    if negative then
        sign = flags.paren and "(" or "-"
    elseif flags.plus then
        sign = "+"
    elseif flags.space then
        sign = " "
    end
    local suffix = (negative and flags.paren) and ")" or ""
    local text = sign .. body .. suffix
    if width and #text < width then
        if flags.zero then
            text = sign .. string.rep("0", width - #text) .. body .. suffix
        elseif flags.left then
            text = text .. string.rep(" ", width - #text)
        else
            text = string.rep(" ", width - #text) .. text
        end
    end
    return text
end

local function pad(text, width, left)
    if width and #text < width then
        if left then
            return text .. string.rep(" ", width - #text)
        end
        return string.rep(" ", width - #text) .. text
    end
    return text
end

local function formatFloat(conv, value, flags, width, precision)
    if value ~= value then
        return pad("NaN", width, flags.left)
    elseif value == math.huge or value == -math.huge then
        local body = "Infinity"
        local negative = value < 0
        return pad((negative and (flags.paren and "(" or "-") or (flags.plus and "+" or (flags.space and " " or ""))) ..
            body .. ((negative and flags.paren) and ")" or ""), width, flags.left)
    end
    local negative = value < 0 or (value == 0 and 1 / value < 0)
    local body
    if conv == "f" then
        local int, frac = fixedNotation(value, precision)
        if flags.comma then
            int = groupThousands(int)
        end
        body = precision > 0 and int .. "." .. frac or int
        if flags.alt and precision == 0 then
            body = body .. "."
        end
    elseif conv == "e" or conv == "E" then
        body = scientificNotation(value, precision, conv == "E")
    else
        -- %g: scientific for small or large magnitudes, fixed otherwise, `precision` significant digits
        local p = precision == 0 and 1 or precision
        local abs = math.abs(value)
        if abs ~= 0 and (abs < 1e-4 or abs >= 10 ^ p) then
            body = scientificNotation(value, p - 1, conv == "G")
        else
            local _, exp = decimalDigits(value)
            local int, frac = fixedNotation(value, math.max(p - (abs == 0 and 1 or exp + 1), 0))
            body = #frac > 0 and int .. "." .. frac or int
        end
    end
    return finishNumber(body, negative, flags, width)
end

local function formatInteger(conv, value, flags, width)
    if conv == "d" then
        local negative = value < 0
        local body
        if math.type and math.type(value) == "integer" then
            body = (tostring(value):gsub("^-", ""))
        else
            body = string.format("%.0f", math.abs(value))
        end
        if flags.comma then
            body = groupThousands(body)
        end
        return finishNumber(body, negative, flags, width)
    end
    local radix = conv == "o" and 8 or 16
    local body
    if value >= 0 then
        body = __K2L_Num.toRadix(value, radix)
    elseif value >= -2147483648 then
        body = __K2L_Num.toRadix(value % 4294967296, radix)
    else
        body = __K2L_Num.toRadix(value % 18446744073709551616, radix)
    end
    if conv == "X" then
        body = body:upper()
    end
    if flags.alt then
        body = (radix == 8 and "0" or (conv == "X" and "0X" or "0x")) .. body
    end
    if width and #body < width then
        if flags.zero then
            body = string.rep("0", width - #body) .. body
        else
            return pad(body, width, flags.left)
        end
    end
    return body
end

local function missingArgument(spec)
    error(__K2L_IllegalArgumentException.new("Format specifier '" .. spec .. "'"))
end

function __K2L_StringFormat(format, ...)
    local n = select("#", ...)
    local args = {...}
    local out = {}
    local nextArg = 0
    local pos = 1
    while pos <= #format do
        local percent = format:find("%", pos, true)
        if percent == nil then
            out[#out + 1] = format:sub(pos)
            break
        end
        out[#out + 1] = format:sub(pos, percent - 1)
        local spec, index, flagText, widthText, precisionText, conv =
            format:match("^(%%(%d*%$?)([-#+ 0,(]*)(%d*)%.?(%d*)([a-zA-Z%%]))", percent)
        if spec == nil then
            error(__K2L_IllegalArgumentException.new("Unknown format conversion at index " .. (percent - 1)))
        end
        -- "1$" is an argument index; a bare number belongs to flags/width
        local argIndex
        if index:sub(-1) == "$" then
            argIndex = tonumber(index:sub(1, -2))
        else
            widthText = index .. widthText
            index = ""
        end
        local hasPrecision = spec:find("%.%d") ~= nil
        local flags = {
            left = flagText:find("-", 1, true) ~= nil,
            plus = flagText:find("+", 1, true) ~= nil,
            space = flagText:find(" ", 1, true) ~= nil,
            zero = flagText:find("0", 1, true) ~= nil,
            comma = flagText:find(",", 1, true) ~= nil,
            paren = flagText:find("(", 1, true) ~= nil,
            alt = flagText:find("#", 1, true) ~= nil,
        }
        if widthText:sub(1, 1) == "0" and #widthText > 1 then
            flags.zero = true
            widthText = widthText:gsub("^0+", "")
        end
        local width = tonumber(widthText)
        local precision = hasPrecision and tonumber(precisionText) or nil
        if conv == "%" then
            out[#out + 1] = pad("%", width, flags.left)
        elseif conv == "n" then
            out[#out + 1] = "\n"
        else
            local value
            if argIndex then
                value = args[argIndex]
                if argIndex > n then
                    missingArgument(spec)
                end
            else
                nextArg = nextArg + 1
                if nextArg > n then
                    missingArgument(spec)
                end
                value = args[nextArg]
            end
            local lower = conv:lower()
            local text
            if lower == "d" or lower == "x" or lower == "o" then
                if value == nil then
                    text = pad("null", width, flags.left)
                else
                    text = formatInteger(conv, value, flags, width)
                end
            elseif lower == "f" or lower == "e" or lower == "g" then
                if value == nil then
                    text = pad("null", width, flags.left)
                else
                    text = formatFloat(conv, value, flags, width, precision or 6)
                end
            elseif lower == "s" then
                text = __K2L_Str(value)
                if precision then
                    text = text:sub(1, precision)
                end
                if conv == "S" then
                    text = text:upper()
                end
                text = pad(text, width, flags.left)
            elseif lower == "c" then
                text = type(value) == "number" and string.char(value) or __K2L_Str(value)
                text = pad(conv == "C" and text:upper() or text, width, flags.left)
            elseif lower == "b" then
                local b = value ~= nil and value ~= false
                text = pad(conv == "B" and tostring(b):upper() or tostring(b), width, flags.left)
            else
                error(__K2L_IllegalArgumentException.new("Conversion = '" .. conv .. "'"))
            end
            out[#out + 1] = text
        end
        pos = percent + #spec
    end
    return table.concat(out)
end

end

------------------------------------------------------------------ StringBuilder
local __K2L_StringBuilder = __K2L_Class("java.lang.StringBuilder")

function __K2L_StringBuilder:____init(initial)
    self.____parts = {initial or ""}
end

function __K2L_StringBuilder:append(text)
    self.____parts[#self.____parts + 1] = text
    return self
end

function __K2L_StringBuilder:appendLine(text)
    self.____parts[#self.____parts + 1] = (text or "") .. "\n"
    return self
end

function __K2L_StringBuilder:toString()
    local s = table.concat(self.____parts)
    self.____parts = {s}
    return s
end

function __K2L_StringBuilder:getLength()
    return #self:toString()
end

function __K2L_StringBuilder:clear()
    self.____parts = {""}
    return self
end

function __K2L_StringBuilder:reverse()
    self.____parts = {self:toString():reverse()}
    return self
end

local function outOfBounds(message)
    error(__K2L_IndexOutOfBoundsException.new(message))
end

function __K2L_StringBuilder:isEmpty()
    return self:getLength() == 0
end

function __K2L_StringBuilder:isNotEmpty()
    return self:getLength() > 0
end

function __K2L_StringBuilder:get(index)
    local s = self:toString()
    if index < 0 or index >= #s then
        outOfBounds("index " .. index .. ",length " .. #s)
    end
    return s:sub(index + 1, index + 1)
end

function __K2L_StringBuilder:set(index, char)
    local s = self:toString()
    if index < 0 or index >= #s then
        outOfBounds("index " .. index .. ",length " .. #s)
    end
    self.____parts = {s:sub(1, index) .. char .. s:sub(index + 2)}
end

function __K2L_StringBuilder:insert(index, text)
    local s = self:toString()
    if index < 0 or index > #s then
        outOfBounds("offset " .. index .. ", length " .. #s)
    end
    self.____parts = {s:sub(1, index) .. text .. s:sub(index + 1)}
    return self
end

function __K2L_StringBuilder:deleteCharAt(index)
    local s = self:toString()
    if index < 0 or index >= #s then
        outOfBounds("index " .. index .. ",length " .. #s)
    end
    self.____parts = {s:sub(1, index) .. s:sub(index + 2)}
    return self
end

function __K2L_StringBuilder:delete(from, to)
    local s = self:toString()
    to = math.min(to, #s)
    if from < 0 or from > to then
        outOfBounds("start " .. from .. ", end " .. to .. ", length " .. #s)
    end
    self.____parts = {s:sub(1, from) .. s:sub(to + 1)}
    return self
end

function __K2L_StringBuilder:replace(from, to, text)
    local s = self:toString()
    to = math.min(to, #s)
    if from < 0 or from > #s or from > to then
        outOfBounds("start " .. from .. ", end " .. to .. ", length " .. #s)
    end
    self.____parts = {s:sub(1, from) .. text .. s:sub(to + 1)}
    return self
end

function __K2L_StringBuilder:setLength(length)
    local s = self:toString()
    if length < 0 then
        outOfBounds(tostring(length))
    end
    self.____parts = {#s >= length and s:sub(1, length) or s .. string.rep("\0", length - #s)}
end

function __K2L_StringBuilder:substring(from, to)
    local s = self:toString()
    to = to or #s
    if from < 0 or from > to or to > #s then
        outOfBounds("start " .. from .. ", end " .. to .. ", length " .. #s)
    end
    return s:sub(from + 1, to)
end

function __K2L_StringBuilder:indexOf(part, from)
    return __K2L_Text.indexOf(self:toString(), part, from)
end

function __K2L_StringBuilder:lastIndexOf(part, from)
    return __K2L_Text.lastIndexOf(self:toString(), part, from)
end

__K2L_StringBuilder.__tostring = __K2L_StringBuilder.toString
