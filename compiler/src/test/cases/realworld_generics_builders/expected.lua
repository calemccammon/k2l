local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_StringPadEnd = ____lualib.__K2L_StringPadEnd
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_StringToDouble = ____lualib.__K2L_StringToDouble
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringTrimEnd = ____lualib.__K2L_StringTrimEnd
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Body, Text, Ul, Align, Config
local Tag = __K2L_Class("generics.builders.Tag")

function Tag:____init(name)
    self.name = name
    self.children = __K2L_ListOf()
    self.attributes = __K2L_MapOf()
end

function Tag:attr(key, value)
    local ____object = self.attributes
    ____object:set(key, __K2L_Str(value))
    return self
end

function Tag:unaryPlus(____this)
    self.children:add(____this)
end

function Tag:child(tag, init)
    init(tag)
    self.children:add(tag)
    return tag
end

function Tag:render(out, indent)
    if out == nil then
        out = __K2L_StringBuilder.new()
    end
    if indent == nil then
        indent = ""
    end
    local attrs = self.attributes:getEntries():joinToString("", nil, nil, nil, nil, function(____destructured)
        local k, v = ____destructured.key, ____destructured.value
        return " " .. k .. "=\"" .. v .. "\""
    end)
    local ____list = self.children
    local ____result = true
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        if type(it) ~= "string" then
            ____result = false
            break
        end
    end
    if ____result then
        return out:append(indent .. "<" .. self.name .. attrs .. ">" .. self.children:joinToString(" ") .. "</" .. self.name .. ">\n")
    end
    out:append(indent .. "<" .. self.name .. attrs .. ">\n")
    local ____list_1 = self.children
    for ____i_1 = 1, ____list_1.size do
        local c = ____list_1[____i_1]
        if __K2L_InstanceOf(c, Tag) then
            c:render(out, indent .. "  ")
        else
            out:append(indent .. "  " .. __K2L_Str(c) .. "\n")
        end
    end
    return out:append(indent .. "</" .. self.name .. ">\n")
end

local Html = __K2L_Class("generics.builders.Html", Tag)

function Html:____init()
    Tag.____init(self, "html")
end

function Html:body(init)
    return self:child(Body.new(), init)
end

Body = __K2L_Class("generics.builders.Body", Tag)

function Body:____init()
    Tag.____init(self, "body")
end

function Body:h1(text)
    return self:child(Text.new("h1"), function(____this_1)
        ____this_1:unaryPlus(text)
    end)
end

function Body:p(init)
    return self:child(Text.new("p"), init)
end

function Body:ul(init)
    return self:child(Ul.new(), init)
end

Text = __K2L_Class("generics.builders.Text", Tag)

function Text:____init(name)
    Tag.____init(self, name)
end

function Text:b(text)
    self:unaryPlus("*" .. text .. "*")
end

Ul = __K2L_Class("generics.builders.Ul", Tag)

function Ul:____init()
    Tag.____init(self, "ul")
end

function Ul:li(text)
    return self:child(Text.new("li"), function(____this_2)
        ____this_2:unaryPlus(text)
    end)
end

local ____lambda_1 = function(it) return __K2L_Str(it) end
function Ul:items(xs, label)
    if label == nil then
        label = ____lambda_1
    end
    local ____items_1, ____n_1 = xs:____array()
    for ____i_2 = 1, ____n_1 do
        local it = ____items_1[____i_2]
        self:li(label(it))
    end
end

local function html(init)
    local ____value = Html.new()
    init(____value)
    return ____value
end

local Column = __K2L_Class("generics.builders.Column")

function Column.new(title, align, get, show)
    return setmetatable({title = title, align = align, get = get, show = show}, Column)
end

Align = __K2L_Class("generics.builders.Align")

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
Align.____values = {Align.LEFT, Align.RIGHT}
local TableBuilder = __K2L_Class("generics.builders.TableBuilder")

function TableBuilder:____init()
    self.columns = __K2L_ListOf()
end

local ____lambda_2 = function(it) return __K2L_Str(it) end
function TableBuilder:column(title, align, show, get)
    if align == nil then
        align = Align.LEFT
    end
    if show == nil then
        show = ____lambda_2
    end
    self.columns:add(Column.new(title, align, get, show))
end

function TableBuilder:number(title, digits, get)
    if digits == nil then
        digits = 2
    end
    self:column(title, Align.RIGHT, function(it)
        return __K2L_StringFormat("%." .. digits .. "f", it)
    end, get)
end

local function cell(self, row)
    return self.show(self.get(row))
end

local ____lambda_3 = function(it) return __K2L_Text.repeatCount("-", it) end
local function ____table(rows, build)
    local ____value_1 = TableBuilder.new()
    build(____value_1)
    local columns = ____value_1.columns
    local ____out = {}
    local ____count = 0
    local ____items_3, ____n_3 = rows:____array()
    for ____i_4 = 1, ____n_3 do
        local row = ____items_3[____i_4]
        local ____result_1
        do
            local ____out_1 = {}
            local ____count_1 = 0
            local ____items_2, ____n_2 = columns:____array()
            for ____i_3 = 1, ____n_2 do
                local it = ____items_2[____i_3]
                ____count_1 = ____count_1 + 1
                ____out_1[____count_1] = cell(it, row)
            end
            ____result_1 = __K2L_ListWrap(____out_1, ____count_1)
        end
        ____count = ____count + 1
        ____out[____count] = ____result_1
    end
    local cells = __K2L_ListWrap(____out, ____count)
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_4, ____n_4 = columns:____array()
    for ____i_5 = 1, ____n_4 do
        local c = ____items_4[____i_5]
        local i = ____i_5 - 1
        local ____result_2
        ____result_2 = math.max(#c.title, cells:maxOfOrNull(function(it) return #it:get(i) end) or 0)
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = ____result_2
    end
    local widths = __K2L_ListWrap(____out_2, ____count_2)
    local function line(values)
        local ____out_3 = {}
        local ____count_3 = 0
        local ____items_5, ____n_5 = values:____array()
        for ____i_6 = 1, ____n_5 do
            local v = ____items_5[____i_6]
            local i = ____i_6 - 1
            local ____result_3
            ____result_3 = columns:get(i).align == Align.RIGHT and __K2L_StringPadStart(v, widths:get(i)) or __K2L_StringPadEnd(v, widths:get(i))
            ____count_3 = ____count_3 + 1
            ____out_3[____count_3] = ____result_3
        end
        return __K2L_StringTrimEnd(__K2L_ListWrap(____out_3, ____count_3):joinToString(" | "))
    end
    local ____builder = __K2L_StringBuilder.new()
    do
        local ____out_4 = {}
        local ____count_4 = 0
        local ____items_6, ____n_6 = columns:____array()
        for ____i_7 = 1, ____n_6 do
            local it = ____items_6[____i_7]
            ____count_4 = ____count_4 + 1
            ____out_4[____count_4] = it.title
        end
        ____builder:appendLine(line(__K2L_ListWrap(____out_4, ____count_4)))
        ____builder:appendLine(widths:joinToString("-+-", nil, nil, nil, nil, ____lambda_3))
        for ____i_8 = 1, cells.size do
            local it = cells[____i_8]
            ____builder:appendLine(line(it))
        end
    end
    return ____builder:toString()
end

local Setting = __K2L_Class("generics.builders.Setting")

function Setting.new(name, default, parse)
    return setmetatable({name = name, default = default, parse = parse}, Setting)
end

local ConfigBuilder = __K2L_Class("generics.builders.ConfigBuilder")

function ConfigBuilder:____init()
    self.values = __K2L_MapOf()
    self.errors = __K2L_ListOf()
end

function ConfigBuilder:to(____this_3, value)
    local ____object_1 = self.values
    ____object_1:set(____this_3, value)
end

function ConfigBuilder:from(____this_4, raw)
    local ____ok, ____result_4 = pcall(function()
        local ____object_2 = self.values
        ____object_2:set(____this_4, ____this_4.parse(raw))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_4)
        if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
            local e = ____error
            self.errors:add(____this_4.name .. ": " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
end

function ConfigBuilder:build()
    return Config.new(self.values:toMap(), self.errors:toList())
end

Config = __K2L_Class("generics.builders.Config")

function Config.new(values, errors)
    return setmetatable({values = values, errors = errors}, Config)
end

function Config:get(s)
    if self.values:containsKey(s) then
        return self.values:get(s)
    else
        return s.default
    end
end

local function config(block)
    local ____value_2 = ConfigBuilder.new()
    block(____value_2)
    return ____value_2:build()
end

local WORKERS = Setting.new("workers", 4, function(____p1) return __K2L_StringToInt(____p1) end)
local VERBOSE = Setting.new("verbose", false, function(it) return __K2L_Text.toBooleanStrict(it) end)
local NAME = Setting.new("name", "service", function(it) return it end)
local RATIO = Setting.new("ratio", 0.5, function(s)
    local ____value_3 = __K2L_StringToDouble(s)
    if not (____value_3 >= 0.0 and ____value_3 <= 1.0) then
        error(__K2L_IllegalArgumentException.new("ratio out of range: " .. ____value_3))
    end
    return ____value_3
end)
local Planet = __K2L_Class("generics.builders.Planet")

function Planet.new(name, moons, radiusKm, rings)
    return setmetatable({name = name, moons = moons, radiusKm = radiusKm, rings = rings}, Planet)
end

__K2L_DataClass(Planet, {"name", "moons", "radiusKm", "rings"})

local ____lambda_4 = function(it) return "<" .. it .. ">" end
local ____lambda_5 = function(it) return it.name end
local ____lambda_6 = function(it) return it.moons end
local ____lambda_7 = function(it) return it.radiusKm end
local ____lambda_8 = function(it) return it and "yes" or "no" end
local ____lambda_9 = function(it) return it.rings end
local ____lambda_10 = function(it) return it.radiusKm / 6371.0 end
local ____lambda_11 = function(it) return #it end
local ____lambda_12 = function(it) return it:upper() end
local function main()
    local page = html(function(____this_5)
        ____this_5:attr("lang", "en")
        ____this_5:body(function(____this_6)
            ____this_6:attr("class", "doc"):attr("id", 7)
            ____this_6:h1("Generics")
            ____this_6:p(function(____this_7)
                ____this_7:unaryPlus("Kotlin has")
                ____this_7:b("declaration-site")
                ____this_7:unaryPlus("variance.")
            end)
            ____this_6:ul(function(____this_8)
                ____this_8:li("in")
                ____this_8:items(__K2L_ListOf("out", "star"), ____lambda_4)
                ____this_8:items(__K2L_IntRange.new(1, 2))
            end)
        end)
    end)
    io.write(__K2L_Str(page:render()))
    local planets = __K2L_ListOf(Planet.new("Mercury", 0, 2439.7, false), Planet.new("Earth", 1, 6371.0, false), Planet.new("Jupiter", 95, 69911.0, true), Planet.new("Saturn", 146, 58232.0, true))
    io.write(____table(planets, function(____this_9)
        ____this_9:column("name", nil, nil, ____lambda_5)
        ____this_9:column("moons", Align.RIGHT, nil, ____lambda_6)
        ____this_9:number("radius (km)", 1, ____lambda_7)
        ____this_9:column("rings", nil, ____lambda_8, ____lambda_9)
        ____this_9:number("vs earth", nil, ____lambda_10)
    end))
    io.write(____table(__K2L_ListOf("a", "bbb", "cc"), function(____this_10)
        ____this_10:column("len", Align.RIGHT, nil, ____lambda_11)
        ____this_10:column("upper", nil, nil, ____lambda_12)
    end))
    local cfg = config(function(____this_11)
        ____this_11:from(WORKERS, "16")
        ____this_11:to(VERBOSE, true)
        ____this_11:from(RATIO, "1.5")
        ____this_11:from(VERBOSE, "yes")
        ____this_11:to(NAME, "api")
    end)
    local workers = cfg:get(WORKERS)
    print("workers=" .. workers * 2 .. " verbose=" .. tostring(cfg:get(VERBOSE)) .. " name=" .. cfg:get(NAME):upper() .. " ratio=" .. cfg:get(RATIO))
    print("errors=" .. __K2L_Str(cfg.errors))
end

__K2L_RunMain(main)
return {Tag = Tag, Html = Html, Body = Body, Text = Text, Ul = Ul, html = html, Column = Column, Align = Align, TableBuilder = TableBuilder, ____table = ____table, Setting = Setting, ConfigBuilder = ConfigBuilder, Config = Config, config = config, WORKERS = WORKERS, VERBOSE = VERBOSE, NAME = NAME, RATIO = RATIO, Planet = Planet}
