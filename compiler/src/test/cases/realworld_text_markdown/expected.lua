local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_IsDigit = ____lualib.__K2L_IsDigit
local __K2L_IsLetterOrDigit = ____lualib.__K2L_IsLetterOrDigit
local __K2L_IsWhitespace = ____lualib.__K2L_IsWhitespace
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StrByte = ____lualib.__K2L_StrByte
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringEndsWith = ____lualib.__K2L_StringEndsWith
local __K2L_StringIsBlank = ____lualib.__K2L_StringIsBlank
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_StringTrimStart = ____lualib.__K2L_StringTrimStart
local __K2L_Text = ____lualib.__K2L_Text

local emphasis

local function escapeHtml(s)
    return __K2L_StringReplace(__K2L_StringReplace(__K2L_StringReplace(__K2L_StringReplace(s, "&", "&amp;"), "<", "&lt;"), ">", "&gt;"), "\"", "&quot;")
end

local function slug(text)
    return __K2L_Regex.new("\\s+", "%s+"):replace(__K2L_StringTrim(__K2L_Regex.new("[^a-z0-9\\s-]", "[^%sa-z0-9%-]"):replace(text:lower(), "")), "-")
end

local CODE_SPAN = __K2L_Regex.new("`([^`]+)`", "`([^%`]+)`")
local IMAGE = __K2L_Regex.new("!\\[([^\\]]*)]\\(([^)\\s]+)\\)", "!%[([^%]]*)%]%(([^%s%)]+)%)")
local LINK = __K2L_Regex.new("\\[([^\\]]+)]\\(([^)\\s]+)\\)", "%[([^%]]+)%]%(([^%s%)]+)%)")
local STRONG = __K2L_ListOf(__K2L_Regex.new("\\*\\*(.+?)\\*\\*", "%*%*([^\n\r][^\n\r]-)%*%*"), __K2L_Regex.new("__(.+?)__", "__([^\n\r][^\n\r]-)__"))
local EM = __K2L_ListOf(__K2L_Regex.new("\\*(\\S[^*]*)\\*", "%*(%S[^%*]*)%*"), __K2L_Regex.new("_([^_]+)_", "_([^_]+)_"))
local AUTOLINK = __K2L_Regex.new("<(https?://[^>]+)>", "<(https?://[^%>]+)>")
local STRIKE = __K2L_Regex.new("~~(.+?)~~", "~~([^\n\r][^\n\r]-)~~")

local ____lambda_1 = function(it)
    return "<a href=\"" .. it.groupValues:get(1) .. "\">" .. it.groupValues:get(1) .. "</a>"
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
        local alt, src = ____destructured[1], ____destructured[2]
        return "<img src=\"" .. src .. "\" alt=\"" .. alt .. "\">"
    end)
    s = LINK:replace(s, "<a href=\"$2\">$1</a>")
    local ____list = STRONG
    for ____i = 1, ____list.size do
        local strong = ____list[____i]
        s = strong:replace(s, "<strong>$1</strong>")
    end
    local ____list_1 = EM
    for ____i_1 = 1, ____list_1.size do
        local em = ____list_1[____i_1]
        s = emphasis(s, em)
    end
    s = STRIKE:replace(s, "<del>$1</del>")
    return __K2L_Regex.new("\000(\\d+)\000", "%z(%d+)%z"):replace(s, function(it)
        return codes:get(__K2L_StringToInt(it.groupValues:get(1)))
    end)
end

local function isWordChar(c)
    return c ~= nil and (__K2L_IsLetterOrDigit[c] == true or c == "_")
end

function emphasis(s, em)
    return em:replace(s, function(m)
        local mark = 0 >= 0 and 0 < #m.value and m.value:sub(0 + 1, 0 + 1) or __K2L_IndexError(0, #m.value, "string")
        local before = __K2L_Text.getOrNull(s, m.range.first - 1)
        local after = __K2L_Text.getOrNull(s, m.range.last + 1)
        local body = m.groupValues:get(1)
        local inWord = isWordChar(before) or before == mark or after == mark or mark == "_" and isWordChar(after)
        return (inWord or __K2L_IsWhitespace[__K2L_Text.last(body)] == true) and m.value or "<em>" .. body .. "</em>"
    end)
end

local function isRule(line)
    local ____list_2 = __K2L_ListOf("*", "-")
    local ____result = false
    local ____items, ____n = ____list_2:____array()
    for ____i_2 = 1, ____n do
        local c = ____items[____i_2]
        local ____result_1
        ____result_1 = __K2L_StringToList(line):firstOrNull() == c and __K2L_StringToList(line):count(function(it) return it == c end) >= 3 and __K2L_StringToList(line):all(function(it)
            return it == c or __K2L_IsWhitespace[it] == true
        end)
        if ____result_1 then
            ____result = true
            break
        end
    end
    return ____result
end

local SEPARATOR_CELL = __K2L_Regex.new(":?-+:?", ":?%-+:?")

local function isSeparator(row)
    local ____list_3 = __K2L_StringSplit(__K2L_Text.removeSuffix(__K2L_Text.removePrefix(__K2L_StringTrim(row), "|"), "|"), "|")
    local ____result_2 = true
    local ____items_1, ____n_1 = ____list_3:____array()
    for ____i_3 = 1, ____n_1 do
        local it = ____items_1[____i_3]
        if not SEPARATOR_CELL:matches(__K2L_StringTrim(it)) then
            ____result_2 = false
            break
        end
    end
    return ____result_2
end

local BULLET = __K2L_Regex.new("^\\s*[-*+] (.*)$", "^%s*[%-%*%+] ([^\n\r]*)$")
local NUMBERED = __K2L_Regex.new("^\\s*\\d+[.)] (.*)$", "^%s*%d+[%.%)] ([^\n\r]*)$")
local CHECKBOX = __K2L_Regex.new("^\\[[ xX]] ", "^%[[ xX]%] ")

local function listItem(line)
    local ____receiver = BULLET:matchEntire(line) or NUMBERED:matchEntire(line)
    local ____receiver_1 = ____receiver and (BULLET:matchEntire(line) or NUMBERED:matchEntire(line)).groupValues
    return ____receiver_1 and ____receiver_1:get(1)
end

local Heading = __K2L_Class("Heading")

function Heading.new(level, text, id)
    return setmetatable({level = level, text = text, id = id}, Heading)
end

__K2L_DataClass(Heading, {"level", "text", "id"})
local Converter = __K2L_Class("Converter")

local ____lambda_2 = function(____p1, ____p2) return ____p1 + ____p2 end
local function uniqueId(self, base)
    local n = __K2L_NotNull(self.usedIds:merge(base, 1, ____lambda_2))
    return n == 1 and base or base .. "-" .. n - 1
end

function Converter:____init()
    self.headings = __K2L_ListOf()
    self.out = __K2L_StringBuilder.new()
    self.usedIds = __K2L_Map.new()
end

local ____lambda_3 = function(it) return it == "#" end
local ____lambda_4 = function(it) return "" end
local ____lambda_5 = function(it) return "" end
local ____lambda_6 = function(it) return __K2L_IsDigit[it] == true end
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
        elseif __K2L_Regex.new("^#{1,6} ", "^##?#?#?#?#? "):containsMatchIn(line) then
            local level = #__K2L_Text.takeWhile(line, ____lambda_3)
            local text = __K2L_StringTrim(__K2L_Text.trimChars(__K2L_StringTrim(__K2L_Text.drop(line, level)), 2, "#"))
            local id = uniqueId(self, slug(text))
            self.headings:add(Heading.new(level, text, id))
            self.out:append("<h" .. level .. " id=\"" .. id .. "\">" .. inline(text) .. "</h" .. level .. ">\n")
            i = i + 1
        elseif isRule(line) then
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
        elseif __K2L_StringContains(line, "|") and i + 1 < lines.size and isSeparator(lines:get(i + 1)) then
            local function cells(row)
                local ____list_4 = __K2L_StringSplit(__K2L_Text.removeSuffix(__K2L_Text.removePrefix(__K2L_StringTrim(row), "|"), "|"), "|")
                local ____out = {}
                local ____count = 0
                local ____items_2, ____n_2 = ____list_4:____array()
                for ____i_4 = 1, ____n_2 do
                    local it = ____items_2[____i_4]
                    ____count = ____count + 1
                    ____out[____count] = __K2L_StringTrim(it)
                end
                return __K2L_ListWrap(____out, ____count)
            end
            local header = cells(line)
            local ____list_5 = cells(lines:get(i + 1))
            local ____out_1 = {}
            local ____count_1 = 0
            local ____items_3, ____n_3 = ____list_5:____array()
            for ____i_5 = 1, ____n_3 do
                local it = ____items_3[____i_5]
                local ____result_3
                if __K2L_StringStartsWith(it, ":") and __K2L_StringEndsWith(it, ":") then
                    ____result_3 = " style=\"text-align:center\""
                elseif __K2L_StringEndsWith(it, ":") then
                    ____result_3 = " style=\"text-align:right\""
                else
                    ____result_3 = ""
                end
                ____count_1 = ____count_1 + 1
                ____out_1[____count_1] = ____result_3
            end
            local aligns = __K2L_ListWrap(____out_1, ____count_1)
            i = i + 2
            self.out:append("<table>\n<tr>")
            for ____i_6 = 1, header.size do
                local h = header[____i_6]
                local c = ____i_6 - 1
                self.out:append("<th" .. aligns:getOrElse(c, ____lambda_4) .. ">" .. inline(h) .. "</th>")
            end
            self.out:append("</tr>\n")
            while i < lines.size and __K2L_StringContains(lines:get(i), "|") do
                self.out:append("<tr>")
                local ____list_6 = cells(lines:get(i))
                for ____i_7 = 1, ____list_6.size do
                    local v = ____list_6[____i_7]
                    local c = ____i_7 - 1
                    self.out:append("<td" .. aligns:getOrElse(c, ____lambda_5) .. ">" .. inline(v) .. "</td>")
                end
                self.out:append("</tr>\n")
                i = i + 1
            end
            self.out:append("</table>\n")
        elseif listItem(line) ~= nil then
            local ordered = __K2L_IsDigit[__K2L_Text.first(__K2L_StringTrimStart(line))] == true
            local start
            if ordered then
                start = __K2L_StringToInt(__K2L_Text.takeWhile(__K2L_StringTrim(line), ____lambda_6))
            else
                start = 1
            end
            local tag = ordered and "ol" or "ul"
            self.out:append(ordered and start ~= 1 and "<ol start=\"" .. start .. "\">\n" or "<" .. tag .. ">\n")
            while i < lines.size do
                local ____value = listItem(lines:get(i))
                if ____value == nil then
                    break
                end
                local text = ____value
                local ____receiver_2 = CHECKBOX:find(text)
                local check = ____receiver_2 and ____receiver_2.value or ""
                local box
                if #check == 0 then
                    box = ""
                elseif (1 >= 0 and __K2L_StrByte(check, 1 + 1) or __K2L_IndexError(1, #check, "string")) == 32 then
                    box = "<input type=\"checkbox\" disabled> "
                else
                    box = "<input type=\"checkbox\" checked disabled> "
                end
                self.out:append("  <li>"):append(box):append(inline(__K2L_Text.removePrefix(text, check))):append("</li>\n")
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
            local joined = __K2L_Regex.new(" {2,}\n", "   *\n"):replace(para:joinToString("\n"), "<br>\n")
            self.out:append("<p>"):append(inline(joined)):append("</p>\n")
        end
    end
    return self.out:toString()
end

local ____lambda_7 = function(it) return it.level end
local function toc(headings)
    local ____builder = __K2L_StringBuilder.new()
    do
        local minLevel = headings:minOfOrNull(____lambda_7) or 1
        for ____i_8 = 1, headings.size do
            local h = headings[____i_8]
            ____builder:append(__K2L_Text.repeatCount("  ", h.level - minLevel)):append("- ["):append(h.text):append("](#"):append(h.id):append(")\n")
        end
    end
    return ____builder:toString()
end

local DOCUMENT = __K2L_Text.trimIndent("\n# k2l *Guide*\n\nWelcome to **k2l**, a _Kotlin_ to Lua transpiler. See <https://example.org/k2l> or [the docs](https://example.org/docs).\nUse `x < y && y > z` freely; it's ~~not~~ escaped.\nSecond line after a hard break.\n\n## Installing\n\n1. Download the archive\n2. Unpack it to `~/opt`\n3. Add **bin** to `PATH`\n\n## Features & Limits\n\n- [x] classes and *objects*\n- [ ] reflection beyond the __basics__\n* plain item with an ![logo](img/logo.png \"The Logo\") inside\n\n> Note: quotes can contain **markup**\n> and span lines.\n>\n> # Even headings\n\n| Feature | Status | Since |\n|:--------|:------:|------:|\n| Regex   | done   | 0.1 |\n| Streams | `partial` | 0.2 |\n\n```kotlin\nfun main() = println(\"<hello>\")\n```\n\n***\n\n## Installing\n\n5) fifth\n6) sixth\n\nSnake_case_words and 2*3*4 should stay as they are, but *this* is emphasis.\n")

local ____lambda_8 = function(it) return it.groupValues:get(1) end
local function main()
    local c = Converter.new()
    local html = c:convert(DOCUMENT)
    io.write(html)
    print("---- toc ----")
    io.write(toc(c.headings))
    local ____list_7 = __K2L_Regex.new("\\W+", "[^%w_]+"):split(__K2L_Regex.new("<[^>]+>", "<[^%>]+>"):replace(html, " "))
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_4, ____n_4 = ____list_7:____array()
    for ____i_9 = 1, ____n_4 do
        local it = ____items_4[____i_9]
        if #it > 0 then
            ____count_2 = ____count_2 + 1
            ____out_2[____count_2] = it
        end
    end
    local words = __K2L_ListWrap(____out_2, ____count_2)
    local ____arg = words.size
    local ____out_3 = {}
    local ____count_3 = 0
    local ____items_5, ____n_5 = words:____array()
    for ____i_10 = 1, ____n_5 do
        local it = ____items_5[____i_10]
        ____count_3 = ____count_3 + 1
        ____out_3[____count_3] = it:lower()
    end
    print("words: " .. ____arg .. ", distinct: " .. __K2L_ListWrap(____out_3, ____count_3):toSet().size)
    print("tags: " .. __K2L_Str(__K2L_Sequence.new(__K2L_Regex.new("<(\\w+)", "<([%w_]+)"):findAllFactory(html)):groupingBy(____lambda_8):eachCount():toSortedMap()))
end

__K2L_RunMain(main)
return {escapeHtml = escapeHtml, slug = slug, inline = inline, isWordChar = isWordChar, emphasis = emphasis, isRule = isRule, isSeparator = isSeparator, listItem = listItem, Heading = Heading, Converter = Converter, toc = toc, DOCUMENT = DOCUMENT}
