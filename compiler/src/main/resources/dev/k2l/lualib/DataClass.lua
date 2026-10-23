-- requires: Equals, Hash, Str, ToInt32
-- The toString(), equals() and hashCode() of a data class or value class, over its primary-constructor properties `fields`
-- (their names in order, or `{name, key}` for one kept under another key), for those the class does not declare itself.
-- toString() prints `name`, by default the end of the class's name: `P(x=1, y=2)`.
local concat = table.concat

local function __K2L_DataClass(cls, fields, name)
    local n = #fields
    local names, keys = {}, {}
    for i = 1, n do
        local field = fields[i]
        if type(field) == "table" then
            names[i], keys[i] = field[1], field[2]
        else
            names[i], keys[i] = field, field
        end
    end
    name = name or cls.____name:match("[^.$]*$")
    if rawget(cls, "toString") == nil then
        function cls:toString()
            local parts = {}
            for i = 1, n do
                parts[i] = names[i] .. "=" .. __K2L_Str(self[keys[i]])
            end
            return name .. "(" .. concat(parts, ", ") .. ")"
        end
    end
    if rawget(cls, "equals") == nil then
        function cls:equals(other)
            if getmetatable(other) ~= cls then
                return false
            end
            for i = 1, n do
                local key = keys[i]
                if not __K2L_Equals(self[key], other[key]) then
                    return false
                end
            end
            return true
        end
    end
    -- result = 31 * result + field.hashCode(), as the Kotlin compiler generates
    if rawget(cls, "hashCode") == nil then
        function cls:hashCode()
            local h = 0
            for i = 1, n do
                h = __K2L_ToInt32(31 * h + __K2L_Hash(self[keys[i]]))
            end
            return h
        end
    end
end
