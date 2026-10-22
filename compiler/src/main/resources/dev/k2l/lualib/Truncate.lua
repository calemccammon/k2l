-- Double.toInt(), toLong() and truncate(x): toward zero. math.floor and math.ceil give an integer on Lua 5.3+ where it fits.
local floor, ceil = math.floor, math.ceil

local function __K2L_Truncate(x)
    if x < 0 then
        return ceil(x)
    end
    return floor(x)
end
