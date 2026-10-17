local ____exports = {}
local isOdd
local greeting = "Hi"
____exports.counter = 0

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
    ____exports.counter = ____exports.counter + 1
    return ____exports.counter
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
    print(____exports.counter)
    print(____end(1, 2))
    hidden()
    print(outer(3))
    unit()
end

____exports.greeting = greeting
____exports.isEven = isEven
____exports.isOdd = isOdd
____exports.factorial = factorial
____exports.bump = bump
____exports.____end = ____end
____exports.outer = outer
____exports.unit = unit
main()
return ____exports
