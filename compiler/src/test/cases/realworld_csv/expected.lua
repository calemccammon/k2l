local ____lualib = require("lualib_bundle")
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CompareByDescending = ____lualib.__K2L_CompareByDescending
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_LazyObject = ____lualib.__K2L_LazyObject
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_StringIsBlank = ____lualib.__K2L_StringIsBlank
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringPadEnd = ____lualib.__K2L_StringPadEnd
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_StringToDouble = ____lualib.__K2L_StringToDouble
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ThenBy = ____lualib.__K2L_ThenBy
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Triple = ____lualib.__K2L_Triple

local Region = __K2L_Class("Region")

function Region:____init(name, ordinal, label, taxRate)
    self.name = name
    self.ordinal = ordinal
    self.label = label
    self.taxRate = taxRate
end

function Region:toString()
    return self.name
end

function Region:compareTo(other)
    return self.ordinal - other.ordinal
end

Region.NORTH = Region.new("NORTH", 0, "North", 0.07)
Region.SOUTH = Region.new("SOUTH", 1, "South", 0.05)
Region.EAST = Region.new("EAST", 2, "East", 0.0825)
Region.WEST = Region.new("WEST", 3, "West", 0.06)
Region.____values = {Region.NORTH, Region.SOUTH, Region.EAST, Region.WEST}
Region.____companion = true

function Region:parse(s)
    local ____value = self.byLabel:get(__K2L_StringTrim(s):lower())
    if ____value == nil then
        error(__K2L_IllegalArgumentException.new("unknown region '" .. s .. "'"))
    end
    return ____value
end

function Region:____initCompanion()
    local ____values = Region.____values
    local ____result = __K2L_Map.new()
    for ____i = 1, #____values do
        local it = ____values[____i]
        local ____value_1 = it.label:lower()
        ____result:put(____value_1, it)
    end
    self.byLabel = ____result
end

__K2L_LazyObject(Region, "____initCompanion")
local Sale = __K2L_Class("Sale")

function Sale:____init(id, date, rep, region, product, units, unitPrice)
    self.id = id
    self.date = date
    self.rep = rep
    self.region = region
    self.product = product
    self.units = units
    self.unitPrice = unitPrice
end

function Sale.new(id, date, rep, region, product, units, unitPrice)
    return setmetatable({id = id, date = date, rep = rep, region = region, product = product, units = units, unitPrice = unitPrice}, Sale)
end

function Sale:getRevenue()
    return self.units * self.unitPrice
end

function Sale:getMonth()
    return __K2L_Text.substring(self.date, 0, 7)
end

function Sale:toString()
    return "Sale(id=" .. self.id .. ", date=" .. self.date .. ", rep=" .. self.rep .. ", region=" .. __K2L_Str(self.region) .. ", product=" .. self.product .. ", units=" .. self.units .. ", unitPrice=" .. __K2L_Str(self.unitPrice) .. ")"
end

function Sale:hashCode()
    return (31 * (31 * (31 * (31 * (31 * (31 * self.id + __K2L_Hash(self.date)) + __K2L_Hash(self.rep)) + __K2L_Hash(self.region)) + __K2L_Hash(self.product)) + self.units) + __K2L_Hash(self.unitPrice) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Sale:equals(other)
    return getmetatable(other) == Sale and self.id == other.id and self.date == other.date and self.rep == other.rep and self.region == other.region and self.product == other.product and self.units == other.units and self.unitPrice == other.unitPrice
end

local RAW = "id,date,rep,region,product,units,unit_price\n1,2024-01-05,\"Smith, Anna\",North,Widget,12,2.50\n2,2024-01-09,Bob Jones,South,Gadget,3,19.99\n3,2024-01-17,\"Smith, Anna\",North,Gizmo,7,7.25\n4,2024-02-02,Carla Diaz,East,Widget,40,2.45\n5,2024-02-11,Bob Jones,South,Widget,15,2.50\n6,2024-02-14,\"O\"\"Brien, Pat\",West,Gadget,2,21.00\n7,2024-02-28,Carla Diaz,East,Gizmo,9,7.00\n8,2024-03-03,\"Smith, Anna\",North,Gadget,5,19.50\n9,2024-03-15,Dev Patel,West,Widget,-4,2.50\n10,2024-03-19,Dev Patel,Weast,Gizmo,4,7.10\n11,2024-03-21,Bob Jones,South,Gizmo,11,6.95\n12,2024-03-30,\"O\"\"Brien, Pat\",West,Widget,25,2.40\n13,2024-03-31,Carla Diaz,East,Gadget,6,\n"

local function parseCsvLine(line)
    local fields = __K2L_ListOf()
    local current = __K2L_StringBuilder.new()
    local inQuotes = false
    local i = 0
    while i < #line do
        local c = i >= 0 and i < #line and line:sub(i + 1, i + 1) or __K2L_IndexError(i, #line, "string")
        if inQuotes and c == "\"" and i + 1 < #line and (i + 1 >= 0 and i + 1 < #line and line:sub(i + 1 + 1, i + 1 + 1) or __K2L_IndexError(i + 1, #line, "string")) == "\"" then
            current:append("\"")
            i = i + 1
        elseif c == "\"" then
            inQuotes = not inQuotes
        elseif c == "," and not inQuotes then
            fields:add(current:toString())
            current:setLength(0)
        else
            current:append(c)
        end
        i = i + 1
    end
    fields:add(current:toString())
    return fields
end

local RowResult = __K2L_Class("RowResult")
RowResult.Ok = __K2L_Class("RowResult$Ok", RowResult)

function RowResult.Ok:____init(sale)
    self.sale = sale
end

function RowResult.Ok.new(sale)
    return setmetatable({sale = sale}, RowResult.Ok)
end

function RowResult.Ok:toString()
    return "Ok(sale=" .. __K2L_Str(self.sale) .. ")"
end

function RowResult.Ok:hashCode()
    return __K2L_Hash(self.sale)
end

function RowResult.Ok:equals(other)
    return getmetatable(other) == RowResult.Ok and self.sale:equals(other.sale)
end

RowResult.Bad = __K2L_Class("RowResult$Bad", RowResult)

function RowResult.Bad:____init(line, reason)
    self.line = line
    self.reason = reason
end

function RowResult.Bad.new(line, reason)
    return setmetatable({line = line, reason = reason}, RowResult.Bad)
end

function RowResult.Bad:toString()
    return "Bad(line=" .. self.line .. ", reason=" .. self.reason .. ")"
end

function RowResult.Bad:hashCode()
    return (31 * self.line + __K2L_Hash(self.reason) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function RowResult.Bad:equals(other)
    return getmetatable(other) == RowResult.Bad and self.line == other.line and self.reason == other.reason
end

local function parseRow(lineNo, header, line)
    local ____ok, ____result_1, ____returned = pcall(function()
        local cols = header:zip(parseCsvLine(line)):toMap()
        local function col(name)
            local ____receiver = cols:get(name)
            local ____value_2 = ____receiver and (not __K2L_StringIsBlank(____receiver) and ____receiver or nil)
            if ____value_2 == nil then
                error(__K2L_IllegalArgumentException.new("missing " .. name))
            end
            return ____value_2
        end
        local units = __K2L_StringToInt(col("units"))
        if not (units > 0) then
            error(__K2L_IllegalArgumentException.new("units must be positive, was " .. units))
        end
        return true, RowResult.Ok.new(Sale.new(__K2L_StringToInt(col("id")), col("date"), col("rep"), Region:parse(col("region")), col("product"), units, __K2L_StringToDouble(col("unit_price"))))
    end)
    if ____ok then
        if ____result_1 then
            return ____returned
        end
    else
        local ____error = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
            local e = ____error
            return RowResult.Bad.new(lineNo, e.message or __K2L_Str(e))
        else
            error(____error, 0)
        end
    end
end

local Stats = __K2L_Class("Stats")

function Stats:____init(count, mean, median, stdDev, min, max)
    self.count = count
    self.mean = mean
    self.median = median
    self.stdDev = stdDev
    self.min = min
    self.max = max
end

function Stats.new(count, mean, median, stdDev, min, max)
    return setmetatable({count = count, mean = mean, median = median, stdDev = stdDev, min = min, max = max}, Stats)
end

function Stats:toString()
    return "Stats(count=" .. self.count .. ", mean=" .. __K2L_Str(self.mean) .. ", median=" .. __K2L_Str(self.median) .. ", stdDev=" .. __K2L_Str(self.stdDev) .. ", min=" .. __K2L_Str(self.min) .. ", max=" .. __K2L_Str(self.max) .. ")"
end

function Stats:hashCode()
    return (31 * (31 * (31 * (31 * (31 * self.count + __K2L_Hash(self.mean)) + __K2L_Hash(self.median)) + __K2L_Hash(self.stdDev)) + __K2L_Hash(self.min)) + __K2L_Hash(self.max) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Stats:equals(other)
    return getmetatable(other) == Stats and self.count == other.count and self.mean == other.mean and self.median == other.median and self.stdDev == other.stdDev and self.min == other.min and self.max == other.max
end

local function stats(self)
    if not self:isNotEmpty() then
        error(__K2L_IllegalArgumentException.new("no data"))
    end
    local sorted = self:sorted()
    local mean = self:average()
    local median = (self.size >= 0 and self.size % 2 or 0 - -self.size % 2) == 1 and sorted:get(self.size >= 0 and self.size // 2 or 0 - -self.size // 2) or (sorted:get((self.size >= 0 and self.size // 2 or 0 - -self.size // 2) - 1) + sorted:get(self.size >= 0 and self.size // 2 or 0 - -self.size // 2)) / 2
    local ____sum = 0.0
    local ____items, ____n = self:____array()
    for ____i_1 = 1, ____n do
        local it = ____items[____i_1]
        ____sum = ____sum + (it - mean) ^ 2
    end
    local variance = ____sum / self.size
    return Stats.new(self.size, mean, median, math.sqrt(variance), sorted:first(), sorted:last())
end

local function money(x)
    return "$" .. __K2L_StringFormat("%,.2f", x)
end

local ____lambda_1 = function(it) return __K2L_Text.repeatCount("-", it) end
local function ____table(headers, rows, rightAlign)
    if rightAlign == nil then
        rightAlign = __K2L_ReadOnlySetOf()
    end
    local widths = headers:getIndices():map(function(c)
        return math.max(#headers:get(c), rows:maxOfOrNull(function(it) return #it:get(c) end) or 0)
    end)
    local function fmt(cells)
        local ____out = {}
        local ____count = 0
        local ____items_1, ____n_1 = cells:____array()
        for ____i_2 = 1, ____n_1 do
            local s = ____items_1[____i_2]
            local c = ____i_2 - 1
            local ____result_2
            ____result_2 = rightAlign:contains(c) and __K2L_StringPadStart(s, widths:get(c)) or __K2L_StringPadEnd(s, widths:get(c))
            ____count = ____count + 1
            ____out[____count] = ____result_2
        end
        return __K2L_ListWrap(____out, ____count):joinToString(" | ", "| ", " |")
    end
    local sep = widths:joinToString("-+-", "+-", "-+", nil, nil, ____lambda_1)
    return __K2L_ReadOnlyListOf(sep, fmt(headers), sep):plusAll(rows:map(fmt)):plus(sep):joinToString("\n")
end

local ____lambda_2 = function(it) return getmetatable(it) == RowResult.Ok end
local ____lambda_3 = function(x) return getmetatable(x) == RowResult.Bad end
local ____lambda_4 = function(it) return it.third end
local ____lambda_5 = function(it) return it.first end
local ____lambda_6 = function(it) return it.region end
local ____lambda_7 = function(acc, s)
    return acc:plus(__K2L_Pair.new(s:getMonth(), (acc:get(s:getMonth()) or 0.0) + s:getRevenue()))
end
local ____lambda_8 = function(receiver) return receiver.region end
local ____lambda_9 = function(it) return it.value end
local ____lambda_10 = function(receiver) return receiver:getRevenue() end
local ____lambda_11 = function(it) return it:getRevenue() end
local ____lambda_12 = function(it) return it.first end
local ____lambda_13 = function(it) return __K2L_Pair.new(it.rep, it.region) end
local ____lambda_14 = function(it) return it.value.id end
local ____lambda_15 = function(it) return it.date end
local ____lambda_16 = function(acc, s) return acc + s.units end
local function main()
    local ____list = __K2L_StringLines(RAW)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_2, ____n_2 = ____list:____array()
    for ____i_3 = 1, ____n_2 do
        local it = ____items_2[____i_3]
        if not __K2L_StringIsBlank(it) then
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = it
        end
    end
    local lines = __K2L_ListWrap(____out_1, ____count_1)
    local header = parseCsvLine(lines:first())
    local ____list_1 = lines:drop(1)
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_3, ____n_3 = ____list_1:____array()
    for ____i_4 = 1, ____n_3 do
        local line = ____items_3[____i_4]
        local i = ____i_4 - 1
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = parseRow(i + 2, header, line)
    end
    local results = __K2L_ListWrap(____out_2, ____count_2)
    local ____destructured = results:partition(____lambda_2)
    local good, bad = ____destructured.first, ____destructured.second
    local ____out_3 = {}
    local ____count_3 = 0
    local ____items_4, ____n_4 = good:____array()
    for ____i_5 = 1, ____n_4 do
        local it = ____items_4[____i_5]
        local ____result_3
        if getmetatable(it) ~= RowResult.Ok then
            __K2L_CastFail(it, "RowResult$Ok", "RowResult.Ok")
        end
        ____result_3 = it.sale
        ____count_3 = ____count_3 + 1
        ____out_3[____count_3] = ____result_3
    end
    local sales = __K2L_ListWrap(____out_3, ____count_3)
    print("parsed " .. sales.size .. " sales, " .. bad.size .. " rejected")
    local ____list_2 = bad:filter(____lambda_3)
    for ____i_6 = 1, ____list_2.size do
        local it = ____list_2[____i_6]
        print("  line " .. it.line .. ": " .. it.reason)
    end
    print("\nBy rep:")
    local ____result_4 = __K2L_Map.new()
    local ____items_5, ____n_5 = sales:____array()
    for ____i_7 = 1, ____n_5 do
        local it = ____items_5[____i_7]
        local ____value_3 = it.rep
        local ____group = ____result_4:get(____value_3)
        if ____group == nil then
            ____group = __K2L_List.new()
            ____result_4:put(____value_3, ____group)
        end
        ____group:add(it)
    end
    local byRep = ____result_4
    local repRows = byRep:map(function(____destructured_1)
        local rep, list = ____destructured_1.key, ____destructured_1.value
        local ____sum_1 = 0
        local ____items_6, ____n_6 = list:____array()
        for ____i_8 = 1, ____n_6 do
            local it = ____items_6[____i_8]
            ____sum_1 = ____sum_1 + it.units
        end
        local ____sum_2 = 0.0
        local ____items_7, ____n_7 = list:____array()
        for ____i_9 = 1, ____n_7 do
            local it = ____items_7[____i_9]
            ____sum_2 = ____sum_2 + it:getRevenue()
        end
        return __K2L_Triple.new(rep, ____sum_1, ____sum_2)
    end):sortedWith(__K2L_ThenBy(__K2L_CompareByDescending(____lambda_4), ____lambda_5))
    local ____arg = __K2L_ReadOnlyListOf("Rep", "Units", "Revenue")
    local ____out_4 = {}
    local ____count_4 = 0
    local ____items_8, ____n_8 = repRows:____array()
    for ____i_10 = 1, ____n_8 do
        local ____it_1 = ____items_8[____i_10]
        local ____result_5
        do
            local rep, units, rev = ____it_1.first, ____it_1.second, ____it_1.third
            ____result_5 = __K2L_ReadOnlyListOf(rep, tostring(units), money(rev))
        end
        ____count_4 = ____count_4 + 1
        ____out_4[____count_4] = ____result_5
    end
    print(____table(____arg, __K2L_ListWrap(____out_4, ____count_4), __K2L_ReadOnlySetOf(1, 2)))
    print("\nMonthly revenue by region:")
    local ____out_5 = {}
    local ____count_5 = 0
    local ____items_9, ____n_9 = sales:____array()
    for ____i_11 = 1, ____n_9 do
        local it = ____items_9[____i_11]
        ____count_5 = ____count_5 + 1
        ____out_5[____count_5] = it:getMonth()
    end
    local months = __K2L_ListWrap(____out_5, ____count_5):distinct():sorted()
    local pivot = sales:groupingBy(____lambda_6):fold(__K2L_ReadOnlyMapOf(), ____lambda_7)
    local ____values_1 = Region.____values
    local ____out_6 = {}
    local ____count_6 = 0
    for ____i_12 = 1, #____values_1 do
        local it = ____values_1[____i_12]
        if pivot:containsKey(it) then
            ____count_6 = ____count_6 + 1
            ____out_6[____count_6] = it
        end
    end
    local ____list_3 = __K2L_ListWrap(____out_6, ____count_6)
    local ____out_7 = {}
    local ____count_7 = 0
    local ____items_11, ____n_11 = ____list_3:____array()
    for ____i_14 = 1, ____n_11 do
        local r = ____items_11[____i_14]
        local ____result_6
        do
            local ____arg_1 = __K2L_SingletonListOf(r.label)
            local ____out_8 = {}
            local ____count_8 = 0
            local ____items_10, ____n_10 = months:____array()
            for ____i_13 = 1, ____n_10 do
                local m = ____items_10[____i_13]
                local ____result_7
                do
                    local ____receiver_1 = pivot:getValue(r):get(m)
                    ____result_7 = ____receiver_1 and __K2L_StringFormat("%.2f", ____receiver_1) or "-"
                end
                ____count_8 = ____count_8 + 1
                ____out_8[____count_8] = ____result_7
            end
            ____result_6 = ____arg_1:plusAll(__K2L_ListWrap(____out_8, ____count_8))
        end
        ____count_7 = ____count_7 + 1
        ____out_7[____count_7] = ____result_6
    end
    local pivotRows = __K2L_ListWrap(____out_7, ____count_7)
    print(____table(__K2L_SingletonListOf("Region"):plusAll(months), pivotRows, __K2L_IntRange.new(1, months.size):toSet()))
    print("\nTax owed:")
    local ____list_4 = sales:groupBy(__K2L_PropertyRef.new("region", "region@702", ____lambda_8)):mapValues(function(____destructured_2)
        local region, list = ____destructured_2.key, ____destructured_2.value
        local ____sum_3 = 0.0
        local ____items_12, ____n_12 = list:____array()
        for ____i_15 = 1, ____n_12 do
            local it = ____items_12[____i_15]
            ____sum_3 = ____sum_3 + it:getRevenue()
        end
        return ____sum_3 * region.taxRate
    end):getEntries():sortedByDescending(____lambda_9, true)
    local ____mod = ____list_4.____modCount
    for ____i_16 = 1, ____list_4.size do
        local ____it_2 = ____list_4[____i_16]
        do
            local region, tax = ____it_2.key, ____it_2.value
            print("  " .. __K2L_StringPadEnd(region.name, 6, ".") .. __K2L_StringPadStart(money(tax), 9) .. " (" .. __K2L_StringFormat("%.2f", region.taxRate * 100) .. "%)")
        end
        if ____list_4.____modCount ~= ____mod and ____list_4:____comodified(____i_16) then
            break
        end
    end
    local ____out_9 = {}
    local ____count_9 = 0
    local ____items_13, ____n_13 = sales:____array()
    for ____i_17 = 1, ____n_13 do
        local it = ____items_13[____i_17]
        ____count_9 = ____count_9 + 1
        ____out_9[____count_9] = it.unitPrice
    end
    local prices = __K2L_ListWrap(____out_9, ____count_9)
    local st = stats(prices)
    print("\nUnit price stats: n=" .. st.count .. " mean=" .. __K2L_StringFormat("%.3f", st.mean) .. " median=" .. __K2L_Str(st.median) .. " sd=" .. __K2L_StringFormat("%.4f", st.stdDev) .. " range=" .. __K2L_Str(st.min) .. ".." .. __K2L_Str(st.max))
    local revenues = sales:map(__K2L_PropertyRef.new("revenue", "/Sale.revenue", ____lambda_10))
    local ____value_4 = stats(revenues)
    print("Revenue stats: " .. __K2L_StringFormat("mean=%.2f median=%.2f max=%.2f", ____value_4.mean, ____value_4.median, ____value_4.max))
    local best = sales:maxBy(____lambda_11)
    local id, date, rep = best.id, best.date, best.rep
    print("\nBest sale: #" .. id .. " on " .. date .. " by " .. rep .. " (" .. money(best:getRevenue()) .. ")")
    local ____result_8 = __K2L_Map.new()
    local ____items_14, ____n_14 = sales:____array()
    for ____i_18 = 1, ____n_14 do
        local it = ____items_14[____i_18]
        local ____value_5 = it.product
        local ____group_1 = ____result_8:get(____value_5)
        if ____group_1 == nil then
            ____group_1 = __K2L_List.new()
            ____result_8:put(____value_5, ____group_1)
        end
        ____group_1:add(it)
    end
    local productShare = ____result_8:mapValues(function(____destructured_3)
        local v = ____destructured_3.value
        local ____sum_4 = 0.0
        local ____items_15, ____n_15 = v:____array()
        for ____i_19 = 1, ____n_15 do
            local it = ____items_15[____i_19]
            ____sum_4 = ____sum_4 + it:getRevenue()
        end
        return ____sum_4
    end)
    local totalRevenue = productShare:getValues():sum(0.0)
    local ____list_5 = productShare:toList():sortedBy(____lambda_12, true)
    local ____mod_1 = ____list_5.____modCount
    for ____i_20 = 1, ____list_5.size do
        local ____it_3 = ____list_5[____i_20]
        do
            local product, rev = ____it_3.first, ____it_3.second
            local pct = rev / totalRevenue * 100
            local bar = __K2L_Text.repeatCount("#", __K2L_Num.roundToInt(pct / 4))
            print(__K2L_StringFormat("  %-7s %6.1f%% %s", product, pct, bar))
        end
        if ____list_5.____modCount ~= ____mod_1 and ____list_5:____comodified(____i_20) then
            break
        end
    end
    local ____list_6 = sales:associate(____lambda_13):getEntries()
    local ____result_9 = __K2L_Map.new()
    local ____items_16, ____n_16 = ____list_6:____array()
    for ____i_21 = 1, ____n_16 do
        local it = ____items_16[____i_21]
        local ____value_6 = it.value
        local ____group_2 = ____result_9:get(____value_6)
        if ____group_2 == nil then
            ____group_2 = __K2L_List.new()
            ____result_9:put(____value_6, ____group_2)
        end
        ____group_2:add(it.key)
    end
    local repsByRegion = ____result_9
    print("reps by region: " .. __K2L_Str(repsByRegion))
    local ____result_10 = __K2L_Map.new()
    local ____items_17, ____n_17 = sales:____array()
    for ____i_22 = 1, ____n_17 do
        local it = ____items_17[____i_22]
        local ____value_7 = it:getMonth()
        ____result_10:put(____value_7, it)
    end
    local firstSaleOfMonth = ____result_10:mapValues(____lambda_14)
    print("last sale id per month: " .. __K2L_Str(firstSaleOfMonth))
    print("running units: " .. __K2L_Str(sales:sortedBy(____lambda_15, true):runningFold(0, ____lambda_16):drop(1)))
    local ____source = sales:first()
    local discounted = Sale.new(____source.id, ____source.date, ____source.rep, ____source.region, ____source.product, 100, 2.0)
    print("copy: " .. __K2L_Str(discounted) .. " revenue=" .. __K2L_Str(discounted:getRevenue()))
    local ____out_10 = {}
    local ____count_10 = 0
    local ____items_18, ____n_18 = sales:____array()
    for ____i_23 = 1, ____n_18 do
        local it = ____items_18[____i_23]
        if it.units >= 10 then
            ____count_10 = ____count_10 + 1
            ____out_10[____count_10] = it
        end
    end
    local ____list_7 = __K2L_ListWrap(____out_10, ____count_10)
    local ____out_11 = {}
    local ____count_11 = 0
    local ____items_19, ____n_19 = ____list_7:____array()
    for ____i_24 = 1, ____n_19 do
        local it = ____items_19[____i_24]
        ____count_11 = ____count_11 + 1
        ____out_11[____count_11] = it.id .. ":" .. it.units
    end
    print("big orders: " .. __K2L_Str(__K2L_ListWrap(____out_11, ____count_11)))
end

main()
return {Region = Region, Sale = Sale, RAW = RAW, parseCsvLine = parseCsvLine, RowResult = RowResult, parseRow = parseRow, Stats = Stats, stats = stats, money = money, ____table = ____table}
