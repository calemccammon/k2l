local ____lualib = require("lualib_bundle")
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IsDigit = ____lualib.__K2L_IsDigit
local __K2L_IsLetterOrDigit = ____lualib.__K2L_IsLetterOrDigit
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SimpleName = ____lualib.__K2L_SimpleName
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringEndsWith = ____lualib.__K2L_StringEndsWith
local __K2L_StringIndexOf = ____lualib.__K2L_StringIndexOf
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToDoubleOrNull = ____lualib.__K2L_StringToDoubleOrNull
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_StringTrimStart = ____lualib.__K2L_StringTrimStart
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local appendUtf8
local TValue = __K2L_Class("TValue")
local TStr = __K2L_Class("TStr", nil, TValue)

function TStr.new(s)
    return setmetatable({s = s}, TStr)
end

__K2L_DataClass(TStr, {"s"})
local TInt = __K2L_Class("TInt", nil, TValue)

function TInt.new(v)
    return setmetatable({v = v}, TInt)
end

__K2L_DataClass(TInt, {"v"})
local TFloat = __K2L_Class("TFloat", nil, TValue)

function TFloat.new(v)
    return setmetatable({v = v}, TFloat)
end

__K2L_DataClass(TFloat, {"v"})
local TBool = __K2L_Class("TBool", nil, TValue)

function TBool.new(v)
    return setmetatable({v = v}, TBool)
end

__K2L_DataClass(TBool, {"v"})
local TArr = __K2L_Class("TArr", nil, TValue)

function TArr.new(items)
    if items == nil then
        items = __K2L_ListOf()
    end
    return setmetatable({items = items}, TArr)
end

__K2L_DataClass(TArr, {"items"})
local TTable = __K2L_Class("TTable", nil, TValue)

function TTable.new(map, inline)
    if map == nil then
        map = __K2L_Map.new()
    end
    if inline == nil then
        inline = false
    end
    return setmetatable({map = map, inline = inline}, TTable)
end

__K2L_DataClass(TTable, {"map", "inline"})
local TomlError = __K2L_Class("TomlError", __K2L_IllegalArgumentException)

function TomlError:____init(line, msg)
    __K2L_IllegalArgumentException.____init(self, "line " .. line .. ": " .. msg)
    self.line = line
end

local TomlParser = __K2L_Class("TomlParser")
local descend, key, value__1, word, number, array__1, skipWsAndComments, inlineTable, literalString, basicString, escape

local function fail(self, msg)
    error(TomlError.new(self.line, msg))
end

local function peek(self)
    return __K2L_Text.getOrNull(self.src, self.i)
end

local function skipSpaces(self)
    while peek(self) == " " or peek(self) == "\t" do
        self.i = self.i + 1
    end
end

local function skipToEol(self)
    skipSpaces(self)
    if peek(self) == "#" then
        while peek(self) ~= nil and peek(self) ~= "\n" do
            self.i = self.i + 1
        end
    end
    local ____subject = peek(self)
    if ____subject == nil then
    elseif ____subject == "\n" then
        self.i = self.i + 1
        self.line = self.line + 1
    elseif ____subject == "\r" then
        if __K2L_Text.getOrNull(self.src, self.i + 1) == "\n" then
            self.i = self.i + 2
            self.line = self.line + 1
        else
            fail(self, "stray carriage return")
        end
    else
        fail(self, "expected end of line, found '" .. __K2L_Str(peek(self)) .. "'")
    end
end

local ____lambda_1 = function() return TArr.new() end
local function header(self)
    local array = self.src:sub(self.i + 1, self.i + #"[[") == "[["
    self.i = self.i + (array and 2 or 1)
    local path = key(self)
    if array then
        if self.src:sub(self.i + 1, self.i + #"]]") ~= "]]" then
            fail(self, "expected ']]'")
        end
        self.i = self.i + 2
        local parent = descend(self, self.root, path:dropLast(1))
        local ____cast = parent.map:getOrPut(path:last(), ____lambda_1)
        local ____value = getmetatable(____cast) == TArr and ____cast or nil
        if ____value == nil then
            fail(self, "'" .. path:last() .. "' is not an array of tables")
        end
        local arr = ____value
        local ____value_1 = TTable.new()
        arr.items:add(____value_1)
        self.current = ____value_1
    else
        if peek(self) ~= "]" then
            fail(self, "expected ']'")
        end
        self.i = self.i + 1
        self.current = descend(self, self.root, path)
    end
    skipToEol(self)
end

local ____lambda_2 = function() return TTable.new() end
function descend(self, start, path)
    return path:fold(start, function(t, k)
        local v = t.map:getOrPut(k, ____lambda_2)
        local ____mt = getmetatable(v)
        if ____mt == TTable then
            if v.inline then
                fail(self, "cannot extend inline table '" .. k .. "'")
            else
                return v
            end
        elseif ____mt == TArr then
            local ____cast_1 = v.items:lastOrNull()
            local ____value_2 = getmetatable(____cast_1) == TTable and ____cast_1 or nil
            if ____value_2 == nil then
                fail(self, "'" .. k .. "' is not a table")
            end
            return ____value_2
        else
            fail(self, "key '" .. k .. "' already holds a " .. __K2L_Str(__K2L_SimpleName(v)))
        end
    end)
end

function key(self)
    local parts = __K2L_ListOf()
    repeat
        skipSpaces(self)
        local ____temp
        local ____subject_1 = peek(self)
        if ____subject_1 == "\"" then
            ____temp = basicString(self)
        elseif ____subject_1 == "'" then
            ____temp = literalString(self)
        else
            local start = self.i
            while true do
                local ____receiver = peek(self)
                if (____receiver and (__K2L_IsLetterOrDigit[____receiver] == true or ____receiver == "_" or ____receiver == "-")) ~= true then
                    break
                end
                self.i = self.i + 1
            end
            if start == self.i then
                fail(self, "expected a key")
            end
            ____temp = __K2L_Text.substring(self.src, start, self.i)
        end
        parts:add(____temp)
        skipSpaces(self)
        local ____cond = peek(self) == "."
        if ____cond then
            local ____old = self.i
            self.i = self.i + 1
            ____cond = ____old >= 0
        end
    until not ____cond
    return parts
end

local function keyValue(self, into)
    local path = key(self)
    if peek(self) ~= "=" then
        fail(self, "expected '=' after key '" .. path:joinToString(".") .. "'")
    end
    self.i = self.i + 1
    skipSpaces(self)
    local target = descend(self, into, path:dropLast(1))
    if target.map:containsKey(path:last()) then
        fail(self, "duplicate key '" .. path:joinToString(".") .. "'")
    end
    local ____object = target.map
    local ____key = path:last()
    ____object:set(____key, value__1(self))
end

function value__1(self)
    local c = peek(self)
    if c == "\"" then
        return TStr.new(basicString(self))
    elseif c == "'" then
        return TStr.new(literalString(self))
    elseif c == "[" then
        return array__1(self)
    elseif c == "{" then
        return inlineTable(self)
    elseif c == "t" or c == "f" then
        return word(self)
    elseif c == nil then
        fail(self, "expected a value")
    elseif __K2L_IsDigit[c] == true or __K2L_StringContains("+-i", c) then
        return number(self)
    else
        fail(self, "unexpected '" .. c .. "'")
    end
end

function word(self)
    local ____list = __K2L_ListOf(__K2L_Pair.new("true", true), __K2L_Pair.new("false", false))
    for ____i = 1, ____list.size do
        local ____item = ____list[____i]
        local w, v = ____item.first, ____item.second
        if self.src:sub(self.i + 1, self.i + #w) == w then
            self.i = self.i + #w
            return TBool.new(v)
        end
    end
    fail(self, "bad literal")
end

local ____lambda_3 = function(it) return __K2L_StringContains(".eE", it) end
function number(self)
    local start = self.i
    while true do
        local ____receiver_1 = peek(self)
        if (____receiver_1 and (__K2L_IsLetterOrDigit[____receiver_1] == true or __K2L_StringContains("+-._", ____receiver_1))) ~= true then
            break
        end
        self.i = self.i + 1
    end
    local raw = __K2L_Text.substring(self.src, start, self.i)
    if __K2L_StringStartsWith(raw, "_") or __K2L_StringEndsWith(raw, "_") or __K2L_StringContains(raw, "__") then
        fail(self, "misplaced underscore in '" .. raw .. "'")
    end
    local t = __K2L_StringReplace(raw, "_", "")
    local radix
    if __K2L_StringStartsWith(t, "0x") then
        radix = 16
    elseif __K2L_StringStartsWith(t, "0o") then
        radix = 8
    elseif __K2L_StringStartsWith(t, "0b") then
        radix = 2
    else
        radix = 10
    end
    if radix ~= 10 then
        local ____value_3 = __K2L_StringToIntOrNull(__K2L_Text.substring(t, 2), radix, true)
        if ____value_3 == nil then
            fail(self, "bad integer '" .. raw .. "'")
        end
        return TInt.new(____value_3)
    end
    if t == "inf" or t == "+inf" then
        return TFloat.new(math.huge)
    elseif t == "-inf" then
        return TFloat.new(-math.huge)
    end
    if __K2L_StringToList(t):any(____lambda_3) then
        local ____value_4 = __K2L_StringToDoubleOrNull(t)
        if ____value_4 == nil then
            fail(self, "bad float '" .. raw .. "'")
        end
        return TFloat.new(____value_4)
    end
    local ____value_5 = __K2L_StringToIntOrNull(t, nil, true)
    if ____value_5 == nil then
        fail(self, "bad integer '" .. raw .. "'")
    end
    return TInt.new(____value_5)
end

function array__1(self)
    self.i = self.i + 1
    local arr = TArr.new()
    while true do
        skipWsAndComments(self)
        if peek(self) == "]" then
            self.i = self.i + 1
            return arr
        end
        arr.items:add(value__1(self))
        skipWsAndComments(self)
        local ____subject_2 = peek(self)
        if ____subject_2 == "," then
            self.i = self.i + 1
        elseif ____subject_2 == "]" then
            self.i = self.i + 1
            return arr
        else
            fail(self, "expected ',' or ']' in array")
        end
    end
end

function skipWsAndComments(self)
    while true do
        local ____subject_3 = peek(self)
        if ____subject_3 == " " or ____subject_3 == "\t" or ____subject_3 == "\r" then
            self.i = self.i + 1
        elseif ____subject_3 == "\n" then
            self.i = self.i + 1
            self.line = self.line + 1
        elseif ____subject_3 == "#" then
            while peek(self) ~= nil and peek(self) ~= "\n" do
                self.i = self.i + 1
            end
        else
            return
        end
    end
end

function inlineTable(self)
    self.i = self.i + 1
    local t = TTable.new()
    skipSpaces(self)
    if peek(self) == "}" then
        self.i = self.i + 1
        t.inline = true
        return t
    end
    while true do
        keyValue(self, t)
        skipSpaces(self)
        local ____subject_4 = peek(self)
        if ____subject_4 == "," then
            self.i = self.i + 1
        elseif ____subject_4 == "}" then
            self.i = self.i + 1
            t.inline = true
            return t
        else
            fail(self, "expected ',' or '}' in inline table")
        end
    end
end

function literalString(self)
    local ____end = __K2L_StringIndexOf(self.src, "'", self.i + 1)
    if ____end < 0 or __K2L_StringContains(__K2L_Text.substring(self.src, self.i, ____end), "\n") then
        fail(self, "unterminated literal string")
    end
    local ____value_6 = __K2L_Text.substring(self.src, self.i + 1, ____end)
    self.i = ____end + 1
    return ____value_6
end

function basicString(self)
    self.i = self.i + 1
    local sb = __K2L_StringBuilder.new()
    while true do
        local ____value_7 = peek(self)
        if ____value_7 == nil then
            fail(self, "unterminated string")
        end
        local c = ____value_7
        self.i = self.i + 1
        if c == "\"" then
            return sb:toString()
        elseif c == "\n" then
            fail(self, "newline in string")
        elseif c == "\\" then
            escape(self, sb)
        else
            sb:append(c)
        end
    end
end

function escape(self, sb)
    local ____value_8 = peek(self)
    if ____value_8 == nil then
        fail(self, "unterminated escape")
    end
    local e = ____value_8
    self.i = self.i + 1
    if e == "b" then
        sb:append("\008")
    elseif e == "t" then
        sb:append("\t")
    elseif e == "n" then
        sb:append("\n")
    elseif e == "f" then
        sb:append("\012")
    elseif e == "r" then
        sb:append("\r")
    elseif e == "\"" or e == "\\" then
        sb:append(e)
    elseif e == "u" or e == "U" then
        local n = e == "u" and 4 or 8
        local hex = __K2L_Text.substring(self.src, self.i, math.min(self.i + n, #self.src))
        local ____receiver_2 = #hex == n and hex or nil
        local ____value_9 = ____receiver_2 and __K2L_StringToIntOrNull(____receiver_2, 16)
        if ____value_9 == nil then
            fail(self, "bad unicode escape '\\" .. e .. hex .. "'")
        end
        local cp = ____value_9
        if cp >= 55296 and cp <= 57343 or cp > 1114111 then
            fail(self, "invalid code point U+" .. hex:upper())
        end
        appendUtf8(sb, cp)
        self.i = self.i + n
    else
        fail(self, "unknown escape '\\" .. e .. "'")
    end
end

function TomlParser:____init(text)
    self.src = text
    self.i = 0
    self.line = 1
    self.root = TTable.new()
    self.current = self.root
end

function TomlParser:parse()
    while self.i < #self.src do
        skipSpaces(self)
        local ____subject_5 = peek(self)
        if ____subject_5 == "#" or ____subject_5 == "\n" or ____subject_5 == "\r" then
            skipToEol(self)
        elseif ____subject_5 == "[" then
            header(self)
        elseif ____subject_5 == nil then
        else
            keyValue(self, self.current)
            skipToEol(self)
        end
    end
    return self.root
end

function appendUtf8(sb, cp)
    if cp < 128 then
        sb:append(string.char(cp))
    elseif cp < 2048 then
        sb:append(string.char(192 | cp // 64)):append(string.char(128 | cp & 63))
    elseif cp < 65536 then
        sb:append(string.char(224 | cp // 4096)):append(string.char(128 | cp // 64 & 63)):append(string.char(128 | cp & 63))
    else
        sb:append(string.char(240 | cp // 262144)):append(string.char(128 | cp // 4096 & 63)):append(string.char(128 | cp // 64 & 63)):append(string.char(128 | cp & 63))
    end
end

local function jsonString(s)
    local ____builder = __K2L_StringBuilder.new()
    ____builder:append("\"")
    for ____i_1 = 1, #s do
        local ch = s:sub(____i_1, ____i_1)
        if ch == "\"" then
            ____builder:append("\\\"")
        elseif ch == "\\" then
            ____builder:append("\\\\")
        elseif ch == "\n" then
            ____builder:append("\\n")
        elseif ch == "\t" then
            ____builder:append("\\t")
        elseif ch < " " or ch:byte() > 126 then
            ____builder:append("\\u"):append(__K2L_StringPadStart(__K2L_Num.toRadix(ch:byte(), 16), 4, "0"))
        else
            ____builder:append(ch)
        end
    end
    ____builder:append("\"")
    return ____builder:toString()
end

local function toJson(v, indent, out)
    if indent == nil then
        indent = ""
    end
    if out == nil then
        out = __K2L_StringBuilder.new()
    end
    local inner = indent .. "  "
    local ____mt_1 = getmetatable(v)
    if ____mt_1 == TStr then
        out:append(jsonString(v.s))
    elseif ____mt_1 == TInt then
        out:append(tostring(v.v))
    elseif ____mt_1 == TFloat then
        out:append(__K2L_Num.isInfinite(v.v) and jsonString(tostring(v.v)) or tostring(v.v))
    elseif ____mt_1 == TBool then
        out:append(tostring(v.v))
    elseif ____mt_1 == TArr then
        if v.items:isEmpty() then
            out:append("[]")
        else
            out:append("[\n")
            local ____list_1 = v.items
            for ____i_3 = 1, ____list_1.size do
                local item = ____list_1[____i_3]
                local k = ____i_3 - 1
                out:append(inner)
                toJson(item, inner, out)
                out:append(k < v.items.size - 1 and ",\n" or "\n")
            end
            out:append(indent):append("]")
        end
    elseif ____mt_1 == TTable then
        if v.map:isEmpty() then
            out:append("{}")
        else
            out:append("{\n")
            local last = v.map:getKeys():last()
            local ____map = v.map
            local ____keys, ____values, ____n = ____map:____arrays()
            for ____i_2 = 1, ____n do
                local k, item = ____keys[____i_2], ____values[____i_2]
                out:append(inner):append(jsonString(k)):append(": ")
                toJson(item, inner, out)
                out:append(k == last and "\n" or ",\n")
            end
            out:append(indent):append("}")
        end
    end
    return out
end

local ____lambda_4 = function(____p1, ____p2) return ____p1 + ____p2 end
local function stats(v)
    local counts = __K2L_SortedMapOf(nil)
    local function walk(x)
        counts:merge(__K2L_NotNull(__K2L_SimpleName(x)), 1, ____lambda_4)
        local ____mt_2 = getmetatable(x)
        if ____mt_2 == TArr then
            local ____list_2 = x.items
            for ____i_5 = 1, ____list_2.size do
                local it = ____list_2[____i_5]
                walk(it)
            end
        elseif ____mt_2 == TTable then
            local ____collection = x.map:getValues()
            local ____items, ____n_1 = ____collection:____array()
            for ____i_4 = 1, ____n_1 do
                local it = ____items[____i_4]
                walk(it)
            end
        end
    end
    walk(v)
    return counts
end

local doc = __K2L_StringTrimStart("\n# Service configuration\ntitle = \"TOML \\u2192 JSON\"\nowner.name = \"Zoë \\\"zed\\\" Ångström\"\nowner.emoji = \"\\U0001F680 launch\"\npath = 'C:\\Users\\cfg'\n\n[server]\nhost = \"0.0.0.0\"\nports = [ 8000, 8_001, 0x1F90 ]   # three listeners\ntimeout = 2.5e1\nratio = -0.125\ndebug = false\nmasks = [0o755, 0b1010_1010]\n\n[server.limits]\nmax-body = 1_048_576\nrates = { burst = 20, sustained = 5.0 }\n\n[[plugin]]\nname = \"auth\"\ntags = [\"core\", 'sec', ]\n\n[[plugin]]\nname = \"metrics\"\noptions = { interval = 15, sinks = [ \"stdout\", \"statsd\" ] }\nnested = [ [1, 2], [], [\"a\\tb\"] ]\n\n[empty]\n\"quoted key\" = \"tab\\there\"\nbounds = [ inf, -inf ]\n")

local ____lambda_5 = function(it) return "0x" .. __K2L_Num.toRadix(it, 16) end
local ____lambda_6 = function(x) return getmetatable(x) == TTable end
local function main()
    local ____table = TomlParser.new(doc):parse()
    print(__K2L_Str(toJson(____table)))
    print(__K2L_Str(stats(____table)))
    local ____cast_2 = ____table.map:get("server")
    if getmetatable(____cast_2) ~= TTable then
        __K2L_CastFail(____cast_2, "TTable")
    end
    local server = ____cast_2
    local ____cast_3 = server.map:get("ports")
    if getmetatable(____cast_3) ~= TArr then
        __K2L_CastFail(____cast_3, "TArr")
    end
    local ____list_3 = ____cast_3.items
    local ____out = {}
    local ____count = 0
    local ____items_1, ____n_2 = ____list_3:____array()
    for ____i_6 = 1, ____n_2 do
        local it = ____items_1[____i_6]
        local ____result
        if getmetatable(it) ~= TInt then
            __K2L_CastFail(it, "TInt")
        end
        ____result = it.v
        ____count = ____count + 1
        ____out[____count] = ____result
    end
    local ports = __K2L_ListWrap(____out, ____count)
    print("ports sum=" .. ports:sum() .. " max=" .. ports:max() .. " hex=" .. ports:joinToString(nil, nil, nil, nil, nil, ____lambda_5))
    local ____cast_4 = ____table.map:get("plugin")
    if getmetatable(____cast_4) ~= TArr then
        __K2L_CastFail(____cast_4, "TArr")
    end
    local plugins = ____cast_4.items:filter(____lambda_6)
    print("plugins: " .. plugins:joinToString(nil, nil, nil, nil, nil, function(it)
        local ____cast_5 = it.map:get("name")
        if getmetatable(____cast_5) ~= TStr then
            __K2L_CastFail(____cast_5, "TStr")
        end
        return ____cast_5.s
    end))
    local ____cast_6 = ____table.map:get("owner")
    if getmetatable(____cast_6) ~= TTable then
        __K2L_CastFail(____cast_6, "TTable")
    end
    local ____cast_7 = ____cast_6.map:get("name")
    if getmetatable(____cast_7) ~= TStr then
        __K2L_CastFail(____cast_7, "TStr")
    end
    local owner = ____cast_7
    print("owner length=" .. #owner.s .. " upper=" .. owner.s:upper())
    print(__K2L_Equals(____table.map:get("title"), TStr.new("TOML → JSON")))
    local bad = __K2L_ListOf("a = 1\na = 2", "x = [1, 2", "s = \"abc", "n = 1__000", "e = \"\\uD800\"", "e = \"\\q\"", "[t]\nk = 1\n[t.k]\n", "t = { a = 1 }\n[t]\nb = 2", "v = 0xZZ", "k = 1 junk", "[[arr]]\n[arr.x]\ny=1\n[arr]", "f = 1.2.3", "= 3")
    for ____i_7 = 1, bad.size do
        local src = bad[____i_7]
        local ____ok, ____result_1 = pcall(function()
            TomlParser.new(src):parse()
            print("ok?? " .. __K2L_StringReplace(src, "\n", "\\n"))
        end)
        if not ____ok then
            local ____error = __K2L_ToThrowable(____result_1)
            if getmetatable(____error) == TomlError then
                local e = ____error
                print("error " .. __K2L_Str(e.message))
            else
                error(____error, 0)
            end
        end
    end
end

__K2L_RunMain(main)
return {TValue = TValue, TStr = TStr, TInt = TInt, TFloat = TFloat, TBool = TBool, TArr = TArr, TTable = TTable, TomlError = TomlError, TomlParser = TomlParser, appendUtf8 = appendUtf8, jsonString = jsonString, toJson = toJson, stats = stats, doc = doc}
