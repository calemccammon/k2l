local ____lualib = require("lualib_bundle")
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_NumberFormatException = ____lualib.__K2L_NumberFormatException
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function breakInTry()
    for i = 1, 5 do
        local ____ok, ____result = __K2L_DeepPcall(function()
            if i == 3 then
                return 1
            end
            print("body " .. i)
        end)
        if ____ok then
            if ____result == 1 then
                break
            end
        else
            local ____error = __K2L_ToThrowable(____result)
            if __K2L_InstanceOf(____error, __K2L_Exception) then
                local e = ____error
                print("never")
            else
                error(____error, 0)
            end
        end
    end
    print("after break")
end

local function continueInTry()
    for i = 1, 5 do
        do
            local ____ok_1, ____result_1 = __K2L_DeepPcall(function()
                if (i >= 0 and i % 2 or 0 - -i % 2) == 0 then
                    return 1
                end
                print("odd " .. i)
            end)
            print("finally " .. i)
            if not ____ok_1 then
                error(____result_1, 0)
            end
            if ____result_1 == 1 then
                goto ____continue
            end
        end
        ::____continue::
    end
end

local function breakWithFinally()
    local i = 0
    while true do
        i = i + 1
        local ____ok_2, ____result_2 = __K2L_DeepPcall(function()
            if i > 2 then
                return 1
            end
            print("tick " .. i)
        end)
        print("cleanup " .. i)
        if not ____ok_2 then
            error(____result_2, 0)
        end
        if ____result_2 == 1 then
            break
        end
    end
    print("done " .. i)
end

local function throwingThenContinue()
    local ____list = __K2L_ReadOnlyListOf("1", "x", "3", "stop", "5")
    for ____i = 1, ____list.size do
        local s = ____list[____i]
        do
            local ____ok_3, ____result_3 = __K2L_DeepPcall(function()
                local n = __K2L_StringToInt(s)
                print("number " .. n)
            end)
            if not ____ok_3 then
                local ____error_3 = __K2L_ToThrowable(____result_3)
                if __K2L_InstanceOf(____error_3, __K2L_NumberFormatException) then
                    local e = ____error_3
                    if s == "stop" then
                        break
                    end
                    print("skipping " .. s)
                    goto ____continue_1
                else
                    error(____error_3, 0)
                end
            end
            print("end of iteration " .. s)
        end
        ::____continue_1::
    end
end

local function catchBreaks()
    for i = 0, 4 do
        local ____ok_4, ____result_4 = __K2L_DeepPcall(function()
            if i == 2 then
                error(__K2L_IllegalStateException.new("boom " .. i))
            end
            print("fine " .. i)
        end)
        if not ____ok_4 then
            ____ok_4, ____result_4 = __K2L_DeepPcall(function()
                local ____error_4 = __K2L_ToThrowable(____result_4)
                if __K2L_InstanceOf(____error_4, __K2L_IllegalStateException) then
                    local e = ____error_4
                    print("caught " .. __K2L_Str(e.message))
                    return 1
                else
                    error(____error_4, 0)
                end
            end)
        end
        print("finally " .. i)
        if not ____ok_4 then
            error(____result_4, 0)
        end
        if ____result_4 == 1 then
            break
        end
    end
end

local function labeled()
    for i = 1, 3 do
        do
            for j = 1, 3 do
                local ____ok_5, ____result_5 = __K2L_DeepPcall(function()
                    if j == 2 then
                        return 1
                    end
                    if i == 3 then
                        return 2
                    end
                    print(i .. "," .. j)
                end)
                print("f " .. i .. "," .. j)
                if not ____ok_5 then
                    error(____result_5, 0)
                end
                if ____result_5 == 1 then
                    goto ____continue_2
                end
                if ____result_5 == 2 then
                    goto ____break
                end
            end
        end
        ::____continue_2::
    end
    ::____break::
    print("labeled done")
end

local function nestedTry()
    for i = 1, 4 do
        do
            local ____ok_6, ____result_6 = __K2L_DeepPcall(function()
                local ____ok_7, ____result_7 = __K2L_DeepPcall(function()
                    if i == 2 then
                        return 1
                    end
                    if i == 4 then
                        return 2
                    end
                    print("inner " .. i)
                end)
                print("inner finally " .. i)
                if not ____ok_7 then
                    error(____result_7, 0)
                end
                if ____result_7 == 1 then
                    return 1
                end
                if ____result_7 == 2 then
                    return 2
                end
                print("between " .. i)
            end)
            print("outer finally " .. i)
            if not ____ok_6 then
                error(____result_6, 0)
            end
            if ____result_6 == 1 then
                goto ____continue_3
            end
            if ____result_6 == 2 then
                break
            end
        end
        ::____continue_3::
    end
end

local function tryInLoopInTry()
    local total = 0
    local ____ok_8, ____result_8, ____returned_8 = __K2L_DeepPcall(function()
        for i = 1, 5 do
            do
                local ____ok_9, ____result_9, ____returned_9 = __K2L_DeepPcall(function()
                    if i == 2 then
                        return 1
                    end
                    if i == 4 then
                        return true, total
                    end
                    total = total + i
                end)
                total = total + 100
                if not ____ok_9 then
                    error(____result_9, 0)
                end
                if ____result_9 == true then
                    return true, ____returned_9
                end
                if ____result_9 == 1 then
                    goto ____continue_4
                end
            end
            ::____continue_4::
        end
    end)
    print("outer total " .. total)
    if not ____ok_8 then
        error(____result_8, 0)
    end
    if ____result_8 then
        return ____returned_8
    end
    return -1
end

local function jumpsAndReturn(limit)
    for i = 1, 10 do
        do
            local ____ok_10, ____result_10, ____returned_10 = __K2L_DeepPcall(function()
                if i == 2 then
                    return 1
                end
                if i == limit then
                    return true, "returned at " .. i
                end
                if i > 6 then
                    return 2
                end
            end)
            io.write("[" .. i .. "]")
            if not ____ok_10 then
                error(____result_10, 0)
            end
            if ____result_10 == true then
                return ____returned_10
            end
            if ____result_10 == 1 then
                goto ____continue_5
            end
            if ____result_10 == 2 then
                break
            end
        end
        ::____continue_5::
    end
    return "fell out"
end

local function finallyJumps()
    for i = 1, 4 do
        do
            local ____ok_11, ____result_11 = __K2L_DeepPcall(function()
                if i == 2 then
                    error(__K2L_RuntimeException.new("swallowed"))
                end
                print("body " .. i)
            end)
            if i == 2 then
                goto ____continue_6
            end
            if i == 3 then
                break
            end
            print("finally " .. i)
            if not ____ok_11 then
                error(____result_11, 0)
            end
        end
        ::____continue_6::
    end
    print("finallyJumps done")
end

local function tryAsValue()
    local out = __K2L_ListOf()
    for i = 1, 5 do
        do
            local v
            local ____ok_12, ____result_12 = __K2L_DeepPcall(function()
                if i == 2 then
                    return 1
                end
                if i == 5 then
                    return 2
                end
                v = i * 10
            end)
            if ____ok_12 then
                if ____result_12 == 1 then
                    goto ____continue_7
                end
                if ____result_12 == 2 then
                    break
                end
            else
                local ____error_12 = __K2L_ToThrowable(____result_12)
                if __K2L_InstanceOf(____error_12, __K2L_Exception) then
                    local e = ____error_12
                    v = -1
                else
                    error(____error_12, 0)
                end
            end
            out:add(v)
        end
        ::____continue_7::
    end
    return out
end

local function doWhile()
    local i = 0
    repeat
        do
            i = i + 1
            local ____ok_13, ____result_13 = __K2L_DeepPcall(function()
                if i == 2 then
                    return 1
                end
                if i == 4 then
                    return 2
                end
                print("do " .. i)
            end)
            print("do finally " .. i)
            if not ____ok_13 then
                error(____result_13, 0)
            end
            if ____result_13 == 1 then
                goto ____continue_8
            end
            if ____result_13 == 2 then
                break
            end
        end
        ::____continue_8::
    until not (i < 10)
end

local function firstEven(xs)
    local ____mod = xs.____modCount
    for ____i_1 = 1, xs.size do
        local x = xs[____i_1]
        local ____ok_14, ____result_14, ____returned_14 = __K2L_DeepPcall(function()
            if (x >= 0 and x % 2 or 0 - -x % 2) == 0 then
                return true, x
            end
        end)
        print("checked " .. x)
        if not ____ok_14 then
            error(____result_14, 0)
        end
        if ____result_14 then
            return ____returned_14
        end
        if xs.____modCount ~= ____mod and xs:____comodified(____i_1) then
            break
        end
    end
    return -1
end

local function tryFirst(xs, f)
    local ____ok_15, ____result_15, ____returned_15 = __K2L_DeepPcall(function()
        local ____mod_1 = xs.____modCount
        for ____i_2 = 1, xs.size do
            local x = xs[____i_2]
            if f(x) then
                return true, x
            end
            if xs.____modCount ~= ____mod_1 and xs:____comodified(____i_2) then
                break
            end
        end
    end)
    if not ____ok_15 then
        ____ok_15, ____result_15, ____returned_15 = __K2L_DeepPcall(function()
            local ____error_15 = __K2L_ToThrowable(____result_15)
            if __K2L_InstanceOf(____error_15, __K2L_Exception) then
                local e = ____error_15
                print("caught")
            else
                error(____error_15, 0)
            end
        end)
    end
    print("tryFirst finally")
    if not ____ok_15 then
        error(____result_15, 0)
    end
    if ____result_15 then
        return ____returned_15
    end
    return -1
end

local function inTry(xs)
    local ____result_16
    do
        local ____ok_16, ____result_17, ____returned_16 = __K2L_DeepPcall(function()
            local ____mod_2 = xs.____modCount
            for ____i_3 = 1, xs.size do
                local x = xs[____i_3]
                local ____result_18
                if x > 5 then
                    return true, 5
                else
                    ____result_18 = x > 1
                end
                if ____result_18 then
                    ____result_16 = x
                    return 1
                end
                if xs.____modCount ~= ____mod_2 and xs:____comodified(____i_3) then
                    break
                end
            end
        end)
        if not ____ok_16 then
            ____ok_16, ____result_17, ____returned_16 = __K2L_DeepPcall(function()
                local ____error_16 = __K2L_ToThrowable(____result_17)
                if __K2L_InstanceOf(____error_16, __K2L_Exception) then
                    local e = ____error_16
                    print("caught")
                else
                    error(____error_16, 0)
                end
            end)
        end
        print("tryFirst finally")
        if not ____ok_16 then
            error(____result_17, 0)
        end
        if ____result_17 == true then
            return ____returned_16
        end
        if ____result_17 == 1 then
            goto ____inline_end
        end
        ____result_16 = -1
        ::____inline_end::
    end
    local found = ____result_16
    return found * 100
end

local function main()
    print(inTry(__K2L_ReadOnlyListOf(1, 2, 3)))
    print(inTry(__K2L_ReadOnlyListOf(1, 9)))
    print(inTry(__K2L_SingletonListOf(1)))
    breakInTry()
    continueInTry()
    breakWithFinally()
    throwingThenContinue()
    catchBreaks()
    labeled()
    nestedTry()
    print(tryInLoopInTry())
    print(jumpsAndReturn(5))
    print(jumpsAndReturn(100))
    finallyJumps()
    print(__K2L_Str(tryAsValue()))
    doWhile()
    print(firstEven(__K2L_ReadOnlyListOf(1, 3, 4, 6)))
end

__K2L_DeepMain(main)
return {breakInTry = breakInTry, continueInTry = continueInTry, breakWithFinally = breakWithFinally, throwingThenContinue = throwingThenContinue, catchBreaks = catchBreaks, labeled = labeled, nestedTry = nestedTry, tryInLoopInTry = tryInLoopInTry, jumpsAndReturn = jumpsAndReturn, finallyJumps = finallyJumps, tryAsValue = tryAsValue, doWhile = doWhile, firstEven = firstEven, tryFirst = tryFirst, inTry = inTry}
