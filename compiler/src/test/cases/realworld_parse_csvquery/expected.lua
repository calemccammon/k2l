local ____lualib = require("lualib_bundle")
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_Lazy = ____lualib.__K2L_Lazy
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_ReverseComparator = ____lualib.__K2L_ReverseComparator
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SequenceBuilder = ____lualib.__K2L_SequenceBuilder
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_SimpleName = ____lualib.__K2L_SimpleName
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StrByte = ____lualib.__K2L_StrByte
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringEqualsIgnoreCase = ____lualib.__K2L_StringEqualsIgnoreCase
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToDouble = ____lualib.__K2L_StringToDouble
local __K2L_StringToDoubleOrNull = ____lualib.__K2L_StringToDoubleOrNull
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Truncate = ____lualib.__K2L_Truncate

local CsvError = __K2L_Class("CsvError", __K2L_Exception)

function CsvError:____init(msg, record, col)
    __K2L_Exception.____init(self, "record " .. record .. ", column " .. col .. ": " .. msg)
    self.record = record
    self.col = col
end

local CsvState = __K2L_Class("CsvState")

function CsvState:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function CsvState:toString()
    return self.name
end

function CsvState:compareTo(other)
    return self.ordinal - other.ordinal
end

CsvState.FIELD_START = CsvState.new("FIELD_START", 0)
CsvState.UNQUOTED = CsvState.new("UNQUOTED", 1)
CsvState.QUOTED = CsvState.new("QUOTED", 2)
CsvState.QUOTE_IN_QUOTED = CsvState.new("QUOTE_IN_QUOTED", 3)
CsvState.____values = {CsvState.FIELD_START, CsvState.UNQUOTED, CsvState.QUOTED, CsvState.QUOTE_IN_QUOTED}

local function csvRecords(text, sep)
    if sep == nil then
        sep = ","
    end
    return __K2L_SequenceBuilder(function(self)
        local state = CsvState.FIELD_START
        local field = __K2L_StringBuilder.new()
        local record = __K2L_ListOf()
        local recNo = 1
        local col = 0
        local function endField()
            record:add(field:toString())
            field:setLength(0)
        end
        for ____i = 1, #text do
            local c = text:sub(____i, ____i)
            col = col + 1
            local ____subject = state
            if ____subject == CsvState.FIELD_START or ____subject == CsvState.UNQUOTED then
                if c == "\"" then
                    if state == CsvState.FIELD_START then
                        state = CsvState.QUOTED
                    else
                        error(CsvError.new("quote inside unquoted field", recNo, col))
                    end
                elseif c == sep then
                    endField()
                    state = CsvState.FIELD_START
                elseif c == "\n" then
                    endField()
                    if record.size > 1 or #record:get(0) > 0 then
                        self:yield(record)
                    end
                    record = __K2L_ListOf()
                    recNo = recNo + 1
                    col = 0
                    state = CsvState.FIELD_START
                elseif c == "\r" then
                    state = state
                else
                    field:append(c)
                    state = CsvState.UNQUOTED
                end
            elseif ____subject == CsvState.QUOTED then
                if c == "\"" then
                    state = CsvState.QUOTE_IN_QUOTED
                else
                    field:append(c)
                    state = CsvState.QUOTED
                end
            elseif ____subject == CsvState.QUOTE_IN_QUOTED then
                if c == "\"" then
                    field:append("\"")
                    state = CsvState.QUOTED
                elseif c == sep then
                    endField()
                    state = CsvState.FIELD_START
                elseif c == "\n" then
                    endField()
                    self:yield(record)
                    record = __K2L_ListOf()
                    recNo = recNo + 1
                    col = 0
                    state = CsvState.FIELD_START
                elseif c == "\r" then
                    state = state
                else
                    error(CsvError.new("unexpected '" .. c .. "' after closing quote", recNo, col))
                end
            end
        end
        if state == CsvState.QUOTED then
            error(CsvError.new("unterminated quoted field", recNo, col))
        end
        if field:isNotEmpty() or record:isNotEmpty() or state == CsvState.QUOTE_IN_QUOTED then
            endField()
            self:yield(record)
        end
    end)
end

local Table = __K2L_Class("Table")

function Table.new(header, rows)
    return setmetatable({header = header, rows = rows}, Table)
end

function Table:index(name)
    local ____value = self.header:indexOf(name)
    local ____value_1 = ____value >= 0 and ____value or nil
    if ____value_1 == nil then
        error(__K2L_IllegalArgumentException.new("no column '" .. name .. "' in " .. __K2L_Str(self.header)))
    end
    return ____value_1
end

local function ____load(text)
    local it = csvRecords(text):iterator()
    local ____list = it:next()
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i_1 = 1, ____n do
        local it = ____items[____i_1]
        ____count = ____count + 1
        ____out[____count] = __K2L_StringTrim(it):lower()
    end
    local header = __K2L_ListWrap(____out, ____count)
    local rows = __K2L_AsSequence(it):onEachIndexed(function(i, r)
        if r.size ~= header.size then
            error(__K2L_IllegalArgumentException.new("row " .. i + 2 .. " has " .. r.size .. " fields, expected " .. header.size))
        end
    end):toList()
    return Table.new(header, rows)
end

local Cond = __K2L_Class("Cond")
Cond.Cmp = __K2L_Class("Cond$Cmp", nil, Cond)

function Cond.Cmp.new(col, op, value)
    return setmetatable({col = col, op = op, value = value}, Cond.Cmp)
end

__K2L_DataClass(Cond.Cmp, {"col", "op", "value"})
Cond.And = __K2L_Class("Cond$And", nil, Cond)

function Cond.And.new(l, r)
    return setmetatable({l = l, r = r}, Cond.And)
end

__K2L_DataClass(Cond.And, {"l", "r"})
Cond.Or = __K2L_Class("Cond$Or", nil, Cond)

function Cond.Or.new(l, r)
    return setmetatable({l = l, r = r}, Cond.Or)
end

__K2L_DataClass(Cond.Or, {"l", "r"})
local Select = __K2L_Class("Select")

function Select.new(col, agg)
    return setmetatable({col = col, agg = agg}, Select)
end

function Select:getLabel()
    return self.agg == nil and self.col or self.agg .. "(" .. self.col .. ")"
end

__K2L_DataClass(Select, {"col", "agg"})
local Query = __K2L_Class("Query")

function Query.new(____select, where, groupBy, orderBy, desc, limit)
    return setmetatable({select = ____select, where = where, groupBy = groupBy, orderBy = orderBy, desc = desc, limit = limit}, Query)
end

__K2L_DataClass(Query, {"select", "where", "groupBy", "orderBy", "desc", "limit"})
local QUOTED = __K2L_Regex.new("'[^']*'", "'[^%']*'")
local TOKENS = __K2L_ListOf(QUOTED, __K2L_Regex.new("[A-Za-z_]\\w*", "[A-Za-z_][%w_]*"), __K2L_Regex.new("\\d+\\.?\\d*", "%d+%.?%d*"), __K2L_Regex.new("[<>!]=", "[%<%>%!]="), __K2L_Regex.new("[(),*=<>]", "[%(%)%,%*%=%<%>]"))

local function tokenize(src)
    local out = __K2L_ListOf()
    local i = 0
    while i < #src do
        do
            local m = TOKENS:firstNotNullOfOrNull(function(it) return it:matchAt(src, i) end)
            if m == nil then
                i = i + 1
                goto ____continue
            end
            local ____end = m.range.last + 1
            while __K2L_StringStartsWith(m.value, "'") and ____end < #src and (____end >= 0 and __K2L_StrByte(src, ____end + 1) or __K2L_IndexError(____end, #src, "string")) == 39 do
                local ____receiver = QUOTED:matchAt(src, ____end)
                local ____receiver_1 = ____receiver and ____receiver.range
                local ____receiver_2 = ____receiver_1 and ____receiver_1.last
                local ____value_2 = ____receiver_2 and ____receiver_2 + 1
                if ____value_2 == nil then
                    break
                end
                ____end = ____value_2
            end
            out:add(__K2L_Text.substring(src, i, ____end))
            i = ____end
        end
        ::____continue::
    end
    return out
end

local QueryParser = __K2L_Class("QueryParser")
local ____and, atom

local function peek(self)
    return self.toks:getOrNull(self.p)
end

local function kw(self, w)
    local ____receiver_3 = peek(self)
    return (____receiver_3 and __K2L_StringEqualsIgnoreCase(____receiver_3, w)) == true
end

local function ____next(self)
    local ____arg = self.toks
    local ____old = self.p
    self.p = self.p + 1
    local ____value_3 = ____arg:getOrNull(____old)
    if ____value_3 == nil then
        error(__K2L_IllegalArgumentException.new("unexpected end of query"))
    end
    return ____value_3
end

local function expect(self, w)
    if not __K2L_StringEqualsIgnoreCase(____next(self), w) then
        error(__K2L_IllegalArgumentException.new("expected " .. w .. " near token " .. self.p - 1))
    end
end

local function ____or(self)
    local l = ____and(self)
    while kw(self, "or") do
        self.p = self.p + 1
        l = Cond.Or.new(l, ____and(self))
    end
    return l
end

function ____and(self)
    local l = atom(self)
    while kw(self, "and") do
        self.p = self.p + 1
        l = Cond.And.new(l, atom(self))
    end
    return l
end

function atom(self)
    if kw(self, "(") then
        self.p = self.p + 1
        local ____value_4 = ____or(self)
        expect(self, ")")
        return ____value_4
    end
    local col = ____next(self):lower()
    local op = ____next(self)
    if not __K2L_SetOf("=", "!=", "<", "<=", ">", ">="):contains(op) then
        error(__K2L_IllegalArgumentException.new("bad operator '" .. op .. "'"))
    end
    local ____value_5 = ____next(self)
    local ____result
    ____result = __K2L_StringStartsWith(____value_5, "'") and __K2L_StringReplace(__K2L_Text.substring(____value_5, 1, #____value_5 - 1), "''", "'") or ____value_5
    local v = ____result
    return Cond.Cmp.new(col, op, v)
end

function QueryParser:____init(src)
    self.toks = tokenize(src)
    self.p = 0
end

function QueryParser:parse()
    expect(self, "select")
    local sel = __K2L_ListOf()
    repeat
        if sel:isNotEmpty() then
            self.p = self.p + 1
        end
        local name = ____next(self):lower()
        local ____temp
        if kw(self, "(") then
            self.p = self.p + 1
            local c = ____next(self):lower()
            expect(self, ")")
            ____temp = Select.new(c, name)
        else
            ____temp = Select.new(name)
        end
        sel:add(____temp)
    until not kw(self, ",")
    local where
    if kw(self, "where") then
        self.p = self.p + 1
        where = ____or(self)
    else
        where = nil
    end
    local group
    if kw(self, "group") then
        self.p = self.p + 1
        expect(self, "by")
        group = ____next(self):lower()
    else
        group = nil
    end
    local order = nil
    local desc = false
    if kw(self, "order") then
        self.p = self.p + 1
        expect(self, "by")
        order = ____next(self):lower()
        if kw(self, "(") then
            self.p = self.p + 1
            order = order .. "(" .. ____next(self):lower() .. ")"
            expect(self, ")")
        end
        if kw(self, "desc") or kw(self, "asc") then
            desc = ____next(self):lower() == "desc"
        end
    end
    local limit
    if kw(self, "limit") then
        self.p = self.p + 1
        limit = __K2L_StringToInt(____next(self))
    else
        limit = nil
    end
    if peek(self) ~= nil then
        error(__K2L_IllegalArgumentException.new("trailing input '" .. __K2L_Str(peek(self)) .. "'"))
    end
    return Query.new(sel, where, group, order, desc, limit)
end

local function compare(a, b)
    local x = __K2L_StringToDoubleOrNull(a)
    local y = __K2L_StringToDoubleOrNull(b)
    return x ~= nil and y ~= nil and __K2L_Compare(x, y) or __K2L_Text.compare(a, b)
end

local function test(____this, t, row)
    local ____mt = getmetatable(____this)
    if ____mt == Cond.And then
        return test(____this.l, t, row) and test(____this.r, t, row)
    elseif ____mt == Cond.Or then
        return test(____this.l, t, row) or test(____this.r, t, row)
    elseif ____mt == Cond.Cmp then
        local ____value_6 = compare(row:get(t:index(____this.col)), ____this.value)
        local ____result_1
        do
            local ____subject_1 = ____this.op
            if ____subject_1 == "=" then
                ____result_1 = ____value_6 == 0
            elseif ____subject_1 == "!=" then
                ____result_1 = ____value_6 ~= 0
            elseif ____subject_1 == "<" then
                ____result_1 = ____value_6 < 0
            elseif ____subject_1 == "<=" then
                ____result_1 = ____value_6 <= 0
            elseif ____subject_1 == ">" then
                ____result_1 = ____value_6 > 0
            else
                ____result_1 = ____value_6 >= 0
            end
        end
        return ____result_1
    end
end

local function fmt(d)
    return d == __K2L_Num.round(d) and tostring(__K2L_Truncate(d)) or string.format("%.2f", d)
end

local function run(t, q)
    local ____list_1 = t.rows
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_2 = 1, ____n_1 do
        local it = ____items_1[____i_2]
        local ____result_2
        do
            local ____receiver_4 = q.where
            local ____value_7 = ____receiver_4 and test(____receiver_4, t, it)
            if ____value_7 == nil then
                ____value_7 = true
            end
            ____result_2 = ____value_7
        end
        if ____result_2 then
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = it
        end
    end
    local rows = __K2L_ListWrap(____out_1, ____count_1)
    local groups
    if q.groupBy ~= nil then
        local ____result_3 = __K2L_Map.new()
        local ____items_2, ____n_2 = rows:____array()
        for ____i_3 = 1, ____n_2 do
            local it = ____items_2[____i_3]
            local ____value_8 = it:get(t:index(q.groupBy))
            local ____group = ____result_3:get(____value_8)
            if ____group == nil then
                ____group = __K2L_List.new()
                ____result_3:put(____value_8, ____group)
            end
            ____group:add(it)
        end
        groups = ____result_3
    else
        groups = __K2L_MapOf(__K2L_Pair.new("", rows))
    end
    local ____list_2 = q.select
    local ____result_4 = false
    local ____items_3, ____n_3 = ____list_2:____array()
    for ____i_4 = 1, ____n_3 do
        local it = ____items_3[____i_4]
        if it.agg ~= nil then
            ____result_4 = true
            break
        end
    end
    local aggregated = ____result_4
    local out
    if not aggregated then
        local ____out_2 = {}
        local ____count_2 = 0
        local ____items_5, ____n_5 = rows:____array()
        for ____i_6 = 1, ____n_5 do
            local r = ____items_5[____i_6]
            local ____result_5
            do
                local ____list_3 = q.select
                local ____out_3 = {}
                local ____count_3 = 0
                local ____items_4, ____n_4 = ____list_3:____array()
                for ____i_5 = 1, ____n_4 do
                    local it = ____items_4[____i_5]
                    local ____result_6
                    ____result_6 = it.col == "*" and r:joinToString("|") or r:get(t:index(it.col))
                    ____count_3 = ____count_3 + 1
                    ____out_3[____count_3] = ____result_6
                end
                ____result_5 = __K2L_ListWrap(____out_3, ____count_3)
            end
            ____count_2 = ____count_2 + 1
            ____out_2[____count_2] = ____result_5
        end
        out = __K2L_ListWrap(____out_2, ____count_2)
    else
        out = groups:map(function(____destructured)
            local g = ____destructured.value
            local ____list_4 = q.select
            local ____out_4 = {}
            local ____count_4 = 0
            local ____items_7, ____n_7 = ____list_4:____array()
            for ____i_8 = 1, ____n_7 do
                local s = ____items_7[____i_8]
                local ____result_7
                do
                    local ____nums_delegate = __K2L_Lazy(function()
                        local ____out_5 = {}
                        local ____count_5 = 0
                        local ____items_6, ____n_6 = g:____array()
                        for ____i_7 = 1, ____n_6 do
                            local it = ____items_6[____i_7]
                            ____count_5 = ____count_5 + 1
                            ____out_5[____count_5] = __K2L_StringToDouble(it:get(t:index(s.col)))
                        end
                        return __K2L_ListWrap(____out_5, ____count_5)
                    end)
                    local ____receiver_5 = s.agg
                    local ____subject_2 = ____receiver_5 and ____receiver_5:lower()
                    if ____subject_2 == nil then
                        ____result_7 = g:first():get(t:index(s.col))
                    elseif ____subject_2 == "count" then
                        ____result_7 = tostring(g.size)
                    elseif ____subject_2 == "sum" then
                        ____result_7 = fmt(____nums_delegate:getValue():sum(0.0))
                    elseif ____subject_2 == "avg" then
                        ____result_7 = fmt(____nums_delegate:getValue():average())
                    elseif ____subject_2 == "min" then
                        ____result_7 = fmt(____nums_delegate:getValue():min())
                    elseif ____subject_2 == "max" then
                        ____result_7 = fmt(____nums_delegate:getValue():max())
                    else
                        error(__K2L_IllegalArgumentException.new("unknown aggregate " .. s.agg))
                    end
                end
                ____count_4 = ____count_4 + 1
                ____out_4[____count_4] = ____result_7
            end
            return __K2L_ListWrap(____out_4, ____count_4)
        end)
    end
    local ____receiver_6 = q.orderBy
    if ____receiver_6 ~= nil then
        do
            local ____value_9 = q.select:indexOfFirst(function(it) return it:getLabel() == ____receiver_6 end)
            local ____value_10 = ____value_9 >= 0 and ____value_9 or nil
            if ____value_10 == nil then
                error(__K2L_IllegalArgumentException.new("ORDER BY " .. ____receiver_6 .. " is not selected"))
            end
            local i = ____value_10
            local cmp = function(a, b) return compare(a:get(i), b:get(i)) end
            out = out:sortedWith(q.desc and __K2L_ReverseComparator(cmp) or cmp)
        end
    end
    local ____receiver_7 = q.limit
    return ____receiver_7 and out:take(____receiver_7) or out
end

local data = "Name,Dept,Salary,City\r\n" .. "\"Smith, Anna\",Eng,120000,\"New York\"\r\n" .. "Bob \"Bobby\" Jones,Ops,85000,Austin\n" .. "\"Chen \"\"CJ\"\" Li\",Eng,135000.50,Seattle\n" .. "Dana,Sales,70000,\"Austin\"\n" .. "Émile,Eng,99000,Montréal\n" .. "\"Multi\nLine\",Ops,60000,\n" .. "Fay,Sales,91000,Seattle"

local ____lambda_1 = function() return ____load(data) end
local ____lambda_2 = function() return "∅" end
local ____lambda_3 = function(it)
    return __K2L_Text.ifEmpty(__K2L_StringReplace(it, "\n", "\\n"), ____lambda_2)
end
local ____lambda_4 = function(it) return it:getLabel() end
local ____lambda_5 = function(it) return "ok " .. __K2L_Str(it) end
local ____lambda_6 = function(it)
    return __K2L_Str(__K2L_SimpleName(it)) .. ": " .. __K2L_Str(it.message)
end
local ____lambda_7 = function(it) return it:single() end
local function main()
    local ____receiver_8 = __K2L_RunCatching(____lambda_1):exceptionOrNull()
    print(__K2L_Str(____receiver_8 and ____receiver_8.message))
    local fixed = __K2L_StringReplace(data, "Bob \"Bobby\" Jones", "\"Bob \"\"Bobby\"\" Jones\"")
    local t = ____load(fixed)
    print(__K2L_Str(t.header) .. " " .. t.rows.size .. " rows")
    local ____list_5 = t.rows
    for ____i_9 = 1, ____list_5.size do
        local r = ____list_5[____i_9]
        print(r:joinToString(" | ", nil, nil, nil, nil, ____lambda_3))
    end
    local queries = __K2L_ListOf("SELECT name, city WHERE dept = 'Eng' AND salary > 100000", "select dept, count(name), sum(salary), avg(salary) group by dept order by sum(salary) desc", "SELECT city, max(salary) GROUP BY city ORDER BY city", "SELECT name WHERE city = 'Austin' OR (dept = 'Sales' AND salary >= 91000) ORDER BY name DESC LIMIT 2", "SELECT * WHERE salary < 70000", "SELECT name WHERE name = 'Bob \"Bobby\" Jones'", "SELECT name, bogus", "SELECT name WHERE salary ~ 3", "SELECT name ORDER BY city", "SELECT name LIMIT", "SELECT name, frob(salary) GROUP BY dept", "UPDATE x")
    for ____i_11 = 1, queries.size do
        local src = queries[____i_11]
        print("> " .. src)
        local ____ok, ____result_8 = pcall(function()
            local q = QueryParser.new(src):parse()
            local res = run(t, q)
            print("  " .. q.select:joinToString("\t", nil, nil, nil, nil, ____lambda_4))
            for ____i_10 = 1, res.size do
                local it = res[____i_10]
                print("  " .. it:joinToString("\t"))
            end
        end)
        if not ____ok then
            local ____error = __K2L_ToThrowable(____result_8)
            if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
                local e = ____error
                print("  error: " .. __K2L_Str(e.message))
            else
                error(____error, 0)
            end
        end
    end
    local errs = __K2L_ListOf("a,\"b\nc", "a,\"b\"x,c", "x,y\n1,2,3")
    for ____i_12 = 1, errs.size do
        local e = errs[____i_12]
        print(__K2L_RunCatching(function() return ____load(e).rows end):fold(____lambda_5, ____lambda_6))
    end
    print(__K2L_Str(csvRecords("a;b;\"c;d\"\n;;\n", ";"):toList()))
    print(__K2L_Str(csvRecords("one\n\ntwo\n"):map(____lambda_7):toList()))
end

__K2L_RunMain(main)
return {CsvError = CsvError, CsvState = CsvState, csvRecords = csvRecords, Table = Table, ____load = ____load, Cond = Cond, Select = Select, Query = Query, tokenize = tokenize, QueryParser = QueryParser, compare = compare, test = test, fmt = fmt, run = run, data = data}
