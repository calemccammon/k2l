-- requires: Exceptions
-- `valueOf(name)` of an enum class.
local function __K2L_EnumValueOf(cls, name)
    for _, entry in ipairs(cls.____values) do
        if entry.name == name then
            return entry
        end
    end
    -- the message names a nested class `app.Outer.Color`, where its Lua class name is `app.Outer$Color`
    local canonical = cls.____name:gsub("%$", ".")
    error(__K2L_IllegalArgumentException.new("No enum constant " .. canonical .. "." .. tostring(name)))
end
