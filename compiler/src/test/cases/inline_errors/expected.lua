local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Spread = ____lualib.__K2L_Spread
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function tryFirst(xs, f)
    local ____ok, ____result, ____returned = pcall(function()
        for ____i = 1, xs.size do
            local x = xs[____i]
            if f(x) then
                return true, x
            end
        end
    end)
    if ____ok then
        if ____result then
            return ____returned
        end
    else
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_Exception) then
            local e = ____error
            print("caught")
        else
            error(____error, 0)
        end
    end
    return -1
end

local function inTry()
    local ____result_1
    do
        local xs = __K2L_ListOf(1, 2)
        local ____ok_1, ____result_2, ____returned_1 = pcall(function()
            for ____i_1 = 1, xs.size do
                local x = xs[____i_1]
                local ____result_3
                if x > 5 then
                    return true, 5
                else
                    ____result_3 = x > 1
                end
                if ____result_3 then
                    ____result_1 = x
                    return 1
                end
            end
        end)
        if ____ok_1 then
            if ____result_2 == true then
                return ____returned_1
            end
            if ____result_2 == 1 then
                goto ____inline_end
            end
        else
            local ____error_1 = __K2L_ToThrowable(____result_2)
            if __K2L_InstanceOf(____error_1, __K2L_Exception) then
                local e = ____error_1
                print("caught")
            else
                error(____error_1, 0)
            end
        end
        ____result_1 = -1
        ::____inline_end::
    end
    return 0
end

local function total(f, ...)
    local xs = __K2L_ArrayOf(...)
    local sum = 0
    for ____i_2 = 1, xs.size do
        local x = xs[____i_2]
        sum = sum + f(x)
    end
    return sum
end

local function spreadFirst(xs)
    local ____result_4
    do
        local ____xs = __K2L_ArrayOf(__K2L_Spread("s.", xs, 1))
        local sum = 0
        for ____i_3 = 1, ____xs.size do
            local x = ____xs[____i_3]
            local ____result_5
            if x < 0 then
                return -1
            else
                ____result_5 = x
            end
            sum = sum + ____result_5
        end
        ____result_4 = sum
    end
    return ____result_4
end

local function main()
    print(inTry() + spreadFirst(__K2L_ArrayOf(1)))
end

__K2L_RunMain(main)
return {tryFirst = tryFirst, inTry = inTry, total = total, spreadFirst = spreadFirst}
