-- requires: KClass, EnumValues
-- Class.enumConstants: a fresh array of the entries of an enum class, or null for any other class, including the class of
-- an entry with a body (a subclass of its enum class, as on the JVM).
local function __K2L_EnumConstants(class)
    local cls = class.____kotlin.____cls
    if cls ~= nil and rawget(cls, "____values") ~= nil then
        return __K2L_EnumValues(cls)
    end
    return nil
end

-- Enum.declaringJavaClass: the enum class, also for an entry with a body.
local function __K2L_EnumDeclaringClass(entry)
    local cls = getmetatable(entry)
    if rawget(cls, "____values") == nil then
        cls = rawget(cls, "____super")
    end
    return __K2L_JavaClass(__K2L_KClassOf(cls))
end
