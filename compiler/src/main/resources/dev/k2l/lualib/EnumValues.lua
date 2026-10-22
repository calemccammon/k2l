-- requires: Collections
-- `values()` and `entries` of an enum class: a fresh list of its entries, in declaration order (copied with a loop:
-- LuaJIT cannot compile an unpack into a vararg call).
local function __K2L_EnumValues(cls)
    local values = cls.____values
    local n = #values
    local out = {}
    for i = 1, n do
        out[i] = values[i]
    end
    out.size = n
    return setmetatable(out, __K2L_List)
end
