local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_GenerateSequence = ____lualib.__K2L_GenerateSequence
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IRem = ____lualib.__K2L_IRem
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_SequenceBuilder = ____lualib.__K2L_SequenceBuilder
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Uninitialized = ____lualib.__K2L_Uninitialized

local TaskContext, Scheduler
local Effect = __K2L_Class("sim.Effect")
Effect.Sleep = __K2L_Class("sim.Effect$Sleep", Effect)

function Effect.Sleep:____init(ticks)
    self.ticks = ticks
end

function Effect.Sleep.new(ticks)
    return setmetatable({ticks = ticks}, Effect.Sleep)
end

function Effect.Sleep:toString()
    return "Sleep(ticks=" .. self.ticks .. ")"
end

function Effect.Sleep:hashCode()
    return self.ticks
end

function Effect.Sleep:equals(other)
    return getmetatable(other) == Effect.Sleep and self.ticks == other.ticks
end

Effect.Send = __K2L_Class("sim.Effect$Send", Effect)

function Effect.Send:____init(channel, value)
    self.channel = channel
    self.value = value
end

function Effect.Send.new(channel, value)
    return setmetatable({channel = channel, value = value}, Effect.Send)
end

function Effect.Send:toString()
    return "Send(channel=" .. self.channel .. ", value=" .. self.value .. ")"
end

function Effect.Send:hashCode()
    return (31 * __K2L_Hash(self.channel) + self.value + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Effect.Send:equals(other)
    return getmetatable(other) == Effect.Send and self.channel == other.channel and self.value == other.value
end

Effect.Receive = __K2L_Class("sim.Effect$Receive", Effect)

function Effect.Receive:____init(channel)
    self.channel = channel
end

function Effect.Receive.new(channel)
    return setmetatable({channel = channel}, Effect.Receive)
end

function Effect.Receive:toString()
    return "Receive(channel=" .. self.channel .. ")"
end

function Effect.Receive:hashCode()
    return __K2L_Hash(self.channel)
end

function Effect.Receive:equals(other)
    return getmetatable(other) == Effect.Receive and self.channel == other.channel
end

Effect.Yield = __K2L_Class("sim.Effect$Yield", Effect)

function Effect.Yield:toString()
    return "Yield"
end

local Mailbox = __K2L_Class("sim.Mailbox")

function Mailbox:____init()
    self.queues = __K2L_MapOf()
end

local ____lambda_1 = function() return __K2L_ArrayDeque.new() end
function Mailbox:offer(channel, value)
    self.queues:getOrPut(channel, ____lambda_1):addLast(value)
end

function Mailbox:poll(channel)
    local ____receiver = self.queues:get(channel)
    return ____receiver and ____receiver:removeFirstOrNull()
end

local ____lambda_2 = function(it) return it:isNotEmpty() end
local ____lambda_3 = function(it) return it.value:toList() end
function Mailbox:pending()
    return self.queues:filterValues(____lambda_2):mapValues(____lambda_3)
end

local Task = __K2L_Class("sim.Task")

function Task:____init(name, body)
    self.name = name
    self.body = body
    self.wakeAt = 0
    self.waitingOn = nil
    self.received = nil
    self.finished = false
    self.steps = 0
end

function Task:start(ctx)
    self.iterator = __K2L_SequenceBuilder(function(____this)
        self.body(____this, ctx)
    end):iterator()
end

function Task:toString()
    return self.name .. "(" .. (self.finished and "done" or "steps=" .. self.steps) .. ")"
end

TaskContext = __K2L_Class("sim.TaskContext")

function TaskContext:____init(scheduler, task)
    self.scheduler = scheduler
    self.task = task
end

function TaskContext.new(scheduler, task)
    return setmetatable({scheduler = scheduler, task = task}, TaskContext)
end

function TaskContext:getNow()
    return self.scheduler.clock
end

function TaskContext:log(msg)
    self.scheduler:log("[t=" .. self.scheduler.clock .. "] " .. self.task.name .. ": " .. msg)
end

function TaskContext:lastReceived()
    local ____value = self.task.received
    if ____value == nil then
        error(__K2L_IllegalStateException.new(self.task.name .. " has received nothing"))
    end
    return ____value
end

Scheduler = __K2L_Class("sim.Scheduler")

function Scheduler:____init(maxTicks)
    if maxTicks == nil then
        maxTicks = 100
    end
    self.maxTicks = maxTicks
    self.clock = 0
    self.tasks = __K2L_ListOf()
    self.mailbox = Mailbox.new()
    self.output = __K2L_ListOf()
    self.listeners = __K2L_ListOf()
end

function Scheduler:log(line)
    self.output:add(line)
end

function Scheduler:onFinish(listener)
    self.listeners:add(listener)
end

function Scheduler:spawn(name, body)
    local ____value_1 = Task.new(name, body)
    ____value_1:start(TaskContext.new(self, ____value_1))
    self.tasks:add(____value_1)
    return ____value_1
end

function Scheduler:runnable(t)
    if t.finished then
        return false
    elseif t.wakeAt > self.clock then
        return false
    elseif t.waitingOn ~= nil then
        local value = self.mailbox:poll(__K2L_NotNull(t.waitingOn))
        if value ~= nil then
            t.received = value
            t.waitingOn = nil
            return true
        else
            return false
        end
    else
        return true
    end
end

function Scheduler:step(t)
    if not (t.iterator or __K2L_Uninitialized("iterator")):hasNext() then
        t.finished = true
        local ____list = self.listeners
        local ____mod = ____list.____modCount
        for ____i = 1, ____list.size do
            local it = ____list[____i]
            it(t)
            if ____list.____modCount ~= ____mod and ____list:____comodified(____i) then
                break
            end
        end
        return
    end
    t.steps = t.steps + 1
    local effect = (t.iterator or __K2L_Uninitialized("iterator")):next()
    local ____mt = getmetatable(effect)
    if ____mt == Effect.Sleep then
        t.wakeAt = self.clock + effect.ticks
    elseif ____mt == Effect.Send then
        self.mailbox:offer(effect.channel, effect.value)
    elseif ____mt == Effect.Receive then
        t.waitingOn = effect.channel
    elseif __K2L_Equals(effect, Effect.Yield) then
    end
end

local ____lambda_4 = function(it) return it.wakeAt end
function Scheduler:run()
    while true do
        local ____cond = self.clock < self.maxTicks
        if ____cond then
            local ____list_1 = self.tasks
            local ____result = false
            local ____items, ____n = ____list_1:____array()
            for ____i_1 = 1, ____n do
                local it = ____items[____i_1]
                if not it.finished then
                    ____result = true
                    break
                end
            end
            ____cond = ____result
        end
        if not ____cond then
            break
        end
        local ready = self.tasks:filter(function(...) return self:runnable(...) end)
        local ____mod_1 = ready.____modCount
        for ____i_2 = 1, ready.size do
            local it = ready[____i_2];
            (function(...) return self:step(...) end)(it)
            if ready.____modCount ~= ____mod_1 and ready:____comodified(____i_2) then
                break
            end
        end
        if ready:isEmpty() then
            local ____list_2 = self.tasks
            local ____out = {}
            local ____count = 0
            local ____items_1, ____n_1 = ____list_2:____array()
            for ____i_3 = 1, ____n_1 do
                local it = ____items_1[____i_3]
                if not it.finished and it.waitingOn == nil then
                    ____count = ____count + 1
                    ____out[____count] = it
                end
            end
            local ____next = __K2L_ListWrap(____out, ____count):minOfOrNull(____lambda_4)
            if ____next == nil then
                local ____arg = self.clock
                local ____list_3 = self.tasks
                local ____out_1 = {}
                local ____count_1 = 0
                local ____items_2, ____n_2 = ____list_3:____array()
                for ____i_4 = 1, ____n_2 do
                    local it = ____items_2[____i_4]
                    if not it.finished then
                        ____count_1 = ____count_1 + 1
                        ____out_1[____count_1] = it
                    end
                end
                local ____list_4 = __K2L_ListWrap(____out_1, ____count_1)
                local ____out_2 = {}
                local ____count_2 = 0
                local ____items_3, ____n_3 = ____list_4:____array()
                for ____i_5 = 1, ____n_3 do
                    local it = ____items_3[____i_5]
                    ____count_2 = ____count_2 + 1
                    ____out_2[____count_2] = it.name .. " waits on " .. __K2L_Str(it.waitingOn)
                end
                self:log("deadlock at t=" .. ____arg .. ": " .. __K2L_Str(__K2L_ListWrap(____out_2, ____count_2)))
                break
            end
            self.clock = math.max(self.clock + 1, ____next)
        end
    end
    self:log("pending messages: " .. __K2L_Str(self.mailbox:pending()))
    return self.output
end

function Scheduler:getSummary()
    return self.tasks:joinToString()
end

local function fibonacci()
    return __K2L_SequenceBuilder(function(self)
        local ____destructured = __K2L_Pair.new(0, 1)
        local a, b = ____destructured.first, ____destructured.second
        while true do
            self:yield(a)
            local ____next = a + b
            a = b
            b = ____next
        end
    end)
end

local function primes()
    return __K2L_SequenceBuilder(function(____this_1)
        local found = __K2L_ListOf()
        local n = 2
        while true do
            local ____result_1 = true
            local ____items_4, ____n_4 = found:____array()
            for ____i_6 = 1, ____n_4 do
                local it = ____items_4[____i_6]
                if __K2L_IRem(n, it) == 0 then
                    ____result_1 = false
                    break
                end
            end
            if ____result_1 then
                found:add(n)
                ____this_1:yield(n)
            end
            n = n + 1
        end
    end)
end

local function chunkedBy(____this_2, size)
    return __K2L_SequenceBuilder(function(____this_3)
        local buffer = __K2L_List.new()
        for _, item in ____this_2:iter() do
            buffer:add(item)
            if buffer.size == size then
                ____this_3:yield(buffer:toList())
                buffer:clear()
            end
        end
        if buffer:isNotEmpty() then
            ____this_3:yield(buffer)
        end
    end)
end

local function tree(depth, prefix)
    if prefix == nil then
        prefix = "r"
    end
    return __K2L_SequenceBuilder(function(____this_4)
        ____this_4:yield(prefix)
        if depth > 0 then
            ____this_4:yieldAll(tree(depth - 1, prefix .. "L"))
            ____this_4:yieldAll(tree(depth - 1, prefix .. "R"))
        end
    end)
end

local ____lambda_5 = function(it) return it < 40 end
local ____lambda_6 = function(it) return it * it end
local ____lambda_7 = function(it)
    return (it >= 0 and it % 10 or 0 - -it % 10) == 9
end
local ____lambda_8 = function(it) return it * 3 end
local ____lambda_9 = function(it) return it - 1 end
local ____lambda_10 = function(it)
    return (it >= 0 and it % 2 or 0 - -it % 2) == 0
end
local ____lambda_11 = function(it) return it > 20 end
local ____lambda_12 = function(____p1) return print(__K2L_Str(____p1)) end
local function main()
    print(__K2L_Str(fibonacci():take(12):toList()))
    print(primes():takeWhile(____lambda_5):joinToString(" "))
    print(__K2L_Str(primes():map(____lambda_6):filter(____lambda_7):take(4):toList()))
    print(__K2L_Str(chunkedBy(__K2L_AsSequence(__K2L_IntRange.new(1, 10)), 4):toList()))
    print(__K2L_Str(tree(2):toList()))
    local lazyLog = __K2L_ListOf()
    local pipeline = __K2L_GenerateSequence(1, ____lambda_8):onEach(function(it)
        lazyLog:add("gen " .. it)
    end):map(____lambda_9):filter(____lambda_10)
    print(pipeline:first(____lambda_11) .. " after " .. lazyLog.size .. " steps")
    local scheduler = Scheduler.new()
    local finished = __K2L_ListOf()
    scheduler:onFinish(function(it)
        finished:add(it.name)
    end)
    scheduler:spawn("producer", function(____this_5, ctx)
        for _, x in fibonacci():drop(3):take(4):iter() do
            ctx:log("send " .. x)
            ____this_5:yield(Effect.Send.new("numbers", __K2L_ToInt32(x)))
            ____this_5:yield(Effect.Sleep.new(2))
        end
        ____this_5:yield(Effect.Send.new("numbers", -1))
        ctx:log("done producing")
    end)
    scheduler:spawn("consumer", function(____this_6, ctx)
        local total = 0
        while true do
            ____this_6:yield(Effect.Receive.new("numbers"))
            local v = ctx:lastReceived()
            if v < 0 then
                break
            end
            total = total + v
            ctx:log("got " .. v .. ", total " .. total)
            if total > 6 then
                ____this_6:yield(Effect.Send.new("report", total))
            end
        end
        ctx:log("consumer finished with " .. total)
    end)
    scheduler:spawn("ticker", function(____this_7, ctx)
        for it = 0, 2 do
            ____this_7:yield(Effect.Sleep.new(3))
            ctx:log("tick " .. it + 1)
        end
    end)
    scheduler:spawn("waiter", function(____this_8, ctx)
        ____this_8:yield(Effect.Yield)
        ____this_8:yield(Effect.Receive.new("never"))
        ctx:log("unreachable")
    end)
    local ____list_5 = scheduler:run()
    local ____mod_2 = ____list_5.____modCount
    for ____i_7 = 1, ____list_5.size do
        local it = ____list_5[____i_7];
        (____lambda_12)(it)
        if ____list_5.____modCount ~= ____mod_2 and ____list_5:____comodified(____i_7) then
            break
        end
    end
    print("finished: " .. __K2L_Str(finished))
    print(scheduler:getSummary())
    local failing = Scheduler.new(5)
    failing:spawn("broken", function(____this_9, ctx)
        ____this_9:yield(Effect.Yield)
        ctx:log("about to fail")
        ctx:lastReceived()
    end)
    local ____ok, ____result_2 = __K2L_DeepPcall(function()
        failing:run()
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_2)
        if __K2L_InstanceOf(____error, __K2L_IllegalStateException) then
            local e = ____error
            print("caught: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
end

__K2L_DeepMain(main)
return {Effect = Effect, Mailbox = Mailbox, Task = Task, TaskContext = TaskContext, Scheduler = Scheduler, fibonacci = fibonacci, primes = primes, chunkedBy = chunkedBy, tree = tree}
