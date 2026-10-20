local ____lualib = require("lualib_bundle")
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_JdkCollections = ____lualib.__K2L_JdkCollections
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_UnsupportedOperationException = ____lualib.__K2L_UnsupportedOperationException

local function attempt(label, block)
    local ____ok, ____result = __K2L_DeepPcall(function()
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
    print(__K2L_Str(view) .. " " .. view.size .. " " .. __K2L_Str(view:get(0)) .. " " .. tostring(view:isEmpty()))
    backing:add(4)
    backing:set(0, 10)
    print(__K2L_Str(view) .. " " .. view.size .. " " .. __K2L_Str(view:get(0)) .. " " .. __K2L_Str(view:last()) .. " " .. tostring(view:contains(4)))
    backing:removeAt(1)
    print(__K2L_Str(view) .. " " .. view.size)
    local seen = __K2L_ListOf()
    local ____mod = view.____modCount
    for ____i_1 = 1, view.size do
        local x = view[____i_1]
        seen:add(x)
        if view.____modCount ~= ____mod and view:____comodified(____i_1) then
            break
        end
    end
    local ____mod_1 = view.____modCount
    for ____i_2 = 1, view.size do
        local it = view[____i_2]
        seen:add(it * 100)
        if view.____modCount ~= ____mod_1 and view:____comodified(____i_2) then
            break
        end
    end
    local ____mod_2 = view.____modCount
    for ____i_3 = 1, view.size do
        local x = view[____i_3]
        local i = ____i_3 - 1
        seen:add(i * 1000 + x)
        if view.____modCount ~= ____mod_2 and view:____comodified(____i_3) then
            break
        end
    end
    print(__K2L_Str(seen))
    print(total(view))
    local ____out = {}
    local ____count = 0
    local ____items, ____n = view:____array()
    for ____i_4 = 1, ____n do
        local it = ____items[____i_4]
        ____count = ____count + 1
        ____out[____count] = it + 1
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = view:____array()
    for ____i_5 = 1, ____n_1 do
        local it = ____items_1[____i_5]
        if it > 3 then
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = it
        end
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
    local ____result_1 = false
    local ____items_2, ____n_2 = view:____array()
    for ____i_6 = 1, ____n_2 do
        local it = ____items_2[____i_6]
        if it > 9 then
            ____result_1 = true
            break
        end
    end
    print(____result_1)
    local ____sum = 0
    local ____items_3, ____n_3 = view:____array()
    for ____i_7 = 1, ____n_3 do
        local it = ____items_3[____i_7]
        ____sum = ____sum + it
    end
    print(____sum)
    print(__K2L_Str(view:getIndices()))
    print(__K2L_Str(view:withIndex():map(function(____destructured)
        local i, x = ____destructured.index, ____destructured.value
        return i * x
    end)))
    print(__K2L_Str(view:sorted()))
    print(view:joinToString("-"))
    print(view:sum())
    local ____result_2
    local ____found = false
    local ____items_4, ____n_4 = view:____array()
    for ____i_8 = 1, ____n_4 do
        local it = ____items_4[____i_8]
        if it > 3 then
            ____result_2 = it
            ____found = true
            break
        end
    end
    if not ____found then
        error(__K2L_NoSuchElementException.new("Collection contains no element matching the predicate."))
    end
    local firstBig = ____result_2
    print(__K2L_NotNull(firstBig))
    for i = 0, view.size - 1 do
        local x = view[i + 1]
        io.write(i .. "=" .. __K2L_Str(x) .. " ")
    end
    print()
    for i = 0, view.size - 1 do
        io.write(__K2L_Str(__K2L_NotNull(view:get(i))))
    end
    print()
    print(__K2L_Equals(view, backing))
    print(__K2L_Equals(view, __K2L_ReadOnlyListOf(10, 3, 4)))
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
    backing:addAll(__K2L_ReadOnlyListOf(7, 8))
    print(outer.size .. " " .. __K2L_Str(outer))
    local nullable = __K2L_ListOf("a", nil)
    local nullView = __K2L_JdkCollections.unmodifiableList(nullable)
    nullable:add("c")
    local count = 0
    local ____mod_3 = nullView.____modCount
    for ____i_9 = 1, nullView.size do
        local s = nullView[____i_9]
        if s == nil then
            count = count + 1
        end
        if nullView.____modCount ~= ____mod_3 and nullView:____comodified(____i_9) then
            break
        end
    end
    print(__K2L_Str(nullView) .. " " .. count)
    local s = __K2L_SetOf(3, 1, 2)
    local sv = __K2L_JdkCollections.unmodifiableSet(s)
    s:add(9)
    s:remove(1)
    print(__K2L_Str(sv) .. " " .. sv.size .. " " .. tostring(sv:contains(9)) .. " " .. tostring(sv:contains(1)))
    local ____items_5, ____n_5 = sv:____array()
    for ____i_10 = 1, ____n_5 do
        local x = ____items_5[____i_10]
        io.write(__K2L_Str(__K2L_NotNull(x)))
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
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_6, ____n_6 = sv:____array()
    for ____i_11 = 1, ____n_6 do
        local it = ____items_6[____i_11]
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = it * 2
    end
    print(__K2L_Str(__K2L_ListWrap(____out_2, ____count_2)))
    local m = __K2L_MapOf(__K2L_Pair.new("a", 1), __K2L_Pair.new("b", 2))
    local mv = __K2L_JdkCollections.unmodifiableMap(m)
    m:set("c", 3)
    m:remove("a")
    print(__K2L_Str(mv) .. " " .. mv.size .. " " .. __K2L_Str(mv:get("c")) .. " " .. tostring(mv:containsKey("a")) .. " " .. __K2L_Str(mv:getKeys()) .. " " .. __K2L_Str(mv:getValues()))
    local ____keys, ____values, ____n_7 = mv:____arrays()
    local ____mod_4 = mv.____modCount
    for ____i_12 = 1, ____n_7 do
        local k, v = ____keys[____i_12], ____values[____i_12]
        io.write(__K2L_Str(k) .. __K2L_Str(v) .. " ")
        if mv.____modCount ~= ____mod_4 and mv:____comodified(____i_12, ____n_7) then
            break
        end
    end
    print()
    local ____list = mv:getEntries()
    local ____out_3 = {}
    local ____count_3 = 0
    local ____items_7, ____n_8 = ____list:____array()
    for ____i_13 = 1, ____n_8 do
        local it = ____items_7[____i_13]
        ____count_3 = ____count_3 + 1
        ____out_3[____count_3] = it.key .. __K2L_Str(it.value)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_3, ____count_3)))
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
    print(c.size .. " " .. __K2L_Str(c))
    local cs = __K2L_JdkCollections.unmodifiableCollection(s)
    s:add(77)
    print(cs.size .. " " .. tostring(cs:contains(77)))
end

__K2L_DeepMain(main)
return {attempt = attempt, total = total}
