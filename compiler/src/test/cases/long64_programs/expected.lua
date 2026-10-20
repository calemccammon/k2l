local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Fmod = ____lualib.__K2L_Fmod
local __K2L_GenerateSequence = ____lualib.__K2L_GenerateSequence
local __K2L_IRem = ____lualib.__K2L_IRem
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SequenceBuilder = ____lualib.__K2L_SequenceBuilder
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StrByte = ____lualib.__K2L_StrByte
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

function Sq.new(side)
    return setmetatable({side = side}, Sq)
end

function Sq:getArea()
    return self.side * self.side
end

local function parse(s)
    return __K2L_StringToIntOrNull(s, nil, true)
end

local function gcd(a, b)
    return b == 0 and a or gcd(b, b ~= 0 and __K2L_Fmod(a, b) + 0 or __K2L_IRem(a, b))
end

local function modPow(base, exp, mod)
    local result = 1
    local b = mod ~= 0 and __K2L_Fmod(base, mod) + 0 or __K2L_IRem(base, mod)
    local e = exp
    while e > 0 do
        if e & 1 == 1 then
            result = mod ~= 0 and __K2L_Fmod(result * b, mod) + 0 or __K2L_IRem(result * b, mod)
        end
        b = mod ~= 0 and __K2L_Fmod(b * b, mod) + 0 or __K2L_IRem(b * b, mod)
        e = e // (1 << 1)
    end
    return result
end

local ____lambda_1 = function(acc, i) return acc * i end
local ____lambda_2 = function(it) return it * it end
local ____lambda_3 = function(it) return it end
local ____lambda_4 = function(a, b) return a * b end
local ____lambda_5 = function(it) return it - 1000000000000000000 end
local ____lambda_6 = function(it) return it >= 0 end
local ____lambda_7 = function(it) return it >= 0 and it // 3 or (it + 2) // 3 end
local ____lambda_8 = function(it) return it.first end
local function main()
    local big = 5000000000000000000
    local max = 9223372036854775807
    print(big + big)
    print(big - -big)
    print(big * 3)
    print(big >= 0 and big // 7 or (big + 6) // 7)
    print(big >= 0 and big % 7 or (big % 7 - 7) % (-7))
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
    for ____i = 1, #"hello world" do
        local ch = __K2L_StrByte("hello world", ____i)
        h = 31 * h + ch
    end
    print(h)
    local x = 88172645463325252
    for it = 0, 4 do
        x = x ~ x << 13
        x = x ~ x >> 7
        x = x ~ x << 17
        print(x)
    end
    local fact = __K2L_IntRange.new(1, 25):fold(1, ____lambda_1)
    print(fact)
    local sumSq = __K2L_IntRange.new(1, 2000000):sumOf(____lambda_2)
    print(sumSq)
    print(__K2L_IntRange.new(1, 20):map(____lambda_3):reduce(____lambda_4))
    print(__K2L_Str(__K2L_IntRange.new(big, big - 3, -1):toList()))
    print(__K2L_Str(__K2L_IntRange.new(1, 3):reversed():toList()))
    print(__K2L_IntRange.new(big, big + 2):count())
    local ____dividend = __K2L_ReadOnlyListOf(1, 2, 3):sum()
    print(____dividend >= 0 and ____dividend // 2 or (____dividend + 1) // 2)
    print(__K2L_Str(__K2L_GenerateSequence(big, ____lambda_5):takeWhile(____lambda_6):toList()))
    local seq = __K2L_SequenceBuilder(function(self)
        self:yield(big)
        self:yield(max)
    end)
    print(__K2L_Str(seq:toList()))
    print(seq:map(____lambda_7):sum())
    local ____pairs = __K2L_ReadOnlyListOf(__K2L_Pair.new(big, 1), __K2L_Pair.new(max, 2))
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____pairs:____array()
    for ____i_1 = 1, ____n do
        local ____it = ____items[____i_1]
        local ____result
        do
            local a, b = ____it.first, ____it.second
            ____result = a + b
        end
        ____count = ____count + 1
        ____out[____count] = ____result
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    print(__K2L_Str(____pairs:toMap()))
    print(__K2L_Str(____pairs:maxByOrNull(____lambda_8)))
    local nested = __K2L_SingletonMapOf(__K2L_Pair.new(big, __K2L_SingletonMapOf(__K2L_Pair.new(max, __K2L_ReadOnlyListOf(1, big)))))
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
