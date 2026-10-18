local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder

local Builder = __K2L_Class("Builder")

function Builder:____init()
    self.parts = __K2L_ListOf()
    self.prefix = ">"
end

function Builder:unaryPlus(____this)
    self.parts:add(self.prefix .. ____this)
end

function Builder:times(____this_1, s)
    local r = ""
    for i = 0, ____this_1 - 1 do
        r = r .. s
    end
    return r .. self.prefix
end

function Builder:joinWith(____this_2, other)
    return ____this_2 .. "," .. other .. self.prefix
end

function Builder:shout(____this_3)
    return ____this_3:upper() .. "!" .. self.parts.size
end

function Builder:plus(____this_4, n)
    return ____this_4 .. "#" .. n
end

function Builder:plus__1(____this_5, s)
    return ____this_5 .. "#" .. s
end

function Builder:getTag(____this_6)
    return "<" .. ____this_6 .. self.prefix .. ">"
end

function Builder:setTag(____this_6, v)
    self.prefix = v .. #____this_6
end

function Builder:getDoubled(____this_7)
    return ____this_7 * 2 + self.parts.size
end

function Builder:run()
    self:unaryPlus("a")
    self:unaryPlus("b")
    local x = self:times(3, "z")
    self:setTag("q", "!")
    return x .. " " .. self:joinWith("l", "r") .. " " .. self:shout("hey") .. " " .. self:getTag("t") .. " " .. self:getDoubled(4)
end

function Builder:twice(____this_8)
    return ____this_8 .. self:shout(____this_8)
end

function Builder:go()
    return self:twice("ab")
end

function Builder:both()
    return "s" .. 1 .. "|" .. self:plus__1(2, "t")
end

local Counter = __K2L_Class("Counter")

function Counter:____init()
    self.count = 0
end

function Counter:bump(____this_9)
    self.count = self.count + ____this_9
    return self.count
end

function Counter:invoke(____this_10)
    return "invoked " .. ____this_10 .. " with " .. self.count
end

function Counter:getScaled(____this_11)
    return ____this_11 * self.count
end

function Counter:setScaled(____this_11, v)
    self.count = __K2L_IDiv(v, ____this_11 == 0 and 1 or ____this_11)
end

function Counter:demo()
    local a = self:bump(3)
    local b = self:bump(4)
    self:setScaled(2, 20)
    local c = self:getScaled(5)
    local d = self:invoke(7)
    return a .. " " .. b .. " " .. c .. " " .. d
end

local Formatter = __K2L_Class("Formatter")

function Formatter:format(____this_12)
    return "[" .. ____this_12 .. "]"
end

function Formatter:render(s)
    return self:format(s)
end

local Loud = __K2L_Class("Loud", nil, Formatter)

function Loud:format(____this_13)
    return ____this_13:upper() .. "!"
end

local Plainer = __K2L_Class("Plainer", nil, Formatter)
local Registry = __K2L_Class("Registry")

function Registry:____init()
    self.names = __K2L_ListOf()
end

function Registry:unaryPlus(____this_14)
    self.names:add(____this_14)
end

function Registry:register(____this_15, times)
    for i = 0, times - 1 do
        self.names:add(____this_15 .. i)
    end
end

function Registry:fill()
    self:unaryPlus("first")
    self:register("gen", 2)
end

Registry:____init()
local Outer = __K2L_Class("Outer")

function Outer:____init(tag)
    self.tag = tag
end

Outer.Inner = __K2L_Class("Inner")

function Outer.Inner:____init(____outer, id)
    self.____outer = ____outer
    self.id = id
end

function Outer.Inner:label(____this_16)
    return ____this_16 .. "@" .. self.id .. "/" .. self.____outer.tag .. "/" .. self.____outer.tag
end

function Outer.Inner:show()
    return self:label("x")
end

function Outer:mark(____this_17)
    return ____this_17 .. self.tag
end

function Outer:nested()
    return Outer.Inner.new(self, 5):show() .. " " .. self:mark("m")
end

local Html = __K2L_Class("Html")

function Html:____init()
    self.sb = __K2L_StringBuilder.new()
    self.depth = 0
end

function Html:tag(name, body)
    self.sb:append(("  "):rep(self.depth)):append("<"):append(name):append(">\n")
    self.depth = self.depth + 1
    body(self)
    self.depth = self.depth - 1
end

function Html:unaryPlus(____this_18)
    self.sb:append(("  "):rep(self.depth)):append(____this_18):append("\n")
end

function Html:bold(____this_19)
    return "*" .. ____this_19 .. "*"
end

function Html:toString()
    return self.sb:toString()
end

local function html(body)
    local h = Html.new()
    body(h)
    return h
end

local Maybe = __K2L_Class("Maybe")

function Maybe:____init(value)
    self.value = value
end

function Maybe:orDash(____this_20)
    return ____this_20 or "-"
end

function Maybe:show()
    local ____arg = self:orDash(self.value)
    local ____receiver = self.value
    return ____arg .. (____receiver and self:orDash(____receiver) or "?")
end

local Vec = __K2L_Class("Vec")

function Vec:____init(x)
    self.x = x
end

function Vec:unaryMinus()
    return Vec.new(-self.x)
end

function Vec:unaryPlus()
    return Vec.new(self.x + 100)
end

function Vec:____not()
    return self.x == 0
end

function Vec:toString()
    return "Vec(" .. self.x .. ")"
end

local function main()
    print(__K2L_Str(Vec.new(3):unaryMinus()))
    print(__K2L_Str(Vec.new(3):unaryPlus()))
    print(Vec.new(0):____not())
    print(Vec.new(1):____not())
    local b = Builder.new()
    print(b:run())
    print(__K2L_Str(b.parts))
    b:unaryPlus("c")
    print(b:times(2, "k"))
    print(b:shout("w"))
    print(b:getDoubled(5))
    print(b:getTag("zz"))
    print(b:joinWith("x", "y"))
    print(b.parts.size)
    print("p" .. 3)
    print(b:plus__1(4, "q"))
    b:unaryPlus("d")
    print(__K2L_Str(b.parts))
    print(b:go())
    print(b:both())
    print(Counter.new():demo())
    print(Loud.new():render("hi"))
    print(Plainer.new():render("hi"))
    Registry:fill()
    local ____value = Registry
    ____value:unaryPlus("last")
    ____value:register("more", 1)
    print(__K2L_Str(Registry.names))
    print(Outer.new("T"):nested())
    local page = html(function(self)
        self:tag("body", function(____this_21)
            ____this_21:unaryPlus("hello")
            ____this_21:tag("p", function(____this_22)
                ____this_22:unaryPlus(____this_22:bold("world"))
            end)
        end)
    end)
    io.write(__K2L_Str(page))
    print(Maybe.new("v"):show())
    print(Maybe.new(nil):show())
end

main()
return {Builder = Builder, Counter = Counter, Formatter = Formatter, Loud = Loud, Plainer = Plainer, Registry = Registry, Outer = Outer, Html = Html, html = html, Maybe = Maybe, Vec = Vec}
