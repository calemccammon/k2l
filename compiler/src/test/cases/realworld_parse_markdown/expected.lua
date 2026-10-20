local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_FunctionRef = ____lualib.__K2L_FunctionRef
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringIndexOf = ____lualib.__K2L_StringIndexOf
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_Triple = ____lualib.__K2L_Triple
local __K2L_Utf16 = ____lualib.__K2L_Utf16
local __K2L_Utf16Case = ____lualib.__K2L_Utf16Case

local Block = __K2L_Class("Block")
__K2L_ClassInfo(Block, "Block", "Block", "class")
Block.Heading = __K2L_Class("Block$Heading", Block)
__K2L_ClassInfo(Block.Heading, "Block.Heading", "Block$Heading", "class")

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
__K2L_ClassInfo(Block.Para, "Block.Para", "Block$Para", "class")

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
__K2L_ClassInfo(Block.Code, "Block.Code", "Block$Code", "class")

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
__K2L_ClassInfo(Block.Quote, "Block.Quote", "Block$Quote", "class")

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
__K2L_ClassInfo(Block.ListBlock, "Block.ListBlock", "Block$ListBlock", "class")

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
__K2L_ClassInfo(Block.Rule, "Block.Rule", "Block$Rule", "class")

function Block.Rule:toString()
    return "Rule"
end

function Block.Rule:hashCode()
    return -1061213187
end

local listMarker = __K2L_Regex.new("^( {0,3})([-*+]|(\\d{1,9})[.)])\\s+(.*)$")
local atx = __K2L_Regex.new("^(#{1,6})\\s+(.*?)\\s*#*\\s*$")

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
        local stripped = __K2L_Text.trimStart(line)
        local heading = atx:matchEntire(line)
        local marker = listMarker:matchEntire(line)
        if __K2L_Text.isBlank(line) then
            flush()
            i = i + 1
        elseif __K2L_Text.startsWith(stripped, "```") then
            flush()
            local lang = __K2L_Text.ifEmpty(__K2L_Text.trim(__K2L_Text.removePrefix(stripped, "```")), ____lambda_1)
            local body = __K2L_StringBuilder.new()
            i = i + 1
            while i < lines.size and not __K2L_Text.startsWith(__K2L_Text.trimStart(lines:get(i)), "```") do
                local ____old_1 = i
                i = i + 1
                body:append(lines:get(____old_1)):append("\n")
            end
            i = i + 1
            out:add(Block.Code.new(lang, body:toString()))
        elseif heading ~= nil then
            flush()
            out:add(Block.Heading.new(__K2L_Utf16.len(heading.groupValues:get(1)), heading.groupValues:get(2)))
            i = i + 1
        elseif para:isNotEmpty() and __K2L_Regex.new("^(=+|-+)\\s*$"):matches(line) then
            local level = __K2L_Text.get(line, 0) == "=" and 1 or 2
            out:add(Block.Heading.new(level, __K2L_Utf16.norm(para:joinToString(" "))))
            para:clear()
            i = i + 1
        else
            local ____cond = __K2L_Utf16.len(stripped) >= 3
            if ____cond then
                local ____value = __K2L_StringReplace(stripped, " ", "")
                local ____result
                ____result = __K2L_Utf16.len(____value) >= 3 and __K2L_Text.toList(____value):all(function(it) return it == __K2L_Text.get(____value, 0) end) and __K2L_Text.contains("-*_", __K2L_Text.get(____value, 0))
                ____cond = ____result
            end
            if ____cond then
                flush()
                out:add(Block.Rule)
                i = i + 1
            elseif __K2L_Text.startsWith(stripped, ">") then
                flush()
                local inner = __K2L_ListOf()
                while i < lines.size and __K2L_Text.startsWith(__K2L_Text.trimStart(lines:get(i)), ">") do
                    local ____old = i
                    i = i + 1
                    inner:add(__K2L_Text.removePrefix(__K2L_Text.removePrefix(__K2L_Text.trimStart(lines:get(____old)), ">"), " "))
                end
                out:add(Block.Quote.new(parseBlocks(inner)))
            elseif marker ~= nil then
                flush()
                local delimiter = __K2L_Text.last(marker.groupValues:get(2))
                local ordered = #marker.groupValues:get(3) > 0
                local start = __K2L_StringToIntOrNull(marker.groupValues:get(3)) or 1
                local items = __K2L_ListOf()
                while i < lines.size do
                    local m = listMarker:matchEntire(lines:get(i))
                    if m ~= nil and m.groupValues:get(1) == marker.groupValues:get(1) and __K2L_Text.last(m.groupValues:get(2)) == delimiter then
                        items:add(__K2L_ListOf(m.groupValues:get(4)))
                        i = i + 1
                    elseif __K2L_Text.startsWith(lines:get(i), "  ") and items:isNotEmpty() then
                        local ____cast = items:last()
                        if not (__K2L_InstanceOf(____cast, __K2L_List) and not ____cast.____readOnly) then
                            __K2L_CastFail(____cast, "java.util.List", "kotlin.collections.MutableList")
                        end
                        ____cast:add(__K2L_Text.drop(lines:get(i), __K2L_Text.startsWith(lines:get(i), "    ") and 4 or 2))
                        i = i + 1
                    elseif __K2L_Text.isBlank(lines:get(i)) and i + 1 < lines.size and (__K2L_Text.startsWith(lines:get(i + 1), "  ") or listMarker:matches(lines:get(i + 1))) then
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
    for c in __K2L_Utf16.each(s) do
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
    while i < __K2L_Utf16.len(src) do
        local c = __K2L_Text.get(src, i)
        if c == "\\" and i + 1 < __K2L_Utf16.len(src) and __K2L_Text.contains("\\`*_[]()#+-.!<>", __K2L_Text.get(src, i + 1)) then
            sb:append(escapeHtml(__K2L_Text.get(src, i + 1)))
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
        elseif (c == "*" or c == "_") and __K2L_Text.startsWithAt(src, __K2L_Utf16.norm(c .. c), i) then
            toggle("strong")
            i = i + 2
        elseif c == "*" or c == "_" and (i == 0 or not __K2L_Utf16Case.isLetterOrDigit(__K2L_Text.get(src, i - 1))) or c == "_" and open:lastOrNull() == "em" then
            toggle("em")
            i = i + 1
        elseif c == "[" then
            local close = __K2L_StringIndexOf(src, "](", i)
            local paren = close >= 0 and __K2L_StringIndexOf(src, ")", close) or -1
            if paren < 0 then
                sb:append("[")
                i = i + 1
            else
                local ____value_1 = __K2L_Text.split(__K2L_Text.substring(src, close + 2, paren), {" \""}, 2)
                local ____result_1
                do
                    local ____arg = ____value_1:get(0)
                    local ____receiver = ____value_1:getOrNull(1)
                    ____result_1 = __K2L_Pair.new(____arg, ____receiver and __K2L_Text.removeSuffix(____receiver, "\""))
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
        elseif c == "<" and __K2L_Regex.new("^<(https?://[^>\\s]+)>"):find(__K2L_Text.substring(src, i)) ~= nil then
            local url = __K2L_NotNull(__K2L_Regex.new("^<(https?://[^>\\s]+)>"):find(__K2L_Text.substring(src, i))).groupValues:get(1)
            sb:append("<a href=\"" .. url .. "\">" .. url .. "</a>")
            i = i + (__K2L_Utf16.len(url) + 2)
        elseif c == " " and __K2L_Text.startsWithAt(src, "  ", i) and i + 2 == __K2L_Utf16.len(src) then
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
__K2L_ClassInfo(Renderer, "Renderer", "Renderer", "class")

function Renderer:____init()
    self.slugs = __K2L_MapOf()
    self.toc = __K2L_ListOf()
end

local ____lambda_2 = function() return "section" end
local ____lambda_3 = function(____p1, ____p2) return ____p1 + ____p2 end
function Renderer:slug(text)
    local base = __K2L_Text.ifEmpty(__K2L_Regex.new("\\s+"):replace(__K2L_Text.trim(__K2L_Regex.new("[^\\p{L}\\p{N}\\s-]"):replace(__K2L_Utf16Case.lowercase(text), "")), "-"), ____lambda_2)
    local n = __K2L_NotNull(self.slugs:merge(base, 1, __K2L_FunctionRef.new("plus", "kotlin/Int.plus(kotlin.Int)", ____lambda_3)))
    return n == 1 and base or base .. "-" .. n - 1
end

local ____lambda_4 = function(it) return inline(it) end
function Renderer:render(blocks, tight)
    if tight == nil then
        tight = false
    end
    local ____builder_1 = __K2L_StringBuilder.new()
    do
        local ____mod_1 = blocks.____modCount
        for ____i_2 = 1, blocks.size do
            local b = blocks[____i_2]
            local ____mt = getmetatable(b)
            if ____mt == Block.Heading then
                local id = self:slug(b.text)
                self.toc:add(__K2L_Triple.new(b.level, b.text, id))
                ____builder_1:append("<h" .. b.level .. " id=\"" .. id .. "\">" .. inline(b.text) .. "</h" .. b.level .. ">\n")
            elseif ____mt == Block.Para then
                local body = __K2L_Utf16.norm(b.lines:joinToString("\n", nil, nil, nil, nil, ____lambda_4))
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
                local ____mod = ____list.____modCount
                for ____i_1 = 1, ____list.size do
                    local item = ____list[____i_1]
                    ____builder_1:append("<li>"):append(__K2L_Text.trimChars(self:render(item, true), 2, "\n")):append("</li>\n")
                    if ____list.____modCount ~= ____mod and ____list:____comodified(____i_1) then
                        break
                    end
                end
                ____builder_1:append("</" .. tag .. ">\n")
            elseif __K2L_Equals(b, Block.Rule) then
                ____builder_1:append("<hr>\n")
            end
            if blocks.____modCount ~= ____mod_1 and blocks:____comodified(____i_2) then
                break
            end
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
    for ____i_3 = 1, ____n_1 do
        local it = ____items_1[____i_3]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = __K2L_KClassOfValue(it).simpleName
    end
    print(__K2L_Utf16.out(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1):groupingBy(____lambda_5):eachCount())))
    local r = Renderer.new()
    local html = r:render(blocks)
    io.write(__K2L_Utf16.out(html))
    print(__K2L_Utf16.out("<nav>"))
    local ____list_1 = r.toc
    local ____mod_2 = ____list_1.____modCount
    for ____i_4 = 1, ____list_1.size do
        local ____item = ____list_1[____i_4]
        local level, text, id = ____item.first, ____item.second, ____item.third
        print(__K2L_Utf16.out(__K2L_Text.repeatCount("  ", level - 1) .. "<a href=\"#" .. id .. "\">" .. escapeHtml(__K2L_Regex.new("[*_`]"):replace(text, "")) .. "</a>"))
        if ____list_1.____modCount ~= ____mod_2 and ____list_1:____comodified(____i_4) then
            break
        end
    end
    print(__K2L_Utf16.out("</nav>"))
    local ____list_2 = __K2L_StringLines(html)
    local ____result_2 = 0
    local ____items_2, ____n_2 = ____list_2:____array()
    for ____i_5 = 1, ____n_2 do
        local it = ____items_2[____i_5]
        if __K2L_Text.startsWith(it, "<li>") then
            ____result_2 = ____result_2 + 1
        end
    end
    print(__K2L_Utf16.out(__K2L_Str(__K2L_Pair.new(____result_2, __K2L_Sequence.new(__K2L_Regex.new("<(\\w+)"):findAllFactory(html)):map(____lambda_6):distinct():sorted():toList()))))
    print(__K2L_Utf16.out(inline("unclosed **bold and `tick")))
end

main()
return {Block = Block, parseBlocks = parseBlocks, escapeHtml = escapeHtml, inline = inline, Renderer = Renderer, doc = doc}
