local isOdd
local greeting = "Hi"
local counter = 0

local function isEven(n)
    if n == 0 then
        return true
    else
        return isOdd(n - 1)
    end
end

function isOdd(n)
    if n == 0 then
        return false
    else
        return isEven(n - 1)
    end
end

local function factorial(n)
    local result = 1
    for i = 2, n do
        result = result * i
    end
    return result
end

local function bump()
    counter = counter + 1
    return counter
end

local function ____end(____local, ____nil)
    return ____local + ____nil
end

local function hidden()
    print("hidden")
end

local function outer(x)
    local function square(y)
        return y * y
    end
    return square(x) + square(x + 1)
end

local function unit()
    print(greeting .. " from unit")
end

local function main()
    print(isEven(10))
    print(isOdd(7))
    print(factorial(10))
    print(factorial(20))
    bump()
    bump()
    print(counter)
    print(____end(1, 2))
    hidden()
    print(outer(3))
    unit()
end

main()
return {greeting = greeting, counter = counter, isEven = isEven, isOdd = isOdd, factorial = factorial, bump = bump, ____end = ____end, outer = outer, unit = unit}
