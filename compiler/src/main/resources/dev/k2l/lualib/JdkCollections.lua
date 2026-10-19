-- requires: Class, Exceptions, Collections, Comparators, Compare, Equals, Random
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

function J.setAll(array, generator)
    for i = 1, array.size do
        array[i] = generator(i - 1)
    end
end

end
