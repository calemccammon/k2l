local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Collectors = ____lualib.__K2L_Collectors
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_DoubleStream = ____lualib.__K2L_DoubleStream
local __K2L_DoubleToInt = ____lualib.__K2L_DoubleToInt
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IntStream = ____lualib.__K2L_IntStream
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Optional = ____lualib.__K2L_Optional
local __K2L_OptionalDouble = ____lualib.__K2L_OptionalDouble
local __K2L_OptionalInt = ____lualib.__K2L_OptionalInt
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_ReverseOrder = ____lualib.__K2L_ReverseOrder
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Stream = ____lualib.__K2L_Stream
local __K2L_Streams = ____lualib.__K2L_Streams
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32

local Person = __K2L_Class("Person")

function Person:____init(name, age, city)
    self.name = name
    self.age = age
    self.city = city
end

function Person:toString()
    return "Person(name=" .. self.name .. ", age=" .. self.age .. ", city=" .. self.city .. ")"
end

function Person:hashCode()
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.name) + __K2L_Hash(self.age)) + __K2L_Hash(self.city))
end

function Person:equals(other)
    return getmetatable(other) == Person and self.name == other.name and self.age == other.age and self.city == other.city
end

local function sources()
    print(__K2L_Streams.range(0, 5):sum())
    print(__K2L_Streams.rangeClosed(1, 5):sum())
    print(__K2L_Streams.range(5, 5):count())
    print(__K2L_Streams.range(5, 2):sum())
    print(__K2L_Str(__K2L_Streams.of(__K2L_IntStream, __K2L_ListOf(5, 6, 7)):boxed():collect(__K2L_Collectors.toList())))
    print(__K2L_Streams.of(__K2L_IntStream, __K2L_ListOf(9)):sum())
    print(__K2L_Streams.empty(__K2L_IntStream):sum())
    print(__K2L_Streams.ofArray(__K2L_IntStream, __K2L_ArrayOf(4, 8, 15, 16, 23, 42)):sum())
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_IntStream, __K2L_ArrayOf(4, 8, 15, 16, 23, 42), 1, 4):boxed():toList()))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_Stream, __K2L_ArrayOf("p", "q", "r")):map(function(it) return it:upper() end):toList()))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_DoubleStream, __K2L_ArrayOf(1.5, 2.5, 4.0)):sum()))
    local list = __K2L_ReadOnlyListOf(3, 1, 2)
    print(__K2L_Str(__K2L_Streams.ofCollection(list):map(function(it) return it * 2 end):collect(__K2L_Collectors.toList())))
    print(__K2L_Streams.ofCollection(__K2L_ReadOnlySetOf("x", "y")):count())
    print(__K2L_Str(__K2L_Streams.of(__K2L_Stream, __K2L_ListOf("a", "b", "c")):collect(__K2L_Collectors.joining(", "))))
    print(__K2L_Str(__K2L_Streams.of(__K2L_Stream, __K2L_ListOf(1, 2, 3)):toList()))
    print(__K2L_Streams.empty(__K2L_Stream):count())
    print(__K2L_Str(__K2L_Streams.concat(__K2L_Stream, __K2L_Streams.of(__K2L_Stream, __K2L_ListOf(1, 2)), __K2L_Streams.of(__K2L_Stream, __K2L_ListOf(3))):toList()))
    print(__K2L_Str(__K2L_Streams.concat(__K2L_IntStream, __K2L_Streams.range(0, 2), __K2L_Streams.range(10, 12)):boxed():toList()))
    print(__K2L_Str(__K2L_Streams.iterate(__K2L_Stream, 1, function(it) return it * 2 end):limit(8):toList()))
    print(__K2L_Str(__K2L_Streams.iterate(__K2L_Stream, 1, function(it) return it < 50 end, function(it) return it * 3 end):toList()))
    print(__K2L_Str(__K2L_Streams.iterate(__K2L_IntStream, 10, function(it) return it - 3 end):limit(4):boxed():toList()))
    local seed = 0
    print(__K2L_Str(__K2L_Streams.generate(__K2L_Stream, function()
        local ____old = seed
        seed = seed + 1
        return ____old
    end):limit(4):toList()))
    print(__K2L_Str(__K2L_Streams.of(__K2L_DoubleStream, __K2L_ListOf(0.5, 1.5)):sum()))
end

local function intStreams()
    local numbers = __K2L_ArrayOf(5, 3, 8, 1, 9, 2, 8)
    print(__K2L_Streams.ofArray(__K2L_IntStream, numbers):max():getAsInt())
    print(__K2L_Streams.ofArray(__K2L_IntStream, numbers):min():getAsInt())
    print(__K2L_Streams.ofArray(__K2L_IntStream, numbers):max():isPresent())
    print(__K2L_Streams.empty(__K2L_IntStream):max():isPresent())
    print(__K2L_Streams.empty(__K2L_IntStream):max():isEmpty())
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_IntStream, numbers):average():getAsDouble()))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_IntStream, numbers):average()))
    print(__K2L_Str(__K2L_Streams.empty(__K2L_IntStream):average()))
    print(__K2L_Streams.ofArray(__K2L_IntStream, numbers):count())
    print(__K2L_Streams.ofArray(__K2L_IntStream, numbers):filter(function(it) return it > 4 end):count())
    print(__K2L_Streams.ofArray(__K2L_IntStream, numbers):map(function(it) return it * it end):sum())
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_IntStream, numbers):sorted():boxed():toList()))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_IntStream, numbers):distinct():sorted():boxed():toList()))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_IntStream, numbers):limit(3):boxed():toList()))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_IntStream, numbers):skip(4):boxed():toList()))
    print(__K2L_Streams.ofArray(__K2L_IntStream, numbers):skip(2):limit(3):sum())
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_IntStream, numbers):toArray():toList()))
    print(__K2L_Streams.ofArray(__K2L_IntStream, numbers):map(function(it) return it + 1 end):toArray():contentToString())
    print(__K2L_Streams.ofArray(__K2L_IntStream, numbers):anyMatch(function(it) return it == 9 end))
    print(__K2L_Streams.ofArray(__K2L_IntStream, numbers):allMatch(function(it) return it > 0 end))
    print(__K2L_Streams.ofArray(__K2L_IntStream, numbers):noneMatch(function(it) return it > 100 end))
    print(__K2L_Streams.ofArray(__K2L_IntStream, numbers):allMatch(function(it) return it > 1 end))
    print(__K2L_Streams.ofArray(__K2L_IntStream, numbers):reduce(0, function(a, b) return a + b end))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_IntStream, numbers):reduce(function(a, b) return a * b end)))
    print(__K2L_Str(__K2L_Streams.empty(__K2L_IntStream):reduce(function(a, b) return a + b end)))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_IntStream, numbers):findFirst()))
    print(__K2L_Str(__K2L_Streams.empty(__K2L_IntStream):findFirst()))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_IntStream, numbers):takeWhile(function(it) return it ~= 1 end):boxed():toList()))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_IntStream, numbers):dropWhile(function(it) return it ~= 1 end):boxed():toList()))
    print(__K2L_Str(__K2L_Streams.rangeClosed(1, 4):mapToObj(function(it) return "n" .. it end):collect(__K2L_Collectors.joining("-", "<", ">"))))
    print(__K2L_Str(__K2L_Streams.rangeClosed(1, 4):asDoubleStream():sum()))
    print(__K2L_Str(__K2L_Streams.rangeClosed(1, 4):mapToDouble(function(it) return it / 2.0 end):sum()))
    print(__K2L_Str(__K2L_Streams.range(0, 4):flatMap(function(it) return __K2L_Streams.range(0, it) end):boxed():toList()))
    local total = 0
    __K2L_Streams.range(0, 5):forEach(function(it)
        total = total + it
    end)
    print(total)
    print(__K2L_Streams.of(__K2L_IntStream, __K2L_ListOf(2147483647, 1)):sum())
    print(__K2L_Streams.range(0, 100):filter(function(it) return math.fmod(it, 7) == 0 end):max():getAsInt())
    print(__K2L_Str(__K2L_Streams.range(0, 10):boxed():map(function(it) return it * 2 end):filter(function(it) return it > 10 end):toList()))
end

local function doubleStreams()
    local values = __K2L_ArrayOf(0.1, 0.2, 0.3, 0.4, 1.0E10, -1.0E10)
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_DoubleStream, values):sum()))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_DoubleStream, __K2L_ArrayOf(0.1, 0.2, 0.3)):sum()))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_DoubleStream, __K2L_ArrayOf(0.1, 0.2, 0.3)):average()))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_DoubleStream, values):max():getAsDouble()))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_DoubleStream, values):min():getAsDouble()))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_DoubleStream, values):filter(function(it) return it < 1 and it > 0 end):map(function(it) return it * 2 end):boxed():toList()))
    print(__K2L_Streams.ofArray(__K2L_DoubleStream, values):filter(function(it) return it > 0.25 end):count())
    print(__K2L_Streams.empty(__K2L_DoubleStream):average():isPresent())
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_DoubleStream, __K2L_ArrayOf(0.5, 1.5)):mapToObj(function(it) return "v" .. __K2L_Str(it) end):toList()))
    print(__K2L_Streams.ofArray(__K2L_DoubleStream, __K2L_ArrayOf(2.5, 3.5)):mapToInt(function(it) return __K2L_DoubleToInt(it) end):sum())
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_DoubleStream, __K2L_ArrayOf(1.5, 2.5, 3.5)):toArray():toList()))
end

local function objectStreams()
    local words = __K2L_ReadOnlyListOf("pear", "fig", "apple", "kiwi", "banana", "fig")
    print(__K2L_Str(__K2L_Streams.ofCollection(words):filter(function(it) return #it > 3 end):collect(__K2L_Collectors.toList())))
    print(__K2L_Str(__K2L_Streams.ofCollection(words):map(function(it) return #it end):collect(__K2L_Collectors.toList())))
    print(__K2L_Str(__K2L_Streams.ofCollection(words):sorted():toList()))
    print(__K2L_Str(__K2L_Streams.ofCollection(words):sorted(__K2L_ReverseOrder):toList()))
    print(__K2L_Str(__K2L_Streams.ofCollection(words):sorted(function(a, b) return #a - #b end):toList()))
    print(__K2L_Str(__K2L_Streams.ofCollection(words):distinct():toList()))
    print(__K2L_Str(__K2L_Streams.ofCollection(words):skip(2):limit(2):toList()))
    print(__K2L_Streams.ofCollection(words):mapToInt(function(it) return #it end):sum())
    print(__K2L_Streams.ofCollection(words):mapToInt(function(it) return #it end):max():getAsInt())
    print(__K2L_Streams.ofCollection(words):anyMatch(function(it) return __K2L_Equals(it, "kiwi") end))
    print(__K2L_Streams.ofCollection(words):allMatch(function(it) return #it > 0 end))
    print(__K2L_Streams.ofCollection(words):noneMatch(function(it) return __K2L_StringStartsWith(it, "z") end))
    print(__K2L_Streams.ofCollection(words):findFirst():get())
    print(__K2L_Str(__K2L_Streams.ofCollection(words):filter(function(it) return __K2L_StringStartsWith(it, "b") end):findFirst():orElse("none")))
    print(__K2L_Str(__K2L_Streams.ofCollection(words):filter(function(it) return __K2L_StringStartsWith(it, "z") end):findFirst():orElse("none")))
    print(__K2L_Streams.ofCollection(words):max(__K2L_CompareBy(function(it) return #it end)):get())
    print(__K2L_Streams.ofCollection(words):min(__K2L_CompareBy(function(it) return #it end)):get())
    print(__K2L_Streams.ofCollection(words):max(function(a, b) return __K2L_Text.compare(a, b) end):get())
    print(__K2L_Str(__K2L_Streams.ofCollection(words):reduce("", function(a, b) return a .. __K2L_Text.first(b) end)))
    print(__K2L_Str(__K2L_Streams.ofCollection(words):reduce(function(a, b) return #a >= #b and a or b end)))
    print(__K2L_Str(__K2L_Streams.ofCollection(words):flatMap(function(it)
        return __K2L_Streams.of(__K2L_Stream, __K2L_ListOf(it, it:upper()))
    end):limit(5):toList()))
    print(__K2L_Streams.ofCollection(words):count())
    print(__K2L_Streams.ofCollection(words):toArray().size)
    __K2L_Streams.ofCollection(words):limit(2):forEach(function(it)
        print("word " .. __K2L_Str(it))
    end)
    print(__K2L_Str(__K2L_Streams.ofCollection(words):takeWhile(function(it) return not __K2L_Equals(it, "apple") end):toList()))
    print(__K2L_Str(__K2L_Streams.ofCollection(words):dropWhile(function(it) return not __K2L_Equals(it, "apple") end):toList()))
end

local function main()
    sources()
    intStreams()
    doubleStreams()
    objectStreams()
end

main()
return {Person = Person, sources = sources, intStreams = intStreams, doubleStreams = doubleStreams, objectStreams = objectStreams}
