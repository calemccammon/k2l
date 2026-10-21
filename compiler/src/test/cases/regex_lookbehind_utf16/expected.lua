local ____lualib = require("lualib_bundle")
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Utf16 = ____lualib.__K2L_Utf16

local ____lambda_1 = function(it) return it.range.first .. ":" .. it.value end
local function show(pattern, input)
    local found = __K2L_Sequence.new(__K2L_Regex.new(pattern):findAllFactory(input)):map(____lambda_1)
    print(__K2L_Utf16.out(pattern .. " on \"" .. input .. "\" -> " .. found:joinToString(" ")))
end

local function main()
    show("(?<=é)x", "éx ex")
    show("(?<=[éa]{2})x", "aéx éx ééx")
    show("(?<=.)\\.", ".a.é.😀.")
    show("(?<=😀)!", "😀! !")
    show("(?<=[^a]{1,2})!", "😀😀! a!")
    show("(?<!\\p{L})\\d", "é1 2 x3")
    show("(?iu)(?<=k)x", "Kx kx Kx")
    show("(?<=ü+)z", "üüz z")
    local ____ok, ____result = __K2L_DeepPcall(function()
        __K2L_Regex.new("(?<=é(a)\\1)b")
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
            local e = ____error
            print(__K2L_Utf16.out(__K2L_Str(e.message)))
        else
            error(____error, 0)
        end
    end
    local text = ("éb"):rep(10000)
    print(__K2L_Utf16.out("long (?<=é)b: " .. __K2L_Sequence.new(__K2L_Regex.new("(?<=é)b"):findAllFactory(text)):count()))
    print(__K2L_Utf16.out("long (?<![^é])b: " .. __K2L_Sequence.new(__K2L_Regex.new("(?<![^é])b"):findAllFactory(text)):count()))
end

__K2L_DeepMain(main)
return {show = show}
