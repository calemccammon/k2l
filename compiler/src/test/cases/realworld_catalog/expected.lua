local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CompareByDescending = ____lualib.__K2L_CompareByDescending
local __K2L_EnumValues = ____lualib.__K2L_EnumValues
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_FunctionRef = ____lualib.__K2L_FunctionRef
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IsNumber = ____lualib.__K2L_IsNumber
local __K2L_Iterable = ____lualib.__K2L_Iterable
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_SortedSetOf = ____lualib.__K2L_SortedSetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_ThenBy = ____lualib.__K2L_ThenBy
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
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
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.isbn) + __K2L_Hash(self.title)) + __K2L_Hash(self.author)) + __K2L_Hash(self.year)) + __K2L_Hash(self.genres)) + __K2L_Hash(self.copies))
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
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.id) + __K2L_Hash(self.name)) + __K2L_Hash(self.tier))
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
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.isbn) + __K2L_Hash(self.member)) + __K2L_Hash(self.out)) + __K2L_Hash(self.due)) + __K2L_Hash(self.returned))
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
    self.members = __K2L_HashMap.new()
    self.loans = __K2L_List.new()
    self.byAuthor = __K2L_SortedMapOf()
    self.byGenre = __K2L_HashMap.new()
    self.wordIndex = __K2L_HashMap.new()
end

function Library:add(book)
    local ____receiver = self.books:putIfAbsent(book.isbn, book)
    if ____receiver ~= nil then
        local ____result
        error(LibraryException.new("duplicate isbn " .. book.isbn))
    end
    self.byAuthor:computeIfAbsent(book.author, function(it) return __K2L_ListOf() end):add(book.isbn)
    local ____collection = book.genres
    local ____items, ____n = ____collection:____array()
    local ____mod = ____collection.____modCount
    for ____i = 1, ____n do
        local g = ____items[____i]
        self.byGenre:getOrPut(g, function() return __K2L_SetOf() end):add(book.isbn)
        if ____collection.____modCount ~= ____mod and ____collection:____comodified(____i, ____n) then
            break
        end
    end
    local ____list = __K2L_StringSplit(book.title:lower(), " "):filter(function(it) return #it > 2 end)
    local ____mod_1 = ____list.____modCount
    for ____i_1 = 1, ____list.size do
        local w = ____list[____i_1]
        self.wordIndex:computeIfAbsent(w, function(it) return __K2L_SortedSetOf() end):add(book.isbn)
        if ____list.____modCount ~= ____mod_1 and ____list:____comodified(____i_1) then
            break
        end
    end
end

function Library:join(member)
    local ____object = self.members
    local ____key = member.id
    ____object:set(____key, member)
end

function Library:available(isbn)
    return self.books:getValue(isbn).copies - self.loans:count(function(it)
        return it.isbn == isbn and it.returned == nil
    end)
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
    local open = self.loans:filter(function(it)
        return it.member == memberId and it.returned == nil
    end)
    if open.size >= member.tier.maxLoans then
        error(LibraryException.new(member.name .. " has reached " .. member.tier.maxLoans .. " loans"))
    elseif open:any(function(it) return it:daysLate(today) > 0 end) then
        error(LibraryException.new(member.name .. " has overdue books"))
    elseif self:available(isbn) <= 0 then
        error(LibraryException.new("'" .. book.title .. "' is not available"))
    end
    local ____value_2 = Loan.new(isbn, memberId, today, today + member.tier.loanDays)
    self.loans:add(____value_2)
    return ____value_2
end

function Library:giveBack(isbn, memberId, today)
    local ____value_3 = self.loans:firstOrNull(function(it)
        return it.isbn == isbn and it.member == memberId and it.returned == nil
    end)
    if ____value_3 == nil then
        error(LibraryException.new("no open loan of " .. isbn .. " by " .. memberId))
    end
    local loan = ____value_3
    loan.returned = today
    return loan:daysLate(today) * self.members:getValue(memberId).tier.finePerDay
end

function Library:search(query)
    local ____arg = __K2L_StringSplit(query:lower(), " "):filter(function(it) return #it > 2 end):map(function(it)
        return self.wordIndex:get(it) or __K2L_ReadOnlySetOf()
    end):reduceOrNull(function(acc, s) return acc:intersect(s) end) or __K2L_ReadOnlySetOf()
    local ____receiver_1 = self.books
    return ____arg:map(function(____p1) return ____receiver_1:getValue(____p1) end)
end

function Library:recommend(isbn)
    local readers = self.loans:filter(function(it) return it.isbn == isbn end):map(function(it) return it.member end):toSet()
    local counts = __K2L_MapOf()
    local ____list_1 = self.loans:filter(function(it)
        return readers:contains(it.member) and it.isbn ~= isbn
    end):distinctBy(function(it) return __K2L_Pair.new(it.member, it.isbn) end)
    local ____mod_2 = ____list_1.____modCount
    for ____i_2 = 1, ____list_1.size do
        local it = ____list_1[____i_2]
        counts:merge(it.isbn, 1, __K2L_FunctionRef.new("plus", "kotlin/Int.plus(kotlin.Int)", function(____p1, ____p2) return ____p1 + ____p2 end))
        if ____list_1.____modCount ~= ____mod_2 and ____list_1:____comodified(____i_2) then
            break
        end
    end
    return counts:getEntries():sortedWith(__K2L_ThenBy(__K2L_CompareByDescending(function(it) return it.value end), function(it) return self.books:getValue(it.key).title end)):map(function(it)
        return __K2L_Pair.new(self.books:getValue(it.key).title, it.value)
    end)
end

function Library:overdue(today)
    return self.loans:filter(function(it)
        return it.returned == nil and it:daysLate(today) > 0
    end):groupBy(function(it)
        return self.members:getValue(it.member).name
    end):mapValues(function(____destructured)
        local ls = ____destructured.value
        return ls:map(function(it)
            return __K2L_Pair.new(self.books:getValue(it.isbn).title, it:daysLate(today))
        end)
    end):toSortedMap()
end

function Library:authors()
    return self.byAuthor:mapValues(function(____destructured_1)
        local isbns = ____destructured_1.value
        return isbns.size
    end)
end

function Library:genres()
    return __K2L_EnumValues(Genre):associateWith(function(it)
        local ____receiver_2 = self.byGenre:get(it)
        return ____receiver_2 and ____receiver_2.size or 0
    end):filterValues(function(it) return it > 0 end)
end

function Library:export()
    return __K2L_ReadOnlyMapOf(__K2L_Pair.new("books", self.books:getValues():map(function(b)
        return __K2L_ReadOnlyMapOf(__K2L_Pair.new("isbn", b.isbn), __K2L_Pair.new("title", b.title), __K2L_Pair.new("year", b.year), __K2L_Pair.new("genres", b.genres:map(function(it) return it.name:lower() end)), __K2L_Pair.new("available", self:available(b.isbn)))
    end)), __K2L_Pair.new("members", self.members:getValues():sortedBy(function(it) return it.id end, true):map(function(it)
        return __K2L_ReadOnlyMapOf(__K2L_Pair.new("id", it.id), __K2L_Pair.new("name", it.name), __K2L_Pair.new("tier", it.tier.name))
    end)), __K2L_Pair.new("openLoans", self.loans:count(function(it) return it.returned == nil end)), __K2L_Pair.new("note", nil))
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
        for c in value:gmatch(".") do
            if c == "\"" then
                ____builder:append("\\\"")
            elseif c == "\\" then
                ____builder:append("\\\\")
            elseif c == "\n" then
                ____builder:append("\\n")
            elseif c:byte() < 32 then
                ____builder:append(__K2L_StringFormat("\\u%04x", c:byte()))
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
        if items:all(function(it)
            return not __K2L_InstanceOf(it, __K2L_Map) and not __K2L_InstanceOf(it, __K2L_Iterable)
        end) then
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
    local ____list_2 = __K2L_ReadOnlyListOf(Book.new("978-0", "The Time Machine", "H. G. Wells", 1895, __K2L_ReadOnlySetOf(Genre.FICTION, Genre.SCIENCE), 2), Book.new("978-1", "The War of the Worlds", "H. G. Wells", 1898, __K2L_ReadOnlySetOf(Genre.FICTION)), Book.new("978-2", "A Brief History of Time", "Stephen Hawking", 1988, __K2L_ReadOnlySetOf(Genre.SCIENCE)), Book.new("978-3", "The Story of Art", "E. H. Gombrich", 1950, __K2L_ReadOnlySetOf(Genre.HISTORY)), Book.new("978-4", "A Little History of the World", "E. H. Gombrich", 1936, __K2L_ReadOnlySetOf(Genre.HISTORY, Genre.KIDS)), Book.new("978-5", "The Gruffalo", "Julia Donaldson", 1999, __K2L_ReadOnlySetOf(Genre.KIDS, Genre.POETRY), 3), Book.new("978-6", "Leaves of Grass", "Walt Whitman", 1855, __K2L_ReadOnlySetOf(Genre.POETRY)))
    local ____mod_3 = ____list_2.____modCount
    for ____i_3 = 1, ____list_2.size do
        local it = ____list_2[____i_3];
        (function(...) return lib:add(...) end)(it)
        if ____list_2.____modCount ~= ____mod_3 and ____list_2:____comodified(____i_3) then
            break
        end
    end
    local ____ok, ____result_1 = pcall(function()
        lib:add(Book.new("978-6", "Dup", "X", 2000, __K2L_ReadOnlySetOf()))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error, LibraryException) then
            local e = ____error
            print("error: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    local ____list_3 = __K2L_ReadOnlyListOf(Member.new(1, "Ana", Member.Tier.BASIC), Member.new(2, "Ben", Member.Tier.PLUS), Member.new(3, "Cy", Member.Tier.STAFF), Member.new(4, "Di", Member.Tier.PLUS))
    local ____mod_4 = ____list_3.____modCount
    for ____i_4 = 1, ____list_3.size do
        local it = ____list_3[____i_4];
        (function(...) return lib:join(...) end)(it)
        if ____list_3.____modCount ~= ____mod_4 and ____list_3:____comodified(____i_4) then
            break
        end
    end
    print("authors: " .. __K2L_Str(lib:authors()))
    print("genres: " .. __K2L_Str(lib:genres()))
    print("search 'history': " .. __K2L_Str(lib:search("history"):map(function(it) return it.title end)))
    print("search 'the time': " .. __K2L_Str(lib:search("THE time"):map(function(it) return it.title end)))
    print("search 'nothing here': " .. __K2L_Str(lib:search("nothing here")))
    local actions = __K2L_ReadOnlyListOf(__K2L_Triple.new("978-0", 1, 1), __K2L_Triple.new("978-2", 1, 1), __K2L_Triple.new("978-3", 1, 2), __K2L_Triple.new("978-0", 2, 2), __K2L_Triple.new("978-0", 3, 3), __K2L_Triple.new("978-2", 2, 3), __K2L_Triple.new("978-5", 4, 4), __K2L_Triple.new("978-0", 4, 5), __K2L_Triple.new("978-9", 2, 5), __K2L_Triple.new("978-1", 7, 5))
    local ____mod_5 = actions.____modCount
    for ____i_5 = 1, actions.size do
        local ____item = actions[____i_5]
        local isbn, member, day = ____item.first, ____item.second, ____item.third
        local ____ok_1, ____result_2 = pcall(function()
            local loan = lib:lend(isbn, member, day)
            print("day " .. day .. ": lent " .. isbn .. " to " .. member .. ", due day " .. loan.due)
        end)
        if not ____ok_1 then
            local ____error_1 = __K2L_ToThrowable(____result_2)
            if __K2L_InstanceOf(____error_1, LibraryException) then
                local e = ____error_1
                print("day " .. day .. ": refused (" .. isbn .. " to " .. member .. "): " .. __K2L_Str(e.message))
            else
                error(____error_1, 0)
            end
        end
        if actions.____modCount ~= ____mod_5 and actions:____comodified(____i_5) then
            break
        end
    end
    print("available: " .. __K2L_Str(__K2L_ReadOnlyListOf("978-0", "978-2", "978-5"):associateWith(function(...) return lib:available(...) end)))
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
    print(toJson(__K2L_ReadOnlyMapOf(__K2L_Pair.new("escaped", "quote \" backslash \\ newline \n tab\t"), __K2L_Pair.new("empty", __K2L_ReadOnlyMapOf()), __K2L_Pair.new("nested", __K2L_ReadOnlyListOf(__K2L_ReadOnlyListOf(1, 2), __K2L_ReadOnlyListOf())))))
end

main()
return {Genre = Genre, Book = Book, Member = Member, Loan = Loan, LibraryException = LibraryException, Library = Library, toJson = toJson}
