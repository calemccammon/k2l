-- The JVM's Math.hypot, atan, atan2, asin, acos, cbrt, sinh, cosh, tanh, expm1 and log1p are StrictMath's: ports of fdlibm
-- 5.3, which round differently from C's libm in the last bit. These are the same algorithms, so the results are the JVM's
-- bit for bit. A double's 32-bit words come from string.pack on Lua 5.3+ and from math.frexp before.
local __K2L_FdLibm = {}

do

local floor, sqrt, huge = math.floor, math.sqrt, math.huge
local TWO_32, TWO_20 = 4294967296, 1048576
local NEG_ZERO = -1 / huge -- not the literal: Lua 5.1 folds -0.0 into a function's constant 0

-- words(x): the high word of x's bits (a signed 32-bit integer) and the low word (unsigned).
-- fromWords(hi, lo): the double with these words (hi may be given unsigned).
local words, fromWords
if string.pack then
    local pack, unpack = string.pack, string.unpack
    words = function(x)
        local lo, hi = unpack("<I4i4", pack("<d", x))
        return hi, lo
    end
    fromWords = function(hi, lo)
        return (unpack("<d", pack("<I4I4", lo, hi % TWO_32)))
    end
else
    local frexp, ldexp = math.frexp, math.ldexp
    words = function(x)
        local negative = x < 0 or (x == 0 and 1 / x < 0)
        if negative then
            x = -x
        end
        local hi, lo
        if x ~= x then
            hi, lo = 0x7ff80000, 0
        elseif x == huge then
            hi, lo = 0x7ff00000, 0
        elseif x == 0 then
            hi, lo = 0, 0
        else
            local m, e = frexp(x)
            local field, mantissa = e + 1022, nil
            if field <= 0 then
                field, mantissa = 0, ldexp(x, 1074)
            else
                mantissa = (m * 2 - 1) * 4503599627370496
            end
            local mhi = floor(mantissa / TWO_32)
            hi, lo = field * TWO_20 + mhi, mantissa - mhi * TWO_32
        end
        if negative then
            hi = hi - 2147483648
        end
        return hi, lo
    end
    fromWords = function(hi, lo)
        hi = hi % TWO_32
        local negative = hi >= 2147483648
        if negative then
            hi = hi - 2147483648
        end
        local field = floor(hi / TWO_20)
        local mantissa = (hi - field * TWO_20) * TWO_32 + lo
        local x
        if field == 0 then
            x = ldexp(mantissa, -1074)
        elseif field == 2047 then
            x = mantissa == 0 and huge or 0 / 0
        else
            x = ldexp(mantissa + 4503599627370496, field - 1075)
        end
        return negative and -x or x
    end
end

local function highWord(x)
    local hi = words(x)
    return hi
end

-- for StrictMath.lua
__K2L_FdLibm.words, __K2L_FdLibm.fromWords = words, fromWords

-- x with its low word cleared
local function chopped(x)
    return fromWords(highWord(x), 0)
end

-- y * 2^k for a y near 1, without the overflow of 2^1024
local function scaled(y, k)
    local half = floor(k / 2)
    return y * 2 ^ half * 2 ^ (k - half)
end

-- (Scaling by 2^-600, 2^600 and 2 multiplies where fdlibm adds to the exponent field: the same numbers, fewer conversions.)
function __K2L_FdLibm.hypot(x, y)
    local a, b = math.abs(x), math.abs(y)
    local ha, la = words(a)
    local hb, lb = words(b)
    if hb > ha then
        a, b, ha, hb, la, lb = b, a, hb, ha, lb, la
    end
    if ha - hb > 0x3c00000 then
        return a + b -- a / b > 2^60
    end
    local k = 0
    if ha > 0x5f300000 then -- a > 2^500
        if ha >= 0x7ff00000 then -- Inf or NaN
            local w = a + b
            if ha % TWO_20 == 0 and la == 0 then
                w = a
            end
            if hb == 0x7ff00000 and lb == 0 then
                w = b
            end
            return w
        end
        ha, hb, k = ha - 0x25800000, hb - 0x25800000, k + 600 -- scale a and b by 2^-600
        a, b = a * 2 ^ -600, b * 2 ^ -600
    end
    if hb < 0x20b00000 then -- b < 2^-500
        if hb <= 0x000fffff then -- subnormal b or 0
            if hb == 0 and lb == 0 then
                return a
            end
            -- scale by 2^1022; fdlibm keeps the old high words for the split below
            b, a, k = b * 4.49423283715579e307, a * 4.49423283715579e307, k - 1022
        else -- scale a and b by 2^600
            ha, hb, k = ha + 0x25800000, hb + 0x25800000, k - 600
            a, b = a * 2 ^ 600, b * 2 ^ 600
        end
    end
    local w = a - b
    if w > b then
        local t1 = fromWords(ha, 0)
        local t2 = a - t1
        w = sqrt(t1 * t1 - (b * -b - t2 * (a + t1)))
    else
        a = a + a
        local y1 = fromWords(hb, 0)
        local y2 = b - y1
        local t1 = ha >= 0x00100000 and 2 * fromWords(ha, 0) or fromWords(ha + 0x00100000, 0)
        local t2 = a - t1
        w = sqrt(t1 * y1 - (w * -w - (t1 * y2 + t2 * b)))
    end
    if k ~= 0 then
        return scaled(w, k)
    end
    return w
end

local B1, B2 = 715094163, 696219795
local C, D, E = 5.42857142857142815906e-01, -7.05306122448979611050e-01, 1.41428571428571436819e+00
local F, G = 1.60714285714285720630e+00, 3.57142857142857150787e-01

function __K2L_FdLibm.cbrt(x)
    local hx, lx = words(x)
    local negative = hx < 0
    hx = hx % 2147483648
    if hx >= 0x7ff00000 then
        return x + x
    elseif hx == 0 and lx == 0 then
        return x
    end
    x = fromWords(hx, lx) -- |x|
    local t
    if hx < 0x00100000 then -- subnormal
        t = 18014398509481984 * x -- 2^54 * x
        local ht, lt = words(t)
        t = fromWords(floor(ht / 3) + B2, lt)
    else
        t = fromWords(floor(hx / 3) + B1, 0)
    end
    local r = t * t / x
    local s = C + r * t
    t = t * (G + F / (s + E + D / s))
    t = fromWords(highWord(t) + 1, 0)
    s = t * t
    r = x / s
    local w = t + t
    r = (r - t) / (w + r)
    t = t + t * r
    return negative and -t or t
end

local atanhi = { 4.63647609000806093515e-01, 7.85398163397448278999e-01, 9.82793723247329054082e-01, 1.57079632679489655800e+00 }
local atanlo = { 2.26987774529616870924e-17, 3.06161699786838301793e-17, 1.39033110312309984516e-17, 6.12323399573676603587e-17 }
local aT0, aT1, aT2, aT3 = 3.33333333333329318027e-01, -1.99999999998764832476e-01, 1.42857142725034663711e-01, -1.11111104054623557880e-01
local aT4, aT5, aT6, aT7 = 9.09088713343650656196e-02, -7.69187620504482999495e-02, 6.66107313738753120669e-02, -5.83357013379057348645e-02
local aT8, aT9, aT10 = 4.97687799461593236017e-02, -3.65315727442169155270e-02, 1.62858201153657823623e-02

local function atan(x)
    local hx, lx = words(x)
    local ix = hx % 2147483648
    local id
    if ix >= 0x44100000 then -- |x| >= 2^66
        if ix > 0x7ff00000 or (ix == 0x7ff00000 and lx ~= 0) then
            return x + x
        elseif hx > 0 then
            return atanhi[4] + atanlo[4]
        end
        return -atanhi[4] - atanlo[4]
    end
    if ix < 0x3fdc0000 then -- |x| < 0.4375
        if ix < 0x3e200000 then -- |x| < 2^-29
            return x
        end
        id = 0
    else
        x = math.abs(x)
        if ix < 0x3ff30000 then -- |x| < 1.1875
            if ix < 0x3fe60000 then -- 7/16 <= |x| < 11/16
                id, x = 1, (2.0 * x - 1.0) / (2.0 + x)
            else
                id, x = 2, (x - 1.0) / (x + 1.0)
            end
        elseif ix < 0x40038000 then -- |x| < 2.4375
            id, x = 3, (x - 1.5) / (1.0 + 1.5 * x)
        else
            id, x = 4, -1.0 / x
        end
    end
    local z = x * x
    local w = z * z
    local s1 = z * (aT0 + w * (aT2 + w * (aT4 + w * (aT6 + w * (aT8 + w * aT10)))))
    local s2 = w * (aT1 + w * (aT3 + w * (aT5 + w * (aT7 + w * aT9))))
    if id == 0 then
        return x - x * (s1 + s2)
    end
    z = atanhi[id] - ((x * (s1 + s2) - atanlo[id]) - x)
    return hx < 0 and -z or z
end

__K2L_FdLibm.atan = atan

local pi_o_4, pi_o_2 = 7.8539816339744827900e-01, 1.5707963267948965580e+00
local pi, pi_lo = 3.1415926535897931160e+00, 1.2246467991473531772e-16

function __K2L_FdLibm.atan2(y, x)
    local hx, lx = words(x)
    local hy, ly = words(y)
    local ix, iy = hx % 2147483648, hy % 2147483648
    if x ~= x or y ~= y then
        return x + y
    elseif x == 1.0 then
        return atan(y)
    end
    local m = (hy < 0 and 1 or 0) + (hx < 0 and 2 or 0) -- 2 * sign(x) + sign(y)
    if iy == 0 and ly == 0 then -- y = 0
        if m < 2 then
            return y
        end
        return m == 2 and pi or -pi
    elseif ix == 0 and lx == 0 then -- x = 0
        return hy < 0 and -pi_o_2 or pi_o_2
    elseif ix == 0x7ff00000 then -- x is infinite
        if iy == 0x7ff00000 then
            if m == 0 then
                return pi_o_4
            elseif m == 1 then
                return -pi_o_4
            end
            return m == 2 and 3.0 * pi_o_4 or -3.0 * pi_o_4
        end
        if m == 0 then
            return 0.0
        elseif m == 1 then
            return NEG_ZERO
        end
        return m == 2 and pi or -pi
    elseif iy == 0x7ff00000 then -- y is infinite
        return hy < 0 and -pi_o_2 or pi_o_2
    end
    local k = floor((iy - ix) / TWO_20)
    local z
    if k > 60 then -- |y / x| > 2^60
        z = pi_o_2 + 0.5 * pi_lo
    elseif hx < 0 and k < -60 then -- |y| / x < -2^60
        z = 0.0
    else
        z = atan(math.abs(y / x))
    end
    if m == 0 then
        return z
    elseif m == 1 then
        return -z
    elseif m == 2 then
        return pi - (z - pi_lo)
    end
    return (z - pi_lo) - pi
end

local pio2_hi, pio2_lo, pio4_hi = 1.57079632679489655800e+00, 6.12323399573676603587e-17, 7.85398163397448278999e-01
local pS0, pS1, pS2 = 1.66666666666666657415e-01, -3.25565818622400915405e-01, 2.01212532134862925881e-01
local pS3, pS4, pS5 = -4.00555345006794114027e-02, 7.91534994289814532176e-04, 3.47933107596021167570e-05
local qS1, qS2, qS3, qS4 = -2.40339491173441421878e+00, 2.02094576023350569471e+00, -6.88283971605453293030e-01, 7.70381505559019352791e-02

local function rational(t)
    local p = t * (pS0 + t * (pS1 + t * (pS2 + t * (pS3 + t * (pS4 + t * pS5)))))
    local q = 1.0 + t * (qS1 + t * (qS2 + t * (qS3 + t * qS4)))
    return p, q
end

function __K2L_FdLibm.asin(x)
    local hx, lx = words(x)
    local ix = hx % 2147483648
    if ix >= 0x3ff00000 then -- |x| >= 1
        if ix == 0x3ff00000 and lx == 0 then
            return x * pio2_hi + x * pio2_lo
        end
        return 0 / 0
    elseif ix < 0x3fe00000 then -- |x| < 0.5
        if ix < 0x3e400000 then -- |x| < 2^-27
            return x
        end
        local t = x * x
        local p, q = rational(t)
        return x + x * (p / q)
    end
    local w = 1.0 - math.abs(x)
    local t = w * 0.5
    local p, q = rational(t)
    local s = sqrt(t)
    if ix >= 0x3fef3333 then -- |x| > 0.975
        t = pio2_hi - (2.0 * (s + s * (p / q)) - pio2_lo)
    else
        w = chopped(s)
        local c = (t - w * w) / (s + w)
        local r = p / q
        p = 2.0 * s * r - (pio2_lo - 2.0 * c)
        q = pio4_hi - 2.0 * w
        t = pio4_hi - (p - q)
    end
    return hx > 0 and t or -t
end

function __K2L_FdLibm.acos(x)
    local hx, lx = words(x)
    local ix = hx % 2147483648
    if ix >= 0x3ff00000 then -- |x| >= 1
        if ix == 0x3ff00000 and lx == 0 then
            return hx > 0 and 0.0 or pi + 2.0 * pio2_lo
        end
        return 0 / 0
    elseif ix < 0x3fe00000 then -- |x| < 0.5
        if ix <= 0x3c600000 then -- |x| < 2^-57
            return pio2_hi + pio2_lo
        end
        local p, q = rational(x * x)
        return pio2_hi - (x - (pio2_lo - x * (p / q)))
    elseif hx < 0 then -- x < -0.5
        local z = (1.0 + x) * 0.5
        local p, q = rational(z)
        local s = sqrt(z)
        local w = (p / q) * s - pio2_lo
        return pi - 2.0 * (s + w)
    end
    local z = (1.0 - x) * 0.5
    local s = sqrt(z)
    local df = chopped(s)
    local c = (z - df * df) / (s + df)
    local p, q = rational(z)
    local w = (p / q) * s + c
    return 2.0 * (df + w)
end

local o_threshold, u_threshold = 7.09782712893383973096e+02, -7.45133219101941108420e+02
local ln2_hi, ln2_lo, invln2 = 6.93147180369123816490e-01, 1.90821492927058770002e-10, 1.44269504088896338700e+00
local twom1000 = 9.33263618503218878990e-302
local P1, P2, P3 = 1.66666666666666019037e-01, -2.77777777770155933842e-03, 6.61375632143793436117e-05
local P4, P5 = -1.65339022054652515390e-06, 4.13813679705723846039e-08

-- The integer part of v, as C's (int) conversion
local function truncated(v)
    return v >= 0 and floor(v) or -floor(-v)
end

local function exp(x)
    local hx, lx = words(x)
    local negative = hx < 0
    hx = hx % 2147483648
    if hx >= 0x40862E42 then -- |x| >= 709.78...
        if hx >= 0x7ff00000 then
            if hx % TWO_20 ~= 0 or lx ~= 0 then
                return x + x
            end
            return negative and 0.0 or x
        elseif x > o_threshold then
            return huge
        elseif x < u_threshold then
            return 0.0
        end
    end
    local hi, lo, k = nil, 0.0, 0
    if hx > 0x3fd62e42 then -- |x| > 0.5 ln2
        if hx < 0x3FF0A2B2 then -- and |x| < 1.5 ln2
            if negative then
                hi, lo, k = x + ln2_hi, -ln2_lo, -1
            else
                hi, lo, k = x - ln2_hi, ln2_lo, 1
            end
        else
            k = truncated(invln2 * x + (negative and -0.5 or 0.5))
            hi = x - k * ln2_hi
            lo = k * ln2_lo
        end
        x = hi - lo
    elseif hx < 0x3e300000 then -- |x| < 2^-28
        return 1.0 + x
    end
    local t = x * x
    local c = x - t * (P1 + t * (P2 + t * (P3 + t * (P4 + t * P5))))
    if k == 0 then
        return 1.0 - ((x * c) / (c - 2.0) - x)
    end
    local y = 1.0 - ((lo - (x * c) / (2.0 - c)) - hi)
    if k >= -1021 then
        return scaled(y, k)
    end
    return scaled(y, k + 1000) * twom1000
end

local Q1, Q2, Q3 = -3.33333333333331316428e-02, 1.58730158725481460165e-03, -7.93650757867487942473e-05
local Q4, Q5 = 4.00821782732936239552e-06, -2.01099218183624371326e-07

local function expm1(x)
    local hx, lx = words(x)
    local negative = hx < 0
    hx = hx % 2147483648
    if hx >= 0x4043687A then -- |x| >= 56 ln2
        if hx >= 0x40862E42 then -- |x| >= 709.78...
            if hx >= 0x7ff00000 then
                if hx % TWO_20 ~= 0 or lx ~= 0 then
                    return x + x
                end
                return negative and -1.0 or x
            elseif x > o_threshold then
                return huge
            end
        end
        if negative then
            return -1.0
        end
    end
    local k, c = 0, 0.0
    if hx > 0x3fd62e42 then -- |x| > 0.5 ln2
        local hi, lo
        if hx < 0x3FF0A2B2 then -- and |x| < 1.5 ln2
            if negative then
                hi, lo, k = x + ln2_hi, -ln2_lo, -1
            else
                hi, lo, k = x - ln2_hi, ln2_lo, 1
            end
        else
            k = truncated(invln2 * x + (negative and -0.5 or 0.5))
            hi = x - k * ln2_hi
            lo = k * ln2_lo
        end
        x = hi - lo
        c = (hi - x) - lo
    elseif hx < 0x3c900000 then -- |x| < 2^-54
        return x
    end
    local hfx = 0.5 * x
    local hxs = x * hfx
    local r1 = 1.0 + hxs * (Q1 + hxs * (Q2 + hxs * (Q3 + hxs * (Q4 + hxs * Q5))))
    local t = 3.0 - r1 * hfx
    local e = hxs * ((r1 - t) / (6.0 - x * t))
    if k == 0 then
        return x - (x * e - hxs)
    end
    e = (x * (e - c) - c)
    e = e - hxs
    if k == -1 then
        return 0.5 * (x - e) - 0.5
    elseif k == 1 then
        if x < -0.25 then
            return -2.0 * (e - (x + 0.5))
        end
        return 1.0 + 2.0 * (x - e)
    elseif k <= -2 or k > 56 then
        return scaled(1.0 - (e - x), k) - 1.0
    elseif k < 20 then
        return scaled((1.0 - 2 ^ -k) - (e - x), k)
    end
    return scaled(x - (e + 2 ^ -k) + 1.0, k)
end

__K2L_FdLibm.exp = exp
__K2L_FdLibm.expm1 = expm1

local Lp1, Lp2, Lp3 = 6.666666666666735130e-01, 3.999999999940941908e-01, 2.857142874366239149e-01
local Lp4, Lp5, Lp6, Lp7 = 2.222219843214978396e-01, 1.818357216161805012e-01, 1.531383769920937332e-01, 1.479819860511658591e-01

function __K2L_FdLibm.log1p(x)
    local hx = highWord(x)
    local ax = hx % 2147483648
    local k, f, hu, c = 1, nil, nil, 0.0
    if hx < 0x3FDA827A then -- x < 0.41422
        if hx < 0 and ax >= 0x3ff00000 then -- x <= -1.0
            if x == -1.0 then
                return -huge
            end
            return 0 / 0
        end
        if ax < 0x3e200000 then -- |x| < 2^-29
            if ax < 0x3c900000 then -- |x| < 2^-54
                return x
            end
            return x - x * x * 0.5
        end
        if hx > 0 or hx <= -1076707645 then -- -0.2929 < x < 0.41422 (0xbfd2bec3)
            k, f, hu = 0, x, 1
        end
    end
    if hx >= 0x7ff00000 then
        return x + x
    end
    if k ~= 0 then
        local u
        if hx < 0x43400000 then
            u = 1.0 + x
            hu = highWord(u)
            k = floor(hu / TWO_20) - 1023
            c = k > 0 and 1.0 - (u - x) or x - (u - 1.0)
            c = c / u
        else
            u = x
            hu = highWord(u)
            k = floor(hu / TWO_20) - 1023
            c = 0.0
        end
        hu = hu % TWO_20
        local _, lu = words(u)
        if hu < 0x6a09e then
            u = fromWords(hu + 0x3ff00000, lu) -- normalize u
        else
            k = k + 1
            u = fromWords(hu + 0x3fe00000, lu) -- normalize u / 2
            hu = floor((0x00100000 - hu) / 4)
        end
        f = u - 1.0
    end
    local hfsq = 0.5 * f * f
    if hu == 0 then -- |f| < 2^-20
        if f == 0 then
            if k == 0 then
                return 0.0
            end
            c = c + k * ln2_lo
            return k * ln2_hi + c
        end
        local R = hfsq * (1.0 - 0.66666666666666666 * f)
        if k == 0 then
            return f - R
        end
        return k * ln2_hi - ((R - (k * ln2_lo + c)) - f)
    end
    local s = f / (2.0 + f)
    local z = s * s
    local R = z * (Lp1 + z * (Lp2 + z * (Lp3 + z * (Lp4 + z * (Lp5 + z * (Lp6 + z * Lp7))))))
    if k == 0 then
        return f - (hfsq - s * (hfsq + R))
    end
    return k * ln2_hi - ((hfsq - (s * (hfsq + R) + (k * ln2_lo + c))) - f)
end

function __K2L_FdLibm.sinh(x)
    local jx, lx = words(x)
    local ix = jx % 2147483648
    if ix >= 0x7ff00000 then
        return x + x
    end
    local h = jx < 0 and -0.5 or 0.5
    if ix < 0x40360000 then -- |x| < 22
        if ix < 0x3e300000 then -- |x| < 2^-28
            return x
        end
        local t = expm1(math.abs(x))
        if ix < 0x3ff00000 then
            return h * (2.0 * t - t * t / (t + 1.0))
        end
        return h * (t + t / (t + 1.0))
    elseif ix < 0x40862E42 then -- |x| in [22, log(maxdouble)]
        return h * exp(math.abs(x))
    elseif ix < 0x408633CE or (ix == 0x408633ce and lx <= 0x8fb9f87d) then
        local w = exp(0.5 * math.abs(x))
        return (h * w) * w
    end
    return x * huge
end

function __K2L_FdLibm.cosh(x)
    local ix, lx = words(x)
    ix = ix % 2147483648
    if ix >= 0x7ff00000 then
        return x * x
    elseif ix < 0x3fd62e43 then -- |x| in [0, 0.5 ln2]
        local t = expm1(math.abs(x))
        local w = 1.0 + t
        if ix < 0x3c800000 then
            return w
        end
        return 1.0 + (t * t) / (w + w)
    elseif ix < 0x40360000 then -- |x| in [0.5 ln2, 22]
        local t = exp(math.abs(x))
        return 0.5 * t + 0.5 / t
    elseif ix < 0x40862E42 then -- |x| in [22, log(maxdouble)]
        return 0.5 * exp(math.abs(x))
    elseif ix < 0x408633CE or (ix == 0x408633ce and lx <= 0x8fb9f87d) then
        local w = exp(0.5 * math.abs(x))
        return (0.5 * w) * w
    end
    return huge
end

function __K2L_FdLibm.tanh(x)
    local jx = highWord(x)
    local ix = jx % 2147483648
    if ix >= 0x7ff00000 then
        if jx >= 0 then
            return 1.0 / x + 1.0
        end
        return 1.0 / x - 1.0
    end
    local z
    if ix < 0x40360000 then -- |x| < 22
        if ix < 0x3c800000 then -- |x| < 2^-55
            return x * (1.0 + x)
        elseif ix >= 0x3ff00000 then -- |x| >= 1
            local t = expm1(2.0 * math.abs(x))
            z = 1.0 - 2.0 / (t + 2.0)
        else
            local t = expm1(-2.0 * math.abs(x))
            z = -t / (t + 2.0)
        end
    else
        z = 1.0
    end
    return jx >= 0 and z or -z
end

end
