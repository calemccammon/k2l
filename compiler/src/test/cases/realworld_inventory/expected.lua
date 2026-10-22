local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_CompareValues = ____lualib.__K2L_CompareValues
local __K2L_EnumValueOf = ____lualib.__K2L_EnumValueOf
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_SimpleName = ____lualib.__K2L_SimpleName
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringPadEnd = ____lualib.__K2L_StringPadEnd
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Unit = ____lualib.__K2L_Unit

local Order
local Money = __K2L_Class("Money")
Money.____comparable = true

function Money:____init(cents)
    self.cents = cents
end

function Money.new(cents)
    return setmetatable({cents = cents}, Money)
end

function Money:plus(o)
    return Money.new(self.cents + o.cents)
end

function Money:minus(o)
    return Money.new(self.cents - o.cents)
end

function Money:times(n)
    return Money.new(self.cents * n)
end

function Money:div(n)
    return Money.new(self.cents // n)
end

function Money:compareTo(other)
    return __K2L_Compare(self.cents, other.cents)
end

function Money:toString()
    local sign = self.cents < 0 and "-" or ""
    local abs = math.abs(self.cents)
    return sign .. "$" .. abs // 100 .. "." .. __K2L_StringPadStart(tostring(abs % 100), 2, "0")
end

function Money:hashCode()
    return __K2L_Hash(self.cents)
end

function Money:equals(other)
    return getmetatable(other) == Money and self.cents == other.cents
end

Money.____companion = true

local ____lambda_1 = function(it) return "0" end
function Money:parse(s)
    local ____value = __K2L_StringSplit(__K2L_Text.removePrefix(s, "$"), ".")
    local ____result
    ____result = __K2L_Pair.new(____value:get(0), ____value:getOrElse(1, ____lambda_1))
    local ____destructured = ____result
    local whole, frac = ____destructured.first, ____destructured.second
    return Money.new(__K2L_StringToInt(whole, nil, true) * 100 + __K2L_StringToInt(__K2L_Text.take(__K2L_StringPadEnd(frac, 2, "0"), 2), nil, true))
end

function Money:____initCompanion()
    self.ZERO = Money.new(0)
end

Money:____initCompanion()

local function getDollars(self)
    return Money.new(self * 100)
end

local ____lambda_2 = function(self, ...) return self:plus(...) end
local function sum(____this)
    return ____this:fold(Money.ZERO, ____lambda_2)
end

local Category = __K2L_Class("Category")

function Category:____init(name, ordinal, code, perishable)
    if perishable == nil then
        perishable = false
    end
    self.name = name
    self.ordinal = ordinal
    self.code = code
    self.perishable = perishable
end

function Category:toString()
    return self.name .. "[" .. self.code .. "]"
end

function Category:compareTo(other)
    return self.ordinal - other.ordinal
end

Category.PRODUCE = Category.new("PRODUCE", 0, "PRD", true)
Category.DAIRY = Category.new("DAIRY", 1, "DRY", true)
Category.HARDWARE = Category.new("HARDWARE", 2, "HWR")
Category.BOOKS = Category.new("BOOKS", 3, "BKS")
Category.____values = {Category.PRODUCE, Category.DAIRY, Category.HARDWARE, Category.BOOKS}
local Product = __K2L_Class("Product")

function Product:____init(sku, name, category, price)
    self.sku = sku
    self.name = name
    self.category = category
    self.price = price
end

function Product.new(sku, name, category, price)
    return setmetatable({sku = sku, name = name, category = category, price = price}, Product)
end

function Product:toString()
    return "Product(sku=" .. self.sku .. ", name=" .. self.name .. ", category=" .. __K2L_Str(self.category) .. ", price=" .. __K2L_Str(self.price) .. ")"
end

function Product:hashCode()
    return (31 * (31 * (31 * __K2L_Hash(self.sku) + __K2L_Hash(self.name)) + __K2L_Hash(self.category)) + self.price:hashCode() + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Product:equals(other)
    return getmetatable(other) == Product and self.sku == other.sku and self.name == other.name and self.category == other.category and self.price:equals(other.price)
end

local OutOfStockException = __K2L_Class("OutOfStockException", __K2L_RuntimeException)

function OutOfStockException:____init(sku, requested, available)
    __K2L_RuntimeException.____init(self, "Cannot take " .. requested .. " of " .. sku .. ": only " .. available .. " left")
    self.sku = sku
    self.requested = requested
    self.available = available
end

local Event = __K2L_Class("Event")
Event.Received = __K2L_Class("Event$Received", nil, Event)

function Event.Received:____init(sku, qty)
    self.sku = sku
    self.qty = qty
end

function Event.Received.new(sku, qty)
    return setmetatable({sku = sku, qty = qty}, Event.Received)
end

function Event.Received:toString()
    return "Received(sku=" .. self.sku .. ", qty=" .. self.qty .. ")"
end

function Event.Received:hashCode()
    return (31 * __K2L_Hash(self.sku) + self.qty + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Event.Received:equals(other)
    return getmetatable(other) == Event.Received and self.sku == other.sku and self.qty == other.qty
end

Event.Shipped = __K2L_Class("Event$Shipped", nil, Event)

function Event.Shipped:____init(sku, qty, order)
    self.sku = sku
    self.qty = qty
    self.order = order
end

function Event.Shipped.new(sku, qty, order)
    return setmetatable({sku = sku, qty = qty, order = order}, Event.Shipped)
end

function Event.Shipped:toString()
    return "Shipped(sku=" .. self.sku .. ", qty=" .. self.qty .. ", order=" .. self.order .. ")"
end

function Event.Shipped:hashCode()
    return (31 * (31 * __K2L_Hash(self.sku) + self.qty) + __K2L_Hash(self.order) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Event.Shipped:equals(other)
    return getmetatable(other) == Event.Shipped and self.sku == other.sku and self.qty == other.qty and self.order == other.order
end

Event.Adjusted = __K2L_Class("Event$Adjusted", nil, Event)

function Event.Adjusted:____init(sku, delta, reason)
    self.sku = sku
    self.delta = delta
    self.reason = reason
end

function Event.Adjusted.new(sku, delta, reason)
    return setmetatable({sku = sku, delta = delta, reason = reason}, Event.Adjusted)
end

function Event.Adjusted:toString()
    return "Adjusted(sku=" .. self.sku .. ", delta=" .. self.delta .. ", reason=" .. self.reason .. ")"
end

function Event.Adjusted:hashCode()
    return (31 * (31 * __K2L_Hash(self.sku) + self.delta) + __K2L_Hash(self.reason) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Event.Adjusted:equals(other)
    return getmetatable(other) == Event.Adjusted and self.sku == other.sku and self.delta == other.delta and self.reason == other.reason
end

Event.PriceChanged = __K2L_Class("Event$PriceChanged", nil, Event)

function Event.PriceChanged:____init(sku, newPrice)
    self.sku = sku
    self.newPrice = newPrice
end

function Event.PriceChanged.new(sku, newPrice)
    return setmetatable({sku = sku, newPrice = newPrice}, Event.PriceChanged)
end

function Event.PriceChanged:toString()
    return "PriceChanged(sku=" .. self.sku .. ", newPrice=" .. __K2L_Str(self.newPrice) .. ")"
end

function Event.PriceChanged:hashCode()
    return (31 * __K2L_Hash(self.sku) + self.newPrice:hashCode() + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Event.PriceChanged:equals(other)
    return getmetatable(other) == Event.PriceChanged and self.sku == other.sku and self.newPrice:equals(other.newPrice)
end

local Inventory = __K2L_Class("Inventory")

function Inventory:____init()
    self.products = __K2L_MapOf()
    self.stock = __K2L_MapOf()
    self.log = __K2L_ListOf()
end

function Inventory:getEvents()
    return self.log
end

function Inventory:register(product)
    if self.products:containsKey(product.sku) then
        error(__K2L_IllegalArgumentException.new("duplicate sku " .. product.sku))
    end
    if not (__K2L_Compare(product.price, Money.ZERO) > 0) then
        error(__K2L_IllegalArgumentException.new("price must be positive"))
    end
    local ____object = self.products
    local ____key = product.sku
    ____object:set(____key, product)
end

function Inventory:product(sku)
    local ____value_1 = self.products:get(sku)
    if ____value_1 == nil then
        error(__K2L_NoSuchElementException.new("unknown sku " .. sku))
    end
    return ____value_1
end

function Inventory:quantity(sku)
    return self.stock:get(sku) or 0
end

local ____lambda_3 = function(____p1, ____p2) return ____p1 + ____p2 end
function Inventory:apply(event)
    self:product(event.sku)
    local ____mt = getmetatable(event)
    if ____mt == Event.Received then
        if not (event.qty > 0) then
            error(__K2L_IllegalArgumentException.new("received quantity must be positive"))
        end
        self.stock:merge(event.sku, event.qty, ____lambda_3)
    elseif ____mt == Event.Shipped then
        local have = self:quantity(event.sku)
        if have < event.qty then
            error(OutOfStockException.new(event.sku, event.qty, have))
        end
        local ____object_3 = self.stock
        local ____key_3 = event.sku
        ____object_3:set(____key_3, have - event.qty)
    elseif ____mt == Event.Adjusted then
        local ____object_2 = self.stock
        local ____key_2 = event.sku
        ____object_2:set(____key_2, math.max(self:quantity(event.sku) + event.delta, 0))
    elseif ____mt == Event.PriceChanged then
        local ____object_1 = self.products
        local ____key_1 = event.sku
        local ____source = self:product(event.sku)
        ____object_1:set(____key_1, Product.new(____source.sku, ____source.name, ____source.category, event.newPrice))
    end
    self.log:add(event)
    local ____list = self.stock:getValues()
    local ____result_1 = true
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        if not (it >= 0) then
            ____result_1 = false
            break
        end
    end
    if not ____result_1 then
        error(__K2L_IllegalStateException.new("negative stock"))
    end
end

function Inventory:value()
    local ____list_1 = self.products:getValues()
    local ____out = {}
    local ____count = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        ____count = ____count + 1
        ____out[____count] = it.price:times(self:quantity(it.sku))
    end
    return sum(__K2L_ListWrap(____out, ____count))
end

function Inventory:report()
    local ____builder = __K2L_StringBuilder.new()
    do
        ____builder:appendLine(string.format("%-6s %-14s %-12s %5s %10s", "SKU", "Name", "Category", "Qty", "Value"))
        local ____list_2 = self.products:getValues():sortedWith(function(____a, ____b)
            local ____c_1 = __K2L_CompareValues(____a.category, ____b.category)
            if ____c_1 ~= 0 then
                return ____c_1
            end
            local ____x_1, ____y_1 = self:quantity(____b.sku), self:quantity(____a.sku)
            if ____x_1 ~= ____y_1 then
                return ____x_1 < ____y_1 and -1 or 1
            end
            return __K2L_CompareValues(____a.sku, ____b.sku)
        end)
        for ____i_2 = 1, ____list_2.size do
            local p = ____list_2[____i_2]
            do
                local qty = self:quantity(p.sku)
                ____builder:appendLine(string.format("%-6s %-14s %-12s %5d %10s", p.sku, p.name, __K2L_Str(p.category), qty, __K2L_Str(p.price:times(qty))))
            end
        end
        ____builder:append("Total value: " .. __K2L_Str(self:value()))
    end
    return ____builder:toString()
end

local OrderLine = __K2L_Class("OrderLine")

function OrderLine:____init(sku, qty)
    self.sku = sku
    self.qty = qty
end

function OrderLine.new(sku, qty)
    return setmetatable({sku = sku, qty = qty}, OrderLine)
end

local OrderBuilder = __K2L_Class("OrderBuilder")

function OrderBuilder:____init(id)
    self.id = id
    self.lines = __K2L_ListOf()
    self.customer = "anonymous"
    self.express = false
end

function OrderBuilder:of(____this_1, sku)
    self.lines:add(OrderLine.new(sku, ____this_1))
end

function OrderBuilder:build()
    if not self.lines:isNotEmpty() then
        error(__K2L_IllegalStateException.new("order " .. self.id .. " has no lines"))
    end
    local ____arg = self.id
    local ____arg_1 = self.customer
    local ____arg_2 = self.express
    local ____list_3 = self.lines
    local ____result_2 = __K2L_Map.new()
    local ____items_2, ____n_2 = ____list_3:____array()
    for ____i_3 = 1, ____n_2 do
        local it = ____items_2[____i_3]
        local ____value_2 = it.sku
        local ____group = ____result_2:get(____value_2)
        if ____group == nil then
            ____group = __K2L_List.new()
            ____result_2:put(____value_2, ____group)
        end
        ____group:add(it)
    end
    return Order.new(____arg, ____arg_1, ____arg_2, ____result_2:map(function(____destructured_1)
        local sku, ls = ____destructured_1.key, ____destructured_1.value
        local ____sum = 0
        local ____items_3, ____n_3 = ls:____array()
        for ____i_4 = 1, ____n_3 do
            local it = ____items_3[____i_4]
            ____sum = ____sum + it.qty
        end
        return OrderLine.new(sku, ____sum)
    end))
end

Order = __K2L_Class("Order")

function Order:____init(id, customer, express, lines)
    self.id = id
    self.customer = customer
    self.express = express
    self.lines = lines
end

function Order.new(id, customer, express, lines)
    return setmetatable({id = id, customer = customer, express = express, lines = lines}, Order)
end

function Order:toString()
    return "Order(id=" .. self.id .. ", customer=" .. self.customer .. ", express=" .. tostring(self.express) .. ", lines=" .. __K2L_Str(self.lines) .. ")"
end

function Order:hashCode()
    return (31 * (31 * (31 * __K2L_Hash(self.id) + __K2L_Hash(self.customer)) + (self.express and 1231 or 1237)) + __K2L_Hash(self.lines) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Order:equals(other)
    return getmetatable(other) == Order and self.id == other.id and self.customer == other.customer and self.express == other.express and __K2L_Equals(self.lines, other.lines)
end

local function order(id, block)
    local ____value_3 = OrderBuilder.new(id)
    block(____value_3)
    return ____value_3:build()
end

local function fulfil(____this_2, ____order)
    return __K2L_RunCatching(function(____this_3)
        local ____list_4 = ____order.lines
        for ____i_5 = 1, ____list_4.size do
            local line = ____list_4[____i_5]
            do
                local have = ____this_3:quantity(line.sku)
                if have < line.qty then
                    error(OutOfStockException.new(line.sku, line.qty, have))
                end
            end
        end
        local ____list_5 = ____order.lines
        local ____out_1 = {}
        local ____count_1 = 0
        local ____items_4, ____n_4 = ____list_5:____array()
        for ____i_6 = 1, ____n_4 do
            local line = ____items_4[____i_6]
            local ____result_3
            ____this_3:apply(Event.Shipped.new(line.sku, line.qty, ____order.id))
            ____result_3 = ____this_3:product(line.sku).price:times(line.qty)
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = ____result_3
        end
        local ____value_4 = sum(__K2L_ListWrap(____out_1, ____count_1))
        local ____result_4
        ____result_4 = ____order.express and ____value_4:plus(getDollars(15)) or ____value_4
        return ____result_4
    end, ____this_2)
end

local ____lambda_4 = function(l) return l.qty .. "x" .. l.sku end
local ____lambda_5 = function()
    return order("ORD-4", function(____this_7)
        ____this_7.customer = "nobody"
    end)
end
local ____lambda_6 = function(x) return getmetatable(x) == Event.Shipped end
local ____lambda_7 = function(it) return __K2L_SimpleName(it) or "?" end
local ____lambda_8 = function(it) return getDollars(it) end
local function main()
    local inv = Inventory.new()
    local ____list_6 = __K2L_ListOf(Product.new("A100", "Apples (kg)", Category.PRODUCE, Money:parse("3.49")), Product.new("M200", "Milk 1L", Category.DAIRY, Money:parse("$1.2")), Product.new("H300", "Hammer", Category.HARDWARE, getDollars(18)), Product.new("H301", "Nails x100", Category.HARDWARE, Money:parse("4.05")), Product.new("B400", "Kotlin Book", Category.BOOKS, Money:parse("39.99")))
    for ____i_7 = 1, ____list_6.size do
        local it = ____list_6[____i_7];
        (function(...) return inv:register(...) end)(it)
    end
    local ____list_7 = __K2L_ListOf(Product.new("A100", "Dup", Category.BOOKS, getDollars(1)), Product.new("Z1", "Free", Category.BOOKS, Money.ZERO))
    for ____i_8 = 1, ____list_7.size do
        local attempt = ____list_7[____i_8]
        local ____ok, ____result_5 = pcall(function()
            inv:register(attempt)
        end)
        if not ____ok then
            local ____error = __K2L_ToThrowable(____result_5)
            if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
                local e = ____error
                print("rejected " .. attempt.sku .. ": " .. __K2L_Str(e.message))
            else
                error(____error, 0)
            end
        end
    end
    local incoming = __K2L_ListOf(Event.Received.new("A100", 50), Event.Received.new("M200", 24), Event.Received.new("H300", 5), Event.Received.new("H301", 40), Event.Received.new("B400", 3), Event.Adjusted.new("A100", -4, "bruised"), Event.PriceChanged.new("M200", Money:parse("1.35")), Event.Received.new("H300", 2))
    for ____i_9 = 1, incoming.size do
        local it = incoming[____i_9];
        (function(...) return inv:apply(...) end)(it)
    end
    print(inv:report())
    local orders = __K2L_ListOf(order("ORD-1", function(____this_4)
        ____this_4.customer = "Ada"
        ____this_4:of(2, "H300")
        ____this_4:of(10, "H301")
        ____this_4:of(5, "H301")
    end), order("ORD-2", function(____this_5)
        ____this_5.customer = "Grace"
        ____this_5.express = true
        ____this_5:of(4, "B400")
    end), order("ORD-3", function(____this_6)
        ____this_6.express = true
        ____this_6:of(12, "M200")
        ____this_6:of(1, "B400")
    end))
    for ____i_10 = 1, orders.size do
        local o = orders[____i_10]
        fulfil(inv, o):onSuccess(function(it)
            print(o.id .. " for " .. o.customer .. ": charged " .. __K2L_Str(it) .. " (" .. o.lines:joinToString(nil, nil, nil, nil, nil, ____lambda_4) .. ")")
        end):onFailure(function(e)
            if getmetatable(e) == OutOfStockException then
                print(o.id .. " failed: " .. __K2L_Str(e.message) .. " [short by " .. e.requested - e.available .. "]")
            else
                error(e)
            end
        end)
    end
    print(__K2L_Str(__K2L_RunCatching(____lambda_5):exceptionOrNull()))
    print(__K2L_Str(__K2L_RunCatching(function()
        inv:apply(Event.Received.new("NOPE", 1))
        return __K2L_Unit
    end):exceptionOrNull()))
    local ____receiver = __K2L_RunCatching(function()
        inv:apply(Event.Received.new("A100", 0))
        return __K2L_Unit
    end):exceptionOrNull()
    print(__K2L_Str(____receiver and ____receiver.message))
    inv:apply(Event.Adjusted.new("H301", -1000, "flood"))
    print()
    print(inv:report())
    local shipped = inv:getEvents():filter(____lambda_6)
    local ____result_6 = __K2L_Map.new()
    local ____items_5, ____n_5 = shipped:____array()
    for ____i_11 = 1, ____n_5 do
        local it = ____items_5[____i_11]
        local ____value_5 = it.order
        local ____group_1 = ____result_6:get(____value_5)
        if ____group_1 == nil then
            ____group_1 = __K2L_List.new()
            ____result_6:put(____value_5, ____group_1)
        end
        ____group_1:add(it.sku .. "x" .. it.qty)
    end
    print("\nshipped by order: " .. __K2L_Str(____result_6))
    local countsByType = inv:getEvents():groupingBy(____lambda_7):eachCount():toSortedMap()
    print("event counts: " .. __K2L_Str(countsByType))
    local ____values = Category.____values
    local ____out_2 = {}
    local ____count_2 = 0
    for ____i_12 = 1, #____values do
        local it = ____values[____i_12]
        if it.perishable then
            ____count_2 = ____count_2 + 1
            ____out_2[____count_2] = it
        end
    end
    local ____list_8 = __K2L_ListWrap(____out_2, ____count_2)
    local ____result_7 = __K2L_Map.new()
    local ____items_9, ____n_9 = ____list_8:____array()
    for ____i_16 = 1, ____n_9 do
        local cat = ____items_9[____i_16]
        local ____result_8
        do
            local ____list_9 = inv:getEvents()
            local ____out_3 = {}
            local ____count_3 = 0
            local ____items_6, ____n_6 = ____list_9:____array()
            for ____i_13 = 1, ____n_6 do
                local it = ____items_6[____i_13]
                ____count_3 = ____count_3 + 1
                ____out_3[____count_3] = it.sku
            end
            local ____list_10 = __K2L_ListWrap(____out_3, ____count_3):distinct():map(function(...) return inv:product(...) end)
            local ____out_4 = {}
            local ____count_4 = 0
            local ____items_7, ____n_7 = ____list_10:____array()
            for ____i_14 = 1, ____n_7 do
                local it = ____items_7[____i_14]
                if it.category == cat then
                    ____count_4 = ____count_4 + 1
                    ____out_4[____count_4] = it
                end
            end
            local ____list_11 = __K2L_ListWrap(____out_4, ____count_4)
            local ____out_5 = {}
            local ____count_5 = 0
            local ____items_8, ____n_8 = ____list_11:____array()
            for ____i_15 = 1, ____n_8 do
                local it = ____items_8[____i_15]
                ____count_5 = ____count_5 + 1
                ____out_5[____count_5] = it.price:times(inv:quantity(it.sku))
            end
            ____result_8 = sum(__K2L_ListWrap(____out_5, ____count_5))
        end
        local ____value_6 = ____result_8
        ____result_7:put(cat, ____value_6)
    end
    local perishableValue = ____result_7
    print("perishable value: " .. __K2L_Str(perishableValue))
    local ____list_12 = inv:getEvents()
    local ____out_6 = {}
    local ____count_6 = 0
    local ____items_10, ____n_10 = ____list_12:____array()
    for ____i_17 = 1, ____n_10 do
        local it = ____items_10[____i_17]
        local ____result_9
        do
            local ____receiver_1 = getmetatable(it) == Event.PriceChanged and it or nil
            ____result_9 = ____receiver_1 and (getmetatable(it) == Event.PriceChanged and it or nil).newPrice
        end
        local ____value_7 = ____result_9
        if ____value_7 ~= nil then
            ____count_6 = ____count_6 + 1
            ____out_6[____count_6] = ____value_7
        end
    end
    local prices = __K2L_ListWrap(____out_6, ____count_6)
    local ____arg_3 = __K2L_Str(prices)
    local ____list_13 = __K2L_ListOf("A100", "H300", "B400")
    local ____out_7 = {}
    local ____count_7 = 0
    local ____items_11, ____n_11 = ____list_13:____array()
    for ____i_18 = 1, ____n_11 do
        local it = ____items_11[____i_18]
        ____count_7 = ____count_7 + 1
        ____out_7[____count_7] = inv:product(it).price
    end
    print("price changes: " .. ____arg_3 .. ", max product price " .. __K2L_Str(__K2L_ListWrap(____out_7, ____count_7):maxOrNull()))
    print("money math: " .. __K2L_Str(getDollars(10):div(3)) .. " " .. __K2L_Str(Money.new(-250)) .. " " .. __K2L_Str(Money:parse("0.5"):times(3)) .. " " .. __K2L_Str(sum(__K2L_IntRange.new(1, 4):map(____lambda_8))))
    local ____destructured_2 = inv:product("B400")
    local sku, name, category = ____destructured_2.sku, ____destructured_2.name, ____destructured_2.category
    print("destructured: " .. sku .. " / " .. name .. " / " .. __K2L_Str(category) .. " / " .. category.ordinal .. " / " .. __K2L_EnumValueOf(Category, "DAIRY").code)
    local ____value_8 = inv:product("A100")
    print("with: " .. name .. " costs " .. __K2L_Str(____value_8.price) .. ", perishable=" .. tostring(category.perishable))
    local ____value_9 = inv:product("H300")
    local ____receiver_2 = inv:quantity(____value_9.sku) > 0 and ____value_9 or nil
    local ____result_10
    if ____receiver_2 ~= nil then
        print("in stock: " .. ____receiver_2.name)
        ____result_10 = __K2L_Unit
    end
    local ____value_10 = ____result_10
    if ____value_10 == nil then
        print("hammers sold out")
        ____value_10 = __K2L_Unit
    end
end

__K2L_RunMain(main)
return {Money = Money, getDollars = getDollars, sum = sum, Category = Category, Product = Product, OutOfStockException = OutOfStockException, Event = Event, Inventory = Inventory, OrderLine = OrderLine, OrderBuilder = OrderBuilder, Order = Order, order = order, fulfil = fulfil}
