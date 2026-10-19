local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Spread = ____lualib.__K2L_Spread
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringPadEnd = ____lualib.__K2L_StringPadEnd
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf
local __K2L_Unpack = ____lualib.__K2L_Unpack

local function sum(...)
    local xs = __K2L_ArrayOf(...)
    return xs:sum()
end

local function tagged(tag, sep, ...)
    local xs = __K2L_ArrayOf(...)
    if sep == nil then
        sep = ","
    end
    return tag .. xs:joinToString(sep)
end

local function build(combine, ...)
    local parts = __K2L_ArrayOf(...)
    return combine(parts:toList())
end

local Row = __K2L_Class("Row")

function Row:____init(width, ...)
    local cells = __K2L_ArrayOf(...)
    if width == nil then
        width = 5
    end
    self.cells = cells
    self.width = width
end

function Row:toString()
    return self.cells:joinToString("|", nil, nil, nil, nil, function(it) return __K2L_StringPadEnd(it, self.width) end)
end

local Base = __K2L_Class("Base")

function Base:____init(name, n, ...)
    local tags = __K2L_ArrayOf(...)
    self.name = name
    self.tags = tags
    self.n = n
end

local Sub = __K2L_Class("Sub", Base)

function Sub:____init()
    Base.____init(self, "s", 2, "a", "b")
end

local Table = __K2L_Class("Table")

function Table:____init(name)
    self.name = name
end

function Table:row(separator, ...)
    local cells = __K2L_ArrayOf(...)
    if separator == nil then
        separator = " | "
    end
    return self.name .. ": " .. cells:joinToString(separator)
end

local function total(f, ...)
    local xs = __K2L_ArrayOf(...)
    local sum = 0
    for ____i = 1, xs.size do
        local x = xs[____i]
        sum = sum + f(x)
    end
    return sum
end

local function spreadFirst(xs)
    local ____result
    do
        local ____xs = __K2L_ArrayOf(__K2L_Spread("s.", xs, 1))
        local sum = 0
        for ____i_1 = 1, ____xs.size do
            local x = ____xs[____i_1]
            local ____result_1
            if x < 0 then
                return -1
            else
                ____result_1 = x
            end
            sum = sum + ____result_1
        end
        ____result = sum
    end
    return ____result
end

local function main()
    print(tagged("t", ";", 1, 2) .. " " .. tagged("u") .. " " .. tagged("v", nil, __K2L_Spread("s.", __K2L_TypedArrayOf("[I", 4, 5), 6)))
    print(build(function(it) return it:joinToString("+") end, "a", "b") .. " " .. build(function(it) return "empty " .. __K2L_Str(it) end))
    print(__K2L_Str(Row.new(3, "a", "b")))
    print(__K2L_Str(Row.new(nil, "c")))
    local s = Sub.new()
    print(s.name .. " " .. __K2L_Str(s.tags:toList()) .. " " .. s.n)
    local t = Table.new("t")
    print(t:row(nil, 1, "x", nil) .. " / " .. t:row(",") .. " / " .. t:row("-", __K2L_Spread("s.", __K2L_TypedArrayOf("[Ljava.lang.Integer;", 1, 2), 3)))
    print(spreadFirst(__K2L_TypedArrayOf("[I", 1, 2)) .. " " .. spreadFirst(__K2L_TypedArrayOf("[I", 3, -4)))
    local f = function(____p1) return sum(__K2L_Unpack(____p1)) end
    local g = function(____p1, ____p2, ____p3)
        return tagged(____p1, ____p3, __K2L_Unpack(____p2))
    end
    local one = sum
    local mk = function(____p1, ____p2)
        return Row.new(____p2, __K2L_Unpack(____p1))
    end
    local ____reference = function(self, ...) return self:row(...) end
    local method = function(____p1, ____p2, ____p3)
        return ____reference(____p1, ____p3, __K2L_Unpack(____p2))
    end
    local ____reference_1 = function(...) return t:row(...) end
    local bound = function(____p1, ____p2)
        return ____reference_1(____p2, __K2L_Unpack(____p1))
    end
    print(f(__K2L_TypedArrayOf("[I", 1, 2, 3)) .. " " .. g("w", __K2L_TypedArrayOf("[I", 7, 8), "-") .. " " .. one(9) .. " " .. __K2L_Str(__K2L_ReadOnlyListOf(4, 5):map(sum)))
    print(__K2L_Str(mk(__K2L_TypedArrayOf("[Ljava.lang.String;", "p", "q"), 2)) .. " " .. method(t, __K2L_ArrayOf(1, 2), "&") .. " " .. bound(__K2L_ArrayOf("z"), ""))
end

main()
return {sum = sum, tagged = tagged, build = build, Row = Row, Base = Base, Sub = Sub, Table = Table, total = total, spreadFirst = spreadFirst}
