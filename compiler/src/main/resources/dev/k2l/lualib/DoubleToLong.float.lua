local function __K2L_DoubleToLong(x)
    if x ~= x then
        return 0
    elseif x >= 9223372036854775807 then
        return 9223372036854775807
    elseif x <= -9223372036854775808 then
        return -9223372036854775808
    end
    -- + 0 turns the -0.0 of math.ceil(-0.5) into 0 where integers are doubles
    return (x >= 0 and math.floor(x) or math.ceil(x)) + 0
end
