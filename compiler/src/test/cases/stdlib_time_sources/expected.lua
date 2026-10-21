local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_Duration = ____lualib.__K2L_Duration
local __K2L_DurationUnit = ____lualib.__K2L_DurationUnit
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_MeasureTime = ____lualib.__K2L_MeasureTime
local __K2L_MeasureTimedValue = ____lualib.__K2L_MeasureTimedValue
local __K2L_Monotonic = ____lualib.__K2L_Monotonic
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_TestTimeSource = ____lualib.__K2L_TestTimeSource
local __K2L_TimedValue = ____lualib.__K2L_TimedValue

local function work(n)
    local acc = 0
    for i = 1, n do
        acc = acc + i * i
    end
    return acc
end

local Stopwatch = __K2L_Class("Stopwatch")

function Stopwatch:____init(source)
    self.source = source
    self.start = self.source:markNow()
end

function Stopwatch:reset()
    self.start = self.source:markNow()
end

function Stopwatch:elapsed()
    return self.start:elapsedNow()
end

local ____lambda_1 = function() return work(1000) end
local ____lambda_2 = function() return "done" end
local function main()
    local took = __K2L_MeasureTime(function()
        work(10000)
    end)
    print("measureTime non-negative: " .. tostring(not took:isNegative()) .. ", finite: " .. tostring(took:isFinite()))
    local ____destructured = __K2L_MeasureTimedValue(____lambda_1)
    local value, duration = ____destructured.value, ____destructured.duration
    print("measureTimedValue: " .. value .. ", non-negative: " .. tostring(__K2L_Compare(duration, __K2L_Duration.ZERO) >= 0))
    local timed = __K2L_MeasureTimedValue(____lambda_2)
    print("timed value: " .. timed.value .. ", below a minute: " .. tostring(__K2L_Compare(timed.duration, __K2L_Duration.ofWhole(60, __K2L_DurationUnit.SECONDS)) < 0))
    local mark = __K2L_Monotonic:markNow()
    work(1000)
    local elapsed = mark:elapsedNow()
    print("elapsed non-negative: " .. tostring(not elapsed:isNegative()) .. ", passed: " .. tostring(mark:hasPassedNow()) .. ", not passed: " .. tostring(mark:hasNotPassedNow()))
    local later = mark:plus(__K2L_Duration.ofWhole(1, __K2L_DurationUnit.SECONDS))
    print("future mark: passed " .. tostring(later:hasPassedNow()) .. ", not passed " .. tostring(later:hasNotPassedNow()))
    print("mark difference: " .. __K2L_Str(later:minus(mark)) .. ", order: " .. tostring(__K2L_Compare(mark, later) < 0) .. ", " .. tostring(__K2L_Compare(later, mark) > 0))
    local earlier = mark:minus(__K2L_Duration.ofWhole(2, __K2L_DurationUnit.SECONDS))
    print("earlier: " .. __K2L_Str(earlier:minus(mark)) .. ", " .. tostring(__K2L_Compare(earlier:elapsedNow(), __K2L_Duration.ofWhole(2, __K2L_DurationUnit.SECONDS)) >= 0))
    local source = __K2L_Monotonic
    print("source: " .. __K2L_Str(source))
    local m2 = source:markNow()
    print("generic mark elapsed non-negative: " .. tostring(not m2:elapsedNow():isNegative()))
    print("measured on a source: " .. tostring(not __K2L_MeasureTime(function()
        work(100)
    end, source):isNegative()))
    local test = __K2L_TestTimeSource.new()
    local start = test:markNow()
    test:plusAssign(__K2L_Duration.ofWhole(1500, __K2L_DurationUnit.MILLISECONDS))
    print("test elapsed: " .. __K2L_Str(start:elapsedNow()))
    local stopwatch = Stopwatch.new(test)
    test:plusAssign(__K2L_Duration.ofWhole(2, __K2L_DurationUnit.SECONDS))
    print("stopwatch: " .. __K2L_Str(stopwatch:elapsed()))
    stopwatch:reset()
    test:plusAssign(__K2L_Duration.ofWhole(250, __K2L_DurationUnit.MILLISECONDS))
    print("after reset: " .. __K2L_Str(stopwatch:elapsed()) .. ", total: " .. __K2L_Str(start:elapsedNow()))
    local deadline = test:markNow():plus(__K2L_Duration.ofWhole(1, __K2L_DurationUnit.SECONDS))
    print("deadline passed: " .. tostring(deadline:hasPassedNow()))
    test:plusAssign(__K2L_Duration.ofWhole(1, __K2L_DurationUnit.SECONDS))
    print("deadline passed: " .. tostring(deadline:hasPassedNow()) .. ", over by: " .. __K2L_Str(deadline:elapsedNow()))
    local t1 = test:markNow()
    test:plusAssign(__K2L_Duration.ofWhole(3, __K2L_DurationUnit.SECONDS))
    local t2 = test:markNow()
    print("t2 - t1 = " .. __K2L_Str(t2:minus(t1)) .. ", t1 < t2: " .. tostring(__K2L_Compare(t1, t2) < 0) .. ", compare: " .. tostring(__K2L_Compare(t2, t1) > 0))
    local measured = __K2L_MeasureTime(function()
        test:plusAssign(__K2L_Duration.ofWhole(42, __K2L_DurationUnit.MILLISECONDS))
    end, test)
    print("test measureTime: " .. __K2L_Str(measured))
    local tv = __K2L_MeasureTimedValue(function()
        test:plusAssign(__K2L_Duration.ofWhole(7, __K2L_DurationUnit.SECONDS))
        return "ok"
    end, test)
    print("test measureTimedValue: " .. __K2L_Str(tv) .. ", " .. tv.value .. ", " .. __K2L_Str(tv.duration))
    print("copy: " .. __K2L_Str(tv:copy("changed")) .. ", equal: " .. tostring(__K2L_Equals(tv, __K2L_TimedValue.new("ok", __K2L_Duration.ofWhole(7, __K2L_DurationUnit.SECONDS)))))
end

__K2L_Main(main)
return {work = work, Stopwatch = Stopwatch}
