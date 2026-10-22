local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str

local Vec = __K2L_Class("Vec")

function Vec:____init(x, y)
    self.x = x
    self.y = y
end

function Vec.new(x, y)
    return setmetatable({x = x, y = y}, Vec)
end

function Vec:plus(o)
    return Vec.new(self.x + o.x, self.y + o.y)
end

function Vec:minus(o)
    return Vec.new(self.x - o.x, self.y - o.y)
end

function Vec:times(s)
    return Vec.new(self.x * s, self.y * s)
end

function Vec:unaryMinus()
    return Vec.new(-self.x, -self.y)
end

function Vec:dot(o)
    return self.x * o.x + self.y * o.y
end

function Vec:getLength()
    return __K2L_Num.hypot(self.x, self.y)
end

function Vec:normalized()
    local ____value = self:getLength()
    local ____result
    ____result = ____value == 0.0 and Vec.new(0.0, 0.0) or Vec.new(self.x / ____value, self.y / ____value)
    return ____result
end

function Vec:toString()
    return "(" .. string.format("%.4f", self.x) .. ", " .. string.format("%.4f", self.y) .. ")"
end

function Vec:hashCode()
    return (31 * __K2L_Hash(self.x) + __K2L_Hash(self.y) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Vec:equals(other)
    return getmetatable(other) == Vec and self.x == other.x and self.y == other.y
end

function Vec:____initCompanion()
    self.ZERO = Vec.new(0.0, 0.0)
end

Vec:____initCompanion()
local Ball = __K2L_Class("Ball")

function Ball:____init(id, pos, vel, radius, mass)
    self.id = id
    self.pos = pos
    self.vel = vel
    self.radius = radius
    self.mass = mass
end

function Ball.new(id, pos, vel, radius, mass)
    return setmetatable({id = id, pos = pos, vel = vel, radius = radius, mass = mass}, Ball)
end

function Ball:getInverseMass()
    return self.mass == 0.0 and 0.0 or 1.0 / self.mass
end

function Ball:kinetic()
    return 0.5 * self.mass * self.vel:dot(self.vel)
end

local World = __K2L_Class("World")

function World:____init(width, height, gravity, restitution)
    if gravity == nil then
        gravity = -9.81
    end
    if restitution == nil then
        restitution = 0.9
    end
    self.width = width
    self.height = height
    self.gravity = gravity
    self.restitution = restitution
    self.balls = __K2L_ListOf()
    self.time = 0.0
    self.wallHits = 0
    self.ballHits = 0
    self.drag = 0.0
end

function World:potential()
    local ____list = self.balls
    local ____sum = 0.0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____sum = ____sum + it.mass * -self.gravity * (it.pos.y - it.radius)
    end
    return ____sum
end

function World:kinetic()
    local ____list_1 = self.balls
    local ____sum_1 = 0.0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        ____sum_1 = ____sum_1 + it:kinetic()
    end
    return ____sum_1
end

local ____lambda_1 = function(acc, b) return acc:plus(b.vel:times(b.mass)) end
function World:momentum()
    return self.balls:fold(Vec.ZERO, ____lambda_1)
end

function World:step(dt)
    local ____list_2 = self.balls
    for ____i_2 = 1, ____list_2.size do
        local b = ____list_2[____i_2]
        local v = b.vel:plus(Vec.new(0.0, self.gravity * dt))
        if self.drag > 0.0 then
            v = v:times(1.0 - self.drag * dt)
        end
        b.vel = v
        b.pos = b.pos:plus(v:times(dt))
    end
    local ____list_3 = self.balls
    for ____i_3 = 1, ____list_3.size do
        local b = ____list_3[____i_3]
        self:bounceWalls(b)
    end
    for i = 0, self.balls.size - 1 do
        for j = i + 1, self.balls.size - 1 do
            self:collide(self.balls:get(i), self.balls:get(j))
        end
    end
    self.time = self.time + dt
end

function World:bounceWalls(b)
    local ____destructured = b.pos
    local x, y = ____destructured.x, ____destructured.y
    local ____destructured_1 = b.vel
    local vx, vy = ____destructured_1.x, ____destructured_1.y
    if x - b.radius < 0.0 and vx < 0.0 then
        x = b.radius
        vx = -vx * self.restitution
        self.wallHits = self.wallHits + 1
    elseif x + b.radius > self.width and vx > 0.0 then
        x = self.width - b.radius
        vx = -vx * self.restitution
        self.wallHits = self.wallHits + 1
    end
    if y - b.radius < 0.0 and vy < 0.0 then
        y = b.radius
        vy = -vy * self.restitution
        self.wallHits = self.wallHits + 1
    elseif y + b.radius > self.height and vy > 0.0 then
        y = self.height - b.radius
        vy = -vy * self.restitution
        self.wallHits = self.wallHits + 1
    end
    b.pos = Vec.new(x, y)
    b.vel = Vec.new(vx, vy)
end

function World:collide(a, b)
    local delta = b.pos:minus(a.pos)
    local dist = delta:getLength()
    local overlap = a.radius + b.radius - dist
    if overlap <= 0.0 or dist == 0.0 then
        return
    end
    local n = delta:times(1.0 / dist)
    local totalInverse = a:getInverseMass() + b:getInverseMass()
    local correction = n:times(overlap / totalInverse * 0.8)
    a.pos = a.pos:minus(correction:times(a:getInverseMass()))
    b.pos = b.pos:plus(correction:times(b:getInverseMass()))
    local relative = b.vel:minus(a.vel):dot(n)
    if relative > 0.0 then
        return
    end
    local impulse = -(1.0 + self.restitution) * relative / totalInverse
    a.vel = a.vel:minus(n:times(impulse * a:getInverseMass()))
    b.vel = b.vel:plus(n:times(impulse * b:getInverseMass()))
    self.ballHits = self.ballHits + 1
end

function World:report(label)
    local ke = self:kinetic()
    local pe = self:potential()
    print(label .. " t=" .. string.format("%.3f", self.time) .. " KE=" .. string.format("%.4f", ke) .. " PE=" .. string.format("%.4f", pe) .. " E=" .. string.format("%.4f", ke + pe) .. " p=" .. __K2L_Str(self:momentum()))
end

local function projectile()
    print("-- projectile")
    local dt = 0.01
    local pos = Vec.new(0.0, 0.0)
    local vel = Vec.new(20.0, 20.0)
    local t = 0.0
    local apex = 0.0
    while pos.y >= 0.0 do
        vel = vel:plus(Vec.new(0.0, -9.81 * dt))
        pos = pos:plus(vel:times(dt))
        t = t + dt
        apex = math.max(apex, pos.y)
    end
    print("flight " .. string.format("%.2f", t) .. "s range " .. string.format("%.4f", pos.x) .. " apex " .. string.format("%.4f", apex))
    local analyticRange = 2 * 20.0 * 20.0 / 9.81
    print("analytic range " .. string.format("%.4f", analyticRange) .. " error " .. string.format("%.4f", math.abs(pos.x - analyticRange)))
end

local function bouncing()
    print("-- bouncing balls")
    local world = World.new(10.0, 10.0)
    world.balls:add(Ball.new(0, Vec.new(2.0, 8.0), Vec.new(1.5, 0.0), 0.5, 1.0))
    world.balls:add(Ball.new(1, Vec.new(5.0, 6.0), Vec.new(-1.0, 2.0), 0.7, 2.0))
    world.balls:add(Ball.new(2, Vec.new(8.0, 3.0), Vec.new(-3.0, 4.0), 0.4, 0.5))
    world.balls:add(Ball.new(3, Vec.new(4.0, 2.0), Vec.new(2.0, -1.0), 0.6, 1.5))
    world:report("start")
    for frame = 1, 600 do
        world:step(1.0 / 120)
        if frame % 150 == 0 then
            world:report("frame " .. frame)
        end
    end
    local ____list_4 = world.balls
    for ____i_4 = 1, ____list_4.size do
        local b = ____list_4[____i_4]
        print("ball " .. b.id .. " pos=" .. __K2L_Str(b.pos) .. " vel=" .. __K2L_Str(b.vel) .. " speed=" .. string.format("%.4f", b.vel:getLength()))
    end
    print("wall hits " .. world.wallHits .. ", ball hits " .. world.ballHits)
end

local ____lambda_2 = function(it) return string.format("%.3f", it.vel.x) end
local function newtonsCradle()
    print("-- cradle")
    local world = World.new(20.0, 2.0, 0.0, 1.0)
    for i = 0, 4 do
        world.balls:add(Ball.new(i, Vec.new(5.0 + i * 1.0, 1.0), Vec.ZERO, 0.5, 1.0))
    end
    local ____object = world.balls:get(0)
    ____object.pos = Vec.new(2.0, 1.0)
    local ____object_1 = world.balls:get(0)
    ____object_1.vel = Vec.new(3.0, 0.0)
    local before = world:kinetic()
    for it = 0, 399 do
        world:step(0.005)
    end
    print(world.balls:joinToString(nil, nil, nil, nil, nil, ____lambda_2))
    print("energy kept: " .. string.format("%.6f", world:kinetic() / before))
    print("momentum: " .. __K2L_Str(world:momentum()))
end

local function orbit()
    print("-- orbit")
    local gm = 1.0
    local pos = Vec.new(1.0, 0.0)
    local vel = Vec.new(0.0, 1.0)
    local dt = 0.001
    local minR = 1.7976931348623157E308
    local maxR = 0.0
    local function energy()
        return 0.5 * vel:dot(vel) - gm / pos:getLength()
    end
    local e0 = energy()
    for it = 0, 6283 do
        do
            local r = pos:getLength()
            local acc = pos:normalized():unaryMinus():times(gm / (r * r))
            vel = vel:plus(acc:times(dt))
            pos = pos:plus(vel:times(dt))
            minR = math.min(minR, pos:getLength())
            maxR = math.max(maxR, pos:getLength())
        end
    end
    print("after one period: " .. __K2L_Str(pos))
    print("radius " .. string.format("%.6f", minR) .. ".." .. string.format("%.6f", maxR))
    print("energy drift " .. string.format("%.3e", energy() - e0))
    print("unit circle " .. math.sqrt(0.5) * math.sqrt(2.0) .. " " .. __K2L_Str(Vec.new(3.0, 4.0):normalized()))
end

local function main()
    projectile()
    bouncing()
    newtonsCradle()
    orbit()
end

__K2L_RunMain(main)
return {Vec = Vec, Ball = Ball, World = World, projectile = projectile, bouncing = bouncing, newtonsCradle = newtonsCradle, orbit = orbit}
