-- requires: Exceptions
-- ULong on Lua 5.3/5.4: a Lua integer holding the 64-bit pattern, so values from 2^63 are negative integers.
local __K2L_Unsigned = {}

do

local ult = math.ult

local function udiv(a, b)
    if b == 0 then
        error(__K2L_ArithmeticException.new("/ by zero"))
    end
    if b < 0 then
        -- the divisor is at least 2^63: the quotient is 0 or 1
        return ult(a, b) and 0 or 1
    end
    if a >= 0 then
        return a // b
    end
    local q = ((a >> 1) // b) << 1
    local r = a - q * b
    if not ult(r, b) then
        q = q + 1
    end
    return q
end

__K2L_Unsigned.udiv = udiv

function __K2L_Unsigned.urem(a, b)
    return a - udiv(a, b) * b
end

function __K2L_Unsigned.compare(a, b)
    if a == b then
        return 0
    end
    return ult(a, b) and -1 or 1
end

function __K2L_Unsigned.toString(a)
    if a >= 0 then
        return tostring(a)
    end
    local q = (a >> 1) // 5
    return tostring(q) .. tostring(a - q * 10)
end

-- ULong.toString(radix)
function __K2L_Unsigned.toRadix(a, radix)
    if radix < 2 or radix > 36 then
        error(__K2L_IllegalArgumentException.new("radix " .. radix .. " was not in valid range 2..36"))
    end
    if a == 0 then
        return "0"
    end
    local digits, out = "0123456789abcdefghijklmnopqrstuvwxyz", {}
    while a ~= 0 do
        local q = udiv(a, radix)
        local d = a - q * radix
        out[#out + 1] = digits:sub(d + 1, d + 1)
        a = q
    end
    return string.reverse(table.concat(out))
end

-- Halving with the lowest bit kept makes the conversion round like a direct one.
function __K2L_Unsigned.toDouble(a)
    if a >= 0 then
        return a + 0.0
    end
    return ((a >> 1) | (a & 1)) * 2.0
end

-- Double.toUInt(): saturating, NaN is 0.
function __K2L_Unsigned.fromDouble32(x)
    if x ~= x or x <= 0 then
        return 0
    elseif x >= 4294967295 then
        return 4294967295
    end
    return math.floor(x)
end

-- Double.toULong()
function __K2L_Unsigned.fromDouble64(x)
    if x ~= x or x <= 0 then
        return 0
    elseif x >= 18446744073709551616.0 then
        return -1
    elseif x < 9223372036854775808.0 then
        return math.floor(x)
    end
    return math.floor(x - 9223372036854775808.0) + math.mininteger
end

end
