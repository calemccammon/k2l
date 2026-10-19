-- `*array` spread into a call.
local __K2L_TableUnpack = table.unpack or unpack

local function __K2L_Unpack(list)
    return __K2L_TableUnpack(list, 1, list.size)
end

-- `f(*xs, y, *zs)`: the vararg arguments from the first spread that is not last on. `spread` marks each value: "s" for an
-- array to spread, "." for one element.
local function __K2L_Spread(spread, ...)
    local out, n = {}, 0
    for i = 1, #spread do
        local value = select(i, ...)
        if spread:byte(i) == 115 then
            for j = 1, value.size do
                out[n + j] = value[j]
            end
            n = n + value.size
        else
            n = n + 1
            out[n] = value
        end
    end
    return __K2L_TableUnpack(out, 1, n)
end
