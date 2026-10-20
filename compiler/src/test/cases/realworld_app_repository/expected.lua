-- ==== domain/Entities.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_CompanionInfo = ____lualib.__K2L_CompanionInfo
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_Text = ____lualib.__K2L_Text

local Entity = __K2L_Class("shop.domain.Entity")
__K2L_ClassInfo(Entity, "shop.domain.Entity", "shop.domain.Entity", "interface")
local Named = __K2L_Class("shop.domain.Named")
__K2L_ClassInfo(Named, "shop.domain.Named", "shop.domain.Named", "interface")

local ____lambda_1 = function(it) return it:upper() end
function Named:label()
    return __K2L_Text.replaceFirstChar(self.name, ____lambda_1)
end

local Versioned = __K2L_Class("shop.domain.Versioned")
__K2L_ClassInfo(Versioned, "shop.domain.Versioned", "shop.domain.Versioned", "interface")
local Sku = __K2L_Class("shop.domain.Sku")
__K2L_ClassInfo(Sku, "shop.domain.Sku", "shop.domain.Sku", "class")
Sku.____comparable = true

function Sku:____init(code)
    self.code = code
    if #self.code ~= 6 then
        error(__K2L_IllegalArgumentException.new("SKU must have 6 characters: " .. self.code))
    end
end

function Sku:compareTo(other)
    return __K2L_Text.compare(self.code, other.code)
end

function Sku:toString()
    return "SKU:" .. self.code
end

function Sku:hashCode()
    return __K2L_Hash(self.code)
end

function Sku:equals(other)
    return getmetatable(other) == Sku and self.code == other.code
end

local CustomerId = __K2L_Class("shop.domain.CustomerId")
__K2L_ClassInfo(CustomerId, "shop.domain.CustomerId", "shop.domain.CustomerId", "class")
CustomerId.____comparable = true

function CustomerId:____init(region, number)
    self.region = region
    self.number = number
end

function CustomerId.new(region, number)
    return setmetatable({region = region, number = number}, CustomerId)
end

local ____lambda_2 = function(receiver) return receiver.region end
local ____lambda_3 = function(receiver) return receiver.number end
function CustomerId:compareTo(other)
    return __K2L_CompareBy(__K2L_PropertyRef.new("region", "region@599", ____lambda_2), __K2L_PropertyRef.new("number", "number@619", ____lambda_3))(self, other)
end

function CustomerId:toString()
    return self.region .. "-" .. self.number
end

function CustomerId:hashCode()
    return (31 * __K2L_Hash(self.region) + self.number + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function CustomerId:equals(other)
    return getmetatable(other) == CustomerId and self.region == other.region and self.number == other.number
end

local Product = __K2L_Class("shop.domain.Product", nil, Entity, Named, Versioned)
__K2L_ClassInfo(Product, "shop.domain.Product", "shop.domain.Product", "class")

function Product:____init(id, name, priceCents, version)
    if version == nil then
        version = 1
    end
    self.id = id
    self.name = name
    self.priceCents = priceCents
    self.version = version
end

function Product:toString()
    return "Product(id=" .. __K2L_Str(self.id) .. ", name=" .. self.name .. ", priceCents=" .. self.priceCents .. ", version=" .. self.version .. ")"
end

function Product:hashCode()
    return (31 * (31 * (31 * __K2L_Hash(self.id) + __K2L_Hash(self.name)) + __K2L_Hash(self.priceCents)) + self.version + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Product:equals(other)
    return getmetatable(other) == Product and self.id:equals(other.id) and self.name == other.name and self.priceCents == other.priceCents and self.version == other.version
end

local Customer = __K2L_Class("shop.domain.Customer", nil, Entity, Named)
__K2L_ClassInfo(Customer, "shop.domain.Customer", "shop.domain.Customer", "class")

function Customer:____init(id, name, vip)
    if vip == nil then
        vip = false
    end
    self.id = id
    self.name = name
    self.vip = vip
end

function Customer:label()
    return self.vip and "*" .. Named.label(self) .. "*" or Named.label(self)
end

function Customer:toString()
    return "Customer(id=" .. __K2L_Str(self.id) .. ", name=" .. self.name .. ", vip=" .. tostring(self.vip) .. ")"
end

function Customer:hashCode()
    return (31 * (31 * __K2L_Hash(self.id) + __K2L_Hash(self.name)) + (self.vip and 1231 or 1237) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Customer:equals(other)
    return getmetatable(other) == Customer and self.id:equals(other.id) and self.name == other.name and self.vip == other.vip
end

local Order = __K2L_Class("shop.domain.Order", nil, Entity)
__K2L_ClassInfo(Order, "shop.domain.Order", "shop.domain.Order", "class")

function Order:____init(id, customer, lines)
    self.id = id
    self.customer = customer
    self.lines = lines
end

function Order.new(id, customer, lines)
    return setmetatable({id = id, customer = customer, lines = lines}, Order)
end

function Order:quantity()
    local ____list = self.lines
    local ____sum = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____sum = ____sum + it.second
    end
    return ____sum
end

function Order:toString()
    return "Order(id=" .. self.id .. ", customer=" .. __K2L_Str(self.customer) .. ", lines=" .. __K2L_Str(self.lines) .. ")"
end

function Order:hashCode()
    return (31 * (31 * self.id + __K2L_Hash(self.customer)) + __K2L_Hash(self.lines) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Order:equals(other)
    return getmetatable(other) == Order and self.id == other.id and self.customer:equals(other.customer) and __K2L_Equals(self.lines, other.lines)
end

local Money = __K2L_Class("shop.domain.Money")
__K2L_ClassInfo(Money, "shop.domain.Money", "shop.domain.Money", "class")
__K2L_CompanionInfo(Money, "shop.domain.Money.Companion", "shop.domain.Money$Companion", "Companion")
Money.____comparable = true

function Money:____init(cents)
    self.cents = cents
end

function Money.new(cents)
    return setmetatable({cents = cents}, Money)
end

function Money:plus(other)
    return Money.new(self.cents + other.cents)
end

function Money:times(n)
    return Money.new(self.cents * n)
end

function Money:compareTo(other)
    return __K2L_Compare(self.cents, other.cents)
end

function Money:toString()
    local abs = self.cents < 0 and -self.cents or self.cents
    local sign = self.cents < 0 and "-" or ""
    return sign .. "$" .. (abs >= 0 and abs // 100 or (abs + 99) // 100) .. "." .. __K2L_StringPadStart(tostring(abs >= 0 and abs % 100 or (abs % 100 - 100) % (-100)), 2, "0")
end

function Money:hashCode()
    return __K2L_Hash(self.cents)
end

function Money:equals(other)
    return getmetatable(other) == Money and self.cents == other.cents
end

Money.____companion = true

function Money:____initCompanion()
    self.ZERO = Money.new(0)
end

Money:____initCompanion()

local function getPrice(self)
    return Money.new(self.priceCents)
end

return {Entity = Entity, Named = Named, Versioned = Versioned, Sku = Sku, CustomerId = CustomerId, Product = Product, Customer = Customer, Order = Order, Money = Money, getPrice = getPrice}
-- ==== main.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_FunInterface = ____lualib.__K2L_FunInterface
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IsComparable = ____lualib.__K2L_IsComparable
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_LoopItems = ____lualib.__K2L_LoopItems
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringIsBlank = ____lualib.__K2L_StringIsBlank
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local ____Repository = require("storage.Repository")
local ____Entities = require("domain.Entities")
local ____Query = require("query.Query")
local ProductRepository = __K2L_Class("shop.ProductRepository", ____Repository.SortedRepository)
__K2L_ClassInfo(ProductRepository, "shop.ProductRepository", "shop.ProductRepository", "class")

function ProductRepository:____init()
    ____Repository.SortedRepository.____init(self, "product")
end

function ProductRepository:validate(entity)
    if entity.priceCents <= 0 then
        return "price must be positive"
    elseif __K2L_StringIsBlank(entity.name) then
        return "name is blank"
    else
        return nil
    end
end

local AuditLog = __K2L_Class("shop.AuditLog", nil, ____Repository.WriteRepository)
__K2L_ClassInfo(AuditLog, "shop.AuditLog", "shop.AuditLog", "class")

function AuditLog:____init()
    self.seen = __K2L_ListOf()
end

function AuditLog:save(entity)
    self.seen:add(__K2L_Str(__K2L_KClassOfValue(entity).simpleName) .. "(" .. __K2L_Str(entity.id) .. ")")
end

local Pricing = __K2L_Class("shop.Pricing")
__K2L_ClassInfo(Pricing, "shop.Pricing", "shop.Pricing", "class")

function Pricing:____init(products)
    self.products = products
end

function Pricing.new(products)
    return setmetatable({products = products}, Pricing)
end

function Pricing:total(order)
    return order.lines:fold(____Entities.Money.ZERO, function(acc, ____destructured)
        local sku, qty = ____destructured.first, ____destructured.second
        return acc:plus(____Entities.getPrice(____Repository.____require(self.products, sku)):times(qty))
    end)
end

local ____lambda_1 = function(it) return __K2L_Str(it) end
local function printAll(title, items, show)
    if show == nil then
        show = ____lambda_1
    end
    print(title .. " (" .. items.size .. "):")
    local ____items, ____n = __K2L_LoopItems(items)
    local ____mod = items.____modCount
    for ____i = 1, ____n do
        local it = ____items[____i]
        print("  " .. show(it))
        if items.____modCount ~= ____mod and items:____comodified(____i, ____n) then
            break
        end
    end
end

local function countNamed(repo)
    local ____list = repo:all()
    local ____result = 0
    local ____items_1, ____n_1 = ____list:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        if __K2L_InstanceOf(it, ____Entities.Named) then
            ____result = ____result + 1
        end
    end
    return ____result
end

local ____lambda_2 = function(it)
    return __K2L_Str(it.id) .. " " .. it:label() .. " " .. __K2L_Str(____Entities.getPrice(it)) .. " v" .. it.version
end
local ____lambda_3 = function(it) return it.name end
local ____lambda_4 = function(it) return it.id end
local ____lambda_5 = function(it)
    return __K2L_Str(it.id) .. " " .. it:label()
end
local ____lambda_6 = function(it) return it.priceCents < 5000 end
local ____lambda_7 = function(it) return it.name end
local ____lambda_8 = function(it) return it.priceCents end
local ____lambda_9 = function(receiver) return receiver.priceCents end
local ____lambda_10 = function(it) return -it.priceCents end
local ____lambda_11 = function(self, ...) return self:plus(...) end
local ____lambda_12 = function(it) return it.name end
local ____lambda_13 = function(it) return ____Entities.getPrice(it) end
local ____lambda_14 = function(it)
    return it.priceCents >= 0 and it.priceCents // 5000 or (it.priceCents + 4999) // 5000
end
local function main()
    local products = ProductRepository.new()
    local ____list_1 = __K2L_ReadOnlyListOf(____Entities.Product.new(____Entities.Sku.new("KB0001"), "keyboard", 4999), ____Entities.Product.new(____Entities.Sku.new("MS0001"), "mouse", 1999), ____Entities.Product.new(____Entities.Sku.new("MN0002"), "monitor", 18900), ____Entities.Product.new(____Entities.Sku.new("CB0003"), "cable", 499), ____Entities.Product.new(____Entities.Sku.new("HD0001"), "headset", 7450))
    local ____mod_1 = ____list_1.____modCount
    for ____i_2 = 1, ____list_1.size do
        local it = ____list_1[____i_2];
        (function(...) return products:save(...) end)(it)
        if ____list_1.____modCount ~= ____mod_1 and ____list_1:____comodified(____i_2) then
            break
        end
    end
    print(__K2L_Str(products))
    local ____ok, ____result_1 = __K2L_DeepPcall(function()
        products:save(____Entities.Product.new(____Entities.Sku.new("XX0000"), "free", 0))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
            local e = ____error
            print("rejected: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    local ____ok_1, ____result_2 = __K2L_DeepPcall(function()
        products:save(____Entities.Product.new(____Entities.Sku.new("KB0001"), "keyboard", 5499, 1))
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_2)
        if getmetatable(____error_1) == ____Repository.ConflictException then
            local e = ____error_1
            print("conflict on " .. __K2L_Str(e.entityId) .. ": " .. __K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
    products:save(____Entities.Product.new(____Entities.Sku.new("KB0001"), "keyboard", 5499, 2))
    local ____ok_2, ____result_3 = __K2L_DeepPcall(function()
        ____Entities.Sku.new("bad")
    end)
    if not ____ok_2 then
        local ____error_2 = __K2L_ToThrowable(____result_3)
        if __K2L_InstanceOf(____error_2, __K2L_IllegalArgumentException) then
            local e = ____error_2
            print("bad sku: " .. __K2L_Str(e.message))
        else
            error(____error_2, 0)
        end
    end
    printAll("all products", products:all(), ____lambda_2)
    printAll("range HD..MS", products:range(____Entities.Sku.new("HD0000"), ____Entities.Sku.new("MS0000")), ____lambda_3)
    local customers = ____Repository.BoundedRepository.new("customer", 3)
    customers:save(____Entities.Customer.new(____Entities.CustomerId.new("eu", 7), "ines"))
    customers:save(____Entities.Customer.new(____Entities.CustomerId.new("us", 2), "bob", true))
    customers:save(____Entities.Customer.new(____Entities.CustomerId.new("eu", 3), "olga"))
    customers:save(____Entities.Customer.new(____Entities.CustomerId.new("ap", 1), "kenji"))
    print(__K2L_Str(customers:history()))
    printAll("customers", customers:all():sortedBy(____lambda_4, true), ____lambda_5)
    local cheap = __K2L_FunInterface(____Query.Spec, "test", ____lambda_6)
    local m = ____Query.nameStarts("m")
    local ____list_2 = ____Query.query(products):where(____Query.____or(cheap, m)):orderBy(____lambda_7):run()
    local ____out = {}
    local ____count = 0
    local ____items_2, ____n_2 = ____list_2:____array()
    for ____i_3 = 1, ____n_2 do
        local it = ____items_2[____i_3]
        ____count = ____count + 1
        ____out[____count] = it.name
    end
    print("cheap or m*: " .. __K2L_Str(__K2L_ListWrap(____out, ____count)))
    local ____list_3 = ____Query.query(products):where(cheap:____not()):run()
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_3, ____n_3 = ____list_3:____array()
    for ____i_4 = 1, ____n_3 do
        local it = ____items_3[____i_4]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = it.name
    end
    print("not cheap: " .. __K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
    print("cheap and m*, by price desc: " .. __K2L_Str(____Query.query(products):where(____Query.____and(cheap, m)):orderByDescending(__K2L_CompareBy(____lambda_8)):run()))
    local ____receiver = ____Query.query(products):orderByDescending(__K2L_CompareBy(__K2L_PropertyRef.new("priceCents", "priceCents@904", ____lambda_9))):first()
    print("priciest: " .. __K2L_Str(____receiver and ____receiver.name))
    local ____list_4 = ____Query.query(products):orderBy(____lambda_10):limit__1(2):run()
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_4, ____n_4 = ____list_4:____array()
    for ____i_5 = 1, ____n_4 do
        local it = ____items_4[____i_5]
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = it.id
    end
    print("top 2: " .. __K2L_Str(__K2L_ListWrap(____out_2, ____count_2)))
    local pricing = Pricing.new(products)
    local orders = ____Repository.SortedRepository.new("order")
    orders:save(____Entities.Order.new(3, ____Entities.CustomerId.new("eu", 7), __K2L_ReadOnlyListOf(__K2L_Pair.new(____Entities.Sku.new("KB0001"), 1), __K2L_Pair.new(____Entities.Sku.new("CB0003"), 3))))
    orders:save(____Entities.Order.new(1, ____Entities.CustomerId.new("us", 2), __K2L_SingletonListOf(__K2L_Pair.new(____Entities.Sku.new("MN0002"), 2))))
    orders:save(____Entities.Order.new(2, ____Entities.CustomerId.new("eu", 3), __K2L_ReadOnlyListOf(__K2L_Pair.new(____Entities.Sku.new("MS0001"), 1), __K2L_Pair.new(____Entities.Sku.new("HD0001"), 1), __K2L_Pair.new(____Entities.Sku.new("CB0003"), 1))))
    printAll("orders", orders:all(), function(it)
        return "#" .. it.id .. " " .. __K2L_Str(it.customer) .. " qty=" .. it:quantity() .. " total=" .. __K2L_Str(pricing:total(it))
    end)
    local ____ok_3, ____result_4 = __K2L_DeepPcall(function()
        pricing:total(____Entities.Order.new(9, ____Entities.CustomerId.new("eu", 7), __K2L_SingletonListOf(__K2L_Pair.new(____Entities.Sku.new("ZZ9999"), 1))))
    end)
    if not ____ok_3 then
        local ____error_3 = __K2L_ToThrowable(____result_4)
        if __K2L_InstanceOf(____error_3, __K2L_NoSuchElementException) then
            local e = ____error_3
            print("pricing failed: " .. __K2L_Str(e.message))
        else
            error(____error_3, 0)
        end
    end
    local totals = orders:all():associate(function(it)
        return __K2L_Pair.new(it.id, pricing:total(it))
    end)
    print("totals: " .. __K2L_Str(totals) .. ", max " .. __K2L_Str(totals:getValues():max()) .. ", sum " .. __K2L_Str(totals:getValues():fold(____Entities.Money.ZERO, ____lambda_11)))
    print("first by key: " .. __K2L_Str(____Query.firstByKey(totals)))
    print("max name: " .. __K2L_Str(____Query.maxValue(products:all(), ____lambda_12)) .. ", max price: " .. __K2L_Str(____Query.maxValue(products:all(), ____lambda_13)))
    print("buckets: " .. __K2L_Str(____Query.bucket(products:all(), ____lambda_14):mapValues(function(____destructured_1)
        local v = ____destructured_1.value
        local ____out_3 = {}
        local ____count_3 = 0
        local ____items_5, ____n_5 = v:____array()
        for ____i_6 = 1, ____n_5 do
            local it = ____items_5[____i_6]
            ____count_3 = ____count_3 + 1
            ____out_3[____count_3] = it.name
        end
        return __K2L_ListWrap(____out_3, ____count_3)
    end)))
    local ____list_5 = products:all()
    local ____out_4 = {}
    local ____count_4 = 0
    local ____items_6, ____n_6 = ____list_5:____array()
    for ____i_7 = 1, ____n_6 do
        local it = ____items_6[____i_7]
        ____count_4 = ____count_4 + 1
        ____out_4[____count_4] = it.name
    end
    print("pages: " .. __K2L_Str(____Query.pages(__K2L_ListWrap(____out_4, ____count_4), 2)))
    local audit = AuditLog.new()
    print("copied " .. ____Repository.copyAll(products, audit) .. " products, " .. ____Repository.copyAll(customers, audit) .. " customers")
    print(__K2L_Str(audit.seen))
    local anyRepo = products
    print("named: " .. countNamed(anyRepo) .. ", " .. ____Repository.describe(anyRepo) .. ", " .. ____Repository.describe(orders))
    local repos = __K2L_ReadOnlyListOf(products, customers, orders)
    local ____mod_2 = repos.____modCount
    for ____i_8 = 1, repos.size do
        local r = repos[____i_8]
        print(__K2L_Str(r) .. ": " .. __K2L_Str(r:history():takeLast(2)))
        if repos.____modCount ~= ____mod_2 and repos:____comodified(____i_8) then
            break
        end
    end
    local ____result_5 = __K2L_Map.new()
    local ____items_7, ____n_7 = repos:____array()
    for ____i_9 = 1, ____n_7 do
        local it = ____items_7[____i_9]
        local ____value = #it.kind
        local ____group = ____result_5:get(____value)
        if ____group == nil then
            ____group = __K2L_List.new()
            ____result_5:put(____value, ____group)
        end
        ____group:add(it)
    end
    local byKind = ____result_5
    print(__K2L_Str(byKind:mapValues(function(____destructured_2)
        local v = ____destructured_2.value
        local ____out_5 = {}
        local ____count_5 = 0
        local ____items_8, ____n_8 = v:____array()
        for ____i_10 = 1, ____n_8 do
            local it = ____items_8[____i_10]
            ____count_5 = ____count_5 + 1
            ____out_5[____count_5] = it.kind
        end
        return __K2L_ListWrap(____out_5, ____count_5)
    end)))
    local first = products:find(____Entities.Sku.new("CB0003"))
    local ____receiver_1 = getmetatable(first) == ____Entities.Product and first or nil
    print("found " .. __K2L_Str(____receiver_1 and (getmetatable(first) == ____Entities.Product and first or nil).name) .. " " .. tostring(__K2L_InstanceOf(first, ____Entities.Named)) .. " " .. tostring(__K2L_IsComparable(first)))
end

__K2L_DeepMain(main)
return {ProductRepository = ProductRepository, AuditLog = AuditLog, Pricing = Pricing, printAll = printAll, countNamed = countNamed}
-- ==== query/Query.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_FunInterface = ____lualib.__K2L_FunInterface
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_LoopItems = ____lualib.__K2L_LoopItems
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReverseComparator = ____lualib.__K2L_ReverseComparator
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith

local Spec = __K2L_Class("shop.query.Spec")
__K2L_ClassInfo(Spec, "shop.query.Spec", "shop.query.Spec", "interface")

function Spec:____not()
    return __K2L_FunInterface(Spec, "test", function(it) return not self:test(it) end)
end

local function ____and(self, other)
    return __K2L_FunInterface(Spec, "test", function(it) return self:test(it) and other:test(it) end)
end

local function ____or(____this, other)
    return __K2L_FunInterface(Spec, "test", function(it) return ____this:test(it) or other:test(it) end)
end

local function nameStarts(prefix)
    return __K2L_FunInterface(Spec, "test", function(it)
        return __K2L_StringStartsWith(it.name:lower(), prefix:lower())
    end)
end

local Query = __K2L_Class("shop.query.Query")
__K2L_ClassInfo(Query, "shop.query.Query", "shop.query.Query", "class")

function Query:____init(source)
    self.source = source
    self.specs = __K2L_ListOf()
    self.order = nil
    self.limit = 2147483647
end

function Query:where(spec)
    self.specs:add(spec)
    return self
end

function Query:orderBy(selector)
    self.order = __K2L_CompareBy(selector)
    return self
end

function Query:orderByDescending(cmp)
    self.order = __K2L_ReverseComparator(cmp)
    return self
end

function Query:limit__1(n)
    self.limit = n
    return self
end

function Query:run()
    local ____list = self.source:all()
    local ____out = {}
    local ____count = 0
    local ____items_1, ____n_1 = ____list:____array()
    for ____i_1 = 1, ____n_1 do
        local e = ____items_1[____i_1]
        local ____result
        do
            local ____list_1 = self.specs
            local ____result_1 = true
            local ____items, ____n = ____list_1:____array()
            for ____i = 1, ____n do
                local it = ____items[____i]
                if not it:test(e) then
                    ____result_1 = false
                    break
                end
            end
            ____result = ____result_1
        end
        if ____result then
            ____count = ____count + 1
            ____out[____count] = e
        end
    end
    local matching = __K2L_ListWrap(____out, ____count)
    local ____receiver = self.order
    local sorted = ____receiver and matching:sortedWith(____receiver) or matching
    return sorted:take(self.limit)
end

function Query:first()
    return self:limit__1(1):run():firstOrNull()
end

local function query(____this_1)
    return Query.new(____this_1)
end

local function maxValue(____this_2, selector)
    local best = nil
    local ____items_2, ____n_2 = __K2L_LoopItems(____this_2)
    local ____mod = ____this_2.____modCount
    for ____i_2 = 1, ____n_2 do
        local item = ____items_2[____i_2]
        local v = selector(item)
        if best == nil or __K2L_Compare(v, best) > 0 then
            best = v
        end
        if ____this_2.____modCount ~= ____mod and ____this_2:____comodified(____i_2, ____n_2) then
            break
        end
    end
    return best
end

local function firstByKey(____this_3)
    local ____receiver_1 = ____this_3:getKeys():minOrNull()
    return ____receiver_1 and __K2L_Pair.new(____receiver_1, ____this_3:getValue(____receiver_1))
end

local ____lambda_1 = function() return __K2L_ListOf() end
local function bucket(____this_4, key)
    local result = __K2L_SortedMapOf()
    local ____items_3, ____n_3 = __K2L_LoopItems(____this_4)
    local ____mod_1 = ____this_4.____modCount
    for ____i_3 = 1, ____n_3 do
        local item = ____items_3[____i_3]
        result:getOrPut(key(item), ____lambda_1):add(item)
        if ____this_4.____modCount ~= ____mod_1 and ____this_4:____comodified(____i_3, ____n_3) then
            break
        end
    end
    return result
end

local function page(____this_5, size, index)
    return ____this_5:drop(size * index):take(size)
end

local function pages(____this_6, size)
    return __K2L_IntRange.new(0, __K2L_IDiv(____this_6.size + size - 1, size) - 1):map(function(it) return page(____this_6, size, it) end)
end

return {Spec = Spec, ____and = ____and, ____or = ____or, nameStarts = nameStarts, Query = Query, query = query, maxValue = maxValue, firstByKey = firstByKey, bucket = bucket, page = page, pages = pages}
-- ==== storage/Repository.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_Str = ____lualib.__K2L_Str

local ____Entities = require("domain.Entities")
local ReadRepository = __K2L_Class("shop.storage.ReadRepository")
__K2L_ClassInfo(ReadRepository, "shop.storage.ReadRepository", "shop.storage.ReadRepository", "interface")

function ReadRepository:getSize()
    return self:all().size
end

local WriteRepository = __K2L_Class("shop.storage.WriteRepository")
__K2L_ClassInfo(WriteRepository, "shop.storage.WriteRepository", "shop.storage.WriteRepository", "interface")
local ConflictException = __K2L_Class("shop.storage.ConflictException", __K2L_IllegalStateException)
__K2L_ClassInfo(ConflictException, "shop.storage.ConflictException", "shop.storage.ConflictException", "class")

function ConflictException:____init(entityId, message)
    __K2L_IllegalStateException.____init(self, message)
    self.entityId = entityId
end

local Repository = __K2L_Class("shop.storage.Repository", nil, ReadRepository, WriteRepository)
__K2L_ClassInfo(Repository, "shop.storage.Repository", "shop.storage.Repository", "class")

function Repository:____init(kind)
    self.kind = kind
    self.events = __K2L_ListOf()
    self.saves = 0
end

function Repository:validate(entity)
    return nil
end

function Repository:save(entity)
    local ____receiver = self:validate(entity)
    if ____receiver ~= nil then
        local ____result
        error(__K2L_IllegalArgumentException.new("invalid " .. self.kind .. " " .. __K2L_Str(entity.id) .. ": " .. ____receiver))
    end
    local old = self:load(entity.id)
    if __K2L_InstanceOf(old, ____Entities.Versioned) and __K2L_InstanceOf(entity, ____Entities.Versioned) and entity.version <= old.version then
        error(ConflictException.new(entity.id, "stale " .. self.kind .. " " .. __K2L_Str(entity.id) .. ": v" .. entity.version .. " <= v" .. old.version))
    end
    self:store(entity)
    self.saves = self.saves + 1
    self.events:add((old == nil and "insert " or "update ") .. __K2L_Str(entity.id))
end

function Repository:find(id)
    return self:load(id)
end

function Repository:history()
    return self.events:toList()
end

function Repository:toString()
    return self.kind .. " repository (" .. self:getSize() .. " items, " .. self.saves .. " saves)"
end

local SortedRepository = __K2L_Class("shop.storage.SortedRepository", Repository)
__K2L_ClassInfo(SortedRepository, "shop.storage.SortedRepository", "shop.storage.SortedRepository", "class")

function SortedRepository:____init(kind)
    Repository.____init(self, kind)
    self.items = __K2L_SortedMapOf()
end

function SortedRepository:store(entity)
    local ____object = self.items
    local ____key = entity.id
    ____object:set(____key, entity)
end

function SortedRepository:load(id)
    return self.items:get(id)
end

function SortedRepository:all()
    return self.items:getValues():toList()
end

function SortedRepository:getSize()
    return self.items.size
end

function SortedRepository:range(from, to)
    return self.items:subMap(from, to):getValues():toList()
end

local BoundedRepository = __K2L_Class("shop.storage.BoundedRepository", Repository)
__K2L_ClassInfo(BoundedRepository, "shop.storage.BoundedRepository", "shop.storage.BoundedRepository", "class")

function BoundedRepository:____init(kind, capacity)
    Repository.____init(self, kind)
    self.capacity = capacity
    self.items = __K2L_Map.new()
end

function BoundedRepository:store(entity)
    self.items:remove(entity.id)
    local ____object_1 = self.items
    local ____key_1 = entity.id
    ____object_1:set(____key_1, entity)
    while self.items.size > self.capacity do
        local oldest = self.items:getKeys():first()
        self.items:remove(oldest)
        self.events:add("evict " .. __K2L_Str(oldest))
    end
end

function BoundedRepository:load(id)
    return self.items:get(id)
end

function BoundedRepository:all()
    return self.items:getValues():toList()
end

local function ____require(self, id)
    local ____value = self:find(id)
    if ____value == nil then
        error(__K2L_NoSuchElementException.new("no entity " .. __K2L_Str(id)))
    end
    return ____value
end

local function describe(____this)
    return "repo with " .. ____this:getSize() .. " entities"
end

local function copyAll(from, to)
    local n = 0
    local ____list = from:all()
    local ____mod = ____list.____modCount
    for ____i = 1, ____list.size do
        local e = ____list[____i]
        to:save(e)
        n = n + 1
        if ____list.____modCount ~= ____mod and ____list:____comodified(____i) then
            break
        end
    end
    return n
end

return {ReadRepository = ReadRepository, WriteRepository = WriteRepository, ConflictException = ConflictException, Repository = Repository, SortedRepository = SortedRepository, BoundedRepository = BoundedRepository, ____require = ____require, describe = describe, copyAll = copyAll}
