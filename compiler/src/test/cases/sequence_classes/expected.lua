local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_IteratorBuilder = ____lualib.__K2L_IteratorBuilder
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringSplit = ____lualib.__K2L_StringSplit

local CountdownIterator = __K2L_Class("CountdownIterator")

function CountdownIterator:____init(current)
    self.current = current
end

function CountdownIterator.new(current)
    return setmetatable({current = current}, CountdownIterator)
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

local Words = __K2L_Class("Words", __K2L_Sequence)

function Words:____init(text)
    self.text = text
end

function Words:iterator()
    return __K2L_IteratorOf(__K2L_StringSplit(self.text, " "))
end

local Fibonacci = __K2L_Class("Fibonacci", __K2L_Sequence)

function Fibonacci:iterator()
    return __K2L_IteratorBuilder(function(____this)
        local a = 0
        local b = 1
        while true do
            ____this:yield(a)
            local ____next = a + b
            a = b
            b = ____next
        end
    end)
end

local Base = __K2L_Class("Base", __K2L_Sequence)

function Base:iterator()
    return __K2L_IteratorOf(__K2L_ListOf(7, 8, 9))
end

local Derived = __K2L_Class("Derived", Base)

function Derived:total()
    return self:sum()
end

local ____lambda_1 = function(it) return it * 2 end
local function describe(items)
    return __K2L_Str(items:map(____lambda_1):toList())
end

local ____lambda_2 = function(it) return it * it end
local ____lambda_3 = function(it) return it % 2 == 1 end
local ____lambda_4 = function(it) return it > 2 end
local ____lambda_5 = function(it) return #it end
local ____lambda_6 = function(it) return it % 2 == 0 end
local ____lambda_7 = function(it) return it + 1 end
local ____lambda_8 = function(it) return it == 2 end
local function main()
    local c = Countdown.new(5)
    print(__K2L_Str(c:toList()))
    print(__K2L_Str(c:map(____lambda_2):filter(____lambda_3):toList()))
    print(c:sum())
    print(c:first())
    print(__K2L_Str(c:take(2):toList()))
    print(c:count(____lambda_4))
    for _, x in c:iter() do
        io.write(x .. " ")
    end
    print()
    print(describe(c))
    print(__K2L_Str(Words.new("the quick brown fox"):map(____lambda_5):toList()))
    print(Words.new("a b c"):joinToString("-"))
    print(__K2L_Str(Fibonacci.new():take(10):toList()))
    print(__K2L_Str(Fibonacci.new():filter(____lambda_6):take(4):toList()))
    print(Derived.new():total())
    print(__K2L_Str(Derived.new():map(____lambda_7):toList()))
    local seq = Countdown.new(3)
    print(__K2L_Str(seq:zip(Countdown.new(2)):toList()))
    print(__K2L_Str(seq:plusAll(Countdown.new(2)):toList()))
    print(__K2L_Str(Countdown.new(4):windowed(2):toList()))
    print(Countdown.new(3):iterator():next())
    print(__K2L_Str(Countdown.new(3):toList()))
    print(Countdown.new(3):any(____lambda_8))
    local it = Countdown.new(2):iterator()
    while it:hasNext() do
        print(it:next())
    end
end

__K2L_RunMain(main)
return {CountdownIterator = CountdownIterator, Countdown = Countdown, Words = Words, Fibonacci = Fibonacci, Base = Base, Derived = Derived, describe = describe}
