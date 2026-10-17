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

local function greet(name, punctuation)
    if name == nil then
        name = "world"
    end
    if punctuation == nil then
        punctuation = "!"
    end
    return "Hello, " .. name .. punctuation
end

local function range(from, to, step)
    if from == nil then
        from = 0
    end
    if step == nil then
        step = 1
    end
    local s = ""
    local i = from
    while i < to do
        s = s .. i .. " "
        i = i + step
    end
    return s
end

local function withDerived(a, b)
    if b == nil then
        b = a * 2
    end
    return a + b
end

local Config = __K2L_Class("Config")

function Config:____init(name, retries, verbose)
    if retries == nil then
        retries = 3
    end
    if verbose == nil then
        verbose = false
    end
    self.name = name
    self.retries = retries
    self.verbose = verbose
end

function Config:toString()
    return "Config(" .. self.name .. ", " .. self.retries .. ", " .. tostring(self.verbose) .. ")"
end

local function main()
    print(greet())
    print(greet("Kotlin"))
    print(greet(nil, "?"))
    print(greet("Lua", "."))
    print(range(nil, 5))
    print(range(2, 10, 3))
    print(range(nil, 6, 2))
    print(withDerived(5))
    print(withDerived(5, 1))
    print(__K2L_Str(Config.new("a")))
    print(__K2L_Str(Config.new("b", nil, true)))
    print(__K2L_Str(Config.new("c", 5)))
end

main()
return {greet = greet, range = range, withDerived = withDerived, Config = Config}
