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

    /** Lua 5.1 and LuaJIT allow a function 60 upvalues: the printer moves the rest into tables (`UpvalueLimit`). */
    val limitsUpvalues get() = this == Lua51 || this == LuaJIT

    /** A coroutine can yield across `pcall`, except on plain 5.1: there a `try` that suspends runs in `__K2L_CoPcall`. */
    val yieldsAcrossPcall get() = this != Lua51

    /** Lua 5.1's `print` stops at a NUL character; `io.write` writes whole strings. */
    val printStopsAtNul get() = this == Lua51

    /** LuaJIT's `bit` operations compile to single instructions. */
    val compilesBitOps get() = this == LuaJIT

    /** Lualib variant suffixes to try, most specific first: `Bit.51.lua` replaces `Bit.lua`. Targets with 64-bit integers have none. */
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

data class CompilerOptions(
    val luaTarget: LuaTarget = LuaTarget.Lua54,
    val luaLibImport: LuaLibImport = LuaLibImport.Require,
    /** Emit Source Map v3 files and make Lua errors and tracebacks report Kotlin positions. */
    val sourceMap: Boolean = false,
)
