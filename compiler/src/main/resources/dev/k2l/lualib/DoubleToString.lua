-- Kotlin/JVM Double.toString: shortest round-tripping digits, plain notation in [1e-3, 1e7).
local function __K2L_DoubleToString(x)
    if x == nil then
        return "null"
    elseif x ~= x then
        return "NaN"
    elseif x == math.huge then
        return "Infinity"
    elseif x == -math.huge then
        return "-Infinity"
    elseif x == 0 then
        return 1 / x < 0 and "-0.0" or "0.0"
    end
    local s
    if x >= 2.2250738585072014e-308 or x <= -2.2250738585072014e-308 then
        -- a normal double: its shortest digits are those of the first of %.14e, %.15e and %.16e that reads back (see
        -- decimalDigits in Strings.lua)
        s = string.format("%.14e", x)
        if tonumber(s) ~= x then
            s = string.format("%.15e", x)
            if tonumber(s) ~= x then
                s = string.format("%.16e", x)
            end
        end
    else
        for precision = 0, 16 do
            s = string.format("%." .. precision .. "e", x)
            if tonumber(s) == x then
                break
            end
        end
    end
    local sign, int, frac, exp = string.match(s, "^(-?)(%d)%.?(%d*)e([-+]%d+)$")
    exp = tonumber(exp)
    local digits = (int .. frac):gsub("0+$", "")
    if digits == "" then
        digits = "0"
    end
    local ax = math.abs(x)
    if ax == 5e-324 then
        return sign .. "4.9E-324"
    end
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
