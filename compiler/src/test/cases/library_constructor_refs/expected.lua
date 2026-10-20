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
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
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

function Holder.new(items)
    return setmetatable({items = items}, Holder)
end

local ____lambda_1 = function() return __K2L_List.new() end
local ____lambda_2 = function() return __K2L_HashMap.new() end
local ____lambda_3 = function() return __K2L_Map.new() end
local ____lambda_4 = function() return __K2L_HashSet.new() end
local ____lambda_5 = function(____p1) return ____p1:toMutableList() end
local ____lambda_6 = function() return __K2L_SortedMap.new() end
local ____lambda_7 = function() return __K2L_ArrayDeque.new() end
local ____lambda_8 = function() return __K2L_StringBuilder.new() end
local ____lambda_9 = function(____p1)
    return __K2L_StringBuilder.new(__K2L_Str(____p1))
end
local ____lambda_10 = function(____p1)
    return __K2L_StringBuilder.new(__K2L_Str(____p1))
end
local ____lambda_11 = function(____p1, ____p2)
    return __K2L_Pair.new(____p1, ____p2)
end
local ____lambda_12 = function(____p1, ____p2, ____p3)
    return __K2L_Triple.new(____p1, ____p2, ____p3)
end
local ____lambda_13 = function(____p1)
    return __K2L_IllegalStateException.new(____p1)
end
local ____lambda_14 = function(____p1, ____p2)
    return __K2L_RuntimeException.new(____p1, ____p2)
end
local ____lambda_15 = function()
    return __K2L_UnsupportedOperationException.new()
end
local ____lambda_16 = function(____p1)
    return __K2L_IllegalArgumentException.new(____p1)
end
local ____lambda_17 = function(____p1) return __K2L_Regex.new(____p1) end
local ____lambda_18 = function(____p1, ____p2)
    return __K2L_Regex.new(____p1, ____p2)
end
local function main()
    local lists = build(2, ____lambda_1)
    lists:get(0):add(1)
    print(__K2L_Str(lists))
    local maps = build(1, ____lambda_2)
    local ____object = maps:get(0)
    ____object:set("a", 1)
    print(__K2L_Str(maps))
    local linked = ____lambda_3
    local ____value = linked()
    ____value:put("z", 1)
    ____value:put("a", 2)
    print(__K2L_Str(____value))
    local sets = ____lambda_4
    local ____value_1 = sets()
    ____value_1:add(3)
    print(__K2L_Str(____value_1))
    local copy = ____lambda_5
    print(__K2L_Str(copy(__K2L_ReadOnlyListOf(1, 2, 3))))
    local sorted = ____lambda_6
    local ____value_2 = sorted()
    ____value_2:put("b", 1)
    ____value_2:put("a", 2)
    print(__K2L_Str(____value_2))
    local deque = ____lambda_7
    local ____value_3 = deque()
    ____value_3:addFirst(1)
    ____value_3:addFirst(2)
    print(__K2L_Str(____value_3))
    local empty = ____lambda_8
    local fromText = ____lambda_9
    print(__K2L_Str(empty():append("x"):append(tostring(1))))
    print(__K2L_Str(fromText("hi"):append("!")))
    local ____list = __K2L_ReadOnlyListOf("a", "b"):map(____lambda_10)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = it:reverse():append("?"):toString()
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    print(__K2L_Str(__K2L_ReadOnlyListOf(1, 2, 3):zip(__K2L_ReadOnlyListOf("one", "two", "three"), ____lambda_11)))
    local triple = ____lambda_12
    print(__K2L_Str(triple(1, "t", true)))
    local errors = __K2L_ReadOnlyListOf("bad", "worse"):map(____lambda_13)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = errors:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = it.message
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
    local wrap = ____lambda_14
    local wrapped = wrap("outer", errors:get(0))
    local ____receiver = wrapped.cause
    print(__K2L_Str(wrapped.message) .. " " .. __K2L_Str(____receiver and ____receiver.message))
    local noMessage = ____lambda_15
    print(__K2L_Str(noMessage().message))
    local ____ok, ____result = pcall(function()
        error(apply("from a reference", ____lambda_16))
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
    local patterns = __K2L_ReadOnlyListOf("a+b", "[0-9]+"):map(____lambda_17)
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_2, ____n_2 = patterns:____array()
    for ____i_2 = 1, ____n_2 do
        local it = ____items_2[____i_2]
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = it:matches("aab")
    end
    print(__K2L_Str(__K2L_ListWrap(____out_2, ____count_2)))
    local holder = Holder.new
    print(__K2L_Str(holder(__K2L_ListOf("x")).items))
    local ref = ____lambda_18
    print(ref("X*", "IGNORE_CASE"):matches("xxx"))
end

main()
return {build = build, apply = apply, Holder = Holder}
