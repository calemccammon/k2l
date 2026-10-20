local ____lualib = require("lualib_bundle")
local __K2L_AbstractCoroutineContextElement = ____lualib.__K2L_AbstractCoroutineContextElement
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ContextGet = ____lualib.__K2L_ContextGet
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_Str = ____lualib.__K2L_Str

local EvenIterator
local Base = __K2L_Class("Base")

function Base:____init(tag)
    self.tag = tag
end

function Base.new(tag)
    return setmetatable({tag = tag}, Base)
end

function Base:describe()
    return "Base(" .. self.tag .. ")"
end

local Evens = __K2L_Class("Evens", Base, __K2L_Sequence)

function Evens:____init(limit)
    Base.____init(self, "evens")
    self.limit = limit
end

function Evens:iterator()
    return EvenIterator.new(self.limit)
end

EvenIterator = __K2L_Class("EvenIterator")

function EvenIterator:____init(limit)
    self.limit = limit
    self.at = 0
end

function EvenIterator:hasNext()
    return self.at < self.limit
end

function EvenIterator:next()
    local v = self.at
    self.at = self.at + 2
    return v
end

local Oops = __K2L_Class("Oops", __K2L_RuntimeException, __K2L_Sequence)

function Oops:____init(n)
    __K2L_RuntimeException.____init(self, "oops")
    self.n = n
end

function Oops:iterator()
    return __K2L_IteratorOf(__K2L_IntRange.new(1, self.n))
end

local Named = __K2L_Class("Named", __K2L_AbstractCoroutineContextElement)

function Named:____init(label)
    __K2L_AbstractCoroutineContextElement.____init(self, Named)
    self.label = label
end

local Sub = __K2L_Class("Sub", Named, __K2L_Sequence)

function Sub:____init(label)
    Named.____init(self, label)
end

function Sub:iterator()
    return __K2L_IteratorOf(__K2L_ReadOnlyListOf(self.label, self.label))
end

local Shape = __K2L_Class("Shape")
local Sq = __K2L_Class("Sq", Base, Shape, __K2L_Sequence)

function Sq:____init(s)
    Base.____init(self, "sq")
    self.s = s
end

function Sq:area()
    return self.s * self.s
end

function Sq:iterator()
    return __K2L_IteratorOf(__K2L_IntRange.new(1, self.s))
end

local Both = __K2L_Class("Both", __K2L_AbstractCoroutineContextElement, __K2L_Sequence)

function Both:____init(n)
    __K2L_AbstractCoroutineContextElement.____init(self, Both)
    self.n = n
end

function Both:iterator()
    return __K2L_IteratorOf(__K2L_IntRange.new(1, self.n))
end

local ____lambda_1 = function(it) return it + 1 end
local ____lambda_2 = function(it) return it > 3 end
local ____lambda_3 = function(it) return it * 2 end
local function main()
    local both = Both.new(3)
    print(__K2L_Str(both:toList()))
    local ____receiver = __K2L_ContextGet(both, Both)
    print(__K2L_Str(____receiver and ____receiver.n))
    print(both.key == Both)
    local e = Evens.new(10)
    print(e:describe())
    print(__K2L_Str(e:toList()))
    print(__K2L_Str(e:map(____lambda_1):filter(____lambda_2):toList()))
    print(e:sum())
    for _, x in e:iter() do
        io.write(tostring(x))
    end
    print()
    local o = Oops.new(3)
    print(__K2L_Str(o.message))
    print(__K2L_Str(o:toList()))
    local s = Sub.new("hi")
    print(__K2L_Str(s:toList()))
    print(s.key == Named)
    print(s.label)
    local q = Sq.new(3)
    print(q:area())
    print(__K2L_Str(q:toList()))
    print(q:describe())
    print(__K2L_Str(q:map(____lambda_3):toList()))
end

main()
return {Base = Base, Evens = Evens, EvenIterator = EvenIterator, Oops = Oops, Named = Named, Sub = Sub, Shape = Shape, Sq = Sq, Both = Both}
