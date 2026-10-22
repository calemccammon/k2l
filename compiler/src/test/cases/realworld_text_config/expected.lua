local ____lualib = require("lualib_bundle")
local __K2L_Bits = ____lualib.__K2L_Bits
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_IsDigit = ____lualib.__K2L_IsDigit
local __K2L_IsLetter = ____lualib.__K2L_IsLetter
local __K2L_IsLetterOrDigit = ____lualib.__K2L_IsLetterOrDigit
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SimpleName = ____lualib.__K2L_SimpleName
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StrByte = ____lualib.__K2L_StrByte
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringEndsWith = ____lualib.__K2L_StringEndsWith
local __K2L_StringIndexOf = ____lualib.__K2L_StringIndexOf
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToDoubleOrNull = ____lualib.__K2L_StringToDoubleOrNull
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local ConfigError = __K2L_Class("ConfigError", __K2L_Exception)

function ConfigError:____init(line, msg)
    __K2L_Exception.____init(self, "line " .. line .. ": " .. msg)
    self.line = line
end

local TValue = __K2L_Class("TValue")
local TStr = __K2L_Class("TStr", nil, TValue)

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

function TFloat:____init(v)
    self.v = v
end

function TFloat.new(v)
    return setmetatable({v = v}, TFloat)
end

function TFloat:toString()
    return "TFloat(v=" .. self.v .. ")"
end

function TFloat:hashCode()
    return __K2L_Hash(self.v)
end

function TFloat:equals(other)
    return getmetatable(other) == TFloat and self.v == other.v
end

local TBool = __K2L_Class("TBool", nil, TValue)

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

function ValueReader:____init(s, line)
    self.s = s
    self.line = line
    self.i = 0
end

function ValueReader:fail(msg)
    error(ConfigError.new(self.line, msg .. " (column " .. self.i + 1 .. ")"))
end

function ValueReader:ws()
    while self.i < #self.s and ((self.i >= 0 and __K2L_StrByte(self.s, self.i + 1) or __K2L_IndexError(self.i, #self.s, "string")) == 32 or (self.i >= 0 and __K2L_StrByte(self.s, self.i + 1) or __K2L_IndexError(self.i, #self.s, "string")) == 9) do
        self.i = self.i + 1
    end
end

function ValueReader:read()
    self:ws()
    if self.i >= #self.s then
        self:fail("missing value")
    end
    local c = self.i >= 0 and self.i < #self.s and self.s:sub(self.i + 1, self.i + 1) or __K2L_IndexError(self.i, #self.s, "string")
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
        return __K2L_IsLetter[c] == true and self:keyword() or self:number()
    end
end

function ValueReader:basicString()
    self.i = self.i + 1
    local sb = __K2L_StringBuilder.new()
    while true do
        do
            if self.i >= #self.s then
                self:fail("unterminated string")
            end
            local ____arg = self.s
            local ____old = self.i
            self.i = self.i + 1
            local c = ____old >= 0 and ____old < #____arg and ____arg:sub(____old + 1, ____old + 1) or __K2L_IndexError(____old, #____arg, "string")
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
                local hex = __K2L_Text.substring(self.s, self.i, math.min(self.i + 4, #self.s))
                if #hex < 4 or not __K2L_StringToList(hex):all(function(it)
                    local ____cond = __K2L_IsDigit[it] == true
                    if not ____cond then
                        local ____value_4 = it:lower()
                        ____cond = ____value_4 >= "a" and ____value_4 <= "f"
                    end
                    return ____cond
                end) then
                    self:fail("bad unicode escape '\\u" .. hex .. "'")
                end
                sb:append(string.char(__K2L_StringToInt(hex, 16)))
                self.i = self.i + 4
            else
                self:fail("unknown escape '\\" .. e .. "'")
            end
        end
        ::____continue::
    end
end

local ____lambda_1 = function(it) return __K2L_IsLetter[it] == true end
function ValueReader:keyword()
    local word = __K2L_Text.takeWhile(__K2L_Text.substring(self.s, self.i), ____lambda_1)
    self.i = self.i + #word
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
    local ____receiver = __K2L_Regex.new("[-+0-9a-zA-Z_.]+", "[%-%+0-9a-zA-Z_%.]+"):matchAt(self.s, self.i)
    local ____value_5 = ____receiver and ____receiver.value
    if ____value_5 == nil then
        self:fail("unexpected '" .. (self.i >= 0 and self.i < #self.s and self.s:sub(self.i + 1, self.i + 1) or __K2L_IndexError(self.i, #self.s, "string")) .. "'")
    end
    local token = ____value_5
    self.i = self.i + #token
    local clean = __K2L_StringReplace(token, "_", "")
    if __K2L_StringContains(token, "__") or __K2L_StringStartsWith(token, "_") or __K2L_StringEndsWith(token, "_") then
        self:fail("misplaced underscore in '" .. token .. "'")
    end
    if __K2L_StringStartsWith(clean, "0x") then
        local ____value_10 = __K2L_StringToIntOrNull(__K2L_Text.drop(clean, 2), 16, true)
        if ____value_10 == nil then
            self:fail("bad hex '" .. token .. "'")
        end
        return TInt.new(____value_10)
    elseif __K2L_StringStartsWith(clean, "0o") then
        local ____value_9 = __K2L_StringToIntOrNull(__K2L_Text.drop(clean, 2), 8, true)
        if ____value_9 == nil then
            self:fail("bad octal '" .. token .. "'")
        end
        return TInt.new(____value_9)
    elseif __K2L_StringStartsWith(clean, "0b") then
        local ____value_8 = __K2L_StringToIntOrNull(__K2L_Text.drop(clean, 2), 2, true)
        if ____value_8 == nil then
            self:fail("bad binary '" .. token .. "'")
        end
        return TInt.new(____value_8)
    elseif __K2L_StringToList(clean):any(____lambda_2) then
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
        if self.i < #self.s and (self.i >= 0 and __K2L_StrByte(self.s, self.i + 1) or __K2L_IndexError(self.i, #self.s, "string")) == 93 then
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
    return __K2L_IsLetterOrDigit[it] == true or it == "_" or it == "-"
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
        self.i = self.i + #key
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
    local ____collection = __K2L_StringToList(line):withIndex()
    local ____items, ____n = ____collection:____array()
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
    end
    return line
end

local function parseConfig(text)
    local root = TTable.new()
    local current = root
    local ____list = __K2L_StringLines(text)
    for ____i_2 = 1, ____list.size do
        local raw = ____list[____i_2]
        local n = ____i_2 - 1
        do
            local lineNo = n + 1
            local line = __K2L_StringTrim(stripComment(raw))
            if #line == 0 then
                goto ____inline_end
            end
            local header = __K2L_Regex.new("^\\[\\s*([A-Za-z0-9_.-]+)\\s*]$", "^%[%s*([A-Za-z0-9_%.%-]+)%s*%]$"):matchEntire(line)
            if header ~= nil then
                current = root
                local ____list_1 = __K2L_StringSplit(header.groupValues:get(1), ".")
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
                end
                goto ____inline_end
            end
            local eq = __K2L_StringIndexOf(line, "=")
            if eq <= 0 then
                error(ConfigError.new(lineNo, "expected 'key = value' but got '" .. __K2L_Text.take(line, 20) .. "'"))
            end
            local key = __K2L_Text.removeSurrounding(__K2L_StringTrim(__K2L_Text.substring(line, 0, eq)), "\"")
            if not __K2L_Regex.new("[A-Za-z0-9_-]+", "[A-Za-z0-9_%-]+"):matches(key) then
                error(ConfigError.new(lineNo, "invalid key '" .. key .. "'"))
            end
            if current.v:containsKey(key) then
                error(ConfigError.new(lineNo, "duplicate key '" .. key .. "'"))
            end
            local reader = ValueReader.new(__K2L_Text.substring(line, eq + 1), lineNo)
            local ____object_2 = current.v
            ____object_2:set(key, reader:read())
            reader:ws()
            if reader.i < #line - eq - 1 then
                reader:fail("trailing characters")
            end
            ::____inline_end::
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
            return __K2L_Num.isInfinite(v.v) and "inf" or tostring(v.v)
        end
    elseif ____mt == TBool then
        return tostring(v.v)
    elseif ____mt == TArr then
        return v.v:joinToString(", ", "[", "]", nil, nil, function(it) return render(it) end)
    elseif ____mt == TTable then
        return v.v:getEntries():joinToString(", ", "{ ", " }", nil, nil, function(it) return it.key .. " = " .. render(it.value) end)
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
    for ____i_4 = 1, values.size do
        local ____item_1 = values[____i_4]
        local k, v = ____item_1.key, ____item_1.value
        out:append(k):append(" = "):append(render(v)):append("\n")
    end
    for ____i_5 = 1, tables.size do
        local ____item_2 = tables[____i_5]
        local k, v = ____item_2.key, ____item_2.value
        local name = #prefix == 0 and k or prefix .. "." .. k
        out:append("\n"):append("["):append(name):append("]\n")
        if getmetatable(v) ~= TTable then
            __K2L_CastFail(v, "TTable")
        end
        serialize(v, name, out)
    end
    return out:toString()
end

local CONFIG = __K2L_Text.trimIndent("\n# Service configuration\ntitle = \"k2l \\\"demo\\\" service\"   # trailing comment\nversion = 3\npi_ish = 3.141_59\nbig = 9_007_199_254_740_991\nmask = 0xFF_FF\nperms = 0o755\nflags = 0b1010_1010\nratio = -2.5e-3\nenabled = true\npath = 'C:\\Users\\k2l\\#notacomment'\ngreeting = \"tab\\there, newline\\nthere, unicode \\u00e9\\u00df\"\nports = [ 8080, 8081 , 8443 ]\nmatrix = [[1, 2], [3], []]\nowner = { name = \"Ada\", id = 36, roles = [\"admin\", \"dev\"] }\n\n[database]\nhost = \"db.local\"\nport = 5432\ntimeout = inf\n\n[database.pool]\nmin = 2\nmax = 16\n\n[logging]\nlevel = \"INFO\"\n")

local function main()
    local cfg = parseConfig(CONFIG)
    local ____list_3 = __K2L_ListOf("title", "version", "pi_ish", "big", "mask", "perms", "flags", "ratio", "enabled", "path", "greeting", "ports", "matrix", "owner.roles", "owner.id", "database.port", "database.timeout", "database.pool.max", "logging.level", "nope", "owner.nope")
    for ____i_6 = 1, ____list_3.size do
        local path = ____list_3[____i_6]
        local ____receiver_3 = lookup(cfg, path)
        local ____arg_3 = ____receiver_3 and __K2L_SimpleName(____receiver_3) or "-"
        local ____receiver_4 = lookup(cfg, path)
        local ____result_2
        if ____receiver_4 ~= nil then
            local ____result_1
            ____result_1 = render(____receiver_4)
            ____result_2 = ____result_1
        end
        print(string.format("%-18s %-7s %s", path, ____arg_3, ____result_2 or "<missing>"))
    end
    local ____cast = lookup(cfg, "database.pool.max")
    if getmetatable(____cast) ~= TInt then
        __K2L_CastFail(____cast, "TInt")
    end
    local ____arg_4 = ____cast.v
    local ____cast_1 = lookup(cfg, "ports")
    if getmetatable(____cast_1) ~= TArr then
        __K2L_CastFail(____cast_1, "TArr")
    end
    local maxConn = ____arg_4 * ____cast_1.v.size
    local ____cast_2 = lookup(cfg, "mask")
    if getmetatable(____cast_2) ~= TInt then
        __K2L_CastFail(____cast_2, "TInt")
    end
    local ____arg_5 = __K2L_Bits.ones64(____cast_2.v)
    local ____cast_3 = lookup(cfg, "perms")
    if getmetatable(____cast_3) ~= TInt then
        __K2L_CastFail(____cast_3, "TInt")
    end
    print("max connections: " .. maxConn .. ", mask bits: " .. ____arg_5 .. ", perms: " .. __K2L_Num.toRadix(____cast_3.v, 8))
    print("--- serialized ---")
    io.write(serialize(cfg))
    print("--- round trip ---")
    local again = parseConfig(serialize(cfg))
    print(serialize(again) == serialize(cfg))
    local env = __K2L_MapOf(__K2L_Pair.new("APP_DATABASE_PORT", "6543"), __K2L_Pair.new("APP_LOGGING_LEVEL", "debug"), __K2L_Pair.new("APP_UNKNOWN", "x"))
    local ____keys, ____values, ____n_2 = env:____arrays()
    for ____i_7 = 1, ____n_2 do
        local k, v = ____keys[____i_7], ____values[____i_7]
        local path = __K2L_StringReplace(__K2L_Text.removePrefix(k, "APP_"):lower(), "_", ".")
        local old = lookup(cfg, path)
        local ____result_4
        if old ~= nil then
            local ____result_3
            ____result_3 = render(old)
            ____result_4 = ____result_3
        end
        local ____arg_6 = ____result_4 or "(none)"
        local ____receiver_5 = __K2L_StringToIntOrNull(v, nil, true)
        print(k .. " -> " .. path .. ": " .. ____arg_6 .. " => " .. (____receiver_5 and __K2L_Str(____receiver_5) or "\"" .. v:upper() .. "\""))
    end
    local broken = __K2L_ListOf("a = 1\na = 2", "x = [1, 2", "s = \"abc", "n = 12__3", "h = 0xZZ", "[t]\nv = 1\n[t.v]\n", "just some words", "k = \"bad \\q escape\"", "u = \"\\u12\"", "f = 1.2.3", "w = yes", "t = { a = 1 b = 2 }", "ok = 1 2")
    for ____i_8 = 1, broken.size do
        local b = broken[____i_8]
        local ____ok, ____result_5 = pcall(function()
            parseConfig(b)
            print("accepted: " .. __K2L_StringReplace(b, "\n", "\\n"))
        end)
        if not ____ok then
            local ____error = __K2L_ToThrowable(____result_5)
            if getmetatable(____error) == ConfigError then
                local e = ____error
                print("error " .. __K2L_Str(e.message))
            else
                error(____error, 0)
            end
        end
    end
end

__K2L_RunMain(main)
return {ConfigError = ConfigError, TValue = TValue, TStr = TStr, TInt = TInt, TFloat = TFloat, TBool = TBool, TArr = TArr, TTable = TTable, ValueReader = ValueReader, stripComment = stripComment, parseConfig = parseConfig, lookup = lookup, render = render, serialize = serialize, CONFIG = CONFIG}
