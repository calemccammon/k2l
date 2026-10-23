-- The host calls the mod's functions with `.`, with several arguments.
Interface.CreatePlayWindowSet()
Interface.Update(0.5)
Interface.Update(0.25)
Dispatch.OnMouseWheel(1, 2, 3)
Dispatch.OnMouseWheel(4, 5, -1)
Book.Initialize("Atlas", 7)

-- Functions of an interface implementation, also when handed around as values.
local t = ticker(function() return true end)
print(t.running(), t.status())
t.start()
print(t.running(), t.status())
local alarm = Alarm.new("wake")
alarm.start()
print(alarm.label(), alarm.status())
Heart.start()
print(Heart.beats, Heart.status())
local handlers = {Heart.start, alarm.start, alarm.label}
for _, f in ipairs(handlers) do
    print(f())
end
print(Heart.beats)
