-- requires: Exceptions
-- Kotlin integer remainder (truncating, sign of the dividend); a zero divisor throws. LuaJIT compiles % but not
-- math.fmod, so the floored % is moved to the dividend's sign, which is exact while both operands are below 2^52;
-- larger ones use fmod (+ 0 turns its -0 into 0).
local fmod = math.fmod
local LIM = 4503599627370496

local function __K2L_IRem(a, b)
    if b == 0 then
        error(__K2L_ArithmeticException.new("/ by zero"))
    end
    if a < LIM and a > -LIM and b < LIM and b > -LIM then
        local r = a % b
        if r ~= 0 and (r < 0) ~= (a < 0) then
            return r - b
        end
        return r
    end
    return fmod(a, b) + 0
end
