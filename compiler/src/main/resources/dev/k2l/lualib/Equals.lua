-- Kotlin `==` for values whose class may override equals(). Numbers compare as boxes do (Double.equals): NaN equals NaN,
-- 0.0 and -0.0 differ (an Int is never -0, so only Doubles get there).
local function __K2L_Equals(a, b)
    if rawequal(a, b) then
        return a ~= 0 or 1 / a == 1 / b
    elseif type(a) == "table" and a.equals ~= nil then
        return a:equals(b)
    end
    return a == b or (a ~= a and b ~= b)
end

-- Double.equals of two Doubles (or Floats, or nulls), as a data class compares its Double properties (Double.compare).
local function __K2L_DoubleEquals(a, b)
    if a == b then
        return a ~= 0 or 1 / a == 1 / b
    end
    return a ~= a and b ~= b
end
