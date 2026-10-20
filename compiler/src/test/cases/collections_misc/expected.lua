local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_CompareByDescending = ____lualib.__K2L_CompareByDescending
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ThenBy = ____lualib.__K2L_ThenBy
local __K2L_Triple = ____lualib.__K2L_Triple
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf
local __K2L_Unpack = ____lualib.__K2L_Unpack

local windowedSumPairs
local Version = __K2L_Class("Version")
Version.____comparable = true

function Version:____init(major, minor)
    self.major = major
    self.minor = minor
end

function Version.new(major, minor)
    return setmetatable({major = major, minor = minor}, Version)
end

function Version:compareTo(other)
    return self.major ~= other.major and self.major - other.major or self.minor - other.minor
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

local ____lambda_1 = function(it) return it.minor end
local ____lambda_2 = function(it) return it.major end
local ____lambda_3 = function(it) return it.minor end
local ____lambda_4 = function(it) return it * it end
local ____lambda_5 = function(it) return it:lower() end
local ____lambda_6 = function(a, b) return b - a end
local function main()
    print(sumAll())
    print(sumAll(1, 2, 3))
    local nums = __K2L_TypedArrayOf("[I", 4, 5)
    print(sumAll(__K2L_Unpack(nums)))
    print(describe("parts", "a", "b"))
    local pair = __K2L_Pair.new("x", 1)
    print(__K2L_Str(pair))
    print(pair.first .. pair.second)
    local name, value = pair.first, pair.second
    print(name .. "=" .. value)
    local triple = __K2L_Triple.new(1, "two", 3.0)
    print(__K2L_Str(triple))
    local versions = __K2L_ReadOnlyListOf(Version.new(1, 2), Version.new(0, 9), Version.new(1, 0))
    print(__K2L_Str(versions:sorted()))
    print(__K2L_Compare(Version.new(1, 0), Version.new(1, 2)) < 0)
    print(__K2L_Str(versions:maxOrNull()))
    print(__K2L_Str(versions:sortedWith(__K2L_CompareBy(____lambda_1))))
    print(__K2L_Str(versions:sortedWith(__K2L_ThenBy(__K2L_CompareByDescending(____lambda_2), ____lambda_3))))
    local r = __K2L_IntRange.new(1, 10)
    local ____list = r:toList()
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i_1 = 1, ____n do
        local it = ____items[____i_1]
        if (it >= 0 and it % 3 or 0 - -it % 3) == 0 then
            ____count = ____count + 1
            ____out[____count] = it
        end
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    print(__K2L_Str(__K2L_IntRange.new(1, 4):map(____lambda_4)))
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
    local words = __K2L_ReadOnlyListOf("banana", "Apple", "cherry")
    print(__K2L_Str(words:sortedBy(____lambda_5)))
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = words:____array()
    for ____i_2 = 1, ____n_1 do
        local it = ____items_1[____i_2]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = #it
    end
    print(__K2L_ListWrap(____out_1, ____count_1):sum())
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_2, ____n_2 = words:____array()
    for ____i_3 = 1, ____n_2 do
        local it = ____items_2[____i_3]
        if #it > 5 then
            ____count_2 = ____count_2 + 1
            ____out_2[____count_2] = it
        end
    end
    print(__K2L_ListWrap(____out_2, ____count_2).size)
    local lookup = words:withIndex():associate(function(____destructured)
        local i, w = ____destructured.index, ____destructured.value
        return __K2L_Pair.new(w, i)
    end)
    print(__K2L_Str(lookup))
    print(__K2L_Str(__K2L_ReadOnlyListOf(3, 1, 2):sortedWith(____lambda_6)))
    local queue = __K2L_List.new()
    queue:addAll(__K2L_ReadOnlyListOf(1, 2, 3))
    print(queue:removeFirst())
    print(__K2L_Str(queue))
    print(__K2L_Str(windowedSumPairs(__K2L_ReadOnlyListOf(1, 2, 3, 4))))
end

function windowedSumPairs(self)
    local ____list_1 = self:zip(self:drop(1))
    local ____out_3 = {}
    local ____count_3 = 0
    local ____items_3, ____n_3 = ____list_1:____array()
    for ____i_4 = 1, ____n_3 do
        local ____it = ____items_3[____i_4]
        local ____result
        do
            local a, b = ____it.first, ____it.second
            ____result = a + b
        end
        ____count_3 = ____count_3 + 1
        ____out_3[____count_3] = ____result
    end
    return __K2L_ListWrap(____out_3, ____count_3)
end

main()
return {Version = Version, sumAll = sumAll, describe = describe, windowedSumPairs = windowedSumPairs}
