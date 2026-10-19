local ____lualib = require("lualib_bundle")
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_GenerateSequence = ____lualib.__K2L_GenerateSequence
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_SequenceOf = ____lualib.__K2L_SequenceOf
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local CountdownIterator = __K2L_Class("CountdownIterator")

function CountdownIterator:____init(current)
    self.current = current
end

function CountdownIterator:hasNext()
    return self.current > 0
end

function CountdownIterator:next()
    local ____old = self.current
    self.current = self.current - 1
    return ____old
end

local Countdown = __K2L_Class("Countdown", __K2L_Sequence)

function Countdown:____init(from)
    self.from = from
end

function Countdown:iterator()
    return CountdownIterator.new(self.from)
end

local function main()
    local s = __K2L_SequenceOf(1, 2, 3, 4)
    local it = s:asIterable()
    print(__K2L_Str(it:map(function(it) return it * 2 end)))
    for _, x in ipairs(it:toList()) do
        io.write(tostring(x))
    end
    print()
    local back = __K2L_AsSequence(__K2L_ListOf(5, 6, 7):asIterable()):map(function(it) return it + 1 end):toList()
    print(__K2L_Str(back))
    local dest = __K2L_ListOf(0)
    s:filter(function(it) return math.fmod(it, 2) == 0 end):toCollection(dest)
    print(__K2L_Str(dest))
    local set = s:toCollection(__K2L_SetOf())
    print(__K2L_Str(set))
    local itr = s:iterator()
    while itr:hasNext() do
        io.write(tostring(itr:next()))
    end
    print()
    local lazyIter = __K2L_GenerateSequence(1, function(it) return it * 2 end):asIterable()
    print(__K2L_Str(lazyIter:take(4):toList()))
    print(lazyIter:first())
    local ii = __K2L_IteratorOf(it)
    print(ii:next())
    print(it:count())
    print(it:joinToString("-"))
    print(s:asIterable():sum())
    print(__K2L_Str(s:asIterable():toList()))
    local m = __K2L_AsSequence(__K2L_MapOf(__K2L_Pair.new(1, 2))):asIterable():toList()
    print(__K2L_Str(m))
    print(__K2L_Str(__K2L_AsSequence("abc"):asIterable():toList()))
    print(__K2L_Str(it:sortedDescending()))
    print(it:contains(2))
    local bySeq = s:asIterable():toSet()
    print(__K2L_Str(bySeq))
    local once = __K2L_SequenceOf(1, 2, 3):constrainOnce():asIterable()
    print(__K2L_Str(once:toList()))
    local ____ok, ____result = pcall(function()
        print(__K2L_Str(once:toList()))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_IllegalStateException) then
            local e = ____error
            print("second pass: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    local countdown = Countdown.new(3):asIterable()
    print(__K2L_Str(countdown:map(function(it) return it * 10 end)))
    print(countdown:count(function(it) return it > 1 end))
    print(__K2L_Str(Countdown.new(2):toCollection(__K2L_ListOf(9))))
    local naturals = __K2L_GenerateSequence(1, function(it) return it + 1 end):asIterable()
    print(naturals:first(function(it) return it > 41 end))
    print(__K2L_Str(naturals:firstOrNull(function(it) return math.fmod(it, 7) == 0 end)))
    print(naturals:any(function(it) return it > 100 end))
    print(__K2L_Str(naturals:take(3)))
    print(naturals:contains(5))
    local seen = 0
    local counting = __K2L_GenerateSequence(1, function(it) return it + 1 end):onEach(function(it)
        seen = seen + 1
    end):asIterable()
    counting:first(function(it) return it == 4 end)
    print("pulled " .. seen)
    local ____ok_1, ____result_1 = pcall(function()
        __K2L_SequenceOf():asIterable():first()
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error_1, __K2L_NoSuchElementException) then
            local e = ____error_1
            print(__K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
end

main()
return {CountdownIterator = CountdownIterator, Countdown = Countdown}
