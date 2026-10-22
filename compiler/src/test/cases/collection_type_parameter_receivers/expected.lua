local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_GenerateSequence = ____lualib.__K2L_GenerateSequence
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_Iterable = ____lualib.__K2L_Iterable
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str

local function copyInto(self, destination)
    local ____items, ____n = self:____array()
    for ____i = 1, ____n do
        local element = ____items[____i]
        destination:add(element)
    end
    return destination
end

local function addTwice(____this, element)
    ____this:add(element)
    ____this:add(element)
    return ____this
end

local function fill(destination, ...)
    local elements = __K2L_ArrayOf(...)
    destination:addAll(elements)
    destination:addAll(elements:toList())
    return destination.size
end

local function put2(____this_1, key, value)
    ____this_1:set(key, value)
    return ____this_1
end

local ____lambda_1 = function() return __K2L_ListOf() end
local function group(____this_2, key, value)
    ____this_2:getOrPut(key, ____lambda_1):add(value)
    return ____this_2
end

local function middle(____this_3)
    return ____this_3:get(____this_3.size // 2)
end

local function sizeOrDefault(____this_4, default)
    return __K2L_InstanceOf(____this_4, __K2L_Iterable) and ____this_4.size ~= nil and ____this_4.size or default
end

local function sizeOr(____this_5, default)
    return __K2L_InstanceOf(____this_5, __K2L_Iterable) and ____this_5.size ~= nil and ____this_5.size or default
end

local function sortedInPlace(____this_6)
    ____this_6:sort()
    return ____this_6
end

local ____lambda_2 = function(it) return it < 4 and it + 1 or nil end
local function main()
    print(__K2L_Str(copyInto(__K2L_ListOf(1, 2, 3), __K2L_ListOf(0.5))))
    print(__K2L_Str(copyInto(__K2L_ListOf("a", "b", "a"), __K2L_SetOf())))
    print(__K2L_Str(addTwice(__K2L_ListOf("x"), "y")))
    print(__K2L_Str(addTwice(__K2L_SetOf(1), 1)))
    local target = __K2L_ListOf()
    print(fill(target, "p", "q"))
    print(__K2L_Str(target))
    print(__K2L_Str(put2(__K2L_MapOf(__K2L_Pair.new("a", 1)), "b", 2)))
    print(__K2L_Str(group(group(group(__K2L_MapOf(), 1, "one"), 2, "two"), 1, "uno")))
    print(middle(__K2L_ListOf(4, 5, 6, 7, 8)))
    print(sizeOrDefault(__K2L_ListOf(1, 2), -1))
    print(sizeOr(__K2L_ListOf(1, 2, 3), -1))
    print(sizeOr(__K2L_GenerateSequence(1, ____lambda_2):asIterable(), -1))
    print(__K2L_Str(sortedInPlace(__K2L_ListOf(3, 1, 2))))
end

__K2L_RunMain(main)
return {copyInto = copyInto, addTwice = addTwice, fill = fill, put2 = put2, group = group, middle = middle, sizeOrDefault = sizeOrDefault, sizeOr = sizeOr, sortedInPlace = sortedInPlace}
