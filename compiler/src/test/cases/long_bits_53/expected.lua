local ____lualib = require("lualib_bundle")
local __K2L_Bits = ____lualib.__K2L_Bits
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StrByte = ____lualib.__K2L_StrByte

local function unsigned(x)
    return x & 4294967295
end

local ____lambda_1 = function(it) return (1 << it) - 1 end
local ____lambda_2 = function(acc, i) return acc | 1 << i end
local function main()
    print(unsigned(-1) .. " " .. unsigned(-2) .. " " .. unsigned(123) .. " " .. unsigned(-2147483648))
    local big = 1 << 40 | 1 << 3
    print(big .. " " .. (big & 1 << 40) .. " " .. (big ~ 8) .. " " .. ~big .. " " .. ~-big)
    print((-1 & 1099511627775) .. " " .. (-256 | 255) .. " " .. (20015998343868 ~ 281474976710655))
    print((1 << 52) // (1 << 50) .. " " .. -(1 << 45) // (1 << 40) .. " " .. (-1 >> 12) .. " " .. (-4096 >> 40) .. " " .. (1 << 35 >> 3) .. " " .. (-8 >> 0))
    local masks = __K2L_IntRange.new(30, 36):map(____lambda_1)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = masks:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = __K2L_Bits.ones64(it)
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    local h = 0
    for ____i_1 = 1, #"hash me" do
        local c = __K2L_StrByte("hash me", ____i_1)
        h = h * 31 + c & 4294967295
    end
    print("hash " .. h .. " " .. __K2L_Num.toRadix(h, 16))
    local bitboard = __K2L_IntRange.new(0, 48 - 1):withStep(5):fold(0, ____lambda_2)
    print("board " .. bitboard .. " set=" .. __K2L_Str(__K2L_IntRange.new(0, 48 - 1):filter(function(it) return bitboard // (1 << it) & 1 == 1 end)))
    print("nul:\000:end " .. 0)
    print(#"a\000b" .. " [" .. "x\000y" .. "]")
end

main()
return {unsigned = unsigned}
