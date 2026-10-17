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

-- Kotlin `is` for classes, objects and interfaces.
local function __K2L_InstanceOf(value, cls)
    if type(value) ~= "table" then
        return false
    end
    local c = rawget(value, "____name") ~= nil and value or getmetatable(value)
    while c ~= nil do
        if c == cls or rawget(c, "____interfaces")[cls] then
            return true
        end
        c = rawget(c, "____super")
    end
    return false
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

local arrayOfShapes
local Shape = __K2L_Class("Shape")

function Shape:describe()
    return self.name .. " with area " .. __K2L_Str(self:area())
end

local Named = __K2L_Class("Named")

function Named:label()
    return "named"
end

local Polygon = __K2L_Class("Polygon", nil, Shape, Named)

function Polygon:____init(name, sides)
    self.name = name
    self.sides = sides
end

function Polygon:perimeterHint()
    return self.sides .. " sides"
end

function Polygon:label()
    return "polygon " .. Named.label(self)
end

local Rect = __K2L_Class("Rect", Polygon)

function Rect:____init(w, h)
    Polygon.____init(self, "rect", 4)
    self.w = w
    self.h = h
end

function Rect:area()
    return self.w * self.h
end

function Rect:perimeterHint()
    return "rectangle with " .. Polygon.perimeterHint(self)
end

local Square = __K2L_Class("Square", Rect)

function Square:____init(side)
    Rect.____init(self, side, side)
end

function Square:describe()
    return "square! " .. Shape.describe(self)
end

local Circle = __K2L_Class("Circle", nil, Shape)

function Circle:____init(r)
    self.r = r
    self.name = "circle"
end

function Circle:area()
    return 3.0 * self.r * self.r
end

local Animal = __K2L_Class("Animal")

function Animal:____init(sound)
    self.sound = sound
end

function Animal:speak()
    return "The animal says " .. self.sound
end

local Dog = __K2L_Class("Dog", Animal)

function Dog:____init1()
    Animal.____init(self, "woof")
end

function Dog.new1()
    local self = setmetatable({}, Dog)
    self:____init1()
    return self
end

function Dog:speak()
    return Animal.speak(self) .. "!"
end

local function kind(s)
    if __K2L_InstanceOf(s, Square) then
        return "square"
    elseif __K2L_InstanceOf(s, Rect) then
        return "rect " .. __K2L_Str(s.w) .. "x" .. __K2L_Str(s.h)
    elseif __K2L_InstanceOf(s, Circle) then
        return "circle r=" .. __K2L_Str(s.r)
    else
        return "unknown"
    end
end

local function main()
    local shapes = arrayOfShapes()
    print(shapes:describe())
    local r = Rect.new(2.0, 3.0)
    print(r:describe())
    print(r:perimeterHint())
    print(r:label())
    local sq = Square.new(2.0)
    print(sq:describe())
    print(Circle.new(1.0):describe())
    print(kind(sq))
    print(kind(r))
    print(kind(Circle.new(2.0)))
    print(__K2L_InstanceOf(sq, Polygon))
    print(__K2L_InstanceOf(sq, Named))
    local shape = Circle.new(1.0)
    print(__K2L_InstanceOf(shape, Polygon))
    local asRect = __K2L_InstanceOf(shape, Rect) and shape or nil
    print(asRect == nil)
    print(Dog.new1():speak())
end

function arrayOfShapes()
    return Rect.new(1.0, 1.0)
end

main()
return {Shape = Shape, Named = Named, Polygon = Polygon, Rect = Rect, Square = Square, Circle = Circle, Animal = Animal, Dog = Dog, kind = kind, arrayOfShapes = arrayOfShapes}
