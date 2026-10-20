-- A hand-written Lua host that loads mods written in Kotlin by module name and drives them.
local events = require("shared.Events")

local M = {}

local queue = {}

local host = { name = "luahost 1.4" }

function host.log(msg)
    print("[host] " .. msg)
end

function host.schedule(delay, task)
    queue[#queue + 1] = { at = delay, task = task }
end

function M.boot(modules)
    local loaded = {}
    for i, name in ipairs(modules) do
        local mod = require(name)
        loaded[i] = mod
        print("loaded " .. name .. " as " .. mod.on_load(host))
    end
    local greeter, counter = loaded[1], loaded[2]

    -- the counter's top-level state is set up by this first read
    print("click_count before " .. counter.click_count)
    counter.click_count = 10
    print("click " .. counter.click(5) .. " " .. counter.click())

    print(greeter.compatible("1.4"), greeter.compatible("1.1"))
    print(greeter.greet("ann"), greeter.greet("bob", "?"))
    greeter.greeting_style = "loud"
    local all = greeter.greet_all("cy", "di")
    print(all.size, all:get(0), all:get(1), tostring(all))

    print("join listeners " .. events.Events:fire("join", "eve"))
    print("click listeners " .. events.Events:fire("click", "3"))
    print("nobody listens " .. events.Events:fire("quit"))

    local v = events.Version:parse("2.10")
    print(tostring(v), v.major, v.minor, v:compareTo(events.Version.new(2, 9)))

    for tick = 1, 3 do
        for _, item in ipairs(queue) do
            if item.at == tick then item.task() end
        end
    end
    return #modules
end

return M
