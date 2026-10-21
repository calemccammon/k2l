local ____lualib = require("lualib_bundle")
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local ____lambda_1 = function(g) return "[" .. g .. "]" end
local ____lambda_2 = function(it)
    return it.range.first .. ":" .. it.value .. it.groupValues:drop(1):joinToString("", nil, nil, nil, nil, ____lambda_1)
end
local function show(pattern, input)
    local regex = __K2L_Regex.new(pattern)
    local found = __K2L_Sequence.new(regex:findAllFactory(input)):map(____lambda_2)
    print(pattern .. " on \"" .. input .. "\" -> " .. found:joinToString(" "))
end

local function reject(pattern)
    local ____ok, ____result = __K2L_DeepPcall(function()
        __K2L_Regex.new(pattern)
        print("accepted " .. pattern)
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
            local e = ____error
            print(__K2L_Str(__K2L_KClassOfValue(e).simpleName) .. ": " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
end

local function main()
    show("(?<=ab)c", "abc xbc abcabc c")
    show("(?<!x)y", "xy y zy yy")
    show("(?<=a|bcd)e", "ae bcde cde e")
    show("(?<!a|bcd)e", "ae bcde cde e")
    show("(?<=[a-c]{2})\\d", "ab1 a2 cc3 9")
    show("(?<=x{1,3})y", "xy xxxy y xxxxy")
    show("(?<=\\b\\w{1,3})\\.", "ab. abcd. a.b.")
    show("(?<=(a|bc)(d|ef)?)!", "ad! bcef! a! aefd! x!")
    show("(?<=(?:de){2}(f{2}))!", "dedeff! deff!")
    show("(?<=(?:ab){0,3})q", "q abq ababq")
    show("(?<=(?:x(?:y|zz)?)?)-", "x- xy- xzz- -")
    show("(?<=(?<=a)b)c", "abc bc")
    show("(?<=a+)b", "aab b xab")
    show("(?<=xa*)q", "xq xaaq q")
    show("(?<=x.+)q", "x12q q")
    show("(?<!\\d+)px", "12px apx px")
    show("(?<=a+(?:b|cd))!", "ab! aacd! cd!")
    show("(?<=^|,)\\w+", "one,two,,three")
    show("(?<=(\\w)\\w)\\b", "ab cde")
    show("(?i)(?<=AB)c", "abc aBc xbc")
    print("lookbehind replace: " .. __K2L_Regex.new("(?<=\\d)(?=(\\d{3})+$)"):replace("1234567", ","))
    print("split: " .. __K2L_Str(__K2L_Regex.new("(?<=[XY])"):split("aXbYc")))
    reject("(?<=(a)\\1)b")
    reject("(?<!(x|yz){0,3})q")
    reject("(?<=(?:ab)*)q")
    reject("(?<=(?:a|bc)+)q")
    reject("(?<=xa+?)q")
    reject("(?<=xa++)q")
    reject("(?<=(?:a?){2})q")
    reject("(?<=(a|bc)(d|ef){1,2})!")
    reject("(?<=a+)q")
    reject("(?<=(?:a){2,})q")
    reject("(?<=(?:a|bc)?+)q")
    local text = ("ab"):rep(20000) .. "c"
    print("long (?<=a)b: " .. __K2L_Sequence.new(__K2L_Regex.new("(?<=a)b"):findAllFactory(text)):count())
    print("long (?<!a)b: " .. __K2L_Sequence.new(__K2L_Regex.new("(?<!a)b"):findAllFactory(text)):count())
    local ____receiver = __K2L_Regex.new("(?<=ab{1,3})c"):find(text)
    print("long (?<=ab{1,3})c: " .. __K2L_Str(____receiver and ____receiver.range))
    print("long (?<=x|yz)c: " .. __K2L_Str(__K2L_Regex.new("(?<=x|yz)c"):find(text)))
    local ____receiver_1 = __K2L_Regex.new("(?<=[^c]{2})c"):find(text)
    print("long (?<=[^c]{2})c: " .. __K2L_Str(____receiver_1 and ____receiver_1.range))
end

__K2L_DeepMain(main)
return {show = show, reject = reject}
