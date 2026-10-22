local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder

local ____exports = {}
local Box = __K2L_Class("Box")

function Box:____init(n)
    self.n = n
end

function Box.new(n)
    return setmetatable({n = n}, Box)
end

function Box:bump()
    self.n = self.n + 1
    return self.n
end

function Box:toString()
    return "Box(" .. self.n .. ")"
end

____exports.counter = 0

local function tick()
    ____exports.counter = ____exports.counter + 1
    return ____exports.counter
end

local function main()
    local d = __K2L_ArrayDeque.new(__K2L_ListOf(1, 2, 3))
    print(__K2L_Str(d) .. " " .. d:removeFirst() .. " " .. __K2L_Str(d))
    local b = Box.new(0)
    print(__K2L_Str(b) .. " " .. b:bump() .. " " .. __K2L_Str(b) .. " " .. b:bump())
    local sb = __K2L_StringBuilder.new("a")
    print(__K2L_Str(sb) .. " " .. __K2L_Str(sb:append("b")) .. " " .. __K2L_Str(sb))
    local list = __K2L_ListOf(1)
    print(tostring(list:add(2)) .. " " .. __K2L_Str(list) .. " " .. list:removeAt(0) .. " " .. __K2L_Str(list))
    print(____exports.counter .. " " .. tick() .. " " .. ____exports.counter)
    local c = Box.new(5)
    local s = "" .. __K2L_Str(c) .. c:bump() .. __K2L_Str(c)
    print(s)
    print(__K2L_Str(c) .. c:bump() .. __K2L_Str(c))
    local m = __K2L_MapOf(__K2L_Pair.new(1, "a"), __K2L_Pair.new(2, "b"))
    print(__K2L_Str(m) .. " " .. __K2L_Str(m:remove(1)) .. " " .. __K2L_Str(m))
end

____exports.Box = Box
____exports.tick = tick
__K2L_RunMain(main)
return ____exports
