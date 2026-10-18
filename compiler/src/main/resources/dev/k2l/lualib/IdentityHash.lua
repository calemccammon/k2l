-- The hash code of an object that does not override hashCode(): a number per table, assigned on first use.
local __K2L_IdentityHash = (function()
    local ids = setmetatable({}, {__mode = "k"})
    local last = 0
    return function(value)
        local id = ids[value]
        if id == nil then
            last = last + 1
            id = last
            ids[value] = id
        end
        return id
    end
end)()
