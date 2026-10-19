-- The text of a CharSequence: a string, or an object of a class implementing CharSequence (its toString()). The String
-- functions run on that text.
local function __K2L_CharSequenceText(value)
    if type(value) == "string" then
        return value
    end
    return value:toString()
end
