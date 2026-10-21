local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Random = ____lualib.__K2L_Random
local __K2L_RandomLong = ____lualib.__K2L_RandomLong
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_Unsigned = ____lualib.__K2L_Unsigned

local SplitMix = __K2L_Class("SplitMix")

function SplitMix:mix(seed)
    local z = seed + -7046029254386353131
    z = (z ~ z >> 30) * -4658895280553007687
    z = (z ~ z >> 27) * -7723592293110705685
    return z ~ z >> 31
end

function SplitMix:chunkSeed(world, cx, cy)
    return self:mix(world ~ cx << 32 ~ cy & 4294967295)
end

local Biome = __K2L_Class("Biome")

function Biome:____init(name, ordinal, symbol)
    self.name = name
    self.ordinal = ordinal
    self.symbol = symbol
end

function Biome:toString()
    return self.name
end

function Biome:compareTo(other)
    return self.ordinal - other.ordinal
end

Biome.OCEAN = Biome.new("OCEAN", 0, "~")
Biome.PLAINS = Biome.new("PLAINS", 1, ".")
Biome.FOREST = Biome.new("FOREST", 2, "T")
Biome.HILLS = Biome.new("HILLS", 3, "n")
Biome.DESERT = Biome.new("DESERT", 4, ":")
Biome.PEAK = Biome.new("PEAK", 5, "^")
Biome.____values = {Biome.OCEAN, Biome.PLAINS, Biome.FOREST, Biome.HILLS, Biome.DESERT, Biome.PEAK}
local Chunk = __K2L_Class("Chunk")

function Chunk:____init(cx, cy, seed)
    self.cx = cx
    self.cy = cy
    self.heights = __K2L_ListOfSize(16, 0, "[I")
    local rng = __K2L_Random.seededLong(seed)
    for i = 0, self.heights.size - 1 do
        local ____object = self.heights
        ____object[i + 1] = rng:nextInt(0, 256)
    end
    local avg = self.heights:average()
    local moisture = rng:nextDouble()
    if avg < 90 then
        self.biome = Biome.OCEAN
    elseif avg > 160 then
        self.biome = Biome.PEAK
    elseif avg > 140 then
        self.biome = Biome.HILLS
    elseif moisture < 0.3 then
        self.biome = Biome.DESERT
    elseif moisture < 0.6 then
        self.biome = Biome.PLAINS
    else
        self.biome = Biome.FOREST
    end
    self.ore = __K2L_RandomLong.nextLong(rng, 1 << 40, 1 << 62)
end

local World = __K2L_Class("World")

function World:____init(seed)
    self.seed = seed
    self.chunks = __K2L_HashMap.new()
end

function World:chunk(cx, cy)
    return self.chunks:getOrPut(__K2L_Pair.new(cx, cy), function()
        return Chunk.new(cx, cy, SplitMix:chunkSeed(self.seed, cx, cy))
    end)
end

function World:render(size)
    return __K2L_IntRange.new(0, size - 1):map(function(y)
        return __K2L_IntRange.new(0, size - 1):map(function(x) return self:chunk(x - 2, y - 2).biome.symbol end):joinToString("")
    end)
end

function World:totalOre(size)
    local total = 0
    for y = 0, size - 1 do
        for x = 0, size - 1 do
            total = total + self:chunk(x - 2, y - 2).ore
        end
    end
    return total
end

local ____lambda_1 = function(it) return __K2L_Unsigned.toString(it) end
local ____lambda_2 = function(it) return __K2L_Unsigned.toString(it) end
local function longDraws()
    print("-- long draws")
    local r = __K2L_Random.seededLong(9223372036854775807)
    local ____out = {}
    for ____i = 1, 3 do
        local it = ____i - 1
        ____out[____i] = r:nextLong()
    end
    print(__K2L_Str(__K2L_ListWrap(____out, 3)))
    local ____out_1 = {}
    for ____i_1 = 1, 3 do
        local it = ____i_1 - 1
        ____out_1[____i_1] = __K2L_RandomLong.nextLong(r, nil, 9223372036854775807)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, 3)))
    local ____out_2 = {}
    for ____i_2 = 1, 3 do
        local it = ____i_2 - 1
        ____out_2[____i_2] = __K2L_RandomLong.nextLong(r, nil, 1 << 53)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_2, 3)))
    local ____out_3 = {}
    for ____i_3 = 1, 3 do
        local it = ____i_3 - 1
        ____out_3[____i_3] = __K2L_RandomLong.nextLong(r, nil, 1 << 62)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_3, 3)))
    local ____out_4 = {}
    for ____i_4 = 1, 3 do
        local it = ____i_4 - 1
        ____out_4[____i_4] = __K2L_RandomLong.nextLong(r, nil, 3000000000000000001)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_4, 3)))
    local ____out_5 = {}
    for ____i_5 = 1, 3 do
        local it = ____i_5 - 1
        ____out_5[____i_5] = __K2L_RandomLong.nextLong(r, -9223372036854775807 - 1, 9223372036854775807)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_5, 3)))
    local ____out_6 = {}
    for ____i_6 = 1, 3 do
        local it = ____i_6 - 1
        ____out_6[____i_6] = __K2L_RandomLong.nextLong(r, -1 << 60, 1 << 60)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_6, 3)))
    local ____out_7 = {}
    for ____i_7 = 1, 3 do
        local it = ____i_7 - 1
        ____out_7[____i_7] = __K2L_RandomLong.nextLongIn(r, __K2L_IntRange.new(0, 9223372036854775807))
    end
    print(__K2L_Str(__K2L_ListWrap(____out_7, 3)))
    local ____out_8 = {}
    for ____i_8 = 1, 3 do
        local it = ____i_8 - 1
        ____out_8[____i_8] = __K2L_RandomLong.nextLongIn(r, __K2L_IntRange.new(-9223372036854775807 - 1, 9223372036854775807))
    end
    print(__K2L_Str(__K2L_ListWrap(____out_8, 3)))
    local ____out_9 = {}
    for ____i_9 = 1, 3 do
        local it = ____i_9 - 1
        ____out_9[____i_9] = __K2L_RandomLong.nextLongIn(r, __K2L_IntRange.new(10, 20))
    end
    print(__K2L_Str(__K2L_ListWrap(____out_9, 3)))
    local ____out_10 = {}
    for ____i_10 = 1, 2 do
        local it = ____i_10 - 1
        ____out_10[____i_10] = __K2L_RandomLong.nextULong(r)
    end
    print(__K2L_ListWrap(____out_10, 2):joinToString(nil, nil, nil, nil, nil, ____lambda_1))
    local ____out_11 = {}
    for ____i_11 = 1, 2 do
        local it = ____i_11 - 1
        ____out_11[____i_11] = __K2L_RandomLong.nextULong(r, nil, __K2L_Unsigned.udiv(0xffffffffffffffff, 3))
    end
    print(__K2L_ListWrap(____out_11, 2):joinToString(nil, nil, nil, nil, nil, ____lambda_2))
    local ____out_12 = {}
    for ____i_12 = 1, 2 do
        local it = ____i_12 - 1
        ____out_12[____i_12] = __K2L_RandomLong.nextLongIn(r, __K2L_IntRange.new(1, 9223372036854775807), false)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_12, 2)))
    local ____out_13 = {}
    for ____i_13 = 1, 6 do
        local it = ____i_13 - 1
        ____out_13[____i_13] = r:nextBits(31)
    end
    local ____list = __K2L_ListWrap(____out_13, 6)
    local ____sum = 0
    local ____items, ____n = ____list:____array()
    for ____i_14 = 1, ____n do
        local it = ____items[____i_14]
        ____sum = ____sum + it
    end
    print(____sum)
    local ____list_1 = __K2L_ReadOnlyListOf(-9223372036854775807 - 1, 9223372036854775807, 1 << 53, (1 << 53) + 1, -1 << 40, 81985529216486895)
    for ____i_15 = 1, ____list_1.size do
        local seed = ____list_1[____i_15]
        local s = __K2L_Random.seededLong(seed)
        print(seed .. " -> " .. s:nextInt() .. " " .. s:nextLong() .. " " .. __K2L_RandomLong.nextLong(s, nil, 1000))
    end
end

local function worlds()
    print("-- worlds")
    print(SplitMix:mix(0))
    print(SplitMix:mix(1))
    print(SplitMix:mix(-9223372036854775807 - 1))
    print(SplitMix:chunkSeed(42, -3, 7))
    local ____list_2 = __K2L_ReadOnlyListOf(42, 8675309, -9000000000000000000)
    for ____i_17 = 1, ____list_2.size do
        local seed = ____list_2[____i_17]
        local world = World.new(seed)
        print("world " .. seed)
        local ____list_3 = world:render(5)
        for ____i_16 = 1, ____list_3.size do
            local it = ____list_3[____i_16]
            print("  " .. it)
        end
        print("  ore=" .. world:totalOre(5) .. " max=" .. __K2L_IntRange.new(0, 5 - 1):maxOf(function(it) return world:chunk(it - 2, 0).ore end))
        local c = world:chunk(0, 0)
        print("  chunk(0,0) heights=" .. __K2L_Str(c.heights:take(6)) .. " biome=" .. __K2L_Str(c.biome))
    end
end

local function lottery()
    print("-- lottery")
    local draw = __K2L_Random.seededLong(20240101)
    local ____out_14 = {}
    for ____i_18 = 1, 5 do
        local it = ____i_18 - 1
        local ____result
        do
            local ____out_15 = {}
            for ____i_19 = 1, 6 do
                local it = ____i_19 - 1
                ____out_15[____i_19] = draw:nextInt(1, 50)
            end
            ____result = __K2L_ListWrap(____out_15, 6):distinct():sorted()
        end
        ____out_14[____i_18] = ____result
    end
    local tickets = __K2L_ListWrap(____out_14, 5)
    local ____mod = tickets.____modCount
    for ____i_20 = 1, tickets.size do
        local t = tickets[____i_20]
        local i = ____i_20 - 1
        print("ticket " .. i .. ": " .. __K2L_Str(t))
        if tickets.____modCount ~= ____mod and tickets:____comodified(____i_20) then
            break
        end
    end
    local winning = __K2L_IntRange.new(1, 49):shuffled(draw):take(6):sorted()
    print("winning: " .. __K2L_Str(winning))
    local ____mod_1 = tickets.____modCount
    for ____i_22 = 1, tickets.size do
        local t = tickets[____i_22]
        local ____result_1 = 0
        local ____items_1, ____n_1 = t:____array()
        for ____i_21 = 1, ____n_1 do
            local it = ____items_1[____i_21]
            if winning:contains(it) then
                ____result_1 = ____result_1 + 1
            end
        end
        print("matches: " .. ____result_1)
        if tickets.____modCount ~= ____mod_1 and tickets:____comodified(____i_22) then
            break
        end
    end
    local ____out_16 = {}
    for ____i_23 = 1, 4 do
        local it = ____i_23 - 1
        ____out_16[____i_23] = __K2L_StringPadStart(__K2L_Unsigned.toRadix(draw:nextLong(), 16), 16, "0")
    end
    local ids = __K2L_ListWrap(____out_16, 4)
    print(__K2L_Str(ids))
end

local function main()
    longDraws()
    worlds()
    lottery()
end

__K2L_Main(main)
return {SplitMix = SplitMix, Biome = Biome, Chunk = Chunk, World = World, longDraws = longDraws, worlds = worlds, lottery = lottery}
