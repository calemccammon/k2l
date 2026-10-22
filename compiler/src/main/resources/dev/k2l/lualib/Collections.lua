-- requires: Class, Str, Equals, Hash, Compare, Pair, Exceptions, ToInt32, Bit
-- Kotlin collections on Lua tables. Lists keep elements in the array part (1-based) with an explicit `size`, so null
-- elements are fine; maps and sets (HashMap and HashSet too) keep insertion order and honor equals()/hashCode() keys.
-- A collection changed while a loop or an iterator walks it is not detected: the loop sees whatever the change left.

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

-- Whether `obj` is an instance of `cls` or one of its subclasses, or of a class declaring `cls` an interface (a program's
-- AbstractList is a List).
local function inherits(obj, cls)
    local c = type(obj) == "table" and getmetatable(obj)
    while c do
        if c == cls or (rawget(c, "____interfaces") or {})[cls] then
            return true
        end
        c = rawget(c, "____super")
    end
    return false
end

-- A comparator is a Lua function, or an object of a class implementing Comparator (callable through __call).
local function isComparator(value)
    if type(value) == "function" then
        return true
    end
    local mt = type(value) == "table" and getmetatable(value)
    return mt and rawget(mt, "__call") ~= nil or false
end

-- LuaJIT's table.new(narray, nhash): a table sized up front for the lists whose size is known (no rehash while it fills)
local tableNew
if jit then
    local ok, new = pcall(require, "table.new")
    if ok then
        tableNew = new
    end
end

local function newList(arr, n)
    arr.size = n
    return setmetatable(arr, __K2L_List)
end

-- Sorting: sorted(), sortedWith(), sortedBy() and the sort functions of lists and arrays are stable, as Kotlin documents
-- them. These return a sorted copy of arr[1..n] as a plain array.

-- A sorted copy of arr[1..n] by `compare(x, y)` (negative, zero or positive): a bottom-up merge sort, which takes the
-- element of the left run first when the two compare equal.
local function mergeSorted(arr, n, compare)
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
                if compare(src[b], src[a]) < 0 then
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
    return src
end

local function reverseNatural(a, b)
    return __K2L_Compare(b, a)
end

-- sorted(), sortedDescending(): compareTo, or with the arguments swapped
local function sortNatural(arr, n, descending)
    return mergeSorted(arr, n, descending and reverseNatural or __K2L_Compare)
end

-- sortedBy(selector) is sortedWith(compareBy(selector)): the selector runs for both elements of every comparison
-- (b first for the descending order). `pure` (set by the compiler) allows computing each key once instead.
local function sortSelected(arr, n, selector, descending, pure)
    if pure then
        local keys, slots = {}, {}
        for i = 1, n do
            keys[i], slots[i] = selector(arr[i]), i
        end
        local compare = descending and function(a, b) return __K2L_CompareValues(keys[b], keys[a]) end
            or function(a, b) return __K2L_CompareValues(keys[a], keys[b]) end
        local sorted = mergeSorted(slots, n, compare)
        for i = 1, n do
            sorted[i] = arr[sorted[i]]
        end
        return sorted
    end
    if descending then
        return mergeSorted(arr, n, function(a, b) return __K2L_CompareValues(selector(b), selector(a)) end)
    end
    return mergeSorted(arr, n, function(a, b) return __K2L_CompareValues(selector(a), selector(b)) end)
end

local function illegalArgument(message)
    error(__K2L_IllegalArgumentException.new(message))
end

local function noSuchElement(message)
    error(__K2L_NoSuchElementException.new(message))
end

-- toList() and toMutableList() copy into a new list (a read-only list is a mutable one at run time).
function __K2L_Iterable:toMutableList()
    local arr, n = self:____array()
    local out = {}
    for i = 1, n do
        out[i] = arr[i]
    end
    return newList(out, n)
end

function __K2L_Iterable:toList()
    local arr, n = self:____array()
    local out = {}
    for i = 1, n do
        out[i] = arr[i]
    end
    return newList(out, n)
end

function __K2L_Iterable:toMutableSet()
    local arr, n = self:____array()
    local set = __K2L_Set.new()
    for i = 1, n do
        set:add(arr[i])
    end
    return set
end

__K2L_Iterable.toSet = __K2L_Iterable.toMutableSet

__K2L_Iterable.toHashSet = __K2L_Iterable.toMutableSet

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

-- A list's get(index), with its message; other collections have Kotlin's own.
function __K2L_Iterable:elementAt(index)
    if inherits(self, __K2L_List) then
        return self:get(index)
    end
    local arr, n = self:____array()
    if index < 0 or index >= n then
        error(__K2L_IndexOutOfBoundsException.new("Collection doesn't contain element at index " .. index .. "."))
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

-- first(), last() and single() of an empty list say "List is empty.", of other collections "Collection is empty."
local function emptyMessage(iterable)
    return inherits(iterable, __K2L_List) and "List is empty." or "Collection is empty."
end

function __K2L_Iterable:first(predicate)
    local arr, n = self:____array()
    for i = 1, n do
        if predicate == nil or predicate(arr[i]) then
            return arr[i]
        end
    end
    noSuchElement(predicate == nil and emptyMessage(self) or "Collection contains no element matching the predicate.")
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
    if predicate == nil then
        noSuchElement(emptyMessage(self))
    end
    noSuchElement((inherits(self, __K2L_List) and "List" or "Collection") .. " contains no element matching the predicate.")
end

function __K2L_Iterable:single(predicate)
    local arr, n = self:____array()
    local found, value = false, nil
    for i = 1, n do
        if predicate == nil or predicate(arr[i]) then
            if found then
                error(__K2L_IllegalArgumentException.new(predicate == nil
                    and (inherits(self, __K2L_List) and "List" or "Collection") .. " has more than one element."
                    or "Collection contains more than one matching element."))
            end
            found, value = true, arr[i]
        end
    end
    if not found then
        noSuchElement(predicate == nil and emptyMessage(self) or "Collection contains no element matching the predicate.")
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
    local out = tableNew and tableNew(n, 2) or {}
    for i = 1, n do
        out[i] = transform(arr[i])
    end
    return newList(out, n)
end

function __K2L_Iterable:mapIndexed(transform)
    local arr, n = self:____array()
    local out = tableNew and tableNew(n, 2) or {}
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
    -- a key may be false (a Boolean key), so `selector and selector(x) or x` would not do
    local function keyOf(value)
        if selector == nil then
            return value
        end
        return selector(value)
    end
    local best, bestKey = arr[1], keyOf(arr[1])
    for i = 2, n do
        local key = keyOf(arr[i])
        -- Kotlin compares the best so far with the next one: maxValue < v
        if __K2L_Compare(bestKey, key) * sign < 0 then
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
-- (one value even when there is none: a call ending an argument list must still pass the null)
function __K2L_Iterable:maxOfOrNull(selector) return (select(2, extreme(self, selector, 1, true))) end
function __K2L_Iterable:minOfOrNull(selector) return (select(2, extreme(self, selector, -1, true))) end

function __K2L_Iterable:sorted()
    local arr, n = self:____array()
    return newList(sortNatural(arr, n, false), n)
end

function __K2L_Iterable:sortedDescending()
    local arr, n = self:____array()
    return newList(sortNatural(arr, n, true), n)
end

function __K2L_Iterable:sortedBy(selector, pure)
    local arr, n = self:____array()
    return newList(sortSelected(arr, n, selector, false, pure), n)
end

function __K2L_Iterable:sortedByDescending(selector, pure)
    local arr, n = self:____array()
    return newList(sortSelected(arr, n, selector, true, pure), n)
end

-- `comparator` is a Lua function (a, b) -> Int, from a Kotlin lambda or compareBy.
function __K2L_Iterable:sortedWith(comparator)
    local arr, n = self:____array()
    return newList(mergeSorted(arr, n, comparator), n)
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
    local texts, k, cut = {}, 0, false
    for i = 1, n do
        if limit >= 0 and i > limit then
            cut = true
            break
        end
        local value = arr[i]
        if transform then
            value = transform(value)
        end
        k = k + 1
        texts[k] = type(value) == "string" and value or __K2L_Str(value)
    end
    local body = table.concat(texts, separator, 1, k)
    if cut then
        body = body .. separator .. (truncated or "...")
    end
    return (prefix or "") .. body .. (postfix or "")
end

function __K2L_Iterable:groupBy(keySelector, valueTransform)
    local arr, n = self:____array()
    local map = __K2L_Map.new()
    local values = map.____values
    for i = 1, n do
        local slot = map:____slot(keySelector(arr[i]))
        local group = values[slot]
        if group == nil then
            group = __K2L_List.new()
            values[slot] = group
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
    local out = self:toMutableList()
    out:add(element)
    return out
end

function __K2L_Iterable:plusAll(elements)
    local out = self:toMutableList()
    out:addAll(elements)
    return out
end

function __K2L_Iterable:minus(element)
    local out = self:toMutableList()
    out:remove(element)
    return out
end

function __K2L_Iterable:minusAll(elements)
    return self:filter(function(it) return not elements:contains(it) end)
end

function __K2L_Iterable:intersect(other)
    return self:toMutableSet():filter(function(it) return other:contains(it) end):toMutableSet()
end

function __K2L_Iterable:union(other)
    local set = self:toMutableSet()
    set:addAll(other)
    return set
end

function __K2L_Iterable:subtract(other)
    return self:toMutableSet():filter(function(it) return not other:contains(it) end):toMutableSet()
end

-- toTypedArray() and toIntArray() and the like: all arrays are of one class
function __K2L_Iterable:toTypedArray()
    local arr, n = self:____array()
    local out = {}
    for i = 1, n do
        out[i] = arr[i]
    end
    out.size = n
    return setmetatable(out, __K2L_Array)
end

for _, name in ipairs({
    "toIntArray", "toLongArray", "toDoubleArray", "toBooleanArray", "toFloatArray", "toCharArray", "toShortArray", "toByteArray",
}) do
    __K2L_Iterable[name] = __K2L_Iterable.toTypedArray
end

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
    local _, n = self:____array()
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
        if comparator(best, arr[i]) * sign < 0 then
            best = arr[i]
        end
    end
    return best
end

function __K2L_Iterable:maxWith(comparator) return extremeWith(self, comparator, 1, false) end
function __K2L_Iterable:minWith(comparator) return extremeWith(self, comparator, -1, false) end
function __K2L_Iterable:maxWithOrNull(comparator) return extremeWith(self, comparator, 1, true) end
function __K2L_Iterable:minWithOrNull(comparator) return extremeWith(self, comparator, -1, true) end

-- maxOfWith(comparator, selector) and the like: the largest (sign 1) or smallest selected value by the comparator.
local function extremeOfWith(self, comparator, selector, sign, orNull)
    local arr, n = self:____array()
    if n == 0 then
        if orNull then
            return nil
        end
        error(__K2L_NoSuchElementException.new())
    end
    local best = selector(arr[1])
    for i = 2, n do
        local value = selector(arr[i])
        if comparator(value, best) * sign > 0 then
            best = value
        end
    end
    return best
end

function __K2L_Iterable:maxOfWith(comparator, selector) return extremeOfWith(self, comparator, selector, 1, false) end
function __K2L_Iterable:minOfWith(comparator, selector) return extremeOfWith(self, comparator, selector, -1, false) end
function __K2L_Iterable:maxOfWithOrNull(comparator, selector) return extremeOfWith(self, comparator, selector, 1, true) end
function __K2L_Iterable:minOfWithOrNull(comparator, selector) return extremeOfWith(self, comparator, selector, -1, true) end

function __K2L_Iterable:reduceIndexedOrNull(operation)
    local _, n = self:____array()
    if n == 0 then
        return nil
    end
    return self:reduceIndexed(operation)
end

function __K2L_Iterable:runningFoldIndexed(initial, operation)
    local arr, n = self:____array()
    local out = {initial}
    local acc = initial
    for i = 1, n do
        acc = operation(i - 1, acc, arr[i])
        out[i + 1] = acc
    end
    return newList(out, n + 1)
end

__K2L_Iterable.scanIndexed = __K2L_Iterable.runningFoldIndexed

function __K2L_Iterable:runningReduceIndexed(operation)
    local arr, n = self:____array()
    if n == 0 then
        return newList({}, 0)
    end
    local out = {arr[1]}
    local acc = arr[1]
    for i = 2, n do
        acc = operation(i - 1, acc, arr[i])
        out[i] = acc
    end
    return newList(out, n)
end

function __K2L_Iterable:filterNotNullTo(destination)
    local arr, n = self:____array()
    for i = 1, n do
        if arr[i] ~= nil then
            destination:add(arr[i])
        end
    end
    return destination
end

function __K2L_Iterable:mapIndexedNotNullTo(destination, transform)
    local arr, n = self:____array()
    for i = 1, n do
        local value = transform(i - 1, arr[i])
        if value ~= nil then
            destination:add(value)
        end
    end
    return destination
end

function __K2L_Iterable:flatMapIndexedTo(destination, transform)
    local arr, n = self:____array()
    for i = 1, n do
        destination:addAll(transform(i - 1, arr[i]))
    end
    return destination
end

-- joinTo(buffer, ...): the joinToString text appended to a StringBuilder (or any Appendable with append).
function __K2L_Iterable:joinTo(buffer, separator, prefix, postfix, limit, truncated, transform)
    buffer:append(self:joinToString(separator, prefix, postfix, limit, truncated, transform))
    return buffer
end

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

-- `what` names the receiver in the error: "collection" unless given ("char sequence")
function __K2L_Iterable:firstNotNullOf(transform, what)
    local value = self:firstNotNullOfOrNull(transform)
    if value == nil then
        noSuchElement("No element of the " .. (what or "collection") .. " was transformed to a non-null value.")
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
    local out = self:toMutableList()
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
    local out = self:toMutableList()
    out:reverse()
    return out
end

-- asList(): a list of the elements (a copy, not a view)
__K2L_Iterable.asList = __K2L_Iterable.toMutableList

-- Index of `element` in the sorted list, or -(insertion point) - 1.
function __K2L_Iterable:binarySearch(element, comparatorOrFrom, from, to)
    local arr, n = self:____array()
    local comparator = __K2L_Compare
    if isComparator(comparatorOrFrom) then
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
    local arr, n = self:____array()
    local out = sortNatural(arr, n, false)
    out.size = n
    return setmetatable(out, __K2L_Array)
end

function __K2L_Iterable:sortedArrayDescending()
    local arr, n = self:____array()
    local out = sortNatural(arr, n, true)
    out.size = n
    return setmetatable(out, __K2L_Array)
end

function __K2L_Iterable:sortedArrayWith(comparator)
    local arr, n = self:____array()
    local out = mergeSorted(arr, n, comparator)
    out.size = n
    return setmetatable(out, __K2L_Array)
end

function __K2L_Iterable:reversedArray()
    local out = self:toMutableList()
    out:reverse()
    return setmetatable(out, __K2L_Array)
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
    -- within one array, a range moved up is copied from its end, so that an overlapping range is copied intact
    if rawequal(arr, destination) and destinationOffset > startIndex then
        for i = endIndex - 1, startIndex, -1 do
            destination[destinationOffset + i - startIndex + 1] = arr[i + 1]
        end
        return destination
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

-- Calls `action` with each element of the source, in order; a sequence (`seq.groupingBy { }`) is pulled one at a time.
local function eachOf(grouping, action)
    local source = grouping.source
    if source.____isSequence then
        for _, value in source:iter() do
            action(value)
        end
        return
    end
    local arr, n = source:____array()
    for i = 1, n do
        action(arr[i])
    end
end

-- The results are new LinkedHashMaps that nobody else sees yet: each element looks its key up once (____slot), and a
-- missing key's entry is added before its value is computed.
function __K2L_Grouping:eachCount()
    local counts = __K2L_Map.new()
    local values = counts.____values
    eachOf(self, function(element)
        local slot = counts:____slot(self.keySelector(element))
        values[slot] = (values[slot] or 0) + 1
    end)
    return counts
end

-- fold(initialValue, operation(accumulator, element))
function __K2L_Grouping:fold(initial, operation)
    local result = __K2L_Map.new()
    local values = result.____values
    eachOf(self, function(element)
        local slot, found = result:____slot(self.keySelector(element))
        local acc = initial
        if found then
            acc = values[slot]
        end
        values[slot] = operation(acc, element)
    end)
    return result
end

-- reduce(operation(key, accumulator, element))
function __K2L_Grouping:reduce(operation)
    local result = __K2L_Map.new()
    local values = result.____values
    eachOf(self, function(element)
        local key = self.keySelector(element)
        local slot, found = result:____slot(key)
        if found then
            values[slot] = operation(key, values[slot], element)
        else
            values[slot] = element
        end
    end)
    return result
end

-- aggregate(operation(key, accumulator, element, isFirst))
function __K2L_Grouping:aggregate(operation)
    local result = __K2L_Map.new()
    local values = result.____values
    eachOf(self, function(element)
        local key = self.keySelector(element)
        local slot, found = result:____slot(key)
        values[slot] = operation(key, values[slot], element, not found)
    end)
    return result
end

function __K2L_Iterable:groupingBy(keySelector)
    return __K2L_Grouping.new(self, keySelector)
end

------------------------------------------------------------------ Iterator
-- iterator(): over a snapshot of the elements; remove() removes the element next() last returned from the collection.
local __K2L_CollectionIterator = __K2L_Class("kotlin.collections.Iterator")

function __K2L_CollectionIterator:____init(source)
    local items, count = source:____array()
    local copy = {}
    for i = 1, count do
        copy[i] = items[i]
    end
    self.____source, self.____items, self.____count, self.____position, self.____removed = source, copy, count, 0, 0
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

function __K2L_CollectionIterator:remove()
    local source, position = self.____source, self.____position
    if position == 0 or self.____lastRemoved == position then
        error(__K2L_IllegalStateException.new())
    end
    if source.removeAt ~= nil and source.____map == nil then
        source:removeAt(position - 1 - self.____removed)
    else
        source:remove(self.____items[position])
    end
    self.____removed = self.____removed + 1
    self.____lastRemoved = position
end

function __K2L_Iterable:iterator()
    return __K2L_CollectionIterator.new(self)
end

------------------------------------------------------------------ List
__K2L_List = __K2L_Class("java.util.ArrayList", __K2L_Iterable)

-- ArrayList(), ArrayList(capacity) and ArrayList(elements), as the constructor of a class extending ArrayList calls it
function __K2L_List:____init(elements)
    self.size = 0
    if type(elements) == "table" then
        __K2L_List.addAll(self, elements)
    end
end

function __K2L_List:____array()
    return self, self.size
end

-- ArrayList's isEmpty and indexOf read the elements; contains calls indexOf (a subclass may override it)
function __K2L_List:isEmpty()
    return self.size == 0
end

function __K2L_List:indexOf(value)
    for i = 1, self.size do
        if __K2L_Equals(self[i], value) then
            return i - 1
        end
    end
    return -1
end

function __K2L_List:lastIndexOf(value)
    for i = self.size, 1, -1 do
        if __K2L_Equals(self[i], value) then
            return i - 1
        end
    end
    return -1
end

function __K2L_List:contains(value)
    return self:indexOf(value) >= 0
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
    local n = self.size + 1
    self.size = n
    self[n] = value
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

-- The bulk and convenience operations do not call add, addAt or removeAt, which a subclass may override.
function __K2L_List:addAll(elements)
    local arr, n = elements:____array()
    local size = self.size
    for i = 1, n do
        self[size + i] = arr[i]
    end
    self.size = size + n
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
        __K2L_List.addAt(self, index + i - 1, copy[i])
    end
    return n > 0
end

function __K2L_List:removeAt(index)
    local value = __K2L_List.get(self, index)
    for i = index + 1, self.size - 1 do
        self[i] = self[i + 1]
    end
    self[self.size] = nil
    self.size = self.size - 1
    return value
end

function __K2L_List:remove(value)
    local index = __K2L_List.indexOf(self, value)
    if index < 0 then
        return false
    end
    __K2L_List.removeAt(self, index)
    return true
end

-- removeFirst() and removeLast() of an empty list throw NoSuchElementException without a message
function __K2L_List:removeFirst()
    if self.size == 0 then
        noSuchElement()
    end
    return __K2L_List.removeAt(self, 0)
end

function __K2L_List:removeLast()
    if self.size == 0 then
        noSuchElement()
    end
    return __K2L_List.removeAt(self, self.size - 1)
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

-- In place, as MutableList.sort*() do, with the same comparisons as sorted*() (none for one element).
function __K2L_List:sort()
    local arr, n = self:____array()
    sortInPlace(self, sortNatural(arr, n, false))
end

function __K2L_List:sortDescending()
    local arr, n = self:____array()
    sortInPlace(self, sortNatural(arr, n, true))
end

function __K2L_List:sortBy(selector, pure)
    local arr, n = self:____array()
    sortInPlace(self, sortSelected(arr, n, selector, false, pure))
end

function __K2L_List:sortByDescending(selector, pure)
    local arr, n = self:____array()
    sortInPlace(self, sortSelected(arr, n, selector, true, pure))
end

function __K2L_List:sortWith(comparator)
    local arr, n = self:____array()
    sortInPlace(self, mergeSorted(arr, n, comparator))
end

function __K2L_List:reverse() sortInPlace(self, self:reversed()) end

function __K2L_List:fill(value, from, to)
    for i = (from or 0) + 1, to or self.size do
        self[i] = value
    end
end

-- subList(from, to): a new list of those elements (a copy, not a view of the list)
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
    return newList(out, to - from)
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

-- getFirst() and getLast()
function __K2L_List:getFirst()
    if self.size == 0 then
        noSuchElement()
    end
    return self:get(0)
end

function __K2L_List:getLast()
    if self.size == 0 then
        noSuchElement()
    end
    return self:get(self.size - 1)
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

-- Arrays share the list representation (and toString) but compare by identity. All arrays are of this one class, whatever
-- their element type (an IntArray too).
__K2L_Array = __K2L_Class("Array", __K2L_List)

-- `is Array<*>`
local function __K2L_IsArray(value)
    return inherits(value, __K2L_Array)
end

function __K2L_Array:equals(other)
    return rawequal(self, other)
end

__K2L_Array.contentEquals = __K2L_List.equals
__K2L_Array.contentToString = __K2L_List.toString
__K2L_Array.contentHashCode = __K2L_Iterable.hashCode

local function arrayIndex(index, size)
    error(__K2L_ArrayIndexOutOfBoundsException.new("Index " .. index .. " out of bounds for length " .. size))
end

function __K2L_Array:get(index)
    if index < 0 or index >= self.size then
        arrayIndex(index, self.size)
    end
    return self[index + 1]
end

------------------------------------------------------------------ factories
-- listOf(...), mutableListOf(...) and emptyList(): a new list (read-only lists are mutable ones at run time).
local function __K2L_ListOf(...)
    return newList({...}, select("#", ...))
end

local function __K2L_ArrayOf(...)
    local arr = {...}
    arr.size = select("#", ...)
    return setmetatable(arr, __K2L_Array)
end

-- List(n) { init(it) } and Array(n) { ... }; also IntArray(n) with a constant initial value. `array` is true for an array,
-- nil for a list.
local function __K2L_ListOfSize(size, init, array)
    local out = tableNew and size > 0 and tableNew(size, 2) or {}
    if type(init) == "function" then
        for i = 1, size do
            out[i] = init(i - 1)
        end
    else
        for i = 1, size do
            out[i] = init
        end
    end
    out.size = size
    return setmetatable(out, array and __K2L_Array or __K2L_List)
end

-- asList() of an array: a list of its elements (a copy, not a view of the array)
__K2L_Array.asList = __K2L_Iterable.toMutableList

------------------------------------------------------------------ hashed keys (Map and Set)
local NIL_KEY = {}

-- Keys are found by raw lookup in ____index, except objects with hashCode(), which are kept in hashCode buckets and
-- compared with equals(). (A Lua table cannot hold NaN as a key, and holds 0.0 and -0.0 as one.)
local function hashOf(key)
    if type(key) == "table" and key.hashCode ~= nil then
        return key:hashCode()
    end
    return nil
end

-- The slot of `key`, or nil.
local function findSlot(self, key)
    if type(key) ~= "table" then
        return self.____index[key == nil and NIL_KEY or key]
    end
    local h = hashOf(key)
    if h ~= nil then
        local bucket = self.____buckets[h]
        if bucket ~= nil then
            for _, slot in ipairs(bucket) do
                if __K2L_Equals(self.____keys[slot], key) then
                    return slot
                end
            end
        end
        return nil
    end
    return self.____index[key]
end

local function addSlot(self, key)
    local slot = self.size + 1
    self.size = slot
    self.____keys[slot] = key
    local h = hashOf(key)
    if h ~= nil then
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

-- Removes the entry at `slot`, keeping the insertion order. The entries after it move down one slot, and their
-- lookup entries are renumbered in place (no rehash of the map); only a key whose hashCode() changed since it was
-- added falls back to rebuilding the lookup tables.
local function removeSlot(self, slot)
    local n = self.size
    local keys, values, index, buckets = self.____keys, self.____values, self.____index, self.____buckets
    local removed = keys[slot]
    local stale = false
    local h = hashOf(removed)
    if h ~= nil then
        local bucket = buckets[h]
        if bucket == nil then
            stale = true
        else
            for j = 1, #bucket do
                if bucket[j] == slot then
                    table.remove(bucket, j)
                    break
                end
            end
            if bucket[1] == nil then
                buckets[h] = nil
            end
        end
    else
        index[removed == nil and NIL_KEY or removed] = nil
    end
    for i = slot, n - 1 do
        local key = keys[i + 1]
        keys[i] = key
        if values ~= nil then
            values[i] = values[i + 1]
        end
        local kh = hashOf(key)
        if kh ~= nil then
            local bucket = buckets[kh]
            local found = false
            if bucket ~= nil then
                for j = 1, #bucket do
                    if bucket[j] == i + 1 then
                        bucket[j] = i
                        found = true
                        break
                    end
                end
            end
            stale = stale or not found
        else
            index[key == nil and NIL_KEY or key] = i
        end
    end
    keys[n] = nil
    if values ~= nil then
        values[n] = nil
    end
    self.size = n - 1
    if stale then
        reindex(self)
    end
end

------------------------------------------------------------------ Set
__K2L_Set = __K2L_Class("java.util.LinkedHashSet", __K2L_Iterable)

-- LinkedHashSet(), (capacity) and (elements), which is also HashSet and mutableSetOf: insertion order. The last calls add
-- for each element (which a subclass may override).
function __K2L_Set:____init(elements)
    self.size = 0
    self.____keys, self.____index, self.____buckets = {}, {}, {}
    if type(elements) == "table" then
        self:addAll(elements)
    end
end

-- A table constructor sizes the set's fields once (set one by one, they rehash the table).
function __K2L_Set.new(...)
    local self = setmetatable({size = 0, ____keys = false, ____index = false, ____buckets = false}, __K2L_Set)
    __K2L_Set.____init(self, ...)
    return self
end

function __K2L_Set:____array()
    return self.____keys, self.size
end

function __K2L_Set:isEmpty()
    return self.size == 0
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

-- Removes the elements matching `predicate`, or contained in a collection.
function __K2L_Set:removeAll(elements)
    local predicate = elements
    if type(elements) ~= "function" then
        -- AbstractSet.removeAll removes the other collection's elements with remove() when that is smaller
        if elements.size ~= nil and self.size > elements.size then
            local arr, m = elements:____array()
            local changed = false
            for i = 1, m do
                changed = self:remove(arr[i]) or changed
            end
            return changed
        end
        predicate = function(it) return elements:contains(it) end
    end
    local keys, n = self.____keys, self.size
    local kept, k = {}, 0
    for i = 1, n do
        if not predicate(keys[i]) then
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
    __K2L_Set.____init(self)
end

function __K2L_Set:toString()
    return __K2L_List.toString(newList(self.____keys, self.size))
end

-- AbstractSet.equals: the same size, and containsAll(other)
function __K2L_Set:equals(other)
    if not inherits(other, __K2L_Set) or (other.getSize and other:getSize() or other.size) ~= self.size then
        return false
    end
    local arr, n = other:____array()
    for i = 1, n do
        if not self:contains(arr[i]) then
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
    local out = self:toMutableSet()
    out:add(element)
    return out
end

function __K2L_Set:plusAll(elements)
    local out = self:toMutableSet()
    out:addAll(elements)
    return out
end

function __K2L_Set:minus(element)
    local out = self:toMutableSet()
    out:remove(element)
    return out
end

function __K2L_Set:minusAll(elements)
    return self:filter(function(it) return not elements:contains(it) end):toMutableSet()
end

local function __K2L_SetOf(...)
    local set = __K2L_Set.new()
    for i = 1, select("#", ...) do
        set:add((select(i, ...)))
    end
    return set
end


------------------------------------------------------------------ Map
local __K2L_Entry = __K2L_Class("kotlin.collections.Map.Entry")

function __K2L_Entry:____init(key, value)
    self.key = key
    self.value = value
end

function __K2L_Entry:toString()
    return __K2L_Str(self.key) .. "=" .. __K2L_Str(self.value)
end

-- An entry read from a map's entries holds the map (____map): setValue also puts the value in the map.
function __K2L_Entry:setValue(value)
    local old = self.value
    local map = self.____map
    if map ~= nil then
        map:put(self.key, value)
    end
    self.value = value
    return old
end

function __K2L_Entry:hashCode()
    return __K2L_BXor(__K2L_Hash(self.key), __K2L_Hash(self.value))
end

function __K2L_Entry:equals(other)
    return inherits(other, __K2L_Entry) and __K2L_Equals(self.key, other.key) and __K2L_Equals(self.value, other.value)
end

-- LinkedHashMap, which HashMap, mutableMapOf, mapOf and the rest are: the keys in ____keys in insertion order, their
-- values in ____values at the same slots.
__K2L_Map = __K2L_Class("java.util.LinkedHashMap")
__K2L_Map.__tostring = __K2L_Iterable.__tostring

-- LinkedHashMap(), (capacity) and (map); copying a map does not call put.
function __K2L_Map:____init(map)
    self.size = 0
    self.____keys, self.____values, self.____index, self.____buckets = {}, {}, {}, {}
    if type(map) == "table" then
        __K2L_Map.putAll(self, map)
    end
end

-- A table constructor sizes the map's fields once (set one by one, they rehash the table at each power of two).
function __K2L_Map.new(...)
    local self = setmetatable({size = 0, ____keys = false, ____values = false, ____index = false, ____buckets = false}, __K2L_Map)
    __K2L_Map.____init(self, ...)
    return self
end

-- for _, k, v in map:iter() do ... end, over the entries in order (the index comes first: a key may be nil)
function __K2L_Map:iter()
    local i = 0
    return function()
        i = i + 1
        if i <= self.size then
            return i, self.____keys[i], self.____values[i]
        end
    end
end

-- The keys, values and entries in iteration order, as an array and its length: what the views and loops read. The keys
-- and values are the map's own arrays, the entries new ones that write setValue through to the map.
function __K2L_Map:____keyArray()
    return self.____keys, self.size
end

function __K2L_Map:____valueArray()
    return self.____values, self.size
end

-- for `for ((k, v) in map)`
function __K2L_Map:____arrays()
    return self.____keys, self.____values, self.size
end

function __K2L_Map:____entryArray()
    local n, entries = self.size, {}
    local keys, values = self.____keys, self.____values
    for i = 1, n do
        entries[i] = setmetatable({key = keys[i], value = values[i], ____map = self}, __K2L_Entry)
    end
    return entries, n
end

-- The slot of `key`, added (without a value) when it is missing, and whether it was there: for the maps the lualib builds.
function __K2L_Map:____slot(key)
    local slot = findSlot(self, key)
    if slot ~= nil then
        return slot, true
    end
    return addSlot(self, key), false
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

-- get, then containsKey for a missing value, as Kotlin's getValue does
function __K2L_Map:getValue(key)
    local value = self:get(key)
    if value == nil and not self:containsKey(key) then
        noSuchElement("Key " .. __K2L_Str(key) .. " is missing in the map.")
    end
    return value
end

-- with get and put, which a subclass may override, as Kotlin's getOrPut
function __K2L_Map:getOrPut(key, default)
    local value = self:get(key)
    if value == nil then
        value = default()
        self:put(key, value)
    end
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

-- A new entry gives a subclass's removeEldestEntry(eldest) the chance to have the first entry removed, as LinkedHashMap does.
function __K2L_Map:put(key, value)
    local slot = findSlot(self, key)
    if slot ~= nil then
        local old = self.____values[slot]
        self.____values[slot] = value
        return old
    end
    slot = addSlot(self, key)
    self.____values[slot] = value
    if self.removeEldestEntry ~= nil then
        local eldest = __K2L_Entry.new(self.____keys[1], self.____values[1])
        if self:removeEldestEntry(eldest) then
            __K2L_Map.remove(self, eldest.key)
        end
    end
    return nil
end

-- the map's own put, which putAll, merge, compute and the like use: not an override of a subclass
__K2L_Map.____put = __K2L_Map.put

function __K2L_Map:set(key, value)
    self:put(key, value)
end

-- Accepts another map, a list of pairs or a sequence of pairs.
function __K2L_Map:putAll(other)
    if other.____isSequence then
        for _, pair in other:iter() do
            self:____put(pair.first, pair.second)
        end
        return
    end
    if other.iter == nil then
        local arr, n = other:____array()
        for i = 1, n do
            self:____put(arr[i].first, arr[i].second)
        end
        return
    end
    for _, k, v in other:iter() do
        self:____put(k, v)
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
        self:____put(key, value)
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
        self:____put(key, result)
    end
    return result
end

function __K2L_Map:compute(key, remapping)
    local result = remapping(key, self:get(key))
    if result == nil then
        self:remove(key)
    else
        self:____put(key, result)
    end
    return result
end

function __K2L_Map:computeIfAbsent(key, mapping)
    local old = self:get(key)
    if old == nil then
        old = mapping(key)
        if old ~= nil then
            self:____put(key, old)
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
        self:____put(key, result)
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

------------------------------------------------------------------ keys, values and entries
-- A map's keys, values and entries are snapshots, made when they are read: a later change of the map does not show in
-- them. Removing from one (remove, removeAll, removeIf, retainAll, clear, and remove() of its iterator) also removes the
-- entries from the map. The keys are a set, the values and the entries lists.
local KeySnapshot = __K2L_Class("kotlin.collections.Set", __K2L_Set)
local ValueSnapshot = __K2L_Class("kotlin.collections.Collection", __K2L_List)
local EntrySnapshot = __K2L_Class("kotlin.collections.Set", __K2L_List)

-- how removing an element of each snapshot removes its entry from the map
local function unmapKey(map, key)
    map:remove(key)
end

local function unmapValue(map, value)
    for i = 1, map.size do
        if __K2L_Equals(map.____values[i], value) then
            removeSlot(map, i)
            return
        end
    end
end

local function unmapEntry(map, entry)
    map:remove(entry.key, entry.value)
end

KeySnapshot.____unmap, ValueSnapshot.____unmap, EntrySnapshot.____unmap = unmapKey, unmapValue, unmapEntry

-- Removes the elements that match `predicate` (that do not, with `keep`) from the snapshot and the map; whether any was.
local function removeThrough(self, predicate, keep)
    local arr, n = self:____array()
    local matched, k = {}, 0
    for i = 1, n do
        if (predicate(arr[i]) and true or false) ~= (keep and true or false) then
            k = k + 1
            matched[k] = arr[i]
        end
    end
    local base = getmetatable(self).____super
    for i = 1, k do
        base.remove(self, matched[i])
        self.____unmap(self.____map, matched[i])
    end
    return k > 0
end

local function predicateOf(elements)
    if type(elements) == "function" then
        return elements
    end
    return function(it) return elements:contains(it) end
end

for _, view in ipairs({KeySnapshot, ValueSnapshot, EntrySnapshot}) do
    function view:remove(element)
        if not getmetatable(self).____super.remove(self, element) then
            return false
        end
        self.____unmap(self.____map, element)
        return true
    end
    function view:removeAll(elements)
        return removeThrough(self, predicateOf(elements), false)
    end
    view.removeIf = view.removeAll
    function view:retainAll(elements)
        return removeThrough(self, predicateOf(elements), true)
    end
    function view:clear()
        getmetatable(self).____super.clear(self)
        self.____map:clear()
    end
end

function __K2L_Map:getKeys()
    local view = __K2L_Set.new()
    for i = 1, self.size do
        addSlot(view, self.____keys[i])
    end
    view.____map = self
    return setmetatable(view, KeySnapshot)
end

function __K2L_Map:getValues()
    local out = {}
    for i = 1, self.size do
        out[i] = self.____values[i]
    end
    out.size, out.____map = self.size, self
    return setmetatable(out, ValueSnapshot)
end

function __K2L_Map:getEntries()
    local out, n = self:____entryArray()
    out.size, out.____map = n, self
    return setmetatable(out, EntrySnapshot)
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

-- AbstractMap.equals: the other map's size(), then its get for each key (and containsKey for a null value)
function __K2L_Map:equals(other)
    if not inherits(other, __K2L_Map) or (other.getSize and other:getSize() or other.size) ~= self.size then
        return false
    end
    for i = 1, self.size do
        local key, value = self.____keys[i], self.____values[i]
        if value == nil then
            if other:get(key) ~= nil or not other:containsKey(key) then
                return false
            end
        elseif not __K2L_Equals(value, other:get(key)) then
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

-- Operations taking an entry lambda receive the entry.
function __K2L_Map:forEach(action)
    local entries, n = self:____entryArray()
    for i = 1, n do
        action(entries[i])
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

function __K2L_Map:toMutableMap()
    local out = __K2L_Map.new()
    out:putAll(self)
    return out
end

__K2L_Map.toMap = __K2L_Map.toMutableMap

function __K2L_Map:plus(pair)
    local out = self:toMutableMap()
    if getmetatable(pair) == __K2L_Pair then
        out:put(pair.first, pair.second)
    else
        out:putAll(pair)
    end
    return out
end

function __K2L_Map:minus(key)
    local out = self:toMutableMap()
    out:remove(key)
    return out
end

-- map - keys
function __K2L_Map:minusAll(keys)
    local out = self:toMutableMap()
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

------------------------------------------------------------------ sorted maps and sets
-- sortedMapOf, toSortedMap, sortedSetOf and toSortedSet: a LinkedHashMap or LinkedHashSet whose keys stay in the
-- comparator's order (natural order by default), found by binary search: keys that compare equal are the same key, as in
-- a TreeMap. A new key is inserted at its place, which renumbers the slots after it. Only the Map and Set operations are
-- there (no firstKey, headMap, floor, ...).
local __K2L_SortedMap = __K2L_Class("java.util.SortedMap", __K2L_Map)
local __K2L_SortedSet = __K2L_Class("java.util.SortedSet", __K2L_Set)
local __K2L_SortedMapOf
local __K2L_SortedSetOf

do
-- Moves the last key (and its value) to its place in the order: after the keys that do not compare greater.
local function placeLast(self)
    local keys, values, n, compare = self.____keys, self.____values, self.size, self.____compare
    local key = keys[n]
    local lo, hi = 1, n
    while lo < hi do
        local mid = math.floor((lo + hi) / 2)
        if compare(keys[mid], key) <= 0 then
            lo = mid + 1
        else
            hi = mid
        end
    end
    if lo == n then
        return
    end
    local value = values and values[n]
    for i = n, lo + 1, -1 do
        keys[i] = keys[i - 1]
        if values then
            values[i] = values[i - 1]
        end
    end
    keys[lo] = key
    if values then
        values[lo] = value
    end
    if next(self.____buckets) == nil then
        local index = self.____index
        for i = lo, n do
            local k = keys[i]
            index[k == nil and NIL_KEY or k] = i
        end
    else
        reindex(self)
    end
end

-- The slot of the key that compares equal to `key`, or nil.
local function sortedSlot(self, key)
    local keys, compare = self.____keys, self.____compare
    local lo, hi = 1, self.size + 1
    while lo < hi do
        local mid = math.floor((lo + hi) / 2)
        if compare(keys[mid], key) < 0 then
            lo = mid + 1
        else
            hi = mid
        end
    end
    if lo <= self.size and compare(keys[lo], key) == 0 then
        return lo
    end
    return nil
end

function __K2L_SortedMap:____init(comparator)
    __K2L_Map.____init(self)
    self.____compare = comparator or __K2L_Compare
end

function __K2L_SortedMap:get(key)
    local slot = sortedSlot(self, key)
    return slot and self.____values[slot]
end

function __K2L_SortedMap:getOrDefault(key, default)
    local slot = sortedSlot(self, key)
    if slot == nil then
        return default
    end
    return self.____values[slot]
end

function __K2L_SortedMap:getOrElse(key, default)
    local slot = sortedSlot(self, key)
    if slot == nil then
        return default()
    end
    return self.____values[slot]
end

function __K2L_SortedMap:containsKey(key)
    return sortedSlot(self, key) ~= nil
end

function __K2L_SortedMap:remove(key, value)
    local slot = sortedSlot(self, key)
    if slot ~= nil then
        key = self.____keys[slot]
    end
    return __K2L_Map.remove(self, key, value)
end

function __K2L_SortedMap:put(key, value)
    local slot = sortedSlot(self, key)
    if slot ~= nil then
        local old = self.____values[slot]
        self.____values[slot] = value
        return old
    end
    slot = addSlot(self, key)
    self.____values[slot] = value
    placeLast(self)
    return nil
end

__K2L_SortedMap.____put = __K2L_SortedMap.put

function __K2L_SortedSet:____init(comparator)
    __K2L_Set.____init(self)
    self.____compare = comparator or __K2L_Compare
end

function __K2L_SortedSet:contains(value)
    return sortedSlot(self, value) ~= nil
end

function __K2L_SortedSet:remove(value)
    local slot = sortedSlot(self, value)
    if slot == nil then
        return false
    end
    removeSlot(self, slot)
    return true
end

function __K2L_SortedSet:add(value)
    if sortedSlot(self, value) ~= nil then
        return false
    end
    addSlot(self, value)
    placeLast(self)
    return true
end

-- sortedMapOf(pairs...), sortedMapOf(comparator, pairs...) (`comparator` nil for the natural order)
function __K2L_SortedMapOf(comparator, ...)
    local map = __K2L_SortedMap.new(comparator)
    for i = 1, select("#", ...) do
        local pair = select(i, ...)
        map:put(pair.first, pair.second)
    end
    return map
end

function __K2L_SortedSetOf(comparator, ...)
    local set = __K2L_SortedSet.new(comparator)
    for i = 1, select("#", ...) do
        set:add((select(i, ...)))
    end
    return set
end

-- The keys sorted first, so that each is added at the end.
function __K2L_Map:toSortedMap(comparator)
    local out = __K2L_SortedMap.new(comparator)
    local compare, keys, values = out.____compare, self.____keys, self.____values
    local slots = {}
    for i = 1, self.size do
        slots[i] = i
    end
    slots = mergeSorted(slots, self.size, function(a, b) return compare(keys[a], keys[b]) end)
    for i = 1, self.size do
        out:put(keys[slots[i]], values[slots[i]])
    end
    return out
end

function __K2L_Iterable:toSortedSet(comparator)
    local out = __K2L_SortedSet.new(comparator)
    local arr, n = self:____array()
    local sorted = mergeSorted(arr, n, out.____compare)
    for i = 1, n do
        out:add(sorted[i])
    end
    return out
end
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

-- A class of the program implementing ClosedRange: contains() and isEmpty() compare its start and endInclusive, unless the
-- class overrides them.
local __K2L_ClosedRangeMixin = __K2L_Class("kotlin.ranges.ClosedRange")

function __K2L_ClosedRangeMixin:contains(value)
    return __K2L_Compare(value, self.start) >= 0 and __K2L_Compare(value, self.endInclusive) <= 0
end

function __K2L_ClosedRangeMixin:isEmpty()
    return __K2L_Compare(self.start, self.endInclusive) > 0
end

-- ClosedRange.start and endInclusive of a value typed as the interface, when the program has its own ClosedRange classes:
-- the lualib ranges store first and last.
local function __K2L_RangeStart(range)
    local first = rawget(range, "first")
    if first == nil then
        return range.start
    end
    return first
end

local function __K2L_RangeEnd(range)
    local last = rawget(range, "last")
    if last == nil then
        return range.endInclusive
    end
    return last
end

------------------------------------------------------------------ arrays
function __K2L_Array:plus(element)
    return setmetatable(__K2L_Iterable.plus(self, element), getmetatable(self))
end

function __K2L_Array:plusAll(elements)
    return setmetatable(__K2L_Iterable.plusAll(self, elements), getmetatable(self))
end

function __K2L_Array:sliceArray(indices)
    return setmetatable(self:slice(indices), getmetatable(self))
end

-- contentDeepHashCode / contentDeepEquals: nested arrays by content, other elements by hashCode()/equals()
function __K2L_Array:contentDeepHashCode()
    local h = 1
    for i = 1, self.size do
        local v = self[i]
        h = __K2L_ToInt32(31 * h + (inherits(v, __K2L_Array) and v:contentDeepHashCode() or __K2L_Hash(v)))
    end
    return h
end

function __K2L_Array:contentDeepEquals(other)
    if not inherits(other, __K2L_Array) or other.size ~= self.size then
        return false
    end
    for i = 1, self.size do
        local a, b = self[i], other[i]
        if inherits(a, __K2L_Array) and inherits(b, __K2L_Array) then
            if not a:contentDeepEquals(b) then
                return false
            end
        elseif not __K2L_Equals(a, b) then
            return false
        end
    end
    return true
end

function __K2L_Array:contentDeepToString()
    local parts = {}
    for i = 1, self.size do
        local v = self[i]
        if inherits(v, __K2L_Array) then
            parts[i] = v:contentDeepToString()
        else
            parts[i] = __K2L_Str(v)
        end
    end
    return "[" .. table.concat(parts, ", ") .. "]"
end
