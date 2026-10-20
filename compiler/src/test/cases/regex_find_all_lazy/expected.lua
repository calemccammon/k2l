local ____lualib = require("lualib_bundle")
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringToInt = ____lualib.__K2L_StringToInt

local ____lambda_1 = function(it) return #it.groupValues:get(2) >= 2 end
local ____lambda_2 = function(it) return it.range end
local ____lambda_3 = function(it)
    return __K2L_StringToInt(it.groupValues:get(2))
end
local ____lambda_4 = function(it) return it > 1 end
local ____lambda_5 = function(it) return it.value:upper() end
local function main()
    local re = __K2L_Regex.new("(\\w)=(\\d+)")
    local text = "a=1, b=22, c=333, d=4"
    for _, m in __K2L_Sequence.new(re:findAllFactory(text)):iter() do
        do
            local ____destructured = m.destructured
            local k, v = ____destructured[1], ____destructured[2]
            io.write(k .. ":" .. v .. " ")
        end
    end
    print()
    for _, m in __K2L_Sequence.new(re:findAllFactory(text, 6)):iter() do
        io.write(m.value .. "@" .. m.range.first .. " ")
    end
    print()
    local seen = __K2L_ListOf()
    local firstLong = __K2L_Sequence.new(re:findAllFactory(text)):onEach(function(it)
        seen:add(it.value)
    end):first(____lambda_1)
    print(firstLong.value .. " after " .. __K2L_Str(seen))
    print(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("x*"):findAllFactory("axb")):map(____lambda_2):toList()))
    print(__K2L_Sequence.new(re:findAllFactory(text)):count() + __K2L_Sequence.new(re:findAllFactory("")):count())
    print(__K2L_Sequence.new(re:findAllFactory(text)):map(____lambda_3):filter(____lambda_4):sum())
    local matches = __K2L_Sequence.new(re:findAllFactory(text))
    print(matches:toList().size .. " " .. matches:toList().size .. " " .. matches:iterator():next().value)
    print(__K2L_Str(__K2L_RunCatching(function()
        return __K2L_Sequence.new(re:findAllFactory(text, 99))
    end):exceptionOrNull()))
    print(__K2L_Sequence.new(__K2L_Regex.new("[aeiou]"):findAllFactory("sequence")):joinToString("", nil, nil, nil, nil, ____lambda_5))
end

main()
