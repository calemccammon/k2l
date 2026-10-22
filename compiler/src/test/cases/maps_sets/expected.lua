local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Text = ____lualib.__K2L_Text

local Key = __K2L_Class("Key")

function Key:____init(x, y)
    self.x = x
    self.y = y
end

function Key.new(x, y)
    return setmetatable({x = x, y = y}, Key)
end

function Key:toString()
    return "Key(x=" .. self.x .. ", y=" .. self.y .. ")"
end

function Key:hashCode()
    return (31 * self.x + self.y + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Key:equals(other)
    return getmetatable(other) == Key and self.x == other.x and self.y == other.y
end

local ____lambda_1 = function(it) return it.value > 30 end
local ____lambda_2 = function(it) return it.value + 1 end
local ____lambda_3 = function() return 3 end
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
    local ____keys, ____values, ____n = ages:____arrays()
    for ____i = 1, ____n do
        local name, age = ____keys[____i], ____values[____i]
        print(name .. " is " .. age)
    end
    local ____items, ____n_1 = ages:____entryArray()
    for ____i_1 = 1, ____n_1 do
        local ____entry = ____items[____i_1]
        do
            local k, v = ____entry.key, ____entry.value
            io.write(k .. "=" .. v .. " ")
        end
    end
    print()
    for _, k, v in ages:iter() do
        io.write(k .. ":" .. v .. " ")
    end
    print()
    print(__K2L_Str(ages:map(function(____destructured)
        local k, v = ____destructured.key, ____destructured.value
        return k .. v
    end)))
    print(__K2L_Str(ages:filter(____lambda_1)))
    print(__K2L_Str(ages:mapValues(____lambda_2)))
    local ____list = ages:getEntries()
    local ____out = {}
    local ____count = 0
    local ____items_1, ____n_2 = ____list:____array()
    for ____i_2 = 1, ____n_2 do
        local it = ____items_1[____i_2]
        ____count = ____count + 1
        ____out[____count] = it.key
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    local counts = __K2L_MapOf()
    for ____i_3 = 1, #"mississippi" do
        local c = ("mississippi"):sub(____i_3, ____i_3)
        counts:set(c, (counts:get(c) or 0) + 1)
    end
    print(__K2L_Str(counts))
    local m = __K2L_Map.new()
    m:set("a", 1)
    m:put("b", 2)
    m:remove("a")
    print(__K2L_Str(m))
    print(m:getOrPut("c", ____lambda_3))
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
    local ____items_2, ____n_3 = s:____array()
    for ____i_4 = 1, ____n_3 do
        local x = ____items_2[____i_4]
        sum = sum + x
    end
    print(sum)
    local ____list_1 = __K2L_ListOf("apple", "avocado", "banana")
    local ____result = __K2L_Map.new()
    local ____items_3, ____n_4 = ____list_1:____array()
    for ____i_5 = 1, ____n_4 do
        local it = ____items_3[____i_5]
        local ____value = __K2L_Text.first(it)
        local ____group = ____result:get(____value)
        if ____group == nil then
            ____group = __K2L_List.new()
            ____result:put(____value, ____group)
        end
        ____group:add(it)
    end
    print(__K2L_Str(____result))
    local ____list_2 = __K2L_ListOf("a", "bb", "ccc")
    local ____result_1 = __K2L_Map.new()
    local ____items_4, ____n_5 = ____list_2:____array()
    for ____i_6 = 1, ____n_5 do
        local it = ____items_4[____i_6]
        local ____value_1 = #it
        ____result_1:put(it, ____value_1)
    end
    print(__K2L_Str(____result_1))
end

__K2L_RunMain(main)
return {Key = Key}
