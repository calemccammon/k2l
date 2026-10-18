-- requires: Exceptions
-- Kotlin floorDiv: integer division rounding toward negative infinity, which is Lua's //.
local function __K2L_FloorDiv(a, b)
    if b == 0 then
        error(__K2L_ArithmeticException.new("/ by zero"))
    end
    return a // b
end
