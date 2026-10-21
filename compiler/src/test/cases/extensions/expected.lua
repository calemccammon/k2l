local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Main = ____lualib.__K2L_Main

local function shout(self)
    return self:upper() .. "!"
end

local function isEven(____this)
    return (____this >= 0 and ____this % 2 or 0 - -____this % 2) == 0
end

local function orEmptyText(____this_1)
    return ____this_1 or ""
end

local Vec = __K2L_Class("Vec")

function Vec:____init(x, y)
    self.x = x
    self.y = y
end

function Vec.new(x, y)
    return setmetatable({x = x, y = y}, Vec)
end

local function length2(____this_2)
    return ____this_2.x * ____this_2.x + ____this_2.y * ____this_2.y
end

local function scaled(____this_3, k)
    return Vec.new(____this_3.x * k, ____this_3.y * k)
end

local function describe(____this_4)
    return "(" .. ____this_4.x .. ", " .. ____this_4.y .. ") len2=" .. length2(____this_4)
end

local function main()
    print(shout("hi"))
    print(isEven(4))
    print(isEven(7))
    local missing = nil
    print(#orEmptyText(missing))
    print(orEmptyText("x"))
    local v = Vec.new(3, 4)
    print(length2(v))
    print(describe(scaled(v, 2)))
    local ____shout = shout
    print(____shout("ref"))
end

__K2L_Main(main)
return {shout = shout, isEven = isEven, orEmptyText = orEmptyText, Vec = Vec, length2 = length2, scaled = scaled, describe = describe}
