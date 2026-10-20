local ____lualib = require("lualib_bundle")
local __K2L_AbstractList = ____lualib.__K2L_AbstractList
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_CollectionBase = ____lualib.__K2L_CollectionBase
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_JavaRandom = ____lualib.__K2L_JavaRandom
local __K2L_JdkCollections = ____lualib.__K2L_JdkCollections
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListBase = ____lualib.__K2L_ListBase
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_MapBase = ____lualib.__K2L_MapBase
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PropertyOverride = ____lualib.__K2L_PropertyOverride
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf

local Window = __K2L_Class("Window", __K2L_ListBase)
__K2L_ClassInfo(Window, "Window", "Window", "class")
Window.____readOnly = true

function Window:____init(data, from, to)
    self.data = data
    self.from = from
    self.to = to
end

function Window:getSize()
    return self.to - self.from
end

function Window:get(index)
    return self.data[self.from + index + 1] or __K2L_IndexError(self.from + index, self.data.size, "array")
end

function Window:isEmpty()
    return self:getSize() == 0
end

function Window:contains(element)
    return self:indexOf(element) >= 0
end

function Window:containsAll(elements)
    return elements:all(function(it) return self:contains(it) end)
end

function Window:indexOf(element)
    return __K2L_IntRange.new(0, self:getSize() - 1):firstOrNull(function(it) return self:get(it) == element end) or -1
end

function Window:lastIndexOf(element)
    return __K2L_IntRange.new(self:getSize() - 1, 0, -1):firstOrNull(function(it) return self:get(it) == element end) or -1
end

function Window:iterator()
    return self:listIterator()
end

function Window:listIterator()
    return self:listIteratorAt(0)
end

function Window:listIteratorAt(index)
    return __K2L_JdkCollections.listIterator(self.data:copyOfRange(self.from, self.to):toList(), index)
end

function Window:subList(fromIndex, toIndex)
    return Window.new(self.data, self.from + fromIndex, self.from + toIndex)
end

__K2L_PropertyOverride(Window, "size", "getSize")
local Numbers = __K2L_Class("Numbers", __K2L_CollectionBase)
__K2L_ClassInfo(Numbers, "Numbers", "Numbers", "class")
Numbers.____readOnly = true

function Numbers:____init(count)
    self.count = count
end

function Numbers:getSize()
    return self.count
end

function Numbers:isEmpty()
    return self.count == 0
end

function Numbers:contains(element)
    return element >= 1 and element <= self.count
end

function Numbers:containsAll(elements)
    return elements:all(function(it) return self:contains(it) end)
end

function Numbers:iterator()
    return __K2L_IteratorOf(__K2L_IntRange.new(1, self.count))
end

__K2L_PropertyOverride(Numbers, "size", "getSize")
local Constants = __K2L_Class("Constants", __K2L_MapBase)
__K2L_ClassInfo(Constants, "Constants", "Constants", "class")
Constants.____readOnly = true

function Constants:____init()
    self.backing = __K2L_MapOf(__K2L_Pair.new("pi", 3.14), __K2L_Pair.new("e", 2.72))
end

function Constants:getEntries()
    return self.backing:getEntries()
end

function Constants:getKeys()
    return self.backing:getKeys()
end

function Constants:getValues()
    return self.backing:getValues()
end

function Constants:getSize()
    return self.backing.size
end

function Constants:isEmpty()
    return self.backing:isEmpty()
end

function Constants:containsKey(key)
    return self.backing:containsKey(key)
end

function Constants:containsValue(value)
    return self.backing:getValues():contains(value)
end

function Constants:get(key)
    return self.backing:get(key)
end

__K2L_PropertyOverride(Constants, "entries", "getEntries")
__K2L_PropertyOverride(Constants, "keys", "getKeys")
__K2L_PropertyOverride(Constants, "values", "getValues")
__K2L_PropertyOverride(Constants, "size", "getSize")
local Matrix = __K2L_Class("Matrix", __K2L_AbstractList)
__K2L_ClassInfo(Matrix, "Matrix", "Matrix", "class")
Matrix.____readOnly = true

function Matrix:____init(rows, cols)
    self.rows = rows
    self.cols = cols
end

function Matrix:getSize()
    return self.rows
end

function Matrix:get(index)
    return __K2L_ListOfSize(self.cols, function(it) return index * self.cols + it end)
end

function Matrix:toString()
    return "Matrix" .. __K2L_AbstractList.toString(self)
end

function Matrix:find(row)
    return __K2L_AbstractList.indexOf(self, row)
end

__K2L_PropertyOverride(Matrix, "size", "getSize")
local Bounded = __K2L_Class("Bounded", __K2L_List)
__K2L_ClassInfo(Bounded, "Bounded", "Bounded", "class")

function Bounded:____init(max)
    __K2L_List.____init(self)
    self.max = max
    self.rejected = __K2L_ListOf()
    if not (self.max > 0) then
        error(__K2L_IllegalArgumentException.new("Failed requirement."))
    end
end

function Bounded:add(element)
    if self.size >= self.max then
        self.rejected:add(element)
        return false
    end
    return __K2L_List.add(self, element)
end

local Base = __K2L_Class("Base", __K2L_List)
__K2L_ClassInfo(Base, "Base", "Base", "class")

function Base:____init()
    __K2L_List.____init(self)
end

function Base:total()
    return self:sum()
end

local Derived = __K2L_Class("Derived", Base)
__K2L_ClassInfo(Derived, "Derived", "Derived", "class")

function Derived:____init(extra)
    Base.____init(self)
    self.extra = extra
end

function Derived:add(element)
    return Base.add(self, element + self.extra)
end

local Snapshot = __K2L_Class("Snapshot", __K2L_List)
__K2L_ClassInfo(Snapshot, "Snapshot", "Snapshot", "class")

function Snapshot:____init(source)
    __K2L_List.____init(self, source)
end

local Sized = __K2L_Class("Sized", __K2L_HashMap)
__K2L_ClassInfo(Sized, "Sized", "Sized", "class")

function Sized:____init()
    __K2L_HashMap.____init(self, 64)
end

local Unsized = __K2L_Class("Unsized", __K2L_HashMap)
__K2L_ClassInfo(Unsized, "Unsized", "Unsized", "class")

function Unsized:____init()
    __K2L_HashMap.____init(self)
end

local Shelf = __K2L_Class("Shelf", __K2L_AbstractList)
__K2L_ClassInfo(Shelf, "Shelf", "Shelf", "class")

function Shelf:____init()
    self.items = __K2L_ListOf()
    self.sets = 0
end

function Shelf:getSize()
    return self.items.size
end

function Shelf:get(index)
    return self.items:get(index)
end

function Shelf:set(index, element)
    self.sets = self.sets + 1
    return self.items:set(index, element)
end

function Shelf:addAt(index, element)
    self.items:addAt(index, element)
end

function Shelf:removeAt(index)
    return self.items:removeAt(index)
end

__K2L_PropertyOverride(Shelf, "size", "getSize")

local ____lambda_1 = function(it) return it * 2 end
local ____lambda_2 = function(it)
    return (it >= 0 and it % 2 or 0 - -it % 2) == 0
end
local ____lambda_3 = function(it) return it.key end
local function interfaces()
    local w = Window.new(__K2L_TypedArrayOf("[I", 5, 6, 7, 8, 9), 1, 4)
    print(tostring(__K2L_StringStartsWith(__K2L_Str(w), "Window@")) .. " " .. w:getSize() .. " " .. w:get(1) .. " " .. w:indexOf(8) .. " " .. tostring(w:contains(7)) .. " " .. __K2L_Str(w:subList(1, 3):toList()) .. " " .. __K2L_Str(w:map(____lambda_1)) .. " " .. tostring(w:equals(__K2L_ReadOnlyListOf(6, 7, 8))))
    print(w:sum() .. " " .. __K2L_Str(w:reversed()) .. " " .. w:last() .. " " .. tostring(w:containsAll(__K2L_ReadOnlyListOf(6, 8))) .. " " .. w:listIteratorAt(1):next() .. " " .. w:joinToString())
    local t = 0
    local ____items, ____n = w:____array()
    for ____i = 1, ____n do
        local x = ____items[____i]
        t = t + x
    end
    print("loop " .. t .. " " .. tostring(__K2L_Str(w) == "[6, 7, 8]") .. " " .. tostring(__K2L_Hash(w) == __K2L_Hash(__K2L_ReadOnlyListOf(6, 7, 8))))
    local n = Numbers.new(4)
    print(tostring(__K2L_StringStartsWith(__K2L_Str(n), "Numbers@")) .. " " .. n:getSize() .. " " .. tostring(n:contains(3)) .. " " .. __K2L_Str(n:filter(____lambda_2)) .. " " .. __K2L_Str(n:toList()) .. " " .. n:max() .. " " .. tostring(n:equals(Numbers.new(4))))
    local c = Constants.new()
    print(tostring(__K2L_StringStartsWith(__K2L_Str(c), "Constants@")) .. " " .. __K2L_Str(c:get("pi")) .. " " .. __K2L_Str(c:getKeys()) .. " " .. __K2L_Str(c:getValues()) .. " " .. c:getSize() .. " " .. tostring(c:containsKey("e")) .. " " .. __K2L_Str(c:map(____lambda_3)) .. " " .. tostring(c:equals(__K2L_ReadOnlyMapOf(__K2L_Pair.new("pi", 3.14), __K2L_Pair.new("e", 2.72)))))
    local ____keys, ____values, ____n_1 = c:____arrays()
    for ____i_1 = 1, ____n_1 do
        local k, v = ____keys[____i_1], ____values[____i_1]
        io.write(k .. "=" .. __K2L_Str(v) .. ";")
    end
    print()
end

local ____lambda_4 = function(it) return it:sum() end
local ____lambda_5 = function(it) return it:upper() end
local ____lambda_6 = function(it) return it == "A" end
local function subclasses()
    local m = Matrix.new(3, 2)
    print(__K2L_Str(m) .. " " .. __K2L_Str(m:get(2)) .. " " .. m:find(__K2L_ReadOnlyListOf(2, 3)) .. " " .. __K2L_Str(m:flatten()) .. " " .. __K2L_Str(m:map(____lambda_4)))
    local b = Bounded.new(2)
    b:add("x")
    b:add("y")
    b:add("z")
    b:addAll(__K2L_ReadOnlyListOf("p", "q"))
    print("bounded " .. __K2L_Str(b) .. " rejected=" .. __K2L_Str(b.rejected) .. " " .. b.size)
    local d = Derived.new(100)
    d:add(1)
    d:add(2)
    print("derived " .. __K2L_Str(d) .. " " .. d:total() .. " " .. d.extra .. " " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(d)).simpleName or ""))
    local s = Snapshot.new(__K2L_ReadOnlyListOf(3, 1, 2))
    s:sort()
    print("snapshot " .. __K2L_Str(s) .. " " .. s.size)
    local sized = Sized.new()
    local unsized = Unsized.new()
    local ____list = __K2L_ReadOnlyListOf(40, 3, 17, 64, 1)
    for ____i_2 = 1, ____list.size do
        local k = ____list[____i_2]
        sized:set(k, "v" .. k)
        unsized:set(k, "v" .. k)
    end
    print("sized " .. __K2L_Str(sized:getKeys()) .. " unsized " .. __K2L_Str(unsized:getKeys()))
    local shelf = Shelf.new()
    shelf:addAll(__K2L_ReadOnlyListOf("c", "a", "b"))
    shelf:sort()
    print("shelf " .. __K2L_Str(shelf) .. " sets=" .. shelf.sets)
    __K2L_JdkCollections.reverse(shelf)
    shelf:replaceAll(____lambda_5)
    print("reverse/replaceAll " .. __K2L_Str(shelf) .. " " .. tostring(shelf.sets > 0))
    shelf:shuffle(__K2L_JavaRandom.new(4))
    print("shuffle " .. __K2L_Str(shelf:sorted()) .. " " .. shelf:getSize())
    shelf:removeIf(____lambda_6)
    shelf:addAt(0, "Z")
    local ____value = shelf:toMutableList()
    ____value:add("!")
    print("removeIf/add " .. __K2L_Str(shelf) .. " " .. __K2L_Str(____value) .. " " .. __K2L_Str(shelf:getIndices()))
    for i = 0, shelf.size - 1 do
        shelf:set(i, shelf:get(i) .. i)
    end
    print("indices " .. __K2L_Str(shelf))
end

local function main()
    interfaces()
    subclasses()
end

main()
return {Window = Window, Numbers = Numbers, Constants = Constants, Matrix = Matrix, Bounded = Bounded, Base = Base, Derived = Derived, Snapshot = Snapshot, Sized = Sized, Unsized = Unsized, Shelf = Shelf, interfaces = interfaces, subclasses = subclasses}
