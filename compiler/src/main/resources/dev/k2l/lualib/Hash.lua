-- requires: ToInt32, IdentityHash
-- Kotlin/JVM hashCode() for primitives and strings; objects use their own hashCode().
-- hashCode() of a string with non-ASCII characters: JVM strings hash their UTF-16 code units, so the UTF-8 is decoded.
local function hashUtf8(s)
    local h, i, n = 0, 1, #s
    local function add(unit)
        h = (31 * h + unit) & 0xFFFFFFFF
    end
    while i <= n do
        local b = s:byte(i)
        if b < 0xC0 then
            add(b)
            i = i + 1
        elseif b < 0xE0 then
            add((b - 0xC0) * 64 + ((s:byte(i + 1) or 0x80) - 0x80))
            i = i + 2
        elseif b < 0xF0 then
            add((b - 0xE0) * 4096 + ((s:byte(i + 1) or 0x80) - 0x80) * 64 + ((s:byte(i + 2) or 0x80) - 0x80))
            i = i + 3
        else
            local cp = (b - 0xF0) * 262144 + ((s:byte(i + 1) or 0x80) - 0x80) * 4096 + ((s:byte(i + 2) or 0x80) - 0x80) * 64
                + ((s:byte(i + 3) or 0x80) - 0x80) - 0x10000
            add(0xD800 + math.floor(cp / 1024))
            add(0xDC00 + cp % 1024)
            i = i + 4
        end
    end
    return __K2L_ToInt32(h)
end

local byte = string.byte

-- String.hashCode(), four bytes per step (h * 31^4 + ...: below 2^53, so exact with doubles too); a string with a
-- non-ASCII byte hashes its UTF-16 units instead (testing the bytes here is cheaper than a find, which LuaJIT cannot compile)
local function hashString(s)
    local h, i, n = 0, 1, #s
    while i + 3 <= n do
        local b1, b2, b3, b4 = byte(s, i, i + 3)
        if b1 > 127 or b2 > 127 or b3 > 127 or b4 > 127 then
            return hashUtf8(s)
        end
        h = (h * 923521 + b1 * 29791 + b2 * 961 + b3 * 31 + b4) & 0xFFFFFFFF
        i = i + 4
    end
    while i <= n do
        local b = byte(s, i)
        if b > 127 then
            return hashUtf8(s)
        end
        h = (31 * h + b) & 0xFFFFFFFF
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
