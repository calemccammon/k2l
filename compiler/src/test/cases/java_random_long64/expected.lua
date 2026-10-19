local ____lualib = require("lualib_bundle")
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_JavaRandom = ____lualib.__K2L_JavaRandom
local __K2L_Str = ____lualib.__K2L_Str

local function main()
    local r = __K2L_JavaRandom.new(42)
    print(__K2L_Str(__K2L_IntRange.new(1, 5):map(function(it) return r:nextLong() end)))
    local s = __K2L_JavaRandom.new(-1)
    print(s:nextLong())
    print(math.fmod(s:nextLong(), 1000))
    print(__K2L_JavaRandom.new(1234567890123456789):nextInt(100))
end

main()
