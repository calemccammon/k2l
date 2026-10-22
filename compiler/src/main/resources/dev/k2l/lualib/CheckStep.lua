-- requires: Exceptions
-- `range step s` throws unless the step is positive; returns the step.
local function __K2L_CheckStep(step)
    if step <= 0 then
        error(__K2L_IllegalArgumentException.new("Step must be positive, was: " .. string.format("%d", step) .. "."))
    end
    return step
end
