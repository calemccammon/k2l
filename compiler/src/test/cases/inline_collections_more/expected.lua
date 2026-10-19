local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListBuilderOf = ____lualib.__K2L_ListBuilderOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapBuilderOf = ____lualib.__K2L_MapBuilderOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_SequenceOf = ____lualib.__K2L_SequenceOf
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf
local __K2L_UnsupportedOperationException = ____lualib.__K2L_UnsupportedOperationException

local Item = __K2L_Class("Item")

function Item:____init(name, price)
    self.name = name
    self.price = price
end

function Item:toString()
    return "Item(name=" .. self.name .. ", price=" .. self.price .. ")"
end

function Item:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.name) + __K2L_Hash(self.price))
end

function Item:equals(other)
    return getmetatable(other) == Item and self.name == other.name and self.price == other.price
end

local items = __K2L_ReadOnlyListOf(Item.new("pen", 3), Item.new("book", 12), Item.new("cup", 7), Item.new("lamp", 12))

local function partitions(xs, stopAt)
    local ____yes = __K2L_ListOf()
    local ____no = __K2L_ListOf()
    for _, it in ipairs(xs) do
        local ____result
        if it == stopAt then
            return "stopped at " .. it
        end
        ____result = it < 5
        if ____result then
            ____yes:add(it)
        else
            ____no:add(it)
        end
    end
    local ____destructured = __K2L_Pair.new(____yes, ____no)
    local small, big = ____destructured.first, ____destructured.second
    return __K2L_Str(small) .. " " .. __K2L_Str(big)
end

local function maxBys(stopAt)
    local ____list = items
    local ____best
    local ____bestKey
    local ____has = false
    for _, it in ipairs(____list) do
        local ____result_1
        if it.price == stopAt then
            return "max stop " .. it.name
        end
        ____result_1 = it.price
        local ____key = ____result_1
        if not ____has or __K2L_Compare(____key, ____bestKey) > 0 then
            ____best = it
            ____bestKey = ____key
            ____has = true
        end
    end
    local a = ____best
    local b = items:minByOrNull(function(it) return it.price end)
    local ____list_1 = items
    local ____best_1
    local ____bestKey_1
    local ____has_1 = false
    for _, it in ipairs(____list_1) do
        local ____result_2
        do
            local ____arg = it.price
            local ____temp
            if it.name == "zzz" then
                return "never"
            else
                ____temp = 0
            end
            ____result_2 = ____arg + ____temp
        end
        local ____key_1 = ____result_2
        if not ____has_1 or __K2L_Compare(____key_1, ____bestKey_1) > 0 then
            ____best_1 = it
            ____bestKey_1 = ____key_1
            ____has_1 = true
        end
    end
    if not ____has_1 then
        error(__K2L_NoSuchElementException.new(nil))
    end
    local c = ____best_1
    local ____list_2 = items
    local ____best_2
    local ____bestKey_2
    local ____has_2 = false
    for _, it in ipairs(____list_2) do
        local ____result_3
        if it.name == "x" then
            return "never"
        else
            ____result_3 = it.name
        end
        local ____key_2 = ____result_3
        if not ____has_2 or __K2L_Compare(____key_2, ____bestKey_2) < 0 then
            ____best_2 = it
            ____bestKey_2 = ____key_2
            ____has_2 = true
        end
    end
    if not ____has_2 then
        error(__K2L_NoSuchElementException.new(nil))
    end
    local d = ____best_2
    local ____list_3 = __K2L_ReadOnlyListOf()
    local ____best_3
    local ____bestKey_3
    local ____has_3 = false
    for _, it in ipairs(____list_3) do
        local ____result_4
        if it.price == 0 then
            return "no"
        else
            ____result_4 = it.price
        end
        local ____key_3 = ____result_4
        if not ____has_3 or __K2L_Compare(____key_3, ____bestKey_3) > 0 then
            ____best_3 = it
            ____bestKey_3 = ____key_3
            ____has_3 = true
        end
    end
    local e = ____best_3
    return __K2L_Str(a and a.name) .. " " .. __K2L_Str(b and b.name) .. " " .. c.name .. " " .. d.name .. " " .. __K2L_Str(e)
end

local function extremes(stopAt)
    local ____list_4 = items
    local ____best_4
    local ____bestKey_4
    local ____has_4 = false
    for _, it in ipairs(____list_4) do
        local ____result_5
        if it.price == stopAt then
            return "maxOf stop"
        end
        ____result_5 = it.name
        local ____key_4 = ____result_5
        if not ____has_4 or __K2L_Compare(____key_4, ____bestKey_4) > 0 then
            ____best_4 = it
            ____bestKey_4 = ____key_4
            ____has_4 = true
        end
    end
    if not ____has_4 then
        error(__K2L_NoSuchElementException.new(nil))
    end
    local a = ____bestKey_4
    local ____list_5 = items
    local ____best_5
    local ____bestKey_5
    local ____has_5 = false
    for _, it in ipairs(____list_5) do
        local ____result_6
        if it.price == -1 then
            return "never"
        end
        ____result_6 = it.price
        local ____key_5 = ____result_6
        if not ____has_5 or __K2L_Compare(____key_5, ____bestKey_5) < 0 then
            ____best_5 = it
            ____bestKey_5 = ____key_5
            ____has_5 = true
        end
    end
    if not ____has_5 then
        error(__K2L_NoSuchElementException.new(nil))
    end
    local b = ____bestKey_5
    local ____list_6 = __K2L_ReadOnlyListOf()
    local ____best_6
    local ____bestKey_6
    local ____has_6 = false
    for _, it in ipairs(____list_6) do
        local ____result_7
        if it == 0 then
            return "no"
        else
            ____result_7 = it
        end
        local ____key_6 = ____result_7
        if not ____has_6 or __K2L_Compare(____key_6, ____bestKey_6) > 0 then
            ____best_6 = it
            ____bestKey_6 = ____key_6
            ____has_6 = true
        end
    end
    local c = ____bestKey_6
    local ____list_7 = items
    local ____best_7
    local ____bestKey_7
    local ____has_7 = false
    for _, it in ipairs(____list_7) do
        local ____result_8
        if it.price == 99 then
            return "never"
        else
            ____result_8 = it.price * 2
        end
        local ____key_7 = ____result_8
        if not ____has_7 or __K2L_Compare(____key_7, ____bestKey_7) > 0 then
            ____best_7 = it
            ____bestKey_7 = ____key_7
            ____has_7 = true
        end
    end
    local d = ____bestKey_7
    return a .. " " .. b .. " " .. __K2L_Str(c) .. " " .. __K2L_Str(d)
end

local function reduces(xs, stopAt)
    local ____acc
    local ____started = false
    for _, x in ipairs(xs) do
        if not ____started then
            ____acc = x
            ____started = true
        else
            local ____result_9
            do
                local acc = ____acc
                if x == stopAt then
                    return "reduce stop"
                end
                ____result_9 = acc + x
            end
            ____acc = ____result_9
        end
    end
    if not ____started then
        error(__K2L_UnsupportedOperationException.new("Empty collection can't be reduced."))
    end
    local a = ____acc
    local ____acc_1
    local ____started_1 = false
    for _, x in ipairs(xs) do
        if not ____started_1 then
            ____acc_1 = x
            ____started_1 = true
        else
            local ____result_10
            do
                local acc = ____acc_1
                if x == -7 then
                    return "never"
                end
                ____result_10 = acc * x
            end
            ____acc_1 = ____result_10
        end
    end
    local b = ____acc_1
    local ____list_8 = __K2L_ReadOnlyListOf()
    local ____acc_2
    local ____started_2 = false
    for _, x in ipairs(____list_8) do
        if not ____started_2 then
            ____acc_2 = x
            ____started_2 = true
        else
            local ____result_11
            do
                local acc = ____acc_2
                if x == 0 then
                    return "no"
                else
                    ____result_11 = acc + x
                end
            end
            ____acc_2 = ____result_11
        end
    end
    local c = ____acc_2
    return a .. " " .. __K2L_Str(b) .. " " .. __K2L_Str(c)
end

local function emptyReduce()
    local ____ok, ____result_12, ____returned = pcall(function()
        local ____list_9 = __K2L_ReadOnlyListOf()
        local ____acc_3
        local ____started_3 = false
        for _, b in ipairs(____list_9) do
            if not ____started_3 then
                ____acc_3 = b
                ____started_3 = true
            else
                local ____result_13
                do
                    local a = ____acc_3
                    if a == 0 then
                        return true, "no"
                    else
                        ____result_13 = a + b
                    end
                end
                ____acc_3 = ____result_13
            end
        end
        if not ____started_3 then
            error(__K2L_UnsupportedOperationException.new("Empty collection can't be reduced."))
        end
    end)
    if ____ok then
        if ____result_12 then
            return ____returned
        end
    else
        local ____error = __K2L_ToThrowable(____result_12)
        if __K2L_InstanceOf(____error, __K2L_UnsupportedOperationException) then
            local e = ____error
            return "caught " .. __K2L_Str(e.message)
        else
            error(____error, 0)
        end
    end
    return "none"
end

local function distincts(xs, stop)
    local ____seen = __K2L_SetOf()
    local ____result_14 = __K2L_ListOf()
    for _, it in ipairs(xs) do
        local ____result_15
        if it == stop then
            return __K2L_SingletonListOf("stopped")
        end
        ____result_15 = #it
        if ____seen:add(____result_15) then
            ____result_14:add(it)
        end
    end
    return ____result_14
end

local function indexedOps(xs, stopAt)
    local ____result_16 = __K2L_ListOf()
    for ____i = 1, xs.size do
        local x = xs[____i]
        local i = ____i - 1
        local ____result_17
        if x == stopAt then
            return "idx stop " .. i
        end
        ____result_17 = math.fmod(i, 2) == 0 and x > 0
        if ____result_17 then
            ____result_16:add(x)
        end
    end
    local a = ____result_16
    local ____result_18 = __K2L_ListOf()
    for ____i_1 = 1, xs.size do
        local x = xs[____i_1]
        local i = ____i_1 - 1
        local ____result_19
        if x == -100 then
            return "never"
        end
        ____result_19 = i * x
        ____result_18:add(____result_19)
    end
    local b = ____result_18
    return __K2L_Str(a) .. " " .. __K2L_Str(b)
end

local function indexSearch(xs, stopAt)
    local ____index = -1
    for ____i_2 = 1, xs.size do
        local it = xs[____i_2]
        local ____index_1 = ____i_2 - 1
        local ____result_20
        if it == stopAt then
            return "first stop"
        end
        ____result_20 = it > 2
        if ____result_20 then
            ____index = ____index_1
            break
        end
    end
    local a = ____index
    local ____index_2 = -1
    for ____i_3 = xs.size, 1, -1 do
        local it = xs[____i_3]
        local ____index_3 = ____i_3 - 1
        local ____result_21
        if it == -1 then
            return "never"
        end
        ____result_21 = it > 2
        if ____result_21 then
            ____index_2 = ____index_3
            break
        end
    end
    local b = ____index_2
    local ____index_4 = -1
    for ____i_4 = 1, xs.size do
        local it = xs[____i_4]
        local ____index_5 = ____i_4 - 1
        local ____result_22
        do
            local ____cond = it > 1000
            if ____cond then
                local ____temp_1
                if it == -5 then
                    return "never"
                else
                    ____temp_1 = true
                end
                ____cond = ____temp_1
            end
            ____result_22 = ____cond
        end
        if ____result_22 then
            ____index_4 = ____index_5
            break
        end
    end
    local c = ____index_4
    return a .. " " .. b .. " " .. c
end

local function lasts(xs, stopAt)
    local ____result_23
    local ____found = false
    for ____i_5 = xs.size, 1, -1 do
        local it = xs[____i_5]
        local ____result_24
        if it == stopAt then
            return "last stop"
        end
        ____result_24 = math.fmod(it, 2) == 1
        if ____result_24 then
            ____result_23 = it
            ____found = true
            break
        end
    end
    if not ____found then
        error(__K2L_NoSuchElementException.new("List contains no element matching the predicate."))
    end
    local a = ____result_23
    local ____result_25
    local ____found_1 = false
    for ____i_6 = xs.size, 1, -1 do
        local it = xs[____i_6]
        local ____result_26
        if it == -3 then
            return "never"
        end
        ____result_26 = it > 100
        if ____result_26 then
            ____result_25 = it
            ____found_1 = true
            break
        end
    end
    local b = ____result_25
    local ____result_27
    local ____found_2 = false
    for ____i_7 = xs.size, 1, -1 do
        local it = xs[____i_7]
        local ____result_28
        if it == -3 then
            return "never"
        end
        ____result_28 = it < 3
        if ____result_28 then
            ____result_27 = it
            ____found_2 = true
            break
        end
    end
    local c = ____result_27
    return a .. " " .. __K2L_Str(b) .. " " .. __K2L_Str(c)
end

local function lastNone(xs)
    local ____ok_1, ____result_29, ____returned_1 = pcall(function()
        local ____result_30
        local ____found_3 = false
        for ____i_8 = xs.size, 1, -1 do
            local it = xs[____i_8]
            local ____result_31
            if it == -3 then
                return true, "never"
            end
            ____result_31 = it > 100
            if ____result_31 then
                ____result_30 = it
                ____found_3 = true
                break
            end
        end
        if not ____found_3 then
            error(__K2L_NoSuchElementException.new("List contains no element matching the predicate."))
        end
    end)
    if ____ok_1 then
        if ____result_29 then
            return ____returned_1
        end
    else
        local ____error_1 = __K2L_ToThrowable(____result_29)
        if __K2L_InstanceOf(____error_1, __K2L_NoSuchElementException) then
            local e = ____error_1
            return "caught " .. __K2L_Str(e.message)
        else
            error(____error_1, 0)
        end
    end
    return "none"
end

local function singles(xs, stopAt)
    local ____result_32
    local ____found_4 = false
    for _, it in ipairs(xs) do
        local ____result_33
        if it == stopAt then
            return "single stop"
        end
        ____result_33 = it == 3
        if ____result_33 then
            if ____found_4 then
                error(__K2L_IllegalArgumentException.new("Collection contains more than one matching element."))
            end
            ____result_32 = it
            ____found_4 = true
        end
    end
    if not ____found_4 then
        error(__K2L_NoSuchElementException.new("Collection contains no element matching the predicate."))
    end
    local a = ____result_32
    local ____result_34
    local ____found_5 = false
    for _, it in ipairs(xs) do
        local ____result_35
        if it == -3 then
            return "never"
        end
        ____result_35 = it > 0
        if ____result_35 then
            if ____found_5 then
                ____result_34 = nil
                break
            end
            ____result_34 = it
            ____found_5 = true
        end
    end
    local b = ____result_34
    local ____result_36
    local ____found_6 = false
    for _, it in ipairs(xs) do
        local ____result_37
        do
            local ____cond_1 = it == 3
            if ____cond_1 then
                local ____temp_2
                if it == -3 then
                    return "never"
                else
                    ____temp_2 = true
                end
                ____cond_1 = ____temp_2
            end
            ____result_37 = ____cond_1
        end
        if ____result_37 then
            if ____found_6 then
                ____result_36 = nil
                break
            end
            ____result_36 = it
            ____found_6 = true
        end
    end
    local c = ____result_36
    return a .. " " .. __K2L_Str(b) .. " " .. __K2L_Str(c)
end

local function singleErrors(xs)
    local r = __K2L_StringBuilder.new()
    local ____ok_2, ____result_38, ____returned_2 = pcall(function()
        local ____result_39
        local ____found_7 = false
        for _, it in ipairs(xs) do
            local ____result_40
            if it == -3 then
                return true, "never"
            end
            ____result_40 = it > 0
            if ____result_40 then
                if ____found_7 then
                    error(__K2L_IllegalArgumentException.new("Collection contains more than one matching element."))
                end
                ____result_39 = it
                ____found_7 = true
            end
        end
        if not ____found_7 then
            error(__K2L_NoSuchElementException.new("Collection contains no element matching the predicate."))
        end
    end)
    if ____ok_2 then
        if ____result_38 then
            return ____returned_2
        end
    else
        local ____error_2 = __K2L_ToThrowable(____result_38)
        if __K2L_InstanceOf(____error_2, __K2L_IllegalArgumentException) then
            local e = ____error_2
            r:append("many: " .. __K2L_Str(e.message) .. "; ")
        else
            error(____error_2, 0)
        end
    end
    local ____ok_3, ____result_41, ____returned_3 = pcall(function()
        local ____result_42
        local ____found_8 = false
        for _, it in ipairs(xs) do
            local ____result_43
            if it == -3 then
                return true, "never"
            end
            ____result_43 = it > 100
            if ____result_43 then
                if ____found_8 then
                    error(__K2L_IllegalArgumentException.new("Collection contains more than one matching element."))
                end
                ____result_42 = it
                ____found_8 = true
            end
        end
        if not ____found_8 then
            error(__K2L_NoSuchElementException.new("Collection contains no element matching the predicate."))
        end
    end)
    if ____ok_3 then
        if ____result_41 then
            return ____returned_3
        end
    else
        local ____error_3 = __K2L_ToThrowable(____result_41)
        if __K2L_InstanceOf(____error_3, __K2L_NoSuchElementException) then
            local e = ____error_3
            r:append("none: " .. __K2L_Str(e.message))
        else
            error(____error_3, 0)
        end
    end
    return r:toString()
end

local function trims(xs, stopAt)
    local ____result_44 = __K2L_ListOf()
    local ____dropping = true
    for ____i_9 = xs.size, 1, -1 do
        local it = xs[____i_9]
        local ____result_45
        if it == stopAt then
            return "tlw stop"
        end
        ____result_45 = it > 2
        if not ____result_45 then
            break
        end
        ____result_44:add(it)
    end
    local a = ____result_44:reversed()
    local ____result_46 = __K2L_ListOf()
    local ____dropping_1 = true
    for _, it in ipairs(xs) do
        if ____dropping_1 then
            local ____result_47
            if it == -3 then
                return "never"
            end
            ____result_47 = it < 3
            if not ____result_47 then
                ____dropping_1 = false
            end
        end
        if not ____dropping_1 then
            ____result_46:add(it)
        end
    end
    local b = ____result_46
    local ____result_48 = __K2L_ListOf()
    local ____dropping_2 = true
    for ____i_10 = xs.size, 1, -1 do
        local it = xs[____i_10]
        if ____dropping_2 then
            local ____result_49
            if it == -3 then
                return "never"
            end
            ____result_49 = it > 4
            if not ____result_49 then
                ____dropping_2 = false
            end
        end
        if not ____dropping_2 then
            ____result_48:add(it)
        end
    end
    local c = ____result_48:reversed()
    return __K2L_Str(a) .. " " .. __K2L_Str(b) .. " " .. __K2L_Str(c)
end

local function zips(xs, ys, stopAt)
    local ____result_50 = __K2L_ListOf()
    for ____i_11 = 1, xs.size do
        local x = xs[____i_11]
        local ____index_6 = ____i_11 - 1
        if ____index_6 >= ys.size then
            break
        end
        local ____result_51
        do
            local y = ys[____index_6 + 1]
            if x == stopAt then
                return "zip stop " .. y
            end
            ____result_51 = x .. y
        end
        ____result_50:add(____result_51)
    end
    local a = ____result_50
    local ____other = ys:toTypedArray("[Ljava.lang.String;")
    local ____result_52 = __K2L_ListOf()
    for ____i_12 = 1, xs.size do
        local x = xs[____i_12]
        local ____index_7 = ____i_12 - 1
        if ____index_7 >= ____other.size then
            break
        end
        local ____result_53
        do
            local y = ____other[____index_7 + 1]
            if x == -3 then
                return "never"
            end
            ____result_53 = y .. x
        end
        ____result_52:add(____result_53)
    end
    local b = ____result_52
    return __K2L_Str(a) .. " " .. __K2L_Str(b)
end

local function maps(m, stopAt)
    local ____result_54 = __K2L_MapOf()
    for _, it in ipairs(m:____entryArray()) do
        local ____result_55
        if it.value == stopAt then
            return "filter stop " .. it.key
        end
        ____result_55 = it.value > 1
        if ____result_55 then
            ____result_54:put(it.key, it.value)
        end
    end
    local a = ____result_54
    local ____result_56 = __K2L_MapOf()
    for _, ____it in ipairs(m:____entryArray()) do
        local ____result_57
        do
            local k, v = ____it.key, ____it.value
            if v == -3 then
                return "never"
            end
            ____result_57 = k == "a"
        end
        if not ____result_57 then
            ____result_56:put(____it.key, ____it.value)
        end
    end
    local b = ____result_56
    local ____result_58 = __K2L_MapOf()
    for _, it in ipairs(m:____entryArray()) do
        local ____result_59
        if it.key == "zzz" then
            return "never"
        end
        ____result_59 = it.value * 10
        ____result_58:put(it.key, ____result_59)
    end
    local c = ____result_58
    local ____result_60 = __K2L_MapOf()
    for _, ____it_1 in ipairs(m:____entryArray()) do
        local ____result_61
        do
            local k, v = ____it_1.key, ____it_1.value
            if v == -3 then
                return "never"
            end
            ____result_61 = k:upper() .. v
        end
        ____result_60:put(____result_61, ____it_1.value)
    end
    local d = ____result_60
    local ____result_62 = __K2L_MapOf()
    for _, ____entry in ipairs(m:____entryArray()) do
        local ____result_63
        do
            local it = ____entry.key
            if it == "zzz" then
                return "never"
            end
            ____result_63 = it ~= "b"
        end
        if ____result_63 then
            ____result_62:put(____entry.key, ____entry.value)
        end
    end
    local e = ____result_62
    local ____result_64 = __K2L_MapOf()
    for _, ____entry_1 in ipairs(m:____entryArray()) do
        local ____result_65
        do
            local it = ____entry_1.value
            if it == -3 then
                return "never"
            end
            ____result_65 = it < 3
        end
        if ____result_65 then
            ____result_64:put(____entry_1.key, ____entry_1.value)
        end
    end
    local f = ____result_64
    local seen = __K2L_ListOf()
    for _, it in ipairs(m:____entryArray()) do
        if it.value == -3 then
            return "never"
        end
        seen:add(it.key)
    end
    local g = m
    return __K2L_Str(a) .. " " .. __K2L_Str(b) .. " " .. __K2L_Str(c) .. " " .. __K2L_Str(d) .. " " .. __K2L_Str(e) .. " " .. __K2L_Str(f) .. " " .. __K2L_Str(seen) .. " " .. g.size
end

local function mapExtremes(m)
    local ____best_8
    local ____bestKey_8
    local ____has_8 = false
    for _, it in ipairs(m:____entryArray()) do
        local ____result_66
        if it.value == -3 then
            return "never"
        end
        ____result_66 = it.value
        local ____key_8 = ____result_66
        if not ____has_8 or __K2L_Compare(____key_8, ____bestKey_8) > 0 then
            ____best_8 = it
            ____bestKey_8 = ____key_8
            ____has_8 = true
        end
    end
    local a = ____best_8
    local ____best_9
    local ____bestKey_9
    local ____has_9 = false
    for _, it in ipairs(m:____entryArray()) do
        local ____result_67
        if it.value == -3 then
            return "never"
        end
        ____result_67 = it.value
        local ____key_9 = ____result_67
        if not ____has_9 or __K2L_Compare(____key_9, ____bestKey_9) < 0 then
            ____best_9 = it
            ____bestKey_9 = ____key_9
            ____has_9 = true
        end
    end
    if not ____has_9 then
        error(__K2L_NoSuchElementException.new(nil))
    end
    local b = ____best_9
    local ____best_10
    local ____bestKey_10
    local ____has_10 = false
    for _, it in ipairs(m:____entryArray()) do
        local ____result_68
        if it.value == -3 then
            return "never"
        end
        ____result_68 = it.value
        local ____key_10 = ____result_68
        if not ____has_10 or __K2L_Compare(____key_10, ____bestKey_10) > 0 then
            ____best_10 = it
            ____bestKey_10 = ____key_10
            ____has_10 = true
        end
    end
    if not ____has_10 then
        error(__K2L_NoSuchElementException.new(nil))
    end
    local c = ____bestKey_10
    return __K2L_Str(a) .. " " .. __K2L_Str(b) .. " " .. c
end

local function flatMaps(xs, stopAt)
    local ____result_69 = __K2L_ListOf()
    for _, x in ipairs(xs) do
        local ____result_70
        if x == stopAt then
            return __K2L_SingletonListOf(-1)
        end
        ____result_70 = __K2L_SequenceOf(x, x * 10)
        ____result_69:addAll(____result_70:toList())
    end
    return ____result_69
end

local function builders(stopAt)
    local ____builder = __K2L_ListBuilderOf()
    for i = 1, 5 do
        if i == stopAt then
            return "buildList stop"
        end
        ____builder:add(i)
    end
    local l = ____builder:____build()
    local ____builder_1 = __K2L_StringBuilder.new()
    for c in ("abc"):gmatch(".") do
        if c == "z" then
            return "buildString stop"
        end
        ____builder_1:append(c)
    end
    local s = ____builder_1:toString()
    local ____builder_2 = __K2L_MapBuilderOf()
    ____builder_2:put("k", 1)
    if stopAt == 99 then
        return "buildMap stop"
    end
    local m = ____builder_2:____build()
    local n = 0
    for it = 0, 2 do
        if stopAt == 98 then
            return "repeat stop"
        end
        n = n + it
    end
    return __K2L_Str(l) .. " " .. s .. " " .. __K2L_Str(m) .. " " .. n
end

local function arrays(stopAt)
    local arr = __K2L_TypedArrayOf("[Ljava.lang.Integer;", 5, 3, 8)
    local a = arr:sortedBy(function(it) return -it end, true)
    local ____result_71
    local ____found_9 = false
    for ____i_13 = arr.size, 1, -1 do
        local it = arr[____i_13]
        local ____result_72
        if it == -1 then
            return "never"
        end
        ____result_72 = it > 4
        if ____result_72 then
            ____result_71 = it
            ____found_9 = true
            break
        end
    end
    if not ____found_9 then
        error(__K2L_NoSuchElementException.new("Array contains no element matching the predicate."))
    end
    local b = ____result_71
    local ____acc_4
    local ____started_4 = false
    for _, x in ipairs(arr) do
        if not ____started_4 then
            ____acc_4 = x
            ____started_4 = true
        else
            local ____result_73
            do
                local acc = ____acc_4
                if x == -1 then
                    return "never"
                end
                ____result_73 = acc + x
            end
            ____acc_4 = ____result_73
        end
    end
    if not ____started_4 then
        error(__K2L_UnsupportedOperationException.new("Empty collection can't be reduced."))
    end
    local c = ____acc_4
    local ____yes_1 = __K2L_ListOf()
    local ____no_1 = __K2L_ListOf()
    for _, it in ipairs(arr) do
        local ____result_74
        if it == -1 then
            return "never"
        end
        ____result_74 = it > 4
        if ____result_74 then
            ____yes_1:add(it)
        else
            ____no_1:add(it)
        end
    end
    local d = __K2L_Pair.new(____yes_1, ____no_1)
    return __K2L_Str(a) .. " " .. b .. " " .. c .. " " .. __K2L_Str(d)
end

local function sets(stopAt)
    local s = __K2L_ReadOnlySetOf(4, 8, 15, 16)
    local ____result_75
    local ____found_10 = false
    for _, it in ipairs(s:toList()) do
        local ____result_76
        if it == stopAt then
            return "set stop"
        end
        ____result_76 = math.fmod(it, 2) == 0
        if ____result_76 then
            ____result_75 = it
            ____found_10 = true
        end
    end
    if not ____found_10 then
        error(__K2L_NoSuchElementException.new("Collection contains no element matching the predicate."))
    end
    local a = ____result_75
    local ____best_11
    local ____bestKey_11
    local ____has_11 = false
    for _, it in ipairs(s:toList()) do
        local ____result_77
        if it == -1 then
            return "never"
        end
        ____result_77 = math.fmod(it, 5)
        local ____key_11 = ____result_77
        if not ____has_11 or __K2L_Compare(____key_11, ____bestKey_11) > 0 then
            ____best_11 = it
            ____bestKey_11 = ____key_11
            ____has_11 = true
        end
    end
    local b = ____best_11
    return a .. " " .. __K2L_Str(b)
end

local function main()
    print(partitions(__K2L_ReadOnlyListOf(1, 9, 3, 7), 100))
    print(partitions(__K2L_ReadOnlyListOf(1, 9, 3, 7), 3))
    print(maxBys(100))
    print(maxBys(7))
    print(extremes(100))
    print(extremes(7))
    print(reduces(__K2L_ReadOnlyListOf(1, 2, 3), 100))
    print(reduces(__K2L_ReadOnlyListOf(1, 2, 3), 3))
    print(emptyReduce())
    print(__K2L_Str(distincts(__K2L_ReadOnlyListOf("a", "bb", "c", "dd", "eee"), "zz")))
    print(__K2L_Str(distincts(__K2L_ReadOnlyListOf("a", "bb", "c", "dd", "eee"), "dd")))
    print(indexedOps(__K2L_ReadOnlyListOf(4, 5, 6, 7), 100))
    print(indexedOps(__K2L_ReadOnlyListOf(4, 5, 6, 7), 6))
    print(indexSearch(__K2L_ReadOnlyListOf(1, 3, 2, 5, 1), 100))
    print(indexSearch(__K2L_ReadOnlyListOf(1, 3, 2, 5, 1), 3))
    print(lasts(__K2L_ReadOnlyListOf(1, 2, 3, 4), 100))
    print(lasts(__K2L_ReadOnlyListOf(1, 2, 3, 4), 3))
    print(lastNone(__K2L_ReadOnlyListOf(1, 2)))
    print(singles(__K2L_ReadOnlyListOf(1, 3, 5), 100))
    print(singles(__K2L_ReadOnlyListOf(1, 3, 5), 3))
    print(singleErrors(__K2L_ReadOnlyListOf(1, 2)))
    print(trims(__K2L_ReadOnlyListOf(1, 5, 6, 3, 4), 100))
    print(trims(__K2L_ReadOnlyListOf(1, 5, 6, 3, 4), 6))
    print(zips(__K2L_ReadOnlyListOf(1, 2, 3), __K2L_ReadOnlyListOf("a", "b"), 100))
    print(zips(__K2L_ReadOnlyListOf(1, 2, 3), __K2L_ReadOnlyListOf("a", "b"), 2))
    print(maps(__K2L_ReadOnlyMapOf(__K2L_Pair.new("a", 1), __K2L_Pair.new("b", 2), __K2L_Pair.new("c", 3)), 100))
    print(maps(__K2L_ReadOnlyMapOf(__K2L_Pair.new("a", 1), __K2L_Pair.new("b", 2), __K2L_Pair.new("c", 3)), 2))
    print(mapExtremes(__K2L_ReadOnlyMapOf(__K2L_Pair.new("a", 1), __K2L_Pair.new("b", 5), __K2L_Pair.new("c", 5))))
    print(__K2L_Str(flatMaps(__K2L_ReadOnlyListOf(1, 2), 100)))
    print(__K2L_Str(flatMaps(__K2L_ReadOnlyListOf(1, 2), 2)))
    print(builders(100))
    print(builders(3))
    print(builders(99))
    print(builders(98))
    print(arrays(100))
    print(arrays(8))
    print(sets(100))
    print(sets(15))
end

main()
return {Item = Item, items = items, partitions = partitions, maxBys = maxBys, extremes = extremes, reduces = reduces, emptyReduce = emptyReduce, distincts = distincts, indexedOps = indexedOps, indexSearch = indexSearch, lasts = lasts, lastNone = lastNone, singles = singles, singleErrors = singleErrors, trims = trims, zips = zips, maps = maps, mapExtremes = mapExtremes, flatMaps = flatMaps, builders = builders, arrays = arrays, sets = sets}
