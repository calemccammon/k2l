local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Spread = ____lualib.__K2L_Spread
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf

local function firstOver(limit, onMiss, ...)
    local values = __K2L_ArrayOf(...)
    for ____i = 1, values.size do
        local v = values[____i]
        if v > limit then
            return v
        end
    end
    return onMiss()
end

local function search(xs)
    local ____result
    do
        local values = __K2L_ArrayOf(1, __K2L_Spread("s.s", xs, 3, xs))
        for ____i_1 = 1, values.size do
            local v = values[____i_1]
            if v > 10 then
                ____result = v
                goto ____inline_end
            end
        end
        local ____result_1
        do return "none in " .. xs.size * 2 + 2 end
        ____result = ____result_1
        ::____inline_end::
    end
    local found = ____result
    return "found " .. found
end

local ____lambda_1 = function(x) return type(x) == "string" end
local ____lambda_2 = function(x) return math.type(x) == "integer" end
local function main()
    local extra = __K2L_ArrayOf(4, "five", nil, 6)
    local ____result_2
    do
        local items = __K2L_ArrayOf(1, "x", __K2L_Spread("s.", extra, 2))
        local ____result_3 = 0
        local ____items, ____n = items:____array()
        for ____i_2 = 1, ____n do
            local it = ____items[____i_2]
            if math.type(it) == "integer" then
                ____result_3 = ____result_3 + 1
            end
        end
        ____result_2 = ____result_3
    end
    print(____result_2)
    local ____result_4
    do
        local items = __K2L_ArrayOf(__K2L_Spread("s.s", extra, "y", extra))
        local ____result_5 = 0
        local ____items_1, ____n_1 = items:____array()
        for ____i_3 = 1, ____n_1 do
            local it = ____items_1[____i_3]
            if type(it) == "string" then
                ____result_5 = ____result_5 + 1
            end
        end
        ____result_4 = ____result_5
    end
    print(____result_4)
    local ____result_6
    do
        local items = __K2L_ArrayOf(__K2L_Spread("ss", extra, extra))
        local ____result_7 = 0
        local ____items_2, ____n_2 = items:____array()
        for ____i_4 = 1, ____n_2 do
            local it = ____items_2[____i_4]
            if it ~= nil then
                ____result_7 = ____result_7 + 1
            end
        end
        ____result_6 = ____result_7
    end
    print(____result_6)
    local ____result_8
    do
        local items = __K2L_ArrayOf("a", 1, __K2L_Spread("s.", extra, "z"))
        ____result_8 = items:filter(____lambda_1):joinToString(", ") .. "!"
    end
    print(____result_8)
    local ____result_9
    do
        local items = __K2L_ArrayOf(__K2L_Spread("s.", extra, 10))
        ____result_9 = items:filter(____lambda_2):joinToString("+") .. "."
    end
    print(____result_9)
    print(search(__K2L_TypedArrayOf("[I", 5, 20)))
    print(search(__K2L_TypedArrayOf("[I", 5, 2)))
end

main()
return {firstOver = firstOver, search = search}
