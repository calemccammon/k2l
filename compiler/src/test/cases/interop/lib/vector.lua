local Vector = {}
Vector.__index = Vector

function Vector.new(x, y)
    return setmetatable({x = x, y = y}, Vector)
end

function Vector:length()
    return math.sqrt(self.x * self.x + self.y * self.y)
end

function Vector:add(other)
    return Vector.new(self.x + other.x, self.y + other.y)
end

return Vector
