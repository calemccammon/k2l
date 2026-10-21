local ____lualib = require("lualib_bundle")
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_Utf16 = ____lualib.__K2L_Utf16

local function checksum(text, pattern)
    local sum = 0
    local count = 0
    for _, m in __K2L_Sequence.new(__K2L_Regex.new(pattern):findAllFactory(text)):iter() do
        local ____dividend = sum * 31 + m.range.first * 7 + m.range.last
        sum = ____dividend >= 0 and ____dividend % 1000000007 or (____dividend % 1000000007 - 1000000007) % (-1000000007)
        local ____list = m.groups:drop(1)
        local ____mod = ____list.____modCount
        for ____i = 1, ____list.size do
            local g = ____list[____i]
            if g ~= nil then
                local ____dividend_1 = sum * 31 + g.range.first + g.range.last * 3
                sum = ____dividend_1 >= 0 and ____dividend_1 % 1000000007 or (____dividend_1 % 1000000007 - 1000000007) % (-1000000007)
            end
            if ____list.____modCount ~= ____mod and ____list:____comodified(____i) then
                break
            end
        end
        count = count + 1
    end
    return count .. " " .. sum
end

local ____lambda_1 = function(it) return it.range.first end
local ____lambda_2 = function(it) return __K2L_Str(it.range) end
local function main()
    local sb = __K2L_StringBuilder.new()
    for i = 0, 5999 do
        sb:append(__K2L_ReadOnlyListOf("é", "😀", "中", "a"):get(i >= 0 and i % 4 or 0 - -i % 4)):append("w"):append(tostring(i >= 0 and i % 10 or 0 - -i % 10))
        if (i >= 0 and i % 7 or 0 - -i % 7) == 0 then
            sb:append("ß😀")
        end
        sb:append(" ")
    end
    local text = sb:toString()
    print(__K2L_Utf16.out(__K2L_Utf16.len(text)))
    print(__K2L_Utf16.out(checksum(text, "w(\\d)")))
    print(__K2L_Utf16.out(checksum(text, "(😀)|(中)w(\\d)")))
    print(__K2L_Utf16.out(checksum(text, "\\s")))
    local at = 0
    local steps = 0
    local last = -1
    while true do
        local ____value = __K2L_Regex.new("\\d+"):find(text, at)
        if ____value == nil then
            break
        end
        local m = ____value
        if __K2L_Regex.new("\\d"):matchAt(text, m.range.first) == nil then
            print(__K2L_Utf16.out("no matchAt at " .. m.range.first))
        end
        last = m.range.last
        at = m.range.last + 1
        steps = steps + 1
    end
    print(__K2L_Utf16.out(steps .. " " .. last))
    local ____list_1 = __K2L_ReadOnlyListOf("😀é😀", "\237\160\189x\237\184\128", "a\237\184\128\237\160\189b", "")
    for ____i_1 = 1, ____list_1.size do
        local s = ____list_1[____i_1]
        print(__K2L_Utf16.out(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new(""):findAllFactory(s)):map(____lambda_1):toList())))
        print(__K2L_Utf16.out(__K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("."):findAllFactory(s)):map(____lambda_2):toList())))
    end
    for i = 0, 5 do
        local m = __K2L_Regex.new("[a-z😀]"):find("é😀ab😀", i)
        print(__K2L_Utf16.out(i .. " -> " .. __K2L_Str(m and m.range) .. " " .. __K2L_Str(m and m.value)))
    end
end

__K2L_Main(main)
return {checksum = checksum}
