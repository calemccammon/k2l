-- ==== main.lua ====
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_FunInterface = ____lualib.__K2L_FunInterface
local __K2L_LazyObject = ____lualib.__K2L_LazyObject
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str

____internal = ____internal or {}
local ____internal = ____internal
Screen = __K2L_Class("app.Screen")

function Screen:____init()
    self.current = ____internal.initial
end

function Screen:OnShown()
    local ____list = ____internal.effects()
    for ____i = 1, ____list.size do
        local e = ____list[____i]
        self.current = ____internal.reduce(self.current, e)
    end
    ____internal.notify(__K2L_FunInterface(____internal.Listener, "changed", function(it)
        print("listener " .. ____internal.describe(it))
    end), self.current)
    print(____internal.getSummary())
end

__K2L_LazyObject(Screen, "____init")

function hostVersion()
    return "v" .. ____internal.START
end

local function ____local()
    return "only main.kt uses this"
end

local function main()
    ____internal.traced(function()
        print(____local())
    end)
    ____internal.ticks = ____internal.ticks + 10
    print(____internal.getSummary())
    print(__K2L_Str(____internal.defaults))
    Screen:OnShown()
end

__K2L_RunMain(main)
-- ==== state/Reducer.lua ====
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_ListOf = ____lualib.__K2L_ListOf

____internal = ____internal or {}
local ____internal = ____internal

local function reduce(state, effect)
    if getmetatable(effect) == ____internal.Effect.Say then
        return ____internal.State.new(state.count, state.log:plus(effect.text))
    elseif __K2L_Equals(effect, ____internal.Effect.Beep) then
        return state:plus(1)
    end
end

____internal.reduce = reduce

local function effects()
    return __K2L_ListOf(____internal.Effect.Say.new("hi"), ____internal.Effect.Beep)
end

____internal.effects = effects
-- ==== state/Store.lua ====
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Str = ____lualib.__K2L_Str

____internal = ____internal or {}
local ____internal = ____internal
local trace, cache, start
local State = __K2L_Class("state.State")

function State.new(count, log)
    return setmetatable({count = count, log = log}, State)
end

function State:plus(step)
    return State.new(self.count + step, self.log:plus("+" .. step))
end

____internal.State = State
local Effect = __K2L_Class("state.Effect")
Effect.Say = __K2L_Class("state.Effect$Say", nil, Effect)

function Effect.Say.new(text)
    return setmetatable({text = text}, Effect.Say)
end

Effect.Beep = __K2L_Class("state.Effect$Beep", nil, Effect)
____internal.Effect = Effect
local Listener = __K2L_Class("state.Listener")
____internal.Listener = Listener
____internal.START = 1

local function getSummary()
    return "ticks=" .. ____internal.ticks
end

____internal.getSummary = getSummary

local function describe(self)
    return "count=" .. self.count .. " log=" .. __K2L_Str(self.log)
end

____internal.describe = describe

local function traced(block)
    trace("before")
    block()
    trace("after")
end

____internal.traced = traced

function trace(what)
    print("trace " .. what)
end

____internal.trace = trace

local function clampCount(n)
    return n > 9 and 9 or n
end

local Cache = __K2L_Class("state.Cache")

function Cache:____init()
    self.seen = __K2L_ListOf()
end

function start()
    cache.seen:add(____internal.START)
    return State.new(clampCount(____internal.START), __K2L_ListOf())
end

local function notify(listener, state)
    ____internal.ticks = ____internal.ticks + 1
    listener:changed(state)
end

____internal.notify = notify
____internal.ticks = 0
____internal.defaults = __K2L_ListOf("a", "b")
cache = Cache.new()
____internal.initial = start()
