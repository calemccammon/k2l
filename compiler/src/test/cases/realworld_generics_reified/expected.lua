local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_EnumValueOf = ____lualib.__K2L_EnumValueOf
local __K2L_FunctionMixin = ____lualib.__K2L_FunctionMixin
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IsNumber = ____lualib.__K2L_IsNumber
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SimpleName = ____lualib.__K2L_SimpleName
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Codec = __K2L_Class("generics.reified.Codec")
local Registry = __K2L_Class("generics.reified.Registry")

function Registry:____init()
    self.codecs = __K2L_MapOf()
end

function Registry:register(____type, codec)
    if self.codecs:containsKey(____type) then
        error(__K2L_IllegalStateException.new("codec for " .. ____type .. " already registered"))
    end
    local ____object = self.codecs
    ____object:set(____type, codec)
end

function Registry:codecFor(____type)
    local ____cast = self.codecs:get(____type)
    if not (____cast == nil or __K2L_InstanceOf(____cast, Codec)) then
        __K2L_CastFail(____cast, "generics.reified.Codec")
    end
    if ____cast == nil then
        error(__K2L_IllegalArgumentException.new("no codec for " .. ____type))
    end
    return ____cast
end

function Registry:encodeAny(value)
    local ____cast_1 = self.codecs:get(__K2L_NotNull(__K2L_SimpleName(value)))
    if not (____cast_1 == nil or __K2L_InstanceOf(____cast_1, Codec)) then
        __K2L_CastFail(____cast_1, "generics.reified.Codec")
    end
    if ____cast_1 == nil then
        return "<" .. __K2L_Str(__K2L_SimpleName(value)) .. "?>"
    end
    local codec = ____cast_1
    return __K2L_Str(__K2L_SimpleName(value)) .. ":" .. codec:encode(value)
end

function Registry:getTypes()
    return self.codecs:getKeys():toList()
end

local Point = __K2L_Class("generics.reified.Point")

function Point:____init(x, y)
    self.x = x
    self.y = y
end

function Point.new(x, y)
    return setmetatable({x = x, y = y}, Point)
end

function Point:toString()
    return "Point(x=" .. self.x .. ", y=" .. self.y .. ")"
end

function Point:hashCode()
    return (31 * self.x + self.y + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Point:equals(other)
    return getmetatable(other) == Point and self.x == other.x and self.y == other.y
end

local Color = __K2L_Class("generics.reified.Color")

function Color:____init(r, g, b)
    self.r = r
    self.g = g
    self.b = b
end

function Color.new(r, g, b)
    return setmetatable({r = r, g = g, b = b}, Color)
end

function Color:toString()
    return string.format("#%02x%02x%02x", self.r, self.g, self.b)
end

function Color:hashCode()
    return (31 * (31 * self.r + self.g) + self.b + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Color:equals(other)
    return getmetatable(other) == Color and self.r == other.r and self.g == other.g and self.b == other.b
end

local Level = __K2L_Class("generics.reified.Level")

function Level:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Level:toString()
    return self.name
end

function Level:compareTo(other)
    return self.ordinal - other.ordinal
end

Level.LOW = Level.new("LOW", 0)
Level.MID = Level.new("MID", 1)
Level.HIGH = Level.new("HIGH", 2)
Level.____values = {Level.LOW, Level.MID, Level.HIGH}
local PointCodec = __K2L_Class("generics.reified.PointCodec", nil, Codec)

function PointCodec:encode(value)
    return value.x .. "," .. value.y
end

function PointCodec:decode(text)
    local ____value = __K2L_StringSplit(text, ",")
    local ____result
    do
        local x, y = ____value[1], ____value[2]
        ____result = Point.new(__K2L_StringToInt(__K2L_StringTrim(x)), __K2L_StringToInt(__K2L_StringTrim(y)))
    end
    return ____result
end

local Bag = __K2L_Class("generics.reified.Bag")

function Bag:____init()
    self.items = __K2L_ListOf()
end

function Bag:add(...)
    local xs = __K2L_ArrayOf(...)
    self.items:addAll(xs)
    return self
end

function Bag:items__1()
    return self.items
end

local Event = __K2L_Class("generics.reified.Event")

function Event:____init(at)
    self.at = at
end

function Event.new(at)
    return setmetatable({at = at}, Event)
end

local Click = __K2L_Class("generics.reified.Click", Event)

function Click:____init(at, x, y)
    Event.____init(self, at)
    self.x = x
    self.y = y
end

local Key = __K2L_Class("generics.reified.Key", Event)

function Key:____init(at, char)
    Event.____init(self, at)
    self.char = char
end

local Tick = __K2L_Class("generics.reified.Tick", Event)

function Tick:____init(at)
    Event.____init(self, at)
end

local Dispatcher = __K2L_Class("generics.reified.Dispatcher")

function Dispatcher:____init()
    self.handlers = __K2L_ListOf()
end

function Dispatcher:dispatch(e)
    local ____list = self.handlers
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local ____it = ____items[____i]
        local ____result_1
        do
            local accepts = ____it.first
            ____result_1 = accepts(e)
        end
        if ____result_1 then
            ____count = ____count + 1
            ____out[____count] = ____it
        end
    end
    local matching = __K2L_ListWrap(____out, ____count)
    for ____i_1 = 1, matching.size do
        local ____it_1 = matching[____i_1]
        do
            local h = ____it_1.second
            h(e)
        end
    end
    return matching.size
end

local ____lambda_1 = function(it) return __K2L_InstanceOf(it, Level) end
local ____lambda_2 = function(it) return type(it) == "boolean" end
local ____lambda_3 = function(it) return getmetatable(it) == Point end
local ____lambda_4 = function(it) return it:toString() end
local ____lambda_5 = function(it) return it.name:lower() end
local ____lambda_6 = function(it) return __K2L_EnumValueOf(Level, it:upper()) end
local ____lambda_7 = function(it) return __K2L_Num.toRadix(it, 16) end
local ____lambda_8 = function(it) return __K2L_StringToInt(it, 16) end
local ____lambda_9 = function(x) return getmetatable(x) == Point end
local ____lambda_10 = function(x) return __K2L_InstanceOf(x, Level) end
local ____lambda_11 = function(x) return __K2L_InstanceOf(x, Level) end
local ____lambda_12 = function(x) return math.type(x) == "integer" end
local ____lambda_13 = function(x) return math.type(x) == "integer" end
local ____lambda_14 = function(x) return x ~= nil end
local ____lambda_15 = function(x) return getmetatable(x) == Point end
local ____lambda_16 = function(x) return getmetatable(x) == Point end
local ____lambda_17 = function(____x) return getmetatable(____x) == Click end
local ____lambda_18 = function(x) return getmetatable(x) == Key end
local ____lambda_19 = function(x) return __K2L_InstanceOf(x, Event) end
local ____lambda_20 = function(____p1) return print(__K2L_Str(____p1)) end
local function main()
    print("== casts")
    local things = __K2L_ListOf(1, "two", 2.5, nil, true, __K2L_ListOf(5), Level.LOW)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = things:____array()
    for ____i_2 = 1, ____n_1 do
        local it = ____items_1[____i_2]
        local ____result_2
        do
            local ____result_3
            ____result_3 = math.type(it) == "integer" and it or nil
            ____result_2 = ____result_3
        end
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = ____result_2
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_2, ____n_2 = things:____array()
    for ____i_3 = 1, ____n_2 do
        local it = ____items_2[____i_3]
        local ____result_4
        do
            local ____result_5
            ____result_5 = type(it) == "string" and it or nil or "-"
            ____result_4 = ____result_5
        end
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = ____result_4
    end
    print(__K2L_Str(__K2L_ListWrap(____out_2, ____count_2)))
    local ____result_6
    do
        local ____result_7 = 0
        local ____items_3, ____n_3 = things:____array()
        for ____i_4 = 1, ____n_3 do
            local it = ____items_3[____i_4]
            if type(it) == "string" then
                ____result_7 = ____result_7 + 1
            end
        end
        ____result_6 = ____result_7
    end
    local ____arg = ____result_6
    local ____result_8
    do
        local ____result_9 = 0
        local ____items_4, ____n_4 = things:____array()
        for ____i_5 = 1, ____n_4 do
            local it = ____items_4[____i_5]
            if __K2L_IsNumber(it) then
                ____result_9 = ____result_9 + 1
            end
        end
        ____result_8 = ____result_9
    end
    local ____arg_1 = ____result_8
    local ____result_10
    do
        local ____result_11 = 0
        local ____items_5, ____n_5 = things:____array()
        for ____i_6 = 1, ____n_5 do
            local it = ____items_5[____i_6]
            if __K2L_InstanceOf(it, __K2L_List) then
                ____result_11 = ____result_11 + 1
            end
        end
        ____result_10 = ____result_11
    end
    print("strings=" .. ____arg .. " numbers=" .. ____arg_1 .. " lists=" .. ____result_10)
    local ____result_12
    do
        local ____cast_2 = things:firstOrNull(____lambda_1)
        if not (____cast_2 == nil or __K2L_InstanceOf(____cast_2, Level)) then
            __K2L_CastFail(____cast_2, "generics.reified.Level")
        end
        ____result_12 = ____cast_2
    end
    local ____arg_2 = __K2L_Str(____result_12)
    local ____result_13
    do
        local ____cast_3 = things:firstOrNull(____lambda_2)
        if not (____cast_3 == nil or type(____cast_3) == "boolean") then
            __K2L_CastFail(____cast_3, "kotlin.Boolean")
        end
        ____result_13 = ____cast_3
    end
    local ____arg_3 = __K2L_Str(____result_13)
    local ____result_14
    do
        local ____cast_4 = things:firstOrNull(____lambda_3)
        if not (____cast_4 == nil or getmetatable(____cast_4) == Point) then
            __K2L_CastFail(____cast_4, "generics.reified.Point")
        end
        ____result_14 = ____cast_4
    end
    print("firstEnum=" .. ____arg_2 .. " firstBoolean=" .. ____arg_3 .. " firstPoint=" .. __K2L_Str(____result_14))
    local ____result_15
    ____result_15 = "Point" or "?"
    local ____arg_4 = ____result_15
    local ____result_16
    ____result_16 = "Level" or "?"
    local ____arg_5 = ____result_16
    local ____result_17
    ____result_17 = "String" or "?"
    print("names: " .. ____arg_4 .. " " .. ____arg_5 .. " " .. ____result_17)
    print("== registry")
    local registry = Registry.new()
    do
        local codec = PointCodec
        registry:register(__K2L_NotNull("Point"), codec)
    end
    do
        local encode = ____lambda_4
        local decode = function(s)
            local ____list_1 = __K2L_Text.chunked(__K2L_Text.removePrefix(s, "#"), 2)
            local ____out_3 = {}
            local ____count_3 = 0
            local ____items_6, ____n_6 = ____list_1:____array()
            for ____i_7 = 1, ____n_6 do
                local it = ____items_6[____i_7]
                ____count_3 = ____count_3 + 1
                ____out_3[____count_3] = __K2L_StringToInt(it, 16)
            end
            local ____value_1 = __K2L_ListWrap(____out_3, ____count_3)
            local ____result_18
            do
                local r, g, b = ____value_1[1], ____value_1[2], ____value_1[3]
                ____result_18 = Color.new(r, g, b)
            end
            return ____result_18
        end
        local ____arg_6 = __K2L_NotNull("Color")
        local ____object_1 = __K2L_Class("generics.reified.Registry$register$1", nil, Codec)
        function ____object_1:encode(value)
            return encode(value)
        end
        function ____object_1:decode(text)
            return decode(text)
        end
        registry:register(____arg_6, ____object_1)
    end
    do
        local encode = ____lambda_5
        local decode = ____lambda_6
        local ____arg_7 = __K2L_NotNull("Level")
        local ____object_2 = __K2L_Class("generics.reified.Registry$register$1", nil, Codec)
        function ____object_2:encode(value)
            return encode(value)
        end
        function ____object_2:decode(text)
            return decode(text)
        end
        registry:register(____arg_7, ____object_2)
    end
    do
        local encode = ____lambda_7
        local decode = ____lambda_8
        local ____arg_8 = __K2L_NotNull("Int")
        local ____object_3 = __K2L_Class("generics.reified.Registry$register$1", nil, Codec)
        function ____object_3:encode(value)
            return encode(value)
        end
        function ____object_3:decode(text)
            return decode(text)
        end
        registry:register(____arg_8, ____object_3)
    end
    print("types=" .. __K2L_Str(registry:getTypes()))
    local ____result_19
    do
        local value = Point.new(3, -4)
        ____result_19 = registry:codecFor(__K2L_NotNull("Point")):encode(value)
    end
    local ____arg_9 = ____result_19 .. " "
    local ____result_20
    do
        local value = Color.new(255, 128, 0)
        ____result_20 = registry:codecFor(__K2L_NotNull("Color")):encode(value)
    end
    local ____arg_10 = ____arg_9 .. ____result_20 .. " "
    local ____result_21
    do
        local value = Level.HIGH
        ____result_21 = registry:codecFor(__K2L_NotNull("Level")):encode(value)
    end
    print(____arg_10 .. ____result_21)
    local ____result_22
    ____result_22 = registry:codecFor(__K2L_NotNull("Point")):decode(" 7, 8")
    local p = ____result_22
    local ____result_23
    ____result_23 = registry:codecFor(__K2L_NotNull("Color")):decode("#0a0b0c")
    local c = ____result_23
    local ____arg_11 = __K2L_Str(p)
    local ____arg_12 = p.x + p.y
    local ____arg_13 = __K2L_Str(c)
    local ____arg_14 = c.g
    local ____result_24
    ____result_24 = registry:codecFor(__K2L_NotNull("Level")):decode("mid")
    local ____arg_15 = ____result_24.ordinal
    local ____result_25
    ____result_25 = registry:codecFor(__K2L_NotNull("Int")):decode("ff")
    print("decoded " .. ____arg_11 .. " " .. ____arg_12 .. " " .. ____arg_13 .. " " .. ____arg_14 .. " " .. ____arg_15 .. " " .. ____result_25 + 1)
    local ____result_26
    if #"1,2;3,4;5,6" == 0 then
        ____result_26 = __K2L_ListOf()
    else
        local ____list_2 = __K2L_StringSplit("1,2;3,4;5,6", ";")
        local ____out_4 = {}
        local ____count_4 = 0
        local ____items_7, ____n_7 = ____list_2:____array()
        for ____i_8 = 1, ____n_7 do
            local it = ____items_7[____i_8]
            local ____result_27
            do
                local ____result_28
                ____result_28 = registry:codecFor(__K2L_NotNull("Point")):decode(it)
                ____result_27 = ____result_28
            end
            ____count_4 = ____count_4 + 1
            ____out_4[____count_4] = ____result_27
        end
        ____result_26 = __K2L_ListWrap(____out_4, ____count_4)
    end
    local ____list_3 = ____result_26
    local ____sum = 0
    local ____items_8, ____n_8 = ____list_3:____array()
    for ____i_9 = 1, ____n_8 do
        local it = ____items_8[____i_9]
        ____sum = ____sum + it.x * it.y
    end
    local ____result_29
    if #"" == 0 then
        ____result_29 = __K2L_ListOf()
    else
        local ____list_4 = __K2L_StringSplit("", ";")
        local ____out_5 = {}
        local ____count_5 = 0
        local ____items_9, ____n_9 = ____list_4:____array()
        for ____i_10 = 1, ____n_9 do
            local it = ____items_9[____i_10]
            local ____result_30
            do
                local ____result_31
                ____result_31 = registry:codecFor(__K2L_NotNull("Level")):decode(it)
                ____result_30 = ____result_31
            end
            ____count_5 = ____count_5 + 1
            ____out_5[____count_5] = ____result_30
        end
        ____result_29 = __K2L_ListWrap(____out_5, ____count_5)
    end
    print("list=" .. ____sum .. " empty=" .. __K2L_Str(____result_29))
    print(__K2L_ListOf(Point.new(1, 1), Level.LOW, 255, "text", Color.new(1, 2, 3)):joinToString(" ", nil, nil, nil, nil, function(it) return registry:encodeAny(it) end))
    local ____ok, ____result_32 = pcall(function()
        local ____result_33
        ____result_33 = registry:codecFor(__K2L_NotNull("String")):decode("x")
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_32)
        if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
            local e = ____error
            print("error: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    local ____ok_1, ____result_34 = pcall(function()
        do
            local codec = PointCodec
            registry:register(__K2L_NotNull("Point"), codec)
        end
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_34)
        if __K2L_InstanceOf(____error_1, __K2L_IllegalStateException) then
            local e = ____error_1
            print("error: " .. __K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
    print("== bag")
    local bag = Bag.new():add(Point.new(0, 0), "label", Point.new(2, 2), Level.MID, 42)
    local ____result_35
    ____result_35 = bag:items__1():filter(____lambda_9)
    local ____arg_18 = __K2L_Str(____result_35)
    local ____result_36
    do
        local ____result_37
        ____result_37 = bag:items__1():filter(____lambda_10)
        local ____value_2 = ____result_37:singleOrNull()
        if ____value_2 == nil then
            local ____arg_16 = __K2L_Str("Level")
            local ____result_38
            ____result_38 = bag:items__1():filter(____lambda_11)
            error(__K2L_IllegalStateException.new("expected one " .. ____arg_16 .. ", found " .. ____result_38.size))
        end
        ____result_36 = ____value_2
    end
    local ____arg_19 = __K2L_Str(____result_36)
    local ____result_39
    do
        local ____result_40
        ____result_40 = bag:items__1():filter(____lambda_12)
        local ____value_3 = ____result_40:singleOrNull()
        if ____value_3 == nil then
            local ____arg_17 = __K2L_Str("Int")
            local ____result_41
            ____result_41 = bag:items__1():filter(____lambda_13)
            error(__K2L_IllegalStateException.new("expected one " .. ____arg_17 .. ", found " .. ____result_41.size))
        end
        ____result_39 = ____value_3
    end
    local ____arg_20 = ____result_39 * 2
    local ____result_42
    ____result_42 = bag:items__1():filter(____lambda_14)
    print("points=" .. ____arg_18 .. " level=" .. ____arg_19 .. " int=" .. ____arg_20 .. " any=" .. ____result_42.size)
    local ____ok_2, ____result_43 = pcall(function()
        local ____result_44
        do
            local ____result_45
            ____result_45 = bag:items__1():filter(____lambda_15)
            local ____value_4 = ____result_45:singleOrNull()
            if ____value_4 == nil then
                local ____arg_21 = __K2L_Str("Point")
                local ____result_46
                ____result_46 = bag:items__1():filter(____lambda_16)
                error(__K2L_IllegalStateException.new("expected one " .. ____arg_21 .. ", found " .. ____result_46.size))
            end
            ____result_44 = ____value_4
        end
    end)
    if not ____ok_2 then
        local ____error_2 = __K2L_ToThrowable(____result_43)
        if __K2L_InstanceOf(____error_2, __K2L_IllegalStateException) then
            local e = ____error_2
            print("error: " .. __K2L_Str(e.message))
        else
            error(____error_2, 0)
        end
    end
    print("== dispatcher")
    local d = Dispatcher.new()
    local log = __K2L_ListOf()
    do
        local handler = function(it)
            log:add("click " .. it.x .. "," .. it.y .. "@" .. it.at)
        end
        local ____arg_23 = d.handlers
        local ____arg_22 = ____lambda_17
        if not (type(handler) == "function" or __K2L_InstanceOf(handler, __K2L_FunctionMixin)) then
            __K2L_CastFail(handler, "kotlin.Function1")
        end
        ____arg_23:add(__K2L_Pair.new(____arg_22, handler))
    end
    do
        local handler = function(it)
            log:add("key " .. it.char:upper() .. "@" .. it.at)
        end
        local ____arg_25 = d.handlers
        local ____arg_24 = ____lambda_18
        if not (type(handler) == "function" or __K2L_InstanceOf(handler, __K2L_FunctionMixin)) then
            __K2L_CastFail(handler, "kotlin.Function1")
        end
        ____arg_25:add(__K2L_Pair.new(____arg_24, handler))
    end
    do
        local handler = function(it)
            log:add("any@" .. it.at)
        end
        local ____arg_27 = d.handlers
        local ____arg_26 = ____lambda_19
        if not (type(handler) == "function" or __K2L_InstanceOf(handler, __K2L_FunctionMixin)) then
            __K2L_CastFail(handler, "kotlin.Function1")
        end
        ____arg_27:add(__K2L_Pair.new(____arg_26, handler))
    end
    local counts = __K2L_ListOf(Click.new(1, 10, 20), Key.new(2, "q"), Tick.new(3), Click.new(4, 0, 0)):map(function(...) return d:dispatch(...) end)
    print("counts=" .. __K2L_Str(counts))
    for ____i_11 = 1, log.size do
        local it = log[____i_11];
        (____lambda_20)(it)
    end
end

__K2L_RunMain(main)
return {Codec = Codec, Registry = Registry, Point = Point, Color = Color, Level = Level, PointCodec = PointCodec, Bag = Bag, Event = Event, Click = Click, Key = Key, Tick = Tick, Dispatcher = Dispatcher}
