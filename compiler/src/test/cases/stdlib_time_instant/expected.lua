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
local __K2L_Instant = ____lualib.__K2L_Instant
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_SystemClock = ____lualib.__K2L_SystemClock
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

local FixedClock = __K2L_Class("FixedClock")
__K2L_ClassInfo(FixedClock, "FixedClock", "FixedClock", "class")

function FixedClock:____init(at)
    self.at = at
end

function FixedClock.new(at)
    return setmetatable({at = at}, FixedClock)
end

function FixedClock:now()
    return self.at
end

local Event = __K2L_Class("Event")
__K2L_ClassInfo(Event, "Event", "Event", "class")

function Event:____init(name, at)
    self.name = name
    self.at = at
end

function Event.new(name, at)
    return setmetatable({name = name, at = at}, Event)
end

function Event:toString()
    return "Event(name=" .. self.name .. ", at=" .. __K2L_Str(self.at) .. ")"
end

function Event:hashCode()
    return (31 * __K2L_Hash(self.name) + __K2L_Hash(self.at) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Event:equals(other)
    return getmetatable(other) == Event and self.name == other.name and __K2L_Equals(self.at, other.at)
end

local function describe(i)
    return i.s .. "s+" .. i.n .. "ns"
end

local ____lambda_1 = function()
    return __K2L_ReadOnlyListOf(__K2L_Instant.fromEpochSeconds(1700000000), __K2L_Instant.fromEpochSeconds(86399), __K2L_Instant.fromEpochSeconds(-1))
end
local ____lambda_2 = function()
    return __K2L_ReadOnlyListOf(__K2L_Instant.fromEpochSeconds(10, 500000000), __K2L_Instant.fromEpochSeconds(10, 1500000000), __K2L_Instant.fromEpochSeconds(10, -1))
end
local ____lambda_3 = function()
    return __K2L_ReadOnlyListOf(__K2L_Instant.fromEpochMilliseconds(1234), __K2L_Instant.fromEpochMilliseconds(-1), __K2L_Instant.fromEpochMilliseconds(1700000000123))
end
local ____lambda_4 = function()
    return __K2L_ReadOnlyListOf(describe(__K2L_Instant.fromEpochMilliseconds(-1)), describe(__K2L_Instant.fromEpochSeconds(5, 1)))
end
local ____lambda_5 = function()
    return __K2L_ReadOnlyListOf(__K2L_Instant.fromEpochSeconds(3, 999999999):toEpochMilliseconds(), __K2L_Instant.fromEpochSeconds(-3, 1):toEpochMilliseconds())
end
local ____lambda_6 = function()
    return __K2L_Instant.fromEpochSeconds(951782400)
end
local ____lambda_7 = function()
    return __K2L_ReadOnlyListOf(__K2L_Instant.fromEpochSeconds(-62135596800), __K2L_Instant.fromEpochSeconds(-62135596801), __K2L_Instant.fromEpochSeconds(-70000000000))
end
local ____lambda_8 = function()
    return __K2L_ReadOnlyListOf(__K2L_Instant.fromEpochSeconds(253402300800), __K2L_Instant.fromEpochSeconds(4000000000000))
end
local ____lambda_9 = function()
    return __K2L_ReadOnlyListOf(__K2L_Instant.DISTANT_PAST, __K2L_Instant.DISTANT_FUTURE)
end
local ____lambda_10 = function()
    return __K2L_ReadOnlyListOf(describe(__K2L_Instant.DISTANT_PAST), describe(__K2L_Instant.DISTANT_FUTURE))
end
local ____lambda_11 = function()
    return __K2L_Instant.parse("2023-11-14T22:13:20Z", false)
end
local ____lambda_12 = function()
    return __K2L_Instant.parse("1970-01-01T00:00:00Z", false).s
end
local ____lambda_13 = function()
    return __K2L_ReadOnlyListOf(__K2L_Instant.parse("2020-02-29T12:34:56.5Z", false), __K2L_Instant.parse("2020-02-29T12:34:56.123456789z", false))
end
local ____lambda_14 = function()
    return __K2L_ReadOnlyListOf(__K2L_Instant.parse("2020-01-01T00:00:00+01:00", false), __K2L_Instant.parse("2020-01-01T00:00:00-05:30", false), __K2L_Instant.parse("2020-01-01t00:00:00+02", false))
end
local ____lambda_15 = function()
    return __K2L_ReadOnlyListOf(__K2L_Instant.parse("+12345-01-01T00:00:00Z", false), __K2L_Instant.parse("-0001-12-31T23:59:59Z", false), __K2L_Instant.parse("0000-01-01T00:00:00Z", false))
end
local ____lambda_16 = function()
    return __K2L_Instant.parse("2020-13-01T00:00:00Z", false)
end
local ____lambda_17 = function()
    return __K2L_Instant.parse("2021-02-29T00:00:00Z", false)
end
local ____lambda_18 = function()
    return __K2L_Instant.parse("2021-02-28T24:00:00Z", false)
end
local ____lambda_19 = function()
    return __K2L_Instant.parse("2020-01-01T00:00:00", false)
end
local ____lambda_20 = function()
    return __K2L_Instant.parse("2020-01-01", false)
end
local ____lambda_21 = function()
    return __K2L_Instant.parse("2020-01-01T00:00Z", false)
end
local ____lambda_22 = function()
    return __K2L_Instant.parse("2020-01-01 00:00:00Z", false)
end
local ____lambda_23 = function()
    return __K2L_Instant.parse("20201-01-01T00:00:00Z", false)
end
local ____lambda_24 = function() return __K2L_Instant.parse("", false) end
local ____lambda_25 = function()
    return __K2L_ReadOnlyListOf(__K2L_Instant.parse("2020-01-01T00:00:00Z", true), __K2L_Instant.parse("nope", true))
end
local function main()
    local epoch = __K2L_Instant.fromEpochSeconds(0)
    t("epoch", function() return epoch end)
    t("seconds", ____lambda_1)
    t("with nanos", ____lambda_2)
    t("millis", ____lambda_3)
    t("parts", ____lambda_4)
    t("toEpochMilliseconds", ____lambda_5)
    t("fractions", function()
        local ____list = __K2L_ReadOnlyListOf(1, 10, 100, 1000, 1000000, 123456789, 120000000)
        local ____out = {}
        local ____count = 0
        local ____items, ____n = ____list:____array()
        for ____i = 1, ____n do
            local it = ____items[____i]
            ____count = ____count + 1
            ____out[____count] = __K2L_Str(__K2L_Instant.fromEpochSeconds(0, it))
        end
        return __K2L_ListWrap(____out, ____count)
    end)
    t("leap day", ____lambda_6)
    t("old", ____lambda_7)
    t("far", ____lambda_8)
    t("distant", ____lambda_9)
    t("distant parts", ____lambda_10)
    t("is distant", function()
        return __K2L_ReadOnlyListOf(__K2L_Instant.DISTANT_PAST:isDistantPast(), __K2L_Instant.DISTANT_FUTURE:isDistantFuture(), epoch:isDistantPast(), epoch:isDistantFuture())
    end)
    local start = __K2L_Instant.fromEpochSeconds(1000, 750000000)
    t("plus", function()
        return __K2L_ReadOnlyListOf(start:plus(__K2L_Duration.ofWhole(1, __K2L_DurationUnit.SECONDS)), start:plus(__K2L_Duration.ofWhole(300, __K2L_DurationUnit.MILLISECONDS)), start:plus(__K2L_Duration.ofWhole(2, __K2L_DurationUnit.DAYS)), start:plus(__K2L_Duration.ofWhole(1, __K2L_DurationUnit.NANOSECONDS)))
    end)
    t("minus", function()
        return __K2L_ReadOnlyListOf(start:minus(__K2L_Duration.ofWhole(1, __K2L_DurationUnit.SECONDS)), start:minus(__K2L_Duration.ofWhole(800, __K2L_DurationUnit.MILLISECONDS)), start:minus(__K2L_Duration.ofWhole(1000, __K2L_DurationUnit.SECONDS)):minus(__K2L_Duration.ofWhole(750, __K2L_DurationUnit.MILLISECONDS)))
    end)
    t("difference", function()
        return __K2L_ReadOnlyListOf(start:minus(epoch), epoch:minus(start), start:plus(__K2L_Duration.ofWhole(90, __K2L_DurationUnit.HOURS)):minus(start))
    end)
    t("plus zero", function()
        return __K2L_Equals(start:plus(__K2L_Duration.ZERO), start)
    end)
    t("plus infinite", function()
        return __K2L_ReadOnlyListOf(start:plus(__K2L_Duration.INFINITE):isDistantFuture(), start:minus(__K2L_Duration.INFINITE):isDistantPast())
    end)
    local later = start:plus(__K2L_Duration.ofWhole(1, __K2L_DurationUnit.NANOSECONDS))
    t("compare", function()
        return __K2L_ReadOnlyListOf(__K2L_Compare(start, later) < 0, __K2L_Compare(start, later) > 0, __K2L_Compare(start, start) <= 0, __K2L_Compare(start, later), __K2L_Compare(later, start))
    end)
    t("equals", function()
        return __K2L_ReadOnlyListOf(__K2L_Equals(start, __K2L_Instant.fromEpochMilliseconds(1000750)), __K2L_Equals(start, later), __K2L_Equals(start, "x"))
    end)
    t("hashCode", function()
        return __K2L_ReadOnlyListOf(__K2L_Hash(epoch), __K2L_Hash(start), __K2L_Hash(__K2L_Instant.fromEpochSeconds(-5, 7)))
    end)
    t("sorted", function()
        return __K2L_ReadOnlyListOf(later, epoch, start):sorted()
    end)
    t("max", function() return __K2L_Num.maxOf(start, later) end)
    t("data", function() return Event.new("launch", start) end)
    t("set", function()
        return __K2L_ReadOnlySetOf(start, __K2L_Instant.fromEpochMilliseconds(1000750), later).size
    end)
    t("parse", ____lambda_11)
    t("parse epoch", ____lambda_12)
    t("parse fraction", ____lambda_13)
    t("parse offset", ____lambda_14)
    t("parse years", ____lambda_15)
    t("round trip", function()
        return __K2L_Equals(__K2L_Instant.parse(__K2L_Str(start), false), start)
    end)
    t("parse bad month", ____lambda_16)
    t("parse bad day", ____lambda_17)
    t("parse bad hour", ____lambda_18)
    t("parse no offset", ____lambda_19)
    t("parse short", ____lambda_20)
    t("parse no seconds", ____lambda_21)
    t("parse bad separator", ____lambda_22)
    t("parse year digits", ____lambda_23)
    t("parse empty", ____lambda_24)
    t("parseOrNull", ____lambda_25)
    local now = __K2L_SystemClock:now()
    t("now after 2020", function()
        return __K2L_Compare(now, __K2L_Instant.parse("2020-01-01T00:00:00Z", false)) > 0
    end)
    t("now before 2200", function()
        return __K2L_Compare(now, __K2L_Instant.parse("2200-01-01T00:00:00Z", false)) < 0
    end)
    t("now nanos in range", function()
        local ____value = now.n
        return ____value >= 0 and ____value <= 999999999
    end)
    local clock = FixedClock.new(start)
    t("fixed clock", function() return clock:now() end)
    local system = __K2L_SystemClock
    t("system clock", function() return __K2L_Compare(system:now(), now) >= 0 end)
end

__K2L_DeepMain(main)
return {t = t, FixedClock = FixedClock, Event = Event, describe = describe}
