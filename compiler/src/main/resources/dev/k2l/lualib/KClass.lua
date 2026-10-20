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
-- An anonymous class (java.util.Collections$1) has neither a simple nor a qualified name.
local function __K2L_KClassNamed(qualified, simple, binary)
    if qualified:find("$", 1, true) then
        binary, qualified = binary or qualified, (qualified:gsub("%$", "."))
        if binary:find("%$%d+$") then
            return __K2L_KClassCache[binary] or __K2L_NewKClass(binary, nil, nil, binary, nil, "class")
        end
    end
    return __K2L_KClassCache[qualified] or __K2L_NewKClass(qualified, simple or qualified:match("[^.]+$"), qualified, binary, nil, "class")
end

-- The class of an array, from its static type: `kotlin.IntArray` with the JVM name `[I` and the Java simple name `int[]`.
local function __K2L_KClassOfArray(binary, simple, javaSimple, qualified)
    local k = __K2L_KClassCache[binary]
    if k == nil then
        k = __K2L_NewKClass(binary, simple, qualified, binary, nil, "class")
        k.____javaSimpleName = javaSimple
    end
    return k
end

-- A local class or object expression gets a class table each time its declaration runs: its KClass is one per declaration
-- site, found by its binary name (unique, `app.MainKt$main$1`), so objects made by one expression share it as on the JVM.
local function siteOf(cls)
    if rawget(cls, "____qualifiedName") == nil then
        local binary = rawget(cls, "____binaryName")
        if binary ~= nil then
            return "site:" .. binary
        end
    end
    return nil
end

local function __K2L_KClassOf(cls)
    -- an array's class (see __K2L_ArrayClassOf) is the one its static type gives
    local array = cls.____arrayBinary
    if array ~= nil then
        return __K2L_KClassOfArray(array, cls.____simpleName or "Array", cls.____javaSimpleName or "Object[]",
            cls.____qualifiedName or "kotlin.Array")
    end
    local site = siteOf(cls)
    local known = __K2L_KClassCache[site or cls]
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
    local k = __K2L_NewKClass(site or cls, simple or nil, qualified, rawget(cls, "____binaryName"), cls, kind)
    k.____site = site ~= nil
    return k
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
    if self.____site then
        -- the value's class (or a superclass) was declared at this site, maybe in another run of the declaration
        local c = type(value) == "table" and (rawget(value, "____name") ~= nil and value or getmetatable(value)) or nil
        while c ~= nil do
            if __K2L_KClassOf(c) == self then
                return true
            end
            c = rawget(c, "____super")
        end
        return false
    end
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
    ["kotlin.collections.Iterable"] = "interface java.lang.Iterable", ["kotlin.collections.Iterator"] = "interface java.util.Iterator",
    ["kotlin.collections.Map.Entry"] = "interface java.util.Map$Entry", ["kotlin.Comparable"] = "interface java.lang.Comparable",
}

-- `class app.Outer$Inner`, like java.lang.Class.toString()
local function jvmString(k)
    local known = k.____cls == nil and jvmNames[k.qualifiedName]
    if known then
        return known
    end
    local arity = k.____cls == nil and k.qualifiedName and k.qualifiedName:match("^kotlin%.Function(%d+)$")
    if arity then
        return "interface kotlin.jvm.functions.Function" .. arity
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
        local simple = k.____javaSimpleName or k.simpleName
        java = setmetatable({simpleName = simple, qualifiedName = k.qualifiedName, name = k.name, ____kotlin = k}, __K2L_JavaClassImpl)
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
