-- ==== ecs/World.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_SimpleName = ____lualib.__K2L_SimpleName
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_Str = ____lualib.__K2L_Str

local World
local Component = __K2L_Class("sim.ecs.Component")
local Entity = __K2L_Class("sim.ecs.Entity")

function Entity:____init(id)
    self.id = id
end

function Entity.new(id)
    return setmetatable({id = id}, Entity)
end

function Entity:toString()
    return "e" .. self.id
end

function Entity:hashCode()
    return self.id
end

function Entity:equals(other)
    return getmetatable(other) == Entity and self.id == other.id
end

local Store = __K2L_Class("sim.ecs.Store")

function Store:____init(____type)
    self.type = ____type
    self.items = __K2L_SortedMapOf(nil)
end

function Store:getSize()
    return self.items.size
end

function Store:get(e)
    return self.items:get(e.id)
end

function Store:set(e, c)
    local ____object = self.items
    local ____key = e.id
    ____object:set(____key, c)
end

function Store:remove(e)
    return self.items:remove(e.id) ~= nil
end

function Store:ids()
    return self.items:getKeys()
end

function Store:toString()
    return self.type .. "x" .. self:getSize()
end

local System = __K2L_Class("sim.ecs.System")

function System:____init(name)
    self.name = name
    self.runs = 0
end

function System:tick(world, dt)
    self.runs = self.runs + 1
    self:update(world, dt)
end

function System:toString()
    return self.name .. "(" .. self.runs .. ")"
end

World = __K2L_Class("sim.ecs.World")

function World:____init()
    self.nextId = 1
    self.alive = __K2L_SetOf()
    self.stores = __K2L_MapOf()
    self.systems = __K2L_ListOf()
    self.pendingRemoval = __K2L_ListOf()
    self.tick = 0
    self.log = __K2L_ListOf()
end

function World:spawn(...)
    local components = __K2L_ArrayOf(...)
    local ____old = self.nextId
    self.nextId = self.nextId + 1
    local e = Entity.new(____old)
    self.alive:add(e.id)
    for ____i = 1, components.size do
        local it = components[____i]
        self:add(e, it)
    end
    return e
end

function World:add(e, c)
    local ____cast = self.stores:getOrPut(__K2L_NotNull(__K2L_SimpleName(c)), function()
        return Store.new(__K2L_NotNull(__K2L_SimpleName(c)))
    end)
    if getmetatable(____cast) ~= Store then
        __K2L_CastFail(____cast, "sim.ecs.Store")
    end
    local store = ____cast
    store:set(e, c)
end

function World:store(____type)
    local ____cast_1 = self.stores:getOrPut(____type, function() return Store.new(____type) end)
    if getmetatable(____cast_1) ~= Store then
        __K2L_CastFail(____cast_1, "sim.ecs.Store")
    end
    return ____cast_1
end

function World:isAlive(id)
    return self.alive:contains(id)
end

function World:destroy(e)
    self.pendingRemoval:add(e)
end

function World:addSystem(system)
    self.systems:add(system)
    return self
end

function World:step(dt)
    if dt == nil then
        dt = 1
    end
    self.tick = self.tick + 1
    local ____list = self.systems
    for ____i_1 = 1, ____list.size do
        local s = ____list[____i_1]
        s:tick(self, dt)
    end
    local ____list_1 = self.pendingRemoval
    for ____i_3 = 1, ____list_1.size do
        local e = ____list_1[____i_3]
        if self.alive:remove(e.id) then
            local ____collection = self.stores:getValues()
            local ____items, ____n = ____collection:____array()
            for ____i_2 = 1, ____n do
                local it = ____items[____i_2]
                it:remove(e)
            end
            self.log:add("t" .. self.tick .. ": " .. __K2L_Str(e) .. " destroyed")
        end
    end
    self.pendingRemoval:clear()
end

function World:getPopulation()
    return self.alive.size
end

function World:systems__1()
    return self.systems
end

function World:toString()
    return "World(tick=" .. self.tick .. ", alive=" .. __K2L_Str(self.alive) .. ", stores=" .. __K2L_Str(self.stores:getValues()) .. ")"
end

return {Component = Component, Entity = Entity, Store = Store, System = System, World = World}
-- ==== game/Systems.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_Triple = ____lualib.__K2L_Triple

local ____World = require("ecs.World")
local distance, nameOf
local Position = __K2L_Class("sim.game.Position", nil, ____World.Component)

function Position:____init(x, y)
    self.x = x
    self.y = y
end

function Position.new(x, y)
    return setmetatable({x = x, y = y}, Position)
end

function Position:toString()
    return "Position(x=" .. self.x .. ", y=" .. self.y .. ")"
end

function Position:hashCode()
    return (31 * self.x + self.y + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Position:equals(other)
    return getmetatable(other) == Position and self.x == other.x and self.y == other.y
end

local Velocity = __K2L_Class("sim.game.Velocity", nil, ____World.Component)

function Velocity:____init(dx, dy)
    self.dx = dx
    self.dy = dy
end

function Velocity.new(dx, dy)
    return setmetatable({dx = dx, dy = dy}, Velocity)
end

function Velocity:toString()
    return "Velocity(dx=" .. self.dx .. ", dy=" .. self.dy .. ")"
end

function Velocity:hashCode()
    return (31 * self.dx + self.dy + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Velocity:equals(other)
    return getmetatable(other) == Velocity and self.dx == other.dx and self.dy == other.dy
end

local Health = __K2L_Class("sim.game.Health", nil, ____World.Component)

function Health:____init(hp, max)
    self.hp = hp
    self.max = max
end

function Health.new(hp, max)
    return setmetatable({hp = hp, max = max}, Health)
end

function Health:getDead()
    return self.hp <= 0
end

function Health:toString()
    return "Health(hp=" .. self.hp .. ", max=" .. self.max .. ")"
end

function Health:hashCode()
    return (31 * self.hp + self.max + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Health:equals(other)
    return getmetatable(other) == Health and self.hp == other.hp and self.max == other.max
end

local Name = __K2L_Class("sim.game.Name", nil, ____World.Component)

function Name:____init(value)
    self.value = value
end

function Name.new(value)
    return setmetatable({value = value}, Name)
end

function Name:toString()
    return "Name(value=" .. self.value .. ")"
end

function Name:hashCode()
    return __K2L_Hash(self.value)
end

function Name:equals(other)
    return getmetatable(other) == Name and self.value == other.value
end

local Damage = __K2L_Class("sim.game.Damage", nil, ____World.Component)

function Damage:____init(amount, range)
    self.amount = amount
    self.range = range
end

function Damage.new(amount, range)
    return setmetatable({amount = amount, range = range}, Damage)
end

function Damage:toString()
    return "Damage(amount=" .. self.amount .. ", range=" .. self.range .. ")"
end

function Damage:hashCode()
    return (31 * self.amount + self.range + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Damage:equals(other)
    return getmetatable(other) == Damage and self.amount == other.amount and self.range == other.range
end

local Player = __K2L_Class("sim.game.Player", nil, ____World.Component)

function Player:toString()
    return "Player"
end

local Movement = __K2L_Class("sim.game.Movement", ____World.System)

function Movement:____init(width, height)
    ____World.System.____init(self, "movement")
    self.width = width
    self.height = height
end

function Movement:update(world, dt)
    local ____result
    do
        local a = world:store(__K2L_NotNull("Position"))
        local b = world:store(__K2L_NotNull("Velocity"))
        local ____list = a:ids()
        local ____out = {}
        local ____count = 0
        local ____items, ____n = ____list:____array()
        for ____i = 1, ____n do
            local it = ____items[____i]
            if b:ids():contains(it) and world:isAlive(it) then
                ____count = ____count + 1
                ____out[____count] = it
            end
        end
        local ____list_1 = __K2L_ListWrap(____out, ____count)
        local ____out_1 = {}
        local ____count_1 = 0
        local ____items_1, ____n_1 = ____list_1:____array()
        for ____i_1 = 1, ____n_1 do
            local id = ____items_1[____i_1]
            local ____result_1
            do
                local ____value = ____World.Entity.new(id)
                ____result_1 = __K2L_Triple.new(____value, __K2L_NotNull(a:get(____value)), __K2L_NotNull(b:get(____value)))
            end
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = ____result_1
        end
        ____result = __K2L_ListWrap(____out_1, ____count_1)
    end
    local ____list_2 = ____result
    for ____i_2 = 1, ____list_2.size do
        local ____item = ____list_2[____i_2]
        local pos, vel = ____item.second, ____item.third
        pos.x = (pos.x + vel.dx * dt) % self.width
        pos.y = __K2L_Num.coerceIn(pos.y + vel.dy * dt, 0, self.height - 1)
    end
end

local Combat = __K2L_Class("sim.game.Combat", ____World.System)

function Combat:____init()
    ____World.System.____init(self, "combat")
end

function Combat:update(world, dt)
    local ____result_2
    do
        local a = world:store(__K2L_NotNull("Position"))
        local b = world:store(__K2L_NotNull("Damage"))
        local ____list_3 = a:ids()
        local ____out_2 = {}
        local ____count_2 = 0
        local ____items_2, ____n_2 = ____list_3:____array()
        for ____i_3 = 1, ____n_2 do
            local it = ____items_2[____i_3]
            if b:ids():contains(it) and world:isAlive(it) then
                ____count_2 = ____count_2 + 1
                ____out_2[____count_2] = it
            end
        end
        local ____list_4 = __K2L_ListWrap(____out_2, ____count_2)
        local ____out_3 = {}
        local ____count_3 = 0
        local ____items_3, ____n_3 = ____list_4:____array()
        for ____i_4 = 1, ____n_3 do
            local id = ____items_3[____i_4]
            local ____result_3
            do
                local ____value_1 = ____World.Entity.new(id)
                ____result_3 = __K2L_Triple.new(____value_1, __K2L_NotNull(a:get(____value_1)), __K2L_NotNull(b:get(____value_1)))
            end
            ____count_3 = ____count_3 + 1
            ____out_3[____count_3] = ____result_3
        end
        ____result_2 = __K2L_ListWrap(____out_3, ____count_3)
    end
    local attackers = ____result_2
    local ____result_4
    do
        local a = world:store(__K2L_NotNull("Position"))
        local b = world:store(__K2L_NotNull("Health"))
        local ____list_5 = a:ids()
        local ____out_4 = {}
        local ____count_4 = 0
        local ____items_4, ____n_4 = ____list_5:____array()
        for ____i_5 = 1, ____n_4 do
            local it = ____items_4[____i_5]
            if b:ids():contains(it) and world:isAlive(it) then
                ____count_4 = ____count_4 + 1
                ____out_4[____count_4] = it
            end
        end
        local ____list_6 = __K2L_ListWrap(____out_4, ____count_4)
        local ____out_5 = {}
        local ____count_5 = 0
        local ____items_5, ____n_5 = ____list_6:____array()
        for ____i_6 = 1, ____n_5 do
            local id = ____items_5[____i_6]
            local ____result_5
            do
                local ____value_2 = ____World.Entity.new(id)
                ____result_5 = __K2L_Triple.new(____value_2, __K2L_NotNull(a:get(____value_2)), __K2L_NotNull(b:get(____value_2)))
            end
            ____count_5 = ____count_5 + 1
            ____out_5[____count_5] = ____result_5
        end
        ____result_4 = __K2L_ListWrap(____out_5, ____count_5)
    end
    local targets = ____result_4
    for ____i_8 = 1, attackers.size do
        local ____item_1 = attackers[____i_8]
        local a, apos, dmg = ____item_1.first, ____item_1.second, ____item_1.third
        for ____i_7 = 1, targets.size do
            local ____item_2 = targets[____i_7]
            local t, tpos, health = ____item_2.first, ____item_2.second, ____item_2.third
            do
                if a:equals(t) or health:getDead() then
                    goto ____continue
                end
                local dist = distance(apos, tpos)
                if dist <= dmg.range then
                    health.hp = health.hp - dmg.amount
                    world.log:add("t" .. world.tick .. ": " .. nameOf(world, a) .. " hits " .. nameOf(world, t) .. " for " .. dmg.amount .. " (hp " .. health.hp .. ")")
                end
            end
            ::____continue::
        end
    end
end

local Reaper = __K2L_Class("sim.game.Reaper", ____World.System)

function Reaper:____init()
    ____World.System.____init(self, "reaper")
end

function Reaper:update(world, dt)
    local ____result_6
    do
        local s = world:store(__K2L_NotNull("Health"))
        local ____list_7 = s:ids()
        local ____out_6 = {}
        local ____count_6 = 0
        local ____items_6, ____n_6 = ____list_7:____array()
        for ____i_9 = 1, ____n_6 do
            local it = ____items_6[____i_9]
            if world:isAlive(it) then
                ____count_6 = ____count_6 + 1
                ____out_6[____count_6] = it
            end
        end
        local ____list_8 = __K2L_ListWrap(____out_6, ____count_6)
        local ____out_7 = {}
        local ____count_7 = 0
        local ____items_7, ____n_7 = ____list_8:____array()
        for ____i_10 = 1, ____n_7 do
            local it = ____items_7[____i_10]
            ____count_7 = ____count_7 + 1
            ____out_7[____count_7] = __K2L_Pair.new(____World.Entity.new(it), __K2L_NotNull(s:get(____World.Entity.new(it))))
        end
        ____result_6 = __K2L_ListWrap(____out_7, ____count_7)
    end
    local ____list_9 = ____result_6
    local ____out_8 = {}
    local ____count_8 = 0
    local ____items_8, ____n_8 = ____list_9:____array()
    for ____i_11 = 1, ____n_8 do
        local ____it = ____items_8[____i_11]
        local ____result_7
        do
            local h = ____it.second
            ____result_7 = h:getDead()
        end
        if ____result_7 then
            ____count_8 = ____count_8 + 1
            ____out_8[____count_8] = ____it
        end
    end
    local ____list_10 = __K2L_ListWrap(____out_8, ____count_8)
    for ____i_12 = 1, ____list_10.size do
        local ____it_1 = ____list_10[____i_12]
        do
            local e = ____it_1.first
            local ____result_8
            do
                local ____result_9
                ____result_9 = world:store(__K2L_NotNull("Player")):get(e)
                ____result_8 = ____result_9 ~= nil
            end
            if ____result_8 then
                world.log:add("t" .. world.tick .. ": the player died")
            end
            world:destroy(e)
        end
    end
end

local Regeneration = __K2L_Class("sim.game.Regeneration", ____World.System)

function Regeneration:____init(every)
    ____World.System.____init(self, "regen")
    self.every = every
end

function Regeneration:update(world, dt)
    if world.tick % self.every ~= 0 then
        return
    end
    local ____result_10
    do
        local s = world:store(__K2L_NotNull("Health"))
        local ____list_11 = s:ids()
        local ____out_9 = {}
        local ____count_9 = 0
        local ____items_9, ____n_9 = ____list_11:____array()
        for ____i_13 = 1, ____n_9 do
            local it = ____items_9[____i_13]
            if world:isAlive(it) then
                ____count_9 = ____count_9 + 1
                ____out_9[____count_9] = it
            end
        end
        local ____list_12 = __K2L_ListWrap(____out_9, ____count_9)
        local ____out_10 = {}
        local ____count_10 = 0
        local ____items_10, ____n_10 = ____list_12:____array()
        for ____i_14 = 1, ____n_10 do
            local it = ____items_10[____i_14]
            ____count_10 = ____count_10 + 1
            ____out_10[____count_10] = __K2L_Pair.new(____World.Entity.new(it), __K2L_NotNull(s:get(____World.Entity.new(it))))
        end
        ____result_10 = __K2L_ListWrap(____out_10, ____count_10)
    end
    local ____list_13 = ____result_10
    for ____i_15 = 1, ____list_13.size do
        local ____it_2 = ____list_13[____i_15]
        do
            local h = ____it_2.second
            if not h:getDead() and h.hp < h.max then
                h.hp = h.hp + 1
            end
        end
    end
end

function distance(a, b)
    return math.max(math.abs(a.x - b.x), math.abs(a.y - b.y))
end

function nameOf(self, e)
    local ____result_11
    ____result_11 = self:store(__K2L_NotNull("Name")):get(e)
    local ____receiver = ____result_11
    return ____receiver and ____receiver.value or e:toString()
end

local ____lambda_1 = function(it) return "." end
local function render(____this, width, height)
    local ____out_11 = {}
    for ____i_16 = 1, height do
        local it = ____i_16 - 1
        local ____result_12
        ____result_12 = __K2L_ListOfSize(width, ____lambda_1, true)
        ____out_11[____i_16] = ____result_12
    end
    local grid = __K2L_ListWrap(____out_11, height)
    local ____result_13
    do
        local s = ____this:store(__K2L_NotNull("Position"))
        local ____list_14 = s:ids()
        local ____out_12 = {}
        local ____count_11 = 0
        local ____items_11, ____n_11 = ____list_14:____array()
        for ____i_17 = 1, ____n_11 do
            local it = ____items_11[____i_17]
            if ____this:isAlive(it) then
                ____count_11 = ____count_11 + 1
                ____out_12[____count_11] = it
            end
        end
        local ____list_15 = __K2L_ListWrap(____out_12, ____count_11)
        local ____out_13 = {}
        local ____count_12 = 0
        local ____items_12, ____n_12 = ____list_15:____array()
        for ____i_18 = 1, ____n_12 do
            local it = ____items_12[____i_18]
            ____count_12 = ____count_12 + 1
            ____out_13[____count_12] = __K2L_Pair.new(____World.Entity.new(it), __K2L_NotNull(s:get(____World.Entity.new(it))))
        end
        ____result_13 = __K2L_ListWrap(____out_13, ____count_12)
    end
    local ____list_16 = ____result_13
    for ____i_19 = 1, ____list_16.size do
        local ____item_3 = ____list_16[____i_19]
        local e, pos = ____item_3.first, ____item_3.second
        local c
        local ____result_16
        do
            local ____result_17
            ____result_17 = ____this:store(__K2L_NotNull("Player")):get(e)
            ____result_16 = ____result_17 ~= nil
        end
        if ____result_16 then
            c = "@"
        else
            local ____result_14
            do
                local ____result_15
                ____result_15 = ____this:store(__K2L_NotNull("Damage")):get(e)
                ____result_14 = ____result_15 ~= nil
            end
            if ____result_14 then
                c = "M"
            else
                c = __K2L_Text.first(nameOf(____this, e)):lower()
            end
        end
        local ____object = grid:get(pos.y)
        local ____key = pos.x
        if ____key < 0 or ____key >= ____object.size then
            __K2L_IndexError(____key, ____object.size, "array")
        end
        ____object[____key + 1] = c
    end
    local ____out_14 = {}
    local ____count_13 = 0
    local ____items_13, ____n_13 = grid:____array()
    for ____i_20 = 1, ____n_13 do
        local it = ____items_13[____i_20]
        ____count_13 = ____count_13 + 1
        ____out_14[____count_13] = __K2L_Text.string(it)
    end
    return __K2L_ListWrap(____out_14, ____count_13)
end

return {Position = Position, Velocity = Velocity, Health = Health, Name = Name, Damage = Damage, Player = Player, Movement = Movement, Combat = Combat, Reaper = Reaper, Regeneration = Regeneration, distance = distance, nameOf = nameOf, render = render}
-- ==== main.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Triple = ____lualib.__K2L_Triple

local ____World = require("ecs.World")
local ____Systems = require("game.Systems")
local Counter = __K2L_Class("sim.Counter", ____World.System)

function Counter:____init()
    ____World.System.____init(self, "counter")
    self.seen = __K2L_MapOf()
end

local ____lambda_1 = function(____p1, ____p2) return ____p1 + ____p2 end
function Counter:update(world, dt)
    local ____result
    do
        local s = world:store(__K2L_NotNull("Health"))
        local ____list = s:ids()
        local ____out = {}
        local ____count = 0
        local ____items, ____n = ____list:____array()
        for ____i = 1, ____n do
            local it = ____items[____i]
            if world:isAlive(it) then
                ____count = ____count + 1
                ____out[____count] = it
            end
        end
        local ____list_1 = __K2L_ListWrap(____out, ____count)
        local ____out_1 = {}
        local ____count_1 = 0
        local ____items_1, ____n_1 = ____list_1:____array()
        for ____i_1 = 1, ____n_1 do
            local it = ____items_1[____i_1]
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = __K2L_Pair.new(____World.Entity.new(it), __K2L_NotNull(s:get(____World.Entity.new(it))))
        end
        ____result = __K2L_ListWrap(____out_1, ____count_1)
    end
    local ____list_2 = ____result
    for ____i_2 = 1, ____list_2.size do
        local ____item = ____list_2[____i_2]
        local e = ____item.first
        self.seen:merge(____Systems.nameOf(world, e), 1, ____lambda_1)
    end
end

local function main()
    local width = 12
    local height = 5
    local counter = Counter.new()
    local world = ____World.World.new():addSystem(____Systems.Movement.new(width, height)):addSystem(____Systems.Combat.new()):addSystem(____Systems.Regeneration.new(3)):addSystem(____Systems.Reaper.new()):addSystem(counter)
    local hero = world:spawn(____Systems.Player, ____Systems.Name.new("hero"), ____Systems.Position.new(1, 2), ____Systems.Velocity.new(1, 0), ____Systems.Health.new(12, 12), ____Systems.Damage.new(3, 1))
    local orc = world:spawn(____Systems.Name.new("orc"), ____Systems.Position.new(6, 2), ____Systems.Velocity.new(-1, 0), ____Systems.Health.new(8, 8), ____Systems.Damage.new(2, 1))
    local bat = world:spawn(____Systems.Name.new("bat"), ____Systems.Position.new(10, 0), ____Systems.Velocity.new(1, 1), ____Systems.Health.new(3, 3), ____Systems.Damage.new(1, 0))
    world:spawn(____Systems.Name.new("tree"), ____Systems.Position.new(4, 4))
    local ghost = world:spawn(____Systems.Name.new("ghost"), ____Systems.Health.new(1, 1))
    print(__K2L_Str(world))
    local ____result_1
    do
        local ____result_2
        do
            local s = world:store(__K2L_NotNull("Position"))
            local ____list_3 = s:ids()
            local ____out_2 = {}
            local ____count_2 = 0
            local ____items_2, ____n_2 = ____list_3:____array()
            for ____i_3 = 1, ____n_2 do
                local it = ____items_2[____i_3]
                if world:isAlive(it) then
                    ____count_2 = ____count_2 + 1
                    ____out_2[____count_2] = it
                end
            end
            local ____list_4 = __K2L_ListWrap(____out_2, ____count_2)
            local ____out_3 = {}
            local ____count_3 = 0
            local ____items_3, ____n_3 = ____list_4:____array()
            for ____i_4 = 1, ____n_3 do
                local it = ____items_3[____i_4]
                ____count_3 = ____count_3 + 1
                ____out_3[____count_3] = __K2L_Pair.new(____World.Entity.new(it), __K2L_NotNull(s:get(____World.Entity.new(it))))
            end
            ____result_2 = __K2L_ListWrap(____out_3, ____count_3)
        end
        local items = ____result_2
        ____result_1 = __K2L_Str("Position") .. ": " .. items:joinToString(nil, nil, nil, nil, nil, function(____destructured)
            local e, c = ____destructured.first, ____destructured.second
            return __K2L_Str(e) .. "=" .. __K2L_Str(c)
        end)
    end
    print(____result_1)
    local ____result_3
    do
        local ____result_4
        do
            local s = world:store(__K2L_NotNull("Health"))
            local ____list_5 = s:ids()
            local ____out_4 = {}
            local ____count_4 = 0
            local ____items_4, ____n_4 = ____list_5:____array()
            for ____i_5 = 1, ____n_4 do
                local it = ____items_4[____i_5]
                if world:isAlive(it) then
                    ____count_4 = ____count_4 + 1
                    ____out_4[____count_4] = it
                end
            end
            local ____list_6 = __K2L_ListWrap(____out_4, ____count_4)
            local ____out_5 = {}
            local ____count_5 = 0
            local ____items_5, ____n_5 = ____list_6:____array()
            for ____i_6 = 1, ____n_5 do
                local it = ____items_5[____i_6]
                ____count_5 = ____count_5 + 1
                ____out_5[____count_5] = __K2L_Pair.new(____World.Entity.new(it), __K2L_NotNull(s:get(____World.Entity.new(it))))
            end
            ____result_4 = __K2L_ListWrap(____out_5, ____count_5)
        end
        local items = ____result_4
        ____result_3 = __K2L_Str("Health") .. ": " .. items:joinToString(nil, nil, nil, nil, nil, function(____destructured_1)
            local e, c = ____destructured_1.first, ____destructured_1.second
            return __K2L_Str(e) .. "=" .. __K2L_Str(c)
        end)
    end
    print(____result_3)
    local ____result_5
    do
        local ____result_6
        ____result_6 = world:store(__K2L_NotNull("Player")):get(hero)
        ____result_5 = ____result_6 ~= nil
    end
    local ____arg = tostring(____result_5)
    local ____result_7
    do
        local ____result_8
        ____result_8 = world:store(__K2L_NotNull("Player")):get(orc)
        ____result_7 = ____result_8 ~= nil
    end
    local ____arg_1 = tostring(____result_7)
    local ____result_9
    ____result_9 = world:store(__K2L_NotNull("Position")):get(ghost)
    print("hero has player: " .. ____arg .. ", orc: " .. ____arg_1 .. ", ghost pos: " .. __K2L_Str(____result_9))
    for t = 1, 8 do
        world:step()
        print("-- tick " .. world.tick .. ": population " .. world:getPopulation())
        local ____list_7 = ____Systems.render(world, width, height)
        for ____i_7 = 1, ____list_7.size do
            local it = ____list_7[____i_7]
            print("   " .. it)
        end
    end
    local ____list_8 = world.log
    for ____i_8 = 1, ____list_8.size do
        local it = ____list_8[____i_8]
        print(it)
    end
    local ____result_10
    do
        local ____result_11
        do
            local s = world:store(__K2L_NotNull("Health"))
            local ____list_9 = s:ids()
            local ____out_6 = {}
            local ____count_6 = 0
            local ____items_6, ____n_6 = ____list_9:____array()
            for ____i_9 = 1, ____n_6 do
                local it = ____items_6[____i_9]
                if world:isAlive(it) then
                    ____count_6 = ____count_6 + 1
                    ____out_6[____count_6] = it
                end
            end
            local ____list_10 = __K2L_ListWrap(____out_6, ____count_6)
            local ____out_7 = {}
            local ____count_7 = 0
            local ____items_7, ____n_7 = ____list_10:____array()
            for ____i_10 = 1, ____n_7 do
                local it = ____items_7[____i_10]
                ____count_7 = ____count_7 + 1
                ____out_7[____count_7] = __K2L_Pair.new(____World.Entity.new(it), __K2L_NotNull(s:get(____World.Entity.new(it))))
            end
            ____result_11 = __K2L_ListWrap(____out_7, ____count_7)
        end
        local items = ____result_11
        ____result_10 = __K2L_Str("Health") .. ": " .. items:joinToString(nil, nil, nil, nil, nil, function(____destructured_2)
            local e, c = ____destructured_2.first, ____destructured_2.second
            return __K2L_Str(e) .. "=" .. __K2L_Str(c)
        end)
    end
    print(____result_10)
    local ____arg_2 = tostring(world:isAlive(bat.id))
    local ____arg_3 = tostring(world:isAlive(orc.id))
    local ____result_12
    ____result_12 = world:store(__K2L_NotNull("Health")):get(orc)
    print("bat alive: " .. ____arg_2 .. ", orc alive: " .. ____arg_3 .. ", orc health: " .. __K2L_Str(____result_12))
    print("systems: " .. __K2L_Str(world:systems__1()))
    print("counter: " .. __K2L_Str(counter.seen:toSortedMap()))
    world:add(ghost, ____Systems.Position.new(0, 0))
    world:add(hero, ____Systems.Velocity.new(0, 1))
    world:step(2)
    local ____result_13
    do
        local ____result_14
        do
            local s = world:store(__K2L_NotNull("Position"))
            local ____list_11 = s:ids()
            local ____out_8 = {}
            local ____count_8 = 0
            local ____items_8, ____n_8 = ____list_11:____array()
            for ____i_11 = 1, ____n_8 do
                local it = ____items_8[____i_11]
                if world:isAlive(it) then
                    ____count_8 = ____count_8 + 1
                    ____out_8[____count_8] = it
                end
            end
            local ____list_12 = __K2L_ListWrap(____out_8, ____count_8)
            local ____out_9 = {}
            local ____count_9 = 0
            local ____items_9, ____n_9 = ____list_12:____array()
            for ____i_12 = 1, ____n_9 do
                local it = ____items_9[____i_12]
                ____count_9 = ____count_9 + 1
                ____out_9[____count_9] = __K2L_Pair.new(____World.Entity.new(it), __K2L_NotNull(s:get(____World.Entity.new(it))))
            end
            ____result_14 = __K2L_ListWrap(____out_9, ____count_9)
        end
        local items = ____result_14
        ____result_13 = __K2L_Str("Position") .. ": " .. items:joinToString(nil, nil, nil, nil, nil, function(____destructured_3)
            local e, c = ____destructured_3.first, ____destructured_3.second
            return __K2L_Str(e) .. "=" .. __K2L_Str(c)
        end)
    end
    print(____result_13)
    local ____result_15
    do
        local a = world:store(__K2L_NotNull("Name"))
        local b = world:store(__K2L_NotNull("Velocity"))
        local ____list_13 = a:ids()
        local ____out_10 = {}
        local ____count_10 = 0
        local ____items_10, ____n_10 = ____list_13:____array()
        for ____i_13 = 1, ____n_10 do
            local it = ____items_10[____i_13]
            if b:ids():contains(it) and world:isAlive(it) then
                ____count_10 = ____count_10 + 1
                ____out_10[____count_10] = it
            end
        end
        local ____list_14 = __K2L_ListWrap(____out_10, ____count_10)
        local ____out_11 = {}
        local ____count_11 = 0
        local ____items_11, ____n_11 = ____list_14:____array()
        for ____i_14 = 1, ____n_11 do
            local id = ____items_11[____i_14]
            local ____result_16
            do
                local ____value = ____World.Entity.new(id)
                ____result_16 = __K2L_Triple.new(____value, __K2L_NotNull(a:get(____value)), __K2L_NotNull(b:get(____value)))
            end
            ____count_11 = ____count_11 + 1
            ____out_11[____count_11] = ____result_16
        end
        ____result_15 = __K2L_ListWrap(____out_11, ____count_11)
    end
    local ____list_15 = ____result_15
    local ____out_12 = {}
    local ____count_12 = 0
    local ____items_12, ____n_12 = ____list_15:____array()
    for ____i_15 = 1, ____n_12 do
        local ____it_2 = ____items_12[____i_15]
        local ____result_17
        do
            local n, v = ____it_2.second, ____it_2.third
            ____result_17 = n.value .. ":" .. v.dx .. "," .. v.dy
        end
        ____count_12 = ____count_12 + 1
        ____out_12[____count_12] = ____result_17
    end
    print(__K2L_Str(__K2L_ListWrap(____out_12, ____count_12)))
    print(__K2L_Str(world))
end

__K2L_RunMain(main)
return {Counter = Counter}
