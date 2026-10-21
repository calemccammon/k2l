-- requires: Class, Exceptions, Collections, Comparators, Compare, Equals, Random, Strings
-- java.util.Collections and java.util.Arrays helpers, Map.withDefault and List.listIterator.
-- The unmodifiable* wrappers are live read-only views of their argument (see "views" below). The empty and singleton
-- collections, nCopies and the like are read-only collections of their own, with the JVM's classes.
local __K2L_JdkCollections = {}
local __K2L_ListIterator = __K2L_Class("java.util.ArrayList$ListItr")
-- a ListBuilder's listIterator() is its Itr
__K2L_ListBuilder.____listIteratorClass = __K2L_Class("kotlin.collections.builders.ListBuilder$Itr", __K2L_ListIterator)
local __K2L_JdkEmptyList = __K2L_MakeReadOnly(__K2L_Class("java.util.Collections$EmptyList", __K2L_List), "list")
local __K2L_JdkEmptySet = __K2L_MakeReadOnly(__K2L_Class("java.util.Collections$EmptySet", __K2L_Set), "set")
local __K2L_JdkEmptyMap = __K2L_MakeReadOnly(__K2L_Class("java.util.Collections$EmptyMap", __K2L_Map), "map")
local __K2L_CopiesList = __K2L_MakeReadOnly(__K2L_Class("java.util.Collections$CopiesList", __K2L_List), "list")
local __K2L_ListView = __K2L_Class("java.util.Collections$UnmodifiableRandomAccessList", __K2L_List)
local __K2L_SetView = __K2L_Class("java.util.Collections$UnmodifiableSet", __K2L_Set)
local __K2L_MapView = __K2L_Class("java.util.Collections$UnmodifiableMap", __K2L_Map)

do

local J = __K2L_JdkCollections

local function unsupported()
    error(__K2L_UnsupportedOperationException.new())
end

local function illegalArgument(message)
    error(__K2L_IllegalArgumentException.new(message))
end

local function arrayIndex(index)
    error(__K2L_ArrayIndexOutOfBoundsException.new("Array index out of range: " .. index))
end

------------------------------------------------------------------ listIterator
function __K2L_ListIterator:____init(list, cursor)
    self.list, self.cursor, self.lastReturned = list, cursor, -1
end

function __K2L_ListIterator:hasNext()
    return self.cursor ~= self.list.size
end

function __K2L_ListIterator:next()
    local i = self.cursor
    if i >= self.list.size then
        error(__K2L_NoSuchElementException.new())
    end
    self.cursor, self.lastReturned = i + 1, i
    return self.list[i + 1]
end

function __K2L_ListIterator:hasPrevious()
    return self.cursor ~= 0
end

function __K2L_ListIterator:previous()
    local i = self.cursor - 1
    if i < 0 then
        error(__K2L_NoSuchElementException.new())
    end
    self.cursor, self.lastReturned = i, i
    return self.list[i + 1]
end

function __K2L_ListIterator:nextIndex()
    return self.cursor
end

function __K2L_ListIterator:previousIndex()
    return self.cursor - 1
end

function __K2L_ListIterator:remove()
    if self.lastReturned < 0 then
        error(__K2L_IllegalStateException.new())
    end
    self.list:removeAt(self.lastReturned)
    self.cursor, self.lastReturned = self.lastReturned, -1
end

function __K2L_ListIterator:set(value)
    if self.lastReturned < 0 then
        error(__K2L_IllegalStateException.new())
    end
    self.list:set(self.lastReturned, value)
end

function __K2L_ListIterator:add(value)
    self.list:addAt(self.cursor, value)
    self.cursor, self.lastReturned = self.cursor + 1, -1
end

-- list.listIterator() and list.listIterator(index)
function J.listIterator(list, index)
    index = index or 0
    if index < 0 or index > list.size then
        error(__K2L_IndexOutOfBoundsException.new("Index: " .. index .. ", Size: " .. list.size))
    end
    return (list.____listIteratorClass or __K2L_ListIterator).new(list, index)
end

------------------------------------------------------------------ withDefault
-- A view of `map` whose getValue() falls back to default(key); everything else, writes included, goes to the map.
function J.withDefault(map, default)
    local function getValue(_, key)
        if map:containsKey(key) then
            return map:get(key)
        end
        return default(key)
    end
    return setmetatable({}, {
        __index = function(proxy, name)
            if name == "getValue" or name == "getOrImplicitDefault" then
                return getValue
            end
            local member = map[name]
            if type(member) == "function" then
                local forwarded = function(_, ...)
                    return member(map, ...)
                end
                rawset(proxy, name, forwarded)
                return forwarded
            end
            return member
        end,
        __tostring = function()
            return map:toString()
        end,
    })
end

------------------------------------------------------------------ views
local LIST_MUTATORS = {
    "add", "addAt", "addAll", "addAllAt", "removeAt", "remove", "removeAll", "retainAll", "removeIf", "clear", "set", "sort",
    "sortDescending", "sortBy", "sortByDescending", "sortWith", "reverse", "shuffle", "fill", "replaceAll", "addFirst", "addLast",
    "removeFirst", "removeLast", "removeFirstOrNull", "removeLastOrNull", "push", "pop", "poll", "pollFirst", "pollLast",
    "offer", "offerFirst", "offerLast",
}
local SET_MUTATORS = {"add", "addAll", "remove", "removeAll", "retainAll", "removeIf", "clear"}
local MAP_MUTATORS = {
    "put", "set", "putAll", "remove", "clear", "putIfAbsent", "merge", "compute", "computeIfAbsent", "computeIfPresent",
    "replaceAll", "getOrPut",
}

-- unmodifiableList(list) and friends: a table holding only the argument. Every key the view does not define is read from
-- the argument, so reads (the `size` field, `view[i]`, the internal tables the methods use, and the methods of the argument's
-- own class, e.g. a HashMap's iteration order) see later changes to it; the mutating methods throw. The index and the
-- methods work the same on all Lua versions, but `ipairs` does not follow __index before 5.3: the compiler uses numeric
-- loops over lists when the program calls an unmodifiable* function.
local function makeView(class, mutators, own)
    local blocked = own or {}
    for _, name in ipairs(mutators) do
        blocked[name] = unsupported
    end
    class.__index = function(self, key)
        local method = blocked[key]
        if method ~= nil then
            return method
        end
        return rawget(self, "____target")[key]
    end
    -- The methods of the argument's class rebuild their tables lazily (a HashMap puts its entries in order when it is read),
    -- which writes fields such as ____keys and size: those belong to the argument. Elements, by index, are not written.
    class.__newindex = function(self, key, value)
        if type(key) == "string" then
            rawget(self, "____target")[key] = value
        else
            unsupported()
        end
    end
end
local CollectionView = __K2L_Class("java.util.Collections$UnmodifiableCollection", __K2L_Iterable)

local function viewOf(class, source)
    return setmetatable({____target = source}, class)
end

-- Whether `source` is a set (an instance of a subclass of Set, or of a class implementing it such as a map's keys).
local function isSet(source)
    local c = getmetatable(source)
    while c do
        if c == __K2L_Set or rawget(c, "____interfaces")[__K2L_Set] then
            return true
        end
        c = rawget(c, "____super")
    end
    return false
end

local function isList(source)
    local c = getmetatable(source)
    while c do
        if c == __K2L_List then
            return true
        end
        c = rawget(c, "____super")
    end
    return false
end

makeView(__K2L_ListView, LIST_MUTATORS)
makeView(__K2L_SetView, SET_MUTATORS)
makeView(CollectionView, SET_MUTATORS)
-- the keys, values and entries of an unmodifiable map are unmodifiable views of the map's
makeView(__K2L_MapView, MAP_MUTATORS, {
    getKeys = function(self) return viewOf(__K2L_SetView, rawget(self, "____target"):getKeys()) end,
    getValues = function(self) return viewOf(CollectionView, rawget(self, "____target"):getValues()) end,
    getEntries = function(self) return viewOf(__K2L_SetView, rawget(self, "____target"):getEntries()) end,
})

function J.unmodifiableList(source)
    return viewOf(__K2L_ListView, source)
end

function J.unmodifiableCollection(source)
    return viewOf(isSet(source) and __K2L_SetView or isList(source) and __K2L_ListView or CollectionView, source)
end

function J.unmodifiableSet(source)
    return viewOf(__K2L_SetView, source)
end

function J.unmodifiableMap(source)
    return viewOf(__K2L_MapView, source)
end

-- the sorted, navigable and sequenced views also block the members that take elements from either end
local function withEnds(mutators, ends)
    local out = {}
    for _, name in ipairs(mutators) do
        out[#out + 1] = name
    end
    for _, name in ipairs(ends) do
        out[#out + 1] = name
    end
    return out
end

local SET_END_MUTATORS = withEnds(SET_MUTATORS, {"pollFirst", "pollLast", "removeFirst", "removeLast", "addFirst", "addLast"})
local MAP_END_MUTATORS = withEnds(MAP_MUTATORS, {"pollFirstEntry", "pollLastEntry", "putFirst", "putLast"})

local function setViewClass(name, base)
    local class = __K2L_Class("java.util.Collections$" .. name, base)
    makeView(class, SET_END_MUTATORS)
    return class
end

local function mapViewClass(name, base)
    local class = __K2L_Class("java.util.Collections$" .. name, base)
    makeView(class, MAP_END_MUTATORS, {
        getKeys = function(self) return viewOf(__K2L_SetView, rawget(self, "____target"):getKeys()) end,
        getValues = function(self) return viewOf(CollectionView, rawget(self, "____target"):getValues()) end,
        getEntries = function(self) return viewOf(__K2L_SetView, rawget(self, "____target"):getEntries()) end,
    })
    return class
end

local SortedSetView = setViewClass("UnmodifiableSortedSet", __K2L_SortedSet)
local NavigableSetView = setViewClass("UnmodifiableNavigableSet", __K2L_SortedSet)
local SequencedSetView = setViewClass("UnmodifiableSequencedSet", __K2L_Set)
local SortedMapView = mapViewClass("UnmodifiableSortedMap", __K2L_SortedMap)
local NavigableMapView = mapViewClass("UnmodifiableNavigableMap", __K2L_SortedMap)
local SequencedMapView = mapViewClass("UnmodifiableSequencedMap", __K2L_Map)
local SequencedCollectionView = __K2L_Class("java.util.Collections$UnmodifiableSequencedCollection", __K2L_Iterable)
makeView(SequencedCollectionView, LIST_MUTATORS)

function J.unmodifiableSortedSet(source) return viewOf(SortedSetView, source) end
function J.unmodifiableNavigableSet(source) return viewOf(NavigableSetView, source) end
function J.unmodifiableSequencedSet(source) return viewOf(SequencedSetView, source) end
function J.unmodifiableSortedMap(source) return viewOf(SortedMapView, source) end
function J.unmodifiableNavigableMap(source) return viewOf(NavigableMapView, source) end
function J.unmodifiableSequencedMap(source) return viewOf(SequencedMapView, source) end
function J.unmodifiableSequencedCollection(source) return viewOf(SequencedCollectionView, source) end

-- emptySortedSet() and emptyNavigableSet(), emptySortedMap() and emptyNavigableMap(): read-only views of empty trees
function J.emptySortedSet() return viewOf(NavigableSetView, __K2L_SortedSet.new()) end
function J.emptySortedMap() return viewOf(NavigableMapView, __K2L_SortedMap.new()) end
J.emptyNavigableSet, J.emptyNavigableMap = J.emptySortedSet, J.emptySortedMap

function __K2L_JdkEmptyList:get(index)
    error(__K2L_IndexOutOfBoundsException.new("Index: " .. index))
end

function J.emptyList()
    return __K2L_JdkEmptyList.new()
end

function J.emptySet()
    return __K2L_JdkEmptySet.new()
end

function J.emptyMap()
    return __K2L_JdkEmptyMap.new()
end

function J.singletonList(value)
    return __K2L_SingletonListOf(value)
end

function J.singleton(value)
    local out = __K2L_Set.new()
    out:add(value)
    return setmetatable(out, __K2L_SingletonSet)
end

function J.singletonMap(key, value)
    local out = __K2L_Map.new()
    out:put(key, value)
    return setmetatable(out, __K2L_SingletonMap)
end

function J.nCopies(n, value)
    if n < 0 then
        illegalArgument("List length = " .. n)
    end
    local out = __K2L_CopiesList.new()
    for i = 1, n do
        out[i] = value
    end
    out.size = n
    return out
end

-- synchronizedList and friends
function J.identity(collection)
    return collection
end

------------------------------------------------------------------ Collections
function J.sort(list, comparator)
    if comparator ~= nil then
        list:sortWith(comparator)
    else
        list:sort()
    end
end

function J.reverse(list)
    list:reverse()
end

function J.shuffle(list, random)
    list:shuffle(random or __K2L_Random.default())
end

function J.swap(list, i, j)
    local first = list:get(i)
    list:set(i, list:get(j))
    list:set(j, first)
end

local function extreme(collection, comparator, sign)
    local arr, n = collection:____array()
    if n == 0 then
        error(__K2L_NoSuchElementException.new())
    end
    comparator = comparator or __K2L_Compare
    local best = arr[1]
    for i = 2, n do
        if comparator(arr[i], best) * sign > 0 then
            best = arr[i]
        end
    end
    return best
end

function J.max(collection, comparator)
    return extreme(collection, comparator, 1)
end

function J.min(collection, comparator)
    return extreme(collection, comparator, -1)
end

function J.frequency(collection, value)
    local arr, n = collection:____array()
    local count = 0
    for i = 1, n do
        if __K2L_Equals(value, arr[i]) then
            count = count + 1
        end
    end
    return count
end

function J.addAll(collection, ...)
    local changed = false
    for i = 1, select("#", ...) do
        if collection:add((select(i, ...))) then
            changed = true
        end
    end
    return changed
end

function J.fill(list, value)
    list:fill(value)
end

function J.rotate(list, distance)
    local n = list.size
    if n == 0 then
        return
    end
    distance = distance % n
    if distance == 0 then
        return
    end
    local copy = {}
    for i = 1, n do
        copy[i] = list[i]
    end
    for i = 0, n - 1 do
        list:set((i + distance) % n, copy[i + 1])
    end
end

function J.replaceAll(list, oldValue, newValue)
    local changed = false
    for i = 0, list.size - 1 do
        if __K2L_Equals(oldValue, list[i + 1]) then
            list:set(i, newValue)
            changed = true
        end
    end
    return changed
end

function J.copy(destination, source)
    local arr, n = source:____array()
    if n > destination.size then
        error(__K2L_IndexOutOfBoundsException.new("Source does not fit in dest"))
    end
    for i = 1, n do
        destination:set(i - 1, arr[i])
    end
end

function J.disjoint(first, second)
    local arr, n = first:____array()
    for i = 1, n do
        if second:contains(arr[i]) then
            return false
        end
    end
    return true
end

function J.reverseOrder(comparator)
    if comparator ~= nil then
        return __K2L_ReverseComparator(comparator)
    end
    return __K2L_ReverseOrder
end

-- indexOfSubList(source, target) and lastIndexOfSubList: where target occurs in source, -1 when it does not
local function matchesAt(source, target, i)
    for j = 0, target.size - 1 do
        if not __K2L_Equals(source:get(i + j), target:get(j)) then
            return false
        end
    end
    return true
end

function J.indexOfSubList(source, target)
    for i = 0, source.size - target.size do
        if matchesAt(source, target, i) then
            return i
        end
    end
    return -1
end

function J.lastIndexOfSubList(source, target)
    for i = source.size - target.size, 0, -1 do
        if matchesAt(source, target, i) then
            return i
        end
    end
    return -1
end

function J.emptyIterator()
    return J.emptyList():iterator()
end

function J.emptyListIterator()
    return J.listIterator(J.emptyList())
end

local function isInstance(value, class)
    local c = getmetatable(value)
    while c do
        if c == class then
            return true
        end
        c = rawget(c, "____super")
    end
    return false
end

-- newSetFromMap(map): a set ordered as the (empty) map would order its keys
function J.newSetFromMap(map)
    if not map:isEmpty() then
        illegalArgument("Map is non-empty")
    end
    if isInstance(map, __K2L_SortedMap) then
        return __K2L_SortedSet.new(rawget(map, "____compare"))
    elseif isInstance(map, __K2L_HashMap) then
        return __K2L_HashSet.new()
    end
    return __K2L_Set.new()
end

-- clone() of ArrayList, LinkedList, ArrayDeque, HashMap, LinkedHashMap, TreeMap, HashSet and the like: a shallow copy of
-- the same class (and comparator)
function J.clone(collection)
    local class = getmetatable(collection)
    local compare = rawget(collection, "____compare")
    local out = (compare ~= nil and compare ~= __K2L_Compare) and class.new(compare) or class.new()
    if collection.containsKey ~= nil then
        out:putAll(collection)
    else
        out:addAll(collection)
    end
    return out
end

-- Map.replace(key, value): only a key that is there gets the value
function J.replace(map, key, value)
    if not map:containsKey(key) then
        return nil
    end
    local old = map:get(key)
    map:put(key, value)
    return old
end

-- Map.replace(key, oldValue, newValue)
function J.replaceIf(map, key, oldValue, newValue)
    if not map:containsKey(key) or not __K2L_Equals(map:get(key), oldValue) then
        return false
    end
    map:put(key, newValue)
    return true
end

-- LinkedHashMap.putLast: the entry moves to the end
function J.putLast(map, key, value)
    local old = map:remove(key)
    map:put(key, value)
    return old
end

J.unsupported = unsupported

function J.removeLastOccurrence(collection, value)
    for i = collection.size, 1, -1 do
        if __K2L_Equals(collection[i], value) then
            if collection.____head ~= nil then
                collection:____delete(i)
            else
                collection:removeAt(i - 1)
            end
            return true
        end
    end
    return false
end

-- Collection.toArray(array): the elements in the array when they fit (then null after the last, as the JDK does), else in a
-- new array of the same type
function J.toArray(collection, array)
    local arr, n = collection:____array()
    local out = array
    if array.size < n then
        out = setmetatable({size = n}, getmetatable(array))
    elseif array.size > n then
        out[n + 1] = nil
    end
    for i = 1, n do
        out[i] = arr[i]
    end
    return out
end

-- the comparator of a TreeMap, TreeSet or PriorityQueue, null for the natural order
function J.comparator(collection)
    local compare = collection.____compare
    if compare == __K2L_Compare then
        return nil
    end
    return compare
end

------------------------------------------------------------------ Arrays
function J.asList(...)
    local list = __K2L_FixedSizeList.new()
    local n = select("#", ...)
    for i = 1, n do
        list[i] = (select(i, ...))
    end
    list.size = n
    return list
end

local function checkRange(size, from, to)
    if from > to then
        illegalArgument("fromIndex(" .. from .. ") > toIndex(" .. to .. ")")
    elseif from < 0 then
        arrayIndex(from)
    elseif to > size then
        arrayIndex(to)
    end
end

-- sort(array), sort(array, comparator), sort(array, from, to) and sort(array, from, to, comparator)
function J.sort_array(array, a, b, comparator)
    if type(a) ~= "number" then
        J.sort(array, a)
        return
    end
    checkRange(array.size, a, b)
    local slice = __K2L_List.new()
    for i = a + 1, b do
        slice[i - a] = array[i]
    end
    slice.size = b - a
    local sorted = comparator and slice:sortedWith(comparator) or slice:sorted()
    for i = 1, b - a do
        array[a + i] = sorted[i]
    end
end

-- fill(array, value) and fill(array, from, to, value)
function J.fill_array(array, a, b, value)
    if b == nil then
        array:fill(a)
        return
    end
    checkRange(array.size, a, b)
    array:fill(value, a, b)
end

-- copyOf(array, newLength) and copyOfRange(array, from, to); `pad` is the zero value of the element type
function J.copyOf(array, newLength, pad)
    return array:copyOfSize(newLength, pad)
end

function J.copyOfRange(array, from, to, pad)
    if from > to then
        illegalArgument(from .. " > " .. to)
    elseif from < 0 or from > array.size then
        arrayIndex(from)
    end
    local out = {}
    for i = from + 1, to do
        if i <= array.size then
            out[i - from] = array[i]
        else
            out[i - from] = pad
        end
    end
    out.size = to - from
    return setmetatable(out, getmetatable(array))
end

function J.arrayToString(array)
    if array == nil then
        return "null"
    end
    return array:contentToString()
end

function J.deepToString(array)
    if array == nil then
        return "null"
    end
    return array:contentDeepToString()
end

function J.arrayEquals(a, b)
    if a == nil or b == nil then
        return a == b
    end
    return (a.contentEquals or a.equals)(a, b)
end

-- Objects.deepEquals: arrays by their contents, all the way down; anything else by equals
function J.objectsDeepEquals(a, b)
    if rawequal(a, b) and type(a) ~= "number" then
        return true
    elseif a == nil or b == nil then
        return false
    elseif type(a) == "table" and a.contentDeepEquals ~= nil and type(b) == "table" and b.contentDeepEquals ~= nil then
        return a:contentDeepEquals(b)
    end
    return __K2L_Equals(a, b)
end

function J.arrayHashCode(array)
    if array == nil then
        return 0
    end
    return (array.contentHashCode or array.hashCode)(array)
end

-- binarySearch(a, key), (a, key, comparator), (a, from, to, key) and (a, from, to, key, comparator)
function J.binarySearch_array(array, a, b, c, d)
    if c == nil then
        return array:binarySearch(a, b)
    end
    checkRange(array.size, a, b)
    return array:binarySearch(c, d or __K2L_Compare, a, b)
end

-- Arrays.compare's order of two elements of the kind ("Int", "Byte", "Char", "Object" ...): the difference for the narrow
-- kinds and Char, as Byte.compare and Character.compare are; null first among objects
local function charCode(c)
    local b = c:byte(1)
    if b < 0x80 then
        return b
    elseif b < 0xE0 then
        return (b - 0xC0) * 64 + c:byte(2) - 0x80
    elseif b < 0xF0 then
        return ((b - 0xE0) * 64 + c:byte(2) - 0x80) * 64 + c:byte(3) - 0x80
    end
    return (((b - 0xF0) * 64 + c:byte(2) - 0x80) * 64 + c:byte(3) - 0x80) * 64 + c:byte(4) - 0x80
end

local function elementOrder(kind, unsigned)
    if kind == "Byte" or kind == "Short" then
        local m = kind == "Byte" and 256 or 65536
        if unsigned then
            return function(a, b) return a % m - b % m end
        end
        return function(a, b) return a - b end
    elseif kind == "Char" then
        return function(a, b) return charCode(a) - charCode(b) end
    elseif kind == "Object" then
        return function(a, b)
            if a == nil or b == nil then
                return a == nil and (b == nil and 0 or -1) or 1
            elseif type(a) == "string" then
                return __K2L_Text.compare(a, b)
            end
            return __K2L_Compare(a, b)
        end
    elseif unsigned then
        return function(a, b)
            local an, bn = __K2L_Compare(a, 0) < 0, __K2L_Compare(b, 0) < 0
            if an ~= bn then
                return an and 1 or -1
            end
            return __K2L_Compare(a, b)
        end
    end
    return __K2L_Compare
end

local function isComparatorArg(x)
    return x ~= nil and type(x) ~= "number"
end

-- the arrays and ranges of compare(a, b[, cmp]) and compare(a, aFrom, aTo, b, bFrom, bTo[, cmp]), checked as the JDK does
local function ranges(a, b, c, d, e, f, g)
    if type(b) == "number" then
        checkRange(a.size, b, c)
        checkRange(d.size, e, f)
        return a, b, c, d, e, f, g
    end
    return a, 0, a and a.size, b, 0, b and b.size, c
end

local function firstMismatch(a, af, at, b, bf, bt, same)
    local n = math.min(at - af, bt - bf)
    for i = 1, n do
        if not same(a[af + i], b[bf + i]) then
            return i - 1
        end
    end
    return -1
end

local function compareArrays(kind, unsigned, ...)
    local a, af, at, b, bf, bt, cmp = ranges(...)
    if a == b and af == bf and at == bt then
        return 0
    elseif a == nil or b == nil then
        return a == nil and -1 or 1
    end
    local order = isComparatorArg(cmp) and cmp or elementOrder(kind, unsigned)
    local i = firstMismatch(a, af, at, b, bf, bt, function(x, y) return order(x, y) == 0 end)
    if i >= 0 then
        return order(a[af + i + 1], b[bf + i + 1])
    end
    return (at - af) - (bt - bf)
end

function J.compareArrays(kind, ...)
    return compareArrays(kind, false, ...)
end

function J.compareUnsignedArrays(kind, ...)
    return compareArrays(kind, true, ...)
end

-- Arrays.mismatch: the index of the first difference (Double.equals for numbers, a comparator's 0 when given), the shorter
-- length when one is a prefix of the other, -1 when they are equal
function J.mismatchArrays(_, ...)
    local a, af, at, b, bf, bt, cmp = ranges(...)
    if a == nil or b == nil then
        error(__K2L_NullPointerException.new())
    end
    local same = __K2L_Equals
    if isComparatorArg(cmp) then
        same = function(x, y) return cmp(x, y) == 0 end
    end
    local i = firstMismatch(a, af, at, b, bf, bt, same)
    if i < 0 and at - af ~= bt - bf then
        return math.min(at - af, bt - bf)
    end
    return i
end

-- parallelPrefix(array, op) and parallelPrefix(array, from, to, op): each element combined with the result before it
function J.parallelPrefix(array, a, b, c)
    local from, to, op = 0, array.size, a
    if type(a) == "number" then
        checkRange(array.size, a, b)
        from, to, op = a, b, c
    end
    for i = from + 2, to do
        array[i] = op(array[i - 1], array[i])
    end
end

function J.setAll(array, generator)
    for i = 1, array.size do
        array[i] = generator(i - 1)
    end
end

end
