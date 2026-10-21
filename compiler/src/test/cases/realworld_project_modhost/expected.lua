-- ==== main.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Str = ____lualib.__K2L_Str

local ____host = require("lib.host")
local ____Greeter = require("mods.Greeter")
local ____Counter = require("mods.Counter")
local ____Events = require("shared.Events")

local function main()
    print("kotlin main starts")
    local modules = {}
    modules[1] = "mods.Greeter"
    modules[2] = "mods.Counter"
    local n = ____host.boot(modules)
    print("booted " .. n .. " mods")
    print("kotlin sees style=" .. ____Greeter.greeting_style .. " clicks=" .. ____Counter.click_count)
    print(____Counter.summary())
    print("fired " .. __K2L_Str(____Events.Events.fired))
end

__K2L_Main(main)
-- ==== mods/Counter.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_LazyFile = ____lualib.__K2L_LazyFile
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull

local ____exports = {}
local ____Events = require("shared.Events")
local click

local function on_load(h)
    ____exports.host = h
    ____Events.Events:on("click", function(it)
        click(__K2L_StringToIntOrNull(it) or 1)
    end)
    return "counter"
end

function click(times)
    if times == nil then
        times = 1
    end
    ____exports.click_count = ____exports.click_count + times
    local ____receiver = ____exports.host
    if ____receiver ~= nil then
        ____receiver.log("clicked " .. times .. ", total " .. ____exports.click_count)
    end
    return ____exports.click_count
end

local function summary()
    return ____exports.bootMessage .. "; " .. ____exports.click_count .. " clicks"
end

____exports.on_load = on_load
____exports.click = click
____exports.summary = summary
__K2L_LazyFile(____exports, function()
    local ____result
    print("counter: initializing its top-level state")
    ____result = "counter ready after " .. ____Events.Events.fired.size .. " events"
    ____exports.bootMessage = ____result
    ____exports.click_count = 0
    ____exports.host = nil
end, {"bootMessage", "click_count", "host"})
return ____exports
-- ==== mods/Greeter.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_ListWrap = ____lualib.__K2L_ListWrap

local ____exports = {}
local ____Events = require("shared.Events")
local greet
local requires = ____Events.Version.new(1, 2)
____exports.greeting_style = "plain"

local function on_load(host)
    host.log("greeter loaded into " .. host.name)
    ____Events.Events:on("join", function(who)
        host.log(greet(who))
    end)
    host.schedule(2, function()
        host.log("greeter: delayed hello")
    end)
    return "greeter"
end

function greet(who, punctuation)
    if punctuation == nil then
        punctuation = "!"
    end
    local ____subject = ____exports.greeting_style
    if ____subject == "loud" then
        return "HELLO " .. who:upper() .. punctuation
    else
        return "hello " .. who .. punctuation
    end
end

local function greet_all(...)
    local names = __K2L_ArrayOf(...)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = names:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = greet(it, ".")
    end
    return __K2L_ListWrap(____out, ____count)
end

local function compatible(hostVersion)
    return __K2L_Compare(____Events.Version:parse(hostVersion), requires) >= 0
end

____exports.requires = requires
____exports.on_load = on_load
____exports.greet = greet
____exports.greet_all = greet_all
____exports.compatible = compatible
return ____exports
-- ==== shared/Events.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringToInt = ____lualib.__K2L_StringToInt

local Events = __K2L_Class("mods.shared.Events")

function Events:____init()
    self.listeners = __K2L_MapOf()
    self.fired = __K2L_ListOf()
end

local ____lambda_1 = function() return __K2L_ListOf() end
function Events:on(name, listener)
    self.listeners:getOrPut(name, ____lambda_1):add(listener)
end

function Events:fire(name, detail)
    if detail == nil then
        detail = "-"
    end
    self.fired:add(name)
    local ls = self.listeners:get(name) or __K2L_ReadOnlyListOf()
    local ____mod = ls.____modCount
    for ____i = 1, ls.size do
        local it = ls[____i]
        it(detail)
        if ls.____modCount ~= ____mod and ls:____comodified(____i) then
            break
        end
    end
    return ls.size
end

Events:____init()
local Version = __K2L_Class("mods.shared.Version")
Version.____comparable = true

function Version:____init(major, minor)
    self.major = major
    self.minor = minor
end

function Version.new(major, minor)
    return setmetatable({major = major, minor = minor}, Version)
end

local ____lambda_2 = function(it) return it.major end
local ____lambda_3 = function(it) return it.minor end
function Version:compareTo(other)
    return __K2L_CompareBy(____lambda_2, ____lambda_3)(self, other)
end

function Version:toString()
    return self.major .. "." .. self.minor
end

Version.____companion = true

function Version:parse(s)
    local ____list = __K2L_StringSplit(s, ".")
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i_1 = 1, ____n do
        local it = ____items[____i_1]
        ____count = ____count + 1
        ____out[____count] = __K2L_StringToInt(it)
    end
    local ____destructured = __K2L_ListWrap(____out, ____count)
    local a, b = ____destructured[1], ____destructured[2]
    return Version.new(a, b)
end

return {Events = Events, Version = Version}
