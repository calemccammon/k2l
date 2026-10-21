-- requires: Class, Collections, Exceptions, Compare, Equals, Str, ToInt32, DoubleToString, LongArith, Hash, Bit
-- java.util.stream: Stream, IntStream, LongStream and DoubleStream, Optional, OptionalInt, OptionalLong and OptionalDouble,
-- and Collectors. Long values are added with __K2L_LongArith, so they are exact with --long64 emulate.
-- A stream is lazy like the JDK's: `____next()` returns `true, element` or `false`, and each stage pulls from the one
-- before it, so side effects in lambdas happen in the JDK's order (element by element, `sorted` waits for all), and
-- `limit`, `findFirst` and `anyMatch` stop early. `____size` is the exact element count while the JDK also knows it
-- (a SIZED stream), which `count()` returns without running the stages, as the JDK 9+ does.
local __K2L_Stream = __K2L_Class("java.util.stream.Stream")
local __K2L_IntStream = __K2L_Class("java.util.stream.IntStream", __K2L_Stream)
local __K2L_DoubleStream = __K2L_Class("java.util.stream.DoubleStream", __K2L_Stream)
local __K2L_LongStream = __K2L_Class("java.util.stream.LongStream", __K2L_Stream)
local __K2L_Optional = __K2L_Class("java.util.Optional")
local __K2L_OptionalInt = __K2L_Class("java.util.OptionalInt")
local __K2L_OptionalLong = __K2L_Class("java.util.OptionalLong")
local __K2L_OptionalDouble = __K2L_Class("java.util.OptionalDouble")
local __K2L_Collectors = {}
local __K2L_Streams = {}

do

local Stream, IntStream, DoubleStream, LongStream = __K2L_Stream, __K2L_IntStream, __K2L_DoubleStream, __K2L_LongStream
local Optional, OptionalInt, OptionalDouble, OptionalLong = __K2L_Optional, __K2L_OptionalInt, __K2L_OptionalDouble, __K2L_OptionalLong
local Collectors, Streams = __K2L_Collectors, __K2L_Streams
local LongArith = __K2L_LongArith
local floor, min, max = math.floor, math.min, math.max

Stream.____optional, IntStream.____optional, DoubleStream.____optional = Optional, OptionalInt, OptionalDouble
LongStream.____optional = OptionalLong

local function noSuchElement(message)
    error(__K2L_NoSuchElementException.new(message))
end

-- a stream is consumed by the first operation on it
local function use(stream)
    if stream.____used then
        error(__K2L_IllegalStateException.new("stream has already been operated upon or closed"))
    end
    stream.____used = true
    return stream.____next
end

local function make(class, nextElement, size)
    return setmetatable({____next = nextElement, ____size = size}, class)
end

local function listOf(items, count)
    items.size = count
    return setmetatable(items, __K2L_List)
end

-- the elements of an array as the JDK's late-binding spliterators see them: [from, to) of a 1-based list
local function ofRange(class, source, from, to)
    local items, count, i
    return make(class, function()
        if items == nil then
            items, count = source:____array()
            i = from
            if to ~= nil and to < count then
                count = to
            end
        end
        if i < count then
            i = i + 1
            return true, items[i]
        end
        return false
    end, to ~= nil and to - from or nil)
end

---------------------------------------------------------------- sources
-- collection.stream(), and parallelStream(), which runs sequentially too
function Streams.ofCollection(collection, parallel)
    local stream = ofRange(Stream, collection, 0, nil)
    stream.____size = collection.size
    stream.____parallel = parallel
    return stream
end

-- Arrays.stream(array[, from, to])
function Streams.ofArray(class, array, from, to)
    from = from or 0
    to = to or array.size
    if from > to then
        error(__K2L_IndexOutOfBoundsException.new("origin(" .. from .. ") > fence(" .. to .. ")"))
    elseif from < 0 or to > array.size then
        error(__K2L_IndexOutOfBoundsException.new("Array index out of range: " .. (from < 0 and from or to)))
    end
    return ofRange(class, array, from, to)
end

-- Stream.of(...) and IntStream.of(...): the elements as one list
function Streams.of(class, items)
    return ofRange(class, items, 0, items.size)
end

function Streams.empty(class)
    return make(class, function() return false end, 0)
end

function Streams.range(first, last)
    local i = first - 1
    return make(IntStream, function()
        if i < last - 1 then
            i = i + 1
            return true, i
        end
        return false
    end, max(0, last - first))
end

function Streams.rangeClosed(first, last)
    return Streams.range(first, last + 1)
end

-- LongStream.range and rangeClosed: Long bounds, counted with __K2L_LongArith (rangeClosed up to Long.MAX_VALUE stops there)
function Streams.rangeLong(first, last, closed)
    local nextValue, done = first, false
    local size
    if type(first) == "number" and type(last) == "number" then
        size = max(0, last - first + (closed and 1 or 0))
    end
    return make(LongStream, function()
        local v = nextValue
        if done or not (LongArith.lt(v, last) or (closed and not LongArith.lt(last, v))) then
            done = true
            return false
        end
        if LongArith.lt(v, last) then
            nextValue = LongArith.add(v, 1)
        else
            done = true
        end
        return true, v
    end, size)
end

-- iterate(seed, next) is infinite, iterate(seed, hasNext, next) ends when hasNext fails
function Streams.iterate(class, seed, a, b)
    local started, current = false, nil
    local hasNext, step = nil, a
    if b ~= nil then
        hasNext, step = a, b
    end
    return make(class, function()
        if not started then
            started, current = true, seed
        else
            current = step(current)
        end
        if hasNext ~= nil and not hasNext(current) then
            started, step = true, nil
            return false
        end
        return true, current
    end)
end

function Streams.generate(class, supplier)
    return make(class, function() return true, supplier() end)
end

function Streams.concat(class, first, second)
    local a, b = use(first), use(second)
    local firstDone = false
    local size
    if first.____size ~= nil and second.____size ~= nil then
        size = first.____size + second.____size
    end
    return make(class, function()
        if not firstDone then
            local ok, v = a()
            if ok then
                return true, v
            end
            firstDone = true
        end
        return b()
    end, size)
end

---------------------------------------------------------------- intermediate operations
local function classOf(stream)
    return getmetatable(stream)
end

function Stream:filter(predicate)
    local nextElement = use(self)
    return make(classOf(self), function()
        while true do
            local ok, v = nextElement()
            if not ok then
                return false
            end
            if predicate(v) then
                return true, v
            end
        end
    end)
end

local function mapped(self, class, transform)
    local nextElement = use(self)
    return make(class, function()
        local ok, v = nextElement()
        if not ok then
            return false
        end
        return true, transform(v)
    end, self.____size)
end

function Stream:map(transform) return mapped(self, classOf(self), transform) end
function Stream:mapToObj(transform) return mapped(self, Stream, transform) end
function Stream:mapToInt(transform) return mapped(self, IntStream, transform) end
function Stream:mapToDouble(transform) return mapped(self, DoubleStream, transform) end
function Stream:mapToLong(transform) return mapped(self, LongStream, transform) end
function Stream:boxed() return mapped(self, Stream, function(v) return v end) end
function Stream:asDoubleStream() return mapped(self, DoubleStream, function(v) return v + 0.0 end) end
function Stream:asLongStream() return mapped(self, LongStream, function(v) return v end) end
function LongStream:asDoubleStream() return mapped(self, DoubleStream, LongArith.toDouble) end

function Stream:peek(action)
    return mapped(self, classOf(self), function(v)
        action(v)
        return v
    end)
end

local function flatMapped(self, class, transform)
    local nextElement = use(self)
    local inner
    return make(class, function()
        while true do
            if inner ~= nil then
                local ok, v = inner()
                if ok then
                    return true, v
                end
                inner = nil
            end
            local ok, v = nextElement()
            if not ok then
                return false
            end
            local stream = transform(v)
            if stream ~= nil then
                inner = use(stream)
            end
        end
    end)
end

function Stream:flatMap(transform) return flatMapped(self, classOf(self), transform) end
function Stream:flatMapToInt(transform) return flatMapped(self, IntStream, transform) end
function Stream:flatMapToLong(transform) return flatMapped(self, LongStream, transform) end
function Stream:flatMapToDouble(transform) return flatMapped(self, DoubleStream, transform) end

function Stream:distinct()
    local nextElement = use(self)
    local seen = __K2L_HashSet.new()
    return make(classOf(self), function()
        while true do
            local ok, v = nextElement()
            if not ok then
                return false
            end
            if seen:add(v) then
                return true, v
            end
        end
    end)
end

-- a barrier: the first pull drains the stages before it, like the JDK's sorted
function Stream:sorted(comparator)
    local nextElement = use(self)
    local sorted, i
    return make(classOf(self), function()
        if sorted == nil then
            local items, count = {}, 0
            while true do
                local ok, v = nextElement()
                if not ok then
                    break
                end
                count = count + 1
                items[count] = v
            end
            local list = listOf(items, count)
            sorted, i = comparator and list:sortedWith(comparator) or list:sorted(), 0
        end
        if i < sorted.size then
            i = i + 1
            return true, sorted[i]
        end
        return false
    end, self.____size)
end

function Stream:limit(count)
    if count < 0 then
        error(__K2L_IllegalArgumentException.new(tostring(count)))
    end
    local nextElement, taken = use(self), 0
    return make(classOf(self), function()
        if taken >= count then
            return false
        end
        local ok, v = nextElement()
        if not ok then
            taken = count
            return false
        end
        taken = taken + 1
        return true, v
    end, self.____size and min(self.____size, count))
end

function Stream:skip(count)
    if count < 0 then
        error(__K2L_IllegalArgumentException.new(tostring(count)))
    end
    local nextElement, skipped = use(self), false
    return make(classOf(self), function()
        if not skipped then
            skipped = true
            for _ = 1, count do
                if not nextElement() then
                    return false
                end
            end
        end
        return nextElement()
    end, self.____size and max(0, self.____size - count))
end

function Stream:takeWhile(predicate)
    local nextElement, done = use(self), false
    return make(classOf(self), function()
        if done then
            return false
        end
        local ok, v = nextElement()
        if ok and predicate(v) then
            return true, v
        end
        done = true
        return false
    end)
end

function Stream:dropWhile(predicate)
    local nextElement, dropping = use(self), true
    return make(classOf(self), function()
        while true do
            local ok, v = nextElement()
            if not ok then
                return false
            end
            if not dropping or not predicate(v) then
                dropping = false
                return true, v
            end
        end
    end)
end

-- parallel() and parallelStream() run sequentially; isParallel() still tells which was asked for
function Stream:parallel()
    self.____parallel = true
    return self
end

function Stream:sequential()
    self.____parallel = false
    return self
end

function Stream:isParallel()
    return self.____parallel == true
end

function Stream:unordered() return self end
Stream.onClose = Stream.unordered
function Stream:close() end

-- iterator(): pulls the elements one by one as hasNext() asks for them, like the JDK's adapter
local StreamIterator = __K2L_Class("java.util.Spliterators$1Adapter")

function Stream:iterator()
    return setmetatable({____next = use(self)}, StreamIterator)
end

function StreamIterator:hasNext()
    if self.____ready == nil then
        local ok, v = self.____next()
        self.____ready, self.____value = ok, v
    end
    return self.____ready
end

function StreamIterator:next()
    if not self:hasNext() then
        noSuchElement()
    end
    self.____ready = nil
    return self.____value
end

StreamIterator.nextInt, StreamIterator.nextLong, StreamIterator.nextDouble = StreamIterator.next, StreamIterator.next, StreamIterator.next

---------------------------------------------------------------- terminal operations
local function pull(nextElement, action)
    while true do
        local ok, v = nextElement()
        if not ok then
            return
        end
        action(v)
    end
end

local function drain(self, action)
    pull(use(self), action)
end

function Stream:forEach(action) drain(self, action) end
Stream.forEachOrdered = Stream.forEach

function Stream:count()
    if self.____size ~= nil then
        use(self)
        return self.____size
    end
    local n = 0
    drain(self, function() n = n + 1 end)
    return n
end

local function toItems(self)
    local items, count = {}, 0
    drain(self, function(v)
        count = count + 1
        items[count] = v
    end)
    return items, count
end

function Stream:toList()
    return listOf(toItems(self))
end

-- toArray() and toArray(generator)
function Stream:toArray()
    local items, count = toItems(self)
    items.size = count
    return setmetatable(items, __K2L_Array)
end

-- an IntStream's toArray() is an IntArray, and so on
for stream, binary in pairs({[IntStream] = "[I", [DoubleStream] = "[D", [LongStream] = "[J"}) do
    stream.toArray = function(self)
        return setmetatable(Stream.toArray(self), __K2L_ArrayClassOf(binary))
    end
end

function Stream:anyMatch(predicate)
    local nextElement = use(self)
    while true do
        local ok, v = nextElement()
        if not ok then
            return false
        elseif predicate(v) then
            return true
        end
    end
end

function Stream:allMatch(predicate)
    local nextElement = use(self)
    while true do
        local ok, v = nextElement()
        if not ok then
            return true
        elseif not predicate(v) then
            return false
        end
    end
end

function Stream:noneMatch(predicate)
    return not self:anyMatch(predicate)
end

function Stream:findFirst()
    local ok, v = use(self)()
    if not ok then
        return self.____optional.empty()
    end
    return self.____optional.of(v)
end

Stream.findAny = Stream.findFirst

-- reduce(op), reduce(identity, op) and reduce(identity, accumulator, combiner)
function Stream:reduce(...)
    local count = select("#", ...)
    local nextElement = use(self)
    if count == 1 then
        local op = ...
        local ok, result = nextElement()
        if not ok then
            return self.____optional.empty()
        end
        pull(nextElement, function(v) result = op(result, v) end)
        return self.____optional.of(result)
    end
    local result, op = ...
    pull(nextElement, function(v) result = op(result, v) end)
    return result
end

local function extreme(self, comparator, sign)
    local nextElement = use(self)
    local ok, best = nextElement()
    if not ok then
        return self.____optional.empty()
    end
    pull(nextElement, function(v)
        if comparator(best, v) * sign < 0 then
            best = v
        end
    end)
    return self.____optional.of(best)
end

function Stream:min(comparator) return extreme(self, comparator, -1) end
function Stream:max(comparator) return extreme(self, comparator, 1) end

-- collect(collector) and collect(supplier, accumulator, combiner)
function Stream:collect(collector, accumulator)
    if accumulator ~= nil then
        local result = collector()
        drain(self, function(v) accumulator(result, v) end)
        return result
    end
    local container = collector.supplier()
    local accumulate = collector.accumulator
    drain(self, function(v) accumulate(container, v) end)
    if collector.finisher ~= nil then
        return collector.finisher(container)
    end
    return container
end

---------------------------------------------------------------- IntStream and DoubleStream
-- Math.min / Math.max of two doubles: NaN wins, and -0.0 is below 0.0
local function minDouble(a, b)
    if a ~= a or b ~= b then
        return 0 / 0
    elseif a == 0 and b == 0 then
        return 1 / a < 0 and a or b
    end
    return a < b and a or b
end

local function maxDouble(a, b)
    if a ~= a or b ~= b then
        return 0 / 0
    elseif a == 0 and b == 0 then
        return 1 / a > 0 and a or b
    end
    return a > b and a or b
end

local function reduceWith(self, op)
    local nextElement = use(self)
    local ok, result = nextElement()
    if not ok then
        return self.____optional.empty()
    end
    pull(nextElement, function(v) result = op(result, v) end)
    return self.____optional.of(result)
end

function IntStream:min() return reduceWith(self, min) end
function IntStream:max() return reduceWith(self, max) end
function DoubleStream:min() return reduceWith(self, minDouble) end
function DoubleStream:max() return reduceWith(self, maxDouble) end

function IntStream:sum()
    local total = 0
    drain(self, function(v) total = total + v end)
    return __K2L_ToInt32(total)
end

function IntStream:average()
    local total, count = 0, 0
    drain(self, function(v)
        total = total + v
        count = count + 1
    end)
    if count == 0 then
        return OptionalDouble.empty()
    end
    return OptionalDouble.of(total / count)
end

-- Kahan summation as in Collectors.sumWithCompensation; returns the sum, and the count when asked
local function compensatedSum(self)
    local sum, compensation, simple, count = 0.0, 0.0, 0.0, 0
    drain(self, function(v)
        local tmp = v - compensation
        local velvel = sum + tmp
        compensation = (velvel - sum) - tmp
        sum = velvel
        simple = simple + v
        count = count + 1
    end)
    local result = sum - compensation
    if result ~= result and (simple == math.huge or simple == -math.huge) then
        result = simple
    end
    return result, count
end

function DoubleStream:sum()
    return (compensatedSum(self))
end

-- LongStream: a wrapping Long sum, and its average as the JDK computes it (the Long sum, then divided)
local function longSum(self)
    local total, count = 0, 0
    drain(self, function(v)
        total = LongArith.add(total, v)
        count = count + 1
    end)
    return total, count
end

function LongStream:sum()
    return (longSum(self))
end

function LongStream:average()
    local total, count = longSum(self)
    if count == 0 then
        return OptionalDouble.empty()
    end
    return OptionalDouble.of(LongArith.toDouble(total) / count)
end

function LongStream:min() return reduceWith(self, function(a, b) return __K2L_Compare(a, b) <= 0 and a or b end) end
function LongStream:max() return reduceWith(self, function(a, b) return __K2L_Compare(a, b) >= 0 and a or b end) end

function DoubleStream:average()
    local sum, count = compensatedSum(self)
    if count == 0 then
        return OptionalDouble.empty()
    end
    return OptionalDouble.of(sum / count)
end

function DoubleStream:map(transform)
    return mapped(self, DoubleStream, function(v) return transform(v) + 0.0 end)
end

---------------------------------------------------------------- Optional, OptionalInt, OptionalDouble
-- `hash` is the hashCode() of a value, `stream` the stream class of stream()
local function defineOptional(class, name, valueMethod, format, hash, stream)
    local EMPTY = setmetatable({____present = false}, class)

    function class.empty() return EMPTY end

    function class.of(value)
        if value == nil then
            error(__K2L_NullPointerException.new())
        end
        return setmetatable({____present = true, ____value = value}, class)
    end

    function class:isPresent() return self.____present end
    function class:isEmpty() return not self.____present end

    class[valueMethod] = function(self)
        if not self.____present then
            noSuchElement("No value present")
        end
        return self.____value
    end

    function class:orElse(other)
        if self.____present then
            return self.____value
        end
        return other
    end

    function class:orElseGet(supplier)
        if self.____present then
            return self.____value
        end
        return supplier()
    end

    function class:orElseThrow(supplier)
        if self.____present then
            return self.____value
        elseif supplier ~= nil then
            error(supplier())
        end
        noSuchElement("No value present")
    end

    function class:ifPresent(action)
        if self.____present then
            action(self.____value)
        end
    end

    function class:ifPresentOrElse(action, otherwise)
        if self.____present then
            action(self.____value)
        else
            otherwise()
        end
    end

    function class:toString()
        if not self.____present then
            return name .. ".empty"
        end
        return name .. "[" .. format(self.____value) .. "]"
    end

    class.__tostring = class.toString

    function class:equals(other)
        return getmetatable(other) == class and self.____present == other.____present and
            (not self.____present or __K2L_Equals(self.____value, other.____value))
    end

    function class:hashCode()
        return self.____present and hash(self.____value) or 0
    end

    function class:stream()
        if not self.____present then
            return Streams.empty(stream)
        end
        return Streams.of(stream, __K2L_ListOf(self.____value))
    end
end

-- Long.hashCode: the halves xor-ed
local function longHash(value)
    local hi, lo = LongArith.halves(value)
    local h = __K2L_BXor(hi, lo) % 4294967296
    return h >= 2147483648 and h - 4294967296 or h
end

defineOptional(Optional, "Optional", "get", __K2L_Str, __K2L_Hash, Stream)
defineOptional(OptionalInt, "OptionalInt", "getAsInt", tostring, function(value) return value end, IntStream)
defineOptional(OptionalDouble, "OptionalDouble", "getAsDouble", __K2L_DoubleToString, __K2L_DoubleHash, DoubleStream)
defineOptional(OptionalLong, "OptionalLong", "getAsLong", __K2L_Str, longHash, LongStream)

-- or(supplier): this when a value is present, else the supplier's Optional
function Optional:Or(supplier)
    if self.____present then
        return self
    end
    local other = supplier()
    if other == nil then
        error(__K2L_NullPointerException.new())
    end
    return other
end

function Optional.ofNullable(value)
    if value == nil then
        return Optional.empty()
    end
    return Optional.of(value)
end

function Optional:map(transform)
    if not self.____present then
        return self
    end
    return Optional.ofNullable(transform(self.____value))
end

function Optional:flatMap(transform)
    if not self.____present then
        return self
    end
    return transform(self.____value)
end

function Optional:filter(predicate)
    if self.____present and not predicate(self.____value) then
        return Optional.empty()
    end
    return self
end

---------------------------------------------------------------- Collectors
local function collector(supplier, accumulator, finisher)
    return {supplier = supplier, accumulator = accumulator, finisher = finisher}
end

function Collectors.toList()
    return collector(__K2L_List.new, function(list, v) list:add(v) end)
end

function Collectors.toSet()
    return collector(__K2L_HashSet.new, function(set, v) set:add(v) end)
end

function Collectors.toCollection(supplier)
    return collector(supplier, function(collection, v) collection:add(v) end)
end

-- joining(), joining(delimiter) and joining(delimiter, prefix, suffix)
function Collectors.joining(delimiter, prefix, suffix)
    return collector(function() return {} end, function(parts, v)
        parts[#parts + 1] = __K2L_Str(v)
    end, function(parts)
        return (prefix or "") .. table.concat(parts, delimiter or "") .. (suffix or "")
    end)
end

function Collectors.counting()
    return collector(function() return {0} end, function(box) box[1] = box[1] + 1 end, function(box) return box[1] end)
end

function Collectors.summingInt(transform)
    return collector(function() return {0} end, function(box, v)
        box[1] = box[1] + transform(v)
    end, function(box) return __K2L_ToInt32(box[1]) end)
end

local function averaging(transform)
    return collector(function() return {0, 0} end, function(box, v)
        box[1] = box[1] + transform(v)
        box[2] = box[2] + 1
    end, function(box)
        if box[2] == 0 then
            return 0.0
        end
        return box[1] / box[2]
    end)
end

function Collectors.averagingInt(transform) return averaging(transform) end

function Collectors.summingLong(transform)
    return collector(function() return {0} end, function(box, v)
        box[1] = LongArith.add(box[1], transform(v))
    end, function(box) return box[1] end)
end

function Collectors.averagingLong(transform)
    return collector(function() return {0, 0} end, function(box, v)
        box[1] = LongArith.add(box[1], transform(v))
        box[2] = box[2] + 1
    end, function(box)
        if box[2] == 0 then
            return 0.0
        end
        return LongArith.toDouble(box[1]) / box[2]
    end)
end

-- the JDK sums doubles with compensation (see compensatedSum)
local function compensated(transform, divide)
    return collector(function() return {0.0, 0.0, 0.0, 0} end, function(box, v)
        local x = transform(v)
        local tmp = x - box[2]
        local velvel = box[1] + tmp
        box[2] = (velvel - box[1]) - tmp
        box[1] = velvel
        box[3] = box[3] + x
        box[4] = box[4] + 1
    end, function(box)
        local result = box[1] - box[2]
        if result ~= result and (box[3] == math.huge or box[3] == -math.huge) then
            result = box[3]
        end
        if divide then
            return box[4] == 0 and 0.0 or result / box[4]
        end
        return result
    end)
end

function Collectors.summingDouble(transform) return compensated(transform, false) end
function Collectors.averagingDouble(transform) return compensated(transform, true) end

function Collectors.mapping(transform, downstream)
    return collector(downstream.supplier, function(container, v)
        downstream.accumulator(container, transform(v))
    end, downstream.finisher)
end

function Collectors.collectingAndThen(downstream, finisher)
    return collector(downstream.supplier, downstream.accumulator, function(container)
        if downstream.finisher ~= nil then
            container = downstream.finisher(container)
        end
        return finisher(container)
    end)
end

function Collectors.minBy(comparator)
    return collector(function() return {} end, function(box, v)
        if not box.present or comparator(box.value, v) > 0 then
            box.present, box.value = true, v
        end
    end, function(box) return box.present and Optional.of(box.value) or Optional.empty() end)
end

function Collectors.maxBy(comparator)
    return collector(function() return {} end, function(box, v)
        if not box.present or comparator(box.value, v) < 0 then
            box.present, box.value = true, v
        end
    end, function(box) return box.present and Optional.of(box.value) or Optional.empty() end)
end

-- groupingBy(classifier) and groupingBy(classifier, downstream): a HashMap of the downstream results
function Collectors.groupingBy(classifier, downstream)
    downstream = downstream or Collectors.toList()
    return collector(__K2L_HashMap.new, function(map, v)
        local key = classifier(v)
        if key == nil then
            error(__K2L_NullPointerException.new("element cannot be mapped to a null key"))
        end
        local container = map:get(key)
        if container == nil then
            container = downstream.supplier()
            map:put(key, container)
        end
        downstream.accumulator(container, v)
    end, function(map)
        if downstream.finisher ~= nil then
            map:replaceAll(function(_, container) return downstream.finisher(container) end)
        end
        return map
    end)
end

-- partitioningBy(predicate[, downstream]): {false=..., true=...}
function Collectors.partitioningBy(predicate, downstream)
    downstream = downstream or Collectors.toList()
    return collector(function()
        return {downstream.supplier(), downstream.supplier()}
    end, function(pair, v)
        downstream.accumulator(pair[predicate(v) and 2 or 1], v)
    end, function(pair)
        local map = __K2L_Map.new()
        for i, key in ipairs({false, true}) do
            map:put(key, downstream.finisher ~= nil and downstream.finisher(pair[i]) or pair[i])
        end
        return map
    end)
end

-- toMap(key, value) and toMap(key, value, merge): a HashMap
function Collectors.toMap(keyOf, valueOf, merge)
    return collector(__K2L_HashMap.new, function(map, v)
        local key, value = keyOf(v), valueOf(v)
        if value == nil then
            error(__K2L_NullPointerException.new())
        end
        if map:containsKey(key) then
            local old = map:get(key)
            if merge == nil then
                error(__K2L_IllegalStateException.new(
                    "Duplicate key " .. __K2L_Str(key) .. " (attempted merging values " .. __K2L_Str(old) .. " and " .. __K2L_Str(value) .. ")"
                ))
            end
            value = merge(old, value)
        end
        map:put(key, value)
    end)
end

end
