-- requires: Class, Exceptions, Duration, FloorDiv, Bit, ToInt32
-- kotlin.time.Instant (whole seconds since the epoch in `s`, 0..999999999 nanoseconds in `n`) and Clock.System, whose
-- now() has the precision of os.time(): whole seconds. Instants are clamped to the JVM's range (years -1000000000 to
-- 1000000000), exact where a Long is: everywhere on Lua 5.3/5.4, within 2^53 seconds elsewhere. ISO-8601 formatting and
-- parsing follow the stdlib's, messages included.
local __K2L_Instant = __K2L_Class("kotlin.time.Instant")
local __K2L_InstantFormatException = __K2L_Class("kotlin.time.InstantFormatException", __K2L_IllegalArgumentException)

local format, huge = string.format, math.huge
local FloorDiv = __K2L_FloorDiv

local NANOS = 1000000000
local MIN_SECOND, MAX_SECOND = -31557014167219200, 31556889864403199
local MAX_LONG = 9223372036854775807
local MIN_LONG = -MAX_LONG - 1

local function make(s, n)
    return setmetatable({s = s, n = n}, __K2L_Instant)
end

local MIN, MAX = make(MIN_SECOND, 0), make(MAX_SECOND, 999999999)

-- seconds plus a nanosecond adjustment of any size, normalized and clamped
local function of(seconds, nanos)
    local carry = FloorDiv(nanos, NANOS)
    local s, n = seconds + carry, nanos - carry * NANOS
    if s < MIN_SECOND then
        return MIN
    elseif s > MAX_SECOND then
        return MAX
    end
    return make(s, n)
end

__K2L_Instant.DISTANT_PAST = make(-3217862419201, 999999999)
__K2L_Instant.DISTANT_FUTURE = make(3093527980800, 0)

function __K2L_Instant.fromEpochSeconds(seconds, nanos)
    return of(seconds, nanos or 0)
end

function __K2L_Instant.fromEpochMilliseconds(millis)
    local s = FloorDiv(millis, 1000)
    return of(s, (millis - s * 1000) * 1000000)
end

function __K2L_Instant:toEpochMilliseconds()
    local s = self.s
    if s > 9223372036854774 then
        return MAX_LONG
    elseif s < -9223372036854774 then
        return MIN_LONG
    end
    return s * 1000 + FloorDiv(self.n, 1000000)
end

function __K2L_Instant:plus(duration)
    local ns = duration.ns
    if ns == huge then
        return MAX
    elseif ns == -huge then
        return MIN
    end
    local seconds = FloorDiv(ns, NANOS)
    local nanos = ns - seconds * NANOS
    if seconds == 0 and nanos == 0 then
        return self
    end
    return of(self.s + seconds, self.n + nanos)
end

-- instant - duration, or the Duration between two instants (in floating point beyond 2^63 nanoseconds)
function __K2L_Instant:minus(other)
    if getmetatable(other) == __K2L_Instant then
        local seconds, nanos = self.s - other.s, self.n - other.n
        if seconds > 9000000000 or seconds < -9000000000 then
            return setmetatable({ns = seconds * 1e9 + nanos}, __K2L_Duration)
        end
        return setmetatable({ns = seconds * NANOS + nanos}, __K2L_Duration)
    end
    return self:plus(other:unaryMinus())
end

function __K2L_Instant:compareTo(other)
    local a, b = self.s, other.s
    if a == b then
        a, b = self.n, other.n
    end
    return a < b and -1 or (a > b and 1 or 0)
end

function __K2L_Instant.__lt(a, b)
    return a:compareTo(b) < 0
end

function __K2L_Instant.__le(a, b)
    return a:compareTo(b) <= 0
end

function __K2L_Instant:equals(other)
    return getmetatable(other) == __K2L_Instant and other.s == self.s and other.n == self.n
end

__K2L_Instant.__eq = __K2L_Instant.equals

-- epochSeconds.hashCode() + 51 * nanosecondsOfSecond
function __K2L_Instant:hashCode()
    local s = self.s
    local lo = s % 4294967296
    local hi = ((s - lo) / 4294967296) % 4294967296
    return __K2L_ToInt32(__K2L_ToInt32(__K2L_BXor(hi, lo)) + 51 * self.n)
end

function __K2L_Instant:isDistantPast()
    return self:compareTo(__K2L_Instant.DISTANT_PAST) <= 0
end

function __K2L_Instant:isDistantFuture()
    return self:compareTo(__K2L_Instant.DISTANT_FUTURE) >= 0
end

------------------------------------------------------------------ the proleptic Gregorian calendar

-- the year, month and day of a day number (days since 1970-01-01), after Howard Hinnant's civil_from_days
local function civil(days)
    local z = days + 719468
    local era = FloorDiv(z, 146097)
    local doe = z - era * 146097
    local yoe = FloorDiv(doe - FloorDiv(doe, 1460) + FloorDiv(doe, 36524) - FloorDiv(doe, 146096), 365)
    local doy = doe - (365 * yoe + FloorDiv(yoe, 4) - FloorDiv(yoe, 100))
    local mp = FloorDiv(5 * doy + 2, 153)
    local month = mp < 10 and mp + 3 or mp - 9
    local year = yoe + era * 400 + (month <= 2 and 1 or 0)
    return year, month, doy - FloorDiv(153 * mp + 2, 5) + 1
end

local function daysOf(year, month, day)
    if month <= 2 then
        year = year - 1
    end
    local era = FloorDiv(year, 400)
    local yoe = year - era * 400
    local mp = month > 2 and month - 3 or month + 9
    local doe = yoe * 365 + FloorDiv(yoe, 4) - FloorDiv(yoe, 100) + FloorDiv(153 * mp + 2, 5) + day - 1
    return era * 146097 + doe - 719468
end

local function isLeap(year)
    return year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)
end

local MONTH_DAYS = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}

local function monthLength(month, year)
    return month == 2 and isLeap(year) and 29 or MONTH_DAYS[month]
end

function __K2L_Instant:toString()
    local days = FloorDiv(self.s, 86400)
    local second = self.s - days * 86400
    local year, month, day = civil(days)
    local out = {}
    if year < 1000 and year > -1000 then
        out[1] = year < 0 and format("-%04d", -year) or format("%04d", year)
    else
        out[1] = (year >= 10000 and "+" or "") .. format("%d", year)
    end
    local hour = FloorDiv(second, 3600)
    out[2] = format("-%02d-%02dT%02d:%02d:%02d", month, day, hour, FloorDiv(second - hour * 3600, 60), second % 60)
    local n = self.n
    if n ~= 0 then
        if n % 1000000 == 0 then
            out[3] = format(".%03d", n / 1000000)
        elseif n % 1000 == 0 then
            out[3] = format(".%06d", n / 1000)
        else
            out[3] = format(".%09d", n)
        end
    end
    out[#out + 1] = "Z"
    return table.concat(out)
end

__K2L_Instant.__tostring = __K2L_Instant.toString

------------------------------------------------------------------ parsing

local function digitAt(s, i)
    local b = s:byte(i + 1)
    return b ~= nil and b >= 48 and b <= 57
end

local function twoDigits(s, i)
    return (s:byte(i + 1) - 48) * 10 + (s:byte(i + 2) - 48)
end

-- the stdlib's parser (positions are 0-based in its messages); nil and the message when `s` is malformed
local function parseIso(s)
    local function fail(message)
        local quoted = " when parsing an Instant from \"" .. (#s > 64 and s:sub(1, 64) .. "..." or s) .. "\""
        return nil, message .. quoted .. quoted
    end
    if s == "" then
        return nil, "An empty string is not a valid Instant when parsing an Instant from \"\""
    end
    local i, len = 0, #s
    local sign = s:sub(1, 1)
    if sign == "+" or sign == "-" then
        i = 1
    else
        sign = " "
    end
    local yearStart, year = i, 0
    while i < len and digitAt(s, i) do
        year = year * 10 + (s:byte(i + 1) - 48)
        i = i + 1
    end
    local digits = i - yearStart
    if digits > 10 then
        return fail("Expected at most 10 digits for the year number, got " .. digits .. " digits")
    elseif digits == 10 and s:byte(yearStart + 1) >= 50 then
        return fail("Expected at most 9 digits for the year number or year 1000000000, got " .. digits .. " digits")
    elseif digits < 4 then
        return fail("The year number must be padded to 4 digits, got " .. digits .. " digits")
    elseif sign == "+" and digits == 4 then
        return fail("The '+' sign at the start is only valid for year numbers longer than 4 digits")
    elseif sign == " " and digits ~= 4 then
        return fail("A '+' or '-' sign is required for year numbers longer than 4 digits")
    end
    if sign == "-" then
        year = -year
    end
    -- at least -MM-DDTHH:MM:SSZ
    if len < i + 16 then
        return fail("The input string is too short")
    end
    local function expect(what, at, ok)
        if not ok then
            return fail("Expected " .. what .. ", but got '" .. s:sub(at + 1, at + 1) .. "' at position " .. at)
        end
    end
    local function char(at)
        return s:sub(at + 1, at + 1)
    end
    local problem, message = nil, nil
    local checks = {
        {"'-'", 0, char(i) == "-"}, {"'-'", 3, char(i + 3) == "-"},
        {"'T' or 't'", 6, char(i + 6) == "T" or char(i + 6) == "t"}, {"':'", 9, char(i + 9) == ":"}, {"':'", 12, char(i + 12) == ":"},
    }
    for _, check in ipairs(checks) do
        problem, message = expect(check[1], i + check[2], check[3])
        if message then
            return problem, message
        end
    end
    for _, j in ipairs({1, 2, 4, 5, 7, 8, 10, 11, 13, 14}) do
        problem, message = expect("an ASCII digit", i + j, digitAt(s, i + j))
        if message then
            return problem, message
        end
    end
    local month, day, hour = twoDigits(s, i + 1), twoDigits(s, i + 4), twoDigits(s, i + 7)
    local minute, second = twoDigits(s, i + 10), twoDigits(s, i + 13)
    local nanos = 0
    if char(i + 15) == "." then
        local start = i + 16
        i = start
        while i < len and digitAt(s, i) do
            nanos = nanos * 10 + (s:byte(i + 1) - 48)
            i = i + 1
        end
        local count = i - start
        if count < 1 or count > 9 then
            return fail("1..9 digits are supported for the fraction of the second, got " .. count .. " digits")
        end
        for _ = count + 1, 9 do
            nanos = nanos * 10
        end
    else
        i = i + 15
    end
    local offset
    local at = char(i)
    if at == "" then
        return fail("The UTC offset at the end of the string is missing")
    elseif at == "z" or at == "Z" then
        if len ~= i + 1 then
            return fail("Extra text after the instant at position " .. (i + 1))
        end
        offset = 0
    elseif at == "-" or at == "+" then
        local size = len - i
        if size % 3 ~= 0 then
            return fail("Invalid UTC offset string '" .. s:sub(i + 1) .. "'")
        elseif size > 9 then
            return fail("The UTC offset string '" .. s:sub(i + 1) .. "' is too long")
        end
        for _, j in ipairs({3, 6}) do
            if i + j < len and char(i + j) ~= ":" then
                return fail("Expected ':' at index " .. (i + j) .. ", got '" .. char(i + j) .. "'")
            end
        end
        for _, j in ipairs({1, 2, 4, 5, 7, 8}) do
            if i + j < len and not digitAt(s, i + j) then
                return fail("Expected a digit at index " .. (i + j) .. ", got '" .. char(i + j) .. "'")
            end
        end
        local h = twoDigits(s, i + 1)
        local m = size > 3 and twoDigits(s, i + 4) or 0
        local sec = size > 6 and twoDigits(s, i + 7) or 0
        if m > 59 then
            return fail("Expected offset-minute-of-hour in 0..59, got " .. m)
        elseif sec > 59 then
            return fail("Expected offset-second-of-minute in 0..59, got " .. sec)
        elseif h > 17 and not (h == 18 and m == 0 and sec == 0) then
            return fail("Expected an offset in -18:00..+18:00, got " .. s:sub(i + 1))
        end
        offset = (h * 3600 + m * 60 + sec) * (at == "-" and -1 or 1)
    else
        return fail("Expected the UTC offset at position " .. i .. ", got '" .. at .. "'")
    end
    if month < 1 or month > 12 then
        return fail("Expected a month number in 1..12, got " .. month)
    elseif day < 1 or day > monthLength(month, year) then
        return fail("Expected a valid day-of-month for month " .. month .. " of year " .. year .. ", got " .. day)
    elseif hour > 23 then
        return fail("Expected hour in 0..23, got " .. hour)
    elseif minute > 59 then
        return fail("Expected minute-of-hour in 0..59, got " .. minute)
    elseif second > 59 then
        return fail("Expected second-of-minute in 0..59, got " .. second)
    end
    return of(daysOf(year, month, day) * 86400 + hour * 3600 + minute * 60 + second - offset, nanos)
end

function __K2L_Instant.parse(s, orNull)
    local instant, message = parseIso(s)
    if instant == nil and not orNull then
        error(__K2L_InstantFormatException.new(message))
    end
    return instant
end

------------------------------------------------------------------ clocks

-- TimeSource.asClock(origin): origin plus the time elapsed on the source since
function __K2L_Instant.asClock(source, origin)
    local start = source:markNow()
    return {now = function()
        return origin:plus(start:elapsedNow())
    end}
end

local System = {}
System.__index = System

function System.now(_)
    return make(os.time(), 0)
end

function System.toString(_)
    return "SystemClock"
end

local __K2L_SystemClock = setmetatable({}, System)
