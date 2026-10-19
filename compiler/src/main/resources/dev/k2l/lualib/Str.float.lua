-- requires: DoubleToString, IdentityHash
-- Without an integer subtype, an integral number is printed as an Int; the compiler calls
-- __K2L_DoubleToString directly where the static type is Double.
local __K2L_StrHooks = {}
local function __K2L_Str(value)
    if value == nil then
        return "null"
    end
    local t = type(value)
    if t == "number" then
        if value % 1 == 0 and value > -9.3e18 and value < 9.3e18 then
            return string.format("%.0f", value) -- exact, unlike tostring's 14 digits
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
    elseif t == "cdata" then
        -- an int64_t of --long64 emulate
        return (tostring(value):gsub("U?LL$", ""))
    end
    return tostring(value)
end
