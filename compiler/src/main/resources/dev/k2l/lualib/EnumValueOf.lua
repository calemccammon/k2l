-- requires: Exceptions
-- `valueOf(name)` of an enum class.
local function __K2L_EnumValueOf(cls, name)
    for _, entry in ipairs(cls.____values) do
        if entry.name == name then
            return entry
        end
    end
    error(__K2L_IllegalArgumentException.new("No enum constant " .. cls.____name .. "." .. tostring(name)))
end
