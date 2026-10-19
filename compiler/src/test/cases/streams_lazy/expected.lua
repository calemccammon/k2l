local ____lualib = require("lualib_bundle")
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntStream = ____lualib.__K2L_IntStream
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_Optional = ____lualib.__K2L_Optional
local __K2L_OptionalInt = ____lualib.__K2L_OptionalInt
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Stream = ____lualib.__K2L_Stream
local __K2L_Streams = ____lualib.__K2L_Streams
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function main()
    local result = __K2L_Streams.of(__K2L_Stream, __K2L_ListOf("a", "bb", "ccc", "dddd")):filter(function(it)
        print("filter " .. __K2L_Str(it))
        return #it > 1
    end):map(function(it)
        print("map " .. __K2L_Str(it))
        return it:upper()
    end):peek(function(it)
        print("peek " .. __K2L_Str(it))
    end):toList()
    print(__K2L_Str(result))
    __K2L_Streams.of(__K2L_Stream, __K2L_ListOf(3, 1, 2)):peek(function(it)
        print("before " .. it)
    end):sorted():peek(function(it)
        print("after " .. it)
    end):forEach(function(it)
        print("each " .. it)
    end)
    print(__K2L_Str(__K2L_Streams.of(__K2L_Stream, __K2L_ListOf(1, 2, 3, 4, 5)):peek(function(it)
        print("see " .. it)
    end):limit(2):toList()))
    print(__K2L_Str(__K2L_Streams.range(0, 100):peek(function(it)
        print("int " .. it)
    end):filter(function(it) return math.fmod(it, 2) == 1 end):findFirst()))
    print(__K2L_Streams.of(__K2L_Stream, __K2L_ListOf(1, 2, 3, 4)):peek(function(it)
        print("any " .. it)
    end):anyMatch(function(it) return __K2L_Equals(it, 2) end))
    print(__K2L_Streams.of(__K2L_Stream, __K2L_ListOf(1, 2, 3, 4)):peek(function(it)
        print("all " .. it)
    end):allMatch(function(it) return it < 3 end))
    print(__K2L_Streams.of(__K2L_Stream, __K2L_ListOf(1, 2, 3, 4)):peek(function(it)
        print("none " .. it)
    end):noneMatch(function(it) return __K2L_Equals(it, 3) end))
    local pending = __K2L_Streams.of(__K2L_Stream, __K2L_ListOf(1, 2, 3)):map(function(it)
        print("never " .. it)
        return it
    end):filter(function(it) return it > 1 end)
    print("built")
    print(pending:count())
    print(__K2L_Streams.of(__K2L_Stream, __K2L_ListOf(1, 2, 3)):peek(function(it)
        print("sized " .. it)
    end):count())
    print(__K2L_Streams.ofCollection(__K2L_ReadOnlyListOf(1, 2, 3)):map(function(it)
        print("sized map " .. it)
        return it
    end):count())
    print(__K2L_Streams.range(0, 4):peek(function(it)
        print("range " .. it)
    end):count())
    print(__K2L_Streams.of(__K2L_Stream, __K2L_ListOf(1, 2, 3, 4)):peek(function(it)
        print("skipped " .. it)
    end):skip(1):limit(2):count())
    print(__K2L_Streams.of(__K2L_Stream, __K2L_ListOf(1, 2, 3, 4)):peek(function(it)
        print("filtered " .. it)
    end):filter(function(it) return it > 1 end):count())
    print(__K2L_Streams.of(__K2L_Stream, __K2L_ListOf(1, 2, 3)):peek(function(it)
        print("sorted " .. it)
    end):sorted():count())
    print(__K2L_Streams.of(__K2L_Stream, __K2L_ListOf(1, 2, 3, 2)):peek(function(it)
        print("distinct " .. it)
    end):distinct():count())
    local calls = 0
    print(__K2L_Str(__K2L_Streams.iterate(__K2L_Stream, 1, function(it)
        calls = calls + 1
        return it + 1
    end):limit(3):toList()))
    print(calls)
    print(__K2L_Str(__K2L_Streams.generate(__K2L_Stream, function() return "x" end):limit(3):toList()))
    print(__K2L_Streams.iterate(__K2L_Stream, 1, function(it) return it * 2 end):filter(function(it) return it > 100 end):findFirst():get())
    print(__K2L_Str(__K2L_Streams.of(__K2L_Stream, __K2L_ListOf(1, 2, 3)):flatMap(function(n)
        return __K2L_Streams.of(__K2L_Stream, __K2L_ListOf(n, n * 10)):peek(function(it)
            print("inner " .. it)
        end)
    end):limit(3):toList()))
    local once = __K2L_Streams.of(__K2L_Stream, __K2L_ListOf(1, 2, 3))
    print(once:count())
    local ____ok, ____result = pcall(function()
        once:forEach(function(it)
            print(it)
        end)
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_IllegalStateException) then
            local e = ____error
            print("reuse: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    local filtered = __K2L_Streams.of(__K2L_Stream, __K2L_ListOf(1, 2, 3)):filter(function(it) return it > 1 end)
    print(__K2L_Str(filtered:toList()))
    local ____ok_1, ____result_1 = pcall(function()
        filtered:map(function(it) return it * 2 end)
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error_1, __K2L_IllegalStateException) then
            local e = ____error_1
            print("reuse: " .. __K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
    local ints = __K2L_Streams.range(0, 3)
    local mapped = ints:map(function(it) return it + 1 end)
    local ____ok_2, ____result_2 = pcall(function()
        ints:sum()
    end)
    if not ____ok_2 then
        local ____error_2 = __K2L_ToThrowable(____result_2)
        if __K2L_InstanceOf(____error_2, __K2L_IllegalStateException) then
            local e = ____error_2
            print("reuse: " .. __K2L_Str(e.message))
        else
            error(____error_2, 0)
        end
    end
    print(mapped:sum())
    local ____ok_3, ____result_3 = pcall(function()
        __K2L_Streams.of(__K2L_Stream, __K2L_ListOf(1)):limit(-1)
    end)
    if not ____ok_3 then
        local ____error_3 = __K2L_ToThrowable(____result_3)
        if __K2L_InstanceOf(____error_3, __K2L_IllegalArgumentException) then
            local e = ____error_3
            print("limit: " .. __K2L_Str(e.message))
        else
            error(____error_3, 0)
        end
    end
    local ____ok_4, ____result_4 = pcall(function()
        __K2L_Streams.empty(__K2L_IntStream):max():getAsInt()
    end)
    if not ____ok_4 then
        local ____error_4 = __K2L_ToThrowable(____result_4)
        if __K2L_InstanceOf(____error_4, __K2L_NoSuchElementException) then
            local e = ____error_4
            print("max: " .. __K2L_Str(e.message))
        else
            error(____error_4, 0)
        end
    end
    local ____ok_5, ____result_5 = pcall(function()
        __K2L_Streams.of(__K2L_Stream, __K2L_ListOf(1, 2)):findFirst():orElseThrow(function()
            return __K2L_IllegalStateException.new("none")
        end)
        __K2L_Streams.empty(__K2L_Stream):findFirst():orElseThrow(function()
            return __K2L_IllegalStateException.new("none")
        end)
    end)
    if not ____ok_5 then
        local ____error_5 = __K2L_ToThrowable(____result_5)
        if __K2L_InstanceOf(____error_5, __K2L_IllegalStateException) then
            local e = ____error_5
            print("orElseThrow: " .. __K2L_Str(e.message))
        else
            error(____error_5, 0)
        end
    end
end

main()
