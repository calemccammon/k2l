local ____lualib = require("lualib_bundle")
local __K2L_ArithmeticException = ____lualib.__K2L_ArithmeticException
local __K2L_BigDecimal = ____lualib.__K2L_BigDecimal
local __K2L_BigInteger = ____lualib.__K2L_BigInteger
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_JavaRandom = ____lualib.__K2L_JavaRandom
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MathContext = ____lualib.__K2L_MathContext
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_RoundingMode = ____lualib.__K2L_RoundingMode
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function root(value, mc)
    local ____ok, ____result, ____returned = pcall(function()
        return true, __K2L_BigDecimal.parse(value):sqrt(mc):toString()
    end)
    if ____ok then
        if ____result then
            return ____returned
        end
    else
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_ArithmeticException) then
            local e = ____error
            return "ArithmeticException: " .. __K2L_Str(e.message)
        else
            error(____error, 0)
        end
    end
end

local function main()
    local values = __K2L_ReadOnlyListOf("2", "3", "4", "5", "7", "10", "16", "99", "0.5", "0.1", "0.01", "0.25", "0.0016", "100", "1E+4", "1E-4", "1E+3", "1E+2", "2.000", "2.25000000", "6.25", "25.00", "1.00", "9.999999", "123456789", "0.000123", "1.5E-7", "1234.5678", "4E+2", "12345678901234567890123.456", "1E+100", "1E-99", "0", "0.00", "0E+4", "15241578750190521", "1.4142135623730950488", "0.0000000001", "1000000", "999999999999999999999999")
    local precisions = __K2L_ReadOnlyListOf(1, 2, 3, 7, 15, 16, 20, 34)
    local ____list = __K2L_ReadOnlyListOf(__K2L_RoundingMode.HALF_UP, __K2L_RoundingMode.HALF_EVEN, __K2L_RoundingMode.DOWN, __K2L_RoundingMode.UP)
    for ____i_1 = 1, ____list.size do
        local mode = ____list[____i_1]
        print("== " .. __K2L_Str(mode))
        local ____mod = values.____modCount
        for ____i = 1, values.size do
            local value = values[____i]
            print(value .. ": " .. precisions:joinToString(" | ", nil, nil, nil, nil, function(it)
                return root(value, __K2L_MathContext.new(it, mode))
            end))
            if values.____modCount ~= ____mod and values:____comodified(____i) then
                break
            end
        end
    end
    print("== other modes")
    local ____list_1 = __K2L_ReadOnlyListOf("2", "3", "0.5", "1E+3", "25.00", "10")
    for ____i_3 = 1, ____list_1.size do
        local value = ____list_1[____i_3]
        local ____list_2 = __K2L_ReadOnlyListOf(__K2L_RoundingMode.HALF_DOWN, __K2L_RoundingMode.FLOOR, __K2L_RoundingMode.CEILING)
        for ____i_2 = 1, ____list_2.size do
            local mode = ____list_2[____i_2]
            print(value .. " " .. __K2L_Str(mode) .. ": " .. __K2L_ReadOnlyListOf(1, 5, 12):joinToString(" | ", nil, nil, nil, nil, function(it)
                return root(value, __K2L_MathContext.new(it, mode))
            end))
        end
    end
    print("== exact")
    local ____mod_1 = values.____modCount
    for ____i_4 = 1, values.size do
        local value = values[____i_4]
        print(value .. ": " .. root(value, __K2L_MathContext.UNLIMITED) .. " | " .. root(value, __K2L_MathContext.new(40, __K2L_RoundingMode.UNNECESSARY)) .. " | " .. root(value, __K2L_MathContext.new(2, __K2L_RoundingMode.UNNECESSARY)))
        if values.____modCount ~= ____mod_1 and values:____comodified(____i_4) then
            break
        end
    end
    print("== defaults")
    print(__K2L_Str(__K2L_BigDecimal.parse("2"):sqrt(__K2L_MathContext.DECIMAL128)))
    print(__K2L_Str(__K2L_BigDecimal.parse("2"):sqrt(__K2L_MathContext.DECIMAL64)))
    print(__K2L_Str(__K2L_BigDecimal.parse("2"):sqrt(__K2L_MathContext.DECIMAL32)))
    print(__K2L_Str(__K2L_BigDecimal.parse("144"):sqrt(__K2L_MathContext.DECIMAL32)))
    print(__K2L_Str(__K2L_BigDecimal.parse("0.0002"):sqrt(__K2L_MathContext.DECIMAL64)))
    print(__K2L_Str(__K2L_BigDecimal.fromDouble(2.0):sqrt(__K2L_MathContext.new(30))))
    print(root("-4", __K2L_MathContext.DECIMAL64))
    print(root("-0.0001", __K2L_MathContext.UNLIMITED))
    print("== random")
    local random = __K2L_JavaRandom.new(20240607)
    local ____list_3 = __K2L_RoundingMode.values()
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list_3:____array()
    for ____i_5 = 1, ____n do
        local it = ____items[____i_5]
        if it ~= __K2L_RoundingMode.UNNECESSARY then
            ____count = ____count + 1
            ____out[____count] = it
        end
    end
    local modes = __K2L_ListWrap(____out, ____count)
    for it = 0, 249 do
        do
            local digits = 1 + random:nextInt(30)
            local unscaled = __K2L_StringBuilder.new()
            for it = 0, digits - 1 do
                unscaled:append(tostring(random:nextInt(10)))
            end
            if random:nextInt(4) == 0 then
                unscaled:append(__K2L_Text.repeatCount("0", random:nextInt(6)))
            end
            local value = __K2L_BigDecimal.fromBigInteger(__K2L_BigInteger.parse(unscaled:toString()), random:nextInt(40) - 8)
            local mc = __K2L_MathContext.new(random:nextInt(40), modes:get(random:nextInt(modes.size)))
            print(__K2L_Str(value) .. " " .. __K2L_Str(mc) .. ": " .. root(value:toString(), mc))
        end
    end
end

main()
return {root = root}
