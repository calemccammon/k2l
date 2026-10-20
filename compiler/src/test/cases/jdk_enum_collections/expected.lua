local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_EnumMap = ____lualib.__K2L_EnumMap
local __K2L_EnumSet = ____lualib.__K2L_EnumSet
local __K2L_EnumSets = ____lualib.__K2L_EnumSets
local __K2L_FunctionRef = ____lualib.__K2L_FunctionRef
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_KClassOf = ____lualib.__K2L_KClassOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_SortedMap = ____lualib.__K2L_SortedMap
local __K2L_SortedSet = ____lualib.__K2L_SortedSet
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf
local __K2L_Unpack = ____lualib.__K2L_Unpack

local S = __K2L_Class("S")
__K2L_ClassInfo(S, "S", "S", "class")

function S:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function S:toString()
    return self.name
end

function S:compareTo(other)
    return self.ordinal - other.ordinal
end

S.A = S.new("A", 0)
S.B = S.new("B", 1)
S.C = S.new("C", 2)
S.D = S.new("D", 3)
S.E = S.new("E", 4)
S.F = S.new("F", 5)
S.G = S.new("G", 6)
S.____values = {S.A, S.B, S.C, S.D, S.E, S.F, S.G}

local ____lambda_1 = function(____p1, ____p2) return ____p1 + ____p2 end
local ____lambda_2 = function() return __K2L_EnumSets.range(S.E, S.B) end
local ____lambda_3 = function()
    return __K2L_EnumSets.copyOf(__K2L_ReadOnlyListOf())
end
local ____lambda_4 = function()
    return __K2L_EnumMap.new(__K2L_ReadOnlyMapOf())
end
local function main()
    local m = __K2L_EnumMap.new(__K2L_JavaClass(__K2L_KClassOf(S)))
    local ____key = S.C
    m:set(____key, 3)
    local ____key_1 = S.A
    m:set(____key_1, 1)
    m:merge(S.C, 10, __K2L_FunctionRef.new("plus", "kotlin/Int.plus(kotlin.Int)", ____lambda_1))
    print(__K2L_Str(m))
    print(__K2L_Str(m:getKeys()))
    print(__K2L_Str(__K2L_EnumSets.copyOf(m:getKeys())))
    print(__K2L_Str(__K2L_EnumSets.of(S.G, S.B, S.A, S.D, S.E, S.F)))
    print(__K2L_Str(__K2L_EnumSets.of(S.G)))
    local n = __K2L_EnumSets.noneOf(__K2L_JavaClass(__K2L_KClassOf(S)))
    n:add(S.D)
    print(__K2L_Str(__K2L_Pair.new(n, __K2L_EnumSets.complementOf(n))))
    print(__K2L_Str(__K2L_EnumSets.allOf(__K2L_JavaClass(__K2L_KClassOf(S)))))
    print(__K2L_Str(__K2L_EnumSets.range(S.B, S.E)))
    print(__K2L_Str(__K2L_RunCatching(____lambda_2)))
    print(__K2L_Str(__K2L_RunCatching(____lambda_3)))
    print(__K2L_Str(__K2L_RunCatching(____lambda_4)))
    print(__K2L_Str(__K2L_EnumMap.new(__K2L_ReadOnlyMapOf(__K2L_Pair.new(S.F, 1), __K2L_Pair.new(S.A, 2)))))
    print(__K2L_InstanceOf(m, __K2L_EnumMap))
    local anyMap = m
    local anySet = n
    print(tostring(__K2L_InstanceOf(anyMap, __K2L_SortedMap)) .. " " .. tostring(__K2L_InstanceOf(anySet, __K2L_SortedSet)) .. " " .. tostring(__K2L_InstanceOf(anySet, __K2L_SortedSet)) .. " " .. tostring(__K2L_InstanceOf(anyMap, __K2L_EnumMap)))
    print(__K2L_InstanceOf(n, __K2L_EnumSet))
    print((__K2L_JavaClass(__K2L_KClassOfValue(n)).simpleName or "") .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(m)).name))
    local e = __K2L_EnumSets.copyOf(__K2L_ReadOnlyListOf(S.E, S.A))
    print(__K2L_Str(__K2L_EnumSets.complementOf(e)))
    local ____list = m:getEntries()
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = it.key.ordinal * it.value
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    m:remove(S.A)
    print(tostring(m.size) .. tostring(m:containsKey(S.A)))
    local arr = __K2L_TypedArrayOf("[LS;", S.B, S.C)
    print(__K2L_Str(__K2L_EnumSets.of(S.A, __K2L_Unpack(arr))))
end

__K2L_DeepMain(main)
return {S = S}
