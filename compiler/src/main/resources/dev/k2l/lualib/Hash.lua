-- requires: ToInt32, IdentityHash
-- Kotlin/JVM hashCode() for primitives and strings; objects use their own hashCode().
local byte = string.byte

-- String.hashCode() of the bytes, four per step (h * 31^4 + ...: below 2^53, so exact with doubles too)
local function hashString(s)
    local h, i, n = 0, 1, #s
    while i + 3 <= n do
        local b1, b2, b3, b4 = byte(s, i, i + 3)
        h = (h * 923521 + b1 * 29791 + b2 * 961 + b3 * 31 + b4) & 0xFFFFFFFF
        i = i + 4
    end
    while i <= n do
        h = (31 * h + byte(s, i)) & 0xFFFFFFFF
        i = i + 1
    end
    if h >= 2147483648 then
        h = h - 4294967296
    end
    return h
end

local mtype = math.type

local function __K2L_Hash(value)
    local t = type(value)
    if t == "number" then
        if mtype(value) == "integer" then
            -- Int.hashCode() is the value itself; Long.hashCode() folds the high bits in.
            if value >= -0x80000000 and value <= 0x7FFFFFFF then
                return value
            end
            return __K2L_ToInt32(value ~ (value >> 32))
        end
        if value ~= value then
            return 2146959360 -- Double.hashCode(NaN): the bits of the canonical NaN (Lua's may have the sign bit set)
        end
        return __K2L_Hash(string.unpack("<i8", string.pack("<d", value)))
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

-- Double.hashCode() of a value statically typed Double (floats are told apart from integers here, see Hash.float.lua).
local function __K2L_DoubleHash(value)
    return __K2L_Hash(value + 0.0)
end
