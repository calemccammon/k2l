-- Kotlin `is` against library interfaces and classes that the lualib does not represent by a class of its own:
-- `Number`, `Comparable` and `CharSequence`. Classes of the program implementing CharSequence are told by the method the
-- interface requires (`subSequence`), as nothing at run time records the marker interface; Comparable ones by a flag.
local function className(value)
    local mt = type(value) == "table" and getmetatable(value)
    return type(mt) == "table" and rawget(mt, "____name") or nil
end

local function __K2L_IsNumber(value)
    if type(value) == "number" then
        return true
    end
    local name = className(value)
    return name == "java.math.BigInteger" or name == "java.math.BigDecimal"
end

local function __K2L_IsComparable(value)
    local t = type(value)
    if t == "number" or t == "string" or t == "boolean" then
        return true
    end
    -- classes of the program implementing Comparable have `____comparable` (see SuperEntries.kt), enum classes their entries in
    -- `____values`; numbers of the lualib (`BigInteger`, `BigDecimal`, emulated Longs) have `____isNumber`. A companion sharing
    -- its class's table is marked `____companion`
    if t ~= "table" or rawget(value, "____companion") then
        return false
    end
    return value.____comparable == true or value.____isNumber == true or value.____values ~= nil
end

local function __K2L_IsCharSequence(value)
    local t = type(value)
    if t == "string" then
        return true
    end
    if t ~= "table" or rawget(value, "____name") ~= nil then
        return false
    end
    return className(value) == "java.lang.StringBuilder" or type(value.subSequence) == "function"
end
