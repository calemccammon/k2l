local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_EnumValues = ____lualib.__K2L_EnumValues
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_KClassNamed = ____lualib.__K2L_KClassNamed
local __K2L_KClassOf = ____lualib.__K2L_KClassOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_NotImplementedError = ____lualib.__K2L_NotImplementedError
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Spread = ____lualib.__K2L_Spread
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringIsBlank = ____lualib.__K2L_StringIsBlank
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Unit = ____lualib.__K2L_Unit

local ValidationException = __K2L_Class("toolkit.ValidationException", __K2L_IllegalArgumentException)
__K2L_ClassInfo(ValidationException, "toolkit.ValidationException", "toolkit.ValidationException", "class")

function ValidationException:____init(field, message)
    __K2L_IllegalArgumentException.____init(self, field .. ": " .. message)
    self.field = field
end

local Validator = __K2L_Class("toolkit.Validator")
__K2L_ClassInfo(Validator, "toolkit.Validator", "toolkit.Validator", "class")

function Validator:____init(subject)
    self.subject = subject
    self.errors = __K2L_ListOf()
end

function Validator:check(field, condition, message)
    if not condition(self:subjectValue()) then
        self:fail(field, function() return message() end)
    end
    return self
end

function Validator:subjectValue()
    return self.subject
end

function Validator:fail(field, message)
    self.errors:add(field .. " " .. message())
end

function Validator:result()
    return self.errors
end

local function validate(subject, block)
    local ____value = Validator.new(subject)
    block(____value)
    return ____value:result()
end

local Clock = __K2L_Class("toolkit.Clock")
__K2L_ClassInfo(Clock, "toolkit.Clock", "toolkit.Clock", "class")

function Clock:____init()
    self.now = 0
end

function Clock:advance(by)
    self.now = self.now + by
end

Clock:____init()

local function timed(label, log, block)
    local start = Clock.now
    local ____ok, ____result, ____returned = pcall(function()
        return true, block()
    end)
    log:add(label .. " took " .. Clock.now - start)
    if not ____ok then
        error(____result, 0)
    end
    if ____result then
        return ____returned
    end
end

local ResourceScope = __K2L_Class("toolkit.ResourceScope")
__K2L_ClassInfo(ResourceScope, "toolkit.ResourceScope", "toolkit.ResourceScope", "class")

function ResourceScope:____init()
    self.closers = __K2L_ArrayDeque.new()
end

function ResourceScope:closeWith(____this, closer)
    self.closers:addFirst(function()
        closer(____this)
    end)
    return ____this
end

function ResourceScope:closeAll()
    local failures = __K2L_ListOf()
    while self.closers:isNotEmpty() do
        local ____ok_1, ____result_1 = pcall(function()
            self.closers:removeFirst()()
        end)
        if not ____ok_1 then
            local ____error_1 = __K2L_ToThrowable(____result_1)
            if __K2L_InstanceOf(____error_1, __K2L_IllegalStateException) then
                local e = ____error_1
                failures:add(e.message or "?")
            else
                error(____error_1, 0)
            end
        end
    end
    return failures
end

local function resourceScope(block)
    local scope = ResourceScope.new()
    local result
    local ____ok_2, ____result_2 = pcall(function()
        result = block(scope)
    end)
    if not ____ok_2 then
        local ____error_2 = __K2L_ToThrowable(____result_2)
        if __K2L_InstanceOf(____error_2, __K2L_Exception) then
            local e = ____error_2
            scope:closeAll()
            error(e)
        else
            error(____error_2, 0)
        end
    end
    return __K2L_Pair.new(result, scope:closeAll())
end

local function fatal(message)
    error(__K2L_IllegalStateException.new("fatal: " .. message))
end

local Machine = __K2L_Class("toolkit.Machine")
__K2L_ClassInfo(Machine, "toolkit.Machine", "toolkit.Machine", "class")

function Machine:____init(name)
    self.name = name
    self.state = Machine.State.IDLE
    self.transitions = __K2L_ListOf()
    self.start = Machine.Transition.new(self, __K2L_ReadOnlySetOf(Machine.State.IDLE, Machine.State.PAUSED), Machine.State.RUNNING)
    self.pause = Machine.Transition.new(self, __K2L_ReadOnlySetOf(Machine.State.RUNNING), Machine.State.PAUSED)
    self.stop = Machine.Transition.new(self, __K2L_EnumValues(Machine.State):toSet():minus(Machine.State.STOPPED), Machine.State.STOPPED)
end

Machine.State = __K2L_Class("toolkit.Machine$State")
__K2L_ClassInfo(Machine.State, "toolkit.Machine.State", "toolkit.Machine$State", "class")

function Machine.State:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Machine.State:toString()
    return self.name
end

function Machine.State:compareTo(other)
    return self.ordinal - other.ordinal
end

Machine.State.IDLE = Machine.State.new("IDLE", 0)
Machine.State.RUNNING = Machine.State.new("RUNNING", 1)
Machine.State.PAUSED = Machine.State.new("PAUSED", 2)
Machine.State.STOPPED = Machine.State.new("STOPPED", 3)
Machine.State.____values = {Machine.State.IDLE, Machine.State.RUNNING, Machine.State.PAUSED, Machine.State.STOPPED}
Machine.Transition = __K2L_Class("toolkit.Machine$Transition")
__K2L_ClassInfo(Machine.Transition, "toolkit.Machine.Transition", "toolkit.Machine$Transition", "class")

function Machine.Transition:____init(____outer, from, to)
    self.____outer = ____outer
    self.from = from
    self.to = to
end

function Machine.Transition:fire()
    if not self.from:contains(self.____outer.state) then
        return false
    end
    self.____outer.transitions:add(self.____outer.name .. ": " .. __K2L_Str(self.____outer.state) .. " -> " .. __K2L_Str(self.to))
    self.____outer.state = self.to
    return true
end

function Machine:history()
    return self.transitions:toList()
end

local function findIndex(grid, target)
    local ____mod_1 = grid.____modCount
    for ____i_1 = 1, grid.size do
        local row = grid[____i_1]
        local r = ____i_1 - 1
        do
            local ____mod = row.____modCount
            for ____i = 1, row.size do
                local v = row[____i]
                local c = ____i - 1
                if v == target then
                    return __K2L_Pair.new(r, c)
                end
                if row.____modCount ~= ____mod and row:____comodified(____i) then
                    break
                end
            end
        end
        if grid.____modCount ~= ____mod_1 and grid:____comodified(____i_1) then
            break
        end
    end
    return nil
end

local function firstNegativeSums(rows)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = rows:____array()
    for ____i_3 = 1, ____n do
        local row = ____items[____i_3]
        local ____result_3
        do
            local sum = 0
            local ____mod_2 = row.____modCount
            for ____i_2 = 1, row.size do
                local it = row[____i_2]
                if it < 0 then
                    ____result_3 = sum
                    goto ____inline_end
                end
                sum = sum + it
                if row.____modCount ~= ____mod_2 and row:____comodified(____i_2) then
                    break
                end
            end
            ____result_3 = sum
            ::____inline_end::
        end
        ____count = ____count + 1
        ____out[____count] = ____result_3
    end
    return __K2L_ListWrap(____out, ____count)
end

local function makeCounters()
    local counters = __K2L_ListOf()
    local shared = 0
    for i = 1, 3 do
        local own = i * 10
        counters:add(function()
            shared = shared + 1
            own = own + i
            return own + shared
        end)
    end
    return counters
end

local function fib(n)
    local memo = __K2L_HashMap.new()
    local function go(k)
        if k < 2 then
            return k
        else
            return memo:getOrPut(k, function() return go(k - 1) + go(k - 2) end)
        end
    end
    return go(n)
end

local ____lambda_1 = function(it) return not __K2L_StringIsBlank(it.name) end
local ____lambda_2 = function() return "must not be blank" end
local ____lambda_3 = function(it) return it.age >= 0 end
local ____lambda_4 = function(it) return it.age >= 18 end
local ____lambda_5 = function() return "must be an adult" end
local ____lambda_6 = function(it)
    return __K2L_StringContains(it.email, "@") and __K2L_StringContains(__K2L_Text.substringAfter(it.email, "@"), ".")
end
local ____lambda_7 = function() return "<anon>" end
local ____lambda_8 = function(x) return type(x) == "string" end
local ____lambda_9 = function(x) return math.type(x) == "integer" end
local function main()
    local User = __K2L_Class("toolkit.MainKt$main$User")
    __K2L_ClassInfo(User, nil, "toolkit.MainKt$main$User", "class")
    function User:____init(name, age, email)
        self.name = name
        self.age = age
        self.email = email
    end
    function User:toString()
        return "User(name=" .. self.name .. ", age=" .. self.age .. ", email=" .. self.email .. ")"
    end
    function User:hashCode()
        return (31 * (31 * __K2L_Hash(self.name) + self.age) + __K2L_Hash(self.email) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
    end
    function User:equals(other)
        return getmetatable(other) == User and self.name == other.name and self.age == other.age and self.email == other.email
    end
    local users = __K2L_ReadOnlyListOf(User.new("ada", 36, "ada@example.com"), User.new("", -1, "nope"), User.new("bob", 17, "bob@example"))
    local ____mod_3 = users.____modCount
    for ____i_4 = 1, users.size do
        local u = users[____i_4]
        local problems = validate(u, function(self)
            self:check("name", ____lambda_1, ____lambda_2)
            self:check("age", ____lambda_3, function() return "must be positive, was " .. u.age end)
            self:check("age", ____lambda_4, ____lambda_5)
            self:check("email", ____lambda_6, function() return "is invalid: " .. u.email end)
        end)
        print(__K2L_Text.ifEmpty(u.name, ____lambda_7) .. ": " .. (problems:isEmpty() and "ok" or problems:joinToString("; ")))
        if users.____modCount ~= ____mod_3 and users:____comodified(____i_4) then
            break
        end
    end
    local delays = __K2L_ListOf()
    local calls = 0
    local ____result_4
    do
        local delay = 10
        for attempt = 0, 4 - 1 - 1 do
            do
                local ____ok_3, ____result_5 = pcall(function()
                    local ____result_6
                    do
                        local attempt = attempt + 1
                        calls = calls + 1
                        if attempt < 3 then
                            error(__K2L_IllegalStateException.new("flaky " .. attempt))
                        end
                        ____result_6 = "succeeded on " .. attempt
                    end
                    ____result_4 = ____result_6
                    return 1
                end)
                if ____ok_3 then
                    if ____result_5 == 1 then
                        goto ____inline_end_1
                    end
                else
                    local ____error_3 = __K2L_ToThrowable(____result_5)
                    local e = ____error_3
                    if not __K2L_InstanceOf(e, __K2L_IllegalStateException) then
                        error(e)
                    end
                    delays:add(delay)
                    delay = delay * 2
                end
            end
        end
        local ____result_7
        calls = calls + 1
        if 4 < 3 then
            error(__K2L_IllegalStateException.new("flaky " .. 4))
        end
        ____result_7 = "succeeded on " .. 4
        ____result_4 = ____result_7
        ::____inline_end_1::
    end
    local value = ____result_4
    print(value .. " after " .. calls .. " calls, delays " .. __K2L_Str(delays))
    local ____ok_4, ____result_8 = pcall(function()
        do
            local delay = 10
            for attempt = 0, 3 - 1 - 1 do
                do
                    local ____ok_5, ____result_9 = pcall(function()
                        do
                            local it = attempt + 1
                            error(__K2L_IllegalArgumentException.new("not retried"))
                        end
                        return 1
                    end)
                    if ____ok_5 then
                        if ____result_9 == 1 then
                            goto ____inline_end_2
                        end
                    else
                        local ____error_4 = __K2L_ToThrowable(____result_9)
                        local e = ____error_4
                        if not __K2L_InstanceOf(e, __K2L_IllegalStateException) then
                            error(e)
                        end
                        delays:add(delay)
                        delay = delay * 2
                    end
                end
            end
            error(__K2L_IllegalArgumentException.new("not retried"))
            ::____inline_end_2::
        end
    end)
    if not ____ok_4 then
        local ____error_5 = __K2L_ToThrowable(____result_8)
        if __K2L_InstanceOf(____error_5, __K2L_IllegalArgumentException) then
            local e = ____error_5
            print("gave up: " .. __K2L_Str(e.message) .. ", delays " .. __K2L_Str(delays))
        else
            error(____error_5, 0)
        end
    end
    local log = __K2L_ListOf()
    local total = timed("sum", log, function()
        Clock:advance(5)
        return __K2L_IntRange.new(1, 10):sum()
    end)
    local function earlyExit()
        do
            local start = Clock.now
            local ____ok_6, ____result_10, ____returned_6 = pcall(function()
                local ____result_11
                Clock:advance(3)
                do return true, "left early" end
                return 1
            end)
            log:add("early" .. " took " .. Clock.now - start)
            if not ____ok_6 then
                error(____result_10, 0)
            end
            if ____result_10 == true then
                return ____returned_6
            end
            if ____result_10 == 1 then
                goto ____inline_end_3
            end
            ::____inline_end_3::
        end
    end
    print(total .. " " .. earlyExit() .. " " .. __K2L_Str(log))
    local ____destructured = resourceScope(function(____this_1)
        local a = ____this_1:closeWith("db", function(it)
            log:add("closed " .. it)
        end)
        local b = ____this_1:closeWith("cache", function(it)
            error(__K2L_IllegalStateException.new("cache refused to close"))
        end)
        local c = ____this_1:closeWith(42, function(it)
            log:add("closed #" .. it)
        end)
        return __K2L_ReadOnlyListOf(a, b, c)
    end)
    local opened, failures = ____destructured.first, ____destructured.second
    print("opened " .. __K2L_Str(opened) .. ", close failures " .. __K2L_Str(failures) .. ", log " .. __K2L_Str(log:drop(2)))
    local mixed = __K2L_ReadOnlyListOf(1, "two", true, nil, __K2L_SingletonListOf(5))
    local ____result_12
    do
        local ____mod_4 = mixed.____modCount
        for ____i_5 = 1, mixed.size do
            local x = mixed[____i_5]
            if type(x) == "string" then
                ____result_12 = x
                goto ____inline_end_4
            end
            if mixed.____modCount ~= ____mod_4 and mixed:____comodified(____i_5) then
                break
            end
        end
        ____result_12 = nil
        ::____inline_end_4::
    end
    local ____arg = ____result_12
    local ____result_13
    do
        local ____mod_5 = mixed.____modCount
        for ____i_6 = 1, mixed.size do
            local x = mixed[____i_6]
            if type(x) == "boolean" then
                ____result_13 = x
                goto ____inline_end_5
            end
            if mixed.____modCount ~= ____mod_5 and mixed:____comodified(____i_6) then
                break
            end
        end
        ____result_13 = nil
        ::____inline_end_5::
    end
    local ____arg_1 = ____result_13
    local ____result_14
    do
        local ____mod_6 = mixed.____modCount
        for ____i_7 = 1, mixed.size do
            local x = mixed[____i_7]
            if __K2L_InstanceOf(x, __K2L_List) then
                ____result_14 = x
                goto ____inline_end_6
            end
            if mixed.____modCount ~= ____mod_6 and mixed:____comodified(____i_7) then
                break
            end
        end
        ____result_14 = nil
        ::____inline_end_6::
    end
    local ____arg_2 = ____result_14
    local ____result_15
    do
        local ____mod_7 = mixed.____modCount
        for ____i_8 = 1, mixed.size do
            local x = mixed[____i_8]
            if __K2L_InstanceOf(x, __K2L_Map) then
                ____result_15 = x
                goto ____inline_end_7
            end
            if mixed.____modCount ~= ____mod_7 and mixed:____comodified(____i_8) then
                break
            end
        end
        ____result_15 = nil
        ::____inline_end_7::
    end
    print(__K2L_Str(____arg) .. " " .. __K2L_Str(____arg_1) .. " " .. __K2L_Str(____arg_2) .. " " .. __K2L_Str(____result_15))
    local ____result_16
    ____result_16 = __K2L_KClassOf(User).simpleName or "anonymous"
    local ____arg_3 = ____result_16
    local ____result_17
    ____result_17 = __K2L_KClassOf(Machine.State).simpleName or "anonymous"
    local ____arg_4 = ____result_17
    local ____result_18
    ____result_18 = __K2L_KClassOf(Machine.Transition).simpleName or "anonymous"
    print(____arg_3 .. " " .. ____arg_4 .. " " .. ____result_18)
    local registry = __K2L_ReadOnlyMapOf(__K2L_Pair.new(__K2L_KClassNamed("kotlin.String"), "text"), __K2L_Pair.new(__K2L_KClassNamed("kotlin.Int"), 7))
    local ____result_19
    do
        local ____cast = registry:get(__K2L_KClassNamed("kotlin.String"))
        ____result_19 = type(____cast) == "string" and ____cast or nil
    end
    local ____arg_5 = ____result_19
    local ____result_20
    do
        local ____cast_1 = registry:get(__K2L_KClassNamed("kotlin.Int"))
        ____result_20 = math.type(____cast_1) == "integer" and ____cast_1 or nil
    end
    local ____arg_6 = ____result_20
    local ____result_21
    do
        local ____cast_2 = registry:get(__K2L_KClassOf(Machine))
        ____result_21 = getmetatable(____cast_2) == Machine and ____cast_2 or nil
    end
    print(__K2L_Str(____arg_5) .. " " .. __K2L_Str(____arg_6) .. " " .. __K2L_Str(____result_21))
    local extra = __K2L_ArrayOf(4, "five", 6)
    local ____result_22
    do
        local items = __K2L_ArrayOf(1, "x", __K2L_Spread("s.", extra, 2))
        local ____result_23 = 0
        local ____items_1, ____n_1 = items:____array()
        for ____i_9 = 1, ____n_1 do
            local it = ____items_1[____i_9]
            if math.type(it) == "integer" then
                ____result_23 = ____result_23 + 1
            end
        end
        ____result_22 = ____result_23
    end
    print(____result_22)
    local ____result_24
    do
        local items = __K2L_ArrayOf(__K2L_Spread("s.s", extra, "y", extra))
        local ____result_25 = 0
        local ____items_2, ____n_2 = items:____array()
        for ____i_10 = 1, ____n_2 do
            local it = ____items_2[____i_10]
            if type(it) == "string" then
                ____result_25 = ____result_25 + 1
            end
        end
        ____result_24 = ____result_25
    end
    print(____result_24)
    local ____result_26
    do
        local items = __K2L_ArrayOf("a", 1, __K2L_Spread("s.", extra, "z"))
        ____result_26 = items:filter(____lambda_8):joinToString(", ") .. "!"
    end
    print(____result_26)
    local ____result_27
    do
        local items = __K2L_ArrayOf(__K2L_Spread("s.", extra, 10))
        ____result_27 = items:filter(____lambda_9):joinToString("+") .. "."
    end
    print(____result_27)
    local m = Machine.new("pump")
    print(tostring(m.start:fire()) .. " " .. tostring(m.start:fire()) .. " " .. tostring(m.pause:fire()) .. " " .. tostring(m.start:fire()) .. " " .. tostring(m.stop:fire()) .. " " .. tostring(m.pause:fire()) .. " " .. __K2L_Str(m.state))
    local ____list = m:history()
    for ____i_11 = 1, ____list.size do
        local it = ____list[____i_11]
        print("  " .. it)
    end
    local grid = __K2L_ReadOnlyListOf(__K2L_ReadOnlyListOf(1, 2, 3), __K2L_ReadOnlyListOf(4, 5, 6))
    print(__K2L_Str(findIndex(grid, 5)) .. " " .. __K2L_Str(findIndex(grid, 9)) .. " " .. __K2L_Str(firstNegativeSums(__K2L_ReadOnlyListOf(__K2L_ReadOnlyListOf(1, 2, -1, 5), __K2L_ReadOnlyListOf(3, 4), __K2L_SingletonListOf(-2)))))
    local counters = makeCounters()
    print(__K2L_Str(__K2L_ListOfSize(2, function(it)
        local ____out_1 = {}
        local ____count_1 = 0
        local ____items_3, ____n_3 = counters:____array()
        for ____i_12 = 1, ____n_3 do
            local it = ____items_3[____i_12]
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = it()
        end
        return __K2L_ListWrap(____out_1, ____count_1)
    end)))
    print("fib(60) = " .. fib(60))
    local outcome = __K2L_RunCatching(function()
        fatal("disk full")
    end)
    local ____arg_7 = outcome:isFailure()
    local ____receiver = outcome:exceptionOrNull()
    print(tostring(____arg_7) .. " " .. __K2L_Str(____receiver and ____receiver.message))
    local lazyTodo = __K2L_RunCatching(function()
        error(__K2L_NotImplementedError.new("An operation is not implemented: " .. "parse config"))
    end)
    local ____receiver_1 = lazyTodo:exceptionOrNull()
    print(__K2L_Str(____receiver_1 and __K2L_Str(__K2L_KClassOfValue(____receiver_1).simpleName) .. ": " .. __K2L_Str(____receiver_1.message)))
    local ____ok_7, ____result_28 = pcall(function()
        if not (users.size > 5) then
            error(__K2L_IllegalArgumentException.new("need more than 5 users, got " .. users.size))
        end
    end)
    if not ____ok_7 then
        local ____error_7 = __K2L_ToThrowable(____result_28)
        if __K2L_InstanceOf(____error_7, __K2L_IllegalArgumentException) then
            local e = ____error_7
            print(__K2L_Str(e.message))
        else
            error(____error_7, 0)
        end
    end
    local e = ValidationException.new("age", "too low")
    print(e.field .. " " .. __K2L_Str(e.message) .. " " .. tostring(__K2L_InstanceOf(e, __K2L_IllegalArgumentException)))
end

main()
return {ValidationException = ValidationException, Validator = Validator, validate = validate, Clock = Clock, timed = timed, ResourceScope = ResourceScope, resourceScope = resourceScope, fatal = fatal, Machine = Machine, findIndex = findIndex, firstNegativeSums = firstNegativeSums, makeCounters = makeCounters, fib = fib}
