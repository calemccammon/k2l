local ____lualib = require("lualib_bundle")
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Str = ____lualib.__K2L_Str

local function sign(n)
    if n > 0 then
        return "positive"
    else
        return n < 0 and "negative" or "zero"
    end
end

local function describe(n)
    local parity = (n >= 0 and n % 2 or 0 - -n % 2) == 0 and "even" or "odd"
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
    if (n >= 0 and n % 15 or 0 - -n % 15) == 0 then
        local word = "Fizz"
        fizz = word .. "Buzz"
    elseif (n >= 0 and n % 3 or 0 - -n % 3) == 0 then
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

__K2L_Main(main)
return {sign = sign, describe = describe, bucket = bucket, isPositive = isPositive, n0 = n0, maybe = maybe}
