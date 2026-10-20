-- requires: Class, Collections, Hash
-- `typeOf<T>()` without kotlin-reflect: kotlin.jvm.internal.TypeReference. The compiler passes the type's JVM-style names (as
-- printed on its own, and as a type argument, where primitives are their wrapper classes), so `toString()`, `==` and `hashCode()`
-- work on the names.
local KTypeImpl = __K2L_Class("kotlin.jvm.internal.TypeReference")
local KTypeProjectionImpl = __K2L_Class("kotlin.reflect.KTypeProjection")
local unpack = table.unpack or unpack

-- `arguments` is a Lua array of projections: {prefix, type} (prefix "", "in " or "out "), or false for a star projection
local function __K2L_TypeOf(name, nullable, classifier, arguments)
    local projections = {}
    for i, a in ipairs(arguments) do
        projections[i] = setmetatable(a and {type = a[2], ____prefix = a[1]} or {____prefix = false}, KTypeProjectionImpl)
    end
    return setmetatable({
        ____string = name,
        isMarkedNullable = nullable,
        classifier = classifier,
        arguments = __K2L_ListOf(unpack(projections, 1, #arguments)),
    }, KTypeImpl)
end

function KTypeImpl:toString()
    return self.____string .. " (Kotlin reflection is not available)"
end

function KTypeImpl:equals(other)
    return getmetatable(other) == KTypeImpl and other.____string == self.____string
end

function KTypeImpl:hashCode()
    return __K2L_Hash(self.____string)
end

function KTypeProjectionImpl:toString()
    if not self.____prefix then
        return "*"
    end
    return self.____prefix .. self.type:toString()
end

function KTypeProjectionImpl:equals(other)
    return getmetatable(other) == KTypeProjectionImpl and other.____prefix == self.____prefix
        and (self.type == nil or self.type:equals(other.type))
end

function KTypeProjectionImpl:hashCode()
    return self.type and self.type:hashCode() or 0
end
