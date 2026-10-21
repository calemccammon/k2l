local ____lualib = require("lualib_bundle")
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_CharRange = ____lualib.__K2L_CharRange
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_DoubleToString = ____lualib.__K2L_DoubleToString
local __K2L_FloatToString = ____lualib.__K2L_FloatToString
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_RandomBase = ____lualib.__K2L_RandomBase
local __K2L_RandomLong = ____lualib.__K2L_RandomLong
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf

local Lcg = __K2L_Class("Lcg", __K2L_RandomBase)

function Lcg:____init(seed)
    self.state = seed & 4294967295
    self.draws = 0
end

function Lcg:nextBits(bitCount)
    self.draws = self.draws + 1
    self.state = self.state * 69069 + 1 & 4294967295
    return __K2L_ToInt32(self.state >> 32 - bitCount)
end

function Lcg:dice()
    return self:nextInt(1, 7)
end

function Lcg:coin()
    return self:nextBoolean() and "heads" or "tails"
end

local Loaded = __K2L_Class("Loaded", Lcg)

function Loaded:____init(seed)
    Lcg.____init(self, seed)
end

function Loaded:nextBoolean()
    return true
end

local function show(name, rng)
    print(name .. ": " .. rng:nextInt() .. " " .. rng:nextInt(10) .. " " .. rng:nextInt(1000) .. " " .. rng:nextInt(-5, 5) .. " " .. rng:nextInt(16))
    print("  ranges: " .. rng:nextIntRange(__K2L_IntRange.new(1, 6)) .. " " .. rng:nextInt(-2147483648, 0) .. " " .. rng:nextInt(-2147483648, 2147483647) .. " " .. rng:nextIntRange(__K2L_IntRange.new(-2147483648, 2147483647)) .. " " .. rng:nextInt(0, 1) .. " " .. rng:nextInt(-100, 2147483647))
    print("  doubles: " .. __K2L_DoubleToString(rng:nextDouble()) .. " " .. __K2L_DoubleToString(rng:nextDouble(10.0)) .. " " .. __K2L_DoubleToString(rng:nextDouble(-1.0, 1.0)) .. " " .. __K2L_DoubleToString(rng:nextDouble(-1.7976931348623157E308, 1.7976931348623157E308)))
    print("  floats: " .. __K2L_FloatToString(rng:nextFloat()) .. " " .. __K2L_FloatToString(rng:nextFloat()) .. " booleans: " .. tostring(rng:nextBoolean()) .. " " .. tostring(rng:nextBoolean()) .. " " .. tostring(rng:nextBoolean()))
    print("  longs: " .. __K2L_RandomLong.nextLong(rng, nil, 1000) .. " " .. __K2L_RandomLong.nextLong(rng, -5, 5) .. " " .. __K2L_RandomLong.nextLong(rng, nil, 1 << 40) .. " " .. __K2L_RandomLong.nextLong(rng, nil, 1 << 32) .. " " .. __K2L_RandomLong.nextLong(rng, nil, 3 << 33) .. " " .. __K2L_RandomLong.nextLongIn(rng, __K2L_IntRange.new(10, 20)))
    print("  bytes: " .. __K2L_Str(rng:nextBytes(__K2L_ListOfSize(7, 0, "[B")):toList()) .. " " .. __K2L_Str(rng:nextBytes(__K2L_ListOfSize(8, 0, "[B"), 1, 6):toList()) .. " " .. rng:nextBytes(__K2L_ListOfSize(0, 0, "[B")).size)
    print("  unsigned: " .. __K2L_RandomLong.nextUInt(rng) .. " " .. __K2L_RandomLong.nextUInt(rng, nil, 10) .. " " .. __K2L_RandomLong.nextUInt(rng, 5, 50))
    print("  bits: " .. rng:nextBits(0) .. " " .. rng:nextBits(1) .. " " .. rng:nextBits(31))
end

local function main()
    local lcg = Lcg.new(42)
    show("lcg", lcg)
    print("draws: " .. lcg.draws)
    local ____out = {}
    for ____i = 1, 10 do
        local it = ____i - 1
        ____out[____i] = lcg:dice()
    end
    print("dice: " .. __K2L_Str(__K2L_ListWrap(____out, 10)) .. " " .. lcg:coin() .. " " .. lcg:coin())
    local rng = Lcg.new(7)
    print("shuffled: " .. __K2L_Str(__K2L_IntRange.new(1, 10):toList():shuffled(rng)))
    local list = __K2L_ListOf("a", "b", "c", "d", "e")
    list:shuffle(rng)
    print("shuffle: " .. __K2L_Str(list))
    print("random: " .. __K2L_ReadOnlyListOf(10, 20, 30):random(rng) .. " " .. rng:nextIntRange(__K2L_IntRange.new(1, 100), false) .. " " .. __K2L_RandomLong.nextLongIn(rng, __K2L_IntRange.new(1, 100), false) .. " " .. __K2L_StringToList("xyz"):random(rng) .. " " .. __K2L_DoubleToString(__K2L_TypedArrayOf("[Ljava.lang.Double;", 1.5, 2.5):random(rng)) .. " " .. __K2L_TypedArrayOf("[I", 4, 5, 6):random(rng) .. " " .. __K2L_CharRange.new("a", "z"):random(rng) .. " " .. __K2L_Str(__K2L_ReadOnlyListOf():randomOrNull(rng)))
    print("sequence: " .. __K2L_Str(__K2L_AsSequence(__K2L_IntRange.new(1, 8)):shuffled(rng):toList()))
    local array = __K2L_TypedArrayOf("[I", 1, 2, 3, 4, 5, 6)
    array:shuffle(rng)
    print("array shuffle: " .. __K2L_Str(array:toList()))
    local loaded = Loaded.new(3)
    print("loaded: " .. loaded:coin() .. " " .. tostring(loaded:nextBoolean()) .. " " .. loaded:nextInt(100) .. " " .. loaded:dice())
    local s = 12345
    local ____object = __K2L_Class("MainKt$main$anonymous$1", __K2L_RandomBase)
    function ____object:nextBits(bitCount)
        local ____dividend = s * 1103 + 12345
        s = ____dividend >= 0 and ____dividend % 2147483648 or (____dividend % 2147483648 - 2147483648) % (-2147483648)
        return __K2L_ToInt32(s << 1 >> 32 - bitCount)
    end
    local anonymous = ____object
    show("anonymous", anonymous)
    local ____ok, ____result = __K2L_DeepPcall(function()
        anonymous:nextInt(5, 5)
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
            local e = ____error
            print(__K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    local ____ok_1, ____result_1 = __K2L_DeepPcall(function()
        anonymous:nextIntRange(__K2L_IntRange.new(1, 0))
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
    local asRandom = Lcg.new(99)
    print("as Random: " .. asRandom:nextInt(50) .. " " .. asRandom:nextBits(8))
end

__K2L_DeepMain(main)
return {Lcg = Lcg, Loaded = Loaded, show = show}
