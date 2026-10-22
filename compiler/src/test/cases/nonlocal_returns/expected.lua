local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Item = __K2L_Class("Item")

function Item:____init(name, price)
    self.name = name
    self.price = price
end

function Item.new(name, price)
    return setmetatable({name = name, price = price}, Item)
end

function Item:toString()
    return "Item(name=" .. self.name .. ", price=" .. self.price .. ")"
end

function Item:hashCode()
    return (31 * __K2L_Hash(self.name) + self.price + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Item:equals(other)
    return getmetatable(other) == Item and self.name == other.name and self.price == other.price
end

local function firstBig(xs)
    local ____result = __K2L_ListOf()
    for _, it in ipairs(xs) do
        local ____result_1
        if it > 100 then
            return "too big: " .. it
        end
        ____result_1 = it * 2
        ____result:add(____result_1)
    end
    local doubled = ____result
    return "ok " .. __K2L_Str(doubled)
end

local function mapNotNullStop(xs)
    local ____result_2 = __K2L_ListOf()
    for _, it in ipairs(xs) do
        local ____result_3
        if it == "stop" then
            return __K2L_ListOf()
        end
        ____result_3 = __K2L_StringToIntOrNull(it)
        local ____value = ____result_3
        if ____value ~= nil then
            ____result_2:add(____result_3)
        end
    end
    return ____result_2
end

local function filtered(xs)
    local ____result_4 = __K2L_ListOf()
    for _, it in ipairs(xs) do
        local ____result_5
        if it < 0 then
            return __K2L_ListOf(-1)
        end
        ____result_5 = it % 2 == 0
        if ____result_5 then
            ____result_4:add(it)
        end
    end
    local kept = ____result_4
    local ____result_6 = __K2L_ListOf()
    for _, it in ipairs(xs) do
        local ____result_7
        if it == 7 then
            return __K2L_ListOf(7)
        end
        ____result_7 = it % 2 == 0
        if not ____result_7 then
            ____result_6:add(it)
        end
    end
    local dropped = ____result_6
    return kept:plusAll(dropped)
end

local function anyAllNone(xs)
    local ____result_8 = false
    for _, it in ipairs(xs) do
        local ____result_9
        if it == 99 then
            return "found 99 in any"
        end
        ____result_9 = it > 5
        if ____result_9 then
            ____result_8 = true
            break
        end
    end
    local a = ____result_8
    local ____result_10 = true
    for _, it in ipairs(xs) do
        local ____result_11
        if it == 98 then
            return "found 98 in all"
        end
        ____result_11 = it > 0
        if not ____result_11 then
            ____result_10 = false
            break
        end
    end
    local b = ____result_10
    local ____result_12 = true
    for _, it in ipairs(xs) do
        local ____result_13
        if it == 97 then
            return "found 97 in none"
        end
        ____result_13 = it > 50
        if ____result_13 then
            ____result_12 = false
            break
        end
    end
    local c = ____result_12
    return tostring(a) .. " " .. tostring(b) .. " " .. tostring(c)
end

local function firsts(xs)
    local ____result_14
    local ____found = false
    for _, it in ipairs(xs) do
        local ____result_15
        if it == 13 then
            return "unlucky"
        end
        ____result_15 = it > 2
        if ____result_15 then
            ____result_14 = it
            ____found = true
            break
        end
    end
    if not ____found then
        error(__K2L_NoSuchElementException.new("Collection contains no element matching the predicate."))
    end
    local f = ____result_14
    local ____result_16
    for _, it in ipairs(xs) do
        local ____result_17
        if it == 14 then
            return "unlucky 14"
        end
        ____result_17 = it > 100
        if ____result_17 then
            ____result_16 = it
            break
        end
    end
    local g = ____result_16
    local ____result_18
    for _, it in ipairs(xs) do
        local ____result_19
        if it == 15 then
            return "unlucky 15"
        end
        ____result_19 = it > 3
        if ____result_19 then
            ____result_18 = it
            break
        end
    end
    local h = ____result_18
    return f .. " " .. __K2L_Str(g) .. " " .. __K2L_Str(h)
end

local function noMatch(xs)
    local ____result_20
    local ____found_1 = false
    for _, it in ipairs(xs) do
        local ____result_21
        if it == 0 then
            return -1
        end
        ____result_21 = it > 1000
        if ____result_21 then
            ____result_20 = it
            ____found_1 = true
            break
        end
    end
    if not ____found_1 then
        error(__K2L_NoSuchElementException.new("Collection contains no element matching the predicate."))
    end
    return ____result_20
end

local function counting(xs)
    local ____result_22 = 0
    for _, it in ipairs(xs) do
        local ____result_23
        if it == 0 then
            return -1
        end
        ____result_23 = it > 1
        if ____result_23 then
            ____result_22 = ____result_22 + 1
        end
    end
    local n = ____result_22
    return n
end

local function summing(xs)
    local ____sum = 0
    for _, it in ipairs(xs) do
        local ____result_24
        if it < 0 then
            return -1
        end
        ____result_24 = it * 10
        ____sum = ____sum + ____result_24
    end
    local total = ____sum
    local ____sum_1 = 0.0
    for _, it in ipairs(xs) do
        local ____result_25
        if it < 0 then
            return -1
        end
        ____result_25 = it / 2.0
        ____sum_1 = ____sum_1 + ____result_25
    end
    local half = ____sum_1
    print(half)
    return total
end

local function indexed(xs)
    for ____i = 1, xs.size do
        local s = xs[____i]
        local i = ____i - 1
        if s == "x" then
            return "x at " .. i
        end
    end
    return "no x"
end

local function each(xs)
    local seen = __K2L_ListOf()
    for _, it in ipairs(xs) do
        if it == 3 then
            return seen
        end
        seen:add(it)
    end
    local back = xs
    return back
end

local function takeWhileOrReturn(xs)
    local ____result_26 = __K2L_ListOf()
    for _, it in ipairs(xs) do
        local ____result_27
        if it == 100 then
            return __K2L_ListOf(100)
        end
        ____result_27 = it < 4
        if not ____result_27 then
            break
        end
        ____result_26:add(it)
    end
    return ____result_26
end

local function associating(items)
    local ____result_28 = __K2L_MapOf()
    for _, it in ipairs(items) do
        local ____result_29
        if it.price < 0 then
            return "negative " .. it.name
        end
        ____result_29 = it.name
        local ____value_1 = ____result_29
        ____result_28:put(____value_1, it)
    end
    local byName = ____result_28
    local ____result_30 = __K2L_MapOf()
    for _, it in ipairs(items) do
        local ____result_31
        if it.price < 0 then
            return "neg"
        end
        ____result_31 = #it.name
        local ____value_2 = ____result_31
        local ____value_3 = it.price
        ____result_30:put(____value_2, ____value_3)
    end
    local byLen = ____result_30
    local ____result_32 = __K2L_MapOf()
    for _, it in ipairs(items) do
        local ____result_33
        if it.price < 0 then
            return "negative price"
        end
        ____result_33 = it.price
        local ____value_4 = ____result_33
        ____result_32:put(it, ____value_4)
    end
    local prices = ____result_32
    local ____result_34 = __K2L_MapOf()
    for _, it in ipairs(items) do
        local ____result_35
        if #it.name == 0 then
            return "empty name"
        end
        ____result_35 = __K2L_Pair.new(it.name, it.price * 2)
        local ____value_5 = ____result_35
        ____result_34:put(____value_5.first, ____value_5.second)
    end
    local ____pairs = ____result_34
    return __K2L_Str(byName) .. " | " .. __K2L_Str(byLen) .. " | " .. __K2L_Str(prices) .. " | " .. __K2L_Str(____pairs)
end

local function grouping(xs)
    local ____result_36 = __K2L_MapOf()
    for _, it in ipairs(xs) do
        local ____result_37
        if it == 0 then
            return "zero"
        end
        ____result_37 = it % 3
        local ____value_6 = ____result_37
        local ____group = ____result_36:get(____value_6)
        if ____group == nil then
            ____group = __K2L_ListOf()
            ____result_36:put(____value_6, ____group)
        end
        ____group:add(it)
    end
    local g = ____result_36
    local ____result_38 = __K2L_MapOf()
    for _, it in ipairs(xs) do
        local ____result_39
        if it == 0 then
            return "zero"
        end
        ____result_39 = it % 2
        local ____value_7 = ____result_39
        local ____value_8 = "v" .. it
        local ____group_1 = ____result_38:get(____value_7)
        if ____group_1 == nil then
            ____group_1 = __K2L_ListOf()
            ____result_38:put(____value_7, ____group_1)
        end
        ____group_1:add(____value_8)
    end
    local h = ____result_38
    return __K2L_Str(g) .. " " .. __K2L_Str(h)
end

local function folding(xs)
    local ____acc = 0
    for _, x in ipairs(xs) do
        local ____result_40
        do
            local acc = ____acc
            if x < 0 then
                return acc
            end
            ____result_40 = acc + x
        end
        ____acc = ____result_40
    end
    return ____acc
end

local function labeled(xs)
    local ____result_41 = __K2L_ListOf()
    for _, it in ipairs(xs) do
        local ____result_42
        do
            if it == 0 then
                ____result_42 = -1
                goto ____inline_end
            end
            if it == 99 then
                return __K2L_ListOf()
            end
            ____result_42 = it
            ::____inline_end::
        end
        ____result_41:add(____result_42)
    end
    local r = ____result_41
    return r
end

local function nested(xss)
    local ____result_43 = __K2L_ListOf()
    for _, xs in ipairs(xss) do
        local ____result_44
        do
            local ____result_45 = __K2L_ListOf()
            for _, it in ipairs(xs) do
                local ____result_46
                if it < 0 then
                    return "negative inside"
                end
                ____result_46 = it + 1
                ____result_45:add(____result_46)
            end
            ____result_44 = ____result_45
        end
        ____result_43:add(____result_44)
    end
    local r = ____result_43
    return __K2L_Str(r)
end

local function nullable(xs)
    local ____result_47 = __K2L_ListOf()
    for ____i_1 = 1, xs.size do
        local it = xs[____i_1]
        local ____result_48
        if it == 0 then
            return __K2L_ListOf()
        end
        ____result_48 = it or -1
        ____result_47:add(____result_48)
    end
    return ____result_47
end

local function overSet(s)
    local ____result_49 = __K2L_ListOf()
    for _, it in ipairs(s:toList()) do
        local ____result_50
        if it == 4 then
            return 4
        end
        ____result_50 = it > 1
        if ____result_50 then
            ____result_49:add(it)
        end
    end
    for ____i_2 = 1, ____result_49.size do
        local x = ____result_49[____i_2]
        print("set " .. x)
    end
    return 0
end

local function overMap(m)
    local ____result_51 = __K2L_ListOf()
    for _, ____it in ipairs(m:____entryArray()) do
        local ____result_52
        do
            local k, v = ____it.key, ____it.value
            if v < 0 then
                return "negative " .. k
            end
            ____result_52 = k .. v
        end
        ____result_51:add(____result_52)
    end
    local keys = ____result_51
    local ____result_53 = false
    for _, it in ipairs(m:____entryArray()) do
        local ____result_54
        if it.value == 99 then
            return "99!"
        end
        ____result_54 = it.value > 1
        if ____result_54 then
            ____result_53 = true
            break
        end
    end
    local any = ____result_53
    return __K2L_Str(keys) .. " " .. tostring(any)
end

local function overArray(arr)
    local ____result_55 = __K2L_ListOf()
    for _, it in ipairs(arr) do
        local ____result_56
        if it == 0 then
            return -1
        end
        ____result_56 = it * 3
        ____result_55:add(____result_56)
    end
    local ys = ____result_55
    return ys:sum()
end

local function overRange()
    local ____list = __K2L_IntRange.new(1, 5)
    local ____result_57 = __K2L_ListOf()
    local ____list_1 = ____list:toList()
    for ____i_3 = 1, ____list_1.size do
        local it = ____list_1[____i_3]
        local ____result_58
        if it == 4 then
            return 40
        end
        ____result_58 = it * it
        ____result_57:add(____result_58)
    end
    local ys = ____result_57
    return ys:sum()
end

local function inLoop(xss)
    local out = __K2L_StringBuilder.new()
    for ____i_4 = 1, xss.size do
        local xs = xss[____i_4]
        local ____result_59 = __K2L_ListOf()
        for _, it in ipairs(xs) do
            local ____result_60
            if it == 0 then
                return out:append("!"):toString()
            end
            ____result_60 = it > 1
            if ____result_60 then
                ____result_59:add(it)
            end
        end
        local r = ____result_59
        out:append(__K2L_Str(r))
    end
    return out:toString()
end

local function inTry(xs)
    local ____ok, ____result_61, ____returned = pcall(function()
        local ____result_62 = __K2L_ListOf()
        for _, it in ipairs(xs) do
            local ____result_63
            if it == 0 then
                return true, "zero"
            end
            if it == 1 then
                error(__K2L_IllegalStateException.new("one"))
            end
            ____result_63 = it
            ____result_62:add(____result_63)
        end
        local r = ____result_62
        return true, "ok " .. __K2L_Str(r)
    end)
    if not ____ok then
        ____ok, ____result_61, ____returned = pcall(function()
            local ____error = __K2L_ToThrowable(____result_61)
            if __K2L_InstanceOf(____error, __K2L_IllegalStateException) then
                local e = ____error
                return true, "caught " .. __K2L_Str(e.message)
            else
                error(____error, 0)
            end
        end)
    end
    print("inTry finally")
    if not ____ok then
        error(____result_61, 0)
    end
    if ____result_61 then
        return ____returned
    end
end

local function valueOfMapAsExpression(xs)
    local ____result_64 = __K2L_ListOf()
    for _, it in ipairs(xs) do
        local ____result_65
        if it > 10 then
            return 10
        end
        ____result_65 = it
        ____result_64:add(____result_65)
    end
    return ____result_64:sum()
end

local function main()
    print(firstBig(__K2L_ListOf(1, 2, 3)))
    print(firstBig(__K2L_ListOf(1, 200, 3)))
    print(__K2L_Str(mapNotNullStop(__K2L_ListOf("1", "a", "3"))))
    print(__K2L_Str(mapNotNullStop(__K2L_ListOf("1", "stop", "3"))))
    print(__K2L_Str(filtered(__K2L_ListOf(1, 2, 3, 4))))
    print(__K2L_Str(filtered(__K2L_ListOf(1, -2, 3))))
    print(__K2L_Str(filtered(__K2L_ListOf(1, 7))))
    print(anyAllNone(__K2L_ListOf(1, 2, 3)))
    print(anyAllNone(__K2L_ListOf(1, 99)))
    print(anyAllNone(__K2L_ListOf(1, 98)))
    print(anyAllNone(__K2L_ListOf(1, 97)))
    print(firsts(__K2L_ListOf(1, 4, 5)))
    print(firsts(__K2L_ListOf(1, 13, 5)))
    print(firsts(__K2L_ListOf(1, 4, 14)))
    print(firsts(__K2L_ListOf(1, 4, 15)))
    print(noMatch(__K2L_ListOf(5, 0)))
    local ____ok_1, ____result_66 = pcall(function()
        noMatch(__K2L_ListOf(5, 6))
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_66)
        if __K2L_InstanceOf(____error_1, __K2L_NoSuchElementException) then
            local e = ____error_1
            print("NoSuchElementException: " .. __K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
    print(counting(__K2L_ListOf(1, 2, 3)))
    print(counting(__K2L_ListOf(1, 0, 3)))
    print(summing(__K2L_ListOf(1, 2, 3)))
    print(summing(__K2L_ListOf(1, -2, 3)))
    print(indexed(__K2L_ListOf("a", "x")))
    print(indexed(__K2L_ListOf("a")))
    print(__K2L_Str(each(__K2L_ListOf(1, 2, 4))))
    print(__K2L_Str(each(__K2L_ListOf(1, 2, 3, 4))))
    print(__K2L_Str(takeWhileOrReturn(__K2L_ListOf(1, 2, 5, 1))))
    print(__K2L_Str(takeWhileOrReturn(__K2L_ListOf(1, 100))))
    local items = __K2L_ListOf(Item.new("a", 1), Item.new("bb", 2))
    print(associating(items))
    print(associating(items:plus(Item.new("c", -1))))
    print(grouping(__K2L_ListOf(1, 2, 3, 4, 5)))
    print(grouping(__K2L_ListOf(1, 0)))
    print(folding(__K2L_ListOf(1, 2, 3)))
    print(folding(__K2L_ListOf(1, 2, -3, 4)))
    print(__K2L_Str(labeled(__K2L_ListOf(1, 0, 2))))
    print(__K2L_Str(labeled(__K2L_ListOf(1, 99, 2))))
    print(nested(__K2L_ListOf(__K2L_ListOf(1), __K2L_ListOf(2, 3))))
    print(nested(__K2L_ListOf(__K2L_ListOf(1), __K2L_ListOf(-2, 3))))
    print(__K2L_Str(nullable(__K2L_ListOf(1, nil, 3))))
    print(__K2L_Str(nullable(__K2L_ListOf(1, 0))))
    print(overSet(__K2L_SetOf(1, 2, 3)))
    print(overSet(__K2L_SetOf(1, 4)))
    print(overMap(__K2L_MapOf(__K2L_Pair.new("a", 1), __K2L_Pair.new("b", 2))))
    print(overMap(__K2L_MapOf(__K2L_Pair.new("a", 1), __K2L_Pair.new("b", -2))))
    print(overMap(__K2L_MapOf(__K2L_Pair.new("a", 99))))
    print(overArray(__K2L_ArrayOf(1, 2, 3)))
    print(overArray(__K2L_ArrayOf(1, 0)))
    print(overRange())
    print(inLoop(__K2L_ListOf(__K2L_ListOf(1, 2, 3), __K2L_ListOf(4, 0))))
    print(inTry(__K2L_ListOf(2, 3)))
    print(inTry(__K2L_ListOf(2, 0)))
    print(inTry(__K2L_ListOf(1)))
    print(valueOfMapAsExpression(__K2L_ListOf(1, 2)))
    print(valueOfMapAsExpression(__K2L_ListOf(1, 20)))
end

__K2L_RunMain(main)
return {Item = Item, firstBig = firstBig, mapNotNullStop = mapNotNullStop, filtered = filtered, anyAllNone = anyAllNone, firsts = firsts, noMatch = noMatch, counting = counting, summing = summing, indexed = indexed, each = each, takeWhileOrReturn = takeWhileOrReturn, associating = associating, grouping = grouping, folding = folding, labeled = labeled, nested = nested, nullable = nullable, overSet = overSet, overMap = overMap, overArray = overArray, overRange = overRange, inLoop = inLoop, inTry = inTry, valueOfMapAsExpression = valueOfMapAsExpression}
