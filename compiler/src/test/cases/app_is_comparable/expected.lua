local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_IsComparable = ____lualib.__K2L_IsComparable
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SimpleName = ____lualib.__K2L_SimpleName
local __K2L_Str = ____lualib.__K2L_Str

local Version = __K2L_Class("Version")
Version.____comparable = true

function Version:compareTo(other)
    return 0
end

local Level = __K2L_Class("Level")

function Level:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Level:toString()
    return self.name
end

function Level:compareTo(other)
    return self.ordinal - other.ordinal
end

Level.LOW = Level.new("LOW", 0)
Level.HIGH = Level.new("HIGH", 1)
Level.____values = {Level.LOW, Level.HIGH}
local Ranked = __K2L_Class("Ranked")
Ranked.____comparable = true

function Ranked:compareTo(other)
    return __K2L_Compare(self.rank, other.rank)
end

local Card = __K2L_Class("Card", nil, Ranked)

function Card:____init(rank)
    self.rank = rank
end

function Card.new(rank)
    return setmetatable({rank = rank}, Card)
end

local Ace = __K2L_Class("Ace", Card)

function Ace:____init()
    Card.____init(self, 14)
end

local Joker = __K2L_Class("Joker", Card)

function Joker:____init()
    Card.____init(self, 99)
end

Joker:____init()
local Money = __K2L_Class("Money")

function Money.new(cents)
    return setmetatable({cents = cents}, Money)
end

function Money:compareTo(other)
    return __K2L_Compare(self.cents, other.cents)
end

local Point = __K2L_Class("Point")
Point.____comparable = true

function Point.new(x)
    return setmetatable({x = x}, Point)
end

function Point:compareTo(other)
    return self.x - other.x
end

__K2L_DataClass(Point, {"x"})
Point.____companion = true

function Point:origin()
    return Point.new(0)
end

local function describe(x)
    return __K2L_IsComparable(x) and "comparable" or "not comparable"
end

local ____lambda_1 = function(x) return __K2L_IsComparable(x) end
local function main()
    local values = __K2L_ListOf(Version, Level.HIGH, Card.new(3), Ace.new(), Joker, Money.new(5), Point.new(1), 1, "s", 2.5, true, nil, __K2L_ListOf(1))
    for ____i = 1, values.size do
        local it = values[____i]
        print(__K2L_Str(it and __K2L_SimpleName(it)) .. ": " .. describe(it))
    end
    print(values:filter(____lambda_1).size)
    print(__K2L_Compare(Money.new(1), Money.new(2)) < 0)
    local companions = __K2L_ListOf(Point, Point:origin())
    local ____out = {}
    local ____count = 0
    local ____items, ____n = companions:____array()
    for ____i_1 = 1, ____n do
        local it = ____items[____i_1]
        ____count = ____count + 1
        ____out[____count] = describe(it)
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    local ____list = __K2L_ListOf(Ace.new(), Card.new(2), Joker):sorted()
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list:____array()
    for ____i_2 = 1, ____n_1 do
        local it = ____items_1[____i_2]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = it.rank
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
end

__K2L_RunMain(main)
return {Version = Version, Level = Level, Ranked = Ranked, Card = Card, Ace = Ace, Joker = Joker, Money = Money, Point = Point, describe = describe}
