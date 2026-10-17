-- Kotlin integer division truncates toward zero; Lua's // floors.
local function __K2L_IDiv(a, b)
    local q = a // b
    if q < 0 and q * b ~= a then
        q = q + 1
    end
    return q
end
