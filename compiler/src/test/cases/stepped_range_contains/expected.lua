local ____lualib = require("lualib_bundle")
local __K2L_CheckStep = ____lualib.__K2L_CheckStep
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Unsigned = ____lualib.__K2L_Unsigned

local ____exports = {}

local function ints(range, test)
    return range:filter(test):joinToString(",")
end

____exports.evaluations = 0

local function traced(n)
    ____exports.evaluations = ____exports.evaluations + 1
    return n
end

local function t(s, n)
    io.write(s .. " ")
    return n
end

local function classify(x)
    if x >= 0 and x <= 10 and (x - 0) % 5 == 0 then
        return "five"
    elseif x >= 11 and x <= 20 and (20 - x) % 3 == 0 then
        return "down3"
    else
        local ____first = -10
        if not (x >= ____first and x < 30 and (x - ____first) % 2 == 0) then
            return "odd"
        else
            return "even"
        end
    end
end

local function charKind(c)
    local ____first_2 = ("a"):byte()
    local ____value_1 = c:byte()
    if ____value_1 >= ____first_2 and ____value_1 <= ("z"):byte() and (____value_1 - ____first_2) % 2 == 0 then
        return "even letter"
    else
        local ____first_1 = ("b"):byte()
        local ____value = c:byte()
        if ____value >= ____first_1 and ____value <= ("z"):byte() and (____value - ____first_1) % 2 == 0 then
            return "odd letter"
        else
            return "other"
        end
    end
end

local function main()
    print(ints(__K2L_IntRange.new(-2, 12), function(it)
        return it >= 0 and it <= 10 and (it - 0) % 2 == 0
    end))
    print(ints(__K2L_IntRange.new(-2, 12), function(it)
        return it >= 1 and it <= 10 and (it - 1) % 3 == 0
    end))
    print(ints(__K2L_IntRange.new(-2, 12), function(it)
        return not (it >= 1 and it <= 10 and (it - 1) % 3 == 0)
    end))
    print(ints(__K2L_IntRange.new(-2, 12), function(it)
        return it >= 0 and it <= 10 and (10 - it) % 3 == 0
    end))
    print(ints(__K2L_IntRange.new(-2, 12), function(it)
        return it >= 0 and it < 10 and (it - 0) % 4 == 0
    end))
    print(ints(__K2L_IntRange.new(-2, 12), function(it)
        return it >= 0 and it < 9 and (it - 0) % 3 == 0
    end))
    print(ints(__K2L_IntRange.new(-2, 12), function(it)
        return it >= 5 and it <= 4 and (it - 5) % 1 == 0
    end))
    print(ints(__K2L_IntRange.new(-2, 12), function(it)
        return it >= 7 and it <= 7 and (it - 7) % 5 == 0
    end))
    print(ints(__K2L_IntRange.new(-2, 12), function(it)
        local ____first_3 = -1
        return it >= -1 and it <= ____first_3 and (____first_3 - it) % 2 == 0
    end))
    print(tostring(9 >= 1 and 9 <= 10 and (9 - 1) % 2 == 0) .. " " .. tostring(10 >= 1 and 10 <= 10 and (10 - 1) % 2 == 0) .. " " .. __K2L_IntRange.new(1, 10):withStep(2).last)
    print(tostring(4 >= 1 and 4 <= 10 and (10 - 4) % 3 == 0) .. " " .. tostring(1 >= 1 and 1 <= 10 and (10 - 1) % 3 == 0) .. " " .. tostring(0 >= 1 and 0 <= 10 and (10 - 0) % 3 == 0))
    local ____list = __K2L_ReadOnlyListOf(0, 5, 10, 14, 17, 21, -3, 25, 26)
    for ____i = 1, ____list.size do
        local x = ____list[____i]
        io.write(classify(x) .. " ")
    end
    print()
    local lo = traced(3)
    local step = traced(4)
    print(ints(__K2L_IntRange.new(0, 20), function(it)
        local ____bound = traced(15)
        local ____step = __K2L_CheckStep(step)
        return it >= lo and it <= ____bound and (it - lo) % ____step == 0
    end))
    print(____exports.evaluations)
    local ____bound_1 = t("a", 0)
    local ____bound_2 = t("b", 9)
    local ____bound_3 = t("s", 3)
    local ____step_1 = __K2L_CheckStep(____bound_3)
    local ____value_2 = t("x", 3)
    print(____value_2 >= ____bound_1 and ____value_2 <= ____bound_2 and (____value_2 - ____bound_1) % ____step_1 == 0)
    local ____bound_4 = t("a", 0)
    local ____bound_5 = t("b", 9)
    local ____bound_6 = t("s", 3)
    local ____step_2 = __K2L_CheckStep(____bound_6)
    local ____value_3 = t("x", -1)
    print(____value_3 >= ____bound_4 and ____value_3 <= ____bound_5 and (____value_3 - ____bound_4) % ____step_2 == 0)
    local ____bound_7 = t("a", 0)
    local ____bound_8 = t("b", 9)
    local ____value_4 = t("x", -1)
    print(____value_4 >= ____bound_7 and ____value_4 <= ____bound_8)
    local ____bound_9 = t("a", 9)
    local ____bound_10 = t("b", 0)
    local ____value_5 = t("x", 12)
    print(____value_5 >= ____bound_10 and ____value_5 <= ____bound_9)
    local ____bound_11 = t("a", 9)
    local ____bound_12 = t("b", 0)
    local ____bound_13 = t("s", 2)
    local ____step_3 = __K2L_CheckStep(____bound_13)
    local ____value_6 = t("x", 12)
    print(____value_6 >= ____bound_12 and ____value_6 <= ____bound_11 and (____bound_11 - ____value_6) % ____step_3 == 0)
    local ____first_4 = ("a"):byte()
    local ____value_7 = ("e"):byte()
    local ____arg = ____value_7 >= ____first_4 and ____value_7 <= ("z"):byte() and (____value_7 - ____first_4) % 4 == 0
    local ____first_5 = ("a"):byte()
    local ____value_8 = ("f"):byte()
    local ____arg_1 = ____value_8 >= ____first_5 and ____value_8 <= ("z"):byte() and (____value_8 - ____first_5) % 4 == 0
    local ____first_6 = ("z"):byte()
    local ____value_9 = ("y"):byte()
    local ____arg_2 = ____value_9 >= ("a"):byte() and ____value_9 <= ____first_6 and (____first_6 - ____value_9) % 3 == 0
    local ____first_7 = ("z"):byte()
    local ____value_10 = ("w"):byte()
    print(tostring(____arg) .. " " .. tostring(____arg_1) .. " " .. tostring(____arg_2) .. " " .. tostring(____value_10 >= ("a"):byte() and ____value_10 <= ____first_7 and (____first_7 - ____value_10) % 3 == 0))
    print(charKind("c") .. " " .. charKind("d") .. " " .. charKind("#"))
    local big = 3000000000
    local ____value_11 = big + 1
    print(tostring(big >= 0 and big <= 4000000000 and (big - 0) % 1000000000 == 0) .. " " .. tostring(____value_11 >= 0 and ____value_11 <= 4000000000 and (____value_11 - 0) % 1000000000 == 0))
    local ____value_12 = -6
    local ____value_13 = -7
    print(tostring(____value_12 >= -10 and ____value_12 <= 10 and (10 - ____value_12) % 4 == 0) .. " " .. tostring(not (____value_13 >= -10 and ____value_13 <= 10 and (10 - ____value_13) % 4 == 0)) .. " " .. tostring(10 >= 0 and 10 < 10 and (10 - 0) % 5 == 0))
    print(tostring(7 >= 1 and 7 <= 10 and (7 - 1) % 3 == 0) .. " " .. tostring(not (8 >= 1 and 8 <= 10 and (8 - 1) % 3 == 0)) .. " " .. tostring(not math.ult(5, 1) and not math.ult(9, 5) and __K2L_Unsigned.urem(9 - 5, 2) == 0) .. " " .. tostring(not math.ult(4, 1) and not math.ult(9, 4) and __K2L_Unsigned.urem(9 - 4, 2) == 0))
    local longs = __K2L_IntRange.new(-5, 15):filter(function(it)
        return it >= 2 and it <= 13 and (it - 2) % 5 == 0
    end)
    print(__K2L_Str(longs))
    local ____list_1 = __K2L_ReadOnlyListOf(2, 0, -3)
    for ____i_1 = 1, ____list_1.size do
        local s = ____list_1[____i_1]
        local ____ok, ____result = pcall(function()
            local ____step_4 = __K2L_CheckStep(s)
            print(5 >= 1 and 5 <= 10 and (5 - 1) % ____step_4 == 0)
        end)
        if not ____ok then
            local ____error = __K2L_ToThrowable(____result)
            if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
                local e = ____error
                print(__K2L_Str(e.message))
            else
                error(____error, 0)
            end
        end
    end
    local ____ok_1, ____result_1 = pcall(function()
        for i = 0, 4, __K2L_CheckStep(lo - 3) do
            io.write(tostring(i))
        end
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error_1, __K2L_IllegalArgumentException) then
            local e = ____error_1
            print(__K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
    for ____code = ("a"):byte(), ("k"):byte(), 3 do
        local c = string.char(____code)
        io.write(c)
    end
    for ____code_1 = ("k"):byte(), ("a"):byte(), -4 do
        local c = string.char(____code_1)
        io.write(c)
    end
    print()
end

____exports.ints = ints
____exports.traced = traced
____exports.t = t
____exports.classify = classify
____exports.charKind = charKind
main()
return ____exports
