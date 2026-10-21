package dev.k2l

/** Interpreters installed on this machine with the target matching their version banner, one per version. */
internal val installedInterpreters: List<Pair<String, LuaTarget>> by lazy {
    val seen = mutableSetOf<LuaTarget>()
    listOf("lua5.1", "lua5.2", "lua5.3", "lua5.4", "luajit", "lua").mapNotNull { name ->
        val banner = runCatching {
            val p = ProcessBuilder(name, "-v").redirectErrorStream(true).start()
            p.inputStream.readBytes().toString(Charsets.UTF_8).also { p.waitFor() }
        }.getOrNull() ?: return@mapNotNull null
        val target = when {
            banner.startsWith("LuaJIT") -> LuaTarget.LuaJIT
            else -> LuaTarget.entries.firstOrNull { banner.startsWith("Lua ${it.id}") }
        }
        if (target != null && seen.add(target)) name to target else null
    }
}
