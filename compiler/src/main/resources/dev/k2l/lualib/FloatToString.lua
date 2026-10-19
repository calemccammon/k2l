-- requires: Fround, DoubleToString, Str
-- Kotlin/JVM Float.toString: the shortest digits (at least two) that round-trip as a float, plain notation in [1e-3, 1e7).
local function __K2L_FloatToString(x)
    if x ~= x then
        return "NaN"
    elseif x == math.huge then
        return "Infinity"
    elseif x == -math.huge then
        return "-Infinity"
    elseif x == 0 then
        return 1 / x < 0 and "-0.0" or "0.0"
    end
    local s
    for precision = 1, 8 do
        s = string.format("%." .. precision .. "e", x)
        if __K2L_Fround(tonumber(s)) == x then
            break
        end
    end
    local sign, int, frac, exp = string.match(s, "^(-?)(%d)%.?(%d*)e([-+]%d+)$")
    exp = tonumber(exp)
    local digits = (int .. frac):gsub("0+$", "")
    if digits == "" then
        digits = "0"
    end
    local ax = math.abs(x)
    if ax >= 1e-3 and ax < 1e7 then
        local point = exp + 1
        local whole, fraction
        if point <= 0 then
            whole, fraction = "0", string.rep("0", -point) .. digits
        elseif point >= #digits then
            whole, fraction = digits .. string.rep("0", point - #digits), "0"
        else
            whole, fraction = digits:sub(1, point), digits:sub(point + 1)
        end
        return sign .. whole .. "." .. fraction
    end
    local fraction = digits:sub(2)
    if fraction == "" then
        fraction = "0"
    end
    return sign .. digits:sub(1, 1) .. "." .. fraction .. "E" .. exp
end

-- A Float among Any-typed values (collections, templates of nullable values) is a double like any other. A number
-- that is exactly a float and has a long double representation is printed as a float, so listOf(1f / 3) works.
__K2L_StrHooks.floatPrinter = function(x)
    local text = __K2L_DoubleToString(x)
    if #text > 11 and x == x and __K2L_Fround(x) == x then
        return __K2L_FloatToString(x)
    end
    return text
end
