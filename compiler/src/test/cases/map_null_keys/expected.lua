local ____lualib = require("lualib_bundle")
local __K2L_AbstractMap = ____lualib.__K2L_AbstractMap
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PropertyOverride = ____lualib.__K2L_PropertyOverride
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_Str = ____lualib.__K2L_Str

local Backed = __K2L_Class("Backed", __K2L_AbstractMap)

function Backed:____init(backing)
    self.backing = backing
end

function Backed:getEntries()
    return self.backing:getEntries()
end

__K2L_PropertyOverride(Backed, "entries", "getEntries")

local ____lambda_1 = function() return -1 end
local ____lambda_2 = function() return -1 end
local function main()
    local a = __K2L_MapOf(__K2L_Pair.new(nil, 1), __K2L_Pair.new("b", 2))
    local b = __K2L_Map.new()
    b:putAll(a)
    print(__K2L_Str(b))
    print(__K2L_Str(a:toMutableMap()))
    print(__K2L_Str(a:toMutableMap()))
    for _, k, v in a:iter() do
        io.write(__K2L_Str(k) .. "=" .. v .. " ")
    end
    print()
    local sorted = __K2L_SortedMapOf(nil, __K2L_Pair.new("x", 1))
    sorted:putAll(__K2L_MapOf(__K2L_Pair.new("y", 2), __K2L_Pair.new("a", 0)))
    print(__K2L_Str(sorted))
    local backed = Backed.new(a)
    print(__K2L_Str(backed))
    print(backed:equals(a))
    print(__K2L_Equals(a, backed))
    print(__K2L_Str(backed:toMutableMap()))
    local copy = __K2L_MapOf()
    copy:putAll(backed)
    print(__K2L_Str(copy))
    for _, k, v in backed:iter() do
        io.write(__K2L_Str(k) .. "=" .. v .. " ")
    end
    print()
    print(backed:getOrElse(nil, ____lambda_1))
    print(backed:getOrElse("z", ____lambda_2))
    print(backed:hashCode() == a:hashCode())
end

__K2L_RunMain(main)
return {Backed = Backed}
