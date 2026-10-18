-- requires: Class, Str, Equals, Hash, Compare, Pair, Exceptions, ToInt32, Bit
-- Kotlin collections. Lists keep elements in the array part (1-based) with an explicit `size`, so
-- null elements are fine; maps and sets keep insertion order and honor equals()/hashCode() keys.

------------------------------------------------------------------ Iterable
-- Shared operations; subclasses provide ____array(), returning a 1-based array and its length.
local __K2L_Iterable = __K2L_Class("kotlin.collections.Iterable")
-- tostring() shows Kotlin's toString(); subclasses inherit the metamethod from __K2L_Class.
function __K2L_Iterable:__tostring()
    return self:toString()
end

local __K2L_List
local __K2L_Array
local __K2L_Set
local __K2L_Map
local __K2L_IntRange

-- Whether `obj` is an instance of `cls` or one of its subclasses.
local function inherits(obj, cls)
    local c = type(obj) == "table" and getmetatable(obj)
    while c do
        if c == cls then
            return true
        end
        c = rawget(c, "____super")
    end
    return false
end

local function newList(arr, n)
    arr.size = n
    return setmetatable(arr, __K2L_List)
end

local function stableSort(arr, n, less)
    -- Merge sort: Kotlin's sorts are stable, table.sort is not.
    local src, dst = {}, {}
    for i = 1, n do
        src[i] = arr[i]
    end
    local width = 1
    while width < n do
        local i = 1
        while i <= n do
            local mid, hi = math.min(i + width, n + 1), math.min(i + 2 * width, n + 1)
            local a, b, k = i, mid, i
            while a < mid and b < hi do
                if less(src[b], src[a]) then
                    dst[k] = src[b]
                    b = b + 1
                else
                    dst[k] = src[a]
                    a = a + 1
                end
                k = k + 1
            end
            while a < mid do
                dst[k] = src[a]
                a, k = a + 1, k + 1
            end
            while b < hi do
                dst[k] = src[b]
                b, k = b + 1, k + 1
            end
            i = i + 2 * width
        end
        src, dst = dst, src
        width = width * 2
    end
    return newList(src, n)
end

local function illegalArgument(message)
    error(__K2L_IllegalArgumentException.new(message))
end

local function noSuchElement(message)
    error(__K2L_NoSuchElementException.new(message))
end

function __K2L_Iterable:toList()
    local arr, n = self:____array()
    local out = {}
    for i = 1, n do
        out[i] = arr[i]
    end
    return newList(out, n)
end

__K2L_Iterable.toMutableList = __K2L_Iterable.toList

function __K2L_Iterable:toSet()
    local arr, n = self:____array()
    local set = __K2L_Set.new()
    for i = 1, n do
        set:add(arr[i])
    end
    return set
end

__K2L_Iterable.toMutableSet = __K2L_Iterable.toSet
__K2L_Iterable.toHashSet = __K2L_Iterable.toSet

function __K2L_Iterable:isEmpty()
    local _, n = self:____array()
    return n == 0
end

function __K2L_Iterable:isNotEmpty()
    return not self:isEmpty()
end

function __K2L_Iterable:contains(value)
    local arr, n = self:____array()
    for i = 1, n do
        if __K2L_Equals(arr[i], value) then
            return true
        end
    end
    return false
end

function __K2L_Iterable:containsAll(other)
    local arr, n = other:____array()
    for i = 1, n do
        if not self:contains(arr[i]) then
            return false
        end
    end
    return true
end

function __K2L_Iterable:indexOf(value)
    local arr, n = self:____array()
    for i = 1, n do
        if __K2L_Equals(arr[i], value) then
            return i - 1
        end
    end
    return -1
end

function __K2L_Iterable:lastIndexOf(value)
    local arr, n = self:____array()
    for i = n, 1, -1 do
        if __K2L_Equals(arr[i], value) then
            return i - 1
        end
    end
    return -1
end

function __K2L_Iterable:indexOfFirst(predicate)
    local arr, n = self:____array()
    for i = 1, n do
        if predicate(arr[i]) then
            return i - 1
        end
    end
    return -1
end

function __K2L_Iterable:indexOfLast(predicate)
    local arr, n = self:____array()
    for i = n, 1, -1 do
        if predicate(arr[i]) then
            return i - 1
        end
    end
    return -1
end

function __K2L_Iterable:elementAt(index)
    local arr, n = self:____array()
    if index < 0 or index >= n then
        error(__K2L_IndexOutOfBoundsException.new("Index " .. index .. " out of bounds for length " .. n))
    end
    return arr[index + 1]
end

function __K2L_Iterable:getOrNull(index)
    local arr, n = self:____array()
    if index < 0 or index >= n then
        return nil
    end
    return arr[index + 1]
end

function __K2L_Iterable:getOrElse(index, default)
    local arr, n = self:____array()
    if index < 0 or index >= n then
        return default(index)
    end
    return arr[index + 1]
end

function __K2L_Iterable:firstOrNull(predicate)
    local arr, n = self:____array()
    for i = 1, n do
        if predicate == nil or predicate(arr[i]) then
            return arr[i]
        end
    end
    return nil
end

__K2L_Iterable.find = __K2L_Iterable.firstOrNull

function __K2L_Iterable:first(predicate)
    local arr, n = self:____array()
    for i = 1, n do
        if predicate == nil or predicate(arr[i]) then
            return arr[i]
        end
    end
    noSuchElement(predicate == nil and "List is empty." or "Collection contains no element matching the predicate.")
end

function __K2L_Iterable:lastOrNull(predicate)
    local arr, n = self:____array()
    for i = n, 1, -1 do
        if predicate == nil or predicate(arr[i]) then
            return arr[i]
        end
    end
    return nil
end

__K2L_Iterable.findLast = __K2L_Iterable.lastOrNull

function __K2L_Iterable:last(predicate)
    local arr, n = self:____array()
    for i = n, 1, -1 do
        if predicate == nil or predicate(arr[i]) then
            return arr[i]
        end
    end
    noSuchElement(predicate == nil and "List is empty." or "List contains no element matching the predicate.")
end

function __K2L_Iterable:single(predicate)
    local arr, n = self:____array()
    local found, value = false, nil
    for i = 1, n do
        if predicate == nil or predicate(arr[i]) then
            if found then
                error(__K2L_IllegalArgumentException.new(predicate == nil and "List has more than one element."
                    or "Collection contains more than one matching element."))
            end
            found, value = true, arr[i]
        end
    end
    if not found then
        noSuchElement(predicate == nil and "List is empty." or "Collection contains no element matching the predicate.")
    end
    return value
end

function __K2L_Iterable:singleOrNull(predicate)
    local arr, n = self:____array()
    local found, value = false, nil
    for i = 1, n do
        if predicate == nil or predicate(arr[i]) then
            if found then
                return nil
            end
            found, value = true, arr[i]
        end
    end
    return value
end

function __K2L_Iterable:map(transform)
    local arr, n = self:____array()
    local out = {}
    for i = 1, n do
        out[i] = transform(arr[i])
    end
    return newList(out, n)
end

function __K2L_Iterable:mapIndexed(transform)
    local arr, n = self:____array()
    local out = {}
    for i = 1, n do
        out[i] = transform(i - 1, arr[i])
    end
    return newList(out, n)
end

function __K2L_Iterable:mapNotNull(transform)
    local arr, n = self:____array()
    local out, k = {}, 0
    for i = 1, n do
        local v = transform(arr[i])
        if v ~= nil then
            k = k + 1
            out[k] = v
        end
    end
    return newList(out, k)
end

function __K2L_Iterable:flatMap(transform)
    local arr, n = self:____array()
    local out, k = {}, 0
    for i = 1, n do
        local inner, m = transform(arr[i]):____array()
        for j = 1, m do
            k = k + 1
            out[k] = inner[j]
        end
    end
    return newList(out, k)
end

function __K2L_Iterable:flatten()
    return self:flatMap(function(it) return it end)
end

function __K2L_Iterable:filter(predicate)
    local arr, n = self:____array()
    local out, k = {}, 0
    for i = 1, n do
        if predicate(arr[i]) then
            k = k + 1
            out[k] = arr[i]
        end
    end
    return newList(out, k)
end

function __K2L_Iterable:filterIndexed(predicate)
    local arr, n = self:____array()
    local out, k = {}, 0
    for i = 1, n do
        if predicate(i - 1, arr[i]) then
            k = k + 1
            out[k] = arr[i]
        end
    end
    return newList(out, k)
end

function __K2L_Iterable:filterNot(predicate)
    return self:filter(function(it) return not predicate(it) end)
end

function __K2L_Iterable:filterNotNull()
    return self:filter(function(it) return it ~= nil end)
end

function __K2L_Iterable:partition(predicate)
    local arr, n = self:____array()
    local yes, no, a, b = {}, {}, 0, 0
    for i = 1, n do
        if predicate(arr[i]) then
            a = a + 1
            yes[a] = arr[i]
        else
            b = b + 1
            no[b] = arr[i]
        end
    end
    return __K2L_Pair.new(newList(yes, a), newList(no, b))
end

function __K2L_Iterable:any(predicate)
    local arr, n = self:____array()
    for i = 1, n do
        if predicate == nil or predicate(arr[i]) then
            return true
        end
    end
    return false
end

function __K2L_Iterable:all(predicate)
    local arr, n = self:____array()
    for i = 1, n do
        if not predicate(arr[i]) then
            return false
        end
    end
    return true
end

function __K2L_Iterable:none(predicate)
    return not self:any(predicate)
end

function __K2L_Iterable:count(predicate)
    local arr, n = self:____array()
    if predicate == nil then
        return n
    end
    local c = 0
    for i = 1, n do
        if predicate(arr[i]) then
            c = c + 1
        end
    end
    return c
end

-- `zero` is 0 or 0.0, chosen by the compiler from the element type.
function __K2L_Iterable:sum(zero)
    local arr, n = self:____array()
    local total = zero or 0
    for i = 1, n do
        total = total + arr[i]
    end
    return total
end

function __K2L_Iterable:sumOf(selector, zero)
    local arr, n = self:____array()
    local total = zero or 0
    for i = 1, n do
        total = total + selector(arr[i])
    end
    return total
end

function __K2L_Iterable:average()
    local arr, n = self:____array()
    if n == 0 then
        return 0 / 0
    end
    local total = 0.0
    for i = 1, n do
        total = total + arr[i]
    end
    return total / n
end

local function extreme(self, selector, sign, orNull, what)
    local arr, n = self:____array()
    if n == 0 then
        if orNull then
            return nil
        end
        noSuchElement(what)
    end
    local best, bestKey = arr[1], selector and selector(arr[1]) or arr[1]
    for i = 2, n do
        local key = selector and selector(arr[i]) or arr[i]
        if __K2L_Compare(key, bestKey) * sign > 0 then
            best, bestKey = arr[i], key
        end
    end
    return best, bestKey
end

function __K2L_Iterable:maxOrNull() return (extreme(self, nil, 1, true)) end
function __K2L_Iterable:minOrNull() return (extreme(self, nil, -1, true)) end
function __K2L_Iterable:max() return (extreme(self, nil, 1, false)) end
function __K2L_Iterable:min() return (extreme(self, nil, -1, false)) end
function __K2L_Iterable:maxByOrNull(selector) return (extreme(self, selector, 1, true)) end
function __K2L_Iterable:minByOrNull(selector) return (extreme(self, selector, -1, true)) end
function __K2L_Iterable:maxBy(selector) return (extreme(self, selector, 1, false)) end
function __K2L_Iterable:minBy(selector) return (extreme(self, selector, -1, false)) end
function __K2L_Iterable:maxOf(selector) return select(2, extreme(self, selector, 1, false)) end
function __K2L_Iterable:minOf(selector) return select(2, extreme(self, selector, -1, false)) end
function __K2L_Iterable:maxOfOrNull(selector) return select(2, extreme(self, selector, 1, true)) end
function __K2L_Iterable:minOfOrNull(selector) return select(2, extreme(self, selector, -1, true)) end

function __K2L_Iterable:sorted()
    local arr, n = self:____array()
    return stableSort(arr, n, function(a, b) return __K2L_Compare(a, b) < 0 end)
end

function __K2L_Iterable:sortedDescending()
    local arr, n = self:____array()
    return stableSort(arr, n, function(a, b) return __K2L_Compare(a, b) > 0 end)
end

function __K2L_Iterable:sortedBy(selector)
    local arr, n = self:____array()
    return stableSort(arr, n, function(a, b) return __K2L_Compare(selector(a), selector(b)) < 0 end)
end

function __K2L_Iterable:sortedByDescending(selector)
    local arr, n = self:____array()
    return stableSort(arr, n, function(a, b) return __K2L_Compare(selector(a), selector(b)) > 0 end)
end

-- `comparator` is a Lua function (a, b) -> Int, from a Kotlin lambda or compareBy.
function __K2L_Iterable:sortedWith(comparator)
    local arr, n = self:____array()
    return stableSort(arr, n, function(a, b) return comparator(a, b) < 0 end)
end

function __K2L_Iterable:reversed()
    local arr, n = self:____array()
    local out = {}
    for i = 1, n do
        out[i] = arr[n - i + 1]
    end
    return newList(out, n)
end

function __K2L_Iterable:distinct()
    return self:toSet():toList()
end

function __K2L_Iterable:distinctBy(selector)
    local arr, n = self:____array()
    local seen = __K2L_Set.new()
    local out, k = {}, 0
    for i = 1, n do
        if seen:add(selector(arr[i])) then
            k = k + 1
            out[k] = arr[i]
        end
    end
    return newList(out, k)
end

local function checkCount(count)
    if count < 0 then
        illegalArgument("Requested element count " .. count .. " is less than zero.")
    end
end

function __K2L_Iterable:take(count)
    checkCount(count)
    local arr, n = self:____array()
    local out = {}
    local m = math.min(count, n)
    for i = 1, m do
        out[i] = arr[i]
    end
    return newList(out, m)
end

function __K2L_Iterable:takeLast(count)
    checkCount(count)
    local arr, n = self:____array()
    local out = {}
    local m = math.min(count, n)
    for i = 1, m do
        out[i] = arr[n - m + i]
    end
    return newList(out, m)
end

function __K2L_Iterable:drop(count)
    checkCount(count)
    local arr, n = self:____array()
    local out, k = {}, 0
    for i = count + 1, n do
        k = k + 1
        out[k] = arr[i]
    end
    return newList(out, k)
end

function __K2L_Iterable:dropLast(count)
    checkCount(count)
    local arr, n = self:____array()
    local out = {}
    local m = math.max(n - count, 0)
    for i = 1, m do
        out[i] = arr[i]
    end
    return newList(out, m)
end

function __K2L_Iterable:takeWhile(predicate)
    local arr, n = self:____array()
    local out, k = {}, 0
    for i = 1, n do
        if not predicate(arr[i]) then
            break
        end
        k = k + 1
        out[k] = arr[i]
    end
    return newList(out, k)
end

function __K2L_Iterable:dropWhile(predicate)
    local arr, n = self:____array()
    local out, k, dropping = {}, 0, true
    for i = 1, n do
        if dropping and not predicate(arr[i]) then
            dropping = false
        end
        if not dropping then
            k = k + 1
            out[k] = arr[i]
        end
    end
    return newList(out, k)
end

function __K2L_Iterable:chunked(size, transform)
    return self:windowed(size, size, true, transform)
end

-- The elements of withIndex()
local __K2L_IndexedValue = __K2L_Class("kotlin.collections.IndexedValue")

function __K2L_IndexedValue:____init(index, value)
    self.index = index
    self.value = value
end

function __K2L_IndexedValue:toString()
    return "IndexedValue(index=" .. self.index .. ", value=" .. __K2L_Str(self.value) .. ")"
end

function __K2L_IndexedValue:equals(other)
    return getmetatable(other) == __K2L_IndexedValue and self.index == other.index and __K2L_Equals(self.value, other.value)
end

function __K2L_IndexedValue:hashCode()
    return __K2L_ToInt32(31 * self.index + __K2L_Hash(self.value))
end

function __K2L_Iterable:withIndex()
    return self:mapIndexed(function(index, value) return __K2L_IndexedValue.new(index, value) end)
end

function __K2L_Iterable:forEachIndexed(action)
    local arr, n = self:____array()
    for i = 1, n do
        action(i - 1, arr[i])
    end
end

function __K2L_Iterable:asIterable()
    return self
end

function __K2L_Iterable:getIndices()
    local _, n = self:____array()
    return __K2L_IntRange.new(0, n - 1, 1)
end

function __K2L_Iterable:zip(other, transform)
    local a, n = self:____array()
    local b, m = other:____array()
    local out = {}
    local k = math.min(n, m)
    for i = 1, k do
        if transform ~= nil then
            out[i] = transform(a[i], b[i])
        else
            out[i] = __K2L_Pair.new(a[i], b[i])
        end
    end
    return newList(out, k)
end

function __K2L_Iterable:fold(initial, operation)
    local arr, n = self:____array()
    local acc = initial
    for i = 1, n do
        acc = operation(acc, arr[i])
    end
    return acc
end

function __K2L_Iterable:reduce(operation)
    local arr, n = self:____array()
    if n == 0 then
        error(__K2L_UnsupportedOperationException.new("Empty collection can't be reduced."))
    end
    local acc = arr[1]
    for i = 2, n do
        acc = operation(acc, arr[i])
    end
    return acc
end

function __K2L_Iterable:joinToString(separator, prefix, postfix, limit, truncated, transform)
    separator = separator or ", "
    limit = limit or -1
    local arr, n = self:____array()
    local parts = {prefix or ""}
    for i = 1, n do
        if limit >= 0 and i > limit then
            parts[#parts + 1] = (separator or ", ") .. (truncated or "...")
            break
        end
        local text = transform and __K2L_Str(transform(arr[i])) or __K2L_Str(arr[i])
        parts[#parts + 1] = (i > 1 and separator or "") .. text
    end
    parts[#parts + 1] = postfix or ""
    return table.concat(parts)
end

function __K2L_Iterable:groupBy(keySelector, valueTransform)
    local arr, n = self:____array()
    local map = __K2L_Map.new()
    for i = 1, n do
        local key = keySelector(arr[i])
        local group = map:get(key)
        if group == nil then
            group = __K2L_List.new()
            map:put(key, group)
        end
        if valueTransform ~= nil then
            group:add(valueTransform(arr[i]))
        else
            group:add(arr[i])
        end
    end
    return map
end

function __K2L_Iterable:associate(transform)
    local arr, n = self:____array()
    local map = __K2L_Map.new()
    for i = 1, n do
        local pair = transform(arr[i])
        map:put(pair.first, pair.second)
    end
    return map
end

function __K2L_Iterable:associateBy(keySelector, valueTransform)
    local arr, n = self:____array()
    local map = __K2L_Map.new()
    for i = 1, n do
        if valueTransform ~= nil then
            map:put(keySelector(arr[i]), valueTransform(arr[i]))
        else
            map:put(keySelector(arr[i]), arr[i])
        end
    end
    return map
end

function __K2L_Iterable:associateWith(valueSelector)
    local arr, n = self:____array()
    local map = __K2L_Map.new()
    for i = 1, n do
        map:put(arr[i], valueSelector(arr[i]))
    end
    return map
end

function __K2L_Iterable:toMap()
    return self:associate(function(pair) return pair end)
end

function __K2L_Iterable:forEach(action)
    local arr, n = self:____array()
    for i = 1, n do
        action(arr[i])
    end
end

function __K2L_Iterable:onEach(action)
    self:forEach(action)
    return self
end

function __K2L_Iterable:plus(element)
    local out = self:toList()
    out:add(element)
    return out
end

function __K2L_Iterable:plusAll(elements)
    local out = self:toList()
    out:addAll(elements)
    return out
end

function __K2L_Iterable:minus(element)
    local out = self:toList()
    out:remove(element)
    return out
end

function __K2L_Iterable:minusAll(elements)
    return self:filter(function(it) return not elements:contains(it) end)
end

function __K2L_Iterable:intersect(other)
    return self:toSet():filter(function(it) return other:contains(it) end):toSet()
end

function __K2L_Iterable:union(other)
    local set = self:toSet()
    set:addAll(other)
    return set
end

function __K2L_Iterable:subtract(other)
    return self:toSet():filter(function(it) return not other:contains(it) end):toSet()
end

function __K2L_Iterable:toTypedArray()
    local arr, n = self:____array()
    local out = {}
    for i = 1, n do
        out[i] = arr[i]
    end
    out.size = n
    return setmetatable(out, __K2L_Array)
end

__K2L_Iterable.toIntArray = __K2L_Iterable.toTypedArray
__K2L_Iterable.toLongArray = __K2L_Iterable.toTypedArray
__K2L_Iterable.toDoubleArray = __K2L_Iterable.toTypedArray
__K2L_Iterable.toBooleanArray = __K2L_Iterable.toTypedArray

function __K2L_Iterable:hashCode()
    local arr, n = self:____array()
    local h = 1
    for i = 1, n do
        h = __K2L_ToInt32(31 * h + __K2L_Hash(arr[i]))
    end
    return h
end


------------------------------------------------------------------ more Iterable operations
local function windowSizes(size, step)
    if size <= 0 or step <= 0 then
        illegalArgument(size ~= step and "Both size " .. size .. " and step " .. step .. " must be greater than zero."
            or "size " .. size .. " must be greater than zero.")
    end
end

function __K2L_Iterable:windowed(size, step, partialWindows, transform)
    step = step or 1
    windowSizes(size, step)
    local arr, n = self:____array()
    local out, k = {}, 0
    local i = 1
    while i <= n and (partialWindows or i + size - 1 <= n) do
        local window, m = {}, 0
        for j = i, math.min(i + size - 1, n) do
            m = m + 1
            window[m] = arr[j]
        end
        k = k + 1
        local list = newList(window, m)
        if transform ~= nil then
            out[k] = transform(list)
        else
            out[k] = list
        end
        i = i + step
    end
    return newList(out, k)
end

function __K2L_Iterable:zipWithNext(transform)
    local arr, n = self:____array()
    local out, k = {}, 0
    for i = 1, n - 1 do
        k = k + 1
        if transform ~= nil then
            out[k] = transform(arr[i], arr[i + 1])
        else
            out[k] = __K2L_Pair.new(arr[i], arr[i + 1])
        end
    end
    return newList(out, k)
end

function __K2L_Iterable:unzip()
    local arr, n = self:____array()
    local first, second = {}, {}
    for i = 1, n do
        first[i], second[i] = arr[i].first, arr[i].second
    end
    return __K2L_Pair.new(newList(first, n), newList(second, n))
end

function __K2L_Iterable:foldRightIndexed(initial, operation)
    local arr, n = self:____array()
    local acc = initial
    for i = n, 1, -1 do
        acc = operation(i - 1, arr[i], acc)
    end
    return acc
end

function __K2L_Iterable:foldRight(initial, operation)
    local arr, n = self:____array()
    local acc = initial
    for i = n, 1, -1 do
        acc = operation(arr[i], acc)
    end
    return acc
end

function __K2L_Iterable:reduceRight(operation)
    local arr, n = self:____array()
    if n == 0 then
        error(__K2L_UnsupportedOperationException.new("Empty list can't be reduced."))
    end
    local acc = arr[n]
    for i = n - 1, 1, -1 do
        acc = operation(arr[i], acc)
    end
    return acc
end

function __K2L_Iterable:reduceOrNull(operation)
    local arr, n = self:____array()
    if n == 0 then
        return nil
    end
    return self:reduce(operation)
end

function __K2L_Iterable:foldIndexed(initial, operation)
    local arr, n = self:____array()
    local acc = initial
    for i = 1, n do
        acc = operation(i - 1, acc, arr[i])
    end
    return acc
end

function __K2L_Iterable:reduceIndexed(operation)
    local arr, n = self:____array()
    if n == 0 then
        error(__K2L_UnsupportedOperationException.new("Empty collection can't be reduced."))
    end
    local acc = arr[1]
    for i = 2, n do
        acc = operation(i - 1, acc, arr[i])
    end
    return acc
end

function __K2L_Iterable:runningFold(initial, operation)
    local arr, n = self:____array()
    local out = {initial}
    local acc = initial
    for i = 1, n do
        acc = operation(acc, arr[i])
        out[i + 1] = acc
    end
    return newList(out, n + 1)
end

__K2L_Iterable.scan = __K2L_Iterable.runningFold

function __K2L_Iterable:runningReduce(operation)
    local arr, n = self:____array()
    if n == 0 then
        return newList({}, 0)
    end
    local out = {arr[1]}
    local acc = arr[1]
    for i = 2, n do
        acc = operation(acc, arr[i])
        out[i] = acc
    end
    return newList(out, n)
end

local function extremeWith(self, comparator, sign, orNull)
    local arr, n = self:____array()
    if n == 0 then
        if orNull then
            return nil
        end
        error(__K2L_NoSuchElementException.new())
    end
    local best = arr[1]
    for i = 2, n do
        if comparator(arr[i], best) * sign > 0 then
            best = arr[i]
        end
    end
    return best
end

function __K2L_Iterable:maxWith(comparator) return extremeWith(self, comparator, 1, false) end
function __K2L_Iterable:minWith(comparator) return extremeWith(self, comparator, -1, false) end
function __K2L_Iterable:maxWithOrNull(comparator) return extremeWith(self, comparator, 1, true) end
function __K2L_Iterable:minWithOrNull(comparator) return extremeWith(self, comparator, -1, true) end

function __K2L_Iterable:takeLastWhile(predicate)
    local arr, n = self:____array()
    local from = n + 1
    while from > 1 and predicate(arr[from - 1]) do
        from = from - 1
    end
    return self:drop(from - 1)
end

function __K2L_Iterable:dropLastWhile(predicate)
    local arr, n = self:____array()
    local last = n
    while last > 0 and predicate(arr[last]) do
        last = last - 1
    end
    return self:take(last)
end

function __K2L_Iterable:mapIndexedNotNull(transform)
    local arr, n = self:____array()
    local out, k = {}, 0
    for i = 1, n do
        local value = transform(i - 1, arr[i])
        if value ~= nil then
            k = k + 1
            out[k] = value
        end
    end
    return newList(out, k)
end

function __K2L_Iterable:flatMapIndexed(transform)
    local arr, n = self:____array()
    local out, k = {}, 0
    for i = 1, n do
        local inner, m = transform(i - 1, arr[i]):____array()
        for j = 1, m do
            k = k + 1
            out[k] = inner[j]
        end
    end
    return newList(out, k)
end

function __K2L_Iterable:mapIndexedTo(destination, transform)
    local arr, n = self:____array()
    for i = 1, n do
        destination:add(transform(i - 1, arr[i]))
    end
    return destination
end

function __K2L_Iterable:mapTo(destination, transform)
    local arr, n = self:____array()
    for i = 1, n do
        destination:add(transform(arr[i]))
    end
    return destination
end

function __K2L_Iterable:filterTo(destination, predicate)
    local arr, n = self:____array()
    for i = 1, n do
        if predicate(arr[i]) then
            destination:add(arr[i])
        end
    end
    return destination
end

function __K2L_Iterable:toCollection(destination)
    local arr, n = self:____array()
    for i = 1, n do
        destination:add(arr[i])
    end
    return destination
end

function __K2L_Iterable:associateByTo(destination, keySelector, valueTransform)
    local arr, n = self:____array()
    for i = 1, n do
        local value = arr[i]
        if valueTransform ~= nil then
            value = valueTransform(arr[i])
        end
        destination:put(keySelector(arr[i]), value)
    end
    return destination
end

function __K2L_Iterable:associateWithTo(destination, valueSelector)
    local arr, n = self:____array()
    for i = 1, n do
        destination:put(arr[i], valueSelector(arr[i]))
    end
    return destination
end

__K2L_Iterable.elementAtOrNull = __K2L_Iterable.getOrNull
__K2L_Iterable.elementAtOrElse = __K2L_Iterable.getOrElse

function __K2L_Iterable:firstNotNullOfOrNull(transform)
    local arr, n = self:____array()
    for i = 1, n do
        local value = transform(arr[i])
        if value ~= nil then
            return value
        end
    end
    return nil
end

function __K2L_Iterable:firstNotNullOf(transform)
    local value = self:firstNotNullOfOrNull(transform)
    if value == nil then
        noSuchElement("No element of the collection was transformed to a non-null value.")
    end
    return value
end

function __K2L_Iterable:ifEmpty(default)
    if self:isEmpty() then
        return default()
    end
    return self
end

function __K2L_Iterable:slice(indices)
    local arr, n = self:____array()
    local idx, m = indices:____array()
    local out = {}
    for i = 1, m do
        if idx[i] < 0 or idx[i] >= n then
            error(__K2L_IndexOutOfBoundsException.new("Index " .. idx[i] .. " out of bounds for length " .. n))
        end
        out[i] = arr[idx[i] + 1]
    end
    return newList(out, m)
end

-- `random` is a kotlin.random.Random (the compiler passes Random.Default when the call has none).
function __K2L_Iterable:random(random)
    local arr, n = self:____array()
    if n == 0 then
        noSuchElement("Collection is empty.")
    end
    return arr[random:nextInt(n) + 1]
end

function __K2L_Iterable:randomOrNull(random)
    local arr, n = self:____array()
    if n == 0 then
        return nil
    end
    return arr[random:nextInt(n) + 1]
end

function __K2L_Iterable:shuffled(random)
    local out = self:toList()
    out:shuffle(random)
    return out
end

function __K2L_Iterable:requireNoNulls()
    local arr, n = self:____array()
    for i = 1, n do
        if arr[i] == nil then
            illegalArgument("null element found in " .. self:toString() .. ".")
        end
    end
    return self
end

function __K2L_Iterable:asReversed()
    return self:reversed()
end

function __K2L_Iterable:asList()
    return self:toList()
end

-- Index of `element` in the sorted list, or -(insertion point) - 1.
function __K2L_Iterable:binarySearch(element, comparatorOrFrom, from, to)
    local arr, n = self:____array()
    local comparator = __K2L_Compare
    if type(comparatorOrFrom) == "function" then
        comparator = comparatorOrFrom
    else
        to, from = from, comparatorOrFrom
    end
    local low, high = from or 0, (to or n) - 1
    if low < 0 or high >= n then
        error(__K2L_IndexOutOfBoundsException.new("fromIndex: " .. low .. ", toIndex: " .. (high + 1) .. ", size: " .. n))
    end
    while low <= high do
        local mid = math.floor((low + high) / 2)
        local c = comparator(arr[mid + 1], element)
        if c < 0 then
            low = mid + 1
        elseif c > 0 then
            high = mid - 1
        else
            return mid
        end
    end
    return -(low + 1)
end

function __K2L_Iterable:binarySearchBy(key, selector)
    local arr, n = self:____array()
    local low, high = 0, n - 1
    while low <= high do
        local mid = math.floor((low + high) / 2)
        local c = __K2L_Compare(selector(arr[mid + 1]), key)
        if c < 0 then
            low = mid + 1
        elseif c > 0 then
            high = mid - 1
        else
            return mid
        end
    end
    return -(low + 1)
end

function __K2L_Iterable:sortedArray()
    local out = self:sorted()
    return setmetatable(out, __K2L_Array)
end

function __K2L_Iterable:sortedArrayDescending()
    return setmetatable(self:sortedDescending(), __K2L_Array)
end

function __K2L_Iterable:reversedArray()
    return setmetatable(self:reversed(), __K2L_Array)
end

function __K2L_Iterable:copyOfRange(from, to)
    local arr, n = self:____array()
    if from > to then
        illegalArgument("fromIndex (" .. from .. ") > toIndex (" .. to .. ")")
    elseif from < 0 or from > n then
        error(__K2L_IndexOutOfBoundsException.new("fromIndex: " .. from .. ", toIndex: " .. to .. ", size: " .. n))
    end
    local out = {}
    for i = from + 1, to do
        out[i - from] = arr[i]
    end
    out.size = to - from
    return setmetatable(out, __K2L_Array)
end

-- Array.copyOf(newSize): `pad` is the element type's zero value (null for object arrays).
function __K2L_Iterable:copyOfSize(newSize, pad)
    local arr, n = self:____array()
    local out = {}
    for i = 1, newSize do
        if i <= n then
            out[i] = arr[i]
        else
            out[i] = pad
        end
    end
    out.size = newSize
    return setmetatable(out, __K2L_Array)
end

function __K2L_Iterable:copyInto(destination, destinationOffset, startIndex, endIndex)
    local arr, n = self:____array()
    destinationOffset = destinationOffset or 0
    startIndex = startIndex or 0
    endIndex = endIndex or n
    if destinationOffset < 0 or startIndex < 0 or endIndex > n or destinationOffset + endIndex - startIndex > destination.size then
        error(__K2L_IndexOutOfBoundsException.new("The destination range is out of bounds"))
    end
    for i = startIndex, endIndex - 1 do
        destination[destinationOffset + i - startIndex + 1] = arr[i + 1]
    end
    return destination
end

------------------------------------------------------------------ Grouping
local __K2L_Grouping = __K2L_Class("kotlin.collections.Grouping")

function __K2L_Grouping:____init(source, keySelector)
    self.source = source
    self.keySelector = keySelector
end

function __K2L_Grouping:eachCount()
    local arr, n = self.source:____array()
    local counts = __K2L_Map.new()
    for i = 1, n do
        local key = self.keySelector(arr[i])
        counts:put(key, (counts:get(key) or 0) + 1)
    end
    return counts
end

-- fold(initialValue, operation(accumulator, element))
function __K2L_Grouping:fold(initial, operation)
    local arr, n = self.source:____array()
    local result = __K2L_Map.new()
    for i = 1, n do
        local key = self.keySelector(arr[i])
        local acc = initial
        if result:containsKey(key) then
            acc = result:get(key)
        end
        result:put(key, operation(acc, arr[i]))
    end
    return result
end

-- reduce(operation(key, accumulator, element))
function __K2L_Grouping:reduce(operation)
    local arr, n = self.source:____array()
    local result = __K2L_Map.new()
    for i = 1, n do
        local key = self.keySelector(arr[i])
        if result:containsKey(key) then
            result:put(key, operation(key, result:get(key), arr[i]))
        else
            result:put(key, arr[i])
        end
    end
    return result
end

-- aggregate(operation(key, accumulator, element, isFirst))
function __K2L_Grouping:aggregate(operation)
    local arr, n = self.source:____array()
    local result = __K2L_Map.new()
    for i = 1, n do
        local key = self.keySelector(arr[i])
        local first = not result:containsKey(key)
        result:put(key, operation(key, result:get(key), arr[i], first))
    end
    return result
end

function __K2L_Iterable:groupingBy(keySelector)
    return __K2L_Grouping.new(self, keySelector)
end

------------------------------------------------------------------ Iterator
local __K2L_CollectionIterator = __K2L_Class("java.util.Iterator")

-- Iterates over a snapshot, so remove() can change the source while iterating.
function __K2L_CollectionIterator:____init(source)
    self.____source = source
    local items, count = source:____array()
    local copy = {}
    for i = 1, count do
        copy[i] = items[i]
    end
    self.____items, self.____count = copy, count
    self.____position = 0
    self.____removed = 0
end

function __K2L_CollectionIterator:hasNext()
    return self.____position < self.____count
end

function __K2L_CollectionIterator:next()
    if self.____position >= self.____count then
        noSuchElement()
    end
    self.____position = self.____position + 1
    return self.____items[self.____position]
end

-- Removes the element last returned by next() from the source.
function __K2L_CollectionIterator:remove()
    local source = self.____source
    if self.____position == 0 then
        error(__K2L_IllegalStateException.new())
    end
    if source.removeAt ~= nil then
        source:removeAt(self.____position - 1 - self.____removed)
    else
        source:remove(self.____items[self.____position])
    end
    self.____removed = self.____removed + 1
end

function __K2L_Iterable:iterator()
    return __K2L_CollectionIterator.new(self)
end

------------------------------------------------------------------ List
__K2L_List = __K2L_Class("java.util.ArrayList", __K2L_Iterable)

function __K2L_List:____init()
    self.size = 0
end

function __K2L_List:____array()
    return self, self.size
end

function __K2L_List:toString()
    local parts = {}
    for i = 1, self.size do
        parts[i] = __K2L_Str(self[i])
    end
    return "[" .. table.concat(parts, ", ") .. "]"
end

function __K2L_List:equals(other)
    if not (type(other) == "table" and other.____array ~= nil and other.get ~= nil) then
        return false
    end
    local arr, n = other:____array()
    if n ~= self.size then
        return false
    end
    for i = 1, n do
        if not __K2L_Equals(self[i], arr[i]) then
            return false
        end
    end
    return true
end

function __K2L_List:get(index)
    if index < 0 or index >= self.size then
        error(__K2L_IndexOutOfBoundsException.new("Index " .. index .. " out of bounds for length " .. self.size))
    end
    return self[index + 1]
end

function __K2L_List:set(index, value)
    local old = self:get(index)
    self[index + 1] = value
    if self.____parent ~= nil then
        self.____parent[self.____offset + index + 1] = value
    end
    return old
end

function __K2L_List:add(value)
    self.size = self.size + 1
    self[self.size] = value
    return true
end

function __K2L_List:addAt(index, value)
    if index < 0 or index > self.size then
        error(__K2L_IndexOutOfBoundsException.new("Index: " .. index .. ", Size: " .. self.size))
    end
    for i = self.size, index + 1, -1 do
        self[i + 1] = self[i]
    end
    self[index + 1] = value
    self.size = self.size + 1
end

function __K2L_List:addAll(elements)
    local arr, n = elements:____array()
    for i = 1, n do
        self:add(arr[i])
    end
    return n > 0
end

function __K2L_List:addAllAt(index, elements)
    local arr, n = elements:____array()
    if index < 0 or index > self.size then
        error(__K2L_IndexOutOfBoundsException.new("Index: " .. index .. ", Size: " .. self.size))
    end
    local copy = {}
    for i = 1, n do
        copy[i] = arr[i]
    end
    for i = 1, n do
        self:addAt(index + i - 1, copy[i])
    end
    return n > 0
end

function __K2L_List:removeAt(index)
    local value = self:get(index)
    if self.____ownerRemove ~= nil then
        self.____ownerRemove(self.____owner, value)
    end
    if self.____parent ~= nil then
        self.____parent:removeAt(self.____offset + index)
        self.____parent = nil
    end
    for i = index + 1, self.size - 1 do
        self[i] = self[i + 1]
    end
    self[self.size] = nil
    self.size = self.size - 1
    return value
end

function __K2L_List:remove(value)
    local index = self:indexOf(value)
    if index < 0 then
        return false
    end
    self:removeAt(index)
    return true
end

function __K2L_List:removeFirst()
    if self.size == 0 then
        noSuchElement("List is empty.")
    end
    return self:removeAt(0)
end

function __K2L_List:removeLast()
    if self.size == 0 then
        noSuchElement("List is empty.")
    end
    return self:removeAt(self.size - 1)
end

function __K2L_List:removeAll(predicate)
    if type(predicate) == "table" then
        local elements = predicate
        predicate = function(it) return elements:contains(it) end
    end
    local k = 0
    local n = self.size
    for i = 1, n do
        local v = self[i]
        if not predicate(v) then
            k = k + 1
            self[k] = v
        elseif self.____ownerRemove ~= nil then
            self.____ownerRemove(self.____owner, v)
        end
    end
    for i = k + 1, n do
        self[i] = nil
    end
    self.size = k
    return k ~= n
end

__K2L_List.removeIf = __K2L_List.removeAll

function __K2L_List:retainAll(predicate)
    if type(predicate) == "table" then
        local elements = predicate
        return self:removeAll(function(it) return not elements:contains(it) end)
    end
    return self:removeAll(function(it) return not predicate(it) end)
end

function __K2L_List:clear()
    local parent = self.____parent
    if parent ~= nil then
        for _ = 1, self.size do
            parent:removeAt(self.____offset)
        end
    end
    if self.____ownerRemove ~= nil then
        for i = 1, self.size do
            self.____ownerRemove(self.____owner, self[i])
        end
    end
    for i = 1, self.size do
        self[i] = nil
    end
    self.size = 0
end

local function sortInPlace(self, sorted)
    for i = 1, self.size do
        self[i] = sorted[i]
        if self.____parent ~= nil then
            self.____parent[self.____offset + i] = sorted[i]
        end
    end
end

function __K2L_List:sort() sortInPlace(self, self:sorted()) end
function __K2L_List:sortDescending() sortInPlace(self, self:sortedDescending()) end
function __K2L_List:sortBy(selector) sortInPlace(self, self:sortedBy(selector)) end
function __K2L_List:sortByDescending(selector) sortInPlace(self, self:sortedByDescending(selector)) end
function __K2L_List:sortWith(comparator) sortInPlace(self, self:sortedWith(comparator)) end
function __K2L_List:reverse() sortInPlace(self, self:reversed()) end

function __K2L_List:fill(value, from, to)
    for i = (from or 0) + 1, to or self.size do
        self[i] = value
    end
end

-- A copy that writes set(), clear(), sort and fill back to the list it came from.
function __K2L_List:subList(from, to)
    if from < 0 then
        error(__K2L_IndexOutOfBoundsException.new("fromIndex = " .. from))
    elseif to > self.size then
        error(__K2L_IndexOutOfBoundsException.new("toIndex = " .. to))
    elseif from > to then
        illegalArgument("fromIndex(" .. from .. ") > toIndex(" .. to .. ")")
    end
    local out = {}
    for i = from + 1, to do
        out[i - from] = self[i]
    end
    local list = newList(out, to - from)
    list.____parent, list.____offset = self, from
    return list
end

function __K2L_List:getLastIndex()
    return self.size - 1
end

function __K2L_List:addFirst(value)
    self:addAt(0, value)
end

function __K2L_List:addLast(value)
    self:add(value)
end

function __K2L_List:removeFirstOrNull()
    if self.size == 0 then
        return nil
    end
    return self:removeAt(0)
end

function __K2L_List:removeLastOrNull()
    if self.size == 0 then
        return nil
    end
    return self:removeAt(self.size - 1)
end

function __K2L_List:replaceAll(operator)
    for i = 1, self.size do
        self[i] = operator(self[i])
    end
end

-- Fisher-Yates from the end, as kotlin.collections.shuffle(random) does.
function __K2L_List:shuffle(random)
    for i = self.size - 1, 1, -1 do
        local j = random:nextInt(i + 1)
        self[i + 1], self[j + 1] = self[j + 1], self[i + 1]
    end
end

-- Queue and Deque methods of java.util.LinkedList and ArrayDeque
__K2L_List.offer = __K2L_List.add
__K2L_List.offerLast = __K2L_List.add
__K2L_List.offerFirst = function(self, value) self:addAt(0, value) return true end
__K2L_List.poll = __K2L_List.removeFirstOrNull
__K2L_List.pollFirst = __K2L_List.removeFirstOrNull
__K2L_List.pollLast = __K2L_List.removeLastOrNull
__K2L_List.peek = function(self) return self[1] end
__K2L_List.peekFirst = __K2L_List.peek
__K2L_List.peekLast = function(self) return self[self.size] end
__K2L_List.push = __K2L_List.addFirst
__K2L_List.pop = __K2L_List.removeFirst

-- Arrays share the list representation but compare by identity, as on the JVM.
__K2L_Array = __K2L_Class("Array", __K2L_List)

function __K2L_Array:equals(other)
    return rawequal(self, other)
end

__K2L_Array.contentEquals = __K2L_List.equals
__K2L_Array.contentToString = __K2L_List.toString
__K2L_Array.contentHashCode = __K2L_Iterable.hashCode

local function __K2L_ListOf(...)
    return newList({...}, select("#", ...))
end

local function __K2L_ArrayOf(...)
    local arr = {...}
    arr.size = select("#", ...)
    return setmetatable(arr, __K2L_Array)
end

-- List(n) { init(it) } and Array(n) { ... }; also IntArray(n) with a constant initial value.
local function __K2L_ListOfSize(size, init, array)
    local out = {}
    for i = 1, size do
        if type(init) == "function" then
            out[i] = init(i - 1)
        else
            out[i] = init
        end
    end
    out.size = size
    return setmetatable(out, array and __K2L_Array or __K2L_List)
end

------------------------------------------------------------------ hashed keys (Map and Set)
local NIL_KEY = {}

-- Finds the slot of `key`: raw lookup for plain values, hashCode buckets plus equals() for objects.
local function findSlot(self, key)
    if type(key) == "table" and key.hashCode ~= nil then
        local bucket = self.____buckets[key:hashCode()]
        if bucket ~= nil then
            for _, slot in ipairs(bucket) do
                if __K2L_Equals(self.____keys[slot], key) then
                    return slot
                end
            end
        end
        return nil
    end
    return self.____index[key == nil and NIL_KEY or key]
end

local function addSlot(self, key)
    local slot = self.size + 1
    self.size = slot
    self.____keys[slot] = key
    if type(key) == "table" and key.hashCode ~= nil then
        local h = key:hashCode()
        local bucket = self.____buckets[h]
        if bucket == nil then
            bucket = {}
            self.____buckets[h] = bucket
        end
        bucket[#bucket + 1] = slot
    else
        self.____index[key == nil and NIL_KEY or key] = slot
    end
    return slot
end

local function reindex(self)
    self.____index, self.____buckets = {}, {}
    local keys, values, n = self.____keys, self.____values, self.size
    self.size = 0
    self.____keys = {}
    for i = 1, n do
        addSlot(self, keys[i])
    end
    self.____values = values
end

local function removeSlot(self, slot)
    local n = self.size
    local keys, values = self.____keys, self.____values
    for i = slot, n - 1 do
        keys[i] = keys[i + 1]
        if values ~= nil then
            values[i] = values[i + 1]
        end
    end
    keys[n] = nil
    if values ~= nil then
        values[n] = nil
    end
    self.size = n - 1
    reindex(self)
end

------------------------------------------------------------------ Set
__K2L_Set = __K2L_Class("java.util.LinkedHashSet", __K2L_Iterable)

function __K2L_Set:____init()
    self.size = 0
    self.____keys, self.____index, self.____buckets = {}, {}, {}
end

function __K2L_Set:____array()
    return self.____keys, self.size
end

function __K2L_Set:contains(value)
    return findSlot(self, value) ~= nil
end

function __K2L_Set:add(value)
    if findSlot(self, value) ~= nil then
        return false
    end
    addSlot(self, value)
    return true
end

function __K2L_Set:addAll(elements)
    local arr, n = elements:____array()
    local changed = false
    for i = 1, n do
        changed = self:add(arr[i]) or changed
    end
    return changed
end

function __K2L_Set:remove(value)
    local slot = findSlot(self, value)
    if slot == nil then
        return false
    end
    removeSlot(self, slot)
    if self.____ownerRemove ~= nil then
        self.____ownerRemove(self.____owner, value)
    end
    return true
end

-- Removes the elements matching `predicate`, or contained in a collection.
function __K2L_Set:removeAll(elements)
    local predicate = elements
    if type(elements) ~= "function" then
        predicate = function(it) return elements:contains(it) end
    end
    local keys, n = self.____keys, self.size
    local kept, k = {}, 0
    for i = 1, n do
        if predicate(keys[i]) then
            if self.____ownerRemove ~= nil then
                self.____ownerRemove(self.____owner, keys[i])
            end
        else
            k = k + 1
            kept[k] = keys[i]
        end
    end
    if k == n then
        return false
    end
    __K2L_Set.____init(self)
    for i = 1, k do
        addSlot(self, kept[i])
    end
    return true
end

__K2L_Set.removeIf = __K2L_Set.removeAll

function __K2L_Set:retainAll(elements)
    if type(elements) == "function" then
        local predicate = elements
        return self:removeAll(function(it) return not predicate(it) end)
    end
    return self:removeAll(function(it) return not elements:contains(it) end)
end

function __K2L_Set:clear()
    if self.____ownerRemove ~= nil then
        for i = 1, self.size do
            self.____ownerRemove(self.____owner, self.____keys[i])
        end
    end
    __K2L_Set.____init(self)
end

function __K2L_Set:toString()
    return __K2L_List.toString(newList(self.____keys, self.size))
end

function __K2L_Set:equals(other)
    if not inherits(other, __K2L_Set) or other.size ~= self.size then
        return false
    end
    for i = 1, self.size do
        if not other:contains(self.____keys[i]) then
            return false
        end
    end
    return true
end

function __K2L_Set:hashCode()
    local h = 0
    for i = 1, self.size do
        h = __K2L_ToInt32(h + __K2L_Hash(self.____keys[i]))
    end
    return h
end

function __K2L_Set:plus(element)
    local out = self:toSet()
    out:add(element)
    return out
end

function __K2L_Set:plusAll(elements)
    local out = self:toSet()
    out:addAll(elements)
    return out
end

function __K2L_Set:minus(element)
    local out = self:toSet()
    out:remove(element)
    return out
end

function __K2L_Set:minusAll(elements)
    return self:filter(function(it) return not elements:contains(it) end):toSet()
end

local function __K2L_SetOf(...)
    local set = __K2L_Set.new()
    for i = 1, select("#", ...) do
        set:add((select(i, ...)))
    end
    return set
end

------------------------------------------------------------------ Map
local __K2L_Entry = __K2L_Class("java.util.Map.Entry")

function __K2L_Entry:____init(key, value)
    self.key = key
    self.value = value
end

function __K2L_Entry:toString()
    return __K2L_Str(self.key) .. "=" .. __K2L_Str(self.value)
end

-- Entries of a map write back to it.
function __K2L_Entry:setValue(value)
    local old = self.value
    self.value = value
    if self.____map ~= nil then
        self.____map:put(self.key, value)
    end
    return old
end

function __K2L_Entry:hashCode()
    return __K2L_BXor(__K2L_Hash(self.key), __K2L_Hash(self.value))
end

function __K2L_Entry:equals(other)
    return getmetatable(other) == __K2L_Entry and __K2L_Equals(self.key, other.key) and __K2L_Equals(self.value, other.value)
end

__K2L_Map = __K2L_Class("java.util.LinkedHashMap")
__K2L_Map.__tostring = __K2L_Iterable.__tostring

function __K2L_Map:____init()
    self.size = 0
    self.____keys, self.____values, self.____index, self.____buckets = {}, {}, {}, {}
end

-- for k, v in map:iter() do ... end
function __K2L_Map:iter()
    local i = 0
    return function()
        i = i + 1
        if i <= self.size then
            return self.____keys[i], self.____values[i]
        end
    end
end

function __K2L_Map:get(key)
    local slot = findSlot(self, key)
    return slot and self.____values[slot]
end

function __K2L_Map:getOrDefault(key, default)
    local slot = findSlot(self, key)
    if slot == nil then
        return default
    end
    return self.____values[slot]
end

function __K2L_Map:getOrElse(key, default)
    local slot = findSlot(self, key)
    if slot == nil then
        return default()
    end
    return self.____values[slot]
end

function __K2L_Map:getValue(key)
    local slot = findSlot(self, key)
    if slot == nil then
        noSuchElement("Key " .. __K2L_Str(key) .. " is missing in the map.")
    end
    return self.____values[slot]
end

function __K2L_Map:getOrPut(key, default)
    local slot = findSlot(self, key)
    if slot ~= nil then
        return self.____values[slot]
    end
    local value = default()
    self:put(key, value)
    return value
end

function __K2L_Map:containsKey(key)
    return findSlot(self, key) ~= nil
end

function __K2L_Map:containsValue(value)
    for i = 1, self.size do
        if __K2L_Equals(self.____values[i], value) then
            return true
        end
    end
    return false
end

function __K2L_Map:put(key, value)
    local slot = findSlot(self, key)
    if slot ~= nil then
        local old = self.____values[slot]
        self.____values[slot] = value
        return old
    end
    slot = addSlot(self, key)
    self.____values[slot] = value
    return nil
end

function __K2L_Map:set(key, value)
    self:put(key, value)
end

-- Accepts another map or a list of pairs.
function __K2L_Map:putAll(other)
    if other.iter == nil then
        local arr, n = other:____array()
        for i = 1, n do
            self:put(arr[i].first, arr[i].second)
        end
        return
    end
    for k, v in other:iter() do
        self:put(k, v)
    end
end

function __K2L_Map:remove(key, value)
    local slot = findSlot(self, key)
    if slot == nil then
        if value ~= nil then
            return false
        end
        return nil
    end
    local old = self.____values[slot]
    if value ~= nil then
        if not __K2L_Equals(old, value) then
            return false
        end
        removeSlot(self, slot)
        return true
    end
    removeSlot(self, slot)
    return old
end

function __K2L_Map:putIfAbsent(key, value)
    local old = self:get(key)
    if old == nil then
        self:put(key, value)
    end
    return old
end

function __K2L_Map:merge(key, value, remapping)
    local old = self:get(key)
    local result = value
    if old ~= nil then
        result = remapping(old, value)
    end
    if result == nil then
        self:remove(key)
    else
        self:put(key, result)
    end
    return result
end

function __K2L_Map:compute(key, remapping)
    local result = remapping(key, self:get(key))
    if result == nil then
        self:remove(key)
    else
        self:put(key, result)
    end
    return result
end

function __K2L_Map:computeIfAbsent(key, mapping)
    local old = self:get(key)
    if old == nil then
        old = mapping(key)
        if old ~= nil then
            self:put(key, old)
        end
    end
    return old
end

function __K2L_Map:computeIfPresent(key, remapping)
    local old = self:get(key)
    if old == nil then
        return nil
    end
    local result = remapping(key, old)
    if result == nil then
        self:remove(key)
    else
        self:put(key, result)
    end
    return result
end

function __K2L_Map:replaceAll(operator)
    for i = 1, self.size do
        self.____values[i] = operator(self.____keys[i], self.____values[i])
    end
end

function __K2L_Map:onEach(action)
    self:forEach(action)
    return self
end

function __K2L_Map:filterNot(predicate)
    return self:filter(function(e) return not predicate(e) end)
end

function __K2L_Map:mapValuesTo(destination, transform)
    for i = 1, self.size do
        destination:put(self.____keys[i], transform(__K2L_Entry.new(self.____keys[i], self.____values[i])))
    end
    return destination
end

function __K2L_Map:mapKeysTo(destination, transform)
    for i = 1, self.size do
        destination:put(transform(__K2L_Entry.new(self.____keys[i], self.____values[i])), self.____values[i])
    end
    return destination
end

function __K2L_Map:orEmpty()
    return self
end

function __K2L_Map:clear()
    __K2L_Map.____init(self)
end

function __K2L_Map:isEmpty()
    return self.size == 0
end

function __K2L_Map:isNotEmpty()
    return self.size > 0
end

-- keys, values and entries are copies that remove from the map when elements are removed from them.
local function removeKey(map, key)
    map:remove(key)
end

local function removeValue(map, value)
    for i = 1, map.size do
        if __K2L_Equals(map.____values[i], value) then
            map:remove(map.____keys[i])
            return
        end
    end
end

local function removeEntry(map, entry)
    map:remove(entry.key)
end

function __K2L_Map:getKeys()
    local set = __K2L_Set.new()
    for i = 1, self.size do
        set:add(self.____keys[i])
    end
    set.____owner, set.____ownerRemove = self, removeKey
    return set
end

function __K2L_Map:getValues()
    local out = {}
    for i = 1, self.size do
        out[i] = self.____values[i]
    end
    local list = newList(out, self.size)
    list.____owner, list.____ownerRemove = self, removeValue
    return list
end

function __K2L_Map:getEntries()
    local out = {}
    for i = 1, self.size do
        local entry = __K2L_Entry.new(self.____keys[i], self.____values[i])
        entry.____map = self
        out[i] = entry
    end
    local list = newList(out, self.size)
    list.____owner, list.____ownerRemove = self, removeEntry
    return list
end

function __K2L_Map:iterator()
    return self:getEntries():iterator()
end

function __K2L_Map:asIterable()
    return self:getEntries()
end

function __K2L_Map:toString()
    local parts = {}
    for i = 1, self.size do
        parts[i] = __K2L_Str(self.____keys[i]) .. "=" .. __K2L_Str(self.____values[i])
    end
    return "{" .. table.concat(parts, ", ") .. "}"
end

function __K2L_Map:equals(other)
    if not inherits(other, __K2L_Map) or other.size ~= self.size then
        return false
    end
    for i = 1, self.size do
        local key = self.____keys[i]
        if not other:containsKey(key) or not __K2L_Equals(other:get(key), self.____values[i]) then
            return false
        end
    end
    return true
end

function __K2L_Map:hashCode()
    local h = 0
    for i = 1, self.size do
        h = __K2L_ToInt32(h + __K2L_BXor(__K2L_Hash(self.____keys[i]), __K2L_Hash(self.____values[i])))
    end
    return h
end

-- Operations taking an entry lambda receive the entry; `forEach { k, v -> }` gets both.
function __K2L_Map:forEach(action)
    for i = 1, self.size do
        action(__K2L_Entry.new(self.____keys[i], self.____values[i]))
    end
end

function __K2L_Map:forEachKeyValue(action)
    for i = 1, self.size do
        action(self.____keys[i], self.____values[i])
    end
end

function __K2L_Map:map(transform)
    return self:getEntries():map(transform)
end

function __K2L_Map:mapNotNull(transform)
    return self:getEntries():mapNotNull(transform)
end

function __K2L_Map:flatMap(transform)
    return self:getEntries():flatMap(transform)
end

function __K2L_Map:any(predicate)
    return self:getEntries():any(predicate)
end

function __K2L_Map:all(predicate)
    return self:getEntries():all(predicate)
end

function __K2L_Map:none(predicate)
    return self:getEntries():none(predicate)
end

function __K2L_Map:count(predicate)
    return self:getEntries():count(predicate)
end

function __K2L_Map:maxByOrNull(selector)
    return self:getEntries():maxByOrNull(selector)
end

function __K2L_Map:minByOrNull(selector)
    return self:getEntries():minByOrNull(selector)
end

function __K2L_Map:filterTo(destination, predicate)
    for i = 1, self.size do
        local k, v = self.____keys[i], self.____values[i]
        if predicate(__K2L_Entry.new(k, v)) then
            destination:put(k, v)
        end
    end
    return destination
end

function __K2L_Map:ifEmpty(default)
    if self.size == 0 then
        return default()
    end
    return self
end

function __K2L_Map:filter(predicate)
    local out = __K2L_Map.new()
    for i = 1, self.size do
        local k, v = self.____keys[i], self.____values[i]
        if predicate(__K2L_Entry.new(k, v)) then
            out:put(k, v)
        end
    end
    return out
end

function __K2L_Map:filterKeys(predicate)
    return self:filter(function(e) return predicate(e.key) end)
end

function __K2L_Map:filterValues(predicate)
    return self:filter(function(e) return predicate(e.value) end)
end

function __K2L_Map:mapValues(transform)
    local out = __K2L_Map.new()
    for i = 1, self.size do
        out:put(self.____keys[i], transform(__K2L_Entry.new(self.____keys[i], self.____values[i])))
    end
    return out
end

function __K2L_Map:mapKeys(transform)
    local out = __K2L_Map.new()
    for i = 1, self.size do
        out:put(transform(__K2L_Entry.new(self.____keys[i], self.____values[i])), self.____values[i])
    end
    return out
end

function __K2L_Map:toList()
    local out = {}
    for i = 1, self.size do
        out[i] = __K2L_Pair.new(self.____keys[i], self.____values[i])
    end
    return newList(out, self.size)
end

function __K2L_Map:toMap()
    local out = __K2L_Map.new()
    out:putAll(self)
    return out
end

__K2L_Map.toMutableMap = __K2L_Map.toMap

function __K2L_Map:plus(pair)
    local out = self:toMap()
    if getmetatable(pair) == __K2L_Pair then
        out:put(pair.first, pair.second)
    else
        out:putAll(pair)
    end
    return out
end

function __K2L_Map:minus(key)
    local out = self:toMap()
    out:remove(key)
    return out
end

-- map - keys
function __K2L_Map:minusAll(keys)
    local out = self:toMap()
    local arr, n = keys:____array()
    for i = 1, n do
        out:remove(arr[i])
    end
    return out
end

local function __K2L_MapOf(...)
    local map = __K2L_Map.new()
    for i = 1, select("#", ...) do
        local pair = select(i, ...)
        map:put(pair.first, pair.second)
    end
    return map
end

------------------------------------------------------------------ ranges
__K2L_IntRange = __K2L_Class("kotlin.ranges.IntRange", __K2L_Iterable)

function __K2L_IntRange:____init(first, last, step)
    self.first = first
    self.last = last
    self.step = step or 1
end

function __K2L_IntRange:____array()
    local out, n = {}, 0
    for i = self.first, self.last, self.step do
        n = n + 1
        out[n] = i
    end
    return out, n
end

function __K2L_IntRange:contains(value)
    if self.step > 0 then
        return value >= self.first and value <= self.last and (value - self.first) % self.step == 0
    end
    return value <= self.first and value >= self.last and (self.first - value) % -self.step == 0
end

function __K2L_IntRange:isEmpty()
    return self.step > 0 and self.first > self.last or self.step < 0 and self.first < self.last
end

-- A progression's last element is the last one it reaches: (1..10 step 3).last is 10, (1..10 step 2).last is 9.
function __K2L_IntRange:withStep(step)
    step = self.step > 0 and step or -step
    local last = self.last
    if not self:isEmpty() then
        last = last - (last - self.first) % step
    end
    return __K2L_IntRange.new(self.first, last, step)
end

function __K2L_IntRange:reversed()
    return __K2L_IntRange.new(self.last, self.first, -self.step)
end

function __K2L_IntRange:toString()
    if self.step == 1 then
        return self.first .. ".." .. self.last
    elseif self.step > 0 then
        return self.first .. ".." .. self.last .. " step " .. self.step
    end
    return self.first .. " downTo " .. self.last .. " step " .. -self.step
end

function __K2L_IntRange:equals(other)
    return getmetatable(other) == __K2L_IntRange and (self:isEmpty() and other:isEmpty() or
        self.first == other.first and self.last == other.last and self.step == other.step)
end

-- 'a'..'e' keeps the endpoints as one-character strings.
local __K2L_CharRange = __K2L_Class("kotlin.ranges.CharRange", __K2L_Iterable)

function __K2L_CharRange:____init(first, last, step)
    self.first = first
    self.last = last
    self.step = step or 1
end

function __K2L_CharRange:____array()
    local out, n = {}, 0
    for code = self.first:byte(), self.last:byte(), self.step do
        n = n + 1
        out[n] = string.char(code)
    end
    return out, n
end

function __K2L_CharRange:contains(value)
    local code = value:byte()
    local first, last = self.first:byte(), self.last:byte()
    if self.step > 0 then
        return code >= first and code <= last and (code - first) % self.step == 0
    end
    return code <= first and code >= last and (first - code) % -self.step == 0
end

function __K2L_CharRange:isEmpty()
    local first, last = self.first:byte(), self.last:byte()
    return self.step > 0 and first > last or self.step < 0 and first < last
end

function __K2L_CharRange:withStep(step)
    return __K2L_CharRange.new(self.first, self.last, self.step > 0 and step or -step)
end

function __K2L_CharRange:reversed()
    return __K2L_CharRange.new(self.last, self.first, -self.step)
end

function __K2L_CharRange:toString()
    if self.step == 1 then
        return self.first .. ".." .. self.last
    elseif self.step > 0 then
        return self.first .. ".." .. self.last .. " step " .. self.step
    end
    return self.first .. " downTo " .. self.last .. " step " .. -self.step
end

function __K2L_CharRange:equals(other)
    return getmetatable(other) == __K2L_CharRange and (self:isEmpty() and other:isEmpty() or
        self.first == other.first and self.last == other.last and self.step == other.step)
end

-- A range of Doubles or other Comparables: not iterable, only a pair of bounds.
local __K2L_ClosedRange = __K2L_Class("kotlin.ranges.ClosedRange")

function __K2L_ClosedRange:____init(first, last)
    self.first = first
    self.last = last
end

function __K2L_ClosedRange:contains(value)
    return __K2L_Compare(value, self.first) >= 0 and __K2L_Compare(value, self.last) <= 0
end

function __K2L_ClosedRange:isEmpty()
    return __K2L_Compare(self.first, self.last) > 0
end

function __K2L_ClosedRange:toString()
    return __K2L_Str(self.first) .. ".." .. __K2L_Str(self.last)
end

function __K2L_ClosedRange:equals(other)
    return getmetatable(other) == __K2L_ClosedRange and (self:isEmpty() and other:isEmpty() or
        __K2L_Equals(self.first, other.first) and __K2L_Equals(self.last, other.last))
end

------------------------------------------------------------------ PriorityQueue
do
-- A binary heap laid out exactly like java.util.PriorityQueue, so iteration order matches.
end

local __K2L_PriorityQueue = __K2L_Class("java.util.PriorityQueue", __K2L_Iterable)

do
local siftDown

-- PriorityQueue(), (comparator) or (collection)
function __K2L_PriorityQueue:____init(comparatorOrElements)
    self.size = 0
    self.____heap = {}
    self.____compare = __K2L_Compare
    if type(comparatorOrElements) == "function" then
        self.____compare = comparatorOrElements
    elseif comparatorOrElements ~= nil then
        -- heapify, as PriorityQueue(Collection) does
        local arr, n = comparatorOrElements:____array()
        for i = 1, n do
            self.____heap[i] = arr[i]
        end
        self.size = n
        for i = math.floor(n / 2) - 1, 0, -1 do
            siftDown(self, i, self.____heap[i + 1])
        end
    end
end

function __K2L_PriorityQueue:____array()
    return self.____heap, self.size
end

local function siftUp(self, k, x)
    local heap, compare = self.____heap, self.____compare
    while k > 0 do
        local parent = math.floor((k - 1) / 2)
        local e = heap[parent + 1]
        if compare(x, e) >= 0 then
            break
        end
        heap[k + 1] = e
        k = parent
    end
    heap[k + 1] = x
end

function siftDown(self, k, x)
    local heap, compare, n = self.____heap, self.____compare, self.size
    local half = math.floor(n / 2)
    while k < half do
        local child = 2 * k + 1
        local c = heap[child + 1]
        local right = child + 1
        if right < n and compare(c, heap[right + 1]) > 0 then
            child = right
            c = heap[child + 1]
        end
        if compare(x, c) <= 0 then
            break
        end
        heap[k + 1] = c
        k = child
    end
    heap[k + 1] = x
end

function __K2L_PriorityQueue:add(element)
    if element == nil then
        error(__K2L_NullPointerException.new())
    end
    local k = self.size
    self.size = k + 1
    siftUp(self, k, element)
    return true
end

__K2L_PriorityQueue.offer = __K2L_PriorityQueue.add

function __K2L_PriorityQueue:addAll(elements)
    local arr, n = elements:____array()
    for i = 1, n do
        self:add(arr[i])
    end
    return n > 0
end

function __K2L_PriorityQueue:peek()
    return self.____heap[1]
end

function __K2L_PriorityQueue:element()
    if self.size == 0 then
        noSuchElement()
    end
    return self.____heap[1]
end

function __K2L_PriorityQueue:poll()
    local n = self.size
    if n == 0 then
        return nil
    end
    local heap = self.____heap
    local result = heap[1]
    n = n - 1
    self.size = n
    local x = heap[n + 1]
    heap[n + 1] = nil
    if n > 0 then
        siftDown(self, 0, x)
    end
    return result
end

local function removeIndex(self, i)
    local heap = self.____heap
    local s = self.size - 1
    self.size = s
    if s == i then
        heap[i + 1] = nil
    else
        local moved = heap[s + 1]
        heap[s + 1] = nil
        siftDown(self, i, moved)
        if heap[i + 1] == moved then
            siftUp(self, i, moved)
        end
    end
end

-- remove() takes the head; remove(element) removes one occurrence.
function __K2L_PriorityQueue:remove(...)
    if select("#", ...) == 0 then
        if self.size == 0 then
            noSuchElement()
        end
        return self:poll()
    end
    local i = self:indexOf((...))
    if i < 0 then
        return false
    end
    removeIndex(self, i)
    return true
end

function __K2L_PriorityQueue:removeAll(predicate)
    if type(predicate) ~= "function" then
        local elements = predicate
        predicate = function(it) return elements:contains(it) end
    end
    local kept = {}
    for i = 1, self.size do
        if not predicate(self.____heap[i]) then
            kept[#kept + 1] = self.____heap[i]
        end
    end
    local changed = #kept ~= self.size
    self:clear()
    for _, v in ipairs(kept) do
        self:add(v)
    end
    return changed
end

__K2L_PriorityQueue.removeIf = __K2L_PriorityQueue.removeAll

function __K2L_PriorityQueue:clear()
    self.____heap = {}
    self.size = 0
end

function __K2L_PriorityQueue:toString()
    local parts = {}
    for i = 1, self.size do
        parts[i] = __K2L_Str(self.____heap[i])
    end
    return "[" .. table.concat(parts, ", ") .. "]"
end

end

------------------------------------------------------------------ sorted collections
local __K2L_SortedMap
local __K2L_SortedSet
local __K2L_SortedMapOf
local __K2L_SortedSetOf

do

-- TreeMap and TreeSet keep their keys ordered by a comparator (natural order by default); inserting
-- is O(n), lookups use the same hash index as LinkedHashMap.

-- First index in the sorted array whose key is not less than `key` (1-based).
local function lowerBound(keys, n, key, compare)
    local low, high = 1, n + 1
    while low < high do
        local mid = math.floor((low + high) / 2)
        if compare(keys[mid], key) < 0 then
            low = mid + 1
        else
            high = mid
        end
    end
    return low
end

-- First index whose key is greater than `key`.
local function upperBound(keys, n, key, compare)
    local low, high = 1, n + 1
    while low < high do
        local mid = math.floor((low + high) / 2)
        if compare(keys[mid], key) <= 0 then
            low = mid + 1
        else
            high = mid
        end
    end
    return low
end

local function shiftRight(arr, n, at)
    for i = n, at, -1 do
        arr[i + 1] = arr[i]
    end
end

__K2L_SortedMap = __K2L_Class("java.util.TreeMap", __K2L_Map)

-- TreeMap(), TreeMap(comparator) or TreeMap(map)
function __K2L_SortedMap:____init(comparatorOrMap)
    __K2L_Map.____init(self)
    self.____compare = __K2L_Compare
    if type(comparatorOrMap) == "function" then
        self.____compare = comparatorOrMap
    elseif comparatorOrMap ~= nil then
        self:putAll(comparatorOrMap)
    end
end

-- Rebuilds the hash index over `keys` after an insertion; the values array is kept.
local function rebuild(self, keys, count)
    self.size, self.____keys, self.____index, self.____buckets = 0, {}, {}, {}
    for i = 1, count do
        addSlot(self, keys[i])
    end
end

function __K2L_SortedMap:put(key, value)
    local slot = findSlot(self, key)
    if slot ~= nil then
        local old = self.____values[slot]
        self.____values[slot] = value
        return old
    end
    local keys, values, n = self.____keys, self.____values, self.size
    local at = lowerBound(keys, n, key, self.____compare)
    shiftRight(keys, n, at)
    shiftRight(values, n, at)
    keys[at], values[at] = key, value
    rebuild(self, keys, n + 1)
    self.____values = values
    return nil
end

function __K2L_SortedMap:clear()
    local compare = self.____compare
    __K2L_Map.____init(self)
    self.____compare = compare
end

local function sortedCopy(self, keepFrom, keepTo)
    local out = __K2L_SortedMap.new(self.____compare)
    for i = keepFrom, keepTo do
        out:put(self.____keys[i], self.____values[i])
    end
    return out
end

local function entryAt(self, i)
    if i < 1 or i > self.size then
        return nil
    end
    local entry = __K2L_Entry.new(self.____keys[i], self.____values[i])
    entry.____map = self
    return entry
end

local function keyAt(self, i)
    if i < 1 or i > self.size then
        return nil
    end
    return self.____keys[i]
end

function __K2L_SortedMap:firstKey()
    if self.size == 0 then
        noSuchElement()
    end
    return self.____keys[1]
end

function __K2L_SortedMap:lastKey()
    if self.size == 0 then
        noSuchElement()
    end
    return self.____keys[self.size]
end

function __K2L_SortedMap:firstEntry() return entryAt(self, 1) end
function __K2L_SortedMap:lastEntry() return entryAt(self, self.size) end

function __K2L_SortedMap:floorKey(key) return keyAt(self, upperBound(self.____keys, self.size, key, self.____compare) - 1) end
function __K2L_SortedMap:lowerKey(key) return keyAt(self, lowerBound(self.____keys, self.size, key, self.____compare) - 1) end
function __K2L_SortedMap:ceilingKey(key) return keyAt(self, lowerBound(self.____keys, self.size, key, self.____compare)) end
function __K2L_SortedMap:higherKey(key) return keyAt(self, upperBound(self.____keys, self.size, key, self.____compare)) end

function __K2L_SortedMap:floorEntry(key) return entryAt(self, upperBound(self.____keys, self.size, key, self.____compare) - 1) end
function __K2L_SortedMap:lowerEntry(key) return entryAt(self, lowerBound(self.____keys, self.size, key, self.____compare) - 1) end
function __K2L_SortedMap:ceilingEntry(key) return entryAt(self, lowerBound(self.____keys, self.size, key, self.____compare)) end
function __K2L_SortedMap:higherEntry(key) return entryAt(self, upperBound(self.____keys, self.size, key, self.____compare)) end

function __K2L_SortedMap:pollFirstEntry()
    local entry = entryAt(self, 1)
    if entry ~= nil then
        entry.____map = nil
        self:remove(entry.key)
    end
    return entry
end

function __K2L_SortedMap:pollLastEntry()
    local entry = entryAt(self, self.size)
    if entry ~= nil then
        entry.____map = nil
        self:remove(entry.key)
    end
    return entry
end

-- headMap(to, inclusive = false)
function __K2L_SortedMap:headMap(to, inclusive)
    local bound = inclusive and upperBound or lowerBound
    return sortedCopy(self, 1, bound(self.____keys, self.size, to, self.____compare) - 1)
end

-- tailMap(from, inclusive = true)
function __K2L_SortedMap:tailMap(from, inclusive)
    local bound = (inclusive == false) and upperBound or lowerBound
    return sortedCopy(self, bound(self.____keys, self.size, from, self.____compare), self.size)
end

function __K2L_SortedMap:subMap(from, to)
    return sortedCopy(self, lowerBound(self.____keys, self.size, from, self.____compare),
        lowerBound(self.____keys, self.size, to, self.____compare) - 1)
end

function __K2L_SortedMap:descendingMap()
    local out = __K2L_Map.new()
    for i = self.size, 1, -1 do
        out:put(self.____keys[i], self.____values[i])
    end
    return out
end

function __K2L_SortedMap:descendingKeySet()
    return self:descendingMap():getKeys()
end

function __K2L_SortedMap:toSortedMap()
    return sortedCopy(self, 1, self.size)
end

function __K2L_Map:toSortedMap(comparator)
    local out = __K2L_SortedMap.new(comparator)
    out:putAll(self)
    return out
end

function __K2L_SortedMapOf(...)
    local map = __K2L_SortedMap.new()
    for i = 1, select("#", ...) do
        local pair = select(i, ...)
        map:put(pair.first, pair.second)
    end
    return map
end

__K2L_SortedSet = __K2L_Class("java.util.TreeSet", __K2L_Set)

-- TreeSet(), TreeSet(comparator) or TreeSet(collection)
function __K2L_SortedSet:____init(comparatorOrElements)
    __K2L_Set.____init(self)
    self.____compare = __K2L_Compare
    if type(comparatorOrElements) == "function" then
        self.____compare = comparatorOrElements
    elseif comparatorOrElements ~= nil then
        self:addAll(comparatorOrElements)
    end
end

function __K2L_SortedSet:add(value)
    if findSlot(self, value) ~= nil then
        return false
    end
    local keys, n = self.____keys, self.size
    local at = lowerBound(keys, n, value, self.____compare)
    shiftRight(keys, n, at)
    keys[at] = value
    rebuild(self, keys, n + 1)
    return true
end

function __K2L_SortedSet:clear()
    local compare = self.____compare
    __K2L_Set.____init(self)
    self.____compare = compare
end

local function sortedSetCopy(self, keepFrom, keepTo)
    local out = __K2L_SortedSet.new(self.____compare)
    for i = keepFrom, keepTo do
        out:add(self.____keys[i])
    end
    return out
end

function __K2L_SortedSet:first()
    if self.size == 0 then
        noSuchElement()
    end
    return self.____keys[1]
end

function __K2L_SortedSet:last()
    if self.size == 0 then
        noSuchElement()
    end
    return self.____keys[self.size]
end

function __K2L_SortedSet:floor(value) return keyAt(self, upperBound(self.____keys, self.size, value, self.____compare) - 1) end
function __K2L_SortedSet:lower(value) return keyAt(self, lowerBound(self.____keys, self.size, value, self.____compare) - 1) end
function __K2L_SortedSet:ceiling(value) return keyAt(self, lowerBound(self.____keys, self.size, value, self.____compare)) end
function __K2L_SortedSet:higher(value) return keyAt(self, upperBound(self.____keys, self.size, value, self.____compare)) end

function __K2L_SortedSet:pollFirst()
    local value = keyAt(self, 1)
    if value ~= nil then
        self:remove(value)
    end
    return value
end

function __K2L_SortedSet:pollLast()
    local value = keyAt(self, self.size)
    if value ~= nil then
        self:remove(value)
    end
    return value
end

function __K2L_SortedSet:headSet(to, inclusive)
    local bound = inclusive and upperBound or lowerBound
    return sortedSetCopy(self, 1, bound(self.____keys, self.size, to, self.____compare) - 1)
end

function __K2L_SortedSet:tailSet(from, inclusive)
    local bound = (inclusive == false) and upperBound or lowerBound
    return sortedSetCopy(self, bound(self.____keys, self.size, from, self.____compare), self.size)
end

function __K2L_SortedSet:subSet(from, to)
    return sortedSetCopy(self, lowerBound(self.____keys, self.size, from, self.____compare),
        lowerBound(self.____keys, self.size, to, self.____compare) - 1)
end

function __K2L_SortedSet:descendingSet()
    local out = __K2L_Set.new()
    for i = self.size, 1, -1 do
        out:add(self.____keys[i])
    end
    return out
end

function __K2L_Iterable:toSortedSet(comparator)
    local out = __K2L_SortedSet.new(comparator)
    out:addAll(self)
    return out
end

function __K2L_SortedSetOf(...)
    local set = __K2L_SortedSet.new()
    for i = 1, select("#", ...) do
        set:add((select(i, ...)))
    end
    return set
end

end

function __K2L_Array:plus(element)
    return setmetatable(__K2L_Iterable.plus(self, element), __K2L_Array)
end

function __K2L_Array:plusAll(elements)
    return setmetatable(__K2L_Iterable.plusAll(self, elements), __K2L_Array)
end

function __K2L_Array:sliceArray(indices)
    return setmetatable(self:slice(indices), __K2L_Array)
end

function __K2L_Array:contentDeepToString()
    local parts = {}
    for i = 1, self.size do
        local v = self[i]
        if getmetatable(v) == __K2L_Array then
            parts[i] = v:contentDeepToString()
        else
            parts[i] = __K2L_Str(v)
        end
    end
    return "[" .. table.concat(parts, ", ") .. "]"
end

------------------------------------------------------------------ HashMap and HashSet
-- java.util.HashMap iterates by bucket: the entries sorted (stably, in insertion order) by
-- (hash ^ (hash >>> 16)) & (capacity - 1), where the capacity doubles whenever the size exceeds three
-- quarters of it. HashMap and HashSet reproduce that order; LinkedHashMap/Set (mapOf, setOf,
-- mutableMapOf...) keep plain insertion order.
local __K2L_HashMap
local __K2L_HashSet
local __K2L_HashMapOf
local __K2L_HashSetOf

do
local function tableSizeFor(capacity)
    local size = 1
    while size < capacity do
        size = size * 2
    end
    return size
end

local function bucketOf(key, capacity)
    local h = __K2L_Hash(key)
    return __K2L_BXor(h, __K2L_Ushr(h, 16)) % capacity
end

-- Puts the keys (and values) in iteration order; new entries were appended, so a stable sort by
-- bucket leaves older entries of a bucket ahead of newer ones, as the chains of a HashMap do.
local function normalize(self)
    self.____dirty = false
    local n, keys, values = self.size, self.____keys, self.____values
    local capacity, bucket, order = self.____capacity, {}, {}
    for i = 1, n do
        bucket[i], order[i] = bucketOf(keys[i], capacity), i
    end
    local sorted = stableSort(order, n, function(a, b) return bucket[a] < bucket[b] end)
    local newKeys, newValues = {}, values and {} or nil
    for i = 1, n do
        newKeys[i] = keys[sorted[i]]
        if values ~= nil then
            newValues[i] = values[sorted[i]]
        end
    end
    self.____keys, self.____values = newKeys, newValues
    reindex(self)
end

local function grow(self)
    self.____dirty = true
    if self.size > math.floor(self.____capacity * 0.75) then
        self.____capacity = self.____capacity * 2
    end
end

-- Kotlin's mapCapacity(expectedSize), the capacity of hashMapOf / hashSetOf
local function mapCapacity(expected)
    if expected < 3 then
        return expected + 1
    end
    return math.floor(expected / 0.75 + 1)
end

-- the methods that read the entries in order first move them into that order
local function ordered(cls, base, names)
    for _, name in ipairs(names) do
        local method = base[name]
        cls[name] = function(self, ...)
            if self.____dirty then
                normalize(self)
            end
            return method(self, ...)
        end
    end
end

__K2L_HashMap = __K2L_Class("java.util.HashMap", __K2L_Map)

-- HashMap(), HashMap(initialCapacity) or HashMap(map)
function __K2L_HashMap:____init(capacityOrMap, capacity)
    __K2L_Map.____init(self)
    self.____capacity = 16
    self.____dirty = false
    if type(capacityOrMap) == "number" then
        self.____capacity = tableSizeFor(capacityOrMap)
    elseif capacityOrMap ~= nil then
        if capacityOrMap.size > 0 then
            self.____capacity = tableSizeFor(math.ceil(capacityOrMap.size / 0.75))
        end
        self:putAll(capacityOrMap)
    end
end

function __K2L_HashMap:put(key, value)
    local slot = findSlot(self, key)
    if slot ~= nil then
        local old = self.____values[slot]
        self.____values[slot] = value
        return old
    end
    slot = addSlot(self, key)
    self.____values[slot] = value
    grow(self)
    return nil
end

function __K2L_HashMap:clear()
    local capacity = self.____capacity
    __K2L_Map.____init(self)
    self.____capacity, self.____dirty = capacity, false
end

ordered(__K2L_HashMap, __K2L_Map, {
    "iter", "getKeys", "getValues", "getEntries", "toString", "forEach", "forEachKeyValue", "filter", "mapValues",
    "mapKeys", "toList", "replaceAll", "mapValuesTo", "mapKeysTo", "containsValue",
})

__K2L_HashSet = __K2L_Class("java.util.HashSet", __K2L_Set)

-- HashSet(), HashSet(initialCapacity) or HashSet(collection)
function __K2L_HashSet:____init(capacityOrElements)
    __K2L_Set.____init(self)
    self.____capacity = 16
    self.____dirty = false
    if type(capacityOrElements) == "number" then
        self.____capacity = tableSizeFor(capacityOrElements)
    elseif capacityOrElements ~= nil then
        self.____capacity = tableSizeFor(math.max(math.floor(capacityOrElements:count() / 0.75) + 1, 16))
        self:addAll(capacityOrElements)
    end
end

function __K2L_HashSet:add(value)
    if findSlot(self, value) ~= nil then
        return false
    end
    addSlot(self, value)
    grow(self)
    return true
end

function __K2L_HashSet:clear()
    local capacity = self.____capacity
    __K2L_Set.____init(self)
    self.____capacity, self.____dirty = capacity, false
end

ordered(__K2L_HashSet, __K2L_Set, {"____array", "toString"})

function __K2L_HashMapOf(...)
    local map = __K2L_HashMap.new(mapCapacity(select("#", ...)))
    for i = 1, select("#", ...) do
        local pair = select(i, ...)
        map:put(pair.first, pair.second)
    end
    return map
end

function __K2L_HashSetOf(...)
    local set = __K2L_HashSet.new(mapCapacity(select("#", ...)))
    for i = 1, select("#", ...) do
        set:add((select(i, ...)))
    end
    return set
end

-- Iterable.toHashSet()
function __K2L_Iterable:toHashSet()
    local set = __K2L_HashSet.new(mapCapacity(self:count()))
    set:addAll(self)
    return set
end
end
