local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_CompareValues = ____lualib.__K2L_CompareValues
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_GenerateSequence = ____lualib.__K2L_GenerateSequence
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Truncate = ____lualib.__K2L_Truncate

local fmt
local Matrix = __K2L_Class("Matrix")

local function swapRows(self, a, b)
    local t = self.data[a + 1] or __K2L_IndexError(a, self.data.size, "array")
    local ____object = self.data
    local ____value = self.data[b + 1] or __K2L_IndexError(b, self.data.size, "array")
    if a < 0 or a >= ____object.size then
        __K2L_IndexError(a, ____object.size, "array")
    end
    ____object[a + 1] = ____value
    local ____object_1 = self.data
    if b < 0 or b >= ____object_1.size then
        __K2L_IndexError(b, ____object_1.size, "array")
    end
    ____object_1[b + 1] = t
end

local ____lambda_1 = function(_, _) return 0.0 end
function Matrix:____init(rows, cols, init)
    if init == nil then
        init = ____lambda_1
    end
    self.rows = rows
    self.cols = cols
    self.data = __K2L_ListOfSize(self.rows, function(r)
        return __K2L_ListOfSize(self.cols, function(c) return init(r, c) end, true)
    end, true)
end

function Matrix:get(r, c)
    return (self.data[r + 1] or __K2L_IndexError(r, self.data.size, "array")):get(c)
end

function Matrix:set(r, c, v)
    local ____object_2 = self.data[r + 1] or __K2L_IndexError(r, self.data.size, "array")
    if c < 0 or c >= ____object_2.size then
        __K2L_IndexError(c, ____object_2.size, "array")
    end
    ____object_2[c + 1] = v
end

function Matrix:times(o)
    if self.cols ~= o.rows then
        error(__K2L_IllegalArgumentException.new("dimension mismatch: " .. self.rows .. "x" .. self.cols .. " * " .. o.rows .. "x" .. o.cols))
    end
    return Matrix.new(self.rows, o.cols, function(r, c)
        return __K2L_IntRange.new(0, self.cols - 1):sumOf(function(it) return self:get(r, it) * o:get(it, c) end, 0.0)
    end)
end

function Matrix:times__1(k)
    return Matrix.new(self.rows, self.cols, function(r, c) return self:get(r, c) * k end)
end

function Matrix:plus(o)
    return Matrix.new(self.rows, self.cols, function(r, c) return self:get(r, c) + o:get(r, c) end)
end

function Matrix:unaryMinus()
    return self:times__1(-1.0)
end

function Matrix:transpose()
    return Matrix.new(self.cols, self.rows, function(r, c) return self:get(c, r) end)
end

function Matrix:determinant()
    if self.rows ~= self.cols then
        error(__K2L_IllegalArgumentException.new("not square"))
    end
    local m = self:copy()
    local det = 1.0
    for col = 0, self.rows - 1 do
        local pivot = __K2L_IntRange.new(col, self.rows - 1):maxBy(function(it) return math.abs(m:get(it, col)) end)
        if math.abs(m:get(pivot, col)) < 1.0E-12 then
            return 0.0
        end
        if pivot ~= col then
            swapRows(m, pivot, col)
            det = -det
        end
        det = det * m:get(col, col)
        for r = col + 1, self.rows - 1 do
            local f = m:get(r, col) / m:get(col, col)
            for c = col, self.cols - 1 do
                m:set(r, c, m:get(r, c) - f * m:get(col, c))
            end
        end
    end
    return det
end

function Matrix:solve(b)
    local n = self.rows
    local aug = Matrix.new(n, n + 1, function(r, c)
        return c < n and self:get(r, c) or (b[r + 1] or __K2L_IndexError(r, b.size, "array"))
    end)
    for col = 0, n - 1 do
        local pivot = __K2L_IntRange.new(col, n - 1):maxBy(function(it) return math.abs(aug:get(it, col)) end)
        if not (math.abs(aug:get(pivot, col)) > 1.0E-12) then
            error(__K2L_IllegalStateException.new("singular matrix"))
        end
        swapRows(aug, pivot, col)
        for r = 0, n - 1 do
            do
                if r == col then
                    goto ____continue
                end
                local f = aug:get(r, col) / aug:get(col, col)
                for c = col, n do
                    aug:set(r, c, aug:get(r, c) - f * aug:get(col, c))
                end
            end
            ::____continue::
        end
    end
    return __K2L_ListOfSize(n, function(it) return aug:get(it, n) / aug:get(it, it) end, true)
end

function Matrix:copy()
    return Matrix.new(self.rows, self.cols, function(r, c) return self:get(r, c) end)
end

function Matrix:equals(other)
    return getmetatable(other) == Matrix and other.rows == self.rows and other.cols == self.cols and __K2L_IntRange.new(0, self.rows - 1):all(function(r)
        return (self.data[r + 1] or __K2L_IndexError(r, self.data.size, "array")):contentEquals(other.data[r + 1] or __K2L_IndexError(r, other.data.size, "array"))
    end)
end

local ____lambda_2 = function(h, row) return h * 31 + row:contentHashCode() end
function Matrix:hashCode()
    return self.data:fold(self.rows * 31 + self.cols, ____lambda_2)
end

local ____lambda_3 = function(it) return string.format("%7.2f", it) end
local ____lambda_4 = function(row)
    return row:joinToString(" ", nil, nil, nil, nil, ____lambda_3)
end
function Matrix:toString()
    return self.data:joinToString("\n", nil, nil, nil, nil, ____lambda_4)
end

local ____lambda_5 = function(r, c) return r == c and 1.0 or 0.0 end
function Matrix:identity(n)
    return Matrix.new(n, n, ____lambda_5)
end

function Matrix:of(...)
    local rows = __K2L_ArrayOf(...)
    return Matrix.new(rows.size, (rows[1] or __K2L_IndexError(0, rows.size, "array")).size, function(r, c)
        return (rows[r + 1] or __K2L_IndexError(r, rows.size, "array")):get(c)
    end)
end

local Meters = __K2L_Class("Meters")
Meters.____comparable = true

function Meters.new(value)
    return setmetatable({value = value}, Meters)
end

function Meters:plus(o)
    return Meters.new(self.value + o.value)
end

function Meters:times(k)
    return Meters.new(self.value * k)
end

function Meters:compareTo(other)
    return __K2L_Compare(self.value, other.value)
end

function Meters:toString()
    return string.format("%.2fm", self.value)
end

__K2L_DataClass(Meters, {"value"})
local Seconds = __K2L_Class("Seconds")

function Seconds.new(value)
    return setmetatable({value = value}, Seconds)
end

__K2L_DataClass(Seconds, {"value"})

local function div(self, t)
    return self.value / t.value
end

local function getM(____this)
    return Meters.new(____this)
end

local function getKm(____this_1)
    return Meters.new(____this_1 * 1000.0)
end

local Vec = __K2L_Class("Vec")

function Vec.new(x, y)
    return setmetatable({x = x, y = y}, Vec)
end

function Vec:plus(o)
    return Vec.new(self.x + o.x, self.y + o.y)
end

function Vec:minus(o)
    return Vec.new(self.x - o.x, self.y - o.y)
end

function Vec:times(k)
    return Vec.new(self.x * k, self.y * k)
end

function Vec:dot(o)
    return self.x * o.x + self.y * o.y
end

function Vec:cross(o)
    return self.x * o.y - self.y * o.x
end

function Vec:getLength()
    return math.sqrt(self:dot(self))
end

function Vec:toString()
    return "(" .. fmt(self.x) .. ", " .. fmt(self.y) .. ")"
end

__K2L_DataClass(Vec, {"x", "y"})

function fmt(____this_2)
    return ____this_2 == math.floor(____this_2) and math.abs(____this_2) < 1.0E9 and tostring(__K2L_Truncate(____this_2)) or string.format("%.3f", ____this_2)
end

local ____lambda_6 = function(____a, ____b)
    local ____c = __K2L_CompareValues(____a.x, ____b.x)
    if ____c ~= 0 then
        return ____c
    end
    return __K2L_CompareValues(____a.y, ____b.y)
end
local function convexHull(points)
    local sorted = points:sortedWith(____lambda_6)
    local function half(list)
        local hull = __K2L_List.new()
        for ____i = 1, list.size do
            local p = list[____i]
            while hull.size >= 2 and hull:get(hull.size - 1):minus(hull:get(hull.size - 2)):cross(p:minus(hull:get(hull.size - 2))) <= 0 do
                hull:removeAt(hull.size - 1)
            end
            hull:add(p)
        end
        return hull:dropLast(1)
    end
    return half(sorted):plusAll(half(sorted:asReversed()))
end

local ____lambda_7 = function(a, b) return a:cross(b) end
local function polygonArea(poly)
    return math.abs(poly:plus(poly:first()):zipWithNext(____lambda_7):sum(0.0)) / 2
end

local Poly = __K2L_Class("Poly")

local ____lambda_8 = function(it) return it == 0 end
local ____lambda_9 = function() return __K2L_ListOf(0) end
function Poly:____init(coefficients)
    self.coef = coefficients:dropLastWhile(____lambda_8):ifEmpty(____lambda_9)
end

function Poly:getDegree()
    return self.coef.size - 1
end

local ____lambda_10 = function(it) return 0 end
local ____lambda_11 = function(it) return 0 end
function Poly:plus(o)
    local ____size = math.max(self.coef.size, o.coef.size)
    local ____out = {}
    for ____i_1 = 1, ____size do
        local it = ____i_1 - 1
        local ____result
        ____result = self.coef:getOrElse(it, ____lambda_10) + o.coef:getOrElse(it, ____lambda_11)
        ____out[____i_1] = ____result
    end
    return Poly.new(__K2L_ListWrap(____out, ____size))
end

function Poly:times(o)
    local out = __K2L_ListOfSize(self.coef.size + o.coef.size - 1, 0, true)
    local ____list = self.coef
    for i = 0, ____list.size - 1 do
        local a = ____list[i + 1]
        local ____list_1 = o.coef
        for j = 0, ____list_1.size - 1 do
            local b = ____list_1[j + 1]
            local ____key = i + j
            out[____key + 1] = (out[____key + 1] or __K2L_IndexError(____key, out.size, "array")) + a * b
        end
    end
    return Poly.new(out:toList())
end

function Poly:invoke(x)
    return self.coef:foldRight(0, function(c, acc) return acc * x + c end)
end

function Poly:derivative()
    local ____list_2 = self.coef:drop(1)
    local ____out_1 = {}
    local ____count = 0
    local ____items, ____n = ____list_2:____array()
    for ____i_2 = 1, ____n do
        local c = ____items[____i_2]
        local i = ____i_2 - 1
        ____count = ____count + 1
        ____out_1[____count] = c * (i + 1)
    end
    return Poly.new(__K2L_ListWrap(____out_1, ____count))
end

local ____lambda_12 = function() return "0" end
function Poly:toString()
    local ____list_3 = self.coef:withIndex():reversed()
    local ____out_2 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_3:____array()
    for ____i_3 = 1, ____n_1 do
        local it = ____items_1[____i_3]
        if it.value ~= 0 then
            ____count_1 = ____count_1 + 1
            ____out_2[____count_1] = it
        end
    end
    return __K2L_Text.ifEmpty(__K2L_StringReplace(__K2L_ListWrap(____out_2, ____count_1):joinToString(" + ", nil, nil, nil, nil, function(____destructured)
        local i, c = ____destructured.index, ____destructured.value
        if i == 0 then
            return tostring(c)
        elseif i == 1 then
            return __K2L_Str(c == 1 and "" or c) .. "x"
        else
            return __K2L_Str(c == 1 and "" or c) .. "x^" .. i
        end
    end), "+ -", "- "), ____lambda_12)
end

local ____lambda_13 = function(it) return fmt(it) end
local ____lambda_14 = function(r, c) return r * 3 + c + 1 + 0.0 end
local ____lambda_15 = function()
    return Matrix:of(__K2L_ArrayOf(1.0, 2.0), __K2L_ArrayOf(2.0, 4.0)):solve(__K2L_ArrayOf(1.0, 2.0))
end
local ____lambda_16 = function(r, c) return 1.0 / (r + c + 1) end
local ____lambda_17 = function(acc, d) return acc:plus(d) end
local ____lambda_18 = function(it) return it.value end
local ____lambda_19 = function(self, ...) return self:plus(...) end
local function main()
    local a = Matrix:of(__K2L_ArrayOf(2.0, 1.0, -1.0), __K2L_ArrayOf(-3.0, -1.0, 2.0), __K2L_ArrayOf(-2.0, 1.0, 2.0))
    print("A =\n" .. __K2L_Str(a))
    print("det(A) = " .. fmt(a:determinant()))
    local x = a:solve(__K2L_ArrayOf(8.0, -11.0, -3.0))
    print("solve: " .. x:joinToString(nil, nil, nil, nil, nil, ____lambda_13))
    print("A * I == A: " .. tostring(a:times(Matrix:identity(3)):equals(a)) .. ", A^T^T == A: " .. tostring(a:transpose():transpose():equals(a)))
    local b = Matrix.new(2, 3, ____lambda_14)
    print("B * B^T =\n" .. __K2L_Str(b:times(b:transpose())))
    print("-B + B is zero: " .. tostring(b:unaryMinus():plus(b):equals(Matrix.new(2, 3))))
    local ____ok, ____result_1 = pcall(function()
        b:times(b)
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
            local e = ____error
            print("error: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    print(__K2L_Str(__K2L_RunCatching(____lambda_15):exceptionOrNull()))
    local hilbert = Matrix.new(4, 4, ____lambda_16)
    print("det(H4) = " .. string.format("%.6e", hilbert:determinant()))
    local m = Matrix:identity(2)
    m:set(0, 1, 5.0)
    m:set(1, 0, m:get(1, 0) + 2.0)
    print("edited: " .. m:get(0, 1) .. " " .. m:get(1, 0) .. " hash equal: " .. tostring(m:hashCode() == m:copy():hashCode()))
    local run = __K2L_ListOf(getM(400.0), getKm(1), getM(2.5):times(100.0)):fold(getM(0.0), ____lambda_17)
    print("distance " .. __K2L_Str(run) .. ", speed " .. string.format("%.3f", div(run, Seconds.new(300.0))) .. " m/s, longest " .. __K2L_Str(__K2L_ListOf(getM(3.0), getM(12.5), getM(7.0)):max()))
    local legs = __K2L_MapOf(__K2L_Pair.new("warmup", getM(800.0)), __K2L_Pair.new("main", getKm(5)), __K2L_Pair.new("cooldown", getM(400.0)))
    local ____list_4 = legs:getEntries():sortedBy(____lambda_18, true)
    local ____out_3 = {}
    local ____count_2 = 0
    local ____items_2, ____n_2 = ____list_4:____array()
    for ____i_4 = 1, ____n_2 do
        local it = ____items_2[____i_4]
        ____count_2 = ____count_2 + 1
        ____out_3[____count_2] = it.key
    end
    print("legs sorted: " .. __K2L_Str(__K2L_ListWrap(____out_3, ____count_2)) .. " total " .. __K2L_Str(legs:getValues():reduce(____lambda_19)))
    local pts = __K2L_ListOf(Vec.new(0.0, 0.0), Vec.new(4.0, 0.0), Vec.new(4.0, 3.0), Vec.new(0.0, 3.0), Vec.new(2.0, 1.0), Vec.new(1.0, 2.0), Vec.new(2.0, 5.0), Vec.new(3.0, 1.5))
    local hull = convexHull(pts)
    print("hull: " .. __K2L_Str(hull) .. " area=" .. fmt(polygonArea(hull)))
    local v = Vec.new(3.0, 4.0)
    print("|v|=" .. fmt(v:getLength()) .. " v·(1,0)=" .. fmt(v:dot(Vec.new(1.0, 0.0))) .. " v×(0,1)=" .. fmt(v:cross(Vec.new(0.0, 1.0))) .. " v*0.5=" .. __K2L_Str(v:times(0.5)))
    local ____destructured_1 = v:minus(Vec.new(1.0, 1.0))
    local vx, vy = ____destructured_1.x, ____destructured_1.y
    print("destructured: " .. vx .. " " .. vy)
    local p = Poly.new(__K2L_ListOf(-1, 0, 1))
    local q = Poly.new(__K2L_ListOf(1, 1))
    print("p = " .. __K2L_Str(p) .. ", q = " .. __K2L_Str(q) .. ", p*q = " .. __K2L_Str(p:times(q)) .. ", p+q = " .. __K2L_Str(p:plus(q)) .. ", p' = " .. __K2L_Str(p:derivative()))
    print("p(3) = " .. p:invoke(3) .. ", (p*q)(2) = " .. p:times(q):invoke(2) .. ", degree " .. p:times(q):times(q):getDegree())
    local binomial = __K2L_GenerateSequence(Poly.new(__K2L_ListOf(1)), function(it) return it:times(q) end):take(6):last()
    print("(x+1)^5 = " .. __K2L_Str(binomial) .. ", at 10: " .. binomial:invoke(10))
    print("zero: " .. __K2L_Str(Poly.new(__K2L_ListOf(0, 0))) .. " " .. __K2L_Str(p:plus(Poly.new(__K2L_ListOf(1, 0, -1)))))
end

__K2L_RunMain(main)
return {Matrix = Matrix, Meters = Meters, Seconds = Seconds, div = div, getM = getM, getKm = getKm, Vec = Vec, fmt = fmt, convexHull = convexHull, polygonArea = polygonArea, Poly = Poly}
