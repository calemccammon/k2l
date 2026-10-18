local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_GenerateSequence = ____lualib.__K2L_GenerateSequence
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_Iterator = ____lualib.__K2L_Iterator
local __K2L_IteratorBuilder = ____lualib.__K2L_IteratorBuilder
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_SequenceBuilder = ____lualib.__K2L_SequenceBuilder
local __K2L_SequenceOf = ____lualib.__K2L_SequenceOf
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function fibonacci()
    return __K2L_SequenceBuilder(function(self)
        local a = 0
        local b = 1
        while true do
            self:yield(a)
            local ____next = a + b
            a = b
            b = ____next
        end
    end)
end

local function primes()
    return __K2L_SequenceBuilder(function(____this)
        local found = __K2L_ListOf()
        local n = 2
        while true do
            if found:none(function(it) return math.fmod(n, it) == 0 end) then
                found:add(n)
                ____this:yield(n)
            end
            n = n + 1
        end
    end)
end

local function emitPair(____this_1, a, b)
    ____this_1:yield(a)
    ____this_1:yield(b)
end

local function classify(xs)
    return __K2L_SequenceBuilder(function(____this_2)
        for _, x in ipairs(xs) do
            do
                if x < 0 then
                    ____this_2:yield("negative " .. x)
                elseif x == 0 then
                    goto ____continue
                elseif math.fmod(x, 2) == 0 then
                    emitPair(____this_2, "even", tostring(x))
                else
                    ____this_2:yield("odd " .. x)
                end
            end
            ::____continue::
        end
        ____this_2:yield("done")
    end)
end

local Tree = __K2L_Class("Tree")

function Tree:____init(value, left, right)
    if left == nil then
        left = nil
    end
    if right == nil then
        right = nil
    end
    self.value = value
    self.left = left
    self.right = right
end

function Tree:inOrder()
    return __K2L_SequenceBuilder(function(____this_3)
        local ____receiver = self.left
        if ____receiver ~= nil then
            ____this_3:yieldAll(____receiver:inOrder())
        end
        ____this_3:yield(self.value)
        if self.right ~= nil then
            ____this_3:yieldAll(self.right:inOrder())
        end
    end)
end

local function countdown(from)
    return __K2L_IteratorBuilder(function(____this_4)
        local i = from
        while i > 0 do
            print("  producing " .. i)
            local ____old = i
            i = i - 1
            ____this_4:yield(____old)
        end
    end)
end

local function failing()
    return __K2L_SequenceBuilder(function(____this_5)
        ____this_5:yield(1)
        ____this_5:yield(2)
        error(__K2L_IllegalStateException.new("generator broke"))
    end)
end

local function guarded()
    return __K2L_SequenceBuilder(function(____this_6)
        local ____ok, ____result = pcall(function()
            ____this_6:yield("inside try")
            error(__K2L_IllegalArgumentException.new("oops"))
        end)
        if not ____ok then
            ____ok, ____result = pcall(function()
                local ____error = __K2L_ToThrowable(____result)
                if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
                    local e = ____error
                    ____this_6:yield("caught " .. __K2L_Str(e.message))
                else
                    error(____error, 0)
                end
            end)
        end
        print("  finally runs")
        if not ____ok then
            error(____result, 0)
        end
        local label
        local ____ok_1, ____result_1 = pcall(function()
            ____this_6:yield("before")
            label = "value"
        end)
        if not ____ok_1 then
            local ____error_1 = __K2L_ToThrowable(____result_1)
            if __K2L_InstanceOf(____error_1, __K2L_Exception) then
                local e = ____error_1
                label = "never"
            else
                error(____error_1, 0)
            end
        end
        ____this_6:yield(label)
    end)
end

local Repeater = __K2L_Class("Repeater")

function Repeater:____init(word, times)
    self.word = word
    self.times = times
end

function Repeater:words()
    return __K2L_SequenceBuilder(function(____this_7)
        for i = 0, self.times - 1 do
            ____this_7:yield(self.word .. "#" .. i)
        end
    end)
end

local function main()
    print(__K2L_Str(fibonacci():take(10):toList()))
    print(primes():take(8):joinToString())
    print(__K2L_Str(classify(__K2L_ListOf(3, 0, -2, 4)):toList()))
    local tree = Tree.new(4, Tree.new(2, Tree.new(1), Tree.new(3)), Tree.new(6, Tree.new(5)))
    print(__K2L_Str(tree:inOrder():toList()))
    print(__K2L_Str(tree:inOrder():filter(function(it) return math.fmod(it, 2) == 1 end):map(function(it) return it * 10 end):toList()))
    print("-- interleaving")
    local logged = __K2L_SequenceBuilder(function(____this_8)
        for i = 1, 3 do
            print("  yield " .. i)
            ____this_8:yield(i)
        end
        print("  end")
    end)
    for _, x in logged:map(function(it) return it * 2 end):iter() do
        print("consumed " .. x)
    end
    print(logged:first())
    print("-- yieldAll")
    local all = __K2L_SequenceBuilder(function(____this_9)
        ____this_9:yieldAll(__K2L_ListOf(1, 2))
        ____this_9:yieldAll(__K2L_SetOf(3))
        ____this_9:yieldAll(__K2L_SequenceOf(4, 5))
        ____this_9:yieldAll(__K2L_GenerateSequence(6, function(it) return it < 8 and it + 1 or nil end))
        ____this_9:yieldAll(__K2L_IteratorOf(__K2L_ListOf(9, 10)))
        ____this_9:yieldAll(__K2L_ListOf())
    end)
    print(__K2L_Str(all:toList()))
    print(all:count())
    local nested = __K2L_SequenceBuilder(function(____this_10)
        ____this_10:yield(0)
        ____this_10:yieldAll(__K2L_SequenceBuilder(function(____this_11)
            for c in ("ab"):gmatch(".") do
                ____this_11:yield(c)
            end
        end):map(function(it) return #it end))
        ____this_10:yield(-1)
    end)
    print(__K2L_Str(nested:toList()))
    print("-- iterator")
    local it = countdown(3)
    while it:hasNext() do
        print("got " .. it:next())
    end
    local ____ok_2, ____result_2 = pcall(function()
        it:next()
    end)
    if not ____ok_2 then
        local ____error_2 = __K2L_ToThrowable(____result_2)
        if __K2L_InstanceOf(____error_2, __K2L_NoSuchElementException) then
            local e = ____error_2
            print("exhausted")
        else
            error(____error_2, 0)
        end
    end
    for _, n in __K2L_Iterator.iter(countdown(2)) do
        print("loop " .. n)
    end
    print("-- exceptions")
    local ____ok_3, ____result_3 = pcall(function()
        for _, x in failing():iter() do
            print("value " .. x)
        end
    end)
    if not ____ok_3 then
        local ____error_3 = __K2L_ToThrowable(____result_3)
        if __K2L_InstanceOf(____error_3, __K2L_IllegalStateException) then
            local e = ____error_3
            print("caught: " .. __K2L_Str(e.message))
        else
            error(____error_3, 0)
        end
    end
    print(__K2L_Str(failing():take(2):toList()))
    print(__K2L_Str(guarded():toList()))
    print(guarded():first())
    print("-- members and helpers")
    print(__K2L_Str(Repeater.new("hi", 3):words():toList()))
    local withNulls = __K2L_SequenceBuilder(function(____this_12)
        ____this_12:yield(nil)
        ____this_12:yield("x")
        ____this_12:yield(nil)
    end)
    print(__K2L_Str(withNulls:toList()))
    print(__K2L_Str(withNulls:filterNotNull():toList()))
    local evaluated = 0
    local lazyInfinite = __K2L_SequenceBuilder(function(____this_13)
        local n = 0
        while true do
            evaluated = evaluated + 1
            local ____old_1 = n
            n = n + 1
            ____this_13:yield(____old_1)
        end
    end)
    print(__K2L_Str(lazyInfinite:drop(2):take(3):toList()))
    print("evaluated " .. evaluated)
    local early = __K2L_SequenceBuilder(function(____this_14)
        ____this_14:yield(1)
        if evaluated > 0 then
            return
        end
        ____this_14:yield(2)
    end)
    print(__K2L_Str(early:toList()))
end

main()
return {fibonacci = fibonacci, primes = primes, emitPair = emitPair, classify = classify, Tree = Tree, countdown = countdown, failing = failing, guarded = guarded, Repeater = Repeater}
