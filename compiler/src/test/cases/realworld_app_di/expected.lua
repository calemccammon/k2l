-- ==== core/Container.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Container, ChildContainer
local Provider = __K2L_Class("app.di.core.Provider")
__K2L_ClassInfo(Provider, "app.di.core.Provider", "app.di.core.Provider", "interface")
local Scope = __K2L_Class("app.di.core.Scope")
__K2L_ClassInfo(Scope, "app.di.core.Scope", "app.di.core.Scope", "class")

function Scope:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Scope:toString()
    return self.name
end

function Scope:compareTo(other)
    return self.ordinal - other.ordinal
end

Scope.SINGLETON = Scope.new("SINGLETON", 0)
Scope.PROTOTYPE = Scope.new("PROTOTYPE", 1)
Scope.SCOPED = Scope.new("SCOPED", 2)
Scope.____values = {Scope.SINGLETON, Scope.PROTOTYPE, Scope.SCOPED}
local ResolutionException = __K2L_Class("app.di.core.ResolutionException", __K2L_RuntimeException)
__K2L_ClassInfo(ResolutionException, "app.di.core.ResolutionException", "app.di.core.ResolutionException", "class")

function ResolutionException:____init(message, chain)
    __K2L_RuntimeException.____init(self, message)
    self.chain = chain
end

local Binding = __K2L_Class("app.di.core.Binding")
__K2L_ClassInfo(Binding, "app.di.core.Binding", "app.di.core.Binding", "class")

function Binding:____init(____type, scope, qualifier, factory)
    self.type = ____type
    self.scope = scope
    self.qualifier = qualifier
    self.factory = factory
    self.cached = nil
    self.created = 0
end

function Binding:create(container)
    self.created = self.created + 1
    return self.factory(container)
end

function Binding:toString()
    local ____receiver = self.qualifier
    return "Binding(" .. __K2L_Str(self.type.simpleName) .. (____receiver and "@" .. ____receiver or "") .. ", " .. __K2L_Str(self.scope) .. ")"
end

local Key = __K2L_Class("app.di.core.Key")
__K2L_ClassInfo(Key, "app.di.core.Key", "app.di.core.Key", "class")

function Key:____init(____type, qualifier)
    self.type = ____type
    self.qualifier = qualifier
end

function Key.new(____type, qualifier)
    return setmetatable({type = ____type, qualifier = qualifier}, Key)
end

function Key:toString()
    local ____arg = self.type.simpleName or "?"
    local ____receiver_1 = self.qualifier
    return ____arg .. (____receiver_1 and "#" .. ____receiver_1 or "")
end

function Key:hashCode()
    return (31 * __K2L_Hash(self.type) + __K2L_Hash(self.qualifier) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Key:equals(other)
    return getmetatable(other) == Key and __K2L_Equals(self.type, other.type) and self.qualifier == other.qualifier
end

Container = __K2L_Class("app.di.core.Container")
__K2L_ClassInfo(Container, "app.di.core.Container", "app.di.core.Container", "class")

function Container:____init(parent, name)
    self.parent = parent
    self.name = name
    self.bindings = __K2L_MapOf()
    self.scopedCache = __K2L_MapOf()
    self.resolving = __K2L_ArrayDeque.new()
    self.log = __K2L_ListOf()
end

function Container:____init1(name)
    if name == nil then
        name = "root"
    end
    Container.____init(self, nil, name)
end

function Container.new1(name)
    local self = setmetatable({}, Container)
    self:____init1(name)
    return self
end

function Container:register(____type, scope, qualifier, factory)
    if qualifier == nil then
        qualifier = nil
    end
    local key = Key.new(____type, qualifier)
    if self.bindings:containsKey(key) then
        error(__K2L_IllegalArgumentException.new("duplicate binding for " .. __K2L_Str(key) .. " in " .. self.name))
    end
    local ____object = self.bindings
    ____object:set(key, Binding.new(____type, scope, qualifier, factory))
    self:onRegister(key)
end

function Container:onRegister(key)
    self.log:add("register " .. __K2L_Str(key))
end

function Container:resolve(____type, qualifier)
    if qualifier == nil then
        qualifier = nil
    end
    local key = Key.new(____type, qualifier)
    if self.resolving:contains(key) then
        local ____list = self.resolving
        local ____out = {}
        local ____count = 0
        local ____items, ____n = ____list:____array()
        for ____i = 1, ____n do
            local it = ____items[____i]
            ____count = ____count + 1
            ____out[____count] = it:toString()
        end
        local chain = __K2L_ListWrap(____out, ____count):plus(key:toString())
        error(ResolutionException.new("cycle: " .. chain:joinToString(" -> "), chain))
    end
    self.resolving:addLast(key)
    local ____ok, ____result, ____returned = pcall(function()
        local ____value = self:lookup(key, self)
        if ____value == nil then
            local ____arg_1 = "no binding for " .. __K2L_Str(key) .. " in " .. self.name
            local ____list_1 = self.resolving
            local ____out_1 = {}
            local ____count_1 = 0
            local ____items_1, ____n_1 = ____list_1:____array()
            for ____i_1 = 1, ____n_1 do
                local it = ____items_1[____i_1]
                ____count_1 = ____count_1 + 1
                ____out_1[____count_1] = it:toString()
            end
            error(ResolutionException.new(____arg_1, __K2L_ListWrap(____out_1, ____count_1)))
        end
        return true, ____value
    end)
    self.resolving:removeLast()
    if not ____ok then
        error(____result, 0)
    end
    if ____result then
        return ____returned
    end
end

function Container:lookup(key, requester)
    local ____cast = self.bindings:get(key)
    if not (____cast == nil or getmetatable(____cast) == Binding) then
        __K2L_CastFail(____cast, "app.di.core.Binding", "app.di.core.Binding")
    end
    local binding = ____cast
    if binding == nil then
        local ____receiver_2 = self.parent
        return ____receiver_2 and ____receiver_2:lookup(key, requester)
    end
    local value
    local ____subject = binding.scope
    if ____subject == Scope.SINGLETON then
        local ____value_2 = binding.cached
        if ____value_2 == nil then
            local ____value_1 = binding:create(self)
            binding.cached = ____value_1
            ____value_2 = ____value_1
        end
        value = ____value_2
    elseif ____subject == Scope.PROTOTYPE then
        value = binding:create(requester)
    elseif ____subject == Scope.SCOPED then
        value = requester.scopedCache:getOrPut(key, function() return binding:create(requester) end)
    end
    return value
end

function Container:child(name)
    return ChildContainer.new(self, name)
end

function Container:describe()
    local ____list_2 = self.bindings:getValues()
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_2, ____n_2 = ____list_2:____array()
    for ____i_2 = 1, ____n_2 do
        local it = ____items_2[____i_2]
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = it:toString()
    end
    local ____arg_2 = __K2L_ListWrap(____out_2, ____count_2)
    local ____receiver_3 = self.parent
    local ____receiver_4 = ____receiver_3 and ____receiver_3:describe()
    local ____result_1
    if ____receiver_4 ~= nil then
        local ____out_3 = {}
        local ____count_3 = 0
        local ____items_3, ____n_3 = ____receiver_4:____array()
        for ____i_3 = 1, ____n_3 do
            local it = ____items_3[____i_3]
            ____count_3 = ____count_3 + 1
            ____out_3[____count_3] = "  ^ " .. it
        end
        ____result_1 = __K2L_ListWrap(____out_3, ____count_3)
    end
    return ____arg_2:plusAll(____result_1 or __K2L_ReadOnlyListOf())
end

function Container:creations()
    return self.bindings:getEntries():associate(function(____destructured)
        local k, v = ____destructured.key, ____destructured.value
        return __K2L_Pair.new(k:toString(), v.created)
    end)
end

function Container:history()
    return self.log:toList()
end

ChildContainer = __K2L_Class("app.di.core.ChildContainer", Container)
__K2L_ClassInfo(ChildContainer, "app.di.core.ChildContainer", "app.di.core.ChildContainer", "class")

function ChildContainer:____init(parent, name)
    Container.____init(self, parent, name)
end

function ChildContainer:onRegister(key)
    self.log:add("[" .. self.name .. "] register " .. __K2L_Str(key))
end

return {Provider = Provider, Scope = Scope, ResolutionException = ResolutionException, Binding = Binding, Key = Key, Container = Container}
-- ==== events/EventBus.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_FunctionMixin = ____lualib.__K2L_FunctionMixin
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Event = __K2L_Class("app.di.events.Event")
__K2L_ClassInfo(Event, "app.di.events.Event", "app.di.events.Event", "interface")
local UserCreated = __K2L_Class("app.di.events.UserCreated", nil, Event)
__K2L_ClassInfo(UserCreated, "app.di.events.UserCreated", "app.di.events.UserCreated", "class")

function UserCreated:____init(source, user)
    self.source = source
    self.user = user
end

function UserCreated.new(source, user)
    return setmetatable({source = source, user = user}, UserCreated)
end

function UserCreated:getSource()
    return self.source
end

function UserCreated:toString()
    return "UserCreated(source=" .. self.source .. ", user=" .. self.user .. ")"
end

function UserCreated:hashCode()
    return (31 * __K2L_Hash(self.source) + __K2L_Hash(self.user) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function UserCreated:equals(other)
    return getmetatable(other) == UserCreated and self.source == other.source and self.user == other.user
end

local UserDeleted = __K2L_Class("app.di.events.UserDeleted", nil, Event)
__K2L_ClassInfo(UserDeleted, "app.di.events.UserDeleted", "app.di.events.UserDeleted", "class")

function UserDeleted:____init(source, user, reason)
    if reason == nil then
        reason = "unspecified"
    end
    self.source__UserDeleted = source
    self.user = user
    self.reason = reason
end

function UserDeleted:getSource()
    return self.source__UserDeleted or "null"
end

function UserDeleted:toString()
    return "UserDeleted(source=" .. self.source .. ", user=" .. self.user .. ", reason=" .. self.reason .. ")"
end

function UserDeleted:hashCode()
    return (31 * (31 * __K2L_Hash(self.source) + __K2L_Hash(self.user)) + __K2L_Hash(self.reason) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function UserDeleted:equals(other)
    return getmetatable(other) == UserDeleted and self.source == other.source and self.user == other.user and self.reason == other.reason
end

local OrderPlaced = __K2L_Class("app.di.events.OrderPlaced", nil, Event)
__K2L_ClassInfo(OrderPlaced, "app.di.events.OrderPlaced", "app.di.events.OrderPlaced", "class")

function OrderPlaced:____init(source, orderId, total)
    self.source__OrderPlaced = source
    self.orderId = orderId
    self.total = total
end

function OrderPlaced.new(source, orderId, total)
    return setmetatable({source__OrderPlaced = source, orderId = orderId, total = total}, OrderPlaced)
end

function OrderPlaced:getSource()
    return self.source__OrderPlaced or "null"
end

function OrderPlaced:toString()
    return "OrderPlaced(source=" .. self.source .. ", orderId=" .. self.orderId .. ", total=" .. __K2L_Str(self.total) .. ")"
end

function OrderPlaced:hashCode()
    return (31 * (31 * __K2L_Hash(self.source) + self.orderId) + __K2L_Hash(self.total) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function OrderPlaced:equals(other)
    return getmetatable(other) == OrderPlaced and self.source == other.source and self.orderId == other.orderId and self.total == other.total
end

local Shutdown = __K2L_Class("app.di.events.Shutdown", nil, Event)
__K2L_ClassInfo(Shutdown, "app.di.events.Shutdown", "app.di.events.Shutdown", "class")

function Shutdown:____init()
    self.source__Shutdown = "system"
end

function Shutdown:getSource()
    return self.source__Shutdown or "null"
end

function Shutdown:toString()
    return "Shutdown"
end

Shutdown:____init()
local Delivery = __K2L_Class("app.di.events.Delivery")
__K2L_ClassInfo(Delivery, "app.di.events.Delivery", "app.di.events.Delivery", "class")
Delivery.Delivered = __K2L_Class("app.di.events.Delivery$Delivered", Delivery)
__K2L_ClassInfo(Delivery.Delivered, "app.di.events.Delivery.Delivered", "app.di.events.Delivery$Delivered", "class")

function Delivery.Delivered:____init(handlers)
    self.handlers = handlers
end

function Delivery.Delivered.new(handlers)
    return setmetatable({handlers = handlers}, Delivery.Delivered)
end

function Delivery.Delivered:toString()
    return "Delivered(handlers=" .. self.handlers .. ")"
end

function Delivery.Delivered:hashCode()
    return self.handlers
end

function Delivery.Delivered:equals(other)
    return getmetatable(other) == Delivery.Delivered and self.handlers == other.handlers
end

Delivery.Failed = __K2L_Class("app.di.events.Delivery$Failed", Delivery)
__K2L_ClassInfo(Delivery.Failed, "app.di.events.Delivery.Failed", "app.di.events.Delivery$Failed", "class")

function Delivery.Failed:____init(errors)
    self.errors = errors
end

function Delivery.Failed.new(errors)
    return setmetatable({errors = errors}, Delivery.Failed)
end

function Delivery.Failed:toString()
    return "Failed(errors=" .. __K2L_Str(self.errors) .. ")"
end

function Delivery.Failed:hashCode()
    return __K2L_Hash(self.errors)
end

function Delivery.Failed:equals(other)
    return getmetatable(other) == Delivery.Failed and __K2L_Equals(self.errors, other.errors)
end

Delivery.Dropped = __K2L_Class("app.di.events.Delivery$Dropped", Delivery)
__K2L_ClassInfo(Delivery.Dropped, "app.di.events.Delivery.Dropped", "app.di.events.Delivery$Dropped", "class")

function Delivery.Dropped:toString()
    return "Dropped"
end

local Subscription = __K2L_Class("app.di.events.Subscription")
__K2L_ClassInfo(Subscription, "app.di.events.Subscription", "app.di.events.Subscription", "class")

function Subscription:____init(onCancel)
    self.onCancel = onCancel
    self.active = true
end

function Subscription:cancel()
    if self.active then
        self.active = false
        self.onCancel()
    end
end

local EventBus = __K2L_Class("app.di.events.EventBus")
__K2L_ClassInfo(EventBus, "app.di.events.EventBus", "app.di.events.EventBus", "class")

function EventBus:____init()
    self.handlers = __K2L_MapOf()
    self.deadLetters = __K2L_ListOf()
    self.published = 0
end

local ____lambda_1 = function() return __K2L_ListOf() end
function EventBus:subscribe(____type, handler)
    if not (type(handler) == "function" or __K2L_InstanceOf(handler, __K2L_FunctionMixin)) then
        __K2L_CastFail(handler, "java.lang.Function1", "kotlin.Function1")
    end
    local h = handler
    local list = self.handlers:getOrPut(____type, ____lambda_1)
    list:add(h)
    return Subscription.new(function()
        list:remove(h)
    end)
end

function EventBus:publish(event)
    self.published = self.published + 1
    local targets = (self.handlers:get(__K2L_KClassOfValue(event)) or __K2L_ReadOnlyListOf()):toList()
    if targets:isEmpty() then
        self.deadLetters:add(event)
        return Delivery.Dropped
    end
    local errors = __K2L_ListOf()
    local ____mod = targets.____modCount
    for ____i = 1, targets.size do
        local h = targets[____i]
        local ____ok, ____result = pcall(function()
            h(event)
        end)
        if not ____ok then
            local ____error = __K2L_ToThrowable(____result)
            if __K2L_InstanceOf(____error, __K2L_IllegalStateException) then
                local e = ____error
                errors:add(__K2L_Str(__K2L_KClassOfValue(e).simpleName) .. ": " .. __K2L_Str(e.message))
            else
                error(____error, 0)
            end
        end
        if targets.____modCount ~= ____mod and targets:____comodified(____i) then
            break
        end
    end
    return errors:isEmpty() and Delivery.Delivered.new(targets.size) or Delivery.Failed.new(errors)
end

function EventBus:getDead()
    return self.deadLetters
end

function EventBus:subscriberCounts()
    return self.handlers:map(function(____destructured)
        local k, v = ____destructured.key, ____destructured.value
        return __K2L_Pair.new(k.simpleName or "?", v.size)
    end):toMap()
end

return {Event = Event, UserCreated = UserCreated, UserDeleted = UserDeleted, OrderPlaced = OrderPlaced, Shutdown = Shutdown, Delivery = Delivery, Subscription = Subscription, EventBus = EventBus}
-- ==== main.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_FunInterface = ____lualib.__K2L_FunInterface
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_KClassNamed = ____lualib.__K2L_KClassNamed
local __K2L_KClassOf = ____lualib.__K2L_KClassOf
local __K2L_Lazy = ____lualib.__K2L_Lazy
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local ____EventBus = require("events.EventBus")
local ____Container = require("core.Container")
local ____Services = require("services.Services")
local B
local A = __K2L_Class("app.di.A")
__K2L_ClassInfo(A, "app.di.A", "app.di.A", "class")

function A:____init(b)
    self.b = b
end

function A.new(b)
    return setmetatable({b = b}, A)
end

B = __K2L_Class("app.di.B")
__K2L_ClassInfo(B, "app.di.B", "app.di.B", "class")

function B:____init(a, eager)
    self.a = a
    self.eager = eager
    if self.eager then
        self.a:get()
    end
end

local Audit = __K2L_Class("app.di.Audit")
__K2L_ClassInfo(Audit, "app.di.Audit", "app.di.Audit", "class")

function Audit:____init(bus)
    self.entries = __K2L_ListOf()
    self.subs = __K2L_ListOf()
    local ____arg = self.subs
    local ____result
    do
        local handler = function(it)
            self.entries:add("created " .. it.user .. " via " .. it:getSource())
        end
        ____result = bus:subscribe(__K2L_KClassOf(____EventBus.UserCreated), handler)
    end
    ____arg:add(____result)
    local ____arg_1 = self.subs
    local ____result_1
    do
        local handler = function(it)
            self.entries:add("deleted " .. it.user .. " (" .. it.reason .. ")")
        end
        ____result_1 = bus:subscribe(__K2L_KClassOf(____EventBus.UserDeleted), handler)
    end
    ____arg_1:add(____result_1)
    local ____arg_2 = self.subs
    local ____result_2
    do
        local handler = function(e)
            if not (e.total < 1000.0) then
                error(__K2L_IllegalStateException.new("order " .. e.orderId .. " too large: " .. __K2L_Str(e.total)))
            end
            self.entries:add("order " .. e.orderId .. " = " .. __K2L_Str(e.total))
        end
        ____result_2 = bus:subscribe(__K2L_KClassOf(____EventBus.OrderPlaced), handler)
    end
    ____arg_2:add(____result_2)
end

local ____lambda_1 = function(self, ...) return self:cancel(...) end
function Audit:stop()
    local ____list = self.subs
    local ____mod = ____list.____modCount
    for ____i = 1, ____list.size do
        local it = ____list[____i];
        (____lambda_1)(it)
        if ____list.____modCount ~= ____mod and ____list:____comodified(____i) then
            break
        end
    end
end

local function describe(d)
    local ____mt = getmetatable(d)
    if ____mt == ____EventBus.Delivery.Delivered then
        return "delivered to " .. d.handlers
    elseif ____mt == ____EventBus.Delivery.Failed then
        return "failed: " .. d.errors:joinToString("; ")
    elseif __K2L_Equals(d, ____EventBus.Delivery.Dropped) then
        return "dropped"
    end
end

local ____lambda_2 = function(self) return ____Services.FakeClock.new() end
local ____lambda_3 = function(____this_2) return ____EventBus.EventBus.new() end
local ____lambda_4 = function(____this_4)
    return ____Services.RequestId:next()
end
local function buildContainer()
    local ____value = ____Container.Container.new1("app")
    do
        local factory = ____lambda_2
        ____value:register(__K2L_KClassOf(____Services.Clock), ____Container.Scope.SINGLETON, nil, factory)
    end
    do
        local factory = function(____this)
            local ____result_3
            ____result_3 = ____this:resolve(__K2L_KClassOf(____Services.Clock), nil)
            return ____Services.ConsoleLogger.new(____result_3)
        end
        ____value:register(__K2L_KClassOf(____Services.Logger), ____Container.Scope.SINGLETON, nil, factory)
    end
    do
        local factory = function(____this_1)
            local ____result_4
            ____result_4 = ____this_1:resolve(__K2L_KClassOf(____Services.Clock), nil)
            return ____Services.ConsoleLogger.new(____result_4, "audit")
        end
        ____value:register(__K2L_KClassOf(____Services.Logger), ____Container.Scope.SINGLETON, "audit", factory)
    end
    do
        local factory = ____lambda_3
        ____value:register(__K2L_KClassOf(____EventBus.EventBus), ____Container.Scope.SINGLETON, nil, factory)
    end
    do
        local factory = function(____this_3)
            local ____result_5
            ____result_5 = ____this_3:resolve(__K2L_KClassOf(____Services.Logger), nil)
            return ____Services.UserRepository.new(____result_5)
        end
        ____value:register(__K2L_KClassOf(____Services.UserRepository), ____Container.Scope.SINGLETON, nil, factory)
    end
    do
        local ____factory = ____lambda_4
        ____value:register(__K2L_KClassOf(____Services.RequestId), ____Container.Scope.PROTOTYPE, nil, ____factory)
    end
    do
        local factory = function(____this_5)
            local ____result_6
            ____result_6 = ____this_5:resolve(__K2L_KClassOf(____Services.UserRepository), nil)
            local ____arg_3 = ____result_6
            local ____result_7
            ____result_7 = ____this_5:resolve(__K2L_KClassOf(____EventBus.EventBus), nil)
            local ____arg_4 = ____result_7
            local ____result_8
            ____result_8 = __K2L_FunInterface(____Container.Provider, "get", function()
                local ____result_9
                ____result_9 = ____this_5:resolve(__K2L_KClassOf(____Services.RequestId), nil)
                return ____result_9
            end)
            return ____Services.UserService.new(____arg_3, ____arg_4, ____result_8)
        end
        ____value:register(__K2L_KClassOf(____Services.UserService), ____Container.Scope.SINGLETON, nil, factory)
    end
    do
        local factory = function(____this_6)
            local ____result_10
            ____result_10 = ____this_6:resolve(__K2L_KClassOf(____EventBus.EventBus), nil)
            local ____arg_5 = ____result_10
            local ____result_11
            ____result_11 = ____this_6:resolve(__K2L_KClassOf(____Services.Logger), "audit")
            return ____Services.OrderService.new(____arg_5, ____result_11)
        end
        ____value:register(__K2L_KClassOf(____Services.OrderService), ____Container.Scope.SINGLETON, nil, factory)
    end
    do
        local factory = function(____this_7)
            local ____result_12
            ____result_12 = ____this_7:resolve(__K2L_KClassOf(____EventBus.EventBus), nil)
            return Audit.new(____result_12)
        end
        ____value:register(__K2L_KClassOf(Audit), ____Container.Scope.SINGLETON, nil, factory)
    end
    return ____value
end

local ____lambda_5 = function(x)
    return getmetatable(x) == ____EventBus.UserCreated
end
local ____lambda_6 = function(x)
    return __K2L_InstanceOf(x, ____EventBus.Event)
end
local ____lambda_7 = function(____this_8)
    return ____Services.Session.new("anon")
end
local ____lambda_8 = function(____this_9)
    return ____Services.Session.new("ada")
end
local ____lambda_9 = function(____this_14) return ____EventBus.EventBus.new() end
local function main()
    local root = buildContainer()
    print("== bindings")
    local ____list_1 = root:describe()
    for ____i_1 = 1, ____list_1.size do
        local it = ____list_1[____i_1]
        print("  " .. it)
    end
    local ____result_13
    ____result_13 = root:resolve(__K2L_KClassOf(Audit), nil)
    local audit = ____result_13
    local ____result_14
    ____result_14 = root:resolve(__K2L_KClassOf(____Services.UserService), nil)
    local users = ____result_14
    local ____result_15
    ____result_15 = root:resolve(__K2L_KClassOf(____Services.OrderService), nil)
    local orders = ____result_15
    local ____result_16
    ____result_16 = root:resolve(__K2L_KClassOf(____Services.Logger), nil)
    local ____arg_6 = ____result_16
    local ____result_17
    ____result_17 = root:resolve(__K2L_KClassOf(____Services.Logger), nil)
    local ____arg_8 = ____arg_6 == ____result_17
    local ____result_18
    ____result_18 = root:resolve(__K2L_KClassOf(____Services.Logger), nil)
    local ____arg_7 = ____result_18
    local ____result_19
    ____result_19 = root:resolve(__K2L_KClassOf(____Services.Logger), "audit")
    print("same logger: " .. tostring(____arg_8) .. ", audit logger differs: " .. tostring(____arg_7 ~= ____result_19))
    print("== users")
    local ____list_2 = __K2L_ReadOnlyListOf("ada", "grace", "linus")
    for ____i_2 = 1, ____list_2.size do
        local name = ____list_2[____i_2]
        print("  " .. name .. " -> " .. users:create(name))
    end
    local ____ok, ____result_20 = pcall(function()
        users:create("ada")
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_20)
        if __K2L_InstanceOf(____error, __K2L_IllegalStateException) then
            local e = ____error
            print("  error: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    users:delete("grace", "requested")
    users:delete("linus")
    users:delete("nobody")
    local ____result_21
    ____result_21 = root:resolve(__K2L_KClassOf(____Services.UserRepository), nil)
    print("  repo: " .. __K2L_Str(____result_21:all()))
    print("== orders")
    local ____result_22
    ____result_22 = root:resolve(__K2L_KClassOf(____EventBus.EventBus), nil)
    local bus = ____result_22
    print("  " .. orders:place(9.5, 20.25))
    print("  " .. orders:place(999.0, 1.5))
    local ____ok_1, ____result_23 = pcall(function()
        orders:place()
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_23)
        if __K2L_InstanceOf(____error_1, __K2L_IllegalArgumentException) then
            local e = ____error_1
            print("  error: " .. __K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
    print("  direct: " .. describe(bus:publish(____EventBus.OrderPlaced.new("manual", 7, 12.0))))
    print("  overflow: " .. describe(bus:publish(____EventBus.OrderPlaced.new("manual", 8, 4000.0))))
    print("  shutdown: " .. describe(bus:publish(____EventBus.Shutdown)))
    audit:stop()
    print("  after stop: " .. describe(bus:publish(____EventBus.UserCreated.new("x", "y"))))
    local ____result_24
    ____result_24 = bus:getDead():filter(____lambda_5)
    local ____arg_9 = ____result_24
    local ____result_25
    ____result_25 = bus:getDead():filter(____lambda_6)
    print("  dead users: " .. __K2L_Str(____arg_9) .. ", dead events: " .. ____result_25.size)
    print("  counts: " .. __K2L_Str(bus:subscriberCounts()))
    local ____list_3 = audit.entries
    for ____i_3 = 1, ____list_3.size do
        local it = ____list_3[____i_3]
        print("  audit: " .. it)
    end
    print("== scopes")
    do
        local factory = ____lambda_7
        root:register(__K2L_KClassOf(____Services.Session), ____Container.Scope.SCOPED, nil, factory)
    end
    local ____value_1 = root:child("request-1")
    do
        local factory = ____lambda_8
        ____value_1:register(__K2L_KClassOf(____Services.Session), ____Container.Scope.SCOPED, nil, factory)
    end
    local req1 = ____value_1
    local req2 = root:child("request-2")
    local ____result_26
    ____result_26 = req1:resolve(__K2L_KClassOf(____Services.Session), nil)
    local s1 = ____result_26
    local ____result_27
    ____result_27 = req1:resolve(__K2L_KClassOf(____Services.Session), nil)
    local ____arg_11 = s1 == ____result_27
    local ____result_28
    ____result_28 = req2:resolve(__K2L_KClassOf(____Services.Session), nil)
    local ____arg_12 = ____result_28
    local ____result_29
    ____result_29 = req2:resolve(__K2L_KClassOf(____Services.Session), nil)
    local ____arg_10 = ____result_29
    local ____result_30
    ____result_30 = req2:resolve(__K2L_KClassOf(____Services.Session), nil)
    print("  " .. __K2L_Str(s1) .. " same=" .. tostring(____arg_11) .. " " .. __K2L_Str(____arg_12) .. " " .. tostring(____arg_10 == ____result_30))
    local ____arg_13 = ____Services.RequestId:getIssued()
    local ____result_31
    ____result_31 = req1:resolve(__K2L_KClassOf(____Services.RequestId), nil)
    local ____arg_14 = ____result_31
    local ____result_32
    ____result_32 = req2:resolve(__K2L_KClassOf(____Services.RequestId), nil)
    print("  request ids issued: " .. ____arg_13 .. ", fresh: " .. __K2L_Str(____arg_14) .. " " .. __K2L_Str(____result_32))
    local ____list_4 = req1:describe()
    for ____i_4 = 1, ____list_4.size do
        local it = ____list_4[____i_4]
        print("  " .. it)
    end
    print("== failures")
    local ____result_33
    do
        local ____ok_2, ____result_34 = pcall(function()
            local ____result_35
            ____result_35 = root:resolve(__K2L_KClassNamed("kotlin.String"), nil)
            ____result_33 = ____result_35
        end)
        if not ____ok_2 then
            local ____error_2 = __K2L_ToThrowable(____result_34)
            if getmetatable(____error_2) == ____Container.ResolutionException then
                local e = ____error_2
                print("  resolve " .. __K2L_Str(__K2L_KClassNamed("kotlin.String").simpleName) .. " failed: " .. __K2L_Str(e.message))
                ____result_33 = nil
            else
                error(____error_2, 0)
            end
        end
    end
    local ____result_36
    do
        local ____ok_3, ____result_37 = pcall(function()
            local ____result_38
            ____result_38 = req2:resolve(__K2L_KClassNamed("kotlin.collections.Map"), nil)
            ____result_36 = ____result_38
        end)
        if not ____ok_3 then
            local ____error_3 = __K2L_ToThrowable(____result_37)
            if getmetatable(____error_3) == ____Container.ResolutionException then
                local e = ____error_3
                print("  resolve " .. __K2L_Str(__K2L_KClassNamed("kotlin.collections.Map").simpleName) .. " failed: " .. __K2L_Str(e.message))
                ____result_36 = nil
            else
                error(____error_3, 0)
            end
        end
    end
    local ____value_2 = ____Container.Container.new1("cyclic")
    do
        local factory = function(____this_10)
            local ____result_39
            ____result_39 = ____this_10:resolve(__K2L_KClassOf(B), nil)
            return A.new(____result_39)
        end
        ____value_2:register(__K2L_KClassOf(A), ____Container.Scope.SINGLETON, nil, factory)
    end
    do
        local factory = function(____this_11)
            local ____result_40
            ____result_40 = __K2L_FunInterface(____Container.Provider, "get", function()
                local ____result_41
                ____result_41 = ____this_11:resolve(__K2L_KClassOf(A), nil)
                return ____result_41
            end)
            return B.new(____result_40, true)
        end
        ____value_2:register(__K2L_KClassOf(B), ____Container.Scope.SINGLETON, nil, factory)
    end
    local cyclic = ____value_2
    local ____ok_4, ____result_42 = pcall(function()
        local ____result_43
        ____result_43 = cyclic:resolve(__K2L_KClassOf(A), nil)
    end)
    if not ____ok_4 then
        local ____error_4 = __K2L_ToThrowable(____result_42)
        if getmetatable(____error_4) == ____Container.ResolutionException then
            local e = ____error_4
            print("  " .. __K2L_Str(e.message) .. " (" .. e.chain.size .. " links)")
        else
            error(____error_4, 0)
        end
    end
    local ____value_3 = ____Container.Container.new1("lazy")
    do
        local factory = function(____this_12)
            local ____result_44
            ____result_44 = ____this_12:resolve(__K2L_KClassOf(B), nil)
            return A.new(____result_44)
        end
        ____value_3:register(__K2L_KClassOf(A), ____Container.Scope.SINGLETON, nil, factory)
    end
    do
        local factory = function(____this_13)
            local ____result_45
            ____result_45 = __K2L_FunInterface(____Container.Provider, "get", function()
                local ____result_46
                ____result_46 = ____this_13:resolve(__K2L_KClassOf(A), nil)
                return ____result_46
            end)
            return B.new(____result_45, false)
        end
        ____value_3:register(__K2L_KClassOf(B), ____Container.Scope.SINGLETON, nil, factory)
    end
    local lazyOk = ____value_3
    local ____result_47
    ____result_47 = lazyOk:resolve(__K2L_KClassOf(B), nil)
    local b = ____result_47
    print("  lazy cycle ok: " .. tostring(b.a:get().b == b))
    local ____ok_5, ____result_48 = pcall(function()
        do
            local factory = ____lambda_9
            root:register(__K2L_KClassOf(____EventBus.EventBus), ____Container.Scope.SINGLETON, nil, factory)
        end
    end)
    if not ____ok_5 then
        local ____error_5 = __K2L_ToThrowable(____result_48)
        if __K2L_InstanceOf(____error_5, __K2L_IllegalArgumentException) then
            local e = ____error_5
            print("  " .. __K2L_Str(e.message))
        else
            error(____error_5, 0)
        end
    end
    local ____result_49
    ____result_49 = __K2L_Lazy(function()
        local ____result_50
        ____result_50 = root:resolve(__K2L_KClassOf(____Services.Logger), nil)
        return ____result_50
    end)
    local lazyLogger = ____result_49
    print("  lazy initialized: " .. tostring(lazyLogger:isInitialized()) .. " prefix=" .. lazyLogger:getValue().prefix .. " " .. tostring(lazyLogger:isInitialized()))
    print("== logs")
    local ____result_51
    ____result_51 = root:resolve(__K2L_KClassOf(____Services.Logger), nil)
    local ____list_5 = ____result_51:lines()
    for ____i_5 = 1, ____list_5.size do
        local it = ____list_5[____i_5]
        print("  " .. it)
    end
    local ____result_52
    ____result_52 = root:resolve(__K2L_KClassOf(____Services.Logger), "audit")
    local ____list_6 = ____result_52:lines()
    for ____i_6 = 1, ____list_6.size do
        local it = ____list_6[____i_6]
        print("  " .. it)
    end
    print("  creations: " .. __K2L_Str(root:creations()))
    local ____list_7 = root:history():plusAll(req1:history())
    for ____i_7 = 1, ____list_7.size do
        local it = ____list_7[____i_7]
        print("  " .. it)
    end
end

main()
return {A = A, B = B, Audit = Audit, describe = describe, buildContainer = buildContainer}
-- ==== services/Services.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_CompanionInfo = ____lualib.__K2L_CompanionInfo
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_Str = ____lualib.__K2L_Str

local ____EventBus = require("events.EventBus")
local RequestId
local Clock = __K2L_Class("app.di.services.Clock")
__K2L_ClassInfo(Clock, "app.di.services.Clock", "app.di.services.Clock", "interface")
local FakeClock = __K2L_Class("app.di.services.FakeClock", nil, Clock)
__K2L_ClassInfo(FakeClock, "app.di.services.FakeClock", "app.di.services.FakeClock", "class")

function FakeClock:____init(time)
    if time == nil then
        time = 1000
    end
    self.time = time
end

function FakeClock:now()
    local ____value = self.time
    self.time = self.time + 15
    return ____value
end

local Logger = __K2L_Class("app.di.services.Logger")
__K2L_ClassInfo(Logger, "app.di.services.Logger", "app.di.services.Logger", "interface")
local BufferedLogger = __K2L_Class("app.di.services.BufferedLogger", nil, Logger)
__K2L_ClassInfo(BufferedLogger, "app.di.services.BufferedLogger", "app.di.services.BufferedLogger", "class")

function BufferedLogger:____init()
    self.buffer = __K2L_ListOf()
end

function BufferedLogger:info(msg)
    self.buffer:add(self:format(msg))
end

function BufferedLogger:lines()
    return self.buffer
end

local ConsoleLogger = __K2L_Class("app.di.services.ConsoleLogger", BufferedLogger)
__K2L_ClassInfo(ConsoleLogger, "app.di.services.ConsoleLogger", "app.di.services.ConsoleLogger", "class")

function ConsoleLogger:____init(clock, prefix)
    if prefix == nil then
        prefix = "app"
    end
    BufferedLogger.____init(self)
    self.clock = clock
    self.prefix = prefix
end

function ConsoleLogger:format(msg)
    return "[" .. self.prefix .. "@" .. self.clock:now() .. "] " .. msg
end

local UserRepository = __K2L_Class("app.di.services.UserRepository")
__K2L_ClassInfo(UserRepository, "app.di.services.UserRepository", "app.di.services.UserRepository", "class")

function UserRepository:____init(logger)
    self.logger = logger
    self.users = __K2L_SortedMapOf()
    self.nextId = 1
end

function UserRepository:add(name)
    if self.users:containsKey(name) then
        error(__K2L_IllegalStateException.new("user " .. name .. " already exists"))
    end
    local ____old = self.nextId
    self.nextId = self.nextId + 1
    local id = ____old
    local ____object = self.users
    ____object:set(name, id)
    self.logger:info("added " .. name .. " as #" .. id)
    return id
end

function UserRepository:remove(name)
    local ____value_1 = self.users:remove(name) ~= nil
    self.logger:info("remove " .. name .. " -> " .. tostring(____value_1))
    return ____value_1
end

function UserRepository:all()
    return self.users
end

local UserService = __K2L_Class("app.di.services.UserService")
__K2L_ClassInfo(UserService, "app.di.services.UserService", "app.di.services.UserService", "class")

function UserService:____init(repo, bus, ids)
    self.repo = repo
    self.bus = bus
    self.ids = ids
end

function UserService.new(repo, bus, ids)
    return setmetatable({repo = repo, bus = bus, ids = ids}, UserService)
end

function UserService:create(name)
    local id = self.repo:add(name)
    self.bus:publish(____EventBus.UserCreated.new("users/" .. __K2L_Str(self.ids:get()), name))
    return id
end

function UserService:delete(name, reason)
    if reason == nil then
        reason = nil
    end
    if self.repo:remove(name) then
        self.bus:publish(reason == nil and ____EventBus.UserDeleted.new("users/" .. __K2L_Str(self.ids:get()), name) or ____EventBus.UserDeleted.new("users/" .. __K2L_Str(self.ids:get()), name, reason))
    end
end

local OrderService = __K2L_Class("app.di.services.OrderService")
__K2L_ClassInfo(OrderService, "app.di.services.OrderService", "app.di.services.OrderService", "class")

function OrderService:____init(bus, logger)
    self.bus = bus
    self.logger = logger
    self.next = 100
end

function OrderService:place(...)
    local prices = __K2L_ArrayOf(...)
    if not prices:isNotEmpty() then
        error(__K2L_IllegalArgumentException.new("an order needs at least one item"))
    end
    local ____old_1 = self.next
    self.next = self.next + 1
    local id = ____old_1
    local total = prices:sum()
    self.logger:info("order " .. id .. ": " .. prices.size .. " items")
    self.bus:publish(____EventBus.OrderPlaced.new("orders", id, total))
    return id
end

RequestId = __K2L_Class("app.di.services.RequestId")
__K2L_ClassInfo(RequestId, "app.di.services.RequestId", "app.di.services.RequestId", "class")
__K2L_CompanionInfo(RequestId, "app.di.services.RequestId.Companion", "app.di.services.RequestId$Companion", "Companion")

function RequestId:____init(value)
    self.value = value
end

function RequestId.new(value)
    return setmetatable({value = value}, RequestId)
end

function RequestId:toString()
    return "req-" .. self.value
end

function RequestId:next()
    self.counter = self.counter + 1
    return RequestId.new(self.counter)
end

function RequestId:getIssued()
    return self.counter
end

function RequestId:____initCompanion()
    self.counter = 0
end

RequestId:____initCompanion()
local Session = __K2L_Class("app.di.services.Session")
__K2L_ClassInfo(Session, "app.di.services.Session", "app.di.services.Session", "class")
__K2L_CompanionInfo(Session, "app.di.services.Session.Companion", "app.di.services.Session$Companion", "Companion")

function Session:____init(user)
    self.user = user
    local ____old_2 = Session.sessions
    Session.sessions = Session.sessions + 1
    self.id = ____old_2
end

function Session:toString()
    return "Session(" .. self.user .. ", #" .. self.id .. ")"
end

function Session:____initCompanion()
    self.sessions = 0
end

Session:____initCompanion()
return {Clock = Clock, FakeClock = FakeClock, Logger = Logger, BufferedLogger = BufferedLogger, ConsoleLogger = ConsoleLogger, UserRepository = UserRepository, UserService = UserService, OrderService = OrderService, RequestId = RequestId, Session = Session}
