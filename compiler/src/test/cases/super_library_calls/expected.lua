local ____lualib = require("lualib_bundle")
local __K2L_AnyToString = ____lualib.__K2L_AnyToString
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_IdentityHash = ____lualib.__K2L_IdentityHash
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringIndexOf = ____lualib.__K2L_StringIndexOf
local __K2L_Throwable = ____lualib.__K2L_Throwable
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function shape(s)
    local at = __K2L_StringIndexOf(s, "@")
    local hex = s:sub(at + 1 + 1)
    local isHex = #hex > 0
    for c in hex:gmatch(".") do
        if not (c >= "0" and c <= "9" or c >= "a" and c <= "f") then
            isHex = false
        end
    end
    return s:sub(1, at) .. "@" .. (isHex and "<hex>" or hex)
end

local Plain = __K2L_Class("Plain")

function Plain:toString()
    return "Plain:" .. shape(__K2L_AnyToString(self))
end

local Derived = __K2L_Class("Derived", Plain)

function Derived:toString()
    return "Derived>" .. Plain.toString(self)
end

local Identity = __K2L_Class("Identity")

function Identity:____init(id)
    self.id = id
end

function Identity:equals(other)
    return self == other
end

function Identity:hashCode()
    return __K2L_IdentityHash(self)
end

local Mixed = __K2L_Class("Mixed")

function Mixed:____init(id)
    self.id = id
end

function Mixed:equals(other)
    return self == other or __K2L_InstanceOf(other, Mixed) and other.id == self.id
end

function Mixed:hashCode()
    return self.id
end

local Hashed = __K2L_Class("Hashed")

function Hashed:____init(id)
    self.id = id
end

function Hashed:hashCode()
    return __K2L_IdentityHash(self)
end

function Hashed:toString()
    return shape(__K2L_AnyToString(self))
end

local MyException = __K2L_Class("MyException", __K2L_Exception)

function MyException:____init(code)
    __K2L_Exception.____init(self, "boom")
    self.code = code
end

function MyException:toString()
    return "MyException[" .. __K2L_Throwable.toString(self) .. "] message=" .. __K2L_Str(self.message) .. " cause=" .. __K2L_Str(self.cause)
end

local Wrapping = __K2L_Class("Wrapping", __K2L_RuntimeException)

function Wrapping:____init(cause)
    __K2L_RuntimeException.____init(self, "wrapped", cause)
end

function Wrapping:describe()
    local ____receiver = self.cause
    return __K2L_Str(self.message) .. " <- " .. __K2L_Str(____receiver and ____receiver.message)
end

local Base = __K2L_Class("Base", __K2L_IllegalStateException)

function Base:____init(message)
    __K2L_IllegalStateException.____init(self, message)
end

local Leaf = __K2L_Class("Leaf", Base)

function Leaf:____init()
    Base.____init(self, "leaf")
end

function Leaf:toString()
    return "Leaf!" .. __K2L_Throwable.toString(self)
end

local Color = __K2L_Class("Color")

function Color:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Color:plain()
    return self.name
end

function Color:toString()
    return self.name
end

Color.RED = Color.new("RED", 0)
do
    local ____GREEN = __K2L_Class("Color", Color)
    function ____GREEN:toString()
        return "green(" .. self.name .. ")"
    end
    Color.GREEN = ____GREEN.new("GREEN", 1)
end
Color.____values = {Color.RED, Color.GREEN}
local Singleton = __K2L_Class("Singleton")

function Singleton:toString()
    return "Singleton:" .. shape(__K2L_AnyToString(self))
end

local function main()
    print(__K2L_Str(Plain.new()))
    print(__K2L_Str(Derived.new()))
    local a = Identity.new(1)
    local b = Identity.new(1)
    print(a:equals(a))
    print(a:equals(b))
    print(a:equals(b))
    print(a:hashCode() == a:hashCode())
    print(a:hashCode() == b:hashCode())
    local set = __K2L_SetOf(a, a, b)
    print(set.size)
    local map = __K2L_MapOf(__K2L_Pair.new(a, "a"), __K2L_Pair.new(b, "b"))
    print(__K2L_Str(map:get(a)))
    print(__K2L_Str(map:get(Identity.new(1))))
    local m1 = Mixed.new(5)
    local m2 = Mixed.new(5)
    local m3 = Mixed.new(6)
    print(m1:equals(m1))
    print(m1:equals(m2))
    print(m1:equals(m3))
    print(__K2L_SetOf(m1, m2, m3).size)
    local h = Hashed.new(1)
    print(__K2L_Str(h))
    print(h:hashCode() == h:hashCode())
    local e = MyException.new(7)
    print(__K2L_Str(e))
    print(__K2L_Str(e.message))
    print(e.code)
    local ____ok, ____result = pcall(function()
        error(MyException.new(1))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, MyException) then
            local ex = ____error
            print("caught " .. __K2L_Str(ex))
        else
            error(____error, 0)
        end
    end
    local w = Wrapping.new(__K2L_IllegalArgumentException.new("inner"))
    print(w:describe())
    print(__K2L_Str(w))
    print(__K2L_Str(Leaf.new()))
    print(__K2L_Str(Leaf.new().message))
    print(Color.RED:plain())
    print(__K2L_Str(Color.GREEN))
    print(Color.GREEN:plain())
    print(__K2L_Str(Singleton))
end

main()
return {shape = shape, Plain = Plain, Derived = Derived, Identity = Identity, Mixed = Mixed, Hashed = Hashed, MyException = MyException, Wrapping = Wrapping, Base = Base, Leaf = Leaf, Color = Color, Singleton = Singleton}
