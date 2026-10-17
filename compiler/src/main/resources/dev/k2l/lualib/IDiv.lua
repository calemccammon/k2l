-- requires: Exceptions
-- Kotlin integer division truncates toward zero; Lua's // floors.
local function __K2L_IDiv(a, b)
    if b == 0 then
        error(__K2L_ArithmeticException.new("/ by zero"))
    end
    local q = a // b
    if q < 0 and q * b ~= a then
        q = q + 1
    end
    return q
end
