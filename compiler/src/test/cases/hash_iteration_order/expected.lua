local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_HashMapOf = ____lualib.__K2L_HashMapOf
local __K2L_HashSet = ____lualib.__K2L_HashSet
local __K2L_HashSetOf = ____lualib.__K2L_HashSetOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32

local Cell = __K2L_Class("Cell")

function Cell:____init(r, c)
    self.r = r
    self.c = c
end

function Cell:toString()
    return "Cell(r=" .. self.r .. ", c=" .. self.c .. ")"
end

function Cell:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.r) + __K2L_Hash(self.c))
end

function Cell:equals(other)
    return getmetatable(other) == Cell and self.r == other.r and self.c == other.c
end

local Key = __K2L_Class("Key")

function Key:____init(name, tags, weight, on)
    self.name = name
    self.tags = tags
    self.weight = weight
    self.on = on
end

function Key:toString()
    return "Key(name=" .. self.name .. ", tags=" .. __K2L_Str(self.tags) .. ", weight=" .. __K2L_Str(self.weight) .. ", on=" .. tostring(self.on) .. ")"
end

function Key:hashCode()
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.name) + __K2L_Hash(self.tags)) + __K2L_Hash(self.weight)) + __K2L_Hash(self.on))
end

function Key:equals(other)
    return getmetatable(other) == Key and self.name == other.name and __K2L_Equals(self.tags, other.tags) and self.weight == other.weight and self.on == other.on
end

local function main()
    local words = __K2L_StringSplit("the quick brown fox jumps over the lazy dog while seven zebras quietly vex jumping kangaroos", " ")
    local counts = __K2L_HashMap.new()
    local ____mod = words.____modCount
    for ____i = 1, words.size do
        local w = words[____i]
        counts:set(w, (counts:get(w) or 0) + 1)
        if words.____modCount ~= ____mod and words:____comodified(____i) then
            break
        end
    end
    print(__K2L_Str(counts))
    print(__K2L_Str(counts:getKeys():take(5)))
    local cells = __K2L_HashSet.new()
    for r = 0, 3 do
        for c = 0, 3 do
            if math.fmod(r * c, 3) ~= 1 then
                cells:add(Cell.new(r, c))
            end
        end
    end
    print(__K2L_Str(cells))
    local ____pairs = __K2L_HashSetOf()
    for i = -3, 3 do
        ____pairs:add(__K2L_Pair.new(i, i * i))
    end
    print(__K2L_Str(____pairs))
    local lists = __K2L_HashSetOf(__K2L_ReadOnlyListOf(1, 2), __K2L_SingletonListOf(3), __K2L_ReadOnlyListOf(), __K2L_ReadOnlyListOf(2, 1))
    print(__K2L_Str(lists))
    local keys = __K2L_HashMapOf(__K2L_Pair.new(Key.new("a", __K2L_SingletonListOf("x"), 1.5, true), 1), __K2L_Pair.new(Key.new("b", __K2L_ReadOnlyListOf(), -0.25, false), 2), __K2L_Pair.new(Key.new("c", __K2L_ReadOnlyListOf("y", "z"), 3.0, true), 3))
    print(__K2L_Str(keys:getValues()))
    print(__K2L_Str(keys:getKeys():map(function(it) return it:hashCode() end)))
    local chars = __K2L_HashMap.new()
    for ____char in ("mississippi river"):gmatch(".") do
        chars:set(____char, (chars:get(____char) or 0) + 1)
    end
    print(__K2L_Str(chars))
    local doubles = __K2L_HashSetOf(0.5, 1.25, -3.5, 100.125, 0.001)
    print(__K2L_Str(doubles))
    local longs = __K2L_HashMapOf(__K2L_Pair.new(10000000000, "a"), __K2L_Pair.new(3, "b"), __K2L_Pair.new(4294967296, "c"))
    print(__K2L_Str(longs))
    local bools = __K2L_HashMapOf(__K2L_Pair.new(true, 1), __K2L_Pair.new(false, 0))
    print(__K2L_Str(bools))
    print(__K2L_Str(words:toHashSet():take(6)))
    print(__K2L_Str(words:groupBy(function(it) return #it end):getKeys()))
    print(__K2L_Str(__K2L_HashMap.new(__K2L_ReadOnlyMapOf(__K2L_Pair.new("z", 1), __K2L_Pair.new("a", 2), __K2L_Pair.new("m", 3), __K2L_Pair.new("Aa", 4), __K2L_Pair.new("BB", 5)))))
    print(__K2L_Hash("Aa") == __K2L_Hash("BB"))
    print(__K2L_Str(__K2L_ReadOnlyListOf("hello", "world", "", "Kotlin", "été"):map(function(it) return __K2L_Hash(it) end)))
end

main()
return {Cell = Cell, Key = Key}
