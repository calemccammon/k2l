-- requires: ToInt32
-- Kotlin/JVM hashCode() for primitives and strings; objects use their own hashCode().
local __K2L_HashIds = setmetatable({}, {__mode = "k"})
local __K2L_HashNext = 0

local function __K2L_Hash(value)
    local t = type(value)
    if value == nil then
        return 0
    elseif t == "boolean" then
        return value and 1231 or 1237
    elseif t == "number" then
        if math.type(value) == "integer" then
            -- Int.hashCode() is the value itself; Long.hashCode() folds the high bits in.
            if value >= -0x80000000 and value <= 0x7FFFFFFF then
                return value
            end
            return __K2L_ToInt32(value ~ (value >> 32))
        end
        return __K2L_Hash(string.unpack("<i8", string.pack("<d", value)))
    elseif t == "string" then
        local h = 0
        for i = 1, #value do
            h = (31 * h + value:byte(i)) & 0xFFFFFFFF
        end
        return __K2L_ToInt32(h)
    elseif t == "table" and value.hashCode ~= nil then
        return value:hashCode()
    end
    local id = __K2L_HashIds[value]
    if id == nil then
        __K2L_HashNext = __K2L_HashNext + 1
        id = __K2L_HashNext
        __K2L_HashIds[value] = id
    end
    return id
end
