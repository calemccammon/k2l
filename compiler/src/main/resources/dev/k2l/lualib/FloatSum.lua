-- requires: Fround
-- sum() of Floats: every partial sum is rounded to single precision, as on the JVM.
local function __K2L_FloatSum(xs)
    return xs:fold(0.0, function(total, x) return __K2L_Fround(total + x) end)
end
