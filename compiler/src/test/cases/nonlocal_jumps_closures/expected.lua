local ____lualib = require("lualib_bundle")
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CloseAfter = ____lualib.__K2L_CloseAfter
local __K2L_GenerateSequence = ____lualib.__K2L_GenerateSequence
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IsJump = ____lualib.__K2L_IsJump
local __K2L_Jump = ____lualib.__K2L_Jump
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_NewJump = ____lualib.__K2L_NewJump
local __K2L_Result = ____lualib.__K2L_Result
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SequenceBuilder = ____lualib.__K2L_SequenceBuilder
local __K2L_SequenceOf = ____lualib.__K2L_SequenceOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function trimOut(s)
    local ____jump = __K2L_NewJump()
    local ____value
    local ____ok, ____result = pcall(function()
        ____value = __K2L_Text.trimWith(s, 3, function(c)
            if c == "!" then
                __K2L_Jump(____jump, 1, "bang")
            else
                return c == " "
            end
        end)
    end)
    if not ____ok then
        if ____result == ____jump then
            return ____jump.value
        end
        error(____result, 0)
    end
    local t = ____value
    return "[" .. t .. "]"
end

local function maxOrStop(xs)
    local ____jump_1 = __K2L_NewJump()
    local ____value_1
    local ____ok_1, ____result_1 = pcall(function()
        ____value_1 = __K2L_AsSequence(xs):maxOf(function(it)
            if it < 0 then
                __K2L_Jump(____jump_1, 1, -1)
            else
                return it * 2
            end
        end)
    end)
    if not ____ok_1 then
        if ____result_1 == ____jump_1 then
            return ____jump_1.value
        end
        error(____result_1, 0)
    end
    local m = ____value_1
    return m
end

local ____lambda_1 = function(it) return it + 1 end
local function firstSquareOver(limit)
    for _, it in __K2L_GenerateSequence(1, ____lambda_1):iter() do
        if it * it > limit then
            return it
        end
    end
    return -1
end

local function sequenceTerminals()
    local out = __K2L_ListOf()
    local function any()
        local ____jump_2 = __K2L_NewJump()
        local ____value_2
        local ____ok_2, ____result_2 = pcall(function()
            ____value_2 = __K2L_SequenceOf(1, 2, 3):any(function(it)
                if it == 2 then
                    __K2L_Jump(____jump_2, 1, 20)
                end
                return false
            end)
        end)
        if not ____ok_2 then
            if ____result_2 == ____jump_2 then
                return ____jump_2.value
            end
            error(____result_2, 0)
        end
        return 0
    end
    local function first()
        local ____jump_3 = __K2L_NewJump()
        local ____value_3
        local ____ok_3, ____result_3 = pcall(function()
            ____value_3 = __K2L_SequenceOf(1, 2, 3):first(function(it)
                if it == 2 then
                    __K2L_Jump(____jump_3, 1, 30)
                end
                return it > 2
            end)
        end)
        if not ____ok_3 then
            if ____result_3 == ____jump_3 then
                return ____jump_3.value
            end
            error(____result_3, 0)
        end
        local v = ____value_3
        return v
    end
    local function fold()
        local ____jump_4 = __K2L_NewJump()
        local ____value_4
        local ____ok_4, ____result_4 = pcall(function()
            ____value_4 = __K2L_SequenceOf(1, 2, 3):fold(0, function(acc, x)
                if x == 3 then
                    __K2L_Jump(____jump_4, 1, -acc)
                end
                return acc + x
            end)
        end)
        if not ____ok_4 then
            if ____result_4 == ____jump_4 then
                return ____jump_4.value
            end
            error(____result_4, 0)
        end
        return ____value_4
    end
    local function count()
        local ____jump_5 = __K2L_NewJump()
        local ____value_5
        local ____ok_5, ____result_5 = pcall(function()
            ____value_5 = __K2L_SequenceOf(1, 2, 3, 4):count(function(it)
                if it > 3 then
                    __K2L_Jump(____jump_5, 1, -1)
                end
                return it % 2 == 0
            end)
        end)
        if not ____ok_5 then
            if ____result_5 == ____jump_5 then
                return ____jump_5.value
            end
            error(____result_5, 0)
        end
        local n = ____value_5
        return n
    end
    local function sum()
        local ____jump_6 = __K2L_NewJump()
        local ____value_6
        local ____ok_6, ____result_6 = pcall(function()
            ____value_6 = __K2L_SequenceOf(1, 2, 3):sumOf(function(it)
                if it == 2 then
                    __K2L_Jump(____jump_6, 1, 99)
                end
                return it
            end)
        end)
        if not ____ok_6 then
            if ____result_6 == ____jump_6 then
                return ____jump_6.value
            end
            error(____result_6, 0)
        end
        return ____value_6
    end
    local function none()
        local ____jump_7 = __K2L_NewJump()
        local ____value_7
        local ____ok_7, ____result_7 = pcall(function()
            ____value_7 = __K2L_SequenceOf("a", "b"):none(function(it)
                if it == "b" then
                    __K2L_Jump(____jump_7, 1, true)
                end
                return false
            end)
        end)
        if not ____ok_7 then
            if ____result_7 == ____jump_7 then
                return ____jump_7.value
            end
            error(____result_7, 0)
        end
        return false
    end
    out:add("any=" .. any() .. " first=" .. first() .. " fold=" .. fold() .. " count=" .. count() .. " sum=" .. sum() .. " none=" .. tostring(none()))
    return out
end

local function mapCatchingOut(r)
    local ____jump_8 = __K2L_NewJump()
    local ____value_8
    local ____ok_8, ____result_8 = pcall(function()
        ____value_8 = r:mapCatching(function(it)
            if it == 1 then
                __K2L_Jump(____jump_8, 1, "returned")
            else
                return it * 10
            end
        end)
    end)
    if not ____ok_8 then
        if ____result_8 == ____jump_8 then
            return ____jump_8.value
        end
        error(____result_8, 0)
    end
    local m = ____value_8
    local ____jump_9 = __K2L_NewJump()
    local ____value_9
    local ____ok_9, ____result_9 = pcall(function()
        ____value_9 = m:recoverCatching(function(it)
            if __K2L_InstanceOf(it, __K2L_IllegalStateException) then
                __K2L_Jump(____jump_9, 1, "recovered-returned")
            else
                return -1
            end
        end)
    end)
    if not ____ok_9 then
        if ____result_9 == ____jump_9 then
            return ____jump_9.value
        end
        error(____result_9, 0)
    end
    local rec = ____value_9
    return __K2L_Str(rec)
end

local function breaksAndContinues()
    local seen = __K2L_ListOf()
    for i = 0, 3 do
        do
            for _, s in __K2L_SequenceOf("a", "b", "c"):iter() do
                do
                    if s == "b" and i == 1 then
                        goto ____continue
                    end
                    if s == "c" and i == 2 then
                        goto ____break
                    end
                    local ____jump_10 = __K2L_NewJump()
                    local ____value_10
                    local ____ok_10, ____result_10 = pcall(function()
                        ____value_10 = __K2L_Text.trimWith("xyz", 3, function(c)
                            if c == "y" and i == 3 then
                                __K2L_Jump(____jump_10, 1)
                            end
                            return c == "x"
                        end)
                    end)
                    if not ____ok_10 then
                        if ____result_10 == ____jump_10 then
                            goto ____break
                        end
                        error(____result_10, 0)
                    end
                    seen:add(i .. s)
                end
            end
        end
        ::____continue::
    end
    ::____break::
    return seen:joinToString(" ")
end

local function jumpsFromOneLambda(n)
    local log = ""
    for i = 0, n do
        do
            local ____jump_11 = __K2L_NewJump()
            local ____value_11
            local ____ok_11, ____result_11 = pcall(function()
                ____value_11 = __K2L_Text.trimWith("  x ", 3, function(c)
                    if i == 1 then
                        __K2L_Jump(____jump_11, 3)
                    elseif i == 3 then
                        __K2L_Jump(____jump_11, 2)
                    elseif i == n then
                        __K2L_Jump(____jump_11, 1, "returned at " .. i .. ", log=" .. log)
                    else
                        return c == " "
                    end
                end)
            end)
            if not ____ok_11 then
                if ____result_11 == ____jump_11 then
                    if ____jump_11.code == 1 then
                        return ____jump_11.value
                    elseif ____jump_11.code == 2 then
                        break
                    elseif ____jump_11.code == 3 then
                        goto ____continue_1
                    end
                end
                error(____result_11, 0)
            end
            log = log .. i
        end
        ::____continue_1::
    end
    return "loop done, log=" .. log
end

local function labeledToLambda()
    local results = __K2L_ListOf()
    local f = function(x)
        local ____jump_12 = __K2L_NewJump()
        local ____value_12
        local ____ok_12, ____result_12 = pcall(function()
            ____value_12 = __K2L_Text.trimWith("bc", 3, function(c)
                if c == "b" and x > 1 then
                    __K2L_Jump(____jump_12, 1, x * 100)
                end
                return false
            end)
        end)
        if not ____ok_12 then
            if ____result_12 == ____jump_12 then
                return ____jump_12.value
            end
            error(____result_12, 0)
        end
        return x
    end
    results:add(f(1))
    results:add(f(2))
    for r = 0, 2 do
        do
            local ____jump_13 = __K2L_NewJump()
            local ____value_13
            local ____ok_13, ____result_13 = pcall(function()
                ____value_13 = __K2L_Text.trimWith(" q ", 3, function(it)
                    if r == 1 then
                        __K2L_Jump(____jump_13, 1)
                    end
                    return it == " "
                end)
            end)
            if not ____ok_13 then
                if ____result_13 == ____jump_13 then
                    goto ____inline_end
                end
                error(____result_13, 0)
            end
            results:add(r)
            ::____inline_end::
        end
    end
    local ____result_14
    do
        local ____jump_14 = __K2L_NewJump()
        local ____value_14
        local ____ok_14, ____result_15 = pcall(function()
            ____value_14 = __K2L_SequenceOf(5, 6):maxOf(function(it)
                if it == 6 then
                    __K2L_Jump(____jump_14, 1, -6)
                end
                return it
            end)
        end)
        if not ____ok_14 then
            if ____result_15 == ____jump_14 then
                ____result_14 = ____jump_14.value
                goto ____inline_end_1
            end
            error(____result_15, 0)
        end
        ____result_14 = 0
        ::____inline_end_1::
    end
    local viaRun = ____result_14
    results:add(viaRun)
    return results
end

local function nested()
    local ____jump_16 = __K2L_NewJump()
    local ____value_16
    local ____ok_16, ____result_17 = pcall(function()
        ____value_16 = __K2L_Text.trimWith("ab", 3, function(a)
            local ____jump_15 = __K2L_NewJump()
            local ____value_15
            local ____ok_15, ____result_16 = pcall(function()
                ____value_15 = __K2L_Text.trimWith("cd", 3, function(b)
                    if a == "b" and b == "d" then
                        __K2L_Jump(____jump_15, 1, 42)
                    end
                    return false
                end)
            end)
            if not ____ok_15 then
                if ____result_16 == ____jump_15 then
                    __K2L_Jump(____jump_16, 1, ____jump_15.value)
                end
                error(____result_16, 0)
            end
            return false
        end)
    end)
    if not ____ok_16 then
        if ____result_17 == ____jump_16 then
            return ____jump_16.value
        end
        error(____result_17, 0)
    end
    return 0
end

local function nestedThroughTry()
    local log = __K2L_ListOf()
    local ____jump_18 = __K2L_NewJump()
    local ____value_18
    local ____ok_19, ____result_20 = pcall(function()
        ____value_18 = __K2L_Text.trimWith("ab", 3, function(a)
            local ____ok_17, ____result_18 = pcall(function()
                local ____jump_17 = __K2L_NewJump()
                local ____value_17
                local ____ok_18, ____result_19 = pcall(function()
                    ____value_17 = __K2L_Text.trimWith("cd", 3, function(b)
                        if a == "a" and b == "c" then
                            __K2L_Jump(____jump_17, 1, "returned through two lambdas and a try, log=" .. __K2L_Str(log))
                        end
                        return false
                    end)
                end)
                if not ____ok_18 then
                    if ____result_19 == ____jump_17 then
                        __K2L_Jump(____jump_18, 1, ____jump_17.value)
                    end
                    error(____result_19, 0)
                end
            end)
            if not ____ok_17 then
                ____ok_17, ____result_18 = pcall(function()
                    local ____error = __K2L_ToThrowable(____result_18)
                    local e = ____error
                    log:add("caught " .. __K2L_Str(e))
                end)
            end
            print("finally of the outer lambda")
            if not ____ok_17 then
                error(____result_18, 0)
            end
            return false
        end)
    end)
    if not ____ok_19 then
        if ____result_20 == ____jump_18 then
            return ____jump_18.value
        end
        error(____result_20, 0)
    end
    return "not reached"
end

local function nestedFunction()
    local function inner(s)
        local ____jump_19 = __K2L_NewJump()
        local ____value_19
        local ____ok_20, ____result_21 = pcall(function()
            ____value_19 = __K2L_Text.trimWith(s, 3, function(it)
                if it == "!" then
                    __K2L_Jump(____jump_19, 1, 1)
                end
                return false
            end)
        end)
        if not ____ok_20 then
            if ____result_21 == ____jump_19 then
                return ____jump_19.value
            end
            error(____result_21, 0)
        end
        return 2
    end
    return inner("a!") * 10 + inner("a")
end

local function tailValue(xs)
    local ____jump_20 = __K2L_NewJump()
    local ____value_20
    local ____ok_21, ____result_22 = pcall(function()
        ____value_20 = __K2L_AsSequence(xs):sumOf(function(it)
            if it > 10 then
                __K2L_Jump(____jump_20, 1, it)
            else
                return it
            end
        end)
    end)
    if not ____ok_21 then
        if ____result_22 == ____jump_20 then
            return ____jump_20.value
        end
        error(____result_22, 0)
    end
    local v = ____value_20
    return v
end

local function unitFunction(log)
    local ____jump_21 = __K2L_NewJump()
    local ____value_21
    local ____ok_22, ____result_23 = pcall(function()
        ____value_21 = __K2L_Text.trimWith("bac", 3, function(it)
            if it == "b" then
                log:add("leaving")
                __K2L_Jump(____jump_21, 1)
            end
            return false
        end)
    end)
    if not ____ok_22 then
        if ____result_23 == ____jump_21 then
            return
        end
        error(____result_23, 0)
    end
    log:add("not reached")
end

local function throughTryCatch()
    local log = __K2L_ListOf()
    local ____jump_22 = __K2L_NewJump()
    local ____value_22
    local ____ok_24, ____result_25 = pcall(function()
        ____value_22 = __K2L_Text.trimWith("abc", 3, function(c)
            local ____ok_23, ____result_24 = pcall(function()
                if c == "c" then
                    __K2L_Jump(____jump_22, 1, "returned through try, log=" .. __K2L_Str(log))
                end
                log:add("try " .. c)
            end)
            if not ____ok_23 then
                ____ok_23, ____result_24 = pcall(function()
                    local ____error_1 = __K2L_ToThrowable(____result_24)
                    local e = ____error_1
                    log:add("caught " .. __K2L_Str(e))
                end)
            end
            log:add("finally " .. c)
            if not ____ok_23 then
                error(____result_24, 0)
            end
            return false
        end)
    end)
    if not ____ok_24 then
        if ____result_25 == ____jump_22 then
            return ____jump_22.value
        end
        error(____result_25, 0)
    end
    return "not reached"
end

local function tryAroundCall()
    local log = __K2L_ListOf()
    local ____ok_25, ____result_26, ____returned_25 = pcall(function()
        local ____jump_23 = __K2L_NewJump()
        local ____value_23
        local ____ok_26, ____result_27 = pcall(function()
            ____value_23 = __K2L_Text.trimWith("abc", 3, function(it)
                if it == "c" then
                    __K2L_Jump(____jump_23, 1, "returned, log=" .. __K2L_Str(log))
                end
                log:add("lambda " .. it)
                return false
            end)
        end)
        if not ____ok_26 then
            if ____result_27 == ____jump_23 then
                return true, ____jump_23.value
            end
            error(____result_27, 0)
        end
    end)
    if not ____ok_25 then
        ____ok_25, ____result_26, ____returned_25 = pcall(function()
            local ____error_2 = __K2L_ToThrowable(____result_26)
            local e = ____error_2
            log:add("caught")
        end)
    end
    print("finally runs, log=" .. __K2L_Str(log))
    if not ____ok_25 then
        error(____result_26, 0)
    end
    if ____result_26 then
        return ____returned_25
    end
    return "not reached"
end

local Resource = __K2L_Class("Resource")

function Resource.new(name, log)
    return setmetatable({name = name, log = log}, Resource)
end

function Resource:close()
    self.log:add("close " .. self.name)
end

local function throughUse(log)
    local ____jump_24 = __K2L_NewJump()
    local ____value_24
    local ____ok_28, ____result_30 = pcall(function()
        ____value_24 = __K2L_Text.trimWith("abc", 3, function(c)
            local ____resource = Resource.new("r" .. c, log)
            local ____result_28
            local ____ok_27, ____result_29 = pcall(function()
                if c == "c" then
                    __K2L_Jump(____jump_24, 1, 7)
                end
            end)
            if ____ok_27 or __K2L_IsJump(____result_29) then
                ____resource:close()
            else
                __K2L_CloseAfter(____resource, ____result_29)
            end
            if not ____ok_27 then
                error(____result_29, 0)
            end
            return false
        end)
    end)
    if not ____ok_28 then
        if ____result_30 == ____jump_24 then
            return ____jump_24.value
        end
        error(____result_30, 0)
    end
    return 0
end

local function throughRunCatching()
    local ____outcome
    local ____ok_29, ____result_31, ____returned_29 = pcall(function()
        local ____result_32
        do
            local ____jump_25 = __K2L_NewJump()
            local ____value_25
            local ____ok_30, ____result_33 = pcall(function()
                ____value_25 = __K2L_Text.trimWith("abc", 3, function(it)
                    if it == "c" then
                        __K2L_Jump(____jump_25, 1, "returned out of runCatching")
                    end
                    return false
                end)
            end)
            if not ____ok_30 then
                if ____result_33 == ____jump_25 then
                    return true, ____jump_25.value
                end
                error(____result_33, 0)
            end
            ____result_32 = "done"
        end
        ____outcome = __K2L_Result.success(____result_32)
    end)
    if ____ok_29 then
        if ____result_31 then
            return ____returned_29
        end
    else
        ____outcome = __K2L_Result.failure(__K2L_ToThrowable(____result_31))
    end
    local r = ____outcome
    return __K2L_Str(r)
end

local ____lambda_2 = function()
    return __K2L_Text.trimWith("abc", 3, function(it)
        if it == "c" then
            error(__K2L_IllegalStateException.new("boom"))
        end
        return false
    end)
end
local function failureStillCaught()
    local r = __K2L_RunCatching(____lambda_2)
    local ____receiver = r:exceptionOrNull()
    return ____receiver and ____receiver.message or "?"
end

local function inSequenceBuilder()
    return __K2L_SequenceBuilder(function(self)
        for i = 1, 5 do
            local ____jump_26 = __K2L_NewJump()
            local ____value_26
            local ____ok_31, ____result_34 = pcall(function()
                ____value_26 = __K2L_SequenceOf(i):maxOf(function(it)
                    if i == 4 then
                        __K2L_Jump(____jump_26, 1)
                    end
                    return it
                end)
            end)
            if not ____ok_31 then
                if ____result_34 == ____jump_26 then
                    return
                end
                error(____result_34, 0)
            end
            self:yield(i)
        end
    end):toList()
end

local function yieldsInsideClosure()
    return __K2L_SequenceBuilder(function(____this)
        for i = 1, 3 do
            local ____jump_27 = __K2L_NewJump()
            local ____value_27
            local ____ok_32, ____result_35 = pcall(function()
                ____value_27 = __K2L_Text.trimWith("ab", 3, function(c)
                    ____this:yield(i * 10 + c:byte() - 97)
                    if i == 2 then
                        __K2L_Jump(____jump_27, 1)
                    end
                    return false
                end)
            end)
            if not ____ok_32 then
                if ____result_35 == ____jump_27 then
                    return
                end
                error(____result_35, 0)
            end
        end
    end):toList()
end

local function main()
    print(trimOut("  a! "))
    print(trimOut("  a "))
    print(maxOrStop(__K2L_ListOf(1, 5, 3)))
    print(maxOrStop(__K2L_ListOf(1, -5, 3)))
    print(firstSquareOver(50))
    print(__K2L_Str(sequenceTerminals()))
    print(mapCatchingOut(__K2L_Result.success(1)))
    print(mapCatchingOut(__K2L_Result.success(2)))
    print(mapCatchingOut(__K2L_Result.failure(__K2L_IllegalStateException.new("x"))))
    print(breaksAndContinues())
    print(jumpsFromOneLambda(5))
    print(jumpsFromOneLambda(2))
    print(__K2L_Str(labeledToLambda()))
    print(nested())
    print(nestedThroughTry())
    print(nestedFunction())
    print(tailValue(__K2L_ListOf(1, 2)))
    print(tailValue(__K2L_ListOf(1, 20)))
    local log = __K2L_ListOf()
    unitFunction(log)
    print(__K2L_Str(log))
    print(throughTryCatch())
    print(tryAroundCall())
    local useLog = __K2L_ListOf()
    print(throughUse(useLog))
    print(__K2L_Str(useLog))
    print(throughRunCatching())
    print(failureStillCaught())
    print(__K2L_Str(inSequenceBuilder()))
    print(__K2L_Str(yieldsInsideClosure()))
end

__K2L_RunMain(main)
return {trimOut = trimOut, maxOrStop = maxOrStop, firstSquareOver = firstSquareOver, sequenceTerminals = sequenceTerminals, mapCatchingOut = mapCatchingOut, breaksAndContinues = breaksAndContinues, jumpsFromOneLambda = jumpsFromOneLambda, labeledToLambda = labeledToLambda, nested = nested, nestedThroughTry = nestedThroughTry, nestedFunction = nestedFunction, tailValue = tailValue, unitFunction = unitFunction, throughTryCatch = throughTryCatch, tryAroundCall = tryAroundCall, Resource = Resource, throughUse = throughUse, throughRunCatching = throughRunCatching, failureStillCaught = failureStillCaught, inSequenceBuilder = inSequenceBuilder, yieldsInsideClosure = yieldsInsideClosure}
