-- Kotlin natural order (compareTo) for numbers, strings, booleans and Comparable objects: Lua's < for numbers and strings
-- (bytes).
local function __K2L_Compare(a, b)
    local t = type(a)
    if t == "number" and type(b) == "number" then
        if a < b then
            return -1
        elseif a > b then
            return 1
        end
        return 0
    elseif t == "string" and type(b) == "string" then
        if a == b then
            return 0
        end
        return a < b and -1 or 1
    end
    if a == nil then
        return b == nil and 0 or -1
    elseif b == nil then
        return 1
    end
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

-- compareValues(a, b), which compareBy and thenBy use: the same object is equal to itself without a call to compareTo.
local function __K2L_CompareValues(a, b)
    -- the common cases of __K2L_Compare first, without the second call
    local t = type(a)
    if t == "number" and type(b) == "number" then
        if a < b then
            return -1
        elseif a > b then
            return 1
        end
    elseif t == "string" and type(b) == "string" and a ~= b then
        return a < b and -1 or 1
    end
    if rawequal(a, b) then
        return 0
    end
    return __K2L_Compare(a, b)
end
