local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_CompareByDescending = ____lualib.__K2L_CompareByDescending
local __K2L_EnumValueOf = ____lualib.__K2L_EnumValueOf
local __K2L_EnumValues = ____lualib.__K2L_EnumValues
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_SortedSet = ____lualib.__K2L_SortedSet
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ThenBy = ____lualib.__K2L_ThenBy
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32

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

Level.LOW = Level.new("LOW", 0)
Level.MEDIUM = Level.new("MEDIUM", 1)
Level.HIGH = Level.new("HIGH", 2)
Level.CRITICAL = Level.new("CRITICAL", 3)
Level.____values = {Level.LOW, Level.MEDIUM, Level.HIGH, Level.CRITICAL}
local Shape = __K2L_Class("Shape")

function Shape:____init(name, ordinal, corners)
    self.name = name
    self.ordinal = ordinal
    self.corners = corners
end

function Shape:toString()
    return self.name
end

function Shape:compareTo(other)
    return self.ordinal - other.ordinal
end

Shape.CIRCLE = Shape.new("CIRCLE", 0, 0)
do
    local ____TRIANGLE = __K2L_Class("Shape", Shape)
    function ____TRIANGLE:toString()
        return "tri"
    end
    Shape.TRIANGLE = ____TRIANGLE.new("TRIANGLE", 1, 3)
end
Shape.SQUARE = Shape.new("SQUARE", 2, 4)
Shape.____values = {Shape.CIRCLE, Shape.TRIANGLE, Shape.SQUARE}

function Shape:byCorners(n)
    return __K2L_EnumValues(Shape):firstOrNull(function(it) return it.corners == n end)
end

function Shape:all()
    return __K2L_EnumValues(Shape):toList()
end

function Shape:named(s)
    return __K2L_EnumValueOf(Shape, s:upper())
end

local Task = __K2L_Class("Task")

function Task:____init(name, level, shape)
    self.name = name
    self.level = level
    self.shape = shape
end

function Task:toString()
    return "Task(name=" .. self.name .. ", level=" .. __K2L_Str(self.level) .. ", shape=" .. __K2L_Str(self.shape) .. ")"
end

function Task:hashCode()
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.name) + __K2L_Hash(self.level)) + __K2L_Hash(self.shape))
end

function Task:equals(other)
    return getmetatable(other) == Task and self.name == other.name and self.level == other.level and self.shape == other.shape
end

local Version = __K2L_Class("Version")

function Version:____init(major, minor)
    self.major = major
    self.minor = minor
end

function Version:compareTo(other)
    return __K2L_CompareBy(function(it) return it.major end, function(it) return it.minor end)(self, other)
end

function Version:toString()
    return "Version(major=" .. self.major .. ", minor=" .. self.minor .. ")"
end

function Version:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.major) + __K2L_Hash(self.minor))
end

function Version:equals(other)
    return getmetatable(other) == Version and self.major == other.major and self.minor == other.minor
end

local function largest(xs)
    return xs:reduce(function(a, b)
        return __K2L_Compare(a, b) >= 0 and a or b
    end)
end

local function main()
    print(tostring(__K2L_Compare(Level.LOW, Level.HIGH) < 0) .. " " .. tostring(__K2L_Compare(Level.CRITICAL, Level.MEDIUM) <= 0) .. " " .. __K2L_Compare(Level.HIGH, Level.LOW) .. " " .. __K2L_Compare(Level.LOW, Level.LOW))
    print(__K2L_Str(__K2L_ReadOnlyListOf(Level.HIGH, Level.LOW, Level.CRITICAL, Level.MEDIUM):sorted()))
    print(__K2L_Str(__K2L_ReadOnlyListOf(Level.HIGH, Level.LOW):sortedDescending()))
    print(__K2L_Str(__K2L_ReadOnlyListOf(Level.MEDIUM, Level.CRITICAL, Level.LOW):max()) .. " " .. __K2L_Str(__K2L_Num.maxOf(Level.LOW, Level.HIGH)) .. " " .. __K2L_Str(__K2L_Num.minOf(Shape.SQUARE, Shape.TRIANGLE)))
    print(__K2L_Str(largest(__K2L_ReadOnlyListOf(Shape.TRIANGLE, Shape.SQUARE, Shape.CIRCLE))))
    local tasks = __K2L_ReadOnlyListOf(Task.new("b", Level.HIGH, Shape.SQUARE), Task.new("a", Level.LOW, Shape.TRIANGLE), Task.new("c", Level.HIGH, Shape.CIRCLE), Task.new("d", Level.MEDIUM, Shape.TRIANGLE))
    print(__K2L_Str(tasks:sortedBy(function(it) return it.level end, true):map(function(it) return it.name end)))
    print(__K2L_Str(tasks:sortedWith(__K2L_ThenBy(__K2L_CompareByDescending(function(it) return it.level end), function(it) return it.shape end)):map(function(it) return it.name end)))
    print(__K2L_Str(tasks:sortedWith(__K2L_CompareBy(function(it) return it.shape end, function(it) return it.name end)):map(function(it) return it.name end)))
    print(tasks:maxBy(function(it) return it.shape end).name .. " " .. __K2L_Str(tasks:minOf(function(it) return it.level end)))
    local c = Level.MEDIUM
    print(tostring(__K2L_Compare(c, Level.LOW) > 0) .. " " .. __K2L_Compare(c, Level.CRITICAL))
    print(__K2L_Str(__K2L_SortedSet.new(__K2L_ReadOnlyListOf(Shape.SQUARE, Shape.TRIANGLE, Shape.CIRCLE))))
    print(__K2L_Str(__K2L_SortedMapOf(__K2L_Pair.new(Level.HIGH, 1), __K2L_Pair.new(Level.LOW, 2))))
    for _, level in ipairs(__K2L_EnumValues(Level)) do
        local band
        if __K2L_Compare(level, Level.LOW) >= 0 and __K2L_Compare(level, Level.MEDIUM) <= 0 then
            band = "routine"
        elseif __K2L_Compare(level, Level.HIGH) >= 0 and __K2L_Compare(level, Level.CRITICAL) <= 0 then
            band = "urgent"
        else
            band = "?"
        end
        print(__K2L_Str(level) .. " " .. band .. " " .. tostring(__K2L_Compare(level, Level.MEDIUM) >= 0 and __K2L_Compare(level, Level.HIGH) <= 0) .. " " .. tostring(not (__K2L_Compare(level, Level.LOW) >= 0 and __K2L_Compare(level, Level.LOW) <= 0)))
    end
    local v = Version.new(1, 4)
    local ____bound = Version.new(1, 0)
    local ____bound_1 = Version.new(2, 0)
    local ____bound_2 = Version.new(1, 5)
    local ____bound_3 = Version.new(2, 0)
    local ____bound_4 = Version.new(1, 0)
    local ____bound_5 = Version.new(2, 0)
    local ____value = Version.new(2, 0)
    print(tostring(__K2L_Compare(v, ____bound) >= 0 and __K2L_Compare(v, ____bound_1) <= 0) .. " " .. tostring(__K2L_Compare(v, ____bound_2) >= 0 and __K2L_Compare(v, ____bound_3) <= 0) .. " " .. tostring(__K2L_Compare(____value, ____bound_4) >= 0 and __K2L_Compare(____value, ____bound_5) <= 0))
    print(tostring("b" >= "a" and "b" <= "c") .. " " .. tostring("d" >= "a" and "d" <= "c") .. " " .. tostring(2.5 >= 1.0 and 2.5 <= 3.0))
    print(__K2L_Str(Shape:byCorners(3)) .. " " .. __K2L_Str(Shape:byCorners(5)) .. " " .. __K2L_Str(Shape:all()) .. " " .. __K2L_Str(Shape:named("square")))
    print(__K2L_Str(__K2L_RunCatching(function() return Shape:named("hexagon") end):exceptionOrNull()))
end

main()
return {Level = Level, Shape = Shape, Task = Task, Version = Version, largest = largest}
