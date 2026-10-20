-- requires: Exceptions
-- Kotlin integer division truncates toward zero.
local floor, ceil = math.floor, math.ceil

local function __K2L_IDiv(a, b)
    if b == 0 then
        error(__K2L_ArithmeticException.new("/ by zero"))
    end
    local q = a / b
    return q >= 0 and floor(q) or ceil(q)
end
