local ____lualib = require("lualib_bundle")
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IRem = ____lualib.__K2L_IRem
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf

local function divide(a, b)
    return (__K2L_IDiv(a, b) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

local function firstBig(xs)
    local ____sum = 0
    for _, it in ipairs(xs) do
        local ____result
        if it < 0 then
            return -1
        else
            ____result = it
        end
        ____sum = ____sum + ____result
    end
    ____sum = (____sum + 0x80000000 & 0xFFFFFFFF) - 0x80000000
    local total = ____sum
    return total
end

local function main()
    local min = -2147483648
    local minusOne = -1
    print((__K2L_IDiv(min, minusOne) + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print(divide(-2147483648, -1))
    print(divide(7, -2))
    print(__K2L_IRem(min, minusOne))
    print(__K2L_IRem(min, minusOne))
    print((__K2L_IDiv(min, minusOne) + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print((math.abs(min) + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print((math.abs(min) + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print((math.abs(min) + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print((math.abs(-5) + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print((2147483647 + 1 + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print((-2147483648 - 1 + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    local n = 2147483647
    n = (n + 1 + 0x80000000 & 0xFFFFFFFF) - 0x80000000
    print(n)
    local big = __K2L_ReadOnlyListOf(2147483647, 1, 2147483647, 5)
    print((big:sum() + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    local ____sum_1 = 0
    local ____items, ____n = big:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____sum_1 = ____sum_1 + it
    end
    ____sum_1 = (____sum_1 + 0x80000000 & 0xFFFFFFFF) - 0x80000000
    print(____sum_1)
    local ____sum_2 = 0
    local ____items_1, ____n_1 = big:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        ____sum_2 = ____sum_2 + ((it * 2 + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    end
    ____sum_2 = (____sum_2 + 0x80000000 & 0xFFFFFFFF) - 0x80000000
    print(____sum_2)
    print((__K2L_AsSequence(big):sum() + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print((__K2L_TypedArrayOf("[Ljava.lang.Integer;", 2147483647, 2147483647):sum() + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print((__K2L_TypedArrayOf("[I", 2147483647, 2):sum() + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print(firstBig(big))
    local ____sum_3 = 0
    local ____items_2, ____n_2 = big:____array()
    for ____i_2 = 1, ____n_2 do
        local it = ____items_2[____i_2]
        ____sum_3 = ____sum_3 + it
    end
    print(____sum_3)
    print((__K2L_ReadOnlyListOf(1, 2, 3):sum() + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print(__K2L_Str(__K2L_ReadOnlyListOf(1.5, 2.5):sum(0.0)))
    local h = 0
    for ____i_3 = 1, #"hello world, this is a long string" do
        local c = ("hello world, this is a long string"):sub(____i_3, ____i_3)
        h = (31 * h + c:byte() + 0x80000000 & 0xFFFFFFFF) - 0x80000000
    end
    print(h)
    print((-min + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print((min - 1 + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
end

main()
return {divide = divide, firstBig = firstBig}
