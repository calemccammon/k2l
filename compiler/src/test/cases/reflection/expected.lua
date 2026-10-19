-- ==== main.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_EnumValueOf = ____lualib.__K2L_EnumValueOf
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_KClassNamed = ____lualib.__K2L_KClassNamed
local __K2L_KClassOf = ____lualib.__K2L_KClassOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32

local ____model = require("model.model")
local Plain = __K2L_Class("app.Plain")
__K2L_ClassInfo(Plain, "app.Plain", "app.Plain", "class")
local Point = __K2L_Class("app.Point")
__K2L_ClassInfo(Point, "app.Point", "app.Point", "class")

function Point:____init(x, y)
    self.x = x
    self.y = y
end

function Point:toString()
    return "Point(x=" .. self.x .. ", y=" .. self.y .. ")"
end

function Point:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.x) + __K2L_Hash(self.y))
end

function Point:equals(other)
    return getmetatable(other) == Point and self.x == other.x and self.y == other.y
end

local Animal = __K2L_Class("app.Animal")
__K2L_ClassInfo(Animal, "app.Animal", "app.Animal", "class")

function Animal:toString()
    return "I am a " .. __K2L_Str(__K2L_KClassOfValue(self).simpleName)
end

local Dog = __K2L_Class("app.Dog", Animal)
__K2L_ClassInfo(Dog, "app.Dog", "app.Dog", "class")
local Cat = __K2L_Class("app.Cat", Animal)
__K2L_ClassInfo(Cat, "app.Cat", "app.Cat", "class")

local function describe(x)
    if x == nil then
        return "null"
    else
        return __K2L_Str(__K2L_KClassOfValue(x).simpleName)
    end
end

local function localClasses()
    local Local = __K2L_Class("app.MainKt$localClasses$Local")
    __K2L_ClassInfo(Local, nil, "app.MainKt$localClasses$Local", "class")
    local l = Local.new()
    print(__K2L_Str(__K2L_KClassOfValue(l).simpleName))
    print(__K2L_Str(__K2L_KClassOf(Local).qualifiedName))
end

local handlers = __K2L_ReadOnlyMapOf(__K2L_Pair.new(__K2L_KClassOf(Plain), function(_) return "plain handler" end), __K2L_Pair.new(__K2L_KClassOf(Point), function(p) return "point handler for " .. __K2L_Str(p) end))

local function kindOf(x)
    local ____subject = __K2L_KClassOfValue(x)
    if __K2L_Equals(____subject, __K2L_KClassOf(Dog)) then
        return "dog"
    elseif __K2L_Equals(____subject, __K2L_KClassOf(Cat)) then
        return "cat"
    elseif __K2L_Equals(____subject, __K2L_KClassNamed("kotlin.String")) then
        return "string"
    elseif __K2L_Equals(____subject, __K2L_KClassNamed("kotlin.Int")) then
        return "int"
    else
        return "unknown"
    end
end

local function main()
    print(__K2L_Str(__K2L_KClassOf(Plain).simpleName))
    print(__K2L_Str(__K2L_KClassOf(Plain).qualifiedName))
    print(__K2L_Str(__K2L_KClassOfValue(Plain.new()).simpleName))
    print(__K2L_Str(__K2L_KClassOfValue(Point.new(1, 2)).simpleName))
    print(__K2L_Str(__K2L_KClassOf(Point).qualifiedName))
    print(__K2L_Str(Animal.new()))
    print(__K2L_Str(Dog.new()))
    print(__K2L_Str(Cat.new()))
    print(describe(Dog.new()))
    print(describe(nil))
    print(describe("hello"))
    print(describe(42))
    local a = Dog.new()
    local b = Cat.new()
    print(__K2L_Equals(__K2L_KClassOfValue(a), __K2L_KClassOf(Dog)))
    print(__K2L_Equals(__K2L_KClassOfValue(a), __K2L_KClassOf(Animal)))
    print(not __K2L_Equals(__K2L_KClassOfValue(a), __K2L_KClassOfValue(b)))
    print(__K2L_Equals(__K2L_KClassOfValue(a), __K2L_KClassOfValue(b)))
    print(__K2L_Equals(__K2L_KClassOfValue(Dog.new()), __K2L_KClassOfValue(Dog.new())))
    print(__K2L_Str(__K2L_KClassOfValue(____model.Circle.new(1.0)).simpleName))
    print(__K2L_Str(__K2L_KClassOf(____model.Circle).qualifiedName))
    print(__K2L_Str(__K2L_KClassOfValue(____model.Square.new(2.0)).qualifiedName))
    print(__K2L_Str(__K2L_KClassOf(____model.Registry).simpleName))
    print(__K2L_Str(__K2L_KClassOf(____model.Registry).qualifiedName))
    print(__K2L_Str(__K2L_KClassOf(____model.Outer.Nested).simpleName))
    print(__K2L_Str(__K2L_KClassOf(____model.Outer.Nested).qualifiedName))
    print(__K2L_Str(__K2L_KClassNamed("app.model.Outer.Companion", "Companion", "app.model.Outer$Companion").simpleName))
    print(__K2L_Str(__K2L_KClassNamed("app.model.Outer.Companion", "Companion", "app.model.Outer$Companion").qualifiedName))
    print(__K2L_Str(__K2L_KClassOfValue(____model.Outer.Inner.new(____model.Outer.new())).qualifiedName))
    print(__K2L_Str(__K2L_KClassOfValue(____model.Color.RED).simpleName))
    print(__K2L_Str(__K2L_KClassOf(____model.Color).qualifiedName))
    print(__K2L_Equals(__K2L_KClassOfValue(____model.Color.GREEN), __K2L_KClassOf(____model.Color)))
    print(__K2L_Str(__K2L_KClassOfValue(____model.Color.GREEN).simpleName))
    print(__K2L_Str(__K2L_KClassOfValue(____model.Color.GREEN).qualifiedName))
    print(__K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(____model.Color.GREEN)).name))
    print(__K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(____model.Color.RED)).name))
    print(__K2L_KClassOfValue(____model.Color.GREEN):isInstance(____model.Color.RED))
    print(__K2L_KClassOf(____model.Color):isInstance(____model.Color.GREEN))
    print(__K2L_Equals(__K2L_KClassOfValue(____model.Op.PLUS), __K2L_KClassOf(____model.Op)))
    print(__K2L_Str(__K2L_KClassOfValue(__K2L_EnumValueOf(____model.Op, "MINUS")).simpleName))
    print(__K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(____model.Op.PLUS)).simpleName or ""))
    print(__K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(____model.Outer.Nested.new())).name))
    print(__K2L_Str(__K2L_KClassOf(____model.Shape).simpleName))
    print(__K2L_Str(__K2L_KClassOf(____model.Shape).qualifiedName))
    localClasses()
    local ____result
    ____result = __K2L_KClassOf(Plain).simpleName
    print(__K2L_Str(____result))
    local ____result_1
    ____result_1 = __K2L_KClassOf(Point).simpleName
    print(__K2L_Str(____result_1))
    local ____result_2
    ____result_2 = __K2L_KClassNamed("kotlin.String").simpleName
    print(__K2L_Str(____result_2))
    local ____result_3
    ____result_3 = __K2L_KClassNamed("kotlin.Int").simpleName
    print(__K2L_Str(____result_3))
    local ____result_4
    ____result_4 = __K2L_KClassOf(____model.Circle).qualifiedName
    print(__K2L_Str(____result_4))
    local ____result_5
    ____result_5 = __K2L_KClassNamed("kotlin.Double").qualifiedName
    print(__K2L_Str(____result_5))
    print(__K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(Plain.new())).simpleName or ""))
    print(__K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(Point.new(0, 0))).simpleName or ""))
    print(__K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(Dog.new())).name))
    print(__K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(____model.Circle.new(1.0))).name))
    print(__K2L_Str(__K2L_KClassNamed("kotlin.String").simpleName))
    print(__K2L_Str(__K2L_KClassNamed("kotlin.Int").simpleName))
    print(__K2L_Str(__K2L_KClassNamed("kotlin.Long").simpleName))
    print(__K2L_Str(__K2L_KClassNamed("kotlin.Double").simpleName))
    print(__K2L_Str(__K2L_KClassNamed("kotlin.Boolean").simpleName))
    print(__K2L_Str(__K2L_KClassNamed("kotlin.Char").simpleName))
    print(__K2L_Str(__K2L_KClassNamed("kotlin.String").qualifiedName))
    print(__K2L_Str(__K2L_KClassNamed("kotlin.Int").qualifiedName))
    print(__K2L_Str(__K2L_KClassOfValue(__K2L_ListOf(1)).simpleName))
    print(__K2L_Str(__K2L_KClassOfValue(__K2L_List.new()).simpleName))
    print(__K2L_Str(__K2L_KClassOfValue(__K2L_MapOf(__K2L_Pair.new(1, 2))).simpleName))
    print(__K2L_Str(__K2L_KClassOfValue(__K2L_SetOf(1)).simpleName))
    print(__K2L_Str(__K2L_KClassOfValue(__K2L_HashMap.new()).simpleName))
    print(__K2L_Str(__K2L_KClassOfValue(__K2L_Pair.new(1, 2)).simpleName))
    print(__K2L_Str(__K2L_KClassOfValue(__K2L_Exception.new("x")).simpleName))
    print(__K2L_Str(__K2L_KClassOfValue(__K2L_IllegalStateException.new("x")).qualifiedName))
    print(__K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(__K2L_RuntimeException.new("x"))).simpleName or ""))
    print(__K2L_Str(__K2L_KClassOfValue(__K2L_StringBuilder.new()).simpleName))
    print(__K2L_Equals(__K2L_KClassNamed("kotlin.String"), __K2L_KClassNamed("kotlin.String")))
    print(__K2L_Equals(__K2L_KClassNamed("kotlin.Int"), __K2L_KClassNamed("kotlin.Int")))
    print(__K2L_Equals(__K2L_KClassNamed("kotlin.Int"), __K2L_KClassNamed("kotlin.Long")))
    local ____receiver = handlers:get(__K2L_KClassOf(Plain))
    print(__K2L_Str(____receiver and ____receiver(Plain.new())))
    local ____receiver_1 = handlers:get(__K2L_KClassOf(Point))
    print(__K2L_Str(____receiver_1 and ____receiver_1(Point.new(1, 2))))
    print(__K2L_Str(handlers:get(__K2L_KClassOf(Dog))))
    print(kindOf(Dog.new()))
    print(kindOf(Cat.new()))
    print(kindOf("s"))
    print(kindOf(3))
    print(kindOf(3.5))
    local classes = __K2L_ReadOnlyListOf(__K2L_KClassOf(Dog), __K2L_KClassOf(Cat), __K2L_KClassOf(Dog))
    print(__K2L_Str(classes:map(function(it) return it.simpleName end)))
    print(classes:distinct().size)
    print(classes:toSet().size)
    print(classes:contains(__K2L_KClassOf(Dog)))
    local k = __K2L_KClassOfValue(Dog.new())
    print(__K2L_Str(k.simpleName))
    print(__K2L_Equals(k, __K2L_KClassOf(Dog)))
    print(__K2L_KClassOf(Animal):isInstance(Dog.new()))
    print(__K2L_KClassOf(Dog):isInstance(Cat.new()))
    print(__K2L_KClassOf(Dog):isInstance(Dog.new()))
    print(__K2L_KClassNamed("kotlin.String"):isInstance("s"))
    print(__K2L_KClassNamed("kotlin.String"):isInstance(1))
    print(__K2L_KClassNamed("kotlin.Int"):isInstance(1))
    print(__K2L_KClassOf(____model.Shape):isInstance(____model.Square.new(1.0)))
    print(__K2L_KClassNamed("kotlin.Any"):isInstance(Plain.new()))
end

main()
return {Plain = Plain, Point = Point, Animal = Animal, Dog = Dog, Cat = Cat, describe = describe, localClasses = localClasses, handlers = handlers, kindOf = kindOf}
-- ==== model/model.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_CompanionInfo = ____lualib.__K2L_CompanionInfo

local Shape = __K2L_Class("app.model.Shape")
__K2L_ClassInfo(Shape, "app.model.Shape", "app.model.Shape", "interface")
local Circle = __K2L_Class("app.model.Circle", nil, Shape)
__K2L_ClassInfo(Circle, "app.model.Circle", "app.model.Circle", "class")

function Circle:____init(r)
    self.r = r
end

local Square = __K2L_Class("app.model.Square", nil, Shape)
__K2L_ClassInfo(Square, "app.model.Square", "app.model.Square", "class")

function Square:____init(side)
    self.side = side
end

local Registry = __K2L_Class("app.model.Registry")
__K2L_ClassInfo(Registry, "app.model.Registry", "app.model.Registry", "class")
local Outer = __K2L_Class("app.model.Outer")
__K2L_ClassInfo(Outer, "app.model.Outer", "app.model.Outer", "class")
__K2L_CompanionInfo(Outer, "app.model.Outer.Companion", "app.model.Outer$Companion", "Companion")
Outer.Nested = __K2L_Class("app.model.Outer$Nested")
__K2L_ClassInfo(Outer.Nested, "app.model.Outer.Nested", "app.model.Outer$Nested", "class")
Outer.Inner = __K2L_Class("app.model.Outer$Inner")
__K2L_ClassInfo(Outer.Inner, "app.model.Outer.Inner", "app.model.Outer$Inner", "class")

function Outer.Inner:____init(____outer)
    self.____outer = ____outer
end

local Color = __K2L_Class("app.model.Color")
__K2L_ClassInfo(Color, "app.model.Color", "app.model.Color", "class")

function Color:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Color:toString()
    return self.name
end

function Color:compareTo(other)
    return self.ordinal - other.ordinal
end

Color.RED = Color.new("RED", 0)
do
    local ____GREEN = __K2L_Class("Color", Color)
    __K2L_ClassInfo(____GREEN, "app.model.Color.GREEN", "app.model.Color$GREEN", "class", "GREEN")
    function ____GREEN:toString()
        return "green"
    end
    Color.GREEN = ____GREEN.new("GREEN", 1)
end
Color.____values = {Color.RED, Color.GREEN}
local Op = __K2L_Class("app.model.Op")
__K2L_ClassInfo(Op, "app.model.Op", "app.model.Op", "class")

function Op:____init(name, ordinal, symbol)
    self.name = name
    self.ordinal = ordinal
    self.symbol = symbol
end

function Op:toString()
    return self.name
end

function Op:compareTo(other)
    return self.ordinal - other.ordinal
end

Op.PLUS = Op.new("PLUS", 0, "+")
Op.MINUS = Op.new("MINUS", 1, "-")
Op.____values = {Op.PLUS, Op.MINUS}
return {Shape = Shape, Circle = Circle, Square = Square, Registry = Registry, Outer = Outer, Color = Color, Op = Op}
