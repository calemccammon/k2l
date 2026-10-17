package dev.k2l.lua

/**
 * Runtime helpers shipped as Lua source in `resources/dev/k2l/lualib/<Name>.lua`. Each file defines
 * `local function __K2L_<Name>` and may declare `-- requires: A, B` on its first line.
 */
object Lualib {
    class Feature(val name: String, val code: String, val requires: List<String>)

    private val cache = mutableMapOf<String, Feature>()

    fun functionName(feature: String) = "__K2L_$feature"

    fun feature(name: String): Feature = cache.getOrPut(name) {
        val code = Lualib::class.java.getResourceAsStream("/dev/k2l/lualib/$name.lua")
            ?.use { it.readBytes().toString(Charsets.UTF_8) }
            ?: error("missing lualib feature $name")
        val requires = code.lineSequence().first().removePrefix("-- requires:").takeIf { it != code.lineSequence().first() }
            ?.split(',')?.map { it.trim() }?.filter { it.isNotEmpty() }.orEmpty()
        Feature(name, code.lines().dropWhile { it.startsWith("-- requires:") }.joinToString("\n").trim(), requires)
    }

    /** Used features plus their dependencies, dependencies first. */
    fun resolve(used: Collection<String>): List<Feature> {
        val ordered = LinkedHashMap<String, Feature>()
        fun visit(name: String) {
            if (name in ordered) return
            val f = feature(name)
            f.requires.forEach(::visit)
            ordered[name] = f
        }
        used.sorted().forEach(::visit)
        return ordered.values.toList()
    }
}
