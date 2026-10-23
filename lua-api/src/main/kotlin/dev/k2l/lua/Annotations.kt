package dev.k2l.lua

/**
 * The declaration is implemented in Lua: k2l emits no code for it and references it by its Lua name.
 * On a class, interface or object, every member is external too.
 */
@Target(AnnotationTarget.CLASS, AnnotationTarget.FUNCTION, AnnotationTarget.PROPERTY)
@Retention(AnnotationRetention.BINARY)
annotation class LuaExternal

/**
 * The Lua name of an external declaration, when it differs from the Kotlin name. On a top-level function or property of
 * the program, the name Lua code finds it under in the file's module table (`require("game.api").on_load(...)`).
 */
@Target(AnnotationTarget.CLASS, AnnotationTarget.FUNCTION, AnnotationTarget.PROPERTY)
@Retention(AnnotationRetention.BINARY)
annotation class LuaName(val name: String)

/**
 * On a file: its top-level external declarations are fields of `require(module)`.
 * On an external class or object: the module itself is that class or object.
 */
@Target(AnnotationTarget.FILE, AnnotationTarget.CLASS)
@Retention(AnnotationRetention.BINARY)
annotation class LuaRequire(val module: String)

/**
 * Call without `self`: `obj.f(x)` instead of `obj:f(x)`. Members of external objects are already called
 * this way; use it on functions of external classes and interfaces. On a class, object, interface, function or
 * property of the program: its members (or it) are also defined without `self`, see the Lua interop documentation.
 */
@Target(AnnotationTarget.CLASS, AnnotationTarget.FUNCTION, AnnotationTarget.PROPERTY)
@Retention(AnnotationRetention.BINARY)
annotation class NoSelf

/** On a file: every class, object, interface and function in it is `@NoSelf`. */
@Target(AnnotationTarget.FILE)
@Retention(AnnotationRetention.BINARY)
annotation class NoSelfInFile

/** Body for external properties: `val version: String get() = definedExternally`. */
val definedExternally: Nothing
    get() = throw UnsupportedOperationException("Implemented in Lua")
