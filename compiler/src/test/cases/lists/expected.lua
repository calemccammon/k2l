local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32

local Item = __K2L_Class("Item")

function Item:____init(name, price)
    self.name = name
    self.price = price
end

function Item:toString()
    return "Item(name=" .. self.name .. ", price=" .. self.price .. ")"
end

function Item:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.name) + __K2L_Hash(self.price))
end

function Item:equals(other)
    return getmetatable(other) == Item and self.name == other.name and self.price == other.price
end

local function main()
    local xs = __K2L_ListOf(5, 3, 8, 1, 9, 2)
    print(__K2L_Str(xs))
    print(xs.size)
    print(xs:get(0) + xs:get(xs.size - 1))
    print(__K2L_Str(xs:map(function(it) return it * 2 end)))
    print(__K2L_Str(xs:filter(function(it) return math.fmod(it, 2) == 1 end)))
    print(__K2L_Str(xs:sorted()))
    print(__K2L_Str(xs:sortedDescending()))
    print(xs:sum())
    print(__K2L_Str(xs:maxOrNull()))
    print(__K2L_Str(xs:minOrNull()))
    print(__K2L_Str(xs:average()))
    print(xs:first() + xs:last())
    print(xs:any(function(it) return it > 8 end))
    print(xs:all(function(it) return it > 0 end))
    print(xs:none(function(it) return it > 100 end))
    print(xs:count(function(it) return it > 3 end))
    print(xs:indexOf(8))
    print(xs:contains(3))
    print(xs:contains(4))
    print(__K2L_Str(xs:take(2):plusAll(xs:drop(4))))
    print(__K2L_Str(xs:reversed()))
    print(xs:joinToString(", ", "<", ">"))
    print(xs:joinToString("-", nil, nil, nil, nil, function(it) return "n" .. it end))
    print(xs:fold(0, function(acc, x) return acc + x end))
    print(xs:reduce(function(a, b) return a * b end))
    print(__K2L_Str(xs:firstOrNull(function(it) return it > 100 end)))
    print(__K2L_Str(xs:find(function(it) return it > 4 end)))
    print(__K2L_Str(__K2L_ListOf(1, 1, 2, 3, 3):distinct()))
    print(__K2L_Str(xs:chunked(4)))
    print(__K2L_Str(xs:zip(__K2L_ListOf("a", "b", "c"))))
    print(__K2L_Str(xs:withIndex():map(function(____destructured)
        local i, v = ____destructured.index, ____destructured.value
        return i * v
    end)))
    local items = __K2L_ListOf(Item.new("pen", 3), Item.new("book", 12), Item.new("cup", 5), Item.new("ink", 3))
    print(__K2L_Str(items:sortedBy(function(it) return it.price end):map(function(it) return it.name end)))
    print(items:sortedByDescending(function(it) return it.price end):first().name)
    print(__K2L_Str(items:maxByOrNull(function(it) return it.price end)))
    print(items:sumOf(function(it) return it.price end))
    print(__K2L_Str(items:groupBy(function(it) return it.price end)))
    print(__K2L_Str(items:associateBy(function(it) return it.name end):get("cup")))
    print(__K2L_Str(items:partition(function(it) return it.price > 4 end)))
    print(__K2L_Str(items:map(function(it) return it.name end):sorted()))
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
    for _, x in ipairs(xs) do
        total = total + x
    end
    print(total)
    for i = 0, xs.size - 1 do
        if math.fmod(i, 2) == 0 then
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
    for _, it in ipairs(xs) do
        if it > 4 then
            io.write(it .. " ")
        end
    end
    print()
    for i = 0, xs.size - 1 do
        local x = xs[i + 1]
        if i == 0 then
            print("first is " .. x)
        end
    end
    local nested = __K2L_ListOf(__K2L_ListOf(1, 2), __K2L_ListOf(3), __K2L_ListOf())
    print(__K2L_Str(nested:flatten()))
    print(__K2L_Str(nested:flatMap(function(it)
        return it:map(function(x) return x * 10 end)
    end)))
    print(__K2L_Equals(__K2L_ListOf(1, 2), __K2L_ListOf(1, 2)))
    print(__K2L_Str(__K2L_ListOfSize(4, function(it) return it * it end)))
    local arr = __K2L_ArrayOf(3, 1, 2)
    arr:set(1, 7)
    print(arr.size)
    print(__K2L_Str(arr:toList()))
    local words = __K2L_ArrayOf("x", "y")
    print(words:joinToString(""))
    print(__K2L_Str(__K2L_ListOf("a", nil, "b"):filterNotNull()))
    local ____destructured_1 = __K2L_ListOf(10, 20)
    local a, b = ____destructured_1[1], ____destructured_1[2]
    print(a + b)
end

main()
return {Item = Item}
