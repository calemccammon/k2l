local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CloseAfter = ____lualib.__K2L_CloseAfter
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_Result = ____lualib.__K2L_Result
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringIsBlank = ____lualib.__K2L_StringIsBlank
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_UnsupportedOperationException = ____lualib.__K2L_UnsupportedOperationException

local Res = __K2L_Class("Res")

function Res:____init(name)
    self.name = name
end

function Res.new(name)
    return setmetatable({name = name}, Res)
end

function Res:close()
    print("closed " .. self.name)
end

local Fussy = __K2L_Class("Fussy")

function Fussy:close()
    print("closing fussy")
    error(__K2L_IllegalStateException.new("close failed"))
end

local function toVariants(xs, which)
    local mapped = __K2L_ListOf()
    for _, it in ipairs(xs) do
        local ____result
        if which == 0 and it == 3 then
            return "mapTo stopped, kept " .. __K2L_Str(mapped)
        else
            ____result = it * 2
        end
        mapped:add(____result)
    end
    local kept = __K2L_SetOf()
    for _, it in ipairs(xs) do
        local ____result_1
        if which == 1 and it == 3 then
            return "filterTo stopped, kept " .. __K2L_Str(kept)
        else
            ____result_1 = (it >= 0 and it % 2 or 0 - -it % 2) == 0
        end
        if ____result_1 then
            kept:add(it)
        end
    end
    local dropped = __K2L_ListOf()
    for _, it in ipairs(xs) do
        local ____result_2
        if which == 2 and it == 3 then
            return "filterNotTo stopped, kept " .. __K2L_Str(dropped)
        else
            ____result_2 = (it >= 0 and it % 2 or 0 - -it % 2) == 0
        end
        if not ____result_2 then
            dropped:add(it)
        end
    end
    local nn = __K2L_ListOf()
    for _, it in ipairs(xs) do
        local ____result_3
        if which == 3 and it == 3 then
            return "mapNotNullTo stopped, kept " .. __K2L_Str(nn)
        else
            ____result_3 = (it >= 0 and it % 2 or 0 - -it % 2) == 0 and "e" .. it or nil
        end
        local ____value = ____result_3
        if ____value ~= nil then
            nn:add(____result_3)
        end
    end
    local flat = __K2L_ListOf()
    for _, it in ipairs(xs) do
        local ____result_4
        if which == 4 and it == 3 then
            return "flatMapTo stopped, kept " .. __K2L_Str(flat)
        else
            ____result_4 = __K2L_ReadOnlyListOf(it, it)
        end
        flat:addAll(____result_4)
    end
    local assoc = __K2L_MapOf()
    for _, it in ipairs(xs) do
        local ____result_5
        if which == 5 and it == 3 then
            return "associateTo stopped, kept " .. __K2L_Str(assoc)
        else
            ____result_5 = __K2L_Pair.new(it, "v" .. it)
        end
        local ____value_1 = ____result_5
        assoc:put(____value_1.first, ____value_1.second)
    end
    local by = __K2L_MapOf()
    for _, it in ipairs(xs) do
        local ____result_6
        if which == 6 and it == 3 then
            return "associateByTo stopped, kept " .. __K2L_Str(by)
        else
            ____result_6 = it * 10
        end
        local ____value_2 = ____result_6
        by:put(____value_2, it)
    end
    local with = __K2L_MapOf()
    for _, it in ipairs(xs) do
        local ____result_7
        if which == 7 and it == 3 then
            return "associateWithTo stopped, kept " .. __K2L_Str(with)
        else
            ____result_7 = it * it
        end
        local ____value_3 = ____result_7
        with:put(it, ____value_3)
    end
    local groups = __K2L_MapOf()
    for _, it in ipairs(xs) do
        local ____result_8
        if which == 8 and it == 3 then
            return "groupByTo stopped, kept " .. __K2L_Str(groups)
        else
            ____result_8 = it >= 0 and it % 3 or 0 - -it % 3
        end
        local ____value_4 = ____result_8
        local ____group = groups:get(____value_4)
        if ____group == nil then
            ____group = __K2L_ListOf()
            groups:put(____value_4, ____group)
        end
        ____group:add(it)
    end
    local idx = __K2L_ListOf()
    for ____i = 1, xs.size do
        local x = xs[____i]
        local i = ____i - 1
        local ____result_9
        if which == 9 and x == 3 then
            return "filterIndexedTo stopped, kept " .. __K2L_Str(idx)
        else
            ____result_9 = (i >= 0 and i % 2 or 0 - -i % 2) == 0
        end
        if ____result_9 then
            idx:add(x)
        end
    end
    local idx2 = __K2L_ListOf()
    for ____i_1 = 1, xs.size do
        local x = xs[____i_1]
        local i = ____i_1 - 1
        local ____result_10
        if which == 10 and x == 3 then
            return "mapIndexedTo stopped, kept " .. __K2L_Str(idx2)
        else
            ____result_10 = i .. ":" .. x
        end
        idx2:add(____result_10)
    end
    return "finished " .. __K2L_Str(mapped) .. " " .. __K2L_Str(kept) .. " " .. __K2L_Str(dropped) .. " " .. __K2L_Str(nn) .. " " .. __K2L_Str(flat) .. " " .. __K2L_Str(assoc) .. " " .. __K2L_Str(by) .. " " .. __K2L_Str(with) .. " " .. __K2L_Str(groups) .. " " .. __K2L_Str(idx) .. " " .. __K2L_Str(idx2)
end

local function indexedAndRunning(xs, which)
    local ____result_11 = __K2L_ListOf()
    for ____i_2 = 1, xs.size do
        local x = xs[____i_2]
        local i = ____i_2 - 1
        local ____result_12
        if which == 0 and x == 3 then
            return "mapIndexedNotNull stopped at " .. i
        else
            ____result_12 = (i >= 0 and i % 2 or 0 - -i % 2) == 0 and x or nil
        end
        local ____value_5 = ____result_12
        if ____value_5 ~= nil then
            ____result_11:add(____value_5)
        end
    end
    local a = ____result_11
    local ____result_13 = __K2L_ListOf()
    for ____i_3 = 1, xs.size do
        local x = xs[____i_3]
        local i = ____i_3 - 1
        local ____result_14
        if which == 1 and x == 3 then
            return "flatMapIndexed stopped at " .. i
        else
            ____result_14 = __K2L_ReadOnlyListOf(i, x)
        end
        ____result_13:addAll(____result_14)
    end
    local b = ____result_13
    local ____acc
    local ____started = false
    for ____i_4 = 1, xs.size do
        local x = xs[____i_4]
        local i = ____i_4 - 1
        if not ____started then
            ____acc = x
            ____started = true
        else
            local ____result_15
            do
                local acc = ____acc
                if which == 2 and x == 3 then
                    return "reduceIndexed stopped at " .. i .. " acc " .. acc
                else
                    ____result_15 = acc + x * i
                end
            end
            ____acc = ____result_15
        end
    end
    if not ____started then
        error(__K2L_UnsupportedOperationException.new("Empty collection can't be reduced."))
    end
    local c = ____acc
    local ____acc_1 = 100
    for ____i_5 = 1, xs.size do
        local x = xs[____i_5]
        local i = ____i_5 - 1
        local ____result_16
        do
            local acc = ____acc_1
            if which == 3 and x == 3 then
                return "foldIndexed stopped at " .. i .. " acc " .. acc
            else
                ____result_16 = acc + x * i
            end
        end
        ____acc_1 = ____result_16
    end
    local d = ____acc_1
    local ____acc_2 = 0
    local ____result_17 = __K2L_ListOf()
    ____result_17:add(____acc_2)
    for _, x in ipairs(xs) do
        local ____result_18
        do
            local acc = ____acc_2
            if which == 4 and x == 3 then
                return "runningFold stopped acc " .. acc
            else
                ____result_18 = acc + x
            end
        end
        ____acc_2 = ____result_18
        ____result_17:add(____acc_2)
    end
    local e = ____result_17
    local ____acc_3
    local ____result_19 = __K2L_ListOf()
    local ____started_1 = false
    for _, x in ipairs(xs) do
        if not ____started_1 then
            ____acc_3 = x
            ____started_1 = true
            ____result_19:add(____acc_3)
        else
            local ____result_20
            do
                local acc = ____acc_3
                if which == 5 and x == 3 then
                    return "runningReduce stopped acc " .. acc
                else
                    ____result_20 = acc + x
                end
            end
            ____acc_3 = ____result_20
            ____result_19:add(____acc_3)
        end
    end
    local f = ____result_19
    local ____acc_4 = "s"
    local ____result_21 = __K2L_ListOf()
    ____result_21:add(____acc_4)
    for _, x in ipairs(xs) do
        local ____result_22
        do
            local acc = ____acc_4
            if which == 6 and x == 3 then
                return "scan stopped acc " .. acc
            else
                ____result_22 = acc .. x
            end
        end
        ____acc_4 = ____result_22
        ____result_21:add(____acc_4)
    end
    local g = ____result_21
    local ____sum = 0
    for _, it in ipairs(xs) do
        local ____result_23
        if which == 7 and it == 3 then
            return "sumOf stopped"
        else
            ____result_23 = it
        end
        ____sum = ____sum + ____result_23
    end
    local h = ____sum
    return "finished " .. __K2L_Str(a) .. " " .. __K2L_Str(b) .. " " .. c .. " " .. d .. " " .. __K2L_Str(e) .. " " .. __K2L_Str(f) .. " " .. __K2L_Str(g) .. " " .. h
end

local ____lambda_1 = function()
    return __K2L_SingletonMapOf(__K2L_Pair.new("fallback", 1))
end
local function lookups(m, xs, key, i)
    local ____value_6
    ____value_6 = m:get(key)
    if ____value_6 == nil then
        local ____result_24
        if key == "boom" then
            return "getOrPut returned"
        else
            ____result_24 = #key
        end
        ____value_6 = ____result_24
        m:put(key, ____value_6)
    end
    local a = ____value_6
    local ____value_7
    local ____key = key .. "?"
    ____value_7 = m:get(____key)
    if ____value_7 == nil then
        local ____result_25
        if key == "bang" then
            return "getOrElse returned"
        else
            ____result_25 = -1
        end
        ____value_7 = ____result_25
    end
    local b = ____value_7
    local ____value_8
    if i >= 0 and i < xs.size then
        ____value_8 = xs[i + 1]
    else
        local ____result_26
        if i > 100 then
            return "list getOrElse returned " .. i
        else
            ____result_26 = i * -1
        end
        ____value_8 = ____result_26
    end
    local c = ____value_8
    local ____value_9
    if xs:isEmpty() then
        local ____result_27
        do return "empty list" end
        ____value_9 = ____result_27
    else
        ____value_9 = xs
    end
    local d = ____value_9
    local e = __K2L_ReadOnlyMapOf():ifEmpty(____lambda_1)
    return "a=" .. a .. " b=" .. b .. " c=" .. c .. " d=" .. __K2L_Str(d) .. " e=" .. __K2L_Str(e) .. " m=" .. __K2L_Str(m)
end

local function texts(s, which)
    local ____chars = __K2L_StringToList(s)
    local ____result_28 = __K2L_ListOf()
    for _, it in ipairs(____chars) do
        local ____result_29
        if which == 0 and it == "c" then
            return "map stopped"
        else
            ____result_29 = it:upper()
        end
        ____result_28:add(____result_29)
    end
    local upper = ____result_28
    local ____chars_1 = __K2L_StringToList(s)
    local ____result_30 = __K2L_ListOf()
    for _, it in ipairs(____chars_1) do
        local ____result_31
        if which == 1 and it == "c" then
            return "filter stopped"
        else
            ____result_31 = it ~= "a"
        end
        if ____result_31 then
            ____result_30:add(it)
        end
    end
    local letters = ____result_30:joinToString("")
    local ____chars_2 = __K2L_StringToList(s)
    local ____result_32 = 0
    for _, it in ipairs(____chars_2) do
        local ____result_33
        if which == 2 and it == "c" then
            return "count stopped"
        else
            ____result_33 = it == "a"
        end
        if ____result_33 then
            ____result_32 = ____result_32 + 1
        end
    end
    local n = ____result_32
    local ____chars_3 = __K2L_StringToList(s)
    local ____result_34 = false
    for _, it in ipairs(____chars_3) do
        local ____result_35
        if which == 3 and it == "c" then
            return "any stopped"
        else
            ____result_35 = it == "z"
        end
        if ____result_35 then
            ____result_34 = true
            break
        end
    end
    local any = ____result_34
    local ____chars_4 = __K2L_StringToList(s)
    local ____result_36 = true
    for _, it in ipairs(____chars_4) do
        local ____result_37
        if which == 4 and it == "c" then
            return "all stopped"
        else
            ____result_37 = it ~= "z"
        end
        if not ____result_37 then
            ____result_36 = false
            break
        end
    end
    local all = ____result_36
    local ____chars_5 = __K2L_StringToList(s)
    local ____index = -1
    for ____i_6 = 1, ____chars_5.size do
        local it = ____chars_5[____i_6]
        local ____index_1 = ____i_6 - 1
        local ____result_38
        if which == 5 and it == "c" then
            return "indexOfFirst stopped"
        else
            ____result_38 = it == "c"
        end
        if ____result_38 then
            ____index = ____index_1
            break
        end
    end
    local first = ____index
    local ____chars_6 = __K2L_StringToList(s)
    local ____result_39 = __K2L_ListOf()
    for _, it in ipairs(____chars_6) do
        local ____result_40
        if which == 6 and it == "c" then
            return "takeWhile stopped"
        else
            ____result_40 = it ~= "c"
        end
        if not ____result_40 then
            break
        end
        ____result_39:add(it)
    end
    local taken = ____result_39:joinToString("")
    local ____chars_7 = __K2L_StringToList(s)
    local ____result_41 = __K2L_ListOf()
    local ____dropping = true
    for _, it in ipairs(____chars_7) do
        if ____dropping then
            local ____result_42
            if which == 7 and it == "c" then
                return "dropWhile stopped"
            else
                ____result_42 = it ~= "c"
            end
            if not ____result_42 then
                ____dropping = false
            end
        end
        if not ____dropping then
            ____result_41:add(it)
        end
    end
    local dropped = ____result_41:joinToString("")
    local ____chars_8 = __K2L_StringToList(s)
    local ____sum_1 = 0
    for _, it in ipairs(____chars_8) do
        local ____result_43
        if which == 8 and it == "c" then
            return "sumOf stopped"
        else
            ____result_43 = it:byte()
        end
        ____sum_1 = ____sum_1 + ____result_43
    end
    local sum = ____sum_1
    local ____chars_9 = __K2L_StringToList(s)
    for i = 0, ____chars_9.size - 1 do
        local c = ____chars_9[i + 1]
        if which == 9 and c == "c" then
            return "forEachIndexed stopped at " .. i
        end
    end
    local ____value_10
    if __K2L_StringIsBlank("  ") then
        local ____result_44
        do return "blank" end
        ____value_10 = ____result_44
    else
        ____value_10 = "  "
    end
    local blank = ____value_10
    return __K2L_Str(upper) .. " " .. letters .. " " .. n .. " " .. tostring(any) .. " " .. tostring(all) .. " " .. first .. " " .. taken .. " " .. dropped .. " " .. sum .. " " .. blank
end

local function resources(fail, early)
    local ____resource = Res.new("a")
    local ____result_45
    local ____ok, ____result_46, ____returned = __K2L_DeepPcall(function()
        local ____result_47
        if early then
            return true, "early from " .. ____resource.name
        end
        if fail then
            error(__K2L_IllegalArgumentException.new("body failed"))
        end
        ____result_47 = #____resource.name
        ____result_45 = ____result_47
    end)
    if ____ok then
        ____resource:close()
    else
        __K2L_CloseAfter(____resource, ____result_46)
    end
    if not ____ok then
        error(____result_46, 0)
    end
    if ____result_46 then
        return ____returned
    end
    local value = ____result_45
    return "value " .. value
end

local function nested(early)
    local ____resource_1 = Res.new("outer")
    local ____result_48
    local ____ok_1, ____result_49, ____returned_1 = __K2L_DeepPcall(function()
        do
            local ____resource_2 = Res.new("inner")
            local ____result_50
            local ____ok_2, ____result_51, ____returned_2 = __K2L_DeepPcall(function()
                if early then
                    return true, "early from " .. ____resource_2.name .. " in " .. ____resource_1.name
                end
            end)
            if ____ok_2 then
                ____resource_2:close()
            else
                __K2L_CloseAfter(____resource_2, ____result_51)
            end
            if not ____ok_2 then
                error(____result_51, 0)
            end
            if ____result_51 then
                return true, ____returned_2
            end
        end
    end)
    if ____ok_1 then
        ____resource_1:close()
    else
        __K2L_CloseAfter(____resource_1, ____result_49)
    end
    if not ____ok_1 then
        error(____result_49, 0)
    end
    if ____result_49 then
        return ____returned_1
    end
    return "ran to the end"
end

local function fussy()
    local ____ok_3, ____result_52 = __K2L_DeepPcall(function()
        local ____resource_3 = Fussy.new()
        local ____result_53
        local ____ok_4, ____result_54 = __K2L_DeepPcall(function()
            local ____result_55
            error(__K2L_IllegalArgumentException.new("body failed"))
            ____result_53 = ____result_55
        end)
        if ____ok_4 then
            ____resource_3:close()
        else
            __K2L_CloseAfter(____resource_3, ____result_54)
        end
        if not ____ok_4 then
            error(____result_54, 0)
        end
    end)
    if not ____ok_3 then
        local ____error = __K2L_ToThrowable(____result_52)
        if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
            local e = ____error
            return "caught " .. __K2L_Str(e.message)
        else
            error(____error, 0)
        end
    end
    return "not reached"
end

local function locked(lock, early)
    local ____result_56
    if early then
        return "left the lock"
    else
        ____result_56 = 42
    end
    local v = ____result_56
    return "got " .. v
end

local function caught(early)
    local ____outcome
    local ____ok_5, ____result_57, ____returned_5 = __K2L_DeepPcall(function()
        local ____result_58
        if early == 0 then
            return true, "returned from runCatching"
        elseif early == 1 then
            error(__K2L_IllegalStateException.new("failed inside"))
        else
            ____result_58 = early * 10
        end
        ____outcome = __K2L_Result.success(____result_58)
    end)
    if ____ok_5 then
        if ____result_57 then
            return ____returned_5
        end
    else
        ____outcome = __K2L_Result.failure(__K2L_ToThrowable(____result_57))
    end
    local r = ____outcome
    local ____arg = tostring(r:isSuccess())
    local ____arg_1 = __K2L_Str(r:getOrNull())
    local ____receiver = r:exceptionOrNull()
    return "result " .. ____arg .. " " .. ____arg_1 .. " " .. __K2L_Str(____receiver and ____receiver.message)
end

local function timed(early)
    local ____start = os.clock()
    if early then
        return "timed block left"
    end
    local ms = math.floor((os.clock() - ____start) * 1000)
    return "took " .. tostring(ms >= 0)
end

local function main()
    local xs = __K2L_ReadOnlyListOf(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15)
    print(toVariants(xs, 99))
    for which = 0, 10 do
        print(toVariants(xs, which))
    end
    print(toVariants(__K2L_ReadOnlyListOf(), 0))
    print(indexedAndRunning(xs, 99))
    for which = 0, 7 do
        print(indexedAndRunning(xs, which))
    end
    local m = __K2L_MapOf(__K2L_Pair.new("x", 1))
    print(lookups(m, __K2L_ReadOnlyListOf(5, 6), "abc", 1))
    print(lookups(m, __K2L_ReadOnlyListOf(5, 6), "abc", 7))
    print(lookups(m, __K2L_ReadOnlyListOf(500, 600), "abc", -1))
    print(lookups(m, __K2L_ReadOnlyListOf(500, 600), "abc", 5))
    print(lookups(m, __K2L_ReadOnlyListOf(), "abc", 0))
    print(lookups(m, __K2L_SingletonListOf(1), "boom", 0))
    print(lookups(m, __K2L_SingletonListOf(1), "bang", 0))
    print(__K2L_Str(m))
    print(texts("bcad", 99))
    for which = 0, 9 do
        print(texts("bcad", which))
    end
    print(resources(false, false))
    print(resources(false, true))
    local ____ok_6, ____result_59 = __K2L_DeepPcall(function()
        resources(true, false)
    end)
    if not ____ok_6 then
        local ____error_1 = __K2L_ToThrowable(____result_59)
        if __K2L_InstanceOf(____error_1, __K2L_IllegalArgumentException) then
            local e = ____error_1
            print("caught " .. __K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
    print(nested(true))
    print(nested(false))
    print(fussy())
    print(locked("lock", true))
    print(locked("lock", false))
    print(caught(0))
    print(caught(1))
    print(caught(3))
    print(timed(true))
    print(timed(false))
end

__K2L_DeepMain(main)
return {Res = Res, Fussy = Fussy, toVariants = toVariants, indexedAndRunning = indexedAndRunning, lookups = lookups, texts = texts, resources = resources, nested = nested, fussy = fussy, locked = locked, caught = caught, timed = timed}
