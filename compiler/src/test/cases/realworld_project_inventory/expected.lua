-- ==== config/Settings.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Lazy = ____lualib.__K2L_Lazy
local __K2L_LazyObject = ____lualib.__K2L_LazyObject
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_Uninitialized = ____lualib.__K2L_Uninitialized

local ____exports = {}
local ____Log = require("log.Log")
local APP_NAME = "inventory"
local TAX_PERCENT = 8
____exports.verbosity = 1
____exports.currency = "EUR"
local ____startupToken_delegate = __K2L_Lazy(function()
    return ____Log.log("computing startupToken") * 100
end)

local function describeSettings()
    local p = ____exports.profile ~= nil and (____exports.profile or __K2L_Uninitialized("profile")) or "<unset>"
    return APP_NAME .. " v=" .. ____exports.verbosity .. " cur=" .. ____exports.currency .. " profile=" .. p
end

local function bumpVerbosity(by)
    if by == nil then
        by = 1
    end
    ____exports.verbosity = ____exports.verbosity + by
    return ____exports.verbosity
end

local Settings = __K2L_Class("shop.config.Settings")

function Settings:____init()
    self.values = __K2L_MapOf()
    ____Log.log("Settings object init")
    local ____object = self.values
    ____object:set("region", "north")
end

function Settings:get(key)
    return self.values:get(key)
end

function Settings:set(key, value)
    ____Log.log("Settings[" .. key .. "] = " .. value)
    local ____object_1 = self.values
    ____object_1:set(key, value)
end

function Settings:getKeys()
    return self.values:getKeys():toList()
end

__K2L_LazyObject(Settings, "____init")
____exports.APP_NAME = APP_NAME
____exports.TAX_PERCENT = TAX_PERCENT
____exports.____startupToken_delegate = ____startupToken_delegate
____exports.describeSettings = describeSettings
____exports.bumpVerbosity = bumpVerbosity
____exports.Settings = Settings
return ____exports
-- ==== ext/Pricing.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart

local ____Settings = require("config.Settings")
local ____Item = require("model.Item")
local lastParsedLine

local function getTotalCents(self)
    return self.cents * self.qty
end

local function withTax(____this)
    local ____arg = getTotalCents(____this)
    local ____dividend = getTotalCents(____this) * ____Settings.TAX_PERCENT
    return ____arg + (____dividend >= 0 and ____dividend // 100 or 0 - -____dividend // 100)
end

local function money(____this_1)
    local sign = ____this_1 < 0 and "-" or ""
    local abs = ____this_1 < 0 and -____this_1 or ____this_1
    return sign .. (abs >= 0 and abs // 100 or 0 - -abs // 100) .. "." .. __K2L_StringPadStart(tostring(abs >= 0 and abs % 100 or 0 - -abs % 100), 2, "0") .. " " .. ____Settings.currency
end

local ____lambda_1 = function(it) return withTax(it) end
local function grandTotal(____this_2)
    return ____this_2:sumOf(____lambda_1)
end

local function times(____this_3, n)
    return ____Item.Item.new(____this_3.sku, ____this_3.name, ____this_3.cents, ____this_3.qty * n)
end

local function getLastParsed(____this_4)
    return lastParsedLine
end

local function setLastParsed(____this_4, value)
    lastParsedLine = value
end

lastParsedLine = "-"
return {getTotalCents = getTotalCents, withTax = withTax, money = money, grandTotal = grandTotal, times = times, getLastParsed = getLastParsed, setLastParsed = setLastParsed}
-- ==== log/Log.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_ListOf = ____lualib.__K2L_ListOf

local ____exports = {}
local journal = __K2L_ListOf()
____exports.sequence = 0

local function log(message)
    ____exports.sequence = ____exports.sequence + 1
    journal:add(____exports.sequence .. " " .. message)
    print("[log] " .. message)
    return ____exports.sequence
end

local function dumpJournal(from)
    if from == nil then
        from = 0
    end
    return journal:drop(from):joinToString(" | ")
end

____exports.journal = journal
____exports.log = log
____exports.dumpJournal = dumpJournal
return ____exports
-- ==== main.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_TouchObject = ____lualib.__K2L_TouchObject

local ____Settings = require("config.Settings")
local ____Log = require("log.Log")
local ____Store = require("store.Store")
local ____Item = require("model.Item")
local ____Pricing = require("ext.Pricing")

local function main()
    print("start " .. ____Settings.APP_NAME)
    print(____Settings.describeSettings())
    ____Settings.profile = "warehouse"
    ____Settings.verbosity = 2
    print(____Settings.describeSettings())
    print("bumped to " .. ____Settings.bumpVerbosity() .. " then " .. ____Settings.bumpVerbosity(3) .. "; main sees " .. ____Settings.verbosity)
    ____Settings.verbosity = ____Settings.verbosity - 1
    print("verbosity now " .. ____Settings.verbosity)
    print("journal size before objects: " .. ____Log.journal.size .. ", sequence " .. ____Log.sequence)
    print("token " .. ____Settings.____startupToken_delegate:getValue() .. " again " .. ____Settings.____startupToken_delegate:getValue())
    local ____object = __K2L_TouchObject(____Settings.Settings)
    ____object:set("region", "south")
    print("keys " .. __K2L_Str(____Settings.Settings:getKeys()))
    print("opened at " .. ____Store.Store.opened)
    ____Store.Store:receive("T-100, hammer, 1299, 2")
    ____Store.Store:receive("F-7, coffee, 450")
    ____Store.Store:receive("T-100, hammer, 1299, 3")
    ____Store.Store:receive("X-1, mystery, 99, 4")
    print("created " .. ____Item.Item.created .. " items; last parsed '" .. ____Pricing.getLastParsed(____Item.Item) .. "'")
    print("stock " .. __K2L_Str(____Store.stock:getKeys()) .. " ops " .. ____Store.operations)
    print(____Store.Store:take("T-100", 4))
    print(____Store.Store:take("F-7", 2))
    print(____Store.Store:take("F-7", 1))
    print(____Store.Store:take("nope", 1))
    local ____list = ____Store.stock:getValues()
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = it.sku .. ":" .. it.qty
    end
    print("stock " .. __K2L_Str(__K2L_ListWrap(____out, ____count)) .. " ops " .. ____Store.operations)
    print(__K2L_Str(____Store.Store:byCategory()))
    ____Settings.currency = "USD"
    print("value " .. ____Pricing.money(____Store.Store:value()))
    local crate = ____Pricing.times(____Item.Item.new("T-9", "nails", 5, 10), 3)
    print(__K2L_Str(crate) .. " " .. ____Pricing.money(____Pricing.getTotalCents(crate)) .. " " .. ____Pricing.money(____Pricing.grandTotal(__K2L_ReadOnlyListOf(crate, crate))))
    print(____Pricing.money(-1234))
    local mark = ____Log.log("done")
    print("journal from " .. mark .. ": " .. ____Log.dumpJournal(mark - 1))
    print("journal head: " .. __K2L_Text.take(____Log.dumpJournal(), 60))
end

__K2L_Main(main)
-- ==== model/Item.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_LazyObject = ____lualib.__K2L_LazyObject
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringTrim = ____lualib.__K2L_StringTrim

local ____Log = require("log.Log")
local ____Settings = require("config.Settings")
local Item = __K2L_Class("shop.model.Item")

function Item:____init(sku, name, cents, qty)
    if qty == nil then
        qty = 1
    end
    self.sku = sku
    self.name = name
    self.cents = cents
    self.qty = qty
    Item.created = Item.created + 1
end

function Item:toString()
    return "Item(sku=" .. self.sku .. ", name=" .. self.name .. ", cents=" .. self.cents .. ", qty=" .. self.qty .. ")"
end

function Item:hashCode()
    return (31 * (31 * (31 * __K2L_Hash(self.sku) + __K2L_Hash(self.name)) + self.cents) + self.qty + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Item:equals(other)
    return getmetatable(other) == Item and self.sku == other.sku and self.name == other.name and self.cents == other.cents and self.qty == other.qty
end

function Item:parse(line)
    local ____list = __K2L_StringSplit(line, ",")
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = __K2L_StringTrim(it)
    end
    local parts = __K2L_ListWrap(____out, ____count)
    local ____arg = parts:get(0)
    local ____arg_1 = parts:get(1)
    local ____arg_2 = __K2L_StringToInt(parts:get(2))
    local ____receiver = parts:getOrNull(3)
    return Item.new(____arg, ____arg_1, ____arg_2, ____receiver and __K2L_StringToInt(____receiver) or self.DEFAULT_QTY)
end

function Item:____initCompanion()
    self.created = 0
    ____Log.log("Item companion init (tax " .. ____Settings.TAX_PERCENT .. "%)")
    self.DEFAULT_QTY = 1
end

__K2L_LazyObject(Item, "____initCompanion")
local Category = __K2L_Class("shop.model.Category")

function Category:____init(name, ordinal, prefix)
    self.name = name
    self.ordinal = ordinal
    self.prefix = prefix
end

function Category:toString()
    return self.name
end

function Category:compareTo(other)
    return self.ordinal - other.ordinal
end

Category.TOOLS = Category.new("TOOLS", 0, "T")
Category.FOOD = Category.new("FOOD", 1, "F")
Category.MISC = Category.new("MISC", 2, "")
Category.____values = {Category.TOOLS, Category.FOOD, Category.MISC}
Category.____companion = true

function Category:of(item)
    local ____values = Category.____values
    local ____result
    for ____i_1 = 1, #____values do
        local it = ____values[____i_1]
        if #it.prefix > 0 and __K2L_StringStartsWith(item.sku, it.prefix) then
            ____result = it
            break
        end
    end
    return ____result or Category.MISC
end

return {Item = Item, Category = Category}
-- ==== store/Store.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_LazyFile = ____lualib.__K2L_LazyFile
local __K2L_LazyObject = ____lualib.__K2L_LazyObject
local __K2L_List = ____lualib.__K2L_List
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_TouchObject = ____lualib.__K2L_TouchObject

local ____exports = {}
local ____Log = require("log.Log")
local ____Settings = require("config.Settings")
local ____Item = require("model.Item")
local ____Pricing = require("ext.Pricing")
local Store = __K2L_Class("shop.store.Store")

function Store:____init()
    self.opened = ____Log.log("Store object init, region=" .. __K2L_Str(__K2L_TouchObject(____Settings.Settings):get("region")))
end

function Store:receive(line)
    local item = ____Item.Item:parse(line)
    local ____object = ____Item.Item
    ____Pricing.setLastParsed(____object, line)
    ____exports.operations = ____exports.operations + 1
    local existing = ____exports.stock:get(item.sku)
    local ____object_1 = ____exports.stock
    local ____key = item.sku
    ____object_1:set(____key, existing == nil and item or ____Item.Item.new(existing.sku, existing.name, existing.cents, existing.qty + item.qty))
    if ____Settings.verbosity > 1 then
        ____Log.log("received " .. item.sku .. " x" .. item.qty)
    end
    return item
end

function Store:take(sku, qty)
    local ____value = ____exports.stock:get(sku)
    if ____value == nil then
        return false
    end
    local item = ____value
    ____exports.operations = ____exports.operations + 1
    if item.qty < qty then
        return false
    end
    if item.qty == qty then
        ____exports.stock:remove(sku)
    else
        local ____object_2 = ____exports.stock
        ____object_2:set(sku, ____Item.Item.new(item.sku, item.name, item.cents, item.qty - qty))
    end
    return true
end

function Store:byCategory()
    local ____list = ____exports.stock:getValues()
    local ____result = __K2L_Map.new()
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        local ____value_1 = ____Item.Category:of(it)
        local ____group = ____result:get(____value_1)
        if ____group == nil then
            ____group = __K2L_List.new()
            ____result:put(____value_1, ____group)
        end
        ____group:add(it.sku)
    end
    return ____result
end

function Store:value()
    local ____list_1 = ____exports.stock:getValues()
    local ____sum = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        ____sum = ____sum + ____Pricing.withTax(it)
    end
    return ____sum
end

__K2L_LazyObject(Store, "____init")
____exports.Store = Store
__K2L_LazyFile(____exports, function()
    ____exports.operations = 0
    ____exports.stock = __K2L_MapOf()
    ____exports.fileStamp = ____Log.log("Store.kt top-level init")
end, {"operations", "stock", "fileStamp"})
return ____exports
