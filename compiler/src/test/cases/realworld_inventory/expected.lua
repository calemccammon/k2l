local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_CompanionInfo = ____lualib.__K2L_CompanionInfo
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_EnumValueOf = ____lualib.__K2L_EnumValueOf
local __K2L_EnumValues = ____lualib.__K2L_EnumValues
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_FunctionRef = ____lualib.__K2L_FunctionRef
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_StringPadEnd = ____lualib.__K2L_StringPadEnd
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ThenBy = ____lualib.__K2L_ThenBy
local __K2L_ThenByDescending = ____lualib.__K2L_ThenByDescending
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Unit = ____lualib.__K2L_Unit

local Order
local Money = __K2L_Class("Money")
__K2L_ClassInfo(Money, "Money", "Money", "class")
__K2L_CompanionInfo(Money, "Money.Companion", "Money$Companion", "Companion")

function Money:____init(cents)
    self.cents = cents
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
    return Money.new(__K2L_IDiv(self.cents, n))
end

function Money:compareTo(other)
    return __K2L_Compare(self.cents, other.cents)
end

function Money:toString()
    local sign = self.cents < 0 and "-" or ""
    local abs = math.abs(self.cents)
    return sign .. "$" .. __K2L_IDiv(abs, 100) .. "." .. __K2L_StringPadStart(tostring(math.fmod(abs, 100)), 2, "0")
end

function Money:hashCode()
    return __K2L_Hash(self.cents)
end

function Money:equals(other)
    return getmetatable(other) == Money and self.cents == other.cents
end

function Money:parse(s)
    local ____value = __K2L_StringSplit(__K2L_Text.removePrefix(s, "$"), ".")
    local ____result
    ____result = __K2L_Pair.new(____value:get(0), ____value:getOrElse(1, function(it) return "0" end))
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

local function sum(____this)
    return ____this:fold(Money.ZERO, function(self, ...) return self:plus(...) end)
end

local Category = __K2L_Class("Category")
__K2L_ClassInfo(Category, "Category", "Category", "class")

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
__K2L_ClassInfo(Product, "Product", "Product", "class")

function Product:____init(sku, name, category, price)
    self.sku = sku
    self.name = name
    self.category = category
    self.price = price
end

function Product:toString()
    return "Product(sku=" .. self.sku .. ", name=" .. self.name .. ", category=" .. __K2L_Str(self.category) .. ", price=" .. __K2L_Str(self.price) .. ")"
end

function Product:hashCode()
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.sku) + __K2L_Hash(self.name)) + __K2L_Hash(self.category)) + __K2L_Hash(self.price))
end

function Product:equals(other)
    return getmetatable(other) == Product and self.sku == other.sku and self.name == other.name and self.category == other.category and self.price:equals(other.price)
end

local OutOfStockException = __K2L_Class("OutOfStockException", __K2L_RuntimeException)
__K2L_ClassInfo(OutOfStockException, "OutOfStockException", "OutOfStockException", "class")

function OutOfStockException:____init(sku, requested, available)
    __K2L_RuntimeException.____init(self, "Cannot take " .. requested .. " of " .. sku .. ": only " .. available .. " left")
    self.sku = sku
    self.requested = requested
    self.available = available
end

local Event = __K2L_Class("Event")
__K2L_ClassInfo(Event, "Event", "Event", "interface")
Event.Received = __K2L_Class("Event$Received", nil, Event)
__K2L_ClassInfo(Event.Received, "Event.Received", "Event$Received", "class")

function Event.Received:____init(sku, qty)
    self.sku = sku
    self.qty = qty
end

function Event.Received:toString()
    return "Received(sku=" .. self.sku .. ", qty=" .. self.qty .. ")"
end

function Event.Received:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.sku) + __K2L_Hash(self.qty))
end

function Event.Received:equals(other)
    return getmetatable(other) == Event.Received and self.sku == other.sku and self.qty == other.qty
end

Event.Shipped = __K2L_Class("Event$Shipped", nil, Event)
__K2L_ClassInfo(Event.Shipped, "Event.Shipped", "Event$Shipped", "class")

function Event.Shipped:____init(sku, qty, order)
    self.sku = sku
    self.qty = qty
    self.order = order
end

function Event.Shipped:toString()
    return "Shipped(sku=" .. self.sku .. ", qty=" .. self.qty .. ", order=" .. self.order .. ")"
end

function Event.Shipped:hashCode()
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.sku) + __K2L_Hash(self.qty)) + __K2L_Hash(self.order))
end

function Event.Shipped:equals(other)
    return getmetatable(other) == Event.Shipped and self.sku == other.sku and self.qty == other.qty and self.order == other.order
end

Event.Adjusted = __K2L_Class("Event$Adjusted", nil, Event)
__K2L_ClassInfo(Event.Adjusted, "Event.Adjusted", "Event$Adjusted", "class")

function Event.Adjusted:____init(sku, delta, reason)
    self.sku = sku
    self.delta = delta
    self.reason = reason
end

function Event.Adjusted:toString()
    return "Adjusted(sku=" .. self.sku .. ", delta=" .. self.delta .. ", reason=" .. self.reason .. ")"
end

function Event.Adjusted:hashCode()
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.sku) + __K2L_Hash(self.delta)) + __K2L_Hash(self.reason))
end

function Event.Adjusted:equals(other)
    return getmetatable(other) == Event.Adjusted and self.sku == other.sku and self.delta == other.delta and self.reason == other.reason
end

Event.PriceChanged = __K2L_Class("Event$PriceChanged", nil, Event)
__K2L_ClassInfo(Event.PriceChanged, "Event.PriceChanged", "Event$PriceChanged", "class")

function Event.PriceChanged:____init(sku, newPrice)
    self.sku = sku
    self.newPrice = newPrice
end

function Event.PriceChanged:toString()
    return "PriceChanged(sku=" .. self.sku .. ", newPrice=" .. __K2L_Str(self.newPrice) .. ")"
end

function Event.PriceChanged:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.sku) + __K2L_Hash(self.newPrice))
end

function Event.PriceChanged:equals(other)
    return getmetatable(other) == Event.PriceChanged and self.sku == other.sku and self.newPrice:equals(other.newPrice)
end

local Inventory = __K2L_Class("Inventory")
__K2L_ClassInfo(Inventory, "Inventory", "Inventory", "class")

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

function Inventory:apply(event)
    self:product(event.sku)
    if __K2L_InstanceOf(event, Event.Received) then
        if not (event.qty > 0) then
            error(__K2L_IllegalArgumentException.new("received quantity must be positive"))
        end
        self.stock:merge(event.sku, event.qty, __K2L_FunctionRef.new("plus", "kotlin/Int.plus(kotlin.Int)", function(____p1, ____p2) return ____p1 + ____p2 end))
    elseif __K2L_InstanceOf(event, Event.Shipped) then
        local have = self:quantity(event.sku)
        if have < event.qty then
            error(OutOfStockException.new(event.sku, event.qty, have))
        end
        local ____object_3 = self.stock
        local ____key_3 = event.sku
        ____object_3:set(____key_3, have - event.qty)
    elseif __K2L_InstanceOf(event, Event.Adjusted) then
        local ____object_2 = self.stock
        local ____key_2 = event.sku
        ____object_2:set(____key_2, math.max(self:quantity(event.sku) + event.delta, 0))
    elseif __K2L_InstanceOf(event, Event.PriceChanged) then
        local ____object_1 = self.products
        local ____key_1 = event.sku
        local ____source = self:product(event.sku)
        ____object_1:set(____key_1, Product.new(____source.sku, ____source.name, ____source.category, event.newPrice))
    end
    self.log:add(event)
    if not self.stock:getValues():all(function(it) return it >= 0 end) then
        error(__K2L_IllegalStateException.new("negative stock"))
    end
end

function Inventory:value()
    return sum(self.products:getValues():map(function(it)
        return it.price:times(self:quantity(it.sku))
    end))
end

function Inventory:report()
    local ____builder = __K2L_StringBuilder.new()
    ____builder:appendLine(__K2L_StringFormat("%-6s %-14s %-12s %5s %10s", "SKU", "Name", "Category", "Qty", "Value"))
    for _, p in ipairs(self.products:getValues():sortedWith(__K2L_ThenBy(__K2L_ThenByDescending(__K2L_CompareBy(function(it) return it.category end), function(it) return self:quantity(it.sku) end), function(it) return it.sku end))) do
        do
            local qty = self:quantity(p.sku)
            ____builder:appendLine(__K2L_StringFormat("%-6s %-14s %-12s %5d %10s", p.sku, p.name, p.category, qty, p.price:times(qty)))
        end
    end
    ____builder:append("Total value: " .. __K2L_Str(self:value()))
    return ____builder:toString()
end

local OrderLine = __K2L_Class("OrderLine")
__K2L_ClassInfo(OrderLine, "OrderLine", "OrderLine", "class")

function OrderLine:____init(sku, qty)
    self.sku = sku
    self.qty = qty
end

local OrderBuilder = __K2L_Class("OrderBuilder")
__K2L_ClassInfo(OrderBuilder, "OrderBuilder", "OrderBuilder", "class")

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
    return Order.new(self.id, self.customer, self.express, self.lines:groupBy(function(it) return it.sku end):map(function(____destructured_1)
        local sku, ls = ____destructured_1.key, ____destructured_1.value
        return OrderLine.new(sku, ls:sumOf(function(it) return it.qty end))
    end))
end

Order = __K2L_Class("Order")
__K2L_ClassInfo(Order, "Order", "Order", "class")

function Order:____init(id, customer, express, lines)
    self.id = id
    self.customer = customer
    self.express = express
    self.lines = lines
end

function Order:toString()
    return "Order(id=" .. self.id .. ", customer=" .. self.customer .. ", express=" .. tostring(self.express) .. ", lines=" .. __K2L_Str(self.lines) .. ")"
end

function Order:hashCode()
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.id) + __K2L_Hash(self.customer)) + __K2L_Hash(self.express)) + __K2L_Hash(self.lines))
end

function Order:equals(other)
    return getmetatable(other) == Order and self.id == other.id and self.customer == other.customer and self.express == other.express and __K2L_Equals(self.lines, other.lines)
end

local function order(id, block)
    local ____value_2 = OrderBuilder.new(id)
    block(____value_2)
    return ____value_2:build()
end

local function fulfil(____this_2, order)
    return __K2L_RunCatching(function(____this_3)
        for _, line in ipairs(order.lines) do
            do
                local have = ____this_3:quantity(line.sku)
                if have < line.qty then
                    error(OutOfStockException.new(line.sku, line.qty, have))
                end
            end
        end
        local ____value_3 = sum(order.lines:map(function(line)
            ____this_3:apply(Event.Shipped.new(line.sku, line.qty, order.id))
            return ____this_3:product(line.sku).price:times(line.qty)
        end))
        local ____result_1
        ____result_1 = order.express and ____value_3:plus(getDollars(15)) or ____value_3
        return ____result_1
    end, ____this_2)
end

local function main()
    local inv = Inventory.new()
    for _, it in ipairs(__K2L_ReadOnlyListOf(Product.new("A100", "Apples (kg)", Category.PRODUCE, Money:parse("3.49")), Product.new("M200", "Milk 1L", Category.DAIRY, Money:parse("$1.2")), Product.new("H300", "Hammer", Category.HARDWARE, getDollars(18)), Product.new("H301", "Nails x100", Category.HARDWARE, Money:parse("4.05")), Product.new("B400", "Kotlin Book", Category.BOOKS, Money:parse("39.99")))) do
        (function(...) return inv:register(...) end)(it)
    end
    for _, attempt in ipairs(__K2L_ReadOnlyListOf(Product.new("A100", "Dup", Category.BOOKS, getDollars(1)), Product.new("Z1", "Free", Category.BOOKS, Money.ZERO))) do
        local ____ok, ____result_2 = pcall(function()
            inv:register(attempt)
        end)
        if not ____ok then
            local ____error = __K2L_ToThrowable(____result_2)
            if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
                local e = ____error
                print("rejected " .. attempt.sku .. ": " .. __K2L_Str(e.message))
            else
                error(____error, 0)
            end
        end
    end
    local incoming = __K2L_ReadOnlyListOf(Event.Received.new("A100", 50), Event.Received.new("M200", 24), Event.Received.new("H300", 5), Event.Received.new("H301", 40), Event.Received.new("B400", 3), Event.Adjusted.new("A100", -4, "bruised"), Event.PriceChanged.new("M200", Money:parse("1.35")), Event.Received.new("H300", 2))
    for _, it in ipairs(incoming) do
        (function(...) return inv:apply(...) end)(it)
    end
    print(inv:report())
    local orders = __K2L_ReadOnlyListOf(order("ORD-1", function(____this_4)
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
    for _, o in ipairs(orders) do
        fulfil(inv, o):onSuccess(function(it)
            print(o.id .. " for " .. o.customer .. ": charged " .. __K2L_Str(it) .. " (" .. o.lines:joinToString(nil, nil, nil, nil, nil, function(l) return l.qty .. "x" .. l.sku end) .. ")")
        end):onFailure(function(e)
            if __K2L_InstanceOf(e, OutOfStockException) then
                print(o.id .. " failed: " .. __K2L_Str(e.message) .. " [short by " .. e.requested - e.available .. "]")
            else
                error(e)
            end
        end)
    end
    print(__K2L_Str(__K2L_RunCatching(function()
        return order("ORD-4", function(____this_7)
            ____this_7.customer = "nobody"
        end)
    end):exceptionOrNull()))
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
    local shipped = inv:getEvents():filter(function(x) return __K2L_InstanceOf(x, Event.Shipped) end)
    print("\nshipped by order: " .. __K2L_Str(shipped:groupBy(function(it) return it.order end, function(it) return it.sku .. "x" .. it.qty end)))
    local countsByType = inv:getEvents():groupingBy(function(it)
        return __K2L_KClassOfValue(it).simpleName or "?"
    end):eachCount():toSortedMap()
    print("event counts: " .. __K2L_Str(countsByType))
    local perishableValue = __K2L_EnumValues(Category):filter(function(it) return it.perishable end):associateWith(function(cat)
        return sum(inv:getEvents():map(function(it) return it.sku end):distinct():map(function(...) return inv:product(...) end):filter(function(it) return it.category == cat end):map(function(it) return it.price:times(inv:quantity(it.sku)) end))
    end)
    print("perishable value: " .. __K2L_Str(perishableValue))
    local prices = inv:getEvents():mapNotNull(function(it)
        local ____receiver_1 = __K2L_InstanceOf(it, Event.PriceChanged) and it or nil
        return ____receiver_1 and (__K2L_InstanceOf(it, Event.PriceChanged) and it or nil).newPrice
    end)
    print("price changes: " .. __K2L_Str(prices) .. ", max product price " .. __K2L_Str(__K2L_ReadOnlyListOf("A100", "H300", "B400"):map(function(it) return inv:product(it).price end):maxOrNull()))
    print("money math: " .. __K2L_Str(getDollars(10):div(3)) .. " " .. __K2L_Str(Money.new(-250)) .. " " .. __K2L_Str(Money:parse("0.5"):times(3)) .. " " .. __K2L_Str(sum(__K2L_IntRange.new(1, 4):map(function(it) return getDollars(it) end))))
    local ____destructured_2 = inv:product("B400")
    local sku, name, category = ____destructured_2.sku, ____destructured_2.name, ____destructured_2.category
    print("destructured: " .. sku .. " / " .. name .. " / " .. __K2L_Str(category) .. " / " .. category.ordinal .. " / " .. __K2L_EnumValueOf(Category, "DAIRY").code)
    local ____value_4 = inv:product("A100")
    print("with: " .. name .. " costs " .. __K2L_Str(____value_4.price) .. ", perishable=" .. tostring(category.perishable))
    local ____value_5 = inv:product("H300")
    local ____receiver_2 = inv:quantity(____value_5.sku) > 0 and ____value_5 or nil
    local ____result_3
    if ____receiver_2 ~= nil then
        print("in stock: " .. ____receiver_2.name)
        ____result_3 = __K2L_Unit
    end
    local ____value_6 = ____result_3
    if ____value_6 == nil then
        print("hammers sold out")
        ____value_6 = __K2L_Unit
    end
end

main()
return {Money = Money, getDollars = getDollars, sum = sum, Category = Category, Product = Product, OutOfStockException = OutOfStockException, Event = Event, Inventory = Inventory, OrderLine = OrderLine, OrderBuilder = OrderBuilder, Order = Order, order = order, fulfil = fulfil}
