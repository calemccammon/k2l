local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Uninitialized = ____lualib.__K2L_Uninitialized
local __K2L_UninitializedPropertyAccessException = ____lualib.__K2L_UninitializedPropertyAccessException

local ____exports = {}
local Service = __K2L_Class("Service")

function Service:ready()
    return self.name ~= nil
end

function Service:warm()
    if self.cache == nil then
        self.cache = __K2L_ListOf()
    end;
    (self.cache or __K2L_Uninitialized("cache")):add((self.cache or __K2L_Uninitialized("cache")).size)
end

function Service:cacheSize()
    return self.cache ~= nil and (self.cache or __K2L_Uninitialized("cache")).size or -1
end

local ____lambda_1 = function()
    return (____exports.config or __K2L_Uninitialized("config")):get("x")
end
local function main()
    local s = Service.new()
    print(tostring(s:ready()) .. " " .. s:cacheSize())
    local ____ok, ____result = pcall(function()
        print(s.name or __K2L_Uninitialized("name"))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_UninitializedPropertyAccessException) then
            local e = ____error
            print("caught: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    print(__K2L_Str(__K2L_RunCatching(function()
        return #(s.name or __K2L_Uninitialized("name"))
    end):exceptionOrNull()))
    s.name = "api"
    s:warm()
    s:warm()
    print(tostring(s:ready()) .. " " .. (s.name or __K2L_Uninitialized("name")) .. " " .. s:cacheSize())
    local ____receiver = __K2L_RunCatching(____lambda_1):exceptionOrNull()
    print(__K2L_Str(____receiver and ____receiver.message))
    print(____exports.config ~= nil)
    ____exports.config = __K2L_SingletonMapOf(__K2L_Pair.new("x", "1"))
    print(tostring(____exports.config ~= nil) .. " " .. __K2L_Str((____exports.config or __K2L_Uninitialized("config")):get("x")))
    local ____local
    local ____receiver_1 = __K2L_RunCatching(function()
        return (____local or __K2L_Uninitialized("local")):upper()
    end):exceptionOrNull()
    print(__K2L_Str(____receiver_1 and ____receiver_1.message))
    ____local = "set"
    print((____local or __K2L_Uninitialized("local")):upper())
    local e = __K2L_UninitializedPropertyAccessException.new("custom")
    print(tostring(__K2L_InstanceOf(e, __K2L_UninitializedPropertyAccessException)) .. " " .. __K2L_Str(e))
end

____exports.Service = Service
main()
return ____exports
