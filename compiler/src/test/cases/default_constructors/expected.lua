local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_NULL_ARGUMENT = ____lualib.__K2L_NULL_ARGUMENT
local __K2L_NullArgument = ____lualib.__K2L_NullArgument
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str

local ____exports = {}
____exports.made = 0

local function fresh()
    ____exports.made = ____exports.made + 1
    print("fresh " .. ____exports.made)
    return ____exports.made
end

local Options = __K2L_Class("app.Options")

function Options.new(size, label, id)
    if size == nil then
        size = 10
    end
    if label == nil then
        label = "x" .. size
    end
    if id == nil then
        id = fresh()
    end
    return setmetatable({size = size, label = label, id = id}, Options)
end

__K2L_DataClass(Options, {"size", "label", "id"})
local Maybe = __K2L_Class("app.Maybe")

function Maybe.new(name, alias, tags)
    if name == nil then
        name = "anon"
    elseif name == __K2L_NULL_ARGUMENT then
        name = nil
    end
    if tags == nil then
        tags = __K2L_ListOf()
    end
    return setmetatable({name = name, alias = alias, tags = tags}, Maybe)
end

__K2L_DataClass(Maybe, {"name", "alias", "tags"})
local Plain = __K2L_Class("app.Plain")

function Plain.new(a, b)
    if b == nil then
        b = a * 2
    end
    return setmetatable({a = a, b = b}, Plain)
end

local Base = __K2L_Class("app.Base")

function Base:____init(level, name)
    if level == nil then
        level = 1
    end
    if name == nil then
        name = "base"
    elseif name == __K2L_NULL_ARGUMENT then
        name = nil
    end
    self.level = level
    self.name = name
end

function Base.new(level, name)
    if level == nil then
        level = 1
    end
    if name == nil then
        name = "base"
    elseif name == __K2L_NULL_ARGUMENT then
        name = nil
    end
    return setmetatable({level = level, name = name}, Base)
end

local Derived = __K2L_Class("app.Derived", Base)

function Derived:____init(level)
    Base.____init(self, level)
end

local Twice = __K2L_Class("app.Twice")

function Twice:____init(n)
    if n == nil then
        n = 1
    end
    self.n = n
end

function Twice.new(n)
    if n == nil then
        n = 1
    end
    return setmetatable({n = n}, Twice)
end

function Twice:____init1(s)
    Twice.____init(self, #s)
end

function Twice.new1(s)
    local self = setmetatable({}, Twice)
    self:____init1(s)
    return self
end

local function main()
    print(__K2L_Str(Options.new()))
    print(__K2L_Str(Options.new(3)))
    print(__K2L_Str(Options.new(nil, "given", 0)))
    print(____exports.made)
    print(__K2L_Str(Maybe.new()))
    print(__K2L_Str(Maybe.new(__K2L_NULL_ARGUMENT)))
    print(__K2L_Str(Maybe.new(__K2L_NULL_ARGUMENT, "a")))
    local nothing = nil
    print(__K2L_Str(Maybe.new(__K2L_NullArgument(nothing), nothing)))
    local m = Maybe.new("n", "a", __K2L_ListOf("t"))
    print(__K2L_Str(Maybe.new(__K2L_NULL_ARGUMENT, m.alias, m.tags)))
    print(__K2L_Str(Maybe.new(m.name, nothing, m.tags)))
    local p = Plain.new(4)
    print(p.a .. " " .. p.b)
    print(Plain.new(1, 1).b)
    local base = Base.new(nil, __K2L_NULL_ARGUMENT)
    print(base.level .. " " .. __K2L_Str(base.name))
    local d = Derived.new(5)
    print(d.level .. " " .. __K2L_Str(d.name))
    print(Twice.new1("four").n)
    print(Twice.new().n)
end

____exports.fresh = fresh
____exports.Options = Options
____exports.Maybe = Maybe
____exports.Plain = Plain
____exports.Base = Base
____exports.Derived = Derived
____exports.Twice = Twice
__K2L_RunMain(main)
return ____exports
