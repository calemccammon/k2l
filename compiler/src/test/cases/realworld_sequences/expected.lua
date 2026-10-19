local ____lualib = require("lualib_bundle")
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_CharRange = ____lualib.__K2L_CharRange
local __K2L_CheckStep = ____lualib.__K2L_CheckStep
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DoubleToInt = ____lualib.__K2L_DoubleToInt
local __K2L_GenerateSequence = ____lualib.__K2L_GenerateSequence
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IRem = ____lualib.__K2L_IRem
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SequenceBuilder = ____lualib.__K2L_SequenceBuilder
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringToDouble = ____lualib.__K2L_StringToDouble
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_Triple = ____lualib.__K2L_Triple

local function collatz(start)
    return __K2L_GenerateSequence(start, function(n)
        if n == 1 then
            return nil
        elseif math.fmod(n, 2) == 0 then
            return __K2L_IDiv(n, 2)
        else
            return 3 * n + 1
        end
    end)
end

local primes = __K2L_SequenceBuilder(function(self)
    self:yield(2)
    local found = __K2L_ListOf()
    local candidate = 3
    while true do
        local limit = __K2L_DoubleToInt(math.sqrt(candidate + 0.0))
        if found:takeWhile(function(it) return it <= limit end):none(function(it) return __K2L_IRem(candidate, it) == 0 end) then
            found:add(candidate)
            self:yield(candidate)
        end
        candidate = candidate + 2
    end
end)

local function sieve(n)
    local composite = __K2L_ListOfSize(n + 1, false, "[Z")
    for i = 2, n do
        do
            if composite:get(i) then
                goto ____continue
            end
            for j = i * i, n, __K2L_CheckStep(i) do
                local ____key = __K2L_ToInt32(j)
                composite:set(____key, true)
            end
        end
        ::____continue::
    end
    return __K2L_IntRange.new(2, n):filterNot(function(it) return composite:get(it) end)
end

local function fibonacci()
    return __K2L_GenerateSequence(__K2L_Pair.new(0, 1), function(____destructured)
        local a, b = ____destructured.first, ____destructured.second
        return __K2L_Pair.new(b, a + b)
    end):map(function(it) return it.first end)
end

local function digitsOf(n)
    return __K2L_StringToList(tostring(n)):map(function(it) return __K2L_Num.digitToInt(it) end)
end

local function isHappy(n)
    local seen = __K2L_SetOf()
    return __K2L_GenerateSequence(n, function(x)
        return __K2L_StringToList(tostring(x)):sumOf(function(it)
            return (it:byte() - ("0"):byte()) * (it:byte() - ("0"):byte())
        end)
    end):first(function(it) return it == 1 or not seen:add(it) end) == 1
end

local Reading = __K2L_Class("Reading")

function Reading:____init(minute, celsius)
    self.minute = minute
    self.celsius = celsius
end

function Reading:toString()
    return "Reading(minute=" .. self.minute .. ", celsius=" .. __K2L_Str(self.celsius) .. ")"
end

function Reading:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.minute) + __K2L_Hash(self.celsius))
end

function Reading:equals(other)
    return getmetatable(other) == Reading and self.minute == other.minute and self.celsius == other.celsius
end

local SENSOR = __K2L_Text.trimIndent("\n    0 21.5\n    1 21.7\n    2 22.4\n    3 23.9\n    4 24.1\n    5 99.9\n    6 24.6\n    7 24.2\n    8 23.0\n    9 22.1\n    10 21.4\n    11 20.9\n    12 -40.0\n    13 20.5\n    14 20.8\n    15 21.6\n")

local function parseReadings(text)
    return __K2L_AsSequence(__K2L_StringLines(text)):map(function(it) return __K2L_StringSplit(it, " ") end):map(function(____destructured_1)
        local m, c = ____destructured_1[1], ____destructured_1[2]
        return Reading.new(__K2L_StringToInt(m), __K2L_StringToDouble(c))
    end)
end

local function fmt(____this, decimals)
    if decimals == nil then
        decimals = 2
    end
    return __K2L_StringFormat("%." .. decimals .. "f", ____this)
end

local function main()
    local longest = __K2L_IntRange.new(1, 30):maxBy(function(it) return collatz(it):count() end)
    print("collatz(27) has " .. collatz(27):count() .. " terms, peak " .. collatz(27):max())
    print("longest under 30: " .. longest .. " (" .. collatz(longest):count() .. " terms)")
    print("collatz(6) = " .. collatz(6):joinToString(" -> "))
    print("first primes: " .. __K2L_Str(primes:take(15):toList()))
    print("100th prime: " .. primes:elementAt(99) .. "; sieve agrees: " .. sieve(541):last())
    print("primes below 100 by last digit: " .. __K2L_Str(sieve(100):groupBy(function(it) return math.fmod(it, 10) end):toSortedMap()))
    local twin = primes:zipWithNext():filter(function(____destructured_2)
        local a, b = ____destructured_2.first, ____destructured_2.second
        return b - a == 2
    end):take(6):toList()
    print("twin primes: " .. __K2L_Str(twin))
    local gaps = sieve(1000):zipWithNext(function(a, b) return b - a end)
    print("max prime gap below 1000: " .. gaps:max() .. " after " .. sieve(1000):get(gaps:indexOf(gaps:max())))
    print("fibonacci: " .. fibonacci():take(20):joinToString())
    local firstBig = fibonacci():withIndex():first(function(it) return #tostring(it.value) >= 15 end)
    print("first 15-digit fibonacci: F(" .. firstBig.index .. ") = " .. firstBig.value)
    print("even fib sum below 4M: " .. fibonacci():takeWhile(function(it) return it < 4000000 end):filter(function(it) return math.fmod(it, 2) == 0 end):sum())
    print("digit sum of F(75): " .. digitsOf(fibonacci():elementAt(75)):sum())
    print("happy numbers: " .. __K2L_Str(__K2L_IntRange.new(1, 50):filter(isHappy)))
    local readings = parseReadings(SENSOR):toList()
    local median3 = readings:windowed(3, nil, nil, function(w)
        return w:map(function(it) return it.celsius end):sorted():get(1)
    end)
    print("median-of-3: " .. median3:joinToString(nil, nil, nil, nil, nil, function(it) return fmt(it, 1) end))
    local outliers = readings:windowed(3):filter(function(____destructured_3)
        local a, b, c = ____destructured_3[1], ____destructured_3[2], ____destructured_3[3]
        return math.abs(b.celsius - (a.celsius + c.celsius) / 2) > 10
    end):map(function(it) return it:get(1) end)
    print("outliers: " .. __K2L_Str(outliers))
    local clean = readings:filter(function(it) return not outliers:contains(it) end)
    local movingAvg = clean:map(function(it) return it.celsius end):windowed(4, 2, true, function(it) return it:average() end)
    print("moving average (4, step 2): " .. __K2L_Str(movingAvg:map(function(it) return fmt(it) end)))
    local chunks = clean:chunked(5, function(chunk)
        return chunk:first().minute .. "-" .. chunk:last().minute .. ": max " .. __K2L_Str(chunk:maxOf(function(it) return it.celsius end))
    end)
    for ____i = 1, chunks.size do
        local it = chunks[____i]
        print("  " .. it)
    end
    local trend = clean:zipWithNext(function(a, b)
        if b.celsius > a.celsius + 0.5 then
            return "+"
        elseif b.celsius < a.celsius - 0.5 then
            return "-"
        else
            return "="
        end
    end):joinToString("")
    print("trend: " .. trend)
    local runs = __K2L_StringToList(trend):fold(__K2L_ListOf(), function(acc, c)
        if acc:isNotEmpty() and acc:last().first == c then
            local ____key_1 = acc.size - 1
            acc:set(____key_1, __K2L_Pair.new(c, acc:last().second + 1))
        else
            acc:add(__K2L_Pair.new(c, 1))
        end
        return acc
    end)
    print("runs: " .. runs:joinToString(" ", nil, nil, nil, nil, function(____destructured_4)
        local c, n = ____destructured_4.first, ____destructured_4.second
        return c .. n
    end))
    local warm = __K2L_AsSequence(clean):dropWhile(function(it) return it.celsius < 23 end):takeWhile(function(it) return it.celsius >= 23 end):map(function(it) return it.minute end):toList()
    print("warm spell minutes: " .. __K2L_Str(warm))
    local triangular = __K2L_GenerateSequence(__K2L_Pair.new(1, 1), function(____destructured_5)
        local n, t = ____destructured_5.first, ____destructured_5.second
        return __K2L_Pair.new(n + 1, t + n + 1)
    end)
    local firstWithDivisors = triangular:first(function(____destructured_6)
        local t = ____destructured_6.second
        return __K2L_IntRange.new(1, t):count(function(it) return __K2L_IRem(t, it) == 0 end) > 20
    end)
    print("first triangular number with >20 divisors: " .. firstWithDivisors.second .. " (n=" .. firstWithDivisors.first .. ")")
    local evens = __K2L_GenerateSequence(0, function(it) return it + 2 end)
    print("evens: " .. __K2L_Str(evens:take(5):toList()) .. " squares of odds: " .. __K2L_Str(__K2L_IntRange.new(1, 20):withStep(2):map(function(it) return it * it end)))
    local countdown = __K2L_IntRange.new(10, 0, -1):withStep(3):toList()
    print("countdown " .. __K2L_Str(countdown) .. ", sum " .. countdown:sum() .. ", reversed " .. __K2L_Str(countdown:asReversed()))
    local chars = __K2L_CharRange.new("a", "z"):filterIndexed(function(i, _) return math.fmod(i, 5) == 0 end):joinToString("")
    print("letters: " .. chars .. " " .. __K2L_Str(__K2L_CharRange.new("A", "F"):toList():chunked(2):map(function(it) return it:joinToString("") end)))
    local pythagorean = __K2L_SequenceBuilder(function(____this_1)
        for c = 1, 30 do
            for b = 1, c - 1 do
                for a = 1, b do
                    if a * a + b * b == c * c then
                        ____this_1:yield(__K2L_Triple.new(a, b, c))
                    end
                end
            end
        end
    end)
    print("pythagorean triples: " .. __K2L_Str(pythagorean:take(6):toList()))
    print("lazy evaluation:")
    local evaluated = __K2L_ListOf()
    local result = __K2L_AsSequence(__K2L_ReadOnlyListOf("one", "two", "three", "four", "five")):onEach(function(it)
        evaluated:add("see " .. it)
    end):filter(function(it) return #it > 3 end):map(function(it) return it:upper() end):firstOrNull()
    print("  result=" .. __K2L_Str(result) .. " after " .. __K2L_Str(evaluated))
end

main()
return {collatz = collatz, primes = primes, sieve = sieve, fibonacci = fibonacci, digitsOf = digitsOf, isHappy = isHappy, Reading = Reading, SENSOR = SENSOR, parseReadings = parseReadings, fmt = fmt}
