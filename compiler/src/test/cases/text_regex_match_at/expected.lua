local ____lualib = require("lualib_bundle")
local __K2L_IndexOutOfBoundsException = ____lualib.__K2L_IndexOutOfBoundsException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function tokens(src)
    local rules = __K2L_ReadOnlyListOf(__K2L_Pair.new("num", __K2L_Regex.new("\\d+(\\.\\d+)?")), __K2L_Pair.new("id", __K2L_Regex.new("[A-Za-z_]\\w*")), __K2L_Pair.new("op", __K2L_Regex.new("[-+*/=()]")), __K2L_Pair.new("ws", __K2L_Regex.new("\\s+")))
    local out = __K2L_ListOf()
    local i = 0
    while i < #src do
        do
            local ____value = rules:firstNotNullOfOrNull(function(____destructured)
                local k, r = ____destructured.first, ____destructured.second
                local ____receiver = r:matchAt(src, i)
                return ____receiver and __K2L_Pair.new(k, ____receiver)
            end)
            if ____value == nil then
                local ____result
                out:add("error@" .. i)
                i = i + 1
                ____result = nil
                ____value = ____result
            end
            local ____value_1 = ____value
            if ____value_1 == nil then
                goto ____continue
            end
            local kind, m = ____value_1.first, ____value_1.second
            if kind ~= "ws" then
                out:add(kind .. ":" .. m.value .. "@" .. m.range.first)
            end
            i = m.range.last + 1
        end
        ::____continue::
    end
    return out
end

local function main()
    print(__K2L_Str(tokens("x1 = 3.25*(y+42) / z_9 ? 7")))
    local word = __K2L_Regex.new("\\w+")
    local text = "hello world"
    print(__K2L_Str(__K2L_ReadOnlyListOf(0, 1, 5, 6, 11):map(function(it)
        local ____receiver_1 = word:matchAt(text, it)
        return ____receiver_1 and ____receiver_1.value
    end)))
    print(__K2L_Str(__K2L_ReadOnlyListOf(0, 5, 6, 11):map(function(it) return word:matchesAt(text, it) end)))
    local ____receiver_2 = __K2L_Regex.new("(?<=o)r"):matchAt("world", 2)
    print(__K2L_Str(____receiver_2 and ____receiver_2.range) .. " " .. __K2L_Str(__K2L_Regex.new("^w"):matchAt("a world", 2)) .. " " .. tostring(__K2L_Regex.new("\\bw"):matchesAt("a world", 2)))
    local ____list = __K2L_ReadOnlyListOf(-1, 12)
    for ____i = 1, ____list.size do
        local bad = ____list[____i]
        local ____ok, ____result_1 = pcall(function()
            word:matchAt(text, bad)
        end)
        if not ____ok then
            local ____error = __K2L_ToThrowable(____result_1)
            if __K2L_InstanceOf(____error, __K2L_IndexOutOfBoundsException) then
                local e = ____error
                print("matchAt(" .. bad .. "): " .. __K2L_Str(__K2L_KClassOfValue(e).simpleName))
            else
                error(____error, 0)
            end
        end
    end
    print(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("[a-z&&[^aeiou]]+"):findAllFactory("programming language")):map(function(it) return it.value end):toList()))
    print(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("[\\w&&\\D]+"):findAllFactory("abc123def_45")):map(function(it) return it.value end):toList()))
    print(__K2L_Sequence.new(__K2L_Regex.new("[a-m&&h-z]"):findAllFactory("abcdefghijklmnopqrstuvwxyz")):joinToString("", nil, nil, nil, nil, function(it) return it.value end))
    print(__K2L_Regex.new("[A-Z&&[^H]]"):replace("Hello World", "#") .. " " .. __K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("[0-9&&[^5]]{2}"):findAllFactory("12345567")):map(function(it) return it.value end):toList()))
    print(tostring(__K2L_Sequence.new(__K2L_Regex.new("\\p{Z}"):findAllFactory("a b\tc")):count()) .. " " .. __K2L_Sequence.new(__K2L_Regex.new("\\p{IsWhite_Space}"):findAllFactory("a b\tc\nd")):count() .. " " .. __K2L_Str(__K2L_Regex.new("\\p{javaWhitespace}+"):split("a \t b\031c")))
end

main()
return {tokens = tokens}
