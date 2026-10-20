local ____lualib = require("lualib_bundle")
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_DoubleToLong = ____lualib.__K2L_DoubleToLong
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_LoopItems = ____lualib.__K2L_LoopItems
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringToDoubleOrNull = ____lualib.__K2L_StringToDoubleOrNull
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Json = __K2L_Class("Json")
__K2L_ClassInfo(Json, "Json", "Json", "class")
Json.Null = __K2L_Class("Json$Null", Json)
__K2L_ClassInfo(Json.Null, "Json.Null", "Json$Null", "class")
Json.Bool = __K2L_Class("Json$Bool", Json)
__K2L_ClassInfo(Json.Bool, "Json.Bool", "Json$Bool", "class")

function Json.Bool:____init(value)
    self.value = value
end

function Json.Bool.new(value)
    return setmetatable({value = value}, Json.Bool)
end

function Json.Bool:toString()
    return "Bool(value=" .. tostring(self.value) .. ")"
end

function Json.Bool:hashCode()
    return self.value and 1231 or 1237
end

function Json.Bool:equals(other)
    return getmetatable(other) == Json.Bool and self.value == other.value
end

Json.Num = __K2L_Class("Json$Num", Json)
__K2L_ClassInfo(Json.Num, "Json.Num", "Json$Num", "class")

function Json.Num:____init(value)
    self.value = value
end

function Json.Num.new(value)
    return setmetatable({value = value}, Json.Num)
end

function Json.Num:toString()
    return "Num(value=" .. __K2L_Str(self.value) .. ")"
end

function Json.Num:hashCode()
    return __K2L_Hash(self.value)
end

function Json.Num:equals(other)
    return getmetatable(other) == Json.Num and self.value == other.value
end

Json.Str = __K2L_Class("Json$Str", Json)
__K2L_ClassInfo(Json.Str, "Json.Str", "Json$Str", "class")

function Json.Str:____init(value)
    self.value = value
end

function Json.Str.new(value)
    return setmetatable({value = value}, Json.Str)
end

function Json.Str:toString()
    return "Str(value=" .. self.value .. ")"
end

function Json.Str:hashCode()
    return __K2L_Hash(self.value)
end

function Json.Str:equals(other)
    return getmetatable(other) == Json.Str and self.value == other.value
end

Json.Arr = __K2L_Class("Json$Arr", Json)
__K2L_ClassInfo(Json.Arr, "Json.Arr", "Json$Arr", "class")

function Json.Arr:____init(items)
    self.items = items
end

function Json.Arr.new(items)
    return setmetatable({items = items}, Json.Arr)
end

function Json.Arr:toString()
    return "Arr(items=" .. __K2L_Str(self.items) .. ")"
end

function Json.Arr:hashCode()
    return __K2L_Hash(self.items)
end

function Json.Arr:equals(other)
    return getmetatable(other) == Json.Arr and __K2L_Equals(self.items, other.items)
end

Json.Obj = __K2L_Class("Json$Obj", Json)
__K2L_ClassInfo(Json.Obj, "Json.Obj", "Json$Obj", "class")

function Json.Obj:____init(fields)
    self.fields = fields
end

function Json.Obj.new(fields)
    return setmetatable({fields = fields}, Json.Obj)
end

function Json.Obj:toString()
    return "Obj(fields=" .. __K2L_Str(self.fields) .. ")"
end

function Json.Obj:hashCode()
    return __K2L_Hash(self.fields)
end

function Json.Obj:equals(other)
    return getmetatable(other) == Json.Obj and __K2L_Equals(self.fields, other.fields)
end

local JsonError = __K2L_Class("JsonError", __K2L_Exception)
__K2L_ClassInfo(JsonError, "JsonError", "JsonError", "class")

function JsonError:____init(message, offset)
    __K2L_Exception.____init(self, message)
    self.offset = offset
end

local Parser = __K2L_Class("Parser")
__K2L_ClassInfo(Parser, "Parser", "Parser", "class")

function Parser:____init(src)
    self.src = src
    self.pos = 0
end

function Parser:parse()
    local v = self:value()
    self:skipWs()
    if self.pos < #self.src then
        self:fail("unexpected trailing '" .. (self.pos >= 0 and self.pos < #self.src and self.src:sub(self.pos + 1, self.pos + 1) or __K2L_IndexError(self.pos, #self.src, "string")) .. "'")
    end
    return v
end

local ____lambda_1 = function(it) return it == "\n" end
function Parser:fail(msg)
    local line = __K2L_StringToList(__K2L_Text.substring(self.src, 0, math.min(self.pos, #self.src))):count(____lambda_1) + 1
    local ____arg = self.pos
    local ____value = __K2L_Text.lastIndexOf(self.src, "\n", self.pos - 1)
    local ____result
    ____result = ____value < 0 and -1 or ____value
    local col = ____arg - ____result
    error(JsonError.new(msg .. " at line " .. line .. ", column " .. col, self.pos))
end

function Parser:skipWs()
    while self.pos < #self.src and (self.pos >= 0 and self.pos < #self.src and self.src:sub(self.pos + 1, self.pos + 1) or __K2L_IndexError(self.pos, #self.src, "string")):match("^%s$") ~= nil do
        self.pos = self.pos + 1
    end
end

function Parser:peek()
    return self.pos < #self.src and (self.pos >= 0 and self.pos < #self.src and self.src:sub(self.pos + 1, self.pos + 1) or __K2L_IndexError(self.pos, #self.src, "string")) or "\000"
end

function Parser:expect(c)
    self:skipWs()
    if self:peek() ~= c then
        self:fail("expected '" .. c .. "' but found " .. (self.pos < #self.src and "'" .. (self.pos >= 0 and self.pos < #self.src and self.src:sub(self.pos + 1, self.pos + 1) or __K2L_IndexError(self.pos, #self.src, "string")) .. "'" or "end of input"))
    end
    self.pos = self.pos + 1
end

function Parser:value()
    self:skipWs()
    local c = self:peek()
    if c == "{" then
        return self:obj()
    elseif c == "[" then
        return self:arr()
    elseif c == "\"" then
        return Json.Str.new(self:string())
    elseif c == "t" or c == "f" or c == "n" then
        return self:literal()
    elseif c == "-" or c:match("^%d$") ~= nil then
        return self:number()
    else
        self:fail("unexpected character '" .. c .. "'")
    end
end

function Parser:literal()
    local ____list = __K2L_ReadOnlyListOf(__K2L_Pair.new("true", Json.Bool.new(true)), __K2L_Pair.new("false", Json.Bool.new(false)), __K2L_Pair.new("null", Json.Null))
    for ____i = 1, ____list.size do
        local ____item = ____list[____i]
        local word, v = ____item.first, ____item.second
        if self.src:sub(self.pos + 1, self.pos + #word) == word then
            self.pos = self.pos + #word
            return v
        end
    end
    self:fail("bad literal")
end

function Parser:number()
    local start = self.pos
    if self:peek() == "-" then
        self.pos = self.pos + 1
    end
    while self:peek():match("^%d$") ~= nil do
        self.pos = self.pos + 1
    end
    if self:peek() == "." then
        self.pos = self.pos + 1
        if self:peek():match("^%d$") == nil then
            self:fail("digit expected after '.'")
        end
        while self:peek():match("^%d$") ~= nil do
            self.pos = self.pos + 1
        end
    end
    if self:peek() == "e" or self:peek() == "E" then
        self.pos = self.pos + 1
        if self:peek() == "+" or self:peek() == "-" then
            self.pos = self.pos + 1
        end
        while self:peek():match("^%d$") ~= nil do
            self.pos = self.pos + 1
        end
    end
    local text = __K2L_Text.substring(self.src, start, self.pos)
    local ____value_1 = __K2L_StringToDoubleOrNull(text)
    if ____value_1 == nil then
        self:fail("bad number '" .. text .. "'")
    end
    return Json.Num.new(____value_1)
end

function Parser:string()
    self:expect("\"")
    local sb = __K2L_StringBuilder.new()
    while true do
        if self.pos >= #self.src then
            self:fail("unterminated string")
        end
        local ____arg_1 = self.src
        local ____old = self.pos
        self.pos = self.pos + 1
        local c = ____old >= 0 and ____old < #____arg_1 and ____arg_1:sub(____old + 1, ____old + 1) or __K2L_IndexError(____old, #____arg_1, "string")
        if c == "\"" then
            return sb:toString()
        elseif c == "\\" then
            local ____arg_2 = self.src
            local ____old_1 = self.pos
            self.pos = self.pos + 1
            local e = ____old_1 >= 0 and ____old_1 < #____arg_2 and ____arg_2:sub(____old_1 + 1, ____old_1 + 1) or __K2L_IndexError(____old_1, #____arg_2, "string")
            if e == "n" then
                sb:append("\n")
            elseif e == "t" then
                sb:append("\t")
            elseif e == "r" then
                sb:append("\r")
            elseif e == "b" then
                sb:append("\008")
            elseif e == "/" then
                sb:append("/")
            elseif e == "\\" then
                sb:append("\\")
            elseif e == "\"" then
                sb:append("\"")
            elseif e == "u" then
                local hex = __K2L_Text.substring(self.src, self.pos, self.pos + 4)
                self.pos = self.pos + 4
                sb:append(string.char(__K2L_StringToInt(hex, 16)))
            else
                self:fail("bad escape '\\" .. e .. "'")
            end
        else
            sb:append(c)
        end
    end
end

function Parser:arr()
    self:expect("[")
    local items = __K2L_ListOf()
    self:skipWs()
    if self:peek() == "]" then
        self.pos = self.pos + 1
        return Json.Arr.new(items)
    end
    while true do
        items:add(self:value())
        self:skipWs()
        local ____subject = self:peek()
        if ____subject == "," then
            self.pos = self.pos + 1
        elseif ____subject == "]" then
            self.pos = self.pos + 1
            return Json.Arr.new(items)
        else
            self:fail("expected ',' or ']'")
        end
    end
end

function Parser:obj()
    self:expect("{")
    local fields = __K2L_Map.new()
    self:skipWs()
    if self:peek() == "}" then
        self.pos = self.pos + 1
        return Json.Obj.new(fields)
    end
    while true do
        self:skipWs()
        local key = self:string()
        self:expect(":")
        fields:set(key, self:value())
        self:skipWs()
        local ____subject_1 = self:peek()
        if ____subject_1 == "," then
            self.pos = self.pos + 1
        elseif ____subject_1 == "}" then
            self.pos = self.pos + 1
            return Json.Obj.new(fields)
        else
            self:fail("expected ',' or '}'")
        end
    end
end

local function quote(s)
    local ____builder = __K2L_StringBuilder.new()
    ____builder:append("\"")
    for ____i_1 = 1, #s do
        local c = s:sub(____i_1, ____i_1)
        if c == "\"" then
            ____builder:append("\\\"")
        elseif c == "\\" then
            ____builder:append("\\\\")
        elseif c == "\n" then
            ____builder:append("\\n")
        elseif c == "\t" then
            ____builder:append("\\t")
        elseif c:byte() < 32 then
            ____builder:append("\\u"):append(__K2L_StringPadStart(__K2L_Num.toRadix(c:byte(), 16), 4, "0"))
        else
            ____builder:append(c)
        end
    end
    ____builder:append("\"")
    return ____builder:toString()
end

local function formatNumber(d)
    return d == math.floor(d) + 0.0 and not __K2L_Num.isInfinite(d) and math.abs(d) < 1.0E15 and tostring(__K2L_DoubleToLong(d)) or __K2L_Str(d)
end

local function compact(self)
    local ____mt = getmetatable(self)
    if __K2L_Equals(self, Json.Null) then
        return "null"
    elseif ____mt == Json.Bool then
        return tostring(self.value)
    elseif ____mt == Json.Num then
        return formatNumber(self.value)
    elseif ____mt == Json.Str then
        return quote(self.value)
    elseif ____mt == Json.Arr then
        return self.items:joinToString(",", "[", "]", nil, nil, function(it) return compact(it) end)
    elseif ____mt == Json.Obj then
        return self.fields:getEntries():joinToString(",", "{", "}", nil, nil, function(____destructured)
            local k, v = ____destructured.key, ____destructured.value
            return quote(k) .. ":" .. compact(v)
        end)
    end
end

local function pretty(____this, indent, step)
    if indent == nil then
        indent = 0
    end
    if step == nil then
        step = "  "
    end
    local pad = __K2L_Text.repeatCount(step, indent)
    local inner = __K2L_Text.repeatCount(step, indent + 1)
    local ____mt_1 = getmetatable(____this)
    if ____mt_1 == Json.Arr then
        if ____this.items:isEmpty() then
            return "[]"
        else
            return ____this.items:joinToString(",\n", "[\n", "\n" .. pad .. "]", nil, nil, function(it)
                return inner .. pretty(it, indent + 1, step)
            end)
        end
    elseif ____mt_1 == Json.Obj then
        if ____this.fields:isEmpty() then
            return "{}"
        else
            return ____this.fields:getEntries():joinToString(",\n", "{\n", "\n" .. pad .. "}", nil, nil, function(____destructured_1)
                local k, v = ____destructured_1.key, ____destructured_1.value
                return inner .. quote(k) .. ": " .. pretty(v, indent + 1, step)
            end)
        end
    else
        return compact(____this)
    end
end

local function pointer(____this_1, path)
    if #path == 0 then
        return ____this_1
    end
    local cur = ____this_1
    local ____list_1 = __K2L_StringSplit(__K2L_Text.removePrefix(path, "/"), "/")
    local ____mod = ____list_1.____modCount
    for ____i_2 = 1, ____list_1.size do
        local raw = ____list_1[____i_2]
        local token = __K2L_StringReplace(__K2L_StringReplace(raw, "~1", "/"), "~0", "~")
        local c = cur
        local ____mt_2 = getmetatable(c)
        if ____mt_2 == Json.Obj then
            local ____value_3 = c.fields:get(token)
            if ____value_3 == nil then
                return nil
            end
            cur = ____value_3
        elseif ____mt_2 == Json.Arr then
            local ____receiver = __K2L_StringToIntOrNull(token)
            local ____value_2 = ____receiver and c.items:getOrNull(____receiver)
            if ____value_2 == nil then
                return nil
            end
            cur = ____value_2
        else
            return nil
        end
        if ____list_1.____modCount ~= ____mod and ____list_1:____comodified(____i_2) then
            break
        end
    end
    return cur
end

local function stats(j, depth, acc)
    if depth == nil then
        depth = 0
    end
    if acc == nil then
        acc = __K2L_SortedMapOf()
    end
    local kind = __K2L_KClassOfValue(j).simpleName or "?"
    acc:set(kind, (acc:get(kind) or 0) + 1)
    acc:set("maxDepth", math.max(acc:get("maxDepth") or 0, depth))
    local ____mt_3 = getmetatable(j)
    if ____mt_3 == Json.Arr then
        local ____list_2 = j.items
        local ____mod_2 = ____list_2.____modCount
        for ____i_4 = 1, ____list_2.size do
            local it = ____list_2[____i_4]
            stats(it, depth + 1, acc)
            if ____list_2.____modCount ~= ____mod_2 and ____list_2:____comodified(____i_4) then
                break
            end
        end
    elseif ____mt_3 == Json.Obj then
        local ____collection = j.fields:getValues()
        local ____items, ____n = __K2L_LoopItems(____collection)
        local ____mod_1 = ____collection.____modCount
        for ____i_3 = 1, ____n do
            local it = ____items[____i_3]
            stats(it, depth + 1, acc)
            if ____collection.____modCount ~= ____mod_1 and ____collection:____comodified(____i_3, ____n) then
                break
            end
        end
    end
    return acc
end

local DOC = __K2L_Text.trimIndent("\n{\n  \"name\": \"k2l\",\n  \"version\": \"0.2.0\",\n  \"tags\": [\"kotlin\", \"lua\", \"transpiler\"],\n  \"stars\": 1234,\n  \"ratio\": 0.875,\n  \"big\": 1.5e20,\n  \"neg\": -42.25e-3,\n  \"nested\": {\"a/b\": {\"m~n\": [1, 2, {\"deep\": true}]}, \"empty\": {}, \"none\": null},\n  \"escaped\": \"line1\\nline2\\t\\\"quoted\\\" \\\\ éA\",\n  \"matrix\": [[1, 2], [3, 4], []]\n}\n")

local ____lambda_2 = function() return "-" end
local function main()
    local doc = Parser.new(DOC):parse()
    print(pretty(doc))
    print(compact(doc))
    print(__K2L_StringLines(pretty(doc, nil, "\t")):take(4):joinToString("|"))
    local ____list_3 = __K2L_ReadOnlyListOf("/name", "/tags/1", "/nested/a~1b/m~0n/2/deep", "/matrix/1/0", "/missing", "/tags/9", "")
    for ____i_5 = 1, ____list_3.size do
        local p = ____list_3[____i_5]
        local r = pointer(doc, p)
        local ____receiver_1 = r and compact(r)
        print(__K2L_StringFormat("pointer '%s' -> %s", p, ____receiver_1 and __K2L_Text.take(____receiver_1, 30) or "<none>"))
    end
    print(__K2L_Str(stats(doc)))
    local roundTrip = Parser.new(compact(doc)):parse()
    print("round trip equal: " .. tostring(__K2L_Equals(roundTrip, doc)))
    local bad = __K2L_ReadOnlyListOf("{\"a\": 1,}", "[1, 2", "{\"a\" 1}", "\"unterminated", "[1.]", "{\n  \"x\": tru\n}", "[1] 2", "@")
    local ____mod_3 = bad.____modCount
    for ____i_6 = 1, bad.size do
        local b = bad[____i_6]
        local ____ok, ____result_1 = __K2L_DeepPcall(function()
            Parser.new(b):parse()
            print("parsed?! " .. b)
        end)
        if not ____ok then
            local ____error = __K2L_ToThrowable(____result_1)
            if getmetatable(____error) == JsonError then
                local e = ____error
                print("error: " .. __K2L_Str(e.message) .. " (offset " .. e.offset .. ")")
            else
                error(____error, 0)
            end
        end
        if bad.____modCount ~= ____mod_3 and bad:____comodified(____i_6) then
            break
        end
    end
    local people = Parser.new("[{\"n\":\"Ada\",\"age\":36,\"langs\":[\"en\",\"fr\"]},{\"n\":\"Linus\",\"age\":54.5,\"langs\":[]},{\"n\":\"Grace\",\"age\":85,\"langs\":[\"en\"]}]"):parse()
    if getmetatable(people) ~= Json.Arr then
        __K2L_CastFail(people, "Json$Arr", "Json.Arr")
    end
    local ____list_4 = people.items
    local ____out = {}
    local ____count = 0
    local ____items_1, ____n_1 = ____list_4:____array()
    for ____i_7 = 1, ____n_1 do
        local it = ____items_1[____i_7]
        local ____result_2
        if getmetatable(it) ~= Json.Obj then
            __K2L_CastFail(it, "Json$Obj", "Json.Obj")
        end
        ____result_2 = it
        ____count = ____count + 1
        ____out[____count] = ____result_2
    end
    local rows = __K2L_ListWrap(____out, ____count)
    print(__K2L_StringFormat("%-8s|%6s|%s", "name", "age", "langs"))
    local ____mod_4 = rows.____modCount
    for ____i_8 = 1, rows.size do
        local r = rows[____i_8]
        local ____cast = r.fields:get("n")
        if getmetatable(____cast) ~= Json.Str then
            __K2L_CastFail(____cast, "Json$Str", "Json.Str")
        end
        local name = ____cast.value
        local ____cast_1 = r.fields:get("age")
        if getmetatable(____cast_1) ~= Json.Num then
            __K2L_CastFail(____cast_1, "Json$Num", "Json.Num")
        end
        local age = ____cast_1.value
        local ____cast_2 = r.fields:get("langs")
        if getmetatable(____cast_2) ~= Json.Arr then
            __K2L_CastFail(____cast_2, "Json$Arr", "Json.Arr")
        end
        local langs = __K2L_Text.ifEmpty(____cast_2.items:joinToString("+", nil, nil, nil, nil, function(it)
            if getmetatable(it) ~= Json.Str then
                __K2L_CastFail(it, "Json$Str", "Json.Str")
            end
            return it.value
        end), ____lambda_2)
        print(__K2L_StringFormat("%-8s|%6.1f|%s", name, age, langs))
        if rows.____modCount ~= ____mod_4 and rows:____comodified(____i_8) then
            break
        end
    end
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_2, ____n_2 = rows:____array()
    for ____i_9 = 1, ____n_2 do
        local it = ____items_2[____i_9]
        local ____result_3
        do
            local ____cast_3 = it.fields:get("age")
            if getmetatable(____cast_3) ~= Json.Num then
                __K2L_CastFail(____cast_3, "Json$Num", "Json.Num")
            end
            ____result_3 = ____cast_3.value
        end
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = ____result_3
    end
    local avg = __K2L_ListWrap(____out_1, ____count_1):average()
    print(__K2L_StringFormat("average age %.3f, %e, %g", avg, avg, avg))
end

__K2L_DeepMain(main)
return {Json = Json, JsonError = JsonError, Parser = Parser, quote = quote, formatNumber = formatNumber, compact = compact, pretty = pretty, pointer = pointer, stats = stats, DOC = DOC}
