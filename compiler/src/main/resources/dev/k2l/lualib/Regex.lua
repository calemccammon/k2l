-- requires: Class, Collections, Exceptions, Str
-- kotlin.text.Regex on Lua patterns. The compiler translates each (compile-time constant) Kotlin regex to a Lua pattern,
-- matched here with string.find; constructs Lua patterns lack are compile errors.
-- Strings are byte strings: indices are bytes, and classes and IGNORE_CASE are ASCII.
local __K2L_Regex = __K2L_Class("kotlin.text.Regex")
local __K2L_MatchResult = __K2L_Class("kotlin.text.MatchResult")
local __K2L_MatchGroup = __K2L_Class("kotlin.text.MatchGroup")

do
local find, sub = string.find, string.sub

------------------------------------------------------------------ MatchResult
local function list(values, n)
    values.size = n
    return setmetatable(values, __K2L_List)
end

-- t is what string.find returned: the start, the end and the captures
local function newMatch(regex, input, t)
    local values = {sub(input, t[1], t[2])}
    for g = 1, regex.____groups do
        values[g + 1] = t[g + 2]
    end
    return setmetatable({
        ____regex = regex, ____input = input, ____first = t[1], ____last = t[2],
        value = values[1], groupValues = list(values, regex.____groups + 1),
    }, __K2L_MatchResult)
end

local lazyMembers = {}

-- Indices are bytes: the 0-based range of the match
function lazyMembers.range(self)
    return __K2L_IntRange.new(self.____first - 1, self.____last - 1)
end

function lazyMembers.groups(self)
    local groups = {}
    for g = 1, self.groupValues.size do
        groups[g] = __K2L_MatchGroup.new(self.groupValues[g])
    end
    return list(groups, self.groupValues.size)
end

function lazyMembers.destructured(self)
    local rest = {}
    for g = 2, self.groupValues.size do
        rest[g - 1] = self.groupValues[g]
    end
    return list(rest, self.groupValues.size - 1)
end

function __K2L_MatchResult.__index(self, key)
    local make = lazyMembers[key]
    if make ~= nil then
        local value = make(self)
        rawset(self, key, value)
        return value
    end
    return __K2L_MatchResult[key]
end

-- A match at or after byte `init` (^ only matches at the start of the input)
local function search(regex, input, init)
    if regex.____anchored and init > 1 then
        return nil
    end
    local t = {find(input, regex.____lua, init)}
    return t[1] ~= nil and newMatch(regex, input, t) or nil
end

-- The next match: after this one, or one byte later after an empty match
function __K2L_MatchResult:next()
    local after = self.____last + (self.____last < self.____first and 2 or 1)
    if after > #self.____input + 1 then
        return nil
    end
    return search(self.____regex, self.____input, after)
end

function __K2L_MatchResult:toString()
    return "MatchResult(value=" .. self.value .. ", range=" .. self.range:toString() .. ")"
end

function __K2L_MatchGroup:____init(value)
    self.value = value
end

function __K2L_MatchGroup:toString()
    return "MatchGroup(value=" .. self.value .. ")"
end

function __K2L_MatchGroup:equals(other)
    return getmetatable(other) == __K2L_MatchGroup and self.value == other.value
end

------------------------------------------------------------------ Regex
-- Regex(pattern, lua): `lua` is the Lua pattern the compiler translated the constant pattern to
function __K2L_Regex:____init(pattern, lua)
    self.pattern = pattern
    self.____lua = lua
    self.____anchored = sub(lua, 1, 1) == "^"
    self.____body = self.____anchored and sub(lua, 2) or lua
    -- a final unescaped $ (after an even number of %) is an anchor
    local percents = lua:match("(%%*)%$$")
    local endAnchored = percents ~= nil and #percents % 2 == 0
    self.____entire = "^" .. self.____body .. (endAnchored and "" or "$")
    -- the captures: the ( that are not escaped (in a class, the compiler escapes them)
    self.____groups = select(2, lua:gsub("%%.", ""):gsub("%(", ""))
end

-- Regex.fromLiteral of a string known at run time: its Lua pattern is the text with the magic characters escaped
function __K2L_Regex.fromLiteral(literal)
    return __K2L_Regex.new(literal, (literal:gsub("[%z%^%$%(%)%%%.%[%]%*%+%-%?]", function(c)
        return c == "\0" and "%z" or "%" .. c
    end)))
end

function __K2L_Regex:toString()
    return self.pattern
end

local function checkStart(input, index)
    index = index or 0
    if index < 0 or index > #input then
        error(__K2L_IndexOutOfBoundsException.new("Start index out of bounds: " .. index .. ", input length: " .. #input))
    end
    return index + 1
end

function __K2L_Regex:find(input, startIndex)
    return search(self, input, checkStart(input, startIndex))
end

-- findAll's sequence: the factory of a generator that searches for each match when the previous one is consumed
function __K2L_Regex:findAllFactory(input, startIndex)
    local init = checkStart(input, startIndex)
    return function()
        local match, started = nil, false
        return function()
            if not started then
                started, match = true, search(self, input, init)
            elseif match ~= nil then
                match = match:next()
            end
            if match ~= nil then
                return true, match
            end
        end
    end
end

function __K2L_Regex:matchEntire(input)
    local t = {find(input, self.____entire)}
    return t[1] ~= nil and newMatch(self, input, t) or nil
end

function __K2L_Regex:matches(input)
    return find(input, self.____entire) ~= nil
end

function __K2L_Regex:containsMatchIn(input)
    return search(self, input, 1) ~= nil
end

-- A match starting exactly at `index` (^ only matches at the start of the input)
function __K2L_Regex:matchAt(input, index)
    if index < 0 or index > #input then
        error(__K2L_IndexOutOfBoundsException.new("index out of bounds: " .. index .. ", input length: " .. #input))
    end
    if self.____anchored and index > 0 then
        return nil
    end
    local t = {find(input, "^" .. self.____body, index + 1)}
    return t[1] ~= nil and newMatch(self, input, t) or nil
end

function __K2L_Regex:matchesAt(input, index)
    return self:matchAt(input, index) ~= nil
end

-- A replacement string as its parts: literal text, and the numbers of the groups `$n` refers to
local function replacementParts(self, replacement)
    local parts, i, n = {}, 1, #replacement
    while i <= n do
        local c = sub(replacement, i, i)
        if c == "\\" then
            if i == n then
                error(__K2L_IllegalArgumentException.new("character to be escaped is missing"))
            end
            parts[#parts + 1] = sub(replacement, i + 1, i + 1)
            i = i + 2
        elseif c == "$" then
            local digits = replacement:match("^%d+", i + 1)
            if digits == nil then
                error(__K2L_IllegalArgumentException.new(sub(replacement, i + 1, i + 1) == "{"
                    and "Regex named group references `${name}` are not supported" or "Illegal group reference"))
            end
            -- as in Kotlin, further digits extend the reference while the group exists
            local len = 1
            while len < #digits and tonumber(sub(digits, 1, len + 1)) <= self.____groups do
                len = len + 1
            end
            local group = tonumber(sub(digits, 1, len))
            if group > self.____groups then
                error(__K2L_IndexOutOfBoundsException.new("No group " .. group))
            end
            parts[#parts + 1] = group
            i = i + 1 + len
        else
            local text = replacement:match("^[^\\$]+", i)
            parts[#parts + 1] = text
            i = i + #text
        end
    end
    return parts
end

local function expand(parts, match)
    local out = {}
    for k, part in ipairs(parts) do
        out[k] = type(part) == "number" and match.groupValues[part + 1] or part
    end
    return table.concat(out)
end

-- replacement: a string with $n references, or a function (MatchResult) -> String
local function replaceMatches(self, input, replacement, onlyFirst)
    local transform = type(replacement) == "function"
    local parts = not transform and replacementParts(self, replacement)
    local out, last = {}, 1
    local match = search(self, input, 1)
    while match ~= nil do
        out[#out + 1] = sub(input, last, match.____first - 1)
        out[#out + 1] = transform and __K2L_Str(replacement(match)) or expand(parts, match)
        last = match.____last + 1
        -- Kotlin's replace with a transform stops at a match that reaches the end
        if onlyFirst or (transform and last > #input) then
            break
        end
        match = match:next()
    end
    out[#out + 1] = sub(input, last)
    return table.concat(out)
end

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
    local match = search(self, input, 1)
    if limit == 1 or match == nil then
        return list({input}, 1)
    end
    local out, last = {}, 1
    repeat
        out[#out + 1] = sub(input, last, match.____first - 1)
        last = match.____last + 1
        if #out == limit - 1 then
            break
        end
        match = match:next()
    until match == nil
    out[#out + 1] = sub(input, last)
    return list(out, #out)
end

-- Kotlin's Regex.escape: the literal quoted as \Q...\E
function __K2L_Regex.escape(literal)
    return "\\Q" .. literal:gsub("\\E", "\\E\\\\E\\Q") .. "\\E"
end

function __K2L_Regex.escapeReplacement(literal)
    return (literal:gsub("[\\$]", "\\%0"))
end

end
