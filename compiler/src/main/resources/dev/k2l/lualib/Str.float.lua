-- requires: DoubleToString
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
    elseif t == "table" and value.toString then
        return value:toString()
    end
    return tostring(value)
end
