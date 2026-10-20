-- requires: Class, Exceptions, BigInteger, DoubleToString, ToInt32, IdentityHash, Collections
-- java.math.BigDecimal (an unscaled BigInteger `u` and an Int `s`: value = u * 10^-s), RoundingMode and MathContext.
local __K2L_RoundingMode = __K2L_Class("java.math.RoundingMode")
local __K2L_MathContext = __K2L_Class("java.math.MathContext")
local __K2L_BigDecimal = __K2L_Class("java.math.BigDecimal")
__K2L_BigDecimal.____isNumber = true -- for `is Number`

do

local BI = __K2L_BigInteger
local ZERO_I, ONE_I = BI.ZERO, BI.ONE
local MINUS_ONE_I = ONE_I:negate()
local max = math.max
local floor = math.floor

local function arithmetic(message)
    error(__K2L_ArithmeticException.new(message))
end

local function numberFormat(message)
    error(__K2L_NumberFormatException.new(message))
end

------------------------------------------------------------------ RoundingMode and MathContext
local MODES = {"UP", "DOWN", "CEILING", "FLOOR", "HALF_UP", "HALF_DOWN", "HALF_EVEN", "UNNECESSARY"}
for i, name in ipairs(MODES) do
    __K2L_RoundingMode[name] = setmetatable({name = name, ordinal = i - 1}, __K2L_RoundingMode)
end
local UP, DOWN, CEILING, FLOOR = __K2L_RoundingMode.UP, __K2L_RoundingMode.DOWN, __K2L_RoundingMode.CEILING, __K2L_RoundingMode.FLOOR
local HALF_UP, HALF_DOWN, HALF_EVEN = __K2L_RoundingMode.HALF_UP, __K2L_RoundingMode.HALF_DOWN, __K2L_RoundingMode.HALF_EVEN
local UNNECESSARY = __K2L_RoundingMode.UNNECESSARY

function __K2L_RoundingMode:toString()
    return self.name
end

__K2L_RoundingMode.__tostring = __K2L_RoundingMode.toString

function __K2L_RoundingMode:hashCode()
    return __K2L_IdentityHash(self)
end

function __K2L_RoundingMode.valueOf(name)
    local mode = rawget(__K2L_RoundingMode, name)
    if type(name) ~= "string" or getmetatable(mode) ~= __K2L_RoundingMode then
        error(__K2L_IllegalArgumentException.new("No enum constant java.math.RoundingMode." .. tostring(name)))
    end
    return mode
end

function __K2L_RoundingMode.values()
    return __K2L_ArrayOf(UP, DOWN, CEILING, FLOOR, HALF_UP, HALF_DOWN, HALF_EVEN, UNNECESSARY)
end

function __K2L_MathContext:____init(precision, mode)
    if precision < 0 then
        error(__K2L_IllegalArgumentException.new("Digits < 0"))
    end
    self.precision = precision
    self.roundingMode = mode or HALF_UP
end

function __K2L_MathContext:toString()
    return "precision=" .. self.precision .. " roundingMode=" .. self.roundingMode.name
end

__K2L_MathContext.__tostring = __K2L_MathContext.toString

function __K2L_MathContext:equals(o)
    return getmetatable(o) == __K2L_MathContext and o.precision == self.precision and o.roundingMode == self.roundingMode
end

function __K2L_MathContext:hashCode()
    return __K2L_ToInt32(self.precision + self.roundingMode.ordinal * 59)
end

__K2L_MathContext.UNLIMITED = __K2L_MathContext.new(0, HALF_UP)
__K2L_MathContext.DECIMAL32 = __K2L_MathContext.new(7, HALF_EVEN)
__K2L_MathContext.DECIMAL64 = __K2L_MathContext.new(16, HALF_EVEN)
__K2L_MathContext.DECIMAL128 = __K2L_MathContext.new(34, HALF_EVEN)

------------------------------------------------------------------ helpers
local function make(u, s)
    return setmetatable({u = u, s = s}, __K2L_BigDecimal)
end

local function isBigDecimal(o)
    return getmetatable(o) == __K2L_BigDecimal
end

local function check(o)
    if not isBigDecimal(o) then
        error(__K2L_NullPointerException.new(nil))
    end
    return o
end

local function scaleUp(u, n)
    return u:____mulPow10(n)
end

local function isOdd(q)
    return (q.mag[1] or 0) % 2 == 1
end

-- num / den rounded to an integer; den is nonzero
local function divRound(num, den, mode)
    local q, r = num:____divmod(den)
    if r.sign == 0 then
        return q
    end
    local sign = num.sign * den.sign
    local inc
    if mode == UP then
        inc = true
    elseif mode == DOWN then
        inc = false
    elseif mode == CEILING then
        inc = sign > 0
    elseif mode == FLOOR then
        inc = sign < 0
    elseif mode == UNNECESSARY then
        arithmetic("Rounding necessary")
    else
        local c = r:abs():shiftLeft(1):compareTo(den:abs())
        if c ~= 0 then
            inc = c > 0
        elseif mode == HALF_UP then
            inc = true
        elseif mode == HALF_DOWN then
            inc = false
        else
            inc = isOdd(q)
        end
    end
    if inc then
        q = q:add(sign > 0 and ONE_I or MINUS_ONE_I)
    end
    return q
end

local function precisionOf(x)
    return x.u:____digits()
end

local function divideByZero(x, y, scaled)
    if x.u.sign == 0 and y.u.sign == 0 and not scaled then
        arithmetic("Division undefined")
    elseif not scaled then
        arithmetic("Division by zero")
    elseif x.u:bitLength() < 64 and y.u:bitLength() < 64 then
        arithmetic("/ by zero")
    end
    arithmetic("BigInteger divide by zero")
end

-- x rounded to `precision` digits
local function roundTo(x, mc)
    local p = mc.precision
    if p == 0 then
        return x
    end
    local drop = precisionOf(x) - p
    while drop > 0 do
        x = make(divRound(x.u, BI.____pow10(drop), mc.roundingMode), x.s - drop)
        drop = precisionOf(x) - p
    end
    return x
end

-- u / v at the given result scale
local function divideAtScale(x, y, scale, mode)
    if y.u.sign == 0 then
        divideByZero(x, y, true)
    end
    local e = scale - x.s + y.s
    local num, den = x.u, y.u
    if e >= 0 then
        num = scaleUp(num, e)
    else
        den = scaleUp(den, -e)
    end
    return make(divRound(num, den, mode), scale)
end

local function stripZeros(u, s, preferred)
    while s > preferred and u.sign ~= 0 do
        local q, r = u:____divmod(BI.TEN)
        if r.sign ~= 0 then
            break
        end
        u, s = q, s - 1
    end
    return make(u, s)
end

local function exactDivide(x, y)
    if y.u.sign == 0 then
        divideByZero(x, y, false)
    end
    local pref = x.s - y.s
    if x.u.sign == 0 then
        return make(ZERO_I, pref)
    end
    local g = x.u:gcd(y.u)
    local n = x.u:divide(g)
    local d = y.u:divide(g)
    if d.sign < 0 then
        n, d = n:negate(), d:negate()
    end
    local twos, fives = 0, 0
    local rest = d
    while true do
        local q, r = rest:____divmod(BI.TWO)
        if r.sign ~= 0 then
            break
        end
        rest, twos = q, twos + 1
    end
    local five = BI.valueOf(5)
    while true do
        local q, r = rest:____divmod(five)
        if r.sign ~= 0 then
            break
        end
        rest, fives = q, fives + 1
    end
    if not rest:____isOne() then
        arithmetic("Non-terminating decimal expansion; no exact representable decimal result.")
    end
    local k = max(twos, fives)
    local q = scaleUp(n, k):divide(d)
    return make(q, pref + k)
end

local function divideMc(x, y, mc)
    local p = mc.precision
    if p == 0 then
        return exactDivide(x, y)
    end
    if y.u.sign == 0 then
        divideByZero(x, y, false)
    end
    local pref = x.s - y.s
    if x.u.sign == 0 then
        return make(ZERO_I, pref)
    end
    local k = p - (precisionOf(x) - precisionOf(y))
    local limit = BI.____pow10(p)
    local num, den, q, r
    for _ = 1, 2 do
        num, den = x.u, y.u
        if k >= 0 then
            num = scaleUp(num, k)
        else
            den = scaleUp(den, -k)
        end
        q, r = num:____divmod(den)
        if q:abs():compareTo(limit) < 0 then
            break
        end
        k = k - 1
    end
    local scale = pref + k
    if r.sign == 0 then
        return stripZeros(q, scale, pref)
    end
    q = divRound(num, den, mc.roundingMode)
    if q:abs():compareTo(limit) >= 0 then
        q, scale = q:divide(BI.TEN), scale - 1
    end
    return make(q, scale)
end

local function plain(x)
    local coeff = x.u:abs():toString()
    local s = x.s
    local out
    if s == 0 then
        out = coeff
    elseif s < 0 then
        out = x.u.sign == 0 and "0" or coeff .. string.rep("0", -s)
    elseif #coeff > s then
        out = coeff:sub(1, #coeff - s) .. "." .. coeff:sub(#coeff - s + 1)
    else
        out = "0." .. string.rep("0", s - #coeff) .. coeff
    end
    return x.u.sign < 0 and "-" .. out or out
end

local function sci(x)
    local coeff = x.u:abs():toString()
    local s = x.s
    local sign = x.u.sign < 0 and "-" or ""
    if s == 0 then
        return sign .. coeff
    end
    local adjusted = -s + (#coeff - 1)
    if s > 0 and adjusted >= -6 then
        return plain(x)
    end
    local out = coeff:sub(1, 1)
    if #coeff > 1 then
        out = out .. "." .. coeff:sub(2)
    end
    if adjusted ~= 0 then
        out = out .. "E" .. (adjusted > 0 and "+" or "") .. adjusted
    end
    return sign .. out
end

-- returns a BigDecimal, or nil and the JVM's message
local function parse(str)
    local len = #str
    if len == 0 then
        return nil, nil
    end
    local pos = 1
    local negative = false
    local c = str:sub(1, 1)
    if c == "-" then
        negative, pos = true, 2
    elseif c == "+" then
        pos = 2
    end
    local digits, dot, fracDigits = {}, false, 0
    local exp = 0
    while pos <= len do
        c = str:sub(pos, pos)
        if c:match("%d") then
            digits[#digits + 1] = c
            if dot then
                fracDigits = fracDigits + 1
            end
        elseif c == "." then
            if dot then
                return nil, "Character array contains more than one decimal point."
            end
            dot = true
        elseif c == "e" or c == "E" then
            if #digits == 0 then
                return nil, "No digits found."
            end
            local expText = str:sub(pos + 1)
            local sign = expText:sub(1, 1)
            if sign == "-" or sign == "+" then
                expText = expText:sub(2)
            end
            if expText == "" then
                return nil, nil
            end
            if expText:find("%D") then
                return nil, "Not a digit."
            end
            exp = tonumber(expText)
            if sign == "-" then
                exp = -exp
            end
            if exp > 2147483647 or exp < -2147483648 then
                return nil, "Exponent overflow."
            end
            break
        else
            return nil, "Character " .. c .. ' is neither a decimal digit number, decimal point, nor "e" notation exponential mark.'
        end
        pos = pos + 1
    end
    if #digits == 0 then
        return nil, "No digits found."
    end
    local u = BI.parse(table.concat(digits), 10)
    if negative then
        u = u:negate()
    end
    return make(u, fracDigits - exp)
end

-- the exact value of a double
local function fromDouble(d)
    if d ~= d or d == math.huge or d == -math.huge then
        numberFormat("Infinite or NaN")
    end
    if d == 0 then
        return make(ZERO_I, 0)
    end
    local negative = d < 0
    local x = negative and -d or d
    x = x + 0.0
    local e = 0
    while x >= 9007199254740992 do
        x = x / 2
        e = e + 1
    end
    while x ~= floor(x) do
        x = x * 2
        e = e - 1
    end
    -- x is an integer below 2^53 now; drop trailing zero bits
    local m = floor(x)
    while m % 2 == 0 and e < 0 do
        m = m / 2
        e = e + 1
    end
    local u = BI.valueOf(m)
    local result
    if e >= 0 then
        result = make(u:shiftLeft(e), 0)
    else
        result = make(u:multiply(BI.valueOf(5):pow(-e)), -e)
    end
    if negative then
        result = make(result.u:negate(), result.s)
    end
    return result
end

------------------------------------------------------------------ construction
__K2L_BigDecimal.ZERO = make(ZERO_I, 0)
__K2L_BigDecimal.ONE = make(ONE_I, 0)
__K2L_BigDecimal.TWO = make(BI.TWO, 0)
__K2L_BigDecimal.TEN = make(BI.TEN, 0)

-- BigDecimal(String)
function __K2L_BigDecimal.parse(str)
    local result, message = parse(str)
    if result == nil then
        numberFormat(message)
    end
    return result
end

-- String.toBigDecimalOrNull()
function __K2L_BigDecimal.parseOrNull(str)
    return (parse(str))
end

-- BigDecimal(Int) and BigDecimal(Long)
function __K2L_BigDecimal.fromLong(x)
    return make(BI.valueOf(x), 0)
end

-- BigDecimal(BigInteger[, scale]) and BigInteger.toBigDecimal([scale])
function __K2L_BigDecimal.fromBigInteger(u, scale)
    return make(u, scale or 0)
end

-- BigDecimal(Double): the exact binary value
function __K2L_BigDecimal.fromDouble(d)
    return fromDouble(d)
end

-- Double.toBigDecimal() and BigDecimal.valueOf(Double): through the shortest decimal string
function __K2L_BigDecimal.valueOfDouble(d)
    return __K2L_BigDecimal.parse(__K2L_DoubleToString(d))
end

-- BigDecimal.valueOf(Long[, scale])
function __K2L_BigDecimal.valueOf(x, scale)
    return make(BI.valueOf(x), scale or 0)
end

------------------------------------------------------------------ arithmetic
function __K2L_BigDecimal:add(o, mc)
    check(o)
    local s = max(self.s, o.s)
    local r = make(scaleUp(self.u, s - self.s):add(scaleUp(o.u, s - o.s)), s)
    return mc and roundTo(r, mc) or r
end

-- lets the generic sumOf loop (total + x) work
function __K2L_BigDecimal.__add(a, b)
    return a:add(b)
end

function __K2L_BigDecimal:subtract(o, mc)
    check(o)
    local s = max(self.s, o.s)
    local r = make(scaleUp(self.u, s - self.s):subtract(scaleUp(o.u, s - o.s)), s)
    return mc and roundTo(r, mc) or r
end

function __K2L_BigDecimal:multiply(o, mc)
    check(o)
    local r = make(self.u:multiply(o.u), self.s + o.s)
    return mc and roundTo(r, mc) or r
end

-- divide(o), divide(o, mode), divide(o, mc) and divide(o, scale, mode)
function __K2L_BigDecimal:divide(o, a, b)
    check(o)
    if a == nil then
        return exactDivide(self, o)
    elseif b ~= nil then
        return divideAtScale(self, o, a, b)
    elseif getmetatable(a) == __K2L_MathContext then
        return divideMc(self, o, a)
    end
    return divideAtScale(self, o, self.s, a)
end

-- Kotlin's `/`
function __K2L_BigDecimal:div(o)
    return divideAtScale(self, check(o), self.s, HALF_EVEN)
end

function __K2L_BigDecimal:divideToIntegralValue(o)
    check(o)
    if o.u.sign == 0 then
        divideByZero(self, o, false)
    end
    local pref = self.s - o.s
    local s = max(self.s, o.s)
    local q = scaleUp(self.u, s - self.s):divide(scaleUp(o.u, s - o.s))
    if q.sign == 0 then
        return make(ZERO_I, pref)
    end
    local r = stripZeros(q, 0, pref)
    if r.s < pref then
        r = make(scaleUp(r.u, pref - r.s), pref)
    end
    return r
end

function __K2L_BigDecimal:remainder(o)
    local q = self:divideToIntegralValue(o)
    return self:subtract(q:multiply(o))
end

function __K2L_BigDecimal:divideAndRemainder(o)
    local q = self:divideToIntegralValue(o)
    return __K2L_ArrayOf(q, self:subtract(q:multiply(o)))
end

function __K2L_BigDecimal:pow(n, mc)
    if n < 0 or n > 999999999 then
        arithmetic("Invalid operation")
    end
    local r = make(self.u:pow(n), self.s * n)
    return mc and roundTo(r, mc) or r
end

function __K2L_BigDecimal:negate()
    return make(self.u:negate(), self.s)
end

function __K2L_BigDecimal:abs()
    return self.u.sign < 0 and make(self.u:negate(), self.s) or self
end

function __K2L_BigDecimal:signum()
    return self.u.sign
end

function __K2L_BigDecimal:inc()
    return self:add(__K2L_BigDecimal.ONE)
end

function __K2L_BigDecimal:dec()
    return self:subtract(__K2L_BigDecimal.ONE)
end

function __K2L_BigDecimal:scale()
    return self.s
end

function __K2L_BigDecimal:precision()
    return precisionOf(self)
end

function __K2L_BigDecimal:unscaledValue()
    return self.u
end

function __K2L_BigDecimal:round(mc)
    return roundTo(self, mc)
end

function __K2L_BigDecimal:setScale(n, mode)
    if n == self.s then
        return self
    elseif n > self.s then
        return make(scaleUp(self.u, n - self.s), n)
    end
    return make(divRound(self.u, BI.____pow10(self.s - n), mode or UNNECESSARY), n)
end

function __K2L_BigDecimal:stripTrailingZeros()
    if self.u.sign == 0 then
        return __K2L_BigDecimal.ZERO
    end
    local u, s = self.u, self.s
    local mag = u.mag
    local zeroLimbs = 0
    while mag[zeroLimbs + 1] == 0 do
        zeroLimbs = zeroLimbs + 1
    end
    if zeroLimbs > 0 then
        local rest = {}
        for i = zeroLimbs + 1, #mag do
            rest[#rest + 1] = mag[i]
        end
        u, s = BI.____make(u.sign, rest), s - zeroLimbs * BI.____limbDigits
    end
    return stripZeros(u, s, -2147483648)
end

local function movePoint(x, newScale)
    local r = make(x.u, newScale)
    if newScale < 0 then
        return r:setScale(0, UNNECESSARY)
    end
    return r
end

function __K2L_BigDecimal:movePointLeft(n)
    if n == 0 then
        return self
    end
    return movePoint(self, self.s + n)
end

function __K2L_BigDecimal:movePointRight(n)
    if n == 0 then
        return self
    end
    return movePoint(self, self.s - n)
end

function __K2L_BigDecimal:scaleByPowerOfTen(n)
    return make(self.u, self.s - n)
end

function __K2L_BigDecimal:compareTo(o)
    check(o)
    if self.u.sign ~= o.u.sign then
        return self.u.sign < o.u.sign and -1 or 1
    end
    local s = max(self.s, o.s)
    return scaleUp(self.u, s - self.s):compareTo(scaleUp(o.u, s - o.s))
end

function __K2L_BigDecimal:min(o)
    return self:compareTo(o) <= 0 and self or o
end

function __K2L_BigDecimal:max(o)
    return self:compareTo(o) >= 0 and self or o
end

function __K2L_BigDecimal:equals(o)
    return isBigDecimal(o) and self.s == o.s and self.u:equals(o.u)
end

function __K2L_BigDecimal:hashCode()
    return __K2L_ToInt32(31 * self.u:hashCode() + self.s)
end

------------------------------------------------------------------ sqrt
local ONE_HALF, ONE_TENTH = make(BI.valueOf(5), 1), make(ONE_I, 1)

-- Java's int division by two (truncates toward zero)
local function halfOf(n)
    return n >= 0 and floor(n / 2) or -floor(-n / 2)
end

-- BigDecimal.sqrt(mc): the JDK's algorithm. A Newton iteration from the double square root, to twice the requested
-- precision for the HALF_* modes (so the final rounding is right), then a fix-up for the directed modes and the
-- preferred scale (this.scale() / 2). Exact results (UNNECESSARY or an unlimited precision) are verified by squaring.
function __K2L_BigDecimal:sqrt(mc)
    local signum = self.u.sign
    if signum < 0 then
        arithmetic("Attempted square root of negative BigDecimal")
    elseif signum == 0 then
        return make(ZERO_I, halfOf(self.s))
    end
    local preferredScale = halfOf(self.s)
    local zeroAtPreferred = make(ZERO_I, preferredScale)
    local stripped = self:stripTrailingZeros()
    local strippedScale = stripped.s
    if stripped.u:equals(ONE_I) and strippedScale % 2 == 0 then
        local result = make(ONE_I, halfOf(strippedScale))
        if result.s ~= preferredScale then
            result = result:add(zeroAtPreferred, mc)
        end
        return result
    end
    -- normalize to 0.1 <= working < 10 with an even scale adjustment
    local scale = strippedScale - precisionOf(stripped) + 1
    local scaleAdjust = scale % 2 == 0 and scale or scale - 1
    local working = make(stripped.u, stripped.s - scaleAdjust)
    local guess = fromDouble(math.sqrt(working:toDouble()))
    local guessPrecision = 15
    local originalPrecision = mc.precision
    local targetRm = mc.roundingMode
    local targetPrecision
    if originalPrecision == 0 then
        targetPrecision = floor(precisionOf(stripped) / 2) + 1
    elseif targetRm == HALF_UP or targetRm == HALF_DOWN or targetRm == HALF_EVEN then
        targetPrecision = 2 * originalPrecision
    else
        targetPrecision = originalPrecision
    end
    local approx = guess
    local workingPrecision = precisionOf(working)
    repeat
        local tmpPrecision = max(max(guessPrecision, targetPrecision + 2), workingPrecision)
        local mcTmp = __K2L_MathContext.new(tmpPrecision, HALF_EVEN)
        approx = ONE_HALF:multiply(approx:add(divideMc(working, approx, mcTmp), mcTmp))
        guessPrecision = guessPrecision * 2
    until guessPrecision >= targetPrecision + 2
    local scaled = make(approx.u, approx.s + halfOf(scaleAdjust))
    local result
    if targetRm == UNNECESSARY or originalPrecision == 0 then
        result = roundTo(scaled, __K2L_MathContext.new(targetPrecision, targetRm == UNNECESSARY and DOWN or targetRm))
        if self:subtract(result:multiply(result)).u.sign ~= 0 then
            arithmetic("Computed square root not exact.")
        end
    else
        result = roundTo(scaled, mc)
        if targetRm == DOWN or targetRm == FLOOR then
            if result:multiply(result):compareTo(self) > 0 then
                local ulp = make(ONE_I, result.s)
                if approx:compareTo(__K2L_BigDecimal.ONE) == 0 then
                    ulp = ulp:multiply(ONE_TENTH)
                end
                result = result:subtract(ulp)
            end
        elseif targetRm == UP or targetRm == CEILING then
            if result:multiply(result):compareTo(self) < 0 then
                result = result:add(make(ONE_I, result.s))
            end
        end
    end
    if result.s ~= preferredScale then
        result = result:stripTrailingZeros():add(zeroAtPreferred, __K2L_MathContext.new(originalPrecision, UNNECESSARY))
    end
    return result
end

------------------------------------------------------------------ conversions
function __K2L_BigDecimal:toString()
    return sci(self)
end

__K2L_BigDecimal.__tostring = __K2L_BigDecimal.toString

function __K2L_BigDecimal:toPlainString()
    return plain(self)
end

-- The digits of %f with `precision` decimals (rounded HALF_UP, as java.util.Formatter does): the integer part and the
-- fraction of the magnitude
function __K2L_BigDecimal:____fixed(precision)
    local text = plain(self:abs():setScale(precision, HALF_UP))
    local int, frac = text:match("^(%d+)%.?(%d*)$")
    return int, frac
end

function __K2L_BigDecimal:toBigInteger()
    if self.s <= 0 then
        return scaleUp(self.u, -self.s)
    end
    return (self.u:____divmod(BI.____pow10(self.s)))
end

function __K2L_BigDecimal:toInt()
    return self:toBigInteger():toInt()
end

function __K2L_BigDecimal:toLong()
    return self:toBigInteger():toLong()
end

function __K2L_BigDecimal:toShort()
    return self:toBigInteger():toShort()
end

function __K2L_BigDecimal:toByte()
    return self:toBigInteger():toByte()
end

function __K2L_BigDecimal:toDouble()
    return tonumber(sci(self)) + 0.0
end

__K2L_BigDecimal.toFloat = __K2L_BigDecimal.toDouble
__K2L_BigDecimal.intValue = __K2L_BigDecimal.toInt
__K2L_BigDecimal.longValue = __K2L_BigDecimal.toLong
__K2L_BigDecimal.doubleValue = __K2L_BigDecimal.toDouble

end
