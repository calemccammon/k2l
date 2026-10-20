-- Hand-written game scripts: they call into the Kotlin module engine.Api (functions, properties, objects it returns)
-- and hand Lua functions and tables back to Kotlin.
local api = require("engine.Api")

local M = {}

M.VERSION = "scripts/1.0"

local function script(name, priority, reply)
    local s = { name = name, priority = priority }
    function s:on_event(kind, payload)
        return reply(self, kind, payload)
    end
    function s.describe()
        return "script " .. name
    end
    s["repeat"] = function(self, n)
        return string.rep(self.name:sub(1, 1), n)
    end
    return s
end

function M.loadScripts()
    return {
        script("guard", 2, function(self, kind, payload)
            if kind == "hit" then
                return self.name .. " blocks " .. payload.damage
            end
            return nil
        end),
        script("healer", nil, function(self, kind, payload)
            return self.name .. " heals after " .. kind .. " at tick " .. tostring(payload.tick)
        end),
    }
end

function M.run_all(scripts, hook)
    local orc = api.spawn("orc", 12)
    local imp = api.spawn("imp")
    orc:tag("big", "green")
    api.on("hit", function(payload)
        local target = api.find(payload.target)
        local survived = target:damage(payload.damage)
        api.log("hit", payload.target, payload.damage, survived and "survives" or "falls")
    end)
    api.on("hit", function(payload)
        payload.seen = (payload.seen or 0) + 1
    end)
    local payload = { target = "orc", damage = 5 }
    local listeners = api.emit("hit", payload)
    api.emit("hit", { target = "imp", damage = 20 })
    api.log("listeners", listeners, "seen", payload.seen, "tick", payload.tick)

    local total = 0
    for i, s in ipairs(scripts) do
        total = total + hook(s.name, i)
    end

    local names = api.names()
    api.log("names", table.concat(names, ","), "count", #names)
    local snap = api.snapshot()
    api.log("snapshot", snap.tick, snap.alive, snap.hp.orc, snap.hp.imp)
    api.log("imp alive", tostring(imp:getAlive()), "orc hp", orc.hp, "tags", orc.tags.size)
    api.log("world", api.world.size, "tick", api.tick)

    local ok, err = pcall(api.fail, "no mana")
    api.log("fail caught", tostring(ok), err.message)
    local ok2, err2 = pcall(function() return api.find("ghost"):damage(1) end)
    api.log("nil entity", tostring(ok2), type(err2))
    return total
end

M["end"] = function(summary)
    if summary.tick == nil then
        error("summary needs a tick", 0)
    end
    return string.format("ended at tick %d with %d scripts", summary.tick, summary.scripts)
end

function M.stats(xs)
    local sum, max = 0, nil
    for _, x in ipairs(xs) do
        sum = sum + x
        if max == nil or x > max then max = x end
    end
    return #xs, max, sum / #xs
end

function M.broken(kind)
    if kind == "string" then
        error("script exploded", 0)
    elseif kind == "table" then
        error({ code = 42 })
    else
        local t = nil
        return t.field
    end
end

return M
