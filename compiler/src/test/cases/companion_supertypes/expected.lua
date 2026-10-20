-- ==== main.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_KClassOf = ____lualib.__K2L_KClassOf
local __K2L_LazyObject = ____lualib.__K2L_LazyObject
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_TouchObject = ____lualib.__K2L_TouchObject

local ____factory = require("model.factory")
local ____token = require("model.token")
local Circle
local Named = __K2L_Class("app.Named")
__K2L_ClassInfo(Named, "app.Named", "app.Named", "interface")
local Registry = __K2L_Class("app.Registry")
__K2L_ClassInfo(Registry, "app.Registry", "app.Registry", "class")

function Registry:____init(prefix)
    self.prefix = prefix
    self.items = __K2L_ListOf()
end

function Registry:register(s)
    self.items:add(self.prefix .. s)
end

function Registry:describe()
    return "Registry" .. __K2L_Str(self.items)
end

local Foo = __K2L_Class("app.Foo")
__K2L_ClassInfo(Foo, "app.Foo", "app.Foo", "class")

function Foo:____init(n)
    self.n = n
end

function Foo.new(n)
    return setmetatable({n = n}, Foo)
end

function Foo:next()
    return Foo.Companion:create()
end

function Foo:toString()
    return "Foo(" .. self.n .. ")"
end

Foo.Companion = __K2L_Class("app.Foo$Companion", nil, ____factory.Factory, Named)
__K2L_ClassInfo(Foo.Companion, "app.Foo.Companion", "app.Foo$Companion", "class")

function Foo.Companion:____init()
    self.count = 0
    self.label__Companion = "foo"
    self.MAX = 10
end

function Foo.Companion:create()
    self.count = self.count + 1
    return Foo.new(self.count)
end

function Foo.Companion:getLabel()
    return self.label__Companion
end

function Foo.Companion:reset()
    self.count = 0
end

Foo.Companion:____init()
local Bar = __K2L_Class("app.Bar")
__K2L_ClassInfo(Bar, "app.Bar", "app.Bar", "class")
Bar.Maker = __K2L_Class("app.Bar$Maker", Registry)
__K2L_ClassInfo(Bar.Maker, "app.Bar.Maker", "app.Bar$Maker", "class")

function Bar.Maker:____init()
    Registry.____init(self, "bar:")
    print("Bar companion init")
end

function Bar.Maker:size()
    return 2
end

function Bar.Maker:describe()
    return "Maker " .. Registry.describe(self)
end

__K2L_LazyObject(Bar.Maker, "____init")

function Bar:____initCompanion()
    __K2L_TouchObject(Bar.Maker)
end

__K2L_LazyObject(Bar, "____initCompanion")
local Baz = __K2L_Class("app.Baz")
__K2L_ClassInfo(Baz, "app.Baz", "app.Baz", "class")

function Baz:____init()
    print("Baz instance")
end

Baz.Companion = __K2L_Class("app.Baz$Companion", nil, Named)
__K2L_ClassInfo(Baz.Companion, "app.Baz.Companion", "app.Baz$Companion", "class")

function Baz.Companion:____init()
    print("Baz companion init")
end

function Baz.Companion:getLabel()
    return "baz"
end

__K2L_LazyObject(Baz.Companion, "____init")

function Baz:____initCompanion()
    __K2L_TouchObject(Baz.Companion)
end

__K2L_LazyObject(Baz, "____initCompanion")
local Shape = __K2L_Class("app.Shape")
__K2L_ClassInfo(Shape, "app.Shape", "app.Shape", "class")
Shape.Companion = __K2L_Class("app.Shape$Companion", nil, ____factory.Factory)
__K2L_ClassInfo(Shape.Companion, "app.Shape.Companion", "app.Shape$Companion", "class")

function Shape.Companion:create()
    return Circle
end

function Shape.Companion:getKind()
    return "shapes"
end

Circle = __K2L_Class("app.Circle", Shape)
__K2L_ClassInfo(Circle, "app.Circle", "app.Circle", "class")

function Circle:toString()
    return "Circle"
end

local Codec = __K2L_Class("app.Codec")
__K2L_ClassInfo(Codec, "app.Codec", "app.Codec", "interface")
Codec.Companion = __K2L_Class("app.Codec$Companion", nil, Codec)
__K2L_ClassInfo(Codec.Companion, "app.Codec.Companion", "app.Codec$Companion", "class")

function Codec.Companion:encode(s)
    return s:reverse()
end

local Upper = __K2L_Class("app.Upper", nil, Codec)
__K2L_ClassInfo(Upper, "app.Upper", "app.Upper", "class")

function Upper:encode(s)
    return s:upper()
end

local Labeled = __K2L_Class("app.Labeled", nil, Named)
__K2L_ClassInfo(Labeled, "app.Labeled", "app.Labeled", "class")

function Labeled:____init(label)
    self.label = label
end

function Labeled.new(label)
    return setmetatable({label = label}, Labeled)
end

function Labeled:getLabel()
    return self.label
end

local Tagged = __K2L_Class("app.Tagged")
__K2L_ClassInfo(Tagged, "app.Tagged", "app.Tagged", "class")
Tagged.Companion = __K2L_Class("app.Tagged$Companion", Labeled)
__K2L_ClassInfo(Tagged.Companion, "app.Tagged.Companion", "app.Tagged$Companion", "class")

function Tagged.Companion:____init()
    Labeled.____init(self, "tagged")
end

Tagged.Companion:____init()
local Outer = __K2L_Class("app.Outer")
__K2L_ClassInfo(Outer, "app.Outer", "app.Outer", "class")
Outer.Inner = __K2L_Class("app.Outer$Inner")
__K2L_ClassInfo(Outer.Inner, "app.Outer.Inner", "app.Outer$Inner", "class")

function Outer.Inner:____init(tag)
    self.tag = tag
end

function Outer.Inner.new(tag)
    return setmetatable({tag = tag}, Outer.Inner)
end

function Outer.Inner:toString()
    return "Inner(" .. self.tag .. ")"
end

Outer.Inner.Companion = __K2L_Class("app.Outer$Inner$Companion", nil, ____factory.Factory)
__K2L_ClassInfo(Outer.Inner.Companion, "app.Outer.Inner.Companion", "app.Outer$Inner$Companion", "class")

function Outer.Inner.Companion:create()
    return Outer.Inner.new("inner")
end

local Box = __K2L_Class("app.Box")
__K2L_ClassInfo(Box, "app.Box", "app.Box", "class")

function Box:____init(value)
    self.value = value
end

function Box.new(value)
    return setmetatable({value = value}, Box)
end

function Box:toString()
    return "Box(" .. __K2L_Str(self.value) .. ")"
end

Box.Companion = __K2L_Class("app.Box$Companion", nil, ____factory.Factory)
__K2L_ClassInfo(Box.Companion, "app.Box.Companion", "app.Box$Companion", "class")

function Box.Companion:create()
    return Box.new(42)
end

local function make(f)
    return f:create()
end

local function encodeAll(codecs, s)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = codecs:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = it:encode(s)
    end
    return __K2L_ListWrap(____out, ____count)
end

local function main()
    local f = Foo.Companion
    print(__K2L_Str(f:create()))
    print(__K2L_Str(make(Foo.Companion)))
    print(__K2L_Str(Foo.Companion:twice()))
    local ____value = Foo.Companion
    print(__K2L_InstanceOf(____value, ____factory.Factory))
    local a = Foo.Companion
    print(__K2L_InstanceOf(a, Named))
    if not __K2L_InstanceOf(a, Named) then
        __K2L_CastFail(a, "app.Named", "app.Named")
    end
    print(a:getLabel())
    print(__K2L_Str(__K2L_InstanceOf(a, Registry) and a or nil))
    print(10 + Foo.Companion.count)
    print(__K2L_Str(Foo.new(0):next()))
    Foo.Companion:reset()
    print(__K2L_Str(Foo.Companion:create()))
    print(f == Foo.Companion)
    print(f:getKind())
    print("before Bar")
    Bar.Maker:register("x")
    local r = __K2L_TouchObject(Bar.Maker)
    r:register("y")
    print(r:describe() .. " " .. r:size() .. " " .. Bar.Maker.prefix)
    print(__K2L_TouchObject(Bar.Maker) == r)
    print("before Baz")
    Baz.new()
    local n = __K2L_TouchObject(Baz.Companion)
    print(n:getLabel())
    local shapes = __K2L_ReadOnlyListOf(Foo.Companion, Shape.Companion, Outer.Inner.Companion, Box.Companion)
    local ____mod = shapes.____modCount
    for ____i_1 = 1, shapes.size do
        local s = shapes[____i_1]
        print(s:getKind() .. " " .. __K2L_Str(s:create()))
        if shapes.____modCount ~= ____mod and shapes:____comodified(____i_1) then
            break
        end
    end
    local x = Shape.Companion
    if __K2L_InstanceOf(x, ____factory.Factory) then
        print("factory " .. __K2L_Str(x:create()))
    else
        print("other")
    end
    print(__K2L_Str(encodeAll(__K2L_ReadOnlyListOf(Codec.Companion, Upper.new(), Codec.Companion), "abc")))
    local ____arg = Tagged.Companion:getLabel() .. " "
    local ____value_1 = Tagged.Companion
    print(____arg .. tostring(__K2L_InstanceOf(____value_1, Labeled)))
    local ____list = __K2L_ReadOnlyListOf(Foo.Companion, Tagged.Companion, __K2L_TouchObject(Baz.Companion))
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list:____array()
    for ____i_2 = 1, ____n_1 do
        local it = ____items_1[____i_2]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = it:getLabel()
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
    print(____token.Token.Companion:parse("id") .. " " .. make(____token.Token.Companion).text)
    print(__K2L_Str(__K2L_KClassOf(Foo.Companion).simpleName) .. " " .. __K2L_Str(__K2L_KClassOf(Bar.Maker).simpleName))
end

main()
return {Named = Named, Registry = Registry, Foo = Foo, Bar = Bar, Baz = Baz, Shape = Shape, Circle = Circle, Codec = Codec, Upper = Upper, Labeled = Labeled, Tagged = Tagged, Outer = Outer, Box = Box, make = make, encodeAll = encodeAll}
-- ==== model/factory.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf

local Factory = __K2L_Class("app.model.Factory")
__K2L_ClassInfo(Factory, "app.model.Factory", "app.model.Factory", "interface")

function Factory:twice()
    return __K2L_ReadOnlyListOf(self:create(), self:create())
end

function Factory:getKind()
    return "factory"
end

return {Factory = Factory}
-- ==== model/token.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo

local ____factory = require("model.factory")
local Token = __K2L_Class("app.model.Token")
__K2L_ClassInfo(Token, "app.model.Token", "app.model.Token", "class")

function Token:____init(text)
    self.text = text
end

function Token.new(text)
    return setmetatable({text = text}, Token)
end

Token.Companion = __K2L_Class("app.model.Token$Companion", nil, ____factory.Factory)
__K2L_ClassInfo(Token.Companion, "app.model.Token.Companion", "app.model.Token$Companion", "class")

function Token.Companion:parse(s)
    return "<" .. s .. ">"
end

function Token.Companion:create()
    return Token.new("made")
end

return {Token = Token}
