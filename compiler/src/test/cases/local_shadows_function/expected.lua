local ____lualib = require("lualib_bundle")
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str

local function nullable(x)
    return x > 0 and x or nil
end

local function total(xs)
    return xs:sum()
end

local label = "top"

local function label__1(n)
    return "label " .. n
end

local ____lambda_1 = function(____total_1)
    return total(__K2L_ReadOnlyListOf(____total_1, 1))
end
local function main()
    local ____nullable = nullable(3)
    print(__K2L_Str(____nullable))
    print(__K2L_Str(nullable(-1)))
    local ____total = total(__K2L_ReadOnlyListOf(1, 2))
    print(____total + total(__K2L_SingletonListOf(3)))
    local f = ____lambda_1
    print(f(4))
    local label = label__1(1)
    print(label .. " " .. label__1(2))
    for ____total_2 = 1, 2 do
        print(total(__K2L_SingletonListOf(____total_2)))
    end
end

main()
return {nullable = nullable, total = total, label = label, label__1 = label__1}
