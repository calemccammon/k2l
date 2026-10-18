-- requires: Class, Exceptions, ToThrowable, Result
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

-- The task whose coroutine is running (nil outside coroutines).
local running = nil

-- Runs `task` until it suspends or finishes, passing `start` (the Result a created coroutine is
-- started with) to its first resumption.
local function resumeTask(task, start)
    local outer = running
    running = task
    local ok, value = coroutine.resume(task.co, start)
    running = outer
    if coroutine.status(task.co) == "dead" then
        task.completion:resumeWith(ok and __K2L_Result.success(value) or __K2L_Result.failure(__K2L_ToThrowable(value)))
    end
end

local function newTask(block, completion, receiver)
    local task = {completion = completion, context = completion.context}
    task.co = coroutine.create(function(start)
        if start ~= nil then
            start:getOrThrow()
        end
        return block(receiver)
    end)
    return task
end

-- The continuation given to suspendCoroutine's block. Its state is "undecided" while the block
-- runs, "suspended" once the task has yielded, and "resumed" after resumeWith().
local SafeContinuation = __K2L_Class("kotlin.coroutines.SafeContinuation")

function SafeContinuation:____init(task, state)
    self.____task = task
    self.____state = state
    self.context = task.context
end

function SafeContinuation:resumeWith(result)
    local state = self.____state
    if state == "resumed" then
        error(__K2L_IllegalStateException.new("Already resumed"))
    end
    self.____state, self.____result = "resumed", result
    if state == "suspended" then
        resumeTask(self.____task, result)
    end
end

-- block.startCoroutine(completion) and block.startCoroutine(receiver, completion)
local function __K2L_StartCoroutine(block, completion, receiver)
    resumeTask(newTask(block, completion, receiver))
end

-- block.createCoroutine(completion): the coroutine starts when the returned continuation is resumed.
local function __K2L_CreateCoroutine(block, completion, receiver)
    return SafeContinuation.new(newTask(block, completion, receiver), "suspended")
end

-- suspendCoroutine { cont -> ... }: the block may resume `cont` right away, later, or never.
local function __K2L_SuspendCoroutine(block)
    local cont = SafeContinuation.new(running, "undecided")
    block(cont)
    if cont.____state == "undecided" then
        cont.____state = "suspended"
        coroutine.yield()
    end
    return cont.____result:getOrThrow()
end

-- coroutineContext
local function __K2L_CoroutineContext()
    return running.context
end

-- suspend fun main(): runs as a coroutine; an exception it ends with is rethrown.
local function __K2L_RunSuspend(main, args)
    __K2L_StartCoroutine(main, __K2L_Continuation.new(__K2L_EmptyCoroutineContext, function(result) result:getOrThrow() end), args)
end
