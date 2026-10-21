-- Rounds a double to the nearest IEEE single-precision value (ties to even), as a Kotlin Float operation does. nil stays nil.
-- Without string.pack: scale so that the float quantum is 1, round half to even, scale back.
local __K2L_Fround
do
    local frexp, ldexp, floor, huge = math.frexp, math.ldexp, math.floor, math.huge
    local NEG_ZERO = -1 / huge -- not the literal: Lua 5.1 folds -0.0 into a function's constant 0
    __K2L_Fround = function(x)
        if x == nil then
            return nil
        end
        if x ~= x or x == 0 or x == huge or x == -huge then
            return x
        end
        local _, e = frexp(x)
        -- normal floats have 24 significant bits (x = m * 2^e, 0.5 <= |m| < 1); below 2^-126 the quantum is 2^-149
        local shift = e - 24
        if shift < -149 then
            shift = -149
        end
        local scaled = ldexp(x, -shift)
        local f = floor(scaled)
        local d = scaled - f
        if d > 0.5 or (d == 0.5 and f % 2 == 1) then
            f = f + 1
        end
        local r = ldexp(f, shift)
        if r == 0 then
            return x < 0 and NEG_ZERO or 0.0
        end
        if r >=3.4028236692093846e38 then
            return huge
        elseif r <= -3.4028236692093846e38 then
            return -huge
        end
        return r
    end
end
