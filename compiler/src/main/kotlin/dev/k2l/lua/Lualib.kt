package dev.k2l.lua

import dev.k2l.LuaTarget

/**
 * Runtime helpers shipped as Lua source in `resources/dev/k2l/lualib/<Name>.lua`. Each file defines
 * `local function __K2L_<Name>` and may declare `-- requires: A, B` on its first line.
 */
object Lualib {
    class Feature(val name: String, val code: String, val requires: List<String>) {
        /** Top-level `__K2L_*` locals the feature defines. */
        val exports: List<String> = Regex("""^local (?:function )?(__K2L_\w+)""", RegexOption.MULTILINE)
            .findAll(code).map { it.groupValues[1] }.distinct().toList()
    }

    const val BUNDLE_MODULE = "lualib_bundle"
    private const val REQUIRES_PREFIX = "-- requires:"

    /** The shared runtime: every used feature, returning a table of their exports. */
    fun bundle(features: Collection<String>, target: LuaTarget = LuaTarget.Lua54): String {
        val resolved = resolve(features, target)
        val exports = resolved.flatMap { it.exports }.distinct()
        return resolved.joinToString("\n\n") { it.code } +
            exports.joinToString(",\n", prefix = "\n\nreturn {\n", postfix = ",\n}\n") { "    $it = $it" }
    }

    private val cache = mutableMapOf<Pair<String, LuaTarget>, Feature>()

    fun functionName(feature: String) = "__K2L_$feature"

    fun feature(name: String, target: LuaTarget = LuaTarget.Lua54): Feature = cache.getOrPut(name to target) {
        val code = (target.lualibVariants.map { "$name.$it" } + name).firstNotNullOfOrNull { file ->
            Lualib::class.java.getResourceAsStream("/dev/k2l/lualib/$file.lua")?.use { it.readBytes().toString(Charsets.UTF_8) }
        } ?: error("missing lualib feature $name")
        val lines = code.lines()
        val requires = lines.first().takeIf { it.startsWith(REQUIRES_PREFIX) }
            ?.removePrefix(REQUIRES_PREFIX)?.split(',')?.map { it.trim() }?.filter { it.isNotEmpty() }.orEmpty()
        Feature(name, lines.dropWhile { it.startsWith(REQUIRES_PREFIX) }.joinToString("\n").trim(), requires)
    }

    /** Used features plus their dependencies, dependencies first. */
    fun resolve(used: Collection<String>, target: LuaTarget = LuaTarget.Lua54): List<Feature> {
        val ordered = LinkedHashMap<String, Feature>()
        fun visit(name: String) {
            if (name in ordered) return
            val f = feature(name, target)
            f.requires.forEach(::visit)
            ordered[name] = f
        }
        used.sorted().forEach(::visit)
        return ordered.values.toList()
    }
}
