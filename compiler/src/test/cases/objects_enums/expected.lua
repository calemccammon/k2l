local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Str = ____lualib.__K2L_Str

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

function Direction:compareTo(other)
    return self.ordinal - other.ordinal
end

Direction.NORTH = Direction.new("NORTH", 0)
Direction.EAST = Direction.new("EAST", 1)
Direction.SOUTH = Direction.new("SOUTH", 2)
Direction.WEST = Direction.new("WEST", 3)
Direction.____values = {Direction.NORTH, Direction.EAST, Direction.SOUTH, Direction.WEST}
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

function Planet:compareTo(other)
    return self.ordinal - other.ordinal
end

Planet.MERCURY = Planet.new("MERCURY", 0, 3.303E23, 2439700.0)
Planet.EARTH = Planet.new("EARTH", 1, 5.976E24, 6378140.0)
Planet.____values = {Planet.MERCURY, Planet.EARTH}
local Point = __K2L_Class("Point")

function Point:____init(x, y)
    self.x = x
    self.y = y
end

function Point.new(x, y)
    return setmetatable({x = x, y = y}, Point)
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
