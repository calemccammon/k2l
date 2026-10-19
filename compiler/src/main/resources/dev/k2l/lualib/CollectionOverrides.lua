-- requires: Class, Collections, Deques, Exceptions, Pair, InstanceOf, Str, Hash, ToInt32, Equals
-- A program's class extending a library collection (ArrayList, HashSet, HashMap, TreeMap, PriorityQueue, ...) that
-- overrides members the library's own operations call on the JVM (size, iterator(), get, contains, isEmpty, indexOf,
-- listIterator, entries, ...): __K2L_HonorOverrides(cls, base) gives the class versions of the library's operations that
-- call those members where the JDK and the Kotlin stdlib do, e.g. AbstractCollection.toString and the stdlib's map
-- (size, then iterator()), List.first() (isEmpty, then get(0)), ArrayList.contains (indexOf), AbstractSet.equals (size,
-- then contains), AbstractMap.toString (entries). Only such classes get them: the lualib collections themselves keep
-- reading their fields. An operation the class (or a superclass of the program) overrides itself is left alone.
local __K2L_HonorOverrides

do

local function noSuchElement(message)
    error(__K2L_NoSuchElementException.new(message))
end

local function illegalArgument(message)
    error(__K2L_IllegalArgumentException.new(message))
end

-- size() of a collection or map: its override (getSize), else the field
local function sizeOf(self)
    local get = self.getSize
    if get ~= nil then
        return get(self)
    end
    return self.size
end

local function copy(arr, n)
    local out = {}
    for i = 1, n do
        out[i] = arr[i]
    end
    return out, n
end

-- A plain ArrayList of the elements, for the operations that compute on them like the library's own.
local function listOf(arr, n)
    local out = copy(arr, n)
    out.size, out.____modCount = n, 0
    return setmetatable(out, __K2L_List)
end

local function emptyList()
    return __K2L_ReadOnlyListOf()
end

local function install(cls, base, name, fn)
    -- leave operations the class or a superclass of the program defines
    if cls[name] == base[name] then
        cls[name] = fn
    end
end

-- the operations shared by lists and other collections; `isList` for ArrayList, LinkedList and kotlin's ArrayDeque
local function collectionOperations(cls, base, isList)
    local function op(name, fn)
        install(cls, base, name, fn)
    end
    local overridesIterator = cls.iterator ~= base.iterator

    -- iterating: through iterator() when the class overrides it, as `for` and the stdlib do
    local function elements(self)
        if self.iterator == base.iterator then
            return base.____array(self)
        end
        local it, arr, n = self:iterator(), {}, 0
        while it:hasNext() do
            n = n + 1
            arr[n] = it:next()
        end
        return arr, n
    end
    -- toArray(): the collection's own storage (AbstractCollection.toArray, a TreeSet's, iterates)
    local function toArray(self)
        if base == __K2L_SortedSet then
            sizeOf(self)
            return elements(self)
        end
        return base.____array(self)
    end
    -- toArray(T[]), which toTypedArray() calls: an ArrayDeque's reads size() first
    local function toTypedArray(self)
        if base == __K2L_Deque then
            sizeOf(self)
        end
        return toArray(self)
    end
    if overridesIterator then
        op("____array", elements)
    end
    op("____ownArray", base.____array)
    op("____toArray", toArray)

    -- AbstractCollection.toString
    op("toString", function(self)
        local arr, n = elements(self)
        local parts = {}
        for i = 1, n do
            parts[i] = rawequal(arr[i], self) and "(this Collection)" or __K2L_Str(arr[i])
        end
        return "[" .. table.concat(parts, ", ") .. "]"
    end)
    op("isNotEmpty", function(self) return not self:isEmpty() end)
    -- ArrayList.isEmpty, a set's and a kotlin ArrayDeque's read the size field; LinkedList's and PriorityQueue's are
    -- AbstractCollection's, size() == 0
    if base == __K2L_LinkedList or base == __K2L_PriorityQueue then
        op("isEmpty", function(self) return sizeOf(self) == 0 end)
    else
        op("isEmpty", function(self) return self.size == 0 end)
    end

    -- the stdlib's map and mapIndexed size the result (collectionSizeOrDefault), then iterate
    for _, name in ipairs({"map", "mapIndexed"}) do
        op(name, function(self, ...)
            sizeOf(self)
            return base[name](self, ...)
        end)
    end
    op("withIndex", function(self)
        return listOf(elements(self)):withIndex()
    end)
    op("zip", function(self, ...)
        local arr, n = elements(self)
        sizeOf(self)
        return listOf(arr, n):zip(...)
    end)
    op("toTypedArray", function(self, binary)
        return __K2L_List.toTypedArray(listOf(toTypedArray(self)), binary)
    end)
    op("count", function(self, predicate)
        if predicate == nil then
            return sizeOf(self)
        end
        if self:isEmpty() then
            return 0
        end
        return listOf(elements(self)):count(predicate)
    end)
    -- any, all and none with a predicate return early for an empty collection
    for name, empty in pairs({any = false, all = true, none = true}) do
        op(name, function(self, predicate)
            if predicate == nil then
                if name == "any" then
                    return not self:isEmpty()
                end
                return self:isEmpty()
            end
            if self:isEmpty() then
                return empty
            end
            local list = listOf(elements(self))
            return list[name](list, predicate)
        end)
    end

    local function single(self)
        if isList then
            return self:get(0)
        end
        return self:iterator():next()
    end
    -- Collection.toList(): by size; one element is read with get(0) (or the iterator), more are copied (toArray)
    op("toList", function(self)
        local n = sizeOf(self)
        if n == 0 then
            return emptyList()
        elseif n == 1 then
            return __K2L_SingletonListOf(single(self))
        end
        return listOf(toArray(self))
    end)
    op("toMutableList", function(self)
        return listOf(toArray(self))
    end)
    -- toSet(): by size, then toCollection(LinkedHashSet(mapCapacity(size)))
    op("toSet", function(self)
        local n = sizeOf(self)
        if n == 0 then
            return __K2L_ReadOnlySetOf()
        elseif n == 1 then
            return __K2L_ReadOnlySetOf(single(self))
        end
        sizeOf(self)
        return listOf(elements(self)):toMutableSet()
    end)
    -- LinkedHashSet(this): its capacity, then addAll
    local function linkedSet(self)
        sizeOf(self)
        return listOf(elements(self)):toMutableSet()
    end
    op("toMutableSet", linkedSet)
    op("toHashSet", function(self)
        sizeOf(self)
        return listOf(elements(self)):toHashSet()
    end)
    op("distinct", function(self)
        return linkedSet(self):toList()
    end)

    -- sorted*() and reversed() of a collection of at most one element are toList(), else sort a copy (toArray)
    for _, name in ipairs({"sorted", "sortedDescending", "sortedBy", "sortedByDescending", "sortedWith"}) do
        op(name, function(self, ...)
            if sizeOf(self) <= 1 then
                return self:toList()
            end
            local list = listOf(toTypedArray(self))
            return list[name](list, ...)
        end)
    end
    op("reversed", function(self)
        if sizeOf(self) <= 1 then
            return self:toList()
        end
        local list = self:toMutableList()
        list:reverse()
        return list
    end)
    op("take", function(self, n)
        if n < 0 then
            illegalArgument("Requested element count " .. n .. " is less than zero.")
        elseif n == 0 then
            return emptyList()
        end
        if n >= sizeOf(self) then
            return self:toList()
        elseif n == 1 then
            return __K2L_SingletonListOf(self:first())
        end
        return listOf(elements(self)):take(n)
    end)
    -- Collection.plus: ArrayList(size + 1), addAll(this)
    for _, name in ipairs({"plus", "plusAll"}) do
        op(name, function(self, ...)
            sizeOf(self)
            return __K2L_List[name](listOf(toArray(self)), ...)
        end)
    end

    -- first(), last(), single() and their OrNull forms: of a list by index, of other collections through the iterator
    if isList then
        op("first", function(self, predicate)
            if predicate ~= nil then
                return base.first(self, predicate)
            end
            if self:isEmpty() then
                noSuchElement("List is empty.")
            end
            return self:get(0)
        end)
        op("firstOrNull", function(self, predicate)
            if predicate ~= nil then
                return base.firstOrNull(self, predicate)
            end
            if self:isEmpty() then
                return nil
            end
            return self:get(0)
        end)
        op("last", function(self, predicate)
            if predicate ~= nil then
                return base.last(self, predicate)
            end
            if self:isEmpty() then
                noSuchElement("List is empty.")
            end
            return self:get(sizeOf(self) - 1)
        end)
        op("lastOrNull", function(self, predicate)
            if predicate ~= nil then
                return base.lastOrNull(self, predicate)
            end
            if self:isEmpty() then
                return nil
            end
            return self:get(sizeOf(self) - 1)
        end)
        op("single", function(self, predicate)
            if predicate ~= nil then
                return base.single(self, predicate)
            end
            local n = sizeOf(self)
            if n == 0 then
                noSuchElement("List is empty.")
            elseif n > 1 then
                illegalArgument("List has more than one element.")
            end
            return self:get(0)
        end)
        op("singleOrNull", function(self, predicate)
            if predicate ~= nil then
                return base.singleOrNull(self, predicate)
            end
            if sizeOf(self) == 1 then
                return self:get(0)
            end
            return nil
        end)
        op("elementAt", function(self, index) return self:get(index) end)
        op("getOrNull", function(self, index)
            if index >= 0 and index <= sizeOf(self) - 1 then
                return self:get(index)
            end
            return nil
        end)
        op("getOrElse", function(self, index, default)
            if index >= 0 and index <= sizeOf(self) - 1 then
                return self:get(index)
            end
            return default(index)
        end)
        op("getLastIndex", function(self) return sizeOf(self) - 1 end)
        op("getIndices", function(self) return __K2L_IntRange.new(0, sizeOf(self) - 1) end)
        -- drop(n) of a RandomAccess list reads the rest by index
        op("drop", function(self, n)
            if n < 0 then
                illegalArgument("Requested element count " .. n .. " is less than zero.")
            elseif n == 0 then
                return self:toList()
            end
            local rest = sizeOf(self) - n
            if rest <= 0 then
                return emptyList()
            elseif rest == 1 then
                return __K2L_SingletonListOf(self:last())
            end
            local out = __K2L_ListOf()
            for i = n, sizeOf(self) - 1 do
                out:add(self:get(i))
            end
            return out
        end)
        -- ArrayList.contains and LinkedList.contains call indexOf
        op("contains", function(self, element) return self:indexOf(element) >= 0 end)
    else
        op("first", function(self, predicate)
            if predicate ~= nil then
                return base.first(self, predicate)
            end
            local it = self:iterator()
            if not it:hasNext() then
                noSuchElement("Collection is empty.")
            end
            return it:next()
        end)
        op("firstOrNull", function(self, predicate)
            if predicate ~= nil then
                return base.firstOrNull(self, predicate)
            end
            local it = self:iterator()
            if not it:hasNext() then
                return nil
            end
            return it:next()
        end)
    end
end

local function listOperations(cls, base)
    collectionOperations(cls, base, true)
    -- ArrayList.hashCode reads its elements; LinkedList's and ArrayDeque's (AbstractList.hashCode) iterate
    if base == __K2L_List then
        install(cls, base, "hashCode", function(self)
            return __K2L_Iterable.hashCode(listOf(base.____array(self)))
        end)
    end
    -- LinkedList.isEmpty is AbstractCollection's: size() == 0
end

local function setOperations(cls, base)
    collectionOperations(cls, base, false)
    -- AbstractSet.equals: size(), then containsAll; hashCode iterates
    install(cls, base, "equals", function(self, other)
        if rawequal(self, other) then
            return true
        end
        if not __K2L_InstanceOf(other, __K2L_Set) or sizeOf(other) ~= sizeOf(self) then
            return false
        end
        return self:containsAll(other)
    end)
    install(cls, base, "hashCode", function(self)
        local arr, n = self:____array()
        local h = 0
        for i = 1, n do
            h = __K2L_ToInt32(h + __K2L_Hash(arr[i]))
        end
        return h
    end)
    -- AbstractSet.removeAll: remove() for each element of a smaller collection, else the iterator's remove()
    install(cls, base, "removeAll", function(self, elements)
        if type(elements) ~= "function" and elements.size ~= nil and sizeOf(self) > elements.size then
            local arr, n = elements:____array()
            local changed = false
            for i = 1, n do
                changed = self:remove(arr[i]) or changed
            end
            return changed
        end
        local matches = type(elements) == "function" and elements or function(it) return elements:contains(it) end
        local it, changed = self:iterator(), false
        while it:hasNext() do
            if matches(it:next()) then
                it:remove()
                changed = true
            end
        end
        return changed
    end)
    -- AbstractCollection.retainAll: the iterator's remove()
    install(cls, base, "retainAll", function(self, elements)
        local keeps = type(elements) == "function" and elements or function(it) return elements:contains(it) end
        local it, changed = self:iterator(), false
        while it:hasNext() do
            if not keeps(it:next()) then
                it:remove()
                changed = true
            end
        end
        return changed
    end)
end

-- A PriorityQueue's and an ArrayDeque's isEmpty is AbstractCollection's (size() == 0) for the queue.
local function queueOperations(cls, base)
    collectionOperations(cls, base, false)
end

-- A LinkedHashMap of the entries (read through `entries`), for operations computed like the library's.
local function linked0(self)
    local out = __K2L_MapOf()
    local arr, n = self:getEntries():____array()
    for i = 1, n do
        out:put(arr[i].key, arr[i].value)
    end
    return out
end

local function mapOperations(cls, base)
    local function op(name, fn)
        install(cls, base, name, fn)
    end
    -- the entries, through the class's `entries` (AbstractMap's operations and the stdlib's iterate entrySet())
    local function entries(self)
        if self.getEntries == base.getEntries then
            return base.____entryArray(self)
        end
        return self:getEntries():____array()
    end
    op("____entryArray", entries)
    op("____arrays", function(self)
        local arr, n = entries(self)
        local keys, values = {}, {}
        for i = 1, n do
            keys[i], values[i] = arr[i].key, arr[i].value
        end
        return keys, values, n
    end)
    -- putAll and the copying constructors (putMapEntries): size(), then the entries when there are any
    op("iter", function(self, whole)
        -- Map.forEach { k, v -> } (`whole`) walks the table
        if whole then
            return base.iter(self, true)
        end
        local arr, n = {}, 0
        if sizeOf(self) > 0 then
            arr, n = entries(self)
        end
        local i = 0
        return function()
            i = i + 1
            if i <= n then
                return arr[i].key, arr[i].value
            end
        end
    end)
    op("toString", function(self)
        local arr, n = entries(self)
        local parts = {}
        for i = 1, n do
            local k, v = arr[i].key, arr[i].value
            parts[i] = (rawequal(k, self) and "(this Map)" or __K2L_Str(k)) .. "=" .. (rawequal(v, self) and "(this Map)" or __K2L_Str(v))
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    end)
    op("hashCode", function(self)
        local arr, n = entries(self)
        local h = 0
        for i = 1, n do
            h = __K2L_ToInt32(h + arr[i]:hashCode())
        end
        return h
    end)
    -- AbstractMap.equals: the sizes, then each entry against the other map's get (and containsKey for a null value)
    op("equals", function(self, other)
        if rawequal(self, other) then
            return true
        end
        if not __K2L_InstanceOf(other, __K2L_Map) or sizeOf(other) ~= sizeOf(self) then
            return false
        end
        local arr, n = entries(self)
        for i = 1, n do
            local key, value = arr[i].key, arr[i].value
            if value == nil then
                if other:get(key) ~= nil or not other:containsKey(key) then
                    return false
                end
            elseif not __K2L_Equals(value, other:get(key)) then
                return false
            end
        end
        return true
    end)
    op("isNotEmpty", function(self) return not self:isEmpty() end)
    -- TreeMap's isEmpty is AbstractMap's, size() == 0
    if base == __K2L_SortedMap then
        op("isEmpty", function(self) return sizeOf(self) == 0 end)
    end
    op("getOrElse", function(self, key, default)
        local value = self:get(key)
        if value == nil then
            return default()
        end
        return value
    end)
    local function entryPairs(self)
        local arr, n = entries(self)
        local out = {}
        for i = 1, n do
            out[i] = __K2L_Pair.new(arr[i].key, arr[i].value)
        end
        return out, n
    end
    -- LinkedHashMap(this): size(), then the entries
    local function linked(self)
        local out = __K2L_MapOf()
        if sizeOf(self) > 0 then
            local arr, n = entries(self)
            for i = 1, n do
                out:put(arr[i].key, arr[i].value)
            end
        end
        return out
    end
    op("toMutableMap", linked)
    op("toList", function(self)
        if sizeOf(self) == 0 then
            return emptyList()
        end
        local arr, n = entryPairs(self)
        sizeOf(self)
        return listOf(arr, n):toList()
    end)
    op("toMap", function(self)
        local n = sizeOf(self)
        if n == 0 then
            return __K2L_ReadOnlyMapOf()
        elseif n == 1 then
            local arr = entryPairs(self)
            return __K2L_SingletonMapOf(arr[1])
        end
        return linked(self)
    end)
    op("plus", function(self, pair)
        if self:isEmpty() and __K2L_InstanceOf(pair, __K2L_Pair) then
            return __K2L_SingletonMapOf(pair)
        end
        return __K2L_Map.plus(linked(self), pair)
    end)
    op("toSortedMap", function(self, comparator)
        sizeOf(self)
        local out = __K2L_SortedMap.new(comparator)
        local arr, n = entries(self)
        for i = 1, n do
            out:put(arr[i].key, arr[i].value)
        end
        return out
    end)
    -- the stdlib's map and mapValues size the result first; filter and the others only iterate
    for _, name in ipairs({"map", "mapValues", "mapKeys"}) do
        op(name, function(self, ...)
            sizeOf(self)
            return __K2L_Map[name](linked0(self), ...)
        end)
    end
    for _, name in ipairs({"filter", "filterNot", "filterKeys", "filterValues", "mapNotNull", "flatMap", "forEach"}) do
        op(name, function(self, ...)
            return __K2L_Map[name](linked0(self), ...)
        end)
    end
    op("count", function(self, predicate)
        if predicate == nil then
            return sizeOf(self)
        end
        if self:isEmpty() then
            return 0
        end
        return self:getEntries():count(predicate)
    end)
    for name, empty in pairs({any = false, all = true, none = true}) do
        op(name, function(self, predicate)
            if predicate == nil then
                if name == "any" then
                    return not self:isEmpty()
                end
                return self:isEmpty()
            end
            if self:isEmpty() then
                return empty
            end
            local e = self:getEntries()
            return e[name](e, predicate)
        end)
    end
end

function __K2L_HonorOverrides(cls, base)
    cls.____honorOverrides = true
    if base == __K2L_List or base == __K2L_LinkedList or base == __K2L_ArrayDeque then
        listOperations(cls, base)
    elseif base == __K2L_Set or base == __K2L_HashSet or base == __K2L_SortedSet then
        setOperations(cls, base)
    elseif base == __K2L_PriorityQueue or base == __K2L_Deque then
        queueOperations(cls, base)
    elseif base == __K2L_Map or base == __K2L_HashMap or base == __K2L_SortedMap then
        mapOperations(cls, base)
    end
end
end
