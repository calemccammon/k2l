local function __K2L_DoubleToInt(x)
    if x ~= x then
        return 0
    elseif x >= 2147483647 then
        return 2147483647
    elseif x <= -2147483648 then
        return -2147483648
    end
    -- + 0 turns the -0.0 of math.ceil(-0.5) into 0 where integers are doubles
    return (x >= 0 and math.floor(x) or math.ceil(x)) + 0
end
