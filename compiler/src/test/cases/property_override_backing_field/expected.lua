local ____lualib = require("lualib_bundle")
local __K2L_AbstractMap = ____lualib.__K2L_AbstractMap
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DispatchMapRemove = ____lualib.__K2L_DispatchMapRemove
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PropertyOverride = ____lualib.__K2L_PropertyOverride
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str

local Sized = __K2L_Class("Sized", __K2L_AbstractMap)

function Sized:____init()
    self.backing = __K2L_Map.new()
    self.sizeChanges = 0
    self.____size = 0
end

function Sized:getSize()
    return self.____size
end

function Sized:setSize(value)
    self.____size = value
    self.sizeChanges = self.sizeChanges + 1
end

function Sized:getEntries()
    return self.backing:getEntries()
end

function Sized:put(key, value)
    local old = self.backing:put(key, value)
    self:setSize(self.backing.size)
    return old
end

function Sized:remove(key)
    local old = self.backing:remove(key)
    self:setSize(self.backing.size)
    return old
end

__K2L_PropertyOverride(Sized, "size", "getSize")
__K2L_PropertyOverride(Sized, "entries", "getEntries")
__K2L_DispatchMapRemove(Sized, nil)
local Failure = __K2L_Class("Failure", __K2L_Exception)

function Failure:____init(text)
    __K2L_Exception.____init(self)
    self.____message = text
end

function Failure:getMessage()
    return self.____message
end

function Failure:setMessage(value)
    self.____message = "[" .. __K2L_Str(value) .. "]"
end

__K2L_PropertyOverride(Failure, "message", "getMessage")

local function main()
    local m = Sized.new()
    print(m:getSize())
    m:set("a", 1)
    m:set("b", 2)
    print(m:getSize())
    print(m:isEmpty())
    print(__K2L_Str(m))
    m:remove("a")
    print(m:getSize() .. " " .. m.sizeChanges)
    local asMap = m
    print(asMap.size)
    print(__K2L_Equals(asMap, __K2L_MapOf(__K2L_Pair.new("b", 2))))
    local f = Failure.new("x")
    print(__K2L_Str(f:getMessage()))
    f:setMessage("y")
    print(__K2L_Str(f:getMessage()))
    print(__K2L_Str(f))
end

__K2L_RunMain(main)
return {Sized = Sized, Failure = Failure}
