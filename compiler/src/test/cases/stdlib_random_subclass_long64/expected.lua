local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Random = ____lualib.__K2L_Random
local __K2L_RandomBase = ____lualib.__K2L_RandomBase
local __K2L_RandomLong = ____lualib.__K2L_RandomLong
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_Unsigned = ____lualib.__K2L_Unsigned
local __K2L_Ushr = ____lualib.__K2L_Ushr

local Xorshift = __K2L_Class("Xorshift", __K2L_RandomBase)

function Xorshift:____init(x)
    self.x = x
end

function Xorshift:nextBits(bitCount)
    self.x = self.x ~ ((self.x << 13) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
    self.x = self.x ~ (self.x & 0xFFFFFFFF) >> 17
    self.x = self.x ~ ((self.x << 5) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
    return __K2L_Ushr(self.x, (32 - bitCount + 0x80000000 & 0xFFFFFFFF) - 0x80000000) & ((-bitCount + 0x80000000 & 0xFFFFFFFF) - 0x80000000) // 2147483648
end

local IntLcg = __K2L_Class("IntLcg", __K2L_RandomBase)

function IntLcg:____init(state)
    self.state = state
end

function IntLcg:nextBits(bitCount)
    self.state = (self.state * 1103515245 + 12345 + 0x80000000 & 0xFFFFFFFF) - 0x80000000
    return __K2L_Ushr(self.state, (32 - bitCount + 0x80000000 & 0xFFFFFFFF) - 0x80000000) & ((-bitCount + 0x80000000 & 0xFFFFFFFF) - 0x80000000) // 2147483648
end

local function longs(name, rng)
    print(name .. ": " .. rng:nextLong() .. " " .. rng:nextLong() .. " " .. __K2L_RandomLong.nextLong(rng, nil, 9223372036854775807) .. " " .. __K2L_RandomLong.nextLong(rng, -9223372036854775807 - 1, 9223372036854775807))
    print("  " .. __K2L_RandomLong.nextLong(rng, nil, 1 << 62) .. " " .. __K2L_RandomLong.nextLong(rng, nil, 1 << 32) .. " " .. __K2L_RandomLong.nextLong(rng, nil, 1 << 20) .. " " .. __K2L_RandomLong.nextLong(rng, -1000, 1000) .. " " .. __K2L_RandomLong.nextLongIn(rng, __K2L_IntRange.new(-9223372036854775807 - 1, 9223372036854775807)) .. " " .. __K2L_RandomLong.nextLongIn(rng, __K2L_IntRange.new(0, 9223372036854775807)))
    print("  ulong: " .. __K2L_Unsigned.toString(__K2L_RandomLong.nextULong(rng)) .. " " .. __K2L_Unsigned.toString(__K2L_RandomLong.nextULong(rng, nil, 0xffffffffffffffff)) .. " " .. __K2L_Unsigned.toString(__K2L_RandomLong.nextULong(rng, 5, 10)))
    print("  int: " .. rng:nextInt() .. " " .. rng:nextInt(-2147483648, 0) .. " " .. rng:nextInt(((1 << 30) + 0x80000000 & 0xFFFFFFFF) - 0x80000000) .. " " .. __K2L_Str(rng:nextDouble()))
end

local function main()
    longs("xorshift", Xorshift.new(__K2L_ToInt32(2463534242)))
    longs("lcg", IntLcg.new(1))
    local xorwow = __K2L_Random.seeded(2024)
    print("xorwow: " .. xorwow:nextInt(-2147483648, 0) .. " " .. xorwow:nextInt(-1073741824, 1073741824) .. " " .. xorwow:nextInt(-1, 2147483647) .. " " .. xorwow:nextInt(-5, 2147483647))
    longs("xorwow", xorwow)
end

__K2L_Main(main)
return {Xorshift = Xorshift, IntLcg = IntLcg, longs = longs}
