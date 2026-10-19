local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringCharAt = ____lualib.__K2L_StringCharAt

local Box = __K2L_Class("Box")

function Box:____init(items)
    self.items = items
end

local function getLastChar(self)
    return __K2L_StringCharAt(self, #self - 1)
end

local function getTotal(____this)
    return ____this:sum()
end

local function getFirst(____this_1)
    return ____this_1.items:get(0)
end

local function setFirst(____this_1, value)
    local ____object = ____this_1.items
    ____object:set(0, value)
end

local function getSize(____this_2)
    return ____this_2.items.size
end

local function describe(p, s)
    return p.name .. " of " .. s .. " is " .. p:get(s)
end

local function main()
    local ref = __K2L_PropertyRef.new("lastChar", getLastChar)
    print(ref.name)
    print(ref:get("hello"))
    print(ref:get("world"))
    print(__K2L_Str(__K2L_ListOf("ab", "cd", "xyz"):map(__K2L_PropertyRef.new("lastChar", getLastChar))))
    print(describe(__K2L_PropertyRef.new("lastChar", getLastChar), "kotlin"))
    local bound = __K2L_PropertyRef.new("lastChar", function() return getLastChar("lua") end)
    print(bound.name)
    print(bound:get())
    print(bound:get())
    local totals = __K2L_ListOf(__K2L_ListOf(1, 2), __K2L_ListOf(3, 4, 5)):map(__K2L_PropertyRef.new("total", getTotal))
    print(__K2L_Str(totals))
    local box = Box.new(__K2L_ListOf(7, 8))
    local first = __K2L_PropertyRef.new("first", getFirst, setFirst)
    print(first:get(box))
    first:set(box, 70)
    print(__K2L_Str(box.items))
    print(first.name)
    local boundFirst = __K2L_PropertyRef.new("first", function() return getFirst(box) end, function(value)
        setFirst(box, value)
    end)
    boundFirst:set(99)
    print(boundFirst:get())
    print(__K2L_Str(__K2L_ListOf(box, Box.new(__K2L_ListOf(1))):map(__K2L_PropertyRef.new("size", getSize))))
    print(__K2L_ListOf(box, Box.new(__K2L_ListOf(1))):sumOf(__K2L_PropertyRef.new("first", getFirst, setFirst)))
end

main()
return {Box = Box, getLastChar = getLastChar, getTotal = getTotal, getFirst = getFirst, setFirst = setFirst, getSize = getSize, describe = describe}
