-- requires: Str
-- toString of a value whose static type says every number in it is a Double (a List<Double>, a Map<String, Double>):
-- without an integer subtype, __K2L_Str prints an integral number as a Double while this runs (see Str.float.lua; with
-- integers, numbers tell Doubles apart themselves and Str.lua has no such switch).
local function __K2L_StrDoubles(value)
    local set = __K2L_StrHooks.printDoubles
    if set == nil then
        return __K2L_Str(value)
    end
    local was = set(true)
    local ok, result = pcall(__K2L_Str, value)
    set(was)
    if not ok then
        error(result, 0)
    end
    return result
end
