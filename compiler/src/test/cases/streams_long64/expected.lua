local ____lualib = require("lualib_bundle")
local __K2L_Collectors = ____lualib.__K2L_Collectors
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_LongStream = ____lualib.__K2L_LongStream
local __K2L_LongSummaryStatistics = ____lualib.__K2L_LongSummaryStatistics
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_OptionalDouble = ____lualib.__K2L_OptionalDouble
local __K2L_OptionalLong = ____lualib.__K2L_OptionalLong
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Streams = ____lualib.__K2L_Streams
local __K2L_SummaryStatistics = ____lualib.__K2L_SummaryStatistics

local ____lambda_1 = function(it) return it * 2 end
local ____lambda_2 = function(it) return it * 10 end
local ____lambda_3 = function(a, b) return a + b end
local ____lambda_4 = function(it) return it end
local ____lambda_5 = function(it) return it end
local ____lambda_6 = function(it)
    return it >= 0 and it // 1000 or (it + 999) // 1000
end
local ____lambda_7 = function(it) return it end
local function main()
    local big = 4000000000000000000
    print(__K2L_Streams.of(__K2L_LongStream, __K2L_ListOf(big, big, 1)):sum())
    print(__K2L_Streams.of(__K2L_LongStream, __K2L_ListOf(9223372036854775807, 1)):sum())
    print(__K2L_Str(__K2L_Streams.rangeLong(9223372036854775807 - 2, 9223372036854775807, true):boxed():toList()))
    print(__K2L_Str(__K2L_Streams.rangeLong(9007199254740990, 9007199254740995, false):map(____lambda_1):boxed():toList()))
    print(__K2L_Streams.of(__K2L_LongStream, __K2L_ListOf(big, -big, 3)):max():getAsLong() .. " " .. __K2L_Streams.of(__K2L_LongStream, __K2L_ListOf(big, -big, 3)):min():getAsLong())
    print(__K2L_Str(__K2L_Streams.of(__K2L_LongStream, __K2L_ListOf(big, big)):average():getAsDouble()))
    print(__K2L_Streams.iterate(__K2L_LongStream, 1, ____lambda_2):limit(19):reduce(0, ____lambda_3))
    print(__K2L_Str(__K2L_SummaryStatistics.of("Long", __K2L_Streams.of(__K2L_LongStream, __K2L_ListOf(big, 2)))))
    print(__K2L_Str(__K2L_LongSummaryStatistics.new()))
    local values = __K2L_ReadOnlyListOf(big, big, 7)
    print(__K2L_NotNull(__K2L_Streams.ofCollection(values):collect(__K2L_Collectors.summingLong(____lambda_4))))
    print(__K2L_Streams.ofCollection(values):collect(__K2L_SummaryStatistics.collector("Long", ____lambda_5)):getSum())
    print(__K2L_Streams.ofCollection(values):mapToLong(____lambda_6):sum())
    print(__K2L_Streams.ofCollection(values, true):mapToLong(____lambda_7):max():getAsLong())
end

main()
