local ____lualib = require("lualib_bundle")
local __K2L_IndexOutOfBoundsException = ____lualib.__K2L_IndexOutOfBoundsException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_SimpleName = ____lualib.__K2L_SimpleName
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local function tokens(src)
    local rules = __K2L_ListOf(__K2L_Pair.new("num", __K2L_Regex.new("\\d+\\.?\\d*", "%d+%.?%d*")), __K2L_Pair.new("id", __K2L_Regex.new("[A-Za-z_]\\w*", "[A-Za-z_][%w_]*")), __K2L_Pair.new("op", __K2L_Regex.new("[-+*/=()]", "[%-%+%*%/%=%(%)]")), __K2L_Pair.new("ws", __K2L_Regex.new("\\s+", "%s+")))
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

local ____lambda_1 = function(it) return it.value end
local ____lambda_2 = function(it) return it.value end
local ____lambda_3 = function(it) return it.value end
local ____lambda_4 = function(it) return it.value end
local function main()
    print(__K2L_Str(tokens("x1 = 3.25*(y+42) / z_9 ? 7")))
    local word = __K2L_Regex.new("\\w+", "[%w_]+")
    local text = "hello world"
    local ____list = __K2L_ListOf(0, 1, 5, 6, 11)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        local ____result_1
        do
            local ____receiver_1 = word:matchAt(text, it)
            ____result_1 = ____receiver_1 and ____receiver_1.value
        end
        ____count = ____count + 1
        ____out[____count] = ____result_1
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    local ____list_1 = __K2L_ListOf(0, 5, 6, 11)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = word:matchesAt(text, it)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
    local ____receiver_2 = __K2L_Regex.new("r", "r"):matchAt("world", 2)
    print(__K2L_Str(____receiver_2 and ____receiver_2.range) .. " " .. __K2L_Str(__K2L_Regex.new("^w", "^w"):matchAt("a world", 2)) .. " " .. tostring(__K2L_Regex.new("\\bw", "%f[%w_]w"):matchesAt("a world", 2)))
    local ____list_2 = __K2L_ListOf(-1, 12)
    for ____i_2 = 1, ____list_2.size do
        local bad = ____list_2[____i_2]
        local ____ok, ____result_2 = pcall(function()
            word:matchAt(text, bad)
        end)
        if not ____ok then
            local ____error = __K2L_ToThrowable(____result_2)
            if __K2L_InstanceOf(____error, __K2L_IndexOutOfBoundsException) then
                local e = ____error
                print("matchAt(" .. bad .. "): " .. __K2L_Str(__K2L_SimpleName(e)))
            else
                error(____error, 0)
            end
        end
    end
    print(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("[b-df-hj-np-tv-z]+", "[b-df-hj-np-tv-z]+"):findAllFactory("programming language")):map(____lambda_1):toList()))
    print(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("[a-zA-Z_]+", "[a-zA-Z_]+"):findAllFactory("abc123def_45")):map(____lambda_2):toList()))
    print(__K2L_Sequence.new(__K2L_Regex.new("[h-m]", "[h-m]"):findAllFactory("abcdefghijklmnopqrstuvwxyz")):joinToString("", nil, nil, nil, nil, ____lambda_3))
    print(__K2L_Regex.new("[A-GI-Z]", "[A-GI-Z]"):replace("Hello World", "#") .. " " .. __K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("[0-46-9]{2}", "[0-46-9][0-46-9]"):findAllFactory("12345567")):map(____lambda_4):toList()))
    print(tostring(__K2L_Sequence.new(__K2L_Regex.new(" ", " "):findAllFactory("a b\tc")):count()) .. " " .. __K2L_Sequence.new(__K2L_Regex.new("\\s", "%s"):findAllFactory("a b\tc\nd")):count() .. " " .. __K2L_Str(__K2L_Regex.new("[\\s\031]+", "[%s\031]+"):split("a \t b\031c")))
end

__K2L_RunMain(main)
return {tokens = tokens}
