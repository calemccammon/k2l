-- The ASCII Char tests as lookup tables, by the one-character string a Char is:
-- `__K2L_IsDigit[c] == true` is `c:match("^%d$") ~= nil` without the pattern call (each table is built with that match).
local function charClass(pattern)
    local t = {}
    for b = 0, 255 do
        local c = string.char(b)
        if c:match(pattern) then
            t[c] = true
        end
    end
    return t
end

local __K2L_IsDigit = charClass("^%d$")
local __K2L_IsLetter = charClass("^%a$")
local __K2L_IsLetterOrDigit = charClass("^%w$")
local __K2L_IsWhitespace = charClass("^%s$")
local __K2L_IsUpperCase = charClass("^%u$")
local __K2L_IsLowerCase = charClass("^%l$")

