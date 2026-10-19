local ____lualib = require("lualib_bundle")
local __K2L_BigDecimal = ____lualib.__K2L_BigDecimal
local __K2L_BigInteger = ____lualib.__K2L_BigInteger
local __K2L_DoubleToString = ____lualib.__K2L_DoubleToString
local __K2L_IsNumber = ____lualib.__K2L_IsNumber
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
    print(values:filter(function(x) return __K2L_IsNumber(x) end).size)
    print(__K2L_Str(values:map(function(it)
        local ____receiver = __K2L_IsNumber(it) and it or nil
        return ____receiver and __K2L_NumberTo(__K2L_IsNumber(it) and it or nil, "toInt")
    end)))
    print(values:count(function(it) return not __K2L_IsNumber(it) end))
    local total = values:filter(function(x) return __K2L_IsNumber(x) end):sumOf(function(it) return __K2L_NumberTo(it, "toDouble") end, 0.0)
    print(__K2L_DoubleToString(total))
end

main()
return {describe = describe}
