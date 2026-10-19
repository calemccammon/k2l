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
    elseif t == "string" and a ~= b and (a:find("[\240-\244]") or b:find("[\240-\244]")) then
        return utf16Order(a, b)
    elseif a < b then
        return -1
    elseif a > b then
        return 1
    end
    return 0
end
