local ____lualib = require("lualib_bundle")
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringEndsWith = ____lualib.__K2L_StringEndsWith
local __K2L_StringIsBlank = ____lualib.__K2L_StringIsBlank
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_Text = ____lualib.__K2L_Text

local function main()
    local sb = __K2L_StringBuilder.new()
    for i = 1, 4 do
        sb:append(tostring(i)):append(", ")
    end
    print("[" .. __K2L_Str(__K2L_Text.removeSuffix(sb:toString(), ", ")) .. "] [" .. __K2L_Str(__K2L_Text.removePrefix(sb:toString(), "1, ")) .. "] [" .. __K2L_Str(__K2L_StringTrim(sb:toString())) .. "] [" .. __K2L_Str(__K2L_Text.trimChars(sb:toString(), 2, ",", " ")) .. "]")
    print(tostring(__K2L_StringStartsWith(sb:toString(), "1")) .. " " .. tostring(__K2L_StringEndsWith(sb:toString(), ", ")) .. " " .. tostring(__K2L_StringContains(sb:toString(), "3,")) .. " " .. __K2L_StringToList(sb:toString()):count(function(it) return it == "," end) .. " " .. tostring(__K2L_StringIsBlank(sb:toString())) .. " " .. tostring(__K2L_StringToList(sb:toString()):any(function(it) return it:match("^%d$") ~= nil end)))
    print(__K2L_Str(__K2L_StringSplit(sb:toString(), ", "):filter(function(it) return #it > 0 end):map(function(it) return __K2L_StringToInt(it) * 10 end)))
    local text = __K2L_StringBuilder.new():appendLine("alpha"):appendLine("beta"):append("gamma")
    print(__K2L_Str(__K2L_StringLines(text:toString())) .. " " .. #__K2L_StringPadStart(text:toString(), 20, ".") .. " " .. text:indexOf("beta") .. " " .. __K2L_Str(__K2L_Text.filter(text:toString(), function(it) return it ~= "a" end)))
    print(__K2L_Text.first(text:toString()) .. " " .. __K2L_Text.last(text:toString()) .. " " .. __K2L_Str(text:substring(0, 5)) .. " " .. __K2L_Str(text:toString():reverse()) .. " " .. text:toString():upper())
end

main()
