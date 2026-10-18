-- requires: Hash
-- Kotlin/JVM Any.toString(): the class name and the hash code in hex, as in `Point@1b2c`.
local function __K2L_AnyToString(value)
    return value.____name .. "@" .. string.format("%x", __K2L_Hash(value) % 4294967296)
end
