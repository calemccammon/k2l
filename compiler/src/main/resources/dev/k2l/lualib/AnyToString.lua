-- requires: Hash
-- Any.toString(): the class name and the hash code in hex, as in `app.Point@1b`.
local function __K2L_AnyToString(value)
    return value.____name .. "@" .. string.format("%x", __K2L_Hash(value) % 4294967296)
end
