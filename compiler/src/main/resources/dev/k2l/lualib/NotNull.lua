-- requires: Exceptions
local function __K2L_NotNull(value)
    if value == nil then
        error(__K2L_NullPointerException.new())
    end
    return value
end
