-- requires: Collections
-- `values()` and `entries` of an enum class: a fresh list of its entries, in declaration order.
local __K2L_EnumUnpack = table.unpack or unpack

local function __K2L_EnumValues(cls)
    local values = cls.____values
    return __K2L_ListOf(__K2L_EnumUnpack(values, 1, #values))
end
