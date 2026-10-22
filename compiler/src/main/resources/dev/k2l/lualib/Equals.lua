-- Kotlin `==` for values whose class may override equals(); other values compare with Lua's `==` (NaN differs from
-- itself, 0.0 equals -0.0).
local function __K2L_Equals(a, b)
    if rawequal(a, b) then
        return true
    elseif type(a) == "table" and a.equals ~= nil then
        return a:equals(b)
    end
    return a == b
end
