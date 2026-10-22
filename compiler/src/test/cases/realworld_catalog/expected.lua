local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CompareValues = ____lualib.__K2L_CompareValues
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IsNumber = ____lualib.__K2L_IsNumber
local __K2L_Iterable = ____lualib.__K2L_Iterable
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_SortedSetOf = ____lualib.__K2L_SortedSetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Triple = ____lualib.__K2L_Triple

local Genre = __K2L_Class("Genre")

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
Genre.POETRY = Genre.new("POETRY", 4)
Genre.____values = {Genre.FICTION, Genre.SCIENCE, Genre.HISTORY, Genre.KIDS, Genre.POETRY}
local Book = __K2L_Class("Book")

function Book:____init(isbn, title, author, year, genres, copies)
    if copies == nil then
        copies = 1
    end
    self.isbn = isbn
    self.title = title
    self.author = author
    self.year = year
    self.genres = genres
    self.copies = copies
end

function Book:toString()
    return "Book(isbn=" .. self.isbn .. ", title=" .. self.title .. ", author=" .. self.author .. ", year=" .. self.year .. ", genres=" .. __K2L_Str(self.genres) .. ", copies=" .. self.copies .. ")"
end

function Book:hashCode()
    return (31 * (31 * (31 * (31 * (31 * __K2L_Hash(self.isbn) + __K2L_Hash(self.title)) + __K2L_Hash(self.author)) + self.year) + __K2L_Hash(self.genres)) + self.copies + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Book:equals(other)
    return getmetatable(other) == Book and self.isbn == other.isbn and self.title == other.title and self.author == other.author and self.year == other.year and __K2L_Equals(self.genres, other.genres) and self.copies == other.copies
end

local Member = __K2L_Class("Member")

function Member:____init(id, name, tier)
    self.id = id
    self.name = name
    self.tier = tier
end

function Member.new(id, name, tier)
    return setmetatable({id = id, name = name, tier = tier}, Member)
end

Member.Tier = __K2L_Class("Member$Tier")

function Member.Tier:____init(name, ordinal, maxLoans, loanDays, finePerDay)
    self.name = name
    self.ordinal = ordinal
    self.maxLoans = maxLoans
    self.loanDays = loanDays
    self.finePerDay = finePerDay
end

function Member.Tier:toString()
    return self.name
end

function Member.Tier:compareTo(other)
    return self.ordinal - other.ordinal
end

Member.Tier.BASIC = Member.Tier.new("BASIC", 0, 2, 14, 25)
Member.Tier.PLUS = Member.Tier.new("PLUS", 1, 5, 28, 10)
Member.Tier.STAFF = Member.Tier.new("STAFF", 2, 10, 60, 0)
Member.Tier.____values = {Member.Tier.BASIC, Member.Tier.PLUS, Member.Tier.STAFF}

function Member:toString()
    return "Member(id=" .. self.id .. ", name=" .. self.name .. ", tier=" .. __K2L_Str(self.tier) .. ")"
end

function Member:hashCode()
    return (31 * (31 * self.id + __K2L_Hash(self.name)) + __K2L_Hash(self.tier) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Member:equals(other)
    return getmetatable(other) == Member and self.id == other.id and self.name == other.name and self.tier == other.tier
end

local Loan = __K2L_Class("Loan")

function Loan:____init(isbn, member, out, due, returned)
    if returned == nil then
        returned = nil
    end
    self.isbn = isbn
    self.member = member
    self.out = out
    self.due = due
    self.returned = returned
end

function Loan:daysLate(today)
    return math.max(0, (self.returned or today) - self.due)
end

function Loan:toString()
    return "Loan(isbn=" .. self.isbn .. ", member=" .. self.member .. ", out=" .. self.out .. ", due=" .. self.due .. ", returned=" .. __K2L_Str(self.returned) .. ")"
end

function Loan:hashCode()
    return (31 * (31 * (31 * (31 * __K2L_Hash(self.isbn) + self.member) + self.out) + self.due) + __K2L_Hash(self.returned) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Loan:equals(other)
    return getmetatable(other) == Loan and self.isbn == other.isbn and self.member == other.member and self.out == other.out and self.due == other.due and self.returned == other.returned
end

local LibraryException = __K2L_Class("LibraryException", __K2L_Exception)

function LibraryException:____init(message)
    __K2L_Exception.____init(self, message)
end

local Library = __K2L_Class("Library")

function Library:____init()
    self.books = __K2L_Map.new()
    self.members = __K2L_Map.new()
    self.loans = __K2L_List.new()
    self.byAuthor = __K2L_SortedMapOf(nil)
    self.byGenre = __K2L_Map.new()
    self.wordIndex = __K2L_Map.new()
end

local ____lambda_1 = function(it) return __K2L_ListOf() end
local ____lambda_2 = function() return __K2L_SetOf() end
local ____lambda_3 = function(it) return __K2L_SortedSetOf(nil) end
function Library:add(book)
    local ____receiver = self.books:putIfAbsent(book.isbn, book)
    if ____receiver ~= nil then
        local ____result
        error(LibraryException.new("duplicate isbn " .. book.isbn))
    end
    self.byAuthor:computeIfAbsent(book.author, ____lambda_1):add(book.isbn)
    local ____collection = book.genres
    local ____items, ____n = ____collection:____array()
    for ____i = 1, ____n do
        local g = ____items[____i]
        self.byGenre:getOrPut(g, ____lambda_2):add(book.isbn)
    end
    local ____list = __K2L_StringSplit(book.title:lower(), " ")
    local ____out = {}
    local ____count = 0
    local ____items_1, ____n_1 = ____list:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        if #it > 2 then
            ____count = ____count + 1
            ____out[____count] = it
        end
    end
    local ____list_1 = __K2L_ListWrap(____out, ____count)
    for ____i_2 = 1, ____list_1.size do
        local w = ____list_1[____i_2]
        self.wordIndex:computeIfAbsent(w, ____lambda_3):add(book.isbn)
    end
end

function Library:join(member)
    local ____object = self.members
    local ____key = member.id
    ____object:set(____key, member)
end

function Library:available(isbn)
    local ____arg = self.books:getValue(isbn).copies
    local ____list_2 = self.loans
    local ____result_1 = 0
    local ____items_2, ____n_2 = ____list_2:____array()
    for ____i_3 = 1, ____n_2 do
        local it = ____items_2[____i_3]
        if it.isbn == isbn and it.returned == nil then
            ____result_1 = ____result_1 + 1
        end
    end
    return ____arg - ____result_1
end

function Library:lend(isbn, memberId, today)
    local ____value = self.members:get(memberId)
    if ____value == nil then
        error(LibraryException.new("no member " .. memberId))
    end
    local member = ____value
    local ____value_1 = self.books:get(isbn)
    if ____value_1 == nil then
        error(LibraryException.new("no book " .. isbn))
    end
    local book = ____value_1
    local ____list_3 = self.loans
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_3, ____n_3 = ____list_3:____array()
    for ____i_4 = 1, ____n_3 do
        local it = ____items_3[____i_4]
        if it.member == memberId and it.returned == nil then
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = it
        end
    end
    local open = __K2L_ListWrap(____out_1, ____count_1)
    if open.size >= member.tier.maxLoans then
        error(LibraryException.new(member.name .. " has reached " .. member.tier.maxLoans .. " loans"))
    else
        local ____result_2 = false
        local ____items_4, ____n_4 = open:____array()
        for ____i_5 = 1, ____n_4 do
            local it = ____items_4[____i_5]
            if it:daysLate(today) > 0 then
                ____result_2 = true
                break
            end
        end
        if ____result_2 then
            error(LibraryException.new(member.name .. " has overdue books"))
        elseif self:available(isbn) <= 0 then
            error(LibraryException.new("'" .. book.title .. "' is not available"))
        end
    end
    local ____value_2 = Loan.new(isbn, memberId, today, today + member.tier.loanDays)
    self.loans:add(____value_2)
    return ____value_2
end

function Library:giveBack(isbn, memberId, today)
    local ____list_4 = self.loans
    local ____result_3
    local ____items_5, ____n_5 = ____list_4:____array()
    for ____i_6 = 1, ____n_5 do
        local it = ____items_5[____i_6]
        if it.isbn == isbn and it.member == memberId and it.returned == nil then
            ____result_3 = it
            break
        end
    end
    if ____result_3 == nil then
        error(LibraryException.new("no open loan of " .. isbn .. " by " .. memberId))
    end
    local loan = ____result_3
    loan.returned = today
    return loan:daysLate(today) * self.members:getValue(memberId).tier.finePerDay
end

local ____lambda_4 = function(acc, s) return acc:intersect(s) end
function Library:search(query)
    local ____list_5 = __K2L_StringSplit(query:lower(), " ")
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_6, ____n_6 = ____list_5:____array()
    for ____i_7 = 1, ____n_6 do
        local it = ____items_6[____i_7]
        if #it > 2 then
            ____count_2 = ____count_2 + 1
            ____out_2[____count_2] = it
        end
    end
    local ____list_6 = __K2L_ListWrap(____out_2, ____count_2)
    local ____out_3 = {}
    local ____count_3 = 0
    local ____items_7, ____n_7 = ____list_6:____array()
    for ____i_8 = 1, ____n_7 do
        local it = ____items_7[____i_8]
        ____count_3 = ____count_3 + 1
        ____out_3[____count_3] = self.wordIndex:get(it) or __K2L_SetOf()
    end
    local ____arg_1 = __K2L_ListWrap(____out_3, ____count_3):reduceOrNull(____lambda_4) or __K2L_SetOf()
    local ____receiver_1 = self.books
    return ____arg_1:map(function(____p1) return ____receiver_1:getValue(____p1) end)
end

local ____lambda_5 = function(it) return __K2L_Pair.new(it.member, it.isbn) end
local ____lambda_6 = function(____p1, ____p2) return ____p1 + ____p2 end
function Library:recommend(isbn)
    local ____list_7 = self.loans
    local ____out_4 = {}
    local ____count_4 = 0
    local ____items_8, ____n_8 = ____list_7:____array()
    for ____i_9 = 1, ____n_8 do
        local it = ____items_8[____i_9]
        if it.isbn == isbn then
            ____count_4 = ____count_4 + 1
            ____out_4[____count_4] = it
        end
    end
    local ____list_8 = __K2L_ListWrap(____out_4, ____count_4)
    local ____out_5 = {}
    local ____count_5 = 0
    local ____items_9, ____n_9 = ____list_8:____array()
    for ____i_10 = 1, ____n_9 do
        local it = ____items_9[____i_10]
        ____count_5 = ____count_5 + 1
        ____out_5[____count_5] = it.member
    end
    local readers = __K2L_ListWrap(____out_5, ____count_5):toSet()
    local counts = __K2L_MapOf()
    local ____list_9 = self.loans
    local ____out_6 = {}
    local ____count_6 = 0
    local ____items_10, ____n_10 = ____list_9:____array()
    for ____i_11 = 1, ____n_10 do
        local it = ____items_10[____i_11]
        if readers:contains(it.member) and it.isbn ~= isbn then
            ____count_6 = ____count_6 + 1
            ____out_6[____count_6] = it
        end
    end
    local ____list_10 = __K2L_ListWrap(____out_6, ____count_6):distinctBy(____lambda_5)
    for ____i_12 = 1, ____list_10.size do
        local it = ____list_10[____i_12]
        counts:merge(it.isbn, 1, ____lambda_6)
    end
    local ____list_11 = counts:getEntries():sortedWith(function(____a, ____b)
        local ____x_1, ____y_1 = ____b.value, ____a.value
        if ____x_1 ~= ____y_1 then
            return ____x_1 < ____y_1 and -1 or 1
        end
        return __K2L_CompareValues(self.books:getValue(____a.key).title, self.books:getValue(____b.key).title)
    end)
    local ____out_7 = {}
    local ____count_7 = 0
    local ____items_11, ____n_11 = ____list_11:____array()
    for ____i_13 = 1, ____n_11 do
        local it = ____items_11[____i_13]
        ____count_7 = ____count_7 + 1
        ____out_7[____count_7] = __K2L_Pair.new(self.books:getValue(it.key).title, it.value)
    end
    return __K2L_ListWrap(____out_7, ____count_7)
end

function Library:overdue(today)
    local ____list_12 = self.loans
    local ____out_8 = {}
    local ____count_8 = 0
    local ____items_12, ____n_12 = ____list_12:____array()
    for ____i_14 = 1, ____n_12 do
        local it = ____items_12[____i_14]
        if it.returned == nil and it:daysLate(today) > 0 then
            ____count_8 = ____count_8 + 1
            ____out_8[____count_8] = it
        end
    end
    local ____list_13 = __K2L_ListWrap(____out_8, ____count_8)
    local ____result_4 = __K2L_Map.new()
    local ____items_13, ____n_13 = ____list_13:____array()
    for ____i_15 = 1, ____n_13 do
        local it = ____items_13[____i_15]
        local ____value_3 = self.members:getValue(it.member).name
        local ____group = ____result_4:get(____value_3)
        if ____group == nil then
            ____group = __K2L_List.new()
            ____result_4:put(____value_3, ____group)
        end
        ____group:add(it)
    end
    return ____result_4:mapValues(function(____destructured)
        local ls = ____destructured.value
        local ____out_9 = {}
        local ____count_9 = 0
        local ____items_14, ____n_14 = ls:____array()
        for ____i_16 = 1, ____n_14 do
            local it = ____items_14[____i_16]
            ____count_9 = ____count_9 + 1
            ____out_9[____count_9] = __K2L_Pair.new(self.books:getValue(it.isbn).title, it:daysLate(today))
        end
        return __K2L_ListWrap(____out_9, ____count_9)
    end):toSortedMap()
end

function Library:authors()
    return self.byAuthor:mapValues(function(____destructured_1)
        local isbns = ____destructured_1.value
        return isbns.size
    end)
end

local ____lambda_7 = function(it) return it > 0 end
function Library:genres()
    local ____values = Genre.____values
    local ____result_5 = __K2L_Map.new()
    for ____i_17 = 1, #____values do
        local it = ____values[____i_17]
        local ____result_6
        do
            local ____receiver_2 = self.byGenre:get(it)
            ____result_6 = ____receiver_2 and ____receiver_2.size or 0
        end
        local ____value_4 = ____result_6
        ____result_5:put(it, ____value_4)
    end
    return ____result_5:filterValues(____lambda_7)
end

local ____lambda_8 = function(it) return it.id end
function Library:export()
    local ____list_14 = self.books:getValues()
    local ____out_10 = {}
    local ____count_10 = 0
    local ____items_16, ____n_16 = ____list_14:____array()
    for ____i_19 = 1, ____n_16 do
        local b = ____items_16[____i_19]
        local ____result_7
        do
            local ____arg_2 = __K2L_Pair.new("isbn", b.isbn)
            local ____arg_3 = __K2L_Pair.new("title", b.title)
            local ____arg_4 = __K2L_Pair.new("year", b.year)
            local ____list_15 = b.genres
            local ____out_11 = {}
            local ____count_11 = 0
            local ____items_15, ____n_15 = ____list_15:____array()
            for ____i_18 = 1, ____n_15 do
                local it = ____items_15[____i_18]
                ____count_11 = ____count_11 + 1
                ____out_11[____count_11] = it.name:lower()
            end
            ____result_7 = __K2L_MapOf(____arg_2, ____arg_3, ____arg_4, __K2L_Pair.new("genres", __K2L_ListWrap(____out_11, ____count_11)), __K2L_Pair.new("available", self:available(b.isbn)))
        end
        ____count_10 = ____count_10 + 1
        ____out_10[____count_10] = ____result_7
    end
    local ____arg_5 = __K2L_Pair.new("books", __K2L_ListWrap(____out_10, ____count_10))
    local ____list_16 = self.members:getValues():sortedBy(____lambda_8, true)
    local ____out_12 = {}
    local ____count_12 = 0
    local ____items_17, ____n_17 = ____list_16:____array()
    for ____i_20 = 1, ____n_17 do
        local it = ____items_17[____i_20]
        ____count_12 = ____count_12 + 1
        ____out_12[____count_12] = __K2L_MapOf(__K2L_Pair.new("id", it.id), __K2L_Pair.new("name", it.name), __K2L_Pair.new("tier", it.tier.name))
    end
    local ____arg_6 = __K2L_Pair.new("members", __K2L_ListWrap(____out_12, ____count_12))
    local ____list_17 = self.loans
    local ____result_8 = 0
    local ____items_18, ____n_18 = ____list_17:____array()
    for ____i_21 = 1, ____n_18 do
        local it = ____items_18[____i_21]
        if it.returned == nil then
            ____result_8 = ____result_8 + 1
        end
    end
    return __K2L_MapOf(____arg_5, ____arg_6, __K2L_Pair.new("openLoans", ____result_8), __K2L_Pair.new("note", nil))
end

local function toJson(value, indent)
    if indent == nil then
        indent = ""
    end
    if value == nil then
        return "null"
    elseif type(value) == "string" then
        local ____builder = __K2L_StringBuilder.new()
        ____builder:append("\"")
        for ____i_23 = 1, #value do
            local c = value:sub(____i_23, ____i_23)
            if c == "\"" then
                ____builder:append("\\\"")
            elseif c == "\\" then
                ____builder:append("\\\\")
            elseif c == "\n" then
                ____builder:append("\\n")
            elseif c:byte() < 32 then
                ____builder:append(string.format("\\u%04x", c:byte()))
            else
                ____builder:append(c)
            end
        end
        ____builder:append("\"")
        return ____builder:toString()
    elseif __K2L_IsNumber(value) or type(value) == "boolean" then
        return __K2L_Str(value)
    elseif __K2L_InstanceOf(value, __K2L_Map) then
        if value:isEmpty() then
            return "{}"
        else
            return value:getEntries():joinToString(",\n", "{\n", "\n" .. indent .. "}", nil, nil, function(____destructured_2)
                local k, v = ____destructured_2.key, ____destructured_2.value
                return indent .. "  " .. toJson(__K2L_Str(k)) .. ": " .. toJson(v, indent .. "  ")
            end)
        end
    elseif __K2L_InstanceOf(value, __K2L_Iterable) then
        local items = value:toList()
        local ____result_9 = true
        local ____items_19, ____n_19 = items:____array()
        for ____i_22 = 1, ____n_19 do
            local it = ____items_19[____i_22]
            if not (not __K2L_InstanceOf(it, __K2L_Map) and not __K2L_InstanceOf(it, __K2L_Iterable)) then
                ____result_9 = false
                break
            end
        end
        if ____result_9 then
            return items:joinToString(", ", "[", "]", nil, nil, function(it) return toJson(it) end)
        else
            return items:joinToString(",\n", "[\n", "\n" .. indent .. "]", nil, nil, function(it)
                return indent .. "  " .. toJson(it, indent .. "  ")
            end)
        end
    else
        return toJson(__K2L_Str(value))
    end
end

local function main()
    local lib = Library.new()
    local ____list_18 = __K2L_ListOf(Book.new("978-0", "The Time Machine", "H. G. Wells", 1895, __K2L_SetOf(Genre.FICTION, Genre.SCIENCE), 2), Book.new("978-1", "The War of the Worlds", "H. G. Wells", 1898, __K2L_SetOf(Genre.FICTION)), Book.new("978-2", "A Brief History of Time", "Stephen Hawking", 1988, __K2L_SetOf(Genre.SCIENCE)), Book.new("978-3", "The Story of Art", "E. H. Gombrich", 1950, __K2L_SetOf(Genre.HISTORY)), Book.new("978-4", "A Little History of the World", "E. H. Gombrich", 1936, __K2L_SetOf(Genre.HISTORY, Genre.KIDS)), Book.new("978-5", "The Gruffalo", "Julia Donaldson", 1999, __K2L_SetOf(Genre.KIDS, Genre.POETRY), 3), Book.new("978-6", "Leaves of Grass", "Walt Whitman", 1855, __K2L_SetOf(Genre.POETRY)))
    for ____i_24 = 1, ____list_18.size do
        local it = ____list_18[____i_24];
        (function(...) return lib:add(...) end)(it)
    end
    local ____ok, ____result_10 = pcall(function()
        lib:add(Book.new("978-6", "Dup", "X", 2000, __K2L_SetOf()))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_10)
        if getmetatable(____error) == LibraryException then
            local e = ____error
            print("error: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    local ____list_19 = __K2L_ListOf(Member.new(1, "Ana", Member.Tier.BASIC), Member.new(2, "Ben", Member.Tier.PLUS), Member.new(3, "Cy", Member.Tier.STAFF), Member.new(4, "Di", Member.Tier.PLUS))
    for ____i_25 = 1, ____list_19.size do
        local it = ____list_19[____i_25];
        (function(...) return lib:join(...) end)(it)
    end
    print("authors: " .. __K2L_Str(lib:authors()))
    print("genres: " .. __K2L_Str(lib:genres()))
    local ____list_20 = lib:search("history")
    local ____out_13 = {}
    local ____count_13 = 0
    local ____items_20, ____n_20 = ____list_20:____array()
    for ____i_26 = 1, ____n_20 do
        local it = ____items_20[____i_26]
        ____count_13 = ____count_13 + 1
        ____out_13[____count_13] = it.title
    end
    print("search 'history': " .. __K2L_Str(__K2L_ListWrap(____out_13, ____count_13)))
    local ____list_21 = lib:search("THE time")
    local ____out_14 = {}
    local ____count_14 = 0
    local ____items_21, ____n_21 = ____list_21:____array()
    for ____i_27 = 1, ____n_21 do
        local it = ____items_21[____i_27]
        ____count_14 = ____count_14 + 1
        ____out_14[____count_14] = it.title
    end
    print("search 'the time': " .. __K2L_Str(__K2L_ListWrap(____out_14, ____count_14)))
    print("search 'nothing here': " .. __K2L_Str(lib:search("nothing here")))
    local actions = __K2L_ListOf(__K2L_Triple.new("978-0", 1, 1), __K2L_Triple.new("978-2", 1, 1), __K2L_Triple.new("978-3", 1, 2), __K2L_Triple.new("978-0", 2, 2), __K2L_Triple.new("978-0", 3, 3), __K2L_Triple.new("978-2", 2, 3), __K2L_Triple.new("978-5", 4, 4), __K2L_Triple.new("978-0", 4, 5), __K2L_Triple.new("978-9", 2, 5), __K2L_Triple.new("978-1", 7, 5))
    for ____i_28 = 1, actions.size do
        local ____item = actions[____i_28]
        local isbn, member, day = ____item.first, ____item.second, ____item.third
        local ____ok_1, ____result_11 = pcall(function()
            local loan = lib:lend(isbn, member, day)
            print("day " .. day .. ": lent " .. isbn .. " to " .. member .. ", due day " .. loan.due)
        end)
        if not ____ok_1 then
            local ____error_1 = __K2L_ToThrowable(____result_11)
            if getmetatable(____error_1) == LibraryException then
                local e = ____error_1
                print("day " .. day .. ": refused (" .. isbn .. " to " .. member .. "): " .. __K2L_Str(e.message))
            else
                error(____error_1, 0)
            end
        end
    end
    print("available: " .. __K2L_Str(__K2L_ListOf("978-0", "978-2", "978-5"):associateWith(function(...) return lib:available(...) end)))
    print("fine Ana: " .. lib:giveBack("978-0", 1, 20) .. " cents")
    print("fine Ben: " .. lib:giveBack("978-0", 2, 20) .. " cents")
    local ____receiver_3 = __K2L_RunCatching(function() return lib:giveBack("978-0", 2, 21) end):exceptionOrNull()
    print(__K2L_Str(____receiver_3 and ____receiver_3.message))
    print("overdue on day 40: " .. __K2L_Str(lib:overdue(40)))
    local ____receiver_4 = __K2L_RunCatching(function() return lib:lend("978-6", 1, 40) end):exceptionOrNull()
    print(__K2L_Str(____receiver_4 and ____receiver_4.message))
    print("fine Ana again: " .. lib:giveBack("978-2", 1, 41))
    print("lend after return: " .. lib:lend("978-6", 1, 41).due)
    print("recommend for 978-0: " .. __K2L_Str(lib:recommend("978-0")))
    print(toJson(lib:export()))
    print(toJson(__K2L_MapOf(__K2L_Pair.new("escaped", "quote \" backslash \\ newline \n tab\t"), __K2L_Pair.new("empty", __K2L_MapOf()), __K2L_Pair.new("nested", __K2L_ListOf(__K2L_ListOf(1, 2), __K2L_ListOf())))))
end

__K2L_RunMain(main)
return {Genre = Genre, Book = Book, Member = Member, Loan = Loan, LibraryException = LibraryException, Library = Library, toJson = toJson}
