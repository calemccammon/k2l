local ____lualib = require("lualib_bundle")
local __K2L_CharSequenceText = ____lualib.__K2L_CharSequenceText
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_PropertyOverride = ____lualib.__K2L_PropertyOverride
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringCharAt = ____lualib.__K2L_StringCharAt
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringIndexOf = ____lualib.__K2L_StringIndexOf
local __K2L_StringIsBlank = ____lualib.__K2L_StringIsBlank
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_Text = ____lualib.__K2L_Text

local Letters = __K2L_Class("Letters")

function Letters:____init(n)
    self.n = n
end

function Letters.new(n)
    return setmetatable({n = n}, Letters)
end

function Letters:getLength()
    return self.n
end

function Letters:get(index)
    return string.char(("a"):byte() + index)
end

function Letters:subSequence(startIndex, endIndex)
    return Letters.new(endIndex - startIndex)
end

function Letters:toString()
    return "Letters(" .. self.n .. ")"
end

__K2L_PropertyOverride(Letters, "length", "getLength")
local Fixed = __K2L_Class("Fixed")

function Fixed:____init(length)
    self.length = length
end

function Fixed.new(length)
    return setmetatable({length = length}, Fixed)
end

function Fixed:get(index)
    return (index >= 0 and index % 2 or 0 - -index % 2) == 0 and "x" or "y"
end

function Fixed:subSequence(startIndex, endIndex)
    return Fixed.new(endIndex - startIndex)
end

local Wrapped = __K2L_Class("Wrapped")

function Wrapped:____init(text)
    self.____delegate_CharSequence = text
end

function Wrapped:get(index)
    return __K2L_StringCharAt(__K2L_CharSequenceText(self.____delegate_CharSequence), index)
end

function Wrapped:subSequence(startIndex, endIndex)
    return __K2L_Text.substring(__K2L_CharSequenceText(self.____delegate_CharSequence), startIndex, endIndex)
end

function Wrapped:getLength()
    return #__K2L_CharSequenceText(self.____delegate_CharSequence)
end

__K2L_PropertyOverride(Wrapped, "length", "getLength")

function Wrapped:____text()
    return __K2L_CharSequenceText(self.____delegate_CharSequence)
end

local Holder = __K2L_Class("Holder")

function Holder:____init(text)
    self.text = text
end

function Holder.new(text)
    return setmetatable({text = text}, Holder)
end

local function count(s, c)
    local n = 0
    for x in __K2L_Text.chars(s) do
        if x == c then
            n = n + 1
        end
    end
    return n
end

local function describe(s)
    local sb = __K2L_StringBuilder.new()
    local ____range = __K2L_IntRange.new(0, __K2L_Text.charsLength(s) - 1)
    for i = ____range.first, ____range.last, ____range.step do
        sb:append(__K2L_Text.charsGet(s, i)):append(tostring(i))
    end
    return __K2L_Str(sb) .. " len=" .. __K2L_Text.charsLength(s) .. " last=" .. __K2L_Text.charsLength(s) - 1 .. " empty=" .. tostring(#__K2L_CharSequenceText(s) == 0) .. " blank=" .. tostring(__K2L_StringIsBlank(__K2L_CharSequenceText(s)))
end

local function maybeText(s)
    return tostring(__K2L_CharSequenceText(s) == nil or __K2L_CharSequenceText(s) == "") .. " " .. tostring(__K2L_CharSequenceText(s) == nil or __K2L_StringIsBlank(__K2L_CharSequenceText(s))) .. " " .. __K2L_Str(s and __K2L_Text.charsLength(s)) .. " " .. __K2L_Str(s and __K2L_StringContains(__K2L_CharSequenceText(s), "b")) .. " [" .. __K2L_Str(s) .. "]"
end

local ____lambda_1 = function(it) return it == "l" end
local ____lambda_2 = function(it) return it:upper() end
local function main()
    local builder = __K2L_StringBuilder.new("hello")
    local texts = __K2L_ReadOnlyListOf("level", builder, Letters.new(4), Fixed.new(5), Wrapped.new(__K2L_StringBuilder.new("lull")))
    local ____mod = texts.____modCount
    for ____i = 1, texts.size do
        local t = texts[____i]
        print(count(t, "l") .. " " .. describe(t))
        if texts.____modCount ~= ____mod and texts:____comodified(____i) then
            break
        end
    end
    local held = Holder.new(__K2L_StringBuilder.new("xyz"))
    for c in __K2L_Text.chars(held.text) do
        io.write(c:upper())
    end
    print()
    local ____collection = __K2L_StringToList(__K2L_CharSequenceText(held.text)):withIndex()
    local ____items, ____n = ____collection:____array()
    for ____i_1 = 1, ____n do
        local ____item = ____items[____i_1]
        local i, c = ____item.index, ____item.value
        io.write(i .. c .. " ")
    end
    print()
    for c in __K2L_Text.chars(__K2L_CharSequenceText(held.text):reverse()) do
        io.write(c)
    end
    print()
    local nullable = texts.size > 1 and builder or nil
    if nullable ~= nil then
        for c in __K2L_Text.chars(nullable) do
            io.write(c)
        end
    end
    print()
    local cs = builder
    print(tostring(__K2L_StringContains(__K2L_CharSequenceText(cs), "ell")) .. " " .. tostring(__K2L_StringStartsWith(__K2L_CharSequenceText(cs), "he")) .. " " .. __K2L_StringIndexOf(__K2L_CharSequenceText(cs), "l") .. " " .. __K2L_Text.first(__K2L_CharSequenceText(cs)) .. " " .. __K2L_Text.last(__K2L_CharSequenceText(cs)) .. " " .. __K2L_StringToList(__K2L_CharSequenceText(cs)):count(____lambda_1))
    print(tostring(__K2L_StringContains("say hello", __K2L_CharSequenceText(builder))) .. " " .. tostring(__K2L_StringStartsWith("hello world", __K2L_CharSequenceText(builder))) .. " " .. __K2L_Str(cs):upper() .. " " .. __K2L_Text.substring(__K2L_CharSequenceText(cs), 1, 3))
    print(tostring(__K2L_StringContains(__K2L_CharSequenceText(Letters.new(5)), "cd")) .. " " .. __K2L_Str(__K2L_StringToList(__K2L_CharSequenceText(Letters.new(3))):map(____lambda_2)) .. " " .. __K2L_Text.charsLength(Letters.new(6)) - 1 .. " " .. __K2L_Str(__K2L_IntRange.new(0, __K2L_Text.charsLength(Letters.new(2)) - 1)))
    local letters = __K2L_ReadOnlyListOf(Letters.new(3), Letters.new(1))
    local ____out = {}
    local ____count = 0
    local ____items_1, ____n_1 = letters:____array()
    for ____i_2 = 1, ____n_1 do
        local it = ____items_1[____i_2]
        ____count = ____count + 1
        ____out[____count] = it:getLength()
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)) .. " " .. __K2L_Str(letters))
    local growing = __K2L_StringBuilder.new("ab")
    local view = growing
    local steps = 0
    for c in __K2L_Text.chars(view) do
        if growing:getLength() < 5 then
            growing:append(c:upper())
        end
        steps = steps + 1
    end
    print(__K2L_Str(growing) .. " " .. steps)
    for c in __K2L_Text.chars(builder) do
        io.write("[" .. c .. "]")
    end
    print()
    print(maybeText(nil) .. " " .. maybeText(__K2L_StringBuilder.new("ab")) .. " " .. maybeText(""))
    local any = builder
    local ____arg = tostring(__K2L_Equals(any, builder))
    local ____arg_1 = tostring(__K2L_Equals(any, "hello"))
    local ____list = __K2L_ReadOnlyListOf("a", __K2L_StringBuilder.new("bc"))
    local ____sum = 0
    local ____items_2, ____n_2 = ____list:____array()
    for ____i_3 = 1, ____n_2 do
        local it = ____items_2[____i_3]
        ____sum = ____sum + __K2L_Text.charsLength(it)
    end
    print(____arg .. " " .. ____arg_1 .. " " .. ____sum)
end

main()
return {Letters = Letters, Fixed = Fixed, Wrapped = Wrapped, Holder = Holder, count = count, describe = describe, maybeText = maybeText}
