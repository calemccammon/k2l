-- ==== dsl/RuleDsl.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_LoopItems = ____lualib.__K2L_LoopItems
local __K2L_NumberTo = ____lualib.__K2L_NumberTo
local __K2L_Str = ____lualib.__K2L_Str

local ____Facts = require("engine.Facts")
local Condition = __K2L_Class("rules.dsl.Condition")

function Condition:____init(text, test)
    self.text = text
    self.test = test
end

function Condition.new(text, test)
    return setmetatable({text = text, test = test}, Condition)
end

function Condition:____and(other)
    return Condition.new("(" .. self.text .. " and " .. other.text .. ")", function(it) return self.test(it) and other.test(it) end)
end

function Condition:____or(other)
    return Condition.new("(" .. self.text .. " or " .. other.text .. ")", function(it) return self.test(it) or other.test(it) end)
end

function Condition:____not()
    return Condition.new("not " .. self.text, function(it) return not self.test(it) end)
end

function Condition:toString()
    return self.text
end

local FactRef = __K2L_Class("rules.dsl.FactRef")

function FactRef:____init(name)
    self.name = name
end

function FactRef.new(name)
    return setmetatable({name = name}, FactRef)
end

function FactRef:gt(n)
    return Condition.new(self.name .. " > " .. __K2L_Str(n), function(it)
        return __K2L_Compare(it:get(self.name), ____Facts.toValue__1(__K2L_NumberTo(n, "toDouble"))) > 0
    end)
end

function FactRef:lt(n)
    return Condition.new(self.name .. " < " .. __K2L_Str(n), function(it)
        return __K2L_Compare(it:get(self.name), ____Facts.toValue__1(__K2L_NumberTo(n, "toDouble"))) < 0
    end)
end

function FactRef:atLeast(n)
    return Condition.new(self.name .. " >= " .. __K2L_Str(n), function(it)
        return __K2L_Compare(it:get(self.name), ____Facts.toValue__1(__K2L_NumberTo(n, "toDouble"))) >= 0
    end)
end

function FactRef:eq(s)
    return Condition.new(self.name .. " == \"" .. s .. "\"", function(it)
        return __K2L_Equals(it:get(self.name), ____Facts.toValue__2(s))
    end)
end

function FactRef:____in(range)
    return Condition.new(self.name .. " in " .. __K2L_Str(range.first) .. ".." .. __K2L_Str(range.last), function(it)
        local ____cast = it:get(self.name)
        local ____receiver = getmetatable(____cast) == ____Facts.Value.Num and ____cast or nil
        local ____result
        if ____receiver ~= nil then
            local ____cast_1 = it:get(self.name)
            ____result = (getmetatable(____cast_1) == ____Facts.Value.Num and ____cast_1 or nil).v
        end
        local ____receiver_1 = ____result
        local ____value = ____receiver_1 and range:contains(____receiver_1)
        if ____value == nil then
            ____value = false
        end
        return ____value
    end)
end

function FactRef:getIsSet()
    return Condition.new(self.name .. " is set", function(it) return it:contains(self.name) end)
end

function FactRef:getIsTrue()
    return Condition.new(self.name, function(it)
        return __K2L_Equals(it:get(self.name), ____Facts.Value.Flag.new(true))
    end)
end

local ConditionScope = __K2L_Class("rules.dsl.ConditionScope")

function ConditionScope:unaryPlus(____this)
    return FactRef.new(____this)
end

function ConditionScope:fact(name)
    return FactRef.new(name)
end

local ____lambda_1 = function(it) return true end
function ConditionScope:always()
    return Condition.new("always", ____lambda_1)
end

local ActionScope = __K2L_Class("rules.dsl.ActionScope")

function ActionScope:____init(facts, fired)
    self.facts = facts
    self.fired = fired
end

function ActionScope.new(facts, fired)
    return setmetatable({facts = facts, fired = fired}, ActionScope)
end

function ActionScope:becomes(____this_1, value)
    local ____object = self.facts
    ____object:set(____this_1, value)
end

function ActionScope:becomes__1(____this_2, value)
    self:becomes(____this_2, ____Facts.toValue__1(__K2L_NumberTo(value, "toDouble")))
end

function ActionScope:becomes__2(____this_3, value)
    self:becomes(____this_3, ____Facts.toValue__2(value))
end

function ActionScope:becomes__3(____this_4, value)
    self:becomes(____this_4, ____Facts.toValue__3(value))
end

function ActionScope:invoke(____this_5)
    return self.facts:get(____this_5)
end

function ActionScope:note(text)
    self.fired:add(text)
end

function ActionScope:drop(name)
    self.facts:minusAssign(name)
end

local Rule = __K2L_Class("rules.dsl.Rule")

function Rule:____init(name, priority, condition, action, once)
    self.name = name
    self.priority = priority
    self.condition = condition
    self.action = action
    self.once = once
end

function Rule.new(name, priority, condition, action, once)
    return setmetatable({name = name, priority = priority, condition = condition, action = action, once = once}, Rule)
end

function Rule:toString()
    return "rule '" .. self.name .. "' (p" .. self.priority .. ") when " .. __K2L_Str(self.condition)
end

local RuleBuilder = __K2L_Class("rules.dsl.RuleBuilder")

function RuleBuilder:____init(name)
    self.name = name
    self.priority = 0
    self.once = false
    self.condition = nil
    self.action = nil
end

function RuleBuilder:whenever(block)
    self.condition = block(ConditionScope.new())
end

function RuleBuilder:____then(block)
    self.action = block
end

function RuleBuilder:build()
    local ____arg = self.name
    local ____arg_1 = self.priority
    local ____value_1 = self.condition
    if ____value_1 == nil then
        error(__K2L_IllegalStateException.new("rule '" .. self.name .. "' has no condition"))
    end
    local ____value_2 = self.action
    if ____value_2 == nil then
        error(__K2L_IllegalStateException.new("rule '" .. self.name .. "' has no action"))
    end
    return Rule.new(____arg, ____arg_1, ____value_1, ____value_2, self.once)
end

local RuleSetBuilder = __K2L_Class("rules.dsl.RuleSetBuilder")

function RuleSetBuilder:____init()
    self.rules = __K2L_ListOf()
end

function RuleSetBuilder:rule(name, block)
    local ____arg_2 = self.rules
    local ____value_3 = RuleBuilder.new(name)
    block(____value_3)
    ____arg_2:add(____value_3:build())
end

function RuleSetBuilder:each(items, block)
    local ____items, ____n = __K2L_LoopItems(items)
    local ____mod = items.____modCount
    for ____i = 1, ____n do
        local item = ____items[____i]
        block(self, item)
        if items.____modCount ~= ____mod and items:____comodified(____i, ____n) then
            break
        end
    end
end

local ____lambda_2 = function(it) return it.priority end
local function ruleSet(block)
    local ____value_4 = RuleSetBuilder.new()
    block(____value_4)
    return ____value_4.rules:sortedByDescending(____lambda_2, true)
end

return {Condition = Condition, FactRef = FactRef, ConditionScope = ConditionScope, ActionScope = ActionScope, Rule = Rule, RuleBuilder = RuleBuilder, RuleSetBuilder = RuleSetBuilder, ruleSet = ruleSet}
-- ==== engine/Engine.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local ____RuleDsl = require("dsl.RuleDsl")
local RuleCycleException = __K2L_Class("rules.engine.RuleCycleException", __K2L_RuntimeException)

function RuleCycleException:____init(rounds)
    __K2L_RuntimeException.____init(self, "no fixpoint after " .. rounds .. " rounds")
    self.rounds = rounds
end

local Engine = __K2L_Class("rules.engine.Engine")

function Engine:____init(rules, maxRounds)
    if maxRounds == nil then
        maxRounds = 10
    end
    self.rules = rules
    self.maxRounds = maxRounds
    self.lastRounds = 0
end

function Engine:run(facts, trace)
    if trace == nil then
        trace = function(it) end
    end
    local fired = __K2L_ListOf()
    local firedOnce = __K2L_SetOf()
    local round = 0
    repeat
        round = round + 1
        if round > self.maxRounds then
            error(RuleCycleException.new(self.maxRounds))
        end
        local before = facts:snapshot()
        local ____list = self.rules
        local ____mod = ____list.____modCount
        for ____i = 1, ____list.size do
            local rule = ____list[____i]
            do
                if rule.once and firedOnce:contains(rule.name) then
                    goto ____continue
                end
                local holds
                local ____ok, ____result = __K2L_DeepPcall(function()
                    holds = rule.condition.test(facts)
                end)
                if not ____ok then
                    local ____error = __K2L_ToThrowable(____result)
                    if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
                        local e = ____error
                        trace("  " .. rule.name .. ": " .. __K2L_Str(e.message))
                        holds = false
                    else
                        error(____error, 0)
                    end
                end
                if not holds then
                    goto ____continue
                end
                trace("  round " .. round .. ": " .. rule.name)
                local ____value = ____RuleDsl.ActionScope.new(facts, fired)
                rule.action(____value)
                firedOnce:add(rule.name)
            end
            ::____continue::
            if ____list.____modCount ~= ____mod and ____list:____comodified(____i) then
                break
            end
        end
        local changed = not __K2L_Equals(facts:snapshot(), before)
    until not changed
    self.lastRounds = round
    return fired
end

return {RuleCycleException = RuleCycleException, Engine = Engine}
-- ==== engine/Facts.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_DoubleEquals = ____lualib.__K2L_DoubleEquals
local __K2L_DoubleToLong = ____lualib.__K2L_DoubleToLong
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_UnsupportedOperationException = ____lualib.__K2L_UnsupportedOperationException

local Value = __K2L_Class("rules.engine.Value")
Value.____comparable = true
Value.Num = __K2L_Class("rules.engine.Value$Num", Value)

function Value.Num:____init(v)
    self.v = v
end

function Value.Num.new(v)
    return setmetatable({v = v}, Value.Num)
end

function Value.Num:toString()
    return self.v == (self.v == 0 and self.v * 1.0 or math.floor(self.v) + 0.0) and not __K2L_Num.isInfinite(self.v) and tostring(__K2L_DoubleToLong(self.v)) or __K2L_Str(self.v)
end

function Value.Num:hashCode()
    return __K2L_Hash(self.v)
end

function Value.Num:equals(other)
    return getmetatable(other) == Value.Num and __K2L_DoubleEquals(self.v, other.v)
end

Value.Text = __K2L_Class("rules.engine.Value$Text", Value)

function Value.Text:____init(s)
    self.s = s
end

function Value.Text.new(s)
    return setmetatable({s = s}, Value.Text)
end

function Value.Text:toString()
    return "\"" .. self.s .. "\""
end

function Value.Text:hashCode()
    return __K2L_Hash(self.s)
end

function Value.Text:equals(other)
    return getmetatable(other) == Value.Text and self.s == other.s
end

Value.Flag = __K2L_Class("rules.engine.Value$Flag", Value)

function Value.Flag:____init(b)
    self.b = b
end

function Value.Flag.new(b)
    return setmetatable({b = b}, Value.Flag)
end

function Value.Flag:toString()
    return tostring(self.b)
end

function Value.Flag:hashCode()
    return self.b and 1231 or 1237
end

function Value.Flag:equals(other)
    return getmetatable(other) == Value.Flag and self.b == other.b
end

Value.Missing = __K2L_Class("rules.engine.Value$Missing", Value)

function Value.Missing:toString()
    return "missing"
end

function Value:compareTo(other)
    if getmetatable(self) == Value.Num and getmetatable(other) == Value.Num then
        return __K2L_Compare(self.v, other.v)
    elseif getmetatable(self) == Value.Text and getmetatable(other) == Value.Text then
        return __K2L_Text.compare(self.s, other.s)
    elseif getmetatable(self) == Value.Flag and getmetatable(other) == Value.Flag then
        return __K2L_Compare(self.b, other.b)
    else
        error(__K2L_IllegalArgumentException.new("cannot compare " .. __K2L_Str(self) .. " with " .. __K2L_Str(other)))
    end
end

function Value:plus(other)
    if getmetatable(self) == Value.Num and getmetatable(other) == Value.Num then
        return Value.Num.new(self.v + other.v)
    elseif getmetatable(self) == Value.Text then
        return Value.Text.new(self.s .. other:render())
    else
        error(__K2L_UnsupportedOperationException.new(__K2L_Str(self) .. " + " .. __K2L_Str(other)))
    end
end

function Value:times(k)
    local ____receiver = getmetatable(self) == Value.Num and self or nil
    local ____result
    if ____receiver ~= nil then
        local ____value = getmetatable(self) == Value.Num and self or nil
        ____result = Value.Num.new(____value.v * k)
    end
    return ____result or Value.Missing
end

function Value:render()
    if getmetatable(self) == Value.Text then
        return self.s
    else
        return __K2L_Str(self)
    end
end

local function toValue(self)
    return Value.Num.new(self + 0.0)
end

local function toValue__1(____this)
    return Value.Num.new(____this)
end

local function toValue__2(____this_1)
    return Value.Text.new(____this_1)
end

local function toValue__3(____this_2)
    return Value.Flag.new(____this_2)
end

local Facts = __K2L_Class("rules.engine.Facts")

function Facts:____init(initial)
    if initial == nil then
        initial = __K2L_ReadOnlyMapOf()
    end
    self.values = initial:toMutableMap()
    self.changes = __K2L_ListOf()
end

function Facts:get(name)
    return self.values:get(name) or Value.Missing
end

function Facts:set(name, value)
    local old = self.values:put(name, value)
    if not __K2L_Equals(old, value) then
        self.changes:add(name .. ": " .. __K2L_Str(old or Value.Missing) .. " -> " .. __K2L_Str(value))
    end
end

function Facts:contains(name)
    return self.values:containsKey(name)
end

function Facts:plusAssign(pair)
    self:set(pair.first, pair.second)
end

function Facts:minusAssign(name)
    local ____receiver_1 = self.values:remove(name)
    if ____receiver_1 ~= nil then
        self.changes:add(name .. " removed")
    end
end

function Facts:snapshot()
    return self.values:toMap()
end

function Facts:getTrail()
    return self.changes
end

local ____lambda_1 = function(it)
    return __K2L_Str(it.key) .. "=" .. __K2L_Str(it.value)
end
function Facts:toString()
    return self.values:getEntries():joinToString(", ", "{", "}", nil, nil, ____lambda_1)
end

return {Value = Value, toValue = toValue, toValue__1 = toValue__1, toValue__2 = toValue__2, toValue__3 = toValue__3, Facts = Facts}
-- ==== main.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_ClosedRange = ____lualib.__K2L_ClosedRange
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_DoubleToInt = ____lualib.__K2L_DoubleToInt
local __K2L_DoubleToString = ____lualib.__K2L_DoubleToString
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Unpack = ____lualib.__K2L_Unpack

local ____RuleDsl = require("dsl.RuleDsl")
local ____Facts = require("engine.Facts")
local ____Engine = require("engine.Engine")
local tiers = __K2L_ReadOnlyListOf(__K2L_Pair.new("bronze", 0.0), __K2L_Pair.new("silver", 0.1), __K2L_Pair.new("gold", 0.2))

local ____lambda_1 = function(____this_1)
    return ____this_1:unaryPlus("age"):atLeast(18)
end
local ____lambda_2 = function(____this_4)
    return ____this_4:unaryPlus("age"):lt(25):____and(____this_4:fact("premium"):getIsSet())
end
local ____lambda_3 = function(____this_7)
    return ____this_7:unaryPlus("claims"):gt(2):____or(____this_7:unaryPlus("points"):gt(6))
end
local ____lambda_4 = function(____this_10)
    return ____this_10:unaryPlus("risk"):eq("high"):____and(____this_10:fact("premium"):getIsSet())
end
local ____lambda_5 = function(____this_17)
    return ____this_17:fact("premium"):getIsSet():____and(____this_17:fact("label"):getIsSet():____not())
end
local ____lambda_6 = function(____this_20)
    return ____this_20:fact("manualReview"):getIsTrue()
end
local ____lambda_7 = function(____this_23)
    return ____this_23:unaryPlus("age"):____in(__K2L_ClosedRange.new(30.0, 50.0, __K2L_DoubleToString))
end
local quoteRules = ____RuleDsl.ruleSet(function(self)
    self:rule("base premium", function(____this)
        ____this.priority = 100
        ____this.once = true
        ____this:whenever(____lambda_1)
        ____this:____then(function(____this_2)
            ____this_2:becomes__1("premium", 500)
            ____this_2:note("base premium set")
        end)
    end)
    self:rule("young driver", function(____this_3)
        ____this_3.priority = 90
        ____this_3.once = true
        ____this_3:whenever(____lambda_2)
        ____this_3:____then(function(____this_5)
            ____this_5:becomes("premium", ____this_5:invoke("premium"):times(1.5))
            ____this_5:note("young driver surcharge")
        end)
    end)
    self:rule("claims", function(____this_6)
        ____this_6.priority = 80
        ____this_6.once = true
        ____this_6:whenever(____lambda_3)
        ____this_6:____then(function(____this_8)
            ____this_8:becomes__2("risk", "high")
            ____this_8:note("high risk: claims=" .. __K2L_Str(____this_8:invoke("claims")) .. " points=" .. __K2L_Str(____this_8:invoke("points")))
        end)
    end)
    self:rule("high risk", function(____this_9)
        ____this_9.priority = 70
        ____this_9.once = true
        ____this_9:whenever(____lambda_4)
        ____this_9:____then(function(____this_11)
            ____this_11:becomes("premium", ____this_11:invoke("premium"):plus(____Facts.toValue(250)))
            ____this_11:becomes__3("manualReview", true)
        end)
    end)
    self:each(tiers, function(____this_12, ____destructured)
        local tier, discount = ____destructured.first, ____destructured.second
        ____this_12:rule("discount " .. tier, function(____this_13)
            ____this_13.priority = 60
            ____this_13.once = true
            ____this_13:whenever(function(____this_14)
                return ____this_14:unaryPlus("tier"):eq(tier):____and(____this_14:fact("risk"):getIsSet():____not()):____and(____this_14:fact("premium"):getIsSet())
            end)
            ____this_13:____then(function(____this_15)
                if discount > 0 then
                    ____this_15:becomes("premium", ____this_15:invoke("premium"):times(1 - discount))
                end
                ____this_15:note(tier .. " discount " .. __K2L_DoubleToInt(discount * 100) .. "%")
            end)
        end)
    end)
    self:rule("label", function(____this_16)
        ____this_16.priority = 10
        ____this_16:whenever(____lambda_5)
        ____this_16:____then(function(____this_18)
            ____this_18:becomes("label", ____Facts.toValue__2("quote: "):plus(____this_18:invoke("premium")))
        end)
    end)
    self:rule("cleanup", function(____this_19)
        ____this_19.priority = 5
        ____this_19.once = true
        ____this_19:whenever(____lambda_6)
        ____this_19:____then(function(____this_21)
            ____this_21:drop("tier")
            ____this_21:note("tier dropped for review")
        end)
    end)
    self:rule("mid age", function(____this_22)
        ____this_22:whenever(____lambda_7)
        ____this_22:____then(function(____this_24)
            ____this_24:becomes__2("band", "mid")
        end)
    end)
end)

local function quote(name, ...)
    local facts = __K2L_ArrayOf(...)
    print("== " .. name)
    local memory = ____Facts.Facts.new(__K2L_ReadOnlyMapOf(__K2L_Unpack(facts)))
    local engine = ____Engine.Engine.new(quoteRules)
    local notes = engine:run(memory, function(it)
        print(it)
    end)
    print("notes: " .. __K2L_Str(notes))
    print("facts: " .. __K2L_Str(memory) .. " (" .. engine.lastRounds .. " rounds)")
    local ____list = memory:getTrail()
    for ____i = 1, ____list.size do
        local it = ____list[____i]
        print("  " .. it)
    end
end

local ____lambda_8 = function(____this_27)
    return ____this_27:fact("x"):getIsSet()
end
local ____lambda_9 = function(____this_31) return ____this_31:always() end
local function main()
    local ____list_1 = quoteRules
    local ____mod = ____list_1.____modCount
    for ____i_1 = 1, ____list_1.size do
        local it = ____list_1[____i_1]
        print(__K2L_Str(it))
        if ____list_1.____modCount ~= ____mod and ____list_1:____comodified(____i_1) then
            break
        end
    end
    quote("ada", __K2L_Pair.new("age", ____Facts.toValue(34)), __K2L_Pair.new("claims", ____Facts.toValue(0)), __K2L_Pair.new("points", ____Facts.toValue(1)), __K2L_Pair.new("tier", ____Facts.toValue__2("gold")))
    quote("tom", __K2L_Pair.new("age", ____Facts.toValue(21)), __K2L_Pair.new("claims", ____Facts.toValue(3)), __K2L_Pair.new("points", ____Facts.toValue(0)), __K2L_Pair.new("tier", ____Facts.toValue__2("silver")))
    quote("kid", __K2L_Pair.new("age", ____Facts.toValue(16)), __K2L_Pair.new("tier", ____Facts.toValue__2("bronze")))
    quote("odd", __K2L_Pair.new("age", ____Facts.toValue__2("forty")), __K2L_Pair.new("claims", ____Facts.toValue(1)), __K2L_Pair.new("points", ____Facts.toValue(9)))
    local looping = ____RuleDsl.ruleSet(function(____this_25)
        ____this_25:rule("ping", function(____this_26)
            ____this_26:whenever(____lambda_8)
            ____this_26:____then(function(____this_28)
                local ____cast = ____this_28:invoke("x")
                if getmetatable(____cast) ~= ____Facts.Value.Num then
                    __K2L_CastFail(____cast, "rules.engine.Value$Num", "rules.engine.Value.Num")
                end
                ____this_28:becomes__1("x", ____cast.v + 1)
            end)
        end)
    end)
    local ____ok, ____result = __K2L_DeepPcall(function()
        ____Engine.Engine.new(looping, 4):run(____Facts.Facts.new(__K2L_SingletonMapOf(__K2L_Pair.new("x", ____Facts.toValue(0)))))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if getmetatable(____error) == ____Engine.RuleCycleException then
            local e = ____error
            print("cycle: " .. __K2L_Str(e.message) .. " after " .. e.rounds)
        else
            error(____error, 0)
        end
    end
    local ____ok_1, ____result_1 = __K2L_DeepPcall(function()
        ____RuleDsl.ruleSet(function(____this_29)
            ____this_29:rule("broken", function(____this_30)
                ____this_30:whenever(____lambda_9)
            end)
        end)
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error_1, __K2L_IllegalStateException) then
            local e = ____error_1
            print("invalid: " .. __K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
    local ____ok_2, ____result_2 = __K2L_DeepPcall(function()
        ____RuleDsl.ruleSet(function(____this_32)
            ____this_32:rule("no condition", function(____this_33)
                ____this_33:____then(function(____this_34)
                    ____this_34:note("x")
                end)
            end)
        end)
    end)
    if not ____ok_2 then
        local ____error_2 = __K2L_ToThrowable(____result_2)
        if __K2L_InstanceOf(____error_2, __K2L_IllegalStateException) then
            local e = ____error_2
            print("invalid: " .. __K2L_Str(e.message))
        else
            error(____error_2, 0)
        end
    end
    local f = ____Facts.Facts.new()
    f:plusAssign(__K2L_Pair.new("a", ____Facts.toValue(1)))
    f:set("b", ____Facts.toValue__2("two"))
    f:set("a", ____Facts.toValue(1))
    f:minusAssign("zzz")
    print(__K2L_Str(f) .. " " .. tostring(f:contains("a")) .. " " .. __K2L_Str(f:get("c")) .. " " .. tostring(__K2L_Compare(f:get("a"), f:get("a"):plus(____Facts.toValue(1))) < 0) .. " " .. __K2L_Str(____Facts.Value.Missing))
    print(__K2L_Str(__K2L_ReadOnlyListOf(____Facts.toValue(3), ____Facts.toValue__1(1.5), ____Facts.toValue(-2)):sorted()))
    print(__K2L_Str(__K2L_ReadOnlyListOf(____Facts.toValue__2("pear"), ____Facts.toValue__2("apple")):maxOrNull()))
    local ____ok_3, ____result_3 = __K2L_DeepPcall(function()
        __K2L_ReadOnlyListOf(____Facts.toValue(1), ____Facts.toValue__2("x")):sorted()
    end)
    if not ____ok_3 then
        local ____error_3 = __K2L_ToThrowable(____result_3)
        if __K2L_InstanceOf(____error_3, __K2L_IllegalArgumentException) then
            local e = ____error_3
            print("sort failed: " .. __K2L_Str(e.message))
        else
            error(____error_3, 0)
        end
    end
end

__K2L_DeepMain(main)
return {tiers = tiers, quoteRules = quoteRules, quote = quote}
