-- Kotlin/JVM Double.toString: shortest round-tripping digits, plain notation in [1e-3, 1e7).
local function __K2L_DoubleToString(x)
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
    for precision = 0, 16 do
        s = string.format("%." .. precision .. "e", x)
        if tonumber(s) == x then
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

local function __K2L_Str(value)
    if value == nil then
        return "null"
    end
    local t = type(value)
    if t == "number" then
        if math.type(value) == "integer" then
            return tostring(value)
        end
        return __K2L_DoubleToString(value)
    elseif t == "table" and value.toString then
        return value:toString()
    end
    return tostring(value)
end

local function main()
    local name = "Kotlin"
    local version = 2
    local ratio = 0.5
    local ok = true
    local missing = nil
    print("Hello, " .. name .. " " .. version .. "!")
    print("ratio=" .. __K2L_Str(ratio) .. " ok=" .. tostring(ok) .. " missing=" .. __K2L_Str(missing))
    print("expr: " .. version * 10 + 1 .. " " .. #name)
    print(tostring(version))
    print(name:upper() .. " " .. name:lower())
    print(("ab"):rep(3))
    print("quotes \"inside\" and \\backslash\\ and tab\tend")
    print("dollar $name")
    print("unicode: héllo ✓")
    print(#"" == 0)
    print(name .. version)
    print(name .. __K2L_Str(ratio))
    local c = "x"
    print("char " .. c)
    local s = "a"
    s = s .. "b"
    s = s .. 1
    print(s)
    print(tostring(version) .. __K2L_Str(ratio))
end

main()
