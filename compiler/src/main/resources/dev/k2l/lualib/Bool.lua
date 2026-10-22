-- Kotlin's infix `a and b` and `a or b` on Booleans: both operands are evaluated (they are arguments), unlike Lua's.
local function __K2L_BoolAnd(a, b)
    return a and b
end

local function __K2L_BoolOr(a, b)
    return a or b
end
