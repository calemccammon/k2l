local ____lualib = require("lualib_bundle")
local __K2L_CharDirectionality = ____lualib.__K2L_CharDirectionality
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_List = ____lualib.__K2L_List
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringToList = ____lualib.__K2L_StringToList

local ____lambda_1 = function(it) return it.name .. "=" .. it.value end
local ____lambda_2 = function(it) return string.char(it) end
local ____lambda_3 = function(it) return it.value.size end
local ____lambda_4 = function(it)
    return __K2L_CharDirectionality.of(it:byte())
end
local function main()
    print(__K2L_CharDirectionality.values():joinToString(nil, nil, nil, nil, nil, ____lambda_1))
    print(__K2L_CharDirectionality.values().size)
    print(__K2L_CharDirectionality.valueOf("WHITESPACE").ordinal)
    local ____list = __K2L_IntRange.new(0, 128 - 1):map(____lambda_2)
    local ____result = __K2L_Map.new()
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        local ____value = __K2L_CharDirectionality.of(it:byte())
        local ____group = ____result:get(____value)
        if ____group == nil then
            ____group = __K2L_List.new()
            ____result:put(____value, ____group)
        end
        ____group:add(it)
    end
    print(__K2L_Str(____result:mapValues(____lambda_3)))
    print(__K2L_Str(__K2L_StringToList("a1 +,\t\n#"):map(____lambda_4)))
    print(__K2L_Str(__K2L_ReadOnlyListOf(__K2L_CharDirectionality.of(("a"):byte()) == __K2L_CharDirectionality.LEFT_TO_RIGHT, __K2L_CharDirectionality.of(("5"):byte()).value)))
end

__K2L_Main(main)
