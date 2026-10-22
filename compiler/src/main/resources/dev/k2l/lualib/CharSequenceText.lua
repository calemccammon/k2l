-- The text of a CharSequence: a string, a StringBuilder or a class delegating CharSequence (their ____text()), or an
-- object of a class implementing CharSequence: the chars of its get(i) up to its length. The String functions run on
-- that text.
local function __K2L_CharSequenceText(value)
    if type(value) == "string" or value == nil then
        return value
    end
    local text = value.____text
    if text ~= nil then
        return text(value)
    end
    local getLength = value.getLength
    local n = getLength ~= nil and getLength(value) or value.length
    local chars = {}
    for i = 1, n do
        chars[i] = value:get(i - 1)
    end
    return table.concat(chars)
end
