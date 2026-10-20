-- requires: Class, Str, Equals, Hash, Compare, Pair, Exceptions, ToInt32, Bit, TimSort, IdentityHash
-- Kotlin collections. Lists keep elements in the array part (1-based) with an explicit `size`, so
-- null elements are fine; maps and sets keep insertion order and honor equals()/hashCode() keys.

------------------------------------------------------------------ Iterable
-- Shared operations; subclasses provide ____array(), returning a 1-based array and its length.
local __K2L_Iterable = __K2L_Class("kotlin.collections.Iterable")
-- tostring() shows Kotlin's toString(); subclasses inherit the metamethod from __K2L_Class.
function __K2L_Iterable:__tostring()
    return self:toString()
end

-- Structural changes (adding or removing elements, clear, sort) count up ____modCount, as the JDK's modCount, so that
-- iterators and `for` loops notice a change of the collection made while they run. A loop over a collection reads
-- `____modCount` before it starts and after each pass of its body; when it changed, ____comodified(i, n) (i elements
-- seen of n) decides like the JVM's iterator: a HashMap's (and a set's, a TreeMap's) knew at the i-th element whether
-- there was another one, an ArrayList's compares its position with the current size. It throws
-- ConcurrentModificationException, or returns true for a loop that ends normally.
__K2L_Iterable.____modCount = 0

local function __K2L_Comodification()
    error(__K2L_ConcurrentModificationException.new())
end

function __K2L_Iterable:____comodified(i, n)
    if i < n then
        __K2L_Comodification()
    end
    return true
end

local __K2L_List
local __K2L_Array
local __K2L_ArrayClassOf
local arrayClass
local __K2L_Set
local __K2L_Map
local __K2L_IntRange
local __K2L_EmptyList
local __K2L_SingletonList
local __K2L_FixedSizeList
local optimizedList
local optimizedSet
local optimizedMap

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

local function newList(arr, n)
    arr.size, arr.____modCount = n, 0
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

-- Whether `keys[1..n]` can be ordered with Lua's `<` and `>` exactly like __K2L_Compare: numbers (no NaN or -0.0) or
-- strings without supplementary characters (those order by UTF-16 code unit).
local function directlyOrdered(keys, n)
    local first = keys[1]
    local t = type(first)
    if t == "number" then
        for i = 1, n do
            local k = keys[i]
            if type(k) ~= "number" or k ~= k or (k == 0 and 1 / k < 0) then
                return false
            end
        end
        return true
    elseif t == "string" then
        for i = 1, n do
            local k = keys[i]
            if type(k) ~= "string" or k:find("[\240-\244]") then
                return false
            end
        end
        return true
    end
    return n == 0
end

-- Stable sort of arr[1..n] by the precomputed `keys` (keys[i] belongs to arr[i]), which are ordered by `<` directly.
local function sortByKeys(arr, n, keys, descending)
    local src, dst = {}, {}
    for i = 1, n do
        src[i] = i
    end
    local width = 1
    while width < n do
        local i = 1
        while i <= n do
            local mid, hi = math.min(i + width, n + 1), math.min(i + 2 * width, n + 1)
            local a, b, k = i, mid, i
            if descending then
                while a < mid and b < hi do
                    local ia, ib = src[a], src[b]
                    if keys[ib] > keys[ia] then
                        dst[k] = ib
                        b = b + 1
                    else
                        dst[k] = ia
                        a = a + 1
                    end
                    k = k + 1
                end
            else
                while a < mid and b < hi do
                    local ia, ib = src[a], src[b]
                    if keys[ib] < keys[ia] then
                        dst[k] = ib
                        b = b + 1
                    else
                        dst[k] = ia
                        a = a + 1
                    end
                    k = k + 1
                end
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
    local out = {}
    for i = 1, n do
        out[i] = arr[src[i]]
    end
    return out
end

-- Sorting. On the JVM, sorted(), sortedWith(), sortedBy() and the sort functions of lists and arrays end in
-- java.util.Arrays.sort, a TimSort (see TimSort.lua): ported, so comparators, compareTo and the selectors of compareBy run
-- exactly as often and in the same order. Only elements whose comparison nobody can observe (numbers and strings in natural
-- order, keys of a selector the compiler knows to be pure) keep a merge sort with Lua's `<`: any stable sort gives the
-- same result. These return a sorted copy of arr[1..n] as a plain array.
local function timSorted(arr, n, compare)
    local out = {}
    for i = 1, n do
        out[i] = arr[i]
    end
    __K2L_TimSort(out, 1, n + 1, compare)
    return out
end

local function reverseNatural(a, b)
    return __K2L_Compare(b, a)
end

-- sorted(), sortedDescending(): compareTo, or Collections.reverseOrder() calling it with the arguments swapped
local function sortNatural(arr, n, descending)
    if directlyOrdered(arr, n) then
        return sortByKeys(arr, n, arr, descending)
    end
    return timSorted(arr, n, descending and reverseNatural or __K2L_Compare)
end

-- sortedBy(selector) is sortedWith(compareBy(selector)): the selector runs for both elements of every comparison
-- (b first for the descending order). `pure` (set by the compiler) allows computing each key once instead.
local function sortSelected(arr, n, selector, descending, pure)
    if pure then
        local keys = {}
        for i = 1, n do
            keys[i] = selector(arr[i])
        end
        if directlyOrdered(keys, n) then
            return sortByKeys(arr, n, keys, descending)
        end
    end
    if descending then
        return timSorted(arr, n, function(a, b) return __K2L_CompareValues(selector(b), selector(a)) end)
    end
    return timSorted(arr, n, function(a, b) return __K2L_CompareValues(selector(a), selector(b)) end)
end

local function illegalArgument(message)
    error(__K2L_IllegalArgumentException.new(message))
end

local function noSuchElement(message)
    error(__K2L_NoSuchElementException.new(message))
end

-- Kotlin's toList(), and the functions ending in optimizeReadOnlyList() (take, drop, distinct, ...), return EmptyList
-- for no elements and a Collections$SingletonList for one; toMutableList() always copies into an ArrayList.
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
    return optimizedList(out, n)
end

function __K2L_Iterable:toMutableSet()
    local arr, n = self:____array()
    local set = __K2L_Set.new()
    for i = 1, n do
        set:add(arr[i])
    end
    return set
end

-- toSet() is an EmptySet or a Collections$SingletonSet for up to one element, else a LinkedHashSet.
function __K2L_Iterable:toSet()
    local set = self:toMutableSet()
    if set.size <= 1 then
        return optimizedSet(set)
    end
    return set
end

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
function __K2L_Iterable:maxOfOrNull(selector) return select(2, extreme(self, selector, 1, true)) end
function __K2L_Iterable:minOfOrNull(selector) return select(2, extreme(self, selector, -1, true)) end

-- The list sorted() and the like return: toList() for at most one element (EmptyList, SingletonList), else the sorted array
-- seen through asList(), an Arrays$ArrayList. Arrays always give the Arrays$ArrayList.
local function sortedList(self, out, n)
    if n <= 1 and not inherits(self, __K2L_Array) then
        return optimizedList(out, n)
    end
    out.size = n
    return setmetatable(out, __K2L_FixedSizeList)
end

function __K2L_Iterable:sorted()
    local arr, n = self:____array()
    return sortedList(self, sortNatural(arr, n, false), n)
end

function __K2L_Iterable:sortedDescending()
    local arr, n = self:____array()
    return sortedList(self, sortNatural(arr, n, true), n)
end

function __K2L_Iterable:sortedBy(selector, pure)
    local arr, n = self:____array()
    return sortedList(self, sortSelected(arr, n, selector, false, pure), n)
end

function __K2L_Iterable:sortedByDescending(selector, pure)
    local arr, n = self:____array()
    return sortedList(self, sortSelected(arr, n, selector, true, pure), n)
end

-- `comparator` is a Lua function (a, b) -> Int, from a Kotlin lambda or compareBy.
function __K2L_Iterable:sortedWith(comparator)
    local arr, n = self:____array()
    return sortedList(self, timSorted(arr, n, comparator), n)
end

function __K2L_Iterable:reversed()
    local arr, n = self:____array()
    local out = {}
    for i = 1, n do
        out[i] = arr[n - i + 1]
    end
    if n <= 1 then
        return optimizedList(out, n)
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
    return optimizedList(out, m)
end

function __K2L_Iterable:takeLast(count)
    checkCount(count)
    local arr, n = self:____array()
    local out = {}
    local m = math.min(count, n)
    for i = 1, m do
        out[i] = arr[n - m + i]
    end
    return optimizedList(out, m)
end

function __K2L_Iterable:drop(count)
    checkCount(count)
    local arr, n = self:____array()
    local out, k = {}, 0
    for i = count + 1, n do
        k = k + 1
        out[k] = arr[i]
    end
    return optimizedList(out, k)
end

function __K2L_Iterable:dropLast(count)
    checkCount(count)
    local arr, n = self:____array()
    local out = {}
    local m = math.max(n - count, 0)
    for i = 1, m do
        out[i] = arr[i]
    end
    return optimizedList(out, m)
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
    local map = self:associate(function(pair) return pair end)
    local _, n = self:____array()
    if n <= 1 then
        return optimizedMap(map)
    end
    return map
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

-- toTypedArray() and toIntArray() and the like; `binary` is the array type's (Object[] when not known)
function __K2L_Iterable:toTypedArray(binary)
    local arr, n = self:____array()
    local out = {}
    for i = 1, n do
        out[i] = arr[i]
    end
    out.size = n
    return setmetatable(out, binary and __K2L_ArrayClassOf(binary) or __K2L_Array)
end

for name, binary in pairs({
    toIntArray = "[I", toLongArray = "[J", toDoubleArray = "[D", toBooleanArray = "[Z", toFloatArray = "[F", toCharArray = "[C",
    toShortArray = "[S", toByteArray = "[B",
}) do
    __K2L_Iterable[name] = function(self)
        return __K2L_Iterable.toTypedArray(self, binary)
    end
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

-- Array.asList(): an Arrays$ArrayList (a copy here, not a view of the array)
function __K2L_Iterable:asList()
    local arr, n = self:____array()
    local out = {}
    for i = 1, n do
        out[i] = arr[i]
    end
    out.size = n
    return setmetatable(out, __K2L_FixedSizeList)
end

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
    return setmetatable(out, arrayClass(self))
end

function __K2L_Iterable:sortedArrayDescending()
    local arr, n = self:____array()
    local out = sortNatural(arr, n, true)
    out.size = n
    return setmetatable(out, arrayClass(self))
end

function __K2L_Iterable:sortedArrayWith(comparator)
    local arr, n = self:____array()
    local out = timSorted(arr, n, comparator)
    out.size = n
    return setmetatable(out, arrayClass(self))
end

function __K2L_Iterable:reversedArray()
    local out = self:toMutableList()
    out:reverse()
    out.____modCount = nil
    return setmetatable(out, arrayClass(self))
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
    return setmetatable(out, arrayClass(self))
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
    return setmetatable(out, arrayClass(self))
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
local __K2L_CollectionIterator = __K2L_Class("java.util.Iterator")

-- Iterates over a snapshot, so remove() can change the source while iterating; like the JDK's HashMap and TreeMap
-- iterators, it knows at each element whether there is another one, and next() throws ConcurrentModificationException
-- when the source changed other than through this iterator. `keys` (the map's keys of a view's elements) makes remove()
-- remove the key of the current element from the view's map.
function __K2L_CollectionIterator:____init(source, items, count, keys)
    self.____source = source
    if items == nil then
        items, count = source:____array()
    end
    local copy = {}
    for i = 1, count do
        copy[i] = items[i]
    end
    self.____items, self.____count, self.____keys = copy, count, keys
    self.____position = 0
    self.____removed = 0
    self.____expected = source.____modCount
end

function __K2L_CollectionIterator:hasNext()
    return self.____position < self.____count
end

function __K2L_CollectionIterator:next()
    if self.____source.____modCount ~= self.____expected then
        __K2L_Comodification()
    end
    if self.____position >= self.____count then
        noSuchElement()
    end
    self.____position = self.____position + 1
    return self.____items[self.____position]
end

-- Removes the element last returned by next() from the source.
function __K2L_CollectionIterator:remove()
    local source, position = self.____source, self.____position
    if position == 0 or self.____lastRemoved == position then
        error(__K2L_IllegalStateException.new())
    end
    if source.____modCount ~= self.____expected then
        __K2L_Comodification()
    end
    if self.____keys ~= nil then
        source.____map:____removeKey(self.____keys[position])
    elseif source.removeAt ~= nil then
        source:removeAt(position - 1 - self.____removed)
    else
        source:remove(self.____items[position])
    end
    self.____removed = self.____removed + 1
    self.____lastRemoved = position
    self.____expected = source.____modCount
end

-- An ArrayList's iterator (ArrayList$Itr and the like) reads the list as it is: hasNext() compares the position with the
-- current size, and next() throws ConcurrentModificationException once the list changed other than through remove().
local __K2L_ListItr = __K2L_Class("java.util.ArrayList$Itr")

function __K2L_ListItr:____init(list)
    self.____list, self.____cursor, self.____last, self.____expected = list, 0, -1, list.____modCount
end

function __K2L_ListItr:hasNext()
    return self.____cursor ~= self.____list.size
end

function __K2L_ListItr:next()
    local list = self.____list
    if list.____modCount ~= self.____expected then
        __K2L_Comodification()
    end
    local i = self.____cursor
    if i >= list.size then
        noSuchElement()
    end
    self.____cursor, self.____last = i + 1, i
    return list[i + 1]
end

-- removes with the list's removeAt, which a subclass may override, as ArrayList.Itr.remove calls remove(index)
function __K2L_ListItr:remove()
    local list = self.____list
    if self.____last < 0 then
        error(__K2L_IllegalStateException.new())
    end
    if list.____modCount ~= self.____expected then
        __K2L_Comodification()
    end
    list:removeAt(self.____last)
    self.____cursor, self.____last = self.____last, -1
    self.____expected = list.____modCount
end

-- of the JVM's class for the collection (its ____iteratorClass, see "view and iterator classes" below)
function __K2L_Iterable:iterator()
    return (self.____iteratorClass or __K2L_CollectionIterator).new(self, self:____ownArray())
end

-- The collection's own elements: ____array(), unless a subclass's ____array() walks its overriding iterator(); and those
-- toArray() reads (AbstractCollection's iterates). See CollectionOverrides.
function __K2L_Iterable:____ownArray()
    return self:____array()
end

__K2L_Iterable.____toArray = __K2L_Iterable.____ownArray

------------------------------------------------------------------ List
__K2L_List = __K2L_Class("java.util.ArrayList", __K2L_Iterable)

-- ArrayList(), ArrayList(capacity) and ArrayList(elements), as the constructor of a class extending ArrayList calls it
function __K2L_List:____init(elements)
    self.size = 0
    self.____modCount = 0
    if type(elements) == "table" then
        __K2L_List.addAll(self, elements)
    end
end

function __K2L_List:____array()
    return self, self.size
end

__K2L_List.____modCount = 0

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

-- ArrayList.Itr.hasNext(): the loop goes on (and next() throws) unless its position is the list's size
function __K2L_List:____comodified(i)
    if i ~= self.size then
        __K2L_Comodification()
    end
    return true
end

function __K2L_List:toString()
    local parts = {}
    for i = 1, self.size do
        parts[i] = __K2L_Str(self[i])
    end
    return "[" .. table.concat(parts, ", ") .. "]"
end

function __K2L_List:equals(other)
    if not (type(other) == "table" and other.____array ~= nil and other.get ~= nil) or other.____notList then
        return false
    end
    local arr, n
    if other.____honorOverrides and getmetatable(self) ~= __K2L_List and other.listIterator ~= nil then
        -- AbstractList.equals walks the other list's listIterator() (ArrayList's, its iterator(): ____array)
        local it = other:listIterator()
        arr, n = {}, 0
        while it:hasNext() do
            n = n + 1
            arr[n] = it:next()
        end
    else
        arr, n = other:____array()
    end
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
    self.____modCount = self.____modCount + 1
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
    self.____modCount = self.____modCount + 1
end

-- Like java.util.ArrayList, the bulk and convenience operations do not call add, addAt or removeAt, which a subclass may
-- override.
-- the argument's toArray(): its storage, not its iterator (see CollectionOverrides)
local function toArray(elements)
    return (elements.____toArray or elements.____array)(elements)
end

function __K2L_List:addAll(elements)
    local arr, n = toArray(elements)
    local size = self.size
    for i = 1, n do
        self[size + i] = arr[i]
    end
    self.size = size + n
    self.____modCount = self.____modCount + 1
    return n > 0
end

function __K2L_List:addAllAt(index, elements)
    local arr, n = toArray(elements)
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
    self.____modCount = self.____modCount + 1
    return n > 0
end

function __K2L_List:removeAt(index)
    local value = __K2L_List.get(self, index)
    if self.____ownerRemove ~= nil then
        self.____ownerRemove(self.____owner, value)
    end
    for i = index + 1, self.size - 1 do
        self[i] = self[i + 1]
    end
    self[self.size] = nil
    self.size = self.size - 1
    self.____modCount = self.____modCount + 1
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

-- java.util.List.removeFirst/removeLast, which Kotlin 2.4 calls on JDK 21: the exception has no message
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
        elseif self.____ownerRemove ~= nil then
            self.____ownerRemove(self.____owner, v)
        end
    end
    for i = k + 1, n do
        self[i] = nil
    end
    self.size = k
    if k ~= n then
        self.____modCount = self.____modCount + 1
    end
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
    if self.____ownerRemove ~= nil then
        for i = 1, self.size do
            self.____ownerRemove(self.____owner, self[i])
        end
    end
    for i = 1, self.size do
        self[i] = nil
    end
    self.size = 0
    self.____modCount = self.____modCount + 1
end

local function sortInPlace(self, sorted)
    for i = 1, self.size do
        self[i] = sorted[i]
    end
end

-- ArrayList.sort and replaceAll count as a change (not those of a view, which set its elements); Collections.reverse
-- (set by index) does not.
local function changedInPlace(self)
    if rawget(self, "____root") == nil then
        self.____modCount = self.____modCount + 1
    end
end

local function sortedInPlace(self, sorted)
    sortInPlace(self, sorted)
    changedInPlace(self)
end

-- In place, as MutableList.sort*() do: Collections.sort, so the same comparisons as sorted*() (none for one element).
function __K2L_List:sort()
    local arr, n = self:____array()
    sortedInPlace(self, sortNatural(arr, n, false))
end

function __K2L_List:sortDescending()
    local arr, n = self:____array()
    sortedInPlace(self, sortNatural(arr, n, true))
end

function __K2L_List:sortBy(selector, pure)
    local arr, n = self:____array()
    sortedInPlace(self, sortSelected(arr, n, selector, false, pure))
end

function __K2L_List:sortByDescending(selector, pure)
    local arr, n = self:____array()
    sortedInPlace(self, sortSelected(arr, n, selector, true, pure))
end

function __K2L_List:sortWith(comparator)
    local arr, n = self:____array()
    sortedInPlace(self, timSorted(arr, n, comparator))
end

function __K2L_List:reverse() sortInPlace(self, self:reversed()) end

function __K2L_List:fill(value, from, to)
    for i = (from or 0) + 1, to or self.size do
        self[i] = value
    end
end

-- A live view of the list, see "subList views" below.
function __K2L_List:subList(from, to)
    if from < 0 then
        error(__K2L_IndexOutOfBoundsException.new("fromIndex = " .. from))
    elseif to > self.size then
        error(__K2L_IndexOutOfBoundsException.new("toIndex = " .. to))
    elseif from > to then
        illegalArgument("fromIndex(" .. from .. ") > toIndex(" .. to .. ")")
    end
    return self:____subList(from, to)
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

-- Deque.descendingIterator(): over a reversed snapshot
function __K2L_List:descendingIterator()
    return __K2L_CollectionIterator.new(self:reversed())
end

-- JDK 21's List.getFirst()/getLast()
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
    changedInPlace(self)
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

-- Arrays share the list representation but compare by identity, as on the JVM. Each array type has a class of its own
-- (__K2L_ArrayClassOf), named by the JVM's binary name (`[I` for an IntArray, `[Ljava.lang.String;` for an Array<String>),
-- given where the array is made, so that `is IntArray`, `x::class` and `javaClass` of an array held in an `Any` and its
-- toString() (`[I@1b`) are the JVM's. __K2L_Array itself is an Object[] (an array whose element type is not known).
__K2L_Array = __K2L_Class("Array", __K2L_List)
__K2L_Array.____arrayBinary, __K2L_Array.____binaryName = "[Ljava.lang.Object;", "[Ljava.lang.Object;"

local arrayClasses = {["[Ljava.lang.Object;"] = __K2L_Array}

local PRIMITIVE_ARRAYS = {
    I = {"IntArray", "int"}, J = {"LongArray", "long"}, D = {"DoubleArray", "double"}, F = {"FloatArray", "float"},
    Z = {"BooleanArray", "boolean"}, C = {"CharArray", "char"}, S = {"ShortArray", "short"}, B = {"ByteArray", "byte"},
}

-- The Java simple name of an array type: `int[]`, `String[]`, `int[][]`.
local function javaSimpleName(binary)
    local element = binary:sub(2)
    local primitive = PRIMITIVE_ARRAYS[element]
    if primitive ~= nil then
        return primitive[2] .. "[]"
    elseif element:sub(1, 1) == "[" then
        return javaSimpleName(element) .. "[]"
    end
    return element:sub(2, -2):match("[^.$]+$") .. "[]"
end

function __K2L_ArrayClassOf(binary)
    local cls = arrayClasses[binary]
    if cls == nil then
        cls = __K2L_Class(binary, __K2L_Array)
        if binary:sub(1, 1) ~= "[" then
            -- kotlin.UIntArray and the like: value classes over a primitive array
            local simple = binary:match("[^.]+$")
            cls.____arrayBinary, cls.____binaryName, cls.____simpleName = binary, binary, simple
            cls.____qualifiedName, cls.____javaSimpleName = binary, simple
            cls.toString = function(self)
                return simple .. "(storage=[" .. (simple == "ULongArray" and "J" or simple:sub(2, 2)) .. "@"
                    .. string.format("%x", __K2L_IdentityHash(self)) .. ")"
            end
        else
            local primitive = PRIMITIVE_ARRAYS[binary:sub(2)]
            local simple = primitive and primitive[1] or "Array"
            cls.____arrayBinary, cls.____binaryName, cls.____simpleName = binary, binary, simple
            cls.____qualifiedName = "kotlin." .. simple
            cls.____javaSimpleName = javaSimpleName(binary)
        end
        arrayClasses[binary] = cls
    end
    return cls
end

-- `is IntArray` (`binary` "[I") and `is Array<*>` (no `binary`: an array of objects)
local function __K2L_IsArray(value, binary)
    if not inherits(value, __K2L_Array) then
        return false
    end
    local actual = value.____arrayBinary
    if binary ~= nil then
        return actual == binary
    end
    return actual:sub(1, 1) == "[" and PRIMITIVE_ARRAYS[actual:sub(2)] == nil
end

-- the class for a copy of `self`: an array's own, else an Object[]
function arrayClass(self)
    if inherits(self, __K2L_Array) then
        return getmetatable(self)
    end
    return __K2L_Array
end

function __K2L_Array:equals(other)
    return rawequal(self, other)
end

-- Any.toString(): `[I@1b`, the class and the identity hash in hex
function __K2L_Array:toString()
    return self.____arrayBinary .. "@" .. string.format("%x", __K2L_IdentityHash(self))
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

------------------------------------------------------------------ read-only lists
-- listOf() and emptyList() are Kotlin's EmptyList, listOf(x) a Collections$SingletonList, listOf(a, b, ...) and asList()
-- an Arrays$ArrayList (the sorted*() results too): the ArrayList representation with the JVM's classes, index messages
-- and read-only behavior. Mutators throw UnsupportedOperationException, except where the JVM finds nothing to change
-- first (removing an absent element, clearing an empty list). An Arrays$ArrayList can still be written by index.
__K2L_EmptyList = __K2L_Class("kotlin.collections.EmptyList", __K2L_List)
__K2L_SingletonList = __K2L_Class("java.util.Collections$SingletonList", __K2L_List)
__K2L_FixedSizeList = __K2L_Class("java.util.Arrays$ArrayList", __K2L_List)

local function unsupported()
    error(__K2L_UnsupportedOperationException.new())
end

-- Makes the methods `names` of `cls` throw, and the removing ones throw when they would remove something; `removeMessage`
-- is the message of remove(element).
local function readOnly(cls, names, removeMessage)
    for _, name in ipairs(names) do
        cls[name] = unsupported
    end
    function cls:addAll(elements)
        local _, n = elements:____array()
        if n > 0 then
            unsupported()
        end
        return false
    end
    function cls:remove(element)
        if self:contains(element) then
            error(__K2L_UnsupportedOperationException.new(removeMessage))
        end
        return false
    end
    function cls:removeAll(predicate)
        if self:any(type(predicate) == "table" and function(it) return predicate:contains(it) end or predicate) then
            unsupported()
        end
        return false
    end
    cls.removeIf = cls.removeAll
    function cls:retainAll(predicate)
        if not self:all(type(predicate) == "table" and function(it) return predicate:contains(it) end or predicate) then
            unsupported()
        end
        return false
    end
    function cls:clear()
        if self.size > 0 then
            unsupported()
        end
    end
end

-- `fixedSize` keeps set and the in-place operations (sort, fill, ...) of an Arrays$ArrayList.
local function readOnlyList(cls, fixedSize)
    local names = {
        "add", "addAt", "addAllAt", "removeAt", "addFirst", "addLast", "removeFirstOrNull", "removeLastOrNull", "push", "pop", "poll",
        "pollFirst", "pollLast", "offer", "offerFirst", "offerLast",
    }
    if not fixedSize then
        for _, name in ipairs({"set", "fill", "replaceAll"}) do
            names[#names + 1] = name
        end
    end
    readOnly(cls, names, fixedSize and "remove" or nil)
    function cls:removeFirst()
        if self.size == 0 then
            noSuchElement()
        end
        unsupported()
    end
    cls.removeLast = cls.removeFirst
end
readOnlyList(__K2L_EmptyList, false)
readOnlyList(__K2L_SingletonList, false)
readOnlyList(__K2L_FixedSizeList, true)

-- Kotlin's own read-only collections are not MutableList/MutableSet/MutableMap (`is` and `as` see ____readOnly)
__K2L_EmptyList.____readOnly = true
local EMPTY_LIST = setmetatable({size = 0}, __K2L_EmptyList)

function __K2L_EmptyList:get(index)
    error(__K2L_IndexOutOfBoundsException.new("Empty list doesn't contain element at index " .. index .. "."))
end

function __K2L_SingletonList:get(index)
    if index ~= 0 then
        error(__K2L_IndexOutOfBoundsException.new("Index: " .. index .. ", Size: 1"))
    end
    return self[1]
end

__K2L_FixedSizeList.get = __K2L_Array.get

-- `arr[1..n]` (a fresh table) as the list Kotlin's optimizeReadOnlyList() gives: EmptyList, a SingletonList or an ArrayList.
function optimizedList(arr, n)
    if n == 0 then
        return EMPTY_LIST
    elseif n == 1 then
        arr.size = 1
        return setmetatable(arr, __K2L_SingletonList)
    end
    return newList(arr, n)
end

-- listOf(...) and emptyList(); listOf(x) with one argument is __K2L_SingletonListOf.
local function __K2L_ReadOnlyListOf(...)
    local n = select("#", ...)
    if n == 0 then
        return EMPTY_LIST
    end
    local arr = {...}
    arr.size = n
    return setmetatable(arr, __K2L_FixedSizeList)
end

local function __K2L_SingletonListOf(value)
    return setmetatable({value, size = 1}, __K2L_SingletonList)
end

local function __K2L_ListOf(...)
    return newList({...}, select("#", ...))
end

local function __K2L_ArrayOf(...)
    local arr = {...}
    arr.size = select("#", ...)
    return setmetatable(arr, __K2L_Array)
end

-- arrayOf(...), intArrayOf(...) and the like, of the array type `binary` (see __K2L_ArrayClassOf)
local function __K2L_TypedArrayOf(binary, ...)
    local arr = {...}
    arr.size = select("#", ...)
    return setmetatable(arr, arrayClasses[binary] or __K2L_ArrayClassOf(binary))
end

-- List(n) { init(it) } and Array(n) { ... }; also IntArray(n) with a constant initial value. `array` is the binary name of
-- the array type (or true for an Object[]), nil for a list.
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
    if not array then
        out.____modCount = 0
        return setmetatable(out, __K2L_List)
    end
    return setmetatable(out, array == true and __K2L_Array or arrayClasses[array] or __K2L_ArrayClassOf(array))
end

------------------------------------------------------------------ subList views
-- list.subList(from, to) is a live view: `view[i]` reads and writes `list[offset + i]`, so the view sees changes of the list
-- and writes go to it; adding and removing through the view change the list (with its addAt, addAllAt and removeAt, as the
-- JDK's views call them) and the sizes of the view and of the views it was made from. ArrayList's views are
-- ArrayList$SubList, which write elements directly; the read-only lists' are AbstractList$RandomAccessSubList and other
-- lists' AbstractList$SubList, whose set() calls the list's. A structural change of the list made other than through the
-- view (its ____modCount moved on) makes the view stale: reading its size or elements throws
-- ConcurrentModificationException, as the JDK's checkForComodification() does. A view's ____modCount is the list's, so
-- loops over the view notice changes of the list.
local __K2L_SubList = __K2L_Class("java.util.ArrayList$SubList", __K2L_List)
local __K2L_AbstractSubList = __K2L_Class("java.util.AbstractList$SubList", __K2L_SubList)
local __K2L_RandomAccessSubList = __K2L_Class("java.util.AbstractList$RandomAccessSubList", __K2L_AbstractSubList)

do
local function checkView(self)
    local root = rawget(self, "____root")
    if root.____modCount ~= rawget(self, "____expected") then
        __K2L_Comodification()
    end
    return root
end

local function viewIndex(self, key)
    if type(key) == "number" then
        local root = checkView(self)
        if key >= 1 and key <= rawget(self, "____size") then
            return root[rawget(self, "____offset") + key]
        end
        return nil
    elseif key == "size" then
        checkView(self)
        return rawget(self, "____size")
    elseif key == "____modCount" then
        return rawget(self, "____root").____modCount
    end
    return getmetatable(self)[key]
end

local function viewNewIndex(self, key, value)
    if type(key) == "number" then
        checkView(self)[rawget(self, "____offset") + key] = value
    else
        rawset(self, key, value)
    end
end

for _, cls in ipairs({__K2L_SubList, __K2L_AbstractSubList, __K2L_RandomAccessSubList}) do
    cls.__index, cls.__newindex = viewIndex, viewNewIndex
end

local function newView(cls, root, offset, size, parent)
    return setmetatable({
        ____root = root, ____offset = offset, ____size = size, ____parentView = parent, ____expected = root.____modCount,
    }, cls)
end

-- a list's views are of the class in its ____subListClass
function __K2L_List:____subList(from, to)
    return newView(self.____subListClass or __K2L_SubList, self, from, to - from, nil)
end

-- a view's views see the same list, and update this view's size as well
function __K2L_SubList:____subList(from, to)
    return newView(getmetatable(self), self.____root, self.____offset + from, to - from, self)
end

-- after a change made through `view`: it and the views it was made from see the list's new size and ____modCount
local function resize(view, delta)
    local modCount = rawget(view, "____root").____modCount
    while view ~= nil do
        rawset(view, "____size", rawget(view, "____size") + delta)
        rawset(view, "____expected", modCount)
        view = rawget(view, "____parentView")
    end
end

local function checkPosition(self, index)
    if index < 0 or index > self.size then
        error(__K2L_IndexOutOfBoundsException.new("Index: " .. index .. ", Size: " .. self.size))
    end
end

function __K2L_SubList:addAt(index, value)
    checkPosition(self, index)
    self.____root:addAt(self.____offset + index, value)
    resize(self, 1)
end

function __K2L_SubList:add(value)
    self:addAt(self.size, value)
    return true
end

function __K2L_SubList:addAllAt(index, elements)
    checkPosition(self, index)
    local _, n = elements:____array()
    if n == 0 then
        return false
    end
    self.____root:addAllAt(self.____offset + index, elements)
    resize(self, n)
    return true
end

function __K2L_SubList:addAll(elements)
    return self:addAllAt(self.size, elements)
end

function __K2L_SubList:removeAt(index)
    local value = self:get(index)
    self.____root:removeAt(self.____offset + index)
    resize(self, -1)
    return value
end

-- An element removed without calling anything (ArrayList$SubList's bulk removals), or with the list's removeAt.
function __K2L_SubList:____drop(index)
    __K2L_List.removeAt(self.____root, self.____offset + index)
    resize(self, -1)
end

function __K2L_AbstractSubList:____drop(index)
    self.____root:removeAt(self.____offset + index)
    resize(self, -1)
end

function __K2L_SubList:remove(value)
    local index = __K2L_Iterable.indexOf(self, value)
    if index < 0 then
        return false
    end
    self:____drop(index)
    return true
end

function __K2L_SubList:removeAll(predicate)
    if type(predicate) == "table" then
        local elements = predicate
        predicate = function(it) return elements:contains(it) end
    end
    local changed = false
    for i = self.size, 1, -1 do
        if predicate(self[i]) then
            self:____drop(i - 1)
            changed = true
        end
    end
    return changed
end

__K2L_SubList.removeIf = __K2L_SubList.removeAll

function __K2L_SubList:clear()
    for i = self.size - 1, 0, -1 do
        self:____drop(i)
    end
end

function __K2L_SubList:removeFirst()
    if self.size == 0 then
        noSuchElement()
    end
    return self:removeAt(0)
end

function __K2L_SubList:removeLast()
    if self.size == 0 then
        noSuchElement()
    end
    return self:removeAt(self.size - 1)
end

function __K2L_AbstractSubList:set(index, value)
    __K2L_List.get(self, index)
    return self.____root:set(self.____offset + index, value)
end
end

------------------------------------------------------------------ array views
-- Array.asList() is an Arrays$ArrayList that reads and writes the array; a primitive array's asList() is a read-only
-- Kotlin AbstractList over it (ArraysKt___ArraysJvmKt$asList$N, numbered by element type as the stdlib's classes are).
local __K2L_ArrayAsList = __K2L_Class("java.util.Arrays$ArrayList", __K2L_FixedSizeList)
local primitiveAsLists = {}

do
local function arrayIndex(self, key)
    if type(key) == "number" then
        return rawget(self, "____root")[key]
    end
    return getmetatable(self)[key]
end

local function arrayNewIndex(self, key, value)
    if type(key) == "number" then
        rawget(self, "____root")[key] = value
    else
        rawset(self, key, value)
    end
end

__K2L_ArrayAsList.__index, __K2L_ArrayAsList.__newindex = arrayIndex, arrayNewIndex
__K2L_FixedSizeList.____subListClass = __K2L_RandomAccessSubList
__K2L_SingletonList.____subListClass = __K2L_RandomAccessSubList

-- emptyList().subList(0, 0) is the EmptyList
function __K2L_EmptyList:____subList()
    return self
end

-- `kind` is the number of a primitive array's asList class (1 ByteArray, 2 ShortArray, 3 IntArray, 4 LongArray, 5 FloatArray,
-- 6 DoubleArray, 7 BooleanArray, 8 CharArray), nil for an Array.
function __K2L_Array:asList(kind)
    local cls = __K2L_ArrayAsList
    if kind ~= nil then
        cls = primitiveAsLists[kind]
        if cls == nil then
            cls = __K2L_Class("kotlin.collections.ArraysKt___ArraysJvmKt$asList$" .. kind, __K2L_List)
            readOnlyList(cls, false)
            cls.get = __K2L_Array.get
            cls.____readOnly = true
            cls.____subListClass = __K2L_RandomAccessSubList
            cls.__index, cls.__newindex = arrayIndex, function() unsupported() end
            primitiveAsLists[kind] = cls
        end
    end
    return setmetatable({____root = self, size = self.size}, cls)
end
end

------------------------------------------------------------------ hashed keys (Map and Set)
local NIL_KEY = {}

-- Finds the slot of `key`: raw lookup for plain values, hashCode buckets plus equals() for objects.
local function findSlot(self, key)
    local kind = type(key)
    if kind == "string" or kind == "number" then
        return self.____index[key]
    elseif (kind == "table" and key.hashCode ~= nil) or kind == "cdata" then
        -- cdata is an int64_t of --long64 emulate: table keys would compare it by identity
        local bucket = self.____buckets[kind == "cdata" and __K2L_Hash(key) or key:hashCode()]
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

-- Adding and removing keys are the structural changes of maps and sets (____modCount); rebuilding the lookup tables
-- (reindex, a TreeMap's rebuild) is not one.
local function addSlot(self, key)
    local slot = self.size + 1
    self.size = slot
    self.____modCount = self.____modCount + 1
    self.____keys[slot] = key
    local kind = type(key)
    if (kind == "table" and key.hashCode ~= nil) or kind == "cdata" then
        local h = kind == "cdata" and __K2L_Hash(key) or key:hashCode()
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
    local keys, values, n, modCount = self.____keys, self.____values, self.size, self.____modCount
    self.size = 0
    self.____keys = {}
    for i = 1, n do
        addSlot(self, keys[i])
    end
    self.____values, self.____modCount = values, modCount
end

-- Removes the entry at `slot`, keeping the insertion order. The entries after it move down one slot, and their
-- lookup entries are renumbered in place (no rehash of the map); only a key whose hashCode() changed since it was
-- added falls back to rebuilding the lookup tables.
local function removeSlot(self, slot)
    local n = self.size
    self.____modCount = self.____modCount + 1
    local keys, values, index, buckets = self.____keys, self.____values, self.____index, self.____buckets
    local removed = keys[slot]
    local stale = false
    if type(removed) == "table" and removed.hashCode ~= nil then
        local h = removed:hashCode()
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
    if next(buckets) == nil then
        -- only plain keys (numbers, strings, ...): the common case, without the hashed-key bookkeeping
        if values ~= nil then
            for i = slot, n - 1 do
                local key = keys[i + 1]
                keys[i] = key
                values[i] = values[i + 1]
                index[key == nil and NIL_KEY or key] = i
            end
            values[n] = nil
        else
            for i = slot, n - 1 do
                local key = keys[i + 1]
                keys[i] = key
                index[key == nil and NIL_KEY or key] = i
            end
        end
        keys[n] = nil
        self.size = n - 1
        return
    end
    for i = slot, n - 1 do
        local key = keys[i + 1]
        keys[i] = key
        if values ~= nil then
            values[i] = values[i + 1]
        end
        if type(key) == "table" and key.hashCode ~= nil then
            local bucket = buckets[key:hashCode()]
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

-- LinkedHashSet(), (capacity) and (elements): like the JVM's, the last calls add for each element (which a subclass may override).
function __K2L_Set:____init(elements)
    self.size = 0
    self.____keys, self.____index, self.____buckets = {}, {}, {}
    if type(elements) == "table" then
        self:addAll(elements)
    end
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
    if self.____ownerRemove ~= nil then
        self.____ownerRemove(self.____owner, value)
    end
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
    self.____modCount = self.____modCount + 1
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

-- setOf() and emptySet() are Kotlin's EmptySet, a set of one element from setOf or toSet() a Collections$SingletonSet,
-- other sizes a LinkedHashSet. Read-only like the lists above.
local __K2L_EmptySet = __K2L_Class("kotlin.collections.EmptySet", __K2L_Set)
local __K2L_SingletonSet = __K2L_Class("java.util.Collections$SingletonSet", __K2L_Set)
readOnly(__K2L_EmptySet, {"add"})
__K2L_EmptySet.____readOnly = true
readOnly(__K2L_SingletonSet, {"add"})
local EMPTY_SET = setmetatable(__K2L_Set.new(), __K2L_EmptySet)

-- `set` (a fresh LinkedHashSet of at most one element) as an EmptySet or a SingletonSet
function optimizedSet(set)
    if set.size == 0 then
        return EMPTY_SET
    end
    return setmetatable(set, __K2L_SingletonSet)
end

-- setOf(...) and emptySet(): Kotlin's setOf(vararg) is elements.toSet(), so the number of arguments decides
local function __K2L_ReadOnlySetOf(...)
    local set = __K2L_SetOf(...)
    if select("#", ...) <= 1 then
        return optimizedSet(set)
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
        self.____map:____setValue(self.key, value)
    end
    return old
end

function __K2L_Entry:hashCode()
    return __K2L_BXor(__K2L_Hash(self.key), __K2L_Hash(self.value))
end

function __K2L_Entry:equals(other)
    return inherits(other, __K2L_Entry) and __K2L_Equals(self.key, other.key) and __K2L_Equals(self.value, other.value)
end

__K2L_Map = __K2L_Class("java.util.LinkedHashMap")
__K2L_Map.__tostring = __K2L_Iterable.__tostring
__K2L_Map.____modCount = 0
__K2L_Map.____comodified = __K2L_Iterable.____comodified

-- LinkedHashMap(), (capacity), (map) and (nil, accessOrder) for LinkedHashMap(capacity, loadFactor, accessOrder); copying a
-- map does not call put, as on the JVM.
function __K2L_Map:____init(map, accessOrder)
    self.size = 0
    self.____keys, self.____values, self.____index, self.____buckets = {}, {}, {}, {}
    if type(map) == "table" then
        __K2L_Map.putAll(self, map)
    end
    if accessOrder then
        self.____accessOrder = true
    end
end

-- A LinkedHashMap in access order moves an entry to the end when get, getOrDefault or put reach it.
local function accessed(self, slot)
    if slot ~= self.size then
        local key, value = self.____keys[slot], self.____values[slot]
        removeSlot(self, slot)
        slot = addSlot(self, key)
        self.____values[slot] = value
    end
    return slot
end

-- for k, v in map:iter() do ... end, over the entries in order. Like the JDK's entry iterators it knew at each entry
-- whether there was another one: when the map changed meanwhile, the next step throws ConcurrentModificationException
-- (after the last entry the loop ends). With `whole` (Map.forEach { k, v -> }, which the JDK runs over the whole map) it
-- goes on over the map as it is and throws at the end instead.
function __K2L_Map:iter(whole)
    local i, modCount = 0, self.____modCount
    if whole then
        return function()
            i = i + 1
            if i <= self.size then
                return self.____keys[i], self.____values[i]
            end
            if self.____modCount ~= modCount then
                __K2L_Comodification()
            end
        end
    end
    local n = self.size
    return function()
        if self.____modCount ~= modCount then
            if i < n then
                __K2L_Comodification()
            end
            return nil
        end
        i = i + 1
        if i <= n then
            return self.____keys[i], self.____values[i]
        end
    end
end

-- The keys, values and entries in iteration order, as an array and its length: what the views and loops read. The keys
-- and values are the map's own arrays; the entries are made for each call, and write back to the map (setValue).
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
    local out, n = {}, self.size
    local keys, values = self.____keys, self.____values
    local cls = self.____views.entry
    for i = 1, n do
        out[i] = setmetatable({key = keys[i], value = values[i], ____map = self}, cls)
    end
    return out, n
end

-- what the views read: the map's own arrays, which a subclass overriding `entries` and the like does not change (the
-- arrays the loops read do, see CollectionOverrides)
__K2L_Map.____viewKeys, __K2L_Map.____viewValues = __K2L_Map.____keyArray, __K2L_Map.____valueArray
__K2L_Map.____viewEntries = __K2L_Map.____entryArray

-- Removes `key` without calling the map's (overridable) remove, as the JDK's views do; whether it was there.
function __K2L_Map:____removeKey(key)
    local slot = findSlot(self, key)
    if slot == nil then
        return false
    end
    removeSlot(self, slot)
    return true
end

-- Whether the map has `key`, and its value, without calling get (EntrySet.contains)
function __K2L_Map:____lookup(key)
    local slot = findSlot(self, key)
    if slot == nil then
        return false
    end
    return true, self.____values[slot]
end

-- Entry.setValue: the value of the key in place, without calling put
function __K2L_Map:____setValue(key, value)
    local slot = findSlot(self, key)
    if slot ~= nil then
        self.____values[slot] = value
    end
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
    return slot and self.____values[self.____accessOrder and accessed(self, slot) or slot]
end

function __K2L_Map:getOrDefault(key, default)
    local slot = findSlot(self, key)
    if slot == nil then
        return default
    end
    return self.____values[self.____accessOrder and accessed(self, slot) or slot]
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
        if self.____accessOrder then
            slot = accessed(self, slot)
        end
        local old = self.____values[slot]
        self.____values[slot] = value
        return old
    end
    slot = addSlot(self, key)
    self.____values[slot] = value
    if self.removeEldestEntry ~= nil then
        local eldest = __K2L_Entry.new(self.____keys[1], self.____values[1])
        eldest.____map = self
        if self:removeEldestEntry(eldest) then
            __K2L_Map.remove(self, eldest.key)
        end
    end
    return nil
end

__K2L_Map.____put = __K2L_Map.put

function __K2L_Map:set(key, value)
    self:put(key, value)
end

-- Accepts another map or a list of pairs.
-- `____put` is the class's own put: HashMap.putAll does not call put, which a subclass may override.
function __K2L_Map:putAll(other)
    if other.____isSequence then
        for _, pair in other:iter() do
            self:put(pair.first, pair.second)
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
    for k, v in other:iter() do
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

-- HashMap's putIfAbsent, merge, compute, computeIfAbsent and computeIfPresent work on the table: they call neither get,
-- put nor remove, which a subclass may override.
function __K2L_Map:putIfAbsent(key, value)
    local old = __K2L_Map.get(self, key)
    if old == nil then
        self:____put(key, value)
    end
    return old
end

function __K2L_Map:merge(key, value, remapping)
    local old = __K2L_Map.get(self, key)
    local result = value
    if old ~= nil then
        result = remapping(old, value)
    end
    if result == nil then
        __K2L_Map.remove(self, key)
    else
        self:____put(key, result)
    end
    return result
end

function __K2L_Map:compute(key, remapping)
    local result = remapping(key, __K2L_Map.get(self, key))
    if result == nil then
        __K2L_Map.remove(self, key)
    else
        self:____put(key, result)
    end
    return result
end

function __K2L_Map:computeIfAbsent(key, mapping)
    local old = __K2L_Map.get(self, key)
    if old == nil then
        old = mapping(key)
        if old ~= nil then
            self:____put(key, old)
        end
    end
    return old
end

function __K2L_Map:computeIfPresent(key, remapping)
    local old = __K2L_Map.get(self, key)
    if old == nil then
        return nil
    end
    local result = remapping(key, old)
    if result == nil then
        __K2L_Map.remove(self, key)
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
    self.____modCount = self.____modCount + 1
end

function __K2L_Map:isEmpty()
    return self.size == 0
end

function __K2L_Map:isNotEmpty()
    return self.size > 0
end

-- keys, values and entries are live views of the map (see "map views" below), made once per map as on the JVM, of the
-- JVM's classes for the map's class (its ____views).
function __K2L_Map:getKeys()
    local view = self.____keySet
    if view == nil then
        view = setmetatable({____map = self}, self.____views.keys)
        self.____keySet = view
    end
    return view
end

function __K2L_Map:getValues()
    local view = self.____valueCollection
    if view == nil then
        view = setmetatable({____map = self}, self.____views.values)
        self.____valueCollection = view
    end
    return view
end

function __K2L_Map:getEntries()
    local view = self.____entrySet
    if view == nil then
        view = setmetatable({____map = self}, self.____views.entries)
        self.____entrySet = view
    end
    return view
end

__K2L_Map.navigableKeySet = __K2L_Map.getKeys

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

-- Operations taking an entry lambda receive the entry; `forEach { k, v -> }` gets both.
function __K2L_Map:forEach(action)
    local entries, n = self:____entryArray()
    for i = 1, n do
        action(entries[i])
    end
end

-- Map.forEach(BiConsumer) runs over the whole map, then throws if it changed
function __K2L_Map:forEachKeyValue(action)
    local modCount, i = self.____modCount, 1
    while i <= self.size do
        action(self.____keys[i], self.____values[i])
        i = i + 1
    end
    if self.____modCount ~= modCount then
        __K2L_Comodification()
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
    return optimizedList(out, self.size)
end

function __K2L_Map:toMutableMap()
    local out = __K2L_Map.new()
    out:putAll(self)
    return out
end

function __K2L_Map:toMap()
    return optimizedMap(self:toMutableMap())
end

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

-- emptyMap() and mapOf() are Kotlin's EmptyMap, mapOf(pair) and toMap() of one entry a Collections$SingletonMap; their
-- mutators throw (removing an absent key or clearing an empty map does nothing).
local __K2L_EmptyMap = __K2L_Class("kotlin.collections.EmptyMap", __K2L_Map)
local __K2L_SingletonMap = __K2L_Class("java.util.Collections$SingletonMap", __K2L_Map)
local function readOnlyMap(cls)
    for _, name in ipairs({
        "put", "set", "putAll", "putIfAbsent", "merge", "compute", "computeIfAbsent", "computeIfPresent", "replaceAll", "getOrPut",
    }) do
        cls[name] = unsupported
    end
    function cls:remove(key)
        if self:containsKey(key) then
            unsupported()
        end
        return nil
    end
    function cls:clear()
        if self.size > 0 then
            unsupported()
        end
    end
end
readOnlyMap(__K2L_EmptyMap)
__K2L_EmptyMap.____readOnly = true
readOnlyMap(__K2L_SingletonMap)
local EMPTY_MAP = setmetatable(__K2L_Map.new(), __K2L_EmptyMap)

-- `map` (a fresh LinkedHashMap) as Kotlin's toMap() returns it: EmptyMap, a SingletonMap, or the map itself
function optimizedMap(map)
    if map.size == 0 then
        return EMPTY_MAP
    elseif map.size == 1 then
        return setmetatable(map, __K2L_SingletonMap)
    end
    return map
end

-- mapOf(...) and emptyMap(); mapOf(pair) with one argument is __K2L_SingletonMapOf.
local function __K2L_ReadOnlyMapOf(...)
    if select("#", ...) == 0 then
        return EMPTY_MAP
    end
    return __K2L_MapOf(...)
end

local function __K2L_SingletonMapOf(pair)
    return setmetatable(__K2L_MapOf(pair), __K2L_SingletonMap)
end

-- Makes a "list", "set" or "map" class read-only like the ones above (for java.util.Collections' own).
local function __K2L_MakeReadOnly(cls, kind)
    if kind == "list" then
        readOnlyList(cls, false)
    elseif kind == "set" then
        readOnly(cls, {"add"})
    else
        readOnlyMap(cls)
    end
    return cls
end

------------------------------------------------------------------ ranges
__K2L_IntRange = __K2L_Class("kotlin.ranges.IntRange", __K2L_Iterable)
__K2L_IntRange.____readOnly = true -- a Kotlin Iterable, not a MutableIterable

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
__K2L_CharRange.____readOnly = true

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

-- `format` prints the bounds of a range of Doubles or Floats (an integral Double is an integer before Lua 5.3)
function __K2L_ClosedRange:____init(first, last, format)
    self.first = first
    self.last = last
    self.____format = format
end

function __K2L_ClosedRange:contains(value)
    return __K2L_Compare(value, self.first) >= 0 and __K2L_Compare(value, self.last) <= 0
end

function __K2L_ClosedRange:isEmpty()
    return __K2L_Compare(self.first, self.last) > 0
end

function __K2L_ClosedRange:toString()
    local format = self.____format or __K2L_Str
    return format(self.first) .. ".." .. format(self.last)
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
    if isComparator(comparatorOrElements) then
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

-- contains reads the heap; equals and hashCode are Object's
function __K2L_PriorityQueue:contains(value)
    for i = 1, self.size do
        if __K2L_Equals(self.____heap[i], value) then
            return true
        end
    end
    return false
end

__K2L_PriorityQueue.equals, __K2L_PriorityQueue.hashCode = rawequal, __K2L_IdentityHash

-- PriorityQueue.Itr.hasNext() is cursor < size
function __K2L_PriorityQueue:____comodified(i)
    if i < self.size then
        __K2L_Comodification()
    end
    return true
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

function __K2L_PriorityQueue:offer(element)
    if element == nil then
        error(__K2L_NullPointerException.new())
    end
    local k = self.size
    self.size = k + 1
    self.____modCount = self.____modCount + 1
    siftUp(self, k, element)
    return true
end

-- as in the JDK, add calls offer and addAll calls add, which a subclass may override
function __K2L_PriorityQueue:add(element)
    return self:offer(element)
end

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
    local head = self:peek()
    if head == nil then
        noSuchElement()
    end
    return head
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
    self.____modCount = self.____modCount + 1
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
    self.____modCount = self.____modCount + 1
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

-- remove() (AbstractQueue's: poll(), failing when that finds nothing)
function __K2L_PriorityQueue:removeHead()
    local head = self:poll()
    if head == nil then
        noSuchElement()
    end
    return head
end

-- remove(element) removes one occurrence
function __K2L_PriorityQueue:remove(element)
    local i = self:indexOf(element)
    if i < 0 then
        return false
    end
    removeIndex(self, i)
    return true
end

-- removes the matching elements and heapifies the rest in their order, as the JDK's bulkRemove does
function __K2L_PriorityQueue:removeAll(predicate)
    if type(predicate) ~= "function" then
        local elements = predicate
        predicate = function(it) return elements:contains(it) end
    end
    local kept, n = {}, 0
    for i = 1, self.size do
        if not predicate(self.____heap[i]) then
            n = n + 1
            kept[n] = self.____heap[i]
        end
    end
    local changed = n ~= self.size
    self.____heap, self.size = kept, n
    if changed then
        self.____modCount = self.____modCount + 1
    end
    for i = math.floor(n / 2) - 1, 0, -1 do
        siftDown(self, i, kept[i + 1])
    end
    return changed
end

__K2L_PriorityQueue.removeIf = __K2L_PriorityQueue.removeAll

function __K2L_PriorityQueue:clear()
    self.____heap = {}
    self.size = 0
    self.____modCount = self.____modCount + 1
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
    if isComparator(comparatorOrMap) then
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
    if at <= n and self.____compare(keys[at], key) == 0 then
        local old = values[at]
        values[at] = value
        return old
    end
    shiftRight(keys, n, at)
    shiftRight(values, n, at)
    keys[at], values[at] = key, value
    rebuild(self, keys, n + 1)
    self.____values = values
    return nil
end

__K2L_SortedMap.____put = __K2L_SortedMap.put

-- Whether `other` is a TreeMap or TreeSet ordered like `self`: copying it into an empty one calls nothing, as in the JDK.
local function sameOrder(self, other, cls)
    return self.size == 0 and inherits(other, cls) and rawequal(other.____compare, self.____compare)
end

-- put for each entry, as AbstractMap.putAll does
function __K2L_SortedMap:putAll(other)
    if sameOrder(self, other, __K2L_SortedMap) then
        for k, v in other:iter() do
            __K2L_SortedMap.put(self, k, v)
        end
        return
    end
    __K2L_Map.putAll(self, other)
end

function __K2L_SortedMap:____put(key, value)
    return self:put(key, value)
end

-- Map.getOrDefault: get, then containsKey for a missing value
function __K2L_SortedMap:getOrDefault(key, default)
    local value = self:get(key)
    if value ~= nil or self:containsKey(key) then
        return value
    end
    return default
end

-- TreeMap's own putIfAbsent, merge, compute, computeIfAbsent and computeIfPresent call neither get nor put.
local function ownGet(self, key)
    return __K2L_Map.get(self, key)
end

function __K2L_SortedMap:putIfAbsent(key, value)
    local old = ownGet(self, key)
    if old == nil then
        __K2L_SortedMap.put(self, key, value)
    end
    return old
end

function __K2L_SortedMap:merge(key, value, remapping)
    local old = ownGet(self, key)
    local result = old == nil and value or remapping(old, value)
    if result == nil then
        __K2L_Map.remove(self, key)
    else
        __K2L_SortedMap.put(self, key, result)
    end
    return result
end

function __K2L_SortedMap:compute(key, remapping)
    local result = remapping(key, ownGet(self, key))
    if result == nil then
        __K2L_Map.remove(self, key)
    else
        __K2L_SortedMap.put(self, key, result)
    end
    return result
end

function __K2L_SortedMap:computeIfAbsent(key, mapping)
    local old = ownGet(self, key)
    if old == nil then
        old = mapping(key)
        if old ~= nil then
            __K2L_SortedMap.put(self, key, old)
        end
    end
    return old
end

function __K2L_SortedMap:computeIfPresent(key, remapping)
    local old = ownGet(self, key)
    if old == nil then
        return nil
    end
    local result = remapping(key, old)
    if result == nil then
        __K2L_Map.remove(self, key)
    else
        __K2L_SortedMap.put(self, key, result)
    end
    return result
end

function __K2L_SortedMap:clear()
    local compare = self.____compare
    __K2L_Map.____init(self)
    self.____compare = compare
    self.____modCount = self.____modCount + 1
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
        __K2L_Map.remove(self, entry.key)
    end
    return entry
end

function __K2L_SortedMap:pollLastEntry()
    local entry = entryAt(self, self.size)
    if entry ~= nil then
        entry.____map = nil
        __K2L_Map.remove(self, entry.key)
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

-- descendingMap() is a live view of the map in reverse order (TreeMap$DescendingSubMap): its methods run on a reversed
-- copy (a TreeMap ordered the other way, rebuilt from the map for each call), whose writes go to the map. Its size and
-- ____modCount are the map's, and its keys, values and entries are views of the view.
local DescendingMap = __K2L_Class("java.util.TreeMap$DescendingSubMap", __K2L_SortedMap)
local ReversedCopy = __K2L_Class("java.util.TreeMap", __K2L_SortedMap)
local DESCENDING_OWN = {
    getKeys = true, getValues = true, getEntries = true, navigableKeySet = true, descendingKeySet = true, descendingMap = true,
}

local function reversedCopy(view)
    local root = rawget(view, "____root")
    local copy = rawget(view, "____copy")
    if copy == nil then
        local compare = root.____compare
        copy = setmetatable({____root = root}, ReversedCopy)
        copy.____compare = function(a, b) return compare(b, a) end
        rawset(view, "____copy", copy)
    end
    __K2L_Map.____init(copy)
    local keys, values, n = root.____keys, root.____values, root.size
    for i = n, 1, -1 do
        copy.____values[addSlot(copy, keys[i])] = values[i]
    end
    return copy
end

local wrapped = {}

DescendingMap.__index = function(self, key)
    if key == "size" then
        return rawget(self, "____root").size
    elseif key == "____modCount" then
        return rawget(self, "____root").____modCount
    end
    local member = DescendingMap[key]
    if type(member) ~= "function" or DESCENDING_OWN[key] then
        return member
    end
    local forward = wrapped[key]
    if forward == nil then
        forward = function(view, ...)
            local copy = reversedCopy(view)
            return copy[key](copy, ...)
        end
        wrapped[key] = forward
    end
    return forward
end

-- the copy's writes go to the map (pollFirstEntry of the reversed order is the map's pollLastEntry)
for _, name in ipairs({
    "put", "set", "remove", "clear", "putAll", "putIfAbsent", "merge", "compute", "computeIfAbsent", "computeIfPresent",
    "replaceAll", "____removeKey", "____setValue",
}) do
    ReversedCopy[name] = function(copy, ...)
        local root = copy.____root
        return root[name](root, ...)
    end
end

function ReversedCopy:pollFirstEntry()
    return self.____root:pollLastEntry()
end

function ReversedCopy:pollLastEntry()
    return self.____root:pollFirstEntry()
end

function __K2L_SortedMap:descendingMap()
    return setmetatable({____root = self}, DescendingMap)
end

-- the reverse of the reverse order is the map's
function DescendingMap:descendingMap()
    return self.____root
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
    if isComparator(comparatorOrElements) then
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
    -- the comparator decides what is a duplicate, as in a java.util.TreeSet
    if at <= n and self.____compare(keys[at], value) == 0 then
        return false
    end
    shiftRight(keys, n, at)
    keys[at] = value
    rebuild(self, keys, n + 1)
    return true
end

-- add for each element (AbstractCollection.addAll), except into an empty set from a sorted one with the same order
function __K2L_SortedSet:addAll(elements)
    if sameOrder(self, elements, __K2L_SortedSet) then
        local arr, n = elements:____array()
        for i = 1, n do
            __K2L_SortedSet.add(self, arr[i])
        end
        return n > 0
    end
    return __K2L_Set.addAll(self, elements)
end

function __K2L_SortedSet:clear()
    local compare = self.____compare
    __K2L_Set.____init(self)
    self.____compare = compare
    self.____modCount = self.____modCount + 1
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
        __K2L_Set.remove(self, value)
    end
    return value
end

function __K2L_SortedSet:pollLast()
    local value = keyAt(self, self.size)
    if value ~= nil then
        __K2L_Set.remove(self, value)
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

-- a TreeSet in the reverse order (a copy; the JVM's is a view of the set)
function __K2L_SortedSet:descendingSet()
    local compare = self.____compare
    local out = __K2L_SortedSet.new(function(a, b) return compare(b, a) end)
    for i = self.size, 1, -1 do
        addSlot(out, self.____keys[i])
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
    return setmetatable(__K2L_Iterable.plus(self, element), getmetatable(self))
end

function __K2L_Array:plusAll(elements)
    return setmetatable(__K2L_Iterable.plusAll(self, elements), getmetatable(self))
end

function __K2L_Array:sliceArray(indices)
    return setmetatable(self:slice(indices), getmetatable(self))
end

-- Arrays.deepHashCode / deepEquals: nested arrays by content, other elements by hashCode()/equals()
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

-- (h ^ (h >>> 16)) & (capacity - 1) for a power-of-two capacity, from the low bits of both halves
local function bucketOf(key, capacity)
    local h = __K2L_Hash(key)
    return __K2L_BXor(h % capacity, __K2L_Ushr(h, 16) % capacity)
end

-- Puts the keys (and values) in iteration order; new entries were appended, so a stable sort by
-- bucket leaves older entries of a bucket ahead of newer ones, as the chains of a HashMap do. The sort counts the
-- entries of each bucket (the buckets in order are a loop over the capacity, or a sort of the used ones when the
-- capacity is much larger than the size), then moves every entry to its place.
local function normalize(self)
    self.____dirty = false
    local n, keys, values = self.size, self.____keys, self.____values
    local capacity, bucket, count = self.____capacity, {}, {}
    for i = 1, n do
        local b = bucketOf(keys[i], capacity) + 1
        bucket[i] = b
        count[b] = (count[b] or 0) + 1
    end
    local pos = 1
    if capacity <= 4 * n + 64 then
        for b = 1, capacity do
            local c = count[b]
            if c ~= nil then
                count[b], pos = pos, pos + c
            end
        end
    else
        local used, m = {}, 0
        for b in pairs(count) do
            m = m + 1
            used[m] = b
        end
        table.sort(used)
        for j = 1, m do
            local b = used[j]
            count[b], pos = pos, pos + count[b]
        end
    end
    local newKeys, newValues = {}, values and {} or nil
    for i = 1, n do
        local b = bucket[i]
        local at = count[b]
        count[b] = at + 1
        newKeys[at] = keys[i]
        if values ~= nil then
            newValues[at] = values[i]
        end
    end
    self.____keys, self.____values = newKeys, newValues
    if next(self.____buckets) == nil then
        -- only plain keys: their slots are renumbered in place
        local index = self.____index
        for i = 1, n do
            local key = newKeys[i]
            index[key == nil and NIL_KEY or key] = i
        end
    else
        reindex(self)
    end
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
        __K2L_Map.putAll(self, capacityOrMap)
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

__K2L_HashMap.____put = __K2L_HashMap.put

function __K2L_HashMap:clear()
    local capacity = self.____capacity
    __K2L_Map.____init(self)
    self.____capacity, self.____dirty = capacity, false
    self.____modCount = self.____modCount + 1
end

ordered(__K2L_HashMap, __K2L_Map, {
    "iter", "____keyArray", "____valueArray", "____entryArray", "____arrays", "____viewKeys", "____viewValues", "____viewEntries",
    "toString", "forEach", "forEachKeyValue", "filter", "mapValues",
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
    self.____modCount = self.____modCount + 1
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

local __K2L_ListBuilder
local __K2L_ListBuilderOf
local __K2L_SetBuilderOf
local __K2L_MapBuilderOf

------------------------------------------------------------------ view and iterator classes
-- The JVM's classes of iterators (`iterator()` makes an instance of the collection's ____iteratorClass) and of a map's
-- keys, values and entries (each map class's ____views).
do
local function iterators(cls, name, base)
    cls.____iteratorClass = __K2L_Class(name, base or __K2L_CollectionIterator)
end

iterators(__K2L_List, "java.util.ArrayList$Itr", __K2L_ListItr)
iterators(__K2L_FixedSizeList, "java.util.Arrays$ArrayItr")
iterators(__K2L_SingletonList, "java.util.Collections$1")
iterators(__K2L_EmptyList, "kotlin.collections.EmptyIterator")
iterators(__K2L_Array, "kotlin.jvm.internal.ArrayIterator")
iterators(__K2L_SubList, "java.util.ArrayList$SubList$1", __K2L_ListItr)
iterators(__K2L_AbstractSubList, "java.util.AbstractList$Itr", __K2L_ListItr)
iterators(__K2L_Set, "java.util.LinkedHashMap$LinkedKeyIterator")
iterators(__K2L_HashSet, "java.util.HashMap$KeyIterator")
iterators(__K2L_SortedSet, "java.util.TreeMap$KeyIterator")
iterators(__K2L_EmptySet, "kotlin.collections.EmptyIterator")
iterators(__K2L_SingletonSet, "java.util.Collections$1")
iterators(__K2L_PriorityQueue, "java.util.PriorityQueue$Itr")
iterators(__K2L_IntRange, "kotlin.ranges.IntProgressionIterator")

------------------------------------------------------------------ map views
-- A map's keys, values and entries are live views: they hold only the map (____map) and read it on every use through its
-- ____keyArray, ____valueArray and ____entryArray, so they see later changes of the map, and their size and ____modCount
-- are the map's. As in the JDK, removing from them (remove, removeAll, retainAll, removeIf, clear, their iterators'
-- remove()) removes the entries from the map without calling its remove, and adding throws UnsupportedOperationException.
-- The keys and the entries are sets; the values are a plain Collection (not a List), equal to itself only.
local KeysView = __K2L_Class("java.util.AbstractSet", __K2L_Iterable)
local ValuesView = __K2L_Class("java.util.AbstractCollection", __K2L_Iterable)
local EntriesView = __K2L_Class("java.util.AbstractSet", __K2L_Iterable)
KeysView.____interfaces[__K2L_Set] = true
EntriesView.____interfaces[__K2L_Set] = true

-- `size` and `____modCount` of a view are the map's.
local function viewIndex(cls)
    cls.__index = function(self, key)
        if key == "size" then
            return rawget(self, "____map").size
        elseif key == "____modCount" then
            return rawget(self, "____map").____modCount
        end
        return cls[key]
    end
end

function KeysView:____array()
    return self.____map:____viewKeys()
end

function ValuesView:____array()
    return self.____map:____viewValues()
end

function EntriesView:____array()
    return self.____map:____viewEntries()
end

local function copyOf(arr, n)
    local out = {}
    for i = 1, n do
        out[i] = arr[i]
    end
    return out
end

-- The view's elements and the map's keys they belong to, as copies.
local function snapshot(self)
    local items, n = self:____array()
    local keys = self.____map:____viewKeys()
    return copyOf(items, n), n, copyOf(keys, n)
end

-- an iterator over a snapshot whose remove() removes the current key from the map
local function viewIterator(self)
    local items, n, keys = snapshot(self)
    return self.____iteratorClass.new(self, items, n, keys)
end

KeysView.iterator, ValuesView.iterator, EntriesView.iterator = viewIterator, viewIterator, viewIterator

-- Removes the entries whose element `matches` (or does not, when `keep`); whether any was removed.
local function removeMatching(self, matches, keep)
    local items, n, keys = snapshot(self)
    local map, changed = self.____map, false
    for i = 1, n do
        if (matches(items[i]) and true or false) ~= keep then
            map:____removeKey(keys[i])
            changed = true
        end
    end
    return changed
end

local function matcher(elements)
    if type(elements) == "function" then
        return elements
    end
    return function(it) return elements:contains(it) end
end

local function viewRemoveAll(self, elements)
    return removeMatching(self, matcher(elements), false)
end

local function viewRetainAll(self, elements)
    return removeMatching(self, matcher(elements), true)
end

local function viewClear(self)
    self.____map:clear()
end

local function viewIsEmpty(self)
    return self.____map.size == 0
end

local function viewToString(self)
    local items, n = self:____array()
    local parts = {}
    for i = 1, n do
        parts[i] = __K2L_Str(items[i])
    end
    return "[" .. table.concat(parts, ", ") .. "]"
end

-- AbstractSet.equals: another set of the same size whose elements this one contains
local function setEquals(self, other)
    if rawequal(self, other) then
        return true
    end
    if not inherits(other, __K2L_Set) or other.size ~= self.size then
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

local function setHash(self)
    local items, n = self:____array()
    local h = 0
    for i = 1, n do
        h = __K2L_ToInt32(h + __K2L_Hash(items[i]))
    end
    return h
end

for _, view in ipairs({KeysView, ValuesView, EntriesView}) do
    view.removeAll, view.removeIf, view.retainAll, view.clear = viewRemoveAll, viewRemoveAll, viewRetainAll, viewClear
    view.isEmpty, view.toString = viewIsEmpty, viewToString
    view.add, view.addAll = unsupported, unsupported
end
for _, view in ipairs({KeysView, EntriesView}) do
    view.equals, view.hashCode = setEquals, setHash
    view.plus, view.plusAll, view.minus, view.minusAll = __K2L_Set.plus, __K2L_Set.plusAll, __K2L_Set.minus, __K2L_Set.minusAll
end
ValuesView.equals, ValuesView.hashCode = rawequal, __K2L_IdentityHash

function KeysView:contains(key)
    return self.____map:containsKey(key)
end

function KeysView:remove(key)
    return self.____map:____removeKey(key)
end

-- AbstractCollection.contains/remove of HashMap$Values and the like: containsValue, and the first entry with the value
function ValuesView:contains(value)
    return self.____map:containsValue(value)
end

function ValuesView:remove(value)
    local items, n, keys = snapshot(self)
    for i = 1, n do
        if __K2L_Equals(items[i], value) then
            return self.____map:____removeKey(keys[i])
        end
    end
    return false
end

-- an entry whose key the map has, with an equal value
function EntriesView:contains(entry)
    if not inherits(entry, __K2L_Entry) then
        return false
    end
    local found, value = self.____map:____lookup(entry.key)
    return found and __K2L_Equals(value, entry.value)
end

function EntriesView:remove(entry)
    if self:contains(entry) then
        return self.____map:____removeKey(entry.key)
    end
    return false
end

-- `prefix` is the map's binary class name; `keys`, `values` and `entries` are the names of its view classes (nested classes
-- of the map's class), `entry` that of its entries, and the iterator names those of the views.
local function views(map, prefix, names)
    local function nested(name)
        return name:find(".", 1, true) and name or prefix .. "$" .. name
    end
    local keys = __K2L_Class(nested(names.keys), KeysView)
    local values = __K2L_Class(nested(names.values), ValuesView)
    local entries = __K2L_Class(nested(names.entries), EntriesView)
    for _, cls in ipairs({keys, values, entries}) do
        viewIndex(cls)
    end
    iterators(keys, nested(names.keyIterator))
    iterators(values, nested(names.valueIterator))
    iterators(entries, nested(names.entryIterator))
    map.____views = {keys = keys, values = values, entries = entries, entry = __K2L_Class(nested(names.entry), __K2L_Entry)}
end

views(__K2L_Map, "java.util.LinkedHashMap", {
    keys = "LinkedKeySet", values = "LinkedValues", entries = "LinkedEntrySet", entry = "Entry",
    keyIterator = "LinkedKeyIterator", valueIterator = "LinkedValueIterator", entryIterator = "LinkedEntryIterator",
})
views(__K2L_HashMap, "java.util.HashMap", {
    keys = "KeySet", values = "Values", entries = "EntrySet", entry = "Node",
    keyIterator = "KeyIterator", valueIterator = "ValueIterator", entryIterator = "EntryIterator",
})
views(__K2L_SortedMap, "java.util.TreeMap", {
    keys = "KeySet", values = "Values", entries = "EntrySet", entry = "Entry",
    keyIterator = "KeyIterator", valueIterator = "ValueIterator", entryIterator = "EntryIterator",
})

-- A TreeMap's keys are a NavigableSet over the map (navigableKeySet(), descendingKeySet()).
local treeKeys = __K2L_SortedMap.____views.keys
treeKeys.____interfaces[__K2L_SortedSet] = true

function treeKeys:descendingSet()
    return self.____map:descendingMap():getKeys()
end

for set, map in pairs({floor = "floorKey", lower = "lowerKey", ceiling = "ceilingKey", higher = "higherKey"}) do
    treeKeys[set] = function(self, key)
        return self.____map[map](self.____map, key)
    end
end

for set, map in pairs({pollFirst = "pollFirstEntry", pollLast = "pollLastEntry"}) do
    treeKeys[set] = function(self)
        local entry = self.____map[map](self.____map)
        return entry and entry.key
    end
end

-- The views of a Collections$SingletonMap are singleton sets, Collections.singleton(key) and the like (its entry an
-- AbstractMap$SimpleImmutableEntry); those of Kotlin's EmptyMap are EmptySet and EmptyList.
local SimpleImmutableEntry = __K2L_Class("java.util.AbstractMap$SimpleImmutableEntry", __K2L_Entry)
SimpleImmutableEntry.setValue = unsupported
__K2L_SingletonMap.____views = {entry = SimpleImmutableEntry}

function __K2L_SingletonMap:getKeys()
    return optimizedSet(__K2L_SetOf(self.____keys[1]))
end

function __K2L_SingletonMap:getValues()
    return optimizedSet(__K2L_SetOf(self.____values[1]))
end

function __K2L_SingletonMap:getEntries()
    local entries = self:____entryArray()
    return optimizedSet(__K2L_SetOf(entries[1]))
end

function __K2L_EmptyMap:getKeys()
    return EMPTY_SET
end

__K2L_EmptyMap.getEntries = __K2L_EmptyMap.getKeys

function __K2L_EmptyMap:getValues()
    return EMPTY_LIST
end

------------------------------------------------------------------ builders
-- buildList { }, buildSet { } and buildMap { } fill a ListBuilder, SetBuilder or MapBuilder (kotlin.collections.builders),
-- which ____build() makes read-only after the block, as Kotlin's build() does: the object keeps its class name and stays
-- a MutableList (`is` is true), but every mutator throws UnsupportedOperationException, also through its views and
-- iterators, and also when it would change nothing (the in-place operations that set elements one by one throw once
-- they would set one).
local NAMESPACE = "kotlin.collections.builders."

__K2L_ListBuilder = __K2L_Class(NAMESPACE .. "ListBuilder", __K2L_List)
local SetBuilder = __K2L_Class(NAMESPACE .. "SetBuilder", __K2L_Set)
local MapBuilder = __K2L_Class(NAMESPACE .. "MapBuilder", __K2L_Map)
iterators(__K2L_ListBuilder, NAMESPACE .. "ListBuilder$Itr", __K2L_ListItr)
local BuilderSubList = __K2L_Class(NAMESPACE .. "ListBuilder$BuilderSubList", __K2L_SubList)
BuilderSubList.__index, BuilderSubList.__newindex = __K2L_SubList.__index, __K2L_SubList.__newindex
__K2L_ListBuilder.____subListClass = BuilderSubList
iterators(BuilderSubList, NAMESPACE .. "ListBuilder$Itr", __K2L_ListItr)
iterators(SetBuilder, NAMESPACE .. "MapBuilder$KeysItr")
views(MapBuilder, NAMESPACE .. "MapBuilder", {
    keys = NAMESPACE .. "MapBuilderKeys", values = NAMESPACE .. "MapBuilderValues", entries = NAMESPACE .. "MapBuilderEntries",
    entry = "EntryRef", keyIterator = "KeysItr", valueIterator = "ValuesItr", entryIterator = "EntriesItr",
})

-- the read-only class of a builder after build(): the builder's class with its mutators blocked
local function built(builder, always, bySize)
    local cls = __K2L_Class(rawget(builder, "____name"), builder)
    for _, name in ipairs(always) do
        cls[name] = unsupported
    end
    for name, size in pairs(bySize or {}) do
        cls[name] = function(self, ...)
            if self.size > size then
                unsupported()
            end
            return builder[name](self, ...)
        end
    end
    function builder:____build()
        return setmetatable(self, cls)
    end
    return cls
end

local BuiltList = built(__K2L_ListBuilder, {
    "add", "addAt", "addAll", "addAllAt", "removeAt", "remove", "removeAll", "retainAll", "clear", "set", "addFirst", "addLast",
    "removeFirst", "removeLast", "removeFirstOrNull", "removeLastOrNull",
}, {
    sort = 1, sortDescending = 1, sortBy = 1, sortByDescending = 1, sortWith = 1, reverse = 1, shuffle = 1, fill = 0,
    replaceAll = 0,
})

-- removeIf removes through the iterator, which fails once it finds an element to remove
function BuiltList:removeIf(predicate)
    if self:any(predicate) then
        unsupported()
    end
    return false
end

built(SetBuilder, {"add", "addAll", "remove", "removeAll", "retainAll", "clear"})
built(MapBuilder, {
    "put", "set", "putAll", "remove", "clear", "putIfAbsent", "merge", "compute", "computeIfAbsent", "computeIfPresent",
    "replaceAll", "getOrPut", "____removeKey", "____setValue",
})

function __K2L_ListBuilderOf()
    return __K2L_ListBuilder.new()
end

function __K2L_SetBuilderOf()
    return SetBuilder.new()
end

function __K2L_MapBuilderOf()
    return MapBuilder.new()
end
end
