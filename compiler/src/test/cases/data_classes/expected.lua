local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str

local Person = __K2L_Class("Person")

function Person.new(name, age, email)
    return setmetatable({name = name, age = age, email = email}, Person)
end

__K2L_DataClass(Person, {"name", "age", "email"})
local Pair2 = __K2L_Class("Pair2")

function Pair2.new(first, second)
    return setmetatable({first = first, second = second}, Pair2)
end

__K2L_DataClass(Pair2, {"first", "second"})
local Wrapper = __K2L_Class("Wrapper")

function Wrapper.new(inner)
    return setmetatable({inner = inner}, Wrapper)
end

__K2L_DataClass(Wrapper, {"inner"})

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
