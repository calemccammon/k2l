local ____lualib = require("lualib_bundle")
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_JdkCollections = ____lualib.__K2L_JdkCollections
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_UnsupportedOperationException = ____lualib.__K2L_UnsupportedOperationException

local function attempt(label, block)
    local ____ok, ____result = pcall(function()
        block()
        print(label .. ": ok")
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_UnsupportedOperationException) then
            local e = ____error
            print(label .. ": UnsupportedOperationException")
        else
            error(____error, 0)
        end
    end
end

local function total(xs)
    local sum = 0
    for ____i = 1, xs.size do
        local x = xs[____i]
        sum = sum + x
    end
    return sum
end

local function main()
    local backing = __K2L_ListOf(1, 2, 3)
    local view = __K2L_JdkCollections.unmodifiableList(backing)
    print(__K2L_Str(view) .. " " .. view.size .. " " .. view:get(0) .. " " .. tostring(view:isEmpty()))
    backing:add(4)
    backing:set(0, 10)
    print(__K2L_Str(view) .. " " .. view.size .. " " .. view:get(0) .. " " .. view:last() .. " " .. tostring(view:contains(4)))
    backing:removeAt(1)
    print(__K2L_Str(view) .. " " .. view.size)
    local seen = __K2L_ListOf()
    for ____i_1 = 1, view.size do
        local x = view[____i_1]
        seen:add(x)
    end
    for ____i_2 = 1, view.size do
        local it = view[____i_2]
        seen:add(it * 100)
    end
    for i = 0, view.size - 1 do
        local x = view[i + 1]
        seen:add(i * 1000 + x)
    end
    print(__K2L_Str(seen))
    print(total(view))
    print(__K2L_Str(view:map(function(it) return it + 1 end)))
    print(__K2L_Str(view:filter(function(it) return it > 3 end)))
    print(view:any(function(it) return it > 9 end))
    print(view:sumOf(function(it) return it end))
    print(__K2L_Str(view:getIndices()))
    print(__K2L_Str(view:withIndex():map(function(____destructured)
        local i, x = ____destructured.index, ____destructured.value
        return i * x
    end)))
    print(__K2L_Str(view:sorted()))
    print(view:joinToString("-"))
    print(view:sum())
    local firstBig = view:first(function(it) return it > 3 end)
    print(firstBig)
    for i = 0, view.size - 1 do
        local x = view[i + 1]
        io.write(i .. "=" .. x .. " ")
    end
    print()
    for i = 0, view.size - 1 do
        io.write(tostring(view:get(i)))
    end
    print()
    print(__K2L_Equals(view, backing))
    print(__K2L_Equals(view, __K2L_ListOf(10, 3, 4)))
    print(__K2L_Hash(view) == __K2L_Hash(backing))
    local copy = view:toMutableList()
    backing:add(5)
    print(__K2L_Str(copy) .. " " .. __K2L_Str(view))
    print(__K2L_Str(view:subList(0, 2)))
    attempt("add", function()
        view:add(1)
    end)
    attempt("set", function()
        view:set(0, 1)
    end)
    attempt("removeAt", function()
        view:removeAt(0)
    end)
    attempt("clear", function()
        view:clear()
    end)
    attempt("sort", function()
        __K2L_JdkCollections.sort(view)
    end)
    attempt("iterator", function()
        local it = __K2L_IteratorOf(view)
        it:next()
        it:remove()
    end)
    print(__K2L_Str(view))
    local outer = __K2L_JdkCollections.unmodifiableList(view)
    backing:clear()
    print(outer.size .. " " .. __K2L_Str(outer))
    backing:addAll(__K2L_ListOf(7, 8))
    print(outer.size .. " " .. __K2L_Str(outer))
    local nullable = __K2L_ListOf("a", nil)
    local nullView = __K2L_JdkCollections.unmodifiableList(nullable)
    nullable:add("c")
    local count = 0
    for ____i_3 = 1, nullView.size do
        local s = nullView[____i_3]
        if s == nil then
            count = count + 1
        end
    end
    print(__K2L_Str(nullView) .. " " .. count)
    local s = __K2L_SetOf(3, 1, 2)
    local sv = __K2L_JdkCollections.unmodifiableSet(s)
    s:add(9)
    s:remove(1)
    print(__K2L_Str(sv) .. " " .. sv.size .. " " .. tostring(sv:contains(9)) .. " " .. tostring(sv:contains(1)))
    local ____list = sv:toList()
    for ____i_4 = 1, ____list.size do
        local x = ____list[____i_4]
        io.write(tostring(x))
    end
    print()
    attempt("setAdd", function()
        sv:add(5)
    end)
    attempt("setRemove", function()
        sv:remove(3)
    end)
    attempt("setClear", function()
        sv:clear()
    end)
    print(__K2L_Str(sv:map(function(it) return it * 2 end)))
    local m = __K2L_MapOf(__K2L_Pair.new("a", 1), __K2L_Pair.new("b", 2))
    local mv = __K2L_JdkCollections.unmodifiableMap(m)
    m:set("c", 3)
    m:remove("a")
    print(__K2L_Str(mv) .. " " .. mv.size .. " " .. __K2L_Str(mv:get("c")) .. " " .. tostring(mv:containsKey("a")) .. " " .. __K2L_Str(mv:getKeys()) .. " " .. __K2L_Str(mv:getValues()))
    for k, v in mv:iter() do
        io.write(__K2L_Str(k) .. v .. " ")
    end
    print()
    print(__K2L_Str(mv:getEntries():map(function(it) return it.key .. it.value end)))
    attempt("put", function()
        mv:set("z", 0)
    end)
    attempt("mapRemove", function()
        mv:remove("b")
    end)
    attempt("mapClear", function()
        mv:clear()
    end)
    local hm = __K2L_HashMap.new()
    local hv = __K2L_JdkCollections.unmodifiableMap(hm)
    hm:set("zebra", 1)
    hm:set("apple", 2)
    hm:set("mango", 3)
    print(__K2L_Str(hv))
    print(__K2L_Str(hv:getKeys():toList()))
    local c = __K2L_JdkCollections.unmodifiableCollection(backing)
    backing:add(1)
    print(c:count() .. " " .. __K2L_Str(c))
    local cs = __K2L_JdkCollections.unmodifiableCollection(s)
    s:add(77)
    print(cs:count() .. " " .. tostring(cs:contains(77)))
end

main()
return {attempt = attempt, total = total}
