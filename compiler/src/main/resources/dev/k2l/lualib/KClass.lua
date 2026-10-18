-- requires: Class, InstanceOf
-- KClass / java.lang.Class stand-ins: simpleName, qualifiedName, name, isInstance. One object per class, so == is identity.
local __K2L_KClassImpl = __K2L_Class("kotlin.jvm.internal.ClassReference")
local __K2L_KClassCache = {}

-- Source classes get their package-qualified names from generated code; library classes carry them as their `____name`.
local function __K2L_ClassInfo(cls, qualifiedName, binaryName, kind, simpleName)
    cls.____qualifiedName = qualifiedName
    cls.____simpleName = simpleName
    cls.____binaryName = binaryName
    cls.____kind = kind
    return cls
end

local function __K2L_NewKClass(key, simple, qualified, binary, cls, kind)
    local k = setmetatable({simpleName = simple, qualifiedName = qualified, name = binary or qualified or simple, ____cls = cls, ____kind = kind}, __K2L_KClassImpl)
    __K2L_KClassCache[key] = k
    return k
end

local function __K2L_KClassNamed(qualified, simple)
    return __K2L_KClassCache[qualified] or __K2L_NewKClass(qualified, simple or qualified:match("[^.]+$"), qualified, nil, nil, "class")
end

local function __K2L_KClassOf(cls)
    local known = __K2L_KClassCache[cls]
    if known ~= nil then
        return known
    end
    local name = rawget(cls, "____name")
    local qualified = rawget(cls, "____qualifiedName")
    local kind = rawget(cls, "____kind") or "class"
    if qualified == nil and rawget(cls, "____binaryName") == nil and name:find(".", 1, true) then
        -- a library class: one per qualified name, so that `ArrayList::class` finds the lists' class
        local named = __K2L_KClassNamed(name)
        __K2L_KClassCache[cls] = named
        named.____cls = cls
        return named
    end
    return __K2L_NewKClass(cls, rawget(cls, "____simpleName") or name:match("[^.]+$"), qualified, rawget(cls, "____binaryName"), cls, kind)
end

-- The class of a runtime value, `x::class`. Chars are strings and Long is Int at runtime.
local function __K2L_KClassOfValue(value)
    local t = type(value)
    if t == "table" then
        return __K2L_KClassOf(rawget(value, "____name") ~= nil and value or getmetatable(value))
    elseif t == "string" then
        return __K2L_KClassNamed("kotlin.String")
    elseif t == "boolean" then
        return __K2L_KClassNamed("kotlin.Boolean")
    elseif t == "number" then
        local isFloat
        if math.type then
            isFloat = math.type(value) == "float"
        else
            isFloat = value % 1 ~= 0
        end
        return __K2L_KClassNamed(isFloat and "kotlin.Double" or "kotlin.Int")
    elseif t == "function" then
        return __K2L_KClassNamed("kotlin.Function")
    end
    error("NullPointerException")
end

function __K2L_KClassImpl:isInstance(value)
    if value == nil then
        return false
    end
    local cls = self.____cls
    if cls ~= nil then
        return __K2L_InstanceOf(value, cls)
    end
    local name = self.qualifiedName
    local t = type(value)
    if name == "kotlin.Any" then
        return true
    elseif name == "kotlin.String" or name == "kotlin.CharSequence" then
        return t == "string"
    elseif name == "kotlin.Boolean" then
        return t == "boolean"
    elseif name == "kotlin.Number" then
        return t == "number"
    end
    return __K2L_KClassOfValue(value) == self
end

function __K2L_KClassImpl:toString()
    return (self.____kind == "interface" and "interface " or "class ") .. (self.qualifiedName or self.name or "")
end
