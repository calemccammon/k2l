-- The text of a CharSequence: a string, or an object of a class implementing CharSequence (its toString(), or for a class
-- delegating CharSequence the delegate's text, ____text()). The String functions run on that text.
local function __K2L_CharSequenceText(value)
    if type(value) == "string" then
        return value
    end
    local text = value.____text
    if text ~= nil then
        return text(value)
    end
    return value:toString()
end
