local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_CompanionInfo = ____lualib.__K2L_CompanionInfo
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_EnumMap = ____lualib.__K2L_EnumMap
local __K2L_EnumSets = ____lualib.__K2L_EnumSets
local __K2L_EnumValueOf = ____lualib.__K2L_EnumValueOf
local __K2L_EnumValues = ____lualib.__K2L_EnumValues
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_FunctionRef = ____lualib.__K2L_FunctionRef
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_KClassOf = ____lualib.__K2L_KClassOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_LazyObject = ____lualib.__K2L_LazyObject
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_StringTrimEnd = ____lualib.__K2L_StringTrimEnd
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local State = __K2L_Class("State")
__K2L_ClassInfo(State, "State", "State", "class")

function State:____init(name, ordinal, canSend)
    if canSend == nil then
        canSend = false
    end
    self.name = name
    self.ordinal = ordinal
    self.canSend = canSend
end

function State:getIsTerminal()
    return self == State.CLOSED or self == State.TIME_WAIT
end

function State:toString()
    return self.name
end

function State:compareTo(other)
    return self.ordinal - other.ordinal
end

State.CLOSED = State.new("CLOSED", 0)
State.LISTEN = State.new("LISTEN", 1)
State.SYN_SENT = State.new("SYN_SENT", 2)
State.SYN_RECEIVED = State.new("SYN_RECEIVED", 3)
State.ESTABLISHED = State.new("ESTABLISHED", 4, true)
State.FIN_WAIT_1 = State.new("FIN_WAIT_1", 5)
State.FIN_WAIT_2 = State.new("FIN_WAIT_2", 6)
State.CLOSE_WAIT = State.new("CLOSE_WAIT", 7, true)
State.CLOSING = State.new("CLOSING", 8)
State.LAST_ACK = State.new("LAST_ACK", 9)
State.TIME_WAIT = State.new("TIME_WAIT", 10)
State.____values = {State.CLOSED, State.LISTEN, State.SYN_SENT, State.SYN_RECEIVED, State.ESTABLISHED, State.FIN_WAIT_1, State.FIN_WAIT_2, State.CLOSE_WAIT, State.CLOSING, State.LAST_ACK, State.TIME_WAIT}
local Event = __K2L_Class("Event")
__K2L_ClassInfo(Event, "Event", "Event", "interface")
Event.PassiveOpen = __K2L_Class("Event$PassiveOpen", nil, Event)
__K2L_ClassInfo(Event.PassiveOpen, "Event.PassiveOpen", "Event$PassiveOpen", "class")

function Event.PassiveOpen:toString()
    return "PassiveOpen"
end

function Event.PassiveOpen:hashCode()
    return -1965221763
end

Event.ActiveOpen = __K2L_Class("Event$ActiveOpen", nil, Event)
__K2L_ClassInfo(Event.ActiveOpen, "Event.ActiveOpen", "Event$ActiveOpen", "class")

function Event.ActiveOpen:toString()
    return "ActiveOpen"
end

function Event.ActiveOpen:hashCode()
    return -25416060
end

Event.Syn = __K2L_Class("Event$Syn", nil, Event)
__K2L_ClassInfo(Event.Syn, "Event.Syn", "Event$Syn", "class")

function Event.Syn:toString()
    return "Syn"
end

function Event.Syn:hashCode()
    return 2034230580
end

Event.SynAck = __K2L_Class("Event$SynAck", nil, Event)
__K2L_ClassInfo(Event.SynAck, "Event.SynAck", "Event$SynAck", "class")

function Event.SynAck:toString()
    return "SynAck"
end

function Event.SynAck:hashCode()
    return -225272139
end

Event.Ack = __K2L_Class("Event$Ack", nil, Event)
__K2L_ClassInfo(Event.Ack, "Event.Ack", "Event$Ack", "class")

function Event.Ack:toString()
    return "Ack"
end

function Event.Ack:hashCode()
    return 2034212597
end

Event.Fin = __K2L_Class("Event$Fin", nil, Event)
__K2L_ClassInfo(Event.Fin, "Event.Fin", "Event$Fin", "class")

function Event.Fin:toString()
    return "Fin"
end

function Event.Fin:hashCode()
    return 2034217591
end

Event.Close = __K2L_Class("Event$Close", nil, Event)
__K2L_ClassInfo(Event.Close, "Event.Close", "Event$Close", "class")

function Event.Close:toString()
    return "Close"
end

function Event.Close:hashCode()
    return 670308708
end

Event.Send = __K2L_Class("Event$Send", nil, Event)
__K2L_ClassInfo(Event.Send, "Event.Send", "Event$Send", "class")

function Event.Send:____init(bytes)
    self.bytes = bytes
end

function Event.Send.new(bytes)
    return setmetatable({bytes = bytes}, Event.Send)
end

function Event.Send:toString()
    return "Send(bytes=" .. self.bytes .. ")"
end

function Event.Send:hashCode()
    return self.bytes
end

function Event.Send:equals(other)
    return getmetatable(other) == Event.Send and self.bytes == other.bytes
end

Event.Tick = __K2L_Class("Event$Tick", nil, Event)
__K2L_ClassInfo(Event.Tick, "Event.Tick", "Event$Tick", "class")

function Event.Tick:____init(ms)
    self.ms = ms
end

function Event.Tick.new(ms)
    return setmetatable({ms = ms}, Event.Tick)
end

function Event.Tick:toString()
    return "Tick(ms=" .. self.ms .. ")"
end

function Event.Tick:hashCode()
    return self.ms
end

function Event.Tick:equals(other)
    return getmetatable(other) == Event.Tick and self.ms == other.ms
end

Event.Reset = __K2L_Class("Event$Reset", nil, Event)
__K2L_ClassInfo(Event.Reset, "Event.Reset", "Event$Reset", "class")

function Event.Reset:toString()
    return "Reset"
end

function Event.Reset:hashCode()
    return 683956411
end

local InvalidTransition = __K2L_Class("InvalidTransition", __K2L_IllegalStateException)
__K2L_ClassInfo(InvalidTransition, "InvalidTransition", "InvalidTransition", "class")

function InvalidTransition:____init(from, event)
    __K2L_IllegalStateException.____init(self, "no transition from " .. __K2L_Str(from) .. " on " .. __K2L_Str(event))
    self.from = from
    self.event = event
end

local Step = __K2L_Class("Step")
__K2L_ClassInfo(Step, "Step", "Step", "class")

function Step:____init(from, event, to)
    self.from = from
    self.event = event
    self.to = to
end

function Step.new(from, event, to)
    return setmetatable({from = from, event = event, to = to}, Step)
end

function Step:toString()
    return "Step(from=" .. __K2L_Str(self.from) .. ", event=" .. __K2L_Str(self.event) .. ", to=" .. __K2L_Str(self.to) .. ")"
end

function Step:hashCode()
    return (31 * (31 * __K2L_Hash(self.from) + __K2L_Hash(self.event)) + __K2L_Hash(self.to) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Step:equals(other)
    return getmetatable(other) == Step and self.from == other.from and __K2L_Equals(self.event, other.event) and self.to == other.to
end

local Connection = __K2L_Class("Connection")
__K2L_ClassInfo(Connection, "Connection", "Connection", "class")
__K2L_CompanionInfo(Connection, "Connection.Companion", "Connection$Companion", "Companion")

function Connection:____init(name)
    self.name = name
    self.state = State.CLOSED
    self.history = __K2L_ListOf()
    self.visits = __K2L_EnumMap.new(__K2L_JavaClass(__K2L_KClassOf(State)))
    self.timeWaitMs = 0
    self.sent = 0
    local ____object = self.visits
    local ____key = State.CLOSED
    ____object:set(____key, 1)
end

local ____lambda_1 = function(____p1, ____p2) return ____p1 + ____p2 end
function Connection:fire(event)
    local ____next = self:next(event)
    self.history:add(Step.new(self.state, event, ____next))
    if ____next ~= self.state then
        self.visits:merge(____next, 1, __K2L_FunctionRef.new("plus", "kotlin/Int.plus(kotlin.Int)", ____lambda_1))
    end
    if ____next == State.TIME_WAIT and self.state ~= State.TIME_WAIT then
        self.timeWaitMs = 0
    end
    self.state = ____next
end

function Connection:next(e)
    local ____mt = getmetatable(e)
    if __K2L_Equals(e, Event.Reset) then
        return State.CLOSED
    elseif ____mt == Event.Send and self.state.canSend then
        local ____value_1 = self.state
        self.sent = self.sent + e.bytes
        return ____value_1
    elseif ____mt == Event.Send then
        error(InvalidTransition.new(self.state, e))
    elseif ____mt == Event.Tick and self.state == State.TIME_WAIT then
        self.timeWaitMs = self.timeWaitMs + e.ms
        return self.timeWaitMs >= 2 * 30 and State.CLOSED or State.TIME_WAIT
    elseif ____mt == Event.Tick then
        return self.state
    else
        local ____receiver = Connection.table:get(self.state)
        local ____value = ____receiver and ____receiver:get(e)
        if ____value == nil then
            error(InvalidTransition.new(self.state, e))
        end
        return ____value
    end
end

function Connection:visited()
    return __K2L_EnumSets.copyOf(self.visits:getKeys())
end

function Connection:visitCounts()
    return self.visits
end

function Connection:____initCompanion()
    self.MSL = 30
    self.table = __K2L_ReadOnlyMapOf(__K2L_Pair.new(State.CLOSED, __K2L_ReadOnlyMapOf(__K2L_Pair.new(Event.PassiveOpen, State.LISTEN), __K2L_Pair.new(Event.ActiveOpen, State.SYN_SENT))), __K2L_Pair.new(State.LISTEN, __K2L_ReadOnlyMapOf(__K2L_Pair.new(Event.Syn, State.SYN_RECEIVED), __K2L_Pair.new(Event.Close, State.CLOSED))), __K2L_Pair.new(State.SYN_SENT, __K2L_ReadOnlyMapOf(__K2L_Pair.new(Event.SynAck, State.ESTABLISHED), __K2L_Pair.new(Event.Close, State.CLOSED))), __K2L_Pair.new(State.SYN_RECEIVED, __K2L_ReadOnlyMapOf(__K2L_Pair.new(Event.Ack, State.ESTABLISHED), __K2L_Pair.new(Event.Close, State.FIN_WAIT_1))), __K2L_Pair.new(State.ESTABLISHED, __K2L_ReadOnlyMapOf(__K2L_Pair.new(Event.Close, State.FIN_WAIT_1), __K2L_Pair.new(Event.Fin, State.CLOSE_WAIT))), __K2L_Pair.new(State.FIN_WAIT_1, __K2L_ReadOnlyMapOf(__K2L_Pair.new(Event.Ack, State.FIN_WAIT_2), __K2L_Pair.new(Event.Fin, State.CLOSING))), __K2L_Pair.new(State.FIN_WAIT_2, __K2L_SingletonMapOf(__K2L_Pair.new(Event.Fin, State.TIME_WAIT))), __K2L_Pair.new(State.CLOSING, __K2L_SingletonMapOf(__K2L_Pair.new(Event.Ack, State.TIME_WAIT))), __K2L_Pair.new(State.CLOSE_WAIT, __K2L_SingletonMapOf(__K2L_Pair.new(Event.Close, State.LAST_ACK))), __K2L_Pair.new(State.LAST_ACK, __K2L_SingletonMapOf(__K2L_Pair.new(Event.Ack, State.CLOSED))))
end

__K2L_LazyObject(Connection, "____initCompanion")

local function parseEvents(script)
    local ____list = __K2L_StringSplit(script, ",")
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = __K2L_StringTrim(it)
    end
    local ____list_1 = __K2L_ListWrap(____out, ____count)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        if #it > 0 then
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = it
        end
    end
    local ____list_2 = __K2L_ListWrap(____out_1, ____count_1)
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_2, ____n_2 = ____list_2:____array()
    for ____i_2 = 1, ____n_2 do
        local tok = ____items_2[____i_2]
        local ____result
        do
            local name = __K2L_Text.substringBefore(tok, "(")
            local arg = __K2L_Text.removeSuffix(__K2L_Text.substringAfter(tok, "(", ""), ")")
            local ____subject = name:lower()
            if ____subject == "listen" then
                ____result = Event.PassiveOpen
            elseif ____subject == "open" then
                ____result = Event.ActiveOpen
            elseif ____subject == "syn" then
                ____result = Event.Syn
            elseif ____subject == "synack" then
                ____result = Event.SynAck
            elseif ____subject == "ack" then
                ____result = Event.Ack
            elseif ____subject == "fin" then
                ____result = Event.Fin
            elseif ____subject == "close" then
                ____result = Event.Close
            elseif ____subject == "rst" then
                ____result = Event.Reset
            elseif ____subject == "send" then
                ____result = Event.Send.new(__K2L_StringToInt(arg))
            elseif ____subject == "tick" then
                local ____value_2 = __K2L_StringToIntOrNull(arg)
                if ____value_2 == nil then
                    error(__K2L_IllegalArgumentException.new("tick needs a number, got '" .. arg .. "'"))
                end
                ____result = Event.Tick.new(____value_2)
            else
                error(__K2L_IllegalArgumentException.new("unknown event '" .. tok .. "'"))
            end
        end
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = ____result
    end
    return __K2L_ListWrap(____out_2, ____count_2)
end

local ____lambda_2 = function(it) return it.to.name end
local function runConnection(name, script)
    local c = Connection.new(name)
    local ____ok, ____result_1 = __K2L_DeepPcall(function()
        local ____list_3 = parseEvents(script)
        local ____mod = ____list_3.____modCount
        for ____i_3 = 1, ____list_3.size do
            local e = ____list_3[____i_3]
            c:fire(e)
            if ____list_3.____modCount ~= ____mod and ____list_3:____comodified(____i_3) then
                break
            end
        end
        print(name .. ": ended in " .. __K2L_Str(c.state) .. (c.state:getIsTerminal() and " (terminal)" or "") .. ", sent " .. c.sent .. " bytes")
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_1)
        if getmetatable(____error) == InvalidTransition then
            local e = ____error
            print(name .. ": " .. __K2L_Str(e.message) .. "; last good state " .. __K2L_Str(e.from) .. " after " .. c.history.size .. " steps")
        elseif __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
            local e = ____error
            print(name .. ": bad script: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    local ____list_4 = c.history
    local ____out_3 = {}
    local ____count_3 = 0
    local ____items_3, ____n_3 = ____list_4:____array()
    for ____i_4 = 1, ____n_3 do
        local it = ____items_3[____i_4]
        if it.from ~= it.to then
            ____count_3 = ____count_3 + 1
            ____out_3[____count_3] = it
        end
    end
    local path = __K2L_ListWrap(____out_3, ____count_3):joinToString(" -> ", "  path: CLOSED -> ", nil, nil, nil, ____lambda_2)
    local ____list_5 = c.history
    local ____result_2 = false
    local ____items_4, ____n_4 = ____list_5:____array()
    for ____i_5 = 1, ____n_4 do
        local it = ____items_4[____i_5]
        if it.from ~= it.to then
            ____result_2 = true
            break
        end
    end
    if ____result_2 then
        print(path)
    end
    print("  visited " .. __K2L_Str(c:visited()) .. " counts " .. __K2L_Str(c:visitCounts()))
end

local Coin = __K2L_Class("Coin")
__K2L_ClassInfo(Coin, "Coin", "Coin", "class")

function Coin:____init(name, ordinal, cents)
    self.name = name
    self.ordinal = ordinal
    self.cents = cents
end

function Coin:toString()
    return self.name
end

function Coin:compareTo(other)
    return self.ordinal - other.ordinal
end

Coin.NICKEL = Coin.new("NICKEL", 0, 5)
Coin.DIME = Coin.new("DIME", 1, 10)
Coin.QUARTER = Coin.new("QUARTER", 2, 25)
Coin.DOLLAR = Coin.new("DOLLAR", 3, 100)
Coin.____values = {Coin.NICKEL, Coin.DIME, Coin.QUARTER, Coin.DOLLAR}
local VendingMachine = __K2L_Class("VendingMachine")
__K2L_ClassInfo(VendingMachine, "VendingMachine", "VendingMachine", "class")

local ____lambda_3 = function(it) return it.value.first end
local ____lambda_4 = function(it) return it.value.second end
function VendingMachine:____init(stock)
    self.prices = stock:mapValues(____lambda_3)
    self.counts = stock:mapValues(____lambda_4):toMutableMap()
    self.credit = 0
    self.log = __K2L_StringBuilder.new()
    self.mode = VendingMachine.Mode.Idle
end

VendingMachine.Mode = __K2L_Class("VendingMachine$Mode")
__K2L_ClassInfo(VendingMachine.Mode, "VendingMachine.Mode", "VendingMachine$Mode", "class")
VendingMachine.Mode.Idle = __K2L_Class("VendingMachine$Mode$Idle", VendingMachine.Mode)
__K2L_ClassInfo(VendingMachine.Mode.Idle, "VendingMachine.Mode.Idle", "VendingMachine$Mode$Idle", "class")

function VendingMachine.Mode.Idle:toString()
    return "Idle"
end

VendingMachine.Mode.HasCredit = __K2L_Class("VendingMachine$Mode$HasCredit", VendingMachine.Mode)
__K2L_ClassInfo(VendingMachine.Mode.HasCredit, "VendingMachine.Mode.HasCredit", "VendingMachine$Mode$HasCredit", "class")

function VendingMachine.Mode.HasCredit:____init(cents)
    self.cents = cents
end

function VendingMachine.Mode.HasCredit.new(cents)
    return setmetatable({cents = cents}, VendingMachine.Mode.HasCredit)
end

function VendingMachine.Mode.HasCredit:toString()
    return "HasCredit(cents=" .. self.cents .. ")"
end

function VendingMachine.Mode.HasCredit:hashCode()
    return self.cents
end

function VendingMachine.Mode.HasCredit:equals(other)
    return getmetatable(other) == VendingMachine.Mode.HasCredit and self.cents == other.cents
end

VendingMachine.Mode.SoldOut = __K2L_Class("VendingMachine$Mode$SoldOut", VendingMachine.Mode)
__K2L_ClassInfo(VendingMachine.Mode.SoldOut, "VendingMachine.Mode.SoldOut", "VendingMachine$Mode$SoldOut", "class")

function VendingMachine.Mode.SoldOut:____init(item)
    self.item = item
end

function VendingMachine.Mode.SoldOut.new(item)
    return setmetatable({item = item}, VendingMachine.Mode.SoldOut)
end

function VendingMachine.Mode.SoldOut:toString()
    return "SoldOut(item=" .. self.item .. ")"
end

function VendingMachine.Mode.SoldOut:hashCode()
    return __K2L_Hash(self.item)
end

function VendingMachine.Mode.SoldOut:equals(other)
    return getmetatable(other) == VendingMachine.Mode.SoldOut and self.item == other.item
end

function VendingMachine:insert(c)
    self.credit = self.credit + c.cents
    self.mode = VendingMachine.Mode.HasCredit.new(self.credit)
    self.log:append("+" .. c.name:lower() .. " ")
end

local ____lambda_5 = function(it) return it.value .. "x" .. __K2L_Str(it.key) end
function VendingMachine:select(item)
    local ____value_3 = self.prices:get(item)
    if ____value_3 == nil then
        return "unknown item '" .. item .. "'"
    end
    local price = ____value_3
    local left = self.counts:getValue(item)
    if left == 0 then
        self.mode = VendingMachine.Mode.SoldOut.new(item)
        return item .. " sold out"
    elseif self.credit < price then
        return "insert " .. price - self.credit .. "c more for " .. item
    else
        local ____object_1 = self.counts
        ____object_1:set(item, left - 1)
        local change = self:makeChange(self.credit - price)
        self.credit = 0
        self.mode = VendingMachine.Mode.Idle
        self.log:append("[" .. item .. "] ")
        local ____temp
        if change:isEmpty() then
            ____temp = "none"
        else
            ____temp = change:getEntries():joinToString(nil, nil, nil, nil, nil, ____lambda_5)
        end
        return "vend " .. item .. ", change " .. ____temp
    end
end

function VendingMachine:makeChange(amount)
    local rest = amount
    local out = __K2L_MapOf()
    local ____list_6 = __K2L_EnumValues(Coin):reversed()
    local ____out_4 = {}
    local ____count_4 = 0
    local ____items_5, ____n_5 = ____list_6:____array()
    for ____i_6 = 1, ____n_5 do
        local it = ____items_5[____i_6]
        if it ~= Coin.DOLLAR then
            ____count_4 = ____count_4 + 1
            ____out_4[____count_4] = it
        end
    end
    local ____list_7 = __K2L_ListWrap(____out_4, ____count_4)
    local ____mod_1 = ____list_7.____modCount
    for ____i_7 = 1, ____list_7.size do
        local coin = ____list_7[____i_7]
        local n = __K2L_IDiv(rest, coin.cents)
        if n > 0 then
            out:set(coin, n)
            rest = rest - n * coin.cents
        end
        if ____list_7.____modCount ~= ____mod_1 and ____list_7:____comodified(____i_7) then
            break
        end
    end
    if rest ~= 0 then
        error(__K2L_IllegalStateException.new("cannot make change for " .. amount))
    end
    return out
end

function VendingMachine:refund()
    local ____value_4 = self.credit
    self.credit = 0
    self.mode = VendingMachine.Mode.Idle
    return ____value_4
end

local ____lambda_6 = function() return __K2L_EnumValueOf(State, "OPEN") end
local ____lambda_7 = function(it) return it.size > 1 end
local function main()
    runConnection("client", "open, synack, send(512), send(1024), close, ack, fin, tick(30), tick(29), tick(1)")
    runConnection("server", "listen, syn, ack, send(64), fin, send(8), close, ack")
    runConnection("simultaneous", "open, synack, close, fin, ack, tick(100)")
    runConnection("early-send", "listen, send(10)")
    runConnection("bad-ack", "open, ack")
    runConnection("reset", "open, synack, rst, listen, close")
    runConnection("typo", "open, synak")
    runConnection("tick", "open, tick(soon)")
    local ____arg = __K2L_EnumValueOf(State, "LISTEN").ordinal
    local ____values = State.____values
    local ____result_3 = 0
    for ____i_8 = 1, #____values do
        local it = ____values[____i_8]
        if it.canSend then
            ____result_3 = ____result_3 + 1
        end
    end
    print(__K2L_Str(__K2L_Pair.new(____arg, ____result_3)))
    local ____receiver_1 = __K2L_RunCatching(____lambda_6):exceptionOrNull()
    local ____receiver_2 = ____receiver_1 and __K2L_JavaClass(__K2L_KClassOfValue(____receiver_1))
    print(__K2L_Str(____receiver_2 and (____receiver_2.simpleName or "")))
    local ____values_1 = State.____values
    local ____result_4 = __K2L_Map.new()
    for ____i_9 = 1, #____values_1 do
        local it = ____values_1[____i_9]
        local ____value_5 = __K2L_Text.substringBefore(it.name, "_")
        local ____group = ____result_4:get(____value_5)
        if ____group == nil then
            ____group = __K2L_List.new()
            ____result_4:put(____value_5, ____group)
        end
        ____group:add(it)
    end
    local byPrefix = ____result_4:filterValues(____lambda_7)
    print(__K2L_Str(byPrefix))
    local vm = VendingMachine.new(__K2L_ReadOnlyMapOf(__K2L_Pair.new("cola", __K2L_Pair.new(125, 2)), __K2L_Pair.new("chips", __K2L_Pair.new(65, 1)), __K2L_Pair.new("gum", __K2L_Pair.new(35, 0))))
    local actions = __K2L_ReadOnlyListOf("Q", "Q", "cola", "D", "D", "D", "D", "D", "D", "D", "D", "D", "D", "D", "D", "cola", "gum", "chips", "$", "N", "chips", "chips", "Q", "nachos", "refund")
    local ____mod_2 = actions.____modCount
    for ____i_10 = 1, actions.size do
        local a = actions[____i_10]
        local result
        if a == "Q" then
            vm:insert(Coin.QUARTER)
            result = nil
        elseif a == "D" then
            vm:insert(Coin.DIME)
            result = nil
        elseif a == "N" then
            vm:insert(Coin.NICKEL)
            result = nil
        elseif a == "$" then
            vm:insert(Coin.DOLLAR)
            result = nil
        elseif a == "refund" then
            result = "refunded " .. vm:refund() .. "c"
        else
            result = vm:select(a)
        end
        if result ~= nil then
            print(a .. " -> " .. result .. "  [" .. __K2L_Str(vm.mode) .. "]")
        end
        if actions.____modCount ~= ____mod_2 and actions:____comodified(____i_10) then
            break
        end
    end
    print(__K2L_StringTrimEnd(vm.log:toString()))
end

__K2L_DeepMain(main)
return {State = State, Event = Event, InvalidTransition = InvalidTransition, Step = Step, Connection = Connection, parseEvents = parseEvents, runConnection = runConnection, Coin = Coin, VendingMachine = VendingMachine}
