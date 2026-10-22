-- ==== main.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IsComparable = ____lualib.__K2L_IsComparable
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local ____Quantities = require("units.Quantities")
local ____Trip = require("trip.Trip")

local ____lambda_1 = function(a, b) return ____Quantities.max(a, b) end
local function describe(label, values, zero)
    local sorted = values:sorted()
    print(label .. ": " .. __K2L_Str(sorted) .. ", min " .. __K2L_Str(sorted:first()) .. ", max " .. __K2L_Str(values:reduce(____lambda_1)) .. ", total " .. __K2L_Str(____Quantities.total(values, zero)))
end

local ____lambda_2 = function(____p1) return print(__K2L_Str(____p1)) end
local ____lambda_3 = function(____p1) return print(__K2L_Str(____p1)) end
local function main()
    local d = ____Quantities.getKm__1(3):plus(____Quantities.getM(250))
    local t = ____Quantities.getMin(12):plus(____Quantities.getS(30))
    print(__K2L_Str(d) .. " " .. __K2L_Str(t) .. " " .. __K2L_Str(____Quantities.div(d, t)) .. " " .. __K2L_Str(____Quantities.times(____Quantities.div(d, t), ____Quantities.getH(2))) .. " " .. __K2L_Str(____Quantities.times__2(2, d)) .. " " .. __K2L_Str(____Quantities.times__1(0.5, d)) .. " " .. __K2L_Str(d:unaryMinus()) .. " " .. d:div__1(____Quantities.getM(250)))
    print(tostring(__K2L_Compare(d, ____Quantities.getKm__1(3)) > 0) .. " " .. tostring(d:equals(____Quantities.Meters.new(3250.0))) .. " " .. d:compareTo(____Quantities.getKm__1(4)) .. " " .. __K2L_SetOf(____Quantities.getKm__1(1), ____Quantities.getM(1000), ____Quantities.getKm__1(2)).size .. " " .. t:getHours())
    local ____arg_1 = __K2L_Str(____Quantities.Speed.new(10.0))
    local ____arg_2 = ____Quantities.Speed.new(10.0):getKmh()
    local ____arg_3 = __K2L_Str(____Quantities.Kilograms.new(2.25))
    local ____arg = ____Quantities.getKg(80)
    local ____value = ____Quantities.getKm(2.5):getSi()
    print(____arg_1 .. " " .. ____arg_2 .. " " .. ____arg_3 .. " " .. __K2L_Str(____arg:minus(____Quantities.Kilograms.new(____value / 1000))))
    describe("distances", __K2L_ListOf(____Quantities.getKm__1(5), ____Quantities.getM(120), ____Quantities.getKm(2.5), ____Quantities.getM(900)), ____Quantities.Meters.new(0.0))
    describe("times", __K2L_ListOf(____Quantities.getH(1), ____Quantities.getMin(45), ____Quantities.getS(90), ____Quantities.getH(3):plus(____Quantities.getMin(5))), ____Quantities.Seconds.new(0.0))
    local trip = ____Trip.commute()
    local ____list = trip:summary()
    for ____i = 1, ____list.size do
        local it = ____list[____i];
        (____lambda_2)(it)
    end
    print("by mode: " .. __K2L_Str(trip:byMode()))
    local ____receiver = trip:fastest()
    local ____arg_4 = __K2L_Str(____receiver and ____receiver.mode)
    local ____receiver_1 = trip:fastest()
    print("fastest: " .. ____arg_4 .. " at " .. __K2L_Str(____receiver_1 and ____receiver_1:getSpeed()) .. ", average leg " .. __K2L_Str(trip:averageLeg()))
    local weekend = ____Trip.Trip.new("weekend"):leg(____Trip.Mode.CAR, ____Quantities.getKm__1(42), ____Quantities.getMin(40)):leg(____Trip.Mode.BIKE, ____Quantities.getKm__1(12), ____Quantities.getMin(50))
    local ____list_1 = weekend:summary()
    for ____i_1 = 1, ____list_1.size do
        local it = ____list_1[____i_1];
        (____lambda_3)(it)
    end
    local ____ok, ____result = pcall(function()
        ____Trip.Trip.new("reckless"):leg(____Trip.Mode.BIKE, ____Quantities.getKm__1(30), ____Quantities.getMin(20))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if getmetatable(____error) == ____Trip.SpeedingException then
            local e = ____error
            print("rejected: " .. __K2L_Str(e.message) .. " (" .. __K2L_Str(e.leg.mode) .. ")")
        else
            error(____error, 0)
        end
    end
    local ____ok_1, ____result_1 = pcall(function()
        ____Trip.Trip.new("empty"):leg(____Trip.Mode.WALK, ____Quantities.getM(0), ____Quantities.getMin(1))
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error_1, __K2L_IllegalArgumentException) then
            local e = ____error_1
            print("rejected: " .. __K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
    local ____ok_2, ____result_2 = pcall(function()
        ____Quantities.average(__K2L_ListOf(), ____Quantities.Seconds.new(0.0))
    end)
    if not ____ok_2 then
        local ____error_2 = __K2L_ToThrowable(____result_2)
        if __K2L_InstanceOf(____error_2, __K2L_IllegalArgumentException) then
            local e = ____error_2
            print("rejected: " .. __K2L_Str(e.message))
        else
            error(____error_2, 0)
        end
    end
    local all = __K2L_ListOf(trip, weekend)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = all:____array()
    for ____i_2 = 1, ____n do
        local it = ____items[____i_2]
        ____count = ____count + 1
        ____out[____count] = it:getCo2()
    end
    local ____arg_5 = __K2L_Str(____Quantities.total(__K2L_ListWrap(____out, ____count), ____Quantities.Kilograms.new(0.0)))
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = all:____array()
    for ____i_3 = 1, ____n_1 do
        local it = ____items_1[____i_3]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = it:getDistance()
    end
    print("total co2 " .. ____arg_5 .. ", distance " .. __K2L_Str(____Quantities.total(__K2L_ListWrap(____out_1, ____count_1), ____Quantities.getM(0))))
    local ____values = ____Trip.Mode.____values
    local ____out_2 = {}
    local ____count_2 = 0
    for ____i_4 = 1, #____values do
        local it = ____values[____i_4]
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = it:describe() .. "<=" .. __K2L_Str(it.maxSpeed)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_2, ____count_2)))
    local q = ____Quantities.getM(7)
    local anyQ = q
    print(q:format(0) .. " " .. q:getSymbol() .. " " .. tostring(__K2L_InstanceOf(anyQ, ____Quantities.Quantity)) .. " " .. tostring(__K2L_IsComparable(anyQ)) .. " " .. tostring(getmetatable(anyQ) == ____Quantities.Meters) .. " " .. tostring(getmetatable(anyQ) == ____Quantities.Seconds))
end

__K2L_RunMain(main)
return {describe = describe}
-- ==== trip/Trip.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_Str = ____lualib.__K2L_Str

local ____Quantities = require("units.Quantities")
local Mode = __K2L_Class("phys.trip.Mode")

function Mode:____init(name, ordinal, maxSpeed, emissionsPerKm)
    self.name = name
    self.ordinal = ordinal
    self.maxSpeed = maxSpeed
    self.emissionsPerKm = emissionsPerKm
end

function Mode:describe()
    return self.name:lower()
end

function Mode:toString()
    return self.name
end

function Mode:compareTo(other)
    return self.ordinal - other.ordinal
end

Mode.WALK = Mode.new("WALK", 0, ____Quantities.Speed.new(1.5), 0.0)
Mode.BIKE = Mode.new("BIKE", 1, ____Quantities.Speed.new(6.0), 0.0)
Mode.BUS = Mode.new("BUS", 2, ____Quantities.Speed.new(14.0), 0.08)
do
    local ____CAR = __K2L_Class("Mode", Mode)
    function ____CAR:describe()
        return "car (" .. __K2L_Str(self.maxSpeed) .. ")"
    end
    Mode.CAR = ____CAR.new("CAR", 3, ____Quantities.Speed.new(30.0), 0.17)
end
Mode.____values = {Mode.WALK, Mode.BIKE, Mode.BUS, Mode.CAR}
local Leg = __K2L_Class("phys.trip.Leg")

function Leg:____init(mode, distance, duration)
    self.mode = mode
    self.distance = distance
    self.duration = duration
    if not (self.distance:getSi() > 0) then
        error(__K2L_IllegalArgumentException.new("a leg must have a positive distance"))
    end
end

function Leg:getSpeed()
    return ____Quantities.div(self.distance, self.duration)
end

function Leg:getCo2()
    return ____Quantities.Kilograms.new(self.mode.emissionsPerKm * self.distance:getKm())
end

function Leg:toString()
    return "Leg(mode=" .. __K2L_Str(self.mode) .. ", distance=" .. __K2L_Str(self.distance) .. ", duration=" .. __K2L_Str(self.duration) .. ")"
end

function Leg:hashCode()
    return (31 * (31 * __K2L_Hash(self.mode) + __K2L_Hash(self.distance)) + __K2L_Hash(self.duration) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Leg:equals(other)
    return getmetatable(other) == Leg and self.mode == other.mode and self.distance:equals(other.distance) and self.duration:equals(other.duration)
end

local SpeedingException = __K2L_Class("phys.trip.SpeedingException", __K2L_IllegalStateException)

function SpeedingException:____init(leg)
    __K2L_IllegalStateException.____init(self, __K2L_Str(leg.mode) .. " too fast: " .. __K2L_Str(leg:getSpeed()) .. " > " .. __K2L_Str(leg.mode.maxSpeed))
    self.leg = leg
end

local Trip = __K2L_Class("phys.trip.Trip")

function Trip:____init(name)
    self.name = name
    self.legs = __K2L_ListOf()
end

function Trip:leg(mode, distance, duration)
    do
        local l = Leg.new(mode, distance, duration)
        if __K2L_Compare(l:getSpeed(), mode.maxSpeed) > 0 then
            error(SpeedingException.new(l))
        end
        self.legs:add(l)
    end
    return self
end

function Trip:getDistance()
    local ____list = self.legs
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = it.distance
    end
    return ____Quantities.total(__K2L_ListWrap(____out, ____count), ____Quantities.Meters.new(0.0))
end

function Trip:getDuration()
    local ____list_1 = self.legs
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = it.duration
    end
    return ____Quantities.total(__K2L_ListWrap(____out_1, ____count_1), ____Quantities.Seconds.new(0.0))
end

function Trip:getCo2()
    local ____list_2 = self.legs
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_2, ____n_2 = ____list_2:____array()
    for ____i_2 = 1, ____n_2 do
        local it = ____items_2[____i_2]
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = it:getCo2()
    end
    return ____Quantities.total(__K2L_ListWrap(____out_2, ____count_2), ____Quantities.Kilograms.new(0.0))
end

function Trip:getAverageSpeed()
    return ____Quantities.div(self:getDistance(), self:getDuration())
end

function Trip:byMode()
    local ____list_3 = self.legs
    local ____result = __K2L_Map.new()
    local ____items_3, ____n_3 = ____list_3:____array()
    for ____i_3 = 1, ____n_3 do
        local it = ____items_3[____i_3]
        local ____value = it.mode
        local ____group = ____result:get(____value)
        if ____group == nil then
            ____group = __K2L_List.new()
            ____result:put(____value, ____group)
        end
        ____group:add(it)
    end
    return ____result:mapValues(function(____destructured)
        local ls = ____destructured.value
        local ____out_3 = {}
        local ____count_3 = 0
        local ____items_4, ____n_4 = ls:____array()
        for ____i_4 = 1, ____n_4 do
            local it = ____items_4[____i_4]
            ____count_3 = ____count_3 + 1
            ____out_3[____count_3] = it.distance
        end
        return ____Quantities.total(__K2L_ListWrap(____out_3, ____count_3), ____Quantities.Meters.new(0.0))
    end)
end

local ____lambda_1 = function(it) return it:getSpeed() end
function Trip:fastest()
    return self.legs:maxByOrNull(____lambda_1)
end

function Trip:averageLeg()
    local ____list_4 = self.legs
    local ____out_4 = {}
    local ____count_4 = 0
    local ____items_5, ____n_5 = ____list_4:____array()
    for ____i_5 = 1, ____n_5 do
        local it = ____items_5[____i_5]
        ____count_4 = ____count_4 + 1
        ____out_4[____count_4] = it.distance
    end
    return ____Quantities.average(__K2L_ListWrap(____out_4, ____count_4), ____Quantities.Meters.new(0.0))
end

function Trip:summary()
    local ____builder = __K2L_ListOf()
    do
        ____builder:add(self.name .. ": " .. self.legs.size .. " legs, " .. self:getDistance():getKm() .. " km in " .. __K2L_Str(self:getDuration()) .. " (avg " .. __K2L_Str(self:getAverageSpeed()) .. "), co2 " .. __K2L_Str(self:getCo2()))
        local ____list_5 = self.legs
        for i = 0, ____list_5.size - 1 do
            local l = ____list_5[i + 1]
            ____builder:add("  " .. i + 1 .. ". " .. l.mode:describe() .. " " .. __K2L_Str(l.distance) .. " in " .. __K2L_Str(l.duration) .. " at " .. __K2L_Str(l:getSpeed()))
        end
    end
    return ____builder
end

local function commute()
    return Trip.new("commute"):leg(Mode.WALK, ____Quantities.Meters.new(800.0), ____Quantities.Seconds.new(600.0)):leg(Mode.BUS, ____Quantities.getKm(7.5), ____Quantities.Seconds.new(1500.0)):leg(Mode.WALK, ____Quantities.Meters.new(350.0), ____Quantities.Seconds.new(300.0))
end

return {Mode = Mode, Leg = Leg, SpeedingException = SpeedingException, Trip = Trip, commute = commute}
-- ==== units/Quantities.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart

local function fixed(self, decimals)
    local factor = 1
    for it = 0, decimals - 1 do
        factor = factor * 10
    end
    local scaled = math.floor(self * factor + 0.5)
    local sign = scaled < 0 and "-" or ""
    local abs = scaled < 0 and -scaled or scaled
    local whole = abs // factor
    if decimals == 0 then
        return sign .. whole
    end
    local frac = __K2L_StringPadStart(tostring(abs % factor), decimals, "0")
    return sign .. whole .. "." .. frac
end

local Quantity = __K2L_Class("phys.units.Quantity")
Quantity.____comparable = true

function Quantity:plus(other)
    return self:make(self:getSi() + other:getSi())
end

function Quantity:minus(other)
    return self:make(self:getSi() - other:getSi())
end

function Quantity:times(k)
    return self:make(self:getSi() * k)
end

function Quantity:div(k)
    return self:make(self:getSi() / k)
end

function Quantity:div__1(other)
    return self:getSi() / other:getSi()
end

function Quantity:unaryMinus()
    return self:make(-self:getSi())
end

function Quantity:compareTo(other)
    return __K2L_Compare(self:getSi(), other:getSi())
end

function Quantity:format(decimals)
    if decimals == nil then
        decimals = 2
    end
    return fixed(self:getSi(), decimals) .. " " .. self:getSymbol()
end

local Meters = __K2L_Class("phys.units.Meters", nil, Quantity)

function Meters:____init(si)
    self.si = si
end

function Meters.new(si)
    return setmetatable({si = si}, Meters)
end

function Meters:getSi()
    return self.si
end

function Meters:make(si)
    return Meters.new(si)
end

function Meters:getSymbol()
    return "m"
end

function Meters:getKm()
    return self:getSi() / 1000
end

function Meters:toString()
    return self:format()
end

function Meters:hashCode()
    return __K2L_Hash(self.si)
end

function Meters:equals(other)
    return getmetatable(other) == Meters and self.si == other.si
end

local Seconds = __K2L_Class("phys.units.Seconds", nil, Quantity)

function Seconds:____init(si)
    self.si__Seconds = si
end

function Seconds.new(si)
    return setmetatable({si__Seconds = si}, Seconds)
end

function Seconds:getSi()
    return self.si__Seconds or 0.0
end

function Seconds:make(si)
    return Seconds.new(si)
end

function Seconds:getSymbol()
    return "s"
end

function Seconds:getHours()
    return self:getSi() / 3600
end

function Seconds:toString()
    local ____total = math.floor(self:getSi() + 0.5)
    local h = ____total // 3600
    local m = ____total % 3600 // 60
    local s = ____total % 60
    return h > 0 and h .. "h" .. __K2L_StringPadStart(tostring(m), 2, "0") .. "m" or m .. "m" .. __K2L_StringPadStart(tostring(s), 2, "0") .. "s"
end

function Seconds:hashCode()
    return __K2L_Hash(self.si)
end

function Seconds:equals(other)
    return getmetatable(other) == Seconds and self.si == other.si
end

local Speed = __K2L_Class("phys.units.Speed", nil, Quantity)

function Speed:____init(si)
    self.si__Speed = si
end

function Speed.new(si)
    return setmetatable({si__Speed = si}, Speed)
end

function Speed:getSi()
    return self.si__Speed or 0.0
end

function Speed:make(si)
    return Speed.new(si)
end

function Speed:getSymbol()
    return "m/s"
end

function Speed:getKmh()
    return self:getSi() * 3.6
end

function Speed:toString()
    return fixed(self:getKmh(), 1) .. " km/h"
end

function Speed:hashCode()
    return __K2L_Hash(self.si)
end

function Speed:equals(other)
    return getmetatable(other) == Speed and self.si == other.si
end

local Kilograms = __K2L_Class("phys.units.Kilograms", nil, Quantity)

function Kilograms:____init(si)
    self.si__Kilograms = si
end

function Kilograms.new(si)
    return setmetatable({si__Kilograms = si}, Kilograms)
end

function Kilograms:getSi()
    return self.si__Kilograms or 0.0
end

function Kilograms:make(si)
    return Kilograms.new(si)
end

function Kilograms:getSymbol()
    return "kg"
end

function Kilograms:toString()
    return self:format(1)
end

function Kilograms:hashCode()
    return __K2L_Hash(self.si)
end

function Kilograms:equals(other)
    return getmetatable(other) == Kilograms and self.si == other.si
end

local function div(____this, t)
    return Speed.new(____this:getSi() / t:getSi())
end

local function times(____this_1, t)
    return Meters.new(____this_1:getSi() * t:getSi())
end

local function times__1(____this_2, m)
    return Meters.new(____this_2 * m:getSi())
end

local function times__2(____this_3, m)
    return Meters.new(____this_3 * m:getSi())
end

local function getM(____this_4)
    return Meters.new(____this_4 + 0.0)
end

local function getKm(____this_5)
    return Meters.new(____this_5 * 1000)
end

local function getKm__1(____this_6)
    return Meters.new(____this_6 * 1000.0)
end

local function getMin(____this_7)
    return Seconds.new(____this_7 * 60.0)
end

local function getH(____this_8)
    return Seconds.new(____this_8 * 3600.0)
end

local function getS(____this_9)
    return Seconds.new(____this_9 + 0.0)
end

local function getKg(____this_10)
    return Kilograms.new(____this_10 + 0.0)
end

local ____lambda_1 = function(acc, q) return acc:plus(q) end
local function total(____this_11, zero)
    return ____this_11:fold(zero, ____lambda_1)
end

local function average(____this_12, zero)
    local n = 0
    local sum = ____this_12:fold(zero, function(acc, q)
        n = n + 1
        return acc:plus(q)
    end)
    if not (n > 0) then
        error(__K2L_IllegalArgumentException.new("average of no " .. zero:getSymbol() .. " values"))
    end
    return sum:div(n + 0.0)
end

local function max(a, b)
    return __K2L_Compare(a, b) >= 0 and a or b
end

return {fixed = fixed, Quantity = Quantity, Meters = Meters, Seconds = Seconds, Speed = Speed, Kilograms = Kilograms, div = div, times = times, times__1 = times__1, times__2 = times__2, getM = getM, getKm = getKm, getKm__1 = getKm__1, getMin = getMin, getH = getH, getS = getS, getKg = getKg, total = total, average = average, max = max}
