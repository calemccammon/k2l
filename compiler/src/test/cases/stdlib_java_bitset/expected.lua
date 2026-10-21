local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_BitSet = ____lualib.__K2L_BitSet
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_GenerateSequence = ____lualib.__K2L_GenerateSequence
local __K2L_HashSetOf = ____lualib.__K2L_HashSetOf
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntStream = ____lualib.__K2L_IntStream
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Streams = ____lualib.__K2L_Streams
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf
local __K2L_Unit = ____lualib.__K2L_Unit

local function t(label, f)
    local ____ok, ____result = __K2L_DeepPcall(function()
        print(label .. " = " .. __K2L_Str(f()))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_Exception) then
            local e = ____error
            print(label .. " EXC " .. __K2L_Str(__K2L_KClassOfValue(e).simpleName) .. ": " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
end

local function bits(...)
    local indexes = __K2L_ArrayOf(...)
    local set = __K2L_BitSet.new()
    for ____i = 1, indexes.size do
        local i = indexes[____i]
        set:set(i)
    end
    return set
end

local function sieve(n)
    local composite = __K2L_BitSet.new(n)
    composite:set(0, 2)
    local i = 2
    while i * i < n do
        if not composite:get(i) then
            local j = i * i
            while j < n do
                composite:set(j)
                j = j + i
            end
        end
        i = i + 1
    end
    composite:flip(0, n)
    return composite
end

local ____lambda_1 = function() return bits(1, 3, 40, 70, 130):get(2, 100) end
local ____lambda_2 = function()
    return bits(1, 3, 40, 70, 130):get(2, 100):size()
end
local ____lambda_3 = function()
    return __K2L_HashSetOf(bits(1, 2), bits(1, 2), bits(3)).size
end
local ____lambda_4 = function()
    return __K2L_ReadOnlyListOf(__K2L_BitSet.new(0):size(), __K2L_BitSet.new(1):size(), __K2L_BitSet.new(64):size(), __K2L_BitSet.new(65):size(), __K2L_BitSet.new(1000):size())
end
local ____lambda_5 = function() return __K2L_BitSet.new(-1) end
local ____lambda_6 = function()
    return bits(0, 50, 64, 130):toLongArray():toList()
end
local ____lambda_7 = function()
    return bits(0, 5, 31, 32, 40):toLongArray():toList()
end
local ____lambda_8 = function()
    return bits(0, 7, 8, 15, 33):toByteArray():toList()
end
local ____lambda_9 = function()
    return __K2L_Equals(__K2L_BitSet.valueOf(bits(3, 64, 99):toLongArray(), false), bits(3, 64, 99))
end
local ____lambda_10 = function()
    return __K2L_Streams.ofArray(__K2L_IntStream, bits(4, 2, 99):____bits()):toArray():toList()
end
local ____lambda_11 = function(it) return it * 2 end
local ____lambda_12 = function()
    return __K2L_Streams.ofArray(__K2L_IntStream, bits(1, 2, 3, 10):____bits()):map(____lambda_11):sum()
end
local ____lambda_13 = function() return __K2L_BitSet.new():get(-1) end
local ____lambda_14 = function() return __K2L_BitSet.new():nextSetBit(-1) end
local ____lambda_15 = function() return __K2L_BitSet.new():nextClearBit(-1) end
local ____lambda_16 = function() return __K2L_BitSet.new():previousSetBit(-2) end
local ____lambda_17 = function()
    return __K2L_BitSet.new():previousClearBit(-2)
end
local ____lambda_18 = function() return sieve(10000):cardinality() end
local ____lambda_19 = function() return sieve(10000):previousSetBit(9999) end
local function main()
    local a = __K2L_BitSet.new()
    t("empty", function()
        return __K2L_Str(a) .. " " .. tostring(a:isEmpty()) .. " " .. a:length() .. " " .. a:size() .. " " .. a:cardinality() .. " " .. a:hashCode()
    end)
    a:set(1)
    a:set(5)
    a:set(31, true)
    a:set(32)
    a:set(63, true)
    a:set(64)
    t("set", function()
        return __K2L_Str(a) .. " len=" .. a:length() .. " size=" .. a:size() .. " card=" .. a:cardinality()
    end)
    t("get", function()
        return __K2L_ReadOnlyListOf(a:get(0), a:get(1), a:get(31), a:get(32), a:get(63), a:get(64), a:get(1000))
    end)
    t("hash", function() return a:hashCode() end)
    a:clear(64)
    a:set(5, false)
    t("clear", function()
        return __K2L_Str(a) .. " len=" .. a:length() .. " size=" .. a:size() .. " hash=" .. a:hashCode()
    end)
    a:flip(2)
    a:flip(1)
    t("flip", function() return a end)
    local r = __K2L_BitSet.new()
    r:set(3, 70)
    t("set range", function()
        return "card=" .. r:cardinality() .. " len=" .. r:length() .. " size=" .. r:size() .. " first=" .. r:nextSetBit(0)
    end)
    r:clear(10, 60)
    t("clear range", function() return r end)
    r:flip(0, 12)
    t("flip range", function() return r end)
    r:set(100, 103, true)
    r:set(101, 102, false)
    t("set value range", function() return __K2L_Str(r) .. " size=" .. r:size() end)
    r:clear(0, 1000)
    t("clear all range", function()
        return __K2L_Str(r) .. " " .. tostring(r:isEmpty()) .. " " .. r:length() .. " " .. r:size()
    end)
    t("get range", ____lambda_1)
    t("get range size", ____lambda_2)
    t("get range past", function()
        local ____value = bits(1, 3):get(5, 10)
        return __K2L_Str(____value) .. " " .. ____value:size()
    end)
    local s = bits(0, 2, 33, 64, 65, 200)
    t("nextSetBit", function()
        return __K2L_GenerateSequence(s:nextSetBit(0), function(it)
            if it < 0 then
                return nil
            else
                return s:nextSetBit(it + 1)
            end
        end):toList()
    end)
    t("nextClearBit", function()
        return __K2L_ReadOnlyListOf(s:nextClearBit(0), s:nextClearBit(1), s:nextClearBit(64), s:nextClearBit(201), s:nextClearBit(999))
    end)
    t("previousSetBit", function()
        return __K2L_ReadOnlyListOf(s:previousSetBit(500), s:previousSetBit(199), s:previousSetBit(64), s:previousSetBit(1), s:previousSetBit(-1))
    end)
    t("previousClearBit", function()
        return __K2L_ReadOnlyListOf(s:previousClearBit(500), s:previousClearBit(65), s:previousClearBit(0), s:previousClearBit(2), s:previousClearBit(-1))
    end)
    t("full", function()
        local ____value_1 = __K2L_BitSet.new()
        ____value_1:set(0, 64)
        return __K2L_ReadOnlyListOf(____value_1:nextClearBit(0), ____value_1:previousClearBit(63), ____value_1:length(), ____value_1:cardinality())
    end)
    local x = bits(1, 2, 3, 40, 100)
    local y = bits(2, 3, 4, 41, 300)
    t("and", function()
        local ____value_2 = x:clone()
        ____value_2:And(y)
        return ____value_2
    end)
    t("or", function()
        local ____value_3 = x:clone()
        ____value_3:Or(y)
        return __K2L_Str(____value_3) .. " size=" .. ____value_3:size()
    end)
    t("xor", function()
        local ____value_4 = x:clone()
        ____value_4:xor(y)
        return ____value_4
    end)
    t("andNot", function()
        local ____value_5 = x:clone()
        ____value_5:andNot(y)
        return ____value_5
    end)
    t("self ops", function()
        local ____value_6 = x:clone()
        ____value_6:xor(____value_6)
        return ____value_6:isEmpty()
    end)
    t("intersects", function()
        return __K2L_ReadOnlyListOf(x:intersects(y), x:intersects(bits(5, 6)), __K2L_BitSet.new():intersects(x))
    end)
    t("equals", function()
        return __K2L_ReadOnlyListOf(__K2L_Equals(x, bits(1, 2, 3, 40, 100)), __K2L_Equals(x, y), x:equals(bits(100, 40, 3, 2, 1)), x:equals("x"), __K2L_Equals(__K2L_BitSet.new(), __K2L_BitSet.new(500)))
    end)
    t("hashes", function()
        return __K2L_ReadOnlyListOf(x:hashCode(), y:hashCode(), __K2L_BitSet.new(1000):hashCode(), bits(63):hashCode(), bits(0, 63, 64, 127, 128):hashCode())
    end)
    t("in set", ____lambda_3)
    t("sizes", ____lambda_4)
    local g = __K2L_BitSet.new()
    local sizes = __K2L_ListOf()
    local ____list = __K2L_ReadOnlyListOf(10, 70, 130, 200, 600, 5000)
    for ____i_1 = 1, ____list.size do
        local i = ____list[____i_1]
        g:set(i)
        sizes:add(g:size())
    end
    t("growth", function() return sizes end)
    t("clone size", function()
        local ____arg = g:clone():size()
        local ____value_7 = __K2L_BitSet.new(1000)
        ____value_7:set(3)
        return __K2L_ReadOnlyListOf(____arg, ____value_7:clone():size())
    end)
    t("negative size", ____lambda_5)
    t("toLongArray", ____lambda_6)
    t("toLongArray low", ____lambda_7)
    t("toByteArray", ____lambda_8)
    t("valueOf longs", function()
        local ____value_8 = __K2L_BitSet.valueOf(__K2L_TypedArrayOf("[J", 5, 0, 1 << 40, 0), false)
        return __K2L_Str(____value_8) .. " " .. ____value_8:size()
    end)
    t("valueOf bytes", function()
        local ____value_9 = __K2L_BitSet.valueOf(__K2L_TypedArrayOf("[B", 1, -128, 0, 3, 0), true)
        return __K2L_Str(____value_9) .. " " .. ____value_9:size() .. " " .. ____value_9:length()
    end)
    t("valueOf empty", function()
        local ____value_10 = __K2L_BitSet.valueOf(__K2L_TypedArrayOf("[J", 0, 0), false)
        return __K2L_Str(____value_10) .. " " .. ____value_10:size() .. " " .. tostring(____value_10:isEmpty())
    end)
    t("round trip", ____lambda_9)
    t("stream", ____lambda_10)
    t("stream sum", ____lambda_12)
    t("get negative", ____lambda_13)
    t("set negative", function()
        __K2L_BitSet.new():set(-2)
        return __K2L_Unit
    end)
    t("clear negative", function()
        __K2L_BitSet.new():clear(-3)
        return __K2L_Unit
    end)
    t("flip negative", function()
        __K2L_BitSet.new():flip(-4)
        return __K2L_Unit
    end)
    t("range negative", function()
        __K2L_BitSet.new():set(-1, 3)
        return __K2L_Unit
    end)
    t("range toIndex", function()
        __K2L_BitSet.new():clear(1, -3)
        return __K2L_Unit
    end)
    t("range reversed", function()
        __K2L_BitSet.new():flip(5, 2)
        return __K2L_Unit
    end)
    t("nextSetBit negative", ____lambda_14)
    t("nextClearBit negative", ____lambda_15)
    t("previousSetBit -2", ____lambda_16)
    t("previousClearBit -2", ____lambda_17)
    local primes = sieve(100)
    t("primes", function() return primes end)
    t("prime count", ____lambda_18)
    t("last prime", ____lambda_19)
end

__K2L_DeepMain(main)
return {t = t, bits = bits, sieve = sieve}
