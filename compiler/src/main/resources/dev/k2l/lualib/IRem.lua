-- requires: Exceptions
-- Kotlin integer remainder (truncating, sign of the dividend); a zero divisor throws.
local function __K2L_IRem(a, b)
    if b == 0 then
        error(__K2L_ArithmeticException.new("/ by zero"))
    end
    return math.fmod(a, b)
end
