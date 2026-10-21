local ____lualib = require("lualib_bundle")
local __K2L_CharSequenceText = ____lualib.__K2L_CharSequenceText
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_PropertyOverride = ____lualib.__K2L_PropertyOverride
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_Utf16 = ____lualib.__K2L_Utf16
local __K2L_Utf16Case = ____lualib.__K2L_Utf16Case

local Pairs = __K2L_Class("Pairs")

function Pairs:____init(____pairs)
    self.pairs = ____pairs
end

function Pairs.new(____pairs)
    return setmetatable({pairs = ____pairs}, Pairs)
end

function Pairs:getLength()
    return self.pairs * 2
end

function Pairs:get(index)
    return __K2L_Text.get("😀", index >= 0 and index % 2 or 0 - -index % 2)
end

function Pairs:subSequence(startIndex, endIndex)
    local ____dividend = endIndex - startIndex
    return Pairs.new(____dividend >= 0 and ____dividend // 2 or 0 - -____dividend // 2)
end

function Pairs:toString()
    return "Pairs(" .. self.pairs .. ")"
end

__K2L_PropertyOverride(Pairs, "length", "getLength")

local function units(s)
    local out = __K2L_StringBuilder.new()
    for c in __K2L_Text.chars(s) do
        out:append(__K2L_Num.toRadix(__K2L_Utf16.code(c), 16)):append(" ")
    end
    return __K2L_Text.trim(out:toString())
end

local function main()
    local texts = __K2L_ReadOnlyListOf("héllo", __K2L_StringBuilder.new("ünï😀"), Pairs.new(2))
    local ____mod = texts.____modCount
    for ____i = 1, texts.size do
        local t = texts[____i]
        print(__K2L_Utf16.out(__K2L_Utf16.norm(__K2L_Text.charsLength(t) .. " " .. __K2L_Text.charsLength(t) - 1 .. " " .. __K2L_Text.charsGet(t, 1) .. " " .. __K2L_Utf16.code(__K2L_Text.charsGet(t, __K2L_Text.charsLength(t) - 1)) .. " [" .. units(t) .. "]")))
        local n = 0
        local ____range = __K2L_IntRange.new(0, __K2L_Text.charsLength(t) - 1)
        for i = ____range.first, ____range.last, ____range.step do
            if __K2L_Utf16.isSurrogate(__K2L_Text.charsGet(t, i)) then
                n = n + 1
            end
        end
        print(__K2L_Utf16.out("surrogates=" .. n .. " text=" .. __K2L_Str(t) .. " upper=" .. __K2L_Utf16Case.uppercase(__K2L_Str(t)) .. " has=" .. tostring(__K2L_Text.contains(__K2L_CharSequenceText(t), "😀"))))
        if texts.____modCount ~= ____mod and texts:____comodified(____i) then
            break
        end
    end
    local sb = __K2L_StringBuilder.new("añb")
    local cs = sb
    local ____collection = __K2L_Text.toList(__K2L_CharSequenceText(cs)):withIndex()
    local ____items, ____n = ____collection:____array()
    for ____i_1 = 1, ____n do
        local ____item = ____items[____i_1]
        local i, c = ____item.index, ____item.value
        io.write(__K2L_Utf16.out(__K2L_Utf16.norm(i .. "=" .. c .. " ")))
    end
    print()
end

__K2L_Main(main)
return {Pairs = Pairs, units = units}
