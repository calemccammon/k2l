package dev.k2l

enum class LuaTarget(val id: String) {
    Lua51("5.1"), Lua52("5.2"), Lua53("5.3"), Lua54("5.4"), LuaJIT("JIT");

    companion object {
        fun parse(id: String): LuaTarget =
            entries.firstOrNull { it.id.equals(id, ignoreCase = true) }
                ?: throw IllegalArgumentException("Unknown Lua target '$id' (expected one of ${entries.joinToString { it.id }})")
    }
}

data class CompilerOptions(
    val luaTarget: LuaTarget = LuaTarget.Lua54,
)
