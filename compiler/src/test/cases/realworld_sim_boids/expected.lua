local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Bits = ____lualib.__K2L_Bits
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Random = ____lualib.__K2L_Random
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Truncate = ____lualib.__K2L_Truncate

local Boid = __K2L_Class("Boid")

function Boid:____init(x, y, heading, speed)
    self.x = x
    self.y = y
    self.heading = heading
    self.speed = speed
end

function Boid.new(x, y, heading, speed)
    return setmetatable({x = x, y = y, heading = heading, speed = speed}, Boid)
end

local Flock = __K2L_Class("Flock")

function Flock:____init(count, seed, size)
    self.size = size
    local rng = __K2L_Random.seeded(seed)
    local ____out = {}
    for ____i = 1, count do
        local it = ____i - 1
        ____out[____i] = Boid.new(rng:nextDouble(self.size), rng:nextDouble(self.size), rng:nextDouble(-math.pi, math.pi), rng:nextDouble(0.5, 1.5))
    end
    self.boids = __K2L_ListWrap(____out, count)
end

function Flock:wrap(v)
    return v - math.floor(v / self.size) * self.size
end

function Flock:angleDiff(a, b)
    return __K2L_Num.IEEErem(b - a, 2 * math.pi)
end

function Flock:step()
    local turns = __K2L_ListOfSize(self.boids.size, 0.0, true)
    local ____list = self.boids
    for i = 0, ____list.size - 1 do
        local b = ____list[i + 1]
        do
            local cx = 0.0
            local cy = 0.0
            local sx = 0.0
            local sy = 0.0
            local align = 0.0
            local n = 0
            local ____list_1 = self.boids
            for ____i_1 = 1, ____list_1.size do
                local o = ____list_1[____i_1]
                do
                    if o == b then
                        goto ____continue
                    end
                    local d = __K2L_Num.hypot(o.x - b.x, o.y - b.y)
                    if d > 10.0 then
                        goto ____continue
                    end
                    n = n + 1
                    cx = cx + o.x
                    cy = cy + o.y
                    align = align + self:angleDiff(b.heading, o.heading)
                    if d < 3.0 then
                        sx = sx - (o.x - b.x) / (d * d + 1.0E-9)
                        sy = sy - (o.y - b.y) / (d * d + 1.0E-9)
                    end
                end
                ::____continue::
            end
            if n == 0 then
                goto ____continue_1
            end
            local toCenter = math.atan(cy / n - b.y, cx / n - b.x)
            local away = sx == 0.0 and sy == 0.0 and b.heading or math.atan(sy, sx)
            local turn = 0.05 * self:angleDiff(b.heading, toCenter) + 0.1 * (align / n) + 0.15 * self:angleDiff(b.heading, away)
            local ____value = __K2L_Num.coerceIn(turn, -0.3, 0.3)
            if i < 0 or i >= turns.size then
                __K2L_IndexError(i, turns.size, "array")
            end
            turns[i + 1] = ____value
        end
        ::____continue_1::
    end
    local ____list_2 = self.boids
    for i = 0, ____list_2.size - 1 do
        local b = ____list_2[i + 1]
        b.heading = __K2L_Num.IEEErem(b.heading + (turns[i + 1] or __K2L_IndexError(i, turns.size, "array")), 2 * math.pi)
        b.x = self:wrap(b.x + math.cos(b.heading) * b.speed)
        b.y = self:wrap(b.y + math.sin(b.heading) * b.speed)
    end
end

function Flock:order()
    local ____list_3 = self.boids
    local ____sum = 0.0
    local ____items, ____n = ____list_3:____array()
    for ____i_2 = 1, ____n do
        local it = ____items[____i_2]
        ____sum = ____sum + math.cos(it.heading)
    end
    local sx = ____sum
    local ____list_4 = self.boids
    local ____sum_1 = 0.0
    local ____items_1, ____n_1 = ____list_4:____array()
    for ____i_3 = 1, ____n_1 do
        local it = ____items_1[____i_3]
        ____sum_1 = ____sum_1 + math.sin(it.heading)
    end
    local sy = ____sum_1
    return __K2L_Num.hypot(sx, sy) / self.boids.size
end

local ____lambda_1 = function(it) return __K2L_ListOfSize(4, 0, true) end
local function flock()
    print("-- flock")
    local f = Flock.new(24, 7, 40.0)
    print("order at start " .. string.format("%.6f", f:order()))
    for round = 1, 4 do
        for it = 0, 24 do
            f:step()
        end
        print("after " .. round * 25 .. " steps order " .. string.format("%.6f", f:order()))
    end
    local b = f.boids:get(0)
    print("boid 0 at (" .. string.format("%.4f", b.x) .. ", " .. string.format("%.4f", b.y) .. ") heading " .. string.format("%.4f", b.heading))
    local grid = __K2L_ListOfSize(4, ____lambda_1, true)
    local ____list_5 = f.boids
    for ____i_4 = 1, ____list_5.size do
        local boid = ____list_5[____i_4]
        local ____object = grid:get(__K2L_Num.coerceIn(__K2L_Truncate(boid.y / 10), 0, 3))
        local ____key = __K2L_Num.coerceIn(__K2L_Truncate(boid.x / 10), 0, 3)
        ____object[____key + 1] = (____object[____key + 1] or __K2L_IndexError(____key, ____object.size, "array")) + 1
    end
    for ____i_5 = 1, grid.size do
        local it = grid[____i_5]
        print(it:joinToString(" "))
    end
end

local function show(label, values)
    print(label .. ": " .. values:joinToString(", "))
end

local ____lambda_2 = function(it) return string.format("%.1f", it) end
local function mathTour()
    print("-- rounding")
    local xs = __K2L_ListOf(2.5, -2.5, 3.5, -0.5, 0.49999999999999994, 1.0E16 + 1, -7.0001)
    local ____out_1 = {}
    local ____count = 0
    local ____items_2, ____n_2 = xs:____array()
    for ____i_6 = 1, ____n_2 do
        local it = ____items_2[____i_6]
        ____count = ____count + 1
        ____out_1[____count] = math.floor(it)
    end
    show("floor", __K2L_ListWrap(____out_1, ____count))
    local ____out_2 = {}
    local ____count_1 = 0
    local ____items_3, ____n_3 = xs:____array()
    for ____i_7 = 1, ____n_3 do
        local it = ____items_3[____i_7]
        ____count_1 = ____count_1 + 1
        ____out_2[____count_1] = math.ceil(it)
    end
    show("ceil", __K2L_ListWrap(____out_2, ____count_1))
    local ____out_3 = {}
    local ____count_2 = 0
    local ____items_4, ____n_4 = xs:____array()
    for ____i_8 = 1, ____n_4 do
        local it = ____items_4[____i_8]
        ____count_2 = ____count_2 + 1
        ____out_3[____count_2] = __K2L_Num.round(it)
    end
    show("round", __K2L_ListWrap(____out_3, ____count_2))
    local ____out_4 = {}
    local ____count_3 = 0
    local ____items_5, ____n_5 = xs:____array()
    for ____i_9 = 1, ____n_5 do
        local it = ____items_5[____i_9]
        ____count_3 = ____count_3 + 1
        ____out_4[____count_3] = __K2L_Truncate(it)
    end
    show("truncate", __K2L_ListWrap(____out_4, ____count_3))
    local ____out_5 = {}
    local ____count_4 = 0
    local ____items_6, ____n_6 = xs:____array()
    for ____i_10 = 1, ____n_6 do
        local it = ____items_6[____i_10]
        ____count_4 = ____count_4 + 1
        ____out_5[____count_4] = math.floor(it + 0.5)
    end
    print("roundToInt: " .. __K2L_Str(__K2L_ListWrap(____out_5, ____count_4)))
    local ____list_6 = __K2L_ListOf(2.5, -2.5, 1.0E15 + 0.5, -0.5)
    local ____out_6 = {}
    local ____count_5 = 0
    local ____items_7, ____n_7 = ____list_6:____array()
    for ____i_11 = 1, ____n_7 do
        local it = ____items_7[____i_11]
        ____count_5 = ____count_5 + 1
        ____out_6[____count_5] = math.floor(it + 0.5)
    end
    print("roundToLong: " .. __K2L_Str(__K2L_ListWrap(____out_6, ____count_5)))
    local ____list_7 = __K2L_ListOf(1.0E10, -1.0E10, math.huge, -math.huge)
    local ____out_7 = {}
    local ____count_6 = 0
    local ____items_8, ____n_8 = ____list_7:____array()
    for ____i_12 = 1, ____n_8 do
        local it = ____items_8[____i_12]
        ____count_6 = ____count_6 + 1
        ____out_7[____count_6] = math.floor(it + 0.5)
    end
    print("saturating: " .. __K2L_Str(__K2L_ListWrap(____out_7, ____count_6)))
    local ____list_8 = __K2L_ListOf(3.99, -3.99, 1.0E10, -1.0E10, 0.0 / 0.0)
    local ____out_8 = {}
    local ____count_7 = 0
    local ____items_9, ____n_9 = ____list_8:____array()
    for ____i_13 = 1, ____n_9 do
        local it = ____items_9[____i_13]
        ____count_7 = ____count_7 + 1
        ____out_8[____count_7] = __K2L_Truncate(it)
    end
    print("toInt: " .. __K2L_Str(__K2L_ListWrap(____out_8, ____count_7)))
    local ____ok, ____result = pcall(function()
        math.floor(0.0 / 0.0 + 0.5)
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
            local e = ____error
            print("NaN.roundToInt: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    print("-- signs")
    local edges = __K2L_ListOf(0.0, -0.0, 1.5, -1.5, math.huge, -math.huge, 0.0 / 0.0, 4.9E-324)
    local ____out_9 = {}
    local ____count_8 = 0
    local ____items_10, ____n_10 = edges:____array()
    for ____i_14 = 1, ____n_10 do
        local it = ____items_10[____i_14]
        ____count_8 = ____count_8 + 1
        ____out_9[____count_8] = __K2L_Num.signDouble(it)
    end
    show("sign", __K2L_ListWrap(____out_9, ____count_8))
    local ____out_10 = {}
    local ____count_9 = 0
    local ____items_11, ____n_11 = edges:____array()
    for ____i_15 = 1, ____n_11 do
        local it = ____items_11[____i_15]
        ____count_9 = ____count_9 + 1
        ____out_10[____count_9] = math.abs(it)
    end
    show("abs", __K2L_ListWrap(____out_10, ____count_9))
    local ____out_11 = {}
    local ____count_10 = 0
    local ____items_12, ____n_12 = edges:____array()
    for ____i_16 = 1, ____n_12 do
        local it = ____items_12[____i_16]
        ____count_10 = ____count_10 + 1
        ____out_11[____count_10] = __K2L_Bits.withSign(it, -1)
    end
    show("withSign(-1)", __K2L_ListWrap(____out_11, ____count_10))
    local ____out_12 = {}
    local ____count_11 = 0
    local ____items_13, ____n_13 = edges:____array()
    for ____i_17 = 1, ____n_13 do
        local it = ____items_13[____i_17]
        ____count_11 = ____count_11 + 1
        ____out_12[____count_11] = __K2L_Bits.withSign(3.0, it)
    end
    show("withSign(-0.0)", __K2L_ListWrap(____out_12, ____count_11))
    local ____out_13 = {}
    local ____count_12 = 0
    local ____items_14, ____n_14 = edges:____array()
    for ____i_18 = 1, ____n_14 do
        local it = ____items_14[____i_18]
        ____count_12 = ____count_12 + 1
        ____out_13[____count_12] = math.abs(it)
    end
    show("absoluteValue", __K2L_ListWrap(____out_13, ____count_12))
    print("1/-0.0 = " .. 1.0 / -0.0 .. ", -0.0 == 0.0: " .. tostring(-0.0 == 0.0) .. ", compare: " .. __K2L_Compare(-0.0, 0.0))
    print("min/max with -0.0: " .. math.min(0.0, -0.0) .. " " .. math.max(-0.0, 0.0) .. " " .. math.min(0.0 / 0.0, 1.0))
    print("-- IEEErem vs %")
    local ____pairs = __K2L_ListOf(__K2L_Pair.new(5.0, 3.0), __K2L_Pair.new(-5.0, 3.0), __K2L_Pair.new(7.5, 2.0), __K2L_Pair.new(6.5, 2.0), __K2L_Pair.new(10.0, -4.0), __K2L_Pair.new(1.0, 0.0), __K2L_Pair.new(math.huge, 2.0), __K2L_Pair.new(3.0, math.huge))
    print(____pairs:joinToString(" ", nil, nil, nil, nil, function(____destructured)
        local a, b = ____destructured.first, ____destructured.second
        return __K2L_Num.IEEErem(a, b) .. "|" .. a % b
    end))
    print("-- powers and logs")
    show("pow", __K2L_ListOf(2.0 ^ 10, 2.0 ^ (-1074), 2.0 ^ 0.5, (-8.0) ^ (1.0 / 3), 0.0 ^ 0, (0.0 / 0.0) ^ 0, 1.0 ^ (0.0 / 0.0), (-2.0) ^ 3, 10.0 ^ 308))
    show("int pow", __K2L_ListOf(3.0 ^ 4, 1.5 ^ (-2), (-1.0) ^ 2147483647))
    show("ln", __K2L_ListOf(math.log(math.exp(1)), math.log(1.0), math.log(0.0), math.log(-1.0), math.log(math.huge)))
    show("log10", __K2L_ListOf(math.log(1000.0, 10), math.log(2.0, 10), math.log(0.001, 10), math.log(4.9E-324, 10)))
    show("exp", __K2L_ListOf(math.exp(1.0), math.exp(-1.0), math.exp(710.0), math.exp(-750.0), math.exp(0.0 / 0.0)))
    show("sqrt", __K2L_ListOf(math.sqrt(2.0), math.sqrt(-0.0), math.sqrt(-1.0), math.sqrt(math.huge), math.sqrt(1.0E-320)))
    show("hypot", __K2L_ListOf(__K2L_Num.hypot(3.0, 4.0), __K2L_Num.hypot(1.0E300, 1.0E300), __K2L_Num.hypot(0.0 / 0.0, math.huge), __K2L_Num.hypot(-5.0, 12.0)))
    show("atan2", __K2L_ListOf(math.atan(0.0, -1.0), math.atan(-0.0, -1.0), math.atan(1.0, 0.0), math.atan(0.0, 0.0), math.atan(-0.0, 0.0), math.atan(1.0, -math.huge)))
    show("trig", __K2L_ListOf(math.sin(math.pi), math.cos(math.pi), math.sin(-0.0), math.cos(math.huge), math.sin(1.0E22)))
    print("-- limits")
    print(4.9E-324 .. " " .. 1.7976931348623157E308 .. " " .. -1.7976931348623157E308 .. " " .. 4.9E-324 / 2 .. " " .. 1.7976931348623157E308 * 2)
    print(-2147483648 + 0.0 .. " " .. -9223372036854775807 - 1 + 0.0 .. " " .. 1.4E-45 .. " " .. 3.4028235E38)
    print(math.pi .. " " .. math.exp(1) .. " " .. math.floor(math.pi * 1.0E10 + 0.5) .. " " .. 0.1 + 0.2 .. " " .. 0.1 + 0.2)
    print("NaN checks: " .. tostring(__K2L_Num.isNaN(0.0 / 0.0)) .. " " .. tostring(__K2L_Num.isNaN(0.0 / 0.0)) .. " " .. tostring(0.0 / 0.0 ~= 0.0 / 0.0))
    print("sorted: " .. __K2L_Str(__K2L_ListOf(3.0, 0.0 / 0.0, -0.0, 0.0, -math.huge, 1.0):sorted()))
    print(__K2L_ArrayOf(1.0, 2.5, -0.0):joinToString("|") .. " " .. __K2L_ArrayOf(1.0, 2.5):joinToString(" ", nil, nil, nil, nil, ____lambda_2))
    print(__K2L_ListOf(1.0, 0.1, 1.0 / 3):joinToString() .. " " .. __K2L_ListOf(1.0, 0.5):joinToString(nil, "<", ">"))
end

local function main()
    flock()
    mathTour()
end

__K2L_RunMain(main)
return {Boid = Boid, Flock = Flock, flock = flock, show = show, mathTour = mathTour}
