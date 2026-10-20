-- Kotlin natural order with --long64 emulate: a number next to a Long box (a table) cannot be compared with < on Lua 5.1.
-- Kotlin natural order (compareTo) for numbers, strings, booleans and Comparable objects.
-- Strings compare by UTF-16 code unit: that differs from the order of the UTF-8 bytes only for supplementary characters
-- (lead byte F0-F4, surrogate pairs) against U+E000-U+FFFF (lead byte EE or EF).
local function utf16Order(a, b)
    local i = 1
    while a:byte(i) == b:byte(i) do
        i = i + 1
    end
    local j = i
    while j > 1 and (a:byte(j) or 0) >= 0x80 and (a:byte(j) or 0) < 0xC0 do
        j = j - 1
    end
    local x, y = a:byte(j), b:byte(j)
    if x and y then
        if x >= 0xF0 and (y == 0xEE or y == 0xEF) then
            return -1
        elseif y >= 0xF0 and (x == 0xEE or x == 0xEF) then
            return 1
        end
    end
    return a < b and -1 or 1
end

-- What a string holds that can make the two orders differ: 1 a supplementary character, 2 one of U+E000-U+FFFF (3 both).
-- Cached per string (strings are interned or hashed by content, so a lookup is cheap); the cache is dropped when full.
local find = string.find
local kinds, kindCount = {}, 0

local function kind(s)
    local k = 0
    if find(s, "[\128-\255]") then
        k = (find(s, "[\240-\244]") and 1 or 0) + (find(s, "[\238\239]") and 2 or 0)
    end
    if kindCount >= 4096 then
        kinds, kindCount = {}, 0
    end
    kinds[s], kindCount = k, kindCount + 1
    return k
end

local function __K2L_Compare(a, b)
    local t = type(a)
    if t == "number" and type(b) == "number" then
        if a < b then
            return -1
        elseif a > b then
            return 1
        elseif a == b and (a ~= 0 or 1 / a == 1 / b) then
            return 0
        end
        -- Double.compareTo is a total order: -0.0 before 0.0, NaN after everything (and equal to itself)
        if a ~= a then
            return b ~= b and 0 or 1
        elseif b ~= b then
            return -1
        end
        return 1 / a < 0 and -1 or 1
    elseif t == "string" and type(b) == "string" then
        if a == b then
            return 0
        end
        local ka, kb = kinds[a] or kind(a), kinds[b] or kind(b)
        if (ka % 2 == 1 and kb >= 2) or (kb % 2 == 1 and ka >= 2) then
            return utf16Order(a, b)
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
    elseif t == "number" and type(b) == "table" then
        return 0 - b:compareTo(a) -- a Long box (--long64 emulate)
    elseif t == "boolean" then
        return (a and 1 or 0) - (b and 1 or 0)
    elseif a < b then
        return -1
    elseif a > b then
        return 1
    elseif t == "number" and (a ~= a or b ~= b or (a == 0 and 1 / a ~= 1 / b)) then
        -- Double.compareTo is a total order: -0.0 before 0.0, NaN after everything (and equal to itself)
        if a ~= a then
            return b ~= b and 0 or 1
        elseif b ~= b then
            return -1
        end
        return 1 / a < 0 and -1 or 1
    end
    return 0
end

-- compareValues(a, b), which compareBy and thenBy use: the same object is equal to itself without a call to compareTo
-- (but 0.0 and -0.0, equal in Lua, are two boxes on the JVM).
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
        local ka, kb = kinds[a] or kind(a), kinds[b] or kind(b)
        if (ka % 2 == 1 and kb >= 2) or (kb % 2 == 1 and ka >= 2) then
            return utf16Order(a, b)
        end
        return a < b and -1 or 1
    end
    if rawequal(a, b) and a ~= 0 then
        return 0
    end
    return __K2L_Compare(a, b)
end
