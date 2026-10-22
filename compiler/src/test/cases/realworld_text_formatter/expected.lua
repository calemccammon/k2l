local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringIsBlank = ____lualib.__K2L_StringIsBlank
local __K2L_StringPadEnd = ____lualib.__K2L_StringPadEnd
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringTrimEnd = ____lualib.__K2L_StringTrimEnd
local __K2L_Text = ____lualib.__K2L_Text

local function wrap(text, width)
    local lines = __K2L_ListOf()
    local line = __K2L_StringBuilder.new()
    local ____list = __K2L_Regex.new("\\s+", "%s+"):split(text)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        if not __K2L_StringIsBlank(it) then
            ____count = ____count + 1
            ____out[____count] = it
        end
    end
    local ____list_1 = __K2L_ListWrap(____out, ____count)
    for ____i_1 = 1, ____list_1.size do
        local word = ____list_1[____i_1]
        if line:isNotEmpty() and line:getLength() + 1 + #word > width then
            lines:add(line:toString())
            line:setLength(0)
        end
        if line:isNotEmpty() then
            line:append(" ")
        end
        line:append(word)
    end
    if line:isNotEmpty() then
        lines:add(line:toString())
    end
    return lines
end

local function justify(line, width)
    local words = __K2L_StringSplit(line, " ")
    if words.size == 1 then
        return __K2L_StringPadEnd(line, width)
    end
    local gaps = words.size - 1
    local ____sum = 0
    local ____items_1, ____n_1 = words:____array()
    for ____i_2 = 1, ____n_1 do
        local it = ____items_1[____i_2]
        ____sum = ____sum + #it
    end
    local spaces = width - ____sum
    local each = spaces // gaps
    local extra = spaces % gaps
    local ____builder = __K2L_StringBuilder.new()
    for ____i_3 = 1, words.size do
        local w = words[____i_3]
        local i = ____i_3 - 1
        ____builder:append(w)
        if i < gaps then
            ____builder:append(__K2L_Text.repeatCount(" ", each + (i < extra and 1 or 0)))
        end
    end
    return ____builder:toString()
end

local function center(s, width, fill)
    if fill == nil then
        fill = " "
    end
    if #s >= width then
        return s
    end
    local left = (width - #s) // 2
    return __K2L_StringPadEnd(__K2L_StringPadStart(s, #s + left, fill), width, fill)
end

local ____lambda_1 = function(it) return #it end
local function columns(items, cols, gutter)
    if gutter == nil then
        gutter = 2
    end
    local rows = (items.size + cols - 1) // cols
    local widths = __K2L_IntRange.new(0, cols - 1):map(function(c)
        return __K2L_IntRange.new(0, rows - 1):mapNotNull(function(r) return items:getOrNull(c * rows + r) end):maxOfOrNull(____lambda_1) or 0
    end)
    return __K2L_IntRange.new(0, rows - 1):joinToString("\n", nil, nil, nil, nil, function(r)
        return __K2L_StringTrimEnd(__K2L_IntRange.new(0, cols - 1):mapNotNull(function(c)
            local ____receiver = items:getOrNull(c * rows + r)
            return ____receiver and __K2L_StringPadEnd(____receiver, widths:get(c))
        end):joinToString(__K2L_Text.repeatCount(" ", gutter)))
    end)
end

local Align = __K2L_Class("Align")

function Align:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Align:toString()
    return self.name
end

function Align:compareTo(other)
    return self.ordinal - other.ordinal
end

Align.LEFT = Align.new("LEFT", 0)
Align.RIGHT = Align.new("RIGHT", 1)
Align.CENTER = Align.new("CENTER", 2)
Align.____values = {Align.LEFT, Align.RIGHT, Align.CENTER}
local Table = __K2L_Class("Table")

function Table:____init(headers, aligns)
    self.headers = headers
    self.aligns = aligns
    self.rows = __K2L_ListOf()
end

function Table:add(...)
    local cells = __K2L_ArrayOf(...)
    local ____arg = self.rows
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_2, ____n_2 = cells:____array()
    for ____i_4 = 1, ____n_2 do
        local it = ____items_2[____i_4]
        local ____result
        ____result = it and __K2L_Str(it) or "-"
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = ____result
    end
    ____arg:add(__K2L_ListWrap(____out_1, ____count_1))
end

local ____lambda_2 = function(it) return __K2L_Text.repeatCount("-", it + 2) end
function Table:render()
    local widths = self.headers:getIndices():map(function(i)
        local ____list_2 = self.rows
        local ____out_2 = {}
        local ____count_2 = 0
        local ____items_3, ____n_3 = ____list_2:____array()
        for ____i_5 = 1, ____n_3 do
            local it = ____items_3[____i_5]
            ____count_2 = ____count_2 + 1
            ____out_2[____count_2] = it:get(i)
        end
        local ____list_3 = __K2L_ListWrap(____out_2, ____count_2):plus(self.headers:get(i))
        local ____best
        local ____has = false
        local ____items_4, ____n_4 = ____list_3:____array()
        for ____i_6 = 1, ____n_4 do
            local it = ____items_4[____i_6]
            local ____key = #it
            if not ____has or ____best < ____key then
                ____best = ____key
                ____has = true
            end
        end
        if not ____has then
            error(__K2L_NoSuchElementException.new(nil))
        end
        return ____best
    end)
    local function cell(s, i)
        local ____subject = self.aligns:get(i)
        if ____subject == Align.LEFT then
            return __K2L_StringPadEnd(s, widths:get(i))
        elseif ____subject == Align.RIGHT then
            return __K2L_StringPadStart(s, widths:get(i))
        elseif ____subject == Align.CENTER then
            return center(s, widths:get(i))
        end
    end
    local sep = widths:joinToString("+", "+", "+", nil, nil, ____lambda_2)
    local sb = __K2L_StringBuilder.new(sep):append("\n")
    local ____list_4 = self.headers
    local ____out_3 = {}
    local ____count_3 = 0
    local ____items_5, ____n_5 = ____list_4:____array()
    for ____i_7 = 1, ____n_5 do
        local h = ____items_5[____i_7]
        local i = ____i_7 - 1
        ____count_3 = ____count_3 + 1
        ____out_3[____count_3] = " " .. center(h, widths:get(i)) .. " "
    end
    sb:append(__K2L_ListWrap(____out_3, ____count_3):joinToString("|", "|", "|")):append("\n")
    sb:append(__K2L_StringReplace(sep, "-", "=")):append("\n")
    local ____list_5 = self.rows
    for ____i_9 = 1, ____list_5.size do
        local r = ____list_5[____i_9]
        local ____out_4 = {}
        local ____count_4 = 0
        local ____items_6, ____n_6 = r:____array()
        for ____i_8 = 1, ____n_6 do
            local c = ____items_6[____i_8]
            local i = ____i_8 - 1
            ____count_4 = ____count_4 + 1
            ____out_4[____count_4] = " " .. cell(c, i) .. " "
        end
        sb:append(__K2L_ListWrap(____out_4, ____count_4):joinToString("|", "|", "|")):append("\n")
    end
    sb:append(sep)
    return sb:toString()
end

local LOREM = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor\nincididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation\nullamco laboris nisi ut aliquip ex ea commodo consequat."

local function formatSamples()
    local ints = __K2L_ListOf(0, 7, -7, 42, 1234567, -98765, 2147483647, -2147483648)
    for ____i_10 = 1, ints.size do
        local n = ints[____i_10]
        print(string.format("[%d] [%5d] [%-6d] [%05d] [%+d] [%s] [% d] [%x] [%X] [%o] [%#x] [%#o]", n, n, n, n, n, __K2L_Text.grouped(string.format("%d", n)), n, n, n, n, n, n))
    end
    local longs = __K2L_ListOf(0, 9007199254740991, -1, -4503599627370496, -9223372036854775807 - 1, 255)
    for ____i_11 = 1, longs.size do
        local n = longs[____i_11]
        print(string.format("%d %s %x %X %o %20d|%-20d|", n, __K2L_Text.grouped(string.format("%d", n)), n, n, n, n, n))
    end
    local doubles = __K2L_ListOf(0.0, -0.0, 0.126, 2.675, 1.005, 3.14159265358979, -1234.5678, 1.0E-7, 6.02214076E23, 999.9999, 0.6, 1.6, 2.6)
    for ____i_12 = 1, doubles.size do
        local d = doubles[____i_12]
        print(string.format("%f|%.2f|%10.3f|%-10.1f|%+.0f|%e|%.3E|%g|%s|%08.2f", d, d, d, d, d, d, d, d, __K2L_Text.grouped(string.format("%.2f", d)), d))
    end
    print(string.format("%.0f %.0f %.0f %.0f %.1f %.1f", 0.4, 1.6, 2.7, -0.4, 0.06, 0.16))
    print(string.format("%s %s %10s %-10s| %.3s %10.2s|", "text", string.upper("text"), "right", "left", "truncate", "ab"))
    print(string.format("%s %c %3s %-3s| %s %s %5s %s", "x", 65, "y", "z", tostring(not not true), string.upper(tostring(not not false)), tostring(not not nil), tostring(not not "nonnull")))
    print(string.format("%%d means decimal; 100%% done\nnext line"))
    print(string.format("[%10.4f] [%-12.6e] [%.10f]", 3.141592653589793, 2.718281828459045, 1.0 / 3))
    print(string.format("%s bytes = %s KiB = %.2f MiB", __K2L_Text.grouped(string.format("%d", 123456789)), __K2L_Text.grouped(string.format("%.1f", 123456789 / 1024.0)), 123456789 / 1048576.0))
    print(string.format("%s", __K2L_Str(__K2L_ListOf(1, 2, 3))) .. string.format(" %s", __K2L_Str(__K2L_MapOf(__K2L_Pair.new("k", 1.5)))) .. string.format(" %s", __K2L_Str(nil)))
    print(string.format("%x %x %o", -1, -255, -8))
    print(string.format("%08X %#010x %s", 48879, 48879, __K2L_Text.grouped(string.format("%+d", 1000000))))
    print(string.format("%.3g %.3g %.3g %g %g", 1.234E-4, 123456.0, 1.0, 0.0, 100000.0))
end

local function main()
    local lines = wrap(LOREM, 40)
    print(center(" Wrapped (40) ", 44, "*"))
    for ____i_13 = 1, lines.size do
        local it = lines[____i_13]
        print("|" .. __K2L_StringPadEnd(it, 40) .. "|")
    end
    print(center(" Justified ", 44, "~"))
    local ____list_6 = lines:dropLast(1)
    for ____i_14 = 1, ____list_6.size do
        local it = ____list_6[____i_14]
        print("|" .. justify(it, 40) .. "|")
    end
    print("|" .. __K2L_StringPadEnd(lines:last(), 40) .. "|")
    print(center("x", 7, ".") .. center("odd", 8, "_") .. center("toolongforit", 4))
    local ____list_7 = __K2L_Regex.new("[^A-Za-z]+", "[^A-Za-z]+"):split(LOREM)
    local ____out_5 = {}
    local ____count_5 = 0
    local ____items_7, ____n_7 = ____list_7:____array()
    for ____i_15 = 1, ____n_7 do
        local it = ____items_7[____i_15]
        if #it > 3 then
            ____count_5 = ____count_5 + 1
            ____out_5[____count_5] = it
        end
    end
    local ____list_8 = __K2L_ListWrap(____out_5, ____count_5)
    local ____out_6 = {}
    local ____count_6 = 0
    local ____items_8, ____n_8 = ____list_8:____array()
    for ____i_16 = 1, ____n_8 do
        local it = ____items_8[____i_16]
        ____count_6 = ____count_6 + 1
        ____out_6[____count_6] = it:lower()
    end
    local words = __K2L_ListWrap(____out_6, ____count_6):distinct():sorted()
    print(columns(words, 4))
    print()
    local t = Table.new(__K2L_ListOf("Item", "Qty", "Price", "Note"), __K2L_ListOf(Align.LEFT, Align.RIGHT, Align.RIGHT, Align.CENTER))
    t:add("Widget", 3, string.format("%.2f", 4.5), "ok")
    t:add("Gadget with a long name", 12, string.format("%.2f", 1234.5), nil)
    t:add("Unicode", 1, string.format("%.2f", 0.1 + 0.2), "e")
    t:add("Nothing", 0, string.format("%.2f", 0.0), "")
    print(t:render())
    formatSamples()
    local items = __K2L_ListOf(__K2L_Pair.new("coffee", 3.5), __K2L_Pair.new("bagel", 2.25), __K2L_Pair.new("orange juice", 4.0), __K2L_Pair.new("tip", 1.75))
    local ____sum_1 = 0.0
    local ____items_9, ____n_9 = items:____array()
    for ____i_17 = 1, ____n_9 do
        local it = ____items_9[____i_17]
        ____sum_1 = ____sum_1 + it.second
    end
    local total = ____sum_1
    for ____i_18 = 1, items.size do
        local ____item = items[____i_18]
        local name, price = ____item.first, ____item.second
        print(__K2L_StringPadEnd(name, 20, ".") .. string.format("$%7.2f", price))
    end
    print(("-"):rep(28))
    print(__K2L_StringPadEnd("TOTAL", 20) .. string.format("$%7.2f", total))
    print(string.format("tax 8.25%%: %.2f, grand total: %.2f", total * 0.0825, total * 1.0825))
end

__K2L_RunMain(main)
return {wrap = wrap, justify = justify, center = center, columns = columns, Align = Align, Table = Table, LOREM = LOREM, formatSamples = formatSamples}
