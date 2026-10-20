local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Collectors = ____lualib.__K2L_Collectors
local __K2L_CompareValues = ____lualib.__K2L_CompareValues
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
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf

local Person = __K2L_Class("Person")

function Person:____init(name, age, city)
    self.name = name
    self.age = age
    self.city = city
end

function Person.new(name, age, city)
    return setmetatable({name = name, age = age, city = city}, Person)
end

function Person:toString()
    return "Person(name=" .. self.name .. ", age=" .. self.age .. ", city=" .. self.city .. ")"
end

function Person:hashCode()
    return (31 * (31 * __K2L_Hash(self.name) + self.age) + __K2L_Hash(self.city) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Person:equals(other)
    return getmetatable(other) == Person and self.name == other.name and self.age == other.age and self.city == other.city
end

local ____lambda_1 = function(it) return it:upper() end
local ____lambda_2 = function(it) return it * 2 end
local ____lambda_3 = function(it) return it * 2 end
local ____lambda_4 = function(it) return it < 50 end
local ____lambda_5 = function(it) return it * 3 end
local ____lambda_6 = function(it) return it - 3 end
local function sources()
    print(__K2L_Streams.range(0, 5):sum())
    print(__K2L_Streams.rangeClosed(1, 5):sum())
    print(__K2L_Streams.range(5, 5):count())
    print(__K2L_Streams.range(5, 2):sum())
    print(__K2L_Str(__K2L_Streams.of(__K2L_IntStream, __K2L_ListOf(5, 6, 7)):boxed():collect(__K2L_Collectors.toList())))
    print(__K2L_Streams.of(__K2L_IntStream, __K2L_ListOf(9)):sum())
    print(__K2L_Streams.empty(__K2L_IntStream):sum())
    print(__K2L_Streams.ofArray(__K2L_IntStream, __K2L_TypedArrayOf("[I", 4, 8, 15, 16, 23, 42)):sum())
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_IntStream, __K2L_TypedArrayOf("[I", 4, 8, 15, 16, 23, 42), 1, 4):boxed():toList()))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_Stream, __K2L_TypedArrayOf("[Ljava.lang.String;", "p", "q", "r")):map(____lambda_1):toList()))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_DoubleStream, __K2L_TypedArrayOf("[D", 1.5, 2.5, 4.0)):sum()))
    local list = __K2L_ReadOnlyListOf(3, 1, 2)
    print(__K2L_Str(__K2L_Streams.ofCollection(list):map(____lambda_2):collect(__K2L_Collectors.toList())))
    print(__K2L_Streams.ofCollection(__K2L_ReadOnlySetOf("x", "y")):count())
    print(__K2L_Str(__K2L_Streams.of(__K2L_Stream, __K2L_ListOf("a", "b", "c")):collect(__K2L_Collectors.joining(", "))))
    print(__K2L_Str(__K2L_Streams.of(__K2L_Stream, __K2L_ListOf(1, 2, 3)):toList()))
    print(__K2L_Streams.empty(__K2L_Stream):count())
    print(__K2L_Str(__K2L_Streams.concat(__K2L_Stream, __K2L_Streams.of(__K2L_Stream, __K2L_ListOf(1, 2)), __K2L_Streams.of(__K2L_Stream, __K2L_ListOf(3))):toList()))
    print(__K2L_Str(__K2L_Streams.concat(__K2L_IntStream, __K2L_Streams.range(0, 2), __K2L_Streams.range(10, 12)):boxed():toList()))
    print(__K2L_Str(__K2L_Streams.iterate(__K2L_Stream, 1, ____lambda_3):limit(8):toList()))
    print(__K2L_Str(__K2L_Streams.iterate(__K2L_Stream, 1, ____lambda_4, ____lambda_5):toList()))
    print(__K2L_Str(__K2L_Streams.iterate(__K2L_IntStream, 10, ____lambda_6):limit(4):boxed():toList()))
    local seed = 0
    print(__K2L_Str(__K2L_Streams.generate(__K2L_Stream, function()
        local ____old = seed
        seed = seed + 1
        return ____old
    end):limit(4):toList()))
    print(__K2L_Str(__K2L_Streams.of(__K2L_DoubleStream, __K2L_ListOf(0.5, 1.5)):sum()))
end

local ____lambda_7 = function(it) return it > 4 end
local ____lambda_8 = function(it) return it * it end
local ____lambda_9 = function(it) return it + 1 end
local ____lambda_10 = function(it) return it == 9 end
local ____lambda_11 = function(it) return it > 0 end
local ____lambda_12 = function(it) return it > 100 end
local ____lambda_13 = function(it) return it > 1 end
local ____lambda_14 = function(a, b) return a + b end
local ____lambda_15 = function(a, b) return a * b end
local ____lambda_16 = function(a, b) return a + b end
local ____lambda_17 = function(it) return it ~= 1 end
local ____lambda_18 = function(it) return it ~= 1 end
local ____lambda_19 = function(it) return "n" .. it end
local ____lambda_20 = function(it) return it / 2.0 end
local ____lambda_21 = function(it) return __K2L_Streams.range(0, it) end
local ____lambda_22 = function(it)
    return (it >= 0 and it % 7 or 0 - -it % 7) == 0
end
local ____lambda_23 = function(it) return it * 2 end
local ____lambda_24 = function(it) return it > 10 end
local function intStreams()
    local numbers = __K2L_TypedArrayOf("[I", 5, 3, 8, 1, 9, 2, 8)
    print(__K2L_Streams.ofArray(__K2L_IntStream, numbers):max():getAsInt())
    print(__K2L_Streams.ofArray(__K2L_IntStream, numbers):min():getAsInt())
    print(__K2L_Streams.ofArray(__K2L_IntStream, numbers):max():isPresent())
    print(__K2L_Streams.empty(__K2L_IntStream):max():isPresent())
    print(__K2L_Streams.empty(__K2L_IntStream):max():isEmpty())
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_IntStream, numbers):average():getAsDouble()))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_IntStream, numbers):average()))
    print(__K2L_Str(__K2L_Streams.empty(__K2L_IntStream):average()))
    print(__K2L_Streams.ofArray(__K2L_IntStream, numbers):count())
    print(__K2L_Streams.ofArray(__K2L_IntStream, numbers):filter(____lambda_7):count())
    print(__K2L_Streams.ofArray(__K2L_IntStream, numbers):map(____lambda_8):sum())
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_IntStream, numbers):sorted():boxed():toList()))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_IntStream, numbers):distinct():sorted():boxed():toList()))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_IntStream, numbers):limit(3):boxed():toList()))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_IntStream, numbers):skip(4):boxed():toList()))
    print(__K2L_Streams.ofArray(__K2L_IntStream, numbers):skip(2):limit(3):sum())
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_IntStream, numbers):toArray():toList()))
    print(__K2L_Streams.ofArray(__K2L_IntStream, numbers):map(____lambda_9):toArray():contentToString())
    print(__K2L_Streams.ofArray(__K2L_IntStream, numbers):anyMatch(____lambda_10))
    print(__K2L_Streams.ofArray(__K2L_IntStream, numbers):allMatch(____lambda_11))
    print(__K2L_Streams.ofArray(__K2L_IntStream, numbers):noneMatch(____lambda_12))
    print(__K2L_Streams.ofArray(__K2L_IntStream, numbers):allMatch(____lambda_13))
    print(__K2L_Streams.ofArray(__K2L_IntStream, numbers):reduce(0, ____lambda_14))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_IntStream, numbers):reduce(____lambda_15)))
    print(__K2L_Str(__K2L_Streams.empty(__K2L_IntStream):reduce(____lambda_16)))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_IntStream, numbers):findFirst()))
    print(__K2L_Str(__K2L_Streams.empty(__K2L_IntStream):findFirst()))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_IntStream, numbers):takeWhile(____lambda_17):boxed():toList()))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_IntStream, numbers):dropWhile(____lambda_18):boxed():toList()))
    print(__K2L_Str(__K2L_Streams.rangeClosed(1, 4):mapToObj(____lambda_19):collect(__K2L_Collectors.joining("-", "<", ">"))))
    print(__K2L_Str(__K2L_Streams.rangeClosed(1, 4):asDoubleStream():sum()))
    print(__K2L_Str(__K2L_Streams.rangeClosed(1, 4):mapToDouble(____lambda_20):sum()))
    print(__K2L_Str(__K2L_Streams.range(0, 4):flatMap(____lambda_21):boxed():toList()))
    local total = 0
    __K2L_Streams.range(0, 5):forEach(function(it)
        total = total + it
    end)
    print(total)
    print(__K2L_Streams.of(__K2L_IntStream, __K2L_ListOf(2147483647, 1)):sum())
    print(__K2L_Streams.range(0, 100):filter(____lambda_22):max():getAsInt())
    print(__K2L_Str(__K2L_Streams.range(0, 10):boxed():map(____lambda_23):filter(____lambda_24):toList()))
end

local ____lambda_25 = function(it) return it < 1 and it > 0 end
local ____lambda_26 = function(it) return it * 2 end
local ____lambda_27 = function(it) return it > 0.25 end
local ____lambda_28 = function(it) return "v" .. __K2L_Str(it) end
local ____lambda_29 = function(it) return __K2L_DoubleToInt(it) end
local function doubleStreams()
    local values = __K2L_TypedArrayOf("[D", 0.1, 0.2, 0.3, 0.4, 1.0E10, -1.0E10)
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_DoubleStream, values):sum()))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_DoubleStream, __K2L_TypedArrayOf("[D", 0.1, 0.2, 0.3)):sum()))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_DoubleStream, __K2L_TypedArrayOf("[D", 0.1, 0.2, 0.3)):average()))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_DoubleStream, values):max():getAsDouble()))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_DoubleStream, values):min():getAsDouble()))
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_DoubleStream, values):filter(____lambda_25):map(____lambda_26):boxed():toList()))
    print(__K2L_Streams.ofArray(__K2L_DoubleStream, values):filter(____lambda_27):count())
    print(__K2L_Streams.empty(__K2L_DoubleStream):average():isPresent())
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_DoubleStream, __K2L_TypedArrayOf("[D", 0.5, 1.5)):mapToObj(____lambda_28):toList()))
    print(__K2L_Streams.ofArray(__K2L_DoubleStream, __K2L_TypedArrayOf("[D", 2.5, 3.5)):mapToInt(____lambda_29):sum())
    print(__K2L_Str(__K2L_Streams.ofArray(__K2L_DoubleStream, __K2L_TypedArrayOf("[D", 1.5, 2.5, 3.5)):toArray():toList()))
end

local ____lambda_30 = function(it) return #it > 3 end
local ____lambda_31 = function(it) return #it end
local ____lambda_32 = function(a, b) return #a - #b end
local ____lambda_33 = function(it) return #it end
local ____lambda_34 = function(it) return #it end
local ____lambda_35 = function(it) return __K2L_Equals(it, "kiwi") end
local ____lambda_36 = function(it) return #it > 0 end
local ____lambda_37 = function(it) return __K2L_StringStartsWith(it, "z") end
local ____lambda_38 = function(it) return __K2L_StringStartsWith(it, "b") end
local ____lambda_39 = function(it) return __K2L_StringStartsWith(it, "z") end
local ____lambda_40 = function(____a, ____b)
    local ____x, ____y = #____a, #____b
    if ____x ~= ____y then
        return ____x < ____y and -1 or 1
    end
    return 0
end
local ____lambda_41 = function(____a_1, ____b_1)
    local ____x_1, ____y_1 = #____a_1, #____b_1
    if ____x_1 ~= ____y_1 then
        return ____x_1 < ____y_1 and -1 or 1
    end
    return 0
end
local ____lambda_42 = function(a, b) return __K2L_Text.compare(a, b) end
local ____lambda_43 = function(a, b) return a .. __K2L_Text.first(b) end
local ____lambda_44 = function(a, b) return #a >= #b and a or b end
local ____lambda_45 = function(it)
    return __K2L_Streams.of(__K2L_Stream, __K2L_ListOf(it, it:upper()))
end
local ____lambda_46 = function(it) return not __K2L_Equals(it, "apple") end
local ____lambda_47 = function(it) return not __K2L_Equals(it, "apple") end
local function objectStreams()
    local words = __K2L_ReadOnlyListOf("pear", "fig", "apple", "kiwi", "banana", "fig")
    print(__K2L_Str(__K2L_Streams.ofCollection(words):filter(____lambda_30):collect(__K2L_Collectors.toList())))
    print(__K2L_Str(__K2L_Streams.ofCollection(words):map(____lambda_31):collect(__K2L_Collectors.toList())))
    print(__K2L_Str(__K2L_Streams.ofCollection(words):sorted():toList()))
    print(__K2L_Str(__K2L_Streams.ofCollection(words):sorted(__K2L_ReverseOrder):toList()))
    print(__K2L_Str(__K2L_Streams.ofCollection(words):sorted(____lambda_32):toList()))
    print(__K2L_Str(__K2L_Streams.ofCollection(words):distinct():toList()))
    print(__K2L_Str(__K2L_Streams.ofCollection(words):skip(2):limit(2):toList()))
    print(__K2L_Streams.ofCollection(words):mapToInt(____lambda_33):sum())
    print(__K2L_Streams.ofCollection(words):mapToInt(____lambda_34):max():getAsInt())
    print(__K2L_Streams.ofCollection(words):anyMatch(____lambda_35))
    print(__K2L_Streams.ofCollection(words):allMatch(____lambda_36))
    print(__K2L_Streams.ofCollection(words):noneMatch(____lambda_37))
    print(__K2L_Streams.ofCollection(words):findFirst():get())
    print(__K2L_Str(__K2L_Streams.ofCollection(words):filter(____lambda_38):findFirst():orElse("none")))
    print(__K2L_Str(__K2L_Streams.ofCollection(words):filter(____lambda_39):findFirst():orElse("none")))
    print(__K2L_Streams.ofCollection(words):max(____lambda_40):get())
    print(__K2L_Streams.ofCollection(words):min(____lambda_41):get())
    print(__K2L_Streams.ofCollection(words):max(____lambda_42):get())
    print(__K2L_Str(__K2L_Streams.ofCollection(words):reduce("", ____lambda_43)))
    print(__K2L_Str(__K2L_Streams.ofCollection(words):reduce(____lambda_44)))
    print(__K2L_Str(__K2L_Streams.ofCollection(words):flatMap(____lambda_45):limit(5):toList()))
    print(__K2L_Streams.ofCollection(words):count())
    print(__K2L_Streams.ofCollection(words):toArray().size)
    __K2L_Streams.ofCollection(words):limit(2):forEach(function(it)
        print("word " .. __K2L_Str(it))
    end)
    print(__K2L_Str(__K2L_Streams.ofCollection(words):takeWhile(____lambda_46):toList()))
    print(__K2L_Str(__K2L_Streams.ofCollection(words):dropWhile(____lambda_47):toList()))
end

local function main()
    sources()
    intStreams()
    doubleStreams()
    objectStreams()
end

main()
return {Person = Person, sources = sources, intStreams = intStreams, doubleStreams = doubleStreams, objectStreams = objectStreams}
