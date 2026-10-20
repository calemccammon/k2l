-- requires: Class, Exceptions, Bit, ToInt32, Collections
-- java.math.BigInteger: sign and magnitude, the magnitude an array of base 10^7 limbs (10^9 with integers, Lua 5.3+),
-- least significant first. A limb product plus carries stays below 2^53 (2^63), so every step is exact in doubles
-- (Lua 5.1, 5.2, LuaJIT) as well as in integers.
-- Bit operations convert to base 2^24 words (two's complement) and back.
local __K2L_BigInteger = __K2L_Class("java.math.BigInteger")
__K2L_BigInteger.____isNumber = true -- for `is Number`

do

local floor = math.floor
local mtype = math.type
-- the limb base and its number of decimal digits
local B, D = 10000000, 7
if mtype then
    B, D = 1000000000, 9
end
local WORD = 16777216
local intdiv = mtype and load("return function(a, b) return a // b end")()

local POW2 = {}
do
    local p = 1
    for k = 0, 30 do
        POW2[k] = p
        p = p * 2
    end
end

local POW10 = {}
do
    local p = 1
    for k = 0, 8 do
        POW10[k] = p
        p = p * 10
    end
end

local function arithmetic(message)
    error(__K2L_ArithmeticException.new(message))
end

local function numberFormat(message)
    error(__K2L_NumberFormatException.new(message))
end

local function trim(m)
    local n = #m
    while n > 0 and m[n] == 0 do
        m[n] = nil
        n = n - 1
    end
    return m
end

local function copy(m)
    local r = {}
    for i = 1, #m do
        r[i] = m[i]
    end
    return r
end

local function cmpMag(a, b)
    local na, nb = #a, #b
    if na ~= nb then
        return na < nb and -1 or 1
    end
    for i = na, 1, -1 do
        if a[i] ~= b[i] then
            return a[i] < b[i] and -1 or 1
        end
    end
    return 0
end

local function addMag(a, b)
    if #a < #b then
        a, b = b, a
    end
    local r, carry = {}, 0
    local nb = #b
    for i = 1, #a do
        local s = a[i] + (i <= nb and b[i] or 0) + carry
        if s >= B then
            r[i] = s - B
            carry = 1
        else
            r[i] = s
            carry = 0
        end
    end
    if carry > 0 then
        r[#a + 1] = carry
    end
    return r
end

-- a - b for |a| >= |b|
local function subMag(a, b)
    local r, borrow = {}, 0
    local nb = #b
    for i = 1, #a do
        local d = a[i] - (i <= nb and b[i] or 0) - borrow
        if d < 0 then
            d = d + B
            borrow = 1
        else
            borrow = 0
        end
        r[i] = d
    end
    return trim(r)
end

local mulSmall

local function mulMag(a, b)
    local na, nb = #a, #b
    if na == 0 or nb == 0 then
        return {}
    elseif nb == 1 then
        return mulSmall(a, b[1])
    elseif na == 1 then
        return mulSmall(b, a[1])
    end
    local r = {}
    for i = 1, na + nb do
        r[i] = 0
    end
    for i = 1, na do
        local ai = a[i]
        if ai ~= 0 then
            local carry, k = 0, i
            for j = 1, nb do
                local cur = r[k] + ai * b[j] + carry
                carry = floor(cur / B)
                r[k] = cur - carry * B
                k = k + 1
            end
            r[k] = carry
        end
    end
    return trim(r)
end

-- m * d + add for 0 <= d, add < 10^8
function mulSmall(m, d, add)
    local r, carry = {}, add or 0
    for i = 1, #m do
        local cur = m[i] * d + carry
        carry = floor(cur / B)
        r[i] = cur - carry * B
    end
    while carry > 0 do
        r[#r + 1] = carry % B
        carry = floor(carry / B)
    end
    return trim(r)
end

-- quotient and remainder of m / d for 0 < d <= 10^8
local function divSmall(m, d)
    local n = #m
    local q = {}
    for i = 1, n do
        q[i] = 0
    end
    local rem = 0
    for i = n, 1, -1 do
        local cur = rem * B + m[i]
        local qi = floor(cur / d)
        rem = cur - qi * d
        if rem < 0 then
            qi, rem = qi - 1, rem + d
        elseif rem >= d then
            qi, rem = qi + 1, rem - d
        end
        q[i] = qi
    end
    return trim(q), rem
end

-- PUC Lua 5.1 and 5.2: the same with % (an instruction) instead of a call of floor, which costs more than the extra
-- division (on LuaJIT, where floor compiles to one instruction, the extra division makes it slower)
if not mtype and not jit then
    function mulSmall(m, d, add)
        local r, carry = {}, add or 0
        for i = 1, #m do
            local cur = m[i] * d + carry
            local low = cur % B
            r[i] = low
            carry = (cur - low) / B
        end
        while carry > 0 do
            r[#r + 1] = carry % B
            carry = floor(carry / B)
        end
        return trim(r)
    end

    divSmall = function(m, d)
        local n = #m
        local q = {}
        for i = 1, n do
            q[i] = 0
        end
        local rem = 0
        for i = n, 1, -1 do
            local cur = rem * B + m[i]
            rem = cur % d
            if rem < 0 then
                rem = rem + d
            elseif rem >= d then
                rem = rem - d
            end
            q[i] = (cur - rem) / d
        end
        return trim(q), rem
    end
end

-- Lua 5.3+: the same loops with integer division instead of a floor call per limb (compiled with load, so that
-- Lua 5.1 never parses the // operator); with base 10^9 the products need integers
local divmodInt
if mtype then
    mulMag, mulSmall, divSmall, divmodInt = load([[
local B, trim, cmpMag, copy = ...
local mulSmall

local function mulMag(a, b)
    local na, nb = #a, #b
    if na == 0 or nb == 0 then
        return {}
    elseif nb == 1 then
        return mulSmall(a, b[1])
    elseif na == 1 then
        return mulSmall(b, a[1])
    end
    local r = {}
    for i = 1, na + nb do
        r[i] = 0
    end
    for i = 1, na do
        local ai = a[i]
        if ai ~= 0 then
            local carry, k = 0, i
            for j = 1, nb do
                local cur = r[k] + ai * b[j] + carry
                carry = cur // B
                r[k] = cur - carry * B
                k = k + 1
            end
            r[k] = carry
        end
    end
    return trim(r)
end

function mulSmall(m, d, add)
    local r, carry = {}, add or 0
    for i = 1, #m do
        local cur = m[i] * d + carry
        carry = cur // B
        r[i] = cur - carry * B
    end
    while carry > 0 do
        r[#r + 1] = carry % B
        carry = carry // B
    end
    return trim(r)
end

local function divSmall(m, d)
    local n = #m
    local q = {}
    for i = 1, n do
        q[i] = 0
    end
    local rem = 0
    for i = n, 1, -1 do
        local cur = rem * B + m[i]
        local qi = cur // d
        rem = cur - qi * d
        q[i] = qi
    end
    return trim(q), rem
end

-- Knuth's algorithm D, as below
local function divmodMag(a, b)
    local n = #b
    if cmpMag(a, b) < 0 then
        return {}, copy(a)
    end
    if n == 1 then
        local q, r = divSmall(a, b[1])
        return q, r == 0 and {} or {r}
    end
    local d = B // (b[n] + 1)
    local u, v = mulSmall(a, d), mulSmall(b, d)
    local na = #a
    for i = #u + 1, na + 1 do
        u[i] = 0
    end
    local m = na - n
    local q = {}
    for i = 1, m + 1 do
        q[i] = 0
    end
    local vtop, vsec = v[n], v[n - 1]
    for j = m, 0, -1 do
        local num = u[j + n + 1] * B + u[j + n]
        local qhat = num // vtop
        local rhat = num - qhat * vtop
        while qhat >= B or qhat * vsec > rhat * B + u[j + n - 1] do
            qhat = qhat - 1
            rhat = rhat + vtop
            if rhat >= B then
                break
            end
        end
        local borrow, carry = 0, 0
        for i = 1, n do
            local p = qhat * v[i] + carry
            carry = p // B
            local s = u[i + j] - (p - carry * B) - borrow
            if s < 0 then
                s = s + B
                borrow = 1
            else
                borrow = 0
            end
            u[i + j] = s
        end
        local top = u[j + n + 1] - carry - borrow
        if top < 0 then
            qhat = qhat - 1
            local c = 0
            for i = 1, n do
                local s = u[i + j] + v[i] + c
                if s >= B then
                    s = s - B
                    c = 1
                else
                    c = 0
                end
                u[i + j] = s
            end
            top = 0
        end
        u[j + n + 1] = top
        q[j + 1] = qhat
    end
    local r = {}
    for i = 1, n do
        r[i] = u[i]
    end
    local rq = divSmall(trim(r), d)
    return trim(q), rq
end

return mulMag, mulSmall, divSmall, divmodMag
]])(B, trim, cmpMag, copy)
end

-- Knuth's algorithm D: quotient and remainder of a / b, b nonzero
local function divmodMag(a, b)
    local n = #b
    if cmpMag(a, b) < 0 then
        return {}, copy(a)
    end
    if n == 1 then
        local q, r = divSmall(a, b[1])
        return q, r == 0 and {} or {r}
    end
    local d = floor(B / (b[n] + 1))
    local u, v = mulSmall(a, d), mulSmall(b, d)
    local na = #a
    for i = #u + 1, na + 1 do
        u[i] = 0
    end
    local m = na - n
    local q = {}
    for i = 1, m + 1 do
        q[i] = 0
    end
    local vtop, vsec = v[n], v[n - 1]
    for j = m, 0, -1 do
        local num = u[j + n + 1] * B + u[j + n]
        local qhat = floor(num / vtop)
        local rhat = num - qhat * vtop
        while qhat >= B or qhat * vsec > rhat * B + u[j + n - 1] do
            qhat = qhat - 1
            rhat = rhat + vtop
            if rhat >= B then
                break
            end
        end
        local borrow, carry = 0, 0
        for i = 1, n do
            local p = qhat * v[i] + carry
            carry = floor(p / B)
            local s = u[i + j] - (p - carry * B) - borrow
            if s < 0 then
                s = s + B
                borrow = 1
            else
                borrow = 0
            end
            u[i + j] = s
        end
        local top = u[j + n + 1] - carry - borrow
        if top < 0 then
            qhat = qhat - 1
            local c = 0
            for i = 1, n do
                local s = u[i + j] + v[i] + c
                if s >= B then
                    s = s - B
                    c = 1
                else
                    c = 0
                end
                u[i + j] = s
            end
            top = 0
        end
        u[j + n + 1] = top
        q[j + 1] = qhat
    end
    local r = {}
    for i = 1, n do
        r[i] = u[i]
    end
    local rq = divSmall(trim(r), d)
    return trim(q), rq
end

if divmodInt then
    divmodMag = divmodInt
end

local function make(sign, mag)
    if #mag == 0 then
        sign = 0
    end
    return setmetatable({sign = sign, mag = mag}, __K2L_BigInteger)
end

local ZERO = make(0, {})
local ONE = make(1, {1})
local TWO = make(1, {2})
local TEN = make(1, {10})

-- valueOf of -16..16, as the JVM caches them
local SMALL = {}

local tointeger = math.tointeger

local function fromNumber(x)
    if tointeger then
        -- limbs are integers: a float limb would make the products of base 10^9 limbs inexact
        x = tointeger(x) or x
    end
    if x == 0 then
        return ZERO
    elseif x < B and x > -B then
        local cached = SMALL[x]
        if cached ~= nil then
            return cached
        end
        if x > 0 then
            return make(1, {x})
        end
        return make(-1, {-x})
    end
    local sign = 1
    local addOne = false
    if x < 0 then
        sign = -1
        x = -(x + 1)
        addOne = true
    end
    local m, n = {}, 0
    local integer = mtype and mtype(x) == "integer"
    while x > 0 do
        local r = x % B
        n = n + 1
        m[n] = r
        if integer then
            x = intdiv(x, B)
        else
            x = (x - r) / B
        end
    end
    if addOne then
        m = addMag(m, {1})
    end
    return make(sign, m)
end

for i = 1, 16 do
    SMALL[i], SMALL[-i] = make(1, {i}), make(-1, {i})
end
SMALL[1], SMALL[2], SMALL[10] = ONE, TWO, TEN

local function isBigInteger(o)
    return getmetatable(o) == __K2L_BigInteger
end

local function check(o)
    if not isBigInteger(o) then
        error(__K2L_NullPointerException.new(nil))
    end
    return o
end

------------------------------------------------------------------ strings
local DIGITS_PER_INT = {
    0, 0, 30, 19, 15, 13, 11, 11, 10, 9, 9, 8, 8, 8, 8, 7, 7, 7, 7, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 5, 5, 5, 5, 5, 5, 5, 5,
}

local function digitValue(c)
    if c >= 48 and c <= 57 then
        return c - 48
    elseif c >= 97 and c <= 122 then
        return c - 87
    elseif c >= 65 and c <= 90 then
        return c - 55
    end
    return 99
end

-- Integer.parseInt's failure for the group the JVM parses at a time
local function groupFailure(group, radix)
    numberFormat('For input string: "' .. group .. '"' .. (radix == 10 and "" or " under radix " .. radix))
end

local function parse(s, radix, strict)
    radix = radix or 10
    if radix < 2 or radix > 36 then
        numberFormat("Radix out of range")
    end
    local len = #s
    if len == 0 then
        numberFormat("Zero length BigInteger")
    end
    local sign, cursor = 1, 1
    local minus = s:match(".*()%-")
    local plus = s:match(".*()%+")
    if (minus and (minus > 1 or plus)) or (plus and plus > 1) then
        numberFormat("Illegal embedded sign character")
    end
    if minus then
        sign, cursor = -1, 2
    elseif plus then
        cursor = 2
    end
    if cursor > len then
        numberFormat("Zero length BigInteger")
    end
    while cursor < len and s:byte(cursor) == 48 do
        cursor = cursor + 1
    end
    local digits = s:sub(cursor)
    local per = DIGITS_PER_INT[radix + 1]
    -- validate group by group like the JVM, so the message names the same substring
    local first = #digits % per
    if first == 0 then
        first = per
    end
    local pos = 1
    local size = first
    while pos <= #digits do
        local group = digits:sub(pos, pos + size - 1)
        for i = 1, #group do
            if digitValue(group:byte(i)) >= radix then
                groupFailure(group, radix)
            end
        end
        pos = pos + size
        size = per
    end
    if digits == "" or digits == "0" then
        return ZERO
    end
    local mag
    if radix == 10 then
        mag = {}
        local n = 0
        for hi = #digits, 1, -D do
            n = n + 1
            mag[n] = tonumber(digits:sub(math.max(1, hi - D + 1), hi))
        end
    else
        local k = 1
        local chunk = radix
        while chunk * radix <= B do
            chunk = chunk * radix
            k = k + 1
        end
        mag = {}
        local i = 1
        while i <= #digits do
            local piece = digits:sub(i, i + k - 1)
            local v, mul = 0, 1
            for j = 1, #piece do
                v = v * radix + digitValue(piece:byte(j))
                mul = mul * radix
            end
            mag = mulSmall(mag, mul, v)
            i = i + k
        end
    end
    return make(sign, trim(mag))
end

local function magToString(mag, radix)
    local n = #mag
    if n == 0 then
        return "0"
    end
    if radix == 10 then
        local parts = {string.format("%d", mag[n])}
        local limb = "%0" .. D .. "d"
        for i = n - 1, 1, -1 do
            parts[#parts + 1] = string.format(limb, mag[i])
        end
        return table.concat(parts)
    end
    local k, chunk = 1, radix
    while chunk * radix <= 100000000 do
        chunk = chunk * radix
        k = k + 1
    end
    local pieces = {}
    local m = mag
    local alphabet = "0123456789abcdefghijklmnopqrstuvwxyz"
    while #m > 0 do
        local q, r = divSmall(m, chunk)
        local digits = {}
        for i = k, 1, -1 do
            local d = r % radix
            digits[i] = alphabet:sub(d + 1, d + 1)
            r = (r - d) / radix
        end
        pieces[#pieces + 1] = table.concat(digits)
        m = q
    end
    local out = {}
    for i = #pieces, 1, -1 do
        out[#out + 1] = pieces[i]
    end
    return (table.concat(out):gsub("^0+", ""))
end

------------------------------------------------------------------ words (base 2^24 and 2^16)
local function toBase(mag, base)
    local words, m = {}, mag
    while #m > 0 do
        local r
        m, r = divSmall(m, base)
        words[#words + 1] = r
    end
    return words
end

local function fromBase(words, base)
    local mag = {}
    for i = #words, 1, -1 do
        mag = mulSmall(mag, base, words[i])
    end
    return mag
end

-- two's complement of x in len words of 24 bits, least significant first
local function twos(x, len)
    local w = toBase(x.mag, WORD)
    for i = #w + 1, len do
        w[i] = 0
    end
    if x.sign < 0 then
        local carry = 1
        for i = 1, len do
            local v = WORD - 1 - w[i] + carry
            if v >= WORD then
                v = v - WORD
                carry = 1
            else
                carry = 0
            end
            w[i] = v
        end
    end
    return w
end

local function fromTwos(w, len)
    if w[len] >= WORD / 2 then
        local carry = 1
        local r = {}
        for i = 1, len do
            local v = WORD - 1 - w[i] + carry
            if v >= WORD then
                v = v - WORD
                carry = 1
            else
                carry = 0
            end
            r[i] = v
        end
        return make(-1, trim(fromBase(r, WORD)))
    end
    return make(1, trim(fromBase(w, WORD)))
end

local function bitwise(x, y, op)
    local len = math.max(#x.mag, #y.mag) * 2 + 2
    local a, b = twos(x, len), twos(y, len)
    local r = {}
    for i = 1, len do
        r[i] = op(a[i], b[i])
    end
    return fromTwos(r, len)
end

local function shiftRight(x, n)
    if x.sign == 0 or n == 0 then
        return x
    end
    local m, lost = x.mag, false
    while n > 0 and #m > 0 do
        local k = n < 24 and n or 24
        local q, r = divSmall(m, POW2[k])
        if r ~= 0 then
            lost = true
        end
        m = q
        n = n - k
    end
    if x.sign < 0 and lost then
        m = addMag(m, {1})
    end
    return make(x.sign, m)
end

local function shiftLeft(x, n)
    if x.sign == 0 or n == 0 then
        return x
    end
    local m = x.mag
    while n > 0 do
        local k = n < 24 and n or 24
        m = mulSmall(m, POW2[k])
        n = n - k
    end
    return make(x.sign, m)
end

local function bitLengthOf(mag)
    local w = toBase(mag, WORD)
    local n = #w
    if n == 0 then
        return 0
    end
    local top, bits = w[n], 0
    while top > 0 do
        top = floor(top / 2)
        bits = bits + 1
    end
    return (n - 1) * 24 + bits
end

local function popCount(mag)
    local count = 0
    for _, w in ipairs(toBase(mag, WORD)) do
        while w > 0 do
            count = count + w % 2
            w = floor(w / 2)
        end
    end
    return count
end

------------------------------------------------------------------ arithmetic
local function addSigned(x, y)
    if x.sign == 0 then
        return y
    elseif y.sign == 0 then
        return x
    elseif x.sign == y.sign then
        return make(x.sign, addMag(x.mag, y.mag))
    end
    local c = cmpMag(x.mag, y.mag)
    if c == 0 then
        return ZERO
    elseif c > 0 then
        return make(x.sign, subMag(x.mag, y.mag))
    end
    return make(y.sign, subMag(y.mag, x.mag))
end

local function negate(x)
    if x.sign == 0 then
        return x
    end
    return make(-x.sign, x.mag)
end

local function divmod(x, y)
    if y.sign == 0 then
        arithmetic("BigInteger divide by zero")
    end
    local q, r = divmodMag(x.mag, y.mag)
    return make(x.sign * y.sign, q), make(x.sign, r)
end

local function pow(x, e)
    local result, base = ONE, x
    while e > 0 do
        if e % 2 == 1 then
            result = make(result.sign * base.sign, mulMag(result.mag, base.mag))
        end
        e = floor(e / 2)
        if e > 0 then
            base = make(1, mulMag(base.mag, base.mag))
        end
    end
    return result
end

local function modOf(x, m)
    local _, r = divmod(x, m)
    if r.sign < 0 then
        r = addSigned(r, m)
    end
    return r
end

local function checkModulus(m)
    if m.sign <= 0 then
        arithmetic("BigInteger: modulus not positive")
    end
end

local function modInverse(x, m)
    checkModulus(m)
    if m.mag[1] == 1 and #m.mag == 1 then
        return ZERO
    end
    local a, b = modOf(x, m), m
    local x0, x1 = ONE, ZERO
    while b.sign ~= 0 do
        local q, r = divmod(a, b)
        a, b = b, r
        x0, x1 = x1, addSigned(x0, negate(make(q.sign * x1.sign, mulMag(q.mag, x1.mag))))
    end
    if not (#a.mag == 1 and a.mag[1] == 1) then
        arithmetic("BigInteger not invertible.")
    end
    return modOf(x0, m)
end

local function modPow(x, e, m)
    checkModulus(m)
    if e.sign < 0 then
        x = modInverse(x, m)
        e = negate(e)
    end
    local result = modOf(ONE, m)
    local base = modOf(x, m)
    local words = toBase(e.mag, WORD)
    for i, w in ipairs(words) do
        for _ = 1, 24 do
            if i == #words and w == 0 then
                break
            end
            if w % 2 == 1 then
                result = modOf(make(result.sign * base.sign, mulMag(result.mag, base.mag)), m)
            end
            w = floor(w / 2)
            base = modOf(make(base.sign * base.sign, mulMag(base.mag, base.mag)), m)
        end
    end
    return result
end

local function gcd(x, y)
    local a, b = x.mag, y.mag
    while #b > 0 do
        local _, r = divmodMag(a, b)
        a, b = b, r
    end
    return make(1, copy(a))
end

local function isqrt(x)
    if x.sign < 0 then
        arithmetic("Negative BigInteger")
    end
    if x.sign == 0 then
        return ZERO
    end
    local approx = make(1, copy(x.mag))
    local digits = #magToString(x.mag, 10)
    local guess = pow(TEN, floor((digits + 1) / 2))
    while true do
        local q = divmod(approx, guess)
        local nextGuess = shiftRight(addSigned(guess, q), 1)
        if cmpMag(nextGuess.mag, guess.mag) >= 0 then
            return guess
        end
        guess = nextGuess
    end
end

local SMALL_PRIMES = {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37}

local function isProbablePrime(x)
    local n = make(1, x.mag)
    if cmpMag(n.mag, {2}) < 0 then
        return false
    end
    for _, p in ipairs(SMALL_PRIMES) do
        local pm = fromNumber(p)
        if cmpMag(n.mag, pm.mag) == 0 then
            return true
        end
        local _, r = divSmall(n.mag, p)
        if r == 0 then
            return false
        end
    end
    local nm1 = subMag(n.mag, {1})
    local d, s = make(1, nm1), 0
    while d.mag[1] % 2 == 0 do
        d = shiftRight(d, 1)
        s = s + 1
    end
    for _, p in ipairs(SMALL_PRIMES) do
        local y = modPow(fromNumber(p), d, n)
        if not (y.sign == 1 and #y.mag == 1 and y.mag[1] == 1) and cmpMag(y.mag, nm1) ~= 0 then
            local composite = true
            for _ = 1, s - 1 do
                y = modOf(make(1, mulMag(y.mag, y.mag)), n)
                if cmpMag(y.mag, nm1) == 0 then
                    composite = false
                    break
                end
            end
            if composite then
                return false
            end
        end
    end
    return true
end

------------------------------------------------------------------ conversions
local function lowWords(x, count)
    return twos(x, math.max(#x.mag * 2, count) + 2)
end

local function toIntValue(x)
    local w = lowWords(x, 2)
    local v = w[1] + (w[2] % 256) * WORD
    if v >= 2147483648 then
        v = v - 4294967296
    end
    return v
end

local function toLongValue(x)
    if x.sign == 0 then
        return 0
    end
    if mtype then
        local w = lowWords(x, 3)
        local lo = w[1] + (w[2] % 256) * WORD
        local hi = floor(w[2] / 256) + (w[3] % 65536) * 65536
        return hi * 4294967296 + lo
    end
    -- doubles: work on the magnitude, so values below 2^53 stay exact
    local w = toBase(x.mag, 65536)
    local m = 0
    for i = 4, 1, -1 do
        m = m * 65536 + (w[i] or 0)
    end
    if x.sign > 0 then
        return m >= 9223372036854775808 and m - 18446744073709551616 or m
    end
    return m > 9223372036854775808 and 18446744073709551616 - m or -m
end

local function toDoubleValue(x)
    if x.sign == 0 then
        return 0.0
    end
    local v = tonumber(magToString(x.mag, 10) .. ".0")
    return x.sign < 0 and -v or v
end

local function hashOf(x)
    local words = toBase(x.mag, 65536)
    local h = 0
    local n = #words
    local i = n
    if n % 2 == 1 then
        h = (31 * h + words[n]) % 4294967296
        i = n - 1
    end
    while i >= 2 do
        h = (31 * h + words[i] * 65536 + words[i - 1]) % 4294967296
        i = i - 2
    end
    h = __K2L_ToInt32(h)
    return __K2L_ToInt32(h * x.sign)
end

------------------------------------------------------------------ public API
__K2L_BigInteger.ZERO = ZERO
__K2L_BigInteger.ONE = ONE
__K2L_BigInteger.TWO = TWO
__K2L_BigInteger.TEN = TEN
-- for BigDecimal and the emulated Long, which read the limbs
__K2L_BigInteger.____limbBase = B
__K2L_BigInteger.____limbDigits = D

-- BigInteger(string, radix)
function __K2L_BigInteger.parse(s, radix)
    return parse(s, radix)
end

-- String.toBigIntegerOrNull(radix): null instead of an exception
function __K2L_BigInteger.parseOrNull(s, radix)
    radix = radix or 10
    local len = #s
    if len == 0 then
        return nil
    end
    local start = (len > 1 and s:byte(1) == 45) and 2 or 1
    for i = start, len do
        if digitValue(s:byte(i)) >= radix then
            return nil
        end
    end
    return parse(s, radix)
end

function __K2L_BigInteger.valueOf(x)
    return fromNumber(x)
end

function __K2L_BigInteger.____make(sign, mag)
    return make(sign, mag)
end

function __K2L_BigInteger.____isBigInteger(o)
    return isBigInteger(o)
end

-- 10^n
function __K2L_BigInteger.____pow10(n)
    local m = {}
    for i = 1, floor(n / D) do
        m[i] = 0
    end
    m[#m + 1] = POW10[n % D]
    return make(1, m)
end

function __K2L_BigInteger:____mulPow10(n)
    if self.sign == 0 or n == 0 then
        return self
    end
    local m = {}
    for i = 1, floor(n / D) do
        m[i] = 0
    end
    for i = 1, #self.mag do
        m[#m + 1] = self.mag[i]
    end
    if n % D ~= 0 then
        m = mulSmall(m, POW10[n % D])
    end
    return make(self.sign, m)
end

function __K2L_BigInteger:____divmod(o)
    return divmod(self, o)
end

function __K2L_BigInteger:____magnitudeCompare(o)
    return cmpMag(self.mag, o.mag)
end

function __K2L_BigInteger:____digits()
    local n = #self.mag
    if n == 0 then
        return 1
    end
    return (n - 1) * D + #string.format("%d", self.mag[n])
end

function __K2L_BigInteger:____isOne()
    return self.sign == 1 and #self.mag == 1 and self.mag[1] == 1
end

function __K2L_BigInteger:add(o)
    return addSigned(self, check(o))
end

-- lets the generic sumOf loop (total + x) work
function __K2L_BigInteger.__add(a, b)
    return a:add(b)
end

function __K2L_BigInteger:subtract(o)
    return addSigned(self, negate(check(o)))
end

function __K2L_BigInteger:multiply(o)
    check(o)
    return make(self.sign * o.sign, mulMag(self.mag, o.mag))
end

function __K2L_BigInteger:divide(o)
    local q = divmod(self, check(o))
    return q
end

function __K2L_BigInteger:remainder(o)
    local _, r = divmod(self, check(o))
    return r
end

function __K2L_BigInteger:mod(o)
    check(o)
    checkModulus(o)
    return modOf(self, o)
end

function __K2L_BigInteger:divideAndRemainder(o)
    local q, r = divmod(self, check(o))
    return __K2L_ArrayOf(q, r)
end

function __K2L_BigInteger:inc()
    return addSigned(self, ONE)
end

function __K2L_BigInteger:dec()
    return addSigned(self, negate(ONE))
end

function __K2L_BigInteger:negate()
    return negate(self)
end

function __K2L_BigInteger:abs()
    return self.sign < 0 and negate(self) or self
end

function __K2L_BigInteger:signum()
    return self.sign
end

function __K2L_BigInteger:pow(e)
    if e < 0 then
        arithmetic("Negative exponent")
    end
    return pow(self, e)
end

function __K2L_BigInteger:gcd(o)
    return gcd(self, check(o))
end

function __K2L_BigInteger:sqrt()
    return isqrt(self)
end

function __K2L_BigInteger:modPow(e, m)
    return modPow(self, check(e), check(m))
end

function __K2L_BigInteger:modInverse(m)
    return modInverse(self, check(m))
end

function __K2L_BigInteger:isProbablePrime(_)
    return isProbablePrime(self)
end

function __K2L_BigInteger:nextProbablePrime()
    if self.sign < 0 then
        arithmetic("start < 0: " .. self:toString())
    end
    local n = addSigned(self, ONE)
    while not isProbablePrime(n) do
        n = addSigned(n, ONE)
    end
    return n
end

function __K2L_BigInteger:compareTo(o)
    check(o)
    if self.sign ~= o.sign then
        return self.sign < o.sign and -1 or 1
    end
    return cmpMag(self.mag, o.mag) * self.sign
end

function __K2L_BigInteger:min(o)
    return self:compareTo(o) <= 0 and self or o
end

function __K2L_BigInteger:max(o)
    return self:compareTo(o) >= 0 and self or o
end

function __K2L_BigInteger:equals(o)
    return isBigInteger(o) and self.sign == o.sign and cmpMag(self.mag, o.mag) == 0
end

function __K2L_BigInteger:hashCode()
    return hashOf(self)
end

function __K2L_BigInteger:toString(radix)
    if radix == nil or radix < 2 or radix > 36 then
        radix = 10
    end
    local s = magToString(self.mag, radix)
    return self.sign < 0 and "-" .. s or s
end

__K2L_BigInteger.__tostring = __K2L_BigInteger.toString

function __K2L_BigInteger:toInt()
    return toIntValue(self)
end

function __K2L_BigInteger:toLong()
    return toLongValue(self)
end

function __K2L_BigInteger:toShort()
    local v = toIntValue(self) % 65536
    return v >= 32768 and v - 65536 or v
end

function __K2L_BigInteger:toByte()
    local v = toIntValue(self) % 256
    return v >= 128 and v - 256 or v
end

function __K2L_BigInteger:toDouble()
    return toDoubleValue(self)
end

__K2L_BigInteger.toFloat = __K2L_BigInteger.toDouble
__K2L_BigInteger.intValue = __K2L_BigInteger.toInt
__K2L_BigInteger.longValue = __K2L_BigInteger.toLong
__K2L_BigInteger.doubleValue = __K2L_BigInteger.toDouble

function __K2L_BigInteger:intValueExact()
    if self:bitLength() > 31 then
        arithmetic("BigInteger out of int range")
    end
    return toIntValue(self)
end

function __K2L_BigInteger:longValueExact()
    if self:bitLength() > 63 then
        arithmetic("BigInteger out of long range")
    end
    return toLongValue(self)
end

function __K2L_BigInteger:bitLength()
    if self.sign < 0 then
        return bitLengthOf(subMag(self.mag, {1}))
    end
    return bitLengthOf(self.mag)
end

function __K2L_BigInteger:bitCount()
    if self.sign < 0 then
        return popCount(subMag(self.mag, {1}))
    end
    return popCount(self.mag)
end

function __K2L_BigInteger:getLowestSetBit()
    if self.sign == 0 then
        return -1
    end
    local bits = 0
    for _, w in ipairs(toBase(self.mag, WORD)) do
        if w ~= 0 then
            while w % 2 == 0 do
                w = w / 2
                bits = bits + 1
            end
            return bits
        end
        bits = bits + 24
    end
    return bits
end

function __K2L_BigInteger:shiftLeft(n)
    if n < 0 then
        return shiftRight(self, -n)
    end
    return shiftLeft(self, n)
end

function __K2L_BigInteger:shiftRight(n)
    if n < 0 then
        return shiftLeft(self, -n)
    end
    return shiftRight(self, n)
end

local function bitAnd(a, b) return __K2L_BAnd(a, b) end
local function bitOr(a, b) return __K2L_BOr(a, b) end
local function bitXor(a, b) return __K2L_BXor(a, b) end
local function bitAndNot(a, b) return __K2L_BAnd(a, WORD - 1 - b) end

-- and, or and not are Lua keywords: the transpiler calls these as band, bor and bnot
function __K2L_BigInteger:band(o)
    return bitwise(self, check(o), bitAnd)
end

function __K2L_BigInteger:bor(o)
    return bitwise(self, check(o), bitOr)
end

function __K2L_BigInteger:bxor(o)
    return bitwise(self, check(o), bitXor)
end

function __K2L_BigInteger:andNot(o)
    return bitwise(self, check(o), bitAndNot)
end

function __K2L_BigInteger:bnot()
    return addSigned(negate(self), negate(ONE))
end

local function checkBit(n)
    if n < 0 then
        arithmetic("Negative bit address")
    end
end

function __K2L_BigInteger:testBit(n)
    checkBit(n)
    return (shiftRight(self, n).mag[1] or 0) % 2 == 1
end

function __K2L_BigInteger:setBit(n)
    checkBit(n)
    return bitwise(self, shiftLeft(ONE, n), bitOr)
end

function __K2L_BigInteger:clearBit(n)
    checkBit(n)
    return bitwise(self, shiftLeft(ONE, n), bitAndNot)
end

function __K2L_BigInteger:flipBit(n)
    checkBit(n)
    return bitwise(self, shiftLeft(ONE, n), bitXor)
end

end
