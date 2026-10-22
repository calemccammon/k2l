local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str

local Person = __K2L_Class("Person")

function Person:____init(name, age, email)
    self.name = name
    self.age = age
    self.email = email
end

function Person.new(name, age, email)
    return setmetatable({name = name, age = age, email = email}, Person)
end

function Person:toString()
    return "Person(name=" .. self.name .. ", age=" .. self.age .. ", email=" .. __K2L_Str(self.email) .. ")"
end

function Person:hashCode()
    return (31 * (31 * __K2L_Hash(self.name) + self.age) + __K2L_Hash(self.email) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Person:equals(other)
    return getmetatable(other) == Person and self.name == other.name and self.age == other.age and self.email == other.email
end

local Pair2 = __K2L_Class("Pair2")

function Pair2:____init(first, second)
    self.first = first
    self.second = second
end

function Pair2.new(first, second)
    return setmetatable({first = first, second = second}, Pair2)
end

function Pair2:toString()
    return "Pair2(first=" .. self.first .. ", second=" .. self.second .. ")"
end

function Pair2:hashCode()
    return (31 * self.first + __K2L_Hash(self.second) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Pair2:equals(other)
    return getmetatable(other) == Pair2 and self.first == other.first and self.second == other.second
end

local Wrapper = __K2L_Class("Wrapper")

function Wrapper:____init(inner)
    self.inner = inner
end

function Wrapper.new(inner)
    return setmetatable({inner = inner}, Wrapper)
end

function Wrapper:toString()
    return "Wrapper(inner=" .. __K2L_Str(self.inner) .. ")"
end

function Wrapper:hashCode()
    return self.inner:hashCode()
end

function Wrapper:equals(other)
    return getmetatable(other) == Wrapper and self.inner:equals(other.inner)
end

local function main()
    local p = Person.new("Ada", 36, nil)
    print(__K2L_Str(p))
    local q = Person.new(p.name, 37, p.email)
    print(__K2L_Str(q))
    print(p:equals(q))
    print(p:equals(Person.new(p.name, p.age, p.email)))
    print(not p:equals(q))
    print(__K2L_Str(Person.new("Ada L.", q.age, "ada@example.com")))
    print(p.name .. " " .. p.age)
    print(__K2L_Str(Pair2.new(1, 2.5)))
    local w1 = Wrapper.new(p)
    local w2 = Wrapper.new(Person.new("Ada", 36, nil))
    print(w1:equals(w2))
    print(__K2L_Str(w1))
    local maybe = nil
    print(__K2L_Equals(maybe, p))
    print(p:equals(q))
end

__K2L_RunMain(main)
return {Person = Person, Pair2 = Pair2, Wrapper = Wrapper}
