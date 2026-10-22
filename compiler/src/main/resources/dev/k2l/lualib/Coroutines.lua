-- requires: Class, Exceptions, ToThrowable, Result, Str
-- kotlin.coroutines on Lua coroutines. startCoroutine runs the suspend block as a task in its own Lua
-- coroutine; suspend functions are ordinary functions called inside it. suspendCoroutine hands its
-- block a continuation and, unless the block already resumed it, yields the task's coroutine until
-- continuation:resumeWith(result) resumes it. When the block returns or throws, the task's
-- completion continuation receives a Result, on the stack of whoever resumed the task last.
local __K2L_EmptyCoroutineContext = setmetatable({}, {__index = {
    toString = function() return "EmptyCoroutineContext" end,
}})

-- Continuation(context) { result -> ... }
local __K2L_Continuation = __K2L_Class("kotlin.coroutines.Continuation")

function __K2L_Continuation:____init(context, onResume)
    self.context = context
    self.____onResume = onResume
end

function __K2L_Continuation:resumeWith(result)
    self.____onResume(result)
end

-- The marker returned by a suspendCoroutineUninterceptedOrReturn block that will resume the continuation later.
local __K2L_COROUTINE_SUSPENDED = setmetatable({}, {__index = {
    toString = function() return "COROUTINE_SUSPENDED" end,
}})

------------------------------------------------------------------ contexts
-- A context is EmptyCoroutineContext, an element (any object with a `key`), or a Combined(left, element). The
-- operations are functions rather than methods so that Kotlin classes implementing Element need no base class.
local Combined = __K2L_Class("kotlin.coroutines.CombinedContext")

function Combined:____init(left, element)
    self.left = left
    self.element = element
end

local __K2L_ContinuationInterceptor = setmetatable({}, {__index = {
    toString = function() return "ContinuationInterceptor" end,
}})

local function __K2L_ContextGet(context, key)
    if context == __K2L_EmptyCoroutineContext then
        return nil
    elseif getmetatable(context) == Combined then
        if context.element.key == key then
            return context.element
        end
        return __K2L_ContextGet(context.left, key)
    end
    return context.key == key and context or nil
end

local function __K2L_ContextFold(context, initial, operation)
    if context == __K2L_EmptyCoroutineContext then
        return initial
    elseif getmetatable(context) == Combined then
        return operation(__K2L_ContextFold(context.left, initial, operation), context.element)
    end
    return operation(initial, context)
end

local function __K2L_ContextMinusKey(context, key)
    if context == __K2L_EmptyCoroutineContext then
        return context
    elseif getmetatable(context) == Combined then
        if context.element.key == key then
            return context.left
        end
        local left = __K2L_ContextMinusKey(context.left, key)
        if left == context.left then
            return context
        elseif left == __K2L_EmptyCoroutineContext then
            return context.element
        end
        return Combined.new(left, context.element)
    end
    return context.key == key and __K2L_EmptyCoroutineContext or context
end

-- context + other: elements of `other` replace those with the same key; the interceptor stays last.
local function __K2L_ContextPlus(context, other)
    return __K2L_ContextFold(other, context, function(acc, element)
        local removed = __K2L_ContextMinusKey(acc, element.key)
        if removed == __K2L_EmptyCoroutineContext then
            return element
        end
        local interceptor = __K2L_ContextGet(removed, __K2L_ContinuationInterceptor)
        if interceptor == nil then
            return Combined.new(removed, element)
        end
        local left = __K2L_ContextMinusKey(removed, __K2L_ContinuationInterceptor)
        if left == __K2L_EmptyCoroutineContext then
            return Combined.new(element, interceptor)
        end
        return Combined.new(Combined.new(left, element), interceptor)
    end)
end

function Combined:toString()
    return "[" .. __K2L_ContextFold(self, "", function(acc, element)
        return (acc == "" and "" or acc .. ", ") .. __K2L_Str(element)
    end) .. "]"
end

-- class Foo : AbstractCoroutineContextElement(Key)
local __K2L_AbstractCoroutineContextElement = __K2L_Class("kotlin.coroutines.AbstractCoroutineContextElement")

function __K2L_AbstractCoroutineContextElement:____init(key)
    self.key = key
end

-- cont.intercepted()
local function __K2L_Intercepted(continuation)
    local interceptor = __K2L_ContextGet(continuation.context, __K2L_ContinuationInterceptor)
    if interceptor == nil then
        return continuation
    end
    return interceptor:interceptContinuation(continuation)
end

------------------------------------------------------------------ tasks
-- The task whose coroutine is running (nil outside coroutines).
local running = nil

-- Resumes a task's coroutine: the Lua side of Continuation.resumeWith for the coroutine's own continuation.
local TaskContinuation = __K2L_Class("kotlin.coroutines.jvm.internal.BaseContinuationImpl")

function TaskContinuation:____init(task)
    self.task = task
    self.context = task.context
end

-- Runs `task` until it suspends or finishes, passing `start` (the Result it is resumed with) to the coroutine.
local function resumeTask(task, start)
    local outer = running
    running = task
    local ok, value = coroutine.resume(task.co, start)
    running = outer
    if coroutine.status(task.co) == "dead" then
        local result = ok and __K2L_Result.success(value) or __K2L_Result.failure(__K2L_ToThrowable(value))
        if task.interceptor ~= nil and task.interceptor.releaseInterceptedContinuation ~= nil then
            task.interceptor:releaseInterceptedContinuation(task.intercepted)
        end
        if task.direct then
            task.directResult = result
        else
            task.completion:resumeWith(result)
        end
    end
end

function TaskContinuation:resumeWith(result)
    resumeTask(self.task, result)
end

local function newTask(block, completion, receiver)
    local task = {completion = completion, context = completion.context}
    task.raw = TaskContinuation.new(task)
    task.co = coroutine.create(function(start)
        if start ~= nil then
            start:getOrThrow()
        end
        return block(receiver)
    end)
    return task
end

-- The task's continuation as seen from outside: the context's interceptor wraps it (asked once, like on the JVM).
local function intercepted(task)
    if task.intercepted == nil then
        task.interceptor = __K2L_ContextGet(task.context, __K2L_ContinuationInterceptor)
        task.intercepted = task.interceptor and task.interceptor:interceptContinuation(task.raw) or task.raw
    end
    return task.intercepted
end

-- The continuation given to suspendCoroutine's block. Its state is "undecided" while the block
-- runs, "suspended" once the task has yielded, and "resumed" after resumeWith(). A continuation that
-- resumes through the interceptor (suspendCoroutine, createCoroutine) lets it dispatch the resumption.
local SafeContinuation = __K2L_Class("kotlin.coroutines.SafeContinuation")

function SafeContinuation:____init(task, state, intercept)
    self.____task = task
    self.____state = state
    self.____intercept = intercept
    self.context = task.context
end

function SafeContinuation:resumeWith(result)
    local state = self.____state
    if state == "resumed" then
        error(__K2L_IllegalStateException.new("Already resumed"))
    end
    self.____state, self.____result = "resumed", result
    if state == "suspended" then
        if self.____intercept then
            intercepted(self.____task):resumeWith(result)
        else
            resumeTask(self.____task, result)
        end
    end
end

-- block.startCoroutine(completion) and block.startCoroutine(receiver, completion)
local function __K2L_StartCoroutine(block, completion, receiver)
    local task = newTask(block, completion, receiver)
    intercepted(task):resumeWith(__K2L_Result.success(nil))
end

-- block.createCoroutine(completion): the coroutine starts when the returned continuation is resumed.
local function __K2L_CreateCoroutine(block, completion, receiver)
    return SafeContinuation.new(newTask(block, completion, receiver), "suspended", true)
end

-- block.createCoroutineUnintercepted(completion): the same, started without asking the interceptor.
local function __K2L_CreateCoroutineUnintercepted(block, completion, receiver)
    return newTask(block, completion, receiver).raw
end

-- block.startCoroutineUninterceptedOrReturn(completion): runs the block now; its value if it finishes without
-- suspending (the completion is not called then), else COROUTINE_SUSPENDED.
local function __K2L_StartCoroutineUninterceptedOrReturn(block, completion, receiver)
    local task = newTask(block, completion, receiver)
    task.direct = true
    resumeTask(task, nil)
    task.direct = nil
    local result = task.directResult
    if result == nil then
        return __K2L_COROUTINE_SUSPENDED
    end
    return result:getOrThrow()
end

-- Shared by suspendCoroutine and suspendCoroutineUninterceptedOrReturn.
local function suspendWith(block, intercept, orReturn)
    local cont = SafeContinuation.new(running, "undecided", intercept)
    local value = block(cont)
    if orReturn and value ~= __K2L_COROUTINE_SUSPENDED then
        cont.____state = "resumed"
        return value
    end
    if cont.____state == "undecided" then
        cont.____state = "suspended"
        coroutine.yield()
    end
    return cont.____result:getOrThrow()
end

-- suspendCoroutine { cont -> ... }: the block may resume `cont` right away, later, or never.
local function __K2L_SuspendCoroutine(block)
    return suspendWith(block, true, false)
end

-- suspendCoroutineUninterceptedOrReturn { cont -> ... }: the block returns the value, or COROUTINE_SUSPENDED
-- after arranging for `cont` to be resumed (directly, not through the interceptor).
local function __K2L_SuspendCoroutineUninterceptedOrReturn(block)
    return suspendWith(block, false, true)
end

-- coroutineContext
local function __K2L_CoroutineContext()
    return running.context
end

-- suspend fun main(): runs as a coroutine. An exception it ends with is raised again, uncaught.
local function __K2L_RunSuspend(main, args)
    local task = newTask(main, __K2L_Continuation.new(__K2L_EmptyCoroutineContext, function(result)
        if result:isFailure() then
            error(result:exceptionOrNull(), 0)
        end
    end), args)
    intercepted(task):resumeWith(__K2L_Result.success(nil))
end
