local ____lualib = require("lualib_bundle")
local __K2L_Bits = ____lualib.__K2L_Bits
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_LoopItems = ____lualib.__K2L_LoopItems
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_StringIndexOf = ____lualib.__K2L_StringIndexOf
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringToDoubleOrNull = ____lualib.__K2L_StringToDoubleOrNull
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Utf16 = ____lualib.__K2L_Utf16
local __K2L_Utf16Case = ____lualib.__K2L_Utf16Case

local ConfigError = __K2L_Class("ConfigError", __K2L_Exception)
__K2L_ClassInfo(ConfigError, "ConfigError", "ConfigError", "class")

function ConfigError:____init(line, msg)
    __K2L_Exception.____init(self, "line " .. line .. ": " .. msg)
    self.line = line
end

local TValue = __K2L_Class("TValue")
__K2L_ClassInfo(TValue, "TValue", "TValue", "interface")
local TStr = __K2L_Class("TStr", nil, TValue)
__K2L_ClassInfo(TStr, "TStr", "TStr", "class")

function TStr:____init(v)
    self.v = v
end

function TStr.new(v)
    return setmetatable({v = v}, TStr)
end

function TStr:toString()
    return "TStr(v=" .. self.v .. ")"
end

function TStr:hashCode()
    return __K2L_Hash(self.v)
end

function TStr:equals(other)
    return getmetatable(other) == TStr and self.v == other.v
end

local TInt = __K2L_Class("TInt", nil, TValue)
__K2L_ClassInfo(TInt, "TInt", "TInt", "class")

function TInt:____init(v)
    self.v = v
end

function TInt.new(v)
    return setmetatable({v = v}, TInt)
end

function TInt:toString()
    return "TInt(v=" .. self.v .. ")"
end

function TInt:hashCode()
    return __K2L_Hash(self.v)
end

function TInt:equals(other)
    return getmetatable(other) == TInt and self.v == other.v
end

local TFloat = __K2L_Class("TFloat", nil, TValue)
__K2L_ClassInfo(TFloat, "TFloat", "TFloat", "class")

function TFloat:____init(v)
    self.v = v
end

function TFloat.new(v)
    return setmetatable({v = v}, TFloat)
end

function TFloat:toString()
    return "TFloat(v=" .. __K2L_Str(self.v) .. ")"
end

function TFloat:hashCode()
    return __K2L_Hash(self.v)
end

function TFloat:equals(other)
    return getmetatable(other) == TFloat and self.v == other.v
end

local TBool = __K2L_Class("TBool", nil, TValue)
__K2L_ClassInfo(TBool, "TBool", "TBool", "class")

function TBool:____init(v)
    self.v = v
end

function TBool.new(v)
    return setmetatable({v = v}, TBool)
end

function TBool:toString()
    return "TBool(v=" .. tostring(self.v) .. ")"
end

function TBool:hashCode()
    return self.v and 1231 or 1237
end

function TBool:equals(other)
    return getmetatable(other) == TBool and self.v == other.v
end

local TArr = __K2L_Class("TArr", nil, TValue)
__K2L_ClassInfo(TArr, "TArr", "TArr", "class")

function TArr:____init(v)
    self.v = v
end

function TArr.new(v)
    return setmetatable({v = v}, TArr)
end

function TArr:toString()
    return "TArr(v=" .. __K2L_Str(self.v) .. ")"
end

function TArr:hashCode()
    return __K2L_Hash(self.v)
end

function TArr:equals(other)
    return getmetatable(other) == TArr and __K2L_Equals(self.v, other.v)
end

local TTable = __K2L_Class("TTable", nil, TValue)
__K2L_ClassInfo(TTable, "TTable", "TTable", "class")

function TTable:____init(v)
    if v == nil then
        v = __K2L_Map.new()
    end
    self.v = v
end

function TTable:toString()
    return "TTable(v=" .. __K2L_Str(self.v) .. ")"
end

function TTable:hashCode()
    return __K2L_Hash(self.v)
end

function TTable:equals(other)
    return getmetatable(other) == TTable and __K2L_Equals(self.v, other.v)
end

local ValueReader = __K2L_Class("ValueReader")
__K2L_ClassInfo(ValueReader, "ValueReader", "ValueReader", "class")

function ValueReader:____init(s, line)
    self.s = s
    self.line = line
    self.i = 0
end

function ValueReader:fail(msg)
    error(ConfigError.new(self.line, msg .. " (column " .. self.i + 1 .. ")"))
end

function ValueReader:ws()
    while self.i < __K2L_Utf16.len(self.s) and (__K2L_Text.get(self.s, self.i) == " " or __K2L_Text.get(self.s, self.i) == "\t") do
        self.i = self.i + 1
    end
end

function ValueReader:read()
    self:ws()
    if self.i >= __K2L_Utf16.len(self.s) then
        self:fail("missing value")
    end
    local c = __K2L_Text.get(self.s, self.i)
    if c == "\"" then
        return TStr.new(self:basicString())
    elseif c == "'" then
        local ____value = __K2L_StringIndexOf(self.s, "'", self.i + 1)
        local ____value_1 = ____value > 0 and ____value or nil
        if ____value_1 == nil then
            self:fail("unterminated literal string")
        end
        local ____end = ____value_1
        local ____value_2 = TStr.new(__K2L_Text.substring(self.s, self.i + 1, ____end))
        self.i = ____end + 1
        return ____value_2
    elseif c == "[" then
        return self:array()
    elseif c == "{" then
        return self:inline()
    else
        return __K2L_Utf16Case.isLetter(c) and self:keyword() or self:number()
    end
end

function ValueReader:basicString()
    self.i = self.i + 1
    local sb = __K2L_StringBuilder.new()
    while true do
        do
            if self.i >= __K2L_Utf16.len(self.s) then
                self:fail("unterminated string")
            end
            local ____arg = self.s
            local ____old = self.i
            self.i = self.i + 1
            local c = __K2L_Text.get(____arg, ____old)
            if c == "\"" then
                return sb:toString()
            end
            if c ~= "\\" then
                sb:append(c)
                goto ____continue
            end
            local ____arg_1 = self.s
            local ____old_1 = self.i
            self.i = self.i + 1
            local ____value_3 = __K2L_Text.getOrNull(____arg_1, ____old_1)
            if ____value_3 == nil then
                self:fail("dangling escape")
            end
            local e = ____value_3
            if e == "n" then
                sb:append("\n")
            elseif e == "t" then
                sb:append("\t")
            elseif e == "\"" then
                sb:append("\"")
            elseif e == "\\" then
                sb:append("\\")
            elseif e == "u" then
                local hex = __K2L_Text.substring(self.s, self.i, math.min(self.i + 4, __K2L_Utf16.len(self.s)))
                if __K2L_Utf16.len(hex) < 4 or not __K2L_Text.toList(hex):all(function(it)
                    local ____cond = __K2L_Utf16Case.isDigit(it)
                    if not ____cond then
                        local ____value_4 = __K2L_Utf16Case.lowercaseChar(it)
                        ____cond = ____value_4 >= "a" and ____value_4 <= "f"
                    end
                    return ____cond
                end) then
                    self:fail("bad unicode escape '\\u" .. hex .. "'")
                end
                sb:append(__K2L_Utf16.char(__K2L_StringToInt(hex, 16)))
                self.i = self.i + 4
            else
                self:fail(__K2L_Utf16.norm("unknown escape '\\" .. e .. "'"))
            end
        end
        ::____continue::
    end
end

local ____lambda_1 = function(it) return __K2L_Utf16Case.isLetter(it) end
function ValueReader:keyword()
    local word = __K2L_Text.takeWhile(__K2L_Text.substring(self.s, self.i), ____lambda_1)
    self.i = self.i + __K2L_Utf16.len(word)
    if word == "true" then
        return TBool.new(true)
    elseif word == "false" then
        return TBool.new(false)
    elseif word == "inf" then
        return TFloat.new(math.huge)
    elseif word == "nan" then
        return TFloat.new(0.0 / 0.0)
    else
        self:fail("unknown word '" .. word .. "'")
    end
end

local ____lambda_2 = function(it) return it == "." or it == "e" or it == "E" end
function ValueReader:number()
    local ____receiver = __K2L_Regex.new("[-+0-9a-zA-Z_.]+"):matchAt(self.s, self.i)
    local ____value_5 = ____receiver and ____receiver.value
    if ____value_5 == nil then
        self:fail(__K2L_Utf16.norm("unexpected '" .. __K2L_Text.get(self.s, self.i) .. "'"))
    end
    local token = ____value_5
    self.i = self.i + __K2L_Utf16.len(token)
    local clean = __K2L_StringReplace(token, "_", "")
    if __K2L_Text.contains(token, "__") or __K2L_Text.startsWith(token, "_") or __K2L_Text.endsWith(token, "_") then
        self:fail("misplaced underscore in '" .. token .. "'")
    end
    if __K2L_Text.startsWith(clean, "0x") then
        local ____value_10 = __K2L_StringToIntOrNull(__K2L_Text.drop(clean, 2), 16, true)
        if ____value_10 == nil then
            self:fail("bad hex '" .. token .. "'")
        end
        return TInt.new(____value_10)
    elseif __K2L_Text.startsWith(clean, "0o") then
        local ____value_9 = __K2L_StringToIntOrNull(__K2L_Text.drop(clean, 2), 8, true)
        if ____value_9 == nil then
            self:fail("bad octal '" .. token .. "'")
        end
        return TInt.new(____value_9)
    elseif __K2L_Text.startsWith(clean, "0b") then
        local ____value_8 = __K2L_StringToIntOrNull(__K2L_Text.drop(clean, 2), 2, true)
        if ____value_8 == nil then
            self:fail("bad binary '" .. token .. "'")
        end
        return TInt.new(____value_8)
    elseif __K2L_Text.toList(clean):any(____lambda_2) then
        local ____value_7 = __K2L_StringToDoubleOrNull(clean)
        if ____value_7 == nil then
            self:fail("bad float '" .. token .. "'")
        end
        return TFloat.new(____value_7)
    else
        local ____value_6 = __K2L_StringToIntOrNull(clean, nil, true)
        if ____value_6 == nil then
            self:fail("bad integer '" .. token .. "'")
        end
        return TInt.new(____value_6)
    end
end

function ValueReader:array()
    self.i = self.i + 1
    local items = __K2L_ListOf()
    while true do
        self:ws()
        if self.i < __K2L_Utf16.len(self.s) and __K2L_Text.get(self.s, self.i) == "]" then
            self.i = self.i + 1
            return TArr.new(items)
        end
        items:add(self:read())
        self:ws()
        local ____subject = __K2L_Text.getOrNull(self.s, self.i)
        if ____subject == "," then
            self.i = self.i + 1
        elseif ____subject == "]" then
            self.i = self.i + 1
            return TArr.new(items)
        else
            self:fail("expected ',' or ']' in array")
        end
    end
end

local ____lambda_3 = function(it)
    return __K2L_Utf16Case.isLetterOrDigit(it) or it == "_" or it == "-"
end
function ValueReader:inline()
    self.i = self.i + 1
    local t = TTable.new()
    while true do
        self:ws()
        if __K2L_Text.getOrNull(self.s, self.i) == "}" then
            self.i = self.i + 1
            return t
        end
        local key = __K2L_Text.takeWhile(__K2L_Text.substring(self.s, self.i), ____lambda_3)
        if #key == 0 then
            self:fail("expected key in inline table")
        end
        self.i = self.i + __K2L_Utf16.len(key)
        self:ws()
        local ____arg_2 = self.s
        local ____old_2 = self.i
        self.i = self.i + 1
        if __K2L_Text.getOrNull(____arg_2, ____old_2) ~= "=" then
            self:fail("expected '=' after '" .. key .. "'")
        end
        local ____object = t.v
        ____object:set(key, self:read())
        self:ws()
        local ____subject_1 = __K2L_Text.getOrNull(self.s, self.i)
        if ____subject_1 == "," then
            self.i = self.i + 1
        elseif ____subject_1 == "}" then
            self.i = self.i + 1
            return t
        else
            self:fail("expected ',' or '}'")
        end
    end
end

local function stripComment(line)
    local inStr = nil
    local ____collection = __K2L_Text.toList(line):withIndex()
    local ____items, ____n = __K2L_LoopItems(____collection)
    local ____mod = ____collection.____modCount
    for ____i = 1, ____n do
        local ____item = ____items[____i]
        local idx, c = ____item.index, ____item.value
        if inStr ~= nil and c == inStr and (inStr == "'" or __K2L_Text.getOrNull(line, idx - 1) ~= "\\") then
            inStr = nil
        elseif inStr == nil and (c == "\"" or c == "'") then
            inStr = c
        elseif inStr == nil and c == "#" then
            return __K2L_Text.substring(line, 0, idx)
        end
        if ____collection.____modCount ~= ____mod and ____collection:____comodified(____i, ____n) then
            break
        end
    end
    return line
end

local function parseConfig(text)
    local root = TTable.new()
    local current = root
    local ____list = __K2L_StringLines(text)
    local ____mod_2 = ____list.____modCount
    for ____i_2 = 1, ____list.size do
        local raw = ____list[____i_2]
        local n = ____i_2 - 1
        do
            local lineNo = n + 1
            local line = __K2L_Text.trim(stripComment(raw))
            if #line == 0 then
                goto ____inline_end
            end
            local header = __K2L_Regex.new("^\\[\\s*([A-Za-z0-9_.-]+)\\s*]$"):matchEntire(line)
            if header ~= nil then
                current = root
                local ____list_1 = __K2L_StringSplit(header.groupValues:get(1), ".")
                local ____mod_1 = ____list_1.____modCount
                for ____i_1 = 1, ____list_1.size do
                    local part = ____list_1[____i_1]
                    local existing = current.v:get(part)
                    if existing == nil then
                        local ____value_11 = TTable.new()
                        do
                            local ____object_1 = current.v
                            ____object_1:set(part, ____value_11)
                        end
                        current = ____value_11
                    elseif getmetatable(existing) == TTable then
                        current = existing
                    else
                        error(ConfigError.new(lineNo, "'" .. part .. "' is not a table"))
                    end
                    if ____list_1.____modCount ~= ____mod_1 and ____list_1:____comodified(____i_1) then
                        break
                    end
                end
                goto ____inline_end
            end
            local eq = __K2L_StringIndexOf(line, "=")
            if eq <= 0 then
                error(ConfigError.new(lineNo, "expected 'key = value' but got '" .. __K2L_Text.take(line, 20) .. "'"))
            end
            local key = __K2L_Text.removeSurrounding(__K2L_Text.trim(__K2L_Text.substring(line, 0, eq)), "\"")
            if not __K2L_Regex.new("[A-Za-z0-9_-]+"):matches(key) then
                error(ConfigError.new(lineNo, "invalid key '" .. key .. "'"))
            end
            if current.v:containsKey(key) then
                error(ConfigError.new(lineNo, "duplicate key '" .. key .. "'"))
            end
            local reader = ValueReader.new(__K2L_Text.substring(line, eq + 1), lineNo)
            local ____object_2 = current.v
            ____object_2:set(key, reader:read())
            reader:ws()
            if reader.i < __K2L_Utf16.len(line) - eq - 1 then
                reader:fail("trailing characters")
            end
            ::____inline_end::
        end
        if ____list.____modCount ~= ____mod_2 and ____list:____comodified(____i_2) then
            break
        end
    end
    return root
end

local function lookup(self, path)
    return __K2L_StringSplit(path, "."):fold(self, function(acc, k)
        local ____receiver_1 = getmetatable(acc) == TTable and acc or nil
        local ____receiver_2 = ____receiver_1 and (getmetatable(acc) == TTable and acc or nil).v
        return ____receiver_2 and ____receiver_2:get(k)
    end)
end

local function render(v)
    local ____mt = getmetatable(v)
    if ____mt == TStr then
        return "\"" .. __K2L_StringReplace(__K2L_StringReplace(__K2L_StringReplace(__K2L_StringReplace(v.v, "\\", "\\\\"), "\"", "\\\""), "\n", "\\n"), "\t", "\\t") .. "\""
    elseif ____mt == TInt then
        return tostring(v.v)
    elseif ____mt == TFloat then
        if v.v ~= v.v then
            return "nan"
        else
            return __K2L_Num.isInfinite(v.v) and "inf" or __K2L_Str(v.v)
        end
    elseif ____mt == TBool then
        return tostring(v.v)
    elseif ____mt == TArr then
        return __K2L_Utf16.norm(v.v:joinToString(", ", "[", "]", nil, nil, function(it) return render(it) end))
    elseif ____mt == TTable then
        return __K2L_Utf16.norm(v.v:getEntries():joinToString(", ", "{ ", " }", nil, nil, function(it) return it.key .. " = " .. render(it.value) end))
    end
end

local function serialize(t, prefix, out)
    if prefix == nil then
        prefix = ""
    end
    if out == nil then
        out = __K2L_StringBuilder.new()
    end
    local ____destructured = t.v:getEntries():partition(function(it)
        local ____value_12 = it.value
        local ____cond_1 = getmetatable(____value_12) == TTable
        if ____cond_1 then
            local ____list_2 = it.value.v:getValues()
            local ____result = false
            local ____items_1, ____n_1 = ____list_2:____array()
            for ____i_3 = 1, ____n_1 do
                local v = ____items_1[____i_3]
                if getmetatable(v) == TTable then
                    ____result = true
                    break
                end
            end
            ____cond_1 = ____result
        end
        local ____cond_3 = ____cond_1
        if not ____cond_3 then
            local ____cond_2 = #prefix == 0
            if ____cond_2 then
                local ____value_13 = it.value
                ____cond_2 = getmetatable(____value_13) == TTable
            end
            ____cond_3 = ____cond_2
        end
        return ____cond_3
    end)
    local tables, values = ____destructured.first, ____destructured.second
    local ____mod_3 = values.____modCount
    for ____i_4 = 1, values.size do
        local ____item_1 = values[____i_4]
        local k, v = ____item_1.key, ____item_1.value
        out:append(k):append(" = "):append(render(v)):append("\n")
        if values.____modCount ~= ____mod_3 and values:____comodified(____i_4) then
            break
        end
    end
    local ____mod_4 = tables.____modCount
    for ____i_5 = 1, tables.size do
        local ____item_2 = tables[____i_5]
        local k, v = ____item_2.key, ____item_2.value
        local name = #prefix == 0 and k or prefix .. "." .. k
        out:append("\n"):append("["):append(name):append("]\n")
        if getmetatable(v) ~= TTable then
            __K2L_CastFail(v, "TTable", "TTable")
        end
        serialize(v, name, out)
        if tables.____modCount ~= ____mod_4 and tables:____comodified(____i_5) then
            break
        end
    end
    return out:toString()
end

local CONFIG = __K2L_Text.trimIndent("\n# Service configuration\ntitle = \"k2l \\\"demo\\\" service\"   # trailing comment\nversion = 3\npi_ish = 3.141_59\nbig = 9_007_199_254_740_991\nmask = 0xFF_FF\nperms = 0o755\nflags = 0b1010_1010\nratio = -2.5e-3\nenabled = true\npath = 'C:\\Users\\k2l\\#notacomment'\ngreeting = \"tab\\there, newline\\nthere, unicode \\u00e9\\u00df\"\nports = [ 8080, 8081 , 8443 ]\nmatrix = [[1, 2], [3], []]\nowner = { name = \"Ada\", id = 36, roles = [\"admin\", \"dev\"] }\n\n[database]\nhost = \"db.local\"\nport = 5432\ntimeout = inf\n\n[database.pool]\nmin = 2\nmax = 16\n\n[logging]\nlevel = \"INFO\"\n")

local function main()
    local cfg = parseConfig(CONFIG)
    local ____list_3 = __K2L_ReadOnlyListOf("title", "version", "pi_ish", "big", "mask", "perms", "flags", "ratio", "enabled", "path", "greeting", "ports", "matrix", "owner.roles", "owner.id", "database.port", "database.timeout", "database.pool.max", "logging.level", "nope", "owner.nope")
    for ____i_6 = 1, ____list_3.size do
        local path = ____list_3[____i_6]
        local ____receiver_3 = lookup(cfg, path)
        local ____arg_3 = ____receiver_3 and __K2L_KClassOfValue(____receiver_3).simpleName or "-"
        local ____receiver_4 = lookup(cfg, path)
        local ____result_2
        if ____receiver_4 ~= nil then
            local ____result_1
            ____result_1 = render(____receiver_4)
            ____result_2 = ____result_1
        end
        print(__K2L_Utf16.out(__K2L_StringFormat("%-18s %-7s %s", path, ____arg_3, ____result_2 or "<missing>")))
    end
    local ____cast = lookup(cfg, "database.pool.max")
    if getmetatable(____cast) ~= TInt then
        __K2L_CastFail(____cast, "TInt", "TInt")
    end
    local ____arg_4 = ____cast.v
    local ____cast_1 = lookup(cfg, "ports")
    if getmetatable(____cast_1) ~= TArr then
        __K2L_CastFail(____cast_1, "TArr", "TArr")
    end
    local maxConn = ____arg_4 * ____cast_1.v.size
    local ____cast_2 = lookup(cfg, "mask")
    if getmetatable(____cast_2) ~= TInt then
        __K2L_CastFail(____cast_2, "TInt", "TInt")
    end
    local ____arg_5 = __K2L_Bits.ones64(____cast_2.v)
    local ____cast_3 = lookup(cfg, "perms")
    if getmetatable(____cast_3) ~= TInt then
        __K2L_CastFail(____cast_3, "TInt", "TInt")
    end
    print(__K2L_Utf16.out("max connections: " .. maxConn .. ", mask bits: " .. ____arg_5 .. ", perms: " .. __K2L_Num.toRadix(____cast_3.v, 8)))
    print(__K2L_Utf16.out("--- serialized ---"))
    io.write(__K2L_Utf16.out(serialize(cfg)))
    print(__K2L_Utf16.out("--- round trip ---"))
    local again = parseConfig(serialize(cfg))
    print(__K2L_Utf16.out(serialize(again) == serialize(cfg)))
    local env = __K2L_ReadOnlyMapOf(__K2L_Pair.new("APP_DATABASE_PORT", "6543"), __K2L_Pair.new("APP_LOGGING_LEVEL", "debug"), __K2L_Pair.new("APP_UNKNOWN", "x"))
    local ____keys, ____values, ____n_2 = env:____arrays()
    local ____mod_5 = env.____modCount
    for ____i_7 = 1, ____n_2 do
        local k, v = ____keys[____i_7], ____values[____i_7]
        local path = __K2L_StringReplace(__K2L_Utf16Case.lowercase(__K2L_Text.removePrefix(k, "APP_")), "_", ".")
        local old = lookup(cfg, path)
        local ____result_4
        if old ~= nil then
            local ____result_3
            ____result_3 = render(old)
            ____result_4 = ____result_3
        end
        local ____arg_6 = ____result_4 or "(none)"
        local ____receiver_5 = __K2L_StringToIntOrNull(v, nil, true)
        print(__K2L_Utf16.out(k .. " -> " .. path .. ": " .. ____arg_6 .. " => " .. (____receiver_5 and __K2L_Str(____receiver_5) or "\"" .. __K2L_Utf16Case.uppercase(v) .. "\"")))
        if env.____modCount ~= ____mod_5 and env:____comodified(____i_7, ____n_2) then
            break
        end
    end
    local broken = __K2L_ReadOnlyListOf("a = 1\na = 2", "x = [1, 2", "s = \"abc", "n = 12__3", "h = 0xZZ", "[t]\nv = 1\n[t.v]\n", "just some words", "k = \"bad \\q escape\"", "u = \"\\u12\"", "f = 1.2.3", "w = yes", "t = { a = 1 b = 2 }", "ok = 1 2")
    local ____mod_6 = broken.____modCount
    for ____i_8 = 1, broken.size do
        local b = broken[____i_8]
        local ____ok, ____result_5 = __K2L_DeepPcall(function()
            parseConfig(b)
            print(__K2L_Utf16.out("accepted: " .. __K2L_StringReplace(b, "\n", "\\n")))
        end)
        if not ____ok then
            local ____error = __K2L_ToThrowable(____result_5)
            if getmetatable(____error) == ConfigError then
                local e = ____error
                print(__K2L_Utf16.out("error " .. __K2L_Str(e.message)))
            else
                error(____error, 0)
            end
        end
        if broken.____modCount ~= ____mod_6 and broken:____comodified(____i_8) then
            break
        end
    end
end

__K2L_DeepMain(main)
return {ConfigError = ConfigError, TValue = TValue, TStr = TStr, TInt = TInt, TFloat = TFloat, TBool = TBool, TArr = TArr, TTable = TTable, ValueReader = ValueReader, stripComment = stripComment, parseConfig = parseConfig, lookup = lookup, render = render, serialize = serialize, CONFIG = CONFIG}
