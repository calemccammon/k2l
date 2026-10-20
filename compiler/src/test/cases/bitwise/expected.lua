local ____lualib = require("lualib_bundle")
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf

local ____lambda_1 = function(acc, f) return acc | f end
local function main()
    local a = 12
    local b = 10
    print(a & b)
    print(a | b)
    print(a ~ b)
    print(~a)
    print(((1 << 4) + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print(-16 // 4)
    print((-16 & 0xFFFFFFFF) >> 28)
    print(-1 & 255)
    print(((2147483647 << 1) + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    local flags = __K2L_ReadOnlyListOf(1, 2, 4, 8)
    print(flags:fold(0, ____lambda_1))
    print(5 & 1 == 1)
end

main()
