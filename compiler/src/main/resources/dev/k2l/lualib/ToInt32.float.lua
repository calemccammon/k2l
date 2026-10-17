-- Wraps a number to Kotlin's 32-bit Int range, as Long.toInt() does.
local function __K2L_ToInt32(x)
    x = x % 4294967296
    if x >= 2147483648 then
        return x - 4294967296
    end
    return x
end
