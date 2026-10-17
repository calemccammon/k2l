-- Wraps a Lua integer to Kotlin's 32-bit Int range, as Long.toInt() does.
local function __K2L_ToInt32(x)
    x = x & 0xFFFFFFFF
    if x >= 0x80000000 then
        return x - 0x100000000
    end
    return x
end
