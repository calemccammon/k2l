local ____lualib = require("lualib_bundle")
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_Random = ____lualib.__K2L_Random
local __K2L_RunMain = ____lualib.__K2L_RunMain

local function main()
    local ____value = __K2L_Random.default():nextIntRange(__K2L_IntRange.new(1, 6))
    print(____value >= 1 and ____value <= 6)
    print(__K2L_Random.default():nextIntRange(__K2L_IntRange.new(5, 6 - 1)))
    print(__K2L_Random.default():nextIntRange(__K2L_IntRange.new(3, 3)))
    local ____value_1 = __K2L_Random.default():nextLongRange(__K2L_IntRange.new(10, 20))
    print(____value_1 >= 10 and ____value_1 <= 20)
    print(__K2L_Random.default():nextLongRange(__K2L_IntRange.new(7, 7)))
    local seeded = __K2L_Random.seeded(42)
    local again = __K2L_Random.seeded(42)
    print(seeded:nextIntRange(__K2L_IntRange.new(0, 1000)) == again:nextIntRange(__K2L_IntRange.new(0, 1000)))
end

__K2L_RunMain(main)
