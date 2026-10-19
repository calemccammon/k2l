local ____lualib = require("lualib_bundle")
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_GenerateSequence = ____lualib.__K2L_GenerateSequence
local __K2L_GenerateSequenceLazy = ____lualib.__K2L_GenerateSequenceLazy
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_IndexOutOfBoundsException = ____lualib.__K2L_IndexOutOfBoundsException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_Iterator = ____lualib.__K2L_Iterator
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_SequenceFromIterator = ____lualib.__K2L_SequenceFromIterator
local __K2L_SequenceOf = ____lualib.__K2L_SequenceOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf
local __K2L_UnsupportedOperationException = ____lualib.__K2L_UnsupportedOperationException

local Countdown
local Item = __K2L_Class("Item")

function Item:____init(name, price)
    self.name = name
    self.price = price
end

function Item:toString()
    return "Item(name=" .. self.name .. ", price=" .. self.price .. ")"
end

function Item:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.name) + __K2L_Hash(self.price))
end

function Item:equals(other)
    return getmetatable(other) == Item and self.name == other.name and self.price == other.price
end

local function naturals()
    return __K2L_GenerateSequence(1, function(it) return it + 1 end)
end

local function fibonacci()
    return __K2L_GenerateSequence(__K2L_Pair.new(0, 1), function(____destructured)
        local a, b = ____destructured.first, ____destructured.second
        return __K2L_Pair.new(b, a + b)
    end):map(function(it) return it.first end)
end

local function laziness()
    print("-- laziness")
    local result = __K2L_AsSequence(__K2L_ReadOnlyListOf(1, 2, 3, 4)):map(function(it)
        print("map " .. it)
        return it * 10
    end):filter(function(it)
        print("filter " .. it)
        return it > 15
    end):first()
    print("first = " .. result)
    local pipeline = __K2L_SequenceOf("a", "bb", "ccc"):onEach(function(it)
        print("saw " .. it)
    end):map(function(it) return #it end)
    print("nothing evaluated yet")
    for _, n in pipeline:iter() do
        print("got " .. n)
    end
    for _, it in pipeline:iter() do
        print("again " .. it)
    end
    local folded = __K2L_AsSequence(__K2L_IntRange.new(1, 4)):map(function(it)
        print("m" .. it)
        return it
    end):fold(0, function(acc, x)
        print("f" .. x)
        return acc + x
    end)
    print("folded " .. folded)
end

local function infinite()
    print("-- infinite")
    print(__K2L_Str(naturals():take(5):toList()))
    print(__K2L_Str(naturals():filter(function(it) return math.fmod(it, 3) == 0 end):map(function(it) return it * it end):take(4):toList()))
    print(naturals():first(function(it) return it * it > 50 end))
    print(naturals():takeWhile(function(it) return it < 6 end):joinToString("-"))
    print(__K2L_Str(naturals():drop(3):take(2):toList()))
    print(__K2L_Str(naturals():dropWhile(function(it) return it < 10 end):firstOrNull()))
    print(naturals():any(function(it) return it > 100 end))
    print(naturals():elementAt(9))
    print(naturals():indexOf(7))
    print(naturals():contains(12))
    print(__K2L_Str(fibonacci():take(10):toList()))
    print(naturals():joinToString(nil, nil, nil, 3))
    print(__K2L_Str(naturals():zip(naturals():map(function(it) return it * it end)):take(3):toList()))
    local calls = 0
    local counted = __K2L_GenerateSequence(1, function(it)
        calls = calls + 1
        return it * 2
    end)
    print(__K2L_Str(counted:take(4):toList()))
    print("next called " .. calls .. " times")
    local n = 3
    local countdown = __K2L_GenerateSequenceLazy(function()
        if n > 0 then
            local ____old = n
            n = n - 1
            return ____old
        else
            return nil
        end
    end)
    print(__K2L_Str(countdown:toList()))
    local ____ok, ____result = pcall(function()
        countdown:toList()
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_IllegalStateException) then
            local e = ____error
            print("once: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    print(__K2L_Str(__K2L_GenerateSequenceLazy(function() return 10 end, function(it) return it > 7 and it - 1 or nil end):toList()))
    local nothing = nil
    print(__K2L_GenerateSequence(nothing, function(it) return it + 1 end):count())
end

local function operations()
    print("-- operations")
    local items = __K2L_ReadOnlyListOf(Item.new("apple", 3), Item.new("pear", 5), Item.new("fig", 2), Item.new("kiwi", 5))
    local seq = __K2L_AsSequence(items)
    print(__K2L_Str(seq:map(function(it) return it.name end):toList()))
    print(__K2L_Str(seq:filterNot(function(it) return it.price > 3 end):map(function(it) return it.name end):toSet()))
    print(__K2L_Str(seq:mapNotNull(function(it)
        return it.price > 2 and it.name:upper() or nil
    end):toList()))
    print(__K2L_Str(seq:mapIndexed(function(i, item) return i .. ":" .. item.name end):toList()))
    print(seq:flatMap(function(it) return __K2L_AsSequence(it.name) end):distinct():count())
    print(__K2L_Str(seq:flatMap(function(it)
        return __K2L_ReadOnlyListOf(it.price, -it.price)
    end):toList()))
    print(__K2L_Str(seq:map(function(it) return it.price end):distinct():toList()))
    print(__K2L_Str(seq:distinctBy(function(it) return it.price end):map(function(it) return it.name end):toList()))
    print(seq:withIndex():map(function(____destructured_1)
        local i, item = ____destructured_1.index, ____destructured_1.value
        return i * item.price
    end):sum())
    print(seq:sumOf(function(it) return it.price end))
    print(__K2L_Str(seq:map(function(it) return it.price + 0.0 end):sum(0.0)))
    print(__K2L_Str(seq:map(function(it) return it.price end):average()))
    print(seq:count(function(it) return it.price == 5 end))
    print(seq:all(function(it) return it.price > 1 end))
    print(seq:none(function(it) return #it.name == 0 end))
    print(seq:maxBy(function(it) return it.price end).name)
    local ____receiver = seq:minByOrNull(function(it) return it.price end)
    print(__K2L_Str(____receiver and ____receiver.name))
    print(__K2L_Str(seq:map(function(it) return it.price end):maxOrNull()))
    print(seq:map(function(it) return it.name end):min())
    print(seq:maxOf(function(it) return #it.name end))
    print(__K2L_Str(seq:sortedBy(function(it) return it.price end, true):map(function(it) return it.name end):toList()))
    print(seq:sortedByDescending(function(it) return it.name end, true):first().name)
    print(__K2L_Str(seq:map(function(it) return it.price end):sorted():toList()))
    print(__K2L_Str(seq:map(function(it) return it.price end):sortedDescending():toList()))
    print(__K2L_Str(seq:sortedWith(__K2L_CompareBy(function(it) return it.price end, function(it) return it.name end)):map(function(it) return it.name end):toList()))
    print(__K2L_Str(seq:associate(function(it) return __K2L_Pair.new(it.name, it.price) end)))
    print(__K2L_Str(seq:associateBy(function(it) return __K2L_Text.first(it.name) end):getKeys()))
    print(__K2L_Str(seq:groupBy(function(it) return it.price end):mapValues(function(____destructured_2)
        local v = ____destructured_2.value
        return v.size
    end)))
    print(__K2L_Str(seq:map(function(it) return __K2L_Pair.new(it.name, it.price) end):toMap()))
    print(__K2L_Str(seq:partition(function(it) return it.price > 3 end).first:map(function(it) return it.name end)))
    print(seq:map(function(it) return it.price end):reduce(function(a, b) return a * b end))
    print(__K2L_Str(seq:find(function(it) return it.price == 2 end)))
    print(__K2L_Str(seq:findLast(function(it) return it.price == 5 end)))
    print(seq:last().name)
    print(__K2L_Str(seq:lastOrNull(function(it) return it.price > 100 end)))
    print(__K2L_Str(seq:single(function(it) return it.name == "fig" end)))
    print(__K2L_Str(seq:singleOrNull(function(it) return it.price == 5 end)))
    print(__K2L_Str(seq:map(function(it) return it.name end):chunked(3):toList()))
    print(__K2L_Str(__K2L_AsSequence(__K2L_IntRange.new(1, 7)):windowed(3, 2):toList()))
    print(__K2L_Str(__K2L_AsSequence(__K2L_IntRange.new(1, 7)):windowed(3, 3, true):map(function(it) return it:sum() end):toList()))
    print(__K2L_Str(__K2L_SequenceOf(1, 2, 3):plus(4):plusAll(__K2L_ReadOnlyListOf(5, 6)):plusAll(__K2L_SequenceOf(7)):toList()))
    print(__K2L_Str(__K2L_SequenceOf(1, 2, 3, 2):minus(2):toList()))
    print(__K2L_Str(__K2L_SequenceOf(3, 1, 2):zip(__K2L_SequenceOf("c", "a"), function(n, s) return s .. n end):toList()))
    print(__K2L_Str(__K2L_SequenceOf(1, 2, 3):zipWithNext():toList()))
    print(__K2L_Str(__K2L_SequenceOf(1, 2, 3, 4):runningFold(0, function(acc, x) return acc + x end):toList()))
    print(__K2L_Str(__K2L_SequenceOf(1, 2, 3, 4):scan(1, function(acc, x) return acc * x end):toList()))
    print(__K2L_Str(__K2L_SequenceOf(1, 2, 3, 4):runningReduce(function(acc, x) return acc + x end):toList()))
    print(__K2L_Str(__K2L_SequenceOf(1, nil, 2, nil):filterNotNull():toList()))
    print(__K2L_Str(__K2L_SequenceOf("x", "y"):filterIndexed(function(i, _) return i == 1 end):toList()))
    print(__K2L_SequenceOf(1, 2, 3):foldIndexed(0, function(i, acc, x) return acc + i * x end))
    __K2L_SequenceOf("p", "q"):forEachIndexed(function(i, s)
        print(i .. "=" .. s)
    end)
    print(__K2L_Str(__K2L_SequenceOf():firstOrNull()))
    print(__K2L_SequenceOf():joinToString(nil, "[", "]"))
    local ____value = __K2L_SequenceOf(1, 2):toMutableList()
    ____value:add(3)
    print(__K2L_Str(____value))
    print(__K2L_Str(__K2L_AsSequence(__K2L_ReadOnlyListOf(3, 4)):ifEmpty(function() return __K2L_SequenceOf(0) end):toList()))
    print(__K2L_Str(__K2L_SequenceOf():ifEmpty(function() return __K2L_SequenceOf(0) end):toList()))
end

local function sources()
    print("-- sources")
    print(__K2L_AsSequence("hey"):map(function(it) return it:upper() end):joinToString(""))
    print(__K2L_Str(__K2L_AsSequence(__K2L_ReadOnlyMapOf(__K2L_Pair.new(1, "one"), __K2L_Pair.new(2, "two"))):map(function(it) return it.key .. "=" .. it.value end):toList()))
    print(__K2L_Str(__K2L_AsSequence(__K2L_TypedArrayOf("[Ljava.lang.Integer;", 5, 6, 7)):filter(function(it) return it ~= 6 end):toList()))
    print(__K2L_Str(__K2L_AsSequence(__K2L_ReadOnlySetOf("s", "t")):toList()))
    print(__K2L_Str(__K2L_AsSequence(__K2L_IntRange.new(10, 1, -1):withStep(3)):toList()))
    local custom = __K2L_SequenceFromIterator(function()
        return __K2L_IteratorOf(__K2L_ReadOnlyListOf(1, 2, 3))
    end)
    print(__K2L_Str(custom:map(function(it) return it * 2 end):toList()))
    print(__K2L_Str(custom:toList()))
    local it = __K2L_SequenceOf(4, 5, 6):iterator()
    while it:hasNext() do
        io.write(it:next() .. " ")
    end
    print()
    local once = __K2L_AsSequence(__K2L_IteratorOf(__K2L_ReadOnlyListOf(7, 8)))
    print(__K2L_Str(once:toList()))
    local ____ok_1, ____result_1 = pcall(function()
        once:toList()
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error_1, __K2L_IllegalStateException) then
            local e = ____error_1
            print(__K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
    local reusable = __K2L_AsSequence(__K2L_ReadOnlyListOf(1, 2)):map(function(it) return it + 1 end)
    print(__K2L_Str(reusable:toList():plusAll(reusable:toList())))
    local s = reusable
    print(__K2L_InstanceOf(s, __K2L_Sequence))
    for _, ____item in __K2L_SequenceOf("a", "b"):withIndex():iter() do
        local i, v = ____item.index, ____item.value
        print(i .. " -> " .. v)
    end
    print(__K2L_Str(__K2L_SingletonListOf(0):plusAll(__K2L_SequenceOf(1, 2))))
    local target = __K2L_ListOf(1)
    target:addAll(__K2L_SequenceOf(2, 3))
    print(__K2L_Str(target))
    print(__K2L_Str(__K2L_SequenceFromIterator(function() return Countdown.new(3) end):map(function(it) return it * 10 end):toList()))
    print(__K2L_Str(__K2L_AsSequence(Countdown.new(2)):toList()))
    local manual = Countdown.new(2)
    for _, x in __K2L_Iterator.iter(manual) do
        print("manual " .. x)
    end
end

Countdown = __K2L_Class("Countdown")

function Countdown:____init(n)
    self.n = n
end

function Countdown:hasNext()
    return self.n > 0
end

function Countdown:next()
    local ____old_1 = self.n
    self.n = self.n - 1
    return ____old_1
end

local function errors()
    print("-- errors")
    local ____ok_2, ____result_2 = pcall(function()
        __K2L_SequenceOf():first()
    end)
    if not ____ok_2 then
        local ____error_2 = __K2L_ToThrowable(____result_2)
        if __K2L_InstanceOf(____error_2, __K2L_NoSuchElementException) then
            local e = ____error_2
            print(__K2L_Str(e.message))
        else
            error(____error_2, 0)
        end
    end
    local ____ok_3, ____result_3 = pcall(function()
        __K2L_SequenceOf(1, 2):single()
    end)
    if not ____ok_3 then
        local ____error_3 = __K2L_ToThrowable(____result_3)
        if __K2L_InstanceOf(____error_3, __K2L_IllegalArgumentException) then
            local e = ____error_3
            print(__K2L_Str(e.message))
        else
            error(____error_3, 0)
        end
    end
    local ____ok_4, ____result_4 = pcall(function()
        naturals():take(3):elementAt(5)
    end)
    if not ____ok_4 then
        local ____error_4 = __K2L_ToThrowable(____result_4)
        if __K2L_InstanceOf(____error_4, __K2L_IndexOutOfBoundsException) then
            local e = ____error_4
            print(__K2L_Str(e.message))
        else
            error(____error_4, 0)
        end
    end
    local ____ok_5, ____result_5 = pcall(function()
        __K2L_SequenceOf():reduce(function(a, b) return a + b end)
    end)
    if not ____ok_5 then
        local ____error_5 = __K2L_ToThrowable(____result_5)
        if __K2L_InstanceOf(____error_5, __K2L_UnsupportedOperationException) then
            local e = ____error_5
            print(__K2L_Str(e.message))
        else
            error(____error_5, 0)
        end
    end
    local ____ok_6, ____result_6 = pcall(function()
        naturals():take(-1)
    end)
    if not ____ok_6 then
        local ____error_6 = __K2L_ToThrowable(____result_6)
        if __K2L_InstanceOf(____error_6, __K2L_IllegalArgumentException) then
            local e = ____error_6
            print(__K2L_Str(e.message))
        else
            error(____error_6, 0)
        end
    end
    local ____ok_7, ____result_7 = pcall(function()
        for _, it in __K2L_SequenceOf(1, 2, 3):map(function(it)
            if it == 2 then
                error(__K2L_IllegalStateException.new("bad " .. it))
            else
                return it
            end
        end):iter() do
            print("ok " .. it)
        end
    end)
    if not ____ok_7 then
        local ____error_7 = __K2L_ToThrowable(____result_7)
        if __K2L_InstanceOf(____error_7, __K2L_IllegalStateException) then
            local e = ____error_7
            print("caught " .. __K2L_Str(e.message))
        else
            error(____error_7, 0)
        end
    end
end

local function main()
    laziness()
    infinite()
    operations()
    sources()
    errors()
end

main()
return {Item = Item, naturals = naturals, fibonacci = fibonacci, laziness = laziness, infinite = infinite, operations = operations, sources = sources, Countdown = Countdown, errors = errors}
