local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Truncate = ____lualib.__K2L_Truncate

local Vec = __K2L_Class("Vec")

function Vec:____init(x, y)
    self.x = x
    self.y = y
end

function Vec.new(x, y)
    return setmetatable({x = x, y = y}, Vec)
end

function Vec:plus(o)
    return Vec.new(self.x + o.x, self.y + o.y)
end

function Vec:length()
    return math.sqrt(self.x * self.x + self.y * self.y)
end

function Vec:scaled(k)
    return Vec.new(self.x * k, self.y * k)
end

function Vec:toString()
    return "Vec(x=" .. self.x .. ", y=" .. self.y .. ")"
end

function Vec:hashCode()
    return (31 * __K2L_Hash(self.x) + __K2L_Hash(self.y) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Vec:equals(other)
    return getmetatable(other) == Vec and self.x == other.x and self.y == other.y
end

local function average(xs)
    local s = 0.0
    for ____i = 1, xs.size do
        local x = xs[____i]
        s = s + x
    end
    return s / xs.size
end

local function main()
    local v = Vec.new(0.1, 0.2):plus(Vec.new(0.3, 0.4))
    print(__K2L_Str(v))
    print(v:length())
    print(__K2L_Str(v:scaled(1.0 / 3)))
    local arr = __K2L_ArrayOf(0.1, 0.7, 1.3)
    print(average(arr))
    print(__K2L_Str(arr:toList()))
    local zeros = __K2L_ListOfSize(2, 0.0, true)
    print(zeros[1] or __K2L_IndexError(0, zeros.size, "array"))
    local ____value = 2.5 / 3
    if 1 < 0 or 1 >= zeros.size then
        __K2L_IndexError(1, zeros.size, "array")
    end
    zeros[2] = ____value
    print(zeros[2] or __K2L_IndexError(1, zeros.size, "array"))
    print(math.abs(-1.1))
    print(math.max(1.1, 2.2))
    print(math.min(1.1, 2.2))
    print(__K2L_Num.coerceIn(1.1, 0.0, 1.0))
    print(math.floor(2.5 + 0.5))
    print(__K2L_Truncate(3.7))
    print(2.0 ^ 10)
    print(2.0 ^ 0.5)
    print(math.sin(1.0))
    print(math.exp(1.0))
    print(math.log(10.0))
    print(__K2L_Compare(1.1, 1.2))
    print(string.format("%.3f", 1.0 / 3))
    print(string.format("%.1f", 2.27))
    local m = __K2L_MapOf(__K2L_Pair.new("a", 0.1), __K2L_Pair.new("b", 0.2 + 0.1))
    print(__K2L_Str(m))
    local p = 0.7 * 3
    print(__K2L_Str(p))
    print("p=" .. __K2L_Str(p))
    local any = 1.0 / 7
    print(__K2L_Str(any))
    print(1000000.0)
    print(1.2345678E7)
    print(0.001)
    print(1.0E-4)
    local zero = 0.0
    print(-zero)
    print(1.0 / 0)
    print(-1.0 / 0)
    print(__K2L_Num.isNaN(0.0 / 0))
    print(5 % 3.0)
    print(-7.5 % 2)
    print(7 / 2.0)
    print(1.6777216E7 + 1)
    print(0.1 + 0.2)
    print(0.1 + 0.2)
    print(1.1 * 1.1)
    print(1.1 * 1.1)
    local big = 1.0E38 * 10
    print(big)
    print(3 * 0.1)
    print(0.1 * 3 == 0.3)
    local ____list = __K2L_ListOf(0.1, 0.2, 0.3)
    local ____sum = 0.0
    local ____items, ____n = ____list:____array()
    for ____i_1 = 1, ____n do
        local it = ____items[____i_1]
        ____sum = ____sum + it * 2
    end
    local total = ____sum
    print(total)
    print(__K2L_ListOf(0.1, 0.2, 0.3):average())
    print(__K2L_ListOf(3.3, 1.1):max())
    print(__K2L_Str(__K2L_ListOf(3.3, 1.1):sorted()))
    print(1.4E-45)
    print(__K2L_Truncate(100000.0))
    print(1.6777217E7)
    print(__K2L_Hash(0.1) == __K2L_Hash(0.1))
    local count = 0.0
    count = count + 1
    count = count + 1
    count = count - 0.1
    count = count * 3
    count = count / 7
    print(count)
end

__K2L_RunMain(main)
return {Vec = Vec, average = average}
