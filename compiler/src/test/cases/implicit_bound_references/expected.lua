local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str

local Filter = __K2L_Class("Filter")

function Filter:____init(limit)
    self.limit = limit
    self.count = 3
end

function Filter:small(x)
    return x < self.limit
end

function Filter:label(x)
    return "n" .. x
end

function Filter:apply(xs)
    return xs:filter(function(...) return self:small(...) end):map(function(...) return self:label(...) end)
end

function Filter:deferred()
    return function()
        return __K2L_ReadOnlyListOf(1, 5, 9):filter(function(...) return self:small(...) end)
    end
end

function Filter:countRef()
    return __K2L_PropertyRef.new("count", "/Filter.count", function() return self.count end, nil, self)
end

Filter.Report = __K2L_Class("Filter$Report")

function Filter.Report:____init(____outer)
    self.____outer = ____outer
end

function Filter.Report:lines(xs)
    return xs:map(function(...) return self.____outer:label(...) end)
end

local Loud = __K2L_Class("Loud", Filter)

function Loud:____init(limit)
    Filter.____init(self, limit)
end

function Loud:label(x)
    return "N" .. x .. "!"
end

function Loud:shout(xs)
    return xs:map(function(...) return self:label(...) end)
end

local Registry = __K2L_Class("Registry")

function Registry:____init()
    self.names = __K2L_ListOf()
end

function Registry:register(name)
    self.names:add(name)
end

function Registry:registerAll(xs)
    local ____mod = xs.____modCount
    for ____i = 1, xs.size do
        local it = xs[____i];
        (function(...) return self:register(...) end)(it)
        if xs.____modCount ~= ____mod and xs:____comodified(____i) then
            break
        end
    end
    return self.names
end

Registry:____init()

local function fib(n)
    local out = __K2L_ListOf()
    local ____destructured = __K2L_Pair.new(0, 1)
    local a, b = ____destructured.first, ____destructured.second
    for it = 0, n - 1 do
        do
            out:add(a)
            local ____next = a + b
            a = b
            b = ____next
        end
    end
    local ____destructured_1 = __K2L_Pair.new("p", 1)
    local x = ____destructured_1.first
    x = x .. "q"
    return out:plus(#x)
end

local function main()
    local f = Filter.new(6)
    print(__K2L_Str(f:apply(__K2L_ReadOnlyListOf(3, 8, 5))))
    print(__K2L_Str(f:deferred()()))
    print(f:countRef():get())
    print(__K2L_Str(Filter.Report.new(f):lines(__K2L_ReadOnlyListOf(1, 2))))
    print(__K2L_Str(Loud.new(2):shout(__K2L_SingletonListOf(1))))
    print(__K2L_Str(Loud.new(4):apply(__K2L_ReadOnlyListOf(1, 7))))
    print(__K2L_Str(Registry:registerAll(__K2L_ReadOnlyListOf("a", "b"))))
    print(__K2L_Str(fib(8)))
end

main()
return {Filter = Filter, Loud = Loud, Registry = Registry, fib = fib}
