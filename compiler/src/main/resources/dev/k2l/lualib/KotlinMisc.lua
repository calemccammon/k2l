-- requires: Class, Exceptions, EnumValues, EnumValueOf
-- More of the kotlin package: KotlinVersion, Any(), AutoCloseable { }, and the library enums LazyThreadSafetyMode and
-- DeprecationLevel.
local __K2L_KotlinVersion = __K2L_Class("kotlin.KotlinVersion")

function __K2L_KotlinVersion:____init(major, minor, patch)
    patch = patch or 0
    if major < 0 or major > 255 or minor < 0 or minor > 255 or patch < 0 or patch > 255 then
        error(__K2L_IllegalArgumentException.new("Version components are out of range: " .. major .. "." .. minor .. "." .. patch))
    end
    self.major, self.minor, self.patch = major, minor, patch
    self.version = major * 65536 + minor * 256 + patch
end

function __K2L_KotlinVersion:toString()
    return self.major .. "." .. self.minor .. "." .. self.patch
end

__K2L_KotlinVersion.__tostring = __K2L_KotlinVersion.toString

function __K2L_KotlinVersion:equals(other)
    return getmetatable(other) == __K2L_KotlinVersion and other.version == self.version
end

function __K2L_KotlinVersion:hashCode()
    return self.version
end

function __K2L_KotlinVersion:compareTo(other)
    return self.version - other.version
end

function __K2L_KotlinVersion:isAtLeast(major, minor, patch)
    if self.major ~= major then
        return self.major > major
    elseif patch == nil or self.minor ~= minor then
        return self.minor >= minor
    end
    return self.patch >= patch
end

-- Any(): an object with only identity
local __K2L_Object = __K2L_Class("java.lang.Object")

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
