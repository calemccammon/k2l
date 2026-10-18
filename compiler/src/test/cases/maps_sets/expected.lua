local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32

local Key = __K2L_Class("Key")

function Key:____init(x, y)
    self.x = x
    self.y = y
end

function Key:toString()
    return "Key(x=" .. self.x .. ", y=" .. self.y .. ")"
end

function Key:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.x) + __K2L_Hash(self.y))
end

function Key:equals(other)
    return getmetatable(other) == Key and self.x == other.x and self.y == other.y
end

local function main()
    local ages = __K2L_MapOf(__K2L_Pair.new("ann", 31), __K2L_Pair.new("bob", 25))
    print(__K2L_Str(ages))
    print(__K2L_Str(ages:get("ann")))
    print(__K2L_Str(ages:get("zed")))
    print(ages.size)
    print(ages:containsKey("bob"))
    print(ages:containsKey("ann"))
    print(__K2L_Str(ages:getKeys()))
    print(__K2L_Str(ages:getValues()))
    print(ages:getOrDefault("zed", 0))
    for name, age in ages:iter() do
        print(name .. " is " .. age)
    end
    for _, ____entry in ipairs(ages:getEntries()) do
        do
            local k, v = ____entry.key, ____entry.value
            io.write(k .. "=" .. v .. " ")
        end
    end
    print()
    for k, v in ages:iter() do
        io.write(k .. ":" .. v .. " ")
    end
    print()
    print(__K2L_Str(ages:map(function(____destructured)
        local k, v = ____destructured.key, ____destructured.value
        return k .. v
    end)))
    print(__K2L_Str(ages:filter(function(it) return it.value > 30 end)))
    print(__K2L_Str(ages:mapValues(function(it) return it.value + 1 end)))
    print(__K2L_Str(ages:getEntries():map(function(it) return it.key end)))
    local counts = __K2L_MapOf()
    for c in ("mississippi"):gmatch(".") do
        counts:set(c, (counts:get(c) or 0) + 1)
    end
    print(__K2L_Str(counts))
    local m = __K2L_HashMap.new()
    m:set("a", 1)
    m:put("b", 2)
    m:remove("a")
    print(__K2L_Str(m))
    print(m:getOrPut("c", function() return 3 end))
    print(__K2L_Str(m))
    local grid = __K2L_MapOf()
    local ____key = Key.new(1, 2)
    grid:set(____key, "treasure")
    print(__K2L_Str(grid:get(Key.new(1, 2))))
    print(grid:containsKey(Key.new(1, 2)))
    print(Key.new(1, 2):hashCode() == Key.new(1, 2):hashCode())
    local s = __K2L_SetOf(3, 1, 3, 2)
    print(__K2L_Str(s))
    print(s.size)
    s:add(1)
    s:add(4)
    s:remove(3)
    print(__K2L_Str(s))
    print(s:contains(2))
    local t = __K2L_SetOf(2, 4, 6)
    print(__K2L_Str(s:intersect(t)))
    print(__K2L_Str(s:union(t)))
    print(__K2L_Str(s:subtract(t)))
    print(__K2L_Equals(__K2L_SetOf(1, 2), __K2L_SetOf(2, 1)))
    print(__K2L_Str(__K2L_ListOf(3, 3, 1):toSet()))
    local sum = 0
    for _, x in ipairs(s:toList()) do
        sum = sum + x
    end
    print(sum)
    print(__K2L_Str(__K2L_ListOf("apple", "avocado", "banana"):groupBy(function(it) return __K2L_Text.first(it) end)))
    print(__K2L_Str(__K2L_ListOf("a", "bb", "ccc"):associateWith(function(it) return #it end)))
end

main()
return {Key = Key}
