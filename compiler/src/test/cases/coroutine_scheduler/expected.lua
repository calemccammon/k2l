local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Continuation = ____lualib.__K2L_Continuation
local __K2L_EmptyCoroutineContext = ____lualib.__K2L_EmptyCoroutineContext
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Result = ____lualib.__K2L_Result
local __K2L_StartCoroutine = ____lualib.__K2L_StartCoroutine
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_SuspendCoroutine = ____lualib.__K2L_SuspendCoroutine
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Unit = ____lualib.__K2L_Unit

local Scheduler = __K2L_Class("Scheduler")

function Scheduler:____init()
    self.frame = 0
    self.waiting = __K2L_ListOf()
    self.active = 0
end

Scheduler.Waiting = __K2L_Class("Scheduler$Waiting")

function Scheduler.Waiting:____init(wakeAt, cont)
    self.wakeAt = wakeAt
    self.cont = cont
end

function Scheduler:launch(name, task)
    self.active = self.active + 1
    __K2L_StartCoroutine(function(...)
        task(...)
        return __K2L_Unit
    end, __K2L_Continuation.new(__K2L_EmptyCoroutineContext, function(result)
        self.active = self.active - 1
        local ____error = result:exceptionOrNull()
        if ____error ~= nil then
            print("[" .. self.frame .. "] " .. name .. " failed: " .. __K2L_Str(____error.message))
        else
            print("[" .. self.frame .. "] " .. name .. " finished")
        end
    end))
end

function Scheduler:waitFrames(n)
    if n <= 0 then
        return
    end
    __K2L_SuspendCoroutine(function(cont)
        self.waiting:add(Scheduler.Waiting.new(self.frame + n, cont))
    end)
end

function Scheduler:cancelAll(reason)
    local all = self.waiting:toList()
    self.waiting:clear()
    for _, w in ipairs(all) do
        w.cont:resumeWith(__K2L_Result.failure(__K2L_IllegalStateException.new(reason)))
    end
end

function Scheduler:runFrame()
    self.frame = self.frame + 1
    local due = self.waiting:filter(function(it) return it.wakeAt <= self.frame end)
    self.waiting:removeAll(due)
    for _, w in ipairs(due) do
        w.cont:resumeWith(__K2L_Result.success(__K2L_Unit))
    end
    return self.active > 0
end

local Mailbox = __K2L_Class("Mailbox")

function Mailbox:____init()
    self.value = nil
    self.receiver = nil
end

function Mailbox:send(v)
    local r = self.receiver
    if r ~= nil then
        self.receiver = nil
        r:resumeWith(__K2L_Result.success(v))
    else
        self.value = v
    end
end

function Mailbox:receive()
    local v = self.value
    if v ~= nil then
        self.value = nil
        return v
    end
    return __K2L_SuspendCoroutine(function(cont)
        self.receiver = cont
    end)
end

local scheduler = Scheduler.new()

local function blink(name, times, every)
    for i = 0, times - 1 do
        print("[" .. scheduler.frame .. "] " .. name .. " blink " .. i + 1)
        scheduler:waitFrames(every)
    end
end

local function guardedWait()
    local ____ok, ____result, ____returned = pcall(function()
        print("[" .. scheduler.frame .. "] guard: waiting inside try")
        scheduler:waitFrames(2)
        print("[" .. scheduler.frame .. "] guard: woke inside try")
        scheduler:waitFrames(100)
        return true, "unreachable"
    end)
    if not ____ok then
        ____ok, ____result, ____returned = pcall(function()
            local ____error = __K2L_ToThrowable(____result)
            if __K2L_InstanceOf(____error, __K2L_IllegalStateException) then
                local e = ____error
                print("[" .. scheduler.frame .. "] guard: caught " .. __K2L_Str(e.message))
                scheduler:waitFrames(1)
                return true, "recovered"
            else
                error(____error, 0)
            end
        end)
    end
    print("[" .. scheduler.frame .. "] guard: finally")
    if not ____ok then
        error(____result, 0)
    end
    if ____result then
        return ____returned
    end
end

local function main()
    local mailbox = Mailbox.new()
    scheduler:launch("fast", function()
        blink("fast", 3, 1)
    end)
    scheduler:launch("slow", function()
        blink("slow", 2, 3)
    end)
    scheduler:launch("consumer", function()
        local first = mailbox:receive()
        print("[" .. scheduler.frame .. "] consumer got " .. first)
        local second = mailbox:receive()
        print("[" .. scheduler.frame .. "] consumer got " .. second)
    end)
    scheduler:launch("producer", function()
        scheduler:waitFrames(2)
        mailbox:send("hello")
        scheduler:waitFrames(2)
        mailbox:send("world")
    end)
    scheduler:launch("guard", function()
        local outcome = guardedWait()
        print("[" .. scheduler.frame .. "] guard: " .. outcome)
    end)
    scheduler:launch("crasher", function()
        scheduler:waitFrames(1)
        error(__K2L_IllegalStateException.new("boom at frame " .. scheduler.frame))
    end)
    scheduler:launch("instant", function()
        print("[" .. scheduler.frame .. "] instant runs without waiting")
    end)
    while scheduler:runFrame() do
        if scheduler.frame == 4 then
            print("-- frame 4: cancelling")
            scheduler:cancelAll("cancelled")
        end
        if scheduler.frame > 20 then
            break
        end
    end
    print("done at frame " .. scheduler.frame)
end

main()
return {Scheduler = Scheduler, Mailbox = Mailbox, scheduler = scheduler, blink = blink, guardedWait = guardedWait}
