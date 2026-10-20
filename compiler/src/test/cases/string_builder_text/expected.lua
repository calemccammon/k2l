local ____lualib = require("lualib_bundle")
local __K2L_IsDigit = ____lualib.__K2L_IsDigit
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
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

local ____lambda_1 = function(it) return it == "," end
local ____lambda_2 = function(it) return __K2L_IsDigit[it] == true end
local ____lambda_3 = function(it) return it ~= "a" end
local function main()
    local sb = __K2L_StringBuilder.new()
    for i = 1, 4 do
        sb:append(tostring(i)):append(", ")
    end
    print("[" .. __K2L_Str(__K2L_Text.removeSuffix(sb:toString(), ", ")) .. "] [" .. __K2L_Str(__K2L_Text.removePrefix(sb:toString(), "1, ")) .. "] [" .. __K2L_Str(__K2L_StringTrim(sb:toString())) .. "] [" .. __K2L_Str(__K2L_Text.trimChars(sb:toString(), 2, ",", " ")) .. "]")
    print(tostring(__K2L_StringStartsWith(sb:toString(), "1")) .. " " .. tostring(__K2L_StringEndsWith(sb:toString(), ", ")) .. " " .. tostring(__K2L_StringContains(sb:toString(), "3,")) .. " " .. __K2L_StringToList(sb:toString()):count(____lambda_1) .. " " .. tostring(__K2L_StringIsBlank(sb:toString())) .. " " .. tostring(__K2L_StringToList(sb:toString()):any(____lambda_2)))
    local ____list = __K2L_StringSplit(sb:toString(), ", ")
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        if #it > 0 then
            ____count = ____count + 1
            ____out[____count] = it
        end
    end
    local ____list_1 = __K2L_ListWrap(____out, ____count)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = __K2L_StringToInt(it) * 10
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
    local text = __K2L_StringBuilder.new():appendLine("alpha"):appendLine("beta"):append("gamma")
    print(__K2L_Str(__K2L_StringLines(text:toString())) .. " " .. __K2L_Text.charsLength(__K2L_StringPadStart(text:toString(), 20, ".")) .. " " .. text:indexOf("beta") .. " " .. __K2L_Str(__K2L_Text.filter(text:toString(), ____lambda_3)))
    print(__K2L_Text.first(text:toString()) .. " " .. __K2L_Text.last(text:toString()) .. " " .. __K2L_Str(text:substring(0, 5)) .. " " .. __K2L_Str(text:toString():reverse()) .. " " .. text:toString():upper())
    local ____builder = __K2L_StringBuilder.new()
    ____builder:append("cap")
    ____builder:append(tostring(4))
    for it = 0, 2 do
        ____builder:append("!")
    end
    local ____arg = ____builder:toString()
    local ____builder_1 = __K2L_StringBuilder.new()
    print(____arg .. ____builder_1:toString())
end

main()
