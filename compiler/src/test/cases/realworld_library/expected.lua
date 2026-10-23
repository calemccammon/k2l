-- ==== main.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CloseAfter = ____lualib.__K2L_CloseAfter
local __K2L_FunInterface = ____lualib.__K2L_FunInterface
local __K2L_IsLowerCase = ____lualib.__K2L_IsLowerCase
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SimpleName = ____lualib.__K2L_SimpleName
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Unit = ____lualib.__K2L_Unit
local __K2L_Unpack = ____lualib.__K2L_Unpack

local ____Desk = require("service.Desk")
local ____Catalog = require("model.Catalog")
local SimClock = __K2L_Class("lib.SimClock", nil, ____Desk.Clock)

function SimClock:____init()
    self.today = 1
end

function SimClock:advance(days)
    self.today = self.today + days
end

local Rule = __K2L_Class("lib.Rule")

local ____lambda_1 = function(____p1)
    return __K2L_IsLowerCase[____p1] == true
end
local ____lambda_2 = function(media)
    return __K2L_StringToList(media.id):any(____lambda_1) and "id must be upper case" or nil
end
local ____lambda_3 = function() return "IdRule" end
local function rules(minTitle)
    local ____arg = __K2L_FunInterface(Rule, "check", function(it)
        return #it.title < minTitle and "title too short" or nil
    end)
    local ____object = __K2L_Class("lib.MainKt$rules$2", nil, Rule)
    function ____object:check(media)
        return __K2L_StringToList(media.id):any(____lambda_1) and "id must be upper case" or nil
    end
    function ____object:toString()
        return "IdRule"
    end
    return __K2L_ListOf(____arg, ____object)
end

local function counter(start)
    local ____object_1 = __K2L_Class("lib.MainKt$counter$1")
    function ____object_1:____init()
        self.n = start
    end
    function ____object_1:next()
        local ____old = self.n
        self.n = self.n + 1
        return ____old
    end
    ____object_1:____init()
    return ____object_1
end

local function announce()
    print("  [announcement] library opens")
end

local ____lambda_4 = function(it) return __K2L_Pair.new(it.name, it.fines) end
local ____lambda_5 = function(____p1) return print(__K2L_Str(____p1)) end
local ____lambda_6 = function(it) return it.id end
local ____lambda_7 = function(x) return getmetatable(x) == ____Catalog.Book end
local ____lambda_8 = function(it) return it.genre end
local ____lambda_9 = function() return "lambda" end
local function main()
    local records = __K2L_ListOf("id=B1; title=Dune; author=Frank Herbert; isbn=978-0441; genre=fiction", "id=B2; title=A Brief History of Time; author=Stephen Hawking; genre=science", "id=B3; title=Gruffalo; genre=kids", "id=D1; title=Alien; minutes=117", "id=d2; title=Up")
    local factories = __K2L_MapOf(__K2L_Pair.new("B", ____Catalog.Book.Companion), __K2L_Pair.new("D", ____Catalog.Dvd.Companion), __K2L_Pair.new("d", ____Catalog.Dvd.Companion))
    local ____out = {}
    local ____count = 0
    local ____items, ____n = records:____array()
    for ____i = 1, ____n do
        local line = ____items[____i]
        local ____result
        do
            local prefix = __K2L_Text.first(__K2L_Text.substringAfter(line, "id="))
            ____result = ____Catalog.parse(factories:getValue(prefix), line)
        end
        ____count = ____count + 1
        ____out[____count] = ____result
    end
    local items = __K2L_ListWrap(____out, ____count)
    print(__K2L_Str(items))
    local ____list = items:sorted()
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = it.title
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
    local ruleSet = rules(3)
    for ____i_3 = 1, items.size do
        local m = items[____i_3]
        local ____out_2 = {}
        local ____count_2 = 0
        local ____items_2, ____n_2 = ruleSet:____array()
        for ____i_2 = 1, ____n_2 do
            local it = ____items_2[____i_2]
            local ____value = it:check(m)
            if ____value ~= nil then
                ____count_2 = ____count_2 + 1
                ____out_2[____count_2] = ____value
            end
        end
        local problems = __K2L_ListWrap(____out_2, ____count_2)
        if problems:isNotEmpty() then
            print(m.id .. ": " .. __K2L_Str(problems))
        end
    end
    print(__K2L_Str(ruleSet:last()))
    local clock = SimClock.new()
    local outbox = ____Desk.Outbox.new("mail to")
    local desk = ____Desk.Desk.new(clock, outbox)
    desk:stock(__K2L_Unpack(items:toTypedArray()))
    local ann = ____Catalog.Member.new("Ann", 1)
    local ben = ____Catalog.Member.new("Ben", 2)
    local attempts = __K2L_ListOf(__K2L_Pair.new("B1", ann), __K2L_Pair.new("D1", ann), __K2L_Pair.new("B1", ben), __K2L_Pair.new("X9", ben), __K2L_Pair.new("B3", ann), __K2L_Pair.new("B2", ann), __K2L_Pair.new("d2", ben))
    for ____i_4 = 1, attempts.size do
        local ____item = attempts[____i_4]
        local id, member = ____item.first, ____item.second
        local ____ok, ____result_1 = pcall(function()
            local loan = desk:checkout(member, id)
            print(member.name .. " borrows " .. loan.media.title .. ", due d" .. loan:getDue())
        end)
        if not ____ok then
            local ____error = __K2L_ToThrowable(____result_1)
            if getmetatable(____error) == ____Desk.LibraryException then
                local e = ____error
                print("refused: " .. __K2L_Str(e.message))
            else
                error(____error, 0)
            end
        end
    end
    clock:advance(10)
    local ____arg_1 = clock.today
    local ____list_1 = desk:overdue()
    local ____out_3 = {}
    local ____count_3 = 0
    local ____items_3, ____n_3 = ____list_1:____array()
    for ____i_5 = 1, ____n_3 do
        local it = ____items_3[____i_5]
        ____count_3 = ____count_3 + 1
        ____out_3[____count_3] = it.media.id
    end
    print("overdue at d" .. ____arg_1 .. ": " .. __K2L_Str(__K2L_ListWrap(____out_3, ____count_3)))
    local ____result_2
    local ____ok_1, ____result_3 = pcall(function()
        print("fees: " .. __K2L_Str(__K2L_ListOf("D1", "d2"):map(function(...) return desk:checkin(...) end)))
        clock:advance(20)
        print("fee B3: " .. desk:checkin("B3"))
    end)
    if ____ok_1 then
        outbox:close()
    else
        __K2L_CloseAfter(outbox, ____result_3)
    end
    if not ____ok_1 then
        error(____result_3, 0)
    end
    print("outbox closed: " .. tostring(outbox.closed))
    __K2L_RunCatching(function()
        desk:notify(ann, "late")
        return __K2L_Unit
    end):onFailure(function(it)
        print("after close: " .. __K2L_Str(it.message))
    end)
    print("fines: " .. __K2L_Str(__K2L_ListOf(ann, ben):associate(____lambda_4)))
    local ____list_2 = ____Desk.Desk.Report.new(desk, "inventory"):lines()
    for ____i_6 = 1, ____list_2.size do
        local it = ____list_2[____i_6];
        (____lambda_5)(it)
    end
    print(desk:getAvailable():joinToString(nil, nil, nil, nil, nil, ____lambda_6))
    print(__K2L_Str(desk:log()))
    local genres = items:filter(____lambda_7):groupingBy(____lambda_8):eachCount()
    local ____values = ____Catalog.Genre.____values
    local ____result_4 = __K2L_Map.new()
    for ____i_7 = 1, #____values do
        local it = ____values[____i_7]
        local ____result_5
        ____result_5 = genres:get(it) or 0
        local ____value_1 = ____result_5
        ____result_4:put(it, ____value_1)
    end
    print(__K2L_Str(____result_4))
    local longest = items:maxBy(function(it)
        local ____receiver = getmetatable(it) == ____Catalog.Dvd and it or nil
        return ____receiver and (getmetatable(it) == ____Catalog.Dvd and it or nil).minutes or 0
    end)
    print(longest:describe())
    local c1 = counter(10)
    local c2 = counter(20)
    print(c1:next() .. " " .. c1:next() .. " " .. c2:next() .. " same class: " .. tostring(__K2L_SimpleName(c1) == __K2L_SimpleName(c2)))
    local opening = function(...)
        announce(...)
        return __K2L_Unit
    end
    print("result: " .. __K2L_Str(opening()))
    local actions = __K2L_ListOf(function(...)
        announce(...)
        return __K2L_Unit
    end, ____lambda_9)
    local ____out_4 = {}
    local ____count_4 = 0
    local ____items_4, ____n_4 = actions:____array()
    for ____i_8 = 1, ____n_4 do
        local it = ____items_4[____i_8]
        ____count_4 = ____count_4 + 1
        ____out_4[____count_4] = it()
    end
    print(__K2L_Str(__K2L_ListWrap(____out_4, ____count_4)))
    print("desks opened: " .. ____Desk.desksOpened)
    for ____i_9 = 1, items.size do
        local it = items[____i_9]
        do
            if getmetatable(it) == ____Catalog.Dvd then
                goto ____inline_end
            end
            io.write(it.id .. " ")
            ::____inline_end::
        end
    end
    print()
    local ____value_2 = __K2L_StringBuilder.new()
    local ____result_6
    do
        local ____result_7 = __K2L_Map.new()
        local ____items_5, ____n_5 = items:____array()
        for ____i_10 = 1, ____n_5 do
            local it = ____items_5[____i_10]
            local ____value_3 = __K2L_SimpleName(it)
            local ____group = ____result_7:get(____value_3)
            if ____group == nil then
                ____group = __K2L_List.new()
                ____result_7:put(____value_3, ____group)
            end
            ____group:add(it)
        end
        local ____items_6, ____n_6 = ____result_7:____entryArray()
        for ____i_11 = 1, ____n_6 do
            local ____entry = ____items_6[____i_11]
            do
                local k, v = ____entry.key, ____entry.value
                ____value_2:append(__K2L_Str(k) .. "=" .. v.size .. ";")
            end
        end
        ____result_6 = ____value_2:toString()
    end
    local summary = ____result_6
    print(summary)
end

__K2L_RunMain(main)
return {SimClock = SimClock, Rule = Rule, rules = rules, announce = announce}
-- ==== model/Catalog.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_EnumValueOf = ____lualib.__K2L_EnumValueOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_SimpleName = ____lualib.__K2L_SimpleName
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_Text = ____lualib.__K2L_Text

local Loan
local MAX_LOANS = 3
local Identified = __K2L_Class("lib.model.Identified")

function Identified:describe()
    return "#" .. self.id
end

local Factory = __K2L_Class("lib.model.Factory")
local Genre = __K2L_Class("lib.model.Genre")

function Genre:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Genre:toString()
    return self.name
end

function Genre:compareTo(other)
    return self.ordinal - other.ordinal
end

Genre.FICTION = Genre.new("FICTION", 0)
Genre.SCIENCE = Genre.new("SCIENCE", 1)
Genre.HISTORY = Genre.new("HISTORY", 2)
Genre.KIDS = Genre.new("KIDS", 3)
Genre.____values = {Genre.FICTION, Genre.SCIENCE, Genre.HISTORY, Genre.KIDS}
local Media = __K2L_Class("lib.model.Media", nil, Identified)
Media.____comparable = true

function Media:____init(id, title)
    self.id = id
    self.title = title
end

function Media.new(id, title)
    return setmetatable({id = id, title = title}, Media)
end

function Media:getLateFeePerDay()
    return 25
end

function Media:compareTo(other)
    return __K2L_Text.compare(self.title:lower(), other.title:lower())
end

function Media:describe()
    return Identified.describe(self) .. " \"" .. self.title .. "\""
end

function Media:toString()
    return __K2L_Str(__K2L_SimpleName(self)) .. "(" .. self.id .. ")"
end

local Book = __K2L_Class("lib.model.Book", Media)

function Book:____init(id, title, author, isbn, genre)
    Media.____init(self, id, title)
    self.author = author
    self.isbn = isbn
    self.genre = genre
    self.loanDays = self.genre == Genre.KIDS and 7 or 21
end

function Book:getLoanDays()
    return self.loanDays
end

function Book:describe()
    return Media.describe(self) .. " by " .. self.author
end

Book.Companion = __K2L_Class("lib.model.Book$Companion", nil, Factory)

function Book.Companion:create(fields)
    local ____arg = fields:getValue("id")
    local ____arg_1 = fields:getValue("title")
    local ____arg_2 = fields:get("author") or "anonymous"
    local ____arg_3 = fields:get("isbn") or ""
    local ____receiver = fields:get("genre")
    return Book.new(____arg, ____arg_1, ____arg_2, ____arg_3, __K2L_EnumValueOf(Genre, ____receiver and ____receiver:upper() or "FICTION"))
end

local Dvd = __K2L_Class("lib.model.Dvd", Media)

function Dvd:____init(id, title, minutes)
    Media.____init(self, id, title)
    self.minutes = minutes
    self.lateFeePerDay = 100
end

function Dvd:getLoanDays()
    return 7
end

function Dvd:getLateFeePerDay()
    return self.lateFeePerDay
end

Dvd.Companion = __K2L_Class("lib.model.Dvd$Companion", nil, Factory)

function Dvd.Companion:create(fields)
    local ____arg_4 = fields:getValue("id")
    local ____arg_5 = fields:getValue("title")
    local ____receiver_1 = fields:get("minutes")
    return Dvd.new(____arg_4, ____arg_5, ____receiver_1 and __K2L_StringToIntOrNull(____receiver_1) or 90)
end

local Member = __K2L_Class("lib.model.Member")

function Member:____init(name, id)
    self.name = name
    self.id = id
    self.fines = 0
    self.loans = __K2L_ListOf()
end

function Member:getCanBorrow()
    return self.loans.size < MAX_LOANS and self.fines < 500
end

__K2L_DataClass(Member, {"name", "id"})
Loan = __K2L_Class("lib.model.Loan")

function Loan.new(media, member, day)
    return setmetatable({media = media, member = member, day = day}, Loan)
end

function Loan:getDue()
    return self.day + self.media:getLoanDays()
end

__K2L_DataClass(Loan, {"media", "member", "day"})

local ____lambda_1 = function(____p1) return __K2L_StringTrim(____p1) end
local function parse(self, line)
    return self:create(__K2L_StringSplit(line, ";"):associate(function(field)
        local ____destructured = __K2L_Text.split(field, {"="}, 2):map(____lambda_1)
        local key, value = ____destructured[1], ____destructured[2]
        return __K2L_Pair.new(key, value)
    end))
end

return {MAX_LOANS = MAX_LOANS, Identified = Identified, Factory = Factory, Genre = Genre, Media = Media, Book = Book, Dvd = Dvd, Member = Member, Loan = Loan, parse = parse}
-- ==== service/Desk.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_Str = ____lualib.__K2L_Str

local ____exports = {}
local ____Catalog = require("model.Catalog")
local LibraryException = __K2L_Class("lib.service.LibraryException", __K2L_Exception)

function LibraryException:____init(message)
    __K2L_Exception.____init(self, message)
end

local Clock = __K2L_Class("lib.service.Clock")
local Notifier = __K2L_Class("lib.service.Notifier")
local Outbox = __K2L_Class("lib.service.Outbox", nil, Notifier)

function Outbox:____init(prefix)
    self.prefix = prefix
    self.messages = __K2L_ListOf()
    self.closed = false
end

function Outbox:notify(member, text)
    if self.closed then
        error(__K2L_IllegalStateException.new("outbox closed"))
    end
    self.messages:add(self.prefix .. " " .. member.name .. ": " .. text)
end

local ____lambda_1 = function(____p1) return print(__K2L_Str(____p1)) end
function Outbox:close()
    self.closed = true
    local ____list = self.messages
    for ____i = 1, ____list.size do
        local it = ____list[____i];
        (____lambda_1)(it)
    end
    self.messages:clear()
end

____exports.desksOpened = 0
local Desk = __K2L_Class("lib.service.Desk", nil, Notifier)

function Desk:____init(clock, notifier)
    self.clock = clock
    self.____delegate_Notifier = notifier
    self.shelf = __K2L_SortedMapOf(nil)
    self.history = __K2L_ListOf()
    self.active = __K2L_ListOf()
    ____exports.desksOpened = ____exports.desksOpened + 1
end

function Desk:stock(...)
    local items = __K2L_ArrayOf(...)
    for ____i_1 = 1, items.size do
        local it = items[____i_1]
        do
            local ____object = self.shelf
            local ____key = it.id
            ____object:set(____key, it)
        end
    end
end

function Desk:getAvailable()
    local ____list_1 = self.shelf:getValues()
    local ____out = {}
    local ____count = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_3 = 1, ____n_1 do
        local m = ____items_1[____i_3]
        local ____result
        do
            local ____list_2 = self.active
            local ____result_1 = true
            local ____items, ____n = ____list_2:____array()
            for ____i_2 = 1, ____n do
                local it = ____items[____i_2]
                if __K2L_Equals(it.media, m) then
                    ____result_1 = false
                    break
                end
            end
            ____result = ____result_1
        end
        if ____result then
            ____count = ____count + 1
            ____out[____count] = m
        end
    end
    return __K2L_ListWrap(____out, ____count)
end

function Desk:checkout(member, id)
    local ____value = self.shelf:get(id)
    if ____value == nil then
        error(LibraryException.new("no such item " .. id))
    end
    local media = ____value
    if not member:getCanBorrow() then
        error(LibraryException.new(member.name .. " cannot borrow (loans=" .. member.loans.size .. "/" .. ____Catalog.MAX_LOANS .. ", fines=" .. member.fines .. ")"))
    end
    local ____list_3 = self.active
    local ____result_2 = false
    local ____items_2, ____n_2 = ____list_3:____array()
    for ____i_4 = 1, ____n_2 do
        local it = ____items_2[____i_4]
        if __K2L_Equals(it.media, media) then
            ____result_2 = true
            break
        end
    end
    if ____result_2 then
        error(LibraryException.new(__K2L_Str(media) .. " is already on loan"))
    end
    local ____value_1 = ____Catalog.Loan.new(media, member, self.clock.today)
    self.active:add(____value_1)
    member.loans:add(____value_1)
    self.history:add("out " .. media.id .. " " .. member.name .. " d" .. self.clock.today)
    return ____value_1
end

function Desk:checkin(id)
    local ____list_4 = self.active
    local ____result_3
    local ____items_3, ____n_3 = ____list_4:____array()
    for ____i_5 = 1, ____n_3 do
        local it = ____items_3[____i_5]
        if it.media.id == id then
            ____result_3 = it
            break
        end
    end
    if ____result_3 == nil then
        error(LibraryException.new(id .. " is not on loan"))
    end
    local loan = ____result_3
    self.active:remove(loan)
    loan.member.loans:remove(loan)
    local late = math.max(self.clock.today - loan:getDue(), 0)
    local fee = late * loan.media:getLateFeePerDay()
    if fee > 0 then
        local ____object_1 = loan.member
        ____object_1.fines = ____object_1.fines + fee
        self:notify(loan.member, "late by " .. late .. " days, fee " .. fee)
    end
    self.history:add("in " .. loan.media.id .. " late=" .. late)
    return fee
end

local ____lambda_2 = function(it) return it:getDue() end
function Desk:overdue()
    local ____list_5 = self.active
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_4, ____n_4 = ____list_5:____array()
    for ____i_6 = 1, ____n_4 do
        local it = ____items_4[____i_6]
        if it:getDue() < self.clock.today then
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = it
        end
    end
    return __K2L_ListWrap(____out_1, ____count_1):sortedBy(____lambda_2)
end

function Desk:log()
    return self.history:toList()
end

Desk.Report = __K2L_Class("lib.service.Desk$Report")

function Desk.Report:____init(____outer, title)
    self.____outer = ____outer
    self.title = title
end

function Desk.Report:lines()
    local ____builder = __K2L_ListOf()
    do
        ____builder:add("== " .. self.title .. " (day " .. self.____outer.clock.today .. ")")
        local ____collection = self.____outer.shelf:getValues()
        local ____items_5, ____n_5 = ____collection:____array()
        for ____i_8 = 1, ____n_5 do
            local m = ____items_5[____i_8]
            do
                local ____list_6 = self.____outer.active
                local ____result_4
                local ____items_6, ____n_6 = ____list_6:____array()
                for ____i_7 = 1, ____n_6 do
                    local it = ____items_6[____i_7]
                    if __K2L_Equals(it.media, m) then
                        ____result_4 = it
                        break
                    end
                end
                local loan = ____result_4
                ____builder:add(m:describe() .. " -> " .. (loan and loan.member.name .. " due d" .. loan:getDue() or "available"))
            end
        end
    end
    return ____builder
end

function Desk:notify(...)
    return self.____delegate_Notifier:notify(...)
end

____exports.LibraryException = LibraryException
____exports.Clock = Clock
____exports.Notifier = Notifier
____exports.Outbox = Outbox
____exports.Desk = Desk
return ____exports
