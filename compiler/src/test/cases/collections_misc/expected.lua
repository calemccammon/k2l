local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_CompareByDescending = ____lualib.__K2L_CompareByDescending
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ThenBy = ____lualib.__K2L_ThenBy
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_Triple = ____lualib.__K2L_Triple
local __K2L_Unpack = ____lualib.__K2L_Unpack

local windowedSumPairs
local Version = __K2L_Class("Version")

function Version:____init(major, minor)
    self.major = major
    self.minor = minor
end

function Version:compareTo(other)
    return self.major ~= other.major and self.major - other.major or self.minor - other.minor
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

local function sumAll(...)
    local numbers = __K2L_ArrayOf(...)
    local total = 0
    for ____i = 1, numbers.size do
        local n = numbers[____i]
        total = total + n
    end
    return total
end

local function describe(label, ...)
    local parts = __K2L_ArrayOf(...)
    return label .. ": " .. parts:joinToString(" ")
end

local function main()
    print(sumAll())
    print(sumAll(1, 2, 3))
    local nums = __K2L_ArrayOf(4, 5)
    print(sumAll(__K2L_Unpack(nums)))
    print(describe("parts", "a", "b"))
    local pair = __K2L_Pair.new("x", 1)
    print(__K2L_Str(pair))
    print(pair.first .. pair.second)
    local name, value = pair.first, pair.second
    print(name .. "=" .. value)
    local triple = __K2L_Triple.new(1, "two", 3.0)
    print(__K2L_Str(triple))
    local versions = __K2L_ListOf(Version.new(1, 2), Version.new(0, 9), Version.new(1, 0))
    print(__K2L_Str(versions:sorted()))
    print(__K2L_Compare(Version.new(1, 0), Version.new(1, 2)) < 0)
    print(__K2L_Str(versions:maxOrNull()))
    print(__K2L_Str(versions:sortedWith(__K2L_CompareBy(function(it) return it.minor end))))
    print(__K2L_Str(versions:sortedWith(__K2L_ThenBy(__K2L_CompareByDescending(function(it) return it.major end), function(it) return it.minor end))))
    local r = __K2L_IntRange.new(1, 10)
    print(__K2L_Str(r:toList():filter(function(it) return math.fmod(it, 3) == 0 end)))
    print(__K2L_Str(__K2L_IntRange.new(1, 4):map(function(it) return it * it end)))
    print(__K2L_Str(__K2L_IntRange.new(10, 1, -1):withStep(4):toList()))
    print(r:contains(5))
    local sum = 0
    for i = r.first, r.last, r.step do
        sum = sum + i
    end
    print(sum)
    print(__K2L_Str(r))
    local evens = __K2L_IntRange.new(0, 10 - 1):withStep(2):toList()
    print(__K2L_Str(evens))
    local words = __K2L_ListOf("banana", "Apple", "cherry")
    print(__K2L_Str(words:sortedBy(function(it) return it:lower() end)))
    print(words:map(function(it) return #it end):sum())
    print(words:filter(function(it) return #it > 5 end).size)
    local lookup = words:withIndex():associate(function(____destructured)
        local i, w = ____destructured.index, ____destructured.value
        return __K2L_Pair.new(w, i)
    end)
    print(__K2L_Str(lookup))
    print(__K2L_Str(__K2L_ListOf(3, 1, 2):sortedWith(function(a, b) return b - a end)))
    local queue = __K2L_List.new()
    queue:addAll(__K2L_ListOf(1, 2, 3))
    print(queue:removeFirst())
    print(__K2L_Str(queue))
    print(__K2L_Str(windowedSumPairs(__K2L_ListOf(1, 2, 3, 4))))
end

function windowedSumPairs(self)
    return self:zip(self:drop(1)):map(function(____destructured_1)
        local a, b = ____destructured_1.first, ____destructured_1.second
        return a + b
    end)
end

main()
return {Version = Version, sumAll = sumAll, describe = describe, windowedSumPairs = windowedSumPairs}
