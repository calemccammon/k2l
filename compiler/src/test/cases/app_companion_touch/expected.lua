local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_CompanionInfo = ____lualib.__K2L_CompanionInfo
local __K2L_KClassOf = ____lualib.__K2L_KClassOf
local __K2L_LazyObject = ____lualib.__K2L_LazyObject
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_TouchObject = ____lualib.__K2L_TouchObject

local log = __K2L_ListOf()
local Widget = __K2L_Class("Widget")
__K2L_ClassInfo(Widget, "Widget", "Widget", "class")
__K2L_CompanionInfo(Widget, "Widget.Companion", "Widget$Companion", "Companion")

function Widget:____init(name)
    self.name = name
end

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
__K2L_ClassInfo(Registry, "Registry", "Registry", "class")

function Registry:____init()
    self.names = __K2L_ListOf()
    log:add("Registry init")
end

function Registry:add(name, factory)
    self.names:add(factory(name).name)
end

function Registry:toString()
    return __K2L_Str(self.names)
end

__K2L_LazyObject(Registry, "____init")

local function main()
    local ____receiver = __K2L_TouchObject(Widget)
    local factory = function(...) return ____receiver:create(...) end
    log:add("reference taken")
    print(factory("a").name)
    local ____arg = __K2L_TouchObject(Registry)
    local ____result
    log:add("label " .. __K2L_Str(__K2L_KClassOf(Widget).simpleName))
    ____result = "w"
    ____arg:add(____result, factory)
    print(__K2L_Str(log))
    print(__K2L_Str(__K2L_TouchObject(Registry)))
end

__K2L_Main(main)
return {log = log, Widget = Widget, Registry = Registry}
