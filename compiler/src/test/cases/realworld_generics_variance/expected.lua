local ____lualib = require("lualib_bundle")
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_CompareValues = ____lualib.__K2L_CompareValues
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IsComparable = ____lualib.__K2L_IsComparable
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SimpleName = ____lualib.__K2L_SimpleName
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Producer = __K2L_Class("generics.variance.Producer")
local Consumer = __K2L_Class("generics.variance.Consumer")
local Animal = __K2L_Class("generics.variance.Animal")
Animal.____comparable = true

function Animal:____init(name)
    self.name = name
    self.sound = "..."
end

function Animal:compareTo(other)
    return __K2L_Text.compare(self.name, other.name)
end

function Animal:toString()
    return __K2L_Str(__K2L_SimpleName(self)) .. "(" .. self.name .. ")"
end

local Dog = __K2L_Class("generics.variance.Dog", Animal)

function Dog:____init(name, tricks)
    if tricks == nil then
        tricks = 0
    end
    Animal.____init(self, name)
    self.tricks = tricks
    self.sound = "woof"
end

local Cat = __K2L_Class("generics.variance.Cat", Animal)

function Cat:____init(name, lives)
    if lives == nil then
        lives = 9
    end
    Animal.____init(self, name)
    self.lives = lives
    self.sound = "meow"
end

local Shelter = __K2L_Class("generics.variance.Shelter", nil, Producer)

function Shelter:____init(animals)
    self.animals = animals
    self.next = 0
end

function Shelter:produce()
    local ____arg = self.animals
    local ____old = self.next
    self.next = self.next + 1
    return ____arg:get(____old % self.animals.size)
end

function Shelter:all()
    return self.animals
end

local Logger = __K2L_Class("generics.variance.Logger", nil, Consumer)

function Logger:____init(prefix, render)
    self.prefix = prefix
    self.render = render
    self.lines = __K2L_ListOf()
end

function Logger:consume(item)
    self.lines:add(self.prefix .. " " .. self.render(item))
end

local function transfer(from, to, n)
    for it = 0, n - 1 do
        to:consume(from:produce())
    end
end

local function copyInto(source, target)
    for ____i = 1, source.size do
        local a = source[____i]
        target:add(a)
    end
end

local function describeAll(items)
    return items:joinToString(nil, nil, nil, nil, nil, function(item)
        if item == nil then
            return "null"
        elseif __K2L_InstanceOf(item, Animal) then
            return "animal " .. item.name
        elseif __K2L_IsComparable(item) then
            return "comparable " .. __K2L_Str(item)
        else
            return "other " .. __K2L_Str(__K2L_SimpleName(item))
        end
    end)
end

local function sizes(groups)
    return groups:mapValues(function(____destructured)
        local v = ____destructured.value
        return v.size
    end)
end

local function maxOf3(a, b, c)
    return __K2L_Num.maxOf(a, __K2L_Num.maxOf(b, c))
end

local function isSorted(self)
    local ____list = self:zipWithNext()
    local ____result = true
    local ____items, ____n = ____list:____array()
    for ____i_1 = 1, ____n do
        local ____it = ____items[____i_1]
        local ____result_1
        do
            local a, b = ____it.first, ____it.second
            ____result_1 = __K2L_Compare(a, b) <= 0
        end
        if not ____result_1 then
            ____result = false
            break
        end
    end
    return ____result
end

local function insertionSorted(____this)
    local out = ____this:toMutableList()
    for i = 1, out.size - 1 do
        local x = out:get(i)
        local j = i - 1
        while j >= 0 and __K2L_Compare(out:get(j), x) > 0 do
            local ____key = j + 1
            out:set(____key, out:get(j))
            j = j - 1
        end
        local ____key_1 = j + 1
        out:set(____key_1, x)
    end
    return out
end

local ____lambda_1 = function(____a, ____b)
    local ____c = __K2L_CompareValues(____b.value, ____a.value)
    if ____c ~= 0 then
        return ____c
    end
    return __K2L_CompareValues(____a.key, ____b.key)
end
local function topBy(entries, n)
    local ____list_1 = entries:getEntries():sortedWith(____lambda_1):take(n)
    local ____out = {}
    local ____count = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_2 = 1, ____n_1 do
        local it = ____items_1[____i_2]
        ____count = ____count + 1
        ____out[____count] = it.key
    end
    return __K2L_ListWrap(____out, ____count)
end

local ____lambda_2 = function(it) return #it .. ":" .. __K2L_Str(it) end
local function joinWhere(items)
    return items:sorted():joinToString("+", nil, nil, nil, nil, ____lambda_2)
end

local Version = __K2L_Class("generics.variance.Version")
Version.____comparable = true

function Version.new(major, minor, patch)
    return setmetatable({major = major, minor = minor, patch = patch}, Version)
end

local ____lambda_3 = function(receiver) return receiver.major end
local ____lambda_4 = function(receiver) return receiver.minor end
local ____lambda_5 = function(receiver) return receiver.patch end
function Version:compareTo(other)
    return __K2L_CompareBy(__K2L_PropertyRef.new("major", "major@2619", ____lambda_3), __K2L_PropertyRef.new("minor", "minor@2635", ____lambda_4), __K2L_PropertyRef.new("patch", "patch@2651", ____lambda_5))(self, other)
end

function Version:toString()
    return self.major .. "." .. self.minor .. "." .. self.patch
end

__K2L_DataClass(Version, {"major", "minor", "patch"})
Version.____companion = true

local ____lambda_6 = function(____p1) return __K2L_StringToInt(____p1) end
function Version:parse(s)
    local ____value = __K2L_StringSplit(s, "."):map(____lambda_6)
    local ____result_2
    do
        local a, b, c = ____value[1], ____value[2], ____value[3]
        ____result_2 = Version.new(a, b, c)
    end
    return ____result_2
end

local Range = __K2L_Class("generics.variance.Range")

function Range:____init(start, ____end)
    self.start = start
    self["end"] = ____end
    if not (__K2L_Compare(self.start, self["end"]) <= 0) then
        error(__K2L_IllegalArgumentException.new("empty range " .. __K2L_Str(self.start) .. ".." .. __K2L_Str(self["end"])))
    end
end

function Range:contains(x)
    return __K2L_Compare(x, self.start) >= 0 and __K2L_Compare(x, self["end"]) <= 0
end

function Range:clamp(x)
    if __K2L_Compare(x, self.start) < 0 then
        return self.start
    else
        return __K2L_Compare(x, self["end"]) > 0 and self["end"] or x
    end
end

function Range:intersect(other)
    local s = __K2L_Num.maxOf(self.start, other.start)
    local e = __K2L_Num.minOf(self["end"], other["end"])
    return __K2L_Compare(s, e) <= 0 and Range.new(s, e) or nil
end

function Range:toString()
    return "[" .. __K2L_Str(self.start) .. ", " .. __K2L_Str(self["end"]) .. "]"
end

local Shape = __K2L_Class("generics.variance.Shape")
Shape.____comparable = true

function Shape:compareTo(other)
    return __K2L_Compare(self:getArea(), other:getArea())
end

local Square = __K2L_Class("generics.variance.Square", Shape)

function Square.new(side)
    return setmetatable({side = side}, Square)
end

function Square:getArea()
    return self.side * self.side
end

function Square:scaled(k)
    return Square.new(self.side * k)
end

function Square:toString()
    return "Square(" .. self.side .. ")"
end

local function largestAfterScaling(shapes, k)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_2, ____n_2 = shapes:____array()
    for ____i_3 = 1, ____n_2 do
        local it = ____items_2[____i_3]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = it:scaled(k)
    end
    return __K2L_ListWrap(____out_1, ____count_1):max()
end

local ____lambda_7 = function(it) return __K2L_Str(it) end
local ____lambda_8 = function(it) return it.name .. " says " .. it.sound end
local ____lambda_9 = function(x) return __K2L_InstanceOf(x, Animal) end
local function main()
    print("== producers and consumers")
    local dogs = Shelter.new(__K2L_ListOf(Dog.new("rex", 3), Dog.new("fido")))
    local animals = dogs
    local anyLog = Logger.new("any:", ____lambda_7)
    local animalLog = Logger.new("animal:", ____lambda_8)
    transfer(animals, animalLog, 3)
    local dogLog = anyLog
    transfer(dogs, dogLog, 2)
    transfer(Shelter.new(__K2L_ListOf(Cat.new("tom", 7))), anyLog, 1)
    if getmetatable(animalLog) ~= Logger then
        __K2L_CastFail(animalLog, "generics.variance.Logger")
    end
    print(__K2L_Str(animalLog.lines))
    print(__K2L_Str(anyLog.lines))
    print("== projections")
    local zoo = __K2L_ListOf("keeper")
    copyInto(dogs:all(), zoo)
    copyInto(__K2L_ListOf(Cat.new("kit")), zoo)
    print(__K2L_Str(zoo))
    print(describeAll(__K2L_ListOf(Dog.new("a"), 3, "s", nil, 2.5, __K2L_ListOf(1))))
    print(__K2L_Str(sizes(__K2L_MapOf(__K2L_Pair.new("dogs", dogs:all()), __K2L_Pair.new("mixed", __K2L_ListOf(1, "a", nil)), __K2L_Pair.new("none", __K2L_ListOf())))))
    local unknown = __K2L_ListOf(Cat.new("z"), Dog.new("y"))
    local ____cast = unknown:first()
    local firstAnimal = __K2L_InstanceOf(____cast, Animal) and ____cast or nil
    print("first=" .. __K2L_Str(firstAnimal and firstAnimal.name) .. " sound=" .. __K2L_Str(firstAnimal and firstAnimal.sound) .. " sorted=" .. __K2L_Str(unknown:filter(____lambda_9):sorted()))
    print("== recursive bounds")
    print("max3=" .. maxOf3(3, 9, 4) .. " " .. maxOf3("pear", "apple", "fig") .. " " .. __K2L_Str(maxOf3(Dog.new("b"), Cat.new("c"), Dog.new("a"))))
    local ____arg_1 = __K2L_ListOf("1.10.0", "1.2.3", "1.2.10", "0.9.9", "2.0.0")
    local ____receiver = Version
    local versions = ____arg_1:map(function(...) return ____receiver:parse(...) end)
    print("sorted=" .. __K2L_Str(insertionSorted(versions)) .. " isSorted=" .. tostring(isSorted(versions)) .. " " .. tostring(isSorted(versions:sorted())))
    local supported = Range.new(Version.new(1, 2, 0), Version.new(1, 10, 0))
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_3, ____n_3 = versions:____array()
    for ____i_4 = 1, ____n_3 do
        local it = ____items_3[____i_4]
        if supported:contains(it) then
            ____count_2 = ____count_2 + 1
            ____out_2[____count_2] = it
        end
    end
    print("in=" .. __K2L_Str(__K2L_ListWrap(____out_2, ____count_2)) .. " clamp=" .. __K2L_Str(supported:clamp(Version.new(3, 0, 0))))
    print("intersect=" .. __K2L_Str(supported:intersect(Range.new(Version.new(1, 5, 0), Version.new(2, 0, 0)))) .. " none=" .. __K2L_Str(Range.new(1, 3):intersect(Range.new(5, 9))))
    local ____ok, ____result_3 = pcall(function()
        Range.new("z", "a")
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_3)
        if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
            local e = ____error
            print("error: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    print("largest=" .. __K2L_Str(largestAfterScaling(__K2L_ListOf(Square.new(1.0), Square.new(3.0), Square.new(2.0)), 0.5)))
    print("== where")
    print(__K2L_Str(topBy(__K2L_MapOf(__K2L_Pair.new("b", 3), __K2L_Pair.new("a", 3), __K2L_Pair.new("c", 9), __K2L_Pair.new("d", 1)), 3)))
    print(__K2L_Str(topBy(__K2L_MapOf(__K2L_Pair.new(2, 0.5), __K2L_Pair.new(1, 1.5)), 5)))
    print(joinWhere(__K2L_ListOf("gamma", "alpha", "beta")))
    print(joinWhere(__K2L_ListOf(__K2L_StringBuilder.new("x"):toString(), "yy")))
end

__K2L_RunMain(main)
return {Producer = Producer, Consumer = Consumer, Animal = Animal, Dog = Dog, Cat = Cat, Shelter = Shelter, Logger = Logger, transfer = transfer, copyInto = copyInto, describeAll = describeAll, sizes = sizes, maxOf3 = maxOf3, isSorted = isSorted, insertionSorted = insertionSorted, topBy = topBy, joinWhere = joinWhere, Version = Version, Range = Range, Shape = Shape, Square = Square, largestAfterScaling = largestAfterScaling}
