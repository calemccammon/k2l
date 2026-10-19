-- ==== ecs/World.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_Str = ____lualib.__K2L_Str

local World
local Component = __K2L_Class("sim.ecs.Component")
__K2L_ClassInfo(Component, "sim.ecs.Component", "sim.ecs.Component", "interface")
local Entity = __K2L_Class("sim.ecs.Entity")
__K2L_ClassInfo(Entity, "sim.ecs.Entity", "sim.ecs.Entity", "class")

function Entity:____init(id)
    self.id = id
end

function Entity:toString()
    return "e" .. self.id
end

function Entity:hashCode()
    return __K2L_Hash(self.id)
end

function Entity:equals(other)
    return getmetatable(other) == Entity and self.id == other.id
end

local Store = __K2L_Class("sim.ecs.Store")
__K2L_ClassInfo(Store, "sim.ecs.Store", "sim.ecs.Store", "class")

function Store:____init(____type)
    self.type = ____type
    self.items = __K2L_SortedMapOf()
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
    return __K2L_Str(self.type.simpleName) .. "x" .. self:getSize()
end

local System = __K2L_Class("sim.ecs.System")
__K2L_ClassInfo(System, "sim.ecs.System", "sim.ecs.System", "class")

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
__K2L_ClassInfo(World, "sim.ecs.World", "sim.ecs.World", "class")

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
    local ____cast = self.stores:getOrPut(__K2L_KClassOfValue(c), function() return Store.new(__K2L_KClassOfValue(c)) end)
    if not __K2L_InstanceOf(____cast, Store) then
        __K2L_CastFail(____cast, "sim.ecs.Store", "sim.ecs.Store")
    end
    local store = ____cast
    store:set(e, c)
end

function World:store(____type)
    local ____cast_1 = self.stores:getOrPut(____type, function() return Store.new(____type) end)
    if not __K2L_InstanceOf(____cast_1, Store) then
        __K2L_CastFail(____cast_1, "sim.ecs.Store", "sim.ecs.Store")
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
    local ____mod = ____list.____modCount
    for ____i_1 = 1, ____list.size do
        local s = ____list[____i_1]
        s:tick(self, dt)
        if ____list.____modCount ~= ____mod and ____list:____comodified(____i_1) then
            break
        end
    end
    local ____list_1 = self.pendingRemoval
    local ____mod_2 = ____list_1.____modCount
    for ____i_3 = 1, ____list_1.size do
        local e = ____list_1[____i_3]
        if self.alive:remove(e.id) then
            local ____collection = self.stores:getValues()
            local ____items, ____n = ____collection:____array()
            local ____mod_1 = ____collection.____modCount
            for ____i_2 = 1, ____n do
                local it = ____items[____i_2]
                it:remove(e)
                if ____collection.____modCount ~= ____mod_1 and ____collection:____comodified(____i_2, ____n) then
                    break
                end
            end
            self.log:add("t" .. self.tick .. ": " .. __K2L_Str(e) .. " destroyed")
        end
        if ____list_1.____modCount ~= ____mod_2 and ____list_1:____comodified(____i_3) then
            break
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
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IRem = ____lualib.__K2L_IRem
local __K2L_KClassOf = ____lualib.__K2L_KClassOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_Triple = ____lualib.__K2L_Triple

local ____World = require("ecs.World")
local distance, nameOf
local Position = __K2L_Class("sim.game.Position", nil, ____World.Component)
__K2L_ClassInfo(Position, "sim.game.Position", "sim.game.Position", "class")

function Position:____init(x, y)
    self.x = x
    self.y = y
end

function Position:toString()
    return "Position(x=" .. self.x .. ", y=" .. self.y .. ")"
end

function Position:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.x) + __K2L_Hash(self.y))
end

function Position:equals(other)
    return getmetatable(other) == Position and self.x == other.x and self.y == other.y
end

local Velocity = __K2L_Class("sim.game.Velocity", nil, ____World.Component)
__K2L_ClassInfo(Velocity, "sim.game.Velocity", "sim.game.Velocity", "class")

function Velocity:____init(dx, dy)
    self.dx = dx
    self.dy = dy
end

function Velocity:toString()
    return "Velocity(dx=" .. self.dx .. ", dy=" .. self.dy .. ")"
end

function Velocity:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.dx) + __K2L_Hash(self.dy))
end

function Velocity:equals(other)
    return getmetatable(other) == Velocity and self.dx == other.dx and self.dy == other.dy
end

local Health = __K2L_Class("sim.game.Health", nil, ____World.Component)
__K2L_ClassInfo(Health, "sim.game.Health", "sim.game.Health", "class")

function Health:____init(hp, max)
    self.hp = hp
    self.max = max
end

function Health:getDead()
    return self.hp <= 0
end

function Health:toString()
    return "Health(hp=" .. self.hp .. ", max=" .. self.max .. ")"
end

function Health:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.hp) + __K2L_Hash(self.max))
end

function Health:equals(other)
    return getmetatable(other) == Health and self.hp == other.hp and self.max == other.max
end

local Name = __K2L_Class("sim.game.Name", nil, ____World.Component)
__K2L_ClassInfo(Name, "sim.game.Name", "sim.game.Name", "class")

function Name:____init(value)
    self.value = value
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
__K2L_ClassInfo(Damage, "sim.game.Damage", "sim.game.Damage", "class")

function Damage:____init(amount, range)
    self.amount = amount
    self.range = range
end

function Damage:toString()
    return "Damage(amount=" .. self.amount .. ", range=" .. self.range .. ")"
end

function Damage:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.amount) + __K2L_Hash(self.range))
end

function Damage:equals(other)
    return getmetatable(other) == Damage and self.amount == other.amount and self.range == other.range
end

local Player = __K2L_Class("sim.game.Player", nil, ____World.Component)
__K2L_ClassInfo(Player, "sim.game.Player", "sim.game.Player", "class")

function Player:toString()
    return "Player"
end

local Movement = __K2L_Class("sim.game.Movement", ____World.System)
__K2L_ClassInfo(Movement, "sim.game.Movement", "sim.game.Movement", "class")

function Movement:____init(width, height)
    ____World.System.____init(self, "movement")
    self.width = width
    self.height = height
end

function Movement:update(world, dt)
    local ____result
    do
        local a = world:store(__K2L_KClassOf(Position))
        local b = world:store(__K2L_KClassOf(Velocity))
        ____result = a:ids():filter(function(it)
            return b:ids():contains(it) and world:isAlive(it)
        end):map(function(id)
            local ____value = ____World.Entity.new(id)
            return __K2L_Triple.new(____value, __K2L_NotNull(a:get(____value)), __K2L_NotNull(b:get(____value)))
        end)
    end
    local ____list = ____result
    local ____mod = ____list.____modCount
    for ____i = 1, ____list.size do
        local ____item = ____list[____i]
        local pos, vel = ____item.second, ____item.third
        pos.x = __K2L_Num.mod(pos.x + vel.dx * dt, self.width)
        pos.y = __K2L_Num.coerceIn(pos.y + vel.dy * dt, 0, self.height - 1)
        if ____list.____modCount ~= ____mod and ____list:____comodified(____i) then
            break
        end
    end
end

local Combat = __K2L_Class("sim.game.Combat", ____World.System)
__K2L_ClassInfo(Combat, "sim.game.Combat", "sim.game.Combat", "class")

function Combat:____init()
    ____World.System.____init(self, "combat")
end

function Combat:update(world, dt)
    local ____result_1
    do
        local a = world:store(__K2L_KClassOf(Position))
        local b = world:store(__K2L_KClassOf(Damage))
        ____result_1 = a:ids():filter(function(it)
            return b:ids():contains(it) and world:isAlive(it)
        end):map(function(id)
            local ____value_1 = ____World.Entity.new(id)
            return __K2L_Triple.new(____value_1, __K2L_NotNull(a:get(____value_1)), __K2L_NotNull(b:get(____value_1)))
        end)
    end
    local attackers = ____result_1
    local ____result_2
    do
        local a = world:store(__K2L_KClassOf(Position))
        local b = world:store(__K2L_KClassOf(Health))
        ____result_2 = a:ids():filter(function(it)
            return b:ids():contains(it) and world:isAlive(it)
        end):map(function(id)
            local ____value_2 = ____World.Entity.new(id)
            return __K2L_Triple.new(____value_2, __K2L_NotNull(a:get(____value_2)), __K2L_NotNull(b:get(____value_2)))
        end)
    end
    local targets = ____result_2
    local ____mod_2 = attackers.____modCount
    for ____i_2 = 1, attackers.size do
        local ____item_1 = attackers[____i_2]
        local a, apos, dmg = ____item_1.first, ____item_1.second, ____item_1.third
        local ____mod_1 = targets.____modCount
        for ____i_1 = 1, targets.size do
            local ____item_2 = targets[____i_1]
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
            if targets.____modCount ~= ____mod_1 and targets:____comodified(____i_1) then
                break
            end
        end
        if attackers.____modCount ~= ____mod_2 and attackers:____comodified(____i_2) then
            break
        end
    end
end

local Reaper = __K2L_Class("sim.game.Reaper", ____World.System)
__K2L_ClassInfo(Reaper, "sim.game.Reaper", "sim.game.Reaper", "class")

function Reaper:____init()
    ____World.System.____init(self, "reaper")
end

function Reaper:update(world, dt)
    local ____result_3
    do
        local s = world:store(__K2L_KClassOf(Health))
        ____result_3 = s:ids():filter(function(it) return world:isAlive(it) end):map(function(it)
            return __K2L_Pair.new(____World.Entity.new(it), __K2L_NotNull(s:get(____World.Entity.new(it))))
        end)
    end
    local ____list_1 = ____result_3:filter(function(____destructured)
        local h = ____destructured.second
        return h:getDead()
    end)
    local ____mod_3 = ____list_1.____modCount
    for ____i_3 = 1, ____list_1.size do
        local ____it = ____list_1[____i_3]
        do
            local e = ____it.first
            local ____result_4
            do
                local ____result_5
                ____result_5 = world:store(__K2L_KClassOf(Player)):get(e)
                ____result_4 = ____result_5 ~= nil
            end
            if ____result_4 then
                world.log:add("t" .. world.tick .. ": the player died")
            end
            world:destroy(e)
        end
        if ____list_1.____modCount ~= ____mod_3 and ____list_1:____comodified(____i_3) then
            break
        end
    end
end

local Regeneration = __K2L_Class("sim.game.Regeneration", ____World.System)
__K2L_ClassInfo(Regeneration, "sim.game.Regeneration", "sim.game.Regeneration", "class")

function Regeneration:____init(every)
    ____World.System.____init(self, "regen")
    self.every = every
end

function Regeneration:update(world, dt)
    if __K2L_IRem(world.tick, self.every) ~= 0 then
        return
    end
    local ____result_6
    do
        local s = world:store(__K2L_KClassOf(Health))
        ____result_6 = s:ids():filter(function(it) return world:isAlive(it) end):map(function(it)
            return __K2L_Pair.new(____World.Entity.new(it), __K2L_NotNull(s:get(____World.Entity.new(it))))
        end)
    end
    local ____list_2 = ____result_6
    local ____mod_4 = ____list_2.____modCount
    for ____i_4 = 1, ____list_2.size do
        local ____it_1 = ____list_2[____i_4]
        do
            local h = ____it_1.second
            if not h:getDead() and h.hp < h.max then
                h.hp = h.hp + 1
            end
        end
        if ____list_2.____modCount ~= ____mod_4 and ____list_2:____comodified(____i_4) then
            break
        end
    end
end

function distance(a, b)
    return math.max(math.abs(a.x - b.x), math.abs(a.y - b.y))
end

function nameOf(self, e)
    local ____result_7
    ____result_7 = self:store(__K2L_KClassOf(Name)):get(e)
    local ____receiver = ____result_7
    return ____receiver and ____receiver.value or e:toString()
end

local function render(____this, width, height)
    local grid = __K2L_ListOfSize(height, function(it)
        return __K2L_ListOfSize(width, function(it) return "." end, "[C")
    end)
    local ____result_8
    do
        local s = ____this:store(__K2L_KClassOf(Position))
        ____result_8 = s:ids():filter(function(it) return ____this:isAlive(it) end):map(function(it)
            return __K2L_Pair.new(____World.Entity.new(it), __K2L_NotNull(s:get(____World.Entity.new(it))))
        end)
    end
    local ____list_3 = ____result_8
    local ____mod_5 = ____list_3.____modCount
    for ____i_5 = 1, ____list_3.size do
        local ____item_3 = ____list_3[____i_5]
        local e, pos = ____item_3.first, ____item_3.second
        local c
        local ____result_11
        do
            local ____result_12
            ____result_12 = ____this:store(__K2L_KClassOf(Player)):get(e)
            ____result_11 = ____result_12 ~= nil
        end
        if ____result_11 then
            c = "@"
        else
            local ____result_9
            do
                local ____result_10
                ____result_10 = ____this:store(__K2L_KClassOf(Damage)):get(e)
                ____result_9 = ____result_10 ~= nil
            end
            if ____result_9 then
                c = "M"
            else
                c = __K2L_Text.first(nameOf(____this, e)):lower()
            end
        end
        local ____object = grid:get(pos.y)
        local ____key = pos.x
        ____object:set(____key, c)
        if ____list_3.____modCount ~= ____mod_5 and ____list_3:____comodified(____i_5) then
            break
        end
    end
    return grid:map(function(it) return __K2L_Text.string(it) end)
end

return {Position = Position, Velocity = Velocity, Health = Health, Name = Name, Damage = Damage, Player = Player, Movement = Movement, Combat = Combat, Reaper = Reaper, Regeneration = Regeneration, distance = distance, nameOf = nameOf, render = render}
-- ==== main.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_FunctionRef = ____lualib.__K2L_FunctionRef
local __K2L_KClassOf = ____lualib.__K2L_KClassOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Triple = ____lualib.__K2L_Triple

local ____World = require("ecs.World")
local ____Systems = require("game.Systems")
local Counter = __K2L_Class("sim.Counter", ____World.System)
__K2L_ClassInfo(Counter, "sim.Counter", "sim.Counter", "class")

function Counter:____init()
    ____World.System.____init(self, "counter")
    self.seen = __K2L_MapOf()
end

function Counter:update(world, dt)
    local ____result
    do
        local s = world:store(__K2L_KClassOf(____Systems.Health))
        ____result = s:ids():filter(function(it) return world:isAlive(it) end):map(function(it)
            return __K2L_Pair.new(____World.Entity.new(it), __K2L_NotNull(s:get(____World.Entity.new(it))))
        end)
    end
    local ____list = ____result
    local ____mod = ____list.____modCount
    for ____i = 1, ____list.size do
        local ____item = ____list[____i]
        local e = ____item.first
        self.seen:merge(____Systems.nameOf(world, e), 1, __K2L_FunctionRef.new("plus", "kotlin/Int.plus(kotlin.Int)", function(____p1, ____p2) return ____p1 + ____p2 end))
        if ____list.____modCount ~= ____mod and ____list:____comodified(____i) then
            break
        end
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
            local s = world:store(__K2L_KClassOf(____Systems.Position))
            ____result_2 = s:ids():filter(function(it) return world:isAlive(it) end):map(function(it)
                return __K2L_Pair.new(____World.Entity.new(it), __K2L_NotNull(s:get(____World.Entity.new(it))))
            end)
        end
        local items = ____result_2
        ____result_1 = __K2L_Str(__K2L_KClassOf(____Systems.Position).simpleName) .. ": " .. items:joinToString(nil, nil, nil, nil, nil, function(____destructured)
            local e, c = ____destructured.first, ____destructured.second
            return __K2L_Str(e) .. "=" .. __K2L_Str(c)
        end)
    end
    print(____result_1)
    local ____result_3
    do
        local ____result_4
        do
            local s = world:store(__K2L_KClassOf(____Systems.Health))
            ____result_4 = s:ids():filter(function(it) return world:isAlive(it) end):map(function(it)
                return __K2L_Pair.new(____World.Entity.new(it), __K2L_NotNull(s:get(____World.Entity.new(it))))
            end)
        end
        local items = ____result_4
        ____result_3 = __K2L_Str(__K2L_KClassOf(____Systems.Health).simpleName) .. ": " .. items:joinToString(nil, nil, nil, nil, nil, function(____destructured_1)
            local e, c = ____destructured_1.first, ____destructured_1.second
            return __K2L_Str(e) .. "=" .. __K2L_Str(c)
        end)
    end
    print(____result_3)
    local ____result_5
    do
        local ____result_6
        ____result_6 = world:store(__K2L_KClassOf(____Systems.Player)):get(hero)
        ____result_5 = ____result_6 ~= nil
    end
    local ____arg = ____result_5
    local ____result_7
    do
        local ____result_8
        ____result_8 = world:store(__K2L_KClassOf(____Systems.Player)):get(orc)
        ____result_7 = ____result_8 ~= nil
    end
    local ____arg_1 = ____result_7
    local ____result_9
    ____result_9 = world:store(__K2L_KClassOf(____Systems.Position)):get(ghost)
    print("hero has player: " .. tostring(____arg) .. ", orc: " .. tostring(____arg_1) .. ", ghost pos: " .. __K2L_Str(____result_9))
    for t = 1, 8 do
        world:step()
        print("-- tick " .. world.tick .. ": population " .. world:getPopulation())
        local ____list_1 = ____Systems.render(world, width, height)
        for ____i_1 = 1, ____list_1.size do
            local it = ____list_1[____i_1]
            print("   " .. it)
        end
    end
    local ____list_2 = world.log
    for ____i_2 = 1, ____list_2.size do
        local it = ____list_2[____i_2]
        print(it)
    end
    local ____result_10
    do
        local ____result_11
        do
            local s = world:store(__K2L_KClassOf(____Systems.Health))
            ____result_11 = s:ids():filter(function(it) return world:isAlive(it) end):map(function(it)
                return __K2L_Pair.new(____World.Entity.new(it), __K2L_NotNull(s:get(____World.Entity.new(it))))
            end)
        end
        local items = ____result_11
        ____result_10 = __K2L_Str(__K2L_KClassOf(____Systems.Health).simpleName) .. ": " .. items:joinToString(nil, nil, nil, nil, nil, function(____destructured_2)
            local e, c = ____destructured_2.first, ____destructured_2.second
            return __K2L_Str(e) .. "=" .. __K2L_Str(c)
        end)
    end
    print(____result_10)
    local ____arg_2 = world:isAlive(bat.id)
    local ____arg_3 = world:isAlive(orc.id)
    local ____result_12
    ____result_12 = world:store(__K2L_KClassOf(____Systems.Health)):get(orc)
    print("bat alive: " .. tostring(____arg_2) .. ", orc alive: " .. tostring(____arg_3) .. ", orc health: " .. __K2L_Str(____result_12))
    print("systems: " .. __K2L_Str(world:systems__1()))
    print("counter: " .. __K2L_Str(counter.seen:toSortedMap()))
    world:add(ghost, ____Systems.Position.new(0, 0))
    world:add(hero, ____Systems.Velocity.new(0, 1))
    world:step(2)
    local ____result_13
    do
        local ____result_14
        do
            local s = world:store(__K2L_KClassOf(____Systems.Position))
            ____result_14 = s:ids():filter(function(it) return world:isAlive(it) end):map(function(it)
                return __K2L_Pair.new(____World.Entity.new(it), __K2L_NotNull(s:get(____World.Entity.new(it))))
            end)
        end
        local items = ____result_14
        ____result_13 = __K2L_Str(__K2L_KClassOf(____Systems.Position).simpleName) .. ": " .. items:joinToString(nil, nil, nil, nil, nil, function(____destructured_3)
            local e, c = ____destructured_3.first, ____destructured_3.second
            return __K2L_Str(e) .. "=" .. __K2L_Str(c)
        end)
    end
    print(____result_13)
    local ____result_15
    do
        local a = world:store(__K2L_KClassOf(____Systems.Name))
        local b = world:store(__K2L_KClassOf(____Systems.Velocity))
        ____result_15 = a:ids():filter(function(it)
            return b:ids():contains(it) and world:isAlive(it)
        end):map(function(id)
            local ____value = ____World.Entity.new(id)
            return __K2L_Triple.new(____value, __K2L_NotNull(a:get(____value)), __K2L_NotNull(b:get(____value)))
        end)
    end
    print(__K2L_Str(____result_15:map(function(____destructured_4)
        local n, v = ____destructured_4.second, ____destructured_4.third
        return n.value .. ":" .. v.dx .. "," .. v.dy
    end)))
    print(__K2L_Str(world))
end

main()
return {Counter = Counter}
