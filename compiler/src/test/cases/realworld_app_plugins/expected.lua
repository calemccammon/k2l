-- ==== api/Plugin.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_LazyObject = ____lualib.__K2L_LazyObject
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Text = ____lualib.__K2L_Text

local initLog = __K2L_ListOf()

local function trace(what)
    initLog:add(what)
end

local Describable = __K2L_Class("host.api.Describable")
__K2L_ClassInfo(Describable, "host.api.Describable", "host.api.Describable", "interface")

function Describable:describe()
    return "Describable(" .. self:getId() .. ")"
end

local Lifecycle = __K2L_Class("host.api.Lifecycle")
__K2L_ClassInfo(Lifecycle, "host.api.Lifecycle", "host.api.Lifecycle", "interface")

function Lifecycle:start()
    return "start"
end

function Lifecycle:stop()
    return "stop"
end

function Lifecycle:describe()
    return "Lifecycle"
end

local Configurable = __K2L_Class("host.api.Configurable")
__K2L_ClassInfo(Configurable, "host.api.Configurable", "host.api.Configurable", "interface")

function Configurable:getSettings()
    return __K2L_ReadOnlyMapOf()
end

function Configurable:setting(key, default)
    return self:getSettings():get(key) or default
end

local Plugin = __K2L_Class("host.api.Plugin", nil, Describable, Lifecycle)
__K2L_ClassInfo(Plugin, "host.api.Plugin", "host.api.Plugin", "class")
Plugin.____comparable = true

function Plugin:____init(id, priority)
    if priority == nil then
        priority = 0
    end
    self.id = id
    self.priority = priority
    self.tag = "plugin"
    self.started = false
    trace("Plugin.init(" .. self:getId() .. ") tag=" .. self:getTag())
end

function Plugin:getId()
    return self.id
end

function Plugin:getDisplayName()
    return self:getId():upper()
end

function Plugin:getTag()
    return self.tag
end

function Plugin:describe()
    return Describable.describe(self) .. "+" .. Lifecycle.describe(self)
end

function Plugin:start()
    self.started = true
    return self:onStart() or Lifecycle.start(self)
end

function Plugin:onStart()
    return nil
end

local ____lambda_1 = function(receiver) return receiver.priority end
function Plugin:compareTo(other)
    local ____value = __K2L_CompareBy(__K2L_PropertyRef.new("priority", "priority@666", ____lambda_1))(other, self)
    local ____result
    ____result = ____value ~= 0 and ____value or __K2L_Text.compare(self:getId(), other:getId())
    return ____result
end

function Plugin:toString()
    return self:getDisplayName() .. "[" .. self.priority .. "]"
end

local CountingPlugin = __K2L_Class("host.api.CountingPlugin", Plugin)
__K2L_ClassInfo(CountingPlugin, "host.api.CountingPlugin", "host.api.CountingPlugin", "class")

function CountingPlugin:____init(id, priority)
    Plugin.____init(self, id, priority)
    self.count = 0
    self.createdAt = initLog.size
    trace("CountingPlugin.init(" .. id .. ") createdAt=" .. self.createdAt)
    self.tag__CountingPlugin = "counting"
end

function CountingPlugin:getTag()
    return self.tag__CountingPlugin or "null"
end

function CountingPlugin:handle(input)
    local r = self:process(input)
    if r ~= nil then
        self.count = self.count + 1
    end
    return r
end

function CountingPlugin:stats()
    return self:getId() .. " handled " .. self.count
end

local PluginException = __K2L_Class("host.api.PluginException", __K2L_Exception)
__K2L_ClassInfo(PluginException, "host.api.PluginException", "host.api.PluginException", "class")

function PluginException:____init(plugin, cause)
    __K2L_Exception.____init(self, "plugin " .. plugin .. " failed: " .. __K2L_Str(cause.message), cause)
    self.plugin = plugin
end

local Registry = __K2L_Class("host.api.Registry")
__K2L_ClassInfo(Registry, "host.api.Registry", "host.api.Registry", "class")

function Registry:____init()
    self.factories = __K2L_MapOf()
    self.lookups = 0
    trace("Registry.init")
end

function Registry:register(name, factory)
    if self.factories:put(name, factory) ~= nil then
        error(__K2L_IllegalStateException.new("plugin " .. name .. " registered twice"))
    end
end

function Registry:create(name, settings)
    if settings == nil then
        settings = __K2L_ReadOnlyMapOf()
    end
    self.lookups = self.lookups + 1
    local ____value_1 = self.factories:get(name)
    if ____value_1 == nil then
        error(__K2L_NoSuchElementException.new("unknown plugin '" .. name .. "'; known: " .. self.factories:getKeys():joinToString()))
    end
    local f = ____value_1
    return f(settings)
end

function Registry:getNames()
    return self.factories:getKeys()
end

__K2L_LazyObject(Registry, "____init")
return {initLog = initLog, trace = trace, Describable = Describable, Lifecycle = Lifecycle, Configurable = Configurable, Plugin = Plugin, CountingPlugin = CountingPlugin, PluginException = PluginException, Registry = Registry}
-- ==== builtin/Builtins.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_CompanionInfo = ____lualib.__K2L_CompanionInfo
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IsLowerCase = ____lualib.__K2L_IsLowerCase
local __K2L_LazyObject = ____lualib.__K2L_LazyObject
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_TouchObject = ____lualib.__K2L_TouchObject

local ____Plugin = require("api.Plugin")
local UpperPlugin = __K2L_Class("host.builtin.UpperPlugin", ____Plugin.CountingPlugin)
__K2L_ClassInfo(UpperPlugin, "host.builtin.UpperPlugin", "host.builtin.UpperPlugin", "class")
__K2L_CompanionInfo(UpperPlugin, "host.builtin.UpperPlugin.Companion", "host.builtin.UpperPlugin$Companion", "Companion")

function UpperPlugin:____init(priority)
    ____Plugin.CountingPlugin.____init(self, "upper", priority)
    ____Plugin.initLog:add("UpperPlugin.init")
end

local ____lambda_1 = function(it) return __K2L_IsLowerCase[it] == true end
function UpperPlugin:process(input)
    if __K2L_StringToList(input):any(____lambda_1) then
        return input:upper()
    else
        return nil
    end
end

function UpperPlugin:onStart()
    return "upper ready"
end

UpperPlugin.____companion = true

function UpperPlugin:create(settings)
    local ____receiver = settings:get("priority")
    return UpperPlugin.new(____receiver and __K2L_StringToInt(____receiver) or 5)
end

function UpperPlugin:____initCompanion()
    ____Plugin.initLog:add("UpperPlugin.Companion.init")
end

__K2L_LazyObject(UpperPlugin, "____initCompanion")
local ReplacePlugin = __K2L_Class("host.builtin.ReplacePlugin", ____Plugin.CountingPlugin, ____Plugin.Configurable)
__K2L_ClassInfo(ReplacePlugin, "host.builtin.ReplacePlugin", "host.builtin.ReplacePlugin", "class")

function ReplacePlugin:____init(settings)
    ____Plugin.CountingPlugin.____init(self, "replace", 3)
    self.settings = settings
    self.from = self:setting("from", "foo")
    self.to = self:setting("to", "bar")
    ____Plugin.initLog:add("ReplacePlugin.init " .. self.from .. "->" .. self.to)
end

function ReplacePlugin:getSettings()
    return self.settings
end

function ReplacePlugin:getDisplayName()
    return "Replace(" .. self.from .. "->" .. self.to .. ")"
end

function ReplacePlugin:process(input)
    return __K2L_StringContains(input, self.from) and __K2L_StringReplace(input, self.from, self.to) or nil
end

function ReplacePlugin:stats()
    return ____Plugin.CountingPlugin.stats(self) .. " (from=" .. self.from .. ")"
end

function ReplacePlugin:describe()
    return "Replace:" .. ____Plugin.Plugin.describe(self)
end

local GuardPlugin = __K2L_Class("host.builtin.GuardPlugin", ____Plugin.Plugin)
__K2L_ClassInfo(GuardPlugin, "host.builtin.GuardPlugin", "host.builtin.GuardPlugin", "class")

function GuardPlugin:____init(limit)
    ____Plugin.Plugin.____init(self, "guard", 10)
    self.limit = limit
    self.tag__GuardPlugin = "guard"
end

function GuardPlugin:getTag()
    return self.tag__GuardPlugin or "null"
end

function GuardPlugin:handle(input)
    if not (#input <= self.limit) then
        error(__K2L_IllegalArgumentException.new("input too long (" .. #input .. " > " .. self.limit .. ")"))
    end
    return nil
end

function GuardPlugin:getDisplayName()
    return "Guard<=" .. self.limit
end

local function counterPlugin(prefix)
    local calls = 0
    local ____object = __K2L_Class("host.builtin.BuiltinsKt$counterPlugin$1", ____Plugin.Plugin)
    __K2L_ClassInfo(____object, nil, "host.builtin.BuiltinsKt$counterPlugin$1", "class", false)
    function ____object:____init()
        ____Plugin.Plugin.____init(self, "counter", 1)
        self.displayName = "Counter(" .. prefix .. ")"
    end
    function ____object:handle(input)
        calls = calls + 1
        return __K2L_StringStartsWith(input, prefix) and prefix .. "#" .. calls or nil
    end
    function ____object:getDisplayName()
        return self.displayName
    end
    ____object:____init()
    return ____object
end

local ____lambda_2 = function(it) return ReplacePlugin.new(it) end
local ____lambda_3 = function(it)
    return counterPlugin(it:getOrDefault("prefix", "#"))
end
local function installBuiltins()
    local ____arg = __K2L_TouchObject(____Plugin.Registry)
    local ____receiver_1 = __K2L_TouchObject(UpperPlugin)
    ____arg:register("upper", function(...) return ____receiver_1:create(...) end)
    ____Plugin.Registry:register("replace", ____lambda_2)
    ____Plugin.Registry:register("guard", function(it)
        local ____receiver_2 = it:get("limit")
        return GuardPlugin.new(____receiver_2 and __K2L_StringToIntOrNull(____receiver_2) or 20)
    end)
    ____Plugin.Registry:register("counter", ____lambda_3)
end

return {UpperPlugin = UpperPlugin, ReplacePlugin = ReplacePlugin, GuardPlugin = GuardPlugin, counterPlugin = counterPlugin, installBuiltins = installBuiltins}
-- ==== main.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IsComparable = ____lualib.__K2L_IsComparable
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_SortedSetOf = ____lualib.__K2L_SortedSetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local ____Plugin = require("api.Plugin")
local ____Builtins = require("builtin.Builtins")
local Host = __K2L_Class("host.Host")
__K2L_ClassInfo(Host, "host.Host", "host.Host", "class")

function Host:____init(name)
    self.name = name
    self.plugins = __K2L_SortedSetOf()
    self.failures = __K2L_ListOf()
end

Host.Run = __K2L_Class("host.Host$Run")
__K2L_ClassInfo(Host.Run, "host.Host.Run", "host.Host$Run", "class")

function Host.Run:____init(____outer, input)
    self.____outer = ____outer
    self.input = input
    self.steps = __K2L_ListOf()
end

function Host.Run:execute()
    local current = self.input
    local ____collection = self.____outer.plugins
    local ____items, ____n = ____collection:____array()
    local ____mod = ____collection.____modCount
    for ____i = 1, ____n do
        local p = ____items[____i]
        local out
        local ____ok, ____result = __K2L_DeepPcall(function()
            out = p:handle(current)
        end)
        if not ____ok then
            local ____error = __K2L_ToThrowable(____result)
            if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
                local e = ____error
                local wrapped = ____Plugin.PluginException.new(p:getId(), e)
                self.____outer.failures:add(__K2L_NotNull(wrapped.message))
                local ____arg = self.____outer.failures
                local ____receiver = wrapped.cause
                local ____receiver_1 = ____receiver and __K2L_JavaClass(__K2L_KClassOfValue(____receiver))
                ____arg:add("cause: " .. __K2L_Str(____receiver_1 and (____receiver_1.simpleName or "")))
                return "rejected by " .. __K2L_Str(p)
            else
                error(____error, 0)
            end
        end
        if out ~= nil then
            self.steps:add(p:getId() .. ": " .. current .. " -> " .. out)
            current = out
        end
        if ____collection.____modCount ~= ____mod and ____collection:____comodified(____i, ____n) then
            break
        end
    end
    return self.____outer.name .. ": " .. current
end

Host.Report = __K2L_Class("host.Host$Report")
__K2L_ClassInfo(Host.Report, "host.Host.Report", "host.Host$Report", "class")

function Host.Report:____init(lines)
    self.lines = lines
end

function Host.Report.new(lines)
    return setmetatable({lines = lines}, Host.Report)
end

local ____lambda_1 = function(it) return "  | " .. it end
function Host.Report:toString()
    return self.lines:joinToString("\n", nil, nil, nil, nil, ____lambda_1)
end

function Host:load(...)
    local specs = __K2L_ArrayOf(...)
    for ____i_1 = 1, specs.size do
        local ____item = specs[____i_1]
        local plugin, settings = ____item.first, ____item.second
        do
            local p
            local ____ok_1, ____result_1 = __K2L_DeepPcall(function()
                p = ____Plugin.Registry:create(plugin, settings)
            end)
            if not ____ok_1 then
                local ____error_1 = __K2L_ToThrowable(____result_1)
                if __K2L_InstanceOf(____error_1, __K2L_NoSuchElementException) then
                    local e = ____error_1
                    self.failures:add(e.message or "?")
                    goto ____continue
                else
                    error(____error_1, 0)
                end
            end
            self.plugins:add(p)
            print("loaded " .. __K2L_Str(p) .. ": " .. p:start() .. " / " .. p:describe())
        end
        ::____continue::
    end
end

function Host:run(input)
    local r = Host.Run.new(self, input)
    return __K2L_Pair.new(r:execute(), r.steps)
end

function Host:report()
    local ____list = self.plugins
    local ____out = {}
    local ____count = 0
    local ____items_1, ____n_1 = ____list:____array()
    for ____i_2 = 1, ____n_1 do
        local p = ____items_1[____i_2]
        local ____result_2
        if __K2L_InstanceOf(p, ____Plugin.CountingPlugin) then
            ____result_2 = p:stats()
        elseif __K2L_InstanceOf(p, ____Plugin.Configurable) then
            ____result_2 = "configurable " .. p:getId()
        else
            ____result_2 = p:getId() .. " (" .. (p.started and "started" or "idle") .. ")"
        end
        ____count = ____count + 1
        ____out[____count] = ____result_2
    end
    return Host.Report.new(__K2L_ListWrap(____out, ____count):plusAll(self.failures))
end

function Host:getOrder()
    local ____list_1 = self.plugins
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_2, ____n_2 = ____list_1:____array()
    for ____i_3 = 1, ____n_2 do
        local it = ____items_2[____i_3]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = it:getId()
    end
    return __K2L_ListWrap(____out_1, ____count_1)
end

local Version = __K2L_Class("host.Version")
__K2L_ClassInfo(Version, "host.Version", "host.Version", "class")
Version.____comparable = true

function Version:____init()
    self.MAJOR = 1
    self.MINOR = 4
end

function Version:compareTo(other)
    return 0
end

function Version:toString()
    return "v" .. 1 .. "." .. 4
end

Version:____init()
local Level = __K2L_Class("host.Level", nil, ____Plugin.Describable)
__K2L_ClassInfo(Level, "host.Level", "host.Level", "class")

function Level:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Level:toString()
    return self.name
end

function Level:compareTo(other)
    return self.ordinal - other.ordinal
end

do
    local ____LOW = __K2L_Class("Level", Level)
    __K2L_ClassInfo(____LOW, "host.Level.LOW", "host.Level$LOW", "class", "LOW")
    function ____LOW:getId()
        return self.id__LOW or "null"
    end
    function ____LOW:____init(...)
        Level.____init(self, ...)
        self.id__LOW = "low"
    end
    Level.LOW = ____LOW.new("LOW", 0)
end
do
    local ____HIGH = __K2L_Class("Level", Level)
    __K2L_ClassInfo(____HIGH, "host.Level.HIGH", "host.Level$HIGH", "class", "HIGH")
    function ____HIGH:getId()
        return self.id__HIGH or "null"
    end
    function ____HIGH:describe()
        return "HIGH!"
    end
    function ____HIGH:____init(...)
        Level.____init(self, ...)
        self.id__HIGH = "high"
    end
    Level.HIGH = ____HIGH.new("HIGH", 1)
end
Level.____values = {Level.LOW, Level.HIGH}
local Both = __K2L_Class("host.Both", nil, ____Plugin.Describable, ____Plugin.Lifecycle)
__K2L_ClassInfo(Both, "host.Both", "host.Both", "class")

function Both:____init()
    self.id__Both = "both"
end

function Both:getId()
    return self.id__Both or "null"
end

function Both:describe()
    return "both: " .. ____Plugin.Lifecycle.describe(self) .. "/" .. ____Plugin.Describable.describe(self)
end

local function check(x)
    local ____builder = __K2L_StringBuilder.new()
    ____builder:append(__K2L_IsComparable(x) and "comparable" or "not comparable")
    if __K2L_InstanceOf(x, ____Plugin.Describable) then
        ____builder:append(", describable " .. x:getId())
    end
    if __K2L_InstanceOf(x, ____Plugin.Lifecycle) then
        ____builder:append(", lifecycle")
    end
    return ____builder:toString()
end

local ____lambda_2 = function(it) return ____Builtins.UpperPlugin:create(it) end
local ____lambda_3 = function(x) return __K2L_IsComparable(x) end
local function main()
    print("before install: " .. __K2L_Str(____Plugin.initLog))
    ____Builtins.installBuiltins()
    print("after install: " .. __K2L_Str(____Plugin.initLog))
    ____Plugin.initLog:clear()
    local host = Host.new("main")
    host:load(__K2L_Pair.new("guard", __K2L_SingletonMapOf(__K2L_Pair.new("limit", "16"))), __K2L_Pair.new("replace", __K2L_ReadOnlyMapOf(__K2L_Pair.new("from", "cat"), __K2L_Pair.new("to", "dog"))), __K2L_Pair.new("upper", __K2L_ReadOnlyMapOf()), __K2L_Pair.new("missing", __K2L_ReadOnlyMapOf()), __K2L_Pair.new("counter", __K2L_SingletonMapOf(__K2L_Pair.new("prefix", "!"))))
    print("init order:")
    local ____list_2 = ____Plugin.initLog
    for ____i_4 = 1, ____list_2.size do
        local it = ____list_2[____i_4]
        print("  " .. it)
    end
    print("order: " .. __K2L_Str(host:getOrder()))
    local ____list_3 = __K2L_ReadOnlyListOf("the cat sat", "!cat", "NO CHANGE", "a very long input line", "cat cat")
    for ____i_6 = 1, ____list_3.size do
        local input = ____list_3[____i_6]
        local ____destructured = host:run(input)
        local result, steps = ____destructured.first, ____destructured.second
        print(input .. " => " .. result)
        for ____i_5 = 1, steps.size do
            local it = steps[____i_5]
            print("    " .. it)
        end
    end
    print("report:\n" .. __K2L_Str(host:report()))
    print("lookups: " .. ____Plugin.Registry.lookups .. ", registered: " .. __K2L_Str(____Plugin.Registry:getNames()))
    local ____ok_2, ____result_3 = __K2L_DeepPcall(function()
        ____Plugin.Registry:register("upper", ____lambda_2)
    end)
    if not ____ok_2 then
        local ____error_2 = __K2L_ToThrowable(____result_3)
        if __K2L_InstanceOf(____error_2, __K2L_IllegalStateException) then
            local e = ____error_2
            print("error: " .. __K2L_Str(e.message))
        else
            error(____error_2, 0)
        end
    end
    local another = ____Builtins.UpperPlugin:create(__K2L_SingletonMapOf(__K2L_Pair.new("priority", "7")))
    print(__K2L_Str(another) .. " " .. another:getDisplayName() .. " " .. another:describe() .. " " .. another:compareTo(____Plugin.Registry:create("upper")))
    print(__K2L_Str(Version) .. " " .. check(Version) .. " | " .. check(Level.HIGH) .. " " .. Level.HIGH:describe() .. " " .. Level.LOW:describe())
    print(check(Both.new()) .. " " .. Both.new():describe() .. " | " .. check(another) .. " | " .. check("text") .. " | " .. check(__K2L_SingletonListOf(1)))
    local comparables = __K2L_ReadOnlyListOf(Version, 3, "s", another, Level.LOW, Both.new(), 2.5):filter(____lambda_3)
    print("comparables: " .. comparables.size)
end

__K2L_DeepMain(main)
return {Host = Host, Version = Version, Level = Level, Both = Both, check = check}
