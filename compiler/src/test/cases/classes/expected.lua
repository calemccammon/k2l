-- Creates a class (or interface) table. Instances use it as their metatable; methods missing from
-- the class are looked up in the base class, then in interface default methods.
local function __K2L_Class(name, base, ...)
    local cls = {____name = name, ____super = base, ____interfaces = {}}
    cls.__index = cls
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

local Counter = __K2L_Class("Counter")

function Counter:____init(step)
    self.step = step
    self.count = 0
    print("Counter created with step " .. self.step)
end

function Counter:getDoubled()
    return self.count * 2
end

function Counter:increment()
    self.count = self.count + self.step
    return self
end

function Counter:reset()
    self.count = 0
end

local Temperature = __K2L_Class("Temperature")

function Temperature:____init(celsius)
    self.celsius = celsius
end

function Temperature:getCelsius()
    return self.celsius
end

function Temperature:setCelsius(value)
    print("setting " .. __K2L_Str(value))
    self.celsius = value < -273.15 and -273.15 or value
end

function Temperature:getFahrenheit()
    return self:getCelsius() * 9 / 5 + 32
end

local Account = __K2L_Class("Account")

function Account:____init(owner)
    self.owner = owner
    self.balance = 0
end

function Account:____init1(owner, initial)
    self:____init(owner)
    self.balance = initial
    print("secondary constructor for " .. owner)
end

function Account.new1(owner, initial)
    local self = setmetatable({}, Account)
    self:____init1(owner, initial)
    return self
end

function Account:deposit(amount)
    self.balance = self.balance + amount
end

function Account:toString()
    return "Account(" .. self.owner .. ", " .. self.balance .. ")"
end

local function main()
    local c = Counter.new(3)
    c:increment():increment()
    print(c.count)
    print(c:getDoubled())
    c:reset()
    print(c.count)
    local t = Temperature.new(20.0)
    print(__K2L_Str(t:getFahrenheit()))
    t:setCelsius(-300.0)
    print(__K2L_Str(t:getCelsius()))
    local a = Account.new1("Ada", 100)
    a:deposit(50)
    a.balance = a.balance - 30
    print(__K2L_Str(a))
    print("account: " .. __K2L_Str(a))
    local b = Account.new("Bob")
    b.balance = b.balance + 1
    print(b:toString())
    print(a == b)
    print(a == a)
end

main()
return {Counter = Counter, Temperature = Temperature, Account = Account}
