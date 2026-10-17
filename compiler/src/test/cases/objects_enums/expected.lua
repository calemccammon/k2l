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

local Registry = __K2L_Class("Registry")

function Registry:____init()
    self.nextId = 1
    self.prefix = "id-"
end

function Registry:register(name)
    local id = self.prefix .. self.nextId
    self.nextId = self.nextId + 1
    print("registered " .. name .. " as " .. id)
    return id
end

Registry:____init()
local Direction = __K2L_Class("Direction")

function Direction:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Direction:turnRight()
    if self == Direction.NORTH then
        return Direction.EAST
    elseif self == Direction.EAST then
        return Direction.SOUTH
    elseif self == Direction.SOUTH then
        return Direction.WEST
    elseif self == Direction.WEST then
        return Direction.NORTH
    end
end

function Direction:toString()
    return self.name
end

Direction.NORTH = Direction.new("NORTH", 0)
Direction.EAST = Direction.new("EAST", 1)
Direction.SOUTH = Direction.new("SOUTH", 2)
Direction.WEST = Direction.new("WEST", 3)
local Planet = __K2L_Class("Planet")

function Planet:____init(name, ordinal, mass, radius)
    self.name = name
    self.ordinal = ordinal
    self.mass = mass
    self.radius = radius
end

function Planet:getGravity()
    return 6.673E-11 * self.mass / (self.radius * self.radius)
end

function Planet:toString()
    return self.name
end

Planet.MERCURY = Planet.new("MERCURY", 0, 3.303E23, 2439700.0)
Planet.EARTH = Planet.new("EARTH", 1, 5.976E24, 6378140.0)
local Point = __K2L_Class("Point")

function Point:____init(x, y)
    self.x = x
    self.y = y
end

function Point:plus(other)
    return Point:of(self.x + other.x, self.y + other.y)
end

function Point:of(x, y)
    self.created = self.created + 1
    return Point.new(x, y)
end

function Point:____initCompanion()
    self.ORIGIN = Point.new(0, 0)
    self.created = 0
end

Point:____initCompanion()

local function main()
    Registry:register("alpha")
    Registry:register("beta")
    print(Registry.prefix)
    local d = Direction.NORTH
    for i = 1, 5 do
        io.write(d.name .. "(" .. d.ordinal .. ") ")
        d = d:turnRight()
    end
    print()
    print(__K2L_Str(Direction.WEST))
    print(d == Direction.EAST)
    local e = Planet.EARTH
    print(e.name .. " " .. tostring(e:getGravity() > 9.7 and e:getGravity() < 9.9))
    print(__K2L_Str(Planet.MERCURY.mass))
    local p = Point:of(1, 2):plus(Point:of(3, 4))
    print(p.x .. "," .. p.y .. " created=" .. Point.created)
    print(Point.ORIGIN.x)
end

main()
return {Registry = Registry, Direction = Direction, Planet = Planet, Point = Point}
