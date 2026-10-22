local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str

local Wrapper = __K2L_Class("Wrapper")

function Wrapper:____init(obj, hash)
    self.obj = obj
    self.hash = hash
end

function Wrapper.new(obj, hash)
    return setmetatable({obj = obj, hash = hash}, Wrapper)
end

function Wrapper:____init1(obj)
    Wrapper.____init(self, obj, -1)
end

function Wrapper.new1(obj)
    local self = setmetatable({}, Wrapper)
    self:____init1(obj)
    return self
end

function Wrapper:toString()
    return "Wrapper(" .. __K2L_Str(self.obj) .. ", " .. self.hash .. ")"
end

local Base = __K2L_Class("Base")

function Base:____init(label)
    self.label = label
end

function Base.new(label)
    return setmetatable({label = label}, Base)
end

local Derived = __K2L_Class("Derived", Base)

function Derived:____init()
    Base.____init(self, "derived")
end

local Outer = __K2L_Class("Outer")
Outer.Inner = __K2L_Class("Outer$Inner")

function Outer.Inner:____init(____outer, n)
    self.____outer = ____outer
    self.n = n
end

local function main()
    print(__K2L_Str(Wrapper.new(1, 0)))
    print(__K2L_Str(Wrapper.new1(2)))
    print(__K2L_Str(Wrapper.new("s", 3)))
    print(__K2L_Str(Wrapper.new(4, 5)))
    print(Base.new("base").label)
    print(Derived.new().label)
    local make = Wrapper.new
    print(__K2L_Str(make(6, 7)))
    print(__K2L_Str(__K2L_ListOf(1, 2):map(Wrapper.new1)))
    print(Outer.Inner.new(Outer.new(), 8).n)
end

__K2L_RunMain(main)
return {Wrapper = Wrapper, Base = Base, Derived = Derived, Outer = Outer}
