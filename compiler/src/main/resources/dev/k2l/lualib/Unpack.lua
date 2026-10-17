-- `*array` spread into a call.
local __K2L_TableUnpack = table.unpack or unpack

local function __K2L_Unpack(list)
    return __K2L_TableUnpack(list, 1, list.size)
end
