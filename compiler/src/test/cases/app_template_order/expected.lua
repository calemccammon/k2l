local ____lualib = require("lualib_bundle")
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf

local ____exports = {}
____exports.counter = 0

local function ____next()
    ____exports.counter = ____exports.counter + 1
    return ____exports.counter
end

local function twice(block)
    block()
    return block()
end

local function main()
    local items = __K2L_ReadOnlyListOf(1, "a", 2)
    local ____arg = ____next()
    local ____result
    ____exports.counter = ____exports.counter + 10
    ____result = items:count(function(it) return math.type(it) == "integer" end)
    print("before " .. ____arg .. " ints " .. ____result .. " after " .. ____next())
    print(____exports.counter .. " " .. twice(function() return ____next() end) .. " " .. ____exports.counter)
    local ____arg_1 = "x" .. ____next()
    local ____result_1
    ____exports.counter = ____exports.counter + 10
    ____result_1 = items:count(function(it) return type(it) == "string" end)
    local s = ____arg_1 .. ____result_1 .. ____next()
    print(s)
end

____exports.____next = ____next
____exports.twice = twice
main()
return ____exports
