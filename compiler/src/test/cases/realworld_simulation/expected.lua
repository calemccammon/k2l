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
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_NaturalOrder = ____lualib.__K2L_NaturalOrder
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Random = ____lualib.__K2L_Random
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_SortedSetOf = ____lualib.__K2L_SortedSetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Customer
local MinQueue = __K2L_Class("MinQueue")

function MinQueue:____init(comparator)
    self.comparator = comparator
    self.heap = __K2L_List.new()
end

function MinQueue:getSize()
    return self.heap.size
end

function MinQueue:isEmpty()
    return self.heap:isEmpty()
end

function MinQueue:isNotEmpty()
    return self.heap:isNotEmpty()
end

function MinQueue:peek()
    return self.heap:firstOrNull()
end

function MinQueue:add(item)
    self.heap:add(item)
    local i = self.heap.size - 1
    while i > 0 do
        local parent = (i - 1) // 2
        if self.comparator(self.heap:get(i), self.heap:get(parent)) >= 0 then
            break
        end
        local t = self.heap:get(i)
        local ____object = self.heap
        local ____key = i
        ____object:set(____key, self.heap:get(parent))
        local ____object_1 = self.heap
        ____object_1:set(parent, t)
        i = parent
    end
    return true
end

function MinQueue:offer(item)
    return self:add(item)
end

function MinQueue:plusAssign(item)
    self:add(item)
end

function MinQueue:poll()
    if self.heap:isEmpty() then
        error(__K2L_NoSuchElementException.new("queue is empty"))
    end
    local top = self.heap:get(0)
    local last = self.heap:removeAt(self.heap.size - 1)
    if self.heap:isNotEmpty() then
        local ____object_2 = self.heap
        ____object_2:set(0, last)
        local i = 0
        while true do
            local l = 2 * i + 1
            if l >= self.heap.size then
                break
            end
            local r = l + 1
            local c = r < self.heap.size and self.comparator(self.heap:get(r), self.heap:get(l)) < 0 and r or l
            if self.comparator(self.heap:get(c), self.heap:get(i)) >= 0 then
                break
            end
            local t = self.heap:get(i)
            local ____object_3 = self.heap
            local ____key_1 = i
            ____object_3:set(____key_1, self.heap:get(c))
            local ____object_4 = self.heap
            ____object_4:set(c, t)
            i = c
        end
    end
    return top
end

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
    self.events = MinQueue.new(__K2L_NaturalOrder)
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
    local ____object_5 = self.busy
    ____object_5:set(teller, true)
    local ____object_6 = self.busyTime
    ____object_6[teller + 1] = (____object_6[teller + 1] or __K2L_IndexError(teller, ____object_6.size, "array")) + c.serviceTime
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
                local ____object_8 = self.stats
                ____object_8.maxQueue = math.max(self.stats.maxQueue, self.queue.size)
            end
        elseif ____mt == SimEvent.Departure then
            local ____object_7 = self.busy
            local ____key_2 = e.teller
            ____object_7:set(____key_2, false)
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
        ____out[____count] = string.format("%.0f%%", 100.0 * it / self.clock)
    end
    return __K2L_ListWrap(____out, ____count)
end

local function customers(n, seed)
    local rnd = __K2L_Random.seeded(seed)
    local t = 0
    local ____out_1 = {}
    for ____i_1 = 1, n do
        local id = ____i_1 - 1
        local ____result
        t = t + rnd:nextInt(1, 6)
        ____result = Customer.new(id + 1, t, rnd:nextInt(2, 12), rnd:nextInt(10) == 0)
        ____out_1[____i_1] = ____result
    end
    return __K2L_ListWrap(____out_1, n)
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
    local ____list_1 = self.cells
    local ____sum = 0
    local ____items_2, ____n_2 = ____list_1:____array()
    for ____i_3 = 1, ____n_2 do
        local row = ____items_2[____i_3]
        local ____result_1
        do
            local ____result_2 = 0
            local ____items_1, ____n_1 = row:____array()
            for ____i_2 = 1, ____n_1 do
                local it = ____items_1[____i_2]
                if it then
                    ____result_2 = ____result_2 + 1
                end
            end
            ____result_1 = ____result_2
        end
        ____sum = ____sum + ____result_1
    end
    return ____sum
end

function Life:neighbours(x, y)
    return __K2L_IntRange.new(-1, 1):sumOf(function(dy)
        return __K2L_IntRange.new(-1, 1):count(function(dx)
            return (dx ~= 0 or dy ~= 0) and self.cells:get((y + dy) % self.h):get((x + dx) % self.w)
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
    self.requests = __K2L_SortedSetOf(nil)
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
            local ____result_4 = false
            local ____items_4, ____n_4 = ____list_3:____array()
            for ____i_5 = 1, ____n_4 do
                local it = ____items_4[____i_5]
                if it > self.floor then
                    ____result_4 = true
                    break
                end
            end
            ____cond_1 = ____result_4
        end
        if ____cond_1 then
            self.motion = Motion.UP
        else
            local ____cond = self.motion == Motion.DOWN
            if ____cond then
                local ____list_2 = self.requests
                local ____result_3 = false
                local ____items_3, ____n_3 = ____list_2:____array()
                for ____i_4 = 1, ____n_3 do
                    local it = ____items_3[____i_4]
                    if it < self.floor then
                        ____result_3 = true
                        break
                    end
                end
                ____cond = ____result_3
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
    local ____out_2 = {}
    local ____count_1 = 0
    local ____items_5, ____n_5 = people:____array()
    for ____i_6 = 1, ____n_5 do
        local it = ____items_5[____i_6]
        if it.vip then
            ____count_1 = ____count_1 + 1
            ____out_2[____count_1] = it
        end
    end
    local ____list_4 = __K2L_ListWrap(____out_2, ____count_1)
    local ____out_3 = {}
    local ____count_2 = 0
    local ____items_6, ____n_6 = ____list_4:____array()
    for ____i_7 = 1, ____n_6 do
        local it = ____items_6[____i_7]
        ____count_2 = ____count_2 + 1
        ____out_3[____count_2] = it.id
    end
    print("vips: " .. __K2L_Str(__K2L_ListWrap(____out_3, ____count_2)))
    for tellers = 1, 3 do
        local bank = Bank.new(tellers)
        for ____i_8 = 1, people.size do
            local it = people[____i_8]
            bank:schedule(SimEvent.Arrival.new(it.arrival, it))
        end
        bank:run()
        local s = bank.stats
        local p90 = s.waits:sorted():get(s.waits.size * 9 // 10)
        print("tellers=" .. tellers .. " served=" .. s.served .. " avgWait=" .. string.format("%.2f", s:getAverageWait()) .. " maxWait=" .. s.maxWait .. " " .. "p90=" .. p90 .. " maxQueue=" .. s.maxQueue .. " end=" .. bank.clock .. " util=" .. __K2L_Str(bank:utilisation()))
    end
    local small = Bank.new(2, true)
    local ____list_5 = customers(6, 7)
    for ____i_9 = 1, ____list_5.size do
        local it = ____list_5[____i_9]
        small:schedule(SimEvent.Arrival.new(it.arrival, it))
    end
    small:run()
    local rnd = __K2L_Random.seeded(99)
    local ____out_4 = {}
    for ____i_10 = 1, 10 do
        local it = ____i_10 - 1
        ____out_4[____i_10] = rnd:nextInt(1, 7)
    end
    local ____arg = __K2L_Str(__K2L_ListWrap(____out_4, 10))
    local ____out_5 = {}
    for ____i_11 = 1, 8 do
        local it = ____i_11 - 1
        local ____result_5
        ____result_5 = rnd:nextBoolean() and "H" or "T"
        ____out_5[____i_11] = ____result_5
    end
    print("dice: " .. ____arg .. " coin: " .. __K2L_ListWrap(____out_5, 8):joinToString(""))
    local shuffled = __K2L_IntRange.new(1, 10):shuffled(__K2L_Random.seeded(5))
    print("shuffled: " .. __K2L_Str(shuffled) .. " sorted back: " .. tostring(__K2L_Equals(shuffled:sorted(), __K2L_IntRange.new(1, 10):toList())))
    local histogram = __K2L_ListOfSize(6, 0, true)
    for it = 0, 599 do
        do
            local ____key_3 = __K2L_Random.seeded(it):nextInt(6)
            histogram[____key_3 + 1] = (histogram[____key_3 + 1] or __K2L_IndexError(____key_3, histogram.size, "array")) + 1
        end
    end
    local ____arg_1 = histogram:sum()
    local ____result_6 = true
    local ____items_7, ____n_7 = histogram:____array()
    for ____i_12 = 1, ____n_7 do
        local it = ____items_7[____i_12]
        if not (it > 50) then
            ____result_6 = false
            break
        end
    end
    print("histogram total=" .. ____arg_1 .. " min>50=" .. tostring(____result_6))
    local glider = __K2L_SetOf(__K2L_Pair.new(1, 0), __K2L_Pair.new(2, 1), __K2L_Pair.new(0, 2), __K2L_Pair.new(1, 2), __K2L_Pair.new(2, 2))
    local life = Life.new(8, 6, glider)
    print("gen " .. life.generation .. ", population " .. life:getPopulation() .. "\n" .. __K2L_Str(life))
    for it = 0, 3 do
        life:step()
    end
    print("gen " .. life.generation .. ", population " .. life:getPopulation() .. "\n" .. __K2L_Str(life))
    local blinker = Life.new(5, 5, __K2L_SetOf(__K2L_Pair.new(1, 2), __K2L_Pair.new(2, 2), __K2L_Pair.new(3, 2)))
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
    local ____ok, ____result_7 = pcall(function()
        elevator:call(12)
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_7)
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

__K2L_RunMain(main)
return {MinQueue = MinQueue, SimEvent = SimEvent, Customer = Customer, BankStats = BankStats, Bank = Bank, customers = customers, Life = Life, Motion = Motion, Elevator = Elevator}
