local ____lualib = require("lualib_bundle")
local __K2L_AbstractCollection = ____lualib.__K2L_AbstractCollection
local __K2L_AbstractIterator = ____lualib.__K2L_AbstractIterator
local __K2L_AbstractMap = ____lualib.__K2L_AbstractMap
local __K2L_AbstractSet = ____lualib.__K2L_AbstractSet
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Entry = ____lualib.__K2L_Entry
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_Iterable = ____lualib.__K2L_Iterable
local __K2L_IterableBase = ____lualib.__K2L_IterableBase
local __K2L_Iterator = ____lualib.__K2L_Iterator
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PropertyOverride = ____lualib.__K2L_PropertyOverride
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Set = ____lualib.__K2L_Set
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_SimpleName = ____lualib.__K2L_SimpleName
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local CountingIterator
local Evens = __K2L_Class("Evens", __K2L_AbstractSet)

function Evens:____init(limit)
    self.limit = limit
end

function Evens:getSize()
    return (self.limit + 1) // 2
end

function Evens:iterator()
    return __K2L_IteratorOf(__K2L_IntRange.new(0, self.limit - 1):withStep(2))
end

__K2L_PropertyOverride(Evens, "size", "getSize")
local Bag = __K2L_Class("Bag", __K2L_AbstractCollection)

function Bag:____init()
    self.items = __K2L_ListOf()
end

function Bag:getSize()
    return self.items.size
end

function Bag:add(element)
    return self.items:add(element)
end

function Bag:iterator()
    return __K2L_IteratorOf(self.items)
end

__K2L_PropertyOverride(Bag, "size", "getSize")
local Tags = __K2L_Class("Tags", __K2L_AbstractSet)

function Tags:____init()
    self.items = __K2L_Set.new()
    self.removes = 0
end

function Tags:getSize()
    return self.items.size
end

function Tags:add(element)
    return self.items:add(element:lower())
end

function Tags:iterator()
    return CountingIterator.new(self, __K2L_IteratorOf(self.items))
end

__K2L_PropertyOverride(Tags, "size", "getSize")
CountingIterator = __K2L_Class("CountingIterator")

function CountingIterator:____init(owner, inner)
    self.owner = owner
    self.inner = inner
end

function CountingIterator.new(owner, inner)
    return setmetatable({owner = owner, inner = inner}, CountingIterator)
end

function CountingIterator:hasNext()
    return self.inner:hasNext()
end

function CountingIterator:next()
    return self.inner:next()
end

function CountingIterator:remove()
    local ____object = self.owner
    ____object.removes = ____object.removes + 1
    self.inner:remove()
end

local Pair2 = __K2L_Class("Pair2")
rawget(Pair2, "____interfaces")[__K2L_Entry] = true

function Pair2:____init(key, value)
    self.key = key
    self.value = value
end

function Pair2.new(key, value)
    return setmetatable({key = key, value = value}, Pair2)
end

function Pair2:toString()
    return "Pair2(key=" .. self.key .. ", value=" .. self.value .. ")"
end

function Pair2:hashCode()
    return (31 * __K2L_Hash(self.key) + self.value + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Pair2:equals(other)
    return getmetatable(other) == Pair2 and self.key == other.key and self.value == other.value
end

local Squares = __K2L_Class("Squares", __K2L_AbstractMap)

function Squares:____init(n)
    self.n = n
end

local ____lambda_1 = function(it) return Pair2.new("k" .. it, it * it) end
function Squares:getEntries()
    return __K2L_IntRange.new(1, self.n):map(____lambda_1):toSet()
end

__K2L_PropertyOverride(Squares, "entries", "getEntries")
local Registry = __K2L_Class("Registry", __K2L_AbstractMap)

function Registry:____init()
    self.backing = __K2L_Map.new()
    self.log = __K2L_ListOf()
end

function Registry:getEntries()
    return self.backing:getEntries()
end

function Registry:put(key, value)
    self.log:add("put(" .. key .. ")")
    return self.backing:put(key, value)
end

__K2L_PropertyOverride(Registry, "entries", "getEntries")
local Countdown = __K2L_Class("Countdown", __K2L_AbstractIterator)

function Countdown:____init(from)
    self.from = from
end

function Countdown:computeNext()
    if self.from < 0 then
        self:done()
    else
        local ____old = self.from
        self.from = self.from - 1
        self:setNext(____old)
    end
end

local Faulty = __K2L_Class("Faulty", __K2L_AbstractIterator)

function Faulty:____init()
    self.n = 0
end

function Faulty:computeNext()
    self.n = self.n + 1
    if self.n == 2 then
        error(__K2L_IllegalStateException.new("boom"))
    end
    self:setNext(self.n)
end

local Words = __K2L_Class("Words", __K2L_IterableBase)

function Words:____init(text)
    self.text = text
end

function Words:iterator()
    return __K2L_IteratorOf(__K2L_StringSplit(self.text, " "))
end

local Stack = __K2L_Class("Stack", __K2L_List)

function Stack:____init()
    __K2L_List.____init(self)
    self.pushes = 0
end

function Stack:add(element)
    self.pushes = self.pushes + 1
    return __K2L_List.add(self, element)
end

function Stack:peek()
    return self:get(self.size - 1)
end

function Stack:toString()
    return "Stack" .. __K2L_List.toString(self)
end

local Seeded = __K2L_Class("Seeded", __K2L_Set)

function Seeded:____init(elements)
    __K2L_Set.____init(self, elements)
end

function Seeded:add(element)
    print("Seeded.add(" .. element .. ")")
    return __K2L_Set.add(self, element)
end

local InstrumentedSet = __K2L_Class("InstrumentedSet", __K2L_Set)

function InstrumentedSet:____init()
    __K2L_Set.____init(self)
    self.attempts = 0
end

function InstrumentedSet:add(element)
    self.attempts = self.attempts + 1
    return __K2L_Set.add(self, element)
end

function InstrumentedSet:addAll(elements)
    self.attempts = self.attempts + elements.size
    return __K2L_Set.addAll(self, elements)
end

local Ordered = __K2L_Class("Ordered", __K2L_Set)

function Ordered:____init()
    __K2L_Set.____init(self)
end

function Ordered:remove(element)
    return __K2L_Set.remove(self, element * 2)
end

local DefaultMap = __K2L_Class("DefaultMap", __K2L_Map)

function DefaultMap:____init()
    __K2L_Map.____init(self)
end

function DefaultMap:get(key)
    return __K2L_Map.get(self, key) or 0
end

local Lru = __K2L_Class("Lru", __K2L_Map)

function Lru:____init(capacity)
    __K2L_Map.____init(self)
    self.capacity = capacity
end

function Lru:removeEldestEntry(eldest)
    return self.size > self.capacity
end

local Copied = __K2L_Class("Copied", __K2L_Map)

function Copied:____init(source)
    __K2L_Map.____init(self, source)
    self.puts = 0
end

function Copied:put(key, value)
    self.puts = self.puts + 1
    return __K2L_Map.put(self, key, value)
end

local ____lambda_2 = function(it) return it // 2 end
local ____lambda_3 = function(it) return it > 3 end
local ____lambda_4 = function(it) return it == "b" end
local function sets()
    local e = Evens.new(9)
    print(__K2L_Str(e) .. " " .. e:getSize() .. " " .. tostring(e:contains(4)) .. " " .. tostring(e:contains(5)) .. " " .. tostring(e:equals(__K2L_SetOf(0, 2, 4, 6, 8))) .. " " .. tostring(__K2L_Equals(__K2L_SetOf(8, 6, 4, 2, 0), e)) .. " " .. tostring(e:hashCode() == __K2L_Hash(__K2L_SetOf(0, 2, 4, 6, 8))))
    print(__K2L_Str(e:map(____lambda_2)) .. " " .. __K2L_Str(e:filter(____lambda_3)) .. " " .. e:sum() .. " " .. __K2L_Str(e:sortedDescending()) .. " " .. tostring(e:containsAll(__K2L_ListOf(2, 4))) .. " " .. tostring(__K2L_InstanceOf(e, __K2L_Set)))
    local total = 0
    local ____items, ____n = e:____array()
    for ____i = 1, ____n do
        local x = ____items[____i]
        total = total + x
    end
    print("loop " .. total .. " " .. e:first() .. " " .. e:last() .. " " .. __K2L_Str(e:toList()) .. " " .. e:joinToString("|"))
    local bag = Bag.new()
    bag:add("b")
    bag:addAll(__K2L_ListOf("a", "b"))
    print("bag " .. __K2L_Str(bag) .. " " .. bag:getSize() .. " " .. tostring(bag:contains("a")) .. " " .. bag:count(____lambda_4))
    bag:remove("b")
    print("bag remove " .. __K2L_Str(bag) .. " " .. tostring(bag:equals(Bag.new())) .. " " .. tostring(__K2L_InstanceOf(bag, __K2L_List)))
    bag:clear()
    print("bag clear " .. __K2L_Str(bag) .. " " .. tostring(bag:isEmpty()))
    local tags = Tags.new()
    tags:add("Red")
    tags:addAll(__K2L_ListOf("GREEN", "red", "Blue"))
    print("tags " .. __K2L_Str(tags) .. " " .. tags:getSize() .. " " .. tostring(tags:contains("green")))
    tags:removeAll(__K2L_ListOf("green", "blue", "pink"))
    print("removeAll " .. __K2L_Str(tags) .. " removes=" .. tags.removes)
    tags:addAll(__K2L_ListOf("x", "y", "z"))
    tags:removeAll(__K2L_ListOf("x"))
    tags:retainAll(__K2L_SetOf("red", "y"))
    print("retainAll " .. __K2L_Str(tags) .. " removes=" .. tags.removes .. " " .. tostring(tags:equals(__K2L_SetOf("y", "red"))))
end

local ____lambda_5 = function(it) return it.key .. it.value end
local ____lambda_6 = function(it) return it.value > 1 end
local ____lambda_7 = function(it) return it.value + 1 end
local ____lambda_8 = function(it) return it.value end
local ____lambda_9 = function() return 5 end
local ____lambda_10 = function() return 9 end
local function maps()
    local sq = Squares.new(3)
    print(__K2L_Str(sq) .. " " .. sq.size .. " " .. __K2L_Str(sq:get("k2")) .. " " .. __K2L_Str(sq:get("x")) .. " " .. tostring(sq:containsKey("k3")) .. " " .. tostring(sq:containsValue(9)) .. " " .. __K2L_Str(sq:getKeys()) .. " " .. __K2L_Str(sq:getValues()))
    print(tostring(sq:equals(__K2L_MapOf(__K2L_Pair.new("k1", 1), __K2L_Pair.new("k2", 4), __K2L_Pair.new("k3", 9)))) .. " " .. tostring(__K2L_Equals(__K2L_MapOf(__K2L_Pair.new("k1", 1), __K2L_Pair.new("k2", 4), __K2L_Pair.new("k3", 9)), sq)) .. " " .. tostring(sq:isEmpty()))
    local ____arg = __K2L_Str(sq:map(____lambda_5))
    local ____arg_1 = __K2L_Str(sq:filter(____lambda_6))
    local ____arg_2 = __K2L_Str(sq:mapValues(____lambda_7))
    local ____receiver = sq:maxByOrNull(____lambda_8)
    print(____arg .. " " .. ____arg_1 .. " " .. ____arg_2 .. " " .. __K2L_Str(____receiver and ____receiver.key))
    local ____keys, ____values, ____n_1 = sq:____arrays()
    for ____i_1 = 1, ____n_1 do
        local k, v = ____keys[____i_1], ____values[____i_1]
        io.write(k .. ":" .. v .. " ")
    end
    print(sq:getOrDefault("zz", -1))
    local r = Registry.new()
    r:set("a", 1)
    r:put("b", 2)
    r:putAll(__K2L_MapOf(__K2L_Pair.new("c", 3), __K2L_Pair.new("d", 4)))
    print("registry " .. __K2L_Str(r) .. " " .. r.size .. " " .. __K2L_Str(r:get("c")) .. " " .. __K2L_Str(r.log))
    print("remove " .. __K2L_Str(r:remove("b")) .. " " .. __K2L_Str(r:remove("zz")) .. " " .. __K2L_Str(r))
    print("getOrPut " .. r:getOrPut("e", ____lambda_9) .. " " .. r:getOrPut("a", ____lambda_10) .. " " .. __K2L_Str(r.log))
    r:clear()
    print("clear " .. __K2L_Str(r) .. " " .. tostring(r:isEmpty()) .. " " .. tostring(__K2L_InstanceOf(r, __K2L_Map)))
end

local ____lambda_11 = function(it) return it * 2 end
local ____lambda_12 = function(it) return #it end
local ____lambda_13 = function(it) return it end
local function iterators()
    local c = Countdown.new(3)
    print(tostring(c:hasNext()) .. " " .. tostring(c:hasNext()) .. " " .. c:next() .. " " .. c:next())
    local rest = __K2L_ListOf()
    for _, x in __K2L_Iterator.iter(c) do
        rest:add(x)
    end
    print("rest " .. __K2L_Str(rest) .. " " .. tostring(c:hasNext()))
    local ____ok, ____result = pcall(function()
        c:next()
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_NoSuchElementException) then
            local e = ____error
            print("done " .. __K2L_Str(__K2L_SimpleName(e)))
        else
            error(____error, 0)
        end
    end
    print(__K2L_Str(__K2L_AsSequence(Countdown.new(4)):map(____lambda_11):toList()))
    local f = Faulty.new()
    print("faulty " .. f:next())
    for step = 1, 2 do
        local ____ok_1, ____result_1 = pcall(function()
            f:hasNext()
        end)
        if not ____ok_1 then
            local ____error_1 = __K2L_ToThrowable(____result_1)
            if __K2L_InstanceOf(____error_1, __K2L_Exception) then
                local e = ____error_1
                print("faulty " .. step .. " " .. __K2L_Str(__K2L_SimpleName(e)) .. ": " .. __K2L_Str(e.message))
            else
                error(____error_1, 0)
            end
        end
    end
    local w = Words.new("the quick brown fox")
    print(__K2L_Str(w:map(____lambda_12)) .. " " .. w:count() .. " " .. w:first() .. " " .. __K2L_Str(w:sortedBy(____lambda_13, true)) .. " " .. w:joinToString("+"))
    local ____items_1, ____n_2 = w:____array()
    for ____i_2 = 1, ____n_2 do
        local x = ____items_1[____i_2]
        io.write(x .. ".")
    end
    print()
    print(tostring(__K2L_StringStartsWith(__K2L_Str(w), "Words@")) .. " " .. tostring(w:equals(Words.new("x"))) .. " " .. tostring(__K2L_InstanceOf(w, __K2L_Iterable)) .. " " .. tostring(__K2L_InstanceOf(w, __K2L_Iterable) and w.size ~= nil))
end

local function concrete()
    local s = Stack.new()
    s:add(1)
    s:add(2)
    s:addAll(__K2L_ListOf(3, 4))
    s:add(5)
    print(__K2L_Str(s) .. " " .. s:peek() .. " " .. s.size .. " pushes=" .. s.pushes .. " " .. s:sum() .. " " .. __K2L_Str(s:reversed()) .. " " .. __K2L_Str(__K2L_SimpleName(s)) .. " " .. tostring(__K2L_InstanceOf(s, __K2L_List)))
    s:removeAt(0)
    s:remove(4)
    s:set(0, 20)
    print(__K2L_Str(s) .. " " .. s:indexOf(3) .. " " .. tostring(s:equals(__K2L_ListOf(20, 3, 5))) .. " " .. tostring(s:contains(5)) .. " " .. tostring(s:hashCode() == __K2L_Hash(__K2L_ListOf(20, 3, 5))))
    print("seeded " .. __K2L_Str(Seeded.new(__K2L_ListOf("b", "a"))))
    local i = InstrumentedSet.new()
    i:addAll(__K2L_ListOf("c", "d", "a"))
    print(__K2L_Str(i) .. " attempts=" .. i.attempts .. " " .. i.size)
    local o = Ordered.new()
    o:addAll(__K2L_ListOf(1, 2, 3, 4))
    o:remove(2)
    print("ordered " .. __K2L_Str(o))
    local d = DefaultMap.new()
    d:set("x", 1)
    print("default " .. d:get("x") .. " " .. d:get("y") .. " " .. d:getValue("x") .. " " .. __K2L_Str(d))
    local lru = Lru.new(2)
    lru:set("a", 1)
    lru:set("b", 2)
    lru:get("a")
    lru:set("c", 3)
    print("lru " .. __K2L_Str(lru) .. " " .. __K2L_Str(lru:getKeys()))
    local copy = Copied.new(__K2L_MapOf(__K2L_Pair.new("p", 1), __K2L_Pair.new("q", 2)))
    copy:putAll(__K2L_MapOf(__K2L_Pair.new("r", 3)))
    copy:set("s", 4)
    print("copied " .. __K2L_Str(copy) .. " puts=" .. copy.puts)
end

local function main()
    sets()
    maps()
    iterators()
    concrete()
end

__K2L_RunMain(main)
return {Evens = Evens, Bag = Bag, Tags = Tags, CountingIterator = CountingIterator, Pair2 = Pair2, Squares = Squares, Registry = Registry, Countdown = Countdown, Faulty = Faulty, Words = Words, Stack = Stack, Seeded = Seeded, InstrumentedSet = InstrumentedSet, Ordered = Ordered, DefaultMap = DefaultMap, Lru = Lru, Copied = Copied, sets = sets, maps = maps, iterators = iterators, concrete = concrete}
