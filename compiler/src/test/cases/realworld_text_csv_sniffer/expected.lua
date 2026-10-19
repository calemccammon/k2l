local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringToDoubleOrNull = ____lualib.__K2L_StringToDoubleOrNull
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_Utf16 = ____lualib.__K2L_Utf16
local __K2L_Utf16Case = ____lualib.__K2L_Utf16Case

local printable
local Dialect = __K2L_Class("Dialect")

function Dialect:____init(delimiter, quote, hasHeader)
    self.delimiter = delimiter
    self.quote = quote
    self.hasHeader = hasHeader
end

function Dialect:toString()
    return "Dialect(delimiter=" .. printable(self.delimiter) .. ", quote=" .. printable(self.quote) .. ", header=" .. tostring(self.hasHeader) .. ")"
end

function Dialect:hashCode()
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.delimiter) + __K2L_Hash(self.quote)) + __K2L_Hash(self.hasHeader))
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
        return __K2L_Utf16.norm("'" .. c .. "'")
    end
end

local function splitRecords(text, d, q)
    local records = __K2L_ListOf()
    local fields = __K2L_ListOf()
    local field = __K2L_StringBuilder.new()
    local inQuotes = false
    local i = 0
    while i < __K2L_Utf16.len(text) do
        local c = __K2L_Text.get(text, i)
        if inQuotes then
            if c == q then
                if i + 1 < __K2L_Utf16.len(text) and __K2L_Text.get(text, i + 1) == q then
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

local function sniff(sample)
    local candidates = __K2L_ReadOnlyListOf(",", ";", "\t", "|", ":")
    local quote = __K2L_ReadOnlyListOf("\"", "'"):maxBy(function(q)
        return __K2L_Sequence.new(__K2L_Regex.new(__K2L_Regex.escape(q) .. "[^\\n]*?" .. __K2L_Regex.escape(q)):findAllFactory(sample)):count()
    end)
    local best = candidates:map(function(d)
        local counts = splitRecords(sample, d, quote):filter(function(it)
            return it:any(function(____p1) return not __K2L_Text.isBlank(____p1) end)
        end):map(function(it) return it.size end)
        local mode = counts:groupingBy(function(it) return it end):eachCount():maxByOrNull(function(it) return it.value end)
        local score = (mode == nil or mode.key < 2) and 0.0 or (mode.value + 0.0) / counts.size * math.min(mode.key, 10)
        return __K2L_Pair.new(d, score)
    end):maxBy(function(it) return it.second end).first
    local rows = splitRecords(sample, best, quote):filter(function(it) return it.size > 1 end)
    local header = rows:firstOrNull() or __K2L_ReadOnlyListOf()
    local body = rows:drop(1)
    local hasHeader = header:getIndices():any(function(col)
        local numericBody = body:count(function(r)
            local ____receiver = r:getOrNull(col)
            local ____receiver_1 = ____receiver and __K2L_Text.trim(____receiver)
            return (____receiver_1 and __K2L_StringToDoubleOrNull(____receiver_1)) ~= nil
        end)
        return __K2L_StringToDoubleOrNull(__K2L_Text.trim(header:get(col))) == nil and numericBody * 2 > body.size
    end) or header:isNotEmpty() and header:distinct().size == header.size and header:all(function(h)
        return not __K2L_Text.isBlank(h) and __K2L_Utf16Case.isLetter(__K2L_Text.first(h))
    end) and body:any(function(r)
        return r:zip(header):any(function(____destructured)
            local cell, h = ____destructured.first, ____destructured.second
            return __K2L_Utf16.len(cell) > __K2L_Utf16.len(h) * 2
        end)
    end)
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
local DATE = __K2L_Regex.new("\\d{4}-\\d{2}-\\d{2}")

local function typeOf(cell)
    local t = __K2L_Text.trim(cell)
    if #t == 0 then
        return ColType.EMPTY
    elseif __K2L_StringToIntOrNull(t, nil, true) ~= nil then
        return ColType.INT
    elseif __K2L_StringToDoubleOrNull(__K2L_StringReplace(t, ",", "")) ~= nil and __K2L_Text.toList(t):any(function(it) return it == "." or it == "e" end) then
        return ColType.DECIMAL
    elseif __K2L_ReadOnlySetOf("true", "false", "yes", "no"):contains(__K2L_Utf16Case.lowercase(t)) then
        return ColType.BOOL
    elseif DATE:matches(t) then
        return ColType.DATE
    else
        return ColType.TEXT
    end
end

local function columnType(cells)
    local types = cells:map(typeOf):filter(function(it) return it ~= ColType.EMPTY end):toSet()
    if types:isEmpty() then
        return ColType.EMPTY
    elseif types.size == 1 then
        return types:single()
    elseif __K2L_Equals(types, __K2L_ReadOnlySetOf(ColType.INT, ColType.DECIMAL)) then
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
    return __K2L_Utf16.norm(rows:joinToString("\n", nil, nil, nil, nil, function(row)
        return __K2L_Utf16.norm(row:joinToString(d, nil, nil, nil, nil, function(f)
            if __K2L_Text.toList(f):any(function(it) return it == d or it == q or it == "\n" end) or f ~= __K2L_Text.trim(f) then
                return __K2L_Utf16.norm(__K2L_Utf16.norm(q .. __K2L_StringReplace(f, q, __K2L_Utf16.norm(q .. q))) .. q)
            else
                return f
            end
        end))
    end))
end

local SAMPLES = __K2L_ReadOnlyMapOf(__K2L_Pair.new("semicolon", __K2L_Text.trimIndent("\n        name;city;amount;paid;since\n        \"Müller; Hans\";Zürich;1.234,50;yes;2019-03-01\n        Smith;\"New\n        York\";99.5;no;2020-11-30\n        \"O\"\"Brien\";Dublin;7;yes;\n    ")), __K2L_Pair.new("tabs", "id\tscore\tcomment\n1\t3.5\tgood\n2\t4\t\"tab\tinside\"\n3\t\t\n10\t2.25e1\tmeh"), __K2L_Pair.new("pipes-noheader", "1|2.5|x\n2|3.5|y\n3|4.5|z\n4|5.5|w"), __K2L_Pair.new("single-quotes", "'a,b',c,d\n'e',f,'g''h'\n'i','j',k"), __K2L_Pair.new("comma", __K2L_Text.trimIndent("\n        product,qty,price,discontinued,released\n        \"Widget, large\",10,4.99,false,2021-01-15\n        Gadget,3,12,true,2018-07-04\n        \"Gizmo \"\"Pro\"\" XL\",,199.00,false,2023-12-24\n        Thing,1,0.5,FALSE,2000-02-29\n    ")))

local function main()
    local ____map = SAMPLES
    local ____keys, ____values, ____n = ____map:____arrays()
    local ____mod_2 = ____map.____modCount
    for ____i_2 = 1, ____n do
        local name, text = ____keys[____i_2], ____values[____i_2]
        local dialect = sniff(text)
        local rows = splitRecords(text, dialect.delimiter, dialect.quote)
        print(__K2L_Utf16.out("== " .. name .. ": " .. __K2L_Str(dialect) .. ", " .. rows.size .. " rows"))
        local header
        if dialect.hasHeader then
            header = rows:first()
        else
            header = rows:first():getIndices():map(function(it) return "col" .. it + 1 end)
        end
        local body = dialect.hasHeader and rows:drop(1) or rows
        local types = header:getIndices():map(function(c)
            return columnType(body:map(function(it)
                return it:getOrElse(c, function(it) return "" end)
            end))
        end)
        print(__K2L_Utf16.out(__K2L_Utf16.norm(header:zip(types):joinToString(" | ", nil, nil, nil, nil, function(____destructured_1)
            local h, t = ____destructured_1.first, ____destructured_1.second
            return h .. ":" .. __K2L_Utf16Case.lowercase(t.name)
        end))))
        local widths = header:getIndices():map(function(c)
            return body:map(function(it)
                return __K2L_StringReplace(it:getOrElse(c, function(it) return "" end), "\n", "⏎")
            end):plus(header:get(c)):maxOf(function(it) return __K2L_Utf16.len(it) end)
        end)
        local ____mod = body.____modCount
        for ____i = 1, body.size do
            local r = body[____i]
            print(__K2L_Utf16.out(__K2L_Text.trimEnd(header:getIndices():joinToString(" | ", nil, nil, nil, nil, function(c)
                local cell = __K2L_StringReplace(r:getOrElse(c, function(it) return "" end), "\n", "⏎")
                return (types:get(c) == ColType.INT or types:get(c) == ColType.DECIMAL) and __K2L_Text.padStart(cell, widths:get(c)) or __K2L_Text.padEnd(cell, widths:get(c))
            end))))
            if body.____modCount ~= ____mod and body:____comodified(____i) then
                break
            end
        end
        local numeric = header:getIndices():filter(function(it)
            return types:get(it) == ColType.INT or types:get(it) == ColType.DECIMAL
        end)
        local ____mod_1 = numeric.____modCount
        for ____i_1 = 1, numeric.size do
            local c = numeric[____i_1]
            local values = body:mapNotNull(function(it)
                local ____receiver_2 = it:getOrNull(c)
                local ____receiver_3 = ____receiver_2 and __K2L_Text.trim(____receiver_2)
                return ____receiver_3 and __K2L_StringToDoubleOrNull(____receiver_3)
            end)
            print(__K2L_Utf16.out("  " .. header:get(c) .. ": n=" .. values.size .. " sum=" .. __K2L_StringFormat("%.2f", values:sum(0.0)) .. " min=" .. __K2L_Str(values:minOrNull()) .. " max=" .. __K2L_Str(values:maxOrNull())))
            if numeric.____modCount ~= ____mod_1 and numeric:____comodified(____i_1) then
                break
            end
        end
        print(__K2L_Utf16.out(__K2L_Utf16.norm(__K2L_StringLines(writeCsv(__K2L_SingletonListOf(header):plusAll(body))):joinToString("\n", nil, nil, nil, nil, function(it) return "  > " .. it end))))
        if ____map.____modCount ~= ____mod_2 and ____map:____comodified(____i_2, ____n) then
            break
        end
    end
end

main()
return {Dialect = Dialect, printable = printable, splitRecords = splitRecords, sniff = sniff, ColType = ColType, typeOf = typeOf, columnType = columnType, writeCsv = writeCsv, SAMPLES = SAMPLES}
