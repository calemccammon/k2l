-- requires: Exceptions
-- Kotlin integer remainder (truncating, sign of the dividend); a zero divisor throws.
-- fmod(-4, 2) is -0 with floating-point numbers; adding 0 makes it 0.
local function __K2L_IRem(a, b)
    if b == 0 then
        error(__K2L_ArithmeticException.new("/ by zero"))
    end
    return math.fmod(a, b) + 0
end
