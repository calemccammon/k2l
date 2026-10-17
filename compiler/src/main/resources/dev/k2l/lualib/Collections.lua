-- requires: Class, Str, Equals, Hash, Compare, Pair, Exceptions, ToInt32
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
                error(__K2L_IllegalArgumentException.new("Collection contains more than one matching element."))
            end
            found, value = true, arr[i]
        end
    end
    if not found then
        noSuchElement("Collection contains no element matching the predicate.")
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
function __K2L_Iterable:max() return (extreme(self, nil, 1, false, "Collection is empty.")) end
function __K2L_Iterable:min() return (extreme(self, nil, -1, false, "Collection is empty.")) end
function __K2L_Iterable:maxByOrNull(selector) return (extreme(self, selector, 1, true)) end
function __K2L_Iterable:minByOrNull(selector) return (extreme(self, selector, -1, true)) end
function __K2L_Iterable:maxBy(selector) return (extreme(self, selector, 1, false, "Collection is empty.")) end
function __K2L_Iterable:minBy(selector) return (extreme(self, selector, -1, false, "Collection is empty.")) end
function __K2L_Iterable:maxOf(selector) return select(2, extreme(self, selector, 1, false, "Collection is empty.")) end
function __K2L_Iterable:minOf(selector) return select(2, extreme(self, selector, -1, false, "Collection is empty.")) end
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

function __K2L_Iterable:take(count)
    local arr, n = self:____array()
    local out = {}
    local m = math.min(count, n)
    for i = 1, m do
        out[i] = arr[i]
    end
    return newList(out, m)
end

function __K2L_Iterable:takeLast(count)
    local arr, n = self:____array()
    local out = {}
    local m = math.min(count, n)
    for i = 1, m do
        out[i] = arr[n - m + i]
    end
    return newList(out, m)
end

function __K2L_Iterable:drop(count)
    local arr, n = self:____array()
    local out, k = {}, 0
    for i = count + 1, n do
        k = k + 1
        out[k] = arr[i]
    end
    return newList(out, k)
end

function __K2L_Iterable:dropLast(count)
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

function __K2L_Iterable:chunked(size)
    local arr, n = self:____array()
    local out, k = {}, 0
    for i = 1, n, size do
        local chunk, m = {}, 0
        for j = i, math.min(i + size - 1, n) do
            m = m + 1
            chunk[m] = arr[j]
        end
        k = k + 1
        out[k] = newList(chunk, m)
    end
    return newList(out, k)
end

function __K2L_Iterable:withIndex()
    return self:mapIndexed(function(index, value) return {index = index, value = value} end)
end

function __K2L_Iterable:zip(other, transform)
    local a, n = self:____array()
    local b, m = other:____array()
    local out = {}
    local k = math.min(n, m)
    for i = 1, k do
        out[i] = transform and transform(a[i], b[i]) or __K2L_Pair.new(a[i], b[i])
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
            parts[#parts + 1] = truncated or "..."
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
        group:add(valueTransform and valueTransform(arr[i]) or arr[i])
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
        map:put(keySelector(arr[i]), valueTransform and valueTransform(arr[i]) or arr[i])
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

function __K2L_Iterable:asSequence()
    return self
end

function __K2L_Iterable:hashCode()
    local arr, n = self:____array()
    local h = 1
    for i = 1, n do
        h = __K2L_ToInt32(31 * h + __K2L_Hash(arr[i]))
    end
    return h
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
    return old
end

function __K2L_List:add(value)
    self.size = self.size + 1
    self[self.size] = value
    return true
end

function __K2L_List:addAt(index, value)
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

function __K2L_List:removeAt(index)
    local value = self:get(index)
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
    for i = 1, self.size do
        self[i] = nil
    end
    self.size = 0
end

local function sortInPlace(self, sorted)
    for i = 1, self.size do
        self[i] = sorted[i]
    end
end

function __K2L_List:sort() sortInPlace(self, self:sorted()) end
function __K2L_List:sortDescending() sortInPlace(self, self:sortedDescending()) end
function __K2L_List:sortBy(selector) sortInPlace(self, self:sortedBy(selector)) end
function __K2L_List:sortByDescending(selector) sortInPlace(self, self:sortedByDescending(selector)) end
function __K2L_List:sortWith(comparator) sortInPlace(self, self:sortedWith(comparator)) end
function __K2L_List:reverse() sortInPlace(self, self:reversed()) end

function __K2L_List:fill(value)
    for i = 1, self.size do
        self[i] = value
    end
end

function __K2L_List:subList(from, to)
    local out = {}
    for i = from + 1, to do
        out[i - from] = self[i]
    end
    return newList(out, to - from)
end

function __K2L_List:getIndices()
    return __K2L_IntRange.new(0, self.size - 1, 1)
end

function __K2L_List:getLastIndex()
    return self.size - 1
end

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
    return true
end

function __K2L_Set:removeAll(elements)
    local changed = false
    for _, v in ipairs(elements:toList()) do
        changed = self:remove(v) or changed
    end
    return changed
end

function __K2L_Set:clear()
    __K2L_Set.____init(self)
end

function __K2L_Set:toString()
    return __K2L_List.toString(newList(self.____keys, self.size))
end

function __K2L_Set:equals(other)
    if not (type(other) == "table" and getmetatable(other) == __K2L_Set) or other.size ~= self.size then
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

function __K2L_Map:putAll(other)
    for k, v in other:iter() do
        self:put(k, v)
    end
end

function __K2L_Map:remove(key)
    local slot = findSlot(self, key)
    if slot == nil then
        return nil
    end
    local old = self.____values[slot]
    removeSlot(self, slot)
    return old
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

function __K2L_Map:getKeys()
    local set = __K2L_Set.new()
    for i = 1, self.size do
        set:add(self.____keys[i])
    end
    return set
end

function __K2L_Map:getValues()
    local out = {}
    for i = 1, self.size do
        out[i] = self.____values[i]
    end
    return newList(out, self.size)
end

function __K2L_Map:getEntries()
    local out = {}
    for i = 1, self.size do
        out[i] = __K2L_Entry.new(self.____keys[i], self.____values[i])
    end
    return newList(out, self.size)
end

function __K2L_Map:toString()
    local parts = {}
    for i = 1, self.size do
        parts[i] = __K2L_Str(self.____keys[i]) .. "=" .. __K2L_Str(self.____values[i])
    end
    return "{" .. table.concat(parts, ", ") .. "}"
end

function __K2L_Map:equals(other)
    if not (type(other) == "table" and getmetatable(other) == __K2L_Map) or other.size ~= self.size then
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
        -- The JVM xors key and value hashes; Lua 5.1 has no xor, so this combination is portable instead.
        h = __K2L_ToInt32(h + 31 * __K2L_Hash(self.____keys[i]) + __K2L_Hash(self.____values[i]))
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

function __K2L_IntRange:withStep(step)
    return __K2L_IntRange.new(self.first, self.last, self.step > 0 and step or -step)
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
