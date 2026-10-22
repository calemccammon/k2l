-- ==== core/Plugin.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_LazyObject = ____lualib.__K2L_LazyObject
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Uninitialized = ____lualib.__K2L_Uninitialized

local Plugin = __K2L_Class("arena.core.Plugin")

function Plugin:getDependsOn()
    return __K2L_ListOf()
end

function Plugin:onTick(tick, world) end

function Plugin:onEvent(event, world)
    return false
end

local PluginFactory = __K2L_Class("arena.core.PluginFactory")
local BasePlugin = __K2L_Class("arena.core.BasePlugin", nil, Plugin)

function BasePlugin:____init(id, ...)
    local deps = __K2L_ArrayOf(...)
    self.id = id
    self.deps = deps
end

function BasePlugin:getDependsOn()
    return self.deps:toList()
end

function BasePlugin:install(ctx)
    self.ctx = ctx
    ctx:log("install " .. self.id .. (self.deps:isEmpty() and "" or " after " .. self.deps:joinToString()))
    self:setup()
end

function BasePlugin:setup() end

function BasePlugin:toString()
    return "Plugin(" .. self.id .. ")"
end

local PluginException = __K2L_Class("arena.core.PluginException", __K2L_RuntimeException)

function PluginException:____init(pluginId, cause)
    __K2L_RuntimeException.____init(self, "plugin " .. pluginId .. " failed: " .. __K2L_Str(cause.message), cause)
    self.pluginId = pluginId
end

local PluginRegistry = __K2L_Class("arena.core.PluginRegistry")

function PluginRegistry:____init()
    self.factories = __K2L_MapOf()
    self.lookups = 0
    print("registry ready")
end

function PluginRegistry:register(factory)
    if self.factories:containsKey(factory:getPluginId()) then
        error(__K2L_IllegalStateException.new("duplicate plugin " .. factory:getPluginId()))
    end
    local ____object = self.factories
    local ____key = factory:getPluginId()
    ____object:set(____key, factory)
    return self
end

function PluginRegistry:getIds()
    return self.factories:getKeys()
end

function PluginRegistry:discover()
    local created = self.factories:mapValues(function(____destructured)
        local f = ____destructured.value
        return f:create()
    end)
    local ordered = __K2L_Map.new()
    local visiting = __K2L_SetOf()
    local function visit(id, from)
        self.lookups = self.lookups + 1
        if ordered:containsKey(id) then
            return
        end
        local ____value = created:get(id)
        if ____value == nil then
            error(__K2L_IllegalArgumentException.new("unknown plugin " .. id .. " needed by " .. __K2L_Str(from)))
        end
        local plugin = ____value
        if not visiting:add(id) then
            error(__K2L_IllegalStateException.new("dependency cycle at " .. id))
        end
        local ____list = plugin:getDependsOn():sorted()
        for ____i = 1, ____list.size do
            local it = ____list[____i]
            visit(it, id)
        end
        visiting:remove(id)
        ordered:set(id, plugin)
    end
    local ____list_1 = created:getKeys():sorted()
    for ____i_1 = 1, ____list_1.size do
        local it = ____list_1[____i_1]
        visit(it, nil)
    end
    return ordered:getValues():toList()
end

function PluginRegistry:clear()
    self.factories:clear()
end

__K2L_LazyObject(PluginRegistry, "____init")
return {Plugin = Plugin, PluginFactory = PluginFactory, BasePlugin = BasePlugin, PluginException = PluginException, PluginRegistry = PluginRegistry}
-- ==== core/World.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map

local Unit = __K2L_Class("arena.core.Unit")

function Unit:____init(name, hp, x, team)
    self.name = name
    self.hp = hp
    self.x = x
    self.team = team
end

function Unit.new(name, hp, x, team)
    return setmetatable({name = name, hp = hp, x = x, team = team}, Unit)
end

function Unit:toString()
    return "Unit(name=" .. self.name .. ", hp=" .. self.hp .. ", x=" .. self.x .. ", team=" .. self.team .. ")"
end

function Unit:hashCode()
    return (31 * (31 * (31 * __K2L_Hash(self.name) + self.hp) + self.x) + __K2L_Hash(self.team) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Unit:equals(other)
    return getmetatable(other) == Unit and self.name == other.name and self.hp == other.hp and self.x == other.x and self.team == other.team
end

local Event = __K2L_Class("arena.core.Event")
Event.Moved = __K2L_Class("arena.core.Event$Moved", nil, Event)

function Event.Moved:____init(unit, to)
    self.unit = unit
    self.to = to
end

function Event.Moved.new(unit, to)
    return setmetatable({unit = unit, to = to}, Event.Moved)
end

function Event.Moved:toString()
    return "Moved(unit=" .. self.unit .. ", to=" .. self.to .. ")"
end

function Event.Moved:hashCode()
    return (31 * __K2L_Hash(self.unit) + self.to + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Event.Moved:equals(other)
    return getmetatable(other) == Event.Moved and self.unit == other.unit and self.to == other.to
end

Event.Attack = __K2L_Class("arena.core.Event$Attack", nil, Event)

function Event.Attack:____init(attacker, target, power)
    self.attacker = attacker
    self.target = target
    self.power = power
end

function Event.Attack.new(attacker, target, power)
    return setmetatable({attacker = attacker, target = target, power = power}, Event.Attack)
end

function Event.Attack:toString()
    return "Attack(attacker=" .. self.attacker .. ", target=" .. self.target .. ", power=" .. self.power .. ")"
end

function Event.Attack:hashCode()
    return (31 * (31 * __K2L_Hash(self.attacker) + __K2L_Hash(self.target)) + self.power + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Event.Attack:equals(other)
    return getmetatable(other) == Event.Attack and self.attacker == other.attacker and self.target == other.target and self.power == other.power
end

Event.Died = __K2L_Class("arena.core.Event$Died", nil, Event)

function Event.Died:____init(unit)
    self.unit = unit
end

function Event.Died.new(unit)
    return setmetatable({unit = unit}, Event.Died)
end

function Event.Died:toString()
    return "Died(unit=" .. self.unit .. ")"
end

function Event.Died:hashCode()
    return __K2L_Hash(self.unit)
end

function Event.Died:equals(other)
    return getmetatable(other) == Event.Died and self.unit == other.unit
end

Event.RoundOver = __K2L_Class("arena.core.Event$RoundOver", nil, Event)

function Event.RoundOver:toString()
    return "RoundOver"
end

function Event.RoundOver:hashCode()
    return 1341314342
end

local World = __K2L_Class("arena.core.World")

function World:____init(width)
    self.width = width
    self.units = __K2L_ListOf()
    self.queue = __K2L_ArrayDeque.new()
    self.history = __K2L_ListOf()
end

function World:post(e)
    self.queue:addLast(e)
end

function World:get(name)
    local ____list = self.units
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

local function alive(self, team)
    if team == nil then
        team = nil
    end
    local ____list_1 = self.units
    local ____out = {}
    local ____count = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        if it.hp > 0 and (team == nil or it.team == team) then
            ____count = ____count + 1
            ____out[____count] = it
        end
    end
    return __K2L_ListWrap(____out, ____count)
end

local function getTeams(____this)
    local ____list_2 = alive(____this)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_2, ____n_2 = ____list_2:____array()
    for ____i_2 = 1, ____n_2 do
        local it = ____items_2[____i_2]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = it.team
    end
    return __K2L_ListWrap(____out_1, ____count_1):toSortedSet()
end

local Context = __K2L_Class("arena.core.Context")

function Context:____init(logger)
    self.logger = logger
    self.services = __K2L_Map.new()
end

function Context:log(msg)
    self.logger(msg)
end

function Context:provide(____type, service)
    local ____object = self.services
    ____object:set(____type, service)
end

function Context:lookup(____type)
    return self.services:get(____type)
end

return {Unit = Unit, Event = Event, World = World, alive = alive, getTeams = getTeams, Context = Context}
-- ==== host/Host.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Uninitialized = ____lualib.__K2L_Uninitialized

local ____World = require("core.World")
local ____Plugin = require("core.Plugin")
local Host = __K2L_Class("arena.host.Host")

function Host:____init(world, maxTicks)
    self.world = world
    self.maxTicks = maxTicks
    self.log = __K2L_ListOf()
    self.context = ____World.Context.new(function(it)
        self.log:add(it)
    end)
end

function Host:getInstalled()
    if self.plugins ~= nil then
        local ____list = self.plugins or __K2L_Uninitialized("plugins")
        local ____out = {}
        local ____count = 0
        local ____items, ____n = ____list:____array()
        for ____i = 1, ____n do
            local it = ____items[____i]
            ____count = ____count + 1
            ____out[____count] = it.id
        end
        return __K2L_ListWrap(____out, ____count)
    else
        return __K2L_ListOf()
    end
end

function Host:getCtx()
    return self.context
end

function Host:boot(registry)
    self.plugins = registry:discover()
    local ____list_1 = self.plugins or __K2L_Uninitialized("plugins")
    for ____i_1 = 1, ____list_1.size do
        local it = ____list_1[____i_1]
        it:install(self.context)
    end
end

function Host:run()
    local tick = 0
    while tick < self.maxTicks and ____World.getTeams(self.world).size > 1 do
        tick = tick + 1
        local ____list_2 = self.plugins or __K2L_Uninitialized("plugins")
        for ____i_2 = 1, ____list_2.size do
            local p = ____list_2[____i_2]
            local ____ok, ____result = pcall(function()
                p:onTick(tick, self.world)
            end)
            if not ____ok then
                local ____error = __K2L_ToThrowable(____result)
                if __K2L_InstanceOf(____error, __K2L_IllegalStateException) then
                    local e = ____error
                    error(____Plugin.PluginException.new(p.id, e))
                else
                    error(____error, 0)
                end
            end
        end
        self:drain()
    end
    self.world:post(____World.Event.RoundOver)
    self:drain()
    return tick
end

function Host:drain()
    while self.world.queue:isNotEmpty() do
        local e = self.world.queue:removeFirst()
        local ____list_3 = self.plugins or __K2L_Uninitialized("plugins")
        local ____result_1
        local ____items_1, ____n_1 = ____list_3:____array()
        for ____i_3 = 1, ____n_1 do
            local it = ____items_1[____i_3]
            if it:onEvent(e, self.world) then
                ____result_1 = it
                break
            end
        end
        local consumer = ____result_1
        if getmetatable(e) == ____World.Event.Died or e == ____World.Event.RoundOver then
            self.log:add(__K2L_Str(e) .. " -> " .. (consumer and consumer.id or "nobody"))
        end
    end
end

local ____lambda_1 = function(it)
    return it.name .. "(" .. it.hp .. "@" .. it.x .. ")"
end
function Host:summary()
    return ____World.alive(self.world):joinToString(nil, nil, nil, nil, nil, ____lambda_1)
end

return {Host = Host}
-- ==== main.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_TouchObject = ____lualib.__K2L_TouchObject

local ____Plugin = require("core.Plugin")
local ____Scoring = require("plugins.Scoring")
local ____Combat = require("plugins.Combat")
local ____Movement = require("plugins.Movement")
local ____World = require("core.World")
local ____Host = require("host.Host")

local ____lambda_1 = function()
    return ____Plugin.PluginRegistry:register(____Combat.CombatPlugin.Factory)
end
local ____lambda_2 = function() return ____Plugin.PluginRegistry:discover() end
local function main()
    print("before registry")
    ____Plugin.PluginRegistry:register(____Scoring.ScoringPlugin):register(____Combat.CombatPlugin.Factory):register(____Movement.MovementPlugin.Companion)
    print("registered " .. __K2L_Str(____Plugin.PluginRegistry:getIds()))
    local ____receiver = __K2L_RunCatching(____lambda_1):exceptionOrNull()
    print(__K2L_Str(____receiver and ____receiver.message))
    local world = ____World.World.new(8)
    world.units:addAll(__K2L_ListOf(____World.Unit.new("knight", 9, 0, "A"), ____World.Unit.new("archer", 6, 1, "A"), ____World.Unit.new("mage", 7, 7, "B"), ____World.Unit.new("brute", 12, 6, "B")))
    local host = ____Host.Host.new(world, 20)
    print("installed before boot: " .. __K2L_Str(host:getInstalled()))
    host:boot(__K2L_TouchObject(____Plugin.PluginRegistry))
    print("installed " .. __K2L_Str(host:getInstalled()) .. ", lookups " .. ____Plugin.PluginRegistry.lookups)
    local ticks = host:run()
    print("finished after " .. ticks .. " ticks: " .. host:summary())
    local ____list = host.log
    for ____i = 1, ____list.size do
        local it = ____list[____i]
        print("  " .. it)
    end
    local ____list_1 = world.history
    for ____i_1 = 1, ____list_1.size do
        local it = ____list_1[____i_1]
        print("  " .. it)
    end
    local ____result
    do
        local ____this = host:getCtx()
        local ____value = ____this:lookup(__K2L_NotNull("Scoreboard"))
        if ____value == nil then
            error(__K2L_IllegalStateException.new("no service " .. __K2L_Str("Scoreboard")))
        end
        ____result = ____value
    end
    print("kills " .. __K2L_Str(____result.kills))
    ____Plugin.PluginRegistry:register(____Scoring.BrokenPlugin.Companion)
    print(__K2L_Str(__K2L_RunCatching(____lambda_2):exceptionOrNull()))
    ____Plugin.PluginRegistry:clear()
    print("cleared " .. __K2L_Str(____Plugin.PluginRegistry:getIds()) .. " " .. __K2L_Str(____Plugin.PluginRegistry:discover()))
end

__K2L_RunMain(main)
-- ==== plugins/Combat.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_Lazy = ____lualib.__K2L_Lazy
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_Uninitialized = ____lualib.__K2L_Uninitialized

local ____Plugin = require("core.Plugin")
local ____World = require("core.World")
local ____damageTable_delegate = __K2L_Lazy(function()
    print("building damage table")
    return __K2L_MapOf(__K2L_Pair.new("k", 4), __K2L_Pair.new("a", 3), __K2L_Pair.new("m", 5))
end)
local CombatPlugin = __K2L_Class("arena.plugins.combat.CombatPlugin", ____Plugin.BasePlugin)

function CombatPlugin:____init(critEvery)
    ____Plugin.BasePlugin.____init(self, "combat", "movement")
    self.critEvery = critEvery
    self.swings = 0
end

function CombatPlugin:onTick(tick, world)
    local ____result
    do
        local ____this = self.ctx or __K2L_Uninitialized("ctx")
        local ____value = ____this:lookup(__K2L_NotNull("Grid"))
        if ____value == nil then
            error(__K2L_IllegalStateException.new("no service " .. __K2L_Str("Grid")))
        end
        ____result = ____value
    end
    local grid = ____result
    local ____list = ____World.alive(world)
    for ____i_1 = 1, ____list.size do
        local u = ____list[____i_1]
        do
            local ____list_1 = ____World.alive(world)
            local ____result_1
            local ____items, ____n = ____list_1:____array()
            for ____i = 1, ____n do
                local it = ____items[____i]
                if it.team ~= u.team and grid:distance(it.x, u.x) <= 1 then
                    ____result_1 = it
                    break
                end
            end
            if ____result_1 == nil then
                goto ____continue
            end
            local target = ____result_1
            self.swings = self.swings + 1
            local base = ____damageTable_delegate:getValue():get(__K2L_Text.first(u.name)) or 1
            world:post(____World.Event.Attack.new(u.name, target.name, self.swings % self.critEvery == 0 and base * 2 or base))
        end
        ::____continue::
    end
end

function CombatPlugin:onEvent(event, world)
    if getmetatable(event) ~= ____World.Event.Attack then
        return false
    end
    local ____value_1 = world:get(event.target)
    if ____value_1 == nil then
        return true
    end
    local target = ____value_1
    if target.hp <= 0 then
        return true
    end
    target.hp = target.hp - event.power
    if target.hp <= 0 then
        world:post(____World.Event.Died.new(target.name))
    end
    return false
end

CombatPlugin.Factory = __K2L_Class("arena.plugins.combat.CombatPlugin$Factory", nil, ____Plugin.PluginFactory)

function CombatPlugin.Factory:____init()
    self.pluginId = "combat"
end

function CombatPlugin.Factory:getPluginId()
    return self.pluginId
end

function CombatPlugin.Factory:create()
    return CombatPlugin.new(3)
end

CombatPlugin.Factory:____init()
return {____damageTable_delegate = ____damageTable_delegate, CombatPlugin = CombatPlugin}
-- ==== plugins/Movement.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Uninitialized = ____lualib.__K2L_Uninitialized

local ____Plugin = require("core.Plugin")
local ____World = require("core.World")
local Grid = __K2L_Class("arena.plugins.movement.Grid")

function Grid:____init(width)
    self.width = width
end

function Grid.new(width)
    return setmetatable({width = width}, Grid)
end

function Grid:clamp(x)
    return __K2L_Num.coerceIn(x, 0, self.width - 1)
end

function Grid:distance(a, b)
    return a > b and a - b or b - a
end

local MovementPlugin = __K2L_Class("arena.plugins.movement.MovementPlugin", ____Plugin.BasePlugin)

function MovementPlugin:____init()
    ____Plugin.BasePlugin.____init(self, "movement")
    self.moves = 0
end

function MovementPlugin:setup()
    (self.ctx or __K2L_Uninitialized("ctx")):provide(__K2L_NotNull("Grid"), Grid.new(8))
end

function MovementPlugin:onTick(tick, world)
    local ____result
    do
        local ____this = self.ctx or __K2L_Uninitialized("ctx")
        local ____value = ____this:lookup(__K2L_NotNull("Grid"))
        if ____value == nil then
            error(__K2L_IllegalStateException.new("no service " .. __K2L_Str("Grid")))
        end
        ____result = ____value
    end
    local grid = ____result
    local ____list = ____World.alive(world)
    for ____i_1 = 1, ____list.size do
        local u = ____list[____i_1]
        do
            local ____list_1 = ____World.alive(world)
            local ____out = {}
            local ____count = 0
            local ____items, ____n = ____list_1:____array()
            for ____i = 1, ____n do
                local it = ____items[____i]
                if it.team ~= u.team then
                    ____count = ____count + 1
                    ____out[____count] = it
                end
            end
            local ____value_1 = __K2L_ListWrap(____out, ____count):minByOrNull(function(it) return grid:distance(it.x, u.x) end)
            if ____value_1 == nil then
                goto ____continue
            end
            local enemy = ____value_1
            if grid:distance(enemy.x, u.x) > 1 then
                u.x = grid:clamp(u.x + (enemy.x > u.x and 1 or -1))
                self.moves = self.moves + 1
                world:post(____World.Event.Moved.new(u.name, u.x))
            end
        end
        ::____continue::
    end
end

function MovementPlugin:onEvent(event, world)
    if event == ____World.Event.RoundOver then
        (self.ctx or __K2L_Uninitialized("ctx")):log("movement made " .. self.moves .. " moves")
    end
    return false
end

MovementPlugin.Companion = __K2L_Class("arena.plugins.movement.MovementPlugin$Companion", nil, ____Plugin.PluginFactory)

function MovementPlugin.Companion:____init()
    self.pluginId__Companion = "movement"
end

function MovementPlugin.Companion:getPluginId()
    return self.pluginId__Companion
end

function MovementPlugin.Companion:create()
    return MovementPlugin.new()
end

MovementPlugin.Companion:____init()
return {Grid = Grid, MovementPlugin = MovementPlugin}
-- ==== plugins/Scoring.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Uninitialized = ____lualib.__K2L_Uninitialized

local ____Plugin = require("core.Plugin")
local ____World = require("core.World")
local Scoreboard = __K2L_Class("arena.plugins.scoring.Scoreboard")

function Scoreboard:____init()
    self.kills = __K2L_SortedMapOf(nil)
end

function Scoreboard:credit(unit)
    local ____object = self.kills
    ____object:set(unit, (self.kills:get(unit) or 0) + 1)
end

local ScoringPlugin = __K2L_Class("arena.plugins.scoring.ScoringPlugin", ____Plugin.BasePlugin, ____Plugin.PluginFactory)

function ScoringPlugin:____init()
    ____Plugin.BasePlugin.____init(self, "scoring", "combat")
    self.lastAttacker = __K2L_MapOf()
end

function ScoringPlugin:getPluginId()
    return self.id
end

function ScoringPlugin:create()
    return self
end

function ScoringPlugin:setup()
    (self.ctx or __K2L_Uninitialized("ctx")):provide(__K2L_NotNull("Scoreboard"), Scoreboard.new())
end

function ScoringPlugin:onEvent(event, world)
    local ____mt = getmetatable(event)
    if ____mt == ____World.Event.Attack then
        local ____object_1 = self.lastAttacker
        local ____key = event.target
        ____object_1:set(____key, event.attacker)
        return false
    elseif ____mt == ____World.Event.Died then
        local killer = self.lastAttacker:get(event.unit) or "?"
        local ____result
        do
            local ____this = self.ctx or __K2L_Uninitialized("ctx")
            local ____value = ____this:lookup(__K2L_NotNull("Scoreboard"))
            if ____value == nil then
                error(__K2L_IllegalStateException.new("no service " .. __K2L_Str("Scoreboard")))
            end
            ____result = ____value
        end
        ____result:credit(killer)
        world.history:add(event.unit .. " killed by " .. killer .. ", teams left " .. __K2L_Str(____World.getTeams(world)))
        return true
    else
        return false
    end
end

ScoringPlugin:____init()
local BrokenPlugin = __K2L_Class("arena.plugins.scoring.BrokenPlugin", ____Plugin.BasePlugin)

function BrokenPlugin:____init()
    ____Plugin.BasePlugin.____init(self, "broken", "teleport")
end

BrokenPlugin.Companion = __K2L_Class("arena.plugins.scoring.BrokenPlugin$Companion", nil, ____Plugin.PluginFactory)

function BrokenPlugin.Companion:____init()
    self.pluginId__Companion = "broken"
end

function BrokenPlugin.Companion:getPluginId()
    return self.pluginId__Companion
end

function BrokenPlugin.Companion:create()
    return BrokenPlugin.new()
end

BrokenPlugin.Companion:____init()
return {Scoreboard = Scoreboard, ScoringPlugin = ScoringPlugin, BrokenPlugin = BrokenPlugin}
