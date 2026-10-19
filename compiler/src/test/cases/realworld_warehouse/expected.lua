local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_CompareByDescending = ____lualib.__K2L_CompareByDescending
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringPadEnd = ____lualib.__K2L_StringPadEnd
local __K2L_ThenBy = ____lualib.__K2L_ThenBy
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_Unpack = ____lualib.__K2L_Unpack

local Priced = __K2L_Class("warehouse.Priced")

function Priced:price(quantity)
    return self.unitPrice * quantity
end

local Discounted = __K2L_Class("warehouse.Discounted", nil, Priced)

function Discounted:price(quantity)
    return __K2L_IDiv(Priced.price(self, quantity) * (100 - self.discountPercent), 100)
end

local Taxed = __K2L_Class("warehouse.Taxed", nil, Priced)

function Taxed:price(quantity)
    return __K2L_IDiv(Priced.price(self, quantity) * 108, 100)
end

local Product = __K2L_Class("warehouse.Product", nil, Priced)

function Product:____init(sku, name)
    self.sku = sku
    self.name = name
    self.fragile = false
    if not __K2L_Regex.new("[A-Z]{2}-\\d{3}"):matches(self.sku) then
        error(__K2L_IllegalArgumentException.new("bad sku '" .. self.sku .. "'"))
    end
end

function Product:getLabel()
    return "[" .. self:getCategory() .. "] " .. self.name .. (self.fragile and " (fragile)" or "")
end

function Product:equals(other)
    return __K2L_InstanceOf(other, Product) and other.sku == self.sku
end

function Product:hashCode()
    return __K2L_Hash(self.sku)
end

function Product:toString()
    return self.sku
end

local Tool = __K2L_Class("warehouse.Tool", Product)

function Tool:____init(sku, name, unitPrice)
    Product.____init(self, sku, name)
    self.unitPrice = unitPrice
    self.category = "tool"
end

function Tool:____init1(sku, unitPrice)
    Tool.____init(self, sku, sku:lower(), unitPrice)
end

function Tool.new1(sku, unitPrice)
    local self = setmetatable({}, Tool)
    self:____init1(sku, unitPrice)
    return self
end

function Tool:getCategory()
    return self.category
end

local Glassware = __K2L_Class("warehouse.Glassware", Product, Discounted, Taxed)

function Glassware:____init(sku, name, unitPrice, discountPercent)
    Product.____init(self, sku, name)
    self.unitPrice = unitPrice
    self.discountPercent = discountPercent
    self.fragile = true
end

function Glassware:getCategory()
    return "glass"
end

function Glassware:price(quantity)
    return math.max(Discounted.price(self, quantity), Taxed.price(self, quantity) - 50)
end

local PowerTool = __K2L_Class("warehouse.PowerTool", Tool, Taxed)

function PowerTool:____init(sku, name, unitPrice, watts)
    Tool.____init(self, sku, name, unitPrice)
    self.watts = watts
    self.category__PowerTool = "power"
end

function PowerTool:getCategory()
    return self.category__PowerTool
end

function PowerTool:price(quantity)
    return Taxed.price(self, quantity)
end

local Slot = __K2L_Class("warehouse.Slot")

function Slot:____init(row, col)
    self.row = row
    self.col = col
end

function Slot:minus(o)
    return math.abs(self.row - o.row) + math.abs(self.col - o.col)
end

function Slot:toString()
    return "Slot(row=" .. self.row .. ", col=" .. self.col .. ")"
end

function Slot:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.row) + __K2L_Hash(self.col))
end

function Slot:equals(other)
    return getmetatable(other) == Slot and self.row == other.row and self.col == other.col
end

local Grid = __K2L_Class("warehouse.Grid")

function Grid:____init(rows, cols)
    self.rows = rows
    self.cols = cols
    self.cells = __K2L_ListOfSize(self.rows, function(it)
        return __K2L_ListOfSize(self.cols, nil, true)
    end, true)
    self.counts = __K2L_ListOfSize(self.rows, function(it) return __K2L_ListOfSize(self.cols, 0, true) end, true)
end

function Grid:get(slot)
    local ____receiver = self.cells:get(slot.row):get(slot.col)
    return ____receiver and __K2L_Pair.new(____receiver, self.counts:get(slot.row):get(slot.col))
end

function Grid:store(product, quantity)
    for r = 0, self.rows - 1 do
        for c = 0, self.cols - 1 do
            if __K2L_Equals(self.cells:get(r):get(c), product) then
                local ____object = self.counts:get(r)
                ____object:set(c, ____object:get(c) + quantity)
                return Slot.new(r, c)
            end
        end
    end
    for r = 0, self.rows - 1 do
        for c = 0, self.cols - 1 do
            do
                if self.cells:get(r):get(c) ~= nil then
                    goto ____continue
                end
                if product.fragile and r > 0 then
                    goto ____break
                end
                local ____object_1 = self.cells:get(r)
                ____object_1:set(c, product)
                local ____object_2 = self.counts:get(r)
                ____object_2:set(c, quantity)
                return Slot.new(r, c)
            end
            ::____continue::
        end
    end
    ::____break::
    error(__K2L_IllegalStateException.new("no room for " .. product:getLabel()))
end

function Grid:take(slot, quantity)
    local have = self.counts:get(slot.row):get(slot.col)
    local taken = math.min(quantity, have)
    local ____object_3 = self.counts:get(slot.row)
    local ____key = slot.col
    ____object_3:set(____key, ____object_3:get(____key) - taken)
    if self.counts:get(slot.row):get(slot.col) == 0 then
        local ____object_4 = self.cells:get(slot.row)
        local ____key_1 = slot.col
        ____object_4:set(____key_1, nil)
    end
    return taken
end

function Grid:find(product)
    local ____list = self.cells
    for r = 0, ____list.size - 1 do
        local row = ____list[r + 1]
        for c = 0, row.size - 1 do
            local p = row[c + 1]
            if __K2L_Equals(p, product) then
                return Slot.new(r, c)
            end
        end
    end
    return nil
end

function Grid:render()
    return self.cells:getIndices():joinToString("\n", nil, nil, nil, nil, function(r)
        return self.cells:get(r):getIndices():joinToString(" | ", nil, nil, nil, nil, function(c)
            local ____receiver_1 = self.cells:get(r):get(c)
            return ____receiver_1 and __K2L_StringPadEnd(____receiver_1.sku .. " x" .. self.counts:get(r):get(c), 10) or __K2L_StringPadEnd("-", 10)
        end)
    end)
end

function Grid:getTotalUnits()
    return self.counts:sumOf(function(it) return it:sum() end)
end

local Order = __K2L_Class("warehouse.Order")

function Order:____init(id, ...)
    local lines = __K2L_ArrayOf(...)
    self.id = id
    self.lines = lines:toList()
end

function Order:invoke(...)
    local lines = __K2L_ArrayOf(...)
    local ____old = self.next
    self.next = self.next + 1
    return Order.new(____old, __K2L_Unpack(lines))
end

function Order:____initCompanion()
    self.next = 1
end

Order:____initCompanion()

local function route(start, stops)
    local remaining = stops:toMutableList()
    local path = __K2L_ListOf()
    local at = start
    while remaining:isNotEmpty() do
        local nearest = remaining:minWith(__K2L_ThenBy(__K2L_ThenBy(__K2L_CompareBy(function(it) return it:minus(at) end), function(it) return it.row end), function(it) return it.col end))
        remaining:remove(nearest)
        path:add(nearest)
        at = nearest
    end
    return path
end

local function main()
    local hammer = Tool.new("TL-001", "hammer", 1200)
    local wrench = Tool.new1("TL-002", 900)
    local drill = PowerTool.new("PT-100", "drill", 8000, 650)
    local vase = Glassware.new("GL-007", "vase", 2500, 20)
    local glasses = Glassware.new("GL-008", "glasses", 400, 5)
    local products = __K2L_ReadOnlyListOf(hammer, wrench, drill, vase, glasses)
    local ____receiver_2 = __K2L_RunCatching(function() return Tool.new1("bad", 1) end):exceptionOrNull()
    print(__K2L_Str(____receiver_2 and ____receiver_2.message))
    for _, p in ipairs(products) do
        print(__K2L_StringPadEnd(p:getLabel(), 24) .. " 1=" .. p:price(1) .. " 10=" .. p:price(10))
    end
    local grid = Grid.new(3, 4)
    local stock = __K2L_ReadOnlyListOf(__K2L_Pair.new(hammer, 10), __K2L_Pair.new(drill, 2), __K2L_Pair.new(vase, 4), __K2L_Pair.new(glasses, 30), __K2L_Pair.new(wrench, 15), __K2L_Pair.new(hammer, 5))
    local slots = stock:map(function(____destructured)
        local p, q = ____destructured.first, ____destructured.second
        return grid:store(p, q)
    end)
    print(__K2L_Str(slots:map(function(it) return it.row .. "," .. it.col end)))
    local ____receiver_3 = __K2L_RunCatching(function()
        return grid:store(Glassware.new("GL-009", "bowl", 300, 0), 1)
    end):exceptionOrNull()
    print(__K2L_Str(____receiver_3 and ____receiver_3.message))
    print(grid:render())
    print("units=" .. grid:getTotalUnits())
    local orders = __K2L_ReadOnlyListOf(Order:invoke(__K2L_Pair.new(hammer, 3), __K2L_Pair.new(vase, 1)), Order:invoke(__K2L_Pair.new(glasses, 12), __K2L_Pair.new(drill, 1), __K2L_Pair.new(wrench, 2)), Order:invoke(__K2L_Pair.new(vase, 10)))
    for _, order in ipairs(orders) do
        local stops = order.lines:mapNotNull(function(____destructured_1)
            local p = ____destructured_1.first
            return grid:find(p)
        end)
        local path = route(Slot.new(2, 0), stops)
        local total = 0
        local picked = order.lines:map(function(____destructured_2)
            local p, q = ____destructured_2.first, ____destructured_2.second
            local ____value = grid:find(p)
            if ____value == nil then
                return p.sku .. ": none"
            end
            local slot = ____value
            local got = grid:take(slot, q)
            total = total + p:price(got)
            return p.sku .. ": " .. got .. "/" .. q
        end)
        print("order " .. order.id .. " route=" .. path:joinToString(">", nil, nil, nil, nil, function(it) return it.row .. it.col end) .. " " .. __K2L_Str(picked) .. " total=" .. total)
    end
    print(grid:render())
    print(__K2L_Str(grid:get(Slot.new(0, 0))))
    print(__K2L_Str(grid:get(Slot.new(2, 2))))
    local bySku = products:associateBy(function(it) return it.sku end)
    print(bySku:get("GL-007") == vase)
    print(products:toSet().size == __K2L_ReadOnlySetOf(Tool.new1("TL-001", 1), hammer).size + 3)
    local ____destructured_3 = products:partition(function(it) return it.fragile end)
    local fragile, sturdy = ____destructured_3.first, ____destructured_3.second
    print("fragile=" .. __K2L_Str(fragile) .. " sturdy=" .. __K2L_Str(sturdy))
    print(__K2L_Str(products:sortedWith(__K2L_ThenBy(__K2L_CompareByDescending(function(it) return it:price(1) end), function(it) return it.name end)):map(function(it) return it.name end)))
    print(__K2L_Str(products:windowed(2):map(function(____destructured_4)
        local a, b = ____destructured_4[1], ____destructured_4[2]
        return a:price(1) - b:price(1)
    end)))
end

main()
return {Priced = Priced, Discounted = Discounted, Taxed = Taxed, Product = Product, Tool = Tool, Glassware = Glassware, PowerTool = PowerTool, Slot = Slot, Grid = Grid, Order = Order, route = route}
