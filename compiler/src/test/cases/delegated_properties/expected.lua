-- ==== lib/delegates.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Lazy = ____lualib.__K2L_Lazy
local __K2L_Str = ____lualib.__K2L_Str

local Logged = __K2L_Class("Logged")

function Logged:____init(value)
    self.value = value
end

function Logged:getValue(thisRef, property)
    print("get " .. property.name)
    return self.value
end

function Logged:setValue(thisRef, property, newValue)
    print("set " .. property.name .. " = " .. __K2L_Str(newValue))
    self.value = newValue
end

local ____shared_delegate = __K2L_Lazy(function()
    print("computing shared")
    return 99
end)
local ____sharedLogged_delegate = Logged.new("init")
return {Logged = Logged, ____shared_delegate = ____shared_delegate, ____sharedLogged_delegate = ____sharedLogged_delegate}
-- ==== main.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_Lazy = ____lualib.__K2L_Lazy
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NotNullProperty = ____lualib.__K2L_NotNullProperty
local __K2L_ObservableProperty = ____lualib.__K2L_ObservableProperty
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_VetoableProperty = ____lualib.__K2L_VetoableProperty

local ____delegates = require("lib.delegates")
local Tracking = __K2L_Class("Tracking")

function Tracking:____init(value)
    self.value = value
end

function Tracking:getValue(thisRef, property)
    print("read " .. property.name .. " (" .. (thisRef == nil and "no owner" or "owned") .. ")")
    return self.value
end

function Tracking:setValue(thisRef, property, newValue)
    print("write " .. property.name .. ": " .. self.value .. " -> " .. newValue)
    self.value = newValue
end

local Uppercase = __K2L_Class("Uppercase")

function Uppercase:getValue(thisRef, property)
    return property.name:upper()
end

local Clamped = __K2L_Class("Clamped")

function Clamped:____init(max)
    self.max = max
    self.value = 0
end

function Clamped:getValue(thisRef, property)
    return self.value
end

function Clamped:setValue(thisRef, property, value)
    self.value = value > self.max and self.max or value
end

local ____topLazy_delegate = __K2L_Lazy(function()
    print("computing topLazy")
    return "top"
end)
local ____topObservable_delegate = __K2L_ObservableProperty(0, function(prop, old, new)
    print(prop.name .. ": " .. old .. " -> " .. new)
end)
local Settings = __K2L_Class("Settings")

function Settings:____init(source)
    self.source = source
    self.____greeting_delegate = __K2L_Lazy(function()
        print("building greeting for " .. self.source)
        return "hello " .. self.source
    end)
    self.____volume_delegate = __K2L_ObservableProperty(5, function(property, oldValue, newValue)
        print(property.name .. " changed from " .. oldValue .. " to " .. newValue)
    end)
    self.____positive_delegate = __K2L_VetoableProperty(1, function(_, old, new)
        print("veto? " .. old .. " -> " .. new)
        return new > 0
    end)
    self.____name_delegate = __K2L_NotNullProperty()
    self.____tracked_delegate = Tracking.new(10)
    self.____clamped_delegate = Clamped.new(100)
    self.____upper_delegate = Uppercase.new()
end

function Settings:getGreeting()
    return self.____greeting_delegate:getValue()
end

function Settings:getVolume()
    return self.____volume_delegate:getValue(self, {name = "volume"})
end

function Settings:setVolume(value)
    self.____volume_delegate:setValue(self, {name = "volume"}, value)
end

function Settings:getPositive()
    return self.____positive_delegate:getValue(self, {name = "positive"})
end

function Settings:setPositive(value)
    self.____positive_delegate:setValue(self, {name = "positive"}, value)
end

function Settings:getName()
    return self.____name_delegate:getValue(self, {name = "name"})
end

function Settings:setName(value)
    self.____name_delegate:setValue(self, {name = "name"}, value)
end

function Settings:getTracked()
    return self.____tracked_delegate:getValue(self, {name = "tracked"})
end

function Settings:setTracked(value)
    self.____tracked_delegate:setValue(self, {name = "tracked"}, value)
end

function Settings:getClamped()
    return self.____clamped_delegate:getValue(self, {name = "clamped"})
end

function Settings:setClamped(value)
    self.____clamped_delegate:setValue(self, {name = "clamped"}, value)
end

function Settings:getUpper()
    return self.____upper_delegate:getValue(self, {name = "upper"})
end

function Settings:bump()
    self:setVolume(self:getVolume() + 1)
    self:setTracked(self:getTracked() + 1)
end

local Config = __K2L_Class("Config")

function Config:____init(map)
    self.____host_delegate = map
    self.____port_delegate = map
end

function Config:getHost()
    return self.____host_delegate:getValue("host")
end

function Config:setHost(value)
    self.____host_delegate:set("host", value)
end

function Config:getPort()
    return self.____port_delegate:getValue("port")
end

function Config:setPort(value)
    self.____port_delegate:set("port", value)
end

local User = __K2L_Class("User")

function User:____init(map)
    self.map = map
    self.____name_delegate = self.map
    self.____age_delegate = self.map
end

function User:getName()
    return self.____name_delegate:getValue("name")
end

function User:getAge()
    return self.____age_delegate:getValue("age")
end

local Registry = __K2L_Class("Registry")

function Registry:____init()
    self.____items_delegate = __K2L_Lazy(function()
        print("loading registry")
        return __K2L_ListOf("a", "b")
    end)
    self.____hits_delegate = __K2L_ObservableProperty(0, function(_, _, new)
        print("hits=" .. new)
    end)
end

function Registry:getItems()
    return self.____items_delegate:getValue()
end

function Registry:getHits()
    return self.____hits_delegate:getValue(self, {name = "hits"})
end

function Registry:setHits(value)
    self.____hits_delegate:setValue(self, {name = "hits"}, value)
end

Registry:____init()
local WithCompanion = __K2L_Class("WithCompanion")

function WithCompanion:getInstance()
    return self.____instance_delegate:getValue()
end

function WithCompanion:____initCompanion()
    self.____instance_delegate = __K2L_Lazy(function()
        print("creating instance")
        return "singleton"
    end)
end

WithCompanion:____initCompanion()

local function main()
    local ____lazyLocal_delegate = __K2L_Lazy(function()
        print("computing lazyLocal")
        return 42
    end)
    print("before lazyLocal")
    print(____lazyLocal_delegate:getValue())
    print(____lazyLocal_delegate:getValue())
    local explicit = __K2L_Lazy(function() return 7 end)
    print(explicit:isInitialized())
    print(explicit:getValue())
    print(explicit:isInitialized())
    print(explicit:getValue() + 1)
    local ____modeLazy_delegate = __K2L_Lazy(function() return "no sync" end)
    print(____modeLazy_delegate:getValue())
    print("before topLazy")
    print(____topLazy_delegate:getValue())
    print(____topLazy_delegate:getValue())
    ____topObservable_delegate:setValue(nil, {name = "topObservable"}, 3)
    ____topObservable_delegate:setValue(nil, {name = "topObservable"}, ____topObservable_delegate:getValue(nil, {name = "topObservable"}) + 2)
    print(____topObservable_delegate:getValue(nil, {name = "topObservable"}))
    local ____counter_delegate = __K2L_ObservableProperty(10, function(p, o, n)
        print("local " .. p.name .. " " .. o .. " -> " .. n)
    end)
    ____counter_delegate:setValue(nil, {name = "counter"}, ____counter_delegate:getValue(nil, {name = "counter"}) + 1)
    ____counter_delegate:setValue(nil, {name = "counter"}, ____counter_delegate:getValue(nil, {name = "counter"}) * 2)
    print(____counter_delegate:getValue(nil, {name = "counter"}))
    local ____limited_delegate = __K2L_VetoableProperty(0, function(_, _, new) return new < 100 end)
    ____limited_delegate:setValue(nil, {name = "limited"}, 50)
    ____limited_delegate:setValue(nil, {name = "limited"}, 500)
    print(____limited_delegate:getValue(nil, {name = "limited"}))
    local s = Settings.new("test")
    print("settings created")
    print(s:getGreeting())
    print(s:getGreeting())
    print(s:getVolume())
    s:setVolume(8)
    s:bump()
    print(s:getVolume())
    s:setPositive(5)
    s:setPositive(-3)
    print(s:getPositive())
    s:setPositive(s:getPositive() + 10)
    print(s:getPositive())
    local ____ok, ____result = pcall(function()
        print(s:getName())
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_IllegalStateException) then
            local e = ____error
            print("caught: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    s:setName("Ada")
    print(s:getName())
    print(s:getTracked())
    s:setTracked(20)
    s:setTracked(s:getTracked() + 5)
    print(s:getTracked())
    s:setClamped(500)
    print(s:getClamped())
    s:setClamped(7)
    print(s:getClamped())
    print(s:getUpper())
    local other = Settings.new("other")
    print(other:getGreeting())
    print(s:getGreeting())
    local ________local_delegate = Tracking.new(1)
    print(________local_delegate:getValue(nil, {name = "local"}))
    ________local_delegate:setValue(nil, {name = "local"}, 2)
    print(________local_delegate:getValue(nil, {name = "local"}))
    local ____tag_delegate = Uppercase.new()
    print(____tag_delegate:getValue(nil, {name = "tag"}))
    local config = Config.new(__K2L_MapOf(__K2L_Pair.new("host", "localhost"), __K2L_Pair.new("port", 8080)))
    print(config:getHost() .. ":" .. config:getPort())
    config:setPort(9090)
    config:setHost("example.org")
    print(config:getHost() .. ":" .. config:getPort())
    local user = User.new(__K2L_MapOf(__K2L_Pair.new("name", "Grace"), __K2L_Pair.new("age", 36)))
    print(user:getName() .. " is " .. user:getAge())
    local backing = __K2L_MapOf(__K2L_Pair.new("title", "Dr"))
    local ____title_delegate = backing
    print(____title_delegate:getValue("title"))
    ____title_delegate:set("title", "Prof")
    print(__K2L_Str(backing:get("title")))
    print("before registry")
    print(Registry:getItems().size)
    print(__K2L_Str(Registry:getItems()))
    local ____object = Registry
    ____object:setHits(2)
    print(WithCompanion:getInstance())
    print(WithCompanion:getInstance())
    print("before shared")
    print(____delegates.____shared_delegate:getValue())
    print(____delegates.____shared_delegate:getValue())
    print(____delegates.____sharedLogged_delegate:getValue(nil, {name = "sharedLogged"}))
    ____delegates.____sharedLogged_delegate:setValue(nil, {name = "sharedLogged"}, "changed")
    print(____delegates.____sharedLogged_delegate:getValue(nil, {name = "sharedLogged"}))
    local attempts = 0
    local ____flaky_delegate = __K2L_Lazy(function()
        attempts = attempts + 1
        if attempts < 2 then
            error(__K2L_IllegalStateException.new("not yet"))
        end
        return "ok after " .. attempts
    end)
    local ____ok_1, ____result_1 = pcall(function()
        print(____flaky_delegate:getValue())
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error_1, __K2L_IllegalStateException) then
            local e = ____error_1
            print("first: " .. __K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
    print(____flaky_delegate:getValue())
    print(____flaky_delegate:getValue())
end

main()
return {Tracking = Tracking, Uppercase = Uppercase, Clamped = Clamped, ____topLazy_delegate = ____topLazy_delegate, ____topObservable_delegate = ____topObservable_delegate, Settings = Settings, Config = Config, User = User, Registry = Registry, WithCompanion = WithCompanion}
