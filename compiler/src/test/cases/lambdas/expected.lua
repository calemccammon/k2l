-- Creates a class (or interface) table. Instances use it as their metatable; methods missing from
-- the class are looked up in the base class, then in interface default methods.
local function __K2L_Class(name, base, ...)
    local cls = {____name = name, ____super = base, ____interfaces = {}}
    cls.__index = cls
    if base ~= nil then
        cls.__tostring = rawget(base, "__tostring")
    end
    local interfaces = {...}
    for _, iface in ipairs(interfaces) do
        cls.____interfaces[iface] = true
        for super in pairs(iface.____interfaces) do
            cls.____interfaces[super] = true
        end
    end
    if #interfaces == 0 then
        if base ~= nil then
            setmetatable(cls, base)
        end
    else
        setmetatable(cls, {__index = function(_, key)
            if base ~= nil then
                local value = base[key]
                if value ~= nil then
                    return value
                end
            end
            for _, iface in ipairs(interfaces) do
                local value = iface[key]
                if value ~= nil then
                    return value
                end
            end
        end})
    end
    function cls.new(...)
        local self = setmetatable({}, cls)
        local init = cls.____init
        if init ~= nil then
            init(self, ...)
        end
        return self
    end
    return cls
end

-- Kotlin/JVM Double.toString: shortest round-tripping digits, plain notation in [1e-3, 1e7).
local function __K2L_DoubleToString(x)
    if x ~= x then
        return "NaN"
    elseif x == math.huge then
        return "Infinity"
    elseif x == -math.huge then
        return "-Infinity"
    elseif x == 0 then
        return 1 / x < 0 and "-0.0" or "0.0"
    end
    local s
    for precision = 0, 16 do
        s = string.format("%." .. precision .. "e", x)
        if tonumber(s) == x then
            break
        end
    end
    local sign, int, frac, exp = string.match(s, "^(-?)(%d)%.?(%d*)e([-+]%d+)$")
    exp = tonumber(exp)
    local digits = (int .. frac):gsub("0+$", "")
    if digits == "" then
        digits = "0"
    end
    local ax = math.abs(x)
    if ax >= 1e-3 and ax < 1e7 then
        local point = exp + 1
        local whole, fraction
        if point <= 0 then
            whole, fraction = "0", string.rep("0", -point) .. digits
        elseif point >= #digits then
            whole, fraction = digits .. string.rep("0", point - #digits), "0"
        else
            whole, fraction = digits:sub(1, point), digits:sub(point + 1)
        end
        return sign .. whole .. "." .. fraction
    end
    local fraction = digits:sub(2)
    if fraction == "" then
        fraction = "0"
    end
    return sign .. digits:sub(1, 1) .. "." .. fraction .. "E" .. exp
end

local function __K2L_Str(value)
    if value == nil then
        return "null"
    end
    local t = type(value)
    if t == "number" then
        if math.type(value) == "integer" then
            return tostring(value)
        end
        return __K2L_DoubleToString(value)
    elseif t == "table" and value.toString then
        return value:toString()
    end
    return tostring(value)
end

local StringBox

local function applyTwice(f, x)
    return f(f(x))
end

local function makeAdder(n)
    return function(it)
        return it + n
    end
end

local function compose(f, g)
    return function(x)
        return g(f(x))
    end
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

local function main()
    print(applyTwice(function(it)
        return it * 3
    end, 2))
    local add5 = makeAdder(5)
    print(add5(10))
    print(compose(add5, square)(1))
    local count = 0
    runAll(function(it)
        count = count + #it
    end)
    print(count)
    print(firstMatch(10, function(it)
        return it * it > 20
    end))
    local g = Greeter.new("Hi")
    local greet = function(...)
        return g:greet(...)
    end
    print(greet("Ann"))
    local lengthOf = function(s)
        return #s
    end
    print(lengthOf("four"))
    local f = function(x)
        return x + 1
    end
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
