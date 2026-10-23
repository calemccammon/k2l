local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str

local Item = __K2L_Class("Item")

function Item.new(name, price)
    return setmetatable({name = name, price = price}, Item)
end

__K2L_DataClass(Item, {"name", "price"})

local ____lambda_1 = function(it) return "n" .. it end
local ____lambda_2 = function(acc, x) return acc + x end
local ____lambda_3 = function(a, b) return a * b end
local ____lambda_4 = function(it) return it.price end
local ____lambda_5 = function(it) return it.price end
local ____lambda_6 = function(it) return it.price end
local ____lambda_7 = function(it) return it.price > 4 end
local function main()
    local xs = __K2L_ListOf(5, 3, 8, 1, 9, 2)
    print(__K2L_Str(xs))
    print(xs.size)
    print(xs:get(0) + xs:get(xs.size - 1))
    local ____out = {}
    local ____count = 0
    local ____items, ____n = xs:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = it * 2
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = xs:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        if it % 2 == 1 then
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = it
        end
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
    print(__K2L_Str(xs:sorted()))
    print(__K2L_Str(xs:sortedDescending()))
    print(xs:sum())
    print(__K2L_Str(xs:maxOrNull()))
    print(__K2L_Str(xs:minOrNull()))
    print(xs:average())
    print(xs:first() + xs:last())
    local ____result = false
    local ____items_2, ____n_2 = xs:____array()
    for ____i_2 = 1, ____n_2 do
        local it = ____items_2[____i_2]
        if it > 8 then
            ____result = true
            break
        end
    end
    print(____result)
    local ____result_1 = true
    local ____items_3, ____n_3 = xs:____array()
    for ____i_3 = 1, ____n_3 do
        local it = ____items_3[____i_3]
        if not (it > 0) then
            ____result_1 = false
            break
        end
    end
    print(____result_1)
    local ____result_2 = true
    local ____items_4, ____n_4 = xs:____array()
    for ____i_4 = 1, ____n_4 do
        local it = ____items_4[____i_4]
        if it > 100 then
            ____result_2 = false
            break
        end
    end
    print(____result_2)
    local ____result_3 = 0
    local ____items_5, ____n_5 = xs:____array()
    for ____i_5 = 1, ____n_5 do
        local it = ____items_5[____i_5]
        if it > 3 then
            ____result_3 = ____result_3 + 1
        end
    end
    print(____result_3)
    print(xs:indexOf(8))
    print(xs:contains(3))
    print(xs:contains(4))
    print(__K2L_Str(xs:take(2):plusAll(xs:drop(4))))
    print(__K2L_Str(xs:reversed()))
    print(xs:joinToString(", ", "<", ">"))
    print(xs:joinToString("-", nil, nil, nil, nil, ____lambda_1))
    print(xs:fold(0, ____lambda_2))
    print(xs:reduce(____lambda_3))
    local ____result_4
    local ____items_6, ____n_6 = xs:____array()
    for ____i_6 = 1, ____n_6 do
        local it = ____items_6[____i_6]
        if it > 100 then
            ____result_4 = it
            break
        end
    end
    print(__K2L_Str(____result_4))
    local ____result_5
    local ____items_7, ____n_7 = xs:____array()
    for ____i_7 = 1, ____n_7 do
        local it = ____items_7[____i_7]
        if it > 4 then
            ____result_5 = it
            break
        end
    end
    print(__K2L_Str(____result_5))
    print(__K2L_Str(__K2L_ListOf(1, 1, 2, 3, 3):distinct()))
    print(__K2L_Str(xs:chunked(4)))
    print(__K2L_Str(xs:zip(__K2L_ListOf("a", "b", "c"))))
    print(__K2L_Str(xs:withIndex():map(function(____destructured)
        local i, v = ____destructured.index, ____destructured.value
        return i * v
    end)))
    local items = __K2L_ListOf(Item.new("pen", 3), Item.new("book", 12), Item.new("cup", 5), Item.new("ink", 3))
    local ____list = items:sortedBy(____lambda_4, true)
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_8, ____n_8 = ____list:____array()
    for ____i_8 = 1, ____n_8 do
        local it = ____items_8[____i_8]
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = it.name
    end
    print(__K2L_Str(__K2L_ListWrap(____out_2, ____count_2)))
    print(items:sortedByDescending(____lambda_5, true):first().name)
    print(__K2L_Str(items:maxByOrNull(____lambda_6)))
    local ____sum = 0
    local ____items_9, ____n_9 = items:____array()
    for ____i_9 = 1, ____n_9 do
        local it = ____items_9[____i_9]
        ____sum = ____sum + it.price
    end
    print(____sum)
    local ____result_6 = __K2L_Map.new()
    local ____items_10, ____n_10 = items:____array()
    for ____i_10 = 1, ____n_10 do
        local it = ____items_10[____i_10]
        local ____value = it.price
        local ____group = ____result_6:get(____value)
        if ____group == nil then
            ____group = __K2L_List.new()
            ____result_6:put(____value, ____group)
        end
        ____group:add(it)
    end
    print(__K2L_Str(____result_6))
    local ____result_7 = __K2L_Map.new()
    local ____items_11, ____n_11 = items:____array()
    for ____i_11 = 1, ____n_11 do
        local it = ____items_11[____i_11]
        local ____value_1 = it.name
        ____result_7:put(____value_1, it)
    end
    print(__K2L_Str(____result_7:get("cup")))
    print(__K2L_Str(items:partition(____lambda_7)))
    local ____out_3 = {}
    local ____count_3 = 0
    local ____items_12, ____n_12 = items:____array()
    for ____i_12 = 1, ____n_12 do
        local it = ____items_12[____i_12]
        ____count_3 = ____count_3 + 1
        ____out_3[____count_3] = it.name
    end
    print(__K2L_Str(__K2L_ListWrap(____out_3, ____count_3):sorted()))
    local m = __K2L_ListOf()
    m:add("b")
    m:add("c")
    m:addAt(0, "a")
    m:add("d")
    print(__K2L_Str(m))
    m:removeAt(1)
    m:remove("d")
    print(__K2L_Str(m))
    m:set(0, "z")
    print(__K2L_Str(m))
    print(m:isEmpty())
    m:clear()
    print(m:isEmpty())
    local total = 0
    for ____i_13 = 1, xs.size do
        local x = xs[____i_13]
        total = total + x
    end
    print(total)
    for i = 0, xs.size - 1 do
        if i % 2 == 0 then
            io.write(xs[i + 1] .. " ")
        end
    end
    print()
    for i = 0, xs.size - 1 do
        local x = xs[i + 1]
        if i < 2 then
            io.write(i .. ":" .. x .. " ")
        end
    end
    print()
    for ____i_14 = 1, xs.size do
        local it = xs[____i_14]
        if it > 4 then
            io.write(it .. " ")
        end
    end
    print()
    for ____i_15 = 1, xs.size do
        local x = xs[____i_15]
        local i = ____i_15 - 1
        if i == 0 then
            print("first is " .. x)
        end
    end
    local nested = __K2L_ListOf(__K2L_ListOf(1, 2), __K2L_ListOf(3), __K2L_ListOf())
    print(__K2L_Str(nested:flatten()))
    local ____out_4 = {}
    local ____count_4 = 0
    local ____items_14, ____n_14 = nested:____array()
    for ____i_17 = 1, ____n_14 do
        local it = ____items_14[____i_17]
        local ____result_8
        do
            local ____out_5 = {}
            local ____count_5 = 0
            local ____items_13, ____n_13 = it:____array()
            for ____i_16 = 1, ____n_13 do
                local x = ____items_13[____i_16]
                ____count_5 = ____count_5 + 1
                ____out_5[____count_5] = x * 10
            end
            ____result_8 = __K2L_ListWrap(____out_5, ____count_5)
        end
        local ____inner, ____m = ____result_8:____array()
        for ____j = 1, ____m do
            ____count_4 = ____count_4 + 1
            ____out_4[____count_4] = ____inner[____j]
        end
    end
    print(__K2L_Str(__K2L_ListWrap(____out_4, ____count_4)))
    print(__K2L_Equals(__K2L_ListOf(1, 2), __K2L_ListOf(1, 2)))
    local ____out_6 = {}
    for ____i_18 = 1, 4 do
        local it = ____i_18 - 1
        ____out_6[____i_18] = it * it
    end
    print(__K2L_Str(__K2L_ListWrap(____out_6, 4)))
    local arr = __K2L_ArrayOf(3, 1, 2)
    if 1 < 0 or 1 >= arr.size then
        __K2L_IndexError(1, arr.size, "array")
    end
    arr[2] = 7
    print(arr.size)
    print(__K2L_Str(arr:toList()))
    local words = __K2L_ArrayOf("x", "y")
    print(words:joinToString(""))
    print(__K2L_Str(__K2L_ListOf("a", nil, "b"):filterNotNull()))
    local ____destructured_1 = __K2L_ListOf(10, 20)
    local a, b = ____destructured_1[1], ____destructured_1[2]
    print(a + b)
end

__K2L_RunMain(main)
return {Item = Item}
