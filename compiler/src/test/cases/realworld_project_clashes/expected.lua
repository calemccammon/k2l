-- ==== geometry/Point.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Str = ____lualib.__K2L_Str

local ____exports = {}
local Point = __K2L_Class("draw.geometry.Point")
__K2L_ClassInfo(Point, "draw.geometry.Point", "draw.geometry.Point", "class")

function Point:____init(x, y)
    self.x = x
    self.y = y
end

function Point.new(x, y)
    return setmetatable({x = x, y = y}, Point)
end

function Point:plus(o)
    return Point.new(self.x + o.x, self.y + o.y)
end

function Point:toString()
    return "(" .. __K2L_Str(self.x) .. ", " .. __K2L_Str(self.y) .. ")"
end

function Point:hashCode()
    return (31 * __K2L_Hash(self.x) + __K2L_Hash(self.y) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Point:equals(other)
    return getmetatable(other) == Point and self.x == other.x and self.y == other.y
end

____exports.count = 0

local function format(p)
    ____exports.count = ____exports.count + 1
    return "geo" .. __K2L_Str(p)
end

local function describe(self)
    return "point at x=" .. __K2L_Str(self.x) .. " y=" .. __K2L_Str(self.y)
end

local function origin()
    return Point.new(0.0, 0.0)
end

local Registry = __K2L_Class("draw.geometry.Registry")
__K2L_ClassInfo(Registry, "draw.geometry.Registry", "draw.geometry.Registry", "class")

function Registry:____init()
    self.names = __K2L_ListOf()
end

function Registry:register(name)
    self.names:add("geo:" .. name)
    ____exports.count = ____exports.count + 1
    return self.names.size
end

Registry:____init()
____exports.Point = Point
____exports.format = format
____exports.describe = describe
____exports.origin = origin
____exports.Registry = Registry
return ____exports
-- ==== main.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_KClassOf = ____lualib.__K2L_KClassOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str

local ____Point = require("geometry.Point")
local ____Point_1 = require("text.Point")
local ____format = require("text.format")
local ____Style_2ecommon = require("text.Style_common")
local Point = __K2L_Class("draw.Point")
__K2L_ClassInfo(Point, "draw.Point", "draw.Point", "class")

function Point:____init(label)
    self.label = label
end

function Point.new(label)
    return setmetatable({label = label}, Point)
end

function Point:toString()
    return "main.Point(" .. self.label .. ")"
end

local function format(p)
    return "main:" .. __K2L_Str(p)
end

local function main()
    local g = ____Point.Point.new(1.5, 2.0):plus(____Point.origin())
    local t = ____Point_1.Point.new(3, 7)
    local parsed = ____format.Point("4:2")
    local own = Point.new("here")
    print(____Point.format(g))
    print(____Point_1.format(t))
    print(format(own))
    print(____format.format("title", 8))
    print(____Point.describe(g))
    print(____Point_1.describe(t))
    print(__K2L_Str(__K2L_ReadOnlyListOf(parsed, t, ____Point_1.Point.new(3, 1)):sorted()))
    print(__K2L_Str(____format.____select(__K2L_ReadOnlyListOf(parsed, t, ____Point_1.Point.new(3, 1)), 3)))
    print("counts geo=" .. ____Point.count .. " text=" .. ____Point_1.count)
    ____Point.Registry:register("circle")
    ____Point_1.Registry:register("label")
    ____Point_1.Registry:register("caption")
    ____Point.count = ____Point.count + 5
    ____Point_1.count = ____Point_1.count - 1
    print("counts geo=" .. ____Point.count .. " text=" .. ____Point_1.count)
    print(__K2L_Str(____Point.Registry.names:plusAll(____Point_1.Registry.names)))
    ____format.____print("hello")
    print("type=" .. ____format.____type)
    print(____Style_2ecommon.styled("plain") .. " " .. ____Style_2ecommon.styled("loud", ____Style_2ecommon.Style.BOLD))
    ____Style_2ecommon.defaultStyle = ____Style_2ecommon.Style.BOLD
    print(____Style_2ecommon.styled("now bold"))
    local geoCount = "shadowed"
    print(geoCount)
    print(____Point.count)
    print(__K2L_Str(__K2L_KClassOf(____Point.Point).simpleName) .. " " .. __K2L_Str(__K2L_KClassOf(____Point.Point).qualifiedName))
    print(__K2L_Str(__K2L_KClassOf(____Point_1.Point).qualifiedName) .. " " .. __K2L_Str(__K2L_KClassOf(Point).qualifiedName))
    local ____list = __K2L_ReadOnlyListOf(g, t, own)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = __K2L_KClassOfValue(it).simpleName
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    print(getmetatable(own) == Point)
    local any = t
    print(tostring(getmetatable(any) == ____Point_1.Point) .. " " .. tostring(getmetatable(any) == ____Point.Point))
end

main()
return {Point = Point, format = format}
-- ==== text/Point.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Str = ____lualib.__K2L_Str

local ____exports = {}
local Point = __K2L_Class("draw.text.Point")
__K2L_ClassInfo(Point, "draw.text.Point", "draw.text.Point", "class")
Point.____comparable = true

function Point:____init(line, column)
    self.line = line
    self.column = column
end

function Point.new(line, column)
    return setmetatable({line = line, column = column}, Point)
end

local ____lambda_1 = function(it) return it.line end
local ____lambda_2 = function(it) return it.column end
function Point:compareTo(other)
    return __K2L_CompareBy(____lambda_1, ____lambda_2)(self, other)
end

function Point:toString()
    return self.line .. ":" .. self.column
end

____exports.count = 100

local function format(p)
    ____exports.count = ____exports.count + 1
    return "text@" .. __K2L_Str(p)
end

local function describe(self)
    return "line " .. self.line .. ", column " .. self.column
end

local Registry = __K2L_Class("draw.text.Registry")
__K2L_ClassInfo(Registry, "draw.text.Registry", "draw.text.Registry", "class")

function Registry:____init()
    self.names = __K2L_ListOf()
end

function Registry:register(name)
    self.names:add("text:" .. name)
    ____exports.count = ____exports.count + 10
    return self.names.size
end

Registry:____init()
____exports.Point = Point
____exports.format = format
____exports.describe = describe
____exports.Registry = Registry
return ____exports
-- ==== text/Style_common.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_LazyFile = ____lualib.__K2L_LazyFile

local ____exports = {}
local Style = __K2L_Class("draw.text.Style")
__K2L_ClassInfo(Style, "draw.text.Style", "draw.text.Style", "class")

function Style:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Style:toString()
    return self.name
end

function Style:compareTo(other)
    return self.ordinal - other.ordinal
end

Style.PLAIN = Style.new("PLAIN", 0)
Style.BOLD = Style.new("BOLD", 1)
Style.____values = {Style.PLAIN, Style.BOLD}

local function styled(text, style)
    if style == nil then
        style = ____exports.defaultStyle
    end
    return style == Style.BOLD and "**" .. text .. "**" or text
end

____exports.Style = Style
____exports.styled = styled
__K2L_LazyFile(____exports, function()
    ____exports.defaultStyle = Style.PLAIN
end, {"defaultStyle"})
return ____exports
-- ==== text/format.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_StringPadEnd = ____lualib.__K2L_StringPadEnd
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringToInt = ____lualib.__K2L_StringToInt

local ____Point = require("text.Point")

local function format(text, width)
    return __K2L_StringPadEnd(text, width, ".") .. "|"
end

local function Point(spec)
    local ____list = __K2L_StringSplit(spec, ":")
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = __K2L_StringToInt(it)
    end
    local ____destructured = __K2L_ListWrap(____out, ____count)
    local l, c = ____destructured[1], ____destructured[2]
    return ____Point.Point.new(l, c)
end

local ____type = "text-format"

local function ____print(msg)
    print("text.print: " .. msg)
end

local function ____select(points, line)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = points:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        if it.line == line then
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = it
        end
    end
    return __K2L_ListWrap(____out_1, ____count_1)
end

return {format = format, Point = Point, ____type = ____type, ____print = ____print, ____select = ____select}
