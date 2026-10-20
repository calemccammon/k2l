local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Collectors = ____lualib.__K2L_Collectors
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Optional = ____lualib.__K2L_Optional
local __K2L_OptionalDouble = ____lualib.__K2L_OptionalDouble
local __K2L_OptionalInt = ____lualib.__K2L_OptionalInt
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SortedSet = ____lualib.__K2L_SortedSet
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Stream = ____lualib.__K2L_Stream
local __K2L_Streams = ____lualib.__K2L_Streams
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

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

local ____lambda_1 = function(it) return it.name end
local ____lambda_2 = function(it) return it.city end
local ____lambda_3 = function(it) return it.name end
local ____lambda_4 = function(it) return it.name end
local ____lambda_5 = function(it) return it.name end
local ____lambda_6 = function(it) return it.city end
local ____lambda_7 = function(it) return it.city end
local ____lambda_8 = function(it) return it.city end
local ____lambda_9 = function(it) return it.name end
local ____lambda_10 = function(it)
    return it.age >= 0 and it.age // 10 or 0 - -it.age // 10
end
local ____lambda_11 = function(it) return it.age end
local ____lambda_12 = function(it) return it.city end
local ____lambda_13 = function(it) return it.age end
local ____lambda_14 = function(it) return it.age >= 30 end
local ____lambda_15 = function(it) return it.age >= 30 end
local ____lambda_16 = function(it) return it.name end
local ____lambda_17 = function(it) return it.age end
local ____lambda_18 = function(it) return it.city end
local ____lambda_19 = function(it) return it.age end
local ____lambda_20 = function(a, b) return a + b end
local ____lambda_21 = function(it) return it.age end
local ____lambda_22 = function(it) return it.age end
local ____lambda_23 = function(it) return it.age * 1.5 end
local ____lambda_24 = function(it) return it.age / 10.0 end
local ____lambda_25 = function(it) return it.age end
local ____lambda_26 = function(it) return it.age end
local ____lambda_27 = function(it) return it.age end
local ____lambda_28 = function(it) return it.age end
local ____lambda_29 = function(it) return it.size end
local ____lambda_30 = function(it) return it.name end
local ____lambda_31 = function() return __K2L_SortedSet.new() end
local ____lambda_32 = function() return __K2L_List.new() end
local ____lambda_33 = function(it) return #it end
local ____lambda_34 = function(it) return it end
local ____lambda_35 = function(it) return "v" .. it end
local function collectors(people)
    print(__K2L_Str(__K2L_Streams.ofCollection(people):map(____lambda_1):collect(__K2L_Collectors.toList())))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):map(____lambda_2):collect(__K2L_Collectors.toSet())))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):map(____lambda_3):collect(__K2L_Collectors.joining())))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):map(____lambda_4):collect(__K2L_Collectors.joining("|"))))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):map(____lambda_5):collect(__K2L_Collectors.joining(", ", "[", "]"))))
    print(__K2L_NotNull(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.counting())))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.groupingBy(____lambda_6))))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.groupingBy(____lambda_7, __K2L_Collectors.counting()))))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.groupingBy(____lambda_8, __K2L_Collectors.mapping(____lambda_9, __K2L_Collectors.toList())))))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.groupingBy(____lambda_10, __K2L_Collectors.summingInt(____lambda_11)))))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.groupingBy(____lambda_12, __K2L_Collectors.averagingInt(____lambda_13)))))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.partitioningBy(____lambda_14))))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.partitioningBy(____lambda_15, __K2L_Collectors.counting()))))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.toMap(____lambda_16, ____lambda_17))))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.toMap(____lambda_18, ____lambda_19, ____lambda_20))))
    print(__K2L_NotNull(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.summingInt(____lambda_21))))
    print(__K2L_Str(__K2L_NotNull(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.averagingInt(____lambda_22)))))
    print(__K2L_Str(__K2L_NotNull(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.averagingDouble(____lambda_23)))))
    print(__K2L_Str(__K2L_NotNull(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.summingDouble(____lambda_24)))))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.maxBy(__K2L_CompareBy(____lambda_25)))))
    print(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.minBy(__K2L_CompareBy(____lambda_26))):get().name)
    print(__K2L_Str(__K2L_Streams.empty(__K2L_Stream):collect(__K2L_Collectors.maxBy(__K2L_CompareBy(____lambda_27)))))
    print(__K2L_NotNull(__K2L_Streams.ofCollection(people):map(____lambda_28):collect(__K2L_Collectors.collectingAndThen(__K2L_Collectors.toList(), ____lambda_29))))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):map(____lambda_30):collect(__K2L_Collectors.toCollection(____lambda_31))))
    print(__K2L_Str(__K2L_Streams.of(__K2L_Stream, __K2L_ListOf(1, 2, 3, 4)):collect(____lambda_32, function(list, x)
        list:add(x * x)
    end, function(a, b)
        a:addAll(b)
    end)))
    print(__K2L_Str(__K2L_Streams.empty(__K2L_Stream):collect(__K2L_Collectors.joining(","))))
    print(__K2L_Str(__K2L_Streams.empty(__K2L_Stream):collect(__K2L_Collectors.groupingBy(____lambda_33))))
    local ____ok, ____result = __K2L_DeepPcall(function()
        __K2L_Streams.of(__K2L_Stream, __K2L_ListOf(1, 1)):collect(__K2L_Collectors.toMap(____lambda_34, ____lambda_35))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_IllegalStateException) then
            local e = ____error
            print(__K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
end

local ____lambda_36 = function() return "computed" end
local ____lambda_37 = function(it) return #it end
local ____lambda_38 = function(it) return #it end
local ____lambda_39 = function(it) return __K2L_StringStartsWith(it, "v") end
local ____lambda_40 = function(it) return __K2L_StringStartsWith(it, "x") end
local ____lambda_41 = function(it) return __K2L_Optional.of(it .. "!") end
local function optionals()
    local present = __K2L_Optional.of("value")
    local empty = __K2L_Optional.empty()
    print(__K2L_Str(present))
    print(__K2L_Str(empty))
    print(present:isPresent())
    print(empty:isPresent())
    print(present:isEmpty())
    print(present:get())
    print(__K2L_Str(empty:orElse("other")))
    print(__K2L_Str(empty:orElseGet(____lambda_36)))
    print(__K2L_Str(present:map(____lambda_37)))
    print(__K2L_Str(empty:map(____lambda_38)))
    print(__K2L_Str(present:filter(____lambda_39)))
    print(__K2L_Str(present:filter(____lambda_40)))
    print(__K2L_Str(__K2L_Optional.ofNullable(nil)))
    print(__K2L_Str(__K2L_Optional.ofNullable("n")))
    present:ifPresent(function(it)
        print("has " .. it)
    end)
    empty:ifPresent(function(it)
        print("has " .. it)
    end)
    present:ifPresentOrElse(function(it)
        print("yes " .. it)
    end, function()
        print("no")
    end)
    empty:ifPresentOrElse(function(it)
        print("yes " .. it)
    end, function()
        print("no")
    end)
    print(__K2L_Equals(present, __K2L_Optional.of("value")))
    print(__K2L_Equals(present, empty))
    print(__K2L_Str(present:flatMap(____lambda_41)))
    local ____ok_1, ____result_1 = __K2L_DeepPcall(function()
        empty:get()
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error_1, __K2L_NoSuchElementException) then
            local e = ____error_1
            print(__K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
    local oi = __K2L_OptionalInt.of(4)
    print(__K2L_Str(oi))
    print(oi:getAsInt())
    print(oi:orElse(0))
    print(__K2L_Str(__K2L_OptionalInt.empty()))
    print(__K2L_OptionalInt.empty():orElse(-1))
    print(__K2L_OptionalInt.empty():isPresent())
    local od = __K2L_OptionalDouble.of(2.5)
    print(__K2L_Str(od))
    print(__K2L_Str(od:getAsDouble()))
    print(__K2L_Str(__K2L_OptionalDouble.empty()))
    print(__K2L_Str(__K2L_OptionalDouble.empty():orElse(0.5)))
end

local function main()
    local people = __K2L_ReadOnlyListOf(Person.new("Ann", 31, "Oslo"), Person.new("Bob", 25, "Rome"), Person.new("Cid", 40, "Oslo"), Person.new("Dee", 27, "Lima"), Person.new("Eve", 38, "Rome"), Person.new("Fay", 28, "Lima"))
    collectors(people)
    optionals()
end

__K2L_DeepMain(main)
return {Person = Person, collectors = collectors, optionals = optionals}
