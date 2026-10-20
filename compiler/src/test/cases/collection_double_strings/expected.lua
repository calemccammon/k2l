local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str

local P = __K2L_Class("P")

function P:____init(n, xs)
    self.n = n
    self.xs = xs
end

function P.new(n, xs)
    return setmetatable({n = n, xs = xs}, P)
end

function P:toString()
    return "P(n=" .. self.n .. ", xs=" .. __K2L_Str(self.xs) .. ")"
end

function P:hashCode()
    return (31 * self.n + __K2L_Hash(self.xs) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function P:equals(other)
    return getmetatable(other) == P and self.n == other.n and __K2L_Equals(self.xs, other.xs)
end

local function main()
    local a = __K2L_ReadOnlyListOf(1.5, 3.0)
    print(__K2L_Str(a))
    print("a=" .. __K2L_Str(a))
    local m = __K2L_ReadOnlyMapOf(__K2L_Pair.new("x", 2.0), __K2L_Pair.new("y", -0.0))
    print(__K2L_Str(m))
    print(__K2L_Str(__K2L_ReadOnlyListOf(__K2L_SingletonListOf(1.0), __K2L_ReadOnlyListOf())))
    print(__K2L_Str(P.new(3, __K2L_SingletonListOf(4.0))))
    print(__K2L_Str(__K2L_Pair.new("w", 7.0)))
    local n = __K2L_SingletonListOf(5.0)
    print(__K2L_Str(n))
    print(__K2L_Str(__K2L_ReadOnlySetOf(1.0, 2.0)))
    print(__K2L_Str(__K2L_ReadOnlyListOf(1, 2)))
end

main()
return {P = P}
