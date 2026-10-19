local ____lualib = require("lualib_bundle")
local __K2L_AbstractList = ____lualib.__K2L_AbstractList
local __K2L_CharSequenceText = ____lualib.__K2L_CharSequenceText
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CollectionBase = ____lualib.__K2L_CollectionBase
local __K2L_ComparatorMixin = ____lualib.__K2L_ComparatorMixin
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_FunctionMixin = ____lualib.__K2L_FunctionMixin
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_IterableBase = ____lualib.__K2L_IterableBase
local __K2L_Iterator = ____lualib.__K2L_Iterator
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_JdkCollections = ____lualib.__K2L_JdkCollections
local __K2L_ListBase = ____lualib.__K2L_ListBase
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapBase = ____lualib.__K2L_MapBase
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NaturalOrder = ____lualib.__K2L_NaturalOrder
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PropertyOverride = ____lualib.__K2L_PropertyOverride
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_ReverseComparator = ____lualib.__K2L_ReverseComparator
local __K2L_ReverseOrder = ____lualib.__K2L_ReverseOrder
local __K2L_RunnableMixin = ____lualib.__K2L_RunnableMixin
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_SequenceOf = ____lualib.__K2L_SequenceOf
local __K2L_SetBase = ____lualib.__K2L_SetBase
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_SortedSet = ____lualib.__K2L_SortedSet
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringCharAt = ____lualib.__K2L_StringCharAt
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_Text = ____lualib.__K2L_Text

local Pair, Words
local Counting = __K2L_Class("Counting", nil, __K2L_ComparatorMixin)

function Counting:____init(cmp)
    self.cmp = cmp
    self.____delegate_Comparator = cmp
    self.calls = 0
end

function Counting:compare(a, b)
    self.calls = self.calls + 1
    return self.cmp(a, b)
end

local Plain = __K2L_Class("Plain", nil, __K2L_ComparatorMixin)

function Plain:____init(cmp)
    self.____delegate_Comparator = cmp
end

function Plain:compare(p0, p1)
    return self.____delegate_Comparator(p0, p1)
end

local Logging = __K2L_Class("Logging", __K2L_ListBase)

function Logging:____init(inner)
    self.inner = inner
    self.____delegate_MutableList = inner
    self.log = __K2L_ListOf()
end

function Logging:add(element)
    self.log:add("add " .. element)
    return self.inner:add(element)
end

function Logging:addAt(index, element)
    return self.____delegate_MutableList:addAt(index, element)
end

function Logging:remove(element)
    return self.____delegate_MutableList:remove(element)
end

function Logging:addAll(elements)
    return self.____delegate_MutableList:addAll(elements)
end

function Logging:addAllAt(index, elements)
    return self.____delegate_MutableList:addAllAt(index, elements)
end

function Logging:removeAll(elements)
    return self.____delegate_MutableList:removeAll(elements)
end

function Logging:retainAll(elements)
    return self.____delegate_MutableList:retainAll(elements)
end

function Logging:clear()
    return self.____delegate_MutableList:clear()
end

function Logging:set(index, element)
    return self.____delegate_MutableList:set(index, element)
end

function Logging:removeAt(index)
    return self.____delegate_MutableList:removeAt(index)
end

function Logging:listIterator()
    return __K2L_JdkCollections.listIterator(self.____delegate_MutableList)
end

function Logging:listIteratorAt(index)
    return __K2L_JdkCollections.listIterator(self.____delegate_MutableList, index)
end

function Logging:subList(fromIndex, toIndex)
    return self.____delegate_MutableList:subList(fromIndex, toIndex)
end

function Logging:getSize()
    return self.____delegate_MutableList.size
end

__K2L_PropertyOverride(Logging, "size", "getSize")

function Logging:isEmpty()
    return self.____delegate_MutableList:isEmpty()
end

function Logging:contains(element)
    return self.____delegate_MutableList:contains(element)
end

function Logging:iterator()
    return __K2L_IteratorOf(self.____delegate_MutableList)
end

function Logging:containsAll(elements)
    return self.____delegate_MutableList:containsAll(elements)
end

function Logging:get(index)
    return self.____delegate_MutableList:get(index)
end

function Logging:indexOf(element)
    return self.____delegate_MutableList:indexOf(element)
end

function Logging:lastIndexOf(element)
    return self.____delegate_MutableList:lastIndexOf(element)
end

local ReadOnly = __K2L_Class("ReadOnly", __K2L_ListBase)
ReadOnly.____readOnly = true

function ReadOnly:____init(list)
    self.____delegate_List = list
end

function ReadOnly:shout()
    return self:joinToString(" ", nil, nil, nil, nil, function(it) return it:upper() end)
end

function ReadOnly:isEmpty()
    return self.____delegate_List:isEmpty()
end

function ReadOnly:contains(element)
    return self.____delegate_List:contains(element)
end

function ReadOnly:iterator()
    return __K2L_IteratorOf(self.____delegate_List)
end

function ReadOnly:containsAll(elements)
    return self.____delegate_List:containsAll(elements)
end

function ReadOnly:get(index)
    return self.____delegate_List:get(index)
end

function ReadOnly:indexOf(element)
    return self.____delegate_List:indexOf(element)
end

function ReadOnly:lastIndexOf(element)
    return self.____delegate_List:lastIndexOf(element)
end

function ReadOnly:listIterator()
    return __K2L_JdkCollections.listIterator(self.____delegate_List)
end

function ReadOnly:listIteratorAt(index)
    return __K2L_JdkCollections.listIterator(self.____delegate_List, index)
end

function ReadOnly:subList(fromIndex, toIndex)
    return self.____delegate_List:subList(fromIndex, toIndex)
end

function ReadOnly:getSize()
    return self.____delegate_List.size
end

__K2L_PropertyOverride(ReadOnly, "size", "getSize")
local Tagged = __K2L_Class("Tagged", __K2L_MapBase)

function Tagged:____init(m)
    self.m = m
    self.____delegate_MutableMap = m
end

function Tagged:put(key, value)
    return self.m:put(key:lower(), value)
end

function Tagged:remove(key)
    return self.____delegate_MutableMap:remove(key)
end

function Tagged:putAll(from)
    return self.____delegate_MutableMap:putAll(from)
end

function Tagged:clear()
    return self.____delegate_MutableMap:clear()
end

function Tagged:getKeys()
    return self.____delegate_MutableMap:getKeys()
end

function Tagged:getValues()
    return self.____delegate_MutableMap:getValues()
end

function Tagged:getEntries()
    return self.____delegate_MutableMap:getEntries()
end

function Tagged:getSize()
    return self.____delegate_MutableMap.size
end

__K2L_PropertyOverride(Tagged, "size", "getSize")

function Tagged:isEmpty()
    return self.____delegate_MutableMap:isEmpty()
end

function Tagged:containsKey(key)
    return self.____delegate_MutableMap:containsKey(key)
end

function Tagged:containsValue(value)
    return self.____delegate_MutableMap:containsValue(value)
end

function Tagged:get(key)
    return self.____delegate_MutableMap:get(key)
end

local Lookup = __K2L_Class("Lookup", __K2L_MapBase)
Lookup.____readOnly = true

function Lookup:____init(m)
    self.____delegate_Map = m
end

function Lookup:isEmpty()
    return self.____delegate_Map:isEmpty()
end

function Lookup:containsKey(key)
    return self.____delegate_Map:containsKey(key)
end

function Lookup:containsValue(value)
    return self.____delegate_Map:containsValue(value)
end

function Lookup:get(key)
    return self.____delegate_Map:get(key)
end

function Lookup:getSize()
    return self.____delegate_Map.size
end

__K2L_PropertyOverride(Lookup, "size", "getSize")

function Lookup:getKeys()
    return self.____delegate_Map:getKeys()
end

function Lookup:getValues()
    return self.____delegate_Map:getValues()
end

function Lookup:getEntries()
    return self.____delegate_Map:getEntries()
end

local Unique = __K2L_Class("Unique", __K2L_SetBase)
Unique.____readOnly = true

function Unique:____init(s)
    self.____delegate_Set = s
end

function Unique:isEmpty()
    return self.____delegate_Set:isEmpty()
end

function Unique:contains(element)
    return self.____delegate_Set:contains(element)
end

function Unique:iterator()
    return __K2L_IteratorOf(self.____delegate_Set)
end

function Unique:containsAll(elements)
    return self.____delegate_Set:containsAll(elements)
end

function Unique:getSize()
    return self.____delegate_Set.size
end

__K2L_PropertyOverride(Unique, "size", "getSize")
local Bag = __K2L_Class("Bag", __K2L_CollectionBase)
Bag.____readOnly = true

function Bag:____init(c)
    self.____delegate_Collection = c
end

function Bag:isEmpty()
    return self.____delegate_Collection:isEmpty()
end

function Bag:contains(element)
    return self.____delegate_Collection:contains(element)
end

function Bag:iterator()
    return __K2L_IteratorOf(self.____delegate_Collection)
end

function Bag:containsAll(elements)
    return self.____delegate_Collection:containsAll(elements)
end

function Bag:getSize()
    return self.____delegate_Collection.size
end

__K2L_PropertyOverride(Bag, "size", "getSize")
local Wrap = __K2L_Class("Wrap", __K2L_IterableBase)
Wrap.____readOnly = true

function Wrap:____init(it)
    self.____delegate_Iterable = it
end

function Wrap:iterator()
    return __K2L_IteratorOf(self.____delegate_Iterable)
end

local Steps = __K2L_Class("Steps")

function Steps:____init(it)
    self.____delegate_Iterator = it
end

function Steps:next()
    return self.____delegate_Iterator:next()
end

function Steps:hasNext()
    return self.____delegate_Iterator:hasNext()
end

local Name = __K2L_Class("Name")

function Name:____init(s)
    self.____delegate_CharSequence = s
end

function Name:get(index)
    return __K2L_StringCharAt(self.____delegate_CharSequence, index)
end

function Name:subSequence(startIndex, endIndex)
    return __K2L_Text.substring(self.____delegate_CharSequence, startIndex, endIndex)
end

function Name:getLength()
    return #self.____delegate_CharSequence
end

__K2L_PropertyOverride(Name, "length", "getLength")

function Name:____text()
    return self.____delegate_CharSequence
end

local Job = __K2L_Class("Job", nil, __K2L_RunnableMixin)

function Job:____init(r)
    self.____delegate_Runnable = r
end

function Job:run()
    return self.____delegate_Runnable()
end

local Twice = __K2L_Class("Twice", nil, __K2L_FunctionMixin)

function Twice:____init(f)
    self.____delegate_Function1 = f
end

function Twice:invoke(p1)
    return self.____delegate_Function1(p1)
end

local function comparators()
    local words = __K2L_ReadOnlyListOf("ccc", "a", "bb", "dddd")
    local byLength = Counting.new(__K2L_CompareBy(function(it) return #it end))
    print(__K2L_Str(words:sortedWith(byLength)) .. " " .. tostring(byLength.calls > 0) .. " " .. byLength:compare("aa", "b"))
    print(__K2L_Str(words:sortedWith(__K2L_ReverseComparator(byLength))))
    local natural = Plain.new(__K2L_NaturalOrder)
    print(__K2L_Str(words:sortedWith(natural)) .. " " .. natural("a", "b") .. " " .. words:maxWith(natural) .. " " .. tostring(type(natural) == "function" or __K2L_InstanceOf(natural, __K2L_ComparatorMixin)))
    local tree = __K2L_SortedSet.new(Plain.new(__K2L_ReverseOrder))
    tree:addAll(__K2L_ReadOnlyListOf(3, 1, 2))
    print(__K2L_Str(tree))
end

local function lists()
    local l = Logging.new(__K2L_ListOf(3, 1, 2))
    l:add(4)
    l:add(5)
    l:addAll(__K2L_ReadOnlyListOf(6, 7))
    l:addAt(0, 9)
    print(__K2L_Str(l.log) .. " " .. __K2L_Str(l.inner) .. " " .. l.size .. " " .. l:get(0) .. " " .. l:indexOf(2) .. " " .. tostring(l:contains(7)) .. " " .. tostring(l:isEmpty()))
    l:removeAt(0)
    l:remove(7)
    l:set(0, 30)
    l:sort()
    print(__K2L_Str(l.inner) .. " " .. l:first() .. " " .. l:last() .. " " .. l:sum() .. " " .. __K2L_Str(l:map(function(it) return it * 2 end)) .. " " .. __K2L_Str(l:filter(function(it) return it > 3 end)) .. " " .. l:joinToString("-"))
    local total = 0
    local ____list = l:toList()
    for ____i = 1, ____list.size do
        local x = ____list[____i]
        total = total + x
    end
    print("loop " .. total .. " " .. tostring(l:equals(__K2L_ReadOnlyListOf(1, 2, 4, 5, 6, 30))) .. " " .. tostring(__K2L_Equals(__K2L_ReadOnlyListOf(1, 2, 4, 5, 6, 30), l)) .. " " .. tostring(__K2L_Hash(l) == __K2L_Hash(l.inner)))
    print(tostring(__K2L_StringStartsWith(__K2L_Str(l), "Logging@")) .. " " .. __K2L_Str(l:subList(1, 3)) .. " " .. __K2L_Str(l:reversed()) .. " " .. __K2L_Str(l:sortedDescending()) .. " " .. __K2L_Str(l:getIndices()))
    local it = __K2L_JdkCollections.listIterator(l)
    it:next()
    it:remove()
    print(__K2L_Str(l.inner) .. " " .. tostring(l:removeIf(function(it) return it > 10 end)) .. " " .. __K2L_Str(l.inner) .. " " .. __K2L_Str(l.log))
    local r = ReadOnly.new(__K2L_ReadOnlyListOf("a", "b", "c"))
    print(r:shout() .. " " .. r.size .. " " .. r:get(1) .. " " .. r:lastIndexOf("c") .. " " .. tostring(r:containsAll(__K2L_ReadOnlyListOf("a", "c"))) .. " " .. __K2L_Str(r:asReversed()) .. " " .. __K2L_Str(r:zip(r:drop(1))))
    print(tostring(r:equals(__K2L_ReadOnlyListOf("a", "b", "c"))) .. " " .. tostring(__K2L_StringStartsWith(__K2L_Str(r), "ReadOnly@")) .. " " .. __K2L_Str(r:toList()) .. " " .. __K2L_Str(r:toSet()) .. " " .. __K2L_Str(r:withIndex():last()))
end

local function maps()
    local t = Tagged.new(__K2L_MapOf(__K2L_Pair.new("x", 1)))
    t:set("Y", 2)
    t:put("Z", 3)
    t:putAll(__K2L_SingletonMapOf(__K2L_Pair.new("W", 4)))
    print(t.size .. " " .. __K2L_Str(t:get("y")) .. " " .. __K2L_Str(t:getKeys()) .. " " .. __K2L_Str(t:getValues()) .. " " .. tostring(t:containsKey("z")) .. " " .. tostring(t:containsValue(4)) .. " " .. tostring(t:containsKey("x")))
    for k, v in t:iter() do
        io.write(k .. "=" .. v .. " ")
    end
    print()
    t:remove("x")
    print(__K2L_Str(t:getEntries():map(function(it) return it.key .. it.value end)) .. " " .. tostring(__K2L_StringStartsWith(__K2L_Str(t), "Tagged@")) .. " " .. tostring(t:equals(__K2L_ReadOnlyMapOf(__K2L_Pair.new("y", 2), __K2L_Pair.new("z", 3), __K2L_Pair.new("W", 4)))))
    print(t:getOrDefault("q", 0) .. " " .. t:getOrPut("q", function() return 7 end) .. " " .. __K2L_Str(t:filterValues(function(it) return it > 3 end)) .. " " .. t:getEntries():maxBy(function(it) return it.value end).key .. " " .. __K2L_Str(t:toList()))
    local m = Lookup.new(__K2L_ReadOnlyMapOf(__K2L_Pair.new("a", 1), __K2L_Pair.new("b", 2)))
    print(__K2L_Str(m:get("a")) .. " " .. m:getValue("b") .. " " .. tostring(m:isEmpty()) .. " " .. __K2L_Str(m:mapValues(function(it) return it.value * 10 end)) .. " " .. m:count() .. " " .. tostring(m:any(function(it) return it.value > 1 end)))
end

local function others()
    local u = Unique.new(__K2L_ReadOnlySetOf(3, 1, 2))
    print(u.size .. " " .. tostring(u:contains(2)) .. " " .. __K2L_Str(u:sorted()) .. " " .. tostring(u:equals(__K2L_ReadOnlySetOf(1, 2, 3))) .. " " .. tostring(__K2L_StringStartsWith(__K2L_Str(u), "Unique@")) .. " " .. __K2L_Str(u:intersect(__K2L_ReadOnlySetOf(2, 9))))
    local b = Bag.new(__K2L_ReadOnlyListOf("x", "y"))
    print(b.size .. " " .. tostring(b:contains("y")) .. " " .. b:joinToString() .. " " .. tostring(b:isEmpty()) .. " " .. __K2L_Str(b:toList()))
    local w = Wrap.new(__K2L_IntRange.new(1, 4))
    print(__K2L_Str(w:map(function(it) return it * it end)) .. " " .. w:sum() .. " " .. __K2L_Str(w:toList()) .. " " .. w:count() .. " " .. w:first())
    local s = 0
    local ____list_1 = w:toList()
    for ____i_1 = 1, ____list_1.size do
        local x = ____list_1[____i_1]
        s = s + x
    end
    local steps = Steps.new(__K2L_IteratorOf(__K2L_ReadOnlyListOf(5, 6)))
    print(s .. " " .. tostring(steps:hasNext()) .. " " .. steps:next() .. " " .. steps:next() .. " " .. tostring(steps:hasNext()))
    for _, x in __K2L_Iterator.iter(Steps.new(__K2L_IteratorOf(__K2L_ReadOnlyListOf(7, 8)))) do
        io.write(x .. " ")
    end
    print()
    local n = Name.new("hello")
    print(#__K2L_CharSequenceText(n) .. " " .. __K2L_StringCharAt(__K2L_CharSequenceText(n), 1) .. " " .. __K2L_Str(__K2L_Text.substring(__K2L_CharSequenceText(n), 1, 3)) .. " " .. tostring(__K2L_StringStartsWith(__K2L_Str(n), "Name@")) .. " " .. tostring(__K2L_StringStartsWith(__K2L_CharSequenceText(n), "he")) .. " " .. tostring(__K2L_StringContains(__K2L_CharSequenceText(n), "l")) .. " " .. __K2L_StringToList(__K2L_CharSequenceText(n)):count(function(it) return it == "l" end))
    local j = Job.new(function()
        print("job ran")
    end)
    j()
    local jobs = __K2L_SingletonListOf(j)
    for ____i_2 = 1, jobs.size do
        local it = jobs[____i_2]
        it()
    end
    local twice = Twice.new(function(it) return it * 2 end)
    print(twice(21) .. " " .. __K2L_Str(__K2L_ReadOnlyListOf(1, 2):map(twice)))
end

local Sized = __K2L_Class("Sized", __K2L_SetBase)

function Sized:____init(items)
    self.items = items
    self.____delegate_MutableSet = items
end

function Sized:getSize()
    return self.items.size * 10
end

function Sized:add(element)
    return self.items:add(__K2L_StringTrim(element))
end

function Sized:iterator()
    return __K2L_IteratorOf(self.____delegate_MutableSet)
end

function Sized:remove(element)
    return self.____delegate_MutableSet:remove(element)
end

function Sized:addAll(elements)
    return self.____delegate_MutableSet:addAll(elements)
end

function Sized:removeAll(elements)
    return self.____delegate_MutableSet:removeAll(elements)
end

function Sized:retainAll(elements)
    return self.____delegate_MutableSet:retainAll(elements)
end

function Sized:clear()
    return self.____delegate_MutableSet:clear()
end

function Sized:isEmpty()
    return self.____delegate_MutableSet:isEmpty()
end

function Sized:contains(element)
    return self.____delegate_MutableSet:contains(element)
end

function Sized:containsAll(elements)
    return self.____delegate_MutableSet:containsAll(elements)
end

__K2L_PropertyOverride(Sized, "size", "getSize")
local Pool = __K2L_Class("Pool", __K2L_CollectionBase)

function Pool:____init(c)
    self.____delegate_MutableCollection = c
end

function Pool:iterator()
    return __K2L_IteratorOf(self.____delegate_MutableCollection)
end

function Pool:add(element)
    return self.____delegate_MutableCollection:add(element)
end

function Pool:remove(element)
    return self.____delegate_MutableCollection:remove(element)
end

function Pool:addAll(elements)
    return self.____delegate_MutableCollection:addAll(elements)
end

function Pool:removeAll(elements)
    return self.____delegate_MutableCollection:removeAll(elements)
end

function Pool:retainAll(elements)
    return self.____delegate_MutableCollection:retainAll(elements)
end

function Pool:clear()
    return self.____delegate_MutableCollection:clear()
end

function Pool:getSize()
    return self.____delegate_MutableCollection.size
end

__K2L_PropertyOverride(Pool, "size", "getSize")

function Pool:isEmpty()
    return self.____delegate_MutableCollection:isEmpty()
end

function Pool:contains(element)
    return self.____delegate_MutableCollection:contains(element)
end

function Pool:containsAll(elements)
    return self.____delegate_MutableCollection:containsAll(elements)
end

local Draining = __K2L_Class("Draining")

function Draining:____init(source)
    self.source = source
    self.____delegate_MutableIterator = source
end

function Draining:remove()
    return self.____delegate_MutableIterator:remove()
end

function Draining:hasNext()
    return self.____delegate_MutableIterator:hasNext()
end

function Draining:next()
    return self.____delegate_MutableIterator:next()
end

local Version = __K2L_Class("Version")

function Version:____init(n)
    self.n = n
end

function Version:compareTo(other)
    return __K2L_Compare(self.n, other.n)
end

function Version:toString()
    return "Version(n=" .. self.n .. ")"
end

function Version:hashCode()
    return __K2L_Hash(self.n)
end

function Version:equals(other)
    return getmetatable(other) == Version and self.n == other.n
end

local Release = __K2L_Class("Release")

function Release:____init(v, label)
    self.label = label
    self.____delegate_Comparable = v
end

function Release:compareTo(other)
    return __K2L_Compare(self.____delegate_Comparable, other)
end

local Pairing = __K2L_Class("Pairing")

function Pairing:____init(e)
    self.____delegate_Entry = e
end

function Pairing:getKey()
    return self.____delegate_Entry.key
end

__K2L_PropertyOverride(Pairing, "key", "getKey")

function Pairing:getValue()
    return self.____delegate_Entry.value
end

__K2L_PropertyOverride(Pairing, "value", "getValue")
local Lines = __K2L_Class("Lines", __K2L_Sequence)

function Lines:____init(s)
    self.____delegate_Sequence = s
end

function Lines:iterator()
    return self.____delegate_Sequence:iterator()
end

local Window = __K2L_Class("Window", __K2L_ListBase)
Window.____readOnly = true

function Window:____init(data, from)
    self.data = data
    self.from = from
end

function Window:getSize()
    return self.data.size - self.from
end

function Window:get(index)
    return self.data:get(self.from + index)
end

function Window:isEmpty()
    return self:getSize() == 0
end

function Window:contains(element)
    return self:indexOf(element) >= 0
end

function Window:containsAll(elements)
    return elements:all(function(it) return self:contains(it) end)
end

function Window:indexOf(element)
    return __K2L_IntRange.new(0, self:getSize() - 1):firstOrNull(function(it) return self:get(it) == element end) or -1
end

function Window:lastIndexOf(element)
    return __K2L_IntRange.new(self:getSize() - 1, 0, -1):firstOrNull(function(it) return self:get(it) == element end) or -1
end

function Window:iterator()
    return __K2L_IteratorOf(__K2L_IntRange.new(0, self:getSize() - 1):map(function(it) return self:get(it) end))
end

function Window:listIterator()
    return __K2L_JdkCollections.listIterator(__K2L_IntRange.new(0, self:getSize() - 1):map(function(it) return self:get(it) end))
end

function Window:listIteratorAt(index)
    return __K2L_JdkCollections.listIterator(__K2L_IntRange.new(0, self:getSize() - 1):map(function(it) return self:get(it) end), index)
end

function Window:subList(fromIndex, toIndex)
    return __K2L_IntRange.new(fromIndex, toIndex - 1):map(function(it) return self:get(it) end)
end

__K2L_PropertyOverride(Window, "size", "getSize")
local Layer = __K2L_Class("Layer", __K2L_ListBase)
Layer.____readOnly = true

function Layer:____init(w)
    self.____delegate_List = w
end

function Layer:isEmpty()
    return self.____delegate_List:isEmpty()
end

function Layer:contains(element)
    return self.____delegate_List:contains(element)
end

function Layer:iterator()
    return __K2L_IteratorOf(self.____delegate_List)
end

function Layer:containsAll(elements)
    return self.____delegate_List:containsAll(elements)
end

function Layer:get(index)
    return self.____delegate_List:get(index)
end

function Layer:indexOf(element)
    return self.____delegate_List:indexOf(element)
end

function Layer:lastIndexOf(element)
    return self.____delegate_List:lastIndexOf(element)
end

function Layer:listIterator()
    return __K2L_JdkCollections.listIterator(self.____delegate_List)
end

function Layer:listIteratorAt(index)
    return __K2L_JdkCollections.listIterator(self.____delegate_List, index)
end

function Layer:subList(fromIndex, toIndex)
    return self.____delegate_List:subList(fromIndex, toIndex)
end

function Layer:getSize()
    return self.____delegate_List.size
end

__K2L_PropertyOverride(Layer, "size", "getSize")

local function more()
    local s = Sized.new(__K2L_SetOf("a"))
    s:add(" b ")
    s:addAll(__K2L_ReadOnlyListOf("c", "a"))
    print(s:getSize() .. " " .. s:count() .. " " .. __K2L_Str(s:toList()) .. " " .. tostring(s:contains("b")) .. " " .. tostring(s:isEmpty()) .. " " .. tostring(s:remove("a")) .. " " .. __K2L_Str(s:toSortedSet()))
    local p = Pool.new(__K2L_ListOf(1, 2, 3))
    p:add(4)
    p:removeAll(function(it) return math.fmod(it, 2) == 0 end)
    print(p.size .. " " .. __K2L_Str(p:toList()) .. " " .. tostring(p:retainAll(__K2L_SingletonListOf(3))) .. " " .. __K2L_Str(p:toList()))
    p:clear()
    print(tostring(p:isEmpty()) .. " " .. p.size)
    local backing = __K2L_ListOf(1, 2, 3)
    local d = Draining.new(__K2L_IteratorOf(backing))
    while d:hasNext() do
        if d:next() == 2 then
            d:remove()
        end
    end
    print(__K2L_Str(backing))
    local r = Release.new(Version.new(3), "three")
    print(tostring(__K2L_Compare(r, Version.new(2)) > 0) .. " " .. tostring(__K2L_Compare(r, Version.new(3)) < 0) .. " " .. __K2L_Compare(r, Version.new(4)) .. " " .. r.label)
    local e = Pairing.new(__K2L_SingletonMapOf(__K2L_Pair.new("k", 5)):getEntries():first())
    print(e.key .. " " .. e.value .. " " .. __K2L_Str(__K2L_SingletonListOf(e):associate(function(it) return __K2L_Pair.new(it.key, it.value) end)))
    local lines = Lines.new(__K2L_SequenceOf("x", "yy", "zzz"))
    print(__K2L_Str(lines:map(function(it) return #it end):toList()) .. " " .. lines:filter(function(it) return #it > 1 end):count() .. " " .. lines:first())
    for _, line in lines:iter() do
        io.write(line .. " ")
    end
    print()
    local layer = Layer.new(Window.new(__K2L_ReadOnlyListOf(1, 2, 3, 4), 1))
    print(layer.size .. " " .. layer:get(0) .. " " .. __K2L_Str(layer:toList()) .. " " .. layer:indexOf(4) .. " " .. __K2L_Str(layer:subList(0, 2)) .. " " .. layer:sum() .. " " .. layer:max())
    local total = 0
    local ____list_2 = layer:toList()
    for ____i_3 = 1, ____list_2.size do
        local x = ____list_2[____i_3]
        total = total + x
    end
    local ____object = __K2L_Class("MainKt$more$anonymous$1", __K2L_ListBase)
    ____object.____readOnly = true
    function ____object:____init()
        self.____delegate_List = __K2L_ReadOnlyListOf(7, 8)
    end
    function ____object:isEmpty()
        return self.____delegate_List:isEmpty()
    end
    function ____object:contains(element)
        return self.____delegate_List:contains(element)
    end
    function ____object:iterator()
        return __K2L_IteratorOf(self.____delegate_List)
    end
    function ____object:containsAll(elements)
        return self.____delegate_List:containsAll(elements)
    end
    function ____object:get(index)
        return self.____delegate_List:get(index)
    end
    function ____object:indexOf(element)
        return self.____delegate_List:indexOf(element)
    end
    function ____object:lastIndexOf(element)
        return self.____delegate_List:lastIndexOf(element)
    end
    function ____object:listIterator()
        return __K2L_JdkCollections.listIterator(self.____delegate_List)
    end
    function ____object:listIteratorAt(index)
        return __K2L_JdkCollections.listIterator(self.____delegate_List, index)
    end
    function ____object:subList(fromIndex, toIndex)
        return self.____delegate_List:subList(fromIndex, toIndex)
    end
    function ____object:getSize()
        return self.____delegate_List.size
    end
    __K2L_PropertyOverride(____object, "size", "getSize", true)
    ____object:____init()
    local anonymous = ____object
    print(total .. " " .. anonymous.size .. " " .. anonymous:last() .. " " .. __K2L_Str(anonymous:map(function(it) return it + 1 end)))
    print(Pair:getSize() .. " " .. __K2L_Str(Pair:toList()) .. " " .. Pair:last() .. " " .. Words.size .. " " .. __K2L_Str(Words:sorted()) .. " " .. Words:first())
end

local Traced = __K2L_Class("Traced", __K2L_ListBase)
Traced.____readOnly = true

function Traced:____init(inner)
    self.inner = inner
    self.____delegate_List = inner
    self.log = __K2L_ListOf()
end

function Traced:iterator()
    self.log:add("iterator")
    return __K2L_IteratorOf(self.inner)
end

function Traced:get(index)
    self.log:add("get " .. index)
    return self.inner:get(index)
end

function Traced:isEmpty()
    return self.____delegate_List:isEmpty()
end

function Traced:contains(element)
    return self.____delegate_List:contains(element)
end

function Traced:containsAll(elements)
    return self.____delegate_List:containsAll(elements)
end

function Traced:indexOf(element)
    return self.____delegate_List:indexOf(element)
end

function Traced:lastIndexOf(element)
    return self.____delegate_List:lastIndexOf(element)
end

function Traced:listIterator()
    return __K2L_JdkCollections.listIterator(self.____delegate_List)
end

function Traced:listIteratorAt(index)
    return __K2L_JdkCollections.listIterator(self.____delegate_List, index)
end

function Traced:subList(fromIndex, toIndex)
    return self.____delegate_List:subList(fromIndex, toIndex)
end

function Traced:getSize()
    return self.____delegate_List.size
end

__K2L_PropertyOverride(Traced, "size", "getSize")

local function traced()
    local t = Traced.new(__K2L_ReadOnlyListOf(4, 5, 6))
    local ____list_3 = t:toList()
    for ____i_4 = 1, ____list_3.size do
        local x = ____list_3[____i_4]
        io.write(x .. " ")
    end
    local ____list_4 = t:toList()
    for ____i_5 = 1, ____list_4.size do
        local it = ____list_4[____i_5]
        io.write(it .. " ")
    end
    print(__K2L_Str(t.log))
    t.log:clear()
    print(t:joinToString() .. " " .. __K2L_Str(t:map(function(it) return it * 2 end)) .. " " .. t:sum() .. " " .. __K2L_Str(t:toList()) .. " " .. tostring(t:contains(5)) .. " " .. __K2L_Str(t.log))
    t.log:clear()
    print(t:first() .. " " .. t:last() .. " " .. t:get(1) .. " " .. __K2L_Str(t:getOrNull(2)) .. " " .. __K2L_Str(t.log))
end

Pair = __K2L_Class("Pair", __K2L_AbstractList)
Pair.____readOnly = true

function Pair:getSize()
    return 2
end

function Pair:get(index)
    return index * 10
end

__K2L_PropertyOverride(Pair, "size", "getSize", true)
Words = __K2L_Class("Words", __K2L_ListBase)
Words.____readOnly = true

function Words:____init()
    self.____delegate_List = __K2L_ReadOnlyListOf("b", "a")
end

function Words:isEmpty()
    return self.____delegate_List:isEmpty()
end

function Words:contains(element)
    return self.____delegate_List:contains(element)
end

function Words:iterator()
    return __K2L_IteratorOf(self.____delegate_List)
end

function Words:containsAll(elements)
    return self.____delegate_List:containsAll(elements)
end

function Words:get(index)
    return self.____delegate_List:get(index)
end

function Words:indexOf(element)
    return self.____delegate_List:indexOf(element)
end

function Words:lastIndexOf(element)
    return self.____delegate_List:lastIndexOf(element)
end

function Words:listIterator()
    return __K2L_JdkCollections.listIterator(self.____delegate_List)
end

function Words:listIteratorAt(index)
    return __K2L_JdkCollections.listIterator(self.____delegate_List, index)
end

function Words:subList(fromIndex, toIndex)
    return self.____delegate_List:subList(fromIndex, toIndex)
end

function Words:getSize()
    return self.____delegate_List.size
end

__K2L_PropertyOverride(Words, "size", "getSize", true)
Words:____init()

local function main()
    comparators()
    lists()
    maps()
    others()
    more()
    traced()
end

main()
return {Counting = Counting, Plain = Plain, Logging = Logging, ReadOnly = ReadOnly, Tagged = Tagged, Lookup = Lookup, Unique = Unique, Bag = Bag, Wrap = Wrap, Steps = Steps, Name = Name, Job = Job, Twice = Twice, comparators = comparators, lists = lists, maps = maps, others = others, Sized = Sized, Pool = Pool, Draining = Draining, Version = Version, Release = Release, Pairing = Pairing, Lines = Lines, Window = Window, Layer = Layer, more = more, Traced = Traced, traced = traced, Pair = Pair, Words = Words}
