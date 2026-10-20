local ____lualib = require("lualib_bundle")
local __K2L_ArithmeticException = ____lualib.__K2L_ArithmeticException
local __K2L_BigDecimal = ____lualib.__K2L_BigDecimal
local __K2L_BigInteger = ____lualib.__K2L_BigInteger
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Fmod = ____lualib.__K2L_Fmod
local __K2L_FunctionRef = ____lualib.__K2L_FunctionRef
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IRem = ____lualib.__K2L_IRem
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_LazyObject = ____lualib.__K2L_LazyObject
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_RoundingMode = ____lualib.__K2L_RoundingMode
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local ____lambda_1 = function(acc, i)
    return acc:multiply(__K2L_BigInteger.valueOf(i))
end
local function factorial(n)
    return __K2L_IntRange.new(2, n):fold(__K2L_BigInteger.ONE, ____lambda_1)
end

local function binomial(n, k)
    local result = __K2L_BigInteger.ONE
    for i = 0, k - 1 do
        result = result:multiply(__K2L_BigInteger.valueOf(n - i)):divide(__K2L_BigInteger.valueOf(i + 1))
    end
    return result
end

local function bigFib(n)
    local a = __K2L_BigInteger.ZERO
    local b = __K2L_BigInteger.ONE
    for it = 0, n - 1 do
        do
            local t = a:add(b)
            a = b
            b = t
        end
    end
    return a
end

local function gcd(a, b)
    return b == 0 and math.abs(a) or gcd(b, b ~= 0 and __K2L_Fmod(a, b) + 0 or __K2L_IRem(a, b))
end

local function lcm(a, b)
    return __K2L_IDiv(a, gcd(a, b)) * b
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

local function isPrime(n)
    if n < 2 then
        return false
    end
    if (n >= 0 and n % 2 or (n % 2 - 2) % (-2)) == 0 then
        return n == 2
    end
    local d = 3
    while d * d <= n do
        if (d ~= 0 and __K2L_Fmod(n, d) + 0 or __K2L_IRem(n, d)) == 0 then
            return false
        end
        d = d + 2
    end
    return true
end

local ____lambda_2 = function(____p1, ____p2) return ____p1 + ____p2 end
local function primeFactors(n)
    local factors = __K2L_MapOf()
    local x = n
    local p = 2
    while p * p <= x do
        while (p ~= 0 and __K2L_Fmod(x, p) + 0 or __K2L_IRem(x, p)) == 0 do
            factors:merge(p, 1, __K2L_FunctionRef.new("plus", "kotlin/Int.plus(kotlin.Int)", ____lambda_2))
            x = __K2L_IDiv(x, p)
        end
        p = p + 1
    end
    if x > 1 then
        local ____key = x
        factors:set(____key, (factors:get(x) or 0) + 1)
    end
    return factors
end

local Rational = __K2L_Class("Rational")
Rational.____comparable = true

function Rational:____init(num, den)
    self.num = num
    self.den = den
end

function Rational.new(num, den)
    return setmetatable({num = num, den = den}, Rational)
end

function Rational:plus(o)
    return Rational:of__1(self.num:multiply(o.den):add(o.num:multiply(self.den)), self.den:multiply(o.den))
end

function Rational:minus(o)
    return Rational:of__1(self.num:multiply(o.den):subtract(o.num:multiply(self.den)), self.den:multiply(o.den))
end

function Rational:times(o)
    return Rational:of__1(self.num:multiply(o.num), self.den:multiply(o.den))
end

function Rational:div(o)
    if o.num:signum() == 0 then
        error(__K2L_ArithmeticException.new("division by zero rational"))
    end
    return Rational:of__1(self.num:multiply(o.den), self.den:multiply(o.num))
end

function Rational:unaryMinus()
    return Rational.new(self.num:negate(), self.den)
end

function Rational:compareTo(other)
    return self.num:multiply(other.den):compareTo(other.num:multiply(self.den))
end

function Rational:equals(other)
    return getmetatable(other) == Rational and __K2L_Equals(self.num, other.num) and __K2L_Equals(self.den, other.den)
end

function Rational:hashCode()
    return 31 * self.num:hashCode() + self.den:hashCode()
end

function Rational:toString()
    return __K2L_Equals(self.den, __K2L_BigInteger.ONE) and __K2L_Str(self.num) or __K2L_Str(self.num) .. "/" .. __K2L_Str(self.den)
end

function Rational:toDouble()
    return self.num:toDouble() / self.den:toDouble()
end

Rational.____companion = true

function Rational:of(n, d)
    if d == nil then
        d = 1
    end
    return self:of__1(__K2L_BigInteger.valueOf(n), __K2L_BigInteger.valueOf(d))
end

function Rational:of__1(n, d)
    if d:signum() == 0 then
        error(__K2L_IllegalArgumentException.new("denominator is zero"))
    end
    local ____value = n:gcd(d)
    local ____result
    ____result = d:signum() < 0 and ____value:negate() or ____value
    local g = ____result
    return Rational.new(n:divide(g), d:divide(g))
end

function Rational:____initCompanion()
    self.ZERO = self:of(0)
end

__K2L_LazyObject(Rational, "____initCompanion")

local function r(self)
    return Rational:of(self)
end

local ____lambda_3 = function(acc, k) return acc:plus(Rational:of(1, k)) end
local function harmonic(n)
    return __K2L_IntRange.new(1, n):fold(Rational.ZERO, ____lambda_3)
end

local ____lambda_4 = function(it) return Rational.ZERO end
local function bernoulli(n)
    local a = __K2L_ListOfSize(n + 1, ____lambda_4, "[LRational;")
    for m = 0, n do
        local ____value_1 = Rational:of(1, m + 1)
        if m < 0 or m >= a.size then
            __K2L_IndexError(m, a.size, "array")
        end
        a[m + 1] = ____value_1
        for j = m, 1, -1 do
            local ____key_1 = j - 1
            local ____value_2 = r(j):times((a[j] or __K2L_IndexError(j - 1, a.size, "array")):minus(a[j + 1] or __K2L_IndexError(j, a.size, "array")))
            if ____key_1 < 0 or ____key_1 >= a.size then
                __K2L_IndexError(____key_1, a.size, "array")
            end
            a[____key_1 + 1] = ____value_2
        end
    end
    return a[1] or __K2L_IndexError(0, a.size, "array")
end

local function integrate(from, to, steps, f)
    if steps == nil then
        steps = 1000
    end
    local h = (to - from) / steps
    local sum = f(from) + f(to)
    for i = 1, steps - 1 do
        sum = sum + f(from + i * h) * ((i >= 0 and i % 2 or 0 - -i % 2) == 1 and 4 or 2)
    end
    return sum * h / 3
end

local function sqrtNewton(x, eps)
    if eps == nil then
        eps = 1.0E-12
    end
    local guess = x / 2
    local iterations = 0
    while math.abs(guess * guess - x) > eps * x do
        guess = (guess + x / guess) / 2
        iterations = iterations + 1
        if not (iterations < 100) then
            error(__K2L_IllegalStateException.new("did not converge"))
        end
    end
    return guess
end

local ____lambda_5 = function(it) return __K2L_Num.digitToInt(it) end
local ____lambda_6 = function(it) return it == "0" end
local ____lambda_7 = function(it) return binomial(10, it) end
local ____lambda_8 = function(n)
    return primeFactors(n):getEntries():fold(1, function(acc, ____destructured)
        local p, e = ____destructured.key, ____destructured.value
        return acc * __K2L_IntRange.new(1, e):fold(1, function(s, _) return s * p + 1 end)
    end)
end
local ____lambda_9 = function(it) return bernoulli(it) end
local ____lambda_10 = function() return Rational:of(1, 0) end
local ____lambda_11 = function(it) return 4 / (1 + it * it) end
local ____lambda_12 = function(it) return math.exp(-it * it / 2) end
local ____lambda_13 = function(acc, _)
    return acc:multiply(__K2L_BigDecimal.parse("1.05")):setScale(2, __K2L_RoundingMode.HALF_EVEN)
end
local function main()
    print("20! = " .. __K2L_Str(factorial(20)) .. " (fits in Long: " .. tostring(__K2L_Compare(factorial(20), __K2L_BigInteger.valueOf(9223372036854775807)) <= 0) .. ")")
    print("25! = " .. __K2L_Str(factorial(25)))
    local f100 = factorial(100)
    print("100! has " .. #f100:toString() .. " digits, digit sum " .. __K2L_StringToList(f100:toString()):sumOf(____lambda_5) .. ", trailing zeros " .. #__K2L_Text.takeLastWhile(f100:toString(), ____lambda_6))
    print("C(50, 25) = " .. __K2L_Str(binomial(50, 25)) .. ", C(100, 3) = " .. __K2L_Str(binomial(100, 3)))
    print("pascal row 10: " .. __K2L_Str(__K2L_IntRange.new(0, 10):map(____lambda_7)))
    print("F(100) = " .. __K2L_Str(bigFib(100)))
    print("F(300) mod 1e9+7 = " .. __K2L_Str(bigFib(300):mod(__K2L_BigInteger.valueOf(1000000007))))
    print("2^100 = " .. __K2L_Str(__K2L_BigInteger.TWO:pow(100)) .. ", bits " .. __K2L_BigInteger.TWO:pow(100):bitLength())
    print("3^200 mod 1000007 = " .. __K2L_Str(__K2L_BigInteger.valueOf(3):modPow(__K2L_BigInteger.valueOf(200), __K2L_BigInteger.valueOf(1000007))) .. " vs " .. modPow(3, 200, 1000007))
    print("gcd(1071, 462) = " .. gcd(1071, 462) .. ", lcm(1..20) = " .. __K2L_IntRange.new(1, 20):reduce(lcm))
    local ____dividend = -17
    print("2^62 = " .. (1 << 62) .. ", Long.MAX_VALUE / 7 = " .. __K2L_IDiv(9223372036854775807, 7) .. ", -17 mod 5 = " .. (____dividend >= 0 and ____dividend % 5 or 0 - -____dividend % 5) .. " / " .. __K2L_Num.mod(-17, 5) .. " / " .. __K2L_Num.mod(-17, 5))
    print("big modpow: " .. modPow(2, 1000000, 1000000007) .. " " .. modPow(12345, 6789, 999983))
    print("primes near 1e9: " .. __K2L_Str(__K2L_IntRange.new(1000000000, 1000000100):filter(isPrime)))
    print("factors: " .. __K2L_Str(primeFactors(600851475143)) .. " " .. __K2L_Str(primeFactors(360)) .. " " .. __K2L_Str(primeFactors(9999999967)))
    local divisorSum = ____lambda_8
    print("sigma(360) = " .. divisorSum(360) .. ", perfect: " .. __K2L_Str(__K2L_IntRange.new(2, 10000):filter(function(it) return divisorSum(it) == 2 * it end)))
    print("H(10) = " .. __K2L_Str(harmonic(10)) .. " ≈ " .. __K2L_StringFormat("%.6f", harmonic(10):toDouble()) .. ", ln(10)+γ ≈ " .. __K2L_StringFormat("%.6f", math.log(10.0) + 0.5772156649))
    print("bernoulli: " .. __K2L_Str(__K2L_IntRange.new(0, 12):map(____lambda_9)))
    local third = Rational:of(1, 3)
    print("1/3 + 1/6 = " .. __K2L_Str(third:plus(Rational:of(1, 6))) .. ", -(2/4) = " .. __K2L_Str(Rational:of(2, 4):unaryMinus()) .. ", (3/4)/(1/8) = " .. __K2L_Str(Rational:of(3, 4):div(Rational:of(1, 8))))
    print("sorted: " .. __K2L_Str(__K2L_ReadOnlyListOf(Rational:of(3, 7), Rational:of(1, 2), Rational:of(-2, 5), r(1)):sorted()))
    print("set: " .. __K2L_ReadOnlySetOf(Rational:of(2, 4), Rational:of(1, 2), Rational:of(3, 6)).size)
    local ____ok, ____result_1 = __K2L_DeepPcall(function()
        third:div(Rational.ZERO)
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error, __K2L_ArithmeticException) then
            local e = ____error
            print("caught: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    local ____receiver = __K2L_RunCatching(____lambda_10):exceptionOrNull()
    print(__K2L_Str(____receiver and ____receiver.message))
    local pi = integrate(0.0, 1.0, nil, ____lambda_11)
    print("pi ≈ " .. __K2L_StringFormat("%.12f", pi) .. " error " .. __K2L_StringFormat("%.2e", math.abs(pi - math.pi)))
    local gauss = integrate(-5.0, 5.0, 2000, ____lambda_12) / math.sqrt(2 * math.pi)
    print("gaussian area ≈ " .. __K2L_StringFormat("%.8f", gauss))
    local ____list = __K2L_ReadOnlyListOf(2.0, 10.0, 12345.678)
    for ____i = 1, ____list.size do
        local x = ____list[____i]
        print("sqrt(" .. __K2L_Str(x) .. ") = " .. __K2L_StringFormat("%.10f", sqrtNewton(x)) .. " (" .. __K2L_Str(math.sqrt(x)) .. ")")
    end
    print("doubles: " .. __K2L_Str(0.1 + 0.2) .. " " .. __K2L_Str(1.0 / 3) .. " " .. __K2L_Str(2.0 / 3 * 3) .. " " .. __K2L_Str(1.0E20) .. " " .. __K2L_Str(1.5E-7) .. " " .. __K2L_Str(100.0) .. " " .. __K2L_Str(-0.0) .. " " .. __K2L_Str(1.7976931348623157E308))
    print("format: " .. __K2L_StringFormat("%8.3f|%-8.2f|%08.2f|%+.1e|%,d", math.pi, -math.pi, 3.14159, 12345.678, 1234567890))
    local ____list_1 = __K2L_ReadOnlyListOf(2.5, 3.5, -2.5, 0.125)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list_1:____array()
    for ____i_1 = 1, ____n do
        local it = ____items[____i_1]
        ____count = ____count + 1
        ____out[____count] = __K2L_Num.roundToLong(it)
    end
    local ____arg = __K2L_Str(__K2L_ListWrap(____out, ____count))
    local ____list_2 = __K2L_ReadOnlyListOf(1.005, 2.675)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_2:____array()
    for ____i_2 = 1, ____n_1 do
        local it = ____items_1[____i_2]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = __K2L_StringFormat("%.2f", it)
    end
    print("rounding: " .. ____arg .. " " .. __K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
    local bd = __K2L_BigDecimal.parse("10"):divide(__K2L_BigDecimal.parse("3"), 20, __K2L_RoundingMode.HALF_UP)
    print("10/3 = " .. __K2L_Str(bd) .. ", scaled " .. __K2L_Str(bd:setScale(4, __K2L_RoundingMode.DOWN)) .. ", money " .. __K2L_Str(__K2L_BigDecimal.parse("19.99"):multiply(__K2L_BigDecimal.fromLong(3))))
    local compound = __K2L_IntRange.new(1, 10):fold(__K2L_BigDecimal.parse("1000.00"), ____lambda_13)
    print("compound interest: " .. __K2L_Str(compound))
    print("Int ops: " .. 2147483647 + 1 .. " " .. (((1 << 30) + 0x80000000 & 0xFFFFFFFF) - 0x80000000) * 2 .. " " .. __K2L_Str(__K2L_Num.toRadixUnsigned(255, 16)) .. " " .. __K2L_StringToInt("ff", 16) .. " " .. 11 .. " " .. -9223372036854775807 - 1)
end

__K2L_DeepMain(main)
return {factorial = factorial, binomial = binomial, bigFib = bigFib, gcd = gcd, lcm = lcm, modPow = modPow, isPrime = isPrime, primeFactors = primeFactors, Rational = Rational, r = r, harmonic = harmonic, bernoulli = bernoulli, integrate = integrate, sqrtNewton = sqrtNewton}
