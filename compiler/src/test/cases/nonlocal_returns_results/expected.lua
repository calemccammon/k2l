local ____lualib = require("lualib_bundle")
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Result = ____lualib.__K2L_Result
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf
local __K2L_UnsupportedOperationException = ____lualib.__K2L_UnsupportedOperationException

local function results(r, which)
    local ____value
    if r.exception ~= nil then
        local ____result
        do
            local it = r.exception
            if which == 0 then
                return "getOrElse returned " .. __K2L_Str(it.message)
            else
                ____result = -1
            end
        end
        ____value = ____result
    else
        ____value = r.value
    end
    local a = ____value
    if r.exception ~= nil then
        do
            local it = r.exception
            if which == 1 then
                return "onFailure returned " .. __K2L_Str(it.message)
            end
        end
    end
    if r.exception == nil then
        do
            local it = r.value
            if which == 2 then
                return "onSuccess returned " .. it
            end
        end
    end
    local ____value_1
    if r.exception == nil then
        local ____result_1
        do
            local it = r.value
            if which == 3 then
                return "fold success returned"
            else
                ____result_1 = it * 2
            end
        end
        ____value_1 = ____result_1
    else
        local ____result_2
        do
            local it = r.exception
            if which == 4 then
                return "fold failure returned"
            else
                ____result_2 = -2
            end
        end
        ____value_1 = ____result_2
    end
    local b = ____value_1
    local ____result_3 = r
    if r.exception == nil then
        local ____result_4
        do
            local it = r.value
            if which == 5 then
                return "map returned"
            else
                ____result_4 = it + 1
            end
        end
        ____result_3 = __K2L_Result.success(____result_4)
    end
    local c = ____result_3
    local ____result_5 = r
    if r.exception ~= nil then
        local ____result_6
        do
            local it = r.exception
            if which == 6 then
                return "recover returned " .. __K2L_Str(it.message)
            else
                ____result_6 = 0
            end
        end
        ____result_5 = __K2L_Result.success(____result_6)
    end
    local d = ____result_5
    return a .. " " .. b .. " " .. __K2L_Str(c:getOrNull()) .. " " .. __K2L_Str(d:getOrNull()) .. " " .. tostring(c:isFailure())
end

local function notNull(xs, which)
    local ____result_7
    for _, it in ipairs(xs) do
        local ____result_8
        if which == 0 and it == 3 then
            return "firstNotNullOf returned"
        else
            ____result_8 = it > 4 and it * 10 or nil
        end
        local ____value_2 = ____result_8
        if ____value_2 ~= nil then
            ____result_7 = ____value_2
            break
        end
    end
    if ____result_7 == nil then
        error(__K2L_NoSuchElementException.new("No element of the collection was transformed to a non-null value."))
    end
    local a = ____result_7
    local ____result_9
    for _, it in ipairs(xs) do
        local ____result_10
        if which == 1 and it == 3 then
            return "firstNotNullOfOrNull returned"
        else
            ____result_10 = it > 100 and it or nil
        end
        local ____value_3 = ____result_10
        if ____value_3 ~= nil then
            ____result_9 = ____value_3
            break
        end
    end
    local b = ____result_9
    return a .. " " .. __K2L_Str(b)
end

local function folds(xs, arr, which)
    local seen = __K2L_ListOf()
    for ____i = 1, xs.size do
        local x = xs[____i]
        local i = ____i - 1
        if which == 0 and x == 3 then
            return "onEachIndexed returned at " .. i
        end
        seen:add(i * x)
    end
    local ____acc = ""
    for ____i_1 = xs.size, 1, -1 do
        local x = xs[____i_1]
        local ____result_11
        do
            local acc = ____acc
            if which == 1 and x == 3 then
                return "foldRight returned acc=" .. acc
            else
                ____result_11 = acc .. x
            end
        end
        ____acc = ____result_11
    end
    local a = ____acc
    local ____acc_1
    local ____started = false
    for ____i_2 = xs.size, 1, -1 do
        local x = xs[____i_2]
        if not ____started then
            ____acc_1 = x
            ____started = true
        else
            local ____result_12
            do
                local acc = ____acc_1
                if which == 2 and x == 3 then
                    return "reduceRight returned acc=" .. acc
                else
                    ____result_12 = x - acc
                end
            end
            ____acc_1 = ____result_12
        end
    end
    if not ____started then
        error(__K2L_UnsupportedOperationException.new("Empty list can't be reduced."))
    end
    local b = ____acc_1
    local ____acc_2 = 0
    for ____i_3 = arr.size, 1, -1 do
        local x = arr[____i_3]
        local ____result_13
        do
            local acc = ____acc_2
            if which == 3 and x == 3 then
                return "array foldRight returned acc=" .. acc
            else
                ____result_13 = acc * 10 + x
            end
        end
        ____acc_2 = ____result_13
    end
    local c = ____acc_2
    local ____acc_3
    local ____started_1 = false
    for ____i_4 = arr.size, 1, -1 do
        local x = arr[____i_4]
        if not ____started_1 then
            ____acc_3 = x
            ____started_1 = true
        else
            local ____result_14
            do
                local acc = ____acc_3
                if which == 4 and x == 2 then
                    return "array reduceRight returned acc=" .. acc
                else
                    ____result_14 = x + acc
                end
            end
            ____acc_3 = ____result_14
        end
    end
    if not ____started_1 then
        error(__K2L_UnsupportedOperationException.new("Empty array can't be reduced."))
    end
    local d = ____acc_3
    return __K2L_Str(seen) .. " " .. a .. " " .. b .. " " .. c .. " " .. d
end

local function emptyFolds(which)
    local ____ok, ____result_15, ____returned = pcall(function()
        if which == 0 then
            local ____list = __K2L_ReadOnlyListOf()
            local ____acc_4
            local ____started_2 = false
            for ____i_5 = ____list.size, 1, -1 do
                local x = ____list[____i_5]
                if not ____started_2 then
                    ____acc_4 = x
                    ____started_2 = true
                else
                    local ____result_16
                    do
                        local acc = ____acc_4
                        if x > 100 then
                            return true, "never"
                        else
                            ____result_16 = x + acc
                        end
                    end
                    ____acc_4 = ____result_16
                end
            end
            if not ____started_2 then
                error(__K2L_UnsupportedOperationException.new("Empty list can't be reduced."))
            end
        end
        if which == 1 then
            local ____list_1 = __K2L_TypedArrayOf("[I")
            local ____acc_5
            local ____started_3 = false
            for ____i_6 = ____list_1.size, 1, -1 do
                local x = ____list_1[____i_6]
                if not ____started_3 then
                    ____acc_5 = x
                    ____started_3 = true
                else
                    local ____result_17
                    do
                        local acc = ____acc_5
                        if x > 100 then
                            return true, "never"
                        else
                            ____result_17 = x + acc
                        end
                    end
                    ____acc_5 = ____result_17
                end
            end
            if not ____started_3 then
                error(__K2L_UnsupportedOperationException.new("Empty array can't be reduced."))
            end
        end
        if which == 2 then
            local ____list_2 = __K2L_ReadOnlyListOf()
            local ____acc_6
            local ____started_4 = false
            for ____i_7 = 1, ____list_2.size do
                local x = ____list_2[____i_7]
                local i = ____i_7 - 1
                if not ____started_4 then
                    ____acc_6 = x
                    ____started_4 = true
                else
                    local ____result_18
                    do
                        local acc = ____acc_6
                        if x > 100 then
                            return true, "never"
                        else
                            ____result_18 = x + acc + i
                        end
                    end
                    ____acc_6 = ____result_18
                end
            end
            if not ____started_4 then
                error(__K2L_UnsupportedOperationException.new("Empty collection can't be reduced."))
            end
        end
        if which == 3 then
            local ____list_3 = __K2L_TypedArrayOf("[I")
            local ____acc_7
            local ____started_5 = false
            for ____i_8 = 1, ____list_3.size do
                local x = ____list_3[____i_8]
                local i = ____i_8 - 1
                if not ____started_5 then
                    ____acc_7 = x
                    ____started_5 = true
                else
                    local ____result_19
                    do
                        local acc = ____acc_7
                        if x > 100 then
                            return true, "never"
                        else
                            ____result_19 = x + acc + i
                        end
                    end
                    ____acc_7 = ____result_19
                end
            end
            if not ____started_5 then
                error(__K2L_UnsupportedOperationException.new("Empty array can't be reduced."))
            end
        end
        if which == 4 then
            local ____list_4 = __K2L_ReadOnlyListOf()
            local ____result_20
            for _, it in ipairs(____list_4) do
                local ____result_21
                if it > 100 then
                    return true, "never"
                else
                    ____result_21 = nil
                end
                local ____value_4 = ____result_21
                if ____value_4 ~= nil then
                    ____result_20 = ____value_4
                    break
                end
            end
            if ____result_20 == nil then
                error(__K2L_NoSuchElementException.new("No element of the collection was transformed to a non-null value."))
            end
        end
        if which == 5 then
            local ____list_5 = __K2L_ReadOnlyListOf()
            local ____acc_8
            local ____started_6 = false
            for ____i_9 = ____list_5.size, 1, -1 do
                local x = ____list_5[____i_9]
                if not ____started_6 then
                    ____acc_8 = x
                    ____started_6 = true
                else
                    local ____result_22
                    do
                        local acc = ____acc_8
                        if x > 100 then
                            return true, "never"
                        else
                            ____result_22 = x + acc
                        end
                    end
                    ____acc_8 = ____result_22
                end
            end
            if not ____started_6 then
                error(__K2L_UnsupportedOperationException.new("Empty list can't be reduced."))
            end
        end
    end)
    if ____ok then
        if ____result_15 then
            return ____returned
        end
    else
        local ____error = __K2L_ToThrowable(____result_15)
        if __K2L_InstanceOf(____error, __K2L_Exception) then
            local e = ____error
            return __K2L_Str(__K2L_KClassOfValue(e).simpleName) .. ": " .. __K2L_Str(e.message)
        else
            error(____error, 0)
        end
    end
    return "no error"
end

local function maps(m, which)
    local values = __K2L_MapOf()
    for _, it in ipairs(m:____entryArray()) do
        local ____result_23
        if which == 0 and it.value == 2 then
            return "mapValuesTo returned, kept " .. __K2L_Str(values)
        else
            ____result_23 = it.value * 10
        end
        values:put(it.key, ____result_23)
    end
    local keys = __K2L_MapOf()
    for _, it in ipairs(m:____entryArray()) do
        local ____result_24
        if which == 1 and it.value == 2 then
            return "mapKeysTo returned, kept " .. __K2L_Str(keys)
        else
            ____result_24 = it.key .. it.key
        end
        keys:put(____result_24, it.value)
    end
    local kept = __K2L_MapOf()
    for _, it in ipairs(m:____entryArray()) do
        local ____result_25
        if which == 2 and it.value == 2 then
            return "filterTo returned, kept " .. __K2L_Str(kept)
        else
            ____result_25 = math.fmod(it.value, 2) == 1
        end
        if ____result_25 then
            kept:put(it.key, it.value)
        end
    end
    local list = __K2L_ListOf()
    for _, it in ipairs(m:____entryArray()) do
        local ____result_26
        if which == 3 and it.value == 2 then
            return "mapTo returned, kept " .. __K2L_Str(list)
        else
            ____result_26 = it.key
        end
        list:add(____result_26)
    end
    return __K2L_Str(values) .. " " .. __K2L_Str(keys) .. " " .. __K2L_Str(kept) .. " " .. __K2L_Str(list)
end

local function main()
    local ok = __K2L_Result.success(5)
    local bad = __K2L_Result.failure(__K2L_IllegalStateException.new("broken"))
    print(results(ok, 99))
    print(results(bad, 99))
    for which = 0, 6 do
        print(results(ok, which))
        print(results(bad, which))
    end
    local xs = __K2L_ReadOnlyListOf(1, 2, 3, 4, 5, 6)
    print(notNull(xs, 99))
    print(notNull(xs, 0))
    print(notNull(xs, 1))
    for which = 0, 4 do
        print(folds(xs, __K2L_TypedArrayOf("[I", 1, 2, 3), which))
    end
    print(folds(xs, __K2L_TypedArrayOf("[I", 1, 2, 3), 99))
    for which = 0, 4 do
        print(emptyFolds(which))
    end
    print(emptyFolds(9))
    local m = __K2L_MapOf(__K2L_Pair.new("a", 1), __K2L_Pair.new("b", 2), __K2L_Pair.new("c", 3))
    print(maps(m, 99))
    for which = 0, 3 do
        print(maps(m, which))
    end
end

main()
return {results = results, notNull = notNull, folds = folds, emptyFolds = emptyFolds, maps = maps}
