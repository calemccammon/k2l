local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_DoubleToInt = ____lualib.__K2L_DoubleToInt
local __K2L_DoubleToLong = ____lualib.__K2L_DoubleToLong
local __K2L_DoubleToString = ____lualib.__K2L_DoubleToString
local __K2L_FloatToString = ____lualib.__K2L_FloatToString
local __K2L_Fround = ____lualib.__K2L_Fround
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf

local Vec = __K2L_Class("Vec")

function Vec:____init(x, y)
    self.x = x
    self.y = y
end

function Vec.new(x, y)
    return setmetatable({x = x, y = y}, Vec)
end

function Vec:plus(o)
    return Vec.new(__K2L_Fround(self.x + o.x), __K2L_Fround(self.y + o.y))
end

function Vec:length()
    return __K2L_Fround(math.sqrt(__K2L_Fround(__K2L_Fround(self.x * self.x) + __K2L_Fround(self.y * self.y))))
end

function Vec:scaled(k)
    return Vec.new(__K2L_Fround(self.x * k), __K2L_Fround(self.y * k))
end

function Vec:toString()
    return "Vec(x=" .. __K2L_FloatToString(self.x) .. ", y=" .. __K2L_FloatToString(self.y) .. ")"
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
        s = __K2L_Fround(s + x)
    end
    return __K2L_Fround(s / xs.size)
end

local function main()
    local v = Vec.new(0.10000000149011612, 0.20000000298023224):plus(Vec.new(0.30000001192092896, 0.4000000059604645))
    print(__K2L_Str(v))
    print(__K2L_FloatToString(v:length()))
    print(__K2L_Str(v:scaled(__K2L_Fround(1.0 / 3))))
    local arr = __K2L_TypedArrayOf("[F", 0.10000000149011612, 0.699999988079071, 1.2999999523162842)
    print(__K2L_FloatToString(average(arr)))
    print(__K2L_Str(arr:toList()))
    local zeros = __K2L_ListOfSize(2, 0.0, "[F")
    print(__K2L_FloatToString(zeros[1] or __K2L_IndexError(0, zeros.size, "array")))
    local ____value = __K2L_Fround(2.5 / 3)
    if 1 < 0 or 1 >= zeros.size then
        __K2L_IndexError(1, zeros.size, "array")
    end
    zeros[2] = ____value
    print(__K2L_FloatToString(zeros[2] or __K2L_IndexError(1, zeros.size, "array")))
    print(__K2L_FloatToString(math.abs(-1.100000023841858)))
    print(__K2L_FloatToString(math.max(1.100000023841858, 2.200000047683716)))
    print(__K2L_FloatToString(math.min(1.100000023841858, 2.200000047683716)))
    print(__K2L_FloatToString(__K2L_Num.coerceIn(1.100000023841858, 0.0, 1.0)))
    print(__K2L_Num.roundToInt(2.5))
    print(__K2L_DoubleToLong(3.700000047683716))
    print(__K2L_FloatToString(__K2L_Fround(2.0 ^ 10)))
    print(__K2L_FloatToString(__K2L_Fround(2.0 ^ 0.5)))
    print(__K2L_FloatToString(__K2L_Fround(math.sin(1.0))))
    print(__K2L_FloatToString(__K2L_Fround(math.exp(1.0))))
    print(__K2L_FloatToString(__K2L_Fround(math.log(10.0))))
    print(__K2L_Compare(1.100000023841858, 1.2000000476837158))
    print(__K2L_StringFormat("%.3f", __K2L_Fround(1.0 / 3)))
    print(__K2L_StringFormat("%.1f", 2.25))
    local m = __K2L_ReadOnlyMapOf(__K2L_Pair.new("a", 0.10000000149011612), __K2L_Pair.new("b", __K2L_Fround(0.20000000298023224 + 0.10000000149011612)))
    print(__K2L_Str(m))
    local p = __K2L_Fround(0.699999988079071 * 3)
    print(__K2L_FloatToString(p))
    print("p=" .. __K2L_FloatToString(p))
    local any = __K2L_Fround(1.0 / 7)
    print(__K2L_Str(any))
    print(__K2L_FloatToString(1000000.0))
    print(__K2L_FloatToString(1.2345678E7))
    print(__K2L_FloatToString(0.0010000000474974513))
    print(__K2L_FloatToString(9.999999747378752E-5))
    local zero = 0.0
    print(__K2L_FloatToString(-zero))
    print(__K2L_FloatToString(__K2L_Fround(1.0 / 0)))
    print(__K2L_FloatToString(__K2L_Fround(-1.0 / 0)))
    print(__K2L_Num.isNaN(__K2L_Fround(0.0 / 0)))
    print(__K2L_FloatToString(math.fmod(5, 3.0)))
    print(__K2L_FloatToString(math.fmod(-7.5, 2)))
    print(__K2L_FloatToString(__K2L_Fround(7 / 2.0)))
    print(__K2L_FloatToString(__K2L_Fround(1.6777216E7 + 1)))
    print(__K2L_DoubleToString(0.10000000149011612 + 0.20000000298023224))
    print(__K2L_DoubleToString(0.1 + 0.2))
    print(__K2L_FloatToString(__K2L_Fround(1.100000023841858 * 1.100000023841858)))
    print(__K2L_DoubleToString(1.1 * 1.1))
    local big = __K2L_Fround(9.999999680285692E37 * 10)
    print(__K2L_FloatToString(big))
    print(__K2L_FloatToString(__K2L_Fround(3 * 0.10000000149011612)))
    print(__K2L_Fround(0.10000000149011612 * 3) == 0.30000001192092896)
    local ____list = __K2L_ReadOnlyListOf(0.10000000149011612, 0.20000000298023224, 0.30000001192092896)
    local ____sum = 0.0
    local ____items, ____n = ____list:____array()
    for ____i_1 = 1, ____n do
        local it = ____items[____i_1]
        ____sum = ____sum + __K2L_Fround(it * 2)
    end
    local total = ____sum
    print(__K2L_DoubleToString(total))
    print(__K2L_DoubleToString(__K2L_ReadOnlyListOf(0.10000000149011612, 0.20000000298023224, 0.30000001192092896):average()))
    print(__K2L_FloatToString(__K2L_ReadOnlyListOf(3.299999952316284, 1.100000023841858):max()))
    print(__K2L_Str(__K2L_ReadOnlyListOf(3.299999952316284, 1.100000023841858):sorted()))
    print(__K2L_DoubleToString(1.401298464324817E-45))
    print(__K2L_DoubleToInt(100000.0))
    print(__K2L_FloatToString(__K2L_Fround(1.6777217E7)))
    print(__K2L_Hash(0.10000000149011612) == __K2L_Hash(0.10000000149011612))
    local count = 0.0
    count = __K2L_Fround(count + 1)
    count = __K2L_Fround(count + 1)
    count = __K2L_Fround(count - 0.10000000149011612)
    count = __K2L_Fround(count * 3)
    count = __K2L_Fround(count / 7)
    print(__K2L_FloatToString(count))
end

main()
return {Vec = Vec, average = average}
