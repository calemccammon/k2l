package dev.k2l

enum class LuaTarget(val id: String) {
    Lua51("5.1"),
    Lua52("5.2"),
    Lua53("5.3"),
    Lua54("5.4"),
    LuaJIT("JIT"),
    ;

    /** 5.3+ have an integer subtype, `//` and native bitwise operators. */
    val hasIntegers get() = this == Lua53 || this == Lua54

    /** Everything but plain 5.1 has `goto` (LuaJIT supports it too). */
    val hasGoto get() = this != Lua51

    /** Lualib variant suffixes to try, most specific first: `IDiv.float.lua` replaces `IDiv.lua`. */
    val lualibVariants: List<String>
        get() = when (this) {
            Lua54, Lua53 -> emptyList()
            Lua52 -> listOf("52", "float")
            Lua51 -> listOf("51", "float")
            LuaJIT -> listOf("jit", "51", "float")
        }

    companion object {
        fun parse(id: String): LuaTarget = entries.firstOrNull { it.id.equals(id, ignoreCase = true) }
            ?: throw IllegalArgumentException("Unknown Lua target '$id' (expected one of ${entries.joinToString { it.id }})")
    }
}

/** How generated files get the lualib runtime, as in TSTL's `luaLibImport`. */
enum class LuaLibImport {
    /** One shared `lualib_bundle.lua`, loaded with `require`. */
    Require,

    /** The helpers each file uses are copied into it. */
    Inline,
}

/** What `Int` arithmetic does when a result leaves the 32-bit range. */
enum class IntOverflow(val id: String) {
    /** Lua numbers are not narrowed: `Int.MAX_VALUE + 1` is 2147483648. Fastest, and the default. */
    Unchecked("unchecked"),

    /** `+ - * ++ --` and unary minus wrap to 32 bits like the JVM. */
    Wrap("wrap"),
    ;

    companion object {
        fun parse(id: String): IntOverflow = entries.firstOrNull { it.id.equals(id, ignoreCase = true) }
            ?: throw IllegalArgumentException("Unknown int overflow mode '$id' (expected one of ${entries.joinToString { it.id }})")
    }
}

/** How `String` and `Char` behave: Lua's bytes, or the JVM's UTF-16 code units. */
enum class StringSemantics(val id: String) {
    /** `length`, indices and `Char` count UTF-8 bytes; `isLetter()`, `uppercase()` and so on are ASCII only. The default. */
    Bytes("bytes"),

    /** Strings stay UTF-8, but lengths, indices, `Char`s and classification behave like the JVM's UTF-16 strings. */
    Utf16("utf16"),
    ;

    companion object {
        fun parse(id: String): StringSemantics = entries.firstOrNull { it.id.equals(id, ignoreCase = true) }
            ?: throw IllegalArgumentException("Unknown strings mode '$id' (expected one of ${entries.joinToString { it.id }})")
    }
}

data class CompilerOptions(
    val luaTarget: LuaTarget = LuaTarget.Lua54,
    val luaLibImport: LuaLibImport = LuaLibImport.Require,
    val intOverflow: IntOverflow = IntOverflow.Unchecked,
    val strings: StringSemantics = StringSemantics.Bytes,
    /** Emit Source Map v3 files and make Lua errors and tracebacks report Kotlin positions. */
    val sourceMap: Boolean = false,
)
