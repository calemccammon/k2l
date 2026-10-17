local function __K2L_DoubleToLong(x)
    if x ~= x then
        return 0
    elseif x >= 0x1p63 then
        return math.maxinteger
    elseif x <= -0x1p63 then
        return math.mininteger
    end
    return x >= 0 and math.floor(x) or math.ceil(x)
end
