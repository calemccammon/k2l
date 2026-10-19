local ____lualib = require("lualib_bundle")
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_JdkCollections = ____lualib.__K2L_JdkCollections
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function attempt(label, block)
    local ____ok, ____result = pcall(function()
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

local function defaults()
    print("-- withDefault")
    local base = __K2L_MapOf(__K2L_Pair.new("a", 1), __K2L_Pair.new("b", 2))
    local m = __K2L_JdkCollections.withDefault(base, function(it) return #it * 10 end)
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
    for k, v in m:iter() do
        print(k .. "=" .. v)
    end
    print(base:getValue("a"))
    attempt("noDefault", function() return base:getValue("zz") end)
    local counts = __K2L_JdkCollections.withDefault(__K2L_MapOf(), function(it) return 0 end)
    for _, w in ipairs(__K2L_StringSplit("a b a c b a", " ")) do
        counts:set(w, counts:getValue(w) + 1)
    end
    print(__K2L_Str(counts))
    print(counts:getValue("nothing"))
    print(counts.size)
    local lists = __K2L_JdkCollections.withDefault(__K2L_MapOf(), function(it) return __K2L_ListOf() end)
    lists:set(1, __K2L_ListOf("x"))
    print(__K2L_Str(lists:getValue(1)))
    print(__K2L_Str(lists:getValue(2)))
    print(__K2L_Str(lists:map(function(it) return it.key end):sorted()))
    local sorted = __K2L_JdkCollections.withDefault(__K2L_SortedMapOf(__K2L_Pair.new("z", 1), __K2L_Pair.new("y", 2)), function(it) return 99 end)
    print(sorted:getValue("q"))
    print(__K2L_Str(sorted:getKeys()))
end

local function iterators()
    print("-- listIterator")
    local list = __K2L_ListOf(1, 2, 3, 4, 5)
    local it = __K2L_JdkCollections.listIterator(list)
    print(tostring(it:hasPrevious()) .. " " .. it:nextIndex() .. " " .. it:previousIndex())
    while it:hasNext() do
        local idx = it:nextIndex()
        local v = it:next()
        if math.fmod(v, 2) == 0 then
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
    attempt("empty", function()
        return __K2L_JdkCollections.listIterator(__K2L_ListOf()):next()
    end)
    attempt("noPrev", function()
        return __K2L_JdkCollections.listIterator(list):previous()
    end)
    attempt("badIndex", function()
        return __K2L_JdkCollections.listIterator(list, 99)
    end)
    attempt("removeFirst", function()
        __K2L_JdkCollections.listIterator(list):remove()
    end)
    attempt("setFirst", function()
        __K2L_JdkCollections.listIterator(list):set(1)
    end)
    local again = __K2L_JdkCollections.listIterator(list)
    again:next()
    again:remove()
    attempt("removeTwice", function()
        again:remove()
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
    local ro = __K2L_JdkCollections.listIterator(__K2L_ListOf(1, 2, 3))
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

main()
return {attempt = attempt, defaults = defaults, iterators = iterators}
