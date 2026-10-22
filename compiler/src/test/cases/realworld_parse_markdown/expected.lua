local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IsLetterOrDigit = ____lualib.__K2L_IsLetterOrDigit
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_SimpleName = ____lualib.__K2L_SimpleName
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StrByte = ____lualib.__K2L_StrByte
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringIndexOf = ____lualib.__K2L_StringIndexOf
local __K2L_StringIsBlank = ____lualib.__K2L_StringIsBlank
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_StringTrimStart = ____lualib.__K2L_StringTrimStart
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_Triple = ____lualib.__K2L_Triple

local Block = __K2L_Class("Block")
Block.Heading = __K2L_Class("Block$Heading", Block)

function Block.Heading:____init(level, text)
    self.level = level
    self.text = text
end

function Block.Heading.new(level, text)
    return setmetatable({level = level, text = text}, Block.Heading)
end

function Block.Heading:toString()
    return "Heading(level=" .. self.level .. ", text=" .. self.text .. ")"
end

function Block.Heading:hashCode()
    return (31 * self.level + __K2L_Hash(self.text) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Block.Heading:equals(other)
    return getmetatable(other) == Block.Heading and self.level == other.level and self.text == other.text
end

Block.Para = __K2L_Class("Block$Para", Block)

function Block.Para:____init(lines)
    self.lines = lines
end

function Block.Para.new(lines)
    return setmetatable({lines = lines}, Block.Para)
end

function Block.Para:toString()
    return "Para(lines=" .. __K2L_Str(self.lines) .. ")"
end

function Block.Para:hashCode()
    return __K2L_Hash(self.lines)
end

function Block.Para:equals(other)
    return getmetatable(other) == Block.Para and __K2L_Equals(self.lines, other.lines)
end

Block.Code = __K2L_Class("Block$Code", Block)

function Block.Code:____init(lang, body)
    self.lang = lang
    self.body = body
end

function Block.Code.new(lang, body)
    return setmetatable({lang = lang, body = body}, Block.Code)
end

function Block.Code:toString()
    return "Code(lang=" .. __K2L_Str(self.lang) .. ", body=" .. self.body .. ")"
end

function Block.Code:hashCode()
    return (31 * __K2L_Hash(self.lang) + __K2L_Hash(self.body) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Block.Code:equals(other)
    return getmetatable(other) == Block.Code and self.lang == other.lang and self.body == other.body
end

Block.Quote = __K2L_Class("Block$Quote", Block)

function Block.Quote:____init(children)
    self.children = children
end

function Block.Quote.new(children)
    return setmetatable({children = children}, Block.Quote)
end

function Block.Quote:toString()
    return "Quote(children=" .. __K2L_Str(self.children) .. ")"
end

function Block.Quote:hashCode()
    return __K2L_Hash(self.children)
end

function Block.Quote:equals(other)
    return getmetatable(other) == Block.Quote and __K2L_Equals(self.children, other.children)
end

Block.ListBlock = __K2L_Class("Block$ListBlock", Block)

function Block.ListBlock:____init(ordered, start, items)
    self.ordered = ordered
    self.start = start
    self.items = items
end

function Block.ListBlock.new(ordered, start, items)
    return setmetatable({ordered = ordered, start = start, items = items}, Block.ListBlock)
end

function Block.ListBlock:toString()
    return "ListBlock(ordered=" .. tostring(self.ordered) .. ", start=" .. self.start .. ", items=" .. __K2L_Str(self.items) .. ")"
end

function Block.ListBlock:hashCode()
    return (31 * (31 * (self.ordered and 1231 or 1237) + self.start) + __K2L_Hash(self.items) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Block.ListBlock:equals(other)
    return getmetatable(other) == Block.ListBlock and self.ordered == other.ordered and self.start == other.start and __K2L_Equals(self.items, other.items)
end

Block.Rule = __K2L_Class("Block$Rule", Block)

function Block.Rule:toString()
    return "Rule"
end

function Block.Rule:hashCode()
    return -1061213187
end

local bulletMarker = __K2L_Regex.new("^( {0,3})([-*+])\\s+(.*)$", "^( ? ? ?)([%-%*%+])%s+([^\n\r]*)$")
local numberMarker = __K2L_Regex.new("^( {0,3})((\\d{1,9})[.)])\\s+(.*)$", "^( ? ? ?)((%d%d?%d?%d?%d?%d?%d?%d?%d?)[%.%)])%s+([^\n\r]*)$")

local function listMarker(line)
    local ____receiver = numberMarker:matchEntire(line)
    local ____value = ____receiver and ____receiver.groupValues
    if ____value == nil then
        local ____receiver_1 = bulletMarker:matchEntire(line)
        local ____receiver_2 = ____receiver_1 and ____receiver_1.groupValues
        ____value = ____receiver_2 and __K2L_ListOf(____receiver_2:get(0), ____receiver_2:get(1), ____receiver_2:get(2), "", ____receiver_2:get(3))
    end
    return ____value
end

local function isSetextUnderline(line)
    return __K2L_Regex.new("^=+\\s*$", "^=+%s*$"):matches(line) or __K2L_Regex.new("^-+\\s*$", "^%-+%s*$"):matches(line)
end

local atx = __K2L_Regex.new("^(#{1,6})\\s+(.*?)\\s*#*\\s*$", "^(##?#?#?#?#?)%s+([^\n\r]-)%s*#*%s*$")

local ____lambda_1 = function() return nil end
local function parseBlocks(lines)
    local out = __K2L_ListOf()
    local i = 0
    local para = __K2L_ListOf()
    local function flush()
        if para:isNotEmpty() then
            out:add(Block.Para.new(para:toList()))
            para:clear()
        end
    end
    while i < lines.size do
        local line = lines:get(i)
        local stripped = __K2L_StringTrimStart(line)
        local heading = atx:matchEntire(line)
        local marker = listMarker(line)
        if __K2L_StringIsBlank(line) then
            flush()
            i = i + 1
        elseif __K2L_StringStartsWith(stripped, "```") then
            flush()
            local lang = __K2L_Text.ifEmpty(__K2L_StringTrim(__K2L_Text.removePrefix(stripped, "```")), ____lambda_1)
            local body = __K2L_StringBuilder.new()
            i = i + 1
            while i < lines.size and not __K2L_StringStartsWith(__K2L_StringTrimStart(lines:get(i)), "```") do
                local ____old_1 = i
                i = i + 1
                body:append(lines:get(____old_1)):append("\n")
            end
            i = i + 1
            out:add(Block.Code.new(lang, body:toString()))
        elseif heading ~= nil then
            flush()
            out:add(Block.Heading.new(#heading.groupValues:get(1), heading.groupValues:get(2)))
            i = i + 1
        elseif para:isNotEmpty() and isSetextUnderline(line) then
            local level = (0 >= 0 and __K2L_StrByte(line, 0 + 1) or __K2L_IndexError(0, #line, "string")) == 61 and 1 or 2
            out:add(Block.Heading.new(level, para:joinToString(" ")))
            para:clear()
            i = i + 1
        else
            local ____cond = #stripped >= 3
            if ____cond then
                local ____value_1 = __K2L_StringReplace(stripped, " ", "")
                local ____result
                ____result = #____value_1 >= 3 and __K2L_StringToList(____value_1):all(function(it)
                    return it == (0 >= 0 and 0 < #____value_1 and ____value_1:sub(0 + 1, 0 + 1) or __K2L_IndexError(0, #____value_1, "string"))
                end) and __K2L_StringContains("-*_", 0 >= 0 and 0 < #____value_1 and ____value_1:sub(0 + 1, 0 + 1) or __K2L_IndexError(0, #____value_1, "string"))
                ____cond = ____result
            end
            if ____cond then
                flush()
                out:add(Block.Rule)
                i = i + 1
            elseif __K2L_StringStartsWith(stripped, ">") then
                flush()
                local inner = __K2L_ListOf()
                while i < lines.size and __K2L_StringStartsWith(__K2L_StringTrimStart(lines:get(i)), ">") do
                    local ____old = i
                    i = i + 1
                    inner:add(__K2L_Text.removePrefix(__K2L_Text.removePrefix(__K2L_StringTrimStart(lines:get(____old)), ">"), " "))
                end
                out:add(Block.Quote.new(parseBlocks(inner)))
            elseif marker ~= nil then
                flush()
                local delimiter = __K2L_Text.last(marker:get(2))
                local ordered = #marker:get(3) > 0
                local start = __K2L_StringToIntOrNull(marker:get(3)) or 1
                local items = __K2L_ListOf()
                while i < lines.size do
                    local m = listMarker(lines:get(i))
                    if m ~= nil and m:get(1) == marker:get(1) and __K2L_Text.last(m:get(2)) == delimiter then
                        items:add(__K2L_ListOf(m:get(4)))
                        i = i + 1
                    elseif __K2L_StringStartsWith(lines:get(i), "  ") and items:isNotEmpty() then
                        local ____cast = items:last()
                        if not __K2L_InstanceOf(____cast, __K2L_List) then
                            __K2L_CastFail(____cast, "kotlin.collections.MutableList")
                        end
                        ____cast:add(__K2L_Text.drop(lines:get(i), __K2L_StringStartsWith(lines:get(i), "    ") and 4 or 2))
                        i = i + 1
                    elseif __K2L_StringIsBlank(lines:get(i)) and i + 1 < lines.size and (__K2L_StringStartsWith(lines:get(i + 1), "  ") or listMarker(lines:get(i + 1)) ~= nil) then
                        i = i + 1
                    else
                        break
                    end
                end
                local ____out = {}
                local ____count = 0
                local ____items, ____n = items:____array()
                for ____i = 1, ____n do
                    local it = ____items[____i]
                    ____count = ____count + 1
                    ____out[____count] = parseBlocks(it)
                end
                out:add(Block.ListBlock.new(ordered, start, __K2L_ListWrap(____out, ____count)))
            else
                para:add(stripped)
                i = i + 1
            end
        end
    end
    flush()
    return out
end

local function escapeHtml(s)
    local ____builder = __K2L_StringBuilder.new()
    for ____i_1 = 1, #s do
        local c = s:sub(____i_1, ____i_1)
        if c == "<" then
            ____builder:append("&lt;")
        elseif c == ">" then
            ____builder:append("&gt;")
        elseif c == "&" then
            ____builder:append("&amp;")
        elseif c == "\"" then
            ____builder:append("&quot;")
        else
            ____builder:append(c)
        end
    end
    return ____builder:toString()
end

local function inline(src)
    local sb = __K2L_StringBuilder.new()
    local i = 0
    local open = __K2L_ArrayDeque.new()
    local function toggle(tag)
        if open:lastOrNull() == tag then
            open:removeLast()
            sb:append("</" .. tag .. ">")
        else
            open:addLast(tag)
            sb:append("<" .. tag .. ">")
        end
    end
    while i < #src do
        local c = i >= 0 and i < #src and src:sub(i + 1, i + 1) or __K2L_IndexError(i, #src, "string")
        if c == "\\" and i + 1 < #src and __K2L_StringContains("\\`*_[]()#+-.!<>", i + 1 >= 0 and i + 1 < #src and src:sub(i + 1 + 1, i + 1 + 1) or __K2L_IndexError(i + 1, #src, "string")) then
            sb:append(escapeHtml(i + 1 >= 0 and i + 1 < #src and src:sub(i + 1 + 1, i + 1 + 1) or __K2L_IndexError(i + 1, #src, "string")))
            i = i + 2
        elseif c == "`" then
            local ____end = __K2L_StringIndexOf(src, "`", i + 1)
            if ____end < 0 then
                sb:append("`")
                i = i + 1
            else
                sb:append("<code>"):append(escapeHtml(__K2L_Text.substring(src, i + 1, ____end))):append("</code>")
                i = ____end + 1
            end
        elseif (c == "*" or c == "_") and src:sub(i + 1, i + #(c .. c)) == c .. c then
            toggle("strong")
            i = i + 2
        elseif c == "*" or c == "_" and (i == 0 or __K2L_IsLetterOrDigit[i - 1 >= 0 and i - 1 < #src and src:sub(i - 1 + 1, i - 1 + 1) or __K2L_IndexError(i - 1, #src, "string")] ~= true) or c == "_" and open:lastOrNull() == "em" then
            toggle("em")
            i = i + 1
        elseif c == "[" then
            local close = __K2L_StringIndexOf(src, "](", i)
            local paren = close >= 0 and __K2L_StringIndexOf(src, ")", close) or -1
            if paren < 0 then
                sb:append("[")
                i = i + 1
            else
                local ____value_2 = __K2L_Text.split(__K2L_Text.substring(src, close + 2, paren), {" \""}, 2)
                local ____result_1
                do
                    local ____arg = ____value_2:get(0)
                    local ____receiver_3 = ____value_2:getOrNull(1)
                    ____result_1 = __K2L_Pair.new(____arg, ____receiver_3 and __K2L_Text.removeSuffix(____receiver_3, "\""))
                end
                local ____destructured = ____result_1
                local url, title = ____destructured.first, ____destructured.second
                sb:append("<a href=\""):append(escapeHtml(url)):append("\"")
                if title ~= nil then
                    sb:append(" title=\""):append(escapeHtml(title)):append("\"")
                end
                sb:append(">"):append(inline(__K2L_Text.substring(src, i + 1, close))):append("</a>")
                i = paren + 1
            end
        elseif c == "<" and __K2L_Regex.new("^<(https?://[^>\\s]+)>", "^<(https?://[^%s%>]+)>"):find(__K2L_Text.substring(src, i)) ~= nil then
            local url = __K2L_NotNull(__K2L_Regex.new("^<(https?://[^>\\s]+)>", "^<(https?://[^%s%>]+)>"):find(__K2L_Text.substring(src, i))).groupValues:get(1)
            sb:append("<a href=\"" .. url .. "\">" .. url .. "</a>")
            i = i + (#url + 2)
        elseif c == " " and src:sub(i + 1, i + #"  ") == "  " and i + 2 == #src then
            sb:append("<br>")
            i = i + 2
        else
            sb:append(escapeHtml(c))
            i = i + 1
        end
    end
    while open:isNotEmpty() do
        sb:append("</" .. open:removeLast() .. ">")
    end
    return sb:toString()
end

local Renderer = __K2L_Class("Renderer")

function Renderer:____init()
    self.slugs = __K2L_MapOf()
    self.toc = __K2L_ListOf()
end

local ____lambda_2 = function() return "section" end
local ____lambda_3 = function(____p1, ____p2) return ____p1 + ____p2 end
function Renderer:slug(text)
    local base = __K2L_Text.ifEmpty(__K2L_Regex.new("\\s+", "%s+"):replace(__K2L_StringTrim(__K2L_Regex.new("[^a-z0-9\\s-]", "[^%sa-z0-9%-]"):replace(text:lower(), "")), "-"), ____lambda_2)
    local n = __K2L_NotNull(self.slugs:merge(base, 1, ____lambda_3))
    return n == 1 and base or base .. "-" .. n - 1
end

local ____lambda_4 = function(it) return inline(it) end
function Renderer:render(blocks, tight)
    if tight == nil then
        tight = false
    end
    local ____builder_1 = __K2L_StringBuilder.new()
    for ____i_3 = 1, blocks.size do
        local b = blocks[____i_3]
        local ____mt = getmetatable(b)
        if ____mt == Block.Heading then
            local id = self:slug(b.text)
            self.toc:add(__K2L_Triple.new(b.level, b.text, id))
            ____builder_1:append("<h" .. b.level .. " id=\"" .. id .. "\">" .. inline(b.text) .. "</h" .. b.level .. ">\n")
        elseif ____mt == Block.Para then
            local body = b.lines:joinToString("\n", nil, nil, nil, nil, ____lambda_4)
            if tight then
                ____builder_1:append(body):append("\n")
            else
                ____builder_1:append("<p>"):append(body):append("</p>\n")
            end
        elseif ____mt == Block.Code then
            ____builder_1:append(b.lang ~= nil and "<pre><code class=\"language-" .. b.lang .. "\">" or "<pre><code>"):append(escapeHtml(b.body)):append("</code></pre>\n")
        elseif ____mt == Block.Quote then
            ____builder_1:append("<blockquote>\n"):append(self:render(b.children)):append("</blockquote>\n")
        elseif ____mt == Block.ListBlock then
            local tag = b.ordered and "ol" or "ul"
            ____builder_1:append(b.ordered and b.start ~= 1 and "<" .. tag .. " start=\"" .. b.start .. "\">\n" or "<" .. tag .. ">\n")
            local ____list = b.items
            for ____i_2 = 1, ____list.size do
                local item = ____list[____i_2]
                ____builder_1:append("<li>"):append(__K2L_Text.trimChars(self:render(item, true), 2, "\n")):append("</li>\n")
            end
            ____builder_1:append("</" .. tag .. ">\n")
        elseif __K2L_Equals(b, Block.Rule) then
            ____builder_1:append("<hr>\n")
        end
    end
    return ____builder_1:toString()
end

local doc = __K2L_Text.trimIndent("\n# Release notes\nVersion **2.0** brings _many_ changes & fixes.\n\nSetup guide\n===========\n\n1. Install with `npm i k2l --save`\n2. Configure:\n   - set `target` to *5.4*\n   - set `strings` to __utf16__\n3. Run it\n\n7) seven\n8) eight\n\n> **Note:** quotes can hold\n> - lists\n> - and `code <b>`\n\n```kotlin\nfun main() = println(\"<hi> & bye\")\n```\n\n* * *\n\nLinks: [docs](https://example.com/docs \"The docs\"), <https://k2l.dev>, and [nested *em*](/x).\nEscapes: \\*not em\\*, snake_case_name, 2 < 3 && 5 > 4.\nLine two after a hard break.\n\n## Setup guide\n## Ünïcode héading!\n")

local ____lambda_5 = function(it) return it end
local ____lambda_6 = function(it) return it.groupValues:get(1) end
local function main()
    local blocks = parseBlocks(__K2L_StringLines(doc))
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = blocks:____array()
    for ____i_4 = 1, ____n_1 do
        local it = ____items_1[____i_4]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = __K2L_SimpleName(it)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1):groupingBy(____lambda_5):eachCount()))
    local r = Renderer.new()
    local html = r:render(blocks)
    io.write(html)
    print("<nav>")
    local ____list_1 = r.toc
    for ____i_5 = 1, ____list_1.size do
        local ____item = ____list_1[____i_5]
        local level, text, id = ____item.first, ____item.second, ____item.third
        print(__K2L_Text.repeatCount("  ", level - 1) .. "<a href=\"#" .. id .. "\">" .. escapeHtml(__K2L_Regex.new("[*_`]", "[%*_%`]"):replace(text, "")) .. "</a>")
    end
    print("</nav>")
    local ____list_2 = __K2L_StringLines(html)
    local ____result_2 = 0
    local ____items_2, ____n_2 = ____list_2:____array()
    for ____i_6 = 1, ____n_2 do
        local it = ____items_2[____i_6]
        if __K2L_StringStartsWith(it, "<li>") then
            ____result_2 = ____result_2 + 1
        end
    end
    print(__K2L_Str(__K2L_Pair.new(____result_2, __K2L_Sequence.new(__K2L_Regex.new("<(\\w+)", "<([%w_]+)"):findAllFactory(html)):map(____lambda_6):distinct():sorted():toList())))
    print(inline("unclosed **bold and `tick"))
end

__K2L_RunMain(main)
return {Block = Block, listMarker = listMarker, isSetextUnderline = isSetextUnderline, parseBlocks = parseBlocks, escapeHtml = escapeHtml, inline = inline, Renderer = Renderer, doc = doc}
