local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_List = ____lualib.__K2L_List
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32

local ____exports = {}
local Event = __K2L_Class("Event")
Event.Click = __K2L_Class("Event$Click", nil, Event)

function Event.Click:____init(x, y)
    self.x = x
    self.y = y
end

function Event.Click:toString()
    return "Click(x=" .. self.x .. ", y=" .. self.y .. ")"
end

function Event.Click:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.x) + __K2L_Hash(self.y))
end

function Event.Click:equals(other)
    return getmetatable(other) == Event.Click and self.x == other.x and self.y == other.y
end

Event.Key = __K2L_Class("Event$Key", nil, Event)

function Event.Key:____init(code, shift)
    self.code = code
    self.shift = shift
end

function Event.Key:toString()
    return "Key(code=" .. self.code .. ", shift=" .. tostring(self.shift) .. ")"
end

function Event.Key:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.code) + __K2L_Hash(self.shift))
end

function Event.Key:equals(other)
    return getmetatable(other) == Event.Key and self.code == other.code and self.shift == other.shift
end

Event.Tick = __K2L_Class("Event$Tick", nil, Event)

function Event.Tick:toString()
    return "Tick"
end

function Event.Tick:hashCode()
    return -1363347279
end

____exports.guardCalls = 0

local function big(n)
    ____exports.guardCalls = ____exports.guardCalls + 1
    return n > 100
end

local function classify(x)
    if x == nil then
        return "null"
    elseif math.type(x) == "integer" and x < 0 then
        return "negative"
    elseif math.type(x) == "integer" and big(x) then
        return "big"
    elseif math.type(x) == "integer" then
        if x == 0 then
            return "zero"
        elseif x >= 1 and x <= 9 then
            return "digit"
        else
            return "int"
        end
    elseif type(x) == "string" and #x == 0 then
        return "empty"
    elseif type(x) == "string" and __K2L_Text.first(x):match("^%u$") ~= nil then
        return "capitalized"
    elseif type(x) == "string" then
        return "text"
    elseif __K2L_InstanceOf(x, __K2L_List) then
        return "list of " .. x.size
    else
        return "other"
    end
end

local function describe(e, ____debug)
    if __K2L_InstanceOf(e, Event.Click) and e.x == e.y then
        return "diagonal click at " .. e.x
    elseif __K2L_InstanceOf(e, Event.Click) then
        return "click (" .. e.x .. ", " .. e.y .. ")"
    elseif __K2L_InstanceOf(e, Event.Key) and (e.shift and e.code:match("^%a$") ~= nil) then
        return "key " .. e.code:upper()
    elseif __K2L_InstanceOf(e, Event.Key) then
        return "key " .. e.code
    elseif __K2L_Equals(e, Event.Tick) and ____debug then
        return "tick (debug)"
    elseif __K2L_Equals(e, Event.Tick) then
        return "tick"
    end
end

local function main()
    print(__K2L_Str(__K2L_ReadOnlyListOf(-3, 0, 7, 42, 500, "", "Hello", "hey", __K2L_ReadOnlyListOf(1, 2), 2.5, nil):map(classify)))
    print("guard calls: " .. ____exports.guardCalls)
    local events = __K2L_ReadOnlyListOf(Event.Click.new(3, 3), Event.Click.new(1, 2), Event.Key.new("a", true), Event.Key.new("1", true), Event.Key.new("b", false), Event.Tick)
    print(__K2L_Str(events:map(function(it) return describe(it, false) end)))
    print(describe(Event.Tick, true))
    local n = 15
    local fizz
    local ____subject = math.fmod(n, 15)
    if ____subject == 0 then
        fizz = "FizzBuzz"
    elseif math.fmod(n, 3) == 0 then
        fizz = "Fizz"
    else
        fizz = tostring(n)
    end
    print(fizz)
end

____exports.Event = Event
____exports.big = big
____exports.classify = classify
____exports.describe = describe
main()
return ____exports
