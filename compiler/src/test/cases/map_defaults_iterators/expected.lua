local ____lualib = require("lualib_bundle")
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_JdkCollections = ____lualib.__K2L_JdkCollections
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Unit = ____lualib.__K2L_Unit

local function attempt(label, block)
    local ____ok, ____result = __K2L_DeepPcall(function()
        print(label .. ": " .. __K2L_Str(block()))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_Exception) then
            local e = ____error
            print(label .. ": " .. __K2L_Str(__K2L_KClassOfValue(e).simpleName) .. ": " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
end

local ____lambda_1 = function(it) return #it * 10 end
local ____lambda_2 = function(it) return 0 end
local ____lambda_3 = function(it) return __K2L_ReadOnlyListOf() end
local ____lambda_4 = function(it) return it.key end
local ____lambda_5 = function(it) return 99 end
local function defaults()
    print("-- withDefault")
    local base = __K2L_ReadOnlyMapOf(__K2L_Pair.new("a", 1), __K2L_Pair.new("b", 2))
    local m = __K2L_JdkCollections.withDefault(base, ____lambda_1)
    print(m:getValue("a"))
    print(m:getValue("missing"))
    print(__K2L_Str(m:get("missing")))
    print(__K2L_Str(m:get("a")))
    print(m:getOrDefault("zz", -1))
    print(m.size)
    print(__K2L_Str(m))
    print(m:containsKey("missing"))
    print(__K2L_Str(m:getKeys()))
    print(__K2L_Equals(m, base))
    local ____keys, ____values, ____n = m:____arrays()
    for ____i = 1, ____n do
        local k, v = ____keys[____i], ____values[____i]
        print(k .. "=" .. v)
    end
    print(base:getValue("a"))
    attempt("noDefault", function() return base:getValue("zz") end)
    local counts = __K2L_JdkCollections.withDefault(__K2L_MapOf(), ____lambda_2)
    local ____list = __K2L_StringSplit("a b a c b a", " ")
    local ____mod = ____list.____modCount
    for ____i_1 = 1, ____list.size do
        local w = ____list[____i_1]
        counts:set(w, counts:getValue(w) + 1)
        if ____list.____modCount ~= ____mod and ____list:____comodified(____i_1) then
            break
        end
    end
    print(__K2L_Str(counts))
    print(counts:getValue("nothing"))
    print(counts.size)
    local lists = __K2L_JdkCollections.withDefault(__K2L_MapOf(), ____lambda_3)
    lists:set(1, __K2L_SingletonListOf("x"))
    print(__K2L_Str(lists:getValue(1)))
    print(__K2L_Str(lists:getValue(2)))
    print(__K2L_Str(lists:map(____lambda_4):sorted()))
    local sorted = __K2L_JdkCollections.withDefault(__K2L_SortedMapOf(__K2L_Pair.new("z", 1), __K2L_Pair.new("y", 2)), ____lambda_5)
    print(__K2L_NotNull(sorted:getValue("q")))
    print(__K2L_Str(sorted:getKeys()))
end

local ____lambda_6 = function()
    return __K2L_JdkCollections.listIterator(__K2L_ListOf()):next()
end
local function iterators()
    print("-- listIterator")
    local list = __K2L_ListOf(1, 2, 3, 4, 5)
    local it = __K2L_JdkCollections.listIterator(list)
    print(tostring(it:hasPrevious()) .. " " .. it:nextIndex() .. " " .. it:previousIndex())
    while it:hasNext() do
        local idx = it:nextIndex()
        local v = it:next()
        if (v >= 0 and v % 2 or 0 - -v % 2) == 0 then
            it:set(v * 10)
        end
        if v == 3 then
            it:add(33)
        end
        if v == 5 then
            it:remove()
        end
        print(idx .. " " .. v .. " -> " .. __K2L_Str(list))
    end
    while it:hasPrevious() do
        io.write(it:previous() .. " ")
    end
    print()
    print(__K2L_Str(list))
    local mid = __K2L_JdkCollections.listIterator(list, 2)
    print(mid:nextIndex() .. " " .. mid:next() .. " " .. mid:previous() .. " " .. mid:previous())
    local ____end = __K2L_JdkCollections.listIterator(list, list.size)
    print(____end:hasNext())
    print(____end:previous())
    attempt("empty", ____lambda_6)
    attempt("noPrev", function()
        return __K2L_JdkCollections.listIterator(list):previous()
    end)
    attempt("badIndex", function()
        return __K2L_JdkCollections.listIterator(list, 99)
    end)
    attempt("removeFirst", function()
        __K2L_JdkCollections.listIterator(list):remove()
        return __K2L_Unit
    end)
    attempt("setFirst", function()
        __K2L_JdkCollections.listIterator(list):set(1)
        return __K2L_Unit
    end)
    local again = __K2L_JdkCollections.listIterator(list)
    again:next()
    again:remove()
    attempt("removeTwice", function()
        again:remove()
        return __K2L_Unit
    end)
    print(__K2L_Str(list))
    local words = __K2L_ListOf("a", "b", "c")
    local wi = __K2L_JdkCollections.listIterator(words)
    while wi:hasNext() do
        local w = wi:next()
        wi:set(w:upper())
        wi:add(w)
    end
    print(__K2L_Str(words))
    local ro = __K2L_JdkCollections.listIterator(__K2L_ReadOnlyListOf(1, 2, 3))
    local sum = 0
    while ro:hasNext() do
        sum = sum + ro:next()
    end
    print(sum)
end

local function main()
    defaults()
    iterators()
end

__K2L_DeepMain(main)
return {attempt = attempt, defaults = defaults, iterators = iterators}
