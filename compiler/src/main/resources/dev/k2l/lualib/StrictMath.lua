-- requires: FdLibm
-- java.lang.StrictMath's sin, cos, tan, log, log10 and pow: ports of the fdlibm code (as the JDK's FdLibm.java has it)
-- that StrictMath specifies, so the results are the JVM's bit for bit on every target. sin, cos and tan reduce their
-- argument by pi/2 with __ieee754_rem_pio2, which takes the bits of 2/pi it needs from a 1584-bit table for huge
-- arguments (__kernel_rem_pio2). Math.sin and kotlin.math.sin stay on Lua's math library: the JVM's own may differ from
-- StrictMath by an ulp, depending on the CPU.
local __K2L_StrictMath = {}

do

local floor, huge = math.floor, math.huge
local words, fromWords = __K2L_FdLibm.words, __K2L_FdLibm.fromWords
local TWO_20, TWO_24, TWO_31 = 1048576, 16777216, 2147483648
local twon24 = 5.96046447753906250000e-08

local function highWord(x)
    local hi = words(x)
    return hi
end

-- x with its low word cleared
local function chopped(x)
    return fromWords(highWord(x), 0)
end

-- The integer part of v, as C's (int) conversion
local function truncated(v)
    return v >= 0 and floor(v) or -floor(-v)
end

-- the exponent field of x's high word
local function exponent(x)
    return floor(highWord(x) % TWO_31 / TWO_20)
end

------------------------------------------------------------------ kernels on [-pi/4, pi/4]
local S1, S2, S3 = -1.66666666666666324348e-01, 8.33333333332248946124e-03, -1.98412698298579493134e-04
local S4, S5, S6 = 2.75573137070700676789e-06, -2.50507602534068634195e-08, 1.58969099521155010221e-10

-- sin(x + y) for the tail y of x; iy == 0 when y is 0
local function kernelSin(x, y, iy)
    if highWord(x) % TWO_31 < 0x3e400000 and truncated(x) == 0 then -- |x| < 2^-27
        return x
    end
    local z = x * x
    local v = z * x
    local r = S2 + z * (S3 + z * (S4 + z * (S5 + z * S6)))
    if iy == 0 then
        return x + v * (S1 + z * r)
    end
    return x - ((z * (0.5 * y - v * r) - y) - v * S1)
end

local C1, C2, C3 = 4.16666666666666019037e-02, -1.38888888888741095749e-03, 2.48015872894767294178e-05
local C4, C5, C6 = -2.75573143513906633035e-07, 2.08757232129817482790e-09, -1.13596475577881948265e-11

local function kernelCos(x, y)
    local ix = highWord(x) % TWO_31
    if ix < 0x3e400000 and truncated(x) == 0 then -- |x| < 2^-27
        return 1.0
    end
    local z = x * x
    local r = z * (C1 + z * (C2 + z * (C3 + z * (C4 + z * (C5 + z * C6)))))
    if ix < 0x3FD33333 then -- |x| < 0.3
        return 1.0 - (0.5 * z - (z * r - x * y))
    end
    local qx
    if ix > 0x3fe90000 then -- |x| > 0.78125
        qx = 0.28125
    else
        qx = fromWords(ix - 0x00200000, 0)
    end
    local hz = 0.5 * z - qx
    local a = 1.0 - qx
    return a - (hz - (z * r - x * y))
end

local pio4, pio4lo = 7.85398163397448278999e-01, 3.06161699786838301793e-17
local T0, T1, T2, T3 = 3.33333333333334091986e-01, 1.33333333333201242699e-01, 5.39682539762260521377e-02, 2.18694882948595424599e-02
local T4, T5, T6 = 8.86323982359930005737e-03, 3.59207910759131235356e-03, 1.45620945432529025516e-03
local T7, T8, T9 = 5.88041240820264096874e-04, 2.46463134818469906812e-04, 7.81794442939557092300e-05
local T10, T11, T12 = 7.14072491382608190305e-05, -1.85586374855275456654e-05, 2.59073051863633712884e-05

-- -1 / (x + y), computed carefully (w is x + y rounded)
local function negInverse(w, x, y)
    local z = chopped(w)
    local v = y - (z - x)
    local a = -1.0 / w
    local t = chopped(a)
    local s = 1.0 + t * z
    return t + a * (s + t * v)
end

-- tan(x + y) when iy is 1, -1 / tan(x + y) when it is -1
local function kernelTan(x, y, iy)
    local hx, lx = words(x)
    local ix = hx % TWO_31
    if ix < 0x3e300000 and truncated(x) == 0 then -- |x| < 2^-28
        if ix == 0 and lx == 0 and iy == -1 then
            return 1.0 / math.abs(x)
        elseif iy == 1 then
            return x
        end
        return negInverse(x + y, x, y)
    end
    local big = ix >= 0x3FE59428 -- |x| >= 0.6744
    if big then
        if hx < 0 then
            x, y = -x, -y
        end
        x = (pio4 - x) + (pio4lo - y)
        y = 0.0
    end
    local z = x * x
    local w = z * z
    -- x^5 (T1 + x^4 T3 + ... + x^20 T11) + x^5 (x^2 (T2 + x^4 T4 + ... + x^20 T12))
    local r = T1 + w * (T3 + w * (T5 + w * (T7 + w * (T9 + w * T11))))
    local v = z * (T2 + w * (T4 + w * (T6 + w * (T8 + w * (T10 + w * T12)))))
    local s = z * x
    r = y + z * (s * (r + v) + y)
    r = r + T0 * s
    w = x + r
    if big then
        v = iy
        return (hx < 0 and -1.0 or 1.0) * (v - 2.0 * (x - (w * w / (w + v) - r)))
    elseif iy == 1 then
        return w
    end
    return negInverse(w, x, r)
end

------------------------------------------------------------------ argument reduction
-- 2/pi in 24-bit chunks, 0-based as __kernel_rem_pio2 indexes them
local TWO_OVER_PI = {[0] =
    0xA2F983, 0x6E4E44, 0x1529FC, 0x2757D1, 0xF534DD, 0xC0DB62, 0x95993C, 0x439041, 0xFE5163, 0xABDEBB, 0xC561B7,
    0x246E3A, 0x424DD2, 0xE00649, 0x2EEA09, 0xD1921C, 0xFE1DEB, 0x1CB129, 0xA73EE8, 0x8235F5, 0x2EBB44, 0x84E99C,
    0x7026B4, 0x5F7E41, 0x3991D6, 0x398353, 0x39F49C, 0x845F8B, 0xBDF928, 0x3B1FF8, 0x97FFDE, 0x05980F, 0xEF2F11,
    0x8B5A0A, 0x6D1F6D, 0x367ECF, 0x27CB09, 0xB74F46, 0x3F669E, 0x5FEA2D, 0x7527BA, 0xC7EBE5, 0xF17B3D, 0x0739F7,
    0x8A5292, 0xEA6BFB, 0x5FB11F, 0x8D5D08, 0x560330, 0x46FC7B, 0x6BABF0, 0xCFBC20, 0x9AF436, 0x1DA9E3, 0x91615E,
    0xE61B08, 0x659985, 0x5F14A0, 0x68408D, 0xFFD880, 0x4D7327, 0x310606, 0x1556CA, 0x73A8C9, 0x60E27B, 0xC08C6B,
}

-- pi/2 in 24-bit chunks
local PIO2 = {[0] =
    1.57079625129699707031e+00, 7.54978941586159635335e-08, 5.39030252995776476554e-15, 3.28200341580791294123e-22,
    1.27065575308067607349e-29, 1.22933308981111328932e-36, 2.73370053816464559624e-44, 2.16741683877804819444e-51,
}

-- The fraction parts of x (24-bit pieces x[0..nx-1], the first scaled by 2^e0) times 2/pi: returns the last three bits
-- of the integer part N and y0 + y1 = x - N pi/2 (53-bit precision, "prec 2" with jk = 4 terms).
local function kernelRemPio2(x, e0, nx)
    local jk = 4
    local jp = jk
    local jx = nx - 1
    local jv = floor((e0 - 3) / 24)
    if jv < 0 then
        jv = 0
    end
    local q0 = e0 - 24 * (jv + 1)
    local f, q, fq, iq = {}, {}, {}, {}
    for i = 0, 19 do
        iq[i] = 0
    end
    local j = jv - jx
    for i = 0, jx + jk do
        f[i] = j < 0 and 0.0 or TWO_OVER_PI[j]
        j = j + 1
    end
    for i = 0, jk do
        local fw = 0.0
        for k = 0, jx do
            fw = fw + x[k] * f[jx + i - k]
        end
        q[i] = fw
    end
    local jz = jk
    local z, n, ih
    while true do
        -- distill q[] into iq[] reversingly
        z = q[jz]
        local i = 0
        for k = jz, 1, -1 do
            local fw = truncated(twon24 * z)
            iq[i] = truncated(z - TWO_24 * fw)
            z = q[k - 1] + fw
            i = i + 1
        end
        -- compute n
        z = z * 2 ^ q0
        z = z - 8.0 * floor(z * 0.125)
        n = truncated(z)
        z = z - n
        ih = 0
        if q0 > 0 then -- need iq[jz-1] to determine n
            local top = floor(iq[jz - 1] / 2 ^ (24 - q0))
            n = n + top
            iq[jz - 1] = iq[jz - 1] - top * 2 ^ (24 - q0)
            ih = floor(iq[jz - 1] / 2 ^ (23 - q0))
        elseif q0 == 0 then
            ih = floor(iq[jz - 1] / 8388608)
        elseif z >= 0.5 then
            ih = 2
        end
        if ih > 0 then -- q > 0.5
            n = n + 1
            local carry = 0
            for k = 0, jz - 1 do -- compute 1 - q
                local v = iq[k]
                if carry == 0 then
                    if v ~= 0 then
                        carry = 1
                        iq[k] = 0x1000000 - v
                    end
                else
                    iq[k] = 0xffffff - v
                end
            end
            if q0 == 1 then -- rare case: chance is 1 in 12
                iq[jz - 1] = iq[jz - 1] % 0x800000
            elseif q0 == 2 then
                iq[jz - 1] = iq[jz - 1] % 0x400000
            end
            if ih == 2 then
                z = 1.0 - z
                if carry ~= 0 then
                    z = z - 2 ^ q0
                end
            end
        end
        -- check if recomputation is needed
        if z ~= 0.0 then
            break
        end
        local nonzero = false
        for k = jz - 1, jk, -1 do
            if iq[k] ~= 0 then
                nonzero = true
            end
        end
        if nonzero then
            break
        end
        local k = 1
        while iq[jk - k] == 0 do -- k = number of terms needed
            k = k + 1
        end
        for m = jz + 1, jz + k do -- add q[jz+1] to q[jz+k]
            f[jx + m] = TWO_OVER_PI[jv + m]
            local fw = 0.0
            for l = 0, jx do
                fw = fw + x[l] * f[jx + m - l]
            end
            q[m] = fw
        end
        jz = jz + k
    end
    -- chop off zero terms
    if z == 0.0 then
        jz = jz - 1
        q0 = q0 - 24
        while iq[jz] == 0 do
            jz = jz - 1
            q0 = q0 - 24
        end
    else -- break z into 24-bit pieces if necessary
        z = z * 2 ^ -q0
        if z >= TWO_24 then
            local fw = truncated(twon24 * z)
            iq[jz] = truncated(z - TWO_24 * fw)
            jz = jz + 1
            q0 = q0 + 24
            iq[jz] = fw
        else
            iq[jz] = truncated(z)
        end
    end
    -- convert the integer "bit" chunks to floating-point values
    local fw = 2 ^ q0
    for i = jz, 0, -1 do
        q[i] = fw * iq[i]
        fw = fw * twon24
    end
    -- PIO2[0..jp] * q[jz..0]
    for i = jz, 0, -1 do
        fw = 0.0
        local k = 0
        while k <= jp and k <= jz - i do
            fw = fw + PIO2[k] * q[i + k]
            k = k + 1
        end
        fq[jz - i] = fw
    end
    -- compress fq[] into y0, y1
    fw = 0.0
    for i = jz, 0, -1 do
        fw = fw + fq[i]
    end
    local y0 = ih == 0 and fw or -fw
    fw = fq[0] - fw
    for i = 1, jz do
        fw = fw + fq[i]
    end
    return n % 8, y0, ih == 0 and fw or -fw
end

-- the high words of k pi/2, k = 1..32
local NPIO2_HW = {
    0x3FF921FB, 0x400921FB, 0x4012D97C, 0x401921FB, 0x401F6A7A, 0x4022D97C, 0x4025FDBB, 0x402921FB, 0x402C463A, 0x402F6A7A,
    0x4031475C, 0x4032D97C, 0x40346B9C, 0x4035FDBB, 0x40378FDB, 0x403921FB, 0x403AB41B, 0x403C463A, 0x403DD85A, 0x403F6A7A,
    0x40407E4C, 0x4041475C, 0x4042106C, 0x4042D97C, 0x4043A28C, 0x40446B9C, 0x404534AC, 0x4045FDBB, 0x4046C6CB, 0x40478FDB,
    0x404858EB, 0x404921FB,
}

local invpio2 = 6.36619772367581382433e-01
local pio2_1, pio2_1t = 1.57079632673412561417e+00, 6.07710050650619224932e-11
local pio2_2, pio2_2t = 6.07710050630396597660e-11, 2.02226624879595063154e-21
local pio2_3, pio2_3t = 2.02226624871116645580e-21, 8.47842766036889956997e-32

-- The remainder of x rem pi/2 as y0 + y1, after n, the quotient (its last bits for huge arguments)
local function remPio2(x)
    local hx, lx = words(x)
    local ix = hx % TWO_31
    if ix <= 0x3fe921fb then -- |x| ~<= pi/4: no reduction
        return 0, x, 0.0
    elseif ix < 0x4002d97c then -- |x| < 3pi/4: n = +-1
        local sign = hx > 0 and 1 or -1
        local z = x - sign * pio2_1
        local tail = pio2_1t
        if ix == 0x3ff921fb then -- near pi/2: 33 + 33 + 53 bits of pi
            z = z - sign * pio2_2
            tail = pio2_2t
        end
        local y0 = z - sign * tail
        return sign, y0, (z - y0) - sign * tail
    elseif ix <= 0x413921fb then -- |x| ~<= 2^19 (pi/2): medium size
        local t = math.abs(x)
        local n = truncated(t * invpio2 + 0.5)
        local fn = n + 0.0
        local r = t - fn * pio2_1
        local w = fn * pio2_1t -- first round good to 85 bits
        local y0 = r - w
        if not (n < 32 and ix ~= NPIO2_HW[n]) then
            local j = floor(ix / TWO_20)
            if j - exponent(y0) > 16 then -- second iteration, good to 118 bits
                t = r
                w = fn * pio2_2
                r = t - w
                w = fn * pio2_2t - ((t - r) - w)
                y0 = r - w
                if j - exponent(y0) > 49 then -- third iteration, 151 bits
                    t = r
                    w = fn * pio2_3
                    r = t - w
                    w = fn * pio2_3t - ((t - r) - w)
                    y0 = r - w
                end
            end
        end
        local y1 = (r - y0) - w
        if hx < 0 then
            return -n, -y0, -y1
        end
        return n, y0, y1
    elseif ix >= 0x7ff00000 then -- Inf or NaN
        local nan = x - x
        return 0, nan, nan
    end
    -- large arguments: z = scalbn(|x|, ilogb(x) - 23) in three 24-bit pieces
    local e0 = floor(ix / TWO_20) - 1046
    local z = fromWords(ix - e0 * TWO_20, lx)
    local tx = {}
    for i = 0, 1 do
        tx[i] = truncated(z) + 0.0
        z = (z - tx[i]) * TWO_24
    end
    tx[2] = z
    local nx = 3
    while tx[nx - 1] == 0.0 do -- skip zero terms
        nx = nx - 1
    end
    local n, y0, y1 = kernelRemPio2(tx, e0, nx)
    if hx < 0 then
        return -n, -y0, -y1
    end
    return n, y0, y1
end

------------------------------------------------------------------ sin, cos, tan
function __K2L_StrictMath.sin(x)
    local ix = highWord(x) % TWO_31
    if ix <= 0x3fe921fb then -- |x| ~< pi/4
        return kernelSin(x, 0.0, 0)
    elseif ix >= 0x7ff00000 then -- NaN for Inf and NaN
        return x - x
    end
    local n, y0, y1 = remPio2(x)
    n = n % 4
    if n == 0 then
        return kernelSin(y0, y1, 1)
    elseif n == 1 then
        return kernelCos(y0, y1)
    elseif n == 2 then
        return -kernelSin(y0, y1, 1)
    end
    return -kernelCos(y0, y1)
end

function __K2L_StrictMath.cos(x)
    local ix = highWord(x) % TWO_31
    if ix <= 0x3fe921fb then -- |x| ~< pi/4
        return kernelCos(x, 0.0)
    elseif ix >= 0x7ff00000 then -- NaN for Inf and NaN
        return x - x
    end
    local n, y0, y1 = remPio2(x)
    n = n % 4
    if n == 0 then
        return kernelCos(y0, y1)
    elseif n == 1 then
        return -kernelSin(y0, y1, 1)
    elseif n == 2 then
        return -kernelCos(y0, y1)
    end
    return kernelSin(y0, y1, 1)
end

function __K2L_StrictMath.tan(x)
    local ix = highWord(x) % TWO_31
    if ix <= 0x3fe921fb then -- |x| ~< pi/4
        return kernelTan(x, 0.0, 1)
    elseif ix >= 0x7ff00000 then -- NaN for Inf and NaN
        return x - x
    end
    local n, y0, y1 = remPio2(x)
    return kernelTan(y0, y1, n % 2 == 0 and 1 or -1)
end

------------------------------------------------------------------ log, log10
local ln2_hi, ln2_lo = 6.93147180369123816490e-01, 1.90821492927058770002e-10
local TWO_54 = 1.80143985094819840000e+16
local Lg1, Lg2, Lg3 = 6.666666666666735130e-01, 3.999999999940941908e-01, 2.857142874366239149e-01
local Lg4, Lg5, Lg6, Lg7 = 2.222219843214978396e-01, 1.818357216161805012e-01, 1.531383769920937332e-01, 1.479819860511658591e-01

-- log(+-0) is -Infinity and log of a negative number NaN; otherwise the scaled x (subnormals by 2^54), its high word
-- and the power of 2 taken out, or nil to return x + x (Infinity, NaN).
local function logArgument(x)
    local hx, lx = words(x)
    local k = 0
    if hx < 0x00100000 then -- x < 2^-1022
        if hx % TWO_31 == 0 and lx == 0 then
            return -huge
        elseif hx < 0 then
            return (x - x) / 0.0
        end
        k = -54
        x = x * TWO_54
        hx = highWord(x)
    end
    if hx >= 0x7ff00000 then
        return x + x
    end
    return nil, x, hx, k
end

local function log(x)
    local special, hx, k
    special, x, hx, k = logArgument(x)
    if special ~= nil then
        return special
    end
    k = k + floor(hx / TWO_20) - 1023
    hx = hx % TWO_20
    local i = floor((hx + 0x95f64) / TWO_20) % 2 * TWO_20
    x = fromWords(hx + 0x3ff00000 - i, select(2, words(x))) -- normalize x or x/2
    k = k + i / TWO_20
    local f = x - 1.0
    local dk = k + 0.0
    if (2 + hx) % TWO_20 < 3 then -- |f| < 2^-20
        if f == 0.0 then
            if k == 0 then
                return 0.0
            end
            return dk * ln2_hi + dk * ln2_lo
        end
        local R = f * f * (0.5 - 0.33333333333333333 * f)
        if k == 0 then
            return f - R
        end
        return dk * ln2_hi - ((R - dk * ln2_lo) - f)
    end
    local s = f / (2.0 + f)
    local z = s * s
    local w = z * z
    local t1 = w * (Lg2 + w * (Lg4 + w * Lg6))
    local t2 = z * (Lg1 + w * (Lg3 + w * (Lg5 + w * Lg7)))
    local R = t2 + t1
    if hx >= 0x6147a and hx <= 0x6b851 then
        local hfsq = 0.5 * f * f
        if k == 0 then
            return f - (hfsq - s * (hfsq + R))
        end
        return dk * ln2_hi - ((hfsq - (s * (hfsq + R) + dk * ln2_lo)) - f)
    elseif k == 0 then
        return f - s * (f - R)
    end
    return dk * ln2_hi - ((s * (f - R) - dk * ln2_lo) - f)
end

__K2L_StrictMath.log = log

local ivln10, log10_2hi, log10_2lo = 4.34294481903251816668e-01, 3.01029995663611771306e-01, 3.69423907715893078616e-13

function __K2L_StrictMath.log10(x)
    local special, hx, k
    special, x, hx, k = logArgument(x)
    if special ~= nil then
        return special
    end
    k = k + floor(hx / TWO_20) - 1023
    local i = k < 0 and 1 or 0
    hx = hx % TWO_20 + (0x3ff - i) * TWO_20
    local y = k + i + 0.0
    x = fromWords(hx, select(2, words(x)))
    local z = y * log10_2lo + ivln10 * log(x)
    return z + y * log10_2hi
end

------------------------------------------------------------------ pow
local INV_LN2, INV_LN2_H, INV_LN2_L = 1.44269504088896338700e+00, 1.44269502162933349609e+00, 1.92596299112661746887e-08
local CP, CP_H, CP_L = 9.61796693925975554329e-01, 9.61796700954437255859e-01, -7.02846165095275826516e-09
local DP_H, DP_L = 5.84962487220764160156e-01, 1.35003920212974897128e-08
local L1, L2, L3 = 5.99999999999994648725e-01, 4.28571428578550184252e-01, 3.33333329818377432918e-01
local L4, L5, L6 = 2.72728123808534006489e-01, 2.30660745775561754067e-01, 2.06975017800338417784e-01
local P1, P2, P3 = 1.66666666666666019037e-01, -2.77777777770155933842e-03, 6.61375632143793436117e-05
local P4, P5 = -1.65339022054652515390e-06, 4.13813679705723846039e-08
local LG2, LG2_H, LG2_L = 6.93147180559945286227e-01, 6.93147182464599609375e-01, -1.90465429995776804525e-09
local OVT = 8.0085662595372944372e-17
local Y_HUGE = 2147483648 + 4294967295 * 2 ^ -21 -- a bit above 2^31
local X_BELOW_ONE, X_ABOVE_ONE = 1 - 2 ^ -21, 1 + 4294967295 * 2 ^ -52

-- log2(|x|) as t1 + t2, t1 with its low word cleared, for |y| above 2^31: |x| is then within 2^-20 of 1
local function log2NearOne(ax)
    local t = ax - 1.0
    local w = (t * t) * (0.5 - t * (0.3333333333333333333333 - t * 0.25))
    local u = INV_LN2_H * t
    local v = t * INV_LN2_L - w * INV_LN2
    local t1 = chopped(u + v)
    return t1, v - (t1 - u)
end

-- log2(|x|) as t1 + t2 (t1 with its low word cleared), from the high word ix of |x|
local function log2Split(ax, ix)
    local n = 0
    if ix < 0x00100000 then -- subnormal
        ax = ax * 9007199254740992
        n = -53
        ix = highWord(ax)
    end
    n = n + floor(ix / TWO_20) - 0x3ff
    local j = ix % TWO_20
    local k = 0
    ix = j + 0x3ff00000 -- normalize ix
    if j > 0x3988E then
        if j < 0xBB67A then -- |x| < sqrt(3)
            k = 1
        else
            n = n + 1
            ix = ix - 0x00100000
        end
    end
    ax = fromWords(ix, select(2, words(ax)))
    -- ss = s_h + s_l = (x - 1) / (x + 1) or (x - 1.5) / (x + 1.5)
    local bp = k == 1 and 1.5 or 1.0
    local u = ax - bp
    local v = 1.0 / (ax + bp)
    local ss = u * v
    local s_h = chopped(ss)
    local t_h = fromWords(floor(ix / 2) + 0x20000000 + 0x00080000 + k * 262144, 0) -- ax + bp, high part
    local t_l = ax - (t_h - bp)
    local s_l = v * ((u - s_h * t_h) - s_h * t_l)
    -- log(ax)
    local s2 = ss * ss
    local r = s2 * s2 * (L1 + s2 * (L2 + s2 * (L3 + s2 * (L4 + s2 * (L5 + s2 * L6)))))
    r = r + s_l * (s_h + ss)
    s2 = s_h * s_h
    t_h = chopped(3.0 + s2 + r)
    t_l = r - ((t_h - 3.0) - s2)
    -- u + v = ss (1 + ...)
    u = s_h * t_h
    v = s_l * t_h + t_l * ss
    -- 2 / (3 log2) (ss + ...)
    local p_h = chopped(u + v)
    local p_l = v - (p_h - u)
    local z_h = CP_H * p_h
    local dp_h, dp_l = k == 1 and DP_H or 0.0, k == 1 and DP_L or 0.0
    local z_l = CP_L * p_h + p_l * CP + dp_l
    -- log2(ax) = (ss + ...) 2 / (3 log2) = n + dp_h + z_h + z_l
    local t = n + 0.0
    local t1 = chopped(((z_h + z_l) + dp_h) + t)
    return t1, z_l - (((t1 - t) - dp_h) - z_h)
end

-- 2^(p_h + p_l) for a sum that neither overflows nor underflows
local function exp2(p_h, p_l, j)
    local i = j % TWO_31
    local k = floor(i / TWO_20) - 0x3ff
    local n = 0
    if i > 0x3fe00000 then -- |z| > 0.5: n = [z + 0.5]
        n = j + floor(TWO_20 / 2 ^ (k + 1))
        k = floor(n % TWO_31 / TWO_20) - 0x3ff -- the new k for n
        local low = 2 ^ (20 - k)
        local t = fromWords(n - n % low, 0)
        n = floor((n % TWO_20 + TWO_20) / low)
        if j < 0 then
            n = -n
        end
        p_h = p_h - t
    end
    local t = chopped(p_l + p_h)
    local u = t * LG2_H
    local v = (p_l - (t - p_h)) * LG2 + t * LG2_L
    local z = u + v
    local w = v - (z - u)
    t = z * z
    local t1 = z - t * (P1 + t * (P2 + t * (P3 + t * (P4 + t * P5))))
    local r = (z * t1) / (t1 - 2.0) - (w + z * w)
    z = 1.0 - (r - z)
    local hz, lz = words(z)
    if floor((hz + n * TWO_20) / TWO_20) <= 0 then -- subnormal output
        local half = floor(n / 2)
        return z * 2 ^ half * 2 ^ (n - half)
    end
    return fromWords(hz + n * TWO_20, lz)
end

function __K2L_StrictMath.pow(x, y)
    if y == 0.0 then
        return 1.0
    elseif x ~= x or y ~= y then
        return x + y
    end
    local ay, ax = math.abs(y), math.abs(x)
    if y == 2.0 then
        return x * x
    elseif y == 0.5 then
        if x >= -1.7976931348623157e308 then -- -Infinity below
            return math.sqrt(x + 0.0) -- + 0.0 for x == -0.0
        end
    elseif ay == 1.0 then
        return y == 1.0 and x or 1.0 / x
    elseif ay == huge then
        if ax == 1.0 then
            return y - y -- NaN
        elseif ax > 1.0 then
            return y >= 0 and y or 0.0
        end
        return y < 0 and -y or 0.0
    end
    local hx = highWord(x)
    local ix = hx % TWO_31
    -- for x < 0, whether y is an integer: 0 no, 1 odd, 2 even
    local yInt = 0
    if hx < 0 then
        if ay >= 9007199254740992 then
            yInt = 2
        elseif ay >= 1.0 and floor(ay) == ay then
            yInt = 2 - floor(ay) % 2
        end
    end
    if ax == 0.0 or ax == huge or ax == 1.0 then -- x is +-0, +-Infinity, +-1
        local z = ax
        if y < 0.0 then
            z = 1.0 / z
        end
        if hx < 0 then
            if ix == 0x3ff00000 and yInt == 0 then
                z = (z - z) / (z - z) -- (-1)^non-integer is NaN
            elseif yInt == 1 then
                z = -1.0 * z
            end
        end
        return z
    end
    local positive = hx >= 0
    if not positive and yInt == 0 then -- (x < 0)^non-integer is NaN
        return (x - x) / (x - x)
    end
    local s = (not positive and yInt == 1) and -1.0 or 1.0 -- the sign of the result
    local t1, t2
    if ay > Y_HUGE then
        -- over- or underflow if x is not close to 1
        if ax < X_BELOW_ONE then
            return y < 0.0 and s * huge or s * 0.0
        elseif ax > X_ABOVE_ONE then
            return y > 0.0 and s * huge or s * 0.0
        end
        t1, t2 = log2NearOne(ax)
    else
        t1, t2 = log2Split(ax, ix)
    end
    -- (y1 + y2) (t1 + t2), y1 the high part of y
    local y1 = chopped(y)
    local p_l = (y - y1) * t1 + y * t2
    local p_h = y1 * t1
    local z = p_l + p_h
    local j, i = words(z)
    if j >= 0x40900000 then -- z >= 1024
        if j ~= 0x40900000 or i ~= 0 or p_l + OVT > z - p_h then
            return s * huge -- overflow
        end
    elseif j % TWO_31 >= 0x4090cc00 then -- z <= -1075
        if j ~= 0xc090cc00 - 4294967296 or i ~= 0 or p_l <= z - p_h then
            return s * 0.0 -- underflow
        end
    end
    return s * exp2(p_h, p_l, j)
end

end
