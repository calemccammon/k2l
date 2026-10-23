-- ==== main.lua ====
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_RunMain = ____lualib.__K2L_RunMain

local ____lambda_1 = function() return false end
local ____lambda_2 = function(receiver, ...) return receiver.label(...) end
local function main()
    Dispatch.OnMouseWheel(0, 0, 10)
    local ____list = __K2L_ListOf(Heart, Alarm.new("late"), ticker(____lambda_1))
    for ____i = 1, ____list.size do
        local t = ____list[____i]
        t.start()
        print(t.status())
    end
    local ____receiver = Interface
    local update = function(...) return ____receiver.Update(...) end
    update(1.0)
    local label = ____lambda_2
    print(label(Alarm.new("ref")))
    print(Book.getPages())
end

__K2L_RunMain(main)
-- ==== ui/Handlers.lua ====
local __K2L_Class = ____lualib.__K2L_Class

Dispatch = __K2L_Class("ui.Dispatch")

function Dispatch.____init()
    Dispatch.wheel = 0
end

function Dispatch.OnMouseWheel(x, y, delta)
    Dispatch.wheel = Dispatch.wheel + delta
    print("wheel " .. x .. " " .. y .. " " .. Dispatch.wheel)
end

Dispatch.____init()
Interface = __K2L_Class("ui.Interface")

function Interface.____init()
    Interface.elapsed = 0.0
end

function Interface.CreatePlayWindowSet()
    print("windows created")
end

function Interface.Update(timePassed)
    Interface.elapsed = Interface.elapsed + timePassed
    print("elapsed " .. Interface.elapsed)
end

Interface.____init()
Book = __K2L_Class("ui.Book")

function Book.____init()
    Book.title = "none"
end

function Book.getPages()
    return #Book.title
end

function Book.Initialize(name, page)
    Book.title = name
    print("book " .. Book.title .. " at " .. page .. " of " .. Book.getPages())
end

Book.____init()
-- ==== ui/Tickers.lua ====
local __K2L_Class = ____lualib.__K2L_Class

Ticker = __K2L_Class("ui.Ticker")

function Ticker:status()
    return self.running() and "running" or "stopped"
end

function ticker(step)
    local on = false
    local ____object = __K2L_Class("ui.TickersKt$ticker$1", nil, Ticker)
    function ____object.start()
        on = step()
    end
    function ____object.running()
        return on
    end
    function ____object.status(...)
        return Ticker.status(____object, ...)
    end
    return ____object
end

Clock = __K2L_Class("ui.Clock", nil, Ticker)

function Clock:____init(name)
    if rawget(self, "start") == nil then
        self.start = function(...) return getmetatable(self).start(self, ...) end
    end
    if rawget(self, "running") == nil then
        self.running = function(...)
            return getmetatable(self).running(self, ...)
        end
    end
    if rawget(self, "status") == nil then
        self.status = function(...)
            return getmetatable(self).status(self, ...)
        end
    end
    if rawget(self, "label") == nil then
        self.label = function(...) return getmetatable(self).label(self, ...) end
    end
    self.name = name
    self.ticks = 0
end

function Clock:start()
    self.ticks = self.ticks + 1
end

function Clock:running()
    return self.ticks > 0
end

function Clock:label()
    return self.name .. ":" .. self.ticks
end

Alarm = __K2L_Class("ui.Alarm", Clock)

function Alarm:____init(name)
    Clock.____init(self, name)
end

function Alarm:label()
    return "alarm " .. Clock.label(self)
end

Heart = __K2L_Class("ui.Heart", nil, Ticker)

function Heart.____init()
    Heart.beats = 0
end

function Heart.start()
    Heart.beats = Heart.beats + 1
end

function Heart.running()
    return Heart.beats > 0
end

function Heart.status(...)
    return Ticker.status(Heart, ...)
end

Heart.____init()
