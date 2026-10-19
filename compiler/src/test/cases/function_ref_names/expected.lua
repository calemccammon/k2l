local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_FunctionRef = ____lualib.__K2L_FunctionRef
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringIsBlank = ____lualib.__K2L_StringIsBlank

local negate, sortedNames
local Greeter = __K2L_Class("Greeter")

function Greeter:____init(greeting)
    self.greeting = greeting
end

function Greeter:greet(name)
    return self.greeting .. ", " .. name
end

local function twice(x)
    return x * 2
end

local function shout(s)
    return s:upper() .. "!"
end

local function whisper(self)
    return self:lower() .. "..."
end

local function describe(f)
    return "function " .. f.name
end

local function names(...)
    local fs = __K2L_ArrayOf(...)
    return fs:map(function(it) return it.name end)
end

local function pick(flag)
    return flag and __K2L_FunctionRef.new("twice", twice) or __K2L_FunctionRef.new("negate", negate)
end

function negate(x)
    return -x
end

local function main()
    local f = __K2L_FunctionRef.new("twice", twice)
    print(f.name)
    print(f(21))
    print(f(4))
    print(__K2L_Str(__K2L_ListOf(1, 2, 3):map(f)))
    print(__K2L_Str(__K2L_ListOf(1, 2, 3):map(twice)))
    print(__K2L_Str(__K2L_ListOf(1, 2, 3):map(negate)))
    local g = __K2L_FunctionRef.new("shout", shout)
    print(g.name .. " -> " .. g("hey"))
    local w = __K2L_FunctionRef.new("whisper", whisper)
    print(w.name .. " -> " .. w("LOUD"))
    local greeter = Greeter.new("Hello")
    local bound = __K2L_FunctionRef.new("greet", function(...) return greeter:greet(...) end)
    print(bound.name .. " -> " .. bound("Kotlin"))
    local unbound = __K2L_FunctionRef.new("greet", function(self, ...) return self:greet(...) end)
    print(unbound.name .. " -> " .. unbound(greeter, "Lua"))
    local len = __K2L_FunctionRef.new("isEmpty", function(____p1) return #____p1 == 0 end)
    print(len.name .. ": " .. tostring(len("four")))
    local up = __K2L_FunctionRef.new("isBlank", function(____p1) return __K2L_StringIsBlank(____p1) end)
    print(up.name .. " -> " .. tostring(up("  ")))
    print(describe(__K2L_FunctionRef.new("twice", twice)))
    print(__K2L_Str(names(__K2L_FunctionRef.new("twice", twice), __K2L_FunctionRef.new("shout", shout), __K2L_FunctionRef.new("greet", function(self, ...) return self:greet(...) end))))
    local chosen = pick(true)
    print(chosen.name .. " " .. chosen(5))
    print(pick(false).name)
    local make = __K2L_FunctionRef.new("<init>", Greeter.new)
    print(make.name)
    print(make("Hi"):greet("there"))
    local ____table = __K2L_MapOf(__K2L_Pair.new("a", __K2L_FunctionRef.new("twice", twice)), __K2L_Pair.new("b", __K2L_FunctionRef.new("negate", negate)))
    for key, fn in ____table:iter() do
        print(key .. ": " .. fn.name .. " " .. fn(10))
    end
    print(__K2L_Str(sortedNames(__K2L_ListOf(__K2L_FunctionRef.new("shout", shout), __K2L_FunctionRef.new("twice", twice)))))
    print("twice")
end

function sortedNames(fs)
    return fs:map(function(it) return it.name end):sorted()
end

main()
return {Greeter = Greeter, twice = twice, shout = shout, whisper = whisper, describe = describe, names = names, pick = pick, negate = negate, sortedNames = sortedNames}
