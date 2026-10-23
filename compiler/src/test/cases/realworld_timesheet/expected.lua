local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClosedRangeMixin = ____lualib.__K2L_ClosedRangeMixin
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_IterableBase = ____lualib.__K2L_IterableBase
local __K2L_LazyObject = ____lualib.__K2L_LazyObject
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringEndsWith = ____lualib.__K2L_StringEndsWith
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_StringIsBlank = ____lualib.__K2L_StringIsBlank
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_Text = ____lualib.__K2L_Text

local DateRange, Weekday
local Date = __K2L_Class("Date")
Date.____comparable = true

function Date:____init(year, month, day)
    self.year = year
    self.month = month
    self.day = day
    local ____value = self.month
    if not (____value >= 1 and ____value <= 12) then
        error(__K2L_IllegalArgumentException.new("bad month " .. self.month))
    end
    local ____bound = Date:daysIn(self.year, self.month)
    local ____value_1 = self.day
    if not (____value_1 >= 1 and ____value_1 <= ____bound) then
        error(__K2L_IllegalArgumentException.new("bad day " .. self.year .. "-" .. self.month .. "-" .. self.day))
    end
end

function Date:getEpochDay()
    local y = self.month <= 2 and self.year - 1 or self.year
    local era = (y >= 0 and y or y - 399) // 400
    local yoe = y - era * 400
    local doy = (153 * (self.month + (self.month > 2 and -3 or 9)) + 2) // 5 + self.day - 1
    local doe = yoe * 365 + yoe // 4 - yoe // 100 + doy
    return era * 146097 + doe - 719468
end

function Date:getDayOfWeek()
    local ____values = Weekday.____values
    local ____index = (self:getEpochDay() + 3) % 7
    return ____values[____index + 1] or __K2L_IndexError(____index, #____values)
end

function Date:plus(days)
    return Date:ofEpochDay(self:getEpochDay() + days)
end

function Date:minus(other)
    return self:getEpochDay() - other:getEpochDay()
end

function Date:rangeTo(other)
    return DateRange.new(self, other)
end

function Date:compareTo(other)
    return __K2L_Compare(self:getEpochDay(), other:getEpochDay())
end

function Date:toString()
    return string.format("%04d-%02d-%02d", self.year, self.month, self.day)
end

__K2L_DataClass(Date, {"year", "month", "day"})
Date.____companion = true

function Date:isLeap(y)
    return y % 4 == 0 and (y % 100 ~= 0 or y % 400 == 0)
end

function Date:daysIn(y, m)
    if m == 2 then
        return self:isLeap(y) and 29 or 28
    elseif m == 4 or m == 6 or m == 9 or m == 11 then
        return 30
    else
        return 31
    end
end

function Date:ofEpochDay(n)
    local z = n + 719468
    local era = (z >= 0 and z or z - 146096) // 146097
    local doe = z - era * 146097
    local yoe = (doe - doe // 1460 + doe // 36524 - doe // 146096) // 365
    local doy = doe - (365 * yoe + yoe // 4 - yoe // 100)
    local mp = (5 * doy + 2) // 153
    local d = doy - (153 * mp + 2) // 5 + 1
    local m = mp < 10 and mp + 3 or mp - 9
    return Date.new(yoe + era * 400 + (m <= 2 and 1 or 0), m, d)
end

local ____lambda_1 = function(____p1) return __K2L_StringToInt(____p1) end
function Date:parse(s)
    local ____value_2 = __K2L_StringSplit(s, "-"):map(____lambda_1)
    local ____result
    do
        local y, m, d = ____value_2[1], ____value_2[2], ____value_2[3]
        ____result = Date.new(y, m, d)
    end
    return ____result
end

DateRange = __K2L_Class("DateRange", __K2L_IterableBase, __K2L_ClosedRangeMixin)

function DateRange:____init(start, endInclusive)
    self.start = start
    self.endInclusive = endInclusive
end

function DateRange:iterator()
    local ____this = self
    local ____object = __K2L_Class("DateRange$iterator$1")
    function ____object:____init()
        self.____next = ____this.start
    end
    function ____object:hasNext()
        return __K2L_Compare(self.____next, ____this.endInclusive) <= 0
    end
    function ____object:next()
        if not self:hasNext() then
            error(__K2L_NoSuchElementException.new())
        end
        local ____value_3 = self.____next
        self.____next = self.____next:plus(1)
        return ____value_3
    end
    ____object:____init()
    return ____object
end

DateRange.contains = __K2L_ClosedRangeMixin.contains
DateRange.isEmpty = __K2L_ClosedRangeMixin.isEmpty
Weekday = __K2L_Class("Weekday")

function Weekday:____init(name, ordinal, short)
    self.name = name
    self.ordinal = ordinal
    self.short = short
end

function Weekday:getIsWeekend()
    return self == Weekday.SATURDAY or self == Weekday.SUNDAY
end

function Weekday:toString()
    return self.name
end

function Weekday:compareTo(other)
    return self.ordinal - other.ordinal
end

Weekday.MONDAY = Weekday.new("MONDAY", 0, "Mon")
Weekday.TUESDAY = Weekday.new("TUESDAY", 1, "Tue")
Weekday.WEDNESDAY = Weekday.new("WEDNESDAY", 2, "Wed")
Weekday.THURSDAY = Weekday.new("THURSDAY", 3, "Thu")
Weekday.FRIDAY = Weekday.new("FRIDAY", 4, "Fri")
Weekday.SATURDAY = Weekday.new("SATURDAY", 5, "Sat")
Weekday.SUNDAY = Weekday.new("SUNDAY", 6, "Sun")
Weekday.____values = {Weekday.MONDAY, Weekday.TUESDAY, Weekday.WEDNESDAY, Weekday.THURSDAY, Weekday.FRIDAY, Weekday.SATURDAY, Weekday.SUNDAY}
local Minutes = __K2L_Class("Minutes")
Minutes.____comparable = true

function Minutes.new(total)
    return setmetatable({total = total}, Minutes)
end

function Minutes:plus(o)
    return Minutes.new(self.total + o.total)
end

function Minutes:minus(o)
    return Minutes.new(self.total - o.total)
end

function Minutes:compareTo(other)
    return __K2L_Compare(self.total, other.total)
end

function Minutes:getHours()
    return self.total / 60.0
end

function Minutes:toString()
    return __K2L_StringFormat(self.total // 60 .. "h%02d", self.total % 60)
end

__K2L_DataClass(Minutes, {"total"})
Minutes.____companion = true

local ____lambda_2 = function(it) return __K2L_StringToInt(it) end
function Minutes:parseClock(s)
    local ____destructured = __K2L_StringSplit(s, ":"):map(____lambda_2)
    local h, m = ____destructured[1], ____destructured[2]
    if not (h >= 0 and h <= 24 and (m >= 0 and m <= 59)) then
        error(__K2L_IllegalArgumentException.new("bad time " .. s))
    end
    return Minutes.new(h * 60 + m)
end

function Minutes:____initCompanion()
    self.ZERO = Minutes.new(0)
end

Minutes:____initCompanion()
local Shift = __K2L_Class("Shift")

function Shift.new(date, start, ____end, breakMinutes)
    if breakMinutes == nil then
        breakMinutes = 0
    end
    return setmetatable({date = date, start = start, ["end"] = ____end, breakMinutes = breakMinutes}, Shift)
end

function Shift:getWorked()
    return self["end"]:minus(self.start):minus(Minutes.new(self.breakMinutes))
end

__K2L_DataClass(Shift, {"date", "start", "end", "breakMinutes"})

local ____lambda_3 = function(it)
    return __K2L_StringIsBlank(it) or __K2L_StringStartsWith(it, "#")
end
local function parseShifts(text)
    return __K2L_StringLines(__K2L_Text.trimIndent(text)):filterNot(____lambda_3):map(function(line)
        local parts = __K2L_Regex.new("\\s+", "%s+"):split(__K2L_StringTrim(line))
        local ____arg = __K2L_StringSplit(parts:get(1), "-")
        local ____receiver = Minutes
        local ____destructured_1 = ____arg:map(function(...) return ____receiver:parseClock(...) end)
        local from, to = ____destructured_1[1], ____destructured_1[2]
        local ____receiver_1 = parts:getOrNull(2)
        local ____receiver_2 = ____receiver_1 and __K2L_Text.removeSuffix(____receiver_1, "m")
        local br = ____receiver_2 and __K2L_StringToInt(____receiver_2) or 0
        return Shift.new(Date:parse(parts:get(0)), from, to, br)
    end)
end

local Payroll = __K2L_Class("Payroll")
local brackets

function Payroll:____init()
    self.HOURLY_CENTS = 2850
    brackets = __K2L_MapOf(__K2L_Pair.new(0, 0.1), __K2L_Pair.new(100000, 0.15), __K2L_Pair.new(250000, 0.25), __K2L_Pair.new(600000, 0.32)):toSortedMap()
end

local ____lambda_4 = function(it) return (it.date:getEpochDay() + 3) // 7 end
local ____lambda_5 = function(it) return it.date end
function Payroll:pay(shifts)
    local regular = 0
    local overtime = 0
    local weekend = 0
    local ____collection = shifts:groupBy(____lambda_4):getValues()
    local ____items, ____n = ____collection:____array()
    for ____i_1 = 1, ____n do
        local week = ____items[____i_1]
        do
            local weekMinutes = 0
            local ____list = week:sortedBy(____lambda_5, true)
            for ____i = 1, ____list.size do
                local s = ____list[____i]
                local m = s:getWorked().total
                if s.date:getDayOfWeek():getIsWeekend() then
                    weekend = weekend + m
                elseif weekMinutes + m > 40 * 60 then
                    local reg = math.max(0, 40 * 60 - weekMinutes)
                    regular = regular + reg
                    overtime = overtime + (m - reg)
                else
                    regular = regular + m
                end
                weekMinutes = weekMinutes + m
            end
        end
    end
    local gross = (regular * 2850 + overtime * 2850 * 3 // 2 + weekend * 2850 * 2) // 60
    return __K2L_MapOf(__K2L_Pair.new("regularMin", regular), __K2L_Pair.new("overtimeMin", overtime), __K2L_Pair.new("weekendMin", weekend), __K2L_Pair.new("gross", gross), __K2L_Pair.new("tax", self:tax(gross)))
end

function Payroll:tax(____cents)
    local remaining = ____cents
    local tax = 0.0
    while remaining > 0 do
        local ____destructured_2 = brackets:getEntries():last(function(it) return it.key <= remaining end)
        local floor, rate = ____destructured_2.key, ____destructured_2.value
        tax = tax + (remaining - floor) * rate
        remaining = floor - 1
    end
    return math.floor(tax + 0.5)
end

__K2L_LazyObject(Payroll, "____init")

local function cents(c)
    return string.format("%d.%02d", c // 100, c % 100)
end

local SHIFTS = "\n    # date       time         break\n    2024-02-26  09:00-17:30  30m\n    2024-02-27  08:30-18:00  45m\n    2024-02-28  09:00-17:00\n    2024-02-29  07:00-19:30  60m\n    2024-03-01  09:00-16:00  30m\n    2024-03-02  10:00-14:00\n    2024-03-04  09:00-17:00  30m\n    2024-03-05  09:15-12:45\n"

local ____lambda_6 = function() return Date.new(2023, 2, 29) end
local ____lambda_7 = function() return Date:parse("2024-13-01") end
local ____lambda_8 = function(it)
    return it:getDayOfWeek().short .. " " .. it.day
end
local ____lambda_9 = function(it) return it:getDayOfWeek():getIsWeekend() end
local ____lambda_10 = function(it)
    return Date:ofEpochDay(it):getEpochDay() == it
end
local ____lambda_11 = function(it) return it:getDayOfWeek() == Weekday.MONDAY end
local ____lambda_12 = function(m)
    return Date.new(2024, m, 1):rangeTo(Date.new(2024, m, 7)):first(____lambda_11).day
end
local ____lambda_13 = function(it) return it:getWorked() end
local ____lambda_14 = function(self, ...) return self:plus(...) end
local ____lambda_15 = function(it) return it:getWorked() end
local ____lambda_16 = function(it) return it:getWorked() end
local ____lambda_17 = function(it) return it.date:getDayOfWeek() end
local ____lambda_18 = function(it) return it:getWorked().total end
local ____lambda_19 = function(it) return Minutes.new(it.value:sum()) end
local ____lambda_20 = function() return Minutes:parseClock("25:00") end
local ____lambda_21 = function(it) return it:getWorked() end
local function main()
    local leap = Date.new(2024, 2, 29)
    print(__K2L_Str(leap) .. " is a " .. __K2L_Str(leap:getDayOfWeek()) .. ", epoch day " .. leap:getEpochDay() .. ", +1 = " .. __K2L_Str(leap:plus(1)) .. ", +366 = " .. __K2L_Str(leap:plus(366)))
    print("1970-01-01 is " .. __K2L_Str(Date.new(1970, 1, 1):getDayOfWeek()) .. "; 2000-01-01 is " .. __K2L_Str(Date.new(2000, 1, 1):getDayOfWeek()) .. "; 1969-12-31 is " .. __K2L_Str(Date:ofEpochDay(-1)))
    print("days between: " .. Date.new(2024, 12, 25):minus(Date.new(2024, 1, 1)) .. " " .. Date:parse("2023-03-01"):minus(Date:parse("2023-02-01")))
    local ____arg_1 = __K2L_IntRange.new(1896, 1912)
    local ____receiver_3 = Date
    print("leap years 1896..1912: " .. __K2L_Str(____arg_1:filter(function(...) return ____receiver_3:isLeap(...) end)))
    local ____receiver_4 = __K2L_RunCatching(____lambda_6):exceptionOrNull()
    print(__K2L_Str(____receiver_4 and ____receiver_4.message))
    local ____receiver_5 = __K2L_RunCatching(____lambda_7):exceptionOrNull()
    print(__K2L_Str(____receiver_5 and ____receiver_5.message))
    local week = Date.new(2024, 3, 1):rangeTo(Date.new(2024, 3, 7))
    print("week: " .. __K2L_Str(week:map(____lambda_8)))
    print("weekend days in March 2024: " .. Date.new(2024, 3, 1):rangeTo(Date.new(2024, 3, 31)):count(____lambda_9))
    print("contains: " .. tostring(week:contains(Date.new(2024, 3, 4))) .. " " .. tostring(week:contains(Date.new(2024, 3, 8))) .. " empty: " .. tostring(__K2L_Compare(week.start, week.endInclusive) > 0))
    local roundTrip = __K2L_IntRange.new(-1000, 1000):withStep(37):all(____lambda_10)
    print("round trip ok: " .. tostring(roundTrip) .. ", first Mondays: " .. __K2L_Str(__K2L_IntRange.new(1, 6):map(____lambda_12)))
    local shifts = parseShifts(SHIFTS)
    print(shifts.size .. " shifts")
    for ____i_2 = 1, shifts.size do
        local s = shifts[____i_2]
        print("  " .. __K2L_Str(s.date) .. " " .. s.date:getDayOfWeek().short .. " " .. __K2L_Str(s.start) .. "-" .. __K2L_Str(s["end"]) .. " worked " .. __K2L_Str(s:getWorked()) .. " (" .. string.format("%.2f", s:getWorked():getHours()) .. "h)")
    end
    local total = shifts:map(____lambda_13):fold(Minutes.ZERO, ____lambda_14)
    print("total " .. __K2L_Str(total) .. ", longest " .. __K2L_Str(shifts:maxBy(____lambda_15).date) .. ", shortest " .. __K2L_Str(shifts:minOf(____lambda_16)))
    local byWeekday = shifts:groupBy(____lambda_17, ____lambda_18):toSortedMap():mapValues(____lambda_19)
    print("by weekday: " .. __K2L_Str(byWeekday))
    local pay = Payroll:pay(shifts)
    print("pay: " .. __K2L_Str(pay:mapValues(function(____destructured_3)
        local k, v = ____destructured_3.key, ____destructured_3.value
        return __K2L_StringEndsWith(k, "Min") and Minutes.new(v):toString() or cents(v)
    end)))
    print("net: " .. cents(pay:getValue("gross") - pay:getValue("tax")))
    local ____list_1 = __K2L_ListOf(5000, 100000, 300000, 1000000)
    for ____i_3 = 1, ____list_1.size do
        local g = ____list_1[____i_3]
        print("  tax on " .. __K2L_StringPadStart(cents(g), 9) .. ": " .. __K2L_StringPadStart(cents(Payroll:tax(g)), 8))
    end
    print(__K2L_Str(__K2L_RunCatching(____lambda_20):exceptionOrNull()))
    print("rate " .. 2850 .. " cents/h, sorted durations " .. __K2L_Str(shifts:map(____lambda_21):sorted():take(3)))
end

__K2L_RunMain(main)
return {Date = Date, DateRange = DateRange, Weekday = Weekday, Minutes = Minutes, Shift = Shift, parseShifts = parseShifts, Payroll = Payroll, cents = cents, SHIFTS = SHIFTS}
