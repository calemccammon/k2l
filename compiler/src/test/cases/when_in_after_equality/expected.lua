local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str

local Color = __K2L_Class("Color")

function Color:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Color:toString()
    return self.name
end

function Color:compareTo(other)
    return self.ordinal - other.ordinal
end

Color.RED = Color.new("RED", 0)
Color.GREEN = Color.new("GREEN", 1)
Color.BLUE = Color.new("BLUE", 2)
Color.____values = {Color.RED, Color.GREEN, Color.BLUE}

local function classify(n)
    if n == 0 then
        return "zero"
    elseif __K2L_ListOf(1, 2, 3):contains(n) then
        return "small"
    elseif __K2L_SetOf(10, 20):contains(n) then
        return "round"
    elseif not (n >= 0 and n <= 100) then
        return "out of range"
    else
        return "other"
    end
end

local function warm(c)
    if c == Color.BLUE then
        return false
    elseif __K2L_ListOf(Color.RED):contains(c) then
        return true
    else
        return false
    end
end

local function cool(c)
    local shade = c
    if shade == Color.RED then
        return "warm"
    elseif __K2L_ListOf(Color.GREEN, Color.BLUE):contains(shade) then
        return "cool " .. __K2L_Str(shade)
    else
        return "?"
    end
end

local function word(s)
    if s == "" then
        return "empty"
    elseif __K2L_ArrayOf("a", "e", "i", "o", "u"):contains(s) then
        return "vowel"
    elseif __K2L_ListOf("y"):contains(s) then
        return "sometimes"
    else
        return "consonant"
    end
end

local function main()
    local ____list = __K2L_ListOf(0, 2, 10, 50, 500)
    for ____i = 1, ____list.size do
        local n = ____list[____i]
        print(n .. " " .. classify(n))
    end
    local ____values = Color.____values
    for ____i_1 = 1, #____values do
        local c = ____values[____i_1]
        print(__K2L_Str(c) .. " " .. tostring(warm(c)) .. " " .. cool(c))
    end
    local ____list_1 = __K2L_ListOf("", "e", "y", "k")
    for ____i_2 = 1, ____list_1.size do
        local s = ____list_1[____i_2]
        print("'" .. s .. "' " .. word(s))
    end
end

__K2L_RunMain(main)
return {Color = Color, classify = classify, warm = warm, cool = cool, word = word}
