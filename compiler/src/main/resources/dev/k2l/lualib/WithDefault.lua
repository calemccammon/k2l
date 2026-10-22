-- map.withDefault(default): a view of `map` whose getValue() falls back to default(key); everything else, writes
-- included, goes to the map.
local function __K2L_WithDefault(map, default)
    local function getValue(_, key)
        if map:containsKey(key) then
            return map:get(key)
        end
        return default(key)
    end
    return setmetatable({}, {
        __index = function(proxy, name)
            if name == "getValue" or name == "getOrImplicitDefault" then
                return getValue
            end
            local member = map[name]
            if type(member) == "function" then
                local forwarded = function(_, ...)
                    return member(map, ...)
                end
                rawset(proxy, name, forwarded)
                return forwarded
            end
            return member
        end,
        __tostring = function()
            return map:toString()
        end,
    })
end
