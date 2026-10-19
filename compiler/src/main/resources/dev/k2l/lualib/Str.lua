-- requires: DoubleToString, IdentityHash
-- floatPrinter is set by FloatToString when the program uses Float: prints numbers that are exactly floats like Float.toString.
local __K2L_StrHooks = {}
local function __K2L_Str(value)
    if value == nil then
        return "null"
    end
    local t = type(value)
    if t == "number" then
        if math.type(value) == "integer" then
            return tostring(value)
        end
        return (__K2L_StrHooks.floatPrinter or __K2L_DoubleToString)(value)
    elseif t == "table" then
        if value.toString then
            return value:toString()
        end
        -- Any.toString() of an object of the program: its JVM class name and hash code in hex, as in `app.Point@1b`
        local cls = rawget(value, "____name") ~= nil and value or getmetatable(value)
        if type(cls) == "table" and rawget(cls, "____name") ~= nil then
            local hash = value.hashCode ~= nil and value:hashCode() or __K2L_IdentityHash(value)
            return cls.____name .. "@" .. string.format("%x", hash % 4294967296)
        end
    end
    return tostring(value)
end
