local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_CompareValues = ____lualib.__K2L_CompareValues
local __K2L_EnumValueOf = ____lualib.__K2L_EnumValueOf
local __K2L_EnumValues = ____lualib.__K2L_EnumValues
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_SortedSet = ____lualib.__K2L_SortedSet
local __K2L_Str = ____lualib.__K2L_Str

local companions
local E = __K2L_Class("E")

function E:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function E:toString()
    return self.name
end

function E:compareTo(other)
    return self.ordinal - other.ordinal
end

E.A = E.new("A", 0)
E.B = E.new("B", 1)
E.C = E.new("C", 2)
E.____values = {E.A, E.B, E.C}
local Level = __K2L_Class("Level")

function Level:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Level:toString()
    return self.name
end

function Level:compareTo(other)
    return self.ordinal - other.ordinal
end

do
    local ____LOW = __K2L_Class("Level", Level)
    function ____LOW:label()
        return "low"
    end
    Level.LOW = ____LOW.new("LOW", 0)
end
do
    local ____HIGH = __K2L_Class("Level", Level)
    function ____HIGH:label()
        return "high"
    end
    Level.HIGH = ____HIGH.new("HIGH", 1)
end
Level.____values = {Level.LOW, Level.HIGH}
local Task = __K2L_Class("Task")

function Task:____init(name, level)
    self.name = name
    self.level = level
end

function Task.new(name, level)
    return setmetatable({name = name, level = level}, Task)
end

function Task:toString()
    return "Task(name=" .. self.name .. ", level=" .. __K2L_Str(self.level) .. ")"
end

function Task:hashCode()
    return (31 * __K2L_Hash(self.name) + __K2L_Hash(self.level) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Task:equals(other)
    return getmetatable(other) == Task and self.name == other.name and self.level == other.level
end

local ____lambda_1 = function(it) return it.key end
local ____lambda_2 = function(____a, ____b)
    local ____c = __K2L_CompareValues(____b.level, ____a.level)
    if ____c ~= 0 then
        return ____c
    end
    return __K2L_CompareValues(____a.name, ____b.name)
end
local ____lambda_3 = function(it) return it.level end
local function main()
    print(__K2L_Compare(E.A, E.B) < 0)
    print(__K2L_Compare(E.C, E.A))
    print(__K2L_Str(__K2L_ReadOnlyListOf(E.C, E.A, E.B):sorted()))
    print(__K2L_Str(__K2L_ReadOnlyListOf(E.C, E.A, E.B):max()))
    print(__K2L_Str(__K2L_ReadOnlyMapOf(__K2L_Pair.new(E.C, 1), __K2L_Pair.new(E.A, 2)):getEntries():sortedBy(____lambda_1, true)))
    local c = E.B
    print(__K2L_Compare(c, E.A))
    print(__K2L_Str(__K2L_Num.maxOf(E.A, E.C)))
    print(__K2L_Str(__K2L_Num.coerceIn(E.B, E.C, E.C)))
    print(__K2L_Str(__K2L_SortedSet.new(__K2L_ReadOnlyListOf(E.B, E.C, E.A, E.B))))
    local ____list = __K2L_ReadOnlyListOf(Level.HIGH, Level.LOW):sorted()
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = it:label()
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    print(__K2L_Compare(Level.HIGH, Level.LOW) > 0)
    local tasks = __K2L_ReadOnlyListOf(Task.new("x", Level.HIGH), Task.new("y", Level.LOW), Task.new("z", Level.HIGH))
    print(__K2L_Str(tasks:sortedWith(____lambda_2)))
    print(tasks:maxBy(____lambda_3).name)
    companions()
end

local Size = __K2L_Class("Size")

function Size:____init(name, ordinal, letter)
    self.name = name
    self.ordinal = ordinal
    self.letter = letter
end

function Size:toString()
    return self.name
end

function Size:compareTo(other)
    return self.ordinal - other.ordinal
end

Size.SMALL = Size.new("SMALL", 0, "s")
Size.LARGE = Size.new("LARGE", 1, "l")
Size.____values = {Size.SMALL, Size.LARGE}
Size.____companion = true

function Size:parse(c)
    local ____values = Size.____values
    local ____result
    for ____i_1 = 1, #____values do
        local it = ____values[____i_1]
        if it.letter == c then
            ____result = it
            break
        end
    end
    return ____result
end

function Size:count()
    return __K2L_EnumValues(Size).size
end

function Size:named(n)
    return __K2L_EnumValueOf(Size, n:upper())
end

function companions()
    print(__K2L_Str(Size:parse("l")) .. " " .. __K2L_Str(Size:parse("x")) .. " " .. Size:count() .. " " .. __K2L_Str(Size:named("small")))
end

main()
return {E = E, Level = Level, Task = Task, Size = Size, companions = companions}
