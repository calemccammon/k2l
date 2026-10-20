local ____lualib = require("lualib_bundle")
local __K2L_ArithmeticException = ____lualib.__K2L_ArithmeticException
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_IndexOutOfBoundsException = ____lualib.__K2L_IndexOutOfBoundsException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_Lazy = ____lualib.__K2L_Lazy
local __K2L_ListBuilderOf = ____lualib.__K2L_ListBuilderOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MapBuilderOf = ____lualib.__K2L_MapBuilderOf
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_NotImplementedError = ____lualib.__K2L_NotImplementedError
local __K2L_NumberFormatException = ____lualib.__K2L_NumberFormatException
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_Result = ____lualib.__K2L_Result
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_SetBuilderOf = ____lualib.__K2L_SetBuilderOf
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Triple = ____lualib.__K2L_Triple

local function ____pairs()
    local p = __K2L_Pair.new(1, "a")
    print(__K2L_Str(p))
    print(__K2L_Str(p:copy(2)))
    print(__K2L_Str(__K2L_ListOf(p.first, p.second)))
    local n, s = p.first, p.second
    print(n .. s)
    print(__K2L_Equals(__K2L_Pair.new(1, 2), __K2L_Pair.new(1, 2)))
    local t = __K2L_Triple.new(1, "b", 2.5)
    print(__K2L_Str(t))
    print(__K2L_Str(t.third))
    print(__K2L_Str(t:copy(nil, "z")))
    print(__K2L_Str(__K2L_ListOf(t.first, t.second, t.third)))
    print(__K2L_Str(__K2L_ReadOnlyListOf(__K2L_Pair.new(1, "x"), __K2L_Pair.new(2, "y")):toMap()))
    local ____list = __K2L_ReadOnlyListOf(__K2L_Pair.new(1, "x"), __K2L_Pair.new(2, "y"))
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = it.second
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    print(__K2L_Pair.new(__K2L_Pair.new(1, 2), 3).first.second)
    print(__K2L_Pair.new(1, 2):hashCode() == __K2L_Pair.new(1, 2):hashCode())
    print(__K2L_Str(__K2L_SingletonMapOf(__K2L_Pair.new(__K2L_Pair.new(1, 2), "v")):get(__K2L_Pair.new(1, 2))))
end

local function checks()
    local ____ok, ____result = pcall(function()
        if true then
            error(__K2L_IllegalArgumentException.new("bad arg"))
        end
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
    local ____ok_1, ____result_1 = pcall(function()
        if not (1 > 2) then
            error(__K2L_IllegalArgumentException.new("Failed requirement."))
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
    local ____ok_2, ____result_2 = pcall(function()
        if true then
            error(__K2L_IllegalStateException.new("bad state"))
        end
    end)
    if not ____ok_2 then
        local ____error_2 = __K2L_ToThrowable(____result_2)
        if __K2L_InstanceOf(____error_2, __K2L_IllegalStateException) then
            local e = ____error_2
            print(__K2L_Str(e.message))
        else
            error(____error_2, 0)
        end
    end
    local ____ok_3, ____result_3 = pcall(function()
        if not (1 > 2) then
            error(__K2L_IllegalStateException.new("Check failed."))
        end
    end)
    if not ____ok_3 then
        local ____error_3 = __K2L_ToThrowable(____result_3)
        if __K2L_InstanceOf(____error_3, __K2L_IllegalStateException) then
            local e = ____error_3
            print(__K2L_Str(e.message))
        else
            error(____error_3, 0)
        end
    end
    local ____ok_4, ____result_4 = pcall(function()
        if nil == nil then
            error(__K2L_IllegalArgumentException.new("was null"))
        end
    end)
    if not ____ok_4 then
        local ____error_4 = __K2L_ToThrowable(____result_4)
        if __K2L_InstanceOf(____error_4, __K2L_IllegalArgumentException) then
            local e = ____error_4
            print(__K2L_Str(e.message))
        else
            error(____error_4, 0)
        end
    end
    local ____ok_5, ____result_5 = pcall(function()
        if nil == nil then
            error(__K2L_IllegalStateException.new("Required value was null."))
        end
    end)
    if not ____ok_5 then
        local ____error_5 = __K2L_ToThrowable(____result_5)
        if __K2L_InstanceOf(____error_5, __K2L_IllegalStateException) then
            local e = ____error_5
            print(__K2L_Str(e.message))
        else
            error(____error_5, 0)
        end
    end
    local ____ok_6, ____result_6 = pcall(function()
        error(__K2L_IllegalStateException.new("boom"))
    end)
    if not ____ok_6 then
        local ____error_6 = __K2L_ToThrowable(____result_6)
        if __K2L_InstanceOf(____error_6, __K2L_IllegalStateException) then
            local e = ____error_6
            print(__K2L_Str(e.message))
        else
            error(____error_6, 0)
        end
    end
    local ____ok_7, ____result_7 = pcall(function()
        error(__K2L_NotImplementedError.new("An operation is not implemented."))
    end)
    if not ____ok_7 then
        local ____error_7 = __K2L_ToThrowable(____result_7)
        if __K2L_InstanceOf(____error_7, __K2L_NotImplementedError) then
            local e = ____error_7
            print(__K2L_Str(e.message))
        else
            error(____error_7, 0)
        end
    end
    if "ok" == nil then
        error(__K2L_IllegalArgumentException.new("Required value was null."))
    end
    print("ok")
    if 5 == nil then
        error(__K2L_IllegalStateException.new("Required value was null."))
    end
    print(5)
end

local function errors()
    local ____ok_8, ____result_8 = pcall(function()
        local ____list_1 = __K2L_SingletonListOf(1)
        local ____result_9
        local ____found = false
        local ____items_1, ____n_1 = ____list_1:____array()
        for ____i_1 = 1, ____n_1 do
            local it = ____items_1[____i_1]
            if it > 5 then
                ____result_9 = it
                ____found = true
                break
            end
        end
        if not ____found then
            error(__K2L_NoSuchElementException.new("Collection contains no element matching the predicate."))
        end
    end)
    if not ____ok_8 then
        local ____error_8 = __K2L_ToThrowable(____result_8)
        if __K2L_InstanceOf(____error_8, __K2L_NoSuchElementException) then
            local e = ____error_8
            print(__K2L_Str(e.message))
        else
            error(____error_8, 0)
        end
    end
    local ____ok_9, ____result_10 = pcall(function()
        __K2L_ReadOnlyListOf():first()
    end)
    if not ____ok_9 then
        local ____error_9 = __K2L_ToThrowable(____result_10)
        if __K2L_InstanceOf(____error_9, __K2L_NoSuchElementException) then
            local e = ____error_9
            print(__K2L_Str(e))
        else
            error(____error_9, 0)
        end
    end
    local ____ok_10, ____result_11 = pcall(function()
        __K2L_ReadOnlyListOf():max()
    end)
    if not ____ok_10 then
        local ____error_10 = __K2L_ToThrowable(____result_11)
        if __K2L_InstanceOf(____error_10, __K2L_NoSuchElementException) then
            local e = ____error_10
            print(__K2L_Str(e))
        else
            error(____error_10, 0)
        end
    end
    local ____ok_11, ____result_12 = pcall(function()
        __K2L_ReadOnlyListOf(1, 2):single()
    end)
    if not ____ok_11 then
        local ____error_11 = __K2L_ToThrowable(____result_12)
        if __K2L_InstanceOf(____error_11, __K2L_IllegalArgumentException) then
            local e = ____error_11
            print(__K2L_Str(e.message))
        else
            error(____error_11, 0)
        end
    end
    local ____ok_12, ____result_13 = pcall(function()
        __K2L_SingletonMapOf(__K2L_Pair.new("a", 1)):getValue("b")
    end)
    if not ____ok_12 then
        local ____error_12 = __K2L_ToThrowable(____result_13)
        if __K2L_InstanceOf(____error_12, __K2L_NoSuchElementException) then
            local e = ____error_12
            print(__K2L_Str(e.message))
        else
            error(____error_12, 0)
        end
    end
    local ____ok_13, ____result_14 = pcall(function()
        __K2L_SingletonListOf(1):get(5)
    end)
    if not ____ok_13 then
        local ____error_13 = __K2L_ToThrowable(____result_14)
        if __K2L_InstanceOf(____error_13, __K2L_IndexOutOfBoundsException) then
            local e = ____error_13
            print("ioobe")
        else
            error(____error_13, 0)
        end
    end
    local ____ok_14, ____result_15 = pcall(function()
        __K2L_StringToInt("abc")
    end)
    if not ____ok_14 then
        local ____error_14 = __K2L_ToThrowable(____result_15)
        if __K2L_InstanceOf(____error_14, __K2L_NumberFormatException) then
            local e = ____error_14
            print(__K2L_Str(e))
        else
            error(____error_14, 0)
        end
    end
    local ____ok_15, ____result_16 = pcall(function()
        print(__K2L_IDiv(1, __K2L_SingletonListOf(0):get(0)))
    end)
    if not ____ok_15 then
        local ____error_15 = __K2L_ToThrowable(____result_16)
        if __K2L_InstanceOf(____error_15, __K2L_ArithmeticException) then
            local e = ____error_15
            print(__K2L_Str(e))
        else
            error(____error_15, 0)
        end
    end
    local ____ok_16, ____result_17 = pcall(function()
        __K2L_ReadOnlyListOf(1, 2, 3):chunked(0)
    end)
    if not ____ok_16 then
        local ____error_16 = __K2L_ToThrowable(____result_17)
        if __K2L_InstanceOf(____error_16, __K2L_IllegalArgumentException) then
            local e = ____error_16
            print(__K2L_Str(e.message))
        else
            error(____error_16, 0)
        end
    end
    local ____ok_17, ____result_18 = pcall(function()
        __K2L_SingletonListOf(1):take(-1)
    end)
    if not ____ok_17 then
        local ____error_17 = __K2L_ToThrowable(____result_18)
        if __K2L_InstanceOf(____error_17, __K2L_IllegalArgumentException) then
            local e = ____error_17
            print(__K2L_Str(e.message))
        else
            error(____error_17, 0)
        end
    end
end

local ____lambda_1 = function() return 1 end
local ____lambda_2 = function() return __K2L_StringToInt("12") end
local ____lambda_3 = function(it) return it * 2 end
local ____lambda_4 = function() return __K2L_StringToInt("zz") end
local ____lambda_5 = function() return __K2L_StringToInt("zz") end
local ____lambda_6 = function(it) return 0 end
local ____lambda_7 = function() return 5 end
local ____lambda_8 = function(it) return "ok " .. it end
local ____lambda_9 = function(it) return "err" end
local function results()
    print(__K2L_Str(__K2L_RunCatching(____lambda_1):getOrNull()))
    local ____receiver = __K2L_RunCatching(function()
        error(__K2L_IllegalStateException.new("x"))
    end):exceptionOrNull()
    print(__K2L_Str(____receiver and ____receiver.message))
    print(__K2L_RunCatching(____lambda_2):map(____lambda_3):getOrDefault(0))
    print(__K2L_RunCatching(____lambda_4):getOrDefault(-1))
    print(__K2L_RunCatching(____lambda_5):recover(____lambda_6):getOrThrow())
    print(__K2L_RunCatching(____lambda_7):fold(____lambda_8, ____lambda_9))
    print(__K2L_Result.success(3):isSuccess())
    print(__K2L_Result.failure(__K2L_RuntimeException.new("f")):isFailure())
end

local ____lambda_10 = function(it) return it * it end
local ____lambda_11 = function(it) return "x" .. it end
local ____lambda_12 = function(it) return it + 1 end
local ____lambda_13 = function() return 5 end
local function scope()
    local s = "abc"
    print(#s)
    print("also " .. s)
    print(s)
    print(#s)
    print(s:upper())
    print(__K2L_Str(#s > 5 and s or nil))
    print(__K2L_Str(not (#s > 5) and s or nil))
    local ____builder = __K2L_ListBuilderOf()
    ____builder:add(1)
    ____builder:add(2)
    print(__K2L_Str(____builder:____build()))
    local ____builder_1 = __K2L_MapBuilderOf()
    ____builder_1:put("a", 1)
    print(__K2L_Str(____builder_1:____build()))
    local ____builder_2 = __K2L_SetBuilderOf()
    ____builder_2:add(1)
    ____builder_2:add(1)
    print(__K2L_Str(____builder_2:____build()))
    print(__K2L_Str(__K2L_ListOfSize(3, ____lambda_10)))
    print(__K2L_Str(__K2L_ListOfSize(2, ____lambda_11)))
    print(__K2L_Str(__K2L_ListOfSize(3, ____lambda_12, "[I"):toList()))
    print(__K2L_Str(__K2L_ListOf(1, nil, 2):filterNotNull()))
    print(__K2L_Str(__K2L_ReadOnlyMapOf()))
    print(__K2L_Str(__K2L_ReadOnlySetOf(3, 1, 2):sorted()))
    local ____value = __K2L_ListOf(1, 2)
    ____value:add(3)
    print(__K2L_Str(____value))
    local ____value_1 = __K2L_SetOf(1)
    ____value_1:addAll(__K2L_ReadOnlyListOf(2, 3))
    print(__K2L_Str(____value_1))
    print(__K2L_Lazy(____lambda_13):getValue())
end

local function main()
    ____pairs()
    checks()
    errors()
    results()
    scope()
end

main()
return {____pairs = ____pairs, checks = checks, errors = errors, results = results, scope = scope}
