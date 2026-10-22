-- A null passed for a parameter whose default is not null (`copy(name = null)`): nil would select the default, so the
-- caller passes this marker instead, and the function turns it back into nil after its defaults (see CallArguments.kt).
local __K2L_NULL_ARGUMENT = setmetatable({}, {
    __tostring = function()
        return "null"
    end,
})

-- A nullable argument for such a parameter: the marker when it is null.
local function __K2L_NullArgument(value)
    if value == nil then
        return __K2L_NULL_ARGUMENT
    end
    return value
end
