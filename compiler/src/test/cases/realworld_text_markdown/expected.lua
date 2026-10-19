local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_FunctionRef = ____lualib.__K2L_FunctionRef
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringCharAt = ____lualib.__K2L_StringCharAt
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
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32

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

local function inline(text)
    local codes = __K2L_ListOf()
    local s = CODE_SPAN:replace(text, function(m)
        codes:add("<code>" .. escapeHtml(m.groupValues:get(1)) .. "</code>")
        return "\000" .. codes.size - 1 .. "\000"
    end)
    s = AUTOLINK:replace(s, function(it)
        return "<a href=\"" .. it.groupValues:get(1) .. "\">" .. it.groupValues:get(1) .. "</a>"
    end)
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
    s = EM:replace(s, function(m)
        return "<em>" .. __K2L_NotNull(m.groups:get(1) or m.groups:get(2)).value .. "</em>"
    end)
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

function Heading:toString()
    return "Heading(level=" .. self.level .. ", text=" .. self.text .. ", id=" .. self.id .. ")"
end

function Heading:hashCode()
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.level) + __K2L_Hash(self.text)) + __K2L_Hash(self.id))
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

function Converter:uniqueId(base)
    local n = __K2L_NotNull(self.usedIds:merge(base, 1, __K2L_FunctionRef.new("plus", "kotlin/Int.plus(kotlin.Int)", function(____p1, ____p2) return ____p1 + ____p2 end)))
    return n == 1 and base or base .. "-" .. n - 1
end

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
            local level = #__K2L_Text.takeWhile(line, function(it) return it == "#" end)
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
                return __K2L_StringSplit(__K2L_Text.removeSuffix(__K2L_Text.removePrefix(__K2L_StringTrim(row), "|"), "|"), "|"):map(function(it) return __K2L_StringTrim(it) end)
            end
            local header = cells(line)
            local aligns = cells(lines:get(i + 1)):map(function(it)
                if __K2L_StringStartsWith(it, ":") and __K2L_StringEndsWith(it, ":") then
                    return " style=\"text-align:center\""
                elseif __K2L_StringEndsWith(it, ":") then
                    return " style=\"text-align:right\""
                else
                    return ""
                end
            end)
            i = i + 2
            self.out:append("<table>\n<tr>")
            local ____mod = header.____modCount
            for ____i = 1, header.size do
                local h = header[____i]
                local c = ____i - 1
                self.out:append("<th" .. aligns:getOrElse(c, function(it) return "" end) .. ">" .. inline(h) .. "</th>")
                if header.____modCount ~= ____mod and header:____comodified(____i) then
                    break
                end
            end
            self.out:append("</tr>\n")
            while i < lines.size and __K2L_StringContains(lines:get(i), "|") do
                self.out:append("<tr>")
                local ____list = cells(lines:get(i))
                local ____mod_1 = ____list.____modCount
                for ____i_1 = 1, ____list.size do
                    local v = ____list[____i_1]
                    local c = ____i_1 - 1
                    self.out:append("<td" .. aligns:getOrElse(c, function(it) return "" end) .. ">" .. inline(v) .. "</td>")
                    if ____list.____modCount ~= ____mod_1 and ____list:____comodified(____i_1) then
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
                start = __K2L_StringToInt(__K2L_Text.takeWhile(__K2L_StringTrim(line), function(it) return it:match("^%d$") ~= nil end))
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
                elseif __K2L_StringCharAt(check, 1) == " " then
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

local function toc(headings)
    local ____builder = __K2L_StringBuilder.new()
    do
        local minLevel = headings:minOfOrNull(function(it) return it.level end) or 1
        local ____mod_2 = headings.____modCount
        for ____i_2 = 1, headings.size do
            local h = headings[____i_2]
            ____builder:append(__K2L_Text.repeatCount("  ", h.level - minLevel)):append("- ["):append(h.text):append("](#"):append(h.id):append(")\n")
            if headings.____modCount ~= ____mod_2 and headings:____comodified(____i_2) then
                break
            end
        end
    end
    return ____builder:toString()
end

local DOCUMENT = __K2L_Text.trimIndent("\n# k2l *Guide*\n\nWelcome to **k2l**, a _Kotlin_ to Lua transpiler. See <https://example.org/k2l> or [the docs](https://example.org/docs).\nUse `x < y && y > z` freely; it's ~~not~~ escaped.\nSecond line after a hard break.\n\n## Installing\n\n1. Download the archive\n2. Unpack it to `~/opt`\n3. Add **bin** to `PATH`\n\n## Features & Limits\n\n- [x] classes and *objects*\n- [ ] reflection beyond the __basics__\n* plain item with an ![logo](img/logo.png \"The Logo\") inside\n\n> Note: quotes can contain **markup**\n> and span lines.\n>\n> # Even headings\n\n| Feature | Status | Since |\n|:--------|:------:|------:|\n| Regex   | done   | 0.1 |\n| Streams | `partial` | 0.2 |\n\n```kotlin\nfun main() = println(\"<hello>\")\n```\n\n***\n\n## Installing\n\n5) fifth\n6) sixth\n\nSnake_case_words and 2*3*4 should stay as they are, but *this* is emphasis.\n")

local function main()
    local c = Converter.new()
    local html = c:convert(DOCUMENT)
    io.write(html)
    print("---- toc ----")
    io.write(toc(c.headings))
    local words = __K2L_Regex.new("\\W+"):split(__K2L_Regex.new("<[^>]+>"):replace(html, " ")):filter(function(it) return #it > 0 end)
    print("words: " .. words.size .. ", distinct: " .. words:map(function(it) return it:lower() end):toSet().size)
    print("tags: " .. __K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("<(\\w+)"):findAllFactory(html)):groupingBy(function(it) return it.groupValues:get(1) end):eachCount():toSortedMap()))
end

main()
return {escapeHtml = escapeHtml, slug = slug, inline = inline, Heading = Heading, Converter = Converter, toc = toc, DOCUMENT = DOCUMENT}
