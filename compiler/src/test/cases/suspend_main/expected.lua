local ____lualib = require("lualib_bundle")
local __K2L_Continuation = ____lualib.__K2L_Continuation
local __K2L_EmptyCoroutineContext = ____lualib.__K2L_EmptyCoroutineContext
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Result = ____lualib.__K2L_Result
local __K2L_RunSuspend = ____lualib.__K2L_RunSuspend
local __K2L_StartCoroutine = ____lualib.__K2L_StartCoroutine
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_SuspendCoroutine = ____lualib.__K2L_SuspendCoroutine
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function double(x)
    return __K2L_SuspendCoroutine(function(it)
        it:resumeWith(__K2L_Result.success(x * 2))
    end)
end

local pending = __K2L_ListOf()

local function request(name)
    return __K2L_SuspendCoroutine(function(it)
        pending:add(it)
    end)
end

local function main()
    print("main runs as a coroutine: " .. double(21))
    local results = __K2L_ListOf()
    for _, name in ipairs(__K2L_ReadOnlyListOf("a", "b")) do
        __K2L_StartCoroutine(function() return results:add(request(name)) end, __K2L_Continuation.new(__K2L_EmptyCoroutineContext, function(it) end))
    end
    print("pending " .. pending.size)
    local ____list = pending
    for i = 0, ____list.size - 1 do
        local cont = ____list[i + 1]
        cont:resumeWith(__K2L_Result.success("reply" .. i))
    end
    print(__K2L_Str(results))
    local ____ok, ____result = pcall(function()
        local ____value = double(1)
        if ____value ~= 3 then
            error(__K2L_IllegalStateException.new("two is not three"))
        end
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
end

__K2L_RunSuspend(main)
return {double = double, pending = pending, request = request}
