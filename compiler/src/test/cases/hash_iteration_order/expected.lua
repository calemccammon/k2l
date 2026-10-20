local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_HashMapOf = ____lualib.__K2L_HashMapOf
local __K2L_HashSet = ____lualib.__K2L_HashSet
local __K2L_HashSetOf = ____lualib.__K2L_HashSetOf
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringSplit = ____lualib.__K2L_StringSplit

local Cell = __K2L_Class("Cell")

function Cell:____init(r, c)
    self.r = r
    self.c = c
end

function Cell.new(r, c)
    return setmetatable({r = r, c = c}, Cell)
end

function Cell:toString()
    return "Cell(r=" .. self.r .. ", c=" .. self.c .. ")"
end

function Cell:hashCode()
    return (31 * self.r + self.c + 0x80000000 & 0xFFFFFFFF) - 0x80000000
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

function Key.new(name, tags, weight, on)
    return setmetatable({name = name, tags = tags, weight = weight, on = on}, Key)
end

function Key:toString()
    return "Key(name=" .. self.name .. ", tags=" .. __K2L_Str(self.tags) .. ", weight=" .. __K2L_Str(self.weight) .. ", on=" .. tostring(self.on) .. ")"
end

function Key:hashCode()
    return (31 * (31 * (31 * __K2L_Hash(self.name) + __K2L_Hash(self.tags)) + __K2L_Hash(self.weight)) + (self.on and 1231 or 1237) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
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
            local ____dividend = r * c
            if (____dividend >= 0 and ____dividend % 3 or 0 - -____dividend % 3) ~= 1 then
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
    local ____list = keys:getKeys()
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i_1 = 1, ____n do
        local it = ____items[____i_1]
        ____count = ____count + 1
        ____out[____count] = it:hashCode()
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    local chars = __K2L_HashMap.new()
    for ____i_2 = 1, #"mississippi river" do
        local ____char = ("mississippi river"):sub(____i_2, ____i_2)
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
    local ____result = __K2L_Map.new()
    local ____items_1, ____n_1 = words:____array()
    for ____i_3 = 1, ____n_1 do
        local it = ____items_1[____i_3]
        local ____value = #it
        local ____group = ____result:get(____value)
        if ____group == nil then
            ____group = __K2L_List.new()
            ____result:put(____value, ____group)
        end
        ____group:add(it)
    end
    print(__K2L_Str(____result:getKeys()))
    print(__K2L_Str(__K2L_HashMap.new(__K2L_ReadOnlyMapOf(__K2L_Pair.new("z", 1), __K2L_Pair.new("a", 2), __K2L_Pair.new("m", 3), __K2L_Pair.new("Aa", 4), __K2L_Pair.new("BB", 5)))))
    print(__K2L_Hash("Aa") == __K2L_Hash("BB"))
    local ____list_1 = __K2L_ReadOnlyListOf("hello", "world", "", "Kotlin", "été")
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_2, ____n_2 = ____list_1:____array()
    for ____i_4 = 1, ____n_2 do
        local it = ____items_2[____i_4]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = __K2L_Hash(it)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
end

main()
return {Cell = Cell, Key = Key}
