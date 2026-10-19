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

local function main()
    local extra = __K2L_ArrayOf(4, "five", nil, 6)
    local ____result_2
    do
        local items = __K2L_ArrayOf(1, "x", __K2L_Spread("s.", extra, 2))
        ____result_2 = items:count(function(it) return math.type(it) == "integer" end)
    end
    print(____result_2)
    local ____result_3
    do
        local items = __K2L_ArrayOf(__K2L_Spread("s.s", extra, "y", extra))
        ____result_3 = items:count(function(it) return type(it) == "string" end)
    end
    print(____result_3)
    local ____result_4
    do
        local items = __K2L_ArrayOf(__K2L_Spread("ss", extra, extra))
        ____result_4 = items:count(function(it) return it ~= nil end)
    end
    print(____result_4)
    local ____result_5
    do
        local items = __K2L_ArrayOf("a", 1, __K2L_Spread("s.", extra, "z"))
        ____result_5 = items:filter(function(x) return type(x) == "string" end):joinToString(", ") .. "!"
    end
    print(____result_5)
    local ____result_6
    do
        local items = __K2L_ArrayOf(__K2L_Spread("s.", extra, 10))
        ____result_6 = items:filter(function(x) return math.type(x) == "integer" end):joinToString("+") .. "."
    end
    print(____result_6)
    print(search(__K2L_TypedArrayOf("[I", 5, 20)))
    print(search(__K2L_TypedArrayOf("[I", 5, 2)))
end

main()
return {firstOver = firstOver, search = search}
