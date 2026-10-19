local ____lualib = require("lualib_bundle")
local __K2L_AbstractCoroutineContextElement = ____lualib.__K2L_AbstractCoroutineContextElement
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ContextFold = ____lualib.__K2L_ContextFold
local __K2L_ContextGet = ____lualib.__K2L_ContextGet
local __K2L_ContextMinusKey = ____lualib.__K2L_ContextMinusKey
local __K2L_ContextPlus = ____lualib.__K2L_ContextPlus
local __K2L_Continuation = ____lualib.__K2L_Continuation
local __K2L_ContinuationInterceptor = ____lualib.__K2L_ContinuationInterceptor
local __K2L_CoroutineContext = ____lualib.__K2L_CoroutineContext
local __K2L_CreateCoroutine = ____lualib.__K2L_CreateCoroutine
local __K2L_EmptyCoroutineContext = ____lualib.__K2L_EmptyCoroutineContext
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Result = ____lualib.__K2L_Result
local __K2L_StartCoroutine = ____lualib.__K2L_StartCoroutine
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_SuspendCoroutine = ____lualib.__K2L_SuspendCoroutine
local __K2L_Unit = ____lualib.__K2L_Unit

local DispatchedContinuation
local CoroutineName = __K2L_Class("CoroutineName", __K2L_AbstractCoroutineContextElement)

function CoroutineName:____init(name)
    __K2L_AbstractCoroutineContextElement.____init(self, CoroutineName)
    self.name = name
end

function CoroutineName:toString()
    return "CoroutineName(" .. self.name .. ")"
end

local UserId = __K2L_Class("UserId")

function UserId:____init(id)
    self.id = id
    self.key = UserId
end

local QueueDispatcher = __K2L_Class("QueueDispatcher", __K2L_AbstractCoroutineContextElement)

function QueueDispatcher:____init()
    __K2L_AbstractCoroutineContextElement.____init(self, __K2L_ContinuationInterceptor)
    self.queue = __K2L_ArrayDeque.new()
    self.dispatched = 0
end

function QueueDispatcher:interceptContinuation(continuation)
    return DispatchedContinuation.new(self, continuation)
end

function QueueDispatcher:runAll()
    while self.queue:isNotEmpty() do
        self.queue:removeFirst()()
    end
end

DispatchedContinuation = __K2L_Class("DispatchedContinuation")

function DispatchedContinuation:____init(dispatcher, delegate)
    self.dispatcher = dispatcher
    self.delegate = delegate
    self.context = self.delegate.context
end

function DispatchedContinuation:resumeWith(result)
    local ____object = self.dispatcher
    ____object.dispatched = ____object.dispatched + 1
    self.dispatcher.queue:add(function()
        self.delegate:resumeWith(result)
    end)
end

local waiting = __K2L_ListOf()

local function park()
    __K2L_SuspendCoroutine(function(it)
        waiting:add(it)
    end)
end

local function nameNow()
    local ____receiver = __K2L_ContextGet(__K2L_CoroutineContext(), CoroutineName)
    return ____receiver and ____receiver.name or "<none>"
end

local function worker(label, steps)
    for i = 1, steps do
        local ____arg = nameNow()
        local ____receiver_1 = __K2L_ContextGet(__K2L_CoroutineContext(), UserId)
        print(label .. " step " .. i .. " in " .. ____arg .. " user=" .. __K2L_Str(____receiver_1 and ____receiver_1.id))
        park()
    end
    print(label .. " done")
end

local function launch(context, block)
    __K2L_StartCoroutine(function(...)
        block(...)
        return __K2L_Unit
    end, __K2L_Continuation.new(context, function(result)
        local ____receiver_2 = result:exceptionOrNull()
        if ____receiver_2 ~= nil then
            print("failed: " .. __K2L_Str(____receiver_2.message))
        end
    end))
end

local function main()
    local dispatcher = QueueDispatcher.new()
    launch(__K2L_ContextPlus(__K2L_ContextPlus(dispatcher, CoroutineName.new("alpha")), UserId.new(1)), function()
        worker("A", 2)
    end)
    launch(__K2L_ContextPlus(CoroutineName.new("beta"), dispatcher), function()
        worker("B", 1)
    end)
    print("launched, queue=" .. dispatcher.queue.size)
    dispatcher:runAll()
    print("after first run, waiting=" .. waiting.size)
    while waiting:isNotEmpty() do
        local ____next = waiting:toList()
        waiting:clear()
        local ____mod = ____next.____modCount
        for ____i = 1, ____next.size do
            local it = ____next[____i]
            it:resumeWith(__K2L_Result.success(__K2L_Unit))
            if ____next.____modCount ~= ____mod and ____next:____comodified(____i) then
                break
            end
        end
        dispatcher:runAll()
    end
    print("dispatched=" .. dispatcher.dispatched)
    local ctx = __K2L_ContextPlus(CoroutineName.new("n"), UserId.new(7))
    local ____receiver_3 = __K2L_ContextGet(ctx, CoroutineName)
    print(__K2L_Str(____receiver_3 and ____receiver_3.name))
    local ____receiver_4 = __K2L_ContextGet(ctx, UserId)
    print(__K2L_Str(____receiver_4 and ____receiver_4.id))
    print(__K2L_ContextGet(ctx, __K2L_ContinuationInterceptor) == nil)
    print(__K2L_ContextGet(__K2L_ContextMinusKey(ctx, CoroutineName), CoroutineName) == nil)
    local ____receiver_5 = __K2L_ContextGet(__K2L_ContextMinusKey(ctx, CoroutineName), UserId)
    print(__K2L_Str(____receiver_5 and ____receiver_5.id))
    local ____receiver_6 = __K2L_ContextGet(__K2L_ContextPlus(ctx, CoroutineName.new("m")), CoroutineName)
    print(__K2L_Str(____receiver_6 and ____receiver_6.name))
    print(__K2L_ContextFold(ctx, 0, function(acc, element)
        return acc + (__K2L_InstanceOf(element, UserId) and element.id or 100)
    end))
    local ____receiver_7 = __K2L_ContextGet(__K2L_ContextPlus(__K2L_EmptyCoroutineContext, ctx), UserId)
    print(__K2L_Str(____receiver_7 and ____receiver_7.id))
    local ____receiver_8 = __K2L_ContextGet(__K2L_ContextPlus(ctx, __K2L_EmptyCoroutineContext), CoroutineName)
    print(__K2L_Str(____receiver_8 and ____receiver_8.name))
    print(__K2L_Equals(CoroutineName.new("x").key, CoroutineName))
    print(__K2L_ContextMinusKey(__K2L_ContextMinusKey(ctx, CoroutineName), UserId) == __K2L_EmptyCoroutineContext)
    local withDispatcher = __K2L_ContextPlus(dispatcher, ctx)
    print(__K2L_ContextGet(withDispatcher, __K2L_ContinuationInterceptor) == dispatcher)
    print(__K2L_ContextFold(withDispatcher, "", function(acc, element)
        return acc .. tostring(__K2L_InstanceOf(element, QueueDispatcher))
    end))
    local finished = false
    local creator = QueueDispatcher.new()
    local cont = __K2L_CreateCoroutine(function()
        print("created body in " .. nameNow())
        return __K2L_Unit
    end, __K2L_Continuation.new(__K2L_ContextPlus(creator, CoroutineName.new("created")), function(it)
        finished = true
    end))
    cont:resumeWith(__K2L_Result.success(__K2L_Unit))
    print("queued=" .. creator.queue.size .. " finished=" .. tostring(finished))
    creator:runAll()
    print("finished=" .. tostring(finished))
end

main()
return {CoroutineName = CoroutineName, UserId = UserId, QueueDispatcher = QueueDispatcher, DispatchedContinuation = DispatchedContinuation, waiting = waiting, park = park, nameNow = nameNow, worker = worker, launch = launch}
