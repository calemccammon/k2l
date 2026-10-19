local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_DoubleToLong = ____lualib.__K2L_DoubleToLong
local __K2L_GenerateSequence = ____lualib.__K2L_GenerateSequence
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local fmt
local Matrix = __K2L_Class("Matrix")

function Matrix:____init(rows, cols, init)
    if init == nil then
        init = function(_, _) return 0.0 end
    end
    self.rows = rows
    self.cols = cols
    self.data = __K2L_ListOfSize(self.rows, function(r)
        return __K2L_ListOfSize(self.cols, function(c) return init(r, c) end, true)
    end, true)
end

function Matrix:get(r, c)
    return self.data:get(r):get(c)
end

function Matrix:set(r, c, v)
    local ____object = self.data:get(r)
    ____object:set(c, v)
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
            m:swapRows(pivot, col)
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
        return c < n and self:get(r, c) or b:get(r)
    end)
    for col = 0, n - 1 do
        local pivot = __K2L_IntRange.new(col, n - 1):maxBy(function(it) return math.abs(aug:get(it, col)) end)
        if not (math.abs(aug:get(pivot, col)) > 1.0E-12) then
            error(__K2L_IllegalStateException.new("singular matrix"))
        end
        aug:swapRows(pivot, col)
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

function Matrix:swapRows(a, b)
    local t = self.data:get(a)
    local ____object_1 = self.data
    ____object_1:set(a, self.data:get(b))
    local ____object_2 = self.data
    ____object_2:set(b, t)
end

function Matrix:copy()
    return Matrix.new(self.rows, self.cols, function(r, c) return self:get(r, c) end)
end

function Matrix:equals(other)
    return __K2L_InstanceOf(other, Matrix) and other.rows == self.rows and other.cols == self.cols and __K2L_IntRange.new(0, self.rows - 1):all(function(r)
        return self.data:get(r):contentEquals(other.data:get(r))
    end)
end

function Matrix:hashCode()
    return self.data:fold(self.rows * 31 + self.cols, function(h, row) return h * 31 + row:contentHashCode() end)
end

function Matrix:toString()
    return self.data:joinToString("\n", nil, nil, nil, nil, function(row)
        return row:joinToString(" ", nil, nil, nil, nil, function(it) return __K2L_StringFormat("%7.2f", it) end)
    end)
end

function Matrix:identity(n)
    return Matrix.new(n, n, function(r, c) return r == c and 1.0 or 0.0 end)
end

function Matrix:of(...)
    local rows = __K2L_ArrayOf(...)
    return Matrix.new(rows.size, rows:get(0).size, function(r, c) return rows:get(r):get(c) end)
end

local Meters = __K2L_Class("Meters")

function Meters:____init(value)
    self.value = value
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
    return __K2L_StringFormat("%.2fm", self.value)
end

function Meters:hashCode()
    return __K2L_Hash(self.value)
end

function Meters:equals(other)
    return getmetatable(other) == Meters and self.value == other.value
end

local Seconds = __K2L_Class("Seconds")

function Seconds:____init(value)
    self.value = value
end

function Seconds:toString()
    return "Seconds(value=" .. __K2L_Str(self.value) .. ")"
end

function Seconds:hashCode()
    return __K2L_Hash(self.value)
end

function Seconds:equals(other)
    return getmetatable(other) == Seconds and self.value == other.value
end

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

function Vec:____init(x, y)
    self.x = x
    self.y = y
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

function Vec:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.x) + __K2L_Hash(self.y))
end

function Vec:equals(other)
    return getmetatable(other) == Vec and self.x == other.x and self.y == other.y
end

function fmt(____this_2)
    return ____this_2 == math.floor(____this_2) + 0.0 and math.abs(____this_2) < 1.0E9 and tostring(__K2L_DoubleToLong(____this_2)) or __K2L_StringFormat("%.3f", ____this_2)
end

local function convexHull(points)
    local sorted = points:sortedWith(__K2L_CompareBy(function(it) return it.x end, function(it) return it.y end))
    local function half(list)
        local hull = __K2L_List.new()
        for _, p in ipairs(list) do
            while hull.size >= 2 and hull:get(hull.size - 1):minus(hull:get(hull.size - 2)):cross(p:minus(hull:get(hull.size - 2))) <= 0 do
                hull:removeAt(hull.size - 1)
            end
            hull:add(p)
        end
        return hull:dropLast(1)
    end
    return half(sorted):plusAll(half(sorted:asReversed()))
end

local function polygonArea(poly)
    return math.abs(poly:plus(poly:first()):zipWithNext(function(a, b) return a:cross(b) end):sum(0.0)) / 2
end

local Poly = __K2L_Class("Poly")

function Poly:____init(coefficients)
    self.coef = coefficients:dropLastWhile(function(it) return it == 0 end):ifEmpty(function() return __K2L_SingletonListOf(0) end)
end

function Poly:getDegree()
    return self.coef.size - 1
end

function Poly:plus(o)
    return Poly.new(__K2L_ListOfSize(math.max(self.coef.size, o.coef.size), function(it)
        return self.coef:getOrElse(it, function(it) return 0 end) + o.coef:getOrElse(it, function(it) return 0 end)
    end))
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
            out:set(____key, out:get(____key) + a * b)
        end
    end
    return Poly.new(out:toList())
end

function Poly:invoke(x)
    return self.coef:foldRight(0, function(c, acc) return acc * x + c end)
end

function Poly:derivative()
    return Poly.new(self.coef:drop(1):mapIndexed(function(i, c) return c * (i + 1) end))
end

function Poly:toString()
    return __K2L_Text.ifEmpty(__K2L_StringReplace(self.coef:withIndex():reversed():filter(function(it) return it.value ~= 0 end):joinToString(" + ", nil, nil, nil, nil, function(____destructured)
        local i, c = ____destructured.index, ____destructured.value
        if i == 0 then
            return tostring(c)
        elseif i == 1 then
            return __K2L_Str(c == 1 and "" or c) .. "x"
        else
            return __K2L_Str(c == 1 and "" or c) .. "x^" .. i
        end
    end), "+ -", "- "), function() return "0" end)
end

local function main()
    local a = Matrix:of(__K2L_ArrayOf(2.0, 1.0, -1.0), __K2L_ArrayOf(-3.0, -1.0, 2.0), __K2L_ArrayOf(-2.0, 1.0, 2.0))
    print("A =\n" .. __K2L_Str(a))
    print("det(A) = " .. fmt(a:determinant()))
    local x = a:solve(__K2L_ArrayOf(8.0, -11.0, -3.0))
    print("solve: " .. x:joinToString(nil, nil, nil, nil, nil, function(it) return fmt(it) end))
    print("A * I == A: " .. tostring(a:times(Matrix:identity(3)):equals(a)) .. ", A^T^T == A: " .. tostring(a:transpose():transpose():equals(a)))
    local b = Matrix.new(2, 3, function(r, c) return r * 3 + c + 1 + 0.0 end)
    print("B * B^T =\n" .. __K2L_Str(b:times(b:transpose())))
    print("-B + B is zero: " .. tostring(b:unaryMinus():plus(b):equals(Matrix.new(2, 3))))
    local ____ok, ____result = pcall(function()
        b:times(b)
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
            local e = ____error
            print("error: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    print(__K2L_Str(__K2L_RunCatching(function()
        return Matrix:of(__K2L_ArrayOf(1.0, 2.0), __K2L_ArrayOf(2.0, 4.0)):solve(__K2L_ArrayOf(1.0, 2.0))
    end):exceptionOrNull()))
    local hilbert = Matrix.new(4, 4, function(r, c) return 1.0 / (r + c + 1) end)
    print("det(H4) = " .. __K2L_StringFormat("%.6e", hilbert:determinant()))
    local m = Matrix:identity(2)
    m:set(0, 1, 5.0)
    m:set(1, 0, m:get(1, 0) + 2.0)
    print("edited: " .. __K2L_Str(m:get(0, 1)) .. " " .. __K2L_Str(m:get(1, 0)) .. " hash equal: " .. tostring(m:hashCode() == m:copy():hashCode()))
    local run = __K2L_ReadOnlyListOf(getM(400.0), getKm(1), getM(2.5):times(100.0)):fold(getM(0.0), function(acc, d) return acc:plus(d) end)
    print("distance " .. __K2L_Str(run) .. ", speed " .. __K2L_StringFormat("%.3f", div(run, Seconds.new(300.0))) .. " m/s, longest " .. __K2L_Str(__K2L_ReadOnlyListOf(getM(3.0), getM(12.5), getM(7.0)):max()))
    local legs = __K2L_ReadOnlyMapOf(__K2L_Pair.new("warmup", getM(800.0)), __K2L_Pair.new("main", getKm(5)), __K2L_Pair.new("cooldown", getM(400.0)))
    print("legs sorted: " .. __K2L_Str(legs:getEntries():sortedBy(function(it) return it.value end, true):map(function(it) return it.key end)) .. " total " .. __K2L_Str(legs:getValues():reduce(function(self, ...) return self:plus(...) end)))
    local pts = __K2L_ReadOnlyListOf(Vec.new(0.0, 0.0), Vec.new(4.0, 0.0), Vec.new(4.0, 3.0), Vec.new(0.0, 3.0), Vec.new(2.0, 1.0), Vec.new(1.0, 2.0), Vec.new(2.0, 5.0), Vec.new(3.0, 1.5))
    local hull = convexHull(pts)
    print("hull: " .. __K2L_Str(hull) .. " area=" .. fmt(polygonArea(hull)))
    local v = Vec.new(3.0, 4.0)
    print("|v|=" .. fmt(v:getLength()) .. " v·(1,0)=" .. fmt(v:dot(Vec.new(1.0, 0.0))) .. " v×(0,1)=" .. fmt(v:cross(Vec.new(0.0, 1.0))) .. " v*0.5=" .. __K2L_Str(v:times(0.5)))
    local ____destructured_1 = v:minus(Vec.new(1.0, 1.0))
    local vx, vy = ____destructured_1.x, ____destructured_1.y
    print("destructured: " .. __K2L_Str(vx) .. " " .. __K2L_Str(vy))
    local p = Poly.new(__K2L_ReadOnlyListOf(-1, 0, 1))
    local q = Poly.new(__K2L_ReadOnlyListOf(1, 1))
    print("p = " .. __K2L_Str(p) .. ", q = " .. __K2L_Str(q) .. ", p*q = " .. __K2L_Str(p:times(q)) .. ", p+q = " .. __K2L_Str(p:plus(q)) .. ", p' = " .. __K2L_Str(p:derivative()))
    print("p(3) = " .. p:invoke(3) .. ", (p*q)(2) = " .. p:times(q):invoke(2) .. ", degree " .. p:times(q):times(q):getDegree())
    local binomial = __K2L_GenerateSequence(Poly.new(__K2L_SingletonListOf(1)), function(it) return it:times(q) end):take(6):last()
    print("(x+1)^5 = " .. __K2L_Str(binomial) .. ", at 10: " .. binomial:invoke(10))
    print("zero: " .. __K2L_Str(Poly.new(__K2L_ReadOnlyListOf(0, 0))) .. " " .. __K2L_Str(p:plus(Poly.new(__K2L_ReadOnlyListOf(1, 0, -1)))))
end

main()
return {Matrix = Matrix, Meters = Meters, Seconds = Seconds, div = div, getM = getM, getKm = getKm, Vec = Vec, fmt = fmt, convexHull = convexHull, polygonArea = polygonArea, Poly = Poly}
