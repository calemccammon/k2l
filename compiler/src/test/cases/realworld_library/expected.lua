-- ==== main.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_EnumValues = ____lualib.__K2L_EnumValues
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_FunInterface = ____lualib.__K2L_FunInterface
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
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
__K2L_ClassInfo(SimClock, "lib.SimClock", "lib.SimClock", "class")

function SimClock:____init()
    self.today = 1
end

function SimClock:advance(days)
    self.today = self.today + days
end

local Rule = __K2L_Class("lib.Rule")
__K2L_ClassInfo(Rule, "lib.Rule", "lib.Rule", "interface")

local function rules(minTitle)
    local ____arg = __K2L_FunInterface(Rule, "check", function(it)
        return #it.title < minTitle and "title too short" or nil
    end)
    local ____object = __K2L_Class("lib.MainKt$rules$2", nil, Rule)
    __K2L_ClassInfo(____object, nil, "lib.MainKt$rules$2", "class", false)
    function ____object:check(media)
        return __K2L_StringToList(media.id):any(function(____p1) return ____p1:match("^%l$") ~= nil end) and "id must be upper case" or nil
    end
    function ____object:toString()
        return "IdRule"
    end
    return __K2L_ReadOnlyListOf(____arg, ____object)
end

local function counter(start)
    local ____object_1 = __K2L_Class("lib.MainKt$counter$1")
    __K2L_ClassInfo(____object_1, nil, "lib.MainKt$counter$1", "class", false)
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

local function main()
    local records = __K2L_ReadOnlyListOf("id=B1; title=Dune; author=Frank Herbert; isbn=978-0441; genre=fiction", "id=B2; title=A Brief History of Time; author=Stephen Hawking; genre=science", "id=B3; title=Gruffalo; genre=kids", "id=D1; title=Alien; minutes=117", "id=d2; title=Up")
    local factories = __K2L_ReadOnlyMapOf(__K2L_Pair.new("B", ____Catalog.Book.Companion), __K2L_Pair.new("D", ____Catalog.Dvd.Companion), __K2L_Pair.new("d", ____Catalog.Dvd.Companion))
    local items = records:map(function(line)
        local prefix = __K2L_Text.first(__K2L_Text.substringAfter(line, "id="))
        return ____Catalog.parse(factories:getValue(prefix), line)
    end)
    print(__K2L_Str(items))
    print(__K2L_Str(items:sorted():map(function(it) return it.title end)))
    local ruleSet = rules(3)
    local ____mod = items.____modCount
    for ____i = 1, items.size do
        local m = items[____i]
        local problems = ruleSet:mapNotNull(function(it) return it:check(m) end)
        if problems:isNotEmpty() then
            print(m.id .. ": " .. __K2L_Str(problems))
        end
        if items.____modCount ~= ____mod and items:____comodified(____i) then
            break
        end
    end
    print(__K2L_Str(ruleSet:last()))
    local clock = SimClock.new()
    local outbox = ____Desk.Outbox.new("mail to")
    local desk = ____Desk.Desk.new(clock, outbox)
    desk:stock(__K2L_Unpack(items:toTypedArray("[Llib.model.Media;")))
    local ann = ____Catalog.Member.new("Ann", 1)
    local ben = ____Catalog.Member.new("Ben", 2)
    local attempts = __K2L_ReadOnlyListOf(__K2L_Pair.new("B1", ann), __K2L_Pair.new("D1", ann), __K2L_Pair.new("B1", ben), __K2L_Pair.new("X9", ben), __K2L_Pair.new("B3", ann), __K2L_Pair.new("B2", ann), __K2L_Pair.new("d2", ben))
    local ____mod_1 = attempts.____modCount
    for ____i_1 = 1, attempts.size do
        local ____item = attempts[____i_1]
        local id, member = ____item.first, ____item.second
        local ____ok, ____result = pcall(function()
            local loan = desk:checkout(member, id)
            print(member.name .. " borrows " .. loan.media.title .. ", due d" .. loan:getDue())
        end)
        if not ____ok then
            local ____error = __K2L_ToThrowable(____result)
            if __K2L_InstanceOf(____error, ____Desk.LibraryException) then
                local e = ____error
                print("refused: " .. __K2L_Str(e.message))
            else
                error(____error, 0)
            end
        end
        if attempts.____modCount ~= ____mod_1 and attempts:____comodified(____i_1) then
            break
        end
    end
    clock:advance(10)
    print("overdue at d" .. clock.today .. ": " .. __K2L_Str(desk:overdue():map(function(it) return it.media.id end)))
    local ____result_1
    local ____ok_1, ____result_2 = pcall(function()
        print("fees: " .. __K2L_Str(__K2L_ReadOnlyListOf("D1", "d2"):map(function(...) return desk:checkin(...) end)))
        clock:advance(20)
        print("fee B3: " .. desk:checkin("B3"))
    end)
    if ____ok_1 then
        outbox:close()
    else
        pcall(outbox.close, outbox)
    end
    if not ____ok_1 then
        error(____result_2, 0)
    end
    print("outbox closed: " .. tostring(outbox.closed))
    __K2L_RunCatching(function()
        desk:notify(ann, "late")
        return __K2L_Unit
    end):onFailure(function(it)
        print("after close: " .. __K2L_Str(it.message))
    end)
    print("fines: " .. __K2L_Str(__K2L_ReadOnlyListOf(ann, ben):associate(function(it) return __K2L_Pair.new(it.name, it.fines) end)))
    local ____list = ____Desk.Desk.Report.new(desk, "inventory"):lines()
    local ____mod_2 = ____list.____modCount
    for ____i_2 = 1, ____list.size do
        local it = ____list[____i_2];
        (function(____p1) return print(__K2L_Str(____p1)) end)(it)
        if ____list.____modCount ~= ____mod_2 and ____list:____comodified(____i_2) then
            break
        end
    end
    print(desk:getAvailable():joinToString(nil, nil, nil, nil, nil, function(it) return it.id end))
    print(__K2L_Str(desk:log()))
    local genres = items:filter(function(x) return __K2L_InstanceOf(x, ____Catalog.Book) end):groupingBy(function(it) return it.genre end):eachCount()
    print(__K2L_Str(__K2L_EnumValues(____Catalog.Genre):associateWith(function(it) return genres:get(it) or 0 end)))
    local longest = items:maxBy(function(it)
        local ____receiver = __K2L_InstanceOf(it, ____Catalog.Dvd) and it or nil
        return ____receiver and (__K2L_InstanceOf(it, ____Catalog.Dvd) and it or nil).minutes or 0
    end)
    print(longest:describe())
    local c1 = counter(10)
    local c2 = counter(20)
    print(c1:next() .. " " .. c1:next() .. " " .. c2:next() .. " same class: " .. tostring(__K2L_Equals(__K2L_JavaClass(__K2L_KClassOfValue(c1)), __K2L_JavaClass(__K2L_KClassOfValue(c2)))))
    print(__K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(c1)).name))
    local opening = function(...)
        announce(...)
        return __K2L_Unit
    end
    print("result: " .. __K2L_Str(opening()))
    local actions = __K2L_ReadOnlyListOf(function(...)
        announce(...)
        return __K2L_Unit
    end, function() return "lambda" end)
    print(__K2L_Str(actions:map(function(it) return it() end)))
    print("desks opened: " .. ____Desk.desksOpened)
    local ____mod_3 = items.____modCount
    for ____i_3 = 1, items.size do
        local it = items[____i_3]
        do
            if __K2L_InstanceOf(it, ____Catalog.Dvd) then
                goto ____inline_end
            end
            io.write(it.id .. " ")
            ::____inline_end::
        end
        if items.____modCount ~= ____mod_3 and items:____comodified(____i_3) then
            break
        end
    end
    print()
    local ____value = __K2L_StringBuilder.new()
    local ____result_3
    do
        local ____collection = items:groupBy(function(it) return __K2L_KClassOfValue(it).simpleName end)
        local ____items, ____n = ____collection:____entryArray()
        local ____mod_4 = ____collection.____modCount
        for ____i_4 = 1, ____n do
            local ____entry = ____items[____i_4]
            do
                local k, v = ____entry.key, ____entry.value
                ____value:append(__K2L_Str(k) .. "=" .. v.size .. ";")
            end
            if ____collection.____modCount ~= ____mod_4 and ____collection:____comodified(____i_4, ____n) then
                break
            end
        end
        ____result_3 = ____value:toString()
    end
    local summary = ____result_3
    print(summary)
end

main()
return {SimClock = SimClock, Rule = Rule, rules = rules, announce = announce}
-- ==== model/Catalog.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_EnumValueOf = ____lualib.__K2L_EnumValueOf
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32

local Loan
local MAX_LOANS = 3
local Identified = __K2L_Class("lib.model.Identified")
__K2L_ClassInfo(Identified, "lib.model.Identified", "lib.model.Identified", "interface")

function Identified:describe()
    return "#" .. self.id
end

local Factory = __K2L_Class("lib.model.Factory")
__K2L_ClassInfo(Factory, "lib.model.Factory", "lib.model.Factory", "interface")
local Genre = __K2L_Class("lib.model.Genre")
__K2L_ClassInfo(Genre, "lib.model.Genre", "lib.model.Genre", "class")

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
__K2L_ClassInfo(Media, "lib.model.Media", "lib.model.Media", "class")
Media.____comparable = true

function Media:____init(id, title)
    self.id = id
    self.title = title
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
    return __K2L_Str(__K2L_KClassOfValue(self).simpleName) .. "(" .. self.id .. ")"
end

local Book = __K2L_Class("lib.model.Book", Media)
__K2L_ClassInfo(Book, "lib.model.Book", "lib.model.Book", "class")

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
__K2L_ClassInfo(Book.Companion, "lib.model.Book.Companion", "lib.model.Book$Companion", "class")

function Book.Companion:create(fields)
    local ____arg = fields:getValue("id")
    local ____arg_1 = fields:getValue("title")
    local ____arg_2 = fields:get("author") or "anonymous"
    local ____arg_3 = fields:get("isbn") or ""
    local ____receiver = fields:get("genre")
    return Book.new(____arg, ____arg_1, ____arg_2, ____arg_3, __K2L_EnumValueOf(Genre, ____receiver and ____receiver:upper() or "FICTION"))
end

local Dvd = __K2L_Class("lib.model.Dvd", Media)
__K2L_ClassInfo(Dvd, "lib.model.Dvd", "lib.model.Dvd", "class")

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
__K2L_ClassInfo(Dvd.Companion, "lib.model.Dvd.Companion", "lib.model.Dvd$Companion", "class")

function Dvd.Companion:create(fields)
    local ____arg_4 = fields:getValue("id")
    local ____arg_5 = fields:getValue("title")
    local ____receiver_1 = fields:get("minutes")
    return Dvd.new(____arg_4, ____arg_5, ____receiver_1 and __K2L_StringToIntOrNull(____receiver_1) or 90)
end

local Member = __K2L_Class("lib.model.Member")
__K2L_ClassInfo(Member, "lib.model.Member", "lib.model.Member", "class")

function Member:____init(name, id)
    self.name = name
    self.id = id
    self.fines = 0
    self.loans = __K2L_ListOf()
end

function Member:getCanBorrow()
    return self.loans.size < MAX_LOANS and self.fines < 500
end

function Member:toString()
    return "Member(name=" .. self.name .. ", id=" .. self.id .. ")"
end

function Member:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.name) + __K2L_Hash(self.id))
end

function Member:equals(other)
    return getmetatable(other) == Member and self.name == other.name and self.id == other.id
end

Loan = __K2L_Class("lib.model.Loan")
__K2L_ClassInfo(Loan, "lib.model.Loan", "lib.model.Loan", "class")

function Loan:____init(media, member, day)
    self.media = media
    self.member = member
    self.day = day
end

function Loan:getDue()
    return self.day + self.media:getLoanDays()
end

function Loan:toString()
    return "Loan(media=" .. __K2L_Str(self.media) .. ", member=" .. __K2L_Str(self.member) .. ", day=" .. self.day .. ")"
end

function Loan:hashCode()
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.media) + __K2L_Hash(self.member)) + __K2L_Hash(self.day))
end

function Loan:equals(other)
    return getmetatable(other) == Loan and __K2L_Equals(self.media, other.media) and self.member:equals(other.member) and self.day == other.day
end

local function parse(self, line)
    return self:create(__K2L_StringSplit(line, ";"):associate(function(field)
        local ____destructured = __K2L_Text.split(field, {"="}, 2):map(function(____p1) return __K2L_StringTrim(____p1) end)
        local key, value = ____destructured[1], ____destructured[2]
        return __K2L_Pair.new(key, value)
    end))
end

return {MAX_LOANS = MAX_LOANS, Identified = Identified, Factory = Factory, Genre = Genre, Media = Media, Book = Book, Dvd = Dvd, Member = Member, Loan = Loan, parse = parse}
-- ==== service/Desk.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_ListBuilderOf = ____lualib.__K2L_ListBuilderOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_Str = ____lualib.__K2L_Str

local ____exports = {}
local ____Catalog = require("model.Catalog")
local LibraryException = __K2L_Class("lib.service.LibraryException", __K2L_Exception)
__K2L_ClassInfo(LibraryException, "lib.service.LibraryException", "lib.service.LibraryException", "class")

function LibraryException:____init(message)
    __K2L_Exception.____init(self, message)
end

local Clock = __K2L_Class("lib.service.Clock")
__K2L_ClassInfo(Clock, "lib.service.Clock", "lib.service.Clock", "interface")
local Notifier = __K2L_Class("lib.service.Notifier")
__K2L_ClassInfo(Notifier, "lib.service.Notifier", "lib.service.Notifier", "interface")
local Outbox = __K2L_Class("lib.service.Outbox", nil, Notifier)
__K2L_ClassInfo(Outbox, "lib.service.Outbox", "lib.service.Outbox", "class")

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

function Outbox:close()
    self.closed = true
    local ____list = self.messages
    local ____mod = ____list.____modCount
    for ____i = 1, ____list.size do
        local it = ____list[____i];
        (function(____p1) return print(__K2L_Str(____p1)) end)(it)
        if ____list.____modCount ~= ____mod and ____list:____comodified(____i) then
            break
        end
    end
    self.messages:clear()
end

____exports.desksOpened = 0
local Desk = __K2L_Class("lib.service.Desk", nil, Notifier)
__K2L_ClassInfo(Desk, "lib.service.Desk", "lib.service.Desk", "class")

function Desk:____init(clock, notifier)
    self.clock = clock
    self.____delegate_Notifier = notifier
    self.shelf = __K2L_SortedMapOf()
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
    return self.shelf:getValues():filter(function(m)
        return self.active:none(function(it) return __K2L_Equals(it.media, m) end)
    end)
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
    if self.active:any(function(it) return __K2L_Equals(it.media, media) end) then
        error(LibraryException.new(__K2L_Str(media) .. " is already on loan"))
    end
    local ____value_1 = ____Catalog.Loan.new(media, member, self.clock.today)
    self.active:add(____value_1)
    member.loans:add(____value_1)
    self.history:add("out " .. media.id .. " " .. member.name .. " d" .. self.clock.today)
    return ____value_1
end

function Desk:checkin(id)
    local ____value_2 = self.active:find(function(it) return it.media.id == id end)
    if ____value_2 == nil then
        error(LibraryException.new(id .. " is not on loan"))
    end
    local loan = ____value_2
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

function Desk:overdue()
    return self.active:filter(function(it) return it:getDue() < self.clock.today end):sortedBy(function(it) return it:getDue() end)
end

function Desk:log()
    return self.history:toList()
end

Desk.Report = __K2L_Class("lib.service.Desk$Report")
__K2L_ClassInfo(Desk.Report, "lib.service.Desk.Report", "lib.service.Desk$Report", "class")

function Desk.Report:____init(____outer, title)
    self.____outer = ____outer
    self.title = title
end

function Desk.Report:lines()
    local ____builder = __K2L_ListBuilderOf()
    do
        ____builder:add("== " .. self.title .. " (day " .. self.____outer.clock.today .. ")")
        local ____collection = self.____outer.shelf:getValues()
        local ____items, ____n = ____collection:____array()
        local ____mod_1 = ____collection.____modCount
        for ____i_2 = 1, ____n do
            local m = ____items[____i_2]
            do
                local loan = self.____outer.active:firstOrNull(function(it) return __K2L_Equals(it.media, m) end)
                ____builder:add(m:describe() .. " -> " .. (loan and loan.member.name .. " due d" .. loan:getDue() or "available"))
            end
            if ____collection.____modCount ~= ____mod_1 and ____collection:____comodified(____i_2, ____n) then
                break
            end
        end
    end
    return ____builder:____build()
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
