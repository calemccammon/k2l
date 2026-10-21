local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Duration = ____lualib.__K2L_Duration
local __K2L_DurationUnit = ____lualib.__K2L_DurationUnit
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

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

local Lap = __K2L_Class("Lap")
__K2L_ClassInfo(Lap, "Lap", "Lap", "class")

function Lap:____init(name, time)
    self.name = name
    self.time = time
end

function Lap.new(name, time)
    return setmetatable({name = name, time = time}, Lap)
end

function Lap:toString()
    return "Lap(name=" .. self.name .. ", time=" .. __K2L_Str(self.time) .. ")"
end

function Lap:hashCode()
    return (31 * __K2L_Hash(self.name) + __K2L_Hash(self.time) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Lap:equals(other)
    return getmetatable(other) == Lap and self.name == other.name and __K2L_Equals(self.time, other.time)
end

local ____lambda_1 = function()
    return __K2L_ReadOnlyListOf(__K2L_Duration.ofWhole(1, __K2L_DurationUnit.NANOSECONDS), __K2L_Duration.ofWhole(2, __K2L_DurationUnit.MICROSECONDS), __K2L_Duration.ofWhole(3, __K2L_DurationUnit.MILLISECONDS), __K2L_Duration.ofWhole(4, __K2L_DurationUnit.SECONDS), __K2L_Duration.ofWhole(5, __K2L_DurationUnit.MINUTES), __K2L_Duration.ofWhole(6, __K2L_DurationUnit.HOURS), __K2L_Duration.ofWhole(7, __K2L_DurationUnit.DAYS))
end
local ____lambda_2 = function()
    return __K2L_ReadOnlyListOf(__K2L_Duration.ofWhole(10000000000, __K2L_DurationUnit.NANOSECONDS), __K2L_Duration.ofWhole(90, __K2L_DurationUnit.SECONDS), __K2L_Duration.ofWhole(36, __K2L_DurationUnit.HOURS))
end
local ____lambda_3 = function()
    return __K2L_ReadOnlyListOf(__K2L_Duration.ofDouble(1.5, __K2L_DurationUnit.SECONDS), __K2L_Duration.ofDouble(0.25, __K2L_DurationUnit.MILLISECONDS), __K2L_Duration.ofDouble(2.75, __K2L_DurationUnit.HOURS), __K2L_Duration.ofDouble(1.0E-6, __K2L_DurationUnit.SECONDS), __K2L_Duration.ofDouble(1.234567, __K2L_DurationUnit.SECONDS))
end
local ____lambda_4 = function()
    return __K2L_ReadOnlyListOf(__K2L_Duration.ofWhole(3, __K2L_DurationUnit.MINUTES), __K2L_Duration.ofWhole(2, __K2L_DurationUnit.DAYS), __K2L_Duration.ofDouble(0.5, __K2L_DurationUnit.SECONDS))
end
local ____lambda_5 = function()
    return __K2L_ReadOnlyListOf(__K2L_Duration.ZERO, __K2L_Duration.INFINITE, __K2L_Duration.INFINITE:unaryMinus())
end
local ____lambda_6 = function()
    return __K2L_ReadOnlyListOf(__K2L_Duration.ofWhole(90, __K2L_DurationUnit.MINUTES), __K2L_Duration.ofWhole(1, __K2L_DurationUnit.DAYS):plus(__K2L_Duration.ofWhole(1, __K2L_DurationUnit.SECONDS)), __K2L_Duration.ofWhole(25, __K2L_DurationUnit.HOURS):plus(__K2L_Duration.ofWhole(30, __K2L_DurationUnit.SECONDS)), __K2L_Duration.ofWhole(61, __K2L_DurationUnit.SECONDS):plus(__K2L_Duration.ofWhole(500, __K2L_DurationUnit.MILLISECONDS)))
end
local ____lambda_7 = function()
    return __K2L_ReadOnlyListOf(__K2L_Duration.ofWhole(1500, __K2L_DurationUnit.MICROSECONDS), __K2L_Duration.ofWhole(1001, __K2L_DurationUnit.NANOSECONDS), __K2L_Duration.ofWhole(999, __K2L_DurationUnit.NANOSECONDS), __K2L_Duration.ofWhole(1, __K2L_DurationUnit.MILLISECONDS):plus(__K2L_Duration.ofWhole(1, __K2L_DurationUnit.NANOSECONDS)))
end
local ____lambda_8 = function()
    return __K2L_ReadOnlyListOf(__K2L_Duration.ofWhole(5, __K2L_DurationUnit.SECONDS):unaryMinus(), __K2L_Duration.ofWhole(90, __K2L_DurationUnit.MINUTES):unaryMinus(), __K2L_Duration.ofDouble(1.5, __K2L_DurationUnit.SECONDS):unaryMinus())
end
local ____lambda_9 = function()
    return __K2L_ReadOnlyListOf(__K2L_Duration.ofDouble(1.1, __K2L_DurationUnit.SECONDS), __K2L_Duration.ofDouble(1.01, __K2L_DurationUnit.SECONDS), __K2L_Duration.ofDouble(1.001, __K2L_DurationUnit.SECONDS), __K2L_Duration.ofDouble(1.0001, __K2L_DurationUnit.SECONDS), __K2L_Duration.ofDouble(2.5, __K2L_DurationUnit.MILLISECONDS))
end
local ____lambda_10 = function()
    return __K2L_Duration.INFINITE:plus(__K2L_Duration.ofWhole(5, __K2L_DurationUnit.DAYS))
end
local ____lambda_11 = function()
    return __K2L_Duration.INFINITE:minus(__K2L_Duration.INFINITE)
end
local ____lambda_12 = function() return __K2L_Duration.ZERO:div(0) end
local ____lambda_13 = function()
    return __K2L_ReadOnlyListOf(__K2L_Duration.ofWhole(3, __K2L_DurationUnit.SECONDS), __K2L_Duration.ofWhole(1, __K2L_DurationUnit.MINUTES), __K2L_Duration.ofWhole(500, __K2L_DurationUnit.MILLISECONDS), __K2L_Duration.ofWhole(2, __K2L_DurationUnit.SECONDS)):sorted()
end
local ____lambda_14 = function()
    return __K2L_Num.maxOf(__K2L_Duration.ofWhole(1, __K2L_DurationUnit.SECONDS), __K2L_Duration.ofWhole(2, __K2L_DurationUnit.SECONDS))
end
local ____lambda_15 = function()
    return __K2L_ReadOnlySetOf(__K2L_Duration.ofWhole(1, __K2L_DurationUnit.SECONDS), __K2L_Duration.ofWhole(1000, __K2L_DurationUnit.MILLISECONDS), __K2L_Duration.ofWhole(2, __K2L_DurationUnit.SECONDS)).size
end
local ____lambda_16 = function()
    return __K2L_ReadOnlyListOf(__K2L_Hash(__K2L_Duration.ofWhole(1, __K2L_DurationUnit.SECONDS)), __K2L_Hash(__K2L_Duration.ofWhole(0, __K2L_DurationUnit.SECONDS)), __K2L_Hash(__K2L_Duration.ofWhole(-3, __K2L_DurationUnit.MILLISECONDS)))
end
local ____lambda_17 = function()
    return __K2L_ReadOnlyListOf(__K2L_Duration.ofDouble(1.5, __K2L_DurationUnit.SECONDS):toLong(__K2L_DurationUnit.MICROSECONDS), __K2L_Duration.ofDouble(1.5, __K2L_DurationUnit.SECONDS):toLong(__K2L_DurationUnit.NANOSECONDS), __K2L_Duration.ofDouble(-1.5, __K2L_DurationUnit.SECONDS):toLong(__K2L_DurationUnit.SECONDS))
end
local ____lambda_18 = function()
    return __K2L_ReadOnlyListOf(__K2L_Duration.ofWhole(90, __K2L_DurationUnit.SECONDS):toDouble(__K2L_DurationUnit.MINUTES), __K2L_Duration.ofWhole(1500, __K2L_DurationUnit.MILLISECONDS):toDouble(__K2L_DurationUnit.SECONDS))
end
local ____lambda_19 = function(days, hours, minutes, seconds, nanoseconds)
    return days .. " " .. hours .. " " .. minutes .. " " .. seconds .. " " .. nanoseconds
end
local ____lambda_20 = function(hours, minutes, seconds, nanoseconds)
    return __K2L_ReadOnlyListOf(hours, minutes, seconds, nanoseconds)
end
local ____lambda_21 = function()
    return __K2L_Duration.ofWhole(26, __K2L_DurationUnit.HOURS):toComponents(4, ____lambda_20)
end
local ____lambda_22 = function(seconds, nanoseconds)
    return seconds * 10 + (nanoseconds >= 0 and nanoseconds // 100000000 or 0 - -nanoseconds // 100000000)
end
local ____lambda_23 = function()
    return __K2L_Duration.ofDouble(2.5, __K2L_DurationUnit.SECONDS):toComponents(2, ____lambda_22)
end
local ____lambda_24 = function()
    return __K2L_ReadOnlyListOf(__K2L_DurationUnit.SECONDS, __K2L_DurationUnit.SECONDS.name, __K2L_DurationUnit.HOURS.ordinal)
end
local ____lambda_25 = function()
    return __K2L_Compare(__K2L_DurationUnit.MINUTES, __K2L_DurationUnit.SECONDS) > 0
end
local ____lambda_26 = function()
    return __K2L_DurationUnit.values():joinToString()
end
local ____lambda_27 = function() return __K2L_DurationUnit.valueOf("DAYS") end
local ____lambda_28 = function(it) return it.time end
local ____lambda_29 = function(acc, x) return acc:plus(x) end
local function main()
    t("units", ____lambda_1)
    t("long", ____lambda_2)
    t("double", ____lambda_3)
    t("toDuration", ____lambda_4)
    t("constants", ____lambda_5)
    t("mixed", ____lambda_6)
    t("small", ____lambda_7)
    t("negative", ____lambda_8)
    t("fractions", ____lambda_9)
    local a = __K2L_Duration.ofWhole(2, __K2L_DurationUnit.MINUTES)
    local b = __K2L_Duration.ofWhole(45, __K2L_DurationUnit.SECONDS)
    t("plus/minus", function()
        return __K2L_ReadOnlyListOf(a:plus(b), a:minus(b), b:minus(a))
    end)
    t("times", function()
        return __K2L_ReadOnlyListOf(a:times(3), b:timesDouble(1.5), b:times(2), a:timesDouble(0.5))
    end)
    t("div", function()
        return __K2L_ReadOnlyListOf(a:div(4), a:divDouble(2.5), a:divDuration(b), b:divDuration(a))
    end)
    t("abs", function()
        return __K2L_ReadOnlyListOf(b:minus(a):absoluteValue(), a:absoluteValue())
    end)
    t("infinite sum", ____lambda_10)
    t("infinite minus infinite", ____lambda_11)
    t("zero by zero", ____lambda_12)
    t("compare", function()
        return __K2L_ReadOnlyListOf(__K2L_Compare(a, b) > 0, __K2L_Compare(a, b) < 0, __K2L_Equals(a, __K2L_Duration.ofWhole(120, __K2L_DurationUnit.SECONDS)), not __K2L_Equals(a, b), __K2L_Compare(a, b), __K2L_Compare(b, b))
    end)
    t("sorted", ____lambda_13)
    t("maxOf", ____lambda_14)
    t("set", ____lambda_15)
    t("hash", ____lambda_16)
    t("predicates", function()
        return __K2L_ReadOnlyListOf(b:isPositive(), b:unaryMinus():isNegative(), __K2L_Duration.ZERO:isPositive(), __K2L_Duration.INFINITE:isInfinite(), a:isFinite())
    end)
    local d = __K2L_Duration.ofWhole(1, __K2L_DurationUnit.DAYS):plus(__K2L_Duration.ofWhole(2, __K2L_DurationUnit.HOURS)):plus(__K2L_Duration.ofWhole(3, __K2L_DurationUnit.MINUTES)):plus(__K2L_Duration.ofWhole(4, __K2L_DurationUnit.SECONDS)):plus(__K2L_Duration.ofWhole(5, __K2L_DurationUnit.MILLISECONDS))
    t("inWhole", function()
        return __K2L_ReadOnlyListOf(d:toLong(__K2L_DurationUnit.DAYS), d:toLong(__K2L_DurationUnit.HOURS), d:toLong(__K2L_DurationUnit.MINUTES), d:toLong(__K2L_DurationUnit.SECONDS), d:toLong(__K2L_DurationUnit.MILLISECONDS))
    end)
    t("inWholeSmall", ____lambda_17)
    t("toLong/toInt", function()
        return __K2L_ReadOnlyListOf(d:toLong(__K2L_DurationUnit.HOURS), d:toInt(__K2L_DurationUnit.MINUTES), __K2L_Duration.INFINITE:toInt(__K2L_DurationUnit.SECONDS))
    end)
    t("toDouble", ____lambda_18)
    t("components", function() return d:toComponents(5, ____lambda_19) end)
    t("components4", ____lambda_21)
    t("components2", ____lambda_23)
    t("unitString", function()
        return __K2L_ReadOnlyListOf(d:toUnitString(__K2L_DurationUnit.HOURS, 2), __K2L_Duration.ofWhole(1500, __K2L_DurationUnit.MILLISECONDS):toUnitString(__K2L_DurationUnit.SECONDS), __K2L_Duration.ofDouble(2.5, __K2L_DurationUnit.SECONDS):toUnitString(__K2L_DurationUnit.SECONDS))
    end)
    t("iso", function()
        return __K2L_ReadOnlyListOf(d:toIsoString(), __K2L_Duration.ofWhole(0, __K2L_DurationUnit.SECONDS):toIsoString(), __K2L_Duration.ofWhole(-90, __K2L_DurationUnit.MINUTES):toIsoString(), __K2L_Duration.ofDouble(1.5, __K2L_DurationUnit.SECONDS):toIsoString())
    end)
    t("unit", ____lambda_24)
    t("unit order", ____lambda_25)
    t("unit entries", ____lambda_26)
    t("unit valueOf", ____lambda_27)
    local laps = __K2L_ReadOnlyListOf(Lap.new("a", __K2L_Duration.ofWhole(61, __K2L_DurationUnit.SECONDS)), Lap.new("b", __K2L_Duration.ofDouble(59.5, __K2L_DurationUnit.SECONDS)), Lap.new("c", __K2L_Duration.ofWhole(1, __K2L_DurationUnit.MINUTES):plus(__K2L_Duration.ofWhole(2, __K2L_DurationUnit.SECONDS))))
    t("laps", function() return laps:sortedBy(____lambda_28, true) end)
    local total = __K2L_Duration.ZERO
    local ____mod = laps.____modCount
    for ____i = 1, laps.size do
        local lap = laps[____i]
        total = total:plus(lap.time)
        if laps.____modCount ~= ____mod and laps:____comodified(____i) then
            break
        end
    end
    t("total", function()
        return "total: " .. __K2L_Str(total) .. ", average: " .. __K2L_Str(total:div(laps.size))
    end)
    t("sumOf", function()
        local ____out = {}
        local ____count = 0
        local ____items, ____n = laps:____array()
        for ____i_1 = 1, ____n do
            local it = ____items[____i_1]
            ____count = ____count + 1
            ____out[____count] = it.time
        end
        return __K2L_ListWrap(____out, ____count):fold(__K2L_Duration.ZERO, ____lambda_29)
    end)
    t("when", function()
        if __K2L_Compare(total, __K2L_Duration.ofWhole(3, __K2L_DurationUnit.MINUTES)) > 0 then
            return "slow"
        elseif __K2L_Compare(total, __K2L_Duration.ofWhole(2, __K2L_DurationUnit.MINUTES)) > 0 then
            return "ok"
        else
            return "fast"
        end
    end)
end

__K2L_DeepMain(main)
return {t = t, Lap = Lap}
