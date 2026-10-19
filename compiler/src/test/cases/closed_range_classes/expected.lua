local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClosedRange = ____lualib.__K2L_ClosedRange
local __K2L_ClosedRangeMixin = ____lualib.__K2L_ClosedRangeMixin
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_DoubleToString = ____lualib.__K2L_DoubleToString
local __K2L_GenerateSequence = ____lualib.__K2L_GenerateSequence
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_IterableBase = ____lualib.__K2L_IterableBase
local __K2L_RangeEnd = ____lualib.__K2L_RangeEnd
local __K2L_RangeStart = ____lualib.__K2L_RangeStart
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str

local Week
local Day = __K2L_Class("Day")
Day.____comparable = true

function Day:____init(n)
    self.n = n
end

function Day:compareTo(other)
    return __K2L_Compare(self.n, other.n)
end

function Day:rangeTo(other)
    return Week.new(self, other)
end

function Day:toString()
    return "Day(n=" .. self.n .. ")"
end

function Day:hashCode()
    return __K2L_Hash(self.n)
end

function Day:equals(other)
    return getmetatable(other) == Day and self.n == other.n
end

local Span = __K2L_Class("Span", nil, __K2L_ClosedRangeMixin)

function Span:____init(start, endInclusive)
    self.start = start
    self.endInclusive = endInclusive
end

function Span:toString()
    return "Span(" .. __K2L_Str(self.start) .. ", " .. __K2L_Str(self.endInclusive) .. ")"
end

Week = __K2L_Class("Week", __K2L_IterableBase, __K2L_ClosedRangeMixin)
Week.____readOnly = true

function Week:____init(start, endInclusive)
    self.start = start
    self.endInclusive = endInclusive
end

function Week:iterator()
    return __K2L_GenerateSequence(self.start, function(it) return Day.new(it.n + 2) end):takeWhile(function(it)
        return __K2L_Compare(it, self.endInclusive) <= 0
    end):iterator()
end

Week.contains = __K2L_ClosedRangeMixin.contains
Week.isEmpty = __K2L_ClosedRangeMixin.isEmpty
local Grades = __K2L_Class("Grades", nil, __K2L_ClosedRangeMixin)

function Grades:____init(lo, hi)
    self.start = lo
    self.endInclusive = hi
end

function Grades:contains(value)
    local ____value = value:upper()
    return ____value >= self.start and ____value <= self.endInclusive
end

local function describe(r)
    return __K2L_Str(__K2L_RangeStart(r)) .. ".." .. __K2L_Str(__K2L_RangeEnd(r)) .. " empty=" .. tostring(r:isEmpty())
end

local function main()
    local span = Span.new(1.5, 4.25)
    print(tostring(span:contains(2.0)) .. " " .. tostring(span:contains(4.5)) .. " " .. tostring(span:isEmpty()) .. " " .. tostring(Span.new(3.0, 1.0):isEmpty()))
    local week = Day.new(1):rangeTo(Day.new(6))
    print(__K2L_Str(week:map(function(it) return it.n end)) .. " " .. tostring(week:contains(Day.new(2))) .. " " .. tostring(week:contains(Day.new(7))) .. " " .. tostring(week:isEmpty()))
    local grades = Grades.new("A", "C")
    print(tostring(grades:contains("b")) .. " " .. tostring(grades:contains("d")) .. " " .. tostring(grades:isEmpty()))
    print(describe(span))
    print(describe(week))
    print(describe(grades))
    print(describe(__K2L_ClosedRange.new(0.5, 2.5, __K2L_DoubleToString)))
    print(describe(__K2L_IntRange.new(3, 1)))
    print(describe(__K2L_ClosedRange.new("a", "f")))
    local ranges = __K2L_ReadOnlyListOf(span, __K2L_ClosedRange.new(0.25, 1.5, __K2L_DoubleToString))
    print(__K2L_Str(ranges:map(function(it)
        return __K2L_RangeEnd(it) - __K2L_RangeStart(it)
    end)))
end

main()
return {Day = Day, Span = Span, Week = Week, Grades = Grades, describe = describe}
