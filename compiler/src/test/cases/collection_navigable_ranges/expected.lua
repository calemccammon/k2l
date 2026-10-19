local ____lualib = require("lualib_bundle")
local __K2L_CharRange = ____lualib.__K2L_CharRange
local __K2L_ClosedRange = ____lualib.__K2L_ClosedRange
local __K2L_DoubleToString = ____lualib.__K2L_DoubleToString
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_FloatToString = ____lualib.__K2L_FloatToString
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_SortedMap = ____lualib.__K2L_SortedMap
local __K2L_SortedSet = ____lualib.__K2L_SortedSet
local __K2L_Str = ____lualib.__K2L_Str

local function main()
    local t = __K2L_SortedMap.new(__K2L_ReadOnlyMapOf(__K2L_Pair.new(3, "c"), __K2L_Pair.new(1, "a"), __K2L_Pair.new(2, "b")))
    local nk = t:navigableKeySet()
    print(__K2L_Str(nk) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(nk)).name))
    local dk = t:descendingKeySet()
    print(__K2L_Str(dk) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(dk)).name))
    local dm = t:descendingMap()
    print(__K2L_Str(dm) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(dm)).name))
    print(__K2L_Str(dm:firstKey()) .. " " .. __K2L_Str(dm:getKeys()) .. " " .. __K2L_Str(dm:getValues()) .. " " .. __K2L_Str(dm:getEntries()))
    t:set(4, "d")
    print(__K2L_Str(nk) .. " " .. __K2L_Str(dk) .. " " .. __K2L_Str(dm))
    nk:remove(1)
    print(__K2L_Str(t))
    print(__K2L_NotNull(dk:first()))
    print(__K2L_Str(__K2L_IntRange.new(1, 0)) .. " " .. __K2L_Str(__K2L_CharRange.new(string.char(1), string.char(0))) .. " " .. __K2L_Str(__K2L_IntRange.new(1, 0)) .. " " .. tostring(__K2L_IntRange.new(1, 0):isEmpty()) .. " " .. __K2L_IntRange.new(1, 0).first .. " " .. __K2L_IntRange.new(1, 0).last)
    print(tostring(__K2L_Equals(__K2L_IntRange.new(1, 0), __K2L_IntRange.new(1, 0))) .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(__K2L_IntRange.new(1, 0))).name) .. " " .. __K2L_CharRange.new(string.char(1), string.char(0)).first:byte() .. " " .. __K2L_IntRange.new(1, 0).last)
    local ____range = __K2L_IntRange.new(1, 0)
    for i = ____range.first, ____range.last, ____range.step do
        print(i)
    end
    print(__K2L_Str(__K2L_IntRange.new(1, 0):toList()))
    print(__K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(t:getKeys())).name))
    print(__K2L_Equals(t:navigableKeySet(), t:getKeys()))
    print(__K2L_Str(t:descendingKeySet():descendingSet()))
    print(__K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(__K2L_SortedSet.new(__K2L_ReadOnlyListOf(1, 2)):descendingSet())).name))
    local r = __K2L_ClosedRange.new(30.0, 50.0, __K2L_DoubleToString)
    print(__K2L_Str(r))
    print(__K2L_DoubleToString(r.first) .. " " .. __K2L_DoubleToString(r.last) .. " " .. __K2L_Str(__K2L_ClosedRange.new(1.5, 2.25, __K2L_DoubleToString)) .. " " .. __K2L_Str(__K2L_ClosedRange.new(1.0, 2.5, __K2L_FloatToString)) .. " " .. __K2L_Str(__K2L_ClosedRange.new(0.1, 0.3, __K2L_DoubleToString)) .. " " .. tostring(r:contains(40.0)))
    print(__K2L_Str(__K2L_ReadOnlyListOf(r, __K2L_ClosedRange.new(-1.0, 1.0E10, __K2L_DoubleToString))))
    print(__K2L_Str(__K2L_ClosedRange.new("a", "c")))
end

main()
