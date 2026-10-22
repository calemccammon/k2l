local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CompareValues = ____lualib.__K2L_CompareValues
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
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_SequenceFromIterator = ____lualib.__K2L_SequenceFromIterator
local __K2L_SequenceOf = ____lualib.__K2L_SequenceOf
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_UnsupportedOperationException = ____lualib.__K2L_UnsupportedOperationException

local Countdown
local Item = __K2L_Class("Item")

function Item:____init(name, price)
    self.name = name
    self.price = price
end

function Item.new(name, price)
    return setmetatable({name = name, price = price}, Item)
end

function Item:toString()
    return "Item(name=" .. self.name .. ", price=" .. self.price .. ")"
end

function Item:hashCode()
    return (31 * __K2L_Hash(self.name) + self.price + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Item:equals(other)
    return getmetatable(other) == Item and self.name == other.name and self.price == other.price
end

local ____lambda_1 = function(it) return it + 1 end
local function naturals()
    return __K2L_GenerateSequence(1, ____lambda_1)
end

local ____lambda_2 = function(it) return it.first end
local function fibonacci()
    return __K2L_GenerateSequence(__K2L_Pair.new(0, 1), function(____destructured)
        local a, b = ____destructured.first, ____destructured.second
        return __K2L_Pair.new(b, a + b)
    end):map(____lambda_2)
end

local ____lambda_3 = function(it) return #it end
local function laziness()
    print("-- laziness")
    local result = __K2L_AsSequence(__K2L_ListOf(1, 2, 3, 4)):map(function(it)
        print("map " .. it)
        return it * 10
    end):filter(function(it)
        print("filter " .. it)
        return it > 15
    end):first()
    print("first = " .. result)
    local pipeline = __K2L_SequenceOf("a", "bb", "ccc"):onEach(function(it)
        print("saw " .. it)
    end):map(____lambda_3)
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

local ____lambda_4 = function(it) return it % 3 == 0 end
local ____lambda_5 = function(it) return it * it end
local ____lambda_6 = function(it) return it * it > 50 end
local ____lambda_7 = function(it) return it < 6 end
local ____lambda_8 = function(it) return it < 10 end
local ____lambda_9 = function(it) return it > 100 end
local ____lambda_10 = function(it) return it * it end
local ____lambda_11 = function() return 10 end
local ____lambda_12 = function(it) return it > 7 and it - 1 or nil end
local ____lambda_13 = function(it) return it + 1 end
local function infinite()
    print("-- infinite")
    print(__K2L_Str(naturals():take(5):toList()))
    print(__K2L_Str(naturals():filter(____lambda_4):map(____lambda_5):take(4):toList()))
    print(naturals():first(____lambda_6))
    print(naturals():takeWhile(____lambda_7):joinToString("-"))
    print(__K2L_Str(naturals():drop(3):take(2):toList()))
    print(__K2L_Str(naturals():dropWhile(____lambda_8):firstOrNull()))
    print(naturals():any(____lambda_9))
    print(naturals():elementAt(9))
    print(naturals():indexOf(7))
    print(naturals():contains(12))
    print(__K2L_Str(fibonacci():take(10):toList()))
    print(naturals():joinToString(nil, nil, nil, 3))
    print(__K2L_Str(naturals():zip(naturals():map(____lambda_10)):take(3):toList()))
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
    print(__K2L_Str(__K2L_GenerateSequenceLazy(____lambda_11, ____lambda_12):toList()))
    local nothing = nil
    print(__K2L_GenerateSequence(nothing, ____lambda_13):count())
end

local ____lambda_14 = function(it) return it.name end
local ____lambda_15 = function(it) return it.price > 3 end
local ____lambda_16 = function(it) return it.name end
local ____lambda_17 = function(it)
    return it.price > 2 and it.name:upper() or nil
end
local ____lambda_18 = function(i, item) return i .. ":" .. item.name end
local ____lambda_19 = function(it) return __K2L_AsSequence(it.name) end
local ____lambda_20 = function(it) return __K2L_ListOf(it.price, -it.price) end
local ____lambda_21 = function(it) return it.price end
local ____lambda_22 = function(it) return it.price end
local ____lambda_23 = function(it) return it.name end
local ____lambda_24 = function(it) return it.price end
local ____lambda_25 = function(it) return it.price + 0.0 end
local ____lambda_26 = function(it) return it.price end
local ____lambda_27 = function(it) return it.price == 5 end
local ____lambda_28 = function(it) return it.price > 1 end
local ____lambda_29 = function(it) return #it.name == 0 end
local ____lambda_30 = function(it) return it.price end
local ____lambda_31 = function(it) return it.price end
local ____lambda_32 = function(it) return it.price end
local ____lambda_33 = function(it) return it.name end
local ____lambda_34 = function(it) return #it.name end
local ____lambda_35 = function(it) return it.price end
local ____lambda_36 = function(it) return it.name end
local ____lambda_37 = function(it) return it.name end
local ____lambda_38 = function(it) return it.price end
local ____lambda_39 = function(it) return it.price end
local ____lambda_40 = function(____a, ____b)
    local ____x, ____y = ____a.price, ____b.price
    if ____x ~= ____y then
        return ____x < ____y and -1 or 1
    end
    return __K2L_CompareValues(____a.name, ____b.name)
end
local ____lambda_41 = function(it) return it.name end
local ____lambda_42 = function(it) return __K2L_Pair.new(it.name, it.price) end
local ____lambda_43 = function(it) return __K2L_Text.first(it.name) end
local ____lambda_44 = function(it) return it.price end
local ____lambda_45 = function(it) return __K2L_Pair.new(it.name, it.price) end
local ____lambda_46 = function(it) return it.price > 3 end
local ____lambda_47 = function(it) return it.price end
local ____lambda_48 = function(a, b) return a * b end
local ____lambda_49 = function(it) return it.price == 2 end
local ____lambda_50 = function(it) return it.price == 5 end
local ____lambda_51 = function(it) return it.price > 100 end
local ____lambda_52 = function(it) return it.name == "fig" end
local ____lambda_53 = function(it) return it.price == 5 end
local ____lambda_54 = function(it) return it.name end
local ____lambda_55 = function(it) return it:sum() end
local ____lambda_56 = function(n, s) return s .. n end
local ____lambda_57 = function(acc, x) return acc + x end
local ____lambda_58 = function(acc, x) return acc * x end
local ____lambda_59 = function(acc, x) return acc + x end
local ____lambda_60 = function(i, _) return i == 1 end
local ____lambda_61 = function(i, acc, x) return acc + i * x end
local ____lambda_62 = function() return __K2L_SequenceOf(0) end
local ____lambda_63 = function() return __K2L_SequenceOf(0) end
local function operations()
    print("-- operations")
    local items = __K2L_ListOf(Item.new("apple", 3), Item.new("pear", 5), Item.new("fig", 2), Item.new("kiwi", 5))
    local seq = __K2L_AsSequence(items)
    print(__K2L_Str(seq:map(____lambda_14):toList()))
    print(__K2L_Str(seq:filterNot(____lambda_15):map(____lambda_16):toSet()))
    print(__K2L_Str(seq:mapNotNull(____lambda_17):toList()))
    print(__K2L_Str(seq:mapIndexed(____lambda_18):toList()))
    print(seq:flatMap(____lambda_19):distinct():count())
    print(__K2L_Str(seq:flatMap(____lambda_20):toList()))
    print(__K2L_Str(seq:map(____lambda_21):distinct():toList()))
    print(__K2L_Str(seq:distinctBy(____lambda_22):map(____lambda_23):toList()))
    print(seq:withIndex():map(function(____destructured_1)
        local i, item = ____destructured_1.index, ____destructured_1.value
        return i * item.price
    end):sum())
    print(seq:sumOf(____lambda_24))
    print(seq:map(____lambda_25):sum(0.0))
    print(seq:map(____lambda_26):average())
    print(seq:count(____lambda_27))
    print(seq:all(____lambda_28))
    print(seq:none(____lambda_29))
    print(seq:maxBy(____lambda_30).name)
    local ____receiver = seq:minByOrNull(____lambda_31)
    print(__K2L_Str(____receiver and ____receiver.name))
    print(__K2L_Str(seq:map(____lambda_32):maxOrNull()))
    print(seq:map(____lambda_33):min())
    print(seq:maxOf(____lambda_34))
    print(__K2L_Str(seq:sortedBy(____lambda_35, true):map(____lambda_36):toList()))
    print(seq:sortedByDescending(____lambda_37, true):first().name)
    print(__K2L_Str(seq:map(____lambda_38):sorted():toList()))
    print(__K2L_Str(seq:map(____lambda_39):sortedDescending():toList()))
    print(__K2L_Str(seq:sortedWith(____lambda_40):map(____lambda_41):toList()))
    print(__K2L_Str(seq:associate(____lambda_42)))
    print(__K2L_Str(seq:associateBy(____lambda_43):getKeys()))
    print(__K2L_Str(seq:groupBy(____lambda_44):mapValues(function(____destructured_2)
        local v = ____destructured_2.value
        return v.size
    end)))
    print(__K2L_Str(seq:map(____lambda_45):toMap()))
    local ____list = seq:partition(____lambda_46).first
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = it.name
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    print(seq:map(____lambda_47):reduce(____lambda_48))
    print(__K2L_Str(seq:find(____lambda_49)))
    print(__K2L_Str(seq:findLast(____lambda_50)))
    print(seq:last().name)
    print(__K2L_Str(seq:lastOrNull(____lambda_51)))
    print(__K2L_Str(seq:single(____lambda_52)))
    print(__K2L_Str(seq:singleOrNull(____lambda_53)))
    print(__K2L_Str(seq:map(____lambda_54):chunked(3):toList()))
    print(__K2L_Str(__K2L_AsSequence(__K2L_IntRange.new(1, 7)):windowed(3, 2):toList()))
    print(__K2L_Str(__K2L_AsSequence(__K2L_IntRange.new(1, 7)):windowed(3, 3, true):map(____lambda_55):toList()))
    print(__K2L_Str(__K2L_SequenceOf(1, 2, 3):plus(4):plusAll(__K2L_ListOf(5, 6)):plusAll(__K2L_SequenceOf(7)):toList()))
    print(__K2L_Str(__K2L_SequenceOf(1, 2, 3, 2):minus(2):toList()))
    print(__K2L_Str(__K2L_SequenceOf(3, 1, 2):zip(__K2L_SequenceOf("c", "a"), ____lambda_56):toList()))
    print(__K2L_Str(__K2L_SequenceOf(1, 2, 3):zipWithNext():toList()))
    print(__K2L_Str(__K2L_SequenceOf(1, 2, 3, 4):runningFold(0, ____lambda_57):toList()))
    print(__K2L_Str(__K2L_SequenceOf(1, 2, 3, 4):scan(1, ____lambda_58):toList()))
    print(__K2L_Str(__K2L_SequenceOf(1, 2, 3, 4):runningReduce(____lambda_59):toList()))
    print(__K2L_Str(__K2L_SequenceOf(1, nil, 2, nil):filterNotNull():toList()))
    print(__K2L_Str(__K2L_SequenceOf("x", "y"):filterIndexed(____lambda_60):toList()))
    print(__K2L_SequenceOf(1, 2, 3):foldIndexed(0, ____lambda_61))
    __K2L_SequenceOf("p", "q"):forEachIndexed(function(i, s)
        print(i .. "=" .. s)
    end)
    print(__K2L_Str(__K2L_SequenceOf():firstOrNull()))
    print(__K2L_SequenceOf():joinToString(nil, "[", "]"))
    local ____value = __K2L_SequenceOf(1, 2):toMutableList()
    ____value:add(3)
    print(__K2L_Str(____value))
    print(__K2L_Str(__K2L_AsSequence(__K2L_ListOf(3, 4)):ifEmpty(____lambda_62):toList()))
    print(__K2L_Str(__K2L_SequenceOf():ifEmpty(____lambda_63):toList()))
end

local ____lambda_64 = function(it) return it:upper() end
local ____lambda_65 = function(it) return it.key .. "=" .. it.value end
local ____lambda_66 = function(it) return it ~= 6 end
local ____lambda_67 = function()
    return __K2L_IteratorOf(__K2L_ListOf(1, 2, 3))
end
local ____lambda_68 = function(it) return it * 2 end
local ____lambda_69 = function(it) return it + 1 end
local ____lambda_70 = function() return Countdown.new(3) end
local ____lambda_71 = function(it) return it * 10 end
local function sources()
    print("-- sources")
    print(__K2L_AsSequence("hey"):map(____lambda_64):joinToString(""))
    print(__K2L_Str(__K2L_AsSequence(__K2L_MapOf(__K2L_Pair.new(1, "one"), __K2L_Pair.new(2, "two"))):map(____lambda_65):toList()))
    print(__K2L_Str(__K2L_AsSequence(__K2L_ArrayOf(5, 6, 7)):filter(____lambda_66):toList()))
    print(__K2L_Str(__K2L_AsSequence(__K2L_SetOf("s", "t")):toList()))
    print(__K2L_Str(__K2L_AsSequence(__K2L_IntRange.new(10, 1, -1):withStep(3)):toList()))
    local custom = __K2L_SequenceFromIterator(____lambda_67)
    print(__K2L_Str(custom:map(____lambda_68):toList()))
    print(__K2L_Str(custom:toList()))
    local it = __K2L_SequenceOf(4, 5, 6):iterator()
    while it:hasNext() do
        io.write(it:next() .. " ")
    end
    print()
    local once = __K2L_AsSequence(__K2L_IteratorOf(__K2L_ListOf(7, 8)))
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
    local reusable = __K2L_AsSequence(__K2L_ListOf(1, 2)):map(____lambda_69)
    print(__K2L_Str(reusable:toList():plusAll(reusable:toList())))
    local s = reusable
    print(__K2L_InstanceOf(s, __K2L_Sequence))
    for _, ____item in __K2L_SequenceOf("a", "b"):withIndex():iter() do
        local i, v = ____item.index, ____item.value
        print(i .. " -> " .. v)
    end
    print(__K2L_Str(__K2L_ListOf(0):plusAll(__K2L_SequenceOf(1, 2))))
    local target = __K2L_ListOf(1)
    target:addAll(__K2L_SequenceOf(2, 3))
    print(__K2L_Str(target))
    print(__K2L_Str(__K2L_SequenceFromIterator(____lambda_70):map(____lambda_71):toList()))
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

function Countdown.new(n)
    return setmetatable({n = n}, Countdown)
end

function Countdown:hasNext()
    return self.n > 0
end

function Countdown:next()
    local ____old_1 = self.n
    self.n = self.n - 1
    return ____old_1
end

local ____lambda_72 = function(a, b) return a + b end
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
        __K2L_SequenceOf():reduce(____lambda_72)
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

__K2L_RunMain(main)
return {Item = Item, naturals = naturals, fibonacci = fibonacci, laziness = laziness, infinite = infinite, operations = operations, sources = sources, Countdown = Countdown, errors = errors}
