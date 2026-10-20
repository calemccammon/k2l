-- requires: Exceptions
-- Failed `x as T`: NullPointerException for null, otherwise ClassCastException worded like the JVM's. `kotlinName` is the
-- Kotlin name of T: a read-only collection cast to a mutable one fails with the message of Kotlin's TypeIntrinsics.
local function __K2L_CastFail(value, target, kotlinName)
    if value == nil then
        error(__K2L_NullPointerException.new("null cannot be cast to non-null type " .. (kotlinName or target)))
    end
    local actual
    local kind = type(value)
    if kind == "string" then
        actual = "java.lang.String"
    elseif kind == "boolean" then
        actual = "java.lang.Boolean"
    elseif kind == "number" then
        local isFloat
        if math.type then
            isFloat = math.type(value) == "float"
        else
            isFloat = value % 1 ~= 0
        end
        actual = isFloat and "java.lang.Double" or "java.lang.Integer"
    elseif kind == "table" then
        local cls = rawget(value, "____name") ~= nil and value or getmetatable(value)
        actual = cls and (rawget(cls, "____binaryName") or rawget(cls, "____qualifiedName") or rawget(cls, "____name")) or "java.lang.Object"
    else
        actual = "java.lang.Object"
    end
    if kind == "table" and value.____readOnly and kotlinName ~= nil and kotlinName:find("^kotlin%.collections%.Mutable") then
        error(__K2L_ClassCastException.new(actual .. " cannot be cast to " .. kotlinName))
    end
    local function describe(name)
        -- arrays of primitives and of the JDK's classes (`[I`, `[Ljava.lang.String;`) are java.base's too
        local element = name:match("^%[+L?(.*)") or name
        if element:find("^java%.") or element:find("^kotlin%.") or name:find("^%[+[A-Z]$") then
            return "module java.base of loader 'bootstrap'"
        end
        return "unnamed module of loader 'app'"
    end
    local a, b = describe(actual), describe(target)
    local where
    if a == b then
        where = actual .. " and " .. target .. " are in " .. a
    else
        where = actual .. " is in " .. a .. "; " .. target .. " is in " .. b
    end
    error(__K2L_ClassCastException.new("class " .. actual .. " cannot be cast to class " .. target .. " (" .. where .. ")"))
end
