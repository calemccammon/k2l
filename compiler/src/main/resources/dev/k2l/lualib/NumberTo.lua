-- requires: DoubleToInt, DoubleToLong, Fround, ToInt32, Numbers
-- `Number.toInt()`, `toDouble()`, ... of a value whose static type is `Number`: a Lua number converts like the Int, Long or
-- Double it is (an integral float before Lua 5.3 like an Int), a BigInteger or BigDecimal calls its own method.
local isInteger = math.type and function(x)
    return math.type(x) == "integer"
end or function(x)
    return x % 1 == 0
end

local function __K2L_NumberTo(x, conversion)
    if type(x) ~= "number" then
        return x[conversion](x)
    end
    if conversion == "toDouble" then
        return x + 0.0
    elseif conversion == "toFloat" then
        return __K2L_Fround(x)
    end
    local integer = isInteger(x)
    if conversion == "toLong" then
        return integer and x or __K2L_DoubleToLong(x)
    end
    local int = integer and __K2L_ToInt32(x) or __K2L_DoubleToInt(x)
    if conversion == "toShort" then
        return __K2L_Num.toShort(int)
    elseif conversion == "toByte" then
        return __K2L_Num.toByte(int)
    end
    return int
end
