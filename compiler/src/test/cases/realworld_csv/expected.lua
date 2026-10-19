local ____lualib = require("lualib_bundle")
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CompareByDescending = ____lualib.__K2L_CompareByDescending
local __K2L_EnumValues = ____lualib.__K2L_EnumValues
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_LazyObject = ____lualib.__K2L_LazyObject
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringCharAt = ____lualib.__K2L_StringCharAt
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
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
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
    self.byLabel = __K2L_EnumValues(Region):associateBy(function(it) return it.label:lower() end)
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
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.id) + __K2L_Hash(self.date)) + __K2L_Hash(self.rep)) + __K2L_Hash(self.region)) + __K2L_Hash(self.product)) + __K2L_Hash(self.units)) + __K2L_Hash(self.unitPrice))
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
        local c = __K2L_StringCharAt(line, i)
        if inQuotes and c == "\"" and i + 1 < #line and __K2L_StringCharAt(line, i + 1) == "\"" then
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

function RowResult.Bad:toString()
    return "Bad(line=" .. self.line .. ", reason=" .. self.reason .. ")"
end

function RowResult.Bad:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.line) + __K2L_Hash(self.reason))
end

function RowResult.Bad:equals(other)
    return getmetatable(other) == RowResult.Bad and self.line == other.line and self.reason == other.reason
end

local function parseRow(lineNo, header, line)
    local ____ok, ____result, ____returned = pcall(function()
        local cols = header:zip(parseCsvLine(line)):toMap()
        local function col(name)
            local ____receiver = cols:get(name)
            local ____value_1 = ____receiver and (not __K2L_StringIsBlank(____receiver) and ____receiver or nil)
            if ____value_1 == nil then
                error(__K2L_IllegalArgumentException.new("missing " .. name))
            end
            return ____value_1
        end
        local units = __K2L_StringToInt(col("units"))
        if not (units > 0) then
            error(__K2L_IllegalArgumentException.new("units must be positive, was " .. units))
        end
        return true, RowResult.Ok.new(Sale.new(__K2L_StringToInt(col("id")), col("date"), col("rep"), Region:parse(col("region")), col("product"), units, __K2L_StringToDouble(col("unit_price"))))
    end)
    if ____ok then
        if ____result then
            return ____returned
        end
    else
        local ____error = __K2L_ToThrowable(____result)
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

function Stats:toString()
    return "Stats(count=" .. self.count .. ", mean=" .. __K2L_Str(self.mean) .. ", median=" .. __K2L_Str(self.median) .. ", stdDev=" .. __K2L_Str(self.stdDev) .. ", min=" .. __K2L_Str(self.min) .. ", max=" .. __K2L_Str(self.max) .. ")"
end

function Stats:hashCode()
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.count) + __K2L_Hash(self.mean)) + __K2L_Hash(self.median)) + __K2L_Hash(self.stdDev)) + __K2L_Hash(self.min)) + __K2L_Hash(self.max))
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
    local median = math.fmod(self.size, 2) == 1 and sorted:get(__K2L_IDiv(self.size, 2)) or (sorted:get(__K2L_IDiv(self.size, 2) - 1) + sorted:get(__K2L_IDiv(self.size, 2))) / 2
    local variance = self:sumOf(function(it) return (it - mean) ^ 2 end, 0.0) / self.size
    return Stats.new(self.size, mean, median, math.sqrt(variance), sorted:first(), sorted:last())
end

local function money(x)
    return "$" .. __K2L_StringFormat("%,.2f", x)
end

local function ____table(headers, rows, rightAlign)
    if rightAlign == nil then
        rightAlign = __K2L_ReadOnlySetOf()
    end
    local widths = headers:getIndices():map(function(c)
        return math.max(#headers:get(c), rows:maxOfOrNull(function(it) return #it:get(c) end) or 0)
    end)
    local function fmt(cells)
        return cells:mapIndexed(function(c, s)
            return rightAlign:contains(c) and __K2L_StringPadStart(s, widths:get(c)) or __K2L_StringPadEnd(s, widths:get(c))
        end):joinToString(" | ", "| ", " |")
    end
    local sep = widths:joinToString("-+-", "+-", "-+", nil, nil, function(it) return __K2L_Text.repeatCount("-", it) end)
    return __K2L_ReadOnlyListOf(sep, fmt(headers), sep):plusAll(rows:map(fmt)):plus(sep):joinToString("\n")
end

local function main()
    local lines = __K2L_StringLines(RAW):filter(function(it) return not __K2L_StringIsBlank(it) end)
    local header = parseCsvLine(lines:first())
    local results = lines:drop(1):mapIndexed(function(i, line) return parseRow(i + 2, header, line) end)
    local ____destructured = results:partition(function(it) return __K2L_InstanceOf(it, RowResult.Ok) end)
    local good, bad = ____destructured.first, ____destructured.second
    local sales = good:map(function(it)
        if not __K2L_InstanceOf(it, RowResult.Ok) then
            __K2L_CastFail(it, "RowResult$Ok", "RowResult.Ok")
        end
        return it.sale
    end)
    print("parsed " .. sales.size .. " sales, " .. bad.size .. " rejected")
    local ____list = bad:filter(function(x) return __K2L_InstanceOf(x, RowResult.Bad) end)
    for ____i = 1, ____list.size do
        local it = ____list[____i]
        print("  line " .. it.line .. ": " .. it.reason)
    end
    print("\nBy rep:")
    local byRep = sales:groupBy(function(it) return it.rep end)
    local repRows = byRep:map(function(____destructured_1)
        local rep, list = ____destructured_1.key, ____destructured_1.value
        return __K2L_Triple.new(rep, list:sumOf(function(it) return it.units end), list:sumOf(function(it) return it:getRevenue() end, 0.0))
    end):sortedWith(__K2L_ThenBy(__K2L_CompareByDescending(function(it) return it.third end), function(it) return it.first end))
    print(____table(__K2L_ReadOnlyListOf("Rep", "Units", "Revenue"), repRows:map(function(____destructured_2)
        local rep, units, rev = ____destructured_2.first, ____destructured_2.second, ____destructured_2.third
        return __K2L_ReadOnlyListOf(rep, tostring(units), money(rev))
    end), __K2L_ReadOnlySetOf(1, 2)))
    print("\nMonthly revenue by region:")
    local months = sales:map(function(it) return it:getMonth() end):distinct():sorted()
    local pivot = sales:groupingBy(function(it) return it.region end):fold(__K2L_ReadOnlyMapOf(), function(acc, s)
        return acc:plus(__K2L_Pair.new(s:getMonth(), (acc:get(s:getMonth()) or 0.0) + s:getRevenue()))
    end)
    local pivotRows = __K2L_EnumValues(Region):filter(function(it) return pivot:containsKey(it) end):map(function(r)
        return __K2L_SingletonListOf(r.label):plusAll(months:map(function(m)
            local ____receiver_1 = pivot:getValue(r):get(m)
            return ____receiver_1 and __K2L_StringFormat("%.2f", ____receiver_1) or "-"
        end))
    end)
    print(____table(__K2L_SingletonListOf("Region"):plusAll(months), pivotRows, __K2L_IntRange.new(1, months.size):toSet()))
    print("\nTax owed:")
    local ____list_1 = sales:groupBy(__K2L_PropertyRef.new("region", "region@702", function(receiver) return receiver.region end)):mapValues(function(____destructured_3)
        local region, list = ____destructured_3.key, ____destructured_3.value
        return list:sumOf(function(it) return it:getRevenue() end, 0.0) * region.taxRate
    end):getEntries():sortedByDescending(function(it) return it.value end, true)
    local ____mod = ____list_1.____modCount
    for ____i_1 = 1, ____list_1.size do
        local ____it_1 = ____list_1[____i_1]
        do
            local region, tax = ____it_1.key, ____it_1.value
            print("  " .. __K2L_StringPadEnd(region.name, 6, ".") .. __K2L_StringPadStart(money(tax), 9) .. " (" .. __K2L_StringFormat("%.2f", region.taxRate * 100) .. "%)")
        end
        if ____list_1.____modCount ~= ____mod and ____list_1:____comodified(____i_1) then
            break
        end
    end
    local prices = sales:map(function(it) return it.unitPrice end)
    local st = stats(prices)
    print("\nUnit price stats: n=" .. st.count .. " mean=" .. __K2L_StringFormat("%.3f", st.mean) .. " median=" .. __K2L_Str(st.median) .. " sd=" .. __K2L_StringFormat("%.4f", st.stdDev) .. " range=" .. __K2L_Str(st.min) .. ".." .. __K2L_Str(st.max))
    local revenues = sales:map(__K2L_PropertyRef.new("revenue", "/Sale.revenue", function(receiver) return receiver:getRevenue() end))
    local ____value_2 = stats(revenues)
    print("Revenue stats: " .. __K2L_StringFormat("mean=%.2f median=%.2f max=%.2f", ____value_2.mean, ____value_2.median, ____value_2.max))
    local best = sales:maxBy(function(it) return it:getRevenue() end)
    local id, date, rep = best.id, best.date, best.rep
    print("\nBest sale: #" .. id .. " on " .. date .. " by " .. rep .. " (" .. money(best:getRevenue()) .. ")")
    local productShare = sales:groupBy(function(it) return it.product end):mapValues(function(____destructured_4)
        local v = ____destructured_4.value
        return v:sumOf(function(it) return it:getRevenue() end, 0.0)
    end)
    local totalRevenue = productShare:getValues():sum(0.0)
    local ____list_2 = productShare:toList():sortedBy(function(it) return it.first end, true)
    local ____mod_1 = ____list_2.____modCount
    for ____i_2 = 1, ____list_2.size do
        local ____it_2 = ____list_2[____i_2]
        do
            local product, rev = ____it_2.first, ____it_2.second
            local pct = rev / totalRevenue * 100
            local bar = __K2L_Text.repeatCount("#", __K2L_Num.roundToInt(pct / 4))
            print(__K2L_StringFormat("  %-7s %6.1f%% %s", product, pct, bar))
        end
        if ____list_2.____modCount ~= ____mod_1 and ____list_2:____comodified(____i_2) then
            break
        end
    end
    local repsByRegion = sales:associate(function(it) return __K2L_Pair.new(it.rep, it.region) end):getEntries():groupBy(function(it) return it.value end, function(it) return it.key end)
    print("reps by region: " .. __K2L_Str(repsByRegion))
    local firstSaleOfMonth = sales:associateBy(function(it) return it:getMonth() end):mapValues(function(it) return it.value.id end)
    print("last sale id per month: " .. __K2L_Str(firstSaleOfMonth))
    print("running units: " .. __K2L_Str(sales:sortedBy(function(it) return it.date end, true):runningFold(0, function(acc, s) return acc + s.units end):drop(1)))
    local ____source = sales:first()
    local discounted = Sale.new(____source.id, ____source.date, ____source.rep, ____source.region, ____source.product, 100, 2.0)
    print("copy: " .. __K2L_Str(discounted) .. " revenue=" .. __K2L_Str(discounted:getRevenue()))
    print("big orders: " .. __K2L_Str(sales:filter(function(it) return it.units >= 10 end):map(function(it) return it.id .. ":" .. it.units end)))
end

main()
return {Region = Region, Sale = Sale, RAW = RAW, parseCsvLine = parseCsvLine, RowResult = RowResult, parseRow = parseRow, Stats = Stats, stats = stats, money = money, ____table = ____table}
