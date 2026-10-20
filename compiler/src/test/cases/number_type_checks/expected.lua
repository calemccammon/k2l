local ____lualib = require("lualib_bundle")
local __K2L_BigDecimal = ____lualib.__K2L_BigDecimal
local __K2L_BigInteger = ____lualib.__K2L_BigInteger
local __K2L_DoubleToString = ____lualib.__K2L_DoubleToString
local __K2L_IsNumber = ____lualib.__K2L_IsNumber
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_NumberTo = ____lualib.__K2L_NumberTo
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str

local function describe(x)
    if x == nil then
        return "null"
    elseif __K2L_IsNumber(x) then
        return "number " .. __K2L_DoubleToString(__K2L_NumberTo(x, "toDouble"))
    elseif type(x) == "string" then
        return "text '" .. x .. "'"
    else
        return "other " .. __K2L_Str(x)
    end
end

local ____lambda_1 = function(x) return __K2L_IsNumber(x) end
local ____lambda_2 = function(x) return __K2L_IsNumber(x) end
local function main()
    local values = __K2L_ReadOnlyListOf(1, 2.5, "3", 4, nil, __K2L_BigInteger.TEN, __K2L_BigDecimal.parse("1.5"), __K2L_SingletonListOf(1), true, 3.0)
    local ____mod = values.____modCount
    for ____i = 1, values.size do
        local it = values[____i]
        print(describe(it))
        if values.____modCount ~= ____mod and values:____comodified(____i) then
            break
        end
    end
    print(values:filter(____lambda_1).size)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = values:____array()
    for ____i_1 = 1, ____n do
        local it = ____items[____i_1]
        local ____result
        do
            local ____receiver = __K2L_IsNumber(it) and it or nil
            ____result = ____receiver and __K2L_NumberTo(__K2L_IsNumber(it) and it or nil, "toInt")
        end
        ____count = ____count + 1
        ____out[____count] = ____result
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    local ____result_1 = 0
    local ____items_1, ____n_1 = values:____array()
    for ____i_2 = 1, ____n_1 do
        local it = ____items_1[____i_2]
        if not __K2L_IsNumber(it) then
            ____result_1 = ____result_1 + 1
        end
    end
    print(____result_1)
    local ____list = values:filter(____lambda_2)
    local ____sum = 0.0
    local ____items_2, ____n_2 = ____list:____array()
    for ____i_3 = 1, ____n_2 do
        local it = ____items_2[____i_3]
        ____sum = ____sum + __K2L_NumberTo(it, "toDouble")
    end
    local total = ____sum
    print(__K2L_DoubleToString(total))
end

main()
return {describe = describe}
