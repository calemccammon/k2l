local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DoubleToInt = ____lualib.__K2L_DoubleToInt
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_StrByte = ____lualib.__K2L_StrByte
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf

local Counter = __K2L_Class("Counter")

function Counter:____init(value)
    self.value = value
end

function Counter.new(value)
    return setmetatable({value = value}, Counter)
end

function Counter:bump()
    self.value = (self.value + 1 + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

local function hash(s)
    local h = 7
    for ____i = 1, #s do
        local c = __K2L_StrByte(s, ____i)
        h = (31 * h + c + 0x80000000 & 0xFFFFFFFF) - 0x80000000
    end
    return h
end

local function mix(a, b)
    return ((a * 31 + b) * 1000003 - a + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

local function id(x)
    return x
end

local function main()
    print(hash("hello"))
    print(hash("the quick brown fox jumps over the lazy dog"))
    print(hash("Aa") == hash("BB"))
    local max = id(2147483647)
    local min = id(-2147483648)
    print((max + 1 + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print((min - 1 + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print((max + max + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print((min + min + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print((-min + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print((-max + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print((min * (-1) + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print((max * max + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print((max * 2 + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print((min * min + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print((123456789 * id(987654321) + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print((id(65536) * id(65536) + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print((id(46341) * id(46341) + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print((id(-46341) * id(46341) + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print(mix(max, min))
    print(mix(123456, -654321))
    local i = id(2147483647)
    i = (i + 1 + 0x80000000 & 0xFFFFFFFF) - 0x80000000
    print(i)
    i = (i - 1 + 0x80000000 & 0xFFFFFFFF) - 0x80000000
    print(i)
    local ____old = i
    i = (i + 1 + 0x80000000 & 0xFFFFFFFF) - 0x80000000
    local before = ____old
    print(before)
    print(i)
    local j = id(-2147483648)
    j = (j - 1 + 0x80000000 & 0xFFFFFFFF) - 0x80000000
    print(j)
    j = (j + 1 + 0x80000000 & 0xFFFFFFFF) - 0x80000000
    print(j)
    local acc = id(1)
    for k = 1, 40 do
        acc = (acc * 3 + 0x80000000 & 0xFFFFFFFF) - 0x80000000
    end
    print(acc)
    acc = (acc + id(2000000000) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
    print(acc)
    acc = (acc - id(2000000000) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
    acc = (acc - id(2000000000) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
    print(acc)
    local c = Counter.new(2147483647)
    c:bump()
    print(c.value)
    c.value = (c.value + 5 + 0x80000000 & 0xFFFFFFFF) - 0x80000000
    print(c.value)
    local arr = __K2L_TypedArrayOf("[I", 2147483647, 1)
    arr[1] = ((arr[1] or __K2L_IndexError(0, arr.size, "array")) + (arr[2] or __K2L_IndexError(1, arr.size, "array")) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
    print(arr[1] or __K2L_IndexError(0, arr.size, "array"))
    local l = 5000000000 + id(1)
    print(__K2L_ToInt32(l))
    print(__K2L_ToInt32(l * 3))
    print(2147483647 + 1)
    print(id(7) * 1000000000)
    print(__K2L_DoubleToInt(3.0E9))
    print(__K2L_DoubleToInt(-2.5))
    print((max + 1 + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print((max + 1 + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print((min - 1 + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print((-min + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print((max * 2 + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    local s = 30000
    local t = 30000
    print((s + t + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    local sh = 32767
    sh = __K2L_Num.toShort(sh + 1)
    print(sh)
    local by = 127
    by = __K2L_Num.toByte(by + 1)
    print(by)
    print((by + 1 + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    local ____dividend = id(7)
    print(____dividend >= 0 and ____dividend // 2 or 0 - -____dividend // 2)
    local ____dividend_1 = id(-7)
    print(____dividend_1 >= 0 and ____dividend_1 % 3 or 0 - -____dividend_1 % 3)
    print(-2147483648)
    print(2147483647)
    print(-2147483648)
    print(((id(1) << 31) + 0x80000000 & 0xFFFFFFFF) - 0x80000000)
    print((((id(1) << 31) + 0x80000000 & 0xFFFFFFFF) - 0x80000000) // 2147483648)
    print(max ~ min)
    local sum = 0
    for n = 1, 100000 do
        sum = (sum + n * n + 0x80000000 & 0xFFFFFFFF) - 0x80000000
    end
    print(sum)
end

main()
return {Counter = Counter, hash = hash, mix = mix, id = id}
