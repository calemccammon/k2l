local function __K2L_DoubleToInt(x)
    if x ~= x then
        return 0
    elseif x >= 2147483647 then
        return 2147483647
    elseif x <= -2147483648 then
        return -2147483648
    end
    return x >= 0 and math.floor(x) or math.ceil(x)
end
