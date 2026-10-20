local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_IsArray = ____lualib.__K2L_IsArray
local __K2L_Jump = ____lualib.__K2L_Jump
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_NewJump = ____lualib.__K2L_NewJump
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Result = ____lualib.__K2L_Result
local __K2L_SequenceOf = ____lualib.__K2L_SequenceOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_Unit = ____lualib.__K2L_Unit

local function show(v)
    if __K2L_IsArray(v) then
        return v:contentToString()
    elseif __K2L_IsArray(v, "[I") then
        return v:contentToString()
    else
        return __K2L_Str(v)
    end
end

local Returns1 = __K2L_Class("Returns1")

function Returns1:t_list_zipWithNext(f)
    local ____jump = __K2L_NewJump()
    local ____value
    local ____ok, ____result = __K2L_DeepPcall(function()
        ____value = __K2L_ReadOnlyListOf(1, 2, 3):zipWithNext(function(a, b)
            if f then
                __K2L_Jump(____jump, 1, "R")
            end
            return a + b
        end)
    end)
    if not ____ok then
        if ____result == ____jump then
            return ____jump.value
        end
        error(____result, 0)
    end
    local v = ____value
    return "ok " .. show(v)
end

function Returns1:t_seq_all(f)
    local ____jump_1 = __K2L_NewJump()
    local ____value_1
    local ____ok_1, ____result_1 = __K2L_DeepPcall(function()
        ____value_1 = __K2L_SequenceOf(1, 2, 3):all(function(it)
            if f then
                __K2L_Jump(____jump_1, 1, "R")
            end
            return it > 1
        end)
    end)
    if not ____ok_1 then
        if ____result_1 == ____jump_1 then
            return ____jump_1.value
        end
        error(____result_1, 0)
    end
    local v = ____value_1
    return "ok " .. show(v)
end

function Returns1:t_seq_any(f)
    local ____jump_2 = __K2L_NewJump()
    local ____value_2
    local ____ok_2, ____result_2 = __K2L_DeepPcall(function()
        ____value_2 = __K2L_SequenceOf(1, 2, 3):any(function(it)
            if f then
                __K2L_Jump(____jump_2, 1, "R")
            end
            return it > 1
        end)
    end)
    if not ____ok_2 then
        if ____result_2 == ____jump_2 then
            return ____jump_2.value
        end
        error(____result_2, 0)
    end
    local v = ____value_2
    return "ok " .. show(v)
end

function Returns1:t_seq_count(f)
    local ____jump_3 = __K2L_NewJump()
    local ____value_3
    local ____ok_3, ____result_3 = __K2L_DeepPcall(function()
        ____value_3 = __K2L_SequenceOf(1, 2, 3):count(function(it)
            if f then
                __K2L_Jump(____jump_3, 1, "R")
            end
            return it > 1
        end)
    end)
    if not ____ok_3 then
        if ____result_3 == ____jump_3 then
            return ____jump_3.value
        end
        error(____result_3, 0)
    end
    local v = ____value_3
    return "ok " .. show(v)
end

function Returns1:t_seq_find(f)
    local ____jump_4 = __K2L_NewJump()
    local ____value_4
    local ____ok_4, ____result_4 = __K2L_DeepPcall(function()
        ____value_4 = __K2L_SequenceOf(1, 2, 3):find(function(it)
            if f then
                __K2L_Jump(____jump_4, 1, "R")
            end
            return it > 1
        end)
    end)
    if not ____ok_4 then
        if ____result_4 == ____jump_4 then
            return ____jump_4.value
        end
        error(____result_4, 0)
    end
    local v = ____value_4
    return "ok " .. show(v)
end

function Returns1:t_seq_first(f)
    local ____jump_5 = __K2L_NewJump()
    local ____value_5
    local ____ok_5, ____result_5 = __K2L_DeepPcall(function()
        ____value_5 = __K2L_SequenceOf(1, 2, 3):first(function(it)
            if f then
                __K2L_Jump(____jump_5, 1, "R")
            end
            return it > 1
        end)
    end)
    if not ____ok_5 then
        if ____result_5 == ____jump_5 then
            return ____jump_5.value
        end
        error(____result_5, 0)
    end
    local v = ____value_5
    return "ok " .. show(v)
end

function Returns1:t_seq_firstOrNull(f)
    local ____jump_6 = __K2L_NewJump()
    local ____value_6
    local ____ok_6, ____result_6 = __K2L_DeepPcall(function()
        ____value_6 = __K2L_SequenceOf(1, 2, 3):firstOrNull(function(it)
            if f then
                __K2L_Jump(____jump_6, 1, "R")
            end
            return it > 1
        end)
    end)
    if not ____ok_6 then
        if ____result_6 == ____jump_6 then
            return ____jump_6.value
        end
        error(____result_6, 0)
    end
    local v = ____value_6
    return "ok " .. show(v)
end

function Returns1:t_seq_forEachIndexed(f)
    local ____jump_7 = __K2L_NewJump()
    local ____ok_7, ____result_7 = __K2L_DeepPcall(function()
        __K2L_SequenceOf(1, 2, 3):forEachIndexed(function(_, _)
            if f then
                __K2L_Jump(____jump_7, 1, "R")
            end
        end)
    end)
    if not ____ok_7 then
        if ____result_7 == ____jump_7 then
            return ____jump_7.value
        end
        error(____result_7, 0)
    end
    local v = __K2L_Unit
    return "ok " .. show(v)
end

function Returns1:t_seq_last(f)
    local ____jump_8 = __K2L_NewJump()
    local ____value_7
    local ____ok_8, ____result_8 = __K2L_DeepPcall(function()
        ____value_7 = __K2L_SequenceOf(1, 2, 3):last(function(it)
            if f then
                __K2L_Jump(____jump_8, 1, "R")
            end
            return it > 1
        end)
    end)
    if not ____ok_8 then
        if ____result_8 == ____jump_8 then
            return ____jump_8.value
        end
        error(____result_8, 0)
    end
    local v = ____value_7
    return "ok " .. show(v)
end

function Returns1:t_seq_lastOrNull(f)
    local ____jump_9 = __K2L_NewJump()
    local ____value_8
    local ____ok_9, ____result_9 = __K2L_DeepPcall(function()
        ____value_8 = __K2L_SequenceOf(1, 2, 3):lastOrNull(function(it)
            if f then
                __K2L_Jump(____jump_9, 1, "R")
            end
            return it > 1
        end)
    end)
    if not ____ok_9 then
        if ____result_9 == ____jump_9 then
            return ____jump_9.value
        end
        error(____result_9, 0)
    end
    local v = ____value_8
    return "ok " .. show(v)
end

function Returns1:t_seq_none(f)
    local ____jump_10 = __K2L_NewJump()
    local ____value_9
    local ____ok_10, ____result_10 = __K2L_DeepPcall(function()
        ____value_9 = __K2L_SequenceOf(1, 2, 3):none(function(it)
            if f then
                __K2L_Jump(____jump_10, 1, "R")
            end
            return it > 1
        end)
    end)
    if not ____ok_10 then
        if ____result_10 == ____jump_10 then
            return ____jump_10.value
        end
        error(____result_10, 0)
    end
    local v = ____value_9
    return "ok " .. show(v)
end

function Returns1:t_seq_associateBy(f)
    local ____jump_11 = __K2L_NewJump()
    local ____value_10
    local ____ok_11, ____result_11 = __K2L_DeepPcall(function()
        ____value_10 = __K2L_SequenceOf(1, 2, 3):associateBy(function(it)
            if f then
                __K2L_Jump(____jump_11, 1, "R")
            end
            return it
        end)
    end)
    if not ____ok_11 then
        if ____result_11 == ____jump_11 then
            return ____jump_11.value
        end
        error(____result_11, 0)
    end
    local v = ____value_10
    return "ok " .. show(v)
end

function Returns1:t_seq_associate(f)
    local ____jump_12 = __K2L_NewJump()
    local ____value_11
    local ____ok_12, ____result_12 = __K2L_DeepPcall(function()
        ____value_11 = __K2L_SequenceOf(1, 2, 3):associate(function(it)
            if f then
                __K2L_Jump(____jump_12, 1, "R")
            end
            return __K2L_Pair.new(it, it)
        end)
    end)
    if not ____ok_12 then
        if ____result_12 == ____jump_12 then
            return ____jump_12.value
        end
        error(____result_12, 0)
    end
    local v = ____value_11
    return "ok " .. show(v)
end

function Returns1:t_seq_associateWith(f)
    local ____jump_13 = __K2L_NewJump()
    local ____value_12
    local ____ok_13, ____result_13 = __K2L_DeepPcall(function()
        ____value_12 = __K2L_SequenceOf(1, 2, 3):associateWith(function(it)
            if f then
                __K2L_Jump(____jump_13, 1, "R")
            end
            return it
        end)
    end)
    if not ____ok_13 then
        if ____result_13 == ____jump_13 then
            return ____jump_13.value
        end
        error(____result_13, 0)
    end
    local v = ____value_12
    return "ok " .. show(v)
end

function Returns1:t_seq_findLast(f)
    local ____jump_14 = __K2L_NewJump()
    local ____value_13
    local ____ok_14, ____result_14 = __K2L_DeepPcall(function()
        ____value_13 = __K2L_SequenceOf(1, 2, 3):findLast(function(it)
            if f then
                __K2L_Jump(____jump_14, 1, "R")
            end
            return it > 1
        end)
    end)
    if not ____ok_14 then
        if ____result_14 == ____jump_14 then
            return ____jump_14.value
        end
        error(____result_14, 0)
    end
    local v = ____value_13
    return "ok " .. show(v)
end

function Returns1:t_seq_fold(f)
    local ____jump_15 = __K2L_NewJump()
    local ____value_14
    local ____ok_15, ____result_15 = __K2L_DeepPcall(function()
        ____value_14 = __K2L_SequenceOf(1, 2, 3):fold(0, function(a, x)
            if f then
                __K2L_Jump(____jump_15, 1, "R")
            end
            return a + x
        end)
    end)
    if not ____ok_15 then
        if ____result_15 == ____jump_15 then
            return ____jump_15.value
        end
        error(____result_15, 0)
    end
    local v = ____value_14
    return "ok " .. show(v)
end

function Returns1:t_seq_foldIndexed(f)
    local ____jump_16 = __K2L_NewJump()
    local ____value_15
    local ____ok_16, ____result_16 = __K2L_DeepPcall(function()
        ____value_15 = __K2L_SequenceOf(1, 2, 3):foldIndexed(0, function(_, a, x)
            if f then
                __K2L_Jump(____jump_16, 1, "R")
            end
            return a + x
        end)
    end)
    if not ____ok_16 then
        if ____result_16 == ____jump_16 then
            return ____jump_16.value
        end
        error(____result_16, 0)
    end
    local v = ____value_15
    return "ok " .. show(v)
end

function Returns1:t_seq_groupBy(f)
    local ____jump_17 = __K2L_NewJump()
    local ____value_16
    local ____ok_17, ____result_17 = __K2L_DeepPcall(function()
        ____value_16 = __K2L_SequenceOf(1, 2, 3):groupBy(function(it)
            if f then
                __K2L_Jump(____jump_17, 1, "R")
            end
            return it
        end)
    end)
    if not ____ok_17 then
        if ____result_17 == ____jump_17 then
            return ____jump_17.value
        end
        error(____result_17, 0)
    end
    local v = ____value_16
    return "ok " .. show(v)
end

function Returns1:t_seq_indexOfFirst(f)
    local ____jump_18 = __K2L_NewJump()
    local ____value_17
    local ____ok_18, ____result_18 = __K2L_DeepPcall(function()
        ____value_17 = __K2L_SequenceOf(1, 2, 3):indexOfFirst(function(it)
            if f then
                __K2L_Jump(____jump_18, 1, "R")
            end
            return it > 1
        end)
    end)
    if not ____ok_18 then
        if ____result_18 == ____jump_18 then
            return ____jump_18.value
        end
        error(____result_18, 0)
    end
    local v = ____value_17
    return "ok " .. show(v)
end

function Returns1:t_seq_maxBy(f)
    local ____jump_19 = __K2L_NewJump()
    local ____value_18
    local ____ok_19, ____result_19 = __K2L_DeepPcall(function()
        ____value_18 = __K2L_SequenceOf(1, 2, 3):maxBy(function(it)
            if f then
                __K2L_Jump(____jump_19, 1, "R")
            end
            return it
        end)
    end)
    if not ____ok_19 then
        if ____result_19 == ____jump_19 then
            return ____jump_19.value
        end
        error(____result_19, 0)
    end
    local v = ____value_18
    return "ok " .. show(v)
end

function Returns1:t_seq_maxByOrNull(f)
    local ____jump_20 = __K2L_NewJump()
    local ____value_19
    local ____ok_20, ____result_20 = __K2L_DeepPcall(function()
        ____value_19 = __K2L_SequenceOf(1, 2, 3):maxByOrNull(function(it)
            if f then
                __K2L_Jump(____jump_20, 1, "R")
            end
            return it
        end)
    end)
    if not ____ok_20 then
        if ____result_20 == ____jump_20 then
            return ____jump_20.value
        end
        error(____result_20, 0)
    end
    local v = ____value_19
    return "ok " .. show(v)
end

function Returns1:t_seq_maxOf(f)
    local ____jump_21 = __K2L_NewJump()
    local ____value_20
    local ____ok_21, ____result_21 = __K2L_DeepPcall(function()
        ____value_20 = __K2L_SequenceOf(1, 2, 3):maxOf(function(it)
            if f then
                __K2L_Jump(____jump_21, 1, "R")
            end
            return it
        end)
    end)
    if not ____ok_21 then
        if ____result_21 == ____jump_21 then
            return ____jump_21.value
        end
        error(____result_21, 0)
    end
    local v = ____value_20
    return "ok " .. show(v)
end

function Returns1:t_seq_maxOfOrNull(f)
    local ____jump_22 = __K2L_NewJump()
    local ____value_21
    local ____ok_22, ____result_22 = __K2L_DeepPcall(function()
        ____value_21 = __K2L_SequenceOf(1, 2, 3):maxOfOrNull(function(it)
            if f then
                __K2L_Jump(____jump_22, 1, "R")
            end
            return it
        end)
    end)
    if not ____ok_22 then
        if ____result_22 == ____jump_22 then
            return ____jump_22.value
        end
        error(____result_22, 0)
    end
    local v = ____value_21
    return "ok " .. show(v)
end

function Returns1:t_seq_minBy(f)
    local ____jump_23 = __K2L_NewJump()
    local ____value_22
    local ____ok_23, ____result_23 = __K2L_DeepPcall(function()
        ____value_22 = __K2L_SequenceOf(1, 2, 3):minBy(function(it)
            if f then
                __K2L_Jump(____jump_23, 1, "R")
            end
            return it
        end)
    end)
    if not ____ok_23 then
        if ____result_23 == ____jump_23 then
            return ____jump_23.value
        end
        error(____result_23, 0)
    end
    local v = ____value_22
    return "ok " .. show(v)
end

function Returns1:t_seq_minByOrNull(f)
    local ____jump_24 = __K2L_NewJump()
    local ____value_23
    local ____ok_24, ____result_24 = __K2L_DeepPcall(function()
        ____value_23 = __K2L_SequenceOf(1, 2, 3):minByOrNull(function(it)
            if f then
                __K2L_Jump(____jump_24, 1, "R")
            end
            return it
        end)
    end)
    if not ____ok_24 then
        if ____result_24 == ____jump_24 then
            return ____jump_24.value
        end
        error(____result_24, 0)
    end
    local v = ____value_23
    return "ok " .. show(v)
end

function Returns1:t_seq_minOf(f)
    local ____jump_25 = __K2L_NewJump()
    local ____value_24
    local ____ok_25, ____result_25 = __K2L_DeepPcall(function()
        ____value_24 = __K2L_SequenceOf(1, 2, 3):minOf(function(it)
            if f then
                __K2L_Jump(____jump_25, 1, "R")
            end
            return it
        end)
    end)
    if not ____ok_25 then
        if ____result_25 == ____jump_25 then
            return ____jump_25.value
        end
        error(____result_25, 0)
    end
    local v = ____value_24
    return "ok " .. show(v)
end

function Returns1:t_seq_minOfOrNull(f)
    local ____jump_26 = __K2L_NewJump()
    local ____value_25
    local ____ok_26, ____result_26 = __K2L_DeepPcall(function()
        ____value_25 = __K2L_SequenceOf(1, 2, 3):minOfOrNull(function(it)
            if f then
                __K2L_Jump(____jump_26, 1, "R")
            end
            return it
        end)
    end)
    if not ____ok_26 then
        if ____result_26 == ____jump_26 then
            return ____jump_26.value
        end
        error(____result_26, 0)
    end
    local v = ____value_25
    return "ok " .. show(v)
end

function Returns1:t_seq_partition(f)
    local ____jump_27 = __K2L_NewJump()
    local ____value_26
    local ____ok_27, ____result_27 = __K2L_DeepPcall(function()
        ____value_26 = __K2L_SequenceOf(1, 2, 3):partition(function(it)
            if f then
                __K2L_Jump(____jump_27, 1, "R")
            end
            return it > 1
        end)
    end)
    if not ____ok_27 then
        if ____result_27 == ____jump_27 then
            return ____jump_27.value
        end
        error(____result_27, 0)
    end
    local v = ____value_26
    return "ok " .. show(v)
end

function Returns1:t_seq_reduce(f)
    local ____jump_28 = __K2L_NewJump()
    local ____value_27
    local ____ok_28, ____result_28 = __K2L_DeepPcall(function()
        ____value_27 = __K2L_SequenceOf(1, 2, 3):reduce(function(a, x)
            if f then
                __K2L_Jump(____jump_28, 1, "R")
            end
            return a + x
        end)
    end)
    if not ____ok_28 then
        if ____result_28 == ____jump_28 then
            return ____jump_28.value
        end
        error(____result_28, 0)
    end
    local v = ____value_27
    return "ok " .. show(v)
end

function Returns1:t_seq_single(f)
    local ____jump_29 = __K2L_NewJump()
    local ____value_28
    local ____ok_29, ____result_29 = __K2L_DeepPcall(function()
        ____value_28 = __K2L_SequenceOf(1, 2, 3):single(function(it)
            if f then
                __K2L_Jump(____jump_29, 1, "R")
            end
            return it == 2
        end)
    end)
    if not ____ok_29 then
        if ____result_29 == ____jump_29 then
            return ____jump_29.value
        end
        error(____result_29, 0)
    end
    local v = ____value_28
    return "ok " .. show(v)
end

local Returns2 = __K2L_Class("Returns2")

function Returns2:t_seq_singleOrNull(f)
    local ____jump_30 = __K2L_NewJump()
    local ____value_29
    local ____ok_30, ____result_30 = __K2L_DeepPcall(function()
        ____value_29 = __K2L_SequenceOf(1, 2, 3):singleOrNull(function(it)
            if f then
                __K2L_Jump(____jump_30, 1, "R")
            end
            return it > 1
        end)
    end)
    if not ____ok_30 then
        if ____result_30 == ____jump_30 then
            return ____jump_30.value
        end
        error(____result_30, 0)
    end
    local v = ____value_29
    return "ok " .. show(v)
end

function Returns2:t_seq_sumOf(f)
    local ____jump_31 = __K2L_NewJump()
    local ____value_30
    local ____ok_31, ____result_31 = __K2L_DeepPcall(function()
        ____value_30 = __K2L_SequenceOf(1, 2, 3):sumOf(function(it)
            if f then
                __K2L_Jump(____jump_31, 1, "R")
            end
            return it
        end)
    end)
    if not ____ok_31 then
        if ____result_31 == ____jump_31 then
            return ____jump_31.value
        end
        error(____result_31, 0)
    end
    local v = ____value_30
    return "ok " .. show(v)
end

function Returns2:t_range_zipWithNext(f)
    local ____jump_32 = __K2L_NewJump()
    local ____value_31
    local ____ok_32, ____result_32 = __K2L_DeepPcall(function()
        ____value_31 = __K2L_IntRange.new(1, 3):zipWithNext(function(a, b)
            if f then
                __K2L_Jump(____jump_32, 1, "R")
            end
            return a + b
        end)
    end)
    if not ____ok_32 then
        if ____result_32 == ____jump_32 then
            return ____jump_32.value
        end
        error(____result_32, 0)
    end
    local v = ____value_31
    return "ok " .. show(v)
end

function Returns2:t_text_trim(f)
    local ____jump_33 = __K2L_NewJump()
    local ____value_32
    local ____ok_33, ____result_33 = __K2L_DeepPcall(function()
        ____value_32 = __K2L_Text.trimWith("abc", 3, function(it)
            if f then
                __K2L_Jump(____jump_33, 1, "R")
            end
            return true
        end)
    end)
    if not ____ok_33 then
        if ____result_33 == ____jump_33 then
            return ____jump_33.value
        end
        error(____result_33, 0)
    end
    local v = ____value_32
    return "ok " .. show(v)
end

function Returns2:t_text_maxOf(f)
    local ____jump_34 = __K2L_NewJump()
    local ____value_33
    local ____ok_34, ____result_34 = __K2L_DeepPcall(function()
        ____value_33 = __K2L_StringToList("abc"):maxOf(function(it)
            if f then
                __K2L_Jump(____jump_34, 1, "R")
            end
            return it
        end)
    end)
    if not ____ok_34 then
        if ____result_34 == ____jump_34 then
            return ____jump_34.value
        end
        error(____result_34, 0)
    end
    local v = ____value_33
    return "ok " .. show(v)
end

function Returns2:t_text_partition(f)
    local ____jump_35 = __K2L_NewJump()
    local ____value_34
    local ____ok_35, ____result_35 = __K2L_DeepPcall(function()
        ____value_34 = __K2L_Text.partition("abc", function(it)
            if f then
                __K2L_Jump(____jump_35, 1, "R")
            end
            return true
        end)
    end)
    if not ____ok_35 then
        if ____result_35 == ____jump_35 then
            return ____jump_35.value
        end
        error(____result_35, 0)
    end
    local v = ____value_34
    return "ok " .. show(v)
end

function Returns2:t_text_trimEnd(f)
    local ____jump_36 = __K2L_NewJump()
    local ____value_35
    local ____ok_36, ____result_36 = __K2L_DeepPcall(function()
        ____value_35 = __K2L_Text.trimWith("abc", 2, function(it)
            if f then
                __K2L_Jump(____jump_36, 1, "R")
            end
            return true
        end)
    end)
    if not ____ok_36 then
        if ____result_36 == ____jump_36 then
            return ____jump_36.value
        end
        error(____result_36, 0)
    end
    local v = ____value_35
    return "ok " .. show(v)
end

function Returns2:t_text_trimStart(f)
    local ____jump_37 = __K2L_NewJump()
    local ____value_36
    local ____ok_37, ____result_37 = __K2L_DeepPcall(function()
        ____value_36 = __K2L_Text.trimWith("abc", 1, function(it)
            if f then
                __K2L_Jump(____jump_37, 1, "R")
            end
            return true
        end)
    end)
    if not ____ok_37 then
        if ____result_37 == ____jump_37 then
            return ____jump_37.value
        end
        error(____result_37, 0)
    end
    local v = ____value_36
    return "ok " .. show(v)
end

function Returns2:t_text_zipWithNext(f)
    local ____jump_38 = __K2L_NewJump()
    local ____value_37
    local ____ok_38, ____result_38 = __K2L_DeepPcall(function()
        ____value_37 = __K2L_StringToList("abc"):zipWithNext(function(a, b)
            if f then
                __K2L_Jump(____jump_38, 1, "R")
            end
            return a
        end)
    end)
    if not ____ok_38 then
        if ____result_38 == ____jump_38 then
            return ____jump_38.value
        end
        error(____result_38, 0)
    end
    local v = ____value_37
    return "ok " .. show(v)
end

function Returns2:t_Array_ctor(f)
    local ____jump_39 = __K2L_NewJump()
    local ____value_38
    local ____ok_39, ____result_39 = __K2L_DeepPcall(function()
        ____value_38 = __K2L_ListOfSize(3, function(it)
            if f then
                __K2L_Jump(____jump_39, 1, "R")
            end
            return it
        end, "[Ljava.lang.Integer;")
    end)
    if not ____ok_39 then
        if ____result_39 == ____jump_39 then
            return ____jump_39.value
        end
        error(____result_39, 0)
    end
    local v = ____value_38
    return "ok " .. show(v)
end

function Returns2:t_IntArray_ctor(f)
    local ____jump_40 = __K2L_NewJump()
    local ____value_39
    local ____ok_40, ____result_40 = __K2L_DeepPcall(function()
        ____value_39 = __K2L_ListOfSize(3, function(it)
            if f then
                __K2L_Jump(____jump_40, 1, "R")
            end
            return it
        end, "[I")
    end)
    if not ____ok_40 then
        if ____result_40 == ____jump_40 then
            return ____jump_40.value
        end
        error(____result_40, 0)
    end
    local v = ____value_39
    return "ok " .. show(v)
end

function Returns2:t_List_ctor(f)
    local ____jump_41 = __K2L_NewJump()
    local ____value_40
    local ____ok_41, ____result_41 = __K2L_DeepPcall(function()
        ____value_40 = __K2L_ListOfSize(3, function(it)
            if f then
                __K2L_Jump(____jump_41, 1, "R")
            end
            return it
        end)
    end)
    if not ____ok_41 then
        if ____result_41 == ____jump_41 then
            return ____jump_41.value
        end
        error(____result_41, 0)
    end
    local v = ____value_40
    return "ok " .. show(v)
end

function Returns2:t_MutableList_ctor(f)
    local ____jump_42 = __K2L_NewJump()
    local ____value_41
    local ____ok_42, ____result_42 = __K2L_DeepPcall(function()
        ____value_41 = __K2L_ListOfSize(3, function(it)
            if f then
                __K2L_Jump(____jump_42, 1, "R")
            end
            return it
        end)
    end)
    if not ____ok_42 then
        if ____result_42 == ____jump_42 then
            return ____jump_42.value
        end
        error(____result_42, 0)
    end
    local v = ____value_41
    return "ok " .. show(v)
end

function Returns2:t_result_mapCatching(f)
    local ____jump_43 = __K2L_NewJump()
    local ____value_42
    local ____ok_43, ____result_43 = __K2L_DeepPcall(function()
        ____value_42 = __K2L_Result.success(1):mapCatching(function(it)
            if f then
                __K2L_Jump(____jump_43, 1, "R")
            end
            return it
        end)
    end)
    if not ____ok_43 then
        if ____result_43 == ____jump_43 then
            return ____jump_43.value
        end
        error(____result_43, 0)
    end
    local v = ____value_42
    return "ok " .. show(v)
end

function Returns2:t_result_recoverCatching(f)
    local ____jump_44 = __K2L_NewJump()
    local ____value_43
    local ____ok_44, ____result_44 = __K2L_DeepPcall(function()
        ____value_43 = __K2L_Result.failure(__K2L_Exception.new()):recoverCatching(function(it)
            if f then
                __K2L_Jump(____jump_44, 1, "R")
            end
            return 0
        end)
    end)
    if not ____ok_44 then
        if ____result_44 == ____jump_44 then
            return ____jump_44.value
        end
        error(____result_44, 0)
    end
    local v = ____value_43
    return "ok " .. show(v)
end

local Breaks1 = __K2L_Class("Breaks1")

function Breaks1:t_seq_any(f)
    local log = ""
    for k = 0, 2 do
        local ____jump_45 = __K2L_NewJump()
        local ____value_44
        local ____ok_45, ____result_45 = __K2L_DeepPcall(function()
            ____value_44 = __K2L_SequenceOf(1, 2, 3):any(function(it)
                if f and k == 1 then
                    __K2L_Jump(____jump_45, 1)
                end
                return it > 1
            end)
        end)
        if not ____ok_45 then
            if ____result_45 == ____jump_45 then
                break
            end
            error(____result_45, 0)
        end
        local v = ____value_44
        log = log .. k .. ":" .. show(v) .. ";"
    end
    return log
end

function Breaks1:t_seq_fold(f)
    local log = ""
    for k = 0, 2 do
        local ____jump_46 = __K2L_NewJump()
        local ____value_45
        local ____ok_46, ____result_46 = __K2L_DeepPcall(function()
            ____value_45 = __K2L_SequenceOf(1, 2, 3):fold(0, function(a, x)
                if f and k == 1 then
                    __K2L_Jump(____jump_46, 1)
                end
                return a + x
            end)
        end)
        if not ____ok_46 then
            if ____result_46 == ____jump_46 then
                break
            end
            error(____result_46, 0)
        end
        local v = ____value_45
        log = log .. k .. ":" .. show(v) .. ";"
    end
    return log
end

function Breaks1:t_seq_forEachIndexed(f)
    local log = ""
    for k = 0, 2 do
        local ____jump_47 = __K2L_NewJump()
        local ____ok_47, ____result_47 = __K2L_DeepPcall(function()
            __K2L_SequenceOf(1, 2, 3):forEachIndexed(function(_, _)
                if f and k == 1 then
                    __K2L_Jump(____jump_47, 1)
                end
            end)
        end)
        if not ____ok_47 then
            if ____result_47 == ____jump_47 then
                break
            end
            error(____result_47, 0)
        end
        local v = __K2L_Unit
        log = log .. k .. ":" .. show(v) .. ";"
    end
    return log
end

function Breaks1:t_seq_maxOf(f)
    local log = ""
    for k = 0, 2 do
        local ____jump_48 = __K2L_NewJump()
        local ____value_46
        local ____ok_48, ____result_48 = __K2L_DeepPcall(function()
            ____value_46 = __K2L_SequenceOf(1, 2, 3):maxOf(function(it)
                if f and k == 1 then
                    __K2L_Jump(____jump_48, 1)
                end
                return it
            end)
        end)
        if not ____ok_48 then
            if ____result_48 == ____jump_48 then
                break
            end
            error(____result_48, 0)
        end
        local v = ____value_46
        log = log .. k .. ":" .. show(v) .. ";"
    end
    return log
end

function Breaks1:t_seq_partition(f)
    local log = ""
    for k = 0, 2 do
        local ____jump_49 = __K2L_NewJump()
        local ____value_47
        local ____ok_49, ____result_49 = __K2L_DeepPcall(function()
            ____value_47 = __K2L_SequenceOf(1, 2, 3):partition(function(it)
                if f and k == 1 then
                    __K2L_Jump(____jump_49, 1)
                end
                return it > 1
            end)
        end)
        if not ____ok_49 then
            if ____result_49 == ____jump_49 then
                break
            end
            error(____result_49, 0)
        end
        local v = ____value_47
        log = log .. k .. ":" .. show(v) .. ";"
    end
    return log
end

function Breaks1:t_text_trim(f)
    local log = ""
    for k = 0, 2 do
        local ____jump_50 = __K2L_NewJump()
        local ____value_48
        local ____ok_50, ____result_50 = __K2L_DeepPcall(function()
            ____value_48 = __K2L_Text.trimWith("abc", 3, function(it)
                if f and k == 1 then
                    __K2L_Jump(____jump_50, 1)
                end
                return true
            end)
        end)
        if not ____ok_50 then
            if ____result_50 == ____jump_50 then
                break
            end
            error(____result_50, 0)
        end
        local v = ____value_48
        log = log .. k .. ":" .. show(v) .. ";"
    end
    return log
end

function Breaks1:t_text_zipWithNext(f)
    local log = ""
    for k = 0, 2 do
        local ____jump_51 = __K2L_NewJump()
        local ____value_49
        local ____ok_51, ____result_51 = __K2L_DeepPcall(function()
            ____value_49 = __K2L_StringToList("abc"):zipWithNext(function(a, b)
                if f and k == 1 then
                    __K2L_Jump(____jump_51, 1)
                end
                return a
            end)
        end)
        if not ____ok_51 then
            if ____result_51 == ____jump_51 then
                break
            end
            error(____result_51, 0)
        end
        local v = ____value_49
        log = log .. k .. ":" .. show(v) .. ";"
    end
    return log
end

function Breaks1:t_List_ctor(f)
    local log = ""
    for k = 0, 2 do
        local ____jump_52 = __K2L_NewJump()
        local ____value_50
        local ____ok_52, ____result_52 = __K2L_DeepPcall(function()
            ____value_50 = __K2L_ListOfSize(3, function(it)
                if f and k == 1 then
                    __K2L_Jump(____jump_52, 1)
                end
                return it
            end)
        end)
        if not ____ok_52 then
            if ____result_52 == ____jump_52 then
                break
            end
            error(____result_52, 0)
        end
        local v = ____value_50
        log = log .. k .. ":" .. show(v) .. ";"
    end
    return log
end

function Breaks1:t_IntArray_ctor(f)
    local log = ""
    for k = 0, 2 do
        local ____jump_53 = __K2L_NewJump()
        local ____value_51
        local ____ok_53, ____result_53 = __K2L_DeepPcall(function()
            ____value_51 = __K2L_ListOfSize(3, function(it)
                if f and k == 1 then
                    __K2L_Jump(____jump_53, 1)
                end
                return it
            end, "[I")
        end)
        if not ____ok_53 then
            if ____result_53 == ____jump_53 then
                break
            end
            error(____result_53, 0)
        end
        local v = ____value_51
        log = log .. k .. ":" .. show(v) .. ";"
    end
    return log
end

function Breaks1:t_result_mapCatching(f)
    local log = ""
    for k = 0, 2 do
        local ____jump_54 = __K2L_NewJump()
        local ____value_52
        local ____ok_54, ____result_54 = __K2L_DeepPcall(function()
            ____value_52 = __K2L_Result.success(1):mapCatching(function(it)
                if f and k == 1 then
                    __K2L_Jump(____jump_54, 1)
                end
                return it
            end)
        end)
        if not ____ok_54 then
            if ____result_54 == ____jump_54 then
                break
            end
            error(____result_54, 0)
        end
        local v = ____value_52
        log = log .. k .. ":" .. show(v) .. ";"
    end
    return log
end

function Breaks1:t_result_recoverCatching(f)
    local log = ""
    for k = 0, 2 do
        local ____jump_55 = __K2L_NewJump()
        local ____value_53
        local ____ok_55, ____result_55 = __K2L_DeepPcall(function()
            ____value_53 = __K2L_Result.failure(__K2L_Exception.new()):recoverCatching(function(it)
                if f and k == 1 then
                    __K2L_Jump(____jump_55, 1)
                end
                return 0
            end)
        end)
        if not ____ok_55 then
            if ____result_55 == ____jump_55 then
                break
            end
            error(____result_55, 0)
        end
        local v = ____value_53
        log = log .. k .. ":" .. show(v) .. ";"
    end
    return log
end

function Breaks1:t_seq_sumOf(f)
    local log = ""
    for k = 0, 2 do
        local ____jump_56 = __K2L_NewJump()
        local ____value_54
        local ____ok_56, ____result_56 = __K2L_DeepPcall(function()
            ____value_54 = __K2L_SequenceOf(1, 2, 3):sumOf(function(it)
                if f and k == 1 then
                    __K2L_Jump(____jump_56, 1)
                end
                return it
            end)
        end)
        if not ____ok_56 then
            if ____result_56 == ____jump_56 then
                break
            end
            error(____result_56, 0)
        end
        local v = ____value_54
        log = log .. k .. ":" .. show(v) .. ";"
    end
    return log
end

local Continues1 = __K2L_Class("Continues1")

function Continues1:t_seq_any(f)
    local log = ""
    for k = 0, 2 do
        do
            local ____jump_57 = __K2L_NewJump()
            local ____value_55
            local ____ok_57, ____result_57 = __K2L_DeepPcall(function()
                ____value_55 = __K2L_SequenceOf(1, 2, 3):any(function(it)
                    if f and k == 1 then
                        __K2L_Jump(____jump_57, 1)
                    end
                    return it > 1
                end)
            end)
            if not ____ok_57 then
                if ____result_57 == ____jump_57 then
                    goto ____continue
                end
                error(____result_57, 0)
            end
            local v = ____value_55
            log = log .. k .. ":" .. show(v) .. ";"
        end
        ::____continue::
    end
    return log
end

function Continues1:t_seq_fold(f)
    local log = ""
    for k = 0, 2 do
        do
            local ____jump_58 = __K2L_NewJump()
            local ____value_56
            local ____ok_58, ____result_58 = __K2L_DeepPcall(function()
                ____value_56 = __K2L_SequenceOf(1, 2, 3):fold(0, function(a, x)
                    if f and k == 1 then
                        __K2L_Jump(____jump_58, 1)
                    end
                    return a + x
                end)
            end)
            if not ____ok_58 then
                if ____result_58 == ____jump_58 then
                    goto ____continue_1
                end
                error(____result_58, 0)
            end
            local v = ____value_56
            log = log .. k .. ":" .. show(v) .. ";"
        end
        ::____continue_1::
    end
    return log
end

function Continues1:t_seq_forEachIndexed(f)
    local log = ""
    for k = 0, 2 do
        do
            local ____jump_59 = __K2L_NewJump()
            local ____ok_59, ____result_59 = __K2L_DeepPcall(function()
                __K2L_SequenceOf(1, 2, 3):forEachIndexed(function(_, _)
                    if f and k == 1 then
                        __K2L_Jump(____jump_59, 1)
                    end
                end)
            end)
            if not ____ok_59 then
                if ____result_59 == ____jump_59 then
                    goto ____continue_2
                end
                error(____result_59, 0)
            end
            local v = __K2L_Unit
            log = log .. k .. ":" .. show(v) .. ";"
        end
        ::____continue_2::
    end
    return log
end

function Continues1:t_seq_maxOf(f)
    local log = ""
    for k = 0, 2 do
        do
            local ____jump_60 = __K2L_NewJump()
            local ____value_57
            local ____ok_60, ____result_60 = __K2L_DeepPcall(function()
                ____value_57 = __K2L_SequenceOf(1, 2, 3):maxOf(function(it)
                    if f and k == 1 then
                        __K2L_Jump(____jump_60, 1)
                    end
                    return it
                end)
            end)
            if not ____ok_60 then
                if ____result_60 == ____jump_60 then
                    goto ____continue_3
                end
                error(____result_60, 0)
            end
            local v = ____value_57
            log = log .. k .. ":" .. show(v) .. ";"
        end
        ::____continue_3::
    end
    return log
end

function Continues1:t_seq_partition(f)
    local log = ""
    for k = 0, 2 do
        do
            local ____jump_61 = __K2L_NewJump()
            local ____value_58
            local ____ok_61, ____result_61 = __K2L_DeepPcall(function()
                ____value_58 = __K2L_SequenceOf(1, 2, 3):partition(function(it)
                    if f and k == 1 then
                        __K2L_Jump(____jump_61, 1)
                    end
                    return it > 1
                end)
            end)
            if not ____ok_61 then
                if ____result_61 == ____jump_61 then
                    goto ____continue_4
                end
                error(____result_61, 0)
            end
            local v = ____value_58
            log = log .. k .. ":" .. show(v) .. ";"
        end
        ::____continue_4::
    end
    return log
end

function Continues1:t_text_trim(f)
    local log = ""
    for k = 0, 2 do
        do
            local ____jump_62 = __K2L_NewJump()
            local ____value_59
            local ____ok_62, ____result_62 = __K2L_DeepPcall(function()
                ____value_59 = __K2L_Text.trimWith("abc", 3, function(it)
                    if f and k == 1 then
                        __K2L_Jump(____jump_62, 1)
                    end
                    return true
                end)
            end)
            if not ____ok_62 then
                if ____result_62 == ____jump_62 then
                    goto ____continue_5
                end
                error(____result_62, 0)
            end
            local v = ____value_59
            log = log .. k .. ":" .. show(v) .. ";"
        end
        ::____continue_5::
    end
    return log
end

function Continues1:t_text_zipWithNext(f)
    local log = ""
    for k = 0, 2 do
        do
            local ____jump_63 = __K2L_NewJump()
            local ____value_60
            local ____ok_63, ____result_63 = __K2L_DeepPcall(function()
                ____value_60 = __K2L_StringToList("abc"):zipWithNext(function(a, b)
                    if f and k == 1 then
                        __K2L_Jump(____jump_63, 1)
                    end
                    return a
                end)
            end)
            if not ____ok_63 then
                if ____result_63 == ____jump_63 then
                    goto ____continue_6
                end
                error(____result_63, 0)
            end
            local v = ____value_60
            log = log .. k .. ":" .. show(v) .. ";"
        end
        ::____continue_6::
    end
    return log
end

function Continues1:t_List_ctor(f)
    local log = ""
    for k = 0, 2 do
        do
            local ____jump_64 = __K2L_NewJump()
            local ____value_61
            local ____ok_64, ____result_64 = __K2L_DeepPcall(function()
                ____value_61 = __K2L_ListOfSize(3, function(it)
                    if f and k == 1 then
                        __K2L_Jump(____jump_64, 1)
                    end
                    return it
                end)
            end)
            if not ____ok_64 then
                if ____result_64 == ____jump_64 then
                    goto ____continue_7
                end
                error(____result_64, 0)
            end
            local v = ____value_61
            log = log .. k .. ":" .. show(v) .. ";"
        end
        ::____continue_7::
    end
    return log
end

function Continues1:t_IntArray_ctor(f)
    local log = ""
    for k = 0, 2 do
        do
            local ____jump_65 = __K2L_NewJump()
            local ____value_62
            local ____ok_65, ____result_65 = __K2L_DeepPcall(function()
                ____value_62 = __K2L_ListOfSize(3, function(it)
                    if f and k == 1 then
                        __K2L_Jump(____jump_65, 1)
                    end
                    return it
                end, "[I")
            end)
            if not ____ok_65 then
                if ____result_65 == ____jump_65 then
                    goto ____continue_8
                end
                error(____result_65, 0)
            end
            local v = ____value_62
            log = log .. k .. ":" .. show(v) .. ";"
        end
        ::____continue_8::
    end
    return log
end

function Continues1:t_result_mapCatching(f)
    local log = ""
    for k = 0, 2 do
        do
            local ____jump_66 = __K2L_NewJump()
            local ____value_63
            local ____ok_66, ____result_66 = __K2L_DeepPcall(function()
                ____value_63 = __K2L_Result.success(1):mapCatching(function(it)
                    if f and k == 1 then
                        __K2L_Jump(____jump_66, 1)
                    end
                    return it
                end)
            end)
            if not ____ok_66 then
                if ____result_66 == ____jump_66 then
                    goto ____continue_9
                end
                error(____result_66, 0)
            end
            local v = ____value_63
            log = log .. k .. ":" .. show(v) .. ";"
        end
        ::____continue_9::
    end
    return log
end

function Continues1:t_result_recoverCatching(f)
    local log = ""
    for k = 0, 2 do
        do
            local ____jump_67 = __K2L_NewJump()
            local ____value_64
            local ____ok_67, ____result_67 = __K2L_DeepPcall(function()
                ____value_64 = __K2L_Result.failure(__K2L_Exception.new()):recoverCatching(function(it)
                    if f and k == 1 then
                        __K2L_Jump(____jump_67, 1)
                    end
                    return 0
                end)
            end)
            if not ____ok_67 then
                if ____result_67 == ____jump_67 then
                    goto ____continue_10
                end
                error(____result_67, 0)
            end
            local v = ____value_64
            log = log .. k .. ":" .. show(v) .. ";"
        end
        ::____continue_10::
    end
    return log
end

function Continues1:t_seq_sumOf(f)
    local log = ""
    for k = 0, 2 do
        do
            local ____jump_68 = __K2L_NewJump()
            local ____value_65
            local ____ok_68, ____result_68 = __K2L_DeepPcall(function()
                ____value_65 = __K2L_SequenceOf(1, 2, 3):sumOf(function(it)
                    if f and k == 1 then
                        __K2L_Jump(____jump_68, 1)
                    end
                    return it
                end)
            end)
            if not ____ok_68 then
                if ____result_68 == ____jump_68 then
                    goto ____continue_11
                end
                error(____result_68, 0)
            end
            local v = ____value_65
            log = log .. k .. ":" .. show(v) .. ";"
        end
        ::____continue_11::
    end
    return log
end

local function main()
    print("Returns1 list_zipWithNext: " .. __K2L_Str(Returns1:t_list_zipWithNext(false)) .. " / " .. __K2L_Str(Returns1:t_list_zipWithNext(true)))
    print("Returns1 seq_all: " .. __K2L_Str(Returns1:t_seq_all(false)) .. " / " .. __K2L_Str(Returns1:t_seq_all(true)))
    print("Returns1 seq_any: " .. __K2L_Str(Returns1:t_seq_any(false)) .. " / " .. __K2L_Str(Returns1:t_seq_any(true)))
    print("Returns1 seq_count: " .. __K2L_Str(Returns1:t_seq_count(false)) .. " / " .. __K2L_Str(Returns1:t_seq_count(true)))
    print("Returns1 seq_find: " .. __K2L_Str(Returns1:t_seq_find(false)) .. " / " .. __K2L_Str(Returns1:t_seq_find(true)))
    print("Returns1 seq_first: " .. __K2L_Str(Returns1:t_seq_first(false)) .. " / " .. __K2L_Str(Returns1:t_seq_first(true)))
    print("Returns1 seq_firstOrNull: " .. __K2L_Str(Returns1:t_seq_firstOrNull(false)) .. " / " .. __K2L_Str(Returns1:t_seq_firstOrNull(true)))
    print("Returns1 seq_forEachIndexed: " .. __K2L_Str(Returns1:t_seq_forEachIndexed(false)) .. " / " .. __K2L_Str(Returns1:t_seq_forEachIndexed(true)))
    print("Returns1 seq_last: " .. __K2L_Str(Returns1:t_seq_last(false)) .. " / " .. __K2L_Str(Returns1:t_seq_last(true)))
    print("Returns1 seq_lastOrNull: " .. __K2L_Str(Returns1:t_seq_lastOrNull(false)) .. " / " .. __K2L_Str(Returns1:t_seq_lastOrNull(true)))
    print("Returns1 seq_none: " .. __K2L_Str(Returns1:t_seq_none(false)) .. " / " .. __K2L_Str(Returns1:t_seq_none(true)))
    print("Returns1 seq_associateBy: " .. __K2L_Str(Returns1:t_seq_associateBy(false)) .. " / " .. __K2L_Str(Returns1:t_seq_associateBy(true)))
    print("Returns1 seq_associate: " .. __K2L_Str(Returns1:t_seq_associate(false)) .. " / " .. __K2L_Str(Returns1:t_seq_associate(true)))
    print("Returns1 seq_associateWith: " .. __K2L_Str(Returns1:t_seq_associateWith(false)) .. " / " .. __K2L_Str(Returns1:t_seq_associateWith(true)))
    print("Returns1 seq_findLast: " .. __K2L_Str(Returns1:t_seq_findLast(false)) .. " / " .. __K2L_Str(Returns1:t_seq_findLast(true)))
    print("Returns1 seq_fold: " .. __K2L_Str(Returns1:t_seq_fold(false)) .. " / " .. __K2L_Str(Returns1:t_seq_fold(true)))
    print("Returns1 seq_foldIndexed: " .. __K2L_Str(Returns1:t_seq_foldIndexed(false)) .. " / " .. __K2L_Str(Returns1:t_seq_foldIndexed(true)))
    print("Returns1 seq_groupBy: " .. __K2L_Str(Returns1:t_seq_groupBy(false)) .. " / " .. __K2L_Str(Returns1:t_seq_groupBy(true)))
    print("Returns1 seq_indexOfFirst: " .. __K2L_Str(Returns1:t_seq_indexOfFirst(false)) .. " / " .. __K2L_Str(Returns1:t_seq_indexOfFirst(true)))
    print("Returns1 seq_maxBy: " .. __K2L_Str(Returns1:t_seq_maxBy(false)) .. " / " .. __K2L_Str(Returns1:t_seq_maxBy(true)))
    print("Returns1 seq_maxByOrNull: " .. __K2L_Str(Returns1:t_seq_maxByOrNull(false)) .. " / " .. __K2L_Str(Returns1:t_seq_maxByOrNull(true)))
    print("Returns1 seq_maxOf: " .. __K2L_Str(Returns1:t_seq_maxOf(false)) .. " / " .. __K2L_Str(Returns1:t_seq_maxOf(true)))
    print("Returns1 seq_maxOfOrNull: " .. __K2L_Str(Returns1:t_seq_maxOfOrNull(false)) .. " / " .. __K2L_Str(Returns1:t_seq_maxOfOrNull(true)))
    print("Returns1 seq_minBy: " .. __K2L_Str(Returns1:t_seq_minBy(false)) .. " / " .. __K2L_Str(Returns1:t_seq_minBy(true)))
    print("Returns1 seq_minByOrNull: " .. __K2L_Str(Returns1:t_seq_minByOrNull(false)) .. " / " .. __K2L_Str(Returns1:t_seq_minByOrNull(true)))
    print("Returns1 seq_minOf: " .. __K2L_Str(Returns1:t_seq_minOf(false)) .. " / " .. __K2L_Str(Returns1:t_seq_minOf(true)))
    print("Returns1 seq_minOfOrNull: " .. __K2L_Str(Returns1:t_seq_minOfOrNull(false)) .. " / " .. __K2L_Str(Returns1:t_seq_minOfOrNull(true)))
    print("Returns1 seq_partition: " .. __K2L_Str(Returns1:t_seq_partition(false)) .. " / " .. __K2L_Str(Returns1:t_seq_partition(true)))
    print("Returns1 seq_reduce: " .. __K2L_Str(Returns1:t_seq_reduce(false)) .. " / " .. __K2L_Str(Returns1:t_seq_reduce(true)))
    print("Returns1 seq_single: " .. __K2L_Str(Returns1:t_seq_single(false)) .. " / " .. __K2L_Str(Returns1:t_seq_single(true)))
    print("Returns2 seq_singleOrNull: " .. __K2L_Str(Returns2:t_seq_singleOrNull(false)) .. " / " .. __K2L_Str(Returns2:t_seq_singleOrNull(true)))
    print("Returns2 seq_sumOf: " .. __K2L_Str(Returns2:t_seq_sumOf(false)) .. " / " .. __K2L_Str(Returns2:t_seq_sumOf(true)))
    print("Returns2 range_zipWithNext: " .. __K2L_Str(Returns2:t_range_zipWithNext(false)) .. " / " .. __K2L_Str(Returns2:t_range_zipWithNext(true)))
    print("Returns2 text_trim: " .. __K2L_Str(Returns2:t_text_trim(false)) .. " / " .. __K2L_Str(Returns2:t_text_trim(true)))
    print("Returns2 text_maxOf: " .. __K2L_Str(Returns2:t_text_maxOf(false)) .. " / " .. __K2L_Str(Returns2:t_text_maxOf(true)))
    print("Returns2 text_partition: " .. __K2L_Str(Returns2:t_text_partition(false)) .. " / " .. __K2L_Str(Returns2:t_text_partition(true)))
    print("Returns2 text_trimEnd: " .. __K2L_Str(Returns2:t_text_trimEnd(false)) .. " / " .. __K2L_Str(Returns2:t_text_trimEnd(true)))
    print("Returns2 text_trimStart: " .. __K2L_Str(Returns2:t_text_trimStart(false)) .. " / " .. __K2L_Str(Returns2:t_text_trimStart(true)))
    print("Returns2 text_zipWithNext: " .. __K2L_Str(Returns2:t_text_zipWithNext(false)) .. " / " .. __K2L_Str(Returns2:t_text_zipWithNext(true)))
    print("Returns2 Array_ctor: " .. __K2L_Str(Returns2:t_Array_ctor(false)) .. " / " .. __K2L_Str(Returns2:t_Array_ctor(true)))
    print("Returns2 IntArray_ctor: " .. __K2L_Str(Returns2:t_IntArray_ctor(false)) .. " / " .. __K2L_Str(Returns2:t_IntArray_ctor(true)))
    print("Returns2 List_ctor: " .. __K2L_Str(Returns2:t_List_ctor(false)) .. " / " .. __K2L_Str(Returns2:t_List_ctor(true)))
    print("Returns2 MutableList_ctor: " .. __K2L_Str(Returns2:t_MutableList_ctor(false)) .. " / " .. __K2L_Str(Returns2:t_MutableList_ctor(true)))
    print("Returns2 result_mapCatching: " .. __K2L_Str(Returns2:t_result_mapCatching(false)) .. " / " .. __K2L_Str(Returns2:t_result_mapCatching(true)))
    print("Returns2 result_recoverCatching: " .. __K2L_Str(Returns2:t_result_recoverCatching(false)) .. " / " .. __K2L_Str(Returns2:t_result_recoverCatching(true)))
    print("Breaks1 seq_any: " .. __K2L_Str(Breaks1:t_seq_any(false)) .. " / " .. __K2L_Str(Breaks1:t_seq_any(true)))
    print("Breaks1 seq_fold: " .. __K2L_Str(Breaks1:t_seq_fold(false)) .. " / " .. __K2L_Str(Breaks1:t_seq_fold(true)))
    print("Breaks1 seq_forEachIndexed: " .. __K2L_Str(Breaks1:t_seq_forEachIndexed(false)) .. " / " .. __K2L_Str(Breaks1:t_seq_forEachIndexed(true)))
    print("Breaks1 seq_maxOf: " .. __K2L_Str(Breaks1:t_seq_maxOf(false)) .. " / " .. __K2L_Str(Breaks1:t_seq_maxOf(true)))
    print("Breaks1 seq_partition: " .. __K2L_Str(Breaks1:t_seq_partition(false)) .. " / " .. __K2L_Str(Breaks1:t_seq_partition(true)))
    print("Breaks1 text_trim: " .. __K2L_Str(Breaks1:t_text_trim(false)) .. " / " .. __K2L_Str(Breaks1:t_text_trim(true)))
    print("Breaks1 text_zipWithNext: " .. __K2L_Str(Breaks1:t_text_zipWithNext(false)) .. " / " .. __K2L_Str(Breaks1:t_text_zipWithNext(true)))
    print("Breaks1 List_ctor: " .. __K2L_Str(Breaks1:t_List_ctor(false)) .. " / " .. __K2L_Str(Breaks1:t_List_ctor(true)))
    print("Breaks1 IntArray_ctor: " .. __K2L_Str(Breaks1:t_IntArray_ctor(false)) .. " / " .. __K2L_Str(Breaks1:t_IntArray_ctor(true)))
    print("Breaks1 result_mapCatching: " .. __K2L_Str(Breaks1:t_result_mapCatching(false)) .. " / " .. __K2L_Str(Breaks1:t_result_mapCatching(true)))
    print("Breaks1 result_recoverCatching: " .. __K2L_Str(Breaks1:t_result_recoverCatching(false)) .. " / " .. __K2L_Str(Breaks1:t_result_recoverCatching(true)))
    print("Breaks1 seq_sumOf: " .. __K2L_Str(Breaks1:t_seq_sumOf(false)) .. " / " .. __K2L_Str(Breaks1:t_seq_sumOf(true)))
    print("Continues1 seq_any: " .. __K2L_Str(Continues1:t_seq_any(false)) .. " / " .. __K2L_Str(Continues1:t_seq_any(true)))
    print("Continues1 seq_fold: " .. __K2L_Str(Continues1:t_seq_fold(false)) .. " / " .. __K2L_Str(Continues1:t_seq_fold(true)))
    print("Continues1 seq_forEachIndexed: " .. __K2L_Str(Continues1:t_seq_forEachIndexed(false)) .. " / " .. __K2L_Str(Continues1:t_seq_forEachIndexed(true)))
    print("Continues1 seq_maxOf: " .. __K2L_Str(Continues1:t_seq_maxOf(false)) .. " / " .. __K2L_Str(Continues1:t_seq_maxOf(true)))
    print("Continues1 seq_partition: " .. __K2L_Str(Continues1:t_seq_partition(false)) .. " / " .. __K2L_Str(Continues1:t_seq_partition(true)))
    print("Continues1 text_trim: " .. __K2L_Str(Continues1:t_text_trim(false)) .. " / " .. __K2L_Str(Continues1:t_text_trim(true)))
    print("Continues1 text_zipWithNext: " .. __K2L_Str(Continues1:t_text_zipWithNext(false)) .. " / " .. __K2L_Str(Continues1:t_text_zipWithNext(true)))
    print("Continues1 List_ctor: " .. __K2L_Str(Continues1:t_List_ctor(false)) .. " / " .. __K2L_Str(Continues1:t_List_ctor(true)))
    print("Continues1 IntArray_ctor: " .. __K2L_Str(Continues1:t_IntArray_ctor(false)) .. " / " .. __K2L_Str(Continues1:t_IntArray_ctor(true)))
    print("Continues1 result_mapCatching: " .. __K2L_Str(Continues1:t_result_mapCatching(false)) .. " / " .. __K2L_Str(Continues1:t_result_mapCatching(true)))
    print("Continues1 result_recoverCatching: " .. __K2L_Str(Continues1:t_result_recoverCatching(false)) .. " / " .. __K2L_Str(Continues1:t_result_recoverCatching(true)))
    print("Continues1 seq_sumOf: " .. __K2L_Str(Continues1:t_seq_sumOf(false)) .. " / " .. __K2L_Str(Continues1:t_seq_sumOf(true)))
end

main()
return {show = show, Returns1 = Returns1, Returns2 = Returns2, Breaks1 = Breaks1, Continues1 = Continues1}
