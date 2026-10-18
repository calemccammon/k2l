-- Kotlin natural order (compareTo) for numbers, strings, booleans and Comparable objects.
local function __K2L_Compare(a, b)
    if a == nil then
        return b == nil and 0 or -1
    elseif b == nil then
        return 1
    end
    local t = type(a)
    if t == "table" then
        return a:compareTo(b)
    elseif t == "boolean" then
        return (a and 1 or 0) - (b and 1 or 0)
    elseif a < b then
        return -1
    elseif a > b then
        return 1
    end
    return 0
end
