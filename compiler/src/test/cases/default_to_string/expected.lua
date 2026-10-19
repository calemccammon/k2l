local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder

local P = __K2L_Class("app.P")

function P:____init(x)
    self.x = x
end

local Hashed = __K2L_Class("app.Hashed")

function Hashed:____init(id)
    self.id = id
end

function Hashed:hashCode()
    return self.id * 31
end

local Base = __K2L_Class("app.Base")
local Derived = __K2L_Class("app.Derived", Base)
local Outer = __K2L_Class("app.Outer")
Outer.Nested = __K2L_Class("app.Outer$Nested")
Outer.Inner = __K2L_Class("app.Outer$Inner")

function Outer.Inner:____init(____outer)
    self.____outer = ____outer
end

local Singleton = __K2L_Class("app.Singleton")
local D = __K2L_Class("app.D")

function D:____init(v)
    self.v = v
end

function D:toString()
    return "D(v=" .. self.v .. ")"
end

function D:hashCode()
    return __K2L_Hash(self.v)
end

function D:equals(other)
    return getmetatable(other) == D and self.v == other.v
end

local E = __K2L_Class("app.E")

function E:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function E:toString()
    return self.name
end

function E:compareTo(other)
    return self.ordinal - other.ordinal
end

E.A = E.new("A", 0)
E.B = E.new("B", 1)
E.____values = {E.A, E.B}
local Problem = __K2L_Class("app.Problem", __K2L_Exception)

function Problem:____init(msg)
    __K2L_Exception.____init(self, msg)
end

local Shape = __K2L_Class("app.Shape")
local Square = __K2L_Class("app.Square", nil, Shape)
local hash = __K2L_Regex.new("@[0-9a-f]+")

local function shape(s)
    return hash:replace(s, "@<hex>")
end

local function main()
    local p = P.new(1)
    print(shape(__K2L_Str(p)))
    print(shape(__K2L_Str(p)))
    print(shape(__K2L_Str(__K2L_ReadOnlyListOf(p, Derived.new()))))
    print(shape(__K2L_Str(__K2L_SingletonMapOf(__K2L_Pair.new("k", Outer.Nested.new())))))
    print(shape(__K2L_Str(Outer.Inner.new(Outer.new()))))
    print(shape(__K2L_Str(Singleton)))
    print(shape(__K2L_Str(Square.new())))
    local any = p
    print(shape(__K2L_Str(any)))
    print(__K2L_Str(p) == __K2L_Str(p))
    print(__K2L_Str(p) == "app.P@" .. __K2L_Str(__K2L_Num.toRadixUnsigned(__K2L_Hash(p), 16)))
    print(__K2L_Hash(p) == __K2L_Hash(p))
    print(__K2L_Str(P.new(1)) ~= __K2L_Str(p))
    print(__K2L_Str(Hashed.new(2)) .. " " .. __K2L_Str(Hashed.new(3)))
    print(__K2L_Str(D.new(1)) .. " " .. __K2L_Str(E.B) .. " " .. __K2L_Str(Problem.new("boom")))
    print(shape(__K2L_StringBuilder.new():append(__K2L_Str(p)):toString()))
end

main()
return {P = P, Hashed = Hashed, Base = Base, Derived = Derived, Outer = Outer, Singleton = Singleton, D = D, E = E, Problem = Problem, Shape = Shape, Square = Square, hash = hash, shape = shape}
