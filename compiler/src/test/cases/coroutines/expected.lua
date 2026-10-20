local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Continuation = ____lualib.__K2L_Continuation
local __K2L_CoroutineContext = ____lualib.__K2L_CoroutineContext
local __K2L_CreateCoroutine = ____lualib.__K2L_CreateCoroutine
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_EmptyCoroutineContext = ____lualib.__K2L_EmptyCoroutineContext
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Result = ____lualib.__K2L_Result
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_StartCoroutine = ____lualib.__K2L_StartCoroutine
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_SuspendCoroutine = ____lualib.__K2L_SuspendCoroutine
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Unit = ____lualib.__K2L_Unit

local ____exports = {}
local sumOfImmediates, nested
____exports.parked = nil

local function awaitValue(label)
    print("  " .. label .. ": suspending")
    local value = __K2L_SuspendCoroutine(function(cont)
        ____exports.parked = cont
    end)
    print("  " .. label .. ": resumed with " .. value)
    return value
end

local function immediate(x)
    return __K2L_SuspendCoroutine(function(cont)
        cont:resumeWith(__K2L_Result.success(x * 2))
    end)
end

local function failLater()
    return __K2L_SuspendCoroutine(function(cont)
        cont:resumeWith(__K2L_Result.failure(__K2L_IllegalStateException.new("async failure")))
    end)
end

local function sum()
    local a = awaitValue("a")
    local b = immediate(a)
    return a + b
end

local Printer = __K2L_Class("Printer")

function Printer:____init(name)
    self.name = name
    self.context = __K2L_EmptyCoroutineContext
end

function Printer:resumeWith(result)
    print(self.name .. " completed: " .. __K2L_Str(result))
end

local function completion(name)
    return __K2L_Continuation.new(__K2L_EmptyCoroutineContext, function(result)
        result:fold(function(it)
            print(name .. " -> success " .. __K2L_Str(it))
            return __K2L_Unit
        end, function(it)
            print(name .. " -> failure " .. __K2L_Str(it.message))
            return __K2L_Unit
        end)
    end)
end

local ____lambda_1 = function()
    return true, failLater()
end
local function recovering()
    local ____ok, ____result, ____returned = __K2L_DeepPcall(____lambda_1)
    if not ____ok then
        ____ok, ____result, ____returned = __K2L_DeepPcall(function()
            local ____error = __K2L_ToThrowable(____result)
            if __K2L_InstanceOf(____error, __K2L_IllegalStateException) then
                local e = ____error
                return true, "recovered from " .. __K2L_Str(e.message)
            else
                error(____error, 0)
            end
        end)
    end
    print("  finally in recovering")
    if not ____ok then
        error(____result, 0)
    end
    if ____result then
        return ____returned
    end
end

local Counter = __K2L_Class("Counter")

function Counter:____init()
    self.count = 0
end

function Counter:tick()
    local ____dividend = immediate(1)
    self.count = self.count + (____dividend >= 0 and ____dividend // 2 or 0 - -____dividend // 2)
    return self.count
end

local function loopAndWhen(n)
    local out = __K2L_ListOf()
    for i = 1, n do
        local doubled = immediate(i)
        local ____temp
        if (doubled >= 0 and doubled % 4 or 0 - -doubled % 4) == 0 then
            ____temp = "four:" .. doubled
        else
            ____temp = "other:" .. doubled
        end
        out:add(____temp)
    end
    local ____list = __K2L_ReadOnlyListOf(10, 20)
    local ____mod = ____list.____modCount
    for ____i = 1, ____list.size do
        local it = ____list[____i]
        out:add("each:" .. immediate(it))
        if ____list.____modCount ~= ____mod and ____list:____comodified(____i) then
            break
        end
    end
    return out
end

local ____lambda_2 = function() return sum() end
local ____lambda_3 = function() return failLater() end
local ____lambda_4 = function() return recovering() end
local ____lambda_5 = function() return awaitValue("rejected") end
local ____lambda_6 = function(self) return self:tick() + self:tick() end
local ____lambda_7 = function() return loopAndWhen(3) end
local ____lambda_8 = function() return __K2L_Str(__K2L_EmptyCoroutineContext) end
local ____lambda_9 = function(it) return -1 end
local ____lambda_10 = function(it) return it * 10 end
local ____lambda_11 = function(it) return 7 end
local ____lambda_12 = function() return #"fine" end
local function main()
    print("-- start and resume")
    local block = ____lambda_2
    __K2L_StartCoroutine(block, Printer.new("sum"))
    print("main: coroutine is parked")
    local cont = __K2L_NotNull(____exports.parked)
    ____exports.parked = nil
    cont:resumeWith(__K2L_Result.success(5))
    print("main: after resume")
    print("-- resume twice")
    local ____ok_1, ____result_1 = __K2L_DeepPcall(function()
        cont:resumeWith(__K2L_Result.success(6))
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error_1, __K2L_IllegalStateException) then
            local e = ____error_1
            print("caught: " .. __K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
    print("-- exceptions")
    __K2L_StartCoroutine(____lambda_3, completion("failLater"))
    __K2L_StartCoroutine(____lambda_4, completion("recovering"))
    __K2L_StartCoroutine(function()
        awaitValue("thrower")
        error(__K2L_IllegalArgumentException.new("thrown after resume"))
    end, completion("thrower"))
    __K2L_NotNull(____exports.parked):resumeWith(__K2L_Result.success(1))
    __K2L_StartCoroutine(____lambda_5, completion("rejected"))
    __K2L_NotNull(____exports.parked):resumeWith(__K2L_Result.failure(__K2L_RuntimeException.new("rejected by main")))
    print("-- createCoroutine")
    local created = __K2L_CreateCoroutine(function()
        print("  created coroutine runs")
        return 42
    end, completion("created"))
    print("not started yet")
    created:resumeWith(__K2L_Result.success(__K2L_Unit))
    local ____ok_2, ____result_2 = __K2L_DeepPcall(function()
        created:resumeWith(__K2L_Result.success(__K2L_Unit))
    end)
    if not ____ok_2 then
        local ____error_2 = __K2L_ToThrowable(____result_2)
        if __K2L_InstanceOf(____error_2, __K2L_IllegalStateException) then
            local e = ____error_2
            print("caught: " .. __K2L_Str(e.message))
        else
            error(____error_2, 0)
        end
    end
    print("-- receivers, members and loops")
    local counter = Counter.new()
    local withReceiver = ____lambda_6
    __K2L_StartCoroutine(withReceiver, completion("receiver"), counter)
    print("count = " .. counter.count)
    __K2L_StartCoroutine(____lambda_7, completion("loops"))
    __K2L_StartCoroutine(____lambda_8, completion("context"))
    __K2L_StartCoroutine(sumOfImmediates, completion("reference"))
    nested()
    print("-- Result")
    local ok = __K2L_Result.success(3)
    local bad = __K2L_Result.failure(__K2L_IllegalStateException.new("nope"))
    print(__K2L_Str(ok) .. " " .. __K2L_Str(bad))
    print(tostring(ok:isSuccess()) .. " " .. tostring(ok:isFailure()) .. " " .. tostring(bad:isSuccess()) .. " " .. tostring(bad:isFailure()))
    local ____arg = __K2L_Str(ok:getOrNull())
    local ____arg_1 = __K2L_Str(bad:getOrNull())
    local ____receiver = bad:exceptionOrNull()
    print(____arg .. " " .. ____arg_1 .. " " .. __K2L_Str(____receiver and ____receiver.message))
    print(ok:getOrDefault(0) .. " " .. bad:getOrDefault(0) .. " " .. bad:getOrElse(____lambda_9))
    print(__K2L_Str(ok:map(____lambda_10)))
    print(bad:recover(____lambda_11):getOrThrow())
    ok:onSuccess(function(it)
        print("onSuccess " .. it)
    end):onFailure(function(it)
        print("not called")
    end)
    bad:onFailure(function(it)
        print("onFailure " .. __K2L_Str(it.message))
    end)
    print(__K2L_Str(__K2L_RunCatching(____lambda_12)))
    print(__K2L_Str(__K2L_RunCatching(function()
        error(__K2L_IllegalStateException.new("broken"))
    end):exceptionOrNull()))
    print(__K2L_Equals(ok, __K2L_Result.success(3)))
    local ____ok_3, ____result_3 = __K2L_DeepPcall(function()
        bad:getOrThrow()
    end)
    if not ____ok_3 then
        local ____error_3 = __K2L_ToThrowable(____result_3)
        if __K2L_InstanceOf(____error_3, __K2L_IllegalStateException) then
            local e = ____error_3
            print("getOrThrow threw " .. __K2L_Str(e.message))
        else
            error(____error_3, 0)
        end
    end
end

function sumOfImmediates()
    return immediate(1) + immediate(2)
end

local function twice(f)
    return f(1) + f(2)
end

local function shout(____this)
    return tostring(immediate(#____this)) .. "!"
end

local Source = __K2L_Class("Source")
local Parked = __K2L_Class("Parked", nil, Source)

function Parked:____init()
    self.waiting = nil
end

function Parked:next()
    return __K2L_SuspendCoroutine(function(it)
        self.waiting = it
    end)
end

local ____lambda_13 = function(it) return immediate(it) + 1 end
local ____lambda_14 = function() return twice(____lambda_13) end
local ____lambda_15 = function() return shout("hey") end
local ____lambda_16 = function() return __K2L_Str(__K2L_CoroutineContext()) end
function nested()
    print("-- nested coroutines")
    local source = Parked.new()
    __K2L_StartCoroutine(function()
        print("  outer: starting inner")
        __K2L_StartCoroutine(function()
            print("  inner: waiting")
            local v = source:next()
            print("  inner: got " .. v)
            return v * 100
        end, completion("inner"))
        print("  outer: inner is parked, resuming it from here")
        __K2L_NotNull(source.waiting):resumeWith(__K2L_Result.success(immediate(3)))
        print("  outer: back")
        return "outer done"
    end, completion("outer"))
    __K2L_StartCoroutine(____lambda_14, completion("twice"))
    __K2L_StartCoroutine(____lambda_15, completion("extension"))
    __K2L_StartCoroutine(____lambda_16, completion("coroutineContext"))
    local caught = Parked.new()
    __K2L_StartCoroutine(function()
        local r = __K2L_RunCatching(function()
            print("  runCatching: waiting")
            return caught:next()
        end)
        print("  runCatching: " .. __K2L_Str(r))
        return r:getOrThrow()
    end, completion("runCatching"))
    __K2L_NotNull(caught.waiting):resumeWith(__K2L_Result.failure(__K2L_IllegalArgumentException.new("late failure")))
end

____exports.awaitValue = awaitValue
____exports.immediate = immediate
____exports.failLater = failLater
____exports.sum = sum
____exports.Printer = Printer
____exports.completion = completion
____exports.recovering = recovering
____exports.Counter = Counter
____exports.loopAndWhen = loopAndWhen
____exports.sumOfImmediates = sumOfImmediates
____exports.twice = twice
____exports.shout = shout
____exports.Source = Source
____exports.Parked = Parked
____exports.nested = nested
__K2L_DeepMain(main)
return ____exports
