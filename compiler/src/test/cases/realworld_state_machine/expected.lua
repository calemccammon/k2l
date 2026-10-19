local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_CompanionInfo = ____lualib.__K2L_CompanionInfo
local __K2L_EnumValueOf = ____lualib.__K2L_EnumValueOf
local __K2L_EnumValues = ____lualib.__K2L_EnumValues
local __K2L_FunInterface = ____lualib.__K2L_FunInterface
local __K2L_FunctionRef = ____lualib.__K2L_FunctionRef
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Event = __K2L_Class("machine.Event")
__K2L_ClassInfo(Event, "machine.Event", "machine.Event", "interface")
Event.Placed = __K2L_Class("machine.Event$Placed", nil, Event)
__K2L_ClassInfo(Event.Placed, "machine.Event.Placed", "machine.Event$Placed", "class")

function Event.Placed:____init(orderId, amount)
    self.orderId = orderId
    self.amount = amount
end

function Event.Placed:toString()
    return "Placed(orderId=" .. self.orderId .. ", amount=" .. __K2L_Str(self.amount) .. ")"
end

function Event.Placed:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.orderId) + __K2L_Hash(self.amount))
end

function Event.Placed:equals(other)
    return getmetatable(other) == Event.Placed and self.orderId == other.orderId and self.amount == other.amount
end

Event.Paid = __K2L_Class("machine.Event$Paid", nil, Event)
__K2L_ClassInfo(Event.Paid, "machine.Event.Paid", "machine.Event$Paid", "class")

function Event.Paid:____init(orderId, amount)
    self.orderId = orderId
    self.amount = amount
end

function Event.Paid:toString()
    return "Paid(orderId=" .. self.orderId .. ", amount=" .. __K2L_Str(self.amount) .. ")"
end

function Event.Paid:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.orderId) + __K2L_Hash(self.amount))
end

function Event.Paid:equals(other)
    return getmetatable(other) == Event.Paid and self.orderId == other.orderId and self.amount == other.amount
end

Event.Shipped = __K2L_Class("machine.Event$Shipped", nil, Event)
__K2L_ClassInfo(Event.Shipped, "machine.Event.Shipped", "machine.Event$Shipped", "class")

function Event.Shipped:____init(orderId, carrier)
    self.orderId = orderId
    self.carrier = carrier
end

function Event.Shipped:toString()
    return "Shipped(orderId=" .. self.orderId .. ", carrier=" .. self.carrier .. ")"
end

function Event.Shipped:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.orderId) + __K2L_Hash(self.carrier))
end

function Event.Shipped:equals(other)
    return getmetatable(other) == Event.Shipped and self.orderId == other.orderId and self.carrier == other.carrier
end

Event.Cancelled = __K2L_Class("machine.Event$Cancelled", nil, Event)
__K2L_ClassInfo(Event.Cancelled, "machine.Event.Cancelled", "machine.Event$Cancelled", "class")

function Event.Cancelled:____init(orderId, reason)
    self.orderId = orderId
    self.reason = reason
end

function Event.Cancelled:toString()
    return "Cancelled(orderId=" .. self.orderId .. ", reason=" .. self.reason .. ")"
end

function Event.Cancelled:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.orderId) + __K2L_Hash(self.reason))
end

function Event.Cancelled:equals(other)
    return getmetatable(other) == Event.Cancelled and self.orderId == other.orderId and self.reason == other.reason
end

Event.Delivered = __K2L_Class("machine.Event$Delivered", nil, Event)
__K2L_ClassInfo(Event.Delivered, "machine.Event.Delivered", "machine.Event$Delivered", "class")

function Event.Delivered:____init(orderId)
    self.orderId = orderId
end

function Event.Delivered:toString()
    return "Delivered(orderId=" .. self.orderId .. ")"
end

function Event.Delivered:hashCode()
    return __K2L_Hash(self.orderId)
end

function Event.Delivered:equals(other)
    return getmetatable(other) == Event.Delivered and self.orderId == other.orderId
end

local OrderState = __K2L_Class("machine.OrderState")
__K2L_ClassInfo(OrderState, "machine.OrderState", "machine.OrderState", "class")

function OrderState:____init(name, ordinal, terminal)
    if terminal == nil then
        terminal = false
    end
    self.name = name
    self.ordinal = ordinal
    self.terminal = terminal
end

function OrderState:getLabel()
    return __K2L_Text.replaceFirstChar(self.name:lower(), function(it) return it:upper() end)
end

function OrderState:toString()
    return self.name
end

function OrderState:compareTo(other)
    return self.ordinal - other.ordinal
end

do
    local ____NEW = __K2L_Class("OrderState", OrderState)
    __K2L_ClassInfo(____NEW, "machine.OrderState.NEW", "machine.OrderState$NEW", "class", "NEW")
    function ____NEW:next(event)
        if __K2L_InstanceOf(event, Event.Paid) then
            return OrderState.PAID
        elseif __K2L_InstanceOf(event, Event.Cancelled) then
            return OrderState.CANCELLED
        else
            return nil
        end
    end
    OrderState.NEW = ____NEW.new("NEW", 0)
end
do
    local ____PAID = __K2L_Class("OrderState", OrderState)
    __K2L_ClassInfo(____PAID, "machine.OrderState.PAID", "machine.OrderState$PAID", "class", "PAID")
    function ____PAID:next(event)
        if __K2L_InstanceOf(event, Event.Shipped) then
            return OrderState.SHIPPED
        elseif __K2L_InstanceOf(event, Event.Cancelled) then
            return OrderState.REFUNDED
        else
            return nil
        end
    end
    OrderState.PAID = ____PAID.new("PAID", 1)
end
do
    local ____SHIPPED = __K2L_Class("OrderState", OrderState)
    __K2L_ClassInfo(____SHIPPED, "machine.OrderState.SHIPPED", "machine.OrderState$SHIPPED", "class", "SHIPPED")
    function ____SHIPPED:next(event)
        return __K2L_InstanceOf(event, Event.Delivered) and OrderState.DELIVERED or nil
    end
    OrderState.SHIPPED = ____SHIPPED.new("SHIPPED", 2)
end
do
    local ____DELIVERED = __K2L_Class("OrderState", OrderState)
    __K2L_ClassInfo(____DELIVERED, "machine.OrderState.DELIVERED", "machine.OrderState$DELIVERED", "class", "DELIVERED")
    function ____DELIVERED:next(event)
        return nil
    end
    OrderState.DELIVERED = ____DELIVERED.new("DELIVERED", 3, true)
end
do
    local ____CANCELLED = __K2L_Class("OrderState", OrderState)
    __K2L_ClassInfo(____CANCELLED, "machine.OrderState.CANCELLED", "machine.OrderState$CANCELLED", "class", "CANCELLED")
    function ____CANCELLED:next(event)
        return nil
    end
    OrderState.CANCELLED = ____CANCELLED.new("CANCELLED", 4, true)
end
do
    local ____REFUNDED = __K2L_Class("OrderState", OrderState)
    __K2L_ClassInfo(____REFUNDED, "machine.OrderState.REFUNDED", "machine.OrderState$REFUNDED", "class", "REFUNDED")
    function ____REFUNDED:next(event)
        return nil
    end
    function ____REFUNDED:getLabel()
        return "refunded (money back)"
    end
    OrderState.REFUNDED = ____REFUNDED.new("REFUNDED", 5, true)
end
OrderState.____values = {OrderState.NEW, OrderState.PAID, OrderState.SHIPPED, OrderState.DELIVERED, OrderState.CANCELLED, OrderState.REFUNDED}
local Listener = __K2L_Class("machine.Listener")
__K2L_ClassInfo(Listener, "machine.Listener", "machine.Listener", "interface")
local IllegalTransition = __K2L_Class("machine.IllegalTransition", __K2L_IllegalStateException)
__K2L_ClassInfo(IllegalTransition, "machine.IllegalTransition", "machine.IllegalTransition", "class")

function IllegalTransition:____init(state, event)
    __K2L_IllegalStateException.____init(self, "cannot apply " .. __K2L_Str(__K2L_KClassOfValue(event).simpleName) .. " in state " .. __K2L_Str(state))
    self.state = state
    self.event = event
end

local EventBus = __K2L_Class("machine.EventBus")
__K2L_ClassInfo(EventBus, "machine.EventBus", "machine.EventBus", "class")

function EventBus:____init()
    self.listeners = __K2L_MapOf()
    self.history = __K2L_ArrayDeque.new()
    self.dispatched = 0
end

function EventBus:subscribe(topic, listener)
    self.listeners:getOrPut(topic, function() return __K2L_ListOf() end):add(listener)
    return function()
        local ____receiver = self.listeners:get(topic)
        if ____receiver ~= nil then
            ____receiver:remove(listener)
        end
    end
end

function EventBus:publish(event)
    self.dispatched = self.dispatched + 1
    self.history:addLast(event)
    if self.history.size > 4 then
        self.history:removeFirst()
    end
    local topic = __K2L_KClassOfValue(event).simpleName or "?"
    local ____list = (self.listeners:get(topic) or __K2L_ReadOnlyListOf()):plusAll(self.listeners:get("*") or __K2L_ReadOnlyListOf())
    local ____mod = ____list.____modCount
    for ____i = 1, ____list.size do
        local it = ____list[____i]
        it:onEvent(event)
        if ____list.____modCount ~= ____mod and ____list:____comodified(____i) then
            break
        end
    end
end

function EventBus:recent()
    return self.history:toList()
end

local Order = __K2L_Class("machine.Order")
__K2L_ClassInfo(Order, "machine.Order", "machine.Order", "class")
__K2L_CompanionInfo(Order, "machine.Order.Factory", "machine.Order$Factory", "Factory")

function Order:____init(id, amount)
    self.id = id
    self.amount = amount
    self.state = OrderState.NEW
    self.transitions = __K2L_ListOf()
end

function Order:getState()
    return self.state
end

function Order:setState(value)
    self.transitions:add(self.state.name .. "->" .. value.name)
    self.state = value
end

function Order:apply(event)
    if event.orderId ~= self.id then
        error(__K2L_IllegalArgumentException.new("event for order " .. event.orderId .. " sent to order " .. self.id))
    end
    if self:getState().terminal then
        error(__K2L_IllegalStateException.new("order " .. self.id .. " is closed (" .. self:getState():getLabel() .. ")"))
    end
    local ____value = self:getState():next(event)
    if ____value == nil then
        error(IllegalTransition.new(self:getState(), event))
    end
    self:setState(____value)
end

function Order:toString()
    return "Order#" .. self.id .. "[" .. __K2L_Str(self:getState()) .. ", " .. __K2L_StringFormat("%.2f", self.amount) .. "]"
end

function Order:create(amount)
    local ____old = self.nextId
    self.nextId = self.nextId + 1
    return Order.new(____old, amount)
end

function Order:getIssued()
    return self.nextId - 100
end

function Order:____initCompanion()
    self.nextId = 100
end

Order:____initCompanion()
local OrderRegistry = __K2L_Class("machine.OrderRegistry")
__K2L_ClassInfo(OrderRegistry, "machine.OrderRegistry", "machine.OrderRegistry", "class")

function OrderRegistry:____init()
    self.orders = __K2L_MapOf()
end

function OrderRegistry:getSize()
    return self.orders.size
end

function OrderRegistry:get(id)
    local ____value_1 = self.orders:get(id)
    if ____value_1 == nil then
        error(__K2L_NoSuchElementException.new("no order " .. id))
    end
    return ____value_1
end

function OrderRegistry:plusAssign(order)
    local ____object = self.orders
    local ____key = order.id
    ____object:set(____key, order)
end

function OrderRegistry:byState()
    return self.orders:getValues():groupBy(function(it) return it:getState() end, function(it) return it.id end):toSortedMap()
end

OrderRegistry:____init()
local Metrics = __K2L_Class("machine.Metrics")
__K2L_ClassInfo(Metrics, "machine.Metrics", "machine.Metrics", "interface")
local Processor = __K2L_Class("machine.Processor", nil, Metrics)
__K2L_ClassInfo(Processor, "machine.Processor", "machine.Processor", "class")

function Processor:____init(bus, metrics)
    self.bus = bus
    self.____delegate_Metrics = metrics
    self.failures = __K2L_ListOf()
    local ____result
    do
        local ____this = self.bus
        local handler = function(e)
            local order = Order:create(e.amount)
            OrderRegistry:plusAssign(order)
            self:count("placed")
        end
        ____result = ____this:subscribe("*", __K2L_FunInterface(Listener, "onEvent", function(it)
            if __K2L_InstanceOf(it, Event.Placed) then
                handler(it)
            end
        end))
    end
end

function Processor:handle(event)
    self.bus:publish(event)
    if __K2L_InstanceOf(event, Event.Placed) then
        return
    end
    local ____ok, ____result_1 = pcall(function()
        OrderRegistry:get(event.orderId):apply(event)
        self:count(__K2L_NotNull(__K2L_KClassOfValue(event).simpleName):lower())
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error, IllegalTransition) then
            local e = ____error
            self.failures:add("transition: " .. __K2L_Str(e.message) .. " (from " .. e.state:getLabel() .. ")")
        elseif __K2L_InstanceOf(____error, __K2L_IllegalStateException) then
            local e = ____error
            self.failures:add("state: " .. __K2L_Str(e.message))
        elseif __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
            local e = ____error
            self.failures:add("argument: " .. __K2L_Str(e.message))
        elseif __K2L_InstanceOf(____error, __K2L_NoSuchElementException) then
            local e = ____error
            self.failures:add("lookup: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
end

function Processor:failures__1()
    return self.failures
end

function Processor:count(...)
    return self.____delegate_Metrics:count(...)
end

function Processor:report(...)
    return self.____delegate_Metrics:report(...)
end

local function main()
    local bus = EventBus.new()
    local log = __K2L_ListOf()
    local counts = __K2L_SortedMapOf()
    local ____object_1 = __K2L_Class("machine.MainKt$main$metrics$1", nil, Metrics)
    __K2L_ClassInfo(____object_1, nil, "machine.MainKt$main$metrics$1", "class", false)
    function ____object_1:count(name)
        counts:merge(name, 1, __K2L_FunctionRef.new("plus", "kotlin/Int.plus(kotlin.Int)", function(____p1, ____p2) return ____p1 + ____p2 end))
    end
    function ____object_1:report()
        return counts:getEntries():joinToString(", ", nil, nil, nil, nil, function(it)
            return __K2L_Str(it.key) .. "=" .. __K2L_Str(it.value)
        end)
    end
    local metrics = ____object_1
    local processor = Processor.new(bus, metrics)
    local unsubscribe = bus:subscribe("Paid", __K2L_FunInterface(Listener, "onEvent", function(it)
        log:add("paid " .. it.orderId)
    end))
    local ____result_2
    do
        local handler = function(it)
            log:add("shipped " .. it.orderId .. " via " .. it.carrier)
        end
        ____result_2 = bus:subscribe("*", __K2L_FunInterface(Listener, "onEvent", function(it)
            if __K2L_InstanceOf(it, Event.Shipped) then
                handler(it)
            end
        end))
    end
    local cancellations = 0
    local ____object_2 = __K2L_Class("machine.MainKt$main$2", nil, Listener)
    __K2L_ClassInfo(____object_2, nil, "machine.MainKt$main$2", "class", false)
    function ____object_2:onEvent(event)
        cancellations = cancellations + 1
        local ____arg = cancellations
        if not __K2L_InstanceOf(event, Event.Cancelled) then
            __K2L_CastFail(event, "machine.Event$Cancelled", "machine.Event.Cancelled")
        end
        log:add("cancelled #" .. ____arg .. ": " .. event.reason)
    end
    bus:subscribe("Cancelled", ____object_2)
    local script = __K2L_ReadOnlyListOf(Event.Placed.new(0, 25.0), Event.Placed.new(0, 99.5), Event.Placed.new(0, 7.25), Event.Paid.new(100, 25.0), Event.Shipped.new(100, "UPS"), Event.Delivered.new(100), Event.Paid.new(101, 99.5), Event.Cancelled.new(101, "changed mind"), Event.Delivered.new(102), Event.Cancelled.new(102, "out of stock"), Event.Paid.new(102, 7.25), Event.Paid.new(999, 1.0))
    for step = 0, script.size - 1 do
        local event = script[step + 1]
        if step == 7 then
            unsubscribe()
        end
        processor:handle(event)
    end
    local ____mod_1 = log.____modCount
    for ____i_1 = 1, log.size do
        local it = log[____i_1];
        (function(____p1) return print(__K2L_Str(____p1)) end)(it)
        if log.____modCount ~= ____mod_1 and log:____comodified(____i_1) then
            break
        end
    end
    local ____list_1 = processor:failures__1()
    for ____i_2 = 1, ____list_1.size do
        local it = ____list_1[____i_2]
        print("! " .. it)
    end
    print(processor:report())
    for id = 100, 102 do
        local order = OrderRegistry:get(id)
        print(__K2L_Str(order) .. " " .. order:getState():getLabel() .. ": " .. order.transitions:joinToString(" "))
    end
    print(__K2L_Str(OrderRegistry:byState()))
    print("issued=" .. Order:getIssued() .. " registry=" .. OrderRegistry:getSize() .. " dispatched=" .. bus.dispatched)
    print(__K2L_Str(bus:recent():map(function(it) return __K2L_KClassOfValue(it).simpleName end)))
    print(__K2L_EnumValues(OrderState):filter(function(it) return it.terminal end):joinToString(nil, nil, nil, nil, nil, function(it) return it:getLabel() end))
    print(__K2L_Str(__K2L_EnumValueOf(OrderState, "PAID"):next(Event.Shipped.new(1, "DHL"))))
    local sameEvents = __K2L_ReadOnlySetOf(Event.Paid.new(1, 2.0), Event.Paid.new(1, 2.0), Event.Delivered.new(1))
    print(sameEvents.size)
    local describe = function(e)
        if __K2L_InstanceOf(e, Event.Placed) or __K2L_InstanceOf(e, Event.Paid) then
            return "money"
        elseif __K2L_InstanceOf(e, Event.Shipped) then
            return "carrier " .. e.carrier
        else
            return "other"
        end
    end
    print(__K2L_Str(script:take(5):map(describe):distinct()))
end

main()
return {Event = Event, OrderState = OrderState, Listener = Listener, IllegalTransition = IllegalTransition, EventBus = EventBus, Order = Order, OrderRegistry = OrderRegistry, Metrics = Metrics, Processor = Processor}
