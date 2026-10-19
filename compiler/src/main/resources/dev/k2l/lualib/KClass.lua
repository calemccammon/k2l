-- requires: Class, InstanceOf
-- KClass and java.lang.Class stand-ins: simpleName, qualifiedName, name, isInstance. One object per class, so == is identity;
-- `KClass.java` is a Class object of its own (they print differently), one per KClass.
local __K2L_KClassImpl = __K2L_Class("kotlin.jvm.internal.ClassReference")
local __K2L_JavaClassImpl = __K2L_Class("java.lang.Class")
local __K2L_KClassCache = {}

-- Source classes get their package-qualified names from generated code; library classes carry them as their `____name`.
local function __K2L_ClassInfo(cls, qualifiedName, binaryName, kind, simpleName)
    cls.____qualifiedName = qualifiedName
    cls.____simpleName = simpleName
    cls.____binaryName = binaryName
    cls.____kind = kind
    return cls
end

-- A companion object is the table of its class at run time: the class records the companion's names for `x::class`.
local function __K2L_CompanionInfo(cls, qualifiedName, binaryName, simpleName)
    cls.____companionNames = {qualifiedName, binaryName, simpleName}
end

local function __K2L_NewKClass(key, simple, qualified, binary, cls, kind)
    local k = setmetatable({simpleName = simple, qualifiedName = qualified, name = binary or qualified or simple, ____cls = cls, ____kind = kind}, __K2L_KClassImpl)
    __K2L_KClassCache[key] = k
    return k
end

-- `qualified` may be a JVM binary name such as java.util.Collections$SingletonList: Kotlin separates nested classes with dots.
local function __K2L_KClassNamed(qualified, simple, binary)
    if qualified:find("$", 1, true) then
        binary, qualified = binary or qualified, (qualified:gsub("%$", "."))
    end
    return __K2L_KClassCache[qualified] or __K2L_NewKClass(qualified, simple or qualified:match("[^.]+$"), qualified, binary, nil, "class")
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
    -- the simple name is the end of the binary name (`app.MainKt$main$Local`); false for an object expression, which has none
    local simple = rawget(cls, "____simpleName")
    if simple == nil then
        simple = name:match("[^.$]+$")
    end
    return __K2L_NewKClass(cls, simple or nil, qualified, rawget(cls, "____binaryName"), cls, kind)
end

-- The class of a runtime value, `x::class`. Chars are strings and Long is Int at runtime.
local function __K2L_KClassOfValue(value)
    local t = type(value)
    if t == "table" then
        if rawget(value, "____name") == nil then
            return __K2L_KClassOf(getmetatable(value))
        end
        local companion = rawget(value, "____companionNames")
        if companion ~= nil then
            return __K2L_KClassNamed(companion[1], companion[3], companion[2])
        end
        return __K2L_KClassOf(value)
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
    if cls ~= nil and (type(value) ~= "table" or rawget(value, "____companionNames") == nil) then
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

-- The JVM's names of the library classes whose Class prints differently from their Kotlin name (`Int::class` is `int`).
local jvmNames = {
    ["kotlin.Any"] = "class java.lang.Object", ["kotlin.String"] = "class java.lang.String",
    ["kotlin.CharSequence"] = "interface java.lang.CharSequence", ["kotlin.Number"] = "class java.lang.Number",
    ["kotlin.Int"] = "int", ["kotlin.Long"] = "long", ["kotlin.Short"] = "short", ["kotlin.Byte"] = "byte", ["kotlin.Double"] = "double",
    ["kotlin.Float"] = "float", ["kotlin.Boolean"] = "boolean", ["kotlin.Char"] = "char", ["kotlin.Throwable"] = "class java.lang.Throwable",
    ["kotlin.collections.List"] = "interface java.util.List", ["kotlin.collections.Set"] = "interface java.util.Set",
    ["kotlin.collections.Map"] = "interface java.util.Map", ["kotlin.collections.Collection"] = "interface java.util.Collection",
    ["kotlin.collections.Iterable"] = "interface java.lang.Iterable",
}

-- `class app.Outer$Inner`, like java.lang.Class.toString()
local function jvmString(k)
    local known = k.____cls == nil and jvmNames[k.qualifiedName]
    if known then
        return known
    end
    return (k.____kind == "interface" and "interface " or "class ") .. (k.name or "")
end

function __K2L_KClassImpl:toString()
    return jvmString(self) .. " (Kotlin reflection is not available)"
end

-- `KClass.java` and `x.javaClass`
local function __K2L_JavaClass(k)
    local java = k.____java
    if java == nil then
        java = setmetatable({simpleName = k.simpleName, qualifiedName = k.qualifiedName, name = k.name, ____kotlin = k}, __K2L_JavaClassImpl)
        k.____java = java
    end
    return java
end

function __K2L_JavaClassImpl:isInstance(value)
    return self.____kotlin:isInstance(value)
end

function __K2L_JavaClassImpl:toString()
    return jvmString(self.____kotlin)
end
