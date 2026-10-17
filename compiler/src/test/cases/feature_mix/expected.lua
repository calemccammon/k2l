local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_EnumValues = ____lualib.__K2L_EnumValues
local __K2L_Lazy = ____lualib.__K2L_Lazy
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ObservableProperty = ____lualib.__K2L_ObservableProperty
local __K2L_Str = ____lualib.__K2L_Str

local Priced = __K2L_Class("Priced")
local Size = __K2L_Class("Size", nil, Priced)

function Size:____init(name, ordinal, factor)
    self.name = name
    self.ordinal = ordinal
    self.factor = factor
end

function Size:getBase()
    return 10
end

function Size:toString()
    return self.name
end

do
    local ____SMALL = __K2L_Class("Size", Size)
    function ____SMALL:getPrice()
        return self:getBase() * self.factor
    end
    Size.SMALL = ____SMALL.new("SMALL", 0, 1)
end
do
    local ____LARGE = __K2L_Class("Size", Size)
    function ____LARGE:getPrice()
        return self:getBase() * self.factor - self:getDiscount()
    end
    function ____LARGE:getDiscount()
        return self.____discount_delegate:getValue()
    end
    function ____LARGE:____init(...)
        Size.____init(self, ...)
        self.____discount_delegate = __K2L_Lazy(function()
            print("computing discount")
            return 2
        end)
    end
    Size.LARGE = ____LARGE.new("LARGE", 1, 3)
end
Size.____values = {Size.SMALL, Size.LARGE}

local function getLabel(self)
    return "costs " .. self:getPrice()
end

local Shop = __K2L_Class("Shop")

function Shop:____init(name)
    self.name = name
    self.____sales_delegate = __K2L_ObservableProperty(0, function(_, old, new)
        print(self.name .. " sales " .. old .. " -> " .. new)
    end)
end

function Shop:getSales()
    return self.____sales_delegate:getValue(self, {name = "sales"})
end

function Shop:setSales(value)
    self.____sales_delegate:setValue(self, {name = "sales"}, value)
end

Shop.Till = __K2L_Class("Till")

function Shop.Till:____init(____outer, id)
    self.____outer = ____outer
    self.id = id
    self.____cache_delegate = __K2L_Lazy(function()
        return self.____outer.name .. "/till" .. self.id
    end)
end

function Shop.Till:getCache()
    return self.____cache_delegate:getValue()
end

function Shop.Till:sell(size)
    self.____outer:setSales(self.____outer:getSales() + size:getPrice())
    print(self:getCache() .. " sold " .. size.name .. ": " .. getLabel(size))
end

local function getTag(____this)
    return "#" .. ____this.id
end

local Item = __K2L_Class("Item")

function Item:____init(title)
    self.title = title
end

function Item:getShown()
    return self.title
end

local Special = __K2L_Class("Special", Item)

function Special:____init(title)
    Item.____init(self, title)
end

function Special:getShown()
    return "*" .. Item.getShown(self) .. "*"
end

local function main()
    local shop = Shop.new("corner")
    local till = Shop.Till.new(shop, 1)
    till:sell(Size.SMALL)
    till:sell(Size.LARGE)
    till:sell(Size.LARGE)
    print(getTag(till))
    print(__K2L_Str(__K2L_EnumValues(Size):map(function(it) return getLabel(it) end)))
    local items = __K2L_ListOf(Item.new("plain"), Special.new("fancy"))
    for _, item in ipairs(items) do
        print(item:getShown())
    end
    print(shop:getSales())
end

main()
return {Priced = Priced, Size = Size, getLabel = getLabel, Shop = Shop, getTag = getTag, Item = Item, Special = Special}
