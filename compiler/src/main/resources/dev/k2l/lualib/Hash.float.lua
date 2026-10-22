-- requires: ToInt32, IdentityHash
-- Kotlin/JVM hashCode() for primitives and strings; objects use their own hashCode().
-- a ~ b for unsigned 32-bit values held in doubles
local function xor32(a, b)
    local r, bit = 0, 1
    for _ = 1, 32 do
        if a % 2 ~= b % 2 then
            r = r + bit
        end
        a, b, bit = math.floor(a / 2), math.floor(b / 2), bit * 2
    end
    return r
end

-- The high and low 32 bits of the IEEE-754 representation of x.
local function doubleBits(x)
    local sign = 0
    if x < 0 or (x == 0 and 1 / x < 0) then
        sign, x = 0x80000000, -x
    end
    if x ~= x then
        return 0x7FF80000, 0
    elseif x == math.huge then
        return sign + 0x7FF00000, 0
    elseif x == 0 then
        return sign, 0
    end
    local m, e = math.frexp(x)
    e = e - 1 + 1023
    local frac
    if e <= 0 then
        e, frac = 0, x / 2 ^ -1074
    else
        frac = (m * 2 - 1) * 2 ^ 52
    end
    local hi = math.floor(frac / 4294967296)
    return sign + e * 0x100000 + hi, frac - hi * 4294967296
end

-- Double.hashCode() of a value statically typed Double: an integral value is still a Double (3.0 is not 3).
local function __K2L_DoubleHash(value)
    return __K2L_ToInt32(xor32(doubleBits(value)))
end

local byte = string.byte

-- String.hashCode() of the bytes, four per step (h * 31^4 + ...: below 2^53, so exact with doubles too)
local function hashString(s)
    local h, i, n = 0, 1, #s
    while i + 3 <= n do
        local b1, b2, b3, b4 = byte(s, i, i + 3)
        h = (h * 923521 + b1 * 29791 + b2 * 961 + b3 * 31 + b4) % 4294967296
        i = i + 4
    end
    while i <= n do
        h = (31 * h + byte(s, i)) % 4294967296
        i = i + 1
    end
    if h >= 2147483648 then
        h = h - 4294967296
    end
    return h
end

local function __K2L_Hash(value)
    local t = type(value)
    if t == "number" then
        if value % 1 == 0 and value >= -2147483648 and value <= 2147483647 then
            if value == 0 and 1 / value < 0 then
                return -2147483648 -- Double.hashCode(-0.0) (an Int is never -0)
            end
            return value
        end
        -- Long.hashCode() for large integral values, Double.hashCode() otherwise
        local hi, lo
        if value % 1 == 0 and math.abs(value) < 2 ^ 63 then
            hi, lo = math.floor(value / 4294967296) % 4294967296, value % 4294967296
        else
            hi, lo = doubleBits(value)
        end
        return __K2L_ToInt32(xor32(hi, lo))
    elseif t == "string" then
        return hashString(value)
    elseif value == nil then
        return 0
    elseif t == "boolean" then
        return value and 1231 or 1237
    elseif t == "table" and value.hashCode ~= nil then
        return value:hashCode()
    end
    return __K2L_IdentityHash(value)
end
