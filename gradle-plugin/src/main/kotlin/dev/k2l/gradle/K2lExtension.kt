package dev.k2l.gradle

import org.gradle.api.file.ConfigurableFileCollection
import org.gradle.api.file.DirectoryProperty
import org.gradle.api.provider.Property

/**
 * The `k2l { }` block. Defaults: sources in `src/main/kotlin`, output in `build/lua`, Lua 5.4,
 * the shared `lualib_bundle.lua`, no source maps.
 */
abstract class K2lExtension {
    /** Directories with the Kotlin sources to transpile. Use `setFrom(...)` to replace the default. */
    abstract val sourceDirs: ConfigurableFileCollection

    /** Where the `.lua` files (and `.lua.map` files) are written. */
    abstract val outputDir: DirectoryProperty

    /** `5.1`, `5.2`, `5.3`, `5.4` or `JIT`. */
    abstract val luaTarget: Property<String>

    /** `require` (one shared `lualib_bundle.lua`) or `inline`. */
    abstract val luaLibImport: Property<String>

    /** `unchecked` (default) or `wrap`: make `Int` arithmetic wrap to 32 bits like the JVM. */
    abstract val intOverflow: Property<String>

    /** `bytes` (default) or `utf16`: make `String` and `Char` behave like the JVM's UTF-16 strings. */
    abstract val strings: Property<String>

    /** `double` (default) or `emulate`: exact 64-bit `Long` and `ULong` on Lua 5.1, 5.2 and LuaJIT (slower). */
    abstract val long64: Property<String>

    /** Write Source Map v3 files and make Lua errors show Kotlin positions. */
    abstract val sourceMap: Property<Boolean>

    /** Extra jars or class directories with Lua bindings (`@LuaExternal` declarations). */
    abstract val classpath: ConfigurableFileCollection
}
