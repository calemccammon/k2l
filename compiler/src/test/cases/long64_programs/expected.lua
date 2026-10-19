local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_GenerateSequence = ____lualib.__K2L_GenerateSequence
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IRem = ____lualib.__K2L_IRem
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_SequenceBuilder = ____lualib.__K2L_SequenceBuilder
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_Unsigned = ____lualib.__K2L_Unsigned

local Counter = __K2L_Class("Counter")

function Counter:____init()
    self.total = 0
    self.big = 5000000000000000000
end

function Counter:bump(by)
    self.total = self.total + by
    self.big = self.big + 1
    self.big = self.big - 2
    return self.total
end

local Consts = __K2L_Class("Consts")

function Consts:____init()
    self.LIMIT = 9000000000000000000
    self.MASK = 281474976710655
end

Consts:____init()
local Shape = __K2L_Class("Shape")
local Sq = __K2L_Class("Sq", nil, Shape)

function Sq:____init(side)
    self.side = side
end

function Sq:getArea()
    return self.side * self.side
end

local function parse(s)
    return __K2L_StringToIntOrNull(s, nil, true)
end

local function gcd(a, b)
    return b == 0 and a or gcd(b, __K2L_IRem(a, b))
end

local function modPow(base, exp, mod)
    local result = 1
    local b = __K2L_IRem(base, mod)
    local e = exp
    while e > 0 do
        if e & 1 == 1 then
            result = __K2L_IRem(result * b, mod)
        end
        b = __K2L_IRem(b * b, mod)
        e = e // (1 << 1)
    end
    return result
end

local function main()
    local big = 5000000000000000000
    local max = 9223372036854775807
    print(big + big)
    print(big - -big)
    print(big * 3)
    print(__K2L_IDiv(big, 7))
    print(math.fmod(big, 7))
    print(big + 1)
    print(big - 1)
    print(-big)
    print(big & 255)
    print(big | 1)
    print(big ~ max)
    print(big << 3)
    print(big // (1 << 3))
    print(big >> 3)
    print(64)
    print(8)
    print(math.abs(-9223372036854775807 - 1))
    print(9000000000000000000 + 9000000000000000000)
    print(Consts.MASK & big)
    local c = Counter.new()
    print(c:bump(big))
    print(c:bump(big))
    print(c.big)
    print(Sq.new(3000000000):getArea())
    print(Sq.new(3037000500):getArea())
    print(__K2L_Str(parse("9223372036854775807")))
    print(__K2L_Str(parse("x")))
    print(__K2L_Str(parse("9223372036854775808")))
    print(gcd(big, 1000000007 * 1000003))
    print(gcd(6000000000000000000, 4000000000000000000))
    print(modPow(2, 1000000006, 1000000007))
    print(modPow(3, big, 998244353))
    print(modPow(123456789, 987654321, max))
    local h = 1125899906842597
    for ch in ("hello world"):gmatch(".") do
        h = 31 * h + ch:byte()
    end
    print(h)
    local x = 88172645463325252
    for it = 0, 4 do
        x = x ~ x << 13
        x = x ~ x >> 7
        x = x ~ x << 17
        print(x)
    end
    local fact = __K2L_IntRange.new(1, 25):fold(1, function(acc, i) return acc * i end)
    print(fact)
    local sumSq = __K2L_IntRange.new(1, 2000000):sumOf(function(it) return it * it end)
    print(sumSq)
    print(__K2L_IntRange.new(1, 20):map(function(it) return it end):reduce(function(a, b) return a * b end))
    print(__K2L_Str(__K2L_IntRange.new(big, big - 3, -1):toList()))
    print(__K2L_Str(__K2L_IntRange.new(1, 3):reversed():toList()))
    print(__K2L_IntRange.new(big, big + 2):count())
    print(__K2L_IDiv(__K2L_ListOf(1, 2, 3):sum(), 2))
    print(__K2L_Str(__K2L_GenerateSequence(big, function(it) return it - 1000000000000000000 end):takeWhile(function(it) return it >= 0 end):toList()))
    local seq = __K2L_SequenceBuilder(function(self)
        self:yield(big)
        self:yield(max)
    end)
    print(__K2L_Str(seq:toList()))
    print(seq:map(function(it) return __K2L_IDiv(it, 3) end):sum())
    local ____pairs = __K2L_ListOf(__K2L_Pair.new(big, 1), __K2L_Pair.new(max, 2))
    print(__K2L_Str(____pairs:map(function(____destructured)
        local a, b = ____destructured.first, ____destructured.second
        return a + b
    end)))
    print(__K2L_Str(____pairs:toMap()))
    print(__K2L_Str(____pairs:maxByOrNull(function(it) return it.first end)))
    local nested = __K2L_MapOf(__K2L_Pair.new(big, __K2L_MapOf(__K2L_Pair.new(max, __K2L_ListOf(1, big)))))
    print(__K2L_Str(nested))
    local ____receiver = nested:get(big)
    local ____receiver_1 = ____receiver and ____receiver:get(max)
    print(__K2L_Str(____receiver_1 and ____receiver_1:last()))
    local text = "id=" .. big .. ";max=" .. max
    print(text)
    print(#(big .. max))
    print(tostring(big + 1))
    print("a" .. -big .. "b")
    print(tostring(big) .. tostring(max))
    local ____builder = __K2L_StringBuilder.new()
    for i = 0, 2 do
        ____builder:append(tostring(big + i)):append(",")
    end
    print(____builder:toString())
    local unsigned = 0xffffffffffffffff
    print(unsigned)
    print(__K2L_Unsigned.toString(__K2L_Unsigned.udiv(unsigned, 3)))
    print(__K2L_Unsigned.toString(unsigned))
    print(__K2L_Unsigned.toString(unsigned - 1))
    print(unsigned - big)
    print(__K2L_Unsigned.toString(big * 4))
    print(__K2L_Unsigned.toString(max + 1))
    print(__K2L_Str(__K2L_Unsigned.toDouble(max)))
    print(__K2L_Str(__K2L_Unsigned.toDouble(unsigned)))
end

main()
return {Counter = Counter, Consts = Consts, Shape = Shape, Sq = Sq, parse = parse, gcd = gcd, modPow = modPow}
