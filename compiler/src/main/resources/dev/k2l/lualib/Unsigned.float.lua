-- requires: Exceptions
-- ULong without 64-bit integers: a double, exact only up to 2^53.
local __K2L_Unsigned = {}

do

function __K2L_Unsigned.udiv(a, b)
    if b == 0 then
        error(__K2L_ArithmeticException.new("/ by zero"))
    end
    return math.floor(a / b)
end

function __K2L_Unsigned.urem(a, b)
    if b == 0 then
        error(__K2L_ArithmeticException.new("/ by zero"))
    end
    return math.fmod(a, b) + 0
end

function __K2L_Unsigned.compare(a, b)
    if a == b then
        return 0
    end
    return a < b and -1 or 1
end

function __K2L_Unsigned.toString(a)
    return string.format("%.0f", a)
end

function __K2L_Unsigned.toDouble(a)
    return a + 0.0
end

function __K2L_Unsigned.fromDouble32(x)
    if x ~= x or x <= 0 then
        return 0
    elseif x >= 4294967295 then
        return 4294967295
    end
    return math.floor(x)
end

function __K2L_Unsigned.fromDouble64(x)
    if x ~= x or x <= 0 then
        return 0
    elseif x >= 18446744073709551616.0 then
        return 18446744073709551616.0
    end
    return math.floor(x)
end

end
