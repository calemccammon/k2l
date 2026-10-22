package dev.k2l.codegen

import dev.k2l.LuaTarget
import java.util.concurrent.ConcurrentHashMap

/**
 * Runtime helpers shipped as Lua source in `resources/dev/k2l/lualib/<Name>.lua`. Each file defines
 * `local function __K2L_<Name>` and may declare `-- requires: A, B` on its first line.
 */
object Lualib {
    /** A feature as loaded for one target: [file] is the resource it was read from (`FloorDiv.float.lua`, `FloorDiv.lua`). */
    class Feature(val name: String, val code: String, val requires: List<String>, val file: String) {
        /** Top-level `__K2L_*` locals the feature defines. */
        val exports: List<String> = Regex("""^local (?:function )?(__K2L_\w+)""", RegexOption.MULTILINE)
            .findAll(code).map { it.groupValues[1] }.distinct().toList()
    }

    const val BUNDLE_MODULE = "lualib_bundle"
    private const val REQUIRES_PREFIX = "-- requires:"

    /** The table holding every feature's exports, in the bundle and in a file that inlines the runtime. */
    private const val EXPORTS = "____lualib"

    private val REFERENCE = Regex("""\b__K2L_\w+""")

    /** The shared runtime: every used feature, returning a table of their exports. */
    fun bundle(features: Collection<String>, target: LuaTarget = LuaTarget.Lua54): String =
        scoped(resolve(features, target)) + "\nreturn $EXPORTS\n"

    /** The runtime copied into one file: the used features, then a local for each runtime name the file refers to. */
    fun inline(features: Collection<String>, names: Collection<String>, target: LuaTarget = LuaTarget.Lua54): String =
        scoped(resolve(features, target)) + names.joinToString("") { "local $it = $EXPORTS.$it\n" }

    /**
     * The features, each in its own `do` block: Lua allows a function (the chunk included) 200 locals, which all features'
     * top-level locals together exceed. A block imports the earlier exports it uses and publishes its own to [EXPORTS].
     */
    private fun scoped(features: List<Feature>): String = buildString {
        append("local $EXPORTS = {}\n")
        val published = LinkedHashSet<String>()
        for (feature in features) {
            val own = feature.exports.toSet()
            val imports = REFERENCE.findAll(feature.code).map { it.value }.filter { it !in own && it in published }.distinct()
            append("\ndo\n")
            imports.forEach { append("local $it = $EXPORTS.$it\n") }
            append(feature.code).append('\n')
            feature.exports.forEach { append("$EXPORTS.$it = $it\n") }
            append("end\n")
            published += feature.exports
        }
    }

    // compilations of several modules can run at once (the Gradle plugin, watch mode)
    private val cache = ConcurrentHashMap<Pair<String, LuaTarget>, Feature>()

    fun functionName(feature: String) = "__K2L_$feature"

    fun feature(name: String, target: LuaTarget = LuaTarget.Lua54): Feature = cache.computeIfAbsent(name to target) {
        val (file, code) = (target.lualibVariants.map { "$name.$it" } + name).firstNotNullOfOrNull { file ->
            Lualib::class.java.getResourceAsStream("/dev/k2l/lualib/$file.lua")
                ?.use { "$file.lua" to it.readBytes().toString(Charsets.UTF_8) }
        } ?: error("missing lualib feature $name")
        val lines = code.lines()
        val requires = lines.first().takeIf { it.startsWith(REQUIRES_PREFIX) }
            ?.removePrefix(REQUIRES_PREFIX)?.split(',')?.map { it.trim() }?.filter { it.isNotEmpty() }.orEmpty()
        Feature(name, lines.dropWhile { it.startsWith(REQUIRES_PREFIX) }.joinToString("\n").trim(), requires, file)
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
