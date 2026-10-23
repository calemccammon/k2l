-- Hand-written Lua, loaded last: which names are globals.
for _, name in ipairs({"Screen", "hostVersion", "State", "Effect", "Listener", "ticks", "defaults", "START", "getSummary",
    "describe", "traced", "trace", "clampCount", "Cache", "initial", "notify", "reduce", "effects", "local", "main"}) do
    print(name, rawget(_G, name) ~= nil, ____internal[name] ~= nil)
end
Screen:OnShown()
print(hostVersion())
