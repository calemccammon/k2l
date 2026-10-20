local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_CompanionInfo = ____lualib.__K2L_CompanionInfo
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_IsComparable = ____lualib.__K2L_IsComparable
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str

local Version = __K2L_Class("Version")
__K2L_ClassInfo(Version, "Version", "Version", "class")
Version.____comparable = true

function Version:compareTo(other)
    return 0
end

local Level = __K2L_Class("Level")
__K2L_ClassInfo(Level, "Level", "Level", "class")

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
__K2L_ClassInfo(Ranked, "Ranked", "Ranked", "interface")
Ranked.____comparable = true

function Ranked:compareTo(other)
    return __K2L_Compare(self.rank, other.rank)
end

local Card = __K2L_Class("Card", nil, Ranked)
__K2L_ClassInfo(Card, "Card", "Card", "class")

function Card:____init(rank)
    self.rank = rank
end

function Card.new(rank)
    return setmetatable({rank = rank}, Card)
end

local Ace = __K2L_Class("Ace", Card)
__K2L_ClassInfo(Ace, "Ace", "Ace", "class")

function Ace:____init()
    Card.____init(self, 14)
end

local Joker = __K2L_Class("Joker", Card)
__K2L_ClassInfo(Joker, "Joker", "Joker", "class")

function Joker:____init()
    Card.____init(self, 99)
end

Joker:____init()
local Money = __K2L_Class("Money")
__K2L_ClassInfo(Money, "Money", "Money", "class")

function Money:____init(cents)
    self.cents = cents
end

function Money.new(cents)
    return setmetatable({cents = cents}, Money)
end

function Money:compareTo(other)
    return __K2L_Compare(self.cents, other.cents)
end

local Point = __K2L_Class("Point")
__K2L_ClassInfo(Point, "Point", "Point", "class")
__K2L_CompanionInfo(Point, "Point.Companion", "Point$Companion", "Companion")
Point.____comparable = true

function Point:____init(x)
    self.x = x
end

function Point.new(x)
    return setmetatable({x = x}, Point)
end

function Point:compareTo(other)
    return self.x - other.x
end

function Point:toString()
    return "Point(x=" .. self.x .. ")"
end

function Point:hashCode()
    return self.x
end

function Point:equals(other)
    return getmetatable(other) == Point and self.x == other.x
end

Point.____companion = true

function Point:origin()
    return Point.new(0)
end

local function describe(x)
    return __K2L_IsComparable(x) and "comparable" or "not comparable"
end

local ____lambda_1 = function(x) return __K2L_IsComparable(x) end
local function main()
    local values = __K2L_ReadOnlyListOf(Version, Level.HIGH, Card.new(3), Ace.new(), Joker, Money.new(5), Point.new(1), 1, "s", 2.5, true, nil, __K2L_SingletonListOf(1))
    local ____mod = values.____modCount
    for ____i = 1, values.size do
        local it = values[____i]
        print(__K2L_Str(it and __K2L_KClassOfValue(it).simpleName) .. ": " .. describe(it))
        if values.____modCount ~= ____mod and values:____comodified(____i) then
            break
        end
    end
    print(values:filter(____lambda_1).size)
    print(__K2L_Compare(Money.new(1), Money.new(2)) < 0)
    local companions = __K2L_ReadOnlyListOf(Point, Point:origin())
    local ____out = {}
    local ____count = 0
    local ____items, ____n = companions:____array()
    for ____i_1 = 1, ____n do
        local it = ____items[____i_1]
        ____count = ____count + 1
        ____out[____count] = describe(it)
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    local ____list = __K2L_ReadOnlyListOf(Ace.new(), Card.new(2), Joker):sorted()
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

main()
return {Version = Version, Level = Level, Ranked = Ranked, Card = Card, Ace = Ace, Joker = Joker, Money = Money, Point = Point, describe = describe}
