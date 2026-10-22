local ____lualib = require("lualib_bundle")
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Truncate = ____lualib.__K2L_Truncate

local function main()
    local a = 17
    local b = 5
    print(a + b)
    print(a - b)
    print(a * b)
    print(a // b)
    print(a % b)
    print(-a // b)
    print(-a % b)
    print(a // -b)
    print(a % -b)
    local x = 7.5
    local y = 2.0
    print(x + y)
    print(x / y)
    print(x % y)
    print(x * a)
    print(a / y)
    print(1.0 / 3)
    print(1.0E10)
    print(1.0E-4)
    print(1.0 / 0.0)
    print(-(1.0 / 0.0))
    print(0.0 / 0.0)
    print(a > b and b > 0)
    print(a < b or b ~= 5)
    print(a ~= b)
    print(2 - -3)
    print(-(-a))
    print(math.max(3, 9))
    print(math.min(2.5, 1.5))
    print(math.sqrt(16.0))
    print(math.abs(-4))
    print(math.floor(2.7))
    print(__K2L_Truncate(x))
    print(__K2L_Truncate(-x))
    print(a + 0.0)
    print(3000000000)
    print(2147483647)
end

__K2L_RunMain(main)
