local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_CharSequenceText = ____lualib.__K2L_CharSequenceText
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_FunInterface = ____lualib.__K2L_FunInterface
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyProperty = ____lualib.__K2L_ReadOnlyProperty
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringIsBlank = ____lualib.__K2L_StringIsBlank
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_Text = ____lualib.__K2L_Text

local Validator = __K2L_Class("generics.properties.Validator")

function Validator:describe(value)
    return self:validate(value) or "valid"
end

local function ____and(self, other)
    return __K2L_FunInterface(Validator, "validate", function(v) return self:validate(v) or other:validate(v) end)
end

local Mapper = __K2L_Class("generics.properties.Mapper")

local function ____then(____this, ____next)
    return __K2L_FunInterface(Mapper, "map", function(it) return ____next:map(____this:map(it)) end)
end

local Validated = __K2L_Class("generics.properties.Validated")

function Validated:____init(value, validator, errors)
    self.value = value
    self.validator = validator
    self.errors = errors
end

function Validated.new(value, validator, errors)
    return setmetatable({value = value, validator = validator, errors = errors}, Validated)
end

function Validated:getValue(thisRef, property)
    return self.value
end

function Validated:setValue(thisRef, property, value)
    local ____error = self.validator:validate(value)
    if ____error ~= nil then
        self.errors:add(property.name .. ": " .. ____error)
    else
        self.value = value
    end
end

local Observed = __K2L_Class("generics.properties.Observed")

function Observed:____init(initial, listeners)
    self.listeners = listeners
    self.value = initial
end

function Observed:getValue(thisRef, property)
    return self.value
end

function Observed:setValue(thisRef, property, value)
    local old = self.value
    self.value = value
    if not __K2L_Equals(old, value) then
        local ____list = self.listeners
        local ____mod = ____list.____modCount
        for ____i = 1, ____list.size do
            local it = ____list[____i]
            it(old, value)
            if ____list.____modCount ~= ____mod and ____list:____comodified(____i) then
                break
            end
        end
    end
end

local function computed(compute)
    return __K2L_ReadOnlyProperty(function(_, _) return compute() end)
end

local positive = __K2L_FunInterface(Validator, "validate", function(it)
    if it > 0 then
        return nil
    else
        return "must be positive, was " .. it
    end
end)

local function atMost(n)
    return __K2L_FunInterface(Validator, "validate", function(it)
        if it <= n then
            return nil
        else
            return "must be at most " .. n .. ", was " .. it
        end
    end)
end

local notBlank = __K2L_FunInterface(Validator, "validate", function(it)
    return __K2L_StringIsBlank(__K2L_CharSequenceText(it)) and "must not be blank" or nil
end)

local function oneOf(...)
    local allowed = __K2L_ArrayOf(...)
    return __K2L_FunInterface(Validator, "validate", function(it)
        if allowed:contains(it) then
            return nil
        else
            return "must be one of " .. __K2L_Str(allowed:toList()) .. ", was " .. __K2L_Str(it)
        end
    end)
end

local Settings = __K2L_Class("generics.properties.Settings")

function Settings:____init()
    self.errors = __K2L_ListOf()
    self.changes = __K2L_ListOf()
    self.____threads_delegate = Validated.new(4, ____and(positive, atMost(64)), self.errors)
    self.____name_delegate = Validated.new("app", notBlank, self.errors)
    self.____mode_delegate = Validated.new("dev", oneOf("dev", "prod"), self.errors)
    self.____debug_delegate = Observed.new(false, self.changes)
    self.____tags_delegate = Observed.new(__K2L_ReadOnlyListOf(), self.changes)
    self.____summary_delegate = computed(function()
        return self:getName() .. "[" .. self:getMode() .. "] threads=" .. self:getThreads() .. " debug=" .. tostring(self:getDebug()) .. " tags=" .. __K2L_Str(self:getTags())
    end)
end

Settings.____threads_property = __K2L_PropertyRef.new("threads", "generics/properties/Settings.threads")

function Settings:getThreads()
    return self.____threads_delegate:getValue(self, Settings.____threads_property)
end

function Settings:setThreads(value)
    self.____threads_delegate:setValue(self, Settings.____threads_property, value)
end

Settings.____name_property = __K2L_PropertyRef.new("name", "generics/properties/Settings.name")

function Settings:getName()
    return self.____name_delegate:getValue(self, Settings.____name_property)
end

function Settings:setName(value)
    self.____name_delegate:setValue(self, Settings.____name_property, value)
end

Settings.____mode_property = __K2L_PropertyRef.new("mode", "generics/properties/Settings.mode")

function Settings:getMode()
    return self.____mode_delegate:getValue(self, Settings.____mode_property)
end

function Settings:setMode(value)
    self.____mode_delegate:setValue(self, Settings.____mode_property, value)
end

Settings.____debug_property = __K2L_PropertyRef.new("debug", "generics/properties/Settings.debug")

function Settings:getDebug()
    return self.____debug_delegate:getValue(self, Settings.____debug_property)
end

function Settings:setDebug(value)
    self.____debug_delegate:setValue(self, Settings.____debug_property, value)
end

Settings.____tags_property = __K2L_PropertyRef.new("tags", "generics/properties/Settings.tags")

function Settings:getTags()
    return self.____tags_delegate:getValue(self, Settings.____tags_property)
end

function Settings:setTags(value)
    self.____tags_delegate:setValue(self, Settings.____tags_property, value)
end

Settings.____summary_property = __K2L_PropertyRef.new("summary", "generics/properties/Settings.summary")

function Settings:getSummary()
    return self.____summary_delegate:getValue(self, Settings.____summary_property)
end

local Id = __K2L_Class("generics.properties.Id")
Id.____comparable = true

function Id:____init(raw)
    self.raw = raw
end

function Id.new(raw)
    return setmetatable({raw = raw}, Id)
end

function Id:compareTo(other)
    return __K2L_Compare(self.raw, other.raw)
end

function Id:toString()
    return "#" .. self.raw
end

function Id:hashCode()
    return self.raw
end

function Id:equals(other)
    return getmetatable(other) == Id and self.raw == other.raw
end

local Author = __K2L_Class("generics.properties.Author")

function Author:____init(id, name)
    self.id = id
    self.name = name
end

function Author.new(id, name)
    return setmetatable({id = id, name = name}, Author)
end

function Author:toString()
    return "Author(id=" .. __K2L_Str(self.id) .. ", name=" .. self.name .. ")"
end

function Author:hashCode()
    return (31 * __K2L_Hash(self.id) + __K2L_Hash(self.name) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Author:equals(other)
    return getmetatable(other) == Author and self.id:equals(other.id) and self.name == other.name
end

local Book = __K2L_Class("generics.properties.Book")

function Book:____init(id, title, author)
    self.id = id
    self.title = title
    self.author = author
end

function Book.new(id, title, author)
    return setmetatable({id = id, title = title, author = author}, Book)
end

function Book:toString()
    return "Book(id=" .. __K2L_Str(self.id) .. ", title=" .. self.title .. ", author=" .. __K2L_Str(self.author) .. ")"
end

function Book:hashCode()
    return (31 * (31 * __K2L_Hash(self.id) + __K2L_Hash(self.title)) + __K2L_Hash(self.author) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Book:equals(other)
    return getmetatable(other) == Book and self.id:equals(other.id) and self.title == other.title and self.author:equals(other.author)
end

local Store = __K2L_Class("generics.properties.Store")

function Store:____init(key)
    self.key = key
    self.items = __K2L_SortedMapOf()
    self.listeners = __K2L_ListOf()
end

function Store:onChange(l)
    self.listeners:add(l)
end

function Store:put(item)
    local event = self.items:put(self.key(item), item) == nil and "added" or "replaced"
    local ____list_1 = self.listeners
    local ____mod_1 = ____list_1.____modCount
    for ____i_1 = 1, ____list_1.size do
        local it = ____list_1[____i_1]
        it(event, item)
        if ____list_1.____modCount ~= ____mod_1 and ____list_1:____comodified(____i_1) then
            break
        end
    end
end

function Store:get(k)
    return self.items:get(k)
end

function Store:values()
    return self.items:getValues()
end

local ____lambda_1 = function() return __K2L_ListOf() end
local function record(____this_1, k, line)
    return ____this_1:getOrPut(k, ____lambda_1):add(line)
end

local ____lambda_2 = function(it)
    return __K2L_StringToInt(__K2L_StringTrim(it))
end
local ____lambda_3 = function(it) return it * it end
local ____lambda_4 = function(it) return "<" .. __K2L_Str(it) .. ">" end
local ____lambda_5 = function(it) return #it > 5 and "too long" or nil end
local ____lambda_6 = function(it) return it.id end
local ____lambda_7 = function(it) return it * it end
local ____lambda_8 = function(it) return "L" .. it end
local ____lambda_9 = function(x) return math.type(x) == "integer" end
local ____lambda_10 = function(x) return type(x) == "string" end
local function main()
    print("== delegates")
    local s = Settings.new()
    s.changes:add(function(old, new)
        print("  changed " .. __K2L_Str(old) .. " -> " .. __K2L_Str(new))
    end)
    s:setThreads(16)
    s:setThreads(0)
    s:setThreads(100)
    s:setName("  ")
    s:setName("api")
    s:setMode("test")
    s:setMode("prod")
    s:setDebug(true)
    s:setDebug(true)
    s:setTags(__K2L_ReadOnlyListOf("a", "b"))
    print(s:getSummary())
    local ____list_2 = s.errors
    for ____i_2 = 1, ____list_2.size do
        local it = ____list_2[____i_2]
        print("  error: " .. it)
    end
    print("== fun interfaces")
    local parse = __K2L_FunInterface(Mapper, "map", ____lambda_2)
    local square = __K2L_FunInterface(Mapper, "map", ____lambda_3)
    local show = __K2L_FunInterface(Mapper, "map", ____lambda_4)
    local pipeline = ____then(____then(parse, square), show)
    print(__K2L_Str(__K2L_ReadOnlyListOf(" 3", "12 ", "-5"):map(function(...) return pipeline:map(...) end)))
    local lengthCheck = ____and(notBlank, __K2L_FunInterface(Validator, "validate", ____lambda_5))
    local ____list_3 = __K2L_ReadOnlyListOf("", "ok", "toolong")
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list_3:____array()
    for ____i_3 = 1, ____n do
        local it = ____items[____i_3]
        ____count = ____count + 1
        ____out[____count] = lengthCheck:describe(it)
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    print("== typed ids")
    local tolkien = Author.new(Id.new(1), "Tolkien")
    local books = Store.new(____lambda_6)
    local log = __K2L_ListOf()
    books:onChange(function(event, b)
        log:add(event .. " " .. __K2L_Str(b.id) .. " " .. b.title)
    end)
    books:put(Book.new(Id.new(20), "The Hobbit", tolkien.id))
    books:put(Book.new(Id.new(10), "Silmarillion", tolkien.id))
    books:put(Book.new(Id.new(20), "The Hobbit (2nd ed.)", tolkien.id))
    local ____list_4 = books:values()
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_4:____array()
    for ____i_4 = 1, ____n_1 do
        local it = ____items_1[____i_4]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = it.title
    end
    local ____arg = __K2L_Str(__K2L_ListWrap(____out_1, ____count_1))
    local ____receiver = books:get(Id.new(10))
    print("values=" .. ____arg .. " get=" .. __K2L_Str(____receiver and ____receiver.title) .. " missing=" .. __K2L_Str(books:get(Id.new(99))))
    print("log=" .. __K2L_Str(log))
    local ids = __K2L_ReadOnlyListOf(Id.new(3), Id.new(1), Id.new(2)):sorted()
    local ____arg_1 = __K2L_Str(ids)
    local ____arg_2 = __K2L_Str(ids:max())
    local ____sum = 0
    local ____items_2, ____n_2 = ids:____array()
    for ____i_5 = 1, ____n_2 do
        local it = ____items_2[____i_5]
        ____sum = ____sum + it.raw
    end
    print("ids=" .. ____arg_1 .. " max=" .. ____arg_2 .. " raw sum=" .. ____sum .. " equal=" .. tostring(Id.new(1):equals(Id.new(1))))
    local ____list_5 = books:values()
    local ____result = __K2L_Map.new()
    local ____items_3, ____n_3 = ____list_5:____array()
    for ____i_6 = 1, ____n_3 do
        local it = ____items_3[____i_6]
        local ____value = it.author
        local ____group = ____result:get(____value)
        if ____group == nil then
            ____group = __K2L_List.new()
            ____result:put(____value, ____group)
        end
        ____group:add(it.id)
    end
    print("by author=" .. __K2L_Str(____result))
    print("== arrays and aliases")
    local ____result_1
    ____result_1 = __K2L_ListOfSize(5, ____lambda_7, "[Ljava.lang.Integer;")
    local squares = ____result_1
    local ____result_2
    ____result_2 = __K2L_ListOfSize(3, ____lambda_8, "[Ljava.lang.String;")
    local labels = ____result_2
    print(squares:contentToString() .. " " .. labels:joinToString() .. " " .. squares.size + labels.size)
    local mixed = __K2L_ReadOnlyListOf(1, "a", 2, "b", 3.5)
    local ____result_3
    ____result_3 = mixed:filter(____lambda_9):toTypedArray("[Ljava.lang.Integer;")
    local ints = ____result_3
    local ____result_4
    ____result_4 = mixed:filter(____lambda_10):toTypedArray("[Ljava.lang.String;")
    local strs = ____result_4
    print("ints=" .. ints:contentToString() .. " sum=" .. ints:sum() .. " strs=" .. strs:contentToString())
    local ____table = __K2L_SortedMapOf()
    local ____list_6 = __K2L_ReadOnlyListOf("apple", "avocado", "banana", "blueberry", "cherry")
    for ____i_7 = 1, ____list_6.size do
        local w = ____list_6[____i_7]
        record(____table, __K2L_Text.first(w), w)
    end
    print(__K2L_Str(____table))
end

__K2L_Main(main)
return {Validator = Validator, ____and = ____and, Mapper = Mapper, ____then = ____then, Validated = Validated, Observed = Observed, computed = computed, positive = positive, atMost = atMost, notBlank = notBlank, oneOf = oneOf, Settings = Settings, Id = Id, Author = Author, Book = Book, Store = Store, record = record}
