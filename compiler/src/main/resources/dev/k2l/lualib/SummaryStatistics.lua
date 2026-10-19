-- requires: Class, Strings, Compare, LongArith
-- java.util.IntSummaryStatistics, LongSummaryStatistics and DoubleSummaryStatistics: count, sum (a Long for Int and Long values,
-- compensated for doubles), min, max and average, printed like the JDK's (`IntSummaryStatistics{count=3, sum=6, min=1,
-- average=2.000000, max=3}`). `summaryStatistics()` of a stream and the Collectors.summarizing* collectors fill one.
local __K2L_IntSummaryStatistics = __K2L_Class("java.util.IntSummaryStatistics")
local __K2L_LongSummaryStatistics = __K2L_Class("java.util.LongSummaryStatistics")
local __K2L_DoubleSummaryStatistics = __K2L_Class("java.util.DoubleSummaryStatistics")
local __K2L_SummaryStatistics = {}

do

local LongArith = __K2L_LongArith
local Int, Long, Double = __K2L_IntSummaryStatistics, __K2L_LongSummaryStatistics, __K2L_DoubleSummaryStatistics

local INT_MAX, INT_MIN = 2147483647, -2147483648

function Int:____init()
    self.____count, self.____sum, self.____min, self.____max = 0, 0, INT_MAX, INT_MIN
end

function Long:____init()
    self.____count, self.____sum, self.____min, self.____max = 0, 0, LongArith.MAX, LongArith.MIN
end

-- the sum of an IntSummaryStatistics is a Long, so it does not wrap at 32 bits
local function acceptWhole(self, value)
    self.____count = self.____count + 1
    self.____sum = LongArith.add(self.____sum, value)
    if __K2L_Compare(value, self.____min) < 0 then
        self.____min = value
    end
    if __K2L_Compare(value, self.____max) > 0 then
        self.____max = value
    end
end

Int.accept, Long.accept = acceptWhole, acceptWhole

local function combineWhole(self, other)
    self.____count = self.____count + other.____count
    self.____sum = LongArith.add(self.____sum, other.____sum)
    if __K2L_Compare(other.____min, self.____min) < 0 then
        self.____min = other.____min
    end
    if __K2L_Compare(other.____max, self.____max) > 0 then
        self.____max = other.____max
    end
end

Int.combine, Long.combine = combineWhole, combineWhole

function Double:____init()
    self.____count, self.____sum, self.____compensation, self.____simpleSum = 0, 0.0, 0.0, 0.0
    self.____min, self.____max = math.huge, -math.huge
end

-- Math.min / Math.max of doubles: NaN wins
local function minDouble(a, b)
    if a ~= a or b ~= b then
        return 0 / 0
    end
    return (a < b or (a == 0 and b == 0 and 1 / a < 0)) and a or b
end

local function maxDouble(a, b)
    if a ~= a or b ~= b then
        return 0 / 0
    end
    return (a > b or (a == 0 and b == 0 and 1 / a > 0)) and a or b
end

-- Kahan summation, as DoubleSummaryStatistics.sumWithCompensation
local function addCompensated(self, value)
    local tmp = value - self.____compensation
    local velvel = self.____sum + tmp
    self.____compensation = (velvel - self.____sum) - tmp
    self.____sum = velvel
end

function Double:accept(value)
    self.____count = self.____count + 1
    self.____simpleSum = self.____simpleSum + value
    addCompensated(self, value)
    self.____min, self.____max = minDouble(self.____min, value), maxDouble(self.____max, value)
end

function Double:combine(other)
    self.____count = self.____count + other.____count
    self.____simpleSum = self.____simpleSum + other.____simpleSum
    addCompensated(self, other.____sum)
    addCompensated(self, -other.____compensation)
    self.____min, self.____max = minDouble(self.____min, other.____min), maxDouble(self.____max, other.____max)
end

for _, class in ipairs({Int, Long, Double}) do
    function class:getCount() return self.____count end
    function class:getMin() return self.____min end
    function class:getMax() return self.____max end
end

Int.getSum, Long.getSum = function(self) return self.____sum end, function(self) return self.____sum end

function Double:getSum()
    local sum = self.____sum - self.____compensation
    if sum ~= sum and (self.____simpleSum == math.huge or self.____simpleSum == -math.huge) then
        return self.____simpleSum
    end
    return sum
end

local function wholeAverage(self)
    if self.____count == 0 then
        return 0.0
    end
    return LongArith.toDouble(self.____sum) / self.____count
end

Int.getAverage, Long.getAverage = wholeAverage, wholeAverage

function Double:getAverage()
    if self.____count == 0 then
        return 0.0
    end
    return self:getSum() / self.____count
end

function Int:toString()
    return __K2L_StringFormat("IntSummaryStatistics{count=%d, sum=%d, min=%d, average=%f, max=%d}",
        self.____count, self.____sum, self.____min, self:getAverage(), self.____max)
end

function Long:toString()
    return __K2L_StringFormat("LongSummaryStatistics{count=%d, sum=%d, min=%d, average=%f, max=%d}",
        self.____count, self.____sum, self.____min, self:getAverage(), self.____max)
end

function Double:toString()
    return __K2L_StringFormat("DoubleSummaryStatistics{count=%d, sum=%f, min=%f, average=%f, max=%f}",
        self.____count, self:getSum(), self.____min, self:getAverage(), self.____max)
end

for _, class in ipairs({Int, Long, Double}) do
    class.__tostring = class.toString
end

local CLASSES = {Int = Int, Long = Long, Double = Double}

-- stream.summaryStatistics(): `kind` is "Int", "Long" or "Double"
function __K2L_SummaryStatistics.of(kind, stream)
    local stats = CLASSES[kind].new()
    stream:forEach(function(v) stats:accept(v) end)
    return stats
end

-- Collectors.summarizingInt(mapper) and the like
function __K2L_SummaryStatistics.collector(kind, mapper)
    return {
        supplier = CLASSES[kind].new,
        accumulator = function(stats, v) stats:accept(mapper(v)) end,
    }
end

end
