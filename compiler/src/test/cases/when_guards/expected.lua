local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IsLetter = ____lualib.__K2L_IsLetter
local __K2L_IsUpperCase = ____lualib.__K2L_IsUpperCase
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Text = ____lualib.__K2L_Text

local ____exports = {}
local Event = __K2L_Class("Event")
Event.Click = __K2L_Class("Event$Click", nil, Event)

function Event.Click.new(x, y)
    return setmetatable({x = x, y = y}, Event.Click)
end

__K2L_DataClass(Event.Click, {"x", "y"})
Event.Key = __K2L_Class("Event$Key", nil, Event)

function Event.Key.new(code, shift)
    return setmetatable({code = code, shift = shift}, Event.Key)
end

__K2L_DataClass(Event.Key, {"code", "shift"})
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
    elseif type(x) == "string" and __K2L_IsUpperCase[__K2L_Text.first(x)] == true then
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
    local ____mt = getmetatable(e)
    if ____mt == Event.Click and e.x == e.y then
        return "diagonal click at " .. e.x
    elseif ____mt == Event.Click then
        return "click (" .. e.x .. ", " .. e.y .. ")"
    elseif ____mt == Event.Key and (e.shift and __K2L_IsLetter[e.code] == true) then
        return "key " .. e.code:upper()
    elseif ____mt == Event.Key then
        return "key " .. e.code
    elseif __K2L_Equals(e, Event.Tick) and ____debug then
        return "tick (debug)"
    elseif __K2L_Equals(e, Event.Tick) then
        return "tick"
    end
end

local function main()
    print(__K2L_Str(__K2L_ListOf(-3, 0, 7, 42, 500, "", "Hello", "hey", __K2L_ListOf(1, 2), 2.5, nil):map(classify)))
    print("guard calls: " .. ____exports.guardCalls)
    local events = __K2L_ListOf(Event.Click.new(3, 3), Event.Click.new(1, 2), Event.Key.new("a", true), Event.Key.new("1", true), Event.Key.new("b", false), Event.Tick)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = events:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = describe(it, false)
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    print(describe(Event.Tick, true))
    local n = 15
    local fizz
    local ____subject = n % 15
    if ____subject == 0 then
        fizz = "FizzBuzz"
    elseif n % 3 == 0 then
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
__K2L_RunMain(main)
return ____exports
