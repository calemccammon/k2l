local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Str = ____lualib.__K2L_Str

local StringBox

local function applyTwice(f, x)
    return f(f(x))
end

local function makeAdder(n)
    return function(it) return it + n end
end

local function compose(f, g)
    return function(x) return g(f(x)) end
end

local function runAll(actions)
    actions("one")
    actions("two")
end

local function firstMatch(limit, predicate)
    for i = 0, limit - 1 do
        if predicate(i) then
            return i
        end
    end
    return -1
end

local function square(x)
    return x * x
end

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

local function buildText(block)
    local box = StringBox.new()
    block(box)
    return box.text
end

StringBox = __K2L_Class("StringBox")

function StringBox:____init()
    self.text = ""
end

function StringBox:add(s)
    self.text = self.text .. s
end

local ____lambda_1 = function(it) return it * 3 end
local ____lambda_2 = function(it) return it * it > 20 end
local ____lambda_3 = function(s) return #s end
local ____lambda_4 = function(x) return x + 1 end
local function main()
    print(applyTwice(____lambda_1, 2))
    local add5 = makeAdder(5)
    print(add5(10))
    print(compose(add5, square)(1))
    local count = 0
    runAll(function(it)
        count = count + #it
    end)
    print(count)
    print(firstMatch(10, ____lambda_2))
    local g = Greeter.new("Hi")
    local greet = function(...) return g:greet(...) end
    print(greet("Ann"))
    local lengthOf = ____lambda_3
    print(lengthOf("four"))
    local f = ____lambda_4
    print(f(1))
    print(buildText(function(self)
        self:add("a")
        self:add("b")
    end))
    local x = 4
    print(x + 1)
    local ____result
    do
        local doubled = x * 2
        ____result = doubled + 1
    end
    local y = ____result
    print(y)
    local ____value = StringBox.new()
    ____value:add("hello")
    ____value:add(" world")
    local sb = ____value
    print(sb.text)
    local ____value_1 = StringBox.new()
    ____value_1:add("also")
    local also = ____value_1
    print(also.text)
    print(#sb.text)
    print(sb.text:upper())
    print(__K2L_Str(x > 3 and x or nil))
    print(__K2L_Str(x > 10 and x or nil))
    for i = 0, 2 do
        io.write("r" .. i .. " ")
    end
    print()
    local n = nil
    print(__K2L_Str(n and n * 2 or "none"))
    local ____result_1
    do
        if x > 2 then
            ____result_1 = "big"
            goto ____inline_end
        end
        ____result_1 = "small"
        ::____inline_end::
    end
    local result = ____result_1
    print(result)
end

main()
return {applyTwice = applyTwice, makeAdder = makeAdder, compose = compose, runAll = runAll, firstMatch = firstMatch, square = square, Greeter = Greeter, buildText = buildText, StringBox = StringBox}
