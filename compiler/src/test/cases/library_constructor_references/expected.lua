local ____lualib = require("lualib_bundle")
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_IndexedValue = ____lualib.__K2L_IndexedValue
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Object = ____lualib.__K2L_Object
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder

local ____lambda_1 = function(____p1)
    return __K2L_StringBuilder.new(__K2L_Str(____p1))
end
local ____lambda_2 = function() return __K2L_List.new() end
local ____lambda_3 = function(____p1, ____p2)
    return __K2L_IndexedValue.new(____p1, ____p2)
end
local ____lambda_4 = function() return __K2L_Object.new() end
local ____lambda_5 = function(____p1, ____p2)
    return __K2L_Pair.new(____p1, ____p2)
end
local function main()
    local builder = ____lambda_1
    print(__K2L_Str(builder("ab"):append("c")))
    local lists = ____lambda_2
    local s = lists()
    s:add(1)
    s:add(2)
    print(s:removeLast() .. " " .. __K2L_Str(s))
    local indexed = ____lambda_3
    print(__K2L_Str(__K2L_ListOf("x", "y"):mapIndexed(indexed)))
    local ____out = {}
    for ____i = 1, 2 do
        local it = ____i - 1
        ____out[____i] = ____lambda_4
    end
    local ____list = __K2L_ListWrap(____out, 2)
    local ____out_1 = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i_1 = 1, ____n do
        local it = ____items[____i_1]
        ____count = ____count + 1
        ____out_1[____count] = it()
    end
    local anys = __K2L_ListWrap(____out_1, ____count)
    print(__K2L_Equals(anys:get(0), anys:get(1)))
    local pair = ____lambda_5
    local ____list_1 = __K2L_ListOf(__K2L_Pair.new(1, "a"), __K2L_Pair.new(2, "b"))
    local ____out_2 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_2 = 1, ____n_1 do
        local ____it = ____items_1[____i_2]
        local ____result
        do
            local n, t = ____it.first, ____it.second
            ____result = pair(t, n)
        end
        ____count_1 = ____count_1 + 1
        ____out_2[____count_1] = ____result
    end
    print(__K2L_Str(__K2L_ListWrap(____out_2, ____count_1)))
end

__K2L_RunMain(main)
