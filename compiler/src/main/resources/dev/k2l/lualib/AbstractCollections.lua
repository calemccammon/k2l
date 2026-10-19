-- requires: Class, Collections, Exceptions, Equals, Hash, Str, ToInt32, Bit, IdentityHash, AnyToString
-- The library's abstract collections as bases of a program's classes: AbstractCollection, AbstractList, AbstractSet and
-- AbstractMap (the Kotlin ones, their mutable variants and java.util's), and kotlin.collections.AbstractIterator; a class
-- implementing List, Set, Map or Collection directly gets the same base. As in the JDK and the Kotlin stdlib, every
-- operation is written in terms of what a subclass implements: iterator() and size; get(index) and size for a list (and
-- set, addAt and removeAt to make it mutable); entries for a map (and put); computeNext() for an iterator. The elements of
-- such a class are not in the array part, so `list[i]` is get(i - 1) (__K2L_ElementAccess), and the operations shared with
-- the lualib collections (map, filter, joinToString, ...) read a snapshot from ____array().
local __K2L_IterableBase = __K2L_Class("java.lang.Iterable", __K2L_Iterable)
local __K2L_AbstractCollection = __K2L_Class("java.util.AbstractCollection", __K2L_Iterable)
local __K2L_AbstractList = __K2L_Class("java.util.AbstractList", __K2L_AbstractCollection)
local __K2L_AbstractSet = __K2L_Class("java.util.AbstractSet", __K2L_AbstractCollection)
local __K2L_AbstractMap = __K2L_Class("java.util.AbstractMap")
local __K2L_AbstractIterator = __K2L_Class("kotlin.collections.AbstractIterator")
-- Bases of classes implementing the interfaces: the same, with Any's toString, equals and hashCode.
local __K2L_CollectionBase = __K2L_Class("java.util.Collection", __K2L_AbstractCollection)
local __K2L_ListBase = __K2L_Class("java.util.List", __K2L_AbstractList)
local __K2L_SetBase = __K2L_Class("java.util.Set", __K2L_AbstractSet)
local __K2L_MapBase = __K2L_Class("java.util.Map", __K2L_AbstractMap)

do

-- `is List`, `is Set`, `is Map` and the lualib's own checks see them as what they implement.
__K2L_AbstractList.____interfaces[__K2L_List] = true
__K2L_AbstractSet.____interfaces[__K2L_Set] = true
__K2L_AbstractMap.____interfaces[__K2L_Map] = true

local function unsupported()
    error(__K2L_UnsupportedOperationException.new())
end

local function noSuchElement(message)
    error(__K2L_NoSuchElementException.new(message))
end

local function illegalState()
    error(__K2L_IllegalStateException.new())
end

-- Whether `value` is an instance of `cls` (or implements it).
local function isA(value, cls)
    local c = type(value) == "table" and getmetatable(value)
    while c do
        if c == cls or (rawget(c, "____interfaces") or {})[cls] then
            return true
        end
        c = rawget(c, "____super")
    end
    return false
end

-- Calls `action(element, iterator)` for each element of `iterable` until it returns true; returns whether one did.
local function each(iterable, action)
    local it = iterable:iterator()
    while it:hasNext() do
        if action(it:next(), it) then
            return true
        end
    end
    return false
end

-- A predicate for removeAll/retainAll(elements or predicate)
local function matcher(elements)
    if type(elements) == "function" then
        return elements
    end
    return function(it) return elements:contains(it) end
end

------------------------------------------------------------------ Iterable
-- A class implementing Iterable: its iterator() is all there is, toString() and equals() are Any's.
function __K2L_IterableBase:____array()
    local arr, n = {}, 0
    local it = self:iterator()
    while it:hasNext() do
        n = n + 1
        arr[n] = it:next()
    end
    return arr, n
end

function __K2L_IterableBase:isEmpty()
    return not self:iterator():hasNext()
end

function __K2L_IterableBase:toString()
    return __K2L_AnyToString(self)
end

function __K2L_IterableBase:equals(other)
    return rawequal(self, other)
end

function __K2L_IterableBase:hashCode()
    return __K2L_IdentityHash(self)
end

------------------------------------------------------------------ AbstractCollection
__K2L_AbstractCollection.____array = __K2L_IterableBase.____array

function __K2L_AbstractCollection:isEmpty()
    return self.size == 0
end

-- Collection.count() is its size
function __K2L_AbstractCollection:count(predicate)
    if predicate == nil then
        return self.size
    end
    return __K2L_Iterable.count(self, predicate)
end

function __K2L_AbstractCollection:contains(element)
    return each(self, function(it) return __K2L_Equals(it, element) end)
end

-- "[a, b]", with "(this Collection)" for the collection itself
function __K2L_AbstractCollection:toString()
    local arr, n = self:____array()
    local parts = {}
    for i = 1, n do
        parts[i] = rawequal(arr[i], self) and "(this Collection)" or __K2L_Str(arr[i])
    end
    return "[" .. table.concat(parts, ", ") .. "]"
end

-- A plain collection is equal to itself only.
function __K2L_AbstractCollection:equals(other)
    return rawequal(self, other)
end

function __K2L_AbstractCollection:hashCode()
    return __K2L_IdentityHash(self)
end

-- The mutators of java.util.AbstractCollection (Kotlin's AbstractMutableCollection): add is the subclass's, the others use
-- add and the iterator's remove().
__K2L_AbstractCollection.add = unsupported

function __K2L_AbstractCollection:addAll(elements)
    local arr, n = elements:____array()
    local changed = false
    for i = 1, n do
        if self:add(arr[i]) then
            changed = true
        end
    end
    return changed
end

function __K2L_AbstractCollection:remove(element)
    return each(self, function(it, iterator)
        if __K2L_Equals(it, element) then
            iterator:remove()
            return true
        end
    end)
end

local function removeMatching(self, predicate, keep)
    local changed = false
    each(self, function(it, iterator)
        if (predicate(it) and true or false) ~= keep then
            iterator:remove()
            changed = true
        end
    end)
    return changed
end

function __K2L_AbstractCollection:removeAll(elements)
    return removeMatching(self, matcher(elements), false)
end

__K2L_AbstractCollection.removeIf = __K2L_AbstractCollection.removeAll

function __K2L_AbstractCollection:retainAll(elements)
    return removeMatching(self, matcher(elements), true)
end

function __K2L_AbstractCollection:clear()
    local it = self:iterator()
    while it:hasNext() do
        it:next()
        it:remove()
    end
end

------------------------------------------------------------------ AbstractList
local __K2L_AbstractListIterator = __K2L_Class("java.util.AbstractList$Itr")

function __K2L_AbstractListIterator:____init(list)
    self.____list, self.____cursor, self.____lastReturned = list, 0, -1
end

function __K2L_AbstractListIterator:hasNext()
    return self.____cursor < self.____list.size
end

function __K2L_AbstractListIterator:next()
    if not self:hasNext() then
        noSuchElement()
    end
    local i = self.____cursor
    local value = self.____list:get(i)
    self.____cursor, self.____lastReturned = i + 1, i
    return value
end

function __K2L_AbstractListIterator:remove()
    if self.____lastReturned < 0 then
        illegalState()
    end
    self.____list:removeAt(self.____lastReturned)
    self.____cursor, self.____lastReturned = self.____lastReturned, -1
end

-- list[i] reads get(i - 1) (nil past the end, as for the lualib lists), list[i] = v calls set(i - 1, v)
__K2L_ElementAccess(__K2L_AbstractList, function(self, i)
    if i >= 1 and i <= self.size then
        return self:get(i - 1)
    end
end, function(self, i, value)
    self:set(i - 1, value)
end)

function __K2L_AbstractList:____array()
    local arr, n = {}, self.size
    for i = 1, n do
        arr[i] = self:get(i - 1)
    end
    return arr, n
end

function __K2L_AbstractList:iterator()
    return __K2L_AbstractListIterator.new(self)
end

function __K2L_AbstractList:indexOf(element)
    for i = 0, self.size - 1 do
        if __K2L_Equals(self:get(i), element) then
            return i
        end
    end
    return -1
end

function __K2L_AbstractList:lastIndexOf(element)
    for i = self.size - 1, 0, -1 do
        if __K2L_Equals(self:get(i), element) then
            return i
        end
    end
    return -1
end

function __K2L_AbstractList:contains(element)
    return self:indexOf(element) >= 0
end

-- Equal to any list with equal elements in the same order.
function __K2L_AbstractList:equals(other)
    if rawequal(self, other) then
        return true
    elseif not isA(other, __K2L_List) or other.size ~= self.size then
        return false
    end
    local arr, n = other:____array()
    for i = 1, n do
        if not __K2L_Equals(self:get(i - 1), arr[i]) then
            return false
        end
    end
    return true
end

__K2L_AbstractList.hashCode = __K2L_Iterable.hashCode

function __K2L_AbstractList:first(predicate)
    if predicate ~= nil then
        return __K2L_Iterable.first(self, predicate)
    elseif self.size == 0 then
        noSuchElement("List is empty.")
    end
    return self:get(0)
end

function __K2L_AbstractList:last(predicate)
    if predicate ~= nil then
        return __K2L_Iterable.last(self, predicate)
    elseif self.size == 0 then
        noSuchElement("List is empty.")
    end
    return self:get(self.size - 1)
end

function __K2L_AbstractList:getOrNull(index)
    if index >= 0 and index < self.size then
        return self:get(index)
    end
    return nil
end

function __K2L_AbstractList:elementAt(index)
    return self:get(index)
end

-- The elements at `from` .. `to` - 1 (read with get), as the list toList() gives.
local function range(self, from, to)
    local out = __K2L_List.new()
    for i = from, to - 1 do
        out:add(self:get(i))
    end
    return out:toList()
end

local function checkCount(count)
    if count < 0 then
        error(__K2L_IllegalArgumentException.new("Requested element count " .. count .. " is less than zero."))
    end
end

-- take, drop and the like read only the elements they keep, as Kotlin's do on a List
function __K2L_AbstractList:take(count)
    checkCount(count)
    return range(self, 0, math.min(count, self.size))
end

function __K2L_AbstractList:drop(count)
    checkCount(count)
    return range(self, math.min(count, self.size), self.size)
end

function __K2L_AbstractList:takeLast(count)
    checkCount(count)
    local size = self.size
    return range(self, math.max(size - count, 0), size)
end

function __K2L_AbstractList:dropLast(count)
    checkCount(count)
    return self:take(math.max(self.size - count, 0))
end

function __K2L_AbstractList:slice(indices)
    local idx, n = indices:____array()
    local out = __K2L_List.new()
    for i = 1, n do
        out:add(self:get(idx[i]))
    end
    return out
end

__K2L_AbstractList.subList = __K2L_List.subList
__K2L_AbstractList.____subList = __K2L_List.____subList
__K2L_AbstractList.____subListClass = __K2L_AbstractSubList
__K2L_AbstractList.getLastIndex = __K2L_List.getLastIndex

-- The mutators of java.util.AbstractList (Kotlin's AbstractMutableList): set, addAt and removeAt are the subclass's.
__K2L_AbstractList.set = unsupported
__K2L_AbstractList.addAt = unsupported
__K2L_AbstractList.removeAt = unsupported

function __K2L_AbstractList:add(element)
    self:addAt(self.size, element)
    return true
end

function __K2L_AbstractList:addAllAt(index, elements)
    local arr, n = elements:____array()
    for i = 1, n do
        self:addAt(index + i - 1, arr[i])
    end
    return n > 0
end

function __K2L_AbstractList:addFirst(element)
    self:addAt(0, element)
end

function __K2L_AbstractList:addLast(element)
    self:add(element)
end

function __K2L_AbstractList:removeFirst()
    if self.size == 0 then
        noSuchElement()
    end
    return self:removeAt(0)
end

function __K2L_AbstractList:removeLast()
    if self.size == 0 then
        noSuchElement()
    end
    return self:removeAt(self.size - 1)
end

function __K2L_AbstractList:removeFirstOrNull()
    if self.size == 0 then
        return nil
    end
    return self:removeAt(0)
end

function __K2L_AbstractList:removeLastOrNull()
    if self.size == 0 then
        return nil
    end
    return self:removeAt(self.size - 1)
end

-- in place through set(), like List.sort/replaceAll and Collections.reverse/fill/shuffle
for _, name in ipairs({
    "sort", "sortDescending", "sortBy", "sortByDescending", "sortWith", "reverse", "fill", "replaceAll", "shuffle",
}) do
    __K2L_AbstractList[name] = __K2L_List[name]
end

------------------------------------------------------------------ AbstractSet
-- Equal to any set with the same elements.
function __K2L_AbstractSet:equals(other)
    if rawequal(self, other) then
        return true
    elseif not isA(other, __K2L_Set) or other.size ~= self.size then
        return false
    end
    return self:containsAll(other)
end

function __K2L_AbstractSet:hashCode()
    local arr, n = self:____array()
    local h = 0
    for i = 1, n do
        h = __K2L_ToInt32(h + __K2L_Hash(arr[i]))
    end
    return h
end

-- java.util.AbstractSet.removeAll removes the other collection's elements one by one when that is smaller.
function __K2L_AbstractSet:removeAll(elements)
    if type(elements) ~= "function" and self.size > elements.size then
        local arr, n = elements:____array()
        local changed = false
        for i = 1, n do
            if self:remove(arr[i]) then
                changed = true
            end
        end
        return changed
    end
    return removeMatching(self, matcher(elements), false)
end

------------------------------------------------------------------ AbstractMap
-- Kotlin's AbstractMap: everything reads `entries` (getEntries(), or a field of that name); `size` is entries.size unless
-- a subclass overrides it.
__K2L_AbstractMap.__tostring = function(self) return self:toString() end
__K2L_PropertyOverride(__K2L_AbstractMap, "size", "getSize")

function __K2L_AbstractMap:getEntries()
    return rawget(self, "entries")
end

function __K2L_AbstractMap:getSize()
    local size = rawget(self, "____size")
    if size ~= nil then
        return size
    end
    return self:getEntries().size
end

local function entriesOf(self)
    return self:getEntries():____array()
end

local function findEntry(self, key)
    local arr, n = entriesOf(self)
    for i = 1, n do
        if __K2L_Equals(arr[i].key, key) then
            return arr[i]
        end
    end
end

function __K2L_AbstractMap:get(key)
    local entry = findEntry(self, key)
    return entry and entry.value
end

function __K2L_AbstractMap:containsKey(key)
    return findEntry(self, key) ~= nil
end

function __K2L_AbstractMap:containsValue(value)
    local arr, n = entriesOf(self)
    for i = 1, n do
        if __K2L_Equals(arr[i].value, value) then
            return true
        end
    end
    return false
end

function __K2L_AbstractMap:isEmpty()
    return self.size == 0
end

function __K2L_AbstractMap:isNotEmpty()
    return self.size ~= 0
end

function __K2L_AbstractMap:getKeys()
    local arr, n = entriesOf(self)
    local keys = __K2L_Set.new()
    for i = 1, n do
        keys:add(arr[i].key)
    end
    return keys
end

function __K2L_AbstractMap:getValues()
    local arr, n = entriesOf(self)
    local values = __K2L_List.new()
    for i = 1, n do
        values:add(arr[i].value)
    end
    return values
end

-- for k, v in map:iter() do ... end
function __K2L_AbstractMap:iter()
    local arr, n = entriesOf(self)
    local i = 0
    return function()
        i = i + 1
        if i <= n then
            return arr[i].key, arr[i].value
        end
    end
end

function __K2L_AbstractMap:iterator()
    return self:getEntries():iterator()
end

function __K2L_AbstractMap:forEach(action)
    local arr, n = entriesOf(self)
    for i = 1, n do
        action(arr[i])
    end
end

function __K2L_AbstractMap:forEachKeyValue(action)
    for k, v in self:iter() do
        action(k, v)
    end
end

-- "{k=v, ...}", with "(this Map)" for the map itself
function __K2L_AbstractMap:toString()
    local arr, n = entriesOf(self)
    local parts = {}
    local function show(x)
        return rawequal(x, self) and "(this Map)" or __K2L_Str(x)
    end
    for i = 1, n do
        parts[i] = show(arr[i].key) .. "=" .. show(arr[i].value)
    end
    return "{" .. table.concat(parts, ", ") .. "}"
end

function __K2L_AbstractMap:equals(other)
    if rawequal(self, other) then
        return true
    elseif not isA(other, __K2L_Map) or other.size ~= self.size then
        return false
    end
    for k, v in other:iter() do
        local ours = self:get(k)
        if not __K2L_Equals(v, ours) or (ours == nil and not self:containsKey(k)) then
            return false
        end
    end
    return true
end

function __K2L_AbstractMap:hashCode()
    local arr, n = entriesOf(self)
    local h = 0
    for i = 1, n do
        h = __K2L_ToInt32(h + __K2L_BXor(__K2L_Hash(arr[i].key), __K2L_Hash(arr[i].value)))
    end
    return h
end

-- The mutators of java.util.AbstractMap (Kotlin's AbstractMutableMap): put is the subclass's; remove and clear go through
-- the entries.
__K2L_AbstractMap.put = unsupported

function __K2L_AbstractMap:set(key, value)
    self:put(key, value)
end

function __K2L_AbstractMap:putAll(other)
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

function __K2L_AbstractMap:remove(key)
    local entries = self:getEntries()
    local old
    each(entries, function(entry, iterator)
        if __K2L_Equals(entry.key, key) then
            old = entry.value
            iterator:remove()
            return true
        end
    end)
    return old
end

function __K2L_AbstractMap:clear()
    self:getEntries():clear()
end

function __K2L_AbstractMap:getOrPut(key, default)
    local value = self:get(key)
    if value == nil then
        value = default()
        self:put(key, value)
    end
    return value
end

function __K2L_AbstractMap:getOrDefault(key, default)
    local entry = findEntry(self, key)
    if entry == nil then
        return default
    end
    return entry.value
end

function __K2L_AbstractMap:putIfAbsent(key, value)
    local old = self:get(key)
    if old == nil then
        old = self:put(key, value)
    end
    return old
end

function __K2L_AbstractMap:computeIfAbsent(key, mapping)
    local old = self:get(key)
    if old ~= nil then
        return old
    end
    local value = mapping(key)
    if value ~= nil then
        self:put(key, value)
    end
    return value
end

function __K2L_AbstractMap:computeIfPresent(key, remapping)
    local old = self:get(key)
    if old == nil then
        return nil
    end
    local value = remapping(key, old)
    if value == nil then
        self:remove(key)
    else
        self:put(key, value)
    end
    return value
end

function __K2L_AbstractMap:compute(key, remapping)
    local value = remapping(key, self:get(key))
    if value == nil then
        if self:containsKey(key) then
            self:remove(key)
        end
    else
        self:put(key, value)
    end
    return value
end

function __K2L_AbstractMap:merge(key, value, remapping)
    local old = self:get(key)
    local new = old == nil and value or remapping(old, value)
    if new == nil then
        self:remove(key)
    else
        self:put(key, new)
    end
    return new
end

-- Other Map operations (map, filter, any, toList, mapValues, ...) read a LinkedHashMap copy of the entries.
local function snapshot(self)
    local copy = __K2L_Map.new()
    for k, v in self:iter() do
        copy:put(k, v)
    end
    return copy
end

setmetatable(__K2L_AbstractMap, {__index = function(_, key)
    local method = __K2L_Map[key]
    if type(method) ~= "function" or type(key) ~= "string" or key:sub(1, 4) == "____" then
        return nil
    end
    local wrapper = function(self, ...)
        return method(snapshot(self), ...)
    end
    rawset(__K2L_AbstractMap, key, wrapper)
    return wrapper
end})

------------------------------------------------------------------ interfaces
for _, base in ipairs({__K2L_CollectionBase, __K2L_ListBase, __K2L_SetBase, __K2L_MapBase}) do
    base.toString = __K2L_IterableBase.toString
    base.equals = __K2L_IterableBase.equals
    base.hashCode = __K2L_IterableBase.hashCode
end
-- A class implementing List has its own iterator(), which the stdlib functions use (an AbstractList's reads get()).
__K2L_ListBase.____array = __K2L_IterableBase.____array

------------------------------------------------------------------ AbstractIterator
-- kotlin.collections.AbstractIterator: hasNext() runs computeNext(), which calls setNext(value) or done().
local READY, DONE, FAILED = 1, 2, 3

local function tryToComputeNext(self)
    self.____state = FAILED
    self:computeNext()
    return self.____state == READY
end

function __K2L_AbstractIterator:hasNext()
    local state = self.____state
    if state == DONE then
        return false
    elseif state == READY then
        return true
    elseif state == FAILED then
        error(__K2L_IllegalArgumentException.new("hasNext called when the iterator is in the FAILED state."))
    end
    return tryToComputeNext(self)
end

function __K2L_AbstractIterator:next()
    if not self:hasNext() then
        noSuchElement()
    end
    self.____state = nil
    return self.____next
end

function __K2L_AbstractIterator:setNext(value)
    self.____next, self.____state = value, READY
end

function __K2L_AbstractIterator:done()
    self.____state = DONE
end

end
