local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_FunctionRef = ____lualib.__K2L_FunctionRef
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringEndsWith = ____lualib.__K2L_StringEndsWith
local __K2L_StringIsBlank = ____lualib.__K2L_StringIsBlank
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_StringTrimStart = ____lualib.__K2L_StringTrimStart
local __K2L_Text = ____lualib.__K2L_Text

local function escapeHtml(s)
    return __K2L_StringReplace(__K2L_StringReplace(__K2L_StringReplace(__K2L_StringReplace(s, "&", "&amp;"), "<", "&lt;"), ">", "&gt;"), "\"", "&quot;")
end

local function slug(text)
    return __K2L_Regex.new("\\s+"):replace(__K2L_StringTrim(__K2L_Regex.new("[^a-z0-9\\s-]"):replace(text:lower(), "")), "-")
end

local CODE_SPAN = __K2L_Regex.new("`([^`]+)`")
local IMAGE = __K2L_Regex.new("!\\[([^\\]]*)]\\(([^)\\s]+)(?:\\s+\"([^\"]*)\")?\\)")
local LINK = __K2L_Regex.new("\\[([^\\]]+)]\\(([^)\\s]+)\\)")
local STRONG = __K2L_Regex.new("\\*\\*(.+?)\\*\\*|__(.+?)__")
local EM = __K2L_Regex.new("(?<![*\\w])\\*(?!\\s)(.+?)(?<!\\s)\\*(?!\\*)|(?<!\\w)_(.+?)_(?!\\w)")
local AUTOLINK = __K2L_Regex.new("<(https?://[^>]+)>")
local STRIKE = __K2L_Regex.new("~~(.+?)~~")

local ____lambda_1 = function(it)
    return "<a href=\"" .. it.groupValues:get(1) .. "\">" .. it.groupValues:get(1) .. "</a>"
end
local ____lambda_2 = function(m)
    return "<em>" .. __K2L_NotNull(m.groups:get(1) or m.groups:get(2)).value .. "</em>"
end
local function inline(text)
    local codes = __K2L_ListOf()
    local s = CODE_SPAN:replace(text, function(m)
        codes:add("<code>" .. escapeHtml(m.groupValues:get(1)) .. "</code>")
        return "\000" .. codes.size - 1 .. "\000"
    end)
    s = AUTOLINK:replace(s, ____lambda_1)
    s = __K2L_StringReplace(__K2L_StringReplace(__K2L_StringReplace(escapeHtml(s), "&lt;a href=&quot;", "<a href=\""), "&quot;&gt;", "\">"), "&lt;/a&gt;", "</a>")
    s = IMAGE:replace(s, function(m)
        local ____destructured = m.destructured
        local alt, src, title = ____destructured[1], ____destructured[2], ____destructured[3]
        return "<img src=\"" .. src .. "\" alt=\"" .. alt .. "\"" .. (#title > 0 and " title=\"" .. title .. "\"" or "") .. ">"
    end)
    s = LINK:replace(s, "<a href=\"$2\">$1</a>")
    s = STRONG:replace(s, function(m)
        local ____receiver = m.groups:get(1)
        return "<strong>" .. (____receiver and ____receiver.value or __K2L_NotNull(m.groups:get(2)).value) .. "</strong>"
    end)
    s = EM:replace(s, ____lambda_2)
    s = STRIKE:replace(s, "<del>$1</del>")
    return __K2L_Regex.new("\000(\\d+)\000"):replace(s, function(it)
        return codes:get(__K2L_StringToInt(it.groupValues:get(1)))
    end)
end

local Heading = __K2L_Class("Heading")

function Heading:____init(level, text, id)
    self.level = level
    self.text = text
    self.id = id
end

function Heading.new(level, text, id)
    return setmetatable({level = level, text = text, id = id}, Heading)
end

function Heading:toString()
    return "Heading(level=" .. self.level .. ", text=" .. self.text .. ", id=" .. self.id .. ")"
end

function Heading:hashCode()
    return (31 * (31 * self.level + __K2L_Hash(self.text)) + __K2L_Hash(self.id) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Heading:equals(other)
    return getmetatable(other) == Heading and self.level == other.level and self.text == other.text and self.id == other.id
end

local Converter = __K2L_Class("Converter")

function Converter:____init()
    self.headings = __K2L_ListOf()
    self.out = __K2L_StringBuilder.new()
    self.usedIds = __K2L_HashMap.new()
end

local ____lambda_3 = function(____p1, ____p2) return ____p1 + ____p2 end
function Converter:uniqueId(base)
    local n = __K2L_NotNull(self.usedIds:merge(base, 1, __K2L_FunctionRef.new("plus", "kotlin/Int.plus(kotlin.Int)", ____lambda_3)))
    return n == 1 and base or base .. "-" .. n - 1
end

local ____lambda_4 = function(it) return it == "#" end
local ____lambda_5 = function(it) return "" end
local ____lambda_6 = function(it) return "" end
local ____lambda_7 = function(it) return it:match("^%d$") ~= nil end
function Converter:convert(md)
    local lines = __K2L_StringLines(md)
    local i = 0
    while i < lines.size do
        local line = lines:get(i)
        if __K2L_StringIsBlank(line) then
            i = i + 1
        elseif __K2L_StringStartsWith(line, "```") then
            local lang = __K2L_StringTrim(__K2L_Text.removePrefix(line, "```"))
            local body = __K2L_ListOf()
            i = i + 1
            while i < lines.size and not __K2L_StringStartsWith(lines:get(i), "```") do
                local ____old_2 = i
                i = i + 1
                body:add(lines:get(____old_2))
            end
            i = i + 1
            local cls = #lang == 0 and "" or " class=\"language-" .. lang .. "\""
            self.out:append("<pre><code" .. cls .. ">"):append(escapeHtml(body:joinToString("\n"))):append("</code></pre>\n")
        elseif __K2L_Regex.new("^#{1,6} "):containsMatchIn(line) then
            local level = #__K2L_Text.takeWhile(line, ____lambda_4)
            local text = __K2L_StringTrim(__K2L_Text.trimChars(__K2L_StringTrim(__K2L_Text.drop(line, level)), 2, "#"))
            local id = self:uniqueId(slug(text))
            self.headings:add(Heading.new(level, text, id))
            self.out:append("<h" .. level .. " id=\"" .. id .. "\">" .. inline(text) .. "</h" .. level .. ">\n")
            i = i + 1
        elseif __K2L_Regex.new("^(\\*\\s*){3,}$|^(-\\s*){3,}$"):matches(line) then
            self.out:append("<hr>\n")
            i = i + 1
        elseif __K2L_StringStartsWith(line, ">") then
            local quoted = __K2L_ListOf()
            while i < lines.size and __K2L_StringStartsWith(lines:get(i), ">") do
                local ____old_1 = i
                i = i + 1
                quoted:add(__K2L_Text.removePrefix(__K2L_Text.removePrefix(lines:get(____old_1), ">"), " "))
            end
            self.out:append("<blockquote>\n"):append(Converter.new():convert(quoted:joinToString("\n"))):append("</blockquote>\n")
        elseif __K2L_StringContains(line, "|") and i + 1 < lines.size and __K2L_Regex.new("^\\s*\\|?\\s*:?-+:?\\s*(\\|\\s*:?-+:?\\s*)*\\|?\\s*$"):matches(lines:get(i + 1)) then
            local function cells(row)
                local ____list = __K2L_StringSplit(__K2L_Text.removeSuffix(__K2L_Text.removePrefix(__K2L_StringTrim(row), "|"), "|"), "|")
                local ____out = {}
                local ____count = 0
                local ____items, ____n = ____list:____array()
                for ____i = 1, ____n do
                    local it = ____items[____i]
                    ____count = ____count + 1
                    ____out[____count] = __K2L_StringTrim(it)
                end
                return __K2L_ListWrap(____out, ____count)
            end
            local header = cells(line)
            local ____list_1 = cells(lines:get(i + 1))
            local ____out_1 = {}
            local ____count_1 = 0
            local ____items_1, ____n_1 = ____list_1:____array()
            for ____i_1 = 1, ____n_1 do
                local it = ____items_1[____i_1]
                local ____result
                if __K2L_StringStartsWith(it, ":") and __K2L_StringEndsWith(it, ":") then
                    ____result = " style=\"text-align:center\""
                elseif __K2L_StringEndsWith(it, ":") then
                    ____result = " style=\"text-align:right\""
                else
                    ____result = ""
                end
                ____count_1 = ____count_1 + 1
                ____out_1[____count_1] = ____result
            end
            local aligns = __K2L_ListWrap(____out_1, ____count_1)
            i = i + 2
            self.out:append("<table>\n<tr>")
            local ____mod = header.____modCount
            for ____i_2 = 1, header.size do
                local h = header[____i_2]
                local c = ____i_2 - 1
                self.out:append("<th" .. aligns:getOrElse(c, ____lambda_5) .. ">" .. inline(h) .. "</th>")
                if header.____modCount ~= ____mod and header:____comodified(____i_2) then
                    break
                end
            end
            self.out:append("</tr>\n")
            while i < lines.size and __K2L_StringContains(lines:get(i), "|") do
                self.out:append("<tr>")
                local ____list_2 = cells(lines:get(i))
                local ____mod_1 = ____list_2.____modCount
                for ____i_3 = 1, ____list_2.size do
                    local v = ____list_2[____i_3]
                    local c = ____i_3 - 1
                    self.out:append("<td" .. aligns:getOrElse(c, ____lambda_6) .. ">" .. inline(v) .. "</td>")
                    if ____list_2.____modCount ~= ____mod_1 and ____list_2:____comodified(____i_3) then
                        break
                    end
                end
                self.out:append("</tr>\n")
                i = i + 1
            end
            self.out:append("</table>\n")
        elseif __K2L_Regex.new("^\\s*([-*+]|\\d+[.)]) "):find(line) ~= nil then
            local ordered = __K2L_Text.first(__K2L_StringTrimStart(line)):match("^%d$") ~= nil
            local start
            if ordered then
                start = __K2L_StringToInt(__K2L_Text.takeWhile(__K2L_StringTrim(line), ____lambda_7))
            else
                start = 1
            end
            local tag = ordered and "ol" or "ul"
            self.out:append(ordered and start ~= 1 and "<ol start=\"" .. start .. "\">\n" or "<" .. tag .. ">\n")
            local item = __K2L_Regex.new("^\\s*(?:[-*+]|\\d+[.)]) (\\[[ xX]] )?(.*)$")
            while i < lines.size do
                local ____value = item:matchEntire(lines:get(i))
                if ____value == nil then
                    break
                end
                local m = ____value
                local check = m.groupValues:get(1)
                local box
                if #check == 0 then
                    box = ""
                elseif (1 >= 0 and 1 < #check and check:sub(1 + 1, 1 + 1) or __K2L_IndexError(1, #check, "string")) == " " then
                    box = "<input type=\"checkbox\" disabled> "
                else
                    box = "<input type=\"checkbox\" checked disabled> "
                end
                self.out:append("  <li>"):append(box):append(inline(m.groupValues:get(2))):append("</li>\n")
                i = i + 1
            end
            self.out:append("</" .. tag .. ">\n")
        else
            local para = __K2L_ListOf()
            while i < lines.size and not __K2L_StringIsBlank(lines:get(i)) and not __K2L_StringStartsWith(lines:get(i), "#") and not __K2L_StringStartsWith(lines:get(i), "```") and not __K2L_StringStartsWith(lines:get(i), ">") do
                local ____old = i
                i = i + 1
                para:add(__K2L_StringTrim(lines:get(____old)))
            end
            local joined = __K2L_Regex.new(" {2,}\n"):replace(para:joinToString("\n"), "<br>\n")
            self.out:append("<p>"):append(inline(joined)):append("</p>\n")
        end
    end
    return self.out:toString()
end

local ____lambda_8 = function(it) return it.level end
local function toc(headings)
    local ____builder = __K2L_StringBuilder.new()
    do
        local minLevel = headings:minOfOrNull(____lambda_8) or 1
        local ____mod_2 = headings.____modCount
        for ____i_4 = 1, headings.size do
            local h = headings[____i_4]
            ____builder:append(__K2L_Text.repeatCount("  ", h.level - minLevel)):append("- ["):append(h.text):append("](#"):append(h.id):append(")\n")
            if headings.____modCount ~= ____mod_2 and headings:____comodified(____i_4) then
                break
            end
        end
    end
    return ____builder:toString()
end

local DOCUMENT = __K2L_Text.trimIndent("\n# k2l *Guide*\n\nWelcome to **k2l**, a _Kotlin_ to Lua transpiler. See <https://example.org/k2l> or [the docs](https://example.org/docs).\nUse `x < y && y > z` freely; it's ~~not~~ escaped.\nSecond line after a hard break.\n\n## Installing\n\n1. Download the archive\n2. Unpack it to `~/opt`\n3. Add **bin** to `PATH`\n\n## Features & Limits\n\n- [x] classes and *objects*\n- [ ] reflection beyond the __basics__\n* plain item with an ![logo](img/logo.png \"The Logo\") inside\n\n> Note: quotes can contain **markup**\n> and span lines.\n>\n> # Even headings\n\n| Feature | Status | Since |\n|:--------|:------:|------:|\n| Regex   | done   | 0.1 |\n| Streams | `partial` | 0.2 |\n\n```kotlin\nfun main() = println(\"<hello>\")\n```\n\n***\n\n## Installing\n\n5) fifth\n6) sixth\n\nSnake_case_words and 2*3*4 should stay as they are, but *this* is emphasis.\n")

local ____lambda_9 = function(it) return it.groupValues:get(1) end
local function main()
    local c = Converter.new()
    local html = c:convert(DOCUMENT)
    io.write(html)
    print("---- toc ----")
    io.write(toc(c.headings))
    local ____list_3 = __K2L_Regex.new("\\W+"):split(__K2L_Regex.new("<[^>]+>"):replace(html, " "))
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_2, ____n_2 = ____list_3:____array()
    for ____i_5 = 1, ____n_2 do
        local it = ____items_2[____i_5]
        if #it > 0 then
            ____count_2 = ____count_2 + 1
            ____out_2[____count_2] = it
        end
    end
    local words = __K2L_ListWrap(____out_2, ____count_2)
    local ____arg = words.size
    local ____out_3 = {}
    local ____count_3 = 0
    local ____items_3, ____n_3 = words:____array()
    for ____i_6 = 1, ____n_3 do
        local it = ____items_3[____i_6]
        ____count_3 = ____count_3 + 1
        ____out_3[____count_3] = it:lower()
    end
    print("words: " .. ____arg .. ", distinct: " .. __K2L_ListWrap(____out_3, ____count_3):toSet().size)
    print("tags: " .. __K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("<(\\w+)"):findAllFactory(html)):groupingBy(____lambda_9):eachCount():toSortedMap()))
end

main()
return {escapeHtml = escapeHtml, slug = slug, inline = inline, Heading = Heading, Converter = Converter, toc = toc, DOCUMENT = DOCUMENT}
