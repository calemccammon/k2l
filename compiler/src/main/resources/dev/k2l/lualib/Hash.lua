-- requires: ToInt32, IdentityHash
-- hashCode() of a value: a number by its value (an integral Double hashes like the Int it equals), a string by its bytes, a
-- boolean as 1231 or 1237, an object by its own hashCode() or else by identity. Hash codes are the same on every target.
local byte, floor = string.byte, math.floor

-- s[0] * 31^(n-1) + ... + s[n-1] of the bytes, four per step (h * 31^4 + ... stays below 2^53, so it is exact with doubles)
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
    return __K2L_ToInt32(h)
end

local function hashNumber(x)
    if x ~= x then
        return 0
    elseif x % 1 ~= 0 or x >= 9007199254740992 or x <= -9007199254740992 then
        -- a fraction, an infinity or a number beyond 2^53: by its text
        return hashString(string.format("%.17g", x))
    elseif x >= -2147483648 and x <= 2147483647 then
        return x == 0 and 0 or floor(x)
    end
    return __K2L_ToInt32(floor(x / 4294967296) * 31 + x % 4294967296)
end

local function __K2L_Hash(value)
    local t = type(value)
    if t == "number" then
        return hashNumber(value)
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
