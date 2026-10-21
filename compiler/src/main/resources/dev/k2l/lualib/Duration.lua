-- requires: Class, Str, Equals, Hash, IDiv, IRem, Exceptions, EnumValues, EnumValueOf, Bit, ToInt32
-- kotlin.time: Duration (its nanoseconds in `ns`, ±math.huge for INFINITE), DurationUnit, TimedValue, and the time
-- sources TimeSource.Monotonic (os.clock: processor time, not wall time) and TestTimeSource with their time marks.
-- Durations are exact to the nanosecond within ±2^53 ns (104 days) without Lua integers, and within ±146 years with them.
local __K2L_Duration = __K2L_Class("kotlin.time.Duration")
local __K2L_DurationUnit = __K2L_Class("kotlin.time.DurationUnit")
local __K2L_TimedValue = __K2L_Class("kotlin.time.TimedValue")
local __K2L_TimeMark = __K2L_Class("kotlin.time.TimeSource.Monotonic.ValueTimeMark")
local __K2L_TestTimeSource = __K2L_Class("kotlin.time.TestTimeSource")

local floor, huge, format = math.floor, math.huge, string.format
local IDiv, IRem = __K2L_IDiv, __K2L_IRem

------------------------------------------------------------------ DurationUnit

local UNITS = {
    {"NANOSECONDS", 1, "ns"}, {"MICROSECONDS", 1000, "us"}, {"MILLISECONDS", 1000000, "ms"}, {"SECONDS", 1000000000, "s"},
    {"MINUTES", 60000000000, "m"}, {"HOURS", 3600000000000, "h"}, {"DAYS", 86400000000000, "d"},
}
local units = {}
for i, u in ipairs(UNITS) do
    local unit = setmetatable({name = u[1], ordinal = i - 1, scale = u[2], short = u[3]}, __K2L_DurationUnit)
    __K2L_DurationUnit[u[1]] = unit
    units[i] = unit
end
__K2L_DurationUnit.____values = units

function __K2L_DurationUnit:toString()
    return self.name
end

__K2L_DurationUnit.__tostring = __K2L_DurationUnit.toString

function __K2L_DurationUnit:compareTo(other)
    return self.ordinal - other.ordinal
end

function __K2L_DurationUnit.values()
    return __K2L_EnumValues(__K2L_DurationUnit)
end

function __K2L_DurationUnit.valueOf(name)
    return __K2L_EnumValueOf(__K2L_DurationUnit, name)
end

------------------------------------------------------------------ Duration

local function of(ns)
    return setmetatable({ns = ns}, __K2L_Duration)
end

local ZERO, INFINITE, NEG_INFINITE = of(0), of(huge), of(-huge)
__K2L_Duration.ZERO, __K2L_Duration.INFINITE = ZERO, INFINITE

local MAX_LONG = 9223372036854775807
local MIN_LONG = -MAX_LONG - 1

local function illegal(message)
    error(__K2L_IllegalArgumentException.new(message))
end

local function isInfinite(ns)
    return ns == huge or ns == -huge
end

-- Long.toDuration(unit), Int.toDuration(unit)
function __K2L_Duration.ofWhole(value, unit)
    return of(value * unit.scale)
end

-- Double.toDuration(unit): rounded to the nanosecond (Math.round), saturating to INFINITE
function __K2L_Duration.ofDouble(value, unit)
    if value ~= value then
        illegal("Duration value cannot be NaN.")
    end
    local ns = value * unit.scale
    if ns >= 4.611686018427388e21 then
        return INFINITE
    elseif ns <= -4.611686018427388e21 then
        return NEG_INFINITE
    end
    return of(floor(ns + 0.5))
end

function __K2L_Duration:plus(other)
    local a, b = self.ns, other.ns
    if isInfinite(a) then
        if isInfinite(b) and a ~= b then
            illegal("Summing infinite durations of different signs yields an undefined result.")
        end
        return self
    elseif isInfinite(b) then
        return other
    end
    return of(a + b)
end

function __K2L_Duration:minus(other)
    return self:plus(of(-other.ns))
end

function __K2L_Duration:unaryMinus()
    return of(-self.ns)
end

function __K2L_Duration:times(scale)
    local ns = self.ns
    if isInfinite(ns) then
        if scale == 0 then
            illegal("Multiplying infinite duration by zero yields an undefined result.")
        end
        return (ns > 0) == (scale > 0) and INFINITE or NEG_INFINITE
    end
    return of(ns * scale)
end

function __K2L_Duration:timesDouble(scale)
    local whole = floor(scale + 0.5)
    if whole == scale then
        return self:times(whole)
    end
    return __K2L_Duration.ofDouble(self.ns * scale, units[1])
end

function __K2L_Duration:div(scale)
    local ns = self.ns
    if scale == 0 then
        if ns > 0 then
            return INFINITE
        elseif ns < 0 then
            return NEG_INFINITE
        end
        illegal("Dividing zero duration by zero yields an undefined result.")
    end
    if isInfinite(ns) then
        return (ns > 0) == (scale > 0) and INFINITE or NEG_INFINITE
    end
    return of(IDiv(ns, scale))
end

function __K2L_Duration:divDouble(scale)
    local whole = floor(scale + 0.5)
    if whole == scale and whole ~= 0 then
        return self:div(whole)
    end
    return __K2L_Duration.ofDouble(self.ns / scale, units[1])
end

function __K2L_Duration:divDuration(other)
    return self.ns / other.ns
end

function __K2L_Duration:compareTo(other)
    local a, b = self.ns, other.ns
    return a < b and -1 or (a > b and 1 or 0)
end

function __K2L_Duration:equals(other)
    return getmetatable(other) == __K2L_Duration and other.ns == self.ns
end

__K2L_Duration.__eq = __K2L_Duration.equals

function __K2L_Duration.__lt(a, b)
    return a.ns < b.ns
end

function __K2L_Duration.__le(a, b)
    return a.ns <= b.ns
end

-- Long.hashCode() of an integral number
local function longHash(n)
    local lo = n % 4294967296
    local hi = ((n - lo) / 4294967296) % 4294967296
    return __K2L_ToInt32(__K2L_BXor(hi, lo))
end

-- the hash of the JVM's raw value: the nanoseconds shifted left by one
function __K2L_Duration:hashCode()
    local ns = self.ns
    if ns == huge then
        return -2147483648
    elseif ns == -huge then
        return -2147483647
    end
    return longHash(ns * 2)
end

function __K2L_Duration:isNegative()
    return self.ns < 0
end

function __K2L_Duration:isPositive()
    return self.ns > 0
end

function __K2L_Duration:isInfinite()
    return isInfinite(self.ns)
end

function __K2L_Duration:isFinite()
    return not isInfinite(self.ns)
end

function __K2L_Duration:absoluteValue()
    return self.ns < 0 and of(-self.ns) or self
end

function __K2L_Duration:toLong(unit)
    local ns = self.ns
    if ns == huge then
        return MAX_LONG
    elseif ns == -huge then
        return MIN_LONG
    end
    return IDiv(ns, unit.scale)
end

function __K2L_Duration:toInt(unit)
    local value = self:toLong(unit)
    if value > 2147483647 then
        return 2147483647
    elseif value < -2147483648 then
        return -2147483648
    end
    return value
end

function __K2L_Duration:toDouble(unit)
    return self.ns / unit.scale
end

-- toComponents { days, hours, minutes, seconds, nanoseconds -> } and its shorter forms: `count` is the lambda's arity
function __K2L_Duration:toComponents(count, action)
    local ns = self.ns
    local infinite = isInfinite(ns)
    local seconds = infinite and 0 or IRem(IDiv(ns, 1000000000), 60)
    local nanos = infinite and 0 or IRem(ns, 1000000000)
    if count == 2 then
        return action(self:toLong(units[4]), nanos)
    end
    local minutes = infinite and 0 or IRem(IDiv(ns, 60000000000), 60)
    if count == 3 then
        return action(self:toLong(units[5]), seconds, nanos)
    end
    local hours = infinite and 0 or IRem(IDiv(ns, 3600000000000), 24)
    if count == 4 then
        return action(self:toLong(units[6]), minutes, seconds, nanos)
    end
    return action(self:toLong(units[7]), hours, minutes, seconds, nanos)
end

local function whole(n)
    return format("%d", n)
end

-- `whole` and the fraction `fractional` of `size` digits: the fraction without its trailing zeros, but in groups of three
-- digits once it has three or more (or always, for ISO)
local function fractional(out, wholePart, fraction, size, unit, isoZeroes)
    out[#out + 1] = whole(wholePart)
    if fraction ~= 0 then
        local digits = format("%0" .. size .. "d", fraction)
        local nonZero = #digits:gsub("0+$", "")
        if not isoZeroes and nonZero < 3 then
            out[#out + 1] = "." .. digits:sub(1, nonZero)
        else
            out[#out + 1] = "." .. digits:sub(1, floor((nonZero + 2) / 3) * 3)
        end
    end
    out[#out + 1] = unit
end

function __K2L_Duration:toString()
    local ns = self.ns
    if ns == 0 then
        return "0s"
    elseif ns == huge then
        return "Infinity"
    elseif ns == -huge then
        return "-Infinity"
    end
    local negative = ns < 0
    local abs = negative and -ns or ns
    local days, hours = IDiv(abs, 86400000000000), IRem(IDiv(abs, 3600000000000), 24)
    local minutes, seconds = IRem(IDiv(abs, 60000000000), 60), IRem(IDiv(abs, 1000000000), 60)
    local nanos = IRem(abs, 1000000000)
    local hasDays, hasHours, hasMinutes = days ~= 0, hours ~= 0, minutes ~= 0
    local hasSeconds = seconds ~= 0 or nanos ~= 0
    local out, components = {}, 0
    local function separate()
        if components > 0 then
            out[#out + 1] = " "
        end
        components = components + 1
    end
    if hasDays then
        out[#out + 1] = whole(days) .. "d"
        components = 1
    end
    if hasHours or (hasDays and (hasMinutes or hasSeconds)) then
        separate()
        out[#out + 1] = whole(hours) .. "h"
    end
    if hasMinutes or (hasSeconds and (hasHours or hasDays)) then
        separate()
        out[#out + 1] = whole(minutes) .. "m"
    end
    if hasSeconds then
        separate()
        if seconds ~= 0 or hasDays or hasHours or hasMinutes then
            fractional(out, seconds, nanos, 9, "s", false)
        elseif nanos >= 1000000 then
            fractional(out, IDiv(nanos, 1000000), IRem(nanos, 1000000), 6, "ms", false)
        elseif nanos >= 1000 then
            fractional(out, IDiv(nanos, 1000), IRem(nanos, 1000), 3, "us", false)
        else
            out[#out + 1] = whole(nanos) .. "ns"
        end
    end
    local text = table.concat(out)
    if negative then
        return components > 1 and "-(" .. text .. ")" or "-" .. text
    end
    return text
end

-- a double with `decimals` places, rounded as DecimalFormat's HALF_UP: printf rounds a tie to even, this away from zero
local function halfUp(value, decimals)
    local exact = format("%." .. (decimals + 60) .. "f", value)
    local point = exact:find(".", 1, true)
    if exact:sub(point + decimals + 1):match("^50*$") then
        local step = 10 ^ -decimals
        return format("%." .. decimals .. "f", tonumber(exact:sub(1, point + decimals)) + (value < 0 and -step or step))
    end
    return format("%." .. decimals .. "f", value)
end

function __K2L_Duration:toUnitString(unit, decimals)
    decimals = decimals or 0
    if decimals < 0 then
        illegal("decimals must be not negative, but was " .. decimals)
    end
    local number = self.ns / unit.scale
    if number == huge then
        return "Infinity"
    elseif number == -huge then
        return "-Infinity"
    end
    return halfUp(number, decimals > 12 and 12 or decimals) .. unit.short
end

function __K2L_Duration:toIsoString()
    local ns = self.ns
    local out = {}
    if ns < 0 then
        out[1] = "-"
    end
    out[#out + 1] = "PT"
    local abs = ns < 0 and -ns or ns
    local hours, minutes, seconds, nanos
    if isInfinite(ns) then
        hours, minutes, seconds, nanos = 9999999999999, 0, 0, 0
    else
        hours, minutes = IDiv(abs, 3600000000000), IRem(IDiv(abs, 60000000000), 60)
        seconds, nanos = IRem(IDiv(abs, 1000000000), 60), IRem(abs, 1000000000)
    end
    local hasHours, hasSeconds = hours ~= 0, seconds ~= 0 or nanos ~= 0
    local hasMinutes = minutes ~= 0 or (hasSeconds and hasHours)
    if hasHours then
        out[#out + 1] = whole(hours) .. "H"
    end
    if hasMinutes then
        out[#out + 1] = whole(minutes) .. "M"
    end
    if hasSeconds or (not hasHours and not hasMinutes) then
        fractional(out, seconds, nanos, 9, "S", true)
    end
    return table.concat(out)
end

------------------------------------------------------------------ parsing

local SHORT_UNITS = {ns = units[1], us = units[2], ms = units[3], s = units[4], m = units[5], h = units[6], d = units[7]}
local ISO_TIME_UNITS = {H = units[6], M = units[5], S = units[4]}

-- a whole number of units plus a fraction (".5"), as Kotlin adds them: the whole part exactly, the fraction rounded
local function component(text, unit)
    local dot = text:find(".", 1, true)
    if dot == nil then
        return __K2L_Duration.ofWhole(tonumber(text), unit)
    end
    local wholePart = dot > 1 and __K2L_Duration.ofWhole(tonumber(text:sub(1, dot - 1)), unit) or ZERO
    return wholePart:plus(__K2L_Duration.ofDouble(tonumber("0" .. text:sub(dot)), unit))
end

-- PnDTnHnMn.nS; nil when malformed
local function parseIso(value, i)
    local n = #value
    i = i + 1
    if i > n then
        return nil
    end
    local result, time, previous = ZERO, false, nil
    while i <= n do
        if value:sub(i, i) == "T" then
            if time or i == n then
                return nil
            end
            time, i = true, i + 1
        else
            local text = value:match("^[%d%+%-%.]+", i)
            if text == nil or not text:match("^[%+%-]?%d*%.?%d*$") or not text:find("%d") then
                return nil
            end
            i = i + #text
            local unitChar = value:sub(i, i)
            local unit = time and ISO_TIME_UNITS[unitChar] or (not time and unitChar == "D" and units[7])
            if not unit or (previous ~= nil and previous.ordinal <= unit.ordinal) or (text:find(".", 1, true) and unit ~= units[4]) then
                return nil
            end
            previous, i = unit, i + 1
            local negative = text:sub(1, 1) == "-"
            local part = component((text:gsub("^[%+%-]", "")), unit)
            result = result:plus(negative and part:unaryMinus() or part)
        end
    end
    return result
end

-- 1h 30m, 1.5s, (1d 2h) after a sign; nil when malformed
local function parseDefault(value, i, hasSign)
    local n = #value
    local spaces = not hasSign
    if hasSign and value:sub(i, i) == "(" and value:sub(n, n) == ")" then
        spaces, i, n = true, i + 1, n - 1
        if i > n then
            return nil
        end
    end
    local result, previous, first = ZERO, nil, true
    while i <= n do
        if not first and spaces then
            i = value:find("[^ ]", i) or n + 1
        end
        first = false
        local text = value:match("^[%d%.]+", i)
        if text == nil or not text:match("^%d+%.?%d*$") then
            return nil
        end
        i = i + #text
        local name = value:sub(i, n):match("^%l+") or ""
        i = i + #name
        local unit = SHORT_UNITS[name]
        if unit == nil or (previous ~= nil and previous.ordinal <= unit.ordinal) then
            return nil
        end
        previous = unit
        if text:find(".", 1, true) and i <= n then
            return nil -- a fractional component must be the last
        end
        result = result:plus(component(text, unit))
    end
    return result
end

local function parse(value, isoOnly)
    if #value == 0 then
        return nil
    end
    local sign = value:sub(1, 1)
    local hasSign = sign == "+" or sign == "-"
    local i = hasSign and 2 or 1
    if i > #value then
        return nil
    end
    local result
    if value:sub(i, i) == "P" then
        result = parseIso(value, i)
    elseif isoOnly then
        return nil
    elseif value:sub(i):lower() == "infinity" then
        result = INFINITE
    else
        result = parseDefault(value, i, hasSign)
    end
    if result ~= nil and sign == "-" then
        return result:unaryMinus()
    end
    return result
end

-- Duration.parse / parseIsoString (`isoOnly`), and their OrNull forms (`orNull`)
function __K2L_Duration.parse(value, isoOnly, orNull)
    local result = parse(value, isoOnly)
    if result == nil and not orNull then
        illegal("Invalid " .. (isoOnly and "ISO duration" or "duration") .. " string format: '" .. value .. "'.")
    end
    return result
end

------------------------------------------------------------------ TimedValue

function __K2L_TimedValue:____init(value, duration)
    self.value = value
    self.duration = duration
end

function __K2L_TimedValue:toString()
    return "TimedValue(value=" .. __K2L_Str(self.value) .. ", duration=" .. self.duration:toString() .. ")"
end

function __K2L_TimedValue:equals(other)
    return getmetatable(other) == __K2L_TimedValue and __K2L_Equals(self.value, other.value) and self.duration:equals(other.duration)
end

function __K2L_TimedValue:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.value) + self.duration:hashCode())
end

function __K2L_TimedValue:copy(value, duration)
    if value == nil then
        value = self.value
    end
    return __K2L_TimedValue.new(value, duration or self.duration)
end

------------------------------------------------------------------ time sources and marks

-- A mark: the reading of its source (in nanoseconds) when it was taken, plus any offset added with `+`.
local function mark(source, reading)
    return setmetatable({source = source, reading = reading}, __K2L_TimeMark)
end

local Monotonic = {}

function Monotonic.read(_)
    return floor(os.clock() * 1000000000)
end

function Monotonic:markNow()
    return mark(self, Monotonic.read())
end

function Monotonic:toString()
    return "TimeSource(System.nanoTime())"
end

Monotonic.__index = Monotonic
local __K2L_Monotonic = setmetatable({}, Monotonic)

function __K2L_TimeMark:elapsedNow()
    return of(self.source:read() - self.reading)
end

function __K2L_TimeMark:plus(duration)
    if isInfinite(duration.ns) then
        return mark(self.source, duration.ns)
    end
    return mark(self.source, self.reading + duration.ns)
end

-- mark - duration, or mark - mark: the Duration between two marks of the same source
function __K2L_TimeMark:minus(other)
    if getmetatable(other) == __K2L_TimeMark then
        if other.source ~= self.source then
            illegal("Subtracting or comparing time marks from different time sources is not possible: " ..
                __K2L_Str(self) .. " and " .. __K2L_Str(other))
        end
        local a, b = self.reading, other.reading
        if isInfinite(a) or isInfinite(b) then
            if a == b then
                return ZERO
            end
            return isInfinite(a) and of(a) or of(-b)
        end
        return of(a - b)
    end
    return self:plus(of(-other.ns))
end

function __K2L_TimeMark:hasPassedNow()
    return not self:elapsedNow():isNegative()
end

function __K2L_TimeMark:hasNotPassedNow()
    return self:elapsedNow():isNegative()
end

function __K2L_TimeMark:compareTo(other)
    return self:minus(other):compareTo(ZERO)
end

function __K2L_TimeMark:equals(other)
    return getmetatable(other) == __K2L_TimeMark and self.source == other.source and self.reading == other.reading
end

function __K2L_TimeMark:hashCode()
    return __K2L_Hash(self.reading)
end

function __K2L_TimeMark:toString()
    return "ValueTimeMark(reading=" .. whole(self.reading) .. ")"
end

function __K2L_TestTimeSource:____init()
    self.nanos = 0
end

function __K2L_TestTimeSource:read()
    return self.nanos
end

function __K2L_TestTimeSource:markNow()
    return mark(self, self.nanos)
end

function __K2L_TestTimeSource:plusAssign(duration)
    if isInfinite(duration.ns) then
        error(__K2L_IllegalStateException.new("TestTimeSource will overflow if its reading " .. whole(self.nanos) ..
            "ns is advanced by " .. duration:toString() .. "."))
    end
    self.nanos = self.nanos + duration.ns
end

function __K2L_TestTimeSource:toString()
    return "TestTimeSource(" .. whole(self.nanos) .. "ns)"
end

-- measureTime { } and source.measureTime { }
local function __K2L_MeasureTime(block, source)
    local start = (source or __K2L_Monotonic):markNow()
    block()
    return start:elapsedNow()
end

local function __K2L_MeasureTimedValue(block, source)
    local start = (source or __K2L_Monotonic):markNow()
    local value = block()
    return __K2L_TimedValue.new(value, start:elapsedNow())
end
