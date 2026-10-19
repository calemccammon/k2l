-- requires: Exceptions
-- The reflection members that need kotlin-reflect (`KClass.isData`, `KFunction.parameters`, `KProperty.returnType`, ...). Like on
-- the JVM without it, they throw. The receiver is passed so that it is still evaluated.
local function __K2L_NeedsReflect(receiver)
    error(__K2L_KotlinReflectionNotSupportedError.new("Kotlin reflection implementation is not found at runtime. Make sure you have kotlin-reflect.jar in the classpath"))
end
