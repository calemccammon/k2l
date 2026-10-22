-- requires: Class, EnumValues, EnumValueOf
-- More of the kotlin package: Any(), AutoCloseable { }, and the library enums LazyThreadSafetyMode and
-- DeprecationLevel.
local __K2L_Object = __K2L_Class("kotlin.Any")

-- AutoCloseable { }: close() runs the block
local function __K2L_AutoCloseableOf(block)
    return {close = function()
        return block()
    end}
end

-- a library enum class with the entries `names`, in order
local function enum(name, names)
    local cls = __K2L_Class(name)
    local values = {}
    for i, entryName in ipairs(names) do
        local entry = setmetatable({name = entryName, ordinal = i - 1}, cls)
        cls[entryName] = entry
        values[i] = entry
    end
    cls.____values = values
    function cls:toString()
        return self.name
    end
    cls.__tostring = cls.toString
    function cls:compareTo(other)
        return self.ordinal - other.ordinal
    end
    function cls.values()
        return __K2L_EnumValues(cls)
    end
    function cls.valueOf(entryName)
        return __K2L_EnumValueOf(cls, entryName)
    end
    return cls
end

local __K2L_LazyThreadSafetyMode = enum("kotlin.LazyThreadSafetyMode", {"SYNCHRONIZED", "PUBLICATION", "NONE"})
local __K2L_DeprecationLevel = enum("kotlin.DeprecationLevel", {"WARNING", "ERROR", "HIDDEN"})
