local ____lualib = require("lualib_bundle")
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_CharRange = ____lualib.__K2L_CharRange
local __K2L_CheckStep = ____lualib.__K2L_CheckStep
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_GenerateSequence = ____lualib.__K2L_GenerateSequence
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RunMain = ____lualib.__K2L_RunMain
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
local __K2L_Triple = ____lualib.__K2L_Triple
local __K2L_Truncate = ____lualib.__K2L_Truncate

local function collatz(start)
    return __K2L_GenerateSequence(start, function(n)
        if n == 1 then
            return nil
        elseif n % 2 == 0 then
            return n // 2
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
        local limit = __K2L_Truncate(math.sqrt(candidate + 0.0))
        local ____list = found:takeWhile(function(it) return it <= limit end)
        local ____result = true
        local ____items, ____n = ____list:____array()
        for ____i = 1, ____n do
            local it = ____items[____i]
            if candidate % it == 0 then
                ____result = false
                break
            end
        end
        if ____result then
            found:add(candidate)
            self:yield(candidate)
        end
        candidate = candidate + 2
    end
end)

local function sieve(n)
    local composite = __K2L_ListOfSize(n + 1, false, true)
    for i = 2, n do
        do
            if composite:get(i) then
                goto ____continue
            end
            for j = i * i, n, __K2L_CheckStep(i) do
                composite:set(j, true)
            end
        end
        ::____continue::
    end
    return __K2L_IntRange.new(2, n):filterNot(function(it) return composite:get(it) end)
end

local ____lambda_1 = function(it) return it.first end
local function fibonacci()
    return __K2L_GenerateSequence(__K2L_Pair.new(0, 1), function(____destructured)
        local a, b = ____destructured.first, ____destructured.second
        return __K2L_Pair.new(b, a + b)
    end):map(____lambda_1)
end

local ____lambda_2 = function(it) return __K2L_Num.digitToInt(it) end
local function digitsOf(n)
    return __K2L_StringToList(tostring(n)):map(____lambda_2)
end

local ____lambda_3 = function(it)
    return (it:byte() - ("0"):byte()) * (it:byte() - ("0"):byte())
end
local ____lambda_4 = function(x)
    return __K2L_StringToList(tostring(x)):sumOf(____lambda_3)
end
local function isHappy(n)
    local seen = __K2L_SetOf()
    return __K2L_GenerateSequence(n, ____lambda_4):first(function(it) return it == 1 or not seen:add(it) end) == 1
end

local Reading = __K2L_Class("Reading")

function Reading:____init(minute, celsius)
    self.minute = minute
    self.celsius = celsius
end

function Reading.new(minute, celsius)
    return setmetatable({minute = minute, celsius = celsius}, Reading)
end

function Reading:toString()
    return "Reading(minute=" .. self.minute .. ", celsius=" .. self.celsius .. ")"
end

function Reading:hashCode()
    return (31 * self.minute + __K2L_Hash(self.celsius) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Reading:equals(other)
    return getmetatable(other) == Reading and self.minute == other.minute and self.celsius == other.celsius
end

local SENSOR = __K2L_Text.trimIndent("\n    0 21.5\n    1 21.7\n    2 22.4\n    3 23.9\n    4 24.1\n    5 99.9\n    6 24.6\n    7 24.2\n    8 23.0\n    9 22.1\n    10 21.4\n    11 20.9\n    12 -40.0\n    13 20.5\n    14 20.8\n    15 21.6\n")

local ____lambda_5 = function(it) return __K2L_StringSplit(it, " ") end
local function parseReadings(text)
    return __K2L_AsSequence(__K2L_StringLines(text)):map(____lambda_5):map(function(____destructured_1)
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

local ____lambda_6 = function(it) return collatz(it):count() end
local ____lambda_7 = function(a, b) return b - a end
local ____lambda_8 = function(it) return #tostring(it.value) >= 12 end
local ____lambda_9 = function(it) return it < 4000000 end
local ____lambda_10 = function(it) return it % 2 == 0 end
local ____lambda_11 = function(it) return fmt(it, 1) end
local ____lambda_12 = function(it) return it:average() end
local ____lambda_13 = function(it) return it.celsius < 23 end
local ____lambda_14 = function(it) return it.celsius >= 23 end
local ____lambda_15 = function(it) return it.minute end
local ____lambda_16 = function(it) return it + 2 end
local ____lambda_17 = function(it) return it * it end
local ____lambda_18 = function(i, _) return i % 5 == 0 end
local ____lambda_19 = function(it) return #it > 3 end
local ____lambda_20 = function(it) return it:upper() end
local function main()
    local longest = __K2L_IntRange.new(1, 30):maxBy(____lambda_6)
    print("collatz(27) has " .. collatz(27):count() .. " terms, peak " .. collatz(27):max())
    print("longest under 30: " .. longest .. " (" .. collatz(longest):count() .. " terms)")
    print("collatz(6) = " .. collatz(6):joinToString(" -> "))
    print("first primes: " .. __K2L_Str(primes:take(15):toList()))
    print("100th prime: " .. primes:elementAt(99) .. "; sieve agrees: " .. sieve(541):last())
    local ____list_1 = sieve(100)
    local ____result_1 = __K2L_Map.new()
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        local ____value = it % 10
        local ____group = ____result_1:get(____value)
        if ____group == nil then
            ____group = __K2L_List.new()
            ____result_1:put(____value, ____group)
        end
        ____group:add(it)
    end
    print("primes below 100 by last digit: " .. __K2L_Str(____result_1:toSortedMap()))
    local twin = primes:zipWithNext():filter(function(____destructured_2)
        local a, b = ____destructured_2.first, ____destructured_2.second
        return b - a == 2
    end):take(6):toList()
    print("twin primes: " .. __K2L_Str(twin))
    local gaps = sieve(1000):zipWithNext(____lambda_7)
    print("max prime gap below 1000: " .. gaps:max() .. " after " .. sieve(1000):get(gaps:indexOf(gaps:max())))
    print("fibonacci: " .. fibonacci():take(20):joinToString())
    local firstBig = fibonacci():withIndex():first(____lambda_8)
    print("first 12-digit fibonacci: F(" .. firstBig.index .. ") = " .. firstBig.value)
    print("even fib sum below 4M: " .. fibonacci():takeWhile(____lambda_9):filter(____lambda_10):sum())
    print("digit sum of F(55): " .. digitsOf(fibonacci():elementAt(55)):sum())
    print("happy numbers: " .. __K2L_Str(__K2L_IntRange.new(1, 50):filter(isHappy)))
    local readings = parseReadings(SENSOR):toList()
    local median3 = readings:windowed(3, nil, nil, function(w)
        local ____out = {}
        local ____count = 0
        local ____items_2, ____n_2 = w:____array()
        for ____i_2 = 1, ____n_2 do
            local it = ____items_2[____i_2]
            ____count = ____count + 1
            ____out[____count] = it.celsius
        end
        return __K2L_ListWrap(____out, ____count):sorted():get(1)
    end)
    print("median-of-3: " .. median3:joinToString(nil, nil, nil, nil, nil, ____lambda_11))
    local ____list_2 = readings:windowed(3)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_3, ____n_3 = ____list_2:____array()
    for ____i_3 = 1, ____n_3 do
        local ____it = ____items_3[____i_3]
        local ____result_2
        do
            local a, b, c = ____it[1], ____it[2], ____it[3]
            ____result_2 = math.abs(b.celsius - (a.celsius + c.celsius) / 2) > 10
        end
        if ____result_2 then
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = ____it
        end
    end
    local ____list_3 = __K2L_ListWrap(____out_1, ____count_1)
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_4, ____n_4 = ____list_3:____array()
    for ____i_4 = 1, ____n_4 do
        local it = ____items_4[____i_4]
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = it:get(1)
    end
    local outliers = __K2L_ListWrap(____out_2, ____count_2)
    print("outliers: " .. __K2L_Str(outliers))
    local ____out_3 = {}
    local ____count_3 = 0
    local ____items_5, ____n_5 = readings:____array()
    for ____i_5 = 1, ____n_5 do
        local it = ____items_5[____i_5]
        if not outliers:contains(it) then
            ____count_3 = ____count_3 + 1
            ____out_3[____count_3] = it
        end
    end
    local clean = __K2L_ListWrap(____out_3, ____count_3)
    local ____out_4 = {}
    local ____count_4 = 0
    local ____items_6, ____n_6 = clean:____array()
    for ____i_6 = 1, ____n_6 do
        local it = ____items_6[____i_6]
        ____count_4 = ____count_4 + 1
        ____out_4[____count_4] = it.celsius
    end
    local movingAvg = __K2L_ListWrap(____out_4, ____count_4):windowed(4, 2, true, ____lambda_12)
    local ____out_5 = {}
    local ____count_5 = 0
    local ____items_7, ____n_7 = movingAvg:____array()
    for ____i_7 = 1, ____n_7 do
        local it = ____items_7[____i_7]
        ____count_5 = ____count_5 + 1
        ____out_5[____count_5] = fmt(it)
    end
    print("moving average (4, step 2): " .. __K2L_Str(__K2L_ListWrap(____out_5, ____count_5)))
    local chunks = clean:chunked(5, function(chunk)
        local ____arg = chunk:first().minute
        local ____arg_1 = chunk:last().minute
        local ____best
        local ____has = false
        local ____items_8, ____n_8 = chunk:____array()
        for ____i_8 = 1, ____n_8 do
            local it = ____items_8[____i_8]
            local ____key = it.celsius
            if not ____has or __K2L_Compare(____best, ____key) < 0 then
                ____best = ____key
                ____has = true
            end
        end
        if not ____has then
            error(__K2L_NoSuchElementException.new(nil))
        end
        return ____arg .. "-" .. ____arg_1 .. ": max " .. ____best
    end)
    for ____i_9 = 1, chunks.size do
        local it = chunks[____i_9]
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
    print("runs: " .. runs:joinToString(" ", nil, nil, nil, nil, function(____destructured_3)
        local c, n = ____destructured_3.first, ____destructured_3.second
        return c .. n
    end))
    local warm = __K2L_AsSequence(clean):dropWhile(____lambda_13):takeWhile(____lambda_14):map(____lambda_15):toList()
    print("warm spell minutes: " .. __K2L_Str(warm))
    local triangular = __K2L_GenerateSequence(__K2L_Pair.new(1, 1), function(____destructured_4)
        local n, t = ____destructured_4.first, ____destructured_4.second
        return __K2L_Pair.new(n + 1, t + n + 1)
    end)
    local firstWithDivisors = triangular:first(function(____destructured_5)
        local t = ____destructured_5.second
        return __K2L_IntRange.new(1, t):count(function(it) return t % it == 0 end) > 20
    end)
    print("first triangular number with >20 divisors: " .. firstWithDivisors.second .. " (n=" .. firstWithDivisors.first .. ")")
    local evens = __K2L_GenerateSequence(0, ____lambda_16)
    print("evens: " .. __K2L_Str(evens:take(5):toList()) .. " squares of odds: " .. __K2L_Str(__K2L_IntRange.new(1, 20):withStep(2):map(____lambda_17)))
    local countdown = __K2L_IntRange.new(10, 0, -1):withStep(3):toList()
    print("countdown " .. __K2L_Str(countdown) .. ", sum " .. countdown:sum() .. ", reversed " .. __K2L_Str(countdown:asReversed()))
    local chars = __K2L_CharRange.new("a", "z"):filterIndexed(____lambda_18):joinToString("")
    local ____list_4 = __K2L_CharRange.new("A", "F"):toList():chunked(2)
    local ____out_6 = {}
    local ____count_6 = 0
    local ____items_9, ____n_9 = ____list_4:____array()
    for ____i_10 = 1, ____n_9 do
        local it = ____items_9[____i_10]
        ____count_6 = ____count_6 + 1
        ____out_6[____count_6] = it:joinToString("")
    end
    print("letters: " .. chars .. " " .. __K2L_Str(__K2L_ListWrap(____out_6, ____count_6)))
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
    local result = __K2L_AsSequence(__K2L_ListOf("one", "two", "three", "four", "five")):onEach(function(it)
        evaluated:add("see " .. it)
    end):filter(____lambda_19):map(____lambda_20):firstOrNull()
    print("  result=" .. __K2L_Str(result) .. " after " .. __K2L_Str(evaluated))
end

__K2L_RunMain(main)
return {collatz = collatz, primes = primes, sieve = sieve, fibonacci = fibonacci, digitsOf = digitsOf, isHappy = isHappy, Reading = Reading, SENSOR = SENSOR, parseReadings = parseReadings, fmt = fmt}
