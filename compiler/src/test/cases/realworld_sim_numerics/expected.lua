local ____lualib = require("lualib_bundle")
local __K2L_ArithmeticException = ____lualib.__K2L_ArithmeticException
local __K2L_BigDecimal = ____lualib.__K2L_BigDecimal
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_FdLibm = ____lualib.__K2L_FdLibm
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_RoundingMode = ____lualib.__K2L_RoundingMode
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf

local function newton(f, df, x0, tol)
    if tol == nil then
        tol = 1.0E-15
    end
    local x = x0
    for i = 1, 100 do
        local step = f(x) / df(x)
        x = x - step
        if math.abs(step) <= tol * math.abs(x) then
            return __K2L_Pair.new(x, i)
        end
    end
    return __K2L_Pair.new(x, 100)
end

local function bisect(f, lo0, hi0)
    local lo = lo0
    local hi = hi0
    for it = 0, 199 do
        do
            local mid = (lo + hi) / 2
            if mid == lo or mid == hi then
                return mid
            end
            if f(mid) < 0 == (f(lo) < 0) then
                lo = mid
            else
                hi = mid
            end
        end
    end
    return (lo + hi) / 2
end

local function simpson(f, a, b, n)
    local h = (b - a) / n
    local sum = f(a) + f(b)
    for i = 1, n - 1 do
        sum = sum + f(a + i * h) * ((i >= 0 and i % 2 or 0 - -i % 2) == 1 and 4 or 2)
    end
    return sum * h / 3
end

local function rk4(f, y0, t1, steps)
    local h = t1 / steps
    local y = y0
    local t = 0.0
    for it = 0, steps - 1 do
        do
            local k1 = f(t, y)
            local k2 = f(t + h / 2, y + h * k1 / 2)
            local k3 = f(t + h / 2, y + h * k2 / 2)
            local k4 = f(t + h, y + h * k3)
            y = y + h / 6 * (k1 + 2 * k2 + 2 * k3 + k4)
            t = t + h
        end
    end
    return y
end

local Matrix = __K2L_Class("Matrix")

local ____lambda_1 = function(_, _) return 0.0 end
function Matrix:____init(rows, cols, init)
    if init == nil then
        init = ____lambda_1
    end
    self.rows = rows
    self.cols = cols
    self.data = __K2L_ListOfSize(self.rows, function(r)
        return __K2L_ListOfSize(self.cols, function(c) return init(r, c) end, "[D")
    end, "[[D")
end

function Matrix:get(r, c)
    return (self.data[r + 1] or __K2L_IndexError(r, self.data.size, "array")):get(c)
end

function Matrix:times(o)
    if self.cols ~= o.rows then
        error(__K2L_IllegalArgumentException.new("shape mismatch: " .. self.rows .. "x" .. self.cols .. " * " .. o.rows .. "x" .. o.cols))
    end
    return Matrix.new(self.rows, o.cols, function(r, c)
        return __K2L_IntRange.new(0, self.cols - 1):sumOf(function(it)
            return (self.data[r + 1] or __K2L_IndexError(r, self.data.size, "array")):get(it) * (o.data[it + 1] or __K2L_IndexError(it, o.data.size, "array")):get(c)
        end, 0.0)
    end)
end

function Matrix:transpose()
    return Matrix.new(self.cols, self.rows, function(r, c)
        return (self.data[c + 1] or __K2L_IndexError(c, self.data.size, "array")):get(r)
    end)
end

local ____lambda_2 = function(it) return __K2L_StringFormat("%10.5f", it) end
local ____lambda_3 = function(row)
    return row:joinToString(" ", nil, nil, nil, nil, ____lambda_2)
end
function Matrix:toString()
    return self.data:joinToString("\n", nil, nil, nil, nil, ____lambda_3)
end

local ____lambda_4 = function(r, c) return r == c and 1.0 or 0.0 end
function Matrix:identity(n)
    return Matrix.new(n, n, ____lambda_4)
end

local function solve(a, b)
    local n = a.rows
    local m = __K2L_ListOfSize(n, function(r)
        return __K2L_ListOfSize(n + 1, function(c)
            return c < n and a:get(r, c) or (b[r + 1] or __K2L_IndexError(r, b.size, "array"))
        end, "[D")
    end, "[[D")
    local det = 1.0
    for col = 0, n - 1 do
        local pivot = __K2L_IntRange.new(col, n - 1):maxBy(function(it)
            return math.abs((m[it + 1] or __K2L_IndexError(it, m.size, "array")):get(col))
        end)
        if math.abs((m[pivot + 1] or __K2L_IndexError(pivot, m.size, "array")):get(col)) < 1.0E-12 then
            error(__K2L_ArithmeticException.new("singular matrix at column " .. col))
        end
        if pivot ~= col then
            local t = m[pivot + 1] or __K2L_IndexError(pivot, m.size, "array")
            local ____value = m[col + 1] or __K2L_IndexError(col, m.size, "array")
            if pivot < 0 or pivot >= m.size then
                __K2L_IndexError(pivot, m.size, "array")
            end
            m[pivot + 1] = ____value
            if col < 0 or col >= m.size then
                __K2L_IndexError(col, m.size, "array")
            end
            m[col + 1] = t
            det = -det
        end
        det = det * (m[col + 1] or __K2L_IndexError(col, m.size, "array")):get(col)
        for r = col + 1, n - 1 do
            local factor = (m[r + 1] or __K2L_IndexError(r, m.size, "array")):get(col) / (m[col + 1] or __K2L_IndexError(col, m.size, "array")):get(col)
            for c = col, n do
                local ____object = m[r + 1] or __K2L_IndexError(r, m.size, "array")
                ____object[c + 1] = (____object[c + 1] or __K2L_IndexError(c, ____object.size, "array")) - factor * (m[col + 1] or __K2L_IndexError(col, m.size, "array")):get(c)
            end
        end
    end
    local x = __K2L_ListOfSize(n, 0.0, "[D")
    for r = n - 1, 0, -1 do
        local s = (m[r + 1] or __K2L_IndexError(r, m.size, "array")):get(n)
        for c = r + 1, n - 1 do
            s = s - (m[r + 1] or __K2L_IndexError(r, m.size, "array")):get(c) * (x[c + 1] or __K2L_IndexError(c, x.size, "array"))
        end
        local ____value_1 = s / (m[r + 1] or __K2L_IndexError(r, m.size, "array")):get(r)
        if r < 0 or r >= x.size then
            __K2L_IndexError(r, x.size, "array")
        end
        x[r + 1] = ____value_1
    end
    return __K2L_Pair.new(x, det)
end

local ____lambda_5 = function(it) return it * it - 2 end
local ____lambda_6 = function(it) return 2 * it end
local ____lambda_7 = function(it) return it * it * it - 10 end
local ____lambda_8 = function(it) return 3 * it * it end
local ____lambda_9 = function(it) return math.cos(it) - it end
local ____lambda_10 = function(it) return math.exp(it) - 3 end
local ____lambda_11 = function(it) return math.exp(it) end
local ____lambda_12 = function(____p1) return math.sin(____p1) end
local ____lambda_13 = function(it) return math.exp(-it * it) end
local ____lambda_14 = function(it) return 1 / it end
local ____lambda_15 = function(_, y) return y end
local ____lambda_16 = function(t, y) return -2 * t * y end
local ____lambda_17 = function(r, c)
    return __K2L_TypedArrayOf("[D", 2.0, 1.0, -1.0, -3.0, -1.0, 2.0, -2.0, 1.0, 2.0):get(r * 3 + c)
end
local ____lambda_18 = function(r, c) return 1.0 / (r + c + 1) end
local ____lambda_19 = function(it) return 1.0 end
local ____lambda_20 = function(r, c) return (r + 1.0) * (c + 1.0) end
local ____lambda_21 = function(____p1) return __K2L_BigDecimal.parse(____p1) end
local ____lambda_22 = function(____p1, ____p2) return ____p1:add(____p2) end
local function main()
    print("-- roots")
    local ____destructured = newton(____lambda_5, ____lambda_6, 1.0)
    local sqrt2, iterations = ____destructured.first, ____destructured.second
    print("sqrt(2) = " .. __K2L_Str(sqrt2) .. " in " .. iterations .. " steps, exact " .. tostring(sqrt2 == math.sqrt(2.0)))
    local ____destructured_1 = newton(____lambda_7, ____lambda_8, 2.0)
    local cubeRoot = ____destructured_1.first
    print("cbrt(10) = " .. __K2L_Str(cubeRoot) .. " vs " .. __K2L_Str(__K2L_FdLibm.cbrt(10.0)))
    local dottie = bisect(____lambda_9, 0.0, 1.0)
    print("dottie number = " .. __K2L_Str(dottie))
    local ____destructured_2 = newton(____lambda_10, ____lambda_11, 1.0)
    local lnRoot = ____destructured_2.first
    print("ln(3) = " .. __K2L_Str(lnRoot) .. " vs " .. __K2L_Str(math.log(3.0)))
    print("-- integrals")
    local ____list = __K2L_ReadOnlyListOf(2, 10, 100, 1000)
    for ____i = 1, ____list.size do
        local n = ____list[____i]
        print("sin 0..pi n=" .. n .. ": " .. __K2L_Str(simpson(____lambda_12, 0.0, math.pi, n)))
    end
    local gauss = simpson(____lambda_13, -6.0, 6.0, 600)
    print("gaussian " .. __K2L_Str(gauss) .. " sqrt(pi) " .. __K2L_Str(math.sqrt(math.pi)) .. " diff " .. __K2L_Str(math.abs(gauss - math.sqrt(math.pi))))
    print("1/x 1..e: " .. __K2L_Str(simpson(____lambda_14, 1.0, 2.718281828459045, 64)))
    print("-- ode")
    local ____list_1 = __K2L_ReadOnlyListOf(1, 10, 100)
    for ____i_1 = 1, ____list_1.size do
        local steps = ____list_1[____i_1]
        print("y'=y, y(1) with " .. steps .. " steps: " .. __K2L_Str(rk4(____lambda_15, 1.0, 1.0, steps)))
    end
    print("y'=-2ty: " .. __K2L_Str(rk4(____lambda_16, 1.0, 2.0, 200)) .. " exact " .. __K2L_Str(math.exp(-4.0)))
    print("-- linear algebra")
    local a = Matrix.new(3, 3, ____lambda_17)
    local ____destructured_3 = solve(a, __K2L_TypedArrayOf("[D", 8.0, -11.0, -3.0))
    local x, det = ____destructured_3.first, ____destructured_3.second
    print("x = " .. __K2L_Str(x:toList()) .. " det = " .. __K2L_Str(det))
    local hilbert = Matrix.new(5, 5, ____lambda_18)
    local ____destructured_4 = solve(hilbert, __K2L_ListOfSize(5, ____lambda_19, "[D"))
    local hx, hdet = ____destructured_4.first, ____destructured_4.second
    local ____out = {}
    local ____count = 0
    local ____items, ____n = hx:____array()
    for ____i_2 = 1, ____n do
        local it = ____items[____i_2]
        ____count = ____count + 1
        ____out[____count] = __K2L_StringFormat("%.6f", it)
    end
    print("hilbert solution " .. __K2L_Str(__K2L_ListWrap(____out, ____count)) .. " det " .. __K2L_Str(hdet))
    local rot = Matrix.new(2, 2, function(r, c)
        if r == c then
            return math.cos(math.pi / 6)
        else
            return r == 0 and -math.sin(math.pi / 6) or math.sin(math.pi / 6)
        end
    end)
    local power = Matrix:identity(2)
    for it = 0, 11 do
        power = power:times(rot)
    end
    print("rotation^12 =\n" .. __K2L_Str(power))
    print("A * A^T =\n" .. __K2L_Str(a:times(a:transpose())))
    local ____ok, ____result = __K2L_DeepPcall(function()
        solve(Matrix.new(2, 2, ____lambda_20), __K2L_TypedArrayOf("[D", 1.0, 2.0))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_ArithmeticException) then
            local e = ____error
            print(__K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    local ____ok_1, ____result_1 = __K2L_DeepPcall(function()
        a:times(Matrix.new(2, 2))
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error_1, __K2L_IllegalArgumentException) then
            local e = ____error_1
            print(__K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
    print("-- series")
    local leibniz = 0.0
    for k = 0, 99999 do
        leibniz = leibniz + ((k >= 0 and k % 2 or 0 - -k % 2) == 0 and 1.0 or -1.0) / (2 * k + 1)
    end
    print("leibniz pi " .. __K2L_Str(leibniz * 4))
    local e = 1.0
    local term = 1.0
    for k = 1, 20 do
        term = term / k
        e = e + term
    end
    print("e series " .. __K2L_Str(e) .. " vs " .. __K2L_Str(2.718281828459045) .. " equal " .. tostring(e == 2.718281828459045))
    local harmonic = 0.0
    for k = 1, 1000 do
        harmonic = harmonic + 1.0 / k
    end
    print("H(1000) = " .. __K2L_Str(harmonic) .. ", minus ln = " .. __K2L_Str(harmonic - math.log(1000.0)))
    print("doubles: " .. __K2L_Str(__K2L_ReadOnlyListOf(0.1 * 3, 1.0 / 3, 2.0 / 3, 100.0 / 7, 1.0E-7, 1.23456789012E11, 1.0E21, 4.9E-324, 4.35, 0.3 - 0.1)))
    print("-- big decimal")
    print(__K2L_Str(__K2L_BigDecimal.valueOfDouble(0.1)))
    print(__K2L_Str(__K2L_BigDecimal.fromDouble(0.1)))
    print(__K2L_Str(__K2L_BigDecimal.valueOfDouble(sqrt2):setScale(20, __K2L_RoundingMode.HALF_EVEN)))
    print(__K2L_Str(__K2L_BigDecimal.valueOfDouble(dottie):setScale(8, __K2L_RoundingMode.HALF_UP)))
    print(__K2L_Str(__K2L_BigDecimal.valueOfDouble(leibniz):multiply(__K2L_BigDecimal.fromLong(4)):setScale(10, __K2L_RoundingMode.DOWN)))
    local total = __K2L_ReadOnlyListOf("0.1", "0.2", "0.3"):map(____lambda_21):fold(__K2L_BigDecimal.ZERO, ____lambda_22)
    print(__K2L_Str(total) .. " " .. __K2L_Str(total:toDouble()) .. " " .. __K2L_Str(0.1 + 0.2 + 0.3))
    print(__K2L_Str(__K2L_BigDecimal.fromLong(1):divide(__K2L_BigDecimal.fromLong(7), 30, __K2L_RoundingMode.HALF_EVEN)))
end

__K2L_DeepMain(main)
return {newton = newton, bisect = bisect, simpson = simpson, rk4 = rk4, Matrix = Matrix, solve = solve}
