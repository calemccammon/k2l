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

-- Kotlin `==` for values whose class may override equals().
local function __K2L_Equals(a, b)
    if rawequal(a, b) then
        return true
    elseif type(a) == "table" and a.equals ~= nil then
        return a:equals(b)
    end
    return a == b
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

local Person = __K2L_Class("Person")

function Person:____init(name, age, email)
    self.name = name
    self.age = age
    self.email = email
end

function Person:toString()
    return "Person(name=" .. self.name .. ", age=" .. self.age .. ", email=" .. __K2L_Str(self.email) .. ")"
end

function Person:equals(other)
    return getmetatable(other) == Person and self.name == other.name and self.age == other.age and self.email == other.email
end

local Pair2 = __K2L_Class("Pair2")

function Pair2:____init(first, second)
    self.first = first
    self.second = second
end

function Pair2:toString()
    return "Pair2(first=" .. self.first .. ", second=" .. __K2L_Str(self.second) .. ")"
end

function Pair2:equals(other)
    return getmetatable(other) == Pair2 and self.first == other.first and self.second == other.second
end

local Wrapper = __K2L_Class("Wrapper")

function Wrapper:____init(inner)
    self.inner = inner
end

function Wrapper:toString()
    return "Wrapper(inner=" .. __K2L_Str(self.inner) .. ")"
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

main()
return {Person = Person, Pair2 = Pair2, Wrapper = Wrapper}
