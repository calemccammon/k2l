local ____lualib = require("lualib_bundle")
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_SortedMap = ____lualib.__K2L_SortedMap
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder

local function main()
    local tm = __K2L_SortedMap.new(__K2L_ReadOnlyMapOf(__K2L_Pair.new(1, "a"), __K2L_Pair.new(5, "e"), __K2L_Pair.new(9, "i")))
    print("floor(0)=" .. __K2L_Str(tm:floorKey(0)) .. " ceiling(6)=" .. __K2L_Str(tm:ceilingKey(6)) .. " higher(9)=" .. __K2L_Str(tm:higherKey(9)) .. " lower(1)=" .. __K2L_Str(tm:lowerKey(1)))
    local ____arg = __K2L_Str(tm:floorEntry(0))
    local ____arg_1 = __K2L_Str(tm:ceilingEntry(2))
    local ____receiver = tm:higherEntry(9)
    print("entries: " .. ____arg .. " " .. ____arg_1 .. " " .. __K2L_Str(____receiver and ____receiver.value))
    local ____list = __K2L_ReadOnlyListOf(0, 4, 9, 12)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = __K2L_Str(tm:floorKey(it))
    end
    local keys = __K2L_ListWrap(____out, ____count)
    print(__K2L_Str(keys))
    print("first: " .. __K2L_Str(tm:firstKey()) .. ", missing: " .. __K2L_Str(tm:higherKey(100)))
    local sb = __K2L_StringBuilder.new("ab")
    print("sb=" .. __K2L_Str(sb) .. " " .. #sb:toString())
end

__K2L_Main(main)
