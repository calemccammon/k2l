-- requires: Exceptions, SimpleName
-- Failed `x as T`: NullPointerException for null, otherwise ClassCastException. `target` is the Kotlin name of T.
local function __K2L_CastFail(value, target)
    if value == nil then
        error(__K2L_NullPointerException.new("null cannot be cast to non-null type " .. target))
    end
    local actual = type(value) == "table" and (getmetatable(value) or {}).____name or "kotlin." .. (__K2L_SimpleName(value) or "Function")
    error(__K2L_ClassCastException.new(actual .. " cannot be cast to " .. target))
end
