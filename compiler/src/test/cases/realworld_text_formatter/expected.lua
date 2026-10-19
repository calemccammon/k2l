local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IRem = ____lualib.__K2L_IRem
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
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
    local ____list = __K2L_Regex.new("\\s+"):split(text):filter(function(it) return not __K2L_StringIsBlank(it) end)
    local ____mod = ____list.____modCount
    for ____i = 1, ____list.size do
        local word = ____list[____i]
        if line:isNotEmpty() and line:getLength() + 1 + #word > width then
            lines:add(line:toString())
            line:setLength(0)
        end
        if line:isNotEmpty() then
            line:append(" ")
        end
        line:append(word)
        if ____list.____modCount ~= ____mod and ____list:____comodified(____i) then
            break
        end
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
    local spaces = width - words:sumOf(function(it) return #it end)
    local each = __K2L_IDiv(spaces, gaps)
    local extra = __K2L_IRem(spaces, gaps)
    local ____builder = __K2L_StringBuilder.new()
    do
        local ____mod_1 = words.____modCount
        for ____i_1 = 1, words.size do
            local w = words[____i_1]
            local i = ____i_1 - 1
            ____builder:append(w)
            if i < gaps then
                ____builder:append(__K2L_Text.repeatCount(" ", each + (i < extra and 1 or 0)))
            end
            if words.____modCount ~= ____mod_1 and words:____comodified(____i_1) then
                break
            end
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
    local left = __K2L_IDiv(width - #s, 2)
    return __K2L_StringPadEnd(__K2L_StringPadStart(s, #s + left, fill), width, fill)
end

local function columns(items, cols, gutter)
    if gutter == nil then
        gutter = 2
    end
    local rows = __K2L_IDiv(items.size + cols - 1, cols)
    local widths = __K2L_IntRange.new(0, cols - 1):map(function(c)
        return __K2L_IntRange.new(0, rows - 1):mapNotNull(function(r) return items:getOrNull(c * rows + r) end):maxOfOrNull(function(it) return #it end) or 0
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
    self.rows:add(cells:map(function(it) return it and __K2L_Str(it) or "-" end))
end

function Table:render()
    local widths = self.headers:getIndices():map(function(i)
        return self.rows:map(function(it) return it:get(i) end):plus(self.headers:get(i)):maxOf(function(it) return #it end)
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
    local sep = widths:joinToString("+", "+", "+", nil, nil, function(it) return __K2L_Text.repeatCount("-", it + 2) end)
    local sb = __K2L_StringBuilder.new(sep):append("\n")
    sb:append(self.headers:mapIndexed(function(i, h)
        return " " .. center(h, widths:get(i)) .. " "
    end):joinToString("|", "|", "|")):append("\n")
    sb:append(__K2L_StringReplace(sep, "-", "=")):append("\n")
    local ____list_1 = self.rows
    local ____mod_2 = ____list_1.____modCount
    for ____i_2 = 1, ____list_1.size do
        local r = ____list_1[____i_2]
        sb:append(r:mapIndexed(function(i, c) return " " .. cell(c, i) .. " " end):joinToString("|", "|", "|")):append("\n")
        if ____list_1.____modCount ~= ____mod_2 and ____list_1:____comodified(____i_2) then
            break
        end
    end
    sb:append(sep)
    return sb:toString()
end

local LOREM = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor\nincididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation\nullamco laboris nisi ut aliquip ex ea commodo consequat."

local function formatSamples()
    local ints = __K2L_ReadOnlyListOf(0, 7, -7, 42, 1234567, -98765, 2147483647, -2147483648)
    local ____mod_3 = ints.____modCount
    for ____i_3 = 1, ints.size do
        local n = ints[____i_3]
        print(__K2L_StringFormat("[%d] [%5d] [%-6d] [%05d] [%+d] [%,d] [%(d] [% d] [%x] [%X] [%o] [%#x] [%#o]", n, n, n, n, n, n, n, n, n, n, n, n, n))
        if ints.____modCount ~= ____mod_3 and ints:____comodified(____i_3) then
            break
        end
    end
    local longs = __K2L_ReadOnlyListOf(0, 9007199254740991, -1, -4503599627370496, -9223372036854775807 - 1, 255)
    local ____mod_4 = longs.____modCount
    for ____i_4 = 1, longs.size do
        local n = longs[____i_4]
        print(__K2L_StringFormat("%d %,d %x %X %o %20d|%-20d|", n, n, __K2L_Text.sized(n, 64), __K2L_Text.sized(n, 64), __K2L_Text.sized(n, 64), n, n))
        if longs.____modCount ~= ____mod_4 and longs:____comodified(____i_4) then
            break
        end
    end
    local doubles = __K2L_ReadOnlyListOf(0.0, -0.0, 0.125, 2.675, 1.005, 3.14159265358979, -1234.5678, 1.0E-7, 6.02214076E23, 999.9999, 0.5, 1.5, 2.5)
    local ____mod_5 = doubles.____modCount
    for ____i_5 = 1, doubles.size do
        local d = doubles[____i_5]
        print(__K2L_StringFormat("%f|%.2f|%10.3f|%-10.1f|%+.0f|%e|%.3E|%g|%,.2f|%08.2f|%(.1f", d, d, d, d, d, d, d, d, d, d, d))
        if doubles.____modCount ~= ____mod_5 and doubles:____comodified(____i_5) then
            break
        end
    end
    print(__K2L_StringFormat("%.0f %.0f %.0f %.0f %.1f %.1f", 0.5, 1.5, 2.5, -0.5, 0.05, 0.15))
    print(__K2L_StringFormat("%s %S %10s %-10s| %.3s %10.2s|", "text", "text", "right", "left", "truncate", "ab"))
    print(__K2L_StringFormat("%c %c %3c %-3c| %b %B %5b %b", "x", 65, "y", "z", true, false, nil, "nonnull"))
    print(__K2L_StringFormat("%2$s %1$s %2$s %<s %s %s", "a", "b"))
    print(__K2L_StringFormat("%%d means decimal; 100%% done%nnext line"))
    print(__K2L_StringFormat("%h %h %H", "hello", 42, "Kotlin"))
    print(__K2L_StringFormat("[%10.4f] [%-12.6e] [%.10f]", 3.141592653589793, 2.718281828459045, 1.0 / 3))
    print(__K2L_StringFormat("%,d bytes = %,.1f KiB = %.2f MiB", 123456789, 123456789 / 1024.0, 123456789 / 1048576.0))
    print(__K2L_StringFormat("%s", __K2L_ReadOnlyListOf(1, 2, 3)) .. __K2L_StringFormat(" %s", __K2L_SingletonMapOf(__K2L_Pair.new("k", 1.5))) .. __K2L_StringFormat(" %s", nil))
    print(__K2L_StringFormat("%x %x %o", -1, -255, -8))
    print(__K2L_StringFormat("%08X %#010x %+,d", 48879, 48879, 1000000))
    print(__K2L_StringFormat("%.3g %.3g %.3g %g %g", 1.234E-4, 123456.0, 1.0, 0.0, 100000.0))
end

local function main()
    local lines = wrap(LOREM, 40)
    print(center(" Wrapped (40) ", 44, "*"))
    local ____mod_6 = lines.____modCount
    for ____i_6 = 1, lines.size do
        local it = lines[____i_6]
        print("|" .. __K2L_StringPadEnd(it, 40) .. "|")
        if lines.____modCount ~= ____mod_6 and lines:____comodified(____i_6) then
            break
        end
    end
    print(center(" Justified ", 44, "~"))
    local ____list_2 = lines:dropLast(1)
    local ____mod_7 = ____list_2.____modCount
    for ____i_7 = 1, ____list_2.size do
        local it = ____list_2[____i_7]
        print("|" .. justify(it, 40) .. "|")
        if ____list_2.____modCount ~= ____mod_7 and ____list_2:____comodified(____i_7) then
            break
        end
    end
    print("|" .. __K2L_StringPadEnd(lines:last(), 40) .. "|")
    print(center("x", 7, ".") .. center("odd", 8, "_") .. center("toolongforit", 4))
    local words = __K2L_Regex.new("[^A-Za-z]+"):split(LOREM):filter(function(it) return #it > 3 end):map(function(it) return it:lower() end):distinct():sorted()
    print(columns(words, 4))
    print()
    local t = Table.new(__K2L_ReadOnlyListOf("Item", "Qty", "Price", "Note"), __K2L_ReadOnlyListOf(Align.LEFT, Align.RIGHT, Align.RIGHT, Align.CENTER))
    t:add("Widget", 3, __K2L_StringFormat("%.2f", 4.5), "ok")
    t:add("Gadget with a long name", 12, __K2L_StringFormat("%.2f", 1234.5), nil)
    t:add("Unicode", 1, __K2L_StringFormat("%.2f", 0.1 + 0.2), "e")
    t:add("Nothing", 0, __K2L_StringFormat("%.2f", 0.0), "")
    print(t:render())
    formatSamples()
    local items = __K2L_ReadOnlyListOf(__K2L_Pair.new("coffee", 3.5), __K2L_Pair.new("bagel", 2.25), __K2L_Pair.new("orange juice", 4.0), __K2L_Pair.new("tip", 1.75))
    local total = items:sumOf(function(it) return it.second end, 0.0)
    local ____mod_8 = items.____modCount
    for ____i_8 = 1, items.size do
        local ____item = items[____i_8]
        local name, price = ____item.first, ____item.second
        print(__K2L_StringPadEnd(name, 20, ".") .. __K2L_StringFormat("$%7.2f", price))
        if items.____modCount ~= ____mod_8 and items:____comodified(____i_8) then
            break
        end
    end
    print(("-"):rep(28))
    print(__K2L_StringPadEnd("TOTAL", 20) .. __K2L_StringFormat("$%7.2f", total))
    print(__K2L_StringFormat("tax 8.25%%: %.2f, grand total: %.2f", total * 0.0825, total * 1.0825))
end

main()
return {wrap = wrap, justify = justify, center = center, columns = columns, Align = Align, Table = Table, LOREM = LOREM, formatSamples = formatSamples}
