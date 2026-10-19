-- requires: Class, Collections, Exceptions, Str, Equals, Compare, Pair
-- kotlin.sequences: lazy sequences. A sequence holds a factory of generators; a generator is a
-- function returning `true, element` for each element and nothing at the end, so a loop is
-- `for _, x in seq:iter() do ... end` and null elements are fine. Intermediate operations wrap the
-- generator and run nothing until a terminal operation pulls elements, one at a time, as on the JVM.
local __K2L_Iterator -- below
local __K2L_Sequence = __K2L_Class("kotlin.sequences.Sequence")

function __K2L_Sequence:____init(factory)
    self.____factory = factory
end

-- Sequence classes written in Kotlin implement iterator() instead of having a factory.
__K2L_Sequence.____isSequence = true

function __K2L_Sequence:iter()
    local factory = self.____factory
    if factory ~= nil then
        return factory()
    end
    return __K2L_Iterator.iter(self:iterator())
end

------------------------------------------------------------------ Iterator
-- kotlin.collections.Iterator over a generator: hasNext() pulls the next element and keeps it.
__K2L_Iterator = __K2L_Class("kotlin.collections.Iterator")

function __K2L_Iterator:____init(gen)
    self.____gen = gen
end

function __K2L_Iterator:hasNext()
    if self.____ready == nil then
        local has, value = self.____gen()
        self.____ready = has == true
        self.____value = value
    end
    return self.____ready
end

function __K2L_Iterator:next()
    if not self:hasNext() then
        error(__K2L_NoSuchElementException.new())
    end
    local value = self.____value
    self.____ready, self.____value = nil, nil
    return value
end

-- A generator over any Iterator, including Kotlin classes implementing hasNext()/next().
function __K2L_Iterator.iter(iterator)
    return function()
        if iterator:hasNext() then
            return true, iterator:next()
        end
    end
end

-- A generator over a sequence, collection, map, string or iterator.
local function __K2L_Generator(source)
    if type(source) == "string" then
        local i = 0
        return function()
            if i < #source then
                i = i + 1
                return true, source:sub(i, i)
            end
        end
    elseif source.____isSequence then
        return source:iter()
    elseif source.hasNext ~= nil then
        return __K2L_Iterator.iter(source)
    end
    local arr, n
    if source.____array ~= nil then
        arr, n = source:____array()
    else
        arr, n = source:getEntries():____array()
    end
    local i = 0
    return function()
        if i < n then
            i = i + 1
            return true, arr[i]
        end
    end
end

-- collection.iterator()
local function __K2L_IteratorOf(source)
    if type(source) == "table" and source.iterator ~= nil and source.____array ~= nil then
        return source:iterator() -- a collection's iterator can remove()
    end
    return __K2L_Iterator.new(__K2L_Generator(source))
end

-- Collection functions taking a sequence argument (list + seq, list.addAll(seq)) read it as an array.
function __K2L_Sequence:____array()
    local list = self:toList()
    return list, list.size
end

function __K2L_Sequence:iterator()
    return __K2L_Iterator.new(self:iter())
end

------------------------------------------------------------------ sources
local function __K2L_SequenceOf(...)
    local values, n = {...}, select("#", ...)
    return __K2L_Sequence.new(function()
        local i = 0
        return function()
            if i < n then
                i = i + 1
                return true, values[i]
            end
        end
    end)
end

------------------------------------------------------------------ Sequence.asIterable()
-- An Iterable that reads its sequence again for each operation (so a constrainOnce sequence fails the second time, as on
-- the JVM). Operations that stop early pull only the elements they need, so they also work on infinite sequences; the others,
-- and a `for` loop, read all of it.
local __K2L_SequenceIterable = __K2L_Class("kotlin.sequences.SequencesKt$asIterable", __K2L_Iterable)

function __K2L_SequenceIterable:____init(sequence)
    self.____sequence = sequence
end

function __K2L_SequenceIterable:____array()
    local list = self.____sequence:toList()
    return list, list.size
end

function __K2L_SequenceIterable:iterator()
    return self.____sequence:iterator()
end

function __K2L_SequenceIterable:take(count)
    return self.____sequence:take(count):toList()
end

function __K2L_SequenceIterable:first(predicate)
    for _, value in self.____sequence:iter() do
        if predicate == nil or predicate(value) then
            return value
        end
    end
    error(__K2L_NoSuchElementException.new(predicate and "Collection contains no element matching the predicate."
        or "Collection is empty."))
end

for _, name in ipairs({"firstOrNull", "find", "any", "all", "none", "contains", "indexOf", "elementAtOrNull"}) do
    __K2L_SequenceIterable[name] = function(self, ...)
        return self.____sequence[name](self.____sequence, ...)
    end
end

function __K2L_Sequence:asIterable()
    return __K2L_SequenceIterable.new(self)
end

-- sequence.toCollection(destination)
function __K2L_Sequence:toCollection(destination)
    for _, value in self:iter() do
        destination:add(value)
    end
    return destination
end

-- collection.asSequence(), string.asSequence(), map.asSequence(): iterates the live source.
local function __K2L_AsSequence(source)
    if type(source) == "table" and source.____isSequence then
        return source
    elseif type(source) == "table" and getmetatable(source) == __K2L_SequenceIterable then
        return source.____sequence
    elseif type(source) == "table" and source.hasNext ~= nil then
        return __K2L_Sequence.new(function() return __K2L_Iterator.iter(source) end):constrainOnce()
    end
    return __K2L_Sequence.new(function() return __K2L_Generator(source) end)
end

-- Sequence { iterator }
local function __K2L_SequenceFromIterator(iteratorFactory)
    return __K2L_Sequence.new(function() return __K2L_Iterator.iter(iteratorFactory()) end)
end

-- generateSequence({ seed }) { next } and, without `nextFunction`, the single-use
-- generateSequence { next }. `next` runs only when the following element is pulled; null ends it.
local function __K2L_GenerateSequenceLazy(seedFunction, nextFunction)
    local sequence = __K2L_Sequence.new(function()
        local started, current = false, nil
        return function()
            if not started then
                started = true
                current = seedFunction()
            elseif current ~= nil then
                current = (nextFunction or seedFunction)(current)
            end
            if current ~= nil then
                return true, current
            end
        end
    end)
    return nextFunction and sequence or sequence:constrainOnce()
end

-- generateSequence(seed) { next }
local function __K2L_GenerateSequence(seed, nextFunction)
    return __K2L_GenerateSequenceLazy(function() return seed end, nextFunction)
end

------------------------------------------------------------------ sequence { } and iterator { }
-- The builder block runs in a Lua coroutine, and yield(x) is coroutine.yield(x): each element is
-- computed when the consumer asks for it. Exceptions thrown by the block reach the consumer.
local SequenceScope = __K2L_Class("kotlin.sequences.SequenceBuilderIterator")

function SequenceScope:yield(value)
    coroutine.yield(value)
end

function SequenceScope:yieldAll(elements)
    for _, value in __K2L_Generator(elements) do
        coroutine.yield(value)
    end
end

local function builderGenerator(block)
    local co = coroutine.create(function() block(SequenceScope.new()) end)
    return function()
        if coroutine.status(co) == "dead" then
            return
        end
        local ok, value = coroutine.resume(co)
        if not ok then
            error(value, 0)
        end
        if coroutine.status(co) ~= "dead" then
            return true, value
        end
    end
end

-- sequence { }: every iteration runs the block again.
local function __K2L_SequenceBuilder(block)
    return __K2L_Sequence.new(function() return builderGenerator(block) end)
end

-- iterator { }
local function __K2L_IteratorBuilder(block)
    return __K2L_Iterator.new(builderGenerator(block))
end

------------------------------------------------------------------ intermediate operations
local function derive(source, wrap)
    return __K2L_Sequence.new(function() return wrap(source:iter()) end)
end

local function checkCount(n)
    if n < 0 then
        error(__K2L_IllegalArgumentException.new("Requested element count " .. n .. " is less than zero."))
    end
end

function __K2L_Sequence:constrainOnce()
    local used = false
    local source = self
    return __K2L_Sequence.new(function()
        if used then
            error(__K2L_IllegalStateException.new("This sequence can be consumed only once."))
        end
        used = true
        return source:iter()
    end)
end

function __K2L_Sequence:asSequence()
    return self
end

function __K2L_Sequence:map(transform)
    return derive(self, function(gen)
        return function()
            local has, value = gen()
            if has then
                return true, transform(value)
            end
        end
    end)
end

function __K2L_Sequence:mapIndexed(transform)
    return derive(self, function(gen)
        local index = -1
        return function()
            local has, value = gen()
            if has then
                index = index + 1
                return true, transform(index, value)
            end
        end
    end)
end

function __K2L_Sequence:withIndex()
    return self:mapIndexed(function(index, value) return {index = index, value = value} end)
end

function __K2L_Sequence:filterIndexed(predicate)
    return derive(self, function(gen)
        local index = -1
        return function()
            while true do
                local has, value = gen()
                if not has then
                    return
                end
                index = index + 1
                if predicate(index, value) then
                    return true, value
                end
            end
        end
    end)
end

function __K2L_Sequence:filter(predicate)
    return self:filterIndexed(function(_, value) return predicate(value) end)
end

function __K2L_Sequence:filterNot(predicate)
    return self:filterIndexed(function(_, value) return not predicate(value) end)
end

function __K2L_Sequence:filterNotNull()
    return self:filterIndexed(function(_, value) return value ~= nil end)
end

function __K2L_Sequence:mapNotNull(transform)
    return self:map(transform):filterNotNull()
end

function __K2L_Sequence:mapIndexedNotNull(transform)
    return self:mapIndexed(transform):filterNotNull()
end

-- `transform` returns a sequence or a collection.
function __K2L_Sequence:flatMap(transform)
    return derive(self, function(gen)
        local inner
        return function()
            while true do
                if inner ~= nil then
                    local has, value = inner()
                    if has then
                        return true, value
                    end
                    inner = nil
                end
                local has, value = gen()
                if not has then
                    return
                end
                inner = __K2L_Generator(transform(value))
            end
        end
    end)
end

function __K2L_Sequence:flatten()
    return self:flatMap(function(it) return it end)
end

function __K2L_Sequence:take(count)
    checkCount(count)
    return derive(self, function(gen)
        local left = count
        return function()
            if left > 0 then
                left = left - 1
                return gen()
            end
        end
    end)
end

function __K2L_Sequence:drop(count)
    checkCount(count)
    return derive(self, function(gen)
        local skip = count
        return function()
            while skip > 0 do
                skip = skip - 1
                if not gen() then
                    return
                end
            end
            return gen()
        end
    end)
end

function __K2L_Sequence:takeWhile(predicate)
    return derive(self, function(gen)
        local done = false
        return function()
            if done then
                return
            end
            local has, value = gen()
            if has and predicate(value) then
                return true, value
            end
            done = true
        end
    end)
end

function __K2L_Sequence:dropWhile(predicate)
    return derive(self, function(gen)
        local dropping = true
        return function()
            while dropping do
                local has, value = gen()
                if not has then
                    return
                end
                if not predicate(value) then
                    dropping = false
                    return true, value
                end
            end
            return gen()
        end
    end)
end

function __K2L_Sequence:distinctBy(selector)
    return derive(self, function(gen)
        local seen = __K2L_Set.new()
        return function()
            while true do
                local has, value = gen()
                if not has then
                    return
                end
                if seen:add(selector(value)) then
                    return true, value
                end
            end
        end
    end)
end

function __K2L_Sequence:distinct()
    return self:distinctBy(function(it) return it end)
end

function __K2L_Sequence:onEach(action)
    return self:map(function(value)
        action(value)
        return value
    end)
end

function __K2L_Sequence:onEachIndexed(action)
    return self:mapIndexed(function(index, value)
        action(index, value)
        return value
    end)
end

function __K2L_Sequence:zip(other, transform)
    local source = self
    return __K2L_Sequence.new(function()
        local first, second = source:iter(), other:iter()
        return function()
            local has, a = first()
            if not has then
                return
            end
            local hasB, b = second()
            if hasB then
                if transform ~= nil then
                    return true, transform(a, b)
                end
                return true, __K2L_Pair.new(a, b)
            end
        end
    end)
end

function __K2L_Sequence:zipWithNext(transform)
    return derive(self, function(gen)
        local started, previous = false, nil
        return function()
            if not started then
                started = true
                local has, value = gen()
                if not has then
                    return
                end
                previous = value
            end
            local has, value = gen()
            if has then
                local a = previous
                previous = value
                if transform ~= nil then
                    return true, transform(a, value)
                end
                return true, __K2L_Pair.new(a, value)
            end
        end
    end)
end

function __K2L_Sequence:windowed(size, step, partialWindows, transform)
    step = step or 1
    if size <= 0 or step <= 0 then
        local message = size ~= step and "Both size " .. size .. " and step " .. step .. " must be greater than zero."
            or "size " .. size .. " must be greater than zero."
        error(__K2L_IllegalArgumentException.new(message))
    end
    return derive(self, function(gen)
        local buffer, done = __K2L_List.new(), false
        return function()
            while buffer.size < size and not done do
                local has, value = gen()
                if has then
                    buffer:add(value)
                else
                    done = true
                end
            end
            if buffer.size == 0 or (buffer.size < size and not partialWindows) then
                return
            end
            local window = buffer:toMutableList()
            local dropped = math.min(step, buffer.size)
            buffer = buffer:drop(dropped):toMutableList()
            -- With step > size, the elements between windows are skipped.
            for _ = dropped + 1, step do
                if done or not gen() then
                    done = true
                    break
                end
            end
            if transform ~= nil then
                return true, transform(window)
            end
            return true, window
        end
    end)
end

function __K2L_Sequence:chunked(size, transform)
    return self:windowed(size, size, true, transform)
end

function __K2L_Sequence:runningFold(initial, operation)
    return derive(self, function(gen)
        local started, acc = false, initial
        return function()
            if not started then
                started = true
                return true, acc
            end
            local has, value = gen()
            if has then
                acc = operation(acc, value)
                return true, acc
            end
        end
    end)
end

__K2L_Sequence.scan = __K2L_Sequence.runningFold

function __K2L_Sequence:runningReduce(operation)
    return derive(self, function(gen)
        local started, acc = false, nil
        return function()
            local has, value = gen()
            if not has then
                return
            end
            if started then
                acc = operation(acc, value)
            else
                started, acc = true, value
            end
            return true, acc
        end
    end)
end

-- Appends one element (plus) or a sequence/collection (plusAll).
function __K2L_Sequence:plusAll(elements)
    local source = self
    return __K2L_Sequence.new(function()
        local gen, second = source:iter(), false
        return function()
            while true do
                local has, value = gen()
                if has or second then
                    return has, value
                end
                second, gen = true, __K2L_Generator(elements)
            end
        end
    end)
end

function __K2L_Sequence:plus(element)
    return self:plusAll(__K2L_SequenceOf(element))
end

function __K2L_Sequence:minus(element)
    return derive(self, function(gen)
        local removed = false
        return function()
            while true do
                local has, value = gen()
                if not has then
                    return
                end
                if removed or not __K2L_Equals(value, element) then
                    return true, value
                end
                removed = true
            end
        end
    end)
end

function __K2L_Sequence:minusAll(elements)
    local set = __K2L_AsSequence(elements):toSet()
    return self:filter(function(value) return not set:contains(value) end)
end

function __K2L_Sequence:ifEmpty(defaultValue)
    local source = self
    return __K2L_Sequence.new(function()
        local gen = source:iter()
        local has, value = gen()
        if not has then
            return defaultValue():iter()
        end
        local first = true
        return function()
            if first then
                first = false
                return true, value
            end
            return gen()
        end
    end)
end

-- sorted*: stateful, so the whole source is read when the first element is pulled.
local function sortedSequence(source, sort)
    return __K2L_Sequence.new(function() return __K2L_Generator(sort(source:toList())) end)
end

function __K2L_Sequence:sorted()
    return sortedSequence(self, function(list) return list:sorted() end)
end

function __K2L_Sequence:sortedDescending()
    return sortedSequence(self, function(list) return list:sortedDescending() end)
end

function __K2L_Sequence:sortedBy(selector, pure)
    return sortedSequence(self, function(list) return list:sortedBy(selector, pure) end)
end

function __K2L_Sequence:sortedByDescending(selector, pure)
    return sortedSequence(self, function(list) return list:sortedByDescending(selector, pure) end)
end

function __K2L_Sequence:sortedWith(comparator)
    return sortedSequence(self, function(list) return list:sortedWith(comparator) end)
end

------------------------------------------------------------------ terminal operations
function __K2L_Sequence:toList()
    local out, n = {}, 0
    for _, value in self:iter() do
        n = n + 1
        out[n] = value
    end
    out.size = n
    return setmetatable(out, __K2L_List)
end

__K2L_Sequence.toMutableList = __K2L_Sequence.toList

function __K2L_Sequence:toSet()
    local set = __K2L_Set.new()
    for _, value in self:iter() do
        set:add(value)
    end
    return set
end

__K2L_Sequence.toMutableSet = __K2L_Sequence.toSet
-- a HashSet, which iterates in the JVM's hash order
function __K2L_Sequence:toHashSet()
    return __K2L_HashSet.new(self:toList())
end

function __K2L_Sequence:forEach(action)
    for _, value in self:iter() do
        action(value)
    end
end

function __K2L_Sequence:forEachIndexed(action)
    local index = 0
    for _, value in self:iter() do
        action(index, value)
        index = index + 1
    end
end

function __K2L_Sequence:foldIndexed(initial, operation)
    local acc, index = initial, 0
    for _, value in self:iter() do
        acc = operation(index, acc, value)
        index = index + 1
    end
    return acc
end

function __K2L_Sequence:fold(initial, operation)
    return self:foldIndexed(initial, function(_, acc, value) return operation(acc, value) end)
end

function __K2L_Sequence:reduce(operation)
    local gen = self:iter()
    local has, acc = gen()
    if not has then
        error(__K2L_UnsupportedOperationException.new("Empty sequence can't be reduced."))
    end
    for _, value in gen do
        acc = operation(acc, value)
    end
    return acc
end

-- The first element matching `predicate` (or any element): found, value.
local function search(self, predicate)
    for _, value in self:iter() do
        if predicate == nil or predicate(value) then
            return true, value
        end
    end
    return false
end

function __K2L_Sequence:firstOrNull(predicate)
    local _, value = search(self, predicate)
    return value
end

__K2L_Sequence.find = __K2L_Sequence.firstOrNull

function __K2L_Sequence:first(predicate)
    local found, value = search(self, predicate)
    if not found then
        error(__K2L_NoSuchElementException.new(predicate and "Sequence contains no element matching the predicate."
            or "Sequence is empty."))
    end
    return value
end

-- The last element matching `predicate` (or any element): found, value.
local function searchLast(self, predicate)
    local found, last = false, nil
    for _, value in self:iter() do
        if predicate == nil or predicate(value) then
            found, last = true, value
        end
    end
    return found, last
end

function __K2L_Sequence:lastOrNull(predicate)
    local _, value = searchLast(self, predicate)
    return value
end

__K2L_Sequence.findLast = __K2L_Sequence.lastOrNull

function __K2L_Sequence:last(predicate)
    local found, value = searchLast(self, predicate)
    if not found then
        error(__K2L_NoSuchElementException.new(predicate and "Sequence contains no element matching the predicate."
            or "Sequence is empty."))
    end
    return value
end

-- The single element matching `predicate`: count (0, 1 or 2 for "more"), value.
local function searchSingle(self, predicate)
    local count, single = 0, nil
    for _, value in self:iter() do
        if predicate == nil or predicate(value) then
            if count == 1 then
                return 2
            end
            count, single = 1, value
        end
    end
    return count, single
end

function __K2L_Sequence:single(predicate)
    local count, value = searchSingle(self, predicate)
    if count == 0 then
        error(__K2L_NoSuchElementException.new(predicate and "Sequence contains no element matching the predicate."
            or "Sequence is empty."))
    elseif count == 2 then
        error(__K2L_IllegalArgumentException.new(predicate and "Sequence contains more than one matching element."
            or "Sequence has more than one element."))
    end
    return value
end

function __K2L_Sequence:singleOrNull(predicate)
    local count, value = searchSingle(self, predicate)
    if count == 1 then
        return value
    end
    return nil
end

function __K2L_Sequence:elementAtOrNull(index)
    local i = 0
    for _, value in self:iter() do
        if i == index then
            return value
        end
        i = i + 1
    end
    return nil
end

function __K2L_Sequence:elementAt(index)
    local i = 0
    if index >= 0 then
        for _, value in self:iter() do
            if i == index then
                return value
            end
            i = i + 1
        end
    end
    error(__K2L_IndexOutOfBoundsException.new("Sequence doesn't contain element at index " .. index .. "."))
end

function __K2L_Sequence:indexOfFirst(predicate)
    local i = 0
    for _, value in self:iter() do
        if predicate(value) then
            return i
        end
        i = i + 1
    end
    return -1
end

function __K2L_Sequence:indexOf(element)
    return self:indexOfFirst(function(value) return __K2L_Equals(value, element) end)
end

function __K2L_Sequence:contains(element)
    return self:indexOf(element) >= 0
end

function __K2L_Sequence:any(predicate)
    return (search(self, predicate))
end

function __K2L_Sequence:none(predicate)
    return not search(self, predicate)
end

function __K2L_Sequence:all(predicate)
    return not search(self, function(value) return not predicate(value) end)
end

function __K2L_Sequence:count(predicate)
    local n = 0
    for _, value in self:iter() do
        if predicate == nil or predicate(value) then
            n = n + 1
        end
    end
    return n
end

-- `zero` is 0 or 0.0, chosen by the compiler from the element type.
function __K2L_Sequence:sumOf(selector, zero)
    local total = zero or 0
    for _, value in self:iter() do
        total = total + selector(value)
    end
    return total
end

function __K2L_Sequence:sum(zero)
    return self:sumOf(function(it) return it end, zero)
end

function __K2L_Sequence:average()
    local total, n = 0.0, 0
    for _, value in self:iter() do
        total, n = total + value, n + 1
    end
    return n == 0 and 0 / 0 or total / n
end

-- The element with the largest (sign 1) or smallest (sign -1) key: found, element, key.
local function extreme(self, selector, sign)
    local found, best, bestKey = false, nil, nil
    for _, value in self:iter() do
        local key = value
        if selector ~= nil then
            key = selector(value) -- may be false (a Boolean key)
        end
        if not found or __K2L_Compare(key, bestKey) * sign > 0 then
            found, best, bestKey = true, value, key
        end
    end
    return found, best, bestKey
end

local function extremeOrThrow(self, selector, sign)
    local found, best, bestKey = extreme(self, selector, sign)
    if not found then
        error(__K2L_NoSuchElementException.new())
    end
    return best, bestKey
end

function __K2L_Sequence:maxOrNull() return (select(2, extreme(self, nil, 1))) end
function __K2L_Sequence:minOrNull() return (select(2, extreme(self, nil, -1))) end
function __K2L_Sequence:max() return (extremeOrThrow(self, nil, 1)) end
function __K2L_Sequence:min() return (extremeOrThrow(self, nil, -1)) end
function __K2L_Sequence:maxByOrNull(selector) return (select(2, extreme(self, selector, 1))) end
function __K2L_Sequence:minByOrNull(selector) return (select(2, extreme(self, selector, -1))) end
function __K2L_Sequence:maxBy(selector) return (extremeOrThrow(self, selector, 1)) end
function __K2L_Sequence:minBy(selector) return (extremeOrThrow(self, selector, -1)) end
function __K2L_Sequence:maxOf(selector) return (select(2, extremeOrThrow(self, selector, 1))) end
function __K2L_Sequence:minOf(selector) return (select(2, extremeOrThrow(self, selector, -1))) end
function __K2L_Sequence:maxOfOrNull(selector) return (select(3, extreme(self, selector, 1))) end
function __K2L_Sequence:minOfOrNull(selector) return (select(3, extreme(self, selector, -1))) end

function __K2L_Sequence:joinToString(separator, prefix, postfix, limit, truncated, transform)
    separator = separator or ", "
    limit = limit or -1
    local parts, n = {prefix or ""}, 0
    for _, value in self:iter() do
        n = n + 1
        if limit >= 0 and n > limit then
            parts[#parts + 1] = (n > 1 and separator or "") .. (truncated or "...")
            break
        end
        local text = transform and __K2L_Str(transform(value)) or __K2L_Str(value)
        parts[#parts + 1] = (n > 1 and separator or "") .. text
    end
    parts[#parts + 1] = postfix or ""
    return table.concat(parts)
end

function __K2L_Sequence:groupBy(keySelector, valueTransform)
    local map = __K2L_Map.new()
    for _, value in self:iter() do
        local key = keySelector(value)
        local group = map:get(key)
        if group == nil then
            group = __K2L_List.new()
            map:put(key, group)
        end
        if valueTransform ~= nil then
            value = valueTransform(value)
        end
        group:add(value)
    end
    return map
end

function __K2L_Sequence:associate(transform)
    local map = __K2L_Map.new()
    for _, value in self:iter() do
        local pair = transform(value)
        map:put(pair.first, pair.second)
    end
    return map
end

function __K2L_Sequence:associateBy(keySelector, valueTransform)
    return self:associate(function(value)
        local key = keySelector(value)
        if valueTransform ~= nil then
            value = valueTransform(value)
        end
        return __K2L_Pair.new(key, value)
    end)
end

function __K2L_Sequence:associateWith(valueSelector)
    return self:associate(function(value) return __K2L_Pair.new(value, valueSelector(value)) end)
end

function __K2L_Sequence:toMap()
    return self:associate(function(pair) return pair end)
end

function __K2L_Sequence:partition(predicate)
    local yes, no = __K2L_List.new(), __K2L_List.new()
    for _, value in self:iter() do
        if predicate(value) then
            yes:add(value)
        else
            no:add(value)
        end
    end
    return __K2L_Pair.new(yes, no)
end

------------------------------------------------------------------ more operations (each pulls one element at a time)
function __K2L_Sequence:elementAtOrElse(index, defaultValue)
    if index >= 0 then
        local i = 0
        for _, value in self:iter() do
            if i == index then
                return value
            end
            i = i + 1
        end
    end
    return defaultValue(index)
end

function __K2L_Sequence:firstNotNullOfOrNull(transform)
    for _, value in self:iter() do
        local result = transform(value)
        if result ~= nil then
            return result
        end
    end
    return nil
end

function __K2L_Sequence:firstNotNullOf(transform)
    local result = self:firstNotNullOfOrNull(transform)
    if result == nil then
        error(__K2L_NoSuchElementException.new("No element of the sequence was transformed to a non-null value."))
    end
    return result
end

function __K2L_Sequence:indexOfLast(predicate)
    local i, found = 0, -1
    for _, value in self:iter() do
        if predicate(value) then
            found = i
        end
        i = i + 1
    end
    return found
end

function __K2L_Sequence:lastIndexOf(element)
    return self:indexOfLast(function(value) return __K2L_Equals(value, element) end)
end

-- The ...To operations add to (or put into) `destination` and return it.
function __K2L_Sequence:filterIndexedTo(destination, predicate)
    local i = 0
    for _, value in self:iter() do
        if predicate(i, value) then
            destination:add(value)
        end
        i = i + 1
    end
    return destination
end

function __K2L_Sequence:filterTo(destination, predicate)
    return self:filterIndexedTo(destination, function(_, value) return predicate(value) end)
end

function __K2L_Sequence:filterNotTo(destination, predicate)
    return self:filterIndexedTo(destination, function(_, value) return not predicate(value) end)
end

function __K2L_Sequence:filterNotNullTo(destination)
    return self:filterIndexedTo(destination, function(_, value) return value ~= nil end)
end

function __K2L_Sequence:mapIndexedNotNullTo(destination, transform)
    local i = 0
    for _, value in self:iter() do
        local result = transform(i, value)
        if result ~= nil then
            destination:add(result)
        end
        i = i + 1
    end
    return destination
end

function __K2L_Sequence:mapIndexedTo(destination, transform)
    local i = 0
    for _, value in self:iter() do
        destination:add(transform(i, value))
        i = i + 1
    end
    return destination
end

function __K2L_Sequence:mapTo(destination, transform)
    for _, value in self:iter() do
        destination:add(transform(value))
    end
    return destination
end

function __K2L_Sequence:mapNotNullTo(destination, transform)
    return self:mapIndexedNotNullTo(destination, function(_, value) return transform(value) end)
end

function __K2L_Sequence:flatMapIndexedTo(destination, transform)
    local i = 0
    for _, value in self:iter() do
        for _, element in __K2L_Generator(transform(i, value)) do
            destination:add(element)
        end
        i = i + 1
    end
    return destination
end

function __K2L_Sequence:flatMapTo(destination, transform)
    return self:flatMapIndexedTo(destination, function(_, value) return transform(value) end)
end

-- flatMapIndexed { index, x -> }: lazy, like flatMap.
function __K2L_Sequence:flatMapIndexed(transform)
    return __K2L_Sequence.new(function()
        local i = -1
        return self:flatMap(function(value)
            i = i + 1
            return transform(i, value)
        end):iter()
    end)
end

function __K2L_Sequence:associateTo(destination, transform)
    for _, value in self:iter() do
        local pair = transform(value)
        destination:put(pair.first, pair.second)
    end
    return destination
end

function __K2L_Sequence:associateByTo(destination, keySelector, valueTransform)
    for _, value in self:iter() do
        local key = keySelector(value)
        if valueTransform ~= nil then
            value = valueTransform(value)
        end
        destination:put(key, value)
    end
    return destination
end

function __K2L_Sequence:associateWithTo(destination, valueSelector)
    for _, value in self:iter() do
        destination:put(value, valueSelector(value))
    end
    return destination
end

function __K2L_Sequence:groupByTo(destination, keySelector, valueTransform)
    for _, value in self:iter() do
        local key = keySelector(value)
        local group = destination:get(key)
        if group == nil then
            group = __K2L_List.new()
            destination:put(key, group)
        end
        if valueTransform ~= nil then
            value = valueTransform(value)
        end
        group:add(value)
    end
    return destination
end

function __K2L_Sequence:groupingBy(keySelector)
    return __K2L_Grouping.new(self, keySelector)
end

-- maxWith(comparator), maxOfWith(comparator, selector), ...: by the comparator; `selector` maps the elements first.
local function extremeWith(self, comparator, selector, sign, orNull)
    local found, best = false, nil
    for _, value in self:iter() do
        if selector ~= nil then
            value = selector(value)
        end
        if not found or comparator(value, best) * sign > 0 then
            found, best = true, value
        end
    end
    if not found and not orNull then
        error(__K2L_NoSuchElementException.new())
    end
    return best
end

function __K2L_Sequence:maxWith(comparator) return extremeWith(self, comparator, nil, 1, false) end
function __K2L_Sequence:minWith(comparator) return extremeWith(self, comparator, nil, -1, false) end
function __K2L_Sequence:maxWithOrNull(comparator) return extremeWith(self, comparator, nil, 1, true) end
function __K2L_Sequence:minWithOrNull(comparator) return extremeWith(self, comparator, nil, -1, true) end
function __K2L_Sequence:maxOfWith(comparator, selector) return extremeWith(self, comparator, selector, 1, false) end
function __K2L_Sequence:minOfWith(comparator, selector) return extremeWith(self, comparator, selector, -1, false) end
function __K2L_Sequence:maxOfWithOrNull(comparator, selector) return extremeWith(self, comparator, selector, 1, true) end
function __K2L_Sequence:minOfWithOrNull(comparator, selector) return extremeWith(self, comparator, selector, -1, true) end

-- reduceIndexed { index, acc, x -> } (`orNull`: null for an empty sequence instead of throwing).
local function reduceIndexed(self, operation, orNull)
    local gen = self:iter()
    local has, acc = gen()
    if not has then
        if orNull then
            return nil
        end
        error(__K2L_UnsupportedOperationException.new("Empty sequence can't be reduced."))
    end
    local i = 1
    for _, value in gen do
        acc = operation(i, acc, value)
        i = i + 1
    end
    return acc
end

function __K2L_Sequence:reduceIndexed(operation) return reduceIndexed(self, operation, false) end
function __K2L_Sequence:reduceIndexedOrNull(operation) return reduceIndexed(self, operation, true) end

function __K2L_Sequence:reduceOrNull(operation)
    return reduceIndexed(self, function(_, acc, value) return operation(acc, value) end, true)
end

function __K2L_Sequence:runningFoldIndexed(initial, operation)
    return derive(self, function(gen)
        local started, acc, i = false, initial, 0
        return function()
            if not started then
                started = true
                return true, acc
            end
            local has, value = gen()
            if not has then
                return
            end
            acc = operation(i, acc, value)
            i = i + 1
            return true, acc
        end
    end)
end

__K2L_Sequence.scanIndexed = __K2L_Sequence.runningFoldIndexed

function __K2L_Sequence:runningReduceIndexed(operation)
    return derive(self, function(gen)
        local started, acc, i = false, nil, 1
        return function()
            local has, value = gen()
            if not has then
                return
            end
            if not started then
                started, acc = true, value
            else
                acc = operation(i, acc, value)
                i = i + 1
            end
            return true, acc
        end
    end)
end

function __K2L_Sequence:sumBy(selector)
    return self:sumOf(selector)
end

function __K2L_Sequence:sumByDouble(selector)
    return self:sumOf(selector, 0.0)
end

-- requireNoNulls(): lazy; a null element throws when it is reached.
function __K2L_Sequence:requireNoNulls()
    return derive(self, function(gen)
        return function()
            local has, value = gen()
            if not has then
                return
            end
            if value == nil then
                error(__K2L_IllegalArgumentException.new("null element found in " .. __K2L_Str(self) .. "."))
            end
            return true, value
        end
    end)
end

function __K2L_Sequence:joinTo(buffer, separator, prefix, postfix, limit, truncated, transform)
    buffer:append(self:joinToString(separator, prefix, postfix, limit, truncated, transform))
    return buffer
end

-- shuffled(random): lazy; picks each element when it is reached, as kotlin.sequences.shuffled does.
function __K2L_Sequence:shuffled(random)
    return __K2L_Sequence.new(function()
        local buffer
        return function()
            if buffer == nil then
                buffer = self:toMutableList()
            end
            if buffer.size == 0 then
                return
            end
            local j = random:nextInt(buffer.size)
            local last = buffer:removeLast()
            if j < buffer.size then
                return true, buffer:set(j, last)
            end
            return true, last
        end
    end)
end

function __K2L_Sequence:toSortedSet(comparator)
    return self:toList():toSortedSet(comparator)
end
