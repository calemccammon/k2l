-- requires: DoubleToString
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
    elseif t == "table" and value.toString then
        return value:toString()
    end
    return tostring(value)
end
