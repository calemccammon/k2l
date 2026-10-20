local ____lualib = require("lualib_bundle")
local __K2L_Collectors = ____lualib.__K2L_Collectors
local __K2L_DoubleStream = ____lualib.__K2L_DoubleStream
local __K2L_DoubleSummaryStatistics = ____lualib.__K2L_DoubleSummaryStatistics
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_IntStream = ____lualib.__K2L_IntStream
local __K2L_IntSummaryStatistics = ____lualib.__K2L_IntSummaryStatistics
local __K2L_Iterator = ____lualib.__K2L_Iterator
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_LongStream = ____lualib.__K2L_LongStream
local __K2L_LongSummaryStatistics = ____lualib.__K2L_LongSummaryStatistics
local __K2L_NaturalOrder = ____lualib.__K2L_NaturalOrder
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Optional = ____lualib.__K2L_Optional
local __K2L_OptionalDouble = ____lualib.__K2L_OptionalDouble
local __K2L_OptionalLong = ____lualib.__K2L_OptionalLong
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Stream = ____lualib.__K2L_Stream
local __K2L_Streams = ____lualib.__K2L_Streams
local __K2L_SummaryStatistics = ____lualib.__K2L_SummaryStatistics
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf

local ____lambda_1 = function(it) return it * it end
local ____lambda_2 = function(it) return it * 3 end
local ____lambda_3 = function(it) return it * 1000000000 end
local ____lambda_4 = function(it) return it * 10 end
local ____lambda_5 = function(it) return #it end
local ____lambda_6 = function(x)
    return (x >= 0 and x % 2 or (x % 2 - 2) % (-2)) == 0
end
local ____lambda_7 = function(a, b) return a * b end
local ____lambda_8 = function(it) return "n" .. it end
local ____lambda_9 = function(it)
    return __K2L_ToInt32(it >= 0 and it // 10 or (it + 9) // 10)
end
local ____lambda_10 = function(it) return it end
local ____lambda_11 = function(it) return #it end
local ____lambda_12 = function(it)
    return __K2L_Streams.of(__K2L_IntStream, __K2L_ListOf(it, it * 10))
end
local ____lambda_13 = function(it)
    return __K2L_Streams.rangeLong(0, it, false)
end
local function longStreams()
    print(__K2L_Streams.rangeLong(1, 6, false):sum())
    print(__K2L_Str(__K2L_Streams.rangeLong(1, 5, true):map(____lambda_1):boxed():toList()))
    print(__K2L_Str(__K2L_Streams.of(__K2L_LongStream, __K2L_ListOf(3, 1, 2)):sorted():toArray():toList()))
    print(__K2L_Streams.of(__K2L_LongStream, __K2L_ListOf(5, 9, 2)):max():getAsLong() .. " " .. __K2L_Streams.of(__K2L_LongStream, __K2L_ListOf(5, 9, 2)):min():getAsLong() .. " " .. __K2L_Str(__K2L_Streams.empty(__K2L_LongStream):max()))
    print(__K2L_Str(__K2L_Streams.of(__K2L_LongStream, __K2L_ListOf(1, 2)):average():getAsDouble()) .. " " .. __K2L_Str(__K2L_Streams.empty(__K2L_LongStream):average()) .. " " .. __K2L_Str(__K2L_Streams.of(__K2L_LongStream, __K2L_ListOf(7)):max()))
    print(__K2L_Str(__K2L_Streams.iterate(__K2L_LongStream, 1, ____lambda_2):limit(5):boxed():toList()))
    print(__K2L_Streams.range(0, 4):asLongStream():map(____lambda_3):sum())
    print(__K2L_Str(__K2L_Streams.range(0, 4):mapToLong(____lambda_4):boxed():toList()))
    print(__K2L_Streams.of(__K2L_Stream, __K2L_ListOf("a", "bb", "ccc")):mapToLong(____lambda_5):sum())
    local ____value = __K2L_TypedArrayOf("[J", 4, 5, 6)
    local ____result
    ____result = __K2L_Streams.ofArray(__K2L_LongStream, ____value):filter(____lambda_6):count()
    print(____result)
    print(__K2L_Streams.rangeLong(1, 20, true):reduce(1, ____lambda_7))
    print(__K2L_Str(__K2L_Streams.of(__K2L_LongStream, __K2L_ListOf(1, 2, 3)):mapToObj(____lambda_8):collect(__K2L_Collectors.joining(","))))
    print(__K2L_Str(__K2L_Streams.of(__K2L_LongStream, __K2L_ListOf(1, 2, 3)):asDoubleStream():sum()))
    print(__K2L_Streams.of(__K2L_LongStream, __K2L_ListOf(10, 20)):mapToInt(____lambda_9):sum())
    print(__K2L_NotNull(__K2L_Streams.ofCollection(__K2L_ReadOnlyListOf(1, 2, 3)):collect(__K2L_Collectors.summingLong(____lambda_10))))
    print(__K2L_Str(__K2L_NotNull(__K2L_Streams.ofCollection(__K2L_ReadOnlyListOf("a", "bb")):collect(__K2L_Collectors.averagingLong(____lambda_11)))))
    print(__K2L_Str(__K2L_Streams.of(__K2L_Stream, __K2L_ListOf(1, 2)):flatMapToInt(____lambda_12):boxed():toList()))
    print(__K2L_Streams.of(__K2L_Stream, __K2L_ListOf(3, 4)):flatMapToLong(____lambda_13):count())
end

local ____lambda_14 = function(it) return it end
local ____lambda_15 = function(it)
    return (it >= 0 and it % 7 or 0 - -it % 7) == 0
end
local ____lambda_16 = function(it) return it * 2 end
local ____lambda_17 = function(a, b) return a + b end
local ____lambda_18 = function(it) return it > 95 end
local ____lambda_19 = function(it) return __K2L_Equals(it, 50) end
local function parallel()
    local numbers = __K2L_IntRange.new(1, 100):toList()
    print(__K2L_Streams.ofCollection(numbers, true):mapToInt(____lambda_14):sum())
    print(__K2L_Streams.ofCollection(numbers, true):filter(____lambda_15):count())
    print(__K2L_Str(__K2L_Streams.ofCollection(numbers, true):map(____lambda_16):toList():take(5)))
    print(__K2L_NotNull(__K2L_Streams.ofCollection(numbers, true):reduce(0, ____lambda_17)))
    print(__K2L_Streams.ofCollection(numbers, true):collect(__K2L_Collectors.toSet()).size)
    local ordered = __K2L_ListOf()
    __K2L_Streams.ofCollection(numbers, true):filter(____lambda_18):forEachOrdered(function(it)
        ordered:add(it)
    end)
    print(__K2L_Str(ordered))
    print(tostring(__K2L_Streams.ofCollection(numbers, true):isParallel()) .. " " .. tostring(__K2L_Streams.ofCollection(numbers):isParallel()) .. " " .. tostring(__K2L_Streams.ofCollection(numbers):parallel():isParallel()))
    print(__K2L_Streams.ofCollection(numbers, true):anyMatch(____lambda_19))
    print(__K2L_Streams.ofCollection(numbers):parallel():max(__K2L_NaturalOrder):get())
end

local ____lambda_20 = function(it) return it:upper() end
local function iterators()
    local it = __K2L_Streams.of(__K2L_Stream, __K2L_ListOf("x", "y", "z")):map(____lambda_20):iterator()
    while it:hasNext() do
        io.write(__K2L_Str(it:next()))
    end
    print()
    local seen = __K2L_ListOf()
    local lazy = __K2L_Streams.of(__K2L_Stream, __K2L_ListOf(1, 2, 3)):peek(function(it)
        seen:add("peek " .. it)
    end):iterator()
    seen:add("made")
    print(tostring(lazy:hasNext()) .. " " .. __K2L_Str(seen))
    print(__K2L_Str(lazy:next()) .. " " .. __K2L_Str(lazy:next()) .. " " .. __K2L_Str(seen))
    for _, n in __K2L_Iterator.iter(__K2L_Streams.range(0, 3):iterator()) do
        io.write(__K2L_Str(n) .. " ")
    end
    print()
    local ints = __K2L_Streams.of(__K2L_IntStream, __K2L_ListOf(4, 5)):iterator()
    print(ints:nextInt() .. " " .. __K2L_Str(ints:next()) .. " " .. tostring(ints:hasNext()))
    local ____ok, ____result_1 = pcall(function()
        ints:next()
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error, __K2L_NoSuchElementException) then
            local e = ____error
            print("done")
        else
            error(____error, 0)
        end
    end
end

local ____lambda_21 = function(it) return #it end
local ____lambda_22 = function(it) return #it end
local ____lambda_23 = function(it) return #it / 2.0 end
local ____lambda_24 = function(it) return #it end
local function statistics()
    local ints = __K2L_SummaryStatistics.of("Int", __K2L_Streams.of(__K2L_IntStream, __K2L_ListOf(4, 8, 15, 16, 23, 42)))
    print(__K2L_Str(ints))
    print(ints:getCount() .. " " .. ints:getSum() .. " " .. ints:getMin() .. " " .. ints:getMax() .. " " .. __K2L_Str(ints:getAverage()))
    print(__K2L_Str(__K2L_SummaryStatistics.of("Int", __K2L_Streams.empty(__K2L_IntStream))))
    print(__K2L_SummaryStatistics.of("Int", __K2L_Streams.of(__K2L_IntStream, __K2L_ListOf(2147483647, 2147483647))):getSum())
    print(__K2L_Str(__K2L_SummaryStatistics.of("Long", __K2L_Streams.of(__K2L_LongStream, __K2L_ListOf(5, 7)))))
    print(__K2L_SummaryStatistics.of("Long", __K2L_Streams.empty(__K2L_LongStream)):getCount())
    local doubles = __K2L_SummaryStatistics.of("Double", __K2L_Streams.of(__K2L_DoubleStream, __K2L_ListOf(1.5, 2.25, 3.0)))
    print(__K2L_Str(doubles))
    print(__K2L_Str(doubles:getSum()) .. " " .. __K2L_Str(doubles:getAverage()) .. " " .. __K2L_Str(doubles:getMin()) .. " " .. __K2L_Str(doubles:getMax()))
    print(__K2L_Str(__K2L_SummaryStatistics.of("Double", __K2L_Streams.empty(__K2L_DoubleStream))))
    local words = __K2L_ReadOnlyListOf("kotlin", "lua", "jvm", "transpiler")
    print(__K2L_Str(__K2L_Streams.ofCollection(words):collect(__K2L_SummaryStatistics.collector("Int", ____lambda_21))))
    print(__K2L_Streams.ofCollection(words):collect(__K2L_SummaryStatistics.collector("Long", ____lambda_22)):getMax())
    print(__K2L_Str(__K2L_Streams.ofCollection(words):collect(__K2L_SummaryStatistics.collector("Double", ____lambda_23))))
    local manual = __K2L_IntSummaryStatistics.new()
    manual:accept(3)
    manual:accept(-1)
    local other = __K2L_IntSummaryStatistics.new()
    other:accept(10)
    manual:combine(other)
    print(__K2L_Str(manual) .. " " .. __K2L_Str(manual:getAverage()))
    local longs = __K2L_LongSummaryStatistics.new()
    longs:accept(2)
    longs:accept(4)
    print(__K2L_Str(longs))
    local ds = __K2L_DoubleSummaryStatistics.new()
    ds:accept(0.1)
    ds:accept(0.2)
    print(__K2L_Str(ds:getSum()) .. " " .. __K2L_Str(ds))
    print(__K2L_Str(__K2L_SummaryStatistics.of("Int", __K2L_Streams.ofCollection(words):mapToInt(____lambda_24)):getAverage()))
end

local function main()
    longStreams()
    parallel()
    iterators()
    statistics()
end

main()
return {longStreams = longStreams, parallel = parallel, iterators = iterators, statistics = statistics}
