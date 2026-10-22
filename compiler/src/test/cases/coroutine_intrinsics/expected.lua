local ____lualib = require("lualib_bundle")
local __K2L_COROUTINE_SUSPENDED = ____lualib.__K2L_COROUTINE_SUSPENDED
local __K2L_Continuation = ____lualib.__K2L_Continuation
local __K2L_CreateCoroutineUnintercepted = ____lualib.__K2L_CreateCoroutineUnintercepted
local __K2L_EmptyCoroutineContext = ____lualib.__K2L_EmptyCoroutineContext
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Result = ____lualib.__K2L_Result
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_StartCoroutine = ____lualib.__K2L_StartCoroutine
local __K2L_StartCoroutineUninterceptedOrReturn = ____lualib.__K2L_StartCoroutineUninterceptedOrReturn
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_SuspendCoroutineUninterceptedOrReturn = ____lualib.__K2L_SuspendCoroutineUninterceptedOrReturn
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Unit = ____lualib.__K2L_Unit

local parked = __K2L_ListOf()

local function immediate(x)
    return __K2L_SuspendCoroutineUninterceptedOrReturn(function(it) return x * 2 end)
end

local function park()
    return __K2L_SuspendCoroutineUninterceptedOrReturn(function(cont)
        parked:add(cont)
        return __K2L_COROUTINE_SUSPENDED
    end)
end

local function resumedBeforeSuspend()
    return __K2L_SuspendCoroutineUninterceptedOrReturn(function(cont)
        cont:resumeWith(__K2L_Result.success(41))
        return __K2L_COROUTINE_SUSPENDED
    end)
end

local function failing()
    return __K2L_SuspendCoroutineUninterceptedOrReturn(function(cont)
        parked:add(cont)
        return __K2L_COROUTINE_SUSPENDED
    end)
end

local function run(block)
    __K2L_StartCoroutine(function(...)
        block(...)
        return __K2L_Unit
    end, __K2L_Continuation.new(__K2L_EmptyCoroutineContext, function(it)
        local ____receiver = it:exceptionOrNull()
        if ____receiver ~= nil then
            print("failed: " .. __K2L_Str(____receiver.message))
        end
    end))
end

local function nested()
    return __K2L_SuspendCoroutineUninterceptedOrReturn(function(cont)
        local block = function()
            local a = park()
            return a + 1
        end
        return __K2L_StartCoroutineUninterceptedOrReturn(block, cont)
    end)
end

local ____lambda_1 = function() return immediate(5) + 1 end
local function nestedSync()
    return __K2L_SuspendCoroutineUninterceptedOrReturn(function(cont)
        local block = ____lambda_1
        return __K2L_StartCoroutineUninterceptedOrReturn(block, cont)
    end)
end

local function main()
    run(function()
        print("immediate " .. immediate(21))
        print("resumedBeforeSuspend " .. resumedBeforeSuspend())
        print("park " .. park())
        print("nestedSync " .. nestedSync())
        print("nested " .. nested())
        local ____ok, ____result = pcall(function()
            failing()
        end)
        if not ____ok then
            local ____error = __K2L_ToThrowable(____result)
            if __K2L_InstanceOf(____error, __K2L_IllegalStateException) then
                local e = ____error
                print("caught " .. __K2L_Str(e.message))
            else
                error(____error, 0)
            end
        end
        print("end")
    end)
    print("parked " .. parked.size)
    parked:removeAt(0):resumeWith(__K2L_Result.success(7))
    print("parked " .. parked.size)
    parked:removeAt(0):resumeWith(__K2L_Result.success(99))
    print("parked " .. parked.size)
    parked:removeAt(0):resumeWith(__K2L_Result.failure(__K2L_IllegalStateException.new("boom")))
    local created = __K2L_CreateCoroutineUnintercepted(function()
        print("unintercepted body")
        return __K2L_Unit
    end, __K2L_Continuation.new(__K2L_EmptyCoroutineContext, function(it)
        print("done " .. tostring(it:isSuccess()))
    end))
    print("created")
    created:resumeWith(__K2L_Result.success(__K2L_Unit))
end

__K2L_RunMain(main)
return {parked = parked, immediate = immediate, park = park, resumedBeforeSuspend = resumedBeforeSuspend, failing = failing, run = run, nested = nested, nestedSync = nestedSync}
