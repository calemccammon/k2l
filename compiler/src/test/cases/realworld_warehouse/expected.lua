local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CompareValues = ____lualib.__K2L_CompareValues
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringPadEnd = ____lualib.__K2L_StringPadEnd
local __K2L_Unpack = ____lualib.__K2L_Unpack

local Priced = __K2L_Class("warehouse.Priced")

function Priced:price(quantity)
    return self.unitPrice * quantity
end

local Discounted = __K2L_Class("warehouse.Discounted", nil, Priced)

function Discounted:price(quantity)
    return Priced.price(self, quantity) * (100 - self.discountPercent) // 100
end

local Taxed = __K2L_Class("warehouse.Taxed", nil, Priced)

function Taxed:price(quantity)
    return Priced.price(self, quantity) * 108 // 100
end

local Product = __K2L_Class("warehouse.Product", nil, Priced)

function Product:____init(sku, name)
    self.sku = sku
    self.name = name
    self.fragile = false
    if not __K2L_Regex.new("[A-Z]{2}-\\d{3}", "[A-Z][A-Z]%-%d%d%d"):matches(self.sku) then
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

function Slot.new(row, col)
    return setmetatable({row = row, col = col}, Slot)
end

function Slot:minus(o)
    return math.abs(self.row - o.row) + math.abs(self.col - o.col)
end

__K2L_DataClass(Slot, {"row", "col"})
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
    local ____receiver = (self.cells[slot.row + 1] or __K2L_IndexError(slot.row, self.cells.size, "array")):get(slot.col)
    return ____receiver and __K2L_Pair.new(____receiver, (self.counts[slot.row + 1] or __K2L_IndexError(slot.row, self.counts.size, "array")):get(slot.col))
end

function Grid:store(product, quantity)
    for r = 0, self.rows - 1 do
        for c = 0, self.cols - 1 do
            if __K2L_Equals((self.cells[r + 1] or __K2L_IndexError(r, self.cells.size, "array")):get(c), product) then
                local ____object = self.counts[r + 1] or __K2L_IndexError(r, self.counts.size, "array")
                ____object[c + 1] = (____object[c + 1] or __K2L_IndexError(c, ____object.size, "array")) + quantity
                return Slot.new(r, c)
            end
        end
    end
    for r = 0, self.rows - 1 do
        for c = 0, self.cols - 1 do
            do
                if (self.cells[r + 1] or __K2L_IndexError(r, self.cells.size, "array")):get(c) ~= nil then
                    goto ____continue
                end
                if product.fragile and r > 0 then
                    goto ____break
                end
                local ____object_1 = self.cells[r + 1] or __K2L_IndexError(r, self.cells.size, "array")
                ____object_1:set(c, product)
                local ____object_2 = self.counts[r + 1] or __K2L_IndexError(r, self.counts.size, "array")
                if c < 0 or c >= ____object_2.size then
                    __K2L_IndexError(c, ____object_2.size, "array")
                end
                ____object_2[c + 1] = quantity
                return Slot.new(r, c)
            end
            ::____continue::
        end
    end
    ::____break::
    error(__K2L_IllegalStateException.new("no room for " .. product:getLabel()))
end

function Grid:take(slot, quantity)
    local have = (self.counts[slot.row + 1] or __K2L_IndexError(slot.row, self.counts.size, "array")):get(slot.col)
    local taken = math.min(quantity, have)
    local ____object_3 = self.counts[slot.row + 1] or __K2L_IndexError(slot.row, self.counts.size, "array")
    local ____key = slot.col
    ____object_3[____key + 1] = (____object_3[____key + 1] or __K2L_IndexError(____key, ____object_3.size, "array")) - taken
    if (self.counts[slot.row + 1] or __K2L_IndexError(slot.row, self.counts.size, "array")):get(slot.col) == 0 then
        local ____object_4 = self.cells[slot.row + 1] or __K2L_IndexError(slot.row, self.cells.size, "array")
        local ____key_1 = slot.col
        ____object_4:set(____key_1, nil)
    end
    return taken
end

function Grid:find(product)
    local ____list = self.cells
    for ____i_1 = 1, ____list.size do
        local row = ____list[____i_1]
        local r = ____i_1 - 1
        for ____i = 1, row.size do
            local p = row[____i]
            local c = ____i - 1
            if __K2L_Equals(p, product) then
                return Slot.new(r, c)
            end
        end
    end
    return nil
end

function Grid:render()
    return self.cells:getIndices():joinToString("\n", nil, nil, nil, nil, function(r)
        return (self.cells[r + 1] or __K2L_IndexError(r, self.cells.size, "array")):getIndices():joinToString(" | ", nil, nil, nil, nil, function(c)
            local ____receiver_1 = (self.cells[r + 1] or __K2L_IndexError(r, self.cells.size, "array")):get(c)
            return ____receiver_1 and __K2L_StringPadEnd(____receiver_1.sku .. " x" .. (self.counts[r + 1] or __K2L_IndexError(r, self.counts.size, "array")):get(c), 10) or __K2L_StringPadEnd("-", 10)
        end)
    end)
end

function Grid:getTotalUnits()
    local ____list_1 = self.counts
    local ____sum = 0
    local ____items, ____n = ____list_1:____array()
    for ____i_2 = 1, ____n do
        local it = ____items[____i_2]
        ____sum = ____sum + it:sum()
    end
    return ____sum
end

local Order = __K2L_Class("warehouse.Order")
local ____next

function Order:____init(id, ...)
    local lines = __K2L_ArrayOf(...)
    self.id = id
    self.lines = lines:toList()
end

function Order:invoke(...)
    local lines = __K2L_ArrayOf(...)
    local ____old = ____next
    ____next = ____next + 1
    return Order.new(____old, __K2L_Unpack(lines))
end

function Order:____initCompanion()
    ____next = 1
end

Order:____initCompanion()

local function route(start, stops)
    local remaining = stops:toMutableList()
    local path = __K2L_ListOf()
    local at = start
    while remaining:isNotEmpty() do
        local nearest = remaining:minWith(function(____a, ____b)
            local ____x_3, ____y_3 = ____a:minus(at), ____b:minus(at)
            if ____x_3 ~= ____y_3 then
                return ____x_3 < ____y_3 and -1 or 1
            end
            local ____x_4, ____y_4 = ____a.row, ____b.row
            if ____x_4 ~= ____y_4 then
                return ____x_4 < ____y_4 and -1 or 1
            end
            local ____x_5, ____y_5 = ____a.col, ____b.col
            if ____x_5 ~= ____y_5 then
                return ____x_5 < ____y_5 and -1 or 1
            end
            return 0
        end)
        remaining:remove(nearest)
        path:add(nearest)
        at = nearest
    end
    return path
end

local ____lambda_1 = function() return Tool.new1("bad", 1) end
local ____lambda_2 = function(it) return it.row .. it.col end
local ____lambda_3 = function(it) return it.fragile end
local ____lambda_4 = function(____a_1, ____b_1)
    local ____x_7, ____y_7 = ____b_1:price(1), ____a_1:price(1)
    if ____x_7 ~= ____y_7 then
        return ____x_7 < ____y_7 and -1 or 1
    end
    return __K2L_CompareValues(____a_1.name, ____b_1.name)
end
local function main()
    local hammer = Tool.new("TL-001", "hammer", 1200)
    local wrench = Tool.new1("TL-002", 900)
    local drill = PowerTool.new("PT-100", "drill", 8000, 650)
    local vase = Glassware.new("GL-007", "vase", 2500, 20)
    local glasses = Glassware.new("GL-008", "glasses", 400, 5)
    local products = __K2L_ListOf(hammer, wrench, drill, vase, glasses)
    local ____receiver_2 = __K2L_RunCatching(____lambda_1):exceptionOrNull()
    print(__K2L_Str(____receiver_2 and ____receiver_2.message))
    for ____i_3 = 1, products.size do
        local p = products[____i_3]
        print(__K2L_StringPadEnd(p:getLabel(), 24) .. " 1=" .. p:price(1) .. " 10=" .. p:price(10))
    end
    local grid = Grid.new(3, 4)
    local stock = __K2L_ListOf(__K2L_Pair.new(hammer, 10), __K2L_Pair.new(drill, 2), __K2L_Pair.new(vase, 4), __K2L_Pair.new(glasses, 30), __K2L_Pair.new(wrench, 15), __K2L_Pair.new(hammer, 5))
    local ____out = {}
    local ____count = 0
    local ____items_1, ____n_1 = stock:____array()
    for ____i_4 = 1, ____n_1 do
        local ____it = ____items_1[____i_4]
        local ____result
        do
            local p, q = ____it.first, ____it.second
            ____result = grid:store(p, q)
        end
        ____count = ____count + 1
        ____out[____count] = ____result
    end
    local slots = __K2L_ListWrap(____out, ____count)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_2, ____n_2 = slots:____array()
    for ____i_5 = 1, ____n_2 do
        local it = ____items_2[____i_5]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = it.row .. "," .. it.col
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
    local ____receiver_3 = __K2L_RunCatching(function()
        return grid:store(Glassware.new("GL-009", "bowl", 300, 0), 1)
    end):exceptionOrNull()
    print(__K2L_Str(____receiver_3 and ____receiver_3.message))
    print(grid:render())
    print("units=" .. grid:getTotalUnits())
    local orders = __K2L_ListOf(Order:invoke(__K2L_Pair.new(hammer, 3), __K2L_Pair.new(vase, 1)), Order:invoke(__K2L_Pair.new(glasses, 12), __K2L_Pair.new(drill, 1), __K2L_Pair.new(wrench, 2)), Order:invoke(__K2L_Pair.new(vase, 10)))
    for ____i_8 = 1, orders.size do
        local order = orders[____i_8]
        local ____list_2 = order.lines
        local ____out_2 = {}
        local ____count_2 = 0
        local ____items_3, ____n_3 = ____list_2:____array()
        for ____i_6 = 1, ____n_3 do
            local ____it_1 = ____items_3[____i_6]
            local ____result_1
            do
                local p = ____it_1.first
                ____result_1 = grid:find(p)
            end
            local ____value = ____result_1
            if ____value ~= nil then
                ____count_2 = ____count_2 + 1
                ____out_2[____count_2] = ____value
            end
        end
        local stops = __K2L_ListWrap(____out_2, ____count_2)
        local path = route(Slot.new(2, 0), stops)
        local total = 0
        local ____list_3 = order.lines
        local ____out_3 = {}
        local ____count_3 = 0
        local ____items_4, ____n_4 = ____list_3:____array()
        for ____i_7 = 1, ____n_4 do
            local ____it_2 = ____items_4[____i_7]
            local ____result_2
            do
                local p, q = ____it_2.first, ____it_2.second
                local ____value_1 = grid:find(p)
                if ____value_1 == nil then
                    ____result_2 = p.sku .. ": none"
                    goto ____inline_end
                end
                local slot = ____value_1
                local got = grid:take(slot, q)
                total = total + p:price(got)
                ____result_2 = p.sku .. ": " .. got .. "/" .. q
                ::____inline_end::
            end
            ____count_3 = ____count_3 + 1
            ____out_3[____count_3] = ____result_2
        end
        local picked = __K2L_ListWrap(____out_3, ____count_3)
        print("order " .. order.id .. " route=" .. path:joinToString(">", nil, nil, nil, nil, ____lambda_2) .. " " .. __K2L_Str(picked) .. " total=" .. total)
    end
    print(grid:render())
    print(__K2L_Str(grid:get(Slot.new(0, 0))))
    print(__K2L_Str(grid:get(Slot.new(2, 2))))
    local ____result_3 = __K2L_Map.new()
    local ____items_5, ____n_5 = products:____array()
    for ____i_9 = 1, ____n_5 do
        local it = ____items_5[____i_9]
        local ____value_2 = it.sku
        ____result_3:put(____value_2, it)
    end
    local bySku = ____result_3
    print(bySku:get("GL-007") == vase)
    print(products:toSet().size == __K2L_SetOf(Tool.new1("TL-001", 1), hammer).size + 3)
    local ____destructured = products:partition(____lambda_3)
    local fragile, sturdy = ____destructured.first, ____destructured.second
    print("fragile=" .. __K2L_Str(fragile) .. " sturdy=" .. __K2L_Str(sturdy))
    local ____list_4 = products:sortedWith(____lambda_4)
    local ____out_4 = {}
    local ____count_4 = 0
    local ____items_6, ____n_6 = ____list_4:____array()
    for ____i_10 = 1, ____n_6 do
        local it = ____items_6[____i_10]
        ____count_4 = ____count_4 + 1
        ____out_4[____count_4] = it.name
    end
    print(__K2L_Str(__K2L_ListWrap(____out_4, ____count_4)))
    local ____list_5 = products:windowed(2)
    local ____out_5 = {}
    local ____count_5 = 0
    local ____items_7, ____n_7 = ____list_5:____array()
    for ____i_11 = 1, ____n_7 do
        local ____it_3 = ____items_7[____i_11]
        local ____result_4
        do
            local a, b = ____it_3[1], ____it_3[2]
            ____result_4 = a:price(1) - b:price(1)
        end
        ____count_5 = ____count_5 + 1
        ____out_5[____count_5] = ____result_4
    end
    print(__K2L_Str(__K2L_ListWrap(____out_5, ____count_5)))
end

__K2L_RunMain(main)
return {Priced = Priced, Discounted = Discounted, Taxed = Taxed, Product = Product, Tool = Tool, Glassware = Glassware, PowerTool = PowerTool, Slot = Slot, Grid = Grid, Order = Order, route = route}
