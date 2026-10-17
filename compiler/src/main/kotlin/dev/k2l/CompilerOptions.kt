package dev.k2l

enum class LuaTarget(val id: String) {
    Lua51("5.1"), Lua52("5.2"), Lua53("5.3"), Lua54("5.4"), LuaJIT("JIT");

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
        fun parse(id: String): LuaTarget =
            entries.firstOrNull { it.id.equals(id, ignoreCase = true) }
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

data class CompilerOptions(
    val luaTarget: LuaTarget = LuaTarget.Lua54,
    val luaLibImport: LuaLibImport = LuaLibImport.Require,
)
