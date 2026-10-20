local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_EnumValues = ____lualib.__K2L_EnumValues
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_GenerateSequenceLazy = ____lualib.__K2L_GenerateSequenceLazy
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PriorityQueue = ____lualib.__K2L_PriorityQueue
local __K2L_Random = ____lualib.__K2L_Random
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_SortedSetOf = ____lualib.__K2L_SortedSetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Customer
local SimEvent = __K2L_Class("SimEvent")
SimEvent.____comparable = true

function SimEvent:____init(time)
    self.time = time
end

function SimEvent.new(time)
    return setmetatable({time = time}, SimEvent)
end

local ____lambda_1 = function(it) return it.time end
local ____lambda_2 = function(it) return it.priority end
function SimEvent:compareTo(other)
    return __K2L_CompareBy(____lambda_1, ____lambda_2)(self, other)
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

function Customer.new(id, arrival, serviceTime, vip)
    return setmetatable({id = id, arrival = arrival, serviceTime = serviceTime, vip = vip}, Customer)
end

function Customer:toString()
    return "Customer(id=" .. self.id .. ", arrival=" .. self.arrival .. ", serviceTime=" .. self.serviceTime .. ", vip=" .. tostring(self.vip) .. ")"
end

function Customer:hashCode()
    return (31 * (31 * (31 * self.id + self.arrival) + self.serviceTime) + (self.vip and 1231 or 1237) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
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
    self.busy = __K2L_ListOfSize(self.tellers, false, "[Z")
    self.busyTime = __K2L_ListOfSize(self.tellers, 0, "[I")
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
    ____object_1[teller + 1] = (____object_1[teller + 1] or __K2L_IndexError(teller, ____object_1.size, "array")) + c.serviceTime
    self.stats:record(self.clock - c.arrival)
    self:schedule(SimEvent.Departure.new(self.clock + c.serviceTime, teller, c))
    if self.log then
        print("  t=" .. self.clock .. " teller " .. teller .. " serves #" .. c.id .. " (waited " .. self.clock - c.arrival .. ")")
    end
end

local ____lambda_3 = function(it) return not it end
function Bank:run()
    while self.events:isNotEmpty() do
        local e = self.events:poll()
        self.clock = e.time
        local ____mt = getmetatable(e)
        if ____mt == SimEvent.Arrival then
            local free = self.busy:indexOfFirst(____lambda_3)
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
        elseif ____mt == SimEvent.Departure then
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
    local ____list = self.busyTime
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = __K2L_StringFormat("%.0f%%", 100.0 * it / self.clock)
    end
    return __K2L_ListWrap(____out, ____count)
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
        return __K2L_ListOfSize(self.w, function(x) return alive:contains(__K2L_Pair.new(x, y)) end, "[Z")
    end, "[[Z")
    self.generation = 0
end

function Life:getPopulation()
    local ____list_1 = self.cells
    local ____sum = 0
    local ____items_2, ____n_2 = ____list_1:____array()
    for ____i_2 = 1, ____n_2 do
        local row = ____items_2[____i_2]
        local ____result
        do
            local ____result_1 = 0
            local ____items_1, ____n_1 = row:____array()
            for ____i_1 = 1, ____n_1 do
                local it = ____items_1[____i_1]
                if it then
                    ____result_1 = ____result_1 + 1
                end
            end
            ____result = ____result_1
        end
        ____sum = ____sum + ____result
    end
    return ____sum
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
        end, "[Z")
    end, "[[Z")
    self.generation = self.generation + 1
end

local ____lambda_4 = function(it) return it and "#" or "." end
local ____lambda_5 = function(row)
    return row:joinToString("", nil, nil, nil, nil, ____lambda_4)
end
function Life:toString()
    return self.cells:joinToString("\n", nil, nil, nil, nil, ____lambda_5)
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
    else
        local ____cond_1 = self.motion == Motion.UP
        if ____cond_1 then
            local ____list_3 = self.requests
            local ____result_3 = false
            local ____items_4, ____n_4 = ____list_3:____array()
            for ____i_4 = 1, ____n_4 do
                local it = ____items_4[____i_4]
                if it > self.floor then
                    ____result_3 = true
                    break
                end
            end
            ____cond_1 = ____result_3
        end
        if ____cond_1 then
            self.motion = Motion.UP
        else
            local ____cond = self.motion == Motion.DOWN
            if ____cond then
                local ____list_2 = self.requests
                local ____result_2 = false
                local ____items_3, ____n_3 = ____list_2:____array()
                for ____i_3 = 1, ____n_3 do
                    local it = ____items_3[____i_3]
                    if it < self.floor then
                        ____result_2 = true
                        break
                    end
                end
                ____cond = ____result_2
            end
            if ____cond then
                self.motion = Motion.DOWN
            elseif self.requests:first() > self.floor or self.requests:last() > self.floor and self.floor - self.requests:first() > self.requests:last() - self.floor then
                self.motion = Motion.UP
            else
                self.motion = Motion.DOWN
            end
        end
    end
    local ____subject = self.motion
    if ____subject == Motion.UP then
        self.floor = self.floor + 1
    elseif ____subject == Motion.DOWN then
        self.floor = self.floor - 1
    end
    self.trace:add(__K2L_Text.first(self.motion.name) .. self.floor)
end

local ____lambda_6 = function(it) return __K2L_Text.first(it) end
local function main()
    local people = customers(40, 2024)
    print("first customers: " .. __K2L_Str(people:take(3)))
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_5, ____n_5 = people:____array()
    for ____i_5 = 1, ____n_5 do
        local it = ____items_5[____i_5]
        if it.vip then
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = it
        end
    end
    local ____list_4 = __K2L_ListWrap(____out_1, ____count_1)
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_6, ____n_6 = ____list_4:____array()
    for ____i_6 = 1, ____n_6 do
        local it = ____items_6[____i_6]
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = it.id
    end
    print("vips: " .. __K2L_Str(__K2L_ListWrap(____out_2, ____count_2)))
    for tellers = 1, 3 do
        local bank = Bank.new(tellers)
        local ____mod = people.____modCount
        for ____i_7 = 1, people.size do
            local it = people[____i_7]
            bank:schedule(SimEvent.Arrival.new(it.arrival, it))
            if people.____modCount ~= ____mod and people:____comodified(____i_7) then
                break
            end
        end
        bank:run()
        local s = bank.stats
        local ____arg = s.waits:sorted()
        local ____dividend = s.waits.size * 9
        local p90 = ____arg:get(____dividend >= 0 and ____dividend // 10 or 0 - -____dividend // 10)
        print("tellers=" .. tellers .. " served=" .. s.served .. " avgWait=" .. __K2L_StringFormat("%.2f", s:getAverageWait()) .. " maxWait=" .. s.maxWait .. " " .. "p90=" .. p90 .. " maxQueue=" .. s.maxQueue .. " end=" .. bank.clock .. " util=" .. __K2L_Str(bank:utilisation()))
    end
    local small = Bank.new(2, true)
    local ____list_5 = customers(6, 7)
    local ____mod_1 = ____list_5.____modCount
    for ____i_8 = 1, ____list_5.size do
        local it = ____list_5[____i_8]
        small:schedule(SimEvent.Arrival.new(it.arrival, it))
        if ____list_5.____modCount ~= ____mod_1 and ____list_5:____comodified(____i_8) then
            break
        end
    end
    small:run()
    local rnd = __K2L_Random.seeded(99)
    print("dice: " .. __K2L_Str(__K2L_ListOfSize(10, function(it) return rnd:nextInt(1, 7) end)) .. " coin: " .. __K2L_ListOfSize(8, function(it) return rnd:nextBoolean() and "H" or "T" end):joinToString(""))
    local shuffled = __K2L_IntRange.new(1, 10):shuffled(__K2L_Random.seeded(5))
    print("shuffled: " .. __K2L_Str(shuffled) .. " sorted back: " .. tostring(__K2L_Equals(shuffled:sorted(), __K2L_IntRange.new(1, 10):toList())))
    local histogram = __K2L_ListOfSize(6, 0, "[I")
    for it = 0, 599 do
        do
            local ____key_1 = __K2L_Random.seeded(it):nextInt(6)
            histogram[____key_1 + 1] = (histogram[____key_1 + 1] or __K2L_IndexError(____key_1, histogram.size, "array")) + 1
        end
    end
    local ____arg_1 = histogram:sum()
    local ____result_4 = true
    local ____items_7, ____n_7 = histogram:____array()
    for ____i_9 = 1, ____n_7 do
        local it = ____items_7[____i_9]
        if not (it > 50) then
            ____result_4 = false
            break
        end
    end
    print("histogram total=" .. ____arg_1 .. " min>50=" .. tostring(____result_4))
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
    local ____ok, ____result_5 = pcall(function()
        elevator:call(12)
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_5)
        if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
            local e = ____error
            print("rejected: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    local counts = elevator.trace:groupingBy(____lambda_6):eachCount()
    print("motion counts: " .. __K2L_Str(__K2L_EnumValues(Motion):associate(function(m)
        return __K2L_Pair.new(m, counts:get(__K2L_Text.first(m.name)) or 0)
    end)))
end

main()
return {SimEvent = SimEvent, Customer = Customer, BankStats = BankStats, Bank = Bank, customers = customers, Life = Life, Motion = Motion, Elevator = Elevator}
