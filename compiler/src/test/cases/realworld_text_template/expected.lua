local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DoubleToLong = ____lualib.__K2L_DoubleToLong
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IsNumber = ____lualib.__K2L_IsNumber
local __K2L_Iterable = ____lualib.__K2L_Iterable
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NumberTo = ____lualib.__K2L_NumberTo
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_StringPadEnd = ____lualib.__K2L_StringPadEnd
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Node = __K2L_Class("Node")
local Text = __K2L_Class("Text", Node)

function Text:____init(text)
    self.text = text
end

function Text:toString()
    return "Text(text=" .. self.text .. ")"
end

function Text:hashCode()
    return __K2L_Hash(self.text)
end

function Text:equals(other)
    return getmetatable(other) == Text and self.text == other.text
end

local Value = __K2L_Class("Value", Node)

function Value:____init(path, filters, raw)
    self.path = path
    self.filters = filters
    self.raw = raw
end

function Value:toString()
    return "Value(path=" .. self.path .. ", filters=" .. __K2L_Str(self.filters) .. ", raw=" .. tostring(self.raw) .. ")"
end

function Value:hashCode()
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.path) + __K2L_Hash(self.filters)) + __K2L_Hash(self.raw))
end

function Value:equals(other)
    return getmetatable(other) == Value and self.path == other.path and __K2L_Equals(self.filters, other.filters) and self.raw == other.raw
end

local Each = __K2L_Class("Each", Node)

function Each:____init(path, body)
    self.path = path
    self.body = body
end

function Each:toString()
    return "Each(path=" .. self.path .. ", body=" .. __K2L_Str(self.body) .. ")"
end

function Each:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.path) + __K2L_Hash(self.body))
end

function Each:equals(other)
    return getmetatable(other) == Each and self.path == other.path and __K2L_Equals(self.body, other.body)
end

local If = __K2L_Class("If", Node)

function If:____init(path, negate, ____then, otherwise)
    self.path = path
    self.negate = negate
    self["then"] = ____then
    self.otherwise = otherwise
end

function If:toString()
    return "If(path=" .. self.path .. ", negate=" .. tostring(self.negate) .. ", then=" .. __K2L_Str(self["then"]) .. ", otherwise=" .. __K2L_Str(self.otherwise) .. ")"
end

function If:hashCode()
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.path) + __K2L_Hash(self.negate)) + __K2L_Hash(self["then"])) + __K2L_Hash(self.otherwise))
end

function If:equals(other)
    return getmetatable(other) == If and self.path == other.path and self.negate == other.negate and __K2L_Equals(self["then"], other["then"]) and __K2L_Equals(self.otherwise, other.otherwise)
end

local Partial = __K2L_Class("Partial", Node)

function Partial:____init(name)
    self.name = name
end

function Partial:toString()
    return "Partial(name=" .. self.name .. ")"
end

function Partial:hashCode()
    return __K2L_Hash(self.name)
end

function Partial:equals(other)
    return getmetatable(other) == Partial and self.name == other.name
end

local TemplateError = __K2L_Class("TemplateError", __K2L_Exception)

function TemplateError:____init(msg)
    __K2L_Exception.____init(self, msg)
end

local TAG = __K2L_Regex.new("\\{\\{(\\{?)\\s*([#/^!>]?)\\s*(.*?)\\s*\\}?\\}\\}")

local function parseTemplate(src)
    local Frame = __K2L_Class("MainKt$parseTemplate$Frame")
    function Frame:____init(kind, arg, nodes, otherwise)
        if otherwise == nil then
            otherwise = nil
        end
        self.kind = kind
        self.arg = arg
        self.nodes = nodes
        self.otherwise = otherwise
    end
    function Frame:toString()
        return "Frame(kind=" .. self.kind .. ", arg=" .. self.arg .. ", nodes=" .. __K2L_Str(self.nodes) .. ", otherwise=" .. __K2L_Str(self.otherwise) .. ")"
    end
    function Frame:hashCode()
        return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.kind) + __K2L_Hash(self.arg)) + __K2L_Hash(self.nodes)) + __K2L_Hash(self.otherwise))
    end
    function Frame:equals(other)
        return getmetatable(other) == Frame and self.kind == other.kind and self.arg == other.arg and __K2L_Equals(self.nodes, other.nodes) and __K2L_Equals(self.otherwise, other.otherwise)
    end
    local stack = __K2L_ArrayDeque.new()
    stack:addLast(Frame.new("root", "", __K2L_ListOf()))
    local last = 0
    for _, m in __K2L_Sequence.new(TAG:findAllFactory(src)):iter() do
        local target = stack:last().otherwise or stack:last().nodes
        if m.range.first > last then
            target:add(Text.new(__K2L_Text.substring(src, last, m.range.first)))
        end
        last = m.range.last + 1
        local ____destructured = m.destructured
        local brace, sigil, body = ____destructured[1], ____destructured[2], ____destructured[3]
        if sigil == "!" then
        elseif sigil == "#" or sigil == "^" then
            local ____value = __K2L_Regex.new("\\s+"):split(body, 2)
            local ____result
            ____result = __K2L_Pair.new(____value:get(0), ____value:getOrElse(1, function(it) return "" end))
            local ____destructured_1 = ____result
            local kind, arg = ____destructured_1.first, ____destructured_1.second
            if sigil == "^" then
                stack:addLast(Frame.new("unless", kind, __K2L_ListOf()))
            else
                stack:addLast(Frame.new(kind, arg, __K2L_ListOf()))
            end
        elseif sigil == "/" then
            local f = stack:removeLast()
            if f.kind ~= body and not (f.kind == "unless" and f.arg == body) then
                error(TemplateError.new("unexpected {{/" .. body .. "}}, open block is '" .. f.kind .. "'"))
            end
            local node
            local ____subject = f.kind
            if ____subject == "each" then
                node = Each.new(f.arg, f.nodes)
            elseif ____subject == "if" then
                node = If.new(f.arg, false, f.nodes, f.otherwise or __K2L_ListOf())
            elseif ____subject == "unless" then
                node = If.new(f.arg, true, f.nodes, f.otherwise or __K2L_ListOf())
            else
                error(TemplateError.new("unknown block '" .. f.kind .. "'"))
            end;
            (stack:last().otherwise or stack:last().nodes):add(node)
        elseif sigil == ">" then
            target:add(Partial.new(body))
        elseif body == "else" then
            local ____object = stack:last()
            ____object.otherwise = __K2L_ListOf()
        else
            local parts = __K2L_StringSplit(body, "|"):map(function(it) return __K2L_StringTrim(it) end)
            local filters = parts:drop(1):map(function(f)
                local name = __K2L_Text.substringBefore(f, ":")
                local ____temp
                if __K2L_StringContains(f, ":") then
                    ____temp = __K2L_StringSplit(__K2L_Text.substringAfter(f, ":"), ","):map(function(it)
                        return __K2L_Text.removeSurrounding(__K2L_StringTrim(it), "\"")
                    end)
                else
                    ____temp = __K2L_ReadOnlyListOf()
                end
                return __K2L_Pair.new(name, ____temp)
            end)
            target:add(Value.new(parts:get(0), filters, brace == "{"))
        end
    end
    if last < #src then
        (stack:last().otherwise or stack:last().nodes):add(Text.new(__K2L_Text.substring(src, last)))
    end
    if stack.size ~= 1 then
        error(TemplateError.new("unclosed {{#" .. stack:last().kind .. "}}"))
    end
    return stack:single().nodes
end

local Scope = __K2L_Class("Scope")

function Scope:____init(value, parent, locals)
    if locals == nil then
        locals = __K2L_ReadOnlyMapOf()
    end
    self.value = value
    self.parent = parent
    self.locals = locals
end

function Scope:lookup(path)
    if path == "." or path == "this" then
        return self.value
    end
    if __K2L_StringStartsWith(path, "@") then
        local ____value_1 = self.locals:get(path)
        if ____value_1 == nil then
            local ____receiver = self.parent
            ____value_1 = ____receiver and ____receiver:lookup(path)
        end
        return ____value_1
    end
    local keys = __K2L_StringSplit(path, ".")
    local scope = self
    while scope ~= nil do
        local head = self:field(scope.value, keys:get(0))
        if head ~= nil then
            return keys:drop(1):fold(head, function(acc, k) return self:field(acc, k) end)
        end
        scope = scope.parent
    end
    return nil
end

function Scope:field(obj, key)
    if __K2L_InstanceOf(obj, __K2L_Map) then
        return obj:get(key)
    elseif __K2L_InstanceOf(obj, __K2L_List) then
        local ____receiver_1 = __K2L_StringToIntOrNull(key)
        return ____receiver_1 and obj:getOrNull(____receiver_1) or (key == "length" and obj.size or nil)
    elseif type(obj) == "string" then
        return key == "length" and #obj or nil
    else
        return nil
    end
end

local function truthy(v)
    if v == nil then
        return false
    elseif type(v) == "boolean" then
        return v
    elseif __K2L_IsNumber(v) then
        return __K2L_NumberTo(v, "toDouble") ~= 0.0
    elseif type(v) == "string" then
        return #v > 0
    elseif __K2L_InstanceOf(v, __K2L_Iterable) and v.size ~= nil then
        return v:isNotEmpty()
    else
        return true
    end
end

local function html(s)
    local ____builder = __K2L_StringBuilder.new()
    for c in s:gmatch(".") do
        local ____temp_1
        if c == "<" then
            ____temp_1 = "&lt;"
        elseif c == ">" then
            ____temp_1 = "&gt;"
        elseif c == "&" then
            ____temp_1 = "&amp;"
        elseif c == "\"" then
            ____temp_1 = "&quot;"
        elseif c == "'" then
            ____temp_1 = "&#39;"
        else
            ____temp_1 = c
        end
        ____builder:append(__K2L_Str(____temp_1))
    end
    return ____builder:toString()
end

local FILTERS = __K2L_ReadOnlyMapOf(__K2L_Pair.new("upper", function(v, _) return __K2L_Str(v):upper() end), __K2L_Pair.new("lower", function(v, _) return __K2L_Str(v):lower() end), __K2L_Pair.new("capitalize", function(v, _)
    return __K2L_Text.replaceFirstChar(__K2L_Str(v), function(it) return it:upper() end)
end), __K2L_Pair.new("trim", function(v, _) return __K2L_StringTrim(__K2L_Str(v)) end), __K2L_Pair.new("money", function(v, a)
    local ____arg = "%,." .. (a:firstOrNull() or "2") .. "f"
    if not __K2L_IsNumber(v) then
        __K2L_CastFail(v, "java.lang.Number", "kotlin.Number")
    end
    return "$" .. __K2L_StringFormat(____arg, __K2L_NumberTo(v, "toDouble"))
end), __K2L_Pair.new("pad", function(v, a)
    return __K2L_StringPadStart(__K2L_Str(v), __K2L_StringToInt(a:get(0)), __K2L_Text.first(a:getOrElse(1, function(it) return " " end)))
end), __K2L_Pair.new("rpad", function(v, a)
    return __K2L_StringPadEnd(__K2L_Str(v), __K2L_StringToInt(a:get(0)), __K2L_Text.first(a:getOrElse(1, function(it) return " " end)))
end), __K2L_Pair.new("default", function(v, a)
    if truthy(v) then
        return v
    else
        return a:get(0)
    end
end), __K2L_Pair.new("join", function(v, a)
    if not __K2L_InstanceOf(v, __K2L_List) then
        __K2L_CastFail(v, "java.util.List", "kotlin.collections.List")
    end
    return v:joinToString(a:firstOrNull() or ", ")
end), __K2L_Pair.new("truncate", function(v, a)
    local ____value_2 = __K2L_Str(v)
    local ____result_1
    ____result_1 = #____value_2 <= __K2L_StringToInt(a:get(0)) and ____value_2 or __K2L_Text.take(____value_2, __K2L_StringToInt(a:get(0)) - 1) .. "…"
    return ____result_1
end), __K2L_Pair.new("plural", function(v, a)
    if not __K2L_IsNumber(v) then
        __K2L_CastFail(v, "java.lang.Number", "kotlin.Number")
    end
    if __K2L_NumberTo(v, "toInt") == 1 then
        return a:get(0)
    else
        return a:getOrElse(1, function(it) return a:get(0) .. "s" end)
    end
end), __K2L_Pair.new("percent", function(v, _)
    if not __K2L_IsNumber(v) then
        __K2L_CastFail(v, "java.lang.Number", "kotlin.Number")
    end
    return __K2L_StringFormat("%.1f%%", __K2L_NumberTo(v, "toDouble") * 100)
end), __K2L_Pair.new("reverse", function(v, _)
    return __K2L_InstanceOf(v, __K2L_List) and v:reversed() or __K2L_Str(v):reverse()
end), __K2L_Pair.new("length", function(v, _)
    return __K2L_InstanceOf(v, __K2L_Iterable) and v.size ~= nil and v.size or #__K2L_Str(v)
end))
local Renderer = __K2L_Class("Renderer")

function Renderer:____init(partials)
    self.partials = partials
    self.cache = __K2L_MapOf()
end

function Renderer:render(nodes, scope, out)
    local ____mod_2 = nodes.____modCount
    for ____i_2 = 1, nodes.size do
        local n = nodes[____i_2]
        if __K2L_InstanceOf(n, Text) then
            out:append(n.text)
        elseif __K2L_InstanceOf(n, Value) then
            local v = scope:lookup(n.path)
            local ____list = n.filters
            local ____mod_1 = ____list.____modCount
            for ____i_1 = 1, ____list.size do
                local ____item = ____list[____i_1]
                local name, args = ____item.first, ____item.second
                local ____value_4 = FILTERS:get(name)
                if ____value_4 == nil then
                    error(TemplateError.new("unknown filter '" .. name .. "'"))
                end
                local f = ____value_4
                v = f(v, args)
                if ____list.____modCount ~= ____mod_1 and ____list:____comodified(____i_1) then
                    break
                end
            end
            local s
            local ____subject_1 = v
            if ____subject_1 == nil then
                s = ""
            elseif math.type(____subject_1) == "float" then
                s = math.fmod(v, 1.0) == 0.0 and tostring(__K2L_DoubleToLong(v)) or __K2L_Str(v)
            else
                s = __K2L_Str(v)
            end
            out:append(n.raw and s or html(s))
        elseif __K2L_InstanceOf(n, Each) then
            local ____cast = scope:lookup(n.path)
            local items = __K2L_InstanceOf(____cast, __K2L_List) and ____cast or nil or __K2L_ReadOnlyListOf()
            local ____mod = items.____modCount
            for ____i = 1, items.size do
                local item = items[____i]
                local i = ____i - 1
                do
                    local locals = __K2L_ReadOnlyMapOf(__K2L_Pair.new("@index", i), __K2L_Pair.new("@number", i + 1), __K2L_Pair.new("@first", i == 0), __K2L_Pair.new("@last", i == items.size - 1))
                    self:render(n.body, Scope.new(item, scope, locals), out)
                end
                if items.____modCount ~= ____mod and items:____comodified(____i) then
                    break
                end
            end
        elseif __K2L_InstanceOf(n, If) then
            self:render(truthy(scope:lookup(n.path)) ~= n.negate and n["then"] or n.otherwise, scope, out)
        elseif __K2L_InstanceOf(n, Partial) then
            self:render(self.cache:getOrPut(n.name, function()
                local ____value_3 = self.partials:get(n.name)
                if ____value_3 == nil then
                    error(TemplateError.new("no partial '" .. n.name .. "'"))
                end
                return parseTemplate(____value_3)
            end), scope, out)
        end
        if nodes.____modCount ~= ____mod_2 and nodes:____comodified(____i_2) then
            break
        end
    end
end

function Renderer:render__1(src, data)
    local ____value_5 = __K2L_StringBuilder.new()
    self:render(parseTemplate(src), Scope.new(data, nil), ____value_5)
    return ____value_5:toString()
end

local INVOICE = __K2L_Text.trimIndent("\n{{! invoice template }}\nINVOICE #{{number | pad:6,0}}  {{customer.name | upper}}\n{{#if customer.vip}}*** VIP customer: {{customer.discount | percent}} off ***{{else}}Regular customer{{/if}}\n{{#each lines}}{{> line}}{{/each}}\n{{#if notes}}Notes: {{notes | join:\"; \"}}{{/if}}{{^notes}}No notes.{{/notes}}\nTotal: {{total | money}} ({{lines | length}} {{lines.length | plural:line}})\nTags: {{#each tags}}{{.}}{{#if @last}}.{{else}}, {{/if}}{{/each}}\nEscaped: {{html}} / raw: {{{html}}} / missing: [{{nope | default:\"n/a\"}}]\n")

local function main()
    local partials = __K2L_SingletonMapOf(__K2L_Pair.new("line", "{{@number | pad:2}}. {{name | rpad:22,.}} {{qty | pad:3}} x {{price | money | pad:10}}{{#if @first}}  <- first{{/if}}\n"))
    local lines = __K2L_ReadOnlyListOf(__K2L_ReadOnlyMapOf(__K2L_Pair.new("name", "keyboard"), __K2L_Pair.new("qty", 2), __K2L_Pair.new("price", 49.99)), __K2L_ReadOnlyMapOf(__K2L_Pair.new("name", "ultra-wide monitor stand"), __K2L_Pair.new("qty", 1), __K2L_Pair.new("price", 1299.5)), __K2L_ReadOnlyMapOf(__K2L_Pair.new("name", "usb cable"), __K2L_Pair.new("qty", 10), __K2L_Pair.new("price", 3.25)))
    local total = lines:sumOf(function(it)
        local ____cast_1 = it:get("qty")
        if math.type(____cast_1) ~= "integer" then
            __K2L_CastFail(____cast_1, "java.lang.Integer", "kotlin.Int")
        end
        local ____cast_2 = it:get("price")
        if math.type(____cast_2) ~= "float" then
            __K2L_CastFail(____cast_2, "java.lang.Double", "kotlin.Double")
        end
        return ____cast_1 * ____cast_2
    end, 0.0) * 0.9
    local data = __K2L_ReadOnlyMapOf(__K2L_Pair.new("number", 417), __K2L_Pair.new("customer", __K2L_ReadOnlyMapOf(__K2L_Pair.new("name", "Ada Lovelace"), __K2L_Pair.new("vip", true), __K2L_Pair.new("discount", 0.1))), __K2L_Pair.new("lines", lines), __K2L_Pair.new("notes", __K2L_ReadOnlyListOf("leave at door", "fragile")), __K2L_Pair.new("total", total), __K2L_Pair.new("tags", __K2L_ReadOnlyListOf("hardware", "office", "q1")), __K2L_Pair.new("html", "<b>\"Tom\" & 'Jerry'</b>"))
    local r = Renderer.new(partials)
    print(r:render__1(INVOICE, data))
    print("----")
    print(r:render__1(INVOICE, data:plus(__K2L_ReadOnlyMapOf(__K2L_Pair.new("notes", __K2L_ReadOnlyListOf()), __K2L_Pair.new("customer", __K2L_ReadOnlyMapOf(__K2L_Pair.new("name", "bob"), __K2L_Pair.new("vip", false)))))))
    print("----")
    print(r:render__1("{{#each rows}}[{{#each .}}{{.}}{{^@last}},{{/@last}}{{/each}}]{{/each}}", __K2L_SingletonMapOf(__K2L_Pair.new("rows", __K2L_ReadOnlyListOf(__K2L_ReadOnlyListOf(1, 2), __K2L_SingletonListOf(3), __K2L_ReadOnlyListOf())))))
    print(r:render__1("{{greeting | capitalize}}, {{name | truncate:6}}! {{name | reverse | lower}} {{name | length}}", __K2L_ReadOnlyMapOf(__K2L_Pair.new("greeting", "hello"), __K2L_Pair.new("name", "Wilhelmina"))))
    print(r:render__1("{{a.b.c}}|{{a.list.1}}|{{a.list.length}}|{{a.missing.deep}}|{{x | trim | upper}}", __K2L_ReadOnlyMapOf(__K2L_Pair.new("a", __K2L_ReadOnlyMapOf(__K2L_Pair.new("b", __K2L_SingletonMapOf(__K2L_Pair.new("c", 3.5))), __K2L_Pair.new("list", __K2L_ReadOnlyListOf("p", "q")))), __K2L_Pair.new("x", "  spaced  "))))
    local ____list_1 = __K2L_ReadOnlyListOf("{{#each x}}oops", "{{#if a}}{{/each}}", "{{x | shout}}", "{{> nope}}")
    for ____i_3 = 1, ____list_1.size do
        local bad = ____list_1[____i_3]
        local ____ok, ____result_2 = pcall(function()
            print(r:render__1(bad, __K2L_SingletonMapOf(__K2L_Pair.new("x", 1))))
        end)
        if not ____ok then
            local ____error = __K2L_ToThrowable(____result_2)
            if __K2L_InstanceOf(____error, TemplateError) then
                local e = ____error
                print("template error: " .. __K2L_Str(e.message))
            else
                error(____error, 0)
            end
        end
    end
end

main()
return {Node = Node, Text = Text, Value = Value, Each = Each, If = If, Partial = Partial, TemplateError = TemplateError, parseTemplate = parseTemplate, Scope = Scope, truthy = truthy, html = html, FILTERS = FILTERS, Renderer = Renderer, INVOICE = INVOICE}
