local ____lualib = require("lualib_bundle")
local __K2L_CharRange = ____lualib.__K2L_CharRange
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_Iterable = ____lualib.__K2L_Iterable
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_SequenceOf = ____lualib.__K2L_SequenceOf
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf

local function nestedLists()
    local rows = __K2L_ListOf()
    rows:add(__K2L_ReadOnlyListOf(1, 2))
    rows:addAll(__K2L_ReadOnlyListOf(__K2L_SingletonListOf(3), __K2L_ReadOnlyListOf(4, 5)))
    rows:add(__K2L_SingletonListOf(6))
    print(__K2L_Str(rows))
    rows:remove(__K2L_ReadOnlyListOf(1, 2))
    print(__K2L_Str(rows))
    rows:removeAll(__K2L_SingletonListOf(__K2L_SingletonListOf(3)))
    print(__K2L_Str(rows))
    local plusOne = rows:plusAll(__K2L_SingletonListOf(7))
    local plusMany = rows:plusAll(__K2L_ReadOnlyListOf(__K2L_SingletonListOf(8), __K2L_SingletonListOf(9)))
    print(__K2L_Str(plusOne))
    print(__K2L_Str(plusMany))
    print(__K2L_Str(plusMany:minusAll(__K2L_SingletonListOf(__K2L_SingletonListOf(8)))))
    print(__K2L_Str(plusMany:minusAll(__K2L_SingletonListOf(9))))
    local readOnly = __K2L_ReadOnlyListOf()
    readOnly = readOnly:plusAll(__K2L_SingletonListOf(__K2L_SingletonListOf(2)))
    readOnly = readOnly:plus(__K2L_SingletonListOf(3))
    print(__K2L_Str(readOnly))
end

local function nestedSets()
    local sets = __K2L_SetOf()
    sets:add(__K2L_ReadOnlySetOf("a"))
    sets:addAll(__K2L_ReadOnlyListOf(__K2L_ReadOnlySetOf("b"), __K2L_ReadOnlySetOf("c")))
    print(__K2L_Str(sets))
    sets:remove(__K2L_ReadOnlySetOf("a"))
    print(__K2L_Str(sets))
    print(__K2L_Str(sets:plusAll(__K2L_ReadOnlySetOf("z"))))
    print(__K2L_Str(sets:plusAll(__K2L_SingletonListOf(__K2L_ReadOnlySetOf("y")))))
    local flat = __K2L_SetOf("q")
    flat:addAll(__K2L_ReadOnlyListOf("r", "s"))
    flat:remove("q")
    print(__K2L_Str(flat))
end

local function maps()
    local m = __K2L_MapOf(__K2L_Pair.new(1, "a"))
    m:set(__K2L_Pair.new(2, "b").first, __K2L_Pair.new(2, "b").second)
    m:putAll(__K2L_SingletonMapOf(__K2L_Pair.new(3, "c")))
    m:putAll(__K2L_ReadOnlyListOf(__K2L_Pair.new(4, "d"), __K2L_Pair.new(5, "e")))
    m:remove(1)
    m:getKeys():removeAll(__K2L_ReadOnlyListOf(2, 3))
    print(__K2L_Str(m))
    local n = __K2L_MapOf(__K2L_Pair.new(0, "z"))
    n:putAll(__K2L_SequenceOf(__K2L_Pair.new(8, "h"), __K2L_Pair.new(9, "i")))
    n:putAll(__K2L_TypedArrayOf("[Lkotlin.Pair;", __K2L_Pair.new(10, "j")))
    print(__K2L_Str(n))
    print(__K2L_Str(n:plus(__K2L_SequenceOf(__K2L_Pair.new(11, "k")))))
    print(__K2L_Str(n:minusAll(__K2L_SequenceOf(8, 9))))
    print(__K2L_Str(m:plus(__K2L_Pair.new(6, "f"))))
    print(__K2L_Str(m:plus(__K2L_SingletonMapOf(__K2L_Pair.new(7, "g")))))
    print(__K2L_Str(m:minus(4)))
    print(__K2L_Str(m:minusAll(__K2L_ReadOnlyListOf(4, 5))))
    local ____pairs = __K2L_ListOf()
    ____pairs:add(__K2L_Pair.new(1, 2))
    ____pairs:addAll(__K2L_SingletonListOf(__K2L_Pair.new(3, 4)))
    print(__K2L_Str(____pairs))
end

local function sequences()
    local nested = __K2L_SequenceOf(__K2L_SingletonListOf(1))
    print(__K2L_Str(nested:plusAll(__K2L_SingletonListOf(2)):toList()))
    print(__K2L_Str(nested:plusAll(__K2L_SequenceOf(__K2L_SingletonListOf(3))):toList()))
    print(__K2L_Str(__K2L_SequenceOf(1, 2):plusAll(__K2L_ReadOnlyListOf(3, 4)):toList()))
    print(__K2L_Str(__K2L_SequenceOf(1, 2, 3):minus(2):toList()))
end

local function addTo(target, extra, counts)
    target:add("x")
    target:addAll(__K2L_ReadOnlyListOf("y", "z"))
    target:remove("y")
    extra:add(3)
    extra:remove(1)
    counts:set(__K2L_Pair.new("k", 1).first, __K2L_Pair.new("k", 1).second)
    counts:remove("old")
end

local ____lambda_1 = function(it) return it > 3 end
local ____lambda_2 = function(it)
    return (it >= 0 and it % 3 or 0 - -it % 3) == 0
end
local ____lambda_3 = function(it) return it > "b" end
local ____lambda_4 = function(it) return it < "e" end
local ____lambda_5 = function(it) return it < 8 end
local ____lambda_6 = function()
    return __K2L_Iterable.first(__K2L_IntRange.new(1, 0))
end
local ____lambda_7 = function(it) return it < 4 end
local function ranges()
    local r = __K2L_IntRange.new(1, 10)
    print(r.first)
    print(r.last)
    print(r.step)
    print(__K2L_Iterable.first(r, ____lambda_1))
    print(__K2L_Iterable.last(r, ____lambda_2))
    print(__K2L_Iterable.first(r))
    print(__K2L_Iterable.last(r))
    print(__K2L_Iterable.last(__K2L_IntRange.new(1, 10):withStep(4)))
    print(__K2L_Iterable.first(__K2L_CharRange.new("a", "f"), ____lambda_3))
    print(__K2L_Iterable.last(__K2L_CharRange.new("a", "f"), ____lambda_4))
    print(__K2L_Iterable.first(__K2L_IntRange.new(10, 1, -1), ____lambda_5))
    local ____receiver = __K2L_RunCatching(____lambda_6):exceptionOrNull()
    local ____receiver_1 = ____receiver and __K2L_JavaClass(__K2L_KClassOfValue(____receiver))
    print(__K2L_Str(____receiver_1 and (____receiver_1.simpleName or "")))
    print(__K2L_IntRange.new(1, 0).first)
    print(__K2L_Iterable.last(__K2L_IntRange.new(1, 5), ____lambda_7))
end

local function main()
    nestedLists()
    nestedSets()
    maps()
    sequences()
    local target = __K2L_ListOf("w")
    local extra = __K2L_SetOf(1, 2)
    local counts = __K2L_MapOf(__K2L_Pair.new("old", 0))
    addTo(target, extra, counts)
    print(__K2L_Str(target) .. " " .. __K2L_Str(extra) .. " " .. __K2L_Str(counts))
    ranges()
end

main()
return {nestedLists = nestedLists, nestedSets = nestedSets, maps = maps, sequences = sequences, addTo = addTo, ranges = ranges}
