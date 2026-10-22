local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_NULL_ARGUMENT = ____lualib.__K2L_NULL_ARGUMENT
local __K2L_NullArgument = ____lualib.__K2L_NullArgument
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str

local Tag = __K2L_Class("Tag")

function Tag:____init(name, weight)
    if name == nil then
        name = "untitled"
    elseif name == __K2L_NULL_ARGUMENT then
        name = nil
    end
    if weight == nil then
        weight = 1
    end
    self.name = name
    self.weight = weight
end

function Tag:toString()
    return "Tag(name=" .. __K2L_Str(self.name) .. ", weight=" .. self.weight .. ")"
end

function Tag:hashCode()
    return (31 * __K2L_Hash(self.name) + self.weight + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Tag:equals(other)
    return getmetatable(other) == Tag and self.name == other.name and self.weight == other.weight
end

local Box = __K2L_Class("Box")

function Box:____init(value)
    if value == nil then
        value = 5
    elseif value == __K2L_NULL_ARGUMENT then
        value = nil
    end
    self.value = value
end

function Box:____init1(text, extra)
    if extra == nil then
        extra = "extra"
    elseif extra == __K2L_NULL_ARGUMENT then
        extra = nil
    end
    Box.____init(self, #text)
    print("secondary " .. text .. " " .. __K2L_Str(extra))
end

function Box.new1(text, extra)
    local self = setmetatable({}, Box)
    self:____init1(text, extra)
    return self
end

local function greet(name)
    if name == nil then
        name = "world"
    elseif name == __K2L_NULL_ARGUMENT then
        name = nil
    end
    return "hello " .. __K2L_Str(name)
end

local function suffixed(self, suffix)
    if suffix == nil then
        suffix = "!"
    elseif suffix == __K2L_NULL_ARGUMENT then
        suffix = nil
    end
    return self .. __K2L_Str(suffix)
end

local function orElse(value, fallback)
    if fallback == nil then
        fallback = value
    elseif fallback == __K2L_NULL_ARGUMENT then
        fallback = nil
    end
    return fallback
end

local Base = __K2L_Class("Base")

function Base:label(text)
    if text == nil then
        text = "base"
    elseif text == __K2L_NULL_ARGUMENT then
        text = nil
    end
    return "label " .. __K2L_Str(text)
end

local Derived = __K2L_Class("Derived", Base)

function Derived:label(text)
    if text == nil then
        text = "base"
    elseif text == __K2L_NULL_ARGUMENT then
        text = nil
    end
    return "derived " .. __K2L_Str(text)
end

local function shout(text)
    if text == nil then
        text = "hey"
    elseif text == __K2L_NULL_ARGUMENT then
        text = nil
    end
    return __K2L_Str(text) .. "!"
end

local function twice(first, second)
    if first == nil then
        first = "a"
    elseif first == __K2L_NULL_ARGUMENT then
        first = nil
    end
    if second == nil then
        second = "b"
    elseif second == __K2L_NULL_ARGUMENT then
        second = nil
    end
    return __K2L_Str(first) .. " " .. __K2L_Str(second)
end

local function visit(text, block)
    if text == nil then
        text = "default"
    elseif text == __K2L_NULL_ARGUMENT then
        text = nil
    end
    block(text)
end

local function firstSeen(value)
    do return "seen " .. __K2L_Str(value) end
    return "unseen"
end

local function main()
    local tag = Tag.new("kotlin", 2)
    print(__K2L_Str(Tag.new(__K2L_NULL_ARGUMENT, tag.weight)))
    local none = nil
    local some = "lua"
    print(__K2L_Str(Tag.new(__K2L_NullArgument(none), tag.weight)))
    print(__K2L_Str(Tag.new(__K2L_NullArgument(some), tag.weight)))
    print(__K2L_Str(Tag.new(tag.name, 3)))
    print(__K2L_Str(Tag.new(__K2L_NULL_ARGUMENT)))
    print(__K2L_Str(Tag.new()))
    print(__K2L_Str(Box.new(__K2L_NULL_ARGUMENT).value))
    print(__K2L_Str(Box.new().value))
    print(__K2L_Str(Box.new1("four", __K2L_NULL_ARGUMENT).value))
    print(__K2L_Str(Box.new1("six").value))
    print(greet(__K2L_NULL_ARGUMENT))
    print(greet(__K2L_NullArgument(none)))
    print(greet(__K2L_NullArgument(some)))
    print(greet())
    print(suffixed("x", __K2L_NULL_ARGUMENT))
    print(suffixed("x"))
    print(__K2L_Str(orElse("a", __K2L_NULL_ARGUMENT)))
    print(orElse("a"))
    local base = Derived.new()
    print(base:label(__K2L_NULL_ARGUMENT))
    print(base:label())
    print(Base.new():label(__K2L_NULL_ARGUMENT))
    print(shout(__K2L_NULL_ARGUMENT))
    print(shout())
    print(twice(nil, __K2L_NULL_ARGUMENT))
    print(twice(__K2L_NULL_ARGUMENT, __K2L_NullArgument(none)))
    local ____list = __K2L_ListOf("p", nil)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = greet(__K2L_NullArgument(it))
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    print(firstSeen(nil))
    print(firstSeen("v"))
end

__K2L_RunMain(main)
return {Tag = Tag, Box = Box, greet = greet, suffixed = suffixed, orElse = orElse, Base = Base, Derived = Derived, shout = shout, twice = twice, visit = visit, firstSeen = firstSeen}
