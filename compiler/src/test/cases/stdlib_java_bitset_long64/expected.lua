local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_BitSet = ____lualib.__K2L_BitSet
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf

local function bits(...)
    local indexes = __K2L_ArrayOf(...)
    local set = __K2L_BitSet.new()
    for ____i = 1, indexes.size do
        local i = indexes[____i]
        set:set(i)
    end
    return set
end

local function main()
    print(__K2L_Str(bits(0, 63, 64, 130):toLongArray():toList()))
    print(__K2L_Str(bits(31, 32, 62, 63):toLongArray():toList()))
    local ____value = __K2L_BitSet.new()
    ____value:set(0, 128)
    print(__K2L_Str(____value:toLongArray():toList()))
    local ____value_1 = __K2L_BitSet.valueOf(__K2L_TypedArrayOf("[J", -1, -9223372036854775807 - 1, 0), false)
    print(____value_1:cardinality() .. " " .. ____value_1:length() .. " " .. ____value_1:size() .. " " .. ____value_1:hashCode())
    local ____value_2 = __K2L_BitSet.valueOf(__K2L_TypedArrayOf("[J", 9223372036854775807), false)
    print(____value_2:cardinality() .. " " .. ____value_2:nextClearBit(0) .. " " .. ____value_2:previousSetBit(100))
    print(__K2L_Str(__K2L_BitSet.valueOf(__K2L_TypedArrayOf("[J", 81985529216486895, -81985529216486895), false)))
    local words = __K2L_TypedArrayOf("[J", -2, 9223090566172966912, 1 << 63)
    print(__K2L_BitSet.valueOf(words, false):toLongArray():contentEquals(words))
    print(__K2L_Str(__K2L_BitSet.valueOf(words, false):toByteArray():toList()))
end

__K2L_Main(main)
return {bits = bits}
