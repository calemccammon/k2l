-- requires: IdentityHash
-- toString() of any value: "null" for nil, an object's toString(), and Lua's tostring for numbers, booleans and the rest.
local function __K2L_Str(value)
    if value == nil then
        return "null"
    end
    if type(value) == "table" then
        if value.toString then
            return value:toString()
        end
        -- Any.toString() of an object of the program: its class name and hash code in hex, as in `app.Point@1b`
        local cls = rawget(value, "____name") ~= nil and value or getmetatable(value)
        if type(cls) == "table" and rawget(cls, "____name") ~= nil then
            local hash = value.hashCode ~= nil and value:hashCode() or __K2L_IdentityHash(value)
            return cls.____name .. "@" .. string.format("%x", hash % 4294967296)
        end
    end
    return tostring(value)
end
