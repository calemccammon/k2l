-- Kotlin `is` for classes, objects and interfaces.
local function __K2L_InstanceOf(value, cls)
    if type(value) ~= "table" then
        return false
    end
    local c = rawget(value, "____name") ~= nil and value or getmetatable(value)
    while c ~= nil do
        if c == cls or rawget(c, "____interfaces")[cls] then
            return true
        end
        c = rawget(c, "____super")
    end
    return false
end
