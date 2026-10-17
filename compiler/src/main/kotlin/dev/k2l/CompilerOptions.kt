package dev.k2l

enum class LuaTarget(val id: String) {
    Lua51("5.1"), Lua52("5.2"), Lua53("5.3"), Lua54("5.4"), LuaJIT("JIT");

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
