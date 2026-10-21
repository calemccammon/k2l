local ____lualib = require("lualib_bundle")
local __K2L_FunctionRef = ____lualib.__K2L_FunctionRef
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Main = ____lualib.__K2L_Main
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

local ____lambda_1 = function() return #"abc" end
local ____lambda_2 = function(____p1) return #____p1 end
local ____lambda_3 = function(____p1) return #____p1 end
local ____lambda_4 = function(____p1) return #____p1 end
local ____lambda_5 = function(____p1) return #____p1 end
local ____lambda_6 = function(____p1) return ____p1.size end
local ____lambda_7 = function(____p1) return #____p1 end
local ____lambda_8 = function(____p1) return #____p1 - 1 end
local ____lambda_9 = function() return #"lua" end
local ____lambda_10 = function() return math.pi end
local ____lambda_11 = function(____p1) return ____p1.size end
local ____lambda_12 = function(____p1) return ____p1.size end
local ____lambda_13 = function(____p1) return ____p1.first end
local ____lambda_14 = function(____p1) return ____p1.second end
local ____lambda_15 = function(____p1) return ____p1.key end
local ____lambda_16 = function(____p1) return ____p1.value end
local ____lambda_17 = function(____p1) return ____p1:getLength() end
local ____lambda_18 = function(____p1) return ____p1:getKeys() end
local ____lambda_19 = function(____p1) return ____p1.size end
local ____lambda_20 = function(____p1) return ____p1.message end
local ____lambda_21 = function(____p1) return ____p1.first end
local ____lambda_22 = function() return 2147483647 end
local ____lambda_23 = function(____p1) return #____p1 - 1 end
local ____lambda_24 = function(____p1) return #____p1 - 1 end
local ____lambda_25 = function(____p1) return ____p1.size - 1 end
local ____lambda_26 = function(____p1) return ____p1.size - 1 end
local ____lambda_27 = function(____p1)
    return __K2L_IntRange.new(0, #____p1 - 1)
end
local ____lambda_28 = function() return #"hello" - 1 end
local ____lambda_29 = function(____p1) return #____p1 end
local ____lambda_30 = function(____p1) return #____p1 - 1 end
local ____lambda_31 = function(____p1) return ____p1:upper() end
local ____lambda_32 = function(____p1) return ____p1:upper() end
local ____lambda_33 = function(____p1, ____p2) return ____p1 + ____p2 end
local ____lambda_34 = function(____p1, ____p2) return ____p1 + ____p2 end
local ____lambda_35 = function(____p1) return "x" .. __K2L_Str(____p1) end
local ____lambda_36 = function(____p1) return print(__K2L_Str(____p1)) end
local ____lambda_37 = function(____p1) return print(__K2L_Str(____p1)) end
local ____lambda_38 = function(____p1) return math.abs(____p1) end
local ____lambda_39 = function(____p1) return ____p1:upper() end
local ____lambda_40 = function(____p1, ____p2) return ____p1 + ____p2 end
local ____lambda_41 = function(____p1) return math.abs(____p1) end
local function main()
    local h = __K2L_PropertyRef.new("length", "kotlin/String.length", ____lambda_1, nil, "abc")
    print(h:get())
    print(h:get())
    print(h.name)
    local f = __K2L_PropertyRef.new("length", "kotlin/String.length", ____lambda_2)
    print(f:get("abcd"))
    print(f:get("abcde"))
    print(f.name)
    print(__K2L_Str(__K2L_ReadOnlyListOf("a", "bb"):map(____lambda_3)))
    print(__K2L_Str(__K2L_ReadOnlyListOf("a", "bb"):map(f)))
    print(__K2L_Str(__K2L_ReadOnlyListOf("aa", "b"):sortedBy(____lambda_4, true)))
    print(__K2L_ReadOnlyListOf("aaa", "b"):maxBy(____lambda_5))
    local g = __K2L_PropertyRef.new("size", "kotlin/collections/List.size", ____lambda_6)
    print(g:get(__K2L_SingletonListOf(1)))
    print(g.name)
    print(describe(__K2L_PropertyRef.new("length", "kotlin/String.length", ____lambda_7), "four"))
    print(describe(__K2L_PropertyRef.new("lastIndex", "kotlin.CharSequence.kotlin/text/lastIndex", ____lambda_8), "four"))
    print(read(__K2L_PropertyRef.new("length", "kotlin/String.length", ____lambda_9, nil, "lua")))
    print(read(__K2L_PropertyRef.new("PI", "kotlin/math/PI", ____lambda_10)))
    local il = __K2L_PropertyRef.new("size", "kotlin/IntArray.size", ____lambda_11)
    print(il:get(__K2L_TypedArrayOf("[I", 1, 2, 3)))
    print(il.name)
    print(__K2L_Str(__K2L_ReadOnlyListOf(__K2L_TypedArrayOf("[I", 1), __K2L_TypedArrayOf("[I")):map(____lambda_12)))
    local first = __K2L_PropertyRef.new("first", "kotlin/Pair.first", ____lambda_13)
    print(first:get(__K2L_Pair.new(1, "a")))
    print(first.name)
    print(__K2L_Str(__K2L_ReadOnlyListOf(__K2L_Pair.new(1, "x"), __K2L_Pair.new(2, "y")):map(____lambda_14)))
    local key = __K2L_PropertyRef.new("key", "kotlin/collections/Map.Entry.key", ____lambda_15)
    print(__K2L_Str(__K2L_ReadOnlyMapOf(__K2L_Pair.new("k", 1), __K2L_Pair.new("j", 2)):getEntries():map(key)))
    print(key:get(__K2L_SingletonMapOf(__K2L_Pair.new("z", 1)):getEntries():first()))
    print(__K2L_Str(__K2L_SingletonMapOf(__K2L_Pair.new("a", 3)):getEntries():map(____lambda_16)))
    local sb = __K2L_PropertyRef.new("length", "java/lang/StringBuilder.length", ____lambda_17)
    print(sb:get(__K2L_StringBuilder.new("abcd")))
    print(sb.name)
    local m = __K2L_SingletonMapOf(__K2L_Pair.new("a", 1))
    print(__K2L_PropertyRef.new("size", "kotlin/collections/Map.size", function() return m.size end, nil, m):get())
    print(__K2L_Str(__K2L_PropertyRef.new("keys", "kotlin/collections/Map.keys", ____lambda_18):get(m)))
    print(__K2L_PropertyRef.new("size", "kotlin/collections/Collection.size", ____lambda_19):get(__K2L_ReadOnlySetOf(1, 2)))
    print(__K2L_Str(__K2L_PropertyRef.new("message", "kotlin/Throwable.message", ____lambda_20):get(__K2L_RuntimeException.new("boom"))))
    local r = __K2L_IntRange.new(1, 3)
    print(__K2L_PropertyRef.new("first", "kotlin/ranges/IntProgression.first", ____lambda_21):get(r))
    print(__K2L_PropertyRef.new("last", "kotlin/ranges/IntProgression.last", function() return r.last end, nil, r):get())
    local mx = __K2L_PropertyRef.new("MAX_VALUE", "kotlin/Int.Companion.MAX_VALUE", ____lambda_22)
    print(mx.name .. " " .. mx:get() .. " " .. mx:get())
    local li = __K2L_PropertyRef.new("lastIndex", "kotlin.CharSequence.kotlin/text/lastIndex", ____lambda_23)
    print(li:get("abc") + li:get("hello"))
    print(li.name)
    print(__K2L_Str(__K2L_ReadOnlyListOf("aa", "b"):map(____lambda_24)))
    local lli = __K2L_PropertyRef.new("lastIndex", "kotlin.collections.List<T>.kotlin/collections/lastIndex", ____lambda_25)
    print(lli:get(__K2L_ReadOnlyListOf(1, 2, 3)))
    print(__K2L_Str(__K2L_ReadOnlyListOf(__K2L_SingletonListOf(1), __K2L_ReadOnlyListOf()):map(____lambda_26)))
    local ind = __K2L_PropertyRef.new("indices", "kotlin.CharSequence.kotlin/text/indices", ____lambda_27)
    print(__K2L_Str(ind:get("abc")))
    print(ind.name)
    local bound = __K2L_PropertyRef.new("lastIndex", "kotlin.CharSequence.kotlin/text/lastIndex", ____lambda_28, nil, "hello")
    print(bound:get() + bound:get())
    local props = __K2L_ReadOnlyListOf(__K2L_PropertyRef.new("length", "kotlin/String.length", ____lambda_29), __K2L_PropertyRef.new("lastIndex", "kotlin.CharSequence.kotlin/text/lastIndex", ____lambda_30))
    local ____out = {}
    local ____count = 0
    local ____items, ____n = props:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = it.name .. "=" .. it:get("four")
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    local up = ____lambda_31
    print(up("abc"))
    print(__K2L_Str(__K2L_ReadOnlyListOf("a", "b"):map(____lambda_32)))
    local plus = ____lambda_33
    print(plus(2, 3))
    print(__K2L_ReadOnlyListOf(1, 2, 3):reduce(____lambda_34))
    local xplus = ____lambda_35
    print(xplus("y"))
    local ____receiver = __K2L_ReadOnlyListOf(1, 2)
    local c = __K2L_FunctionRef.new("contains", "kotlin/collections/List.contains(E)", function(____p1) return ____receiver:contains(____p1) end, ____receiver)
    print(c(2))
    local ____arg = __K2L_ReadOnlyListOf(1, 5)
    local ____receiver_1 = __K2L_ReadOnlyListOf(1, 2)
    print(__K2L_Str(____arg:filter(function(____p1) return ____receiver_1:contains(____p1) end)))
    local pr = ____lambda_36
    pr("printed")
    local ____list = __K2L_ReadOnlyListOf("p", "q")
    local ____mod = ____list.____modCount
    for ____i_1 = 1, ____list.size do
        local it = ____list[____i_1];
        (____lambda_37)(it)
        if ____list.____modCount ~= ____mod and ____list:____comodified(____i_1) then
            break
        end
    end
    local a = ____lambda_38
    print(a(-3))
    local kup = __K2L_FunctionRef.new("uppercase", "kotlin.String.kotlin/text/uppercase()", ____lambda_39)
    print(kup.name .. " " .. kup("k"))
    local ____receiver_2 = __K2L_ReadOnlyListOf(1, 2)
    local kc = __K2L_FunctionRef.new("contains", "kotlin/collections/List.contains(E)", function(____p1) return ____receiver_2:contains(____p1) end, ____receiver_2)
    print(kc.name .. " " .. tostring(kc(1)))
    local kplus = __K2L_FunctionRef.new("plus", "kotlin/Int.plus(kotlin.Int)", ____lambda_40)
    print(kplus.name .. " " .. kplus(1, 2))
    local ka = __K2L_FunctionRef.new("abs", "kotlin/math/abs(kotlin.Double)", ____lambda_41)
    print(ka.name .. " " .. __K2L_Str(ka(-2.5)))
    print("isEmpty")
end

__K2L_Main(main)
return {describe = describe, read = read}
