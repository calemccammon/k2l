local ____lualib = require("lualib_bundle")
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder

local escape, Head, Title, Body, B, P, H1, UL, LI, A, ArrayBuilder, toJson
local Element = __K2L_Class("dsl.Element")
local TextElement = __K2L_Class("dsl.TextElement", nil, Element)

function TextElement.new(text)
    return setmetatable({text = text}, TextElement)
end

function TextElement:render(builder, indent)
    builder:append(indent .. escape(self.text) .. "\n")
end

function escape(s)
    local ____builder = __K2L_StringBuilder.new()
    for ____i = 1, #s do
        local c = s:sub(____i, ____i)
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

local Tag = __K2L_Class("dsl.Tag", nil, Element)

local function renderAttributes(self)
    return self.attributes:getEntries():joinToString("", nil, nil, nil, nil, function(____destructured)
        local k, v = ____destructured.key, ____destructured.value
        return " " .. k .. "=\"" .. escape(v) .. "\""
    end)
end

function Tag:____init(name)
    self.name = name
    self.children = __K2L_ListOf()
    self.attributes = __K2L_MapOf()
end

function Tag:initTag(tag, init)
    init(tag)
    self.children:add(tag)
    return tag
end

function Tag:render(builder, indent)
    builder:append(indent .. "<" .. self.name .. renderAttributes(self))
    if self.children:isEmpty() then
        builder:append("/>\n")
        return
    end
    builder:append(">\n")
    local ____list = self.children
    for ____i_1 = 1, ____list.size do
        local c = ____list[____i_1]
        c:render(builder, indent .. "  ")
    end
    builder:append(indent .. "</" .. self.name .. ">\n")
end

function Tag:toString()
    local ____value = __K2L_StringBuilder.new()
    self:render(____value, "")
    return ____value:toString()
end

function Tag:unaryPlus(____this)
    self.children:add(TextElement.new(____this))
end

function Tag:set(attr, value)
    local ____object = self.attributes
    ____object:set(attr, value)
end

function Tag:get(attr)
    return self.attributes:get(attr)
end

local TagWithText = __K2L_Class("dsl.TagWithText", Tag)

function TagWithText:____init(name)
    Tag.____init(self, name)
end

local HTML = __K2L_Class("dsl.HTML", TagWithText)

function HTML:____init()
    TagWithText.____init(self, "html")
end

function HTML:head(init)
    return self:initTag(Head.new(), init)
end

function HTML:body(init)
    return self:initTag(Body.new(), init)
end

Head = __K2L_Class("dsl.Head", TagWithText)

function Head:____init()
    TagWithText.____init(self, "head")
end

function Head:title(init)
    return self:initTag(Title.new(), init)
end

Title = __K2L_Class("dsl.Title", TagWithText)

function Title:____init()
    TagWithText.____init(self, "title")
end

local BodyTag = __K2L_Class("dsl.BodyTag", TagWithText)

function BodyTag:____init(name)
    TagWithText.____init(self, name)
end

function BodyTag:b(init)
    return self:initTag(B.new(), init)
end

function BodyTag:p(init)
    return self:initTag(P.new(), init)
end

function BodyTag:h1(init)
    return self:initTag(H1.new(), init)
end

function BodyTag:ul(init)
    return self:initTag(UL.new(), init)
end

function BodyTag:a(href, init)
    local a = self:initTag(A.new(), init)
    a:setHref(href)
end

Body = __K2L_Class("dsl.Body", BodyTag)

function Body:____init()
    BodyTag.____init(self, "body")
end

B = __K2L_Class("dsl.B", BodyTag)

function B:____init()
    BodyTag.____init(self, "b")
end

P = __K2L_Class("dsl.P", BodyTag)

function P:____init()
    BodyTag.____init(self, "p")
end

H1 = __K2L_Class("dsl.H1", BodyTag)

function H1:____init()
    BodyTag.____init(self, "h1")
end

UL = __K2L_Class("dsl.UL", BodyTag)

function UL:____init()
    BodyTag.____init(self, "ul")
end

function UL:li(init)
    return self:initTag(LI.new(), init)
end

LI = __K2L_Class("dsl.LI", BodyTag)

function LI:____init()
    BodyTag.____init(self, "li")
end

A = __K2L_Class("dsl.A", BodyTag)

function A:____init()
    BodyTag.____init(self, "a")
end

function A:getHref()
    return self.attributes:getValue("href")
end

function A:setHref(value)
    local ____object_1 = self.attributes
    ____object_1:set("href", value)
end

local function getCssClass(self)
    return self.attributes:get("class")
end

local function setCssClass(self, value)
    if value == nil then
        self.attributes:remove("class")
    else
        local ____object_2 = self.attributes
        ____object_2:set("class", value)
    end
end

local ____lambda_1 = function(x) return __K2L_InstanceOf(x, Tag) end
local function getDepth(____this_1)
    return 1 + (____this_1.children:filter(____lambda_1):maxOfOrNull(function(it) return getDepth(it) end) or 0)
end

local function html(init)
    local ____value_1 = HTML.new()
    init(____value_1)
    return ____value_1
end

local Json = __K2L_Class("dsl.Json")

function Json:toString()
    local ____builder_1 = __K2L_StringBuilder.new()
    self:write(____builder_1)
    return ____builder_1:toString()
end

Json.JString = __K2L_Class("dsl.Json$JString", Json)

function Json.JString.new(value)
    return setmetatable({value = value}, Json.JString)
end

function Json.JString:write(sb)
    sb:append("\"")
    local ____text = self.value
    for ____i_2 = 1, #____text do
        local ch = ____text:sub(____i_2, ____i_2)
        if ch == "\"" then
            sb:append("\\\"")
        elseif ch == "\\" then
            sb:append("\\\\")
        elseif ch == "\n" then
            sb:append("\\n")
        else
            sb:append(ch)
        end
    end
    sb:append("\"")
end

__K2L_DataClass(Json.JString, {"value"})
Json.JNumber = __K2L_Class("dsl.Json$JNumber", Json)

function Json.JNumber.new(value)
    return setmetatable({value = value}, Json.JNumber)
end

function Json.JNumber:write(sb)
    sb:append(__K2L_Str(self.value))
end

__K2L_DataClass(Json.JNumber, {"value"})
Json.JBool = __K2L_Class("dsl.Json$JBool", Json)

function Json.JBool.new(value)
    return setmetatable({value = value}, Json.JBool)
end

function Json.JBool:write(sb)
    sb:append(tostring(self.value))
end

__K2L_DataClass(Json.JBool, {"value"})
Json.JNull = __K2L_Class("dsl.Json$JNull", Json)

function Json.JNull:write(sb)
    sb:append("null")
end

Json.JArray = __K2L_Class("dsl.Json$JArray", Json)

function Json.JArray.new(items)
    return setmetatable({items = items}, Json.JArray)
end

function Json.JArray:write(sb)
    sb:append("[")
    local ____list_1 = self.items
    for ____i_3 = 1, ____list_1.size do
        local item = ____list_1[____i_3]
        local i = ____i_3 - 1
        if i > 0 then
            sb:append(",")
        end
        item:write(sb)
    end
    sb:append("]")
end

Json.JObject = __K2L_Class("dsl.Json$JObject", Json)

function Json.JObject.new(fields)
    return setmetatable({fields = fields}, Json.JObject)
end

function Json.JObject:write(sb)
    sb:append("{")
    local first = true
    local ____map = self.fields
    local ____keys, ____values, ____n = ____map:____arrays()
    for ____i_4 = 1, ____n do
        local k, v = ____keys[____i_4], ____values[____i_4]
        if not first then
            sb:append(",")
        end
        first = false
        Json.JString.new(k):write(sb)
        sb:append(":")
        v:write(sb)
    end
    sb:append("}")
end

function Json.JObject:get(key)
    return self.fields:get(key)
end

local ObjectBuilder = __K2L_Class("dsl.ObjectBuilder")

function ObjectBuilder:____init()
    self.fields = __K2L_MapOf()
end

function ObjectBuilder:to(____this_2, value)
    local ____object_3 = self.fields
    ____object_3:set(____this_2, toJson(value))
end

function ObjectBuilder:obj(key, init)
    local ____object_4 = self.fields
    local ____value_2 = ObjectBuilder.new()
    init(____value_2)
    ____object_4:set(key, ____value_2:build())
end

function ObjectBuilder:array(key, init)
    local ____object_5 = self.fields
    local ____value_3 = ArrayBuilder.new()
    init(____value_3)
    ____object_5:set(key, ____value_3:build())
end

function ObjectBuilder:build()
    return Json.JObject.new(self.fields:toMap())
end

ArrayBuilder = __K2L_Class("dsl.ArrayBuilder")

function ArrayBuilder:____init()
    self.items = __K2L_ListOf()
end

function ArrayBuilder:unaryPlus(____this_3)
    self.items:add(toJson(____this_3))
end

function ArrayBuilder:obj(init)
    local ____arg = self.items
    local ____value_4 = ObjectBuilder.new()
    init(____value_4)
    ____arg:add(____value_4:build())
end

function ArrayBuilder:build()
    return Json.JArray.new(self.items:toList())
end

function toJson(value)
    if value == nil then
        return Json.JNull
    elseif __K2L_InstanceOf(value, Json) then
        return value
    elseif type(value) == "string" then
        return Json.JString.new(value)
    elseif type(value) == "boolean" then
        return Json.JBool.new(value)
    elseif math.type(value) == "integer" then
        return Json.JNumber.new(value)
    elseif math.type(value) == "float" then
        return Json.JNumber.new(value)
    elseif __K2L_InstanceOf(value, __K2L_List) then
        return Json.JArray.new(value:map(toJson))
    elseif __K2L_InstanceOf(value, __K2L_Map) then
        return Json.JObject.new(value:getEntries():associate(function(____destructured_1)
            local k, v = ____destructured_1.key, ____destructured_1.value
            return __K2L_Pair.new(__K2L_Str(k), toJson(v))
        end))
    else
        return Json.JString.new(__K2L_Str(value))
    end
end

local function json(init)
    local ____value_5 = ObjectBuilder.new()
    init(____value_5)
    return ____value_5:build()
end

local ____lambda_2 = function(x) return getmetatable(x) == A end
local function main()
    local page = html(function(____this_4)
        ____this_4:head(function(____this_5)
            ____this_5:title(function(____this_6)
                ____this_6:unaryPlus("Report <draft>")
            end)
        end)
        ____this_4:body(function(____this_7)
            setCssClass(____this_7, "main")
            ____this_7:h1(function(____this_8)
                ____this_8:unaryPlus("Sales & Revenue")
            end)
            ____this_7:p(function(____this_9)
                ____this_9:unaryPlus("Totals for")
                ____this_9:b(function(____this_10)
                    ____this_10:unaryPlus("Q3")
                end)
                ____this_9:set("data-id", "p1")
            end)
            ____this_7:ul(function(____this_11)
                local ____list_2 = __K2L_ListOf("apples", "pears", "plums")
                for i = 0, ____list_2.size - 1 do
                    local item = ____list_2[i + 1]
                    ____this_11:li(function(____this_12)
                        if i % 2 == 0 then
                            setCssClass(____this_12, "even")
                        end
                        ____this_12:unaryPlus(i + 1 .. ". " .. item)
                    end)
                end
            end)
            ____this_7:a("https://example.com/?q=1&r=2", function(____this_13)
                ____this_13:unaryPlus("link")
            end)
        end)
    end)
    io.write(__K2L_Str(page))
    local ____cast = page.children:last()
    if getmetatable(____cast) ~= Body then
        __K2L_CastFail(____cast, "dsl.Body")
    end
    local body = ____cast
    local ____arg_1 = __K2L_Str(getCssClass(body))
    local ____arg_2 = getDepth(page)
    local ____cast_1 = body.children:get(1)
    if not __K2L_InstanceOf(____cast_1, Tag) then
        __K2L_CastFail(____cast_1, "dsl.Tag")
    end
    print("body class=" .. ____arg_1 .. " depth=" .. ____arg_2 .. " p=" .. __K2L_Str(____cast_1:get("data-id")))
    setCssClass(body, nil)
    print("after: " .. __K2L_Str(getCssClass(body)) .. " " .. __K2L_Str(body.attributes))
    local link = body.children:filter(____lambda_2):single()
    print(link:getHref())
    local doc = json(function(____this_14)
        ____this_14:to("name", "k2l")
        ____this_14:to("version", 1)
        ____this_14:to("ratio", 0.75)
        ____this_14:to("stable", false)
        ____this_14:to("notes", nil)
        ____this_14:to("quote", "say \"hi\"\n")
        ____this_14:obj("owner", function(____this_15)
            ____this_15:to("login", "cale")
            ____this_15:to("tags", __K2L_ListOf("lua", "kotlin"))
        end)
        ____this_14:array("targets", function(____this_16)
            ____this_16:unaryPlus("5.1")
            ____this_16:unaryPlus(true)
            ____this_16:obj(function(____this_17)
                ____this_17:to("jit", true)
            end)
        end)
        ____this_14:to("extra", __K2L_MapOf(__K2L_Pair.new("a", 1), __K2L_Pair.new("b", __K2L_ListOf(1, 2))))
    end)
    print(__K2L_Str(doc))
    print(__K2L_Str(doc:get("owner")))
    local ____cast_2 = doc:get("targets")
    if getmetatable(____cast_2) ~= Json.JArray then
        __K2L_CastFail(____cast_2, "dsl.Json.JArray")
    end
    print(____cast_2.items.size)
    print(__K2L_Str(doc:get("missing") or "absent"))
    print(Json.JString.new("x"):equals(Json.JString.new("x")))
    print(__K2L_ListOf(Json.JNull, Json.JBool.new(true), Json.JNumber.new(3)):joinToString(" "))
end

__K2L_RunMain(main)
return {Element = Element, TextElement = TextElement, escape = escape, Tag = Tag, TagWithText = TagWithText, HTML = HTML, Head = Head, Title = Title, BodyTag = BodyTag, Body = Body, B = B, P = P, H1 = H1, UL = UL, LI = LI, A = A, getCssClass = getCssClass, setCssClass = setCssClass, getDepth = getDepth, html = html, Json = Json, ObjectBuilder = ObjectBuilder, ArrayBuilder = ArrayBuilder, toJson = toJson, json = json}
