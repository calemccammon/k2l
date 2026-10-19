local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Collectors = ____lualib.__K2L_Collectors
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_Optional = ____lualib.__K2L_Optional
local __K2L_OptionalDouble = ____lualib.__K2L_OptionalDouble
local __K2L_OptionalInt = ____lualib.__K2L_OptionalInt
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SortedSet = ____lualib.__K2L_SortedSet
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Stream = ____lualib.__K2L_Stream
local __K2L_Streams = ____lualib.__K2L_Streams
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

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

local function collectors(people)
    print(__K2L_Str(__K2L_Streams.ofCollection(people):map(function(it) return it.name end):collect(__K2L_Collectors.toList())))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):map(function(it) return it.city end):collect(__K2L_Collectors.toSet())))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):map(function(it) return it.name end):collect(__K2L_Collectors.joining())))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):map(function(it) return it.name end):collect(__K2L_Collectors.joining("|"))))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):map(function(it) return it.name end):collect(__K2L_Collectors.joining(", ", "[", "]"))))
    print(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.counting()))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.groupingBy(function(it) return it.city end))))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.groupingBy(function(it) return it.city end, __K2L_Collectors.counting()))))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.groupingBy(function(it) return it.city end, __K2L_Collectors.mapping(function(it) return it.name end, __K2L_Collectors.toList())))))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.groupingBy(function(it) return __K2L_IDiv(it.age, 10) end, __K2L_Collectors.summingInt(function(it) return it.age end)))))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.groupingBy(function(it) return it.city end, __K2L_Collectors.averagingInt(function(it) return it.age end)))))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.partitioningBy(function(it) return it.age >= 30 end))))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.partitioningBy(function(it) return it.age >= 30 end, __K2L_Collectors.counting()))))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.toMap(function(it) return it.name end, function(it) return it.age end))))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.toMap(function(it) return it.city end, function(it) return it.age end, function(a, b) return a + b end))))
    print(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.summingInt(function(it) return it.age end)))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.averagingInt(function(it) return it.age end))))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.averagingDouble(function(it) return it.age * 1.5 end))))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.summingDouble(function(it) return it.age / 10.0 end))))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.maxBy(__K2L_CompareBy(function(it) return it.age end)))))
    print(__K2L_Streams.ofCollection(people):collect(__K2L_Collectors.minBy(__K2L_CompareBy(function(it) return it.age end))):get().name)
    print(__K2L_Str(__K2L_Streams.empty(__K2L_Stream):collect(__K2L_Collectors.maxBy(__K2L_CompareBy(function(it) return it.age end)))))
    print(__K2L_Streams.ofCollection(people):map(function(it) return it.age end):collect(__K2L_Collectors.collectingAndThen(__K2L_Collectors.toList(), function(it) return it.size end)))
    print(__K2L_Str(__K2L_Streams.ofCollection(people):map(function(it) return it.name end):collect(__K2L_Collectors.toCollection(function() return __K2L_SortedSet.new() end))))
    print(__K2L_Str(__K2L_Streams.of(__K2L_Stream, __K2L_ListOf(1, 2, 3, 4)):collect(function() return __K2L_List.new() end, function(list, x)
        list:add(x * x)
    end, function(a, b)
        a:addAll(b)
    end)))
    print(__K2L_Str(__K2L_Streams.empty(__K2L_Stream):collect(__K2L_Collectors.joining(","))))
    print(__K2L_Str(__K2L_Streams.empty(__K2L_Stream):collect(__K2L_Collectors.groupingBy(function(it) return #it end))))
    local ____ok, ____result = pcall(function()
        __K2L_Streams.of(__K2L_Stream, __K2L_ListOf(1, 1)):collect(__K2L_Collectors.toMap(function(it) return it end, function(it) return "v" .. it end))
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
    print(__K2L_Str(empty:orElseGet(function() return "computed" end)))
    print(__K2L_Str(present:map(function(it) return #it end)))
    print(__K2L_Str(empty:map(function(it) return #it end)))
    print(__K2L_Str(present:filter(function(it) return __K2L_StringStartsWith(it, "v") end)))
    print(__K2L_Str(present:filter(function(it) return __K2L_StringStartsWith(it, "x") end)))
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
    print(__K2L_Str(present:flatMap(function(it) return __K2L_Optional.of(it .. "!") end)))
    local ____ok_1, ____result_1 = pcall(function()
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

main()
return {Person = Person, collectors = collectors, optionals = optionals}
