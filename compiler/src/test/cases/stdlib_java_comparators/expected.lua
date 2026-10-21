local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_CompareValues = ____lualib.__K2L_CompareValues
local __K2L_DoubleEquals = ____lualib.__K2L_DoubleEquals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_NaturalOrder = ____lualib.__K2L_NaturalOrder
local __K2L_NullsFirst = ____lualib.__K2L_NullsFirst
local __K2L_NullsLast = ____lualib.__K2L_NullsLast
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ThenBy = ____lualib.__K2L_ThenBy

local Employee = __K2L_Class("Employee")

function Employee:____init(name, age, salary, rating)
    self.name = name
    self.age = age
    self.salary = salary
    self.rating = rating
end

function Employee.new(name, age, salary, rating)
    return setmetatable({name = name, age = age, salary = salary, rating = rating}, Employee)
end

function Employee:toString()
    return "Employee(name=" .. self.name .. ", age=" .. self.age .. ", salary=" .. self.salary .. ", rating=" .. __K2L_Str(self.rating) .. ")"
end

function Employee:hashCode()
    return (31 * (31 * (31 * __K2L_Hash(self.name) + self.age) + __K2L_Hash(self.salary)) + __K2L_Hash(self.rating) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Employee:equals(other)
    return getmetatable(other) == Employee and self.name == other.name and self.age == other.age and self.salary == other.salary and __K2L_DoubleEquals(self.rating, other.rating)
end

local ____lambda_1 = function(it) return it.age end
local ____lambda_2 = function(it) return it.salary end
local ____lambda_3 = function(it) return it.age end
local ____lambda_4 = function(it) return it.rating end
local ____lambda_5 = function(it) return it.salary end
local ____lambda_6 = function(____a, ____b)
    local ____x, ____y = ____a.age, ____b.age
    if ____x ~= ____y then
        return ____x < ____y and -1 or 1
    end
    return 0
end
local ____lambda_7 = function(it) return -it.rating end
local ____lambda_8 = function(it) return #it end
local function main()
    local staff = __K2L_ReadOnlyListOf(Employee.new("Ann", 41, 5200, 4.5), Employee.new("Bob", 29, 4100, 3.9), Employee.new("Cid", 41, 4100, 4.8), Employee.new("Dee", 35, 6100, 3.9))
    local ____list = staff:sortedWith(__K2L_CompareBy(____lambda_1))
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = it.name
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    local ____list_1 = staff:sortedWith(__K2L_ThenBy(__K2L_CompareBy(____lambda_2), ____lambda_3))
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = it.name
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
    local ____list_2 = staff:sortedWith(__K2L_ThenBy(__K2L_CompareBy(____lambda_4), ____lambda_5))
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_2, ____n_2 = ____list_2:____array()
    for ____i_2 = 1, ____n_2 do
        local it = ____items_2[____i_2]
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = it.name
    end
    print(__K2L_Str(__K2L_ListWrap(____out_2, ____count_2)))
    local ____list_3 = staff:sortedWith(__K2L_ThenBy(____lambda_6, ____lambda_7))
    local ____out_3 = {}
    local ____count_3 = 0
    local ____items_3, ____n_3 = ____list_3:____array()
    for ____i_3 = 1, ____n_3 do
        local it = ____items_3[____i_3]
        ____count_3 = ____count_3 + 1
        ____out_3[____count_3] = it.name
    end
    print(__K2L_Str(__K2L_ListWrap(____out_3, ____count_3)))
    local names = __K2L_ReadOnlyListOf("pear", nil, "apple", nil, "fig")
    print(__K2L_Str(names:sortedWith(__K2L_NullsFirst(__K2L_NaturalOrder))))
    print(__K2L_Str(names:sortedWith(__K2L_NullsLast(__K2L_CompareBy(____lambda_8)))))
end

__K2L_Main(main)
return {Employee = Employee}
