local ____lualib = require("lualib_bundle")
local __K2L_Jump = ____lualib.__K2L_Jump
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_NewJump = ____lualib.__K2L_NewJump
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SequenceOf = ____lualib.__K2L_SequenceOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_Text = ____lualib.__K2L_Text

local function forEachJumps()
    local log = ""
    for i = 0, 4 do
        do
            local ____list = __K2L_ListOf(1, 2, 3)
            for ____i = 1, ____list.size do
                local it = ____list[____i]
                if it == 2 and i == 3 then
                    goto ____break
                end
                if it == 3 then
                    goto ____continue
                end
                log = log .. i .. it .. " "
            end
        end
        ::____continue::
    end
    ::____break::
    return log
end

local function mapJumps(stopAt)
    local rows = __K2L_ListOf()
    for i = 0, 4 do
        do
            local ____list_1 = __K2L_ListOf(1, 2, 3)
            local ____result = __K2L_ListOf()
            for _, it in ipairs(____list_1) do
                local ____result_1
                if i == 1 then
                    goto ____continue_1
                end
                if i == stopAt then
                    goto ____break_1
                end
                if i == 4 and it == 2 then
                    return "returned with " .. __K2L_Str(rows)
                end
                ____result_1 = it * i
                ____result:add(____result_1)
            end
            local row = ____result
            rows:add(row)
        end
        ::____continue_1::
    end
    ::____break_1::
    return __K2L_Str(rows)
end

local function labeled()
    local log = ""
    for i = 0, 3 do
        do
            for j = 0, 3 do
                do
                    local ____list_2 = __K2L_ListOf("a", "b")
                    for ____i_1 = 1, ____list_2.size do
                        local s = ____list_2[____i_1]
                        local k = ____i_1 - 1
                        if j == 1 then
                            goto ____continue_2
                        end
                        if j == 2 and i == 1 then
                            goto ____continue_3
                        end
                        if j == 2 and k == 1 then
                            goto ____break_2
                        end
                        if i == 3 then
                            goto ____break_3
                        end
                        log = log .. i .. j .. s .. " "
                    end
                end
                ::____continue_2::
            end
            ::____break_2::
        end
        ::____continue_3::
    end
    ::____break_3::
    return log
end

local function scopeFunctions()
    local log = ""
    local n = 0
    while n < 6 do
        do
            n = n + 1
            local ____value = n
            if ____value == 2 then
                goto ____continue_4
            end
            if n == 5 then
                break
            end
            log = log .. n
        end
        ::____continue_4::
    end
    local m = 0
    repeat
        do
            m = m + 1
            local ____value_1 = m
            if ____value_1 % 2 == 0 then
                goto ____continue_5
            end
            log = log .. "-" .. m
        end
        ::____continue_5::
    until not (m < 5)
    return log
end

local function stringAndSequence()
    local log = ""
    local ____list_3 = __K2L_ListOf("abc", "xyz", "stop", "end")
    for ____i_2 = 1, ____list_3.size do
        local w = ____list_3[____i_2]
        do
            local ____chars = __K2L_StringToList(w)
            local ____result_2 = __K2L_ListOf()
            for _, it in ipairs(____chars) do
                local ____result_3
                if it == "y" then
                    goto ____continue_6
                end
                if w == "stop" then
                    goto ____break_5
                end
                ____result_3 = it ~= "b"
                if ____result_3 then
                    ____result_2:add(it)
                end
            end
            local upper = ____result_2:joinToString("")
            log = log .. upper .. " "
            for _, it in __K2L_SequenceOf(1, 2):iter() do
                if it == 2 then
                    goto ____continue_6
                end
                log = log .. it .. " "
            end
        end
        ::____continue_6::
    end
    ::____break_5::
    return log
end

local function twice(body)
    for i = 0, 1 do
        body(i)
    end
end

local function userInline()
    local log = ""
    for k = 0, 3 do
        do
            for ____i_3 = 0, 1 do
                if k == 1 then
                    goto ____continue_7
                end
                if k == 3 then
                    goto ____break_6
                end
                log = log .. k .. ____i_3 .. " "
            end
        end
        ::____continue_7::
    end
    ::____break_6::
    return log
end

local function trimWith(s, pred)
    return __K2L_Text.trimWith(s, 3, pred)
end

local function trimVia(s, pred)
    return __K2L_Text.trimWith(s, 3, function(it) return pred(it) end)
end

local function passedOn(s)
    local ____result_4
    do
        local ____jump = __K2L_NewJump()
        local ____value_2
        local ____ok, ____result_5 = pcall(function()
            ____value_2 = __K2L_Text.trimWith(s, 3, function(it)
                if it == "!" then
                    __K2L_Jump(____jump, 1, "returned via trimWith")
                else
                    return it == " "
                end
            end)
        end)
        if not ____ok then
            if ____result_5 == ____jump then
                return ____jump.value
            end
            error(____result_5, 0)
        end
        ____result_4 = ____value_2
    end
    local a = ____result_4
    local ____result_6
    do
        local ____jump_1 = __K2L_NewJump()
        local ____value_3
        local ____ok_1, ____result_8 = pcall(function()
            ____value_3 = __K2L_Text.trimWith(s, 3, function(it)
                local ____result_7
                if it == "?" then
                    __K2L_Jump(____jump_1, 1, "returned via trimVia")
                else
                    ____result_7 = it == " "
                end
                return ____result_7
            end)
        end)
        if not ____ok_1 then
            if ____result_8 == ____jump_1 then
                return ____jump_1.value
            end
            error(____result_8, 0)
        end
        ____result_6 = ____value_3
    end
    local b = ____result_6
    return "[" .. a .. "][" .. b .. "]"
end

local function passedOnJumps()
    local log = ""
    for k = 0, 3 do
        do
            local ____result_9
            do
                local ____jump_2 = __K2L_NewJump()
                local ____value_4
                local ____ok_2, ____result_11 = pcall(function()
                    ____value_4 = __K2L_Text.trimWith("ab", 3, function(it)
                        local ____result_10
                        if k == 1 then
                            __K2L_Jump(____jump_2, 1)
                        end
                        if k == 3 then
                            __K2L_Jump(____jump_2, 2)
                        end
                        ____result_10 = false
                        return ____result_10
                    end)
                end)
                if not ____ok_2 then
                    if ____result_11 == ____jump_2 then
                        if ____jump_2.code == 1 then
                            goto ____continue_8
                        elseif ____jump_2.code == 2 then
                            break
                        end
                    end
                    error(____result_11, 0)
                end
                ____result_9 = ____value_4
            end
            log = log .. k .. " "
        end
        ::____continue_8::
    end
    return log
end

local function capped(n, f)
    for i = 0, 2 do
        f(n + i)
    end
end

local function viaTrim(s)
    for i = 0, 2 do
        do
            local it = 1 + i
            local ____jump_3 = __K2L_NewJump()
            local ____value_5
            local ____ok_3, ____result_12 = pcall(function()
                ____value_5 = __K2L_Text.trimWith(s, 3, function(c)
                    if c:byte() > it then
                        __K2L_Jump(____jump_3, 1, __K2L_ListOf())
                    else
                        return true
                    end
                end)
            end)
            if not ____ok_3 then
                if ____result_12 == ____jump_3 then
                    return ____jump_3.value
                end
                error(____result_12, 0)
            end
        end
    end
    return __K2L_ListOf(#s)
end

local function nestedInlineReturns(a, b)
    local log = ""
    local ____result_13
    do
        do
            if a then
                goto ____inline_end
            end
            if b then
                ____result_13 = "outer"
                goto ____inline_end_1
            end
            log = log .. "x"
            ::____inline_end::
        end
        ____result_13 = "end"
        ::____inline_end_1::
    end
    local r = ____result_13
    return r .. " " .. log
end

local function returnFromLoopInRun(n)
    local ____result_14
    do
        for i = 0, 5 do
            do
                if i == 1 then
                    goto ____continue_9
                end
                if i == n then
                    ____result_14 = "at " .. i
                    goto ____inline_end_2
                end
            end
            ::____continue_9::
        end
        ____result_14 = "none"
        ::____inline_end_2::
    end
    return ____result_14
end

local function main()
    print(forEachJumps())
    print(mapJumps(3))
    print(mapJumps(9))
    print(labeled())
    print(scopeFunctions())
    print(stringAndSequence())
    print(userInline())
    print(passedOn("  a  "))
    print(passedOn(" a! "))
    print(passedOn(" a? "))
    print(passedOnJumps())
    print(__K2L_Str(viaTrim("a")))
    print(__K2L_Str(viaTrim("\001")))
    print(nestedInlineReturns(true, false))
    print(nestedInlineReturns(false, true))
    print(nestedInlineReturns(false, false))
    print(returnFromLoopInRun(3))
    print(returnFromLoopInRun(9))
end

__K2L_RunMain(main)
return {forEachJumps = forEachJumps, mapJumps = mapJumps, labeled = labeled, scopeFunctions = scopeFunctions, stringAndSequence = stringAndSequence, twice = twice, userInline = userInline, trimWith = trimWith, trimVia = trimVia, passedOn = passedOn, passedOnJumps = passedOnJumps, capped = capped, viaTrim = viaTrim, nestedInlineReturns = nestedInlineReturns, returnFromLoopInRun = returnFromLoopInRun}
