-- ==== engine/Api.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf

local ____exports = {}
local ____Entity = require("engine.Entity")
local world = __K2L_ListOf()
____exports.tick = 0
local journal = __K2L_ListOf()
local handlers = __K2L_MapOf()

local function spawn(name, hp)
    if hp == nil then
        hp = 10
    end
    local e = ____Entity.Entity.new(name, hp)
    world:add(e)
    journal:add("spawn " .. name)
    return e
end

local function find(name)
    local ____list = world
    local ____result
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        if it.name == name then
            ____result = it
            break
        end
    end
    return ____result
end

local ____lambda_1 = function() return __K2L_ListOf() end
local function on(event, handler)
    handlers:getOrPut(event, ____lambda_1):add(handler)
end

local function emit(event, payload)
    ____exports.tick = ____exports.tick + 1
    local ____value = handlers:get(event)
    if ____value == nil then
        return 0
    end
    local list = ____value
    payload.tick = ____exports.tick
    for ____i_1 = 1, list.size do
        local it = list[____i_1]
        it(payload)
    end
    return list.size
end

local function names()
    local t = {}
    local ____list_1 = world
    for ____i_2 = 1, ____list_1.size do
        local e = ____list_1[____i_2]
        local i = ____i_2 - 1
        do
            local ____key = i + 1
            t[____key] = e.name
        end
    end
    return t
end

local function snapshot()
    local t = {}
    t.tick = ____exports.tick
    local ____list_2 = world
    local ____result_1 = 0
    local ____items_1, ____n_1 = ____list_2:____array()
    for ____i_3 = 1, ____n_1 do
        local it = ____items_1[____i_3]
        if it:getAlive() then
            ____result_1 = ____result_1 + 1
        end
    end
    t.alive = ____result_1
    local hp = {}
    local ____list_3 = world
    for ____i_4 = 1, ____list_3.size do
        local it = ____list_3[____i_4]
        do
            local ____key_1 = it.name
            hp[____key_1] = it.hp
        end
    end
    t.hp = hp
    return t
end

local function log(...)
    local parts = __K2L_ArrayOf(...)
    journal:add(parts:joinToString(" "))
end

local function fail(reason)
    error(__K2L_IllegalStateException.new(reason))
end

____exports.world = world
____exports.journal = journal
____exports.spawn = spawn
____exports.find = find
____exports.on = on
____exports.emit = emit
____exports.names = names
____exports.snapshot = snapshot
____exports.log = log
____exports.fail = fail
return ____exports
-- ==== engine/Entity.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Str = ____lualib.__K2L_Str

local Entity = __K2L_Class("game.engine.Entity")

function Entity:____init(name, hp)
    self.name = name
    self.hp = hp
    self.tags = __K2L_ListOf()
end

function Entity:getAlive()
    return self.hp > 0
end

function Entity:damage(amount)
    self.hp = math.max(0, self.hp - amount)
    return self:getAlive()
end

function Entity:tag(...)
    local names = __K2L_ArrayOf(...)
    self.tags:addAll(names)
    return self
end

function Entity:toString()
    return "Entity(" .. self.name .. ", hp=" .. self.hp .. (self.tags:isEmpty() and "" or ", tags=" .. __K2L_Str(self.tags)) .. ")"
end

local Vec = __K2L_Class("game.engine.Vec")

function Vec:____init(x, y)
    self.x = x
    self.y = y
end

function Vec.new(x, y)
    return setmetatable({x = x, y = y}, Vec)
end

function Vec:plus(o)
    return Vec.new(self.x + o.x, self.y + o.y)
end

function Vec:toString()
    return "Vec(x=" .. self.x .. ", y=" .. self.y .. ")"
end

function Vec:hashCode()
    return (31 * self.x + self.y + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Vec:equals(other)
    return getmetatable(other) == Vec and self.x == other.x and self.y == other.y
end

return {Entity = Entity, Vec = Vec}
-- ==== main.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_SimpleName = ____lualib.__K2L_SimpleName
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local ____scripting = require("lib.scripting")
local ____Api = require("engine.Api")
local ____audio = require("lib.audio")
local ____Entity = require("engine.Entity")

local function main()
    print("scripts " .. ____scripting.VERSION)
    local scripts = ____scripting.loadScripts()
    print("loaded " .. #scripts)
    local hooked = __K2L_ListOf()
    local total = ____scripting.run_all(scripts, function(name, index)
        hooked:add(index .. ":" .. name)
        return index * 10
    end)
    print("hook total " .. total .. ", calls " .. __K2L_Str(hooked))
    local ____list = ____Api.journal
    for ____i = 1, ____list.size do
        local it = ____list[____i]
        print("  " .. it)
    end
    print(__K2L_Str(____Api.world))
    print("tick " .. ____Api.tick)
    for i = 1, #scripts do
        local s = __K2L_NotNull(scripts[i])
        local payload = {}
        payload.damage = 3 * i
        payload.tick = ____Api.tick
        print(s.describe() .. " (priority " .. __K2L_Str(s.priority or "none") .. ") " .. s["repeat"](s, i + 1) .. ": " .. __K2L_Str(s:on_event("hit", payload)))
        print("  on spawn: " .. (s:on_event("spawn", payload) or "ignored"))
    end
    local n, max, mean = ____scripting.stats(__K2L_ListOf(4, 9, 2))
    print("stats " .. n .. " " .. max .. " " .. mean)
    local summary = {}
    summary.scripts = #scripts
    local ____receiver = __K2L_RunCatching(function() return ____scripting["end"](summary) end):exceptionOrNull()
    print(__K2L_Str(____receiver and ____receiver.message))
    summary.tick = ____Api.tick
    print(____scripting["end"](summary))
    local ____list_1 = __K2L_ListOf("string", "table", "index")
    for ____i_1 = 1, ____list_1.size do
        local kind = ____list_1[____i_1]
        local ____ok, ____result = pcall(function()
            ____scripting.broken(kind)
        end)
        if not ____ok then
            local ____error = __K2L_ToThrowable(____result)
            if __K2L_InstanceOf(____error, __K2L_RuntimeException) then
                local e = ____error
                local msg = e.message or ""
                print(kind .. ": " .. __K2L_Str(__K2L_SimpleName(e)) .. " " .. __K2L_Str(kind == "string" and msg or (__K2L_StringStartsWith(msg, "table:") or __K2L_StringContains(msg, "nil"))))
            else
                error(____error, 0)
            end
        end
    end
    print(tostring(____audio.play("boom", 0.5)) .. " " .. tostring(____audio.play("zap", 1.0)) .. " " .. ____audio.played .. " " .. __K2L_Str(____audio.last_sound))
    ____audio.set_muted(true)
    print(tostring(____audio.play("hush", 0.1)) .. " " .. ____audio.played .. " " .. __K2L_Str(____audio.last_sound))
    print(__K2L_Str(____Entity.Vec.new(1, 2):plus(____Entity.Vec.new(3, 4))))
end

__K2L_RunMain(main)
