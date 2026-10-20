local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_FunctionRef = ____lualib.__K2L_FunctionRef
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringIsBlank = ____lualib.__K2L_StringIsBlank

local negate, sortedNames
local Greeter = __K2L_Class("Greeter")

function Greeter:____init(greeting)
    self.greeting = greeting
end

function Greeter.new(greeting)
    return setmetatable({greeting = greeting}, Greeter)
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
    local ____out = {}
    local ____count = 0
    local ____items, ____n = fs:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = it.name
    end
    return __K2L_ListWrap(____out, ____count)
end

local function pick(flag)
    return flag and __K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice) or __K2L_FunctionRef.new("negate", "/negate(kotlin.Int)", negate)
end

function negate(x)
    return -x
end

local ____lambda_1 = function(self, ...) return self:greet(...) end
local ____lambda_2 = function(____p1) return #____p1 == 0 end
local ____lambda_3 = function(____p1) return __K2L_StringIsBlank(____p1) end
local ____lambda_4 = function(self, ...) return self:greet(...) end
local function main()
    local f = __K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice)
    print(f.name)
    print(f(21))
    print(f(4))
    print(__K2L_Str(__K2L_ReadOnlyListOf(1, 2, 3):map(f)))
    print(__K2L_Str(__K2L_ReadOnlyListOf(1, 2, 3):map(twice)))
    print(__K2L_Str(__K2L_ReadOnlyListOf(1, 2, 3):map(negate)))
    local g = __K2L_FunctionRef.new("shout", "/shout(kotlin.String)", shout)
    print(g.name .. " -> " .. g("hey"))
    local w = __K2L_FunctionRef.new("whisper", "kotlin.String./whisper()", whisper)
    print(w.name .. " -> " .. w("LOUD"))
    local greeter = Greeter.new("Hello")
    local bound = __K2L_FunctionRef.new("greet", "/Greeter.greet(kotlin.String)", function(...) return greeter:greet(...) end, greeter)
    print(bound.name .. " -> " .. bound("Kotlin"))
    local unbound = __K2L_FunctionRef.new("greet", "/Greeter.greet(kotlin.String)", ____lambda_1)
    print(unbound.name .. " -> " .. unbound(greeter, "Lua"))
    local len = __K2L_FunctionRef.new("isEmpty", "kotlin.CharSequence.kotlin/text/isEmpty()", ____lambda_2)
    print(len.name .. ": " .. tostring(len("four")))
    local up = __K2L_FunctionRef.new("isBlank", "kotlin.CharSequence.kotlin/text/isBlank()", ____lambda_3)
    print(up.name .. " -> " .. tostring(up("  ")))
    print(describe(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice)))
    print(__K2L_Str(names(__K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice), __K2L_FunctionRef.new("shout", "/shout(kotlin.String)", shout), __K2L_FunctionRef.new("greet", "/Greeter.greet(kotlin.String)", ____lambda_4))))
    local chosen = pick(true)
    print(chosen.name .. " " .. chosen(5))
    print(pick(false).name)
    local make = __K2L_FunctionRef.new("<init>", "/Greeter.<init>(kotlin.String)", Greeter.new)
    print(make.name)
    print(make("Hi"):greet("there"))
    local ____table = __K2L_ReadOnlyMapOf(__K2L_Pair.new("a", __K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice)), __K2L_Pair.new("b", __K2L_FunctionRef.new("negate", "/negate(kotlin.Int)", negate)))
    local ____keys, ____values, ____n_1 = ____table:____arrays()
    local ____mod = ____table.____modCount
    for ____i_1 = 1, ____n_1 do
        local key, fn = ____keys[____i_1], ____values[____i_1]
        print(key .. ": " .. fn.name .. " " .. fn(10))
        if ____table.____modCount ~= ____mod and ____table:____comodified(____i_1, ____n_1) then
            break
        end
    end
    print(__K2L_Str(sortedNames(__K2L_ReadOnlyListOf(__K2L_FunctionRef.new("shout", "/shout(kotlin.String)", shout), __K2L_FunctionRef.new("twice", "/twice(kotlin.Int)", twice)))))
    print("twice")
end

function sortedNames(fs)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_2 = fs:____array()
    for ____i_2 = 1, ____n_2 do
        local it = ____items_1[____i_2]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = it.name
    end
    return __K2L_ListWrap(____out_1, ____count_1):sorted()
end

main()
return {Greeter = Greeter, twice = twice, shout = shout, whisper = whisper, describe = describe, names = names, pick = pick, negate = negate, sortedNames = sortedNames}
