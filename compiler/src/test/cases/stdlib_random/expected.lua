local ____lualib = require("lualib_bundle")
local __K2L_CharRange = ____lualib.__K2L_CharRange
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_HashSet = ____lualib.__K2L_HashSet
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_Random = ____lualib.__K2L_Random
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function main()
    local r = __K2L_Random.seeded(42)
    local inRange = true
    for it = 0, 199 do
        do
            local i = r:nextInt(10)
            local j = r:nextInt(5, 8)
            local d = r:nextDouble()
            local e = r:nextDouble(2.0, 3.0)
            if not (i >= 0 and i <= 9) or not (j >= 5 and j <= 7) or d < 0.0 or d >= 1.0 or e < 2.0 or e >= 3.0 then
                inRange = false
            end
        end
    end
    print(inRange)
    local a = __K2L_Random.seeded(7)
    local b = __K2L_Random.seeded(7)
    print(__K2L_Equals(__K2L_IntRange.new(1, 20):map(function(it) return a:nextInt(1000) end), __K2L_IntRange.new(1, 20):map(function(it) return b:nextInt(1000) end)))
    print(__K2L_Random.seeded(1):nextInt() == __K2L_Random.seeded(1):nextInt())
    print(__K2L_Random.seeded(1):nextDouble() == __K2L_Random.seeded(1):nextDouble())
    print(__K2L_Random.seeded(1):nextBoolean() == __K2L_Random.seeded(1):nextBoolean())
    local seen = __K2L_HashSet.new()
    for it = 0, 499 do
        seen:add(r:nextInt(4))
    end
    print(seen.size)
    local trues = 0
    for it = 0, 999 do
        if r:nextBoolean() then
            trues = trues + 1
        end
    end
    local ____value = trues
    print(____value >= 300 and ____value <= 700)
    local xs = __K2L_IntRange.new(1, 20):toList()
    local shuffled = xs:shuffled(__K2L_Random.seeded(3))
    print(__K2L_Equals(shuffled:sorted(), xs))
    print(shuffled.size)
    print(__K2L_Equals(xs:shuffled(__K2L_Random.seeded(5)), xs:shuffled(__K2L_Random.seeded(5))))
    local ml = xs:toMutableList()
    ml:shuffle(__K2L_Random.seeded(9))
    print(__K2L_Equals(ml:sorted(), xs))
    print(xs:contains(xs:random(__K2L_Random.seeded(2))))
    print(xs:contains(xs:randomOrNull(__K2L_Random.seeded(2))))
    print(__K2L_Str(__K2L_ReadOnlyListOf():randomOrNull(__K2L_Random.default())))
    local ____value_1 = __K2L_Random.seeded(1):nextIntRange(__K2L_IntRange.new(1, 5), false)
    print(____value_1 >= 1 and ____value_1 <= 5)
    local ____value_2 = __K2L_CharRange.new("a", "e"):random(__K2L_Random.seeded(1))
    print(____value_2 >= "a" and ____value_2 <= "e")
    print(__K2L_StringContains("abc", __K2L_StringToList("abc"):random(__K2L_Random.seeded(1))))
    local ____value_3 = __K2L_Random.default():nextInt(5)
    print(____value_3 >= 0 and ____value_3 <= 4)
    local ____value_4 = __K2L_Random.default():nextInt(1, 3)
    print(____value_4 >= 1 and ____value_4 <= 2)
    print(__K2L_Random.default():nextDouble() < 1.0)
    local ____ok, ____result = __K2L_DeepPcall(function()
        __K2L_Random.seeded(1):nextInt(0)
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
            local e = ____error
            print(__K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    local ____ok_1, ____result_1 = __K2L_DeepPcall(function()
        __K2L_Random.seeded(1):nextInt(5, 5)
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error_1, __K2L_IllegalArgumentException) then
            local e = ____error_1
            print(__K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
    local ____ok_2, ____result_2 = __K2L_DeepPcall(function()
        __K2L_ReadOnlyListOf():random(__K2L_Random.default())
    end)
    if not ____ok_2 then
        local ____error_2 = __K2L_ToThrowable(____result_2)
        if __K2L_InstanceOf(____error_2, __K2L_NoSuchElementException) then
            local e = ____error_2
            print(__K2L_Str(e.message))
        else
            error(____error_2, 0)
        end
    end
end

__K2L_DeepMain(main)
