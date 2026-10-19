local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_HashSet = ____lualib.__K2L_HashSet
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_SortedMap = ____lualib.__K2L_SortedMap
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Triple = ____lualib.__K2L_Triple
local __K2L_UnsupportedOperationException = ____lualib.__K2L_UnsupportedOperationException

local function build(n, make)
    return __K2L_ListOfSize(n, function(it) return make() end)
end

local function apply(a, f)
    return f(a)
end

local Holder = __K2L_Class("Holder")

function Holder:____init(items)
    self.items = items
end

local function main()
    local lists = build(2, function() return __K2L_List.new() end)
    lists:get(0):add(1)
    print(__K2L_Str(lists))
    local maps = build(1, function() return __K2L_HashMap.new() end)
    local ____object = maps:get(0)
    ____object:set("a", 1)
    print(__K2L_Str(maps))
    local linked = function() return __K2L_Map.new() end
    local ____value = linked()
    ____value:put("z", 1)
    ____value:put("a", 2)
    print(__K2L_Str(____value))
    local sets = function() return __K2L_HashSet.new() end
    local ____value_1 = sets()
    ____value_1:add(3)
    print(__K2L_Str(____value_1))
    local copy = function(____p1) return ____p1:toMutableList() end
    print(__K2L_Str(copy(__K2L_ReadOnlyListOf(1, 2, 3))))
    local sorted = function() return __K2L_SortedMap.new() end
    local ____value_2 = sorted()
    ____value_2:put("b", 1)
    ____value_2:put("a", 2)
    print(__K2L_Str(____value_2))
    local deque = function() return __K2L_ArrayDeque.new() end
    local ____value_3 = deque()
    ____value_3:addFirst(1)
    ____value_3:addFirst(2)
    print(__K2L_Str(____value_3))
    local empty = function() return __K2L_StringBuilder.new() end
    local fromText = function(____p1)
        return __K2L_StringBuilder.new(__K2L_Str(____p1))
    end
    print(__K2L_Str(empty():append("x"):append(tostring(1))))
    print(__K2L_Str(fromText("hi"):append("!")))
    print(__K2L_Str(__K2L_ReadOnlyListOf("a", "b"):map(function(____p1)
        return __K2L_StringBuilder.new(__K2L_Str(____p1))
    end):map(function(it) return it:reverse():append("?"):toString() end)))
    print(__K2L_Str(__K2L_ReadOnlyListOf(1, 2, 3):zip(__K2L_ReadOnlyListOf("one", "two", "three"), function(____p1, ____p2)
        return __K2L_Pair.new(____p1, ____p2)
    end)))
    local triple = function(____p1, ____p2, ____p3)
        return __K2L_Triple.new(____p1, ____p2, ____p3)
    end
    print(__K2L_Str(triple(1, "t", true)))
    local errors = __K2L_ReadOnlyListOf("bad", "worse"):map(function(____p1)
        return __K2L_IllegalStateException.new(____p1)
    end)
    print(__K2L_Str(errors:map(function(it) return it.message end)))
    local wrap = function(____p1, ____p2)
        return __K2L_RuntimeException.new(____p1, ____p2)
    end
    local wrapped = wrap("outer", errors:get(0))
    local ____receiver = wrapped.cause
    print(__K2L_Str(wrapped.message) .. " " .. __K2L_Str(____receiver and ____receiver.message))
    local noMessage = function()
        return __K2L_UnsupportedOperationException.new()
    end
    print(__K2L_Str(noMessage().message))
    local ____ok, ____result = pcall(function()
        error(apply("from a reference", function(____p1)
            return __K2L_IllegalArgumentException.new(____p1)
        end))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
            local e = ____error
            print("caught " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    local patterns = __K2L_ReadOnlyListOf("a+b", "[0-9]+"):map(function(____p1) return __K2L_Regex.new(____p1) end)
    print(__K2L_Str(patterns:map(function(it) return it:matches("aab") end)))
    local holder = Holder.new
    print(__K2L_Str(holder(__K2L_ListOf("x")).items))
    local ref = function(____p1, ____p2)
        return __K2L_Regex.new(____p1, ____p2)
    end
    print(ref("X*", "IGNORE_CASE"):matches("xxx"))
end

main()
return {build = build, apply = apply, Holder = Holder}
