-- requires: Collections, Exceptions, Str
-- Kotlin String functions. Strings are Lua byte strings; indices count bytes.

local function __K2L_PatternEscape(s)
    return (s:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0"))
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

local function __K2L_StringIndexOf(s, part, from)
    local i = s:find(part, (from or 0) + 1, true)
    return i and i - 1 or -1
end

local function __K2L_StringLastIndexOf(s, part)
    local last = -1
    local i = s:find(part, 1, true)
    while i do
        last = i - 1
        i = s:find(part, i + 1, true)
    end
    return last
end

local function __K2L_StringReplace(s, old, new)
    if old == "" then
        return s
    end
    return (s:gsub(__K2L_PatternEscape(old), (new:gsub("%%", "%%%%"))))
end

local function __K2L_StringSplit(s, delimiter)
    local out = __K2L_List.new()
    if delimiter == "" then
        out:add("")
        for i = 1, #s do
            out:add(s:sub(i, i))
        end
        out:add("")
        return out
    end
    local start = 1
    while true do
        local i, j = s:find(delimiter, start, true)
        if i == nil then
            out:add(s:sub(start))
            return out
        end
        out:add(s:sub(start, i - 1))
        start = j + 1
    end
end

local function __K2L_StringLines(s)
    local out = __K2L_StringSplit((s:gsub("\r\n", "\n")), "\n")
    return out
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

local function __K2L_StringPadStart(s, length, pad)
    pad = pad or " "
    return string.rep(pad, length - #s) .. s
end

local function __K2L_StringPadEnd(s, length, pad)
    pad = pad or " "
    return s .. string.rep(pad, length - #s)
end

local function __K2L_StringToIntOrNull(s)
    if not s:match("^[+-]?%d+$") then
        return nil
    end
    local n = tonumber(s)
    return math.tointeger and math.tointeger(n) or n
end

local function __K2L_StringToInt(s)
    local n = __K2L_StringToIntOrNull(s)
    if n == nil then
        error(__K2L_NumberFormatException.new("For input string: \"" .. s .. "\""))
    end
    return n
end

local function __K2L_StringToDoubleOrNull(s)
    local trimmed = __K2L_StringTrim(s)
    if trimmed == "" or trimmed:match("^0[xX]") then
        return nil
    end
    local n = tonumber(trimmed)
    return n and n + 0.0
end

local function __K2L_StringToDouble(s)
    local n = __K2L_StringToDoubleOrNull(s)
    if n == nil then
        error(__K2L_NumberFormatException.new("For input string: \"" .. s .. "\""))
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

-- String.format: Java and C format strings mostly agree; non-numbers are formatted with toString().
local function __K2L_StringFormat(format, ...)
    local n = select("#", ...)
    local args = {...}
    for i = 1, n do
        if type(args[i]) ~= "number" then
            args[i] = __K2L_Str(args[i])
        end
    end
    return string.format(format, (table.unpack or unpack)(args, 1, n))
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

__K2L_StringBuilder.__tostring = __K2L_StringBuilder.toString
