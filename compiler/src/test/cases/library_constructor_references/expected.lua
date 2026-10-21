local ____lualib = require("lualib_bundle")
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_Duration = ____lualib.__K2L_Duration
local __K2L_DurationUnit = ____lualib.__K2L_DurationUnit
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_IndexedValue = ____lualib.__K2L_IndexedValue
local __K2L_JavaUtil = ____lualib.__K2L_JavaUtil
local __K2L_KotlinVersion = ____lualib.__K2L_KotlinVersion
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Object = ____lualib.__K2L_Object
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringJoiner = ____lualib.__K2L_StringJoiner
local __K2L_TestTimeSource = ____lualib.__K2L_TestTimeSource

local ____lambda_1 = function(____p1) return __K2L_StringJoiner.new(____p1) end
local ____lambda_2 = function() return __K2L_List.new() end
local ____lambda_3 = function() return __K2L_TestTimeSource.new() end
local ____lambda_4 = function(____p1, ____p2)
    return __K2L_IndexedValue.new(____p1, ____p2)
end
local ____lambda_5 = function(____p1, ____p2, ____p3)
    return __K2L_KotlinVersion.new(____p1, ____p2, ____p3)
end
local ____lambda_6 = function() return __K2L_Object.new() end
local ____lambda_7 = function(____p1, ____p2)
    return __K2L_Pair.new(____p1, ____p2)
end
local function main()
    local joiner = ____lambda_1
    print(__K2L_Str(joiner(", "):add("a"):add("b")))
    local stacks = ____lambda_2
    local s = stacks()
    __K2L_JavaUtil.push(s, 1)
    __K2L_JavaUtil.push(s, 2)
    print(__K2L_Str(__K2L_JavaUtil.pop(s)) .. " " .. __K2L_Str(s))
    local clock = ____lambda_3
    local source = clock()
    local mark = source:markNow()
    source:plusAssign(__K2L_Duration.ofWhole(3, __K2L_DurationUnit.SECONDS))
    print(__K2L_Str(mark:elapsedNow()))
    local indexed = ____lambda_4
    print(__K2L_Str(__K2L_ReadOnlyListOf("x", "y"):mapIndexed(indexed)))
    local version = ____lambda_5
    print(__K2L_Compare(version(1, 9, 0), __K2L_KotlinVersion.new(2, 0)) < 0)
    local ____out = {}
    for ____i = 1, 2 do
        local it = ____i - 1
        ____out[____i] = ____lambda_6
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
    local pair = ____lambda_7
    local ____list_1 = __K2L_ReadOnlyListOf(__K2L_Pair.new(1, "a"), __K2L_Pair.new(2, "b"))
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

__K2L_Main(main)
