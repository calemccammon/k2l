local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_EnumConstants = ____lualib.__K2L_EnumConstants
local __K2L_EnumDeclaringClass = ____lualib.__K2L_EnumDeclaringClass
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_KClassNamed = ____lualib.__K2L_KClassNamed
local __K2L_KClassOf = ____lualib.__K2L_KClassOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Str = ____lualib.__K2L_Str

local Color = __K2L_Class("Color")
__K2L_ClassInfo(Color, "Color", "Color", "class")

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
Color.GREEN = Color.new("GREEN", 1)
Color.BLUE = Color.new("BLUE", 2)
Color.____values = {Color.RED, Color.GREEN, Color.BLUE}
local Op = __K2L_Class("Op")
__K2L_ClassInfo(Op, "Op", "Op", "class")

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

do
    local ____PLUS = __K2L_Class("Op", Op)
    __K2L_ClassInfo(____PLUS, "Op.PLUS", "Op$PLUS", "class", "PLUS")
    function ____PLUS:apply(a, b)
        return a + b
    end
    Op.PLUS = ____PLUS.new("PLUS", 0, "+")
end
do
    local ____TIMES = __K2L_Class("Op", Op)
    __K2L_ClassInfo(____TIMES, "Op.TIMES", "Op$TIMES", "class", "TIMES")
    function ____TIMES:apply(a, b)
        return a * b
    end
    Op.TIMES = ____TIMES.new("TIMES", 1, "*")
end
Op.____values = {Op.PLUS, Op.TIMES}
local Empty = __K2L_Class("Empty")
__K2L_ClassInfo(Empty, "Empty", "Empty", "class")

function Empty:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Empty:toString()
    return self.name
end

function Empty:compareTo(other)
    return self.ordinal - other.ordinal
end

Empty.____values = {}
local Plain = __K2L_Class("Plain")
__K2L_ClassInfo(Plain, "Plain", "Plain", "class")

local function names(constants)
    return constants and constants:joinToString(",") or "null"
end

local ____lambda_1 = function(cls) return __K2L_EnumConstants(cls).size end
local function main()
    print(names(__K2L_EnumConstants(__K2L_JavaClass(__K2L_KClassOf(Color)))))
    print(names(__K2L_EnumConstants(__K2L_JavaClass(__K2L_KClassOfValue(Color.GREEN)))))
    print(names(__K2L_EnumConstants(__K2L_EnumDeclaringClass(Color.RED))))
    print(names(__K2L_EnumConstants(__K2L_JavaClass(__K2L_KClassOfValue(Op.PLUS)))) .. " " .. names(__K2L_EnumConstants(__K2L_EnumDeclaringClass(Op.PLUS))))
    print(__K2L_Equals(__K2L_EnumDeclaringClass(Op.TIMES), __K2L_JavaClass(__K2L_KClassOf(Op))))
    print(names(__K2L_EnumConstants(__K2L_JavaClass(__K2L_KClassOf(Op)))))
    local ____list = __K2L_EnumConstants(__K2L_JavaClass(__K2L_KClassOf(Op)))
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = it:apply(6, 7)
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    print(names(__K2L_EnumConstants(__K2L_JavaClass(__K2L_KClassOf(Empty)))))
    print(__K2L_EnumConstants(__K2L_JavaClass(__K2L_KClassOf(Empty))).size)
    print(names(__K2L_EnumConstants(__K2L_JavaClass(__K2L_KClassOf(Plain)))))
    print(names(__K2L_EnumConstants(__K2L_JavaClass(__K2L_KClassNamed("kotlin.String")))))
    print(names(__K2L_EnumConstants(__K2L_JavaClass(__K2L_KClassOfValue("text")))))
    local first = __K2L_EnumConstants(__K2L_JavaClass(__K2L_KClassOf(Color)))
    first:set(0, Color.BLUE)
    print(names(first) .. " " .. names(__K2L_EnumConstants(__K2L_JavaClass(__K2L_KClassOf(Color)))))
    print(first == __K2L_EnumConstants(__K2L_JavaClass(__K2L_KClassOf(Color))))
    local function count(cls)
        return __K2L_EnumConstants(cls).size
    end
    print(count(__K2L_JavaClass(__K2L_KClassOf(Color))) + count(__K2L_JavaClass(__K2L_KClassOf(Op))))
    local any = __K2L_JavaClass(__K2L_KClassOf(Color))
    local ____receiver = __K2L_EnumConstants(any)
    print(__K2L_Str(____receiver and ____receiver.size))
end

__K2L_Main(main)
return {Color = Color, Op = Op, Empty = Empty, Plain = Plain, names = names}
