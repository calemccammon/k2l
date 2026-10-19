-- requires: Exceptions
-- `range step s` throws unless the step is positive; returns the step. A Long box (--long64 emulate, |step| >= 2^53) is
-- not checked: Lua 5.1 cannot compare it with a number.
local function __K2L_CheckStep(step)
    if type(step) == "number" and step <= 0 then
        error(__K2L_IllegalArgumentException.new("Step must be positive, was: " .. string.format("%d", step) .. "."))
    end
    return step
end
