local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
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
    return (n >= 0 and n % 2 or 0 - -n % 2) == 0 and Base.new(n) or Derived.new(n)
end

local ____lambda_1 = function(it) return square(it + 0.0) end
local function main()
    local squares = __K2L_IntRange.new(1, 3):map(____lambda_1)
    local c = circle(1.0)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = squares:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = __K2L_JavaClass(__K2L_KClassOfValue(it))
    end
    print(__K2L_ListWrap(____out, ____count):distinct().size)
    print(__K2L_Equals(__K2L_KClassOfValue(squares:get(0)), __K2L_KClassOfValue(squares:get(2))))
    print(__K2L_Equals(__K2L_JavaClass(__K2L_KClassOfValue(squares:get(0))), __K2L_JavaClass(__K2L_KClassOfValue(c))))
    print(__K2L_JavaClass(__K2L_KClassOfValue(squares:get(1))).name .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(c)).name))
    print(__K2L_KClassOfValue(squares:get(2)):isInstance(squares:get(0)))
    print(__K2L_KClassOfValue(squares:get(2)):isInstance(c))
    local ____list = squares:plus(c)
    local ____result = __K2L_Map.new()
    local ____items_1, ____n_1 = ____list:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        local ____value = __K2L_KClassOfValue(it)
        local ____group = ____result:get(____value)
        if ____group == nil then
            ____group = __K2L_List.new()
            ____result:put(____value, ____group)
        end
        ____group:add(it)
    end
    local byClass = ____result
    print(byClass:getValues():joinToString(nil, nil, nil, nil, nil, function(group)
        local ____sum = 0.0
        local ____items_2, ____n_2 = group:____array()
        for ____i_2 = 1, ____n_2 do
            local it = ____items_2[____i_2]
            ____sum = ____sum + it:area()
        end
        return __K2L_StringFormat("%.1f", ____sum)
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
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_3, ____n_3 = counters:____array()
    for ____i_3 = 1, ____n_3 do
        local it = ____items_3[____i_3]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = __K2L_JavaClass(__K2L_KClassOfValue(it))
    end
    print(__K2L_ListWrap(____out_1, ____count_1):toSet().size)
    local locals = __K2L_IntRange.new(1, 4):map(makeLocal)
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_4, ____n_4 = locals:____array()
    for ____i_4 = 1, ____n_4 do
        local it = ____items_4[____i_4]
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = __K2L_JavaClass(__K2L_KClassOfValue(it)).name
    end
    print(__K2L_Str(__K2L_ListWrap(____out_2, ____count_2)))
    print(__K2L_Equals(__K2L_KClassOfValue(locals:get(0)), __K2L_KClassOfValue(locals:get(2))))
    print(__K2L_KClassOfValue(locals:get(1)):isInstance(locals:get(3)))
    print(__K2L_KClassOfValue(locals:get(0)):isInstance(locals:get(1)))
    print(__K2L_KClassOfValue(locals:get(1)):isInstance(locals:get(0)))
end

main()
return {Shape = Shape, square = square, circle = circle, makeLocal = makeLocal}
