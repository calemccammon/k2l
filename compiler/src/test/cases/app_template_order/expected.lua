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

local ____lambda_1 = function() return ____next() end
local function main()
    local items = __K2L_ReadOnlyListOf(1, "a", 2)
    local ____arg = ____next()
    local ____result
    do
        ____exports.counter = ____exports.counter + 10
        local ____result_1 = 0
        local ____items_1, ____n = items:____array()
        for ____i = 1, ____n do
            local it = ____items_1[____i]
            if math.type(it) == "integer" then
                ____result_1 = ____result_1 + 1
            end
        end
        ____result = ____result_1
    end
    print("before " .. ____arg .. " ints " .. ____result .. " after " .. ____next())
    print(____exports.counter .. " " .. twice(____lambda_1) .. " " .. ____exports.counter)
    local ____arg_1 = "x" .. ____next()
    local ____result_2
    do
        ____exports.counter = ____exports.counter + 10
        local ____result_3 = 0
        local ____items_3, ____n_1 = items:____array()
        for ____i_1 = 1, ____n_1 do
            local it = ____items_3[____i_1]
            if type(it) == "string" then
                ____result_3 = ____result_3 + 1
            end
        end
        ____result_2 = ____result_3
    end
    local s = ____arg_1 .. ____result_2 .. ____next()
    print(s)
end

____exports.____next = ____next
____exports.twice = twice
main()
return ____exports
