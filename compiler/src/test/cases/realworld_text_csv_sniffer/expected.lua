local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_IsLetter = ____lualib.__K2L_IsLetter
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringIsBlank = ____lualib.__K2L_StringIsBlank
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringPadEnd = ____lualib.__K2L_StringPadEnd
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringToDoubleOrNull = ____lualib.__K2L_StringToDoubleOrNull
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_StringTrimEnd = ____lualib.__K2L_StringTrimEnd
local __K2L_Text = ____lualib.__K2L_Text

local printable
local Dialect = __K2L_Class("Dialect")

function Dialect:____init(delimiter, quote, hasHeader)
    self.delimiter = delimiter
    self.quote = quote
    self.hasHeader = hasHeader
end

function Dialect.new(delimiter, quote, hasHeader)
    return setmetatable({delimiter = delimiter, quote = quote, hasHeader = hasHeader}, Dialect)
end

function Dialect:toString()
    return "Dialect(delimiter=" .. printable(self.delimiter) .. ", quote=" .. printable(self.quote) .. ", header=" .. tostring(self.hasHeader) .. ")"
end

function Dialect:hashCode()
    return (31 * (31 * __K2L_Hash(self.delimiter) + __K2L_Hash(self.quote)) + (self.hasHeader and 1231 or 1237) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Dialect:equals(other)
    return getmetatable(other) == Dialect and self.delimiter == other.delimiter and self.quote == other.quote and self.hasHeader == other.hasHeader
end

function printable(c)
    if c == "\t" then
        return "\\t"
    elseif c == " " then
        return "' '"
    else
        return "'" .. c .. "'"
    end
end

local function splitRecords(text, d, q)
    local records = __K2L_ListOf()
    local fields = __K2L_ListOf()
    local field = __K2L_StringBuilder.new()
    local inQuotes = false
    local i = 0
    while i < #text do
        local c = i >= 0 and i < #text and text:sub(i + 1, i + 1) or __K2L_IndexError(i, #text, "string")
        if inQuotes then
            if c == q then
                if i + 1 < #text and (i + 1 >= 0 and i + 1 < #text and text:sub(i + 1 + 1, i + 1 + 1) or __K2L_IndexError(i + 1, #text, "string")) == q then
                    field:append(q)
                    i = i + 1
                else
                    inQuotes = false
                end
            else
                field:append(c)
            end
        elseif c == q then
            inQuotes = true
        elseif c == d then
            fields:add(field:toString())
            field:clear()
        elseif c == "\r" then
        elseif c == "\n" then
            fields:add(field:toString())
            field:clear()
            records:add(fields)
            fields = __K2L_ListOf()
        else
            field:append(c)
        end
        i = i + 1
    end
    if field:isNotEmpty() or fields:isNotEmpty() then
        fields:add(field:toString())
        records:add(fields)
    end
    return records
end

local ____lambda_1 = function(____p1) return not __K2L_StringIsBlank(____p1) end
local ____lambda_2 = function(it) return it end
local ____lambda_3 = function(it) return it.value end
local ____lambda_4 = function(it) return it.second end
local function sniff(sample)
    local candidates = __K2L_ListOf(",", ";", "\t", "|", ":")
    local quoted = __K2L_MapOf(__K2L_Pair.new("\"", __K2L_Regex.new("\"[^\\n]*?\"", "\"[^\n]-\"")), __K2L_Pair.new("'", __K2L_Regex.new("'[^\\n]*?'", "'[^\n]-'")))
    local quote = quoted:getKeys():maxBy(function(q)
        return __K2L_Sequence.new(quoted:getValue(q):findAllFactory(sample)):count()
    end)
    local ____out = {}
    local ____count = 0
    local ____items_2, ____n_2 = candidates:____array()
    for ____i_2 = 1, ____n_2 do
        local d = ____items_2[____i_2]
        local ____result
        do
            local ____list = splitRecords(sample, d, quote)
            local ____out_1 = {}
            local ____count_1 = 0
            local ____items, ____n = ____list:____array()
            for ____i = 1, ____n do
                local it = ____items[____i]
                if it:any(____lambda_1) then
                    ____count_1 = ____count_1 + 1
                    ____out_1[____count_1] = it
                end
            end
            local ____list_1 = __K2L_ListWrap(____out_1, ____count_1)
            local ____out_2 = {}
            local ____count_2 = 0
            local ____items_1, ____n_1 = ____list_1:____array()
            for ____i_1 = 1, ____n_1 do
                local it = ____items_1[____i_1]
                ____count_2 = ____count_2 + 1
                ____out_2[____count_2] = it.size
            end
            local counts = __K2L_ListWrap(____out_2, ____count_2)
            local mode = counts:groupingBy(____lambda_2):eachCount():maxByOrNull(____lambda_3)
            local score = (mode == nil or mode.key < 2) and 0.0 or (mode.value + 0.0) / counts.size * math.min(mode.key, 10)
            ____result = __K2L_Pair.new(d, score)
        end
        ____count = ____count + 1
        ____out[____count] = ____result
    end
    local best = __K2L_ListWrap(____out, ____count):maxBy(____lambda_4).first
    local ____list_2 = splitRecords(sample, best, quote)
    local ____out_3 = {}
    local ____count_3 = 0
    local ____items_3, ____n_3 = ____list_2:____array()
    for ____i_3 = 1, ____n_3 do
        local it = ____items_3[____i_3]
        if it.size > 1 then
            ____count_3 = ____count_3 + 1
            ____out_3[____count_3] = it
        end
    end
    local rows = __K2L_ListWrap(____out_3, ____count_3)
    local header = rows:firstOrNull() or __K2L_ListOf()
    local body = rows:drop(1)
    local ____cond_2 = header:getIndices():any(function(col)
        local ____result_1 = 0
        local ____items_4, ____n_4 = body:____array()
        for ____i_4 = 1, ____n_4 do
            local r = ____items_4[____i_4]
            local ____result_2
            do
                local ____receiver = r:getOrNull(col)
                local ____receiver_1 = ____receiver and __K2L_StringTrim(____receiver)
                ____result_2 = (____receiver_1 and __K2L_StringToDoubleOrNull(____receiver_1)) ~= nil
            end
            if ____result_2 then
                ____result_1 = ____result_1 + 1
            end
        end
        local numericBody = ____result_1
        return __K2L_StringToDoubleOrNull(__K2L_StringTrim(header:get(col))) == nil and numericBody * 2 > body.size
    end)
    if not ____cond_2 then
        local ____cond = header:isNotEmpty() and header:distinct().size == header.size
        if ____cond then
            local ____result_3 = true
            local ____items_5, ____n_5 = header:____array()
            for ____i_5 = 1, ____n_5 do
                local h = ____items_5[____i_5]
                if not (not __K2L_StringIsBlank(h) and __K2L_IsLetter[__K2L_Text.first(h)] == true) then
                    ____result_3 = false
                    break
                end
            end
            ____cond = ____result_3
        end
        local ____cond_1 = ____cond
        if ____cond_1 then
            local ____result_4 = false
            local ____items_7, ____n_7 = body:____array()
            for ____i_7 = 1, ____n_7 do
                local r = ____items_7[____i_7]
                local ____result_5
                do
                    local ____list_3 = r:zip(header)
                    local ____result_6 = false
                    local ____items_6, ____n_6 = ____list_3:____array()
                    for ____i_6 = 1, ____n_6 do
                        local ____it = ____items_6[____i_6]
                        local ____result_7
                        do
                            local cell, h = ____it.first, ____it.second
                            ____result_7 = #cell > #h * 2
                        end
                        if ____result_7 then
                            ____result_6 = true
                            break
                        end
                    end
                    ____result_5 = ____result_6
                end
                if ____result_5 then
                    ____result_4 = true
                    break
                end
            end
            ____cond_1 = ____result_4
        end
        ____cond_2 = ____cond_1
    end
    local hasHeader = ____cond_2
    return Dialect.new(best, quote, hasHeader)
end

local ColType = __K2L_Class("ColType")

function ColType:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function ColType:toString()
    return self.name
end

function ColType:compareTo(other)
    return self.ordinal - other.ordinal
end

ColType.INT = ColType.new("INT", 0)
ColType.DECIMAL = ColType.new("DECIMAL", 1)
ColType.BOOL = ColType.new("BOOL", 2)
ColType.DATE = ColType.new("DATE", 3)
ColType.TEXT = ColType.new("TEXT", 4)
ColType.EMPTY = ColType.new("EMPTY", 5)
ColType.____values = {ColType.INT, ColType.DECIMAL, ColType.BOOL, ColType.DATE, ColType.TEXT, ColType.EMPTY}
local DATE = __K2L_Regex.new("\\d{4}-\\d{2}-\\d{2}", "%d%d%d%d%-%d%d%-%d%d")

local ____lambda_5 = function(it) return it == "." or it == "e" end
local function typeOf(cell)
    local t = __K2L_StringTrim(cell)
    if #t == 0 then
        return ColType.EMPTY
    elseif __K2L_StringToIntOrNull(t, nil, true) ~= nil then
        return ColType.INT
    elseif __K2L_StringToDoubleOrNull(__K2L_StringReplace(t, ",", "")) ~= nil and __K2L_StringToList(t):any(____lambda_5) then
        return ColType.DECIMAL
    elseif __K2L_SetOf("true", "false", "yes", "no"):contains(t:lower()) then
        return ColType.BOOL
    elseif DATE:matches(t) then
        return ColType.DATE
    else
        return ColType.TEXT
    end
end

local function columnType(cells)
    local ____list_4 = cells:map(typeOf)
    local ____out_4 = {}
    local ____count_4 = 0
    local ____items_8, ____n_8 = ____list_4:____array()
    for ____i_8 = 1, ____n_8 do
        local it = ____items_8[____i_8]
        if it ~= ColType.EMPTY then
            ____count_4 = ____count_4 + 1
            ____out_4[____count_4] = it
        end
    end
    local types = __K2L_ListWrap(____out_4, ____count_4):toSet()
    if types:isEmpty() then
        return ColType.EMPTY
    elseif types.size == 1 then
        return types:single()
    elseif __K2L_Equals(types, __K2L_SetOf(ColType.INT, ColType.DECIMAL)) then
        return ColType.DECIMAL
    else
        return ColType.TEXT
    end
end

local function writeCsv(rows, d, q)
    if d == nil then
        d = ","
    end
    if q == nil then
        q = "\""
    end
    return rows:joinToString("\n", nil, nil, nil, nil, function(row)
        return row:joinToString(d, nil, nil, nil, nil, function(f)
            if __K2L_StringToList(f):any(function(it) return it == d or it == q or it == "\n" end) or f ~= __K2L_StringTrim(f) then
                return q .. __K2L_StringReplace(f, q, q .. q) .. q
            else
                return f
            end
        end)
    end)
end

local SAMPLES = __K2L_MapOf(__K2L_Pair.new("semicolon", __K2L_Text.trimIndent("\n        name;city;amount;paid;since\n        \"Müller; Hans\";Zürich;1.234,50;yes;2019-03-01\n        Smith;\"New\n        York\";99.5;no;2020-11-30\n        \"O\"\"Brien\";Dublin;7;yes;\n    ")), __K2L_Pair.new("tabs", "id\tscore\tcomment\n1\t3.5\tgood\n2\t4\t\"tab\tinside\"\n3\t\t\n10\t2.25e1\tmeh"), __K2L_Pair.new("pipes-noheader", "1|2.5|x\n2|3.5|y\n3|4.5|z\n4|5.5|w"), __K2L_Pair.new("single-quotes", "'a,b',c,d\n'e',f,'g''h'\n'i','j',k"), __K2L_Pair.new("comma", __K2L_Text.trimIndent("\n        product,qty,price,discontinued,released\n        \"Widget, large\",10,4.99,false,2021-01-15\n        Gadget,3,12,true,2018-07-04\n        \"Gizmo \"\"Pro\"\" XL\",,199.00,false,2023-12-24\n        Thing,1,0.5,FALSE,2000-02-29\n    ")))

local ____lambda_6 = function(it) return "col" .. it + 1 end
local ____lambda_7 = function(it) return "" end
local ____lambda_8 = function(it) return "" end
local ____lambda_9 = function(it) return "" end
local ____lambda_10 = function(it) return "  > " .. it end
local function main()
    local ____map = SAMPLES
    local ____keys, ____values, ____n_9 = ____map:____arrays()
    for ____i_15 = 1, ____n_9 do
        local name, text = ____keys[____i_15], ____values[____i_15]
        local dialect = sniff(text)
        local rows = splitRecords(text, dialect.delimiter, dialect.quote)
        print("== " .. name .. ": " .. __K2L_Str(dialect) .. ", " .. rows.size .. " rows")
        local header
        if dialect.hasHeader then
            header = rows:first()
        else
            header = rows:first():getIndices():map(____lambda_6)
        end
        local body = dialect.hasHeader and rows:drop(1) or rows
        local types = header:getIndices():map(function(c)
            local ____out_5 = {}
            local ____count_5 = 0
            local ____items_9, ____n_10 = body:____array()
            for ____i_9 = 1, ____n_10 do
                local it = ____items_9[____i_9]
                local ____result_8
                ____result_8 = it:getOrElse(c, ____lambda_7)
                ____count_5 = ____count_5 + 1
                ____out_5[____count_5] = ____result_8
            end
            return columnType(__K2L_ListWrap(____out_5, ____count_5))
        end)
        print(header:zip(types):joinToString(" | ", nil, nil, nil, nil, function(____destructured)
            local h, t = ____destructured.first, ____destructured.second
            return h .. ":" .. t.name:lower()
        end))
        local widths = header:getIndices():map(function(c)
            local ____out_6 = {}
            local ____count_6 = 0
            local ____items_10, ____n_11 = body:____array()
            for ____i_10 = 1, ____n_11 do
                local it = ____items_10[____i_10]
                local ____result_9
                ____result_9 = __K2L_StringReplace(it:getOrElse(c, ____lambda_8), "\n", "⏎")
                ____count_6 = ____count_6 + 1
                ____out_6[____count_6] = ____result_9
            end
            local ____list_5 = __K2L_ListWrap(____out_6, ____count_6):plus(header:get(c))
            local ____best
            local ____has = false
            local ____items_11, ____n_12 = ____list_5:____array()
            for ____i_11 = 1, ____n_12 do
                local it = ____items_11[____i_11]
                local ____key = #it
                if not ____has or ____best < ____key then
                    ____best = ____key
                    ____has = true
                end
            end
            if not ____has then
                error(__K2L_NoSuchElementException.new(nil))
            end
            return ____best
        end)
        for ____i_12 = 1, body.size do
            local r = body[____i_12]
            print(__K2L_StringTrimEnd(header:getIndices():joinToString(" | ", nil, nil, nil, nil, function(c)
                local cell = __K2L_StringReplace(r:getOrElse(c, ____lambda_9), "\n", "⏎")
                return (types:get(c) == ColType.INT or types:get(c) == ColType.DECIMAL) and __K2L_StringPadStart(cell, widths:get(c)) or __K2L_StringPadEnd(cell, widths:get(c))
            end)))
        end
        local numeric = header:getIndices():filter(function(it)
            return types:get(it) == ColType.INT or types:get(it) == ColType.DECIMAL
        end)
        for ____i_14 = 1, numeric.size do
            local c = numeric[____i_14]
            local ____out_7 = {}
            local ____count_7 = 0
            local ____items_12, ____n_13 = body:____array()
            for ____i_13 = 1, ____n_13 do
                local it = ____items_12[____i_13]
                local ____result_10
                do
                    local ____receiver_2 = it:getOrNull(c)
                    local ____receiver_3 = ____receiver_2 and __K2L_StringTrim(____receiver_2)
                    ____result_10 = ____receiver_3 and __K2L_StringToDoubleOrNull(____receiver_3)
                end
                local ____value = ____result_10
                if ____value ~= nil then
                    ____count_7 = ____count_7 + 1
                    ____out_7[____count_7] = ____value
                end
            end
            local values = __K2L_ListWrap(____out_7, ____count_7)
            print("  " .. header:get(c) .. ": n=" .. values.size .. " sum=" .. string.format("%.2f", values:sum(0.0)) .. " min=" .. __K2L_Str(values:minOrNull()) .. " max=" .. __K2L_Str(values:maxOrNull()))
        end
        print(__K2L_StringLines(writeCsv(__K2L_ListOf(header):plusAll(body))):joinToString("\n", nil, nil, nil, nil, ____lambda_10))
    end
end

__K2L_RunMain(main)
return {Dialect = Dialect, printable = printable, splitRecords = splitRecords, sniff = sniff, ColType = ColType, typeOf = typeOf, columnType = columnType, writeCsv = writeCsv, SAMPLES = SAMPLES}
