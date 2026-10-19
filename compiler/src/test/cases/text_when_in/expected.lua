local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf

local function ____next()
    print("next")
    return 3
end

local function classify(c)
    if __K2L_StringContains("aeiou", c) then
        return "vowel"
    elseif not __K2L_StringContains("bcdfghjklmnpqrstvwxyz", c) then
        return "other"
    else
        return "consonant"
    end
end

local Bag = __K2L_Class("Bag")

function Bag:____init(items)
    self.items = items
end

function Bag:contains(s)
    return self.items:contains(s:lower())
end

local function main()
    local ____pairs = __K2L_ReadOnlyMapOf(__K2L_Pair.new(")", "("), __K2L_Pair.new("]", "["))
    for c in ("a(b]z!"):gmatch(".") do
        if ____pairs:getValues():contains(c) then
            print("open " .. c)
        elseif ____pairs:getKeys():contains(c) then
            print("close " .. c)
        else
            print(classify(c) .. " " .. c)
        end
    end
    local set = __K2L_ReadOnlySetOf(1, 2, 3)
    local ____subject = ____next()
    if set:contains(____subject) then
        print("in set")
    else
        print("no")
    end
    local n = ____next()
    if __K2L_ReadOnlyListOf(5, 6):contains(n) or set:contains(n) then
        print("n=" .. n .. " in")
    else
        print("no")
    end
    local word = "kotlin"
    local ____temp
    if __K2L_ReadOnlyListOf("java", "kotlin"):contains(word) then
        ____temp = "jvm"
    else
        ____temp = "?"
    end
    print(____temp)
    local ____temp_1
    if __K2L_StringContains(word, "lin") then
        ____temp_1 = "sub"
    else
        ____temp_1 = "?"
    end
    print(____temp_1)
    local bag = Bag.new(__K2L_ReadOnlySetOf("apple", "pear"))
    local ____list = __K2L_ReadOnlyListOf("Apple", "kiwi")
    for ____i = 1, ____list.size do
        local f = ____list[____i]
        local ____temp_2
        if bag:contains(f) then
            ____temp_2 = f .. " in bag"
        elseif not bag:contains(f) then
            ____temp_2 = f .. " not in bag"
        else
            ____temp_2 = "?"
        end
        print(____temp_2)
    end
    local ranges = __K2L_ReadOnlyListOf(__K2L_IntRange.new(1, 3), __K2L_IntRange.new(10, 12))
    local ____temp_3
    if ranges:get(0):contains(11) then
        ____temp_3 = "first"
    elseif ranges:get(1):contains(11) then
        ____temp_3 = "second"
    else
        ____temp_3 = "none"
    end
    print(____temp_3)
    local ____temp_4
    if __K2L_TypedArrayOf("[C", "x", "y"):contains("x") then
        ____temp_4 = "xy"
    else
        ____temp_4 = "-"
    end
    print(____temp_4)
end

main()
return {____next = ____next, classify = classify, Bag = Bag}
