-- requires: ToInt32, IdentityHash
-- Kotlin/JVM hashCode() for primitives and strings; objects use their own hashCode().
local function __K2L_Hash(value)
    local t = type(value)
    if value == nil then
        return 0
    elseif t == "boolean" then
        return value and 1231 or 1237
    elseif t == "number" then
        if value % 1 == 0 and value >= -2147483648 and value <= 2147483647 then
            return value
        end
        return __K2L_Hash(string.format("%.17g", value))
    elseif t == "string" then
        local h = 0
        for i = 1, #value do
            h = (31 * h + value:byte(i)) % 4294967296
        end
        return __K2L_ToInt32(h)
    elseif t == "table" and value.hashCode ~= nil then
        return value:hashCode()
    end
    return __K2L_IdentityHash(value)
end
