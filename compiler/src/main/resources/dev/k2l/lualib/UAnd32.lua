-- The and of two unsigned 32-bit patterns held in doubles, eight bits at a time from a table of the and of two bytes
-- (AND8[x * 256 + y + 1]), for the bitwise operations of plain Lua 5.1 (Bit.51, Long64.l64). The table is only built
-- where there is no bit32 library to do the work.
local AND8 = {}
if not bit32 then
    local AND4 = {}
    for x = 0, 15 do
        for y = 0, 15 do
            local r, bit, a, b = 0, 1, x, y
            for _ = 1, 4 do
                local p, q = a % 2, b % 2
                if p == 1 and q == 1 then
                    r = r + bit
                end
                a, b, bit = (a - p) / 2, (b - q) / 2, bit * 2
            end
            AND4[x * 16 + y + 1] = r
        end
    end
    for x = 0, 255 do
        local xl, xh = x % 16 * 16 + 1, (x - x % 16) + 1
        for y = 0, 255 do
            local yl = y % 16
            AND8[x * 256 + y + 1] = AND4[xl + yl] + AND4[xh + (y - yl) / 16] * 16
        end
    end
end

-- the table itself, for the operations of Bit.51 that do these steps in place
local __K2L_AND8 = AND8

-- the unsigned and of two unsigned 32-bit patterns, stopping when either operand has no bits left
local function __K2L_UAnd32(a, b)
    local x, y = a % 256, b % 256
    local r = AND8[x * 256 + y + 1]
    a, b = (a - x) / 256, (b - y) / 256
    if a == 0 or b == 0 then
        return r
    end
    x, y = a % 256, b % 256
    r = r + AND8[x * 256 + y + 1] * 256
    a, b = (a - x) / 256, (b - y) / 256
    if a == 0 or b == 0 then
        return r
    end
    x, y = a % 256, b % 256
    r = r + AND8[x * 256 + y + 1] * 65536
    a, b = (a - x) / 256, (b - y) / 256
    return r + AND8[a * 256 + b + 1] * 16777216
end

-- the unsigned xor and or, from the and of the same steps (a + b = (a xor b) + 2 (a and b), a or b = a + b - (a and b)),
-- for Long64.l64
local function __K2L_UXor32(a, b)
    local x, y = a % 256, b % 256
    local n = AND8[x * 256 + y + 1]
    local p, q = (a - x) / 256, (b - y) / 256
    if p ~= 0 and q ~= 0 then
        x, y = p % 256, q % 256
        n = n + AND8[x * 256 + y + 1] * 256
        p, q = (p - x) / 256, (q - y) / 256
        if p ~= 0 and q ~= 0 then
            x, y = p % 256, q % 256
            n = n + AND8[x * 256 + y + 1] * 65536
            p, q = (p - x) / 256, (q - y) / 256
            n = n + AND8[p * 256 + q + 1] * 16777216
        end
    end
    return a + b - 2 * n
end

local function __K2L_UOr32(a, b)
    local x, y = a % 256, b % 256
    local n = AND8[x * 256 + y + 1]
    local p, q = (a - x) / 256, (b - y) / 256
    if p ~= 0 and q ~= 0 then
        x, y = p % 256, q % 256
        n = n + AND8[x * 256 + y + 1] * 256
        p, q = (p - x) / 256, (q - y) / 256
        if p ~= 0 and q ~= 0 then
            x, y = p % 256, q % 256
            n = n + AND8[x * 256 + y + 1] * 65536
            p, q = (p - x) / 256, (q - y) / 256
            n = n + AND8[p * 256 + q + 1] * 16777216
        end
    end
    return a + b - n
end
