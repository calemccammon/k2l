-- requires: Exceptions
-- Kotlin integer remainder (truncating, sign of the dividend); a zero divisor throws. The floored % (exact on
-- integers) is moved to the dividend's sign, which saves the math.fmod call.
local function __K2L_IRem(a, b)
    if b == 0 then
        error(__K2L_ArithmeticException.new("/ by zero"))
    end
    local r = a % b
    if r ~= 0 and (r < 0) ~= (a < 0) then
        return r - b
    end
    return r
end
