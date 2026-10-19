local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_EnumValueOf = ____lualib.__K2L_EnumValueOf
local __K2L_EnumValues = ____lualib.__K2L_EnumValues
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_KClassOf = ____lualib.__K2L_KClassOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_LazyObject = ____lualib.__K2L_LazyObject
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_TouchObject = ____lualib.__K2L_TouchObject

local Named = __K2L_Class("Named")
__K2L_ClassInfo(Named, "Named", "Named", "interface")
local Config = __K2L_Class("Config", nil, Named)
__K2L_ClassInfo(Config, "Config", "Config", "class")

function Config:____init()
    self.name = "config"
    self.calls = 0
    print("Config initialized")
end

function Config:label()
    return "Config(" .. self.name .. ")"
end

function Config:bump()
    self.calls = self.calls + 1
    return self.calls
end

__K2L_LazyObject(Config, "____init")
local Loud = __K2L_Class("Loud")
__K2L_ClassInfo(Loud, "Loud", "Loud", "class")

function Loud:____init()
    self.value = self:compute("Loud")
    self.other = self.value .. "!"
end

function Loud:compute(s)
    print("computing " .. s)
    return s:upper()
end

__K2L_LazyObject(Loud, "____init")
local Plain = __K2L_Class("Plain")
__K2L_ClassInfo(Plain, "Plain", "Plain", "class")

function Plain:____init()
    self.x = 10
    self.names = __K2L_ListOf("a", "b")
    self.count = 0
end

function Plain:inc()
    self.count = self.count + 1
    return self.count
end

Plain:____init()
local Second = __K2L_Class("Second")
__K2L_ClassInfo(Second, "Second", "Second", "class")

function Second:____init()
    self.dependsOnConfig = Config.name .. "-second"
    print("Second initialized")
end

__K2L_LazyObject(Second, "____init")
local Base = __K2L_Class("Base")
__K2L_ClassInfo(Base, "Base", "Base", "class")

function Base:____init(id)
    self.id = id
    print("Base(" .. self.id .. ")")
end

local Derived = __K2L_Class("Derived", Base)
__K2L_ClassInfo(Derived, "Derived", "Derived", "class")

function Derived:____init()
    Base.____init(self, 7)
    self.tag = "derived"
end

__K2L_LazyObject(Derived, "____init")
local Service = __K2L_Class("Service")
__K2L_ClassInfo(Service, "Service", "Service", "class")
Service.Nested = __K2L_Class("Nested")
__K2L_ClassInfo(Service.Nested, "Service.Nested", "Service$Nested", "class")

function Service.Nested:____init()
    print("Nested initialized")
    self.k = 3
end

__K2L_LazyObject(Service.Nested, "____init")

function Service:create(name)
    self.instances:add(name)
    return Service.new()
end

function Service:____initCompanion()
    self.instances = __K2L_ListOf()
    print("Service companion initialized")
end

__K2L_LazyObject(Service, "____initCompanion")
local Quiet = __K2L_Class("Quiet")
__K2L_ClassInfo(Quiet, "Quiet", "Quiet", "class")

function Quiet:____initCompanion()
    self.ZERO = Quiet.new()
    self.LIMIT = 5
    self.made = 0
end

Quiet:____initCompanion()
local Level = __K2L_Class("Level")
__K2L_ClassInfo(Level, "Level", "Level", "class")

function Level:____init(name, ordinal, code)
    self.name = name
    self.ordinal = ordinal
    self.code = code
    print("Level." .. self.name .. " created")
end

function Level:toString()
    return self.name
end

function Level:____initEnum()
    Level.LOW = Level.new("LOW", 0, 1)
    Level.HIGH = Level.new("HIGH", 1, 2)
    Level.____values = {Level.LOW, Level.HIGH}
end

function Level:____initCompanion()
    self.default = Level.LOW
end

__K2L_LazyObject(Level, "____initEnum", "____initCompanion")
local Color = __K2L_Class("Color")
__K2L_ClassInfo(Color, "Color", "Color", "class")

function Color:____init(name, ordinal, rgb)
    self.name = name
    self.ordinal = ordinal
    self.rgb = rgb
end

function Color:hex()
    return "#" .. __K2L_Num.toRadix(self.rgb, 16)
end

function Color:toString()
    return self.name
end

Color.RED = Color.new("RED", 0, 16711680)
Color.GREEN = Color.new("GREEN", 1, 65280)
Color.____values = {Color.RED, Color.GREEN}
local Mode = __K2L_Class("Mode")
__K2L_ClassInfo(Mode, "Mode", "Mode", "class")

function Mode:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
    local ____value = self.name:upper()
    print("Mode." .. self.name .. " upper")
    self.upper = ____value
end

function Mode:toString()
    return self.name
end

function Mode:____initEnum()
    do
        local ____A = __K2L_Class("Mode", Mode)
        __K2L_ClassInfo(____A, "Mode.A", "Mode$A", "class", "A")
        function ____A:describe()
            return "mode a"
        end
        Mode.A = ____A.new("A", 0)
    end
    do
        local ____B = __K2L_Class("Mode", Mode)
        __K2L_ClassInfo(____B, "Mode.B", "Mode$B", "class", "B")
        function ____B:describe()
            return "mode b"
        end
        Mode.B = ____B.new("B", 1)
    end
    Mode.____values = {Mode.A, Mode.B}
end

__K2L_LazyObject(Mode, "____initEnum")

local function main()
    print("start")
    print(Plain:inc())
    print(Color.RED:hex() .. " " .. __K2L_EnumValues(Color).size)
    print("before Config")
    local ref = __K2L_TouchObject(Config)
    print("holding a reference")
    print(__K2L_InstanceOf(ref, Named))
    print(Config:bump())
    print(Config:label())
    print(Config:bump())
    print("before Loud")
    print(Loud.other)
    print(Loud.value)
    print("before Second")
    print(Second.dependsOnConfig)
    print("before Derived")
    print(Derived.tag)
    print(Derived.id)
    print("before Service")
    print(Service.Nested.k)
    print(__K2L_Equals(__K2L_KClassOfValue(Service:create("one")), __K2L_KClassOf(Service)))
    print(__K2L_Str(Service.instances))
    print(5)
    print(Quiet.made)
    print("before Level")
    print(Level.HIGH.code)
    print(__K2L_Str(__K2L_EnumValues(Level):map(function(it) return it.name end)))
    print(__K2L_Str(Level.default))
    print(__K2L_EnumValueOf(Level, "LOW").code)
    print("before Mode")
    print(Mode.B:describe())
    print(Mode.A.upper)
    print("end")
end

main()
return {Named = Named, Config = Config, Loud = Loud, Plain = Plain, Second = Second, Base = Base, Derived = Derived, Service = Service, Quiet = Quiet, Level = Level, Color = Color, Mode = Mode}
