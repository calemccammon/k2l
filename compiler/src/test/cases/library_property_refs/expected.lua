local ____lualib = require("lualib_bundle")
local __K2L_FunctionRef = ____lualib.__K2L_FunctionRef
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf

local function describe(p, s)
    return p.name .. "(\"" .. s .. "\") = " .. p:get(s)
end

local function read(p)
    return p.name .. " -> " .. __K2L_Str(p:get())
end

local function main()
    local h = __K2L_PropertyRef.new("length", "kotlin/String.length", function() return #"abc" end, nil, "abc")
    print(h:get())
    print(h:get())
    print(h.name)
    local f = __K2L_PropertyRef.new("length", "kotlin/String.length", function(____p1) return #____p1 end)
    print(f:get("abcd"))
    print(f:get("abcde"))
    print(f.name)
    print(__K2L_Str(__K2L_ReadOnlyListOf("a", "bb"):map(function(____p1) return #____p1 end)))
    print(__K2L_Str(__K2L_ReadOnlyListOf("a", "bb"):map(f)))
    print(__K2L_Str(__K2L_ReadOnlyListOf("aa", "b"):sortedBy(function(____p1) return #____p1 end, true)))
    print(__K2L_ReadOnlyListOf("aaa", "b"):maxBy(function(____p1) return #____p1 end))
    local g = __K2L_PropertyRef.new("size", "kotlin/collections/List.size", function(____p1) return ____p1.size end)
    print(g:get(__K2L_SingletonListOf(1)))
    print(g.name)
    print(describe(__K2L_PropertyRef.new("length", "kotlin/String.length", function(____p1) return #____p1 end), "four"))
    print(describe(__K2L_PropertyRef.new("lastIndex", "kotlin.CharSequence.kotlin/text/lastIndex", function(____p1) return #____p1 - 1 end), "four"))
    print(read(__K2L_PropertyRef.new("length", "kotlin/String.length", function() return #"lua" end, nil, "lua")))
    print(read(__K2L_PropertyRef.new("PI", "kotlin/math/PI", function() return math.pi end)))
    local il = __K2L_PropertyRef.new("size", "kotlin/IntArray.size", function(____p1) return ____p1.size end)
    print(il:get(__K2L_TypedArrayOf("[I", 1, 2, 3)))
    print(il.name)
    print(__K2L_Str(__K2L_ReadOnlyListOf(__K2L_TypedArrayOf("[I", 1), __K2L_TypedArrayOf("[I")):map(function(____p1) return ____p1.size end)))
    local first = __K2L_PropertyRef.new("first", "kotlin/Pair.first", function(____p1) return ____p1.first end)
    print(first:get(__K2L_Pair.new(1, "a")))
    print(first.name)
    print(__K2L_Str(__K2L_ReadOnlyListOf(__K2L_Pair.new(1, "x"), __K2L_Pair.new(2, "y")):map(function(____p1) return ____p1.second end)))
    local key = __K2L_PropertyRef.new("key", "kotlin/collections/Map.Entry.key", function(____p1) return ____p1.key end)
    print(__K2L_Str(__K2L_ReadOnlyMapOf(__K2L_Pair.new("k", 1), __K2L_Pair.new("j", 2)):getEntries():map(key)))
    print(key:get(__K2L_SingletonMapOf(__K2L_Pair.new("z", 1)):getEntries():first()))
    print(__K2L_Str(__K2L_SingletonMapOf(__K2L_Pair.new("a", 3)):getEntries():map(function(____p1) return ____p1.value end)))
    local sb = __K2L_PropertyRef.new("length", "java/lang/StringBuilder.length", function(____p1) return ____p1:getLength() end)
    print(sb:get(__K2L_StringBuilder.new("abcd")))
    print(sb.name)
    local m = __K2L_SingletonMapOf(__K2L_Pair.new("a", 1))
    print(__K2L_PropertyRef.new("size", "kotlin/collections/Map.size", function() return m.size end, nil, m):get())
    print(__K2L_Str(__K2L_PropertyRef.new("keys", "kotlin/collections/Map.keys", function(____p1) return ____p1:getKeys() end):get(m)))
    print(__K2L_PropertyRef.new("size", "kotlin/collections/Collection.size", function(____p1) return ____p1.size end):get(__K2L_ReadOnlySetOf(1, 2)))
    print(__K2L_Str(__K2L_PropertyRef.new("message", "kotlin/Throwable.message", function(____p1) return ____p1.message end):get(__K2L_RuntimeException.new("boom"))))
    local r = __K2L_IntRange.new(1, 3)
    print(__K2L_PropertyRef.new("first", "kotlin/ranges/IntProgression.first", function(____p1) return ____p1.first end):get(r))
    print(__K2L_PropertyRef.new("last", "kotlin/ranges/IntProgression.last", function() return r.last end, nil, r):get())
    local mx = __K2L_PropertyRef.new("MAX_VALUE", "kotlin/Int.Companion.MAX_VALUE", function() return 2147483647 end)
    print(mx.name .. " " .. mx:get() .. " " .. mx:get())
    local li = __K2L_PropertyRef.new("lastIndex", "kotlin.CharSequence.kotlin/text/lastIndex", function(____p1) return #____p1 - 1 end)
    print(li:get("abc") + li:get("hello"))
    print(li.name)
    print(__K2L_Str(__K2L_ReadOnlyListOf("aa", "b"):map(function(____p1) return #____p1 - 1 end)))
    local lli = __K2L_PropertyRef.new("lastIndex", "kotlin.collections.List<T>.kotlin/collections/lastIndex", function(____p1) return ____p1.size - 1 end)
    print(lli:get(__K2L_ReadOnlyListOf(1, 2, 3)))
    print(__K2L_Str(__K2L_ReadOnlyListOf(__K2L_SingletonListOf(1), __K2L_ReadOnlyListOf()):map(function(____p1) return ____p1.size - 1 end)))
    local ind = __K2L_PropertyRef.new("indices", "kotlin.CharSequence.kotlin/text/indices", function(____p1)
        return __K2L_IntRange.new(0, #____p1 - 1)
    end)
    print(__K2L_Str(ind:get("abc")))
    print(ind.name)
    local bound = __K2L_PropertyRef.new("lastIndex", "kotlin.CharSequence.kotlin/text/lastIndex", function() return #"hello" - 1 end, nil, "hello")
    print(bound:get() + bound:get())
    local props = __K2L_ReadOnlyListOf(__K2L_PropertyRef.new("length", "kotlin/String.length", function(____p1) return #____p1 end), __K2L_PropertyRef.new("lastIndex", "kotlin.CharSequence.kotlin/text/lastIndex", function(____p1) return #____p1 - 1 end))
    print(__K2L_Str(props:map(function(it) return it.name .. "=" .. it:get("four") end)))
    local up = function(____p1) return ____p1:upper() end
    print(up("abc"))
    print(__K2L_Str(__K2L_ReadOnlyListOf("a", "b"):map(function(____p1) return ____p1:upper() end)))
    local plus = function(____p1, ____p2) return ____p1 + ____p2 end
    print(plus(2, 3))
    print(__K2L_ReadOnlyListOf(1, 2, 3):reduce(function(____p1, ____p2) return ____p1 + ____p2 end))
    local xplus = function(____p1) return "x" .. __K2L_Str(____p1) end
    print(xplus("y"))
    local ____receiver = __K2L_ReadOnlyListOf(1, 2)
    local c = __K2L_FunctionRef.new("contains", "kotlin/collections/List.contains(E)", function(____p1) return ____receiver:contains(____p1) end, ____receiver)
    print(c(2))
    local ____arg = __K2L_ReadOnlyListOf(1, 5)
    local ____receiver_1 = __K2L_ReadOnlyListOf(1, 2)
    print(__K2L_Str(____arg:filter(function(____p1) return ____receiver_1:contains(____p1) end)))
    local pr = function(____p1) return print(__K2L_Str(____p1)) end
    pr("printed")
    local ____list = __K2L_ReadOnlyListOf("p", "q")
    local ____mod = ____list.____modCount
    for ____i = 1, ____list.size do
        local it = ____list[____i];
        (function(____p1) return print(__K2L_Str(____p1)) end)(it)
        if ____list.____modCount ~= ____mod and ____list:____comodified(____i) then
            break
        end
    end
    local a = function(____p1) return math.abs(____p1) end
    print(a(-3))
    local kup = __K2L_FunctionRef.new("uppercase", "kotlin.String.kotlin/text/uppercase()", function(____p1) return ____p1:upper() end)
    print(kup.name .. " " .. kup("k"))
    local ____receiver_2 = __K2L_ReadOnlyListOf(1, 2)
    local kc = __K2L_FunctionRef.new("contains", "kotlin/collections/List.contains(E)", function(____p1) return ____receiver_2:contains(____p1) end, ____receiver_2)
    print(kc.name .. " " .. tostring(kc(1)))
    local kplus = __K2L_FunctionRef.new("plus", "kotlin/Int.plus(kotlin.Int)", function(____p1, ____p2) return ____p1 + ____p2 end)
    print(kplus.name .. " " .. kplus(1, 2))
    local ka = __K2L_FunctionRef.new("abs", "kotlin/math/abs(kotlin.Double)", function(____p1) return math.abs(____p1) end)
    print(ka.name .. " " .. __K2L_Str(ka(-2.5)))
    print("isEmpty")
end

main()
return {describe = describe, read = read}
