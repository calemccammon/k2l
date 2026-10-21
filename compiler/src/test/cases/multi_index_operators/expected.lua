local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringToInt = ____lualib.__K2L_StringToInt

local ____exports = {}
local Matrix = __K2L_Class("Matrix")

function Matrix:____init(rows, cols)
    self.rows = rows
    self.cols = cols
    self.data = __K2L_ListOfSize(self.rows * self.cols, 0, "[I")
end

function Matrix:get(i, j)
    return self.data[i * self.cols + j + 1] or __K2L_IndexError(i * self.cols + j, self.data.size, "array")
end

function Matrix:set(i, j, v)
    local ____object = self.data
    local ____key = i * self.cols + j
    if ____key < 0 or ____key >= ____object.size then
        __K2L_IndexError(____key, ____object.size, "array")
    end
    ____object[____key + 1] = v
end

function Matrix:get__1(row, col)
    return self:get(__K2L_StringToInt(row), __K2L_StringToInt(col))
end

function Matrix:set__1(row, col, v)
    self:set(__K2L_StringToInt(row), __K2L_StringToInt(col), v)
end

function Matrix:toString()
    return __K2L_IntRange.new(0, self.rows - 1):joinToString(" / ", nil, nil, nil, nil, function(i)
        return __K2L_IntRange.new(0, self.cols - 1):joinToString(",", nil, nil, nil, nil, function(j) return tostring(self:get(i, j)) end)
    end)
end

local Cube = __K2L_Class("Cube")

function Cube:____init()
    self.cells = __K2L_MapOf()
end

function Cube:get(x, y, z)
    return self.cells:get(x .. "/" .. y .. "/" .. z) or 0.0
end

function Cube:set(x, y, z, v)
    local ____object_1 = self.cells
    local ____key_1 = x .. "/" .. y .. "/" .. z
    ____object_1:set(____key_1, v)
end

local Grid = __K2L_Class("Grid")
local MapGrid = __K2L_Class("MapGrid", nil, Grid)

function MapGrid:____init(default)
    self.default = default
    self.cells = __K2L_HashMap.new()
end

function MapGrid:get(x, y)
    return self.cells:get(__K2L_Pair.new(x, y)) or self.default
end

function MapGrid:set(x, y, value)
    print("set " .. x .. "," .. y .. " = " .. __K2L_Str(value))
    local ____object_2 = self.cells
    local ____key_2 = __K2L_Pair.new(x, y)
    ____object_2:set(____key_2, value)
end

local TextGrid = __K2L_Class("TextGrid", MapGrid)

function TextGrid:____init()
    MapGrid.____init(self, ".")
end

local function get(self, i, j)
    return self:get(i):get(j)
end

local function set(____this, i, j, v)
    local ____object_3 = ____this:get(i)
    ____object_3:set(j, v)
end

local Row = __K2L_Class("Row")

function Row:____init(values)
    self.values = values
end

function Row.new(values)
    return setmetatable({values = values}, Row)
end

function Row:get(i)
    return self.values:get(i)
end

local function get__1(____this_1, i, suffix)
    return ____this_1.values:get(i) .. suffix
end

local function set__1(____this_2, i, suffix, v)
    local ____object_4 = ____this_2.values
    ____object_4:set(i, v .. suffix)
end

____exports.calls = 0

local function index(n)
    ____exports.calls = ____exports.calls + 1
    print("index " .. n)
    return n
end

local function main()
    local m = Matrix.new(2, 3)
    m:set(0, 1, 5)
    m:set(1, 2, m:get(0, 1) * 2)
    m:set(0, 1, m:get(0, 1) + 3)
    m:set(1, 2, m:get(1, 2) - 4)
    m:set(0, 0, m:get(0, 0) + 1)
    m:set(0, 0, m:get(0, 0) + 1)
    m:set(1, 1, m:get(1, 1) - 1)
    m:set(1, 0, m:get(1, 0) + 1)
    print(__K2L_Str(m))
    local ____old = m:get(0, 1)
    m:set(0, 1, m:get(0, 1) + 1)
    local old = ____old
    m:set(0, 1, m:get(0, 1) + 1)
    local new = m:get(0, 1)
    print(old .. " " .. new .. " " .. m:get(0, 1))
    m:set__1("1", "1", 9)
    m:set__1("1", "1", m:get__1("1", "1") * 2)
    print(m:get__1("1", "1"))
    print(__K2L_Str(m))
    local ____key_3 = index(1)
    local ____key_4 = index(2)
    m:set(____key_3, ____key_4, m:get(____key_3, ____key_4) + 100)
    local ____key_5 = index(0)
    local ____key_6 = index(2)
    m:set(____key_5, ____key_6, m:get(____key_5, ____key_6) + 1)
    print(__K2L_Str(m) .. ", " .. ____exports.calls .. " calls")
    local c = Cube.new()
    c:set(1, 2, 3, 1.5)
    c:set(1, 2, 3, c:get(1, 2, 3) + 2.0)
    c:set(0, 0, 0, c:get(0, 0, 0) - 1.0)
    print(__K2L_Str(c:get(1, 2, 3)) .. " " .. __K2L_Str(c:get(0, 0, 0)) .. " " .. __K2L_Str(c:get(9, 9, 9)))
    local g = TextGrid.new()
    g:set(0, 0, "a")
    g:set(0, 0, g:get(0, 0) .. "b")
    print(g:get(0, 0) .. g:get(5, 5))
    local counts = MapGrid.new(0)
    for i = 0, 2 do
        local ____key_7 = i >= 0 and i % 2 or 0 - -i % 2
        counts:set(____key_7, 0, counts:get(____key_7, 0) + 1)
    end
    print(counts:get(0, 0) .. " " .. counts:get(1, 0))
    local ____table = __K2L_ReadOnlyListOf(__K2L_ListOf(1, 2), __K2L_ListOf(3, 4))
    set(____table, 1, 0, 30)
    set(____table, 0, 1, get(____table, 0, 1) * 10)
    set(____table, 1, 1, get(____table, 1, 1) + 1)
    print(__K2L_Str(____table) .. " " .. get(____table, 1, 0))
    local row = Row.new(__K2L_ListOf("x", "y"))
    set__1(row, 1, "!", "z")
    set__1(row, 0, "?", get__1(row, 0, "?") .. "w")
    print(row:get(0) .. " " .. row:get(1) .. " " .. get__1(row, 0, "."))
end

____exports.Matrix = Matrix
____exports.Cube = Cube
____exports.Grid = Grid
____exports.MapGrid = MapGrid
____exports.TextGrid = TextGrid
____exports.get = get
____exports.set = set
____exports.Row = Row
____exports.get__1 = get__1
____exports.set__1 = set__1
____exports.index = index
__K2L_Main(main)
return ____exports
