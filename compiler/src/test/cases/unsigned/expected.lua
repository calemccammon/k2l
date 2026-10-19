local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_DoubleToString = ____lualib.__K2L_DoubleToString
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_FloatToString = ____lualib.__K2L_FloatToString
local __K2L_Fround = ____lualib.__K2L_Fround
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_Unsigned = ____lualib.__K2L_Unsigned

local sumOfSquares

local function hash(s)
    local h = 2166136261
    for c in s:gmatch(".") do
        h = h ~ c:byte() & 0xFFFFFFFF
        h = h * 16777619 & 0xFFFFFFFF
    end
    return h
end

local function main()
    local a = 4000000000
    local b = 500000000
    print(a)
    print(a + b & 0xFFFFFFFF)
    print(b - a & 0xFFFFFFFF)
    print(a * 3 & 0xFFFFFFFF)
    print(a * a & 0xFFFFFFFF)
    print(__K2L_IDiv(a, 7))
    print(math.fmod(a, 7))
    print(a > b)
    print(b < a)
    print(__K2L_Equals(a, 4000000000))
    print(4294967295)
    print(0)
    print(4294967295)
    print(4294967295 + 1 & 0xFFFFFFFF)
    print("a=" .. a)
    print(__K2L_ToInt32(a))
    print(-1 & 0xFFFFFFFF)
    print(-1 & 0xFFFFFFFF)
    print(5000000000 & 0xFFFFFFFF)
    print(a)
    print(__K2L_Unsigned.toString(a))
    print(__K2L_DoubleToString(a + 0.0))
    print(__K2L_Unsigned.fromDouble32(3.7))
    print(__K2L_Unsigned.fromDouble32(-3.7))
    print(__K2L_Unsigned.fromDouble32(1.0E20))
    print(a << 1 & 0xFFFFFFFF)
    print(a >> 3)
    print(a & 4042322160)
    print(a | 1)
    print(a ~ 4294967295)
    print(4294967295 - a)
    print(hash("hello"))
    print(hash("The quick brown fox"))
    local c = 5
    c = c - 1 & 0xFFFFFFFF
    c = c - 1 & 0xFFFFFFFF
    c = c - 1 & 0xFFFFFFFF
    c = c - 1 & 0xFFFFFFFF
    c = c - 1 & 0xFFFFFFFF
    c = c - 1 & 0xFFFFFFFF
    print(c)
    c = c + 10 & 0xFFFFFFFF
    print(c)
    for i = 1, 5 do
        io.write(i .. " ")
    end
    print()
    for i = 10, 7, -1 do
        io.write(i .. " ")
    end
    print()
    for i = 0, 2 do
        io.write(i .. " ")
    end
    print()
    for i = 0, 10, 5 do
        io.write(i .. " ")
    end
    print()
    print(5 >= 1 and 5 <= 10)
    print(11 >= 1 and 11 <= 10)
    local bytes = 200 & 0xFF
    print(bytes)
    print(bytes + (100 & 0xFF) & 0xFFFFFFFF)
    print(bytes)
    print(300 & 0xFF)
    print(70000 & 0xFFFF)
    print(bytes << 4 & 0xFFFFFFFF)
    local s = 65535
    print(s)
    print(s + 1)
    print(__K2L_Str(__K2L_ListOf(3, 1, 2):sorted()))
    print(__K2L_Str(__K2L_ListOf(1, 2):map(function(it) return it * 2 & 0xFFFFFFFF end)))
    print(math.max(5, 9))
    print(tostring(a))
    print(__K2L_Num.toRadix(a, 16))
    print(__K2L_ArrayOf(1, 2, 3):sum() & 0xFFFFFFFF)
    local arr = __K2L_ListOfSize(3, 0, true)
    arr:set(1, 7)
    print(__K2L_Str(arr:toList()))
    print(arr:get(1) + arr:get(0) & 0xFFFFFFFF)
    print(__K2L_Compare(a, b))
    print(__K2L_ToInt32(4294967295))
    print(__K2L_DoubleToString((1 + 0.0) / 3))
    print(__K2L_FloatToString(__K2L_Fround(a + 0.0)))
    print(10 * 2)
    print(__K2L_Unsigned.toString(4294967295 + 1))
    local x = 9000000000
    local y = 7
    print(__K2L_Unsigned.toString(x + y))
    print(__K2L_Unsigned.toString(x - y))
    print(__K2L_Unsigned.toString(x * y))
    print(__K2L_Unsigned.toString(__K2L_Unsigned.udiv(x, y)))
    print(__K2L_Unsigned.toString(__K2L_Unsigned.urem(x, y)))
    print(math.ult(y, x))
    print(__K2L_Unsigned.compare(y, x))
    print(__K2L_Unsigned.toString(x) .. "!")
    print(x & 0xFFFFFFFF)
    print(x + 1)
    print(__K2L_DoubleToString(__K2L_Unsigned.toDouble(x)))
    print(__K2L_Unsigned.toString(x >> 3))
    print(math.ult(x, -1 - x))
    print(math.ult(y, y - 8))
    for i = 1, 3 do
        io.write(__K2L_Unsigned.toString(i) .. " ")
    end
    print()
    print(sumOfSquares(5))
end

function sumOfSquares(n)
    local total = 0
    for i = 1, n do
        total = total + (i * i & 0xFFFFFFFF) & 0xFFFFFFFF
    end
    return total
end

main()
return {hash = hash, sumOfSquares = sumOfSquares}
