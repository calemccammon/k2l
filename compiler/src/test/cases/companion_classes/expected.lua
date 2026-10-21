local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_CompanionInfo = ____lualib.__K2L_CompanionInfo
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_KClassNamed = ____lualib.__K2L_KClassNamed
local __K2L_KClassOf = ____lualib.__K2L_KClassOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Str = ____lualib.__K2L_Str

local Outer = __K2L_Class("app.Outer")
__K2L_ClassInfo(Outer, "app.Outer", "app.Outer", "class")
__K2L_CompanionInfo(Outer, "app.Outer.Companion", "app.Outer$Companion", "Companion")

function Outer:____initCompanion()
    self.z = 1
end

Outer:____initCompanion()
local Named = __K2L_Class("app.Named")
__K2L_ClassInfo(Named, "app.Named", "app.Named", "class")
__K2L_CompanionInfo(Named, "app.Named.Factory", "app.Named$Factory", "Factory")

function Named:make()
    return Named.new()
end

local Solo = __K2L_Class("app.Solo")
__K2L_ClassInfo(Solo, "app.Solo", "app.Solo", "class")
local Marker = __K2L_Class("app.Marker")
__K2L_ClassInfo(Marker, "app.Marker", "app.Marker", "interface")
local Impl = __K2L_Class("app.Impl", nil, Marker)
__K2L_ClassInfo(Impl, "app.Impl", "app.Impl", "class")

local function classOf(x)
    return __K2L_KClassOfValue(x)
end

local function main()
    local c = Outer
    print(__K2L_Str(__K2L_KClassOfValue(c).simpleName))
    print(__K2L_Str(__K2L_KClassOfValue(c).qualifiedName))
    print(__K2L_Equals(__K2L_KClassOfValue(c), __K2L_KClassNamed("app.Outer.Companion", "Companion", "app.Outer$Companion")))
    print(__K2L_Equals(__K2L_KClassOfValue(c), __K2L_KClassOf(Outer)))
    print(__K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(c)).name))
    print(__K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(c)).simpleName or ""))
    print(__K2L_Str(__K2L_JavaClass(__K2L_KClassNamed("app.Outer.Companion", "Companion", "app.Outer$Companion")).name))
    print(__K2L_Equals(__K2L_JavaClass(__K2L_KClassNamed("app.Outer.Companion", "Companion", "app.Outer$Companion")), __K2L_JavaClass(__K2L_KClassOfValue(c))))
    print(__K2L_Str(classOf(c).simpleName))
    print(__K2L_Equals(classOf(c), __K2L_KClassNamed("app.Outer.Companion", "Companion", "app.Outer$Companion")))
    print(__K2L_Str(classOf(Named).simpleName))
    print(__K2L_Str(classOf(Named).qualifiedName))
    print(__K2L_Str(classOf(Named:make()).simpleName))
    print(__K2L_Str(classOf(Solo).simpleName))
    print(__K2L_KClassNamed("app.Outer.Companion", "Companion", "app.Outer$Companion"):isInstance(c))
    print(__K2L_KClassNamed("app.Outer.Companion", "Companion", "app.Outer$Companion"):isInstance(Outer.new()))
    print(__K2L_KClassOf(Outer):isInstance(c))
    print(__K2L_KClassOf(Outer):isInstance(Outer.new()))
    local any = Named
    print(__K2L_Str(__K2L_KClassOfValue(any).simpleName))
    print(any == Named)
    print(Outer.z)
    print(__K2L_Str(__K2L_KClassOf(Outer)))
    print(__K2L_Str(__K2L_KClassNamed("app.Outer.Companion", "Companion", "app.Outer$Companion")))
    print(__K2L_Str(__K2L_KClassNamed("app.Named.Factory", "Factory", "app.Named$Factory")))
    print(__K2L_Str(__K2L_KClassOf(Solo)))
    print(__K2L_Str(__K2L_KClassOf(Marker)))
    print(__K2L_Str(__K2L_KClassOfValue(Impl.new())))
    print(__K2L_Str(__K2L_KClassOfValue(c)))
    print(__K2L_Str(__K2L_KClassOf(Outer)))
    print(__K2L_Str(__K2L_JavaClass(__K2L_KClassOf(Outer))))
    print(__K2L_Str(__K2L_JavaClass(__K2L_KClassOf(Marker))))
    print(__K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(Impl.new()))))
    print(__K2L_Str(__K2L_JavaClass(__K2L_KClassNamed("app.Outer.Companion", "Companion", "app.Outer$Companion"))))
    print(__K2L_Str(__K2L_KClassNamed("kotlin.String")))
    print(__K2L_Str(__K2L_KClassNamed("kotlin.Int")))
    print(__K2L_Equals(__K2L_JavaClass(__K2L_KClassOf(Outer)).____kotlin, __K2L_KClassOf(Outer)))
    print(__K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(Impl.new())).____kotlin.simpleName))
end

__K2L_Main(main)
return {Outer = Outer, Named = Named, Solo = Solo, Marker = Marker, Impl = Impl, classOf = classOf}
