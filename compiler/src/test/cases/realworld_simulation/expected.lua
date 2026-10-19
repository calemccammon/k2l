local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_EnumValues = ____lualib.__K2L_EnumValues
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_GenerateSequenceLazy = ____lualib.__K2L_GenerateSequenceLazy
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PriorityQueue = ____lualib.__K2L_PriorityQueue
local __K2L_Random = ____lualib.__K2L_Random
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_SortedSetOf = ____lualib.__K2L_SortedSetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Customer
local SimEvent = __K2L_Class("SimEvent")

function SimEvent:____init(time)
    self.time = time
end

function SimEvent:compareTo(other)
    return __K2L_CompareBy(function(it) return it.time end, function(it) return it.priority end)(self, other)
end

SimEvent.Arrival = __K2L_Class("SimEvent$Arrival", SimEvent)

function SimEvent.Arrival:____init(time, customer)
    SimEvent.____init(self, time)
    self.customer = customer
    self.priority = 1
end

SimEvent.Departure = __K2L_Class("SimEvent$Departure", SimEvent)

function SimEvent.Departure:____init(time, teller, customer)
    SimEvent.____init(self, time)
    self.teller = teller
    self.customer = customer
    self.priority = 0
end

Customer = __K2L_Class("Customer")

function Customer:____init(id, arrival, serviceTime, vip)
    self.id = id
    self.arrival = arrival
    self.serviceTime = serviceTime
    self.vip = vip
end

function Customer:toString()
    return "Customer(id=" .. self.id .. ", arrival=" .. self.arrival .. ", serviceTime=" .. self.serviceTime .. ", vip=" .. tostring(self.vip) .. ")"
end

function Customer:hashCode()
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.id) + __K2L_Hash(self.arrival)) + __K2L_Hash(self.serviceTime)) + __K2L_Hash(self.vip))
end

function Customer:equals(other)
    return getmetatable(other) == Customer and self.id == other.id and self.arrival == other.arrival and self.serviceTime == other.serviceTime and self.vip == other.vip
end

local BankStats = __K2L_Class("BankStats")

function BankStats:____init()
    self.served = 0
    self.totalWait = 0
    self.maxWait = 0
    self.maxQueue = 0
    self.waits = __K2L_ListOf()
end

function BankStats:record(wait)
    self.served = self.served + 1
    self.totalWait = self.totalWait + wait
    self.maxWait = math.max(self.maxWait, wait)
    self.waits:add(wait)
end

function BankStats:getAverageWait()
    return self.served == 0 and 0.0 or (self.totalWait + 0.0) / self.served
end

local Bank = __K2L_Class("Bank")

function Bank:____init(tellers, log)
    if log == nil then
        log = false
    end
    self.tellers = tellers
    self.log = log
    self.events = __K2L_PriorityQueue.new()
    self.queue = __K2L_ArrayDeque.new()
    self.busy = __K2L_ListOfSize(self.tellers, false, true)
    self.busyTime = __K2L_ListOfSize(self.tellers, 0, true)
    self.stats = BankStats.new()
    self.clock = 0
end

function Bank:schedule(e)
    self.events:add(e)
end

function Bank:startService(teller, c)
    local ____object = self.busy
    ____object:set(teller, true)
    local ____object_1 = self.busyTime
    ____object_1:set(teller, ____object_1:get(teller) + c.serviceTime)
    self.stats:record(self.clock - c.arrival)
    self:schedule(SimEvent.Departure.new(self.clock + c.serviceTime, teller, c))
    if self.log then
        print("  t=" .. self.clock .. " teller " .. teller .. " serves #" .. c.id .. " (waited " .. self.clock - c.arrival .. ")")
    end
end

function Bank:run()
    while self.events:isNotEmpty() do
        local e = self.events:poll()
        self.clock = e.time
        if __K2L_InstanceOf(e, SimEvent.Arrival) then
            local free = self.busy:indexOfFirst(function(it) return not it end)
            if free >= 0 then
                self:startService(free, e.customer)
            else
                if e.customer.vip then
                    self.queue:addFirst(e.customer)
                else
                    self.queue:addLast(e.customer)
                end
                local ____object_3 = self.stats
                ____object_3.maxQueue = math.max(self.stats.maxQueue, self.queue.size)
            end
        elseif __K2L_InstanceOf(e, SimEvent.Departure) then
            local ____object_2 = self.busy
            local ____key = e.teller
            ____object_2:set(____key, false)
            local ____receiver = self.queue:removeFirstOrNull()
            if ____receiver ~= nil then
                self:startService(e.teller, ____receiver)
            end
        end
    end
    return self
end

function Bank:utilisation()
    return self.busyTime:map(function(it)
        return __K2L_StringFormat("%.0f%%", 100.0 * it / self.clock)
    end)
end

local function customers(n, seed)
    local rnd = __K2L_Random.seeded(seed)
    local t = 0
    return __K2L_ListOfSize(n, function(id)
        t = t + rnd:nextInt(1, 6)
        return Customer.new(id + 1, t, rnd:nextInt(2, 12), rnd:nextInt(10) == 0)
    end)
end

local Life = __K2L_Class("Life")

function Life:____init(w, h, alive)
    self.w = w
    self.h = h
    self.cells = __K2L_ListOfSize(self.h, function(y)
        return __K2L_ListOfSize(self.w, function(x) return alive:contains(__K2L_Pair.new(x, y)) end, true)
    end, true)
    self.generation = 0
end

function Life:getPopulation()
    return self.cells:sumOf(function(row)
        return row:count(function(it) return it end)
    end)
end

function Life:neighbours(x, y)
    return __K2L_IntRange.new(-1, 1):sumOf(function(dy)
        return __K2L_IntRange.new(-1, 1):count(function(dx)
            return (dx ~= 0 or dy ~= 0) and self.cells:get(__K2L_Num.mod(y + dy, self.h)):get(__K2L_Num.mod(x + dx, self.w))
        end)
    end)
end

function Life:step()
    self.cells = __K2L_ListOfSize(self.h, function(y)
        return __K2L_ListOfSize(self.w, function(x)
            local n = self:neighbours(x, y)
            return n == 3 or n == 2 and self.cells:get(y):get(x)
        end, true)
    end, true)
    self.generation = self.generation + 1
end

function Life:toString()
    return self.cells:joinToString("\n", nil, nil, nil, nil, function(row)
        return row:joinToString("", nil, nil, nil, nil, function(it) return it and "#" or "." end)
    end)
end

local Motion = __K2L_Class("Motion")

function Motion:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Motion:toString()
    return self.name
end

function Motion:compareTo(other)
    return self.ordinal - other.ordinal
end

Motion.IDLE = Motion.new("IDLE", 0)
Motion.UP = Motion.new("UP", 1)
Motion.DOWN = Motion.new("DOWN", 2)
Motion.DOORS_OPEN = Motion.new("DOORS_OPEN", 3)
Motion.____values = {Motion.IDLE, Motion.UP, Motion.DOWN, Motion.DOORS_OPEN}
local Elevator = __K2L_Class("Elevator")

function Elevator:____init(floors)
    self.floors = floors
    self.floor = self.floors.first
    self.motion = Motion.IDLE
    self.requests = __K2L_SortedSetOf()
    self.trace = __K2L_ListOf()
end

function Elevator:call(f)
    if not self.floors:contains(f) then
        error(__K2L_IllegalArgumentException.new("floor " .. f .. " out of range " .. __K2L_Str(self.floors)))
    end
    self.requests:add(f)
end

function Elevator:tick()
    if self.requests:contains(self.floor) then
        self.requests:remove(self.floor)
        self.motion = Motion.DOORS_OPEN
    elseif self.requests:isEmpty() then
        self.motion = Motion.IDLE
    elseif self.motion == Motion.UP and self.requests:any(function(it) return it > self.floor end) then
        self.motion = Motion.UP
    elseif self.motion == Motion.DOWN and self.requests:any(function(it) return it < self.floor end) then
        self.motion = Motion.DOWN
    elseif self.requests:first() > self.floor or self.requests:last() > self.floor and self.floor - self.requests:first() > self.requests:last() - self.floor then
        self.motion = Motion.UP
    else
        self.motion = Motion.DOWN
    end
    local ____subject = self.motion
    if ____subject == Motion.UP then
        self.floor = self.floor + 1
    elseif ____subject == Motion.DOWN then
        self.floor = self.floor - 1
    end
    self.trace:add(__K2L_Text.first(self.motion.name) .. self.floor)
end

local function main()
    local people = customers(40, 2024)
    print("first customers: " .. __K2L_Str(people:take(3)))
    print("vips: " .. __K2L_Str(people:filter(function(it) return it.vip end):map(function(it) return it.id end)))
    for tellers = 1, 3 do
        local bank = Bank.new(tellers)
        for _, it in ipairs(people) do
            bank:schedule(SimEvent.Arrival.new(it.arrival, it))
        end
        bank:run()
        local s = bank.stats
        local p90 = s.waits:sorted():get(__K2L_IDiv(s.waits.size * 9, 10))
        print("tellers=" .. tellers .. " served=" .. s.served .. " avgWait=" .. __K2L_StringFormat("%.2f", s:getAverageWait()) .. " maxWait=" .. s.maxWait .. " " .. "p90=" .. p90 .. " maxQueue=" .. s.maxQueue .. " end=" .. bank.clock .. " util=" .. __K2L_Str(bank:utilisation()))
    end
    local small = Bank.new(2, true)
    for _, it in ipairs(customers(6, 7)) do
        small:schedule(SimEvent.Arrival.new(it.arrival, it))
    end
    small:run()
    local rnd = __K2L_Random.seeded(99)
    print("dice: " .. __K2L_Str(__K2L_ListOfSize(10, function(it) return rnd:nextInt(1, 7) end)) .. " coin: " .. __K2L_ListOfSize(8, function(it) return rnd:nextBoolean() and "H" or "T" end):joinToString(""))
    local shuffled = __K2L_IntRange.new(1, 10):shuffled(__K2L_Random.seeded(5))
    print("shuffled: " .. __K2L_Str(shuffled) .. " sorted back: " .. tostring(__K2L_Equals(shuffled:sorted(), __K2L_IntRange.new(1, 10):toList())))
    local histogram = __K2L_ListOfSize(6, 0, true)
    for it = 0, 599 do
        do
            local ____key_1 = __K2L_Random.seeded(it):nextInt(6)
            histogram:set(____key_1, histogram:get(____key_1) + 1)
        end
    end
    print("histogram total=" .. histogram:sum() .. " min>50=" .. tostring(histogram:all(function(it) return it > 50 end)))
    local glider = __K2L_ReadOnlySetOf(__K2L_Pair.new(1, 0), __K2L_Pair.new(2, 1), __K2L_Pair.new(0, 2), __K2L_Pair.new(1, 2), __K2L_Pair.new(2, 2))
    local life = Life.new(8, 6, glider)
    print("gen " .. life.generation .. ", population " .. life:getPopulation() .. "\n" .. __K2L_Str(life))
    for it = 0, 3 do
        life:step()
    end
    print("gen " .. life.generation .. ", population " .. life:getPopulation() .. "\n" .. __K2L_Str(life))
    local blinker = Life.new(5, 5, __K2L_ReadOnlySetOf(__K2L_Pair.new(1, 2), __K2L_Pair.new(2, 2), __K2L_Pair.new(3, 2)))
    local history = __K2L_GenerateSequenceLazy(function()
        blinker:step()
        return blinker:toString()
    end):take(4):toList()
    print("blinker period 2: " .. tostring(history:get(0) == history:get(2) and history:get(1) == history:get(3) and history:get(0) ~= history:get(1)))
    local elevator = Elevator.new(__K2L_IntRange.new(0, 9))
    elevator:call(5)
    elevator:call(2)
    for it = 0, 3 do
        elevator:tick()
    end
    elevator:call(8)
    elevator:call(1)
    for it = 0, 15 do
        elevator:tick()
    end
    print("elevator: " .. elevator.trace:joinToString(" "))
    print("ended at " .. elevator.floor .. " " .. __K2L_Str(elevator.motion))
    local ____ok, ____result = pcall(function()
        elevator:call(12)
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
            local e = ____error
            print("rejected: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    local counts = elevator.trace:groupingBy(function(it) return __K2L_Text.first(it) end):eachCount()
    print("motion counts: " .. __K2L_Str(__K2L_EnumValues(Motion):associate(function(m)
        return __K2L_Pair.new(m, counts:get(__K2L_Text.first(m.name)) or 0)
    end)))
end

main()
return {SimEvent = SimEvent, Customer = Customer, BankStats = BankStats, Bank = Bank, customers = customers, Life = Life, Motion = Motion, Elevator = Elevator}
