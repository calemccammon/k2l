-- `x::class.simpleName` of a value whose static type does not say its class: the end of the class's name (nil for an
-- object expression, whose name ends in a number). Numbers are Int or Double, chars are Strings.
local function __K2L_SimpleName(value)
    local t = type(value)
    if t == "table" then
        -- an `object` is its class's table
        local cls = rawget(value, "____name") ~= nil and value or getmetatable(value)
        if type(cls) ~= "table" or cls.____name == nil then
            return nil
        end
        local last = cls.____name:match("[^.$]+$")
        if last:find("^%d+$") then
            return nil
        end
        return last
    elseif t == "string" then
        return "String"
    elseif t == "boolean" then
        return "Boolean"
    elseif t == "number" then
        local isFloat
        if math.type then
            isFloat = math.type(value) == "float"
        else
            isFloat = value % 1 ~= 0
        end
        return isFloat and "Double" or "Int"
    end
    return nil
end
