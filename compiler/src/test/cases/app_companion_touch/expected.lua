local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_LazyObject = ____lualib.__K2L_LazyObject
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_TouchObject = ____lualib.__K2L_TouchObject

local log = __K2L_ListOf()
local Widget = __K2L_Class("Widget")

function Widget.new(name)
    return setmetatable({name = name}, Widget)
end

function Widget:create(name)
    return Widget.new(name)
end

function Widget:____initCompanion()
    log:add("Widget.Companion init")
end

__K2L_LazyObject(Widget, "____initCompanion")
local Registry = __K2L_Class("Registry")
local names

function Registry:____init()
    names = __K2L_ListOf()
    log:add("Registry init")
end

function Registry:add(name, factory)
    names:add(factory(name).name)
end

function Registry:toString()
    return __K2L_Str(names)
end

__K2L_LazyObject(Registry, "____init")

local function main()
    local ____receiver = __K2L_TouchObject(Widget)
    local factory = function(...) return ____receiver:create(...) end
    log:add("reference taken")
    print(factory("a").name)
    local ____arg = __K2L_TouchObject(Registry)
    local ____result
    log:add("label " .. __K2L_Str("Widget"))
    ____result = "w"
    ____arg:add(____result, factory)
    print(__K2L_Str(log))
    print(__K2L_Str(__K2L_TouchObject(Registry)))
end

__K2L_RunMain(main)
return {log = log, Widget = Widget, Registry = Registry}
