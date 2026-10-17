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

local function sign(n)
    if n > 0 then
        return "positive"
    else
        return n < 0 and "negative" or "zero"
    end
end

local function describe(n)
    local parity = math.fmod(n, 2) == 0 and "even" or "odd"
    local size
    if n < 10 then
        size = "small"
    elseif n < 100 then
        size = "medium"
    else
        size = "large"
    end
    return n .. " is " .. parity .. " and " .. size
end

local function bucket(n)
    if n == 0 then
        return 0
    elseif n == 1 or n == 2 or n == 3 then
        return 1
    elseif n >= 4 and n <= 9 then
        return 2
    elseif not (n >= 10 and n <= 99) then
        return 4
    else
        return 3
    end
end

local function isPositive(n)
    if n > 0 then
        return true
    else
        return false
    end
end

local function n0()
    return 1
end

local function maybe(n)
    if n > 0 then
        return nil
    else
        return "nonpositive"
    end
end

local function main()
    print(sign(5))
    print(sign(-5))
    print(sign(0))
    print(describe(7))
    print(describe(42))
    print(describe(1000))
    print(bucket(0))
    print(bucket(2))
    print(bucket(7))
    print(bucket(50))
    print(bucket(500))
    print(isPositive(3))
    print(isPositive(-3))
    print(__K2L_Str(maybe(1)))
    print(__K2L_Str(maybe(-1)))
    local label = "stale"
    if n0() > 0 then
        label = nil
    else
        label = "set"
    end
    print(__K2L_Str(label))
    local n = 15
    local fizz
    if math.fmod(n, 15) == 0 then
        local word = "Fizz"
        fizz = word .. "Buzz"
    elseif math.fmod(n, 3) == 0 then
        fizz = "Fizz"
    else
        fizz = tostring(n)
    end
    print(fizz)
    local count = 0
    if n > 10 then
        count = count + 1
    elseif n > 5 then
        count = count + 2
    else
        count = count + 3
    end
    print(count)
end

main()
return {sign = sign, describe = describe, bucket = bucket, isPositive = isPositive, n0 = n0, maybe = maybe}
