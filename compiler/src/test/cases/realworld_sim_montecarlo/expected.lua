local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_CharRange = ____lualib.__K2L_CharRange
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Random = ____lualib.__K2L_Random
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Set = ____lualib.__K2L_Set
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function estimatePi(seed, samples)
    local rng = __K2L_Random.seeded(seed)
    local inside = 0
    for it = 0, samples - 1 do
        do
            local x = rng:nextDouble()
            local y = rng:nextDouble()
            if x * x + y * y <= 1.0 then
                inside = inside + 1
            end
        end
    end
    return 4.0 * inside / samples
end

local Walk = __K2L_Class("Walk")

function Walk.new(x, y, maxDistance, returns)
    return setmetatable({x = x, y = y, maxDistance = maxDistance, returns = returns}, Walk)
end

__K2L_DataClass(Walk, {"x", "y", "maxDistance", "returns"})

local function randomWalk(rng, steps)
    local x = 0
    local y = 0
    local best = 0.0
    local returns = 0
    for it = 0, steps - 1 do
        do
            local ____subject = rng:nextInt(4)
            if ____subject == 0 then
                x = x + 1
            elseif ____subject == 1 then
                x = x - 1
            elseif ____subject == 2 then
                y = y + 1
            else
                y = y - 1
            end
            local d = math.sqrt(x * x + y * y + 0.0)
            if d > best then
                best = d
            end
            if x == 0 and y == 0 then
                returns = returns + 1
            end
        end
    end
    return Walk.new(x, y, best, returns)
end

local DiceStats = __K2L_Class("DiceStats")

function DiceStats:____init(sides)
    self.sides = sides
    self.counts = __K2L_ListOfSize(self.sides + 1, 0, true)
    self.rolls = 0
    self.sum = 0
end

function DiceStats:roll(rng)
    local v = rng:nextInt(1, self.sides + 1)
    local ____object = self.counts
    ____object[v + 1] = (____object[v + 1] or __K2L_IndexError(v, ____object.size, "array")) + 1
    self.rolls = self.rolls + 1
    self.sum = self.sum + v
end

function DiceStats:mean()
    return (self.sum + 0.0) / self.rolls
end

function DiceStats:chiSquare()
    local expected = (self.rolls + 0.0) / self.sides
    local chi = 0.0
    for face = 1, self.sides do
        local diff = (self.counts[face + 1] or __K2L_IndexError(face, self.counts.size, "array")) - expected
        chi = chi + diff * diff / expected
    end
    return chi
end

function DiceStats:histogram()
    return __K2L_IntRange.new(1, self.sides):joinToString(" ", nil, nil, nil, nil, function(it)
        return it .. ":" .. (self.counts[it + 1] or __K2L_IndexError(it, self.counts.size, "array"))
    end)
end

local function rawSequences()
    print("-- raw sequences")
    local r = __K2L_Random.seeded(42)
    local ____out = {}
    for ____i = 1, 6 do
        local it = ____i - 1
        ____out[____i] = r:nextInt()
    end
    print(__K2L_Str(__K2L_ListWrap(____out, 6)))
    local ____out_1 = {}
    for ____i_1 = 1, 6 do
        local it = ____i_1 - 1
        ____out_1[____i_1] = r:nextInt(100)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, 6)))
    local ____out_2 = {}
    for ____i_2 = 1, 6 do
        local it = ____i_2 - 1
        ____out_2[____i_2] = r:nextInt(-50, 50)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_2, 6)))
    local ____out_3 = {}
    for ____i_3 = 1, 6 do
        local it = ____i_3 - 1
        ____out_3[____i_3] = r:nextInt(((1 << 16) + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_3, 6)))
    local ____out_4 = {}
    for ____i_4 = 1, 4 do
        local it = ____i_4 - 1
        ____out_4[____i_4] = r:nextInt(-2147483648, 2147483647)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_4, 4)))
    local ____out_5 = {}
    for ____i_5 = 1, 4 do
        local it = ____i_5 - 1
        ____out_5[____i_5] = r:nextInt(-2000000000, 2000000000)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_5, 4)))
    local ____out_6 = {}
    for ____i_6 = 1, 6 do
        local it = ____i_6 - 1
        ____out_6[____i_6] = r:nextIntRange(__K2L_IntRange.new(3, 9))
    end
    print(__K2L_Str(__K2L_ListWrap(____out_6, 6)))
    local ____out_7 = {}
    for ____i_7 = 1, 6 do
        local it = ____i_7 - 1
        ____out_7[____i_7] = r:nextBits(5)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_7, 6)))
    local ____out_8 = {}
    for ____i_8 = 1, 3 do
        local it = ____i_8 - 1
        ____out_8[____i_8] = r:nextBits(32)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_8, 3)))
    print(r:nextBits(0))
    local ____out_9 = {}
    for ____i_9 = 1, 8 do
        local it = ____i_9 - 1
        ____out_9[____i_9] = r:nextBoolean()
    end
    print(__K2L_Str(__K2L_ListWrap(____out_9, 8)))
    local ____out_10 = {}
    for ____i_10 = 1, 4 do
        local it = ____i_10 - 1
        ____out_10[____i_10] = string.format("%.12f", r:nextDouble())
    end
    print(__K2L_Str(__K2L_ListWrap(____out_10, 4)))
    local ____out_11 = {}
    for ____i_11 = 1, 3 do
        local it = ____i_11 - 1
        ____out_11[____i_11] = string.format("%.10f", r:nextDouble(10.0))
    end
    print(__K2L_Str(__K2L_ListWrap(____out_11, 3)))
    local ____out_12 = {}
    for ____i_12 = 1, 3 do
        local it = ____i_12 - 1
        ____out_12[____i_12] = string.format("%.10f", r:nextDouble(-1.5, 2.5))
    end
    print(__K2L_Str(__K2L_ListWrap(____out_12, 3)))
    local ____out_13 = {}
    for ____i_13 = 1, 4 do
        local it = ____i_13 - 1
        ____out_13[____i_13] = r:nextFloat()
    end
    print(__K2L_Str(__K2L_ListWrap(____out_13, 4)))
    local ____out_14 = {}
    for ____i_14 = 1, 4 do
        local it = ____i_14 - 1
        ____out_14[____i_14] = r:nextLong(1000)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_14, 4)))
    local ____out_15 = {}
    for ____i_15 = 1, 3 do
        local it = ____i_15 - 1
        ____out_15[____i_15] = r:nextLong(-5, 5)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_15, 3)))
    print(r:nextBytes(__K2L_ListOfSize(7, 0, true)):joinToString(","))
    local buffer = __K2L_ListOfSize(10, 0, true)
    r:nextBytes(buffer, 2, 9)
    print(buffer:joinToString(","))
    r:nextBytes(buffer)
    print(buffer:joinToString(","))
end

local function seeds()
    print("-- seeds")
    local ____list = __K2L_ListOf(0, 1, -1, 7, 123456, -2147483648, 2147483647)
    for ____i_16 = 1, ____list.size do
        local seed = ____list[____i_16]
        local r = __K2L_Random.seeded(seed)
        print(seed .. ": " .. r:nextInt() .. " " .. r:nextInt(10) .. " " .. string.format("%.6f", r:nextDouble()))
    end
    local ____list_1 = __K2L_ListOf(0, 42, -42, 4294967296, 1234567890123, -9007199254740992)
    for ____i_17 = 1, ____list_1.size do
        local seed = ____list_1[____i_17]
        local r = __K2L_Random.seeded(seed)
        print(seed .. "L: " .. r:nextInt() .. " " .. r:nextInt(1000))
    end
    print(__K2L_Random.seeded(5):nextInt() == __K2L_Random.seeded(5):nextInt())
    print(__K2L_Random.seeded(-5):nextInt() == __K2L_Random.seeded(-5):nextInt())
end

local ____lambda_1 = function(it) return it * it end
local function collections()
    print("-- collections")
    local deck = __K2L_IntRange.new(1, 13):flatMap(function(rank)
        local ____list_2 = __K2L_ListOf("S", "H", "D", "C")
        local ____out_16 = {}
        local ____count = 0
        local ____items, ____n = ____list_2:____array()
        for ____i_18 = 1, ____n do
            local it = ____items[____i_18]
            ____count = ____count + 1
            ____out_16[____count] = rank .. it
        end
        return __K2L_ListWrap(____out_16, ____count)
    end)
    local shuffled = deck:shuffled(__K2L_Random.seeded(2024))
    print(__K2L_Str(shuffled:take(10)))
    print(__K2L_Equals(shuffled:sorted(), deck:sorted()))
    local hand = deck:toMutableList()
    hand:shuffle(__K2L_Random.seeded(7))
    print(__K2L_Str(hand:takeLast(5)))
    local array = __K2L_ListOfSize(10, ____lambda_1, true)
    array:shuffle(__K2L_Random.seeded(3))
    print(array:joinToString())
    local boxed = __K2L_ArrayOf("a", "b", "c", "d", "e", "f")
    boxed:shuffle(__K2L_Random.seeded(11))
    print(boxed:joinToString(""))
    local picker = __K2L_Random.seeded(99)
    local ____out_17 = {}
    for ____i_19 = 1, 6 do
        local it = ____i_19 - 1
        ____out_17[____i_19] = deck:random(picker)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_17, 6)))
    local ____out_18 = {}
    for ____i_20 = 1, 5 do
        local it = ____i_20 - 1
        ____out_18[____i_20] = picker:nextIntRange(__K2L_IntRange.new(1, 100), false)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_18, 5)))
    local ____out_19 = {}
    for ____i_21 = 1, 5 do
        local it = ____i_21 - 1
        ____out_19[____i_21] = __K2L_CharRange.new("a", "z"):random(picker)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_19, 5)))
    local ____out_20 = {}
    for ____i_22 = 1, 3 do
        local it = ____i_22 - 1
        ____out_20[____i_22] = __K2L_StringToList("kotlin"):random(picker)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_20, 3)))
    local ____out_21 = {}
    for ____i_23 = 1, 4 do
        local it = ____i_23 - 1
        ____out_21[____i_23] = __K2L_ArrayOf(10, 20, 30):random(picker)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_21, 4)))
    local ____out_22 = {}
    for ____i_24 = 1, 4 do
        local it = ____i_24 - 1
        ____out_22[____i_24] = __K2L_ArrayOf(1, 2, 3, 4, 5):random(picker)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_22, 4)))
    print(__K2L_Str(__K2L_ListOf():randomOrNull(picker)))
    print(__K2L_Str(__K2L_ListOf(9):randomOrNull(picker)))
    print(__K2L_Str(picker:nextIntRange(__K2L_IntRange.new(1, 0), true)))
    local ____ok, ____result = pcall(function()
        picker:nextIntRange(__K2L_IntRange.new(1, 0), false)
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_NoSuchElementException) then
            local e = ____error
            print("empty range: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    local ____ok_1, ____result_1 = pcall(function()
        picker:nextIntRange(__K2L_IntRange.new(5, 4))
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error_1, __K2L_IllegalArgumentException) then
            local e = ____error_1
            print(__K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
    local ____ok_2, ____result_2 = pcall(function()
        picker:nextDouble(2.0, 1.0)
    end)
    if not ____ok_2 then
        local ____error_2 = __K2L_ToThrowable(____result_2)
        if __K2L_InstanceOf(____error_2, __K2L_IllegalArgumentException) then
            local e = ____error_2
            print(__K2L_Str(e.message))
        else
            error(____error_2, 0)
        end
    end
end

local function experiments()
    print("-- experiments")
    local ____list_3 = __K2L_ListOf(__K2L_Pair.new(1, 1000), __K2L_Pair.new(2, 10000), __K2L_Pair.new(3, 50000))
    for ____i_25 = 1, ____list_3.size do
        local ____item = ____list_3[____i_25]
        local seed, samples = ____item.first, ____item.second
        local pi = estimatePi(seed, samples)
        print("pi(" .. seed .. ", " .. samples .. ") = " .. pi .. " error=" .. string.format("%.5f", math.abs(pi - 3.141592653589793)))
    end
    local walker = __K2L_Random.seeded(31337)
    for it = 0, 2 do
        print(__K2L_Str(randomWalk(walker, 500)))
    end
    local d6 = DiceStats.new(6)
    local d20 = DiceStats.new(20)
    local dice = __K2L_Random.seeded(6)
    for it = 0, 5999 do
        d6:roll(dice)
    end
    for it = 0, 3999 do
        d20:roll(dice)
    end
    print(d6:histogram())
    print("d6 mean=" .. string.format("%.4f", d6:mean()) .. " chi2=" .. string.format("%.4f", d6:chiSquare()))
    print("d20 mean=" .. string.format("%.4f", d20:mean()) .. " chi2=" .. string.format("%.4f", d20:chiSquare()))
    local coin = __K2L_Random.seeded(1)
    local streak = 0
    local longest = 0
    for it = 0, 9999 do
        if coin:nextBoolean() then
            streak = streak + 1
            if streak > longest then
                longest = streak
            end
        else
            streak = 0
        end
    end
    print("longest heads streak: " .. longest)
    local birthdays = __K2L_Random.seeded(365)
    local collisions = 0
    for it = 0, 1999 do
        do
            local seen = __K2L_Set.new()
            local hit = false
            for it = 0, 22 do
                if not seen:add(birthdays:nextInt(365)) then
                    hit = true
                end
            end
            if hit then
                collisions = collisions + 1
            end
        end
    end
    print("birthday paradox (23 people): " .. string.format("%.3f", collisions / 2000.0))
end

local function defaults()
    print("-- default")
    local ____out_23 = {}
    for ____i_26 = 1, 200 do
        local it = ____i_26 - 1
        ____out_23[____i_26] = __K2L_Random.default():nextInt(10)
    end
    local values = __K2L_ListWrap(____out_23, 200)
    local ____result_3 = true
    local ____items_1, ____n_1 = values:____array()
    for ____i_27 = 1, ____n_1 do
        local it = ____items_1[____i_27]
        if not (it >= 0 and it <= 9) then
            ____result_3 = false
            break
        end
    end
    print(____result_3)
    local ____value = __K2L_Random.default():nextDouble()
    print(____value >= 0.0 and ____value <= 1.0)
    print(__K2L_Random.default():nextInt(5, 6))
    local ____value_1 = __K2L_Random.default():nextBits(4)
    print(____value_1 >= 0 and ____value_1 <= 15)
    print(__K2L_Random.default():nextBytes(__K2L_ListOfSize(3, 0, true)).size)
    print(__K2L_Random.default():nextFloat() < 1.0)
    print(__K2L_Random.default():nextLong(3, 4))
end

local function main()
    rawSequences()
    seeds()
    collections()
    experiments()
    defaults()
end

__K2L_RunMain(main)
return {estimatePi = estimatePi, Walk = Walk, randomWalk = randomWalk, DiceStats = DiceStats, rawSequences = rawSequences, seeds = seeds, collections = collections, experiments = experiments, defaults = defaults}
