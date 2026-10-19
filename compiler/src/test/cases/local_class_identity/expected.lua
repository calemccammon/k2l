local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringFormat = ____lualib.__K2L_StringFormat

local Shape = __K2L_Class("app.Shape")
__K2L_ClassInfo(Shape, "app.Shape", "app.Shape", "interface")

local function square(side)
    local ____object = __K2L_Class("app.MainKt$square$1", nil, Shape)
    __K2L_ClassInfo(____object, nil, "app.MainKt$square$1", "class", false)
    function ____object:area()
        return side * side
    end
    return ____object
end

local function circle(r)
    local ____object_1 = __K2L_Class("app.MainKt$circle$1", nil, Shape)
    __K2L_ClassInfo(____object_1, nil, "app.MainKt$circle$1", "class", false)
    function ____object_1:area()
        return 3.0 * r * r
    end
    return ____object_1
end

local function makeLocal(n)
    local Base = __K2L_Class("app.MainKt$makeLocal$Base")
    __K2L_ClassInfo(Base, nil, "app.MainKt$makeLocal$Base", "class")
    function Base:____init(n)
        self.n = n
    end
    local Derived = __K2L_Class("app.MainKt$makeLocal$Derived", Base)
    __K2L_ClassInfo(Derived, nil, "app.MainKt$makeLocal$Derived", "class")
    function Derived:____init(n)
        Base.____init(self, n)
    end
    return math.fmod(n, 2) == 0 and Base.new(n) or Derived.new(n)
end

local function main()
    local squares = __K2L_IntRange.new(1, 3):map(function(it) return square(it + 0.0) end)
    local c = circle(1.0)
    print(squares:map(function(it)
        return __K2L_JavaClass(__K2L_KClassOfValue(it))
    end):distinct().size)
    print(__K2L_Equals(__K2L_KClassOfValue(squares:get(0)), __K2L_KClassOfValue(squares:get(2))))
    print(__K2L_Equals(__K2L_JavaClass(__K2L_KClassOfValue(squares:get(0))), __K2L_JavaClass(__K2L_KClassOfValue(c))))
    print(__K2L_JavaClass(__K2L_KClassOfValue(squares:get(1))).name .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(c)).name))
    print(__K2L_KClassOfValue(squares:get(2)):isInstance(squares:get(0)))
    print(__K2L_KClassOfValue(squares:get(2)):isInstance(c))
    local byClass = squares:plus(c):groupBy(function(it) return __K2L_KClassOfValue(it) end)
    print(byClass:getValues():joinToString(nil, nil, nil, nil, nil, function(group)
        return __K2L_StringFormat("%.1f", group:sumOf(function(it) return it:area() end, 0.0))
    end))
    local counters = __K2L_ListOfSize(3, function(it)
        local ____object_2 = __K2L_Class("app.MainKt$main$counters$1$1")
        __K2L_ClassInfo(____object_2, nil, "app.MainKt$main$counters$1$1", "class", false)
        function ____object_2:____init()
            self.hits = it
        end
        ____object_2:____init()
        return ____object_2
    end)
    print(counters:map(function(it)
        return __K2L_JavaClass(__K2L_KClassOfValue(it))
    end):toSet().size)
    local locals = __K2L_IntRange.new(1, 4):map(makeLocal)
    print(__K2L_Str(locals:map(function(it)
        return __K2L_JavaClass(__K2L_KClassOfValue(it)).name
    end)))
    print(__K2L_Equals(__K2L_KClassOfValue(locals:get(0)), __K2L_KClassOfValue(locals:get(2))))
    print(__K2L_KClassOfValue(locals:get(1)):isInstance(locals:get(3)))
    print(__K2L_KClassOfValue(locals:get(0)):isInstance(locals:get(1)))
    print(__K2L_KClassOfValue(locals:get(1)):isInstance(locals:get(0)))
end

main()
return {Shape = Shape, square = square, circle = circle, makeLocal = makeLocal}
