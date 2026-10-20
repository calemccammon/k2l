local ____lualib = require("lualib_bundle")
local __K2L_AbstractList = ____lualib.__K2L_AbstractList
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IndexOutOfBoundsException = ____lualib.__K2L_IndexOutOfBoundsException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_Iterable = ____lualib.__K2L_Iterable
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_JdkCollections = ____lualib.__K2L_JdkCollections
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_PropertyOverride = ____lualib.__K2L_PropertyOverride
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Set = ____lualib.__K2L_Set
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Tens = __K2L_Class("Tens", __K2L_AbstractList)
__K2L_ClassInfo(Tens, "Tens", "Tens", "class")
Tens.____readOnly = true

function Tens:____init(n)
    self.n = n
    self.reads = 0
end

function Tens:getSize()
    return self.n
end

function Tens:get(index)
    if index < 0 or index >= self.n then
        error(__K2L_IndexOutOfBoundsException.new("index " .. index .. " of " .. self.n))
    end
    self.reads = self.reads + 1
    return index * 10
end

__K2L_PropertyOverride(Tens, "size", "getSize")
local Fixed = __K2L_Class("Fixed", __K2L_AbstractList)
__K2L_ClassInfo(Fixed, "Fixed", "Fixed", "class")
Fixed.____readOnly = true

function Fixed:____init(size)
    self.size = size
end

function Fixed:get(index)
    return "s" .. index
end

local Logged = __K2L_Class("Logged", __K2L_AbstractList)
__K2L_ClassInfo(Logged, "Logged", "Logged", "class")

function Logged:____init()
    self.items = __K2L_List.new()
    self.log = __K2L_ListOf()
end

function Logged:getSize()
    return self.items.size
end

function Logged:get(index)
    return self.items:get(index)
end

function Logged:set(index, element)
    self.log:add("set(" .. index .. ", " .. element .. ")")
    return self.items:set(index, element)
end

function Logged:addAt(index, element)
    self.log:add("add(" .. index .. ", " .. element .. ")")
    self.items:addAt(index, element)
end

function Logged:removeAt(index)
    self.log:add("removeAt(" .. index .. ")")
    return self.items:removeAt(index)
end

function Logged:drain()
    local ____value = self.log:joinToString(" ")
    self.log:clear()
    return ____value
end

__K2L_PropertyOverride(Logged, "size", "getSize")

local ____lambda_1 = function(it) return it + 1 end
local ____lambda_2 = function(it) return it > 15 end
local ____lambda_3 = function(it) return #it end
local function readOnlyList()
    local t = Tens.new(5)
    print(__K2L_Str(t) .. " size=" .. t:getSize() .. " [2]=" .. t:get(2) .. " get=" .. t:get(4) .. " (" .. t.reads .. ")")
    print("contains " .. tostring(t:contains(30)) .. " " .. tostring(t:contains(35)) .. " indexOf " .. t:indexOf(20) .. " " .. t:lastIndexOf(40) .. " " .. t:indexOf(7) .. " (" .. t.reads .. ")")
    print("first " .. t:first() .. " last " .. t:last() .. " getOrNull " .. __K2L_Str(t:getOrNull(9)) .. " " .. __K2L_Str(t:getOrNull(1)) .. " isEmpty " .. tostring(t:isEmpty()) .. " (" .. t.reads .. ")")
    print("map " .. __K2L_Str(t:map(____lambda_1)) .. " filter " .. __K2L_Str(t:filter(____lambda_2)) .. " sum " .. t:sum() .. " reversed " .. __K2L_Str(t:reversed()) .. " (" .. t.reads .. ")")
    print("join " .. t:joinToString("-") .. " sortedDesc " .. __K2L_Str(t:sortedDescending()) .. " take " .. __K2L_Str(t:take(2)) .. " drop " .. __K2L_Str(t:drop(3)) .. " (" .. t.reads .. ")")
    print("subList " .. __K2L_Str(t:subList(1, 3)) .. " slice " .. __K2L_Str(t:slice(__K2L_ReadOnlyListOf(0, 4))) .. " chunked " .. __K2L_Str(t:chunked(2)) .. " (" .. t.reads .. ")")
    print("equals " .. tostring(t:equals(__K2L_ReadOnlyListOf(0, 10, 20, 30, 40))) .. " " .. tostring(__K2L_Equals(__K2L_ReadOnlyListOf(0, 10, 20, 30, 40), t)) .. " " .. tostring(t:equals(Tens.new(5))) .. " " .. tostring(t:equals(Tens.new(4))) .. " (" .. t.reads .. ")")
    print("hashCode " .. tostring(t:hashCode() == __K2L_Hash(__K2L_ReadOnlyListOf(0, 10, 20, 30, 40))) .. " (" .. t.reads .. ")")
    local total = 0
    for ____i = 1, t.size do
        local x = t[____i]
        total = total + x
    end
    for i = 0, t.size - 1 do
        total = total + t:get(i)
    end
    for ____i_1 = 1, t.size do
        local it = t[____i_1]
        total = total + it
    end
    print("loops " .. total .. " (" .. t.reads .. ")")
    local it = __K2L_IteratorOf(t)
    print("iterator " .. it:next() .. " " .. it:next() .. " " .. tostring(it:hasNext()) .. " (" .. t.reads .. ")")
    local li = __K2L_JdkCollections.listIterator(t, 4)
    print("listIterator " .. li:previous() .. " " .. li:previousIndex() .. " (" .. t.reads .. ")")
    print("is " .. tostring(__K2L_InstanceOf(t, __K2L_List)) .. " " .. tostring(__K2L_InstanceOf(t, __K2L_Iterable) and t.size ~= nil) .. " " .. tostring(__K2L_InstanceOf(t, __K2L_Set)) .. " " .. __K2L_Str(__K2L_KClassOfValue(t).simpleName) .. " (" .. t.reads .. ")")
    local ____ok, ____result = pcall(function()
        t:get(7)
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_IndexOutOfBoundsException) then
            local e = ____error
            print("caught " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    local list = Tens.new(3)
    print("as List: " .. __K2L_Str(list) .. " " .. list.size .. " " .. list:max() .. " " .. __K2L_Str(list:toSet()) .. " " .. __K2L_Str(list:withIndex():map(function(____destructured)
        local i, v = ____destructured.index, ____destructured.value
        return i + v
    end)) .. " (" .. t.reads .. ")")
    print("Fixed " .. __K2L_Str(Fixed.new(3)) .. " " .. __K2L_Str(Fixed.new(2):map(____lambda_3)) .. " " .. __K2L_Str(Fixed.new(0)) .. " (" .. t.reads .. ")")
    print("reads " .. t.reads)
end

local ____lambda_4 = function(it)
    return (it >= 0 and it % 2 or 0 - -it % 2) == 0
end
local function mutableList()
    local l = Logged.new()
    l:add(1)
    l:add(3)
    l:addAt(1, 2)
    print(__K2L_Str(l) .. " " .. l:drain())
    l:addAll(__K2L_ReadOnlyListOf(4, 5))
    print("addAll " .. __K2L_Str(l) .. " " .. l:drain())
    l:addAllAt(0, __K2L_ReadOnlyListOf(-1, 0))
    print("addAll(0) " .. __K2L_Str(l) .. " " .. l:drain())
    l:set(0, -2)
    l:add(6)
    print("set and += " .. __K2L_Str(l) .. " " .. l:drain())
    l:remove(3)
    print("remove " .. __K2L_Str(l) .. " " .. l:drain())
    l:removeAll(____lambda_4)
    print("removeAll " .. __K2L_Str(l) .. " " .. l:drain())
    l:addAll(__K2L_ReadOnlyListOf(9, 7, 8))
    l:drain()
    l:sort()
    print("sort " .. __K2L_Str(l) .. " " .. l:drain())
    l:removeFirst()
    l:removeLast()
    print("removeFirst/Last " .. __K2L_Str(l) .. " " .. l:drain())
    local iterator = __K2L_IteratorOf(l)
    iterator:next()
    iterator:remove()
    print("iterator remove " .. __K2L_Str(l) .. " " .. l:drain())
    l:retainAll(__K2L_ReadOnlyListOf(7, 8))
    print("retainAll " .. __K2L_Str(l) .. " " .. l:drain())
    l:addAll(__K2L_ReadOnlyListOf(1, 2))
    l:drain()
    l:clear()
    print("clear " .. __K2L_Str(l) .. " " .. l:drain() .. " " .. tostring(l:isEmpty()))
end

local function main()
    readOnlyList()
    mutableList()
end

main()
return {Tens = Tens, Fixed = Fixed, Logged = Logged, readOnlyList = readOnlyList, mutableList = mutableList}
