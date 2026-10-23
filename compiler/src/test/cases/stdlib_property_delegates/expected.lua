local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DelegateProvider = ____lualib.__K2L_DelegateProvider
local __K2L_KProperty = ____lualib.__K2L_KProperty
local __K2L_Lazy = ____lualib.__K2L_Lazy
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ObservableProperty = ____lualib.__K2L_ObservableProperty
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_ReadOnlyProperty = ____lualib.__K2L_ReadOnlyProperty
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str

local ____exports = {}
____exports.topLevel = 1
local ____alias_delegate = __K2L_PropertyRef.new("topLevel", "/topLevel", function() return ____exports.topLevel end, function(value)
    ____exports.topLevel = value
end)
local Settings = __K2L_Class("Settings")

function Settings:____init()
    self.width = 10
    self.____size_delegate = __K2L_PropertyRef.new("width", "/Settings.width", function() return self.width end, function(value)
        self.width = value
    end, self)
    self.____doubled_delegate = __K2L_Lazy(function() return self.width * 2 end)
end

function Settings:getSize()
    return self.____size_delegate:get()
end

function Settings:setSize(value)
    self.____size_delegate:set(value)
end

function Settings:getDoubled()
    return self.____doubled_delegate:getValue()
end

local Wrapper = __K2L_Class("Wrapper")

function Wrapper:____init(settings)
    self.settings = settings
    local ____receiver = self.settings
    self.____width_delegate = __K2L_PropertyRef.new("width", "/Settings.width", function() return ____receiver.width end, function(value)
        ____receiver.width = value
    end, ____receiver)
end

function Wrapper:getWidth()
    return self.____width_delegate:get()
end

function Wrapper:setWidth(value)
    self.____width_delegate:set(value)
end

local Point = __K2L_Class("Point")

function Point.new(x)
    return setmetatable({x = x}, Point)
end

local Moved = __K2L_Class("Moved")

function Moved:____init(point)
    self.point = point
    local ____receiver_1 = self.point
    self.____left_delegate = __K2L_PropertyRef.new("x", "x@622", function() return ____receiver_1.x end, function(value)
        ____receiver_1.x = value
    end, ____receiver_1)
end

function Moved:getLeft()
    return self.____left_delegate:get()
end

function Moved:setLeft(value)
    self.____left_delegate:set(value)
end

local Upper = __K2L_Class("Upper")

function Upper:getValue(thisRef, property)
    return property.name:upper()
end

local upper = Upper.new()
local ____NAME_delegate = upper
local ____providedName_delegate = __K2L_DelegateProvider(function(_, p)
    return __K2L_ReadOnlyProperty(function(_, _) return "provided " .. p.name end)
end):provideDelegate(nil, __K2L_KProperty("providedName", "/providedName"))

local ____lambda_1 = function() return ____exports.topLevel end
local ____lambda_2 = function() return ____exports.topLevel end
local ____lambda_3 = function(_, property)
    return __K2L_ReadOnlyProperty(function(_, _) return "provided for " .. property.name end)
end
local ____lambda_4 = function() return ____exports.topLevel end
local ____lambda_5 = function() return ____exports.topLevel end
local ____lambda_6 = function() return ____exports.topLevel end
local ____lambda_7 = function() return ____exports.topLevel end
local ____lambda_8 = function(receiver) return receiver.x end
local ____lambda_9 = function(receiver) return receiver.x end
local function main()
    print("alias " .. ____alias_delegate:get())
    ____alias_delegate:set(5)
    print("topLevel " .. ____exports.topLevel .. " alias " .. ____alias_delegate:get())
    ____exports.topLevel = 7
    print("alias " .. ____alias_delegate:get())
    local s = Settings.new()
    s:setSize(30)
    print("width " .. s.width .. " size " .. s:getSize() .. " doubled " .. s:getDoubled())
    local w = Wrapper.new(s)
    w:setWidth(42)
    print("settings " .. s.width .. " wrapper " .. w:getWidth())
    local m = Moved.new(Point.new(3))
    m:setLeft(m:getLeft() + 4)
    print("point " .. m.point.x .. " left " .. m:getLeft())
    local observed = __K2L_ListOf()
    local observable = __K2L_ObservableProperty(0, function(p, old, new)
        observed:add(p.name .. ": " .. old .. " -> " .. new)
    end)
    observable:setValue(nil, __K2L_PropertyRef.new("topLevel", "/topLevel", ____lambda_1, function(value)
        ____exports.topLevel = value
    end), 9)
    print("observable " .. observable:getValue(nil, __K2L_PropertyRef.new("topLevel", "/topLevel", ____lambda_2, function(value)
        ____exports.topLevel = value
    end)) .. " " .. __K2L_Str(observed))
    local provider = __K2L_DelegateProvider(____lambda_3)
    print(provider:provideDelegate(nil, __K2L_PropertyRef.new("topLevel", "/topLevel", ____lambda_4, function(value)
        ____exports.topLevel = value
    end)):getValue(nil, __K2L_PropertyRef.new("topLevel", "/topLevel", ____lambda_5, function(value)
        ____exports.topLevel = value
    end)))
    print(____NAME_delegate:getValue(nil, __K2L_KProperty("NAME", "/NAME")))
    __K2L_PropertyRef.new("topLevel", "/topLevel", ____lambda_6, function(value)
        ____exports.topLevel = value
    end):set(11)
    print(__K2L_PropertyRef.new("topLevel", "/topLevel", ____lambda_7, function(value)
        ____exports.topLevel = value
    end):get())
    local p = Point.new(1)
    __K2L_PropertyRef.new("x", "x@622", ____lambda_8, function(receiver, value)
        receiver.x = value
    end):set(p, 8)
    print(p.x .. " " .. __K2L_PropertyRef.new("x", "x@622", ____lambda_9, function(receiver, value)
        receiver.x = value
    end):get(p))
    print(____providedName_delegate:getValue(nil, __K2L_KProperty("providedName", "/providedName")))
end

____exports.____alias_delegate = ____alias_delegate
____exports.Settings = Settings
____exports.Wrapper = Wrapper
____exports.Point = Point
____exports.Moved = Moved
____exports.Upper = Upper
____exports.upper = upper
____exports.____NAME_delegate = ____NAME_delegate
____exports.____providedName_delegate = ____providedName_delegate
__K2L_RunMain(main)
return ____exports
