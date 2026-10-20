local ____lualib = require("lualib_bundle")
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_CallableMixin = ____lualib.__K2L_CallableMixin
local __K2L_CharSequenceText = ____lualib.__K2L_CharSequenceText
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ComparatorMixin = ____lualib.__K2L_ComparatorMixin
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_CompareByWith = ____lualib.__K2L_CompareByWith
local __K2L_CompareValues = ____lualib.__K2L_CompareValues
local __K2L_FunInterface = ____lualib.__K2L_FunInterface
local __K2L_FunctionMixin = ____lualib.__K2L_FunctionMixin
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IterableBase = ____lualib.__K2L_IterableBase
local __K2L_Iterator = ____lualib.__K2L_Iterator
local __K2L_JdkCollections = ____lualib.__K2L_JdkCollections
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_NaturalOrder = ____lualib.__K2L_NaturalOrder
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_PropertyOverride = ____lualib.__K2L_PropertyOverride
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReverseComparator = ____lualib.__K2L_ReverseComparator
local __K2L_RunnableMixin = ____lualib.__K2L_RunnableMixin
local __K2L_SortedSet = ____lualib.__K2L_SortedSet
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringIndexOf = ____lualib.__K2L_StringIndexOf
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_Then = ____lualib.__K2L_Then
local __K2L_ThenBy = ____lualib.__K2L_ThenBy

local ByLength = __K2L_Class("ByLength", nil, __K2L_ComparatorMixin)

function ByLength:____init()
    self.calls = 0
end

function ByLength:compare(a, b)
    self.calls = self.calls + 1
    return #a - #b
end

local Version = __K2L_Class("Version")
Version.____comparable = true

function Version:____init(major, minor)
    self.major = major
    self.minor = minor
end

function Version.new(major, minor)
    return setmetatable({major = major, minor = minor}, Version)
end

local ____lambda_1 = function(it) return it.major end
local ____lambda_2 = function(it) return it.minor end
function Version:compareTo(other)
    return __K2L_CompareBy(____lambda_1, ____lambda_2)(self, other)
end

function Version:toString()
    return "Version(major=" .. self.major .. ", minor=" .. self.minor .. ")"
end

function Version:hashCode()
    return (31 * self.major + self.minor + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Version:equals(other)
    return getmetatable(other) == Version and self.major == other.major and self.minor == other.minor
end

local Count = __K2L_Class("Count")

function Count:____init(n)
    self.n = n
    self.i = 0
end

function Count:hasNext()
    return self.i < self.n
end

function Count:next()
    local ____old = self.i
    self.i = self.i + 1
    return ____old
end

local Upto = __K2L_Class("Upto", __K2L_IterableBase)
Upto.____readOnly = true

function Upto:____init(n)
    self.n = n
end

function Upto:iterator()
    return Count.new(self.n)
end

local Letters = __K2L_Class("Letters")

function Letters:____init(text)
    self.text = text
end

function Letters.new(text)
    return setmetatable({text = text}, Letters)
end

function Letters:getLength()
    return #self.text
end

function Letters:get(index)
    return index >= 0 and index < #self.text and self.text:sub(index + 1, index + 1) or __K2L_IndexError(index, #self.text, "string")
end

function Letters:subSequence(startIndex, endIndex)
    return Letters.new(__K2L_Text.substring(self.text, startIndex, endIndex))
end

function Letters:toString()
    return self.text
end

__K2L_PropertyOverride(Letters, "length", "getLength")
local Task = __K2L_Class("Task", nil, __K2L_RunnableMixin)

function Task:____init(name)
    self.name = name
end

function Task:run()
    print("run " .. self.name)
end

local Answer = __K2L_Class("Answer", nil, __K2L_CallableMixin)

function Answer:call()
    return 42
end

local Doubler = __K2L_Class("Doubler", nil, __K2L_FunctionMixin)

function Doubler:invoke(x)
    return x * 2
end

local Check = __K2L_Class("Check")

local ____lambda_3 = function(it) return it end
local ____lambda_4 = function(a, b) return __K2L_Text.compare(b, a) end
local function comparators()
    local words = __K2L_ReadOnlyListOf("ccc", "a", "bb", "dddd", "ee")
    local byLength = ByLength.new()
    print(__K2L_Str(words:sortedWith(byLength)))
    print("calls " .. byLength.calls .. " " .. byLength:compare("aa", "b"))
    print(__K2L_Str(words:sortedWith(__K2L_ReverseComparator(byLength))))
    print(__K2L_Str(words:sortedWith(__K2L_ThenBy(byLength, ____lambda_3))))
    print(__K2L_Str(words:sortedWith(__K2L_Then(byLength, __K2L_ReverseComparator(__K2L_NaturalOrder)))))
    print(words:maxWith(byLength) .. " " .. __K2L_Str(words:minWithOrNull(byLength)))
    local mutable = words:toMutableList()
    mutable:sortWith(byLength)
    __K2L_JdkCollections.sort(mutable, ByLength.new())
    print(__K2L_Str(mutable))
    local tree = __K2L_SortedSet.new(ByLength.new())
    tree:addAll(words)
    print(__K2L_Str(tree))
    local sam = ____lambda_4
    print(__K2L_Str(words:sortedWith(sam)) .. " " .. sam("a", "b") .. " " .. __K2L_Str(words:sortedWith(__K2L_ReverseComparator(sam))))
    local arr = words:toTypedArray("[Ljava.lang.String;")
    __K2L_JdkCollections.sort_array(arr, byLength)
    print(__K2L_Str(arr:toList()))
end

local ____lambda_5 = function(it) return it end
local function comparables()
    local vs = __K2L_ReadOnlyListOf(Version.new(1, 2), Version.new(0, 9), Version.new(1, 0))
    print(__K2L_Str(vs:sorted()) .. " " .. __K2L_Str(vs:max()) .. " " .. __K2L_Str(vs:minOrNull()) .. " " .. __K2L_Str(vs:sortedDescending()))
    print(tostring(__K2L_Compare(Version.new(1, 0), Version.new(1, 1)) < 0) .. " " .. tostring(__K2L_Compare(Version.new(2, 0), Version.new(1, 9)) >= 0) .. " " .. Version.new(1, 1):compareTo(Version.new(1, 1)))
    print(__K2L_Str(__K2L_Num.coerceIn(Version.new(3, 0), Version.new(1, 0), Version.new(2, 0))) .. " " .. __K2L_Str(__K2L_Num.maxOf(Version.new(1, 0), Version.new(0, 5))) .. " " .. __K2L_Str(vs:sortedBy(____lambda_5, true)))
    print(__K2L_Str(vs:sortedWith(__K2L_NaturalOrder)))
end

local ____lambda_6 = function(it) return it * it end
local ____lambda_7 = function(it)
    return (it >= 0 and it % 2 or 0 - -it % 2) == 0
end
local function iterators()
    for _, x in __K2L_Iterator.iter(Count.new(3)) do
        io.write(x .. " ")
    end
    print()
    local c = Count.new(4)
    print(c:next() .. " " .. tostring(c:hasNext()) .. " " .. __K2L_Str(__K2L_AsSequence(c):toList()))
    local u = Upto.new(5)
    print(__K2L_Str(u:map(____lambda_6)) .. " " .. __K2L_Str(u:filter(____lambda_7)) .. " " .. __K2L_Str(u:toList()) .. " " .. u:joinToString("-") .. " " .. u:sum() .. " " .. u:count())
    local total = 0
    local ____items, ____n = u:____array()
    for ____i = 1, ____n do
        local x = ____items[____i]
        total = total + x
    end
    local ____items_1, ____n_1 = u:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        total = total + it
    end
    print("total " .. total .. " " .. u:first() .. " " .. u:last() .. " " .. tostring(u:contains(3)) .. " " .. __K2L_Str(u:sortedDescending()) .. " " .. __K2L_Str(u:toSet()) .. " " .. __K2L_Str(u:zip(u:drop(1))))
end

local ____lambda_8 = function(it)
    return (it >= 0 and it % 2 or 0 - -it % 2) == 0
end
local function others()
    local l = Letters.new("hello")
    print(l:getLength() .. " " .. l:get(1) .. " " .. __K2L_Str(l:subSequence(1, 3)) .. " " .. __K2L_Str(l) .. " " .. "[" .. __K2L_Str(l) .. "]" .. " " .. l:toString():upper())
    Task.new("t1"):run()
    local tasks = __K2L_ReadOnlyListOf(Task.new("t2"), function()
        print("lambda runnable")
    end)
    local ____mod = tasks.____modCount
    for ____i_2 = 1, tasks.size do
        local it = tasks[____i_2]
        it()
        if tasks.____modCount ~= ____mod and tasks:____comodified(____i_2) then
            break
        end
    end
    print(Answer.new():call())
    local d = Doubler.new()
    print(d:invoke(4) .. " " .. __K2L_Str(__K2L_ReadOnlyListOf(1, 2):map(d)))
    local even = __K2L_FunInterface(Check, "test", ____lambda_8)
    print(tostring(even:test(4)) .. " " .. tostring(even:test(3)))
end

local Named = __K2L_Class("Named")

function Named:____init(name)
    self.name = name
end

function Named.new(name)
    return setmetatable({name = name}, Named)
end

local Reverse = __K2L_Class("Reverse", Named, __K2L_ComparatorMixin)

function Reverse:____init()
    Named.____init(self, "reverse")
end

function Reverse:compare(a, b)
    return __K2L_Compare(b, a)
end

local Backwards = __K2L_Class("Backwards")

function Backwards:____init(items)
    self.items = items
    self.i = self.items.size
end

function Backwards:hasNext()
    return self.i > 0
end

function Backwards:next()
    local ____arg = self.items
    self.i = self.i - 1
    return ____arg:get(self.i)
end

function Backwards:hasPrevious()
    return self.i < self.items.size
end

function Backwards:previous()
    local ____arg_1 = self.items
    local ____old_1 = self.i
    self.i = self.i + 1
    return ____arg_1:get(____old_1)
end

function Backwards:nextIndex()
    return self.items.size - self.i
end

function Backwards:previousIndex()
    return self:nextIndex() - 1
end

local function describe(cs)
    return __K2L_Text.charsLength(cs) .. ":" .. __K2L_Text.charsGet(cs, 0) .. ":" .. __K2L_Str(__K2L_Text.substring(__K2L_CharSequenceText(cs), 1, 3)) .. ":" .. tostring(#__K2L_CharSequenceText(cs) == 0) .. ":" .. __K2L_Str(__K2L_CharSequenceText(cs):reverse()) .. ":" .. __K2L_StringIndexOf(__K2L_CharSequenceText(cs), "l")
end

local function countMatching(xs, check)
    return xs:count(function(it) return check:test(it) end)
end

local function twice(r)
    r()
    r()
end

local function smallest(words, c)
    return words:minWith(c)
end

local ____lambda_9 = function(x, y) return #y - #x end
local ____lambda_10 = function(it) return it .. it end
local ____lambda_11 = function(it) return it > 1 end
local ____lambda_12 = function(it)
    return (it >= 0 and it % 2 or 0 - -it % 2) == 1
end
local ____lambda_13 = function(____a, ____b)
    return __K2L_CompareValues(____a, ____b)
end
local function more()
    twice(function()
        print("sam lambda")
    end)
    twice(Task.new("t3"))
    print(smallest(__K2L_ReadOnlyListOf("bb", "a"), ByLength.new()) .. " " .. smallest(__K2L_ReadOnlyListOf("bb", "a"), ____lambda_9))
    local r = Reverse.new()
    print(__K2L_Str(__K2L_ReadOnlyListOf(1, 3, 2):sortedWith(r)) .. " " .. r.name .. " " .. tostring(type(r) == "function" or __K2L_InstanceOf(r, __K2L_ComparatorMixin)) .. " " .. __K2L_ReadOnlyListOf(5, 9):maxWith(r))
    print(__K2L_Str(__K2L_ReadOnlyListOf("b", "aa", "c"):sortedWith(__K2L_CompareByWith(ByLength.new(), ____lambda_10))))
    print(describe(Letters.new("hello")) .. " " .. describe("world") .. " " .. tostring(__K2L_StringContains(__K2L_CharSequenceText(Letters.new("foo")), "o")) .. " " .. __K2L_Text.first(__K2L_CharSequenceText(Letters.new("abc"))))
    print(countMatching(__K2L_ReadOnlyListOf(1, 2, 3, 4), __K2L_FunInterface(Check, "test", ____lambda_11)) .. " " .. countMatching(__K2L_ReadOnlyListOf(1, 2, 3), __K2L_FunInterface(Check, "test", ____lambda_12)))
    local b = Backwards.new(__K2L_ReadOnlyListOf("x", "y", "z"))
    local seen = __K2L_ListOf()
    for _, s in __K2L_Iterator.iter(b) do
        seen:add(s)
    end
    print(__K2L_Str(seen) .. " " .. tostring(b:hasPrevious()) .. " " .. b:previous() .. " " .. b:nextIndex())
    print(__K2L_Str(__K2L_Num.coerceAtLeast(Version.new(1, 5), Version.new(2, 0))) .. " " .. __K2L_Str(__K2L_ReadOnlyListOf(Version.new(0, 1), Version.new(0, 0)):sortedWith(____lambda_13)))
end

local function main()
    more()
    comparators()
    comparables()
    iterators()
    others()
end

main()
return {ByLength = ByLength, Version = Version, Count = Count, Upto = Upto, Letters = Letters, Task = Task, Answer = Answer, Doubler = Doubler, Check = Check, comparators = comparators, comparables = comparables, iterators = iterators, others = others, Named = Named, Reverse = Reverse, Backwards = Backwards, describe = describe, countMatching = countMatching, twice = twice, smallest = smallest, more = more}
