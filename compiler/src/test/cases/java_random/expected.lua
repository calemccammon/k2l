local ____lualib = require("lualib_bundle")
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_JavaRandom = ____lualib.__K2L_JavaRandom
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Shl = ____lualib.__K2L_Shl
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function ints()
    print("-- nextInt")
    local r = __K2L_JavaRandom.new(42)
    print(__K2L_Str(__K2L_IntRange.new(1, 8):map(function(it) return r:nextInt() end)))
    for _, bound in ipairs(__K2L_ReadOnlyListOf(2, 10, 16, 100, 1000, 1024, 65536, 1000000007, 1073741825, 2147483647)) do
        print(bound .. ": " .. __K2L_Str(__K2L_IntRange.new(1, 6):map(function(it) return r:nextInt(bound) end)))
    end
    local negative = __K2L_JavaRandom.new(-12345)
    print(__K2L_Str(__K2L_IntRange.new(1, 5):map(function(it) return negative:nextInt(50) end)))
    local big = __K2L_JavaRandom.new(1234567890123)
    print(__K2L_Str(__K2L_IntRange.new(1, 5):map(function(it) return big:nextInt(1000) end)))
    print(__K2L_Str(__K2L_IntRange.new(1, 5):map(function(it) return big:nextInt() end)))
    local ranged = __K2L_JavaRandom.new(99)
    print(__K2L_Str(__K2L_IntRange.new(1, 8):map(function(it) return ranged:nextInt(5, 15) end)))
    print(__K2L_Str(__K2L_IntRange.new(1, 8):map(function(it) return ranged:nextInt(-100, 100) end)))
    print(__K2L_Str(__K2L_IntRange.new(1, 4):map(function(it) return ranged:nextInt(0, __K2L_Shl(1, 20)) end)))
    print(__K2L_Str(__K2L_IntRange.new(1, 4):map(function(it) return ranged:nextInt(10, 11) end)))
    print(__K2L_Str(__K2L_IntRange.new(1, 4):map(function(it)
        return ranged:nextInt(-1000000000, 1000000000)
    end)))
    print(__K2L_Str(__K2L_IntRange.new(1, 4):map(function(it)
        return ranged:nextInt(-2000000000, 2000000000)
    end)))
    local ____ok, ____result = pcall(function()
        ranged:nextInt(0)
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
    local ____ok_1, ____result_1 = pcall(function()
        ranged:nextInt(5, 5)
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
end

local function others()
    print("-- others")
    local r = __K2L_JavaRandom.new(2024)
    print(__K2L_Str(__K2L_IntRange.new(1, 10):map(function(it) return r:nextBoolean() end)))
    print(__K2L_Str(__K2L_IntRange.new(1, 4):map(function(it)
        return __K2L_StringFormat("%.12f", r:nextDouble())
    end)))
    print(__K2L_Str(__K2L_IntRange.new(1, 4):map(function(it)
        return __K2L_StringFormat("%.7f", r:nextFloat())
    end)))
    print(__K2L_Str(__K2L_IntRange.new(1, 6):map(function(it)
        return __K2L_StringFormat("%.9f", r:nextGaussian())
    end)))
    print(__K2L_Str(__K2L_IntRange.new(1, 3):map(function(it)
        return __K2L_StringFormat("%.9f", r:nextDouble(10.0))
    end)))
    print(__K2L_Str(__K2L_IntRange.new(1, 3):map(function(it)
        return __K2L_StringFormat("%.9f", r:nextDouble(-5.0, 5.0))
    end)))
    local a = __K2L_JavaRandom.new(7)
    local b = __K2L_JavaRandom.new(7)
    print(a:nextInt() == b:nextInt())
    a:setSeed(100)
    b:setSeed(100)
    print(__K2L_Equals(__K2L_IntRange.new(1, 3):map(function(it) return a:nextInt(1000) end), __K2L_IntRange.new(1, 3):map(function(it) return b:nextInt(1000) end)))
    a:setSeed(100)
    print(a:nextInt(1000))
    local unseeded = __K2L_JavaRandom.new()
    local value = unseeded:nextInt(10)
    print(value >= 0 and value <= 9)
end

local function main()
    ints()
    others()
end

main()
return {ints = ints, others = others}
