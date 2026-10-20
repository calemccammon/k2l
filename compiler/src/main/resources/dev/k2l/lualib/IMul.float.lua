-- requires: ToInt32
-- Kotlin Int multiplication, wrapped to 32 bits. The exact product can exceed 2^53, so a is split into 16-bit
-- halves: a * b = al * b + (ah * b mod 2^16) * 2^16 (mod 2^32), and every partial result is below 2^48.
local function __K2L_IMul(a, b)
    local al = a % 65536
    local ah = (a - al) / 65536
    local r = (al * b + ((ah * b) % 65536) * 65536) % 4294967296
    if r >= 2147483648 then
        return r - 4294967296
    end
    return r
end
