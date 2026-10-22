
// A package manager's dependency resolver: semantic versions with Comparable and ranges,
// constraint parsing, a registry backed by sorted maps, backtracking resolution and a lock file.

data class Version(val major: Int, val minor: Int = 0, val patch: Int = 0, val pre: String? = null) : Comparable<Version> {
    override fun compareTo(other: Version): Int = compareValuesBy(this, other, { it.major }, { it.minor }, { it.patch })
        .takeIf { it != 0 } ?: when {
        pre == other.pre -> 0
        pre == null -> 1
        other.pre == null -> -1
        else -> pre.compareTo(other.pre)
    }

    fun bump(part: Part) = when (part) {
        Part.MAJOR -> Version(major + 1)
        Part.MINOR -> Version(major, minor + 1)
        Part.PATCH -> copy(patch = patch + 1, pre = null)
    }

    override fun toString() = "$major.$minor.$patch" + (pre?.let { "-$it" } ?: "")

    enum class Part { MAJOR, MINOR, PATCH }

    companion object {
        // MAJOR[.MINOR[.PATCH]][-PRE]: Lua patterns have no optional groups, so the parts are split off
        private val NUMBER = Regex("""\d+""")
        private val PRE = Regex("""[\w.]+""")
        fun parse(s: String): Version {
            val text = s.trim()
            val numbers = text.substringBefore('-').split('.')
            val pre = text.substringAfter('-', "")
            if (numbers.size > 3 || !numbers.all { it.matches(NUMBER) } || ('-' in text && !pre.matches(PRE))) {
                throw IllegalArgumentException("invalid version '$s'")
            }
            return Version(numbers[0].toInt(), numbers.getOrNull(1)?.toInt() ?: 0, numbers.getOrNull(2)?.toInt() ?: 0, pre.ifEmpty { null })
        }
    }
}

fun String.toVersion() = Version.parse(this)

sealed interface Constraint {
    fun allows(v: Version): Boolean

    data class Exact(val v: Version) : Constraint {
        override fun allows(v: Version) = v == this.v
        override fun toString() = "=$v"
    }

    data class Range(val range: ClosedRange<Version>, val upperExclusive: Boolean) : Constraint {
        override fun allows(v: Version) = v in range && !(upperExclusive && v == range.endInclusive) && v.pre == null
        override fun toString() = "[${range.start}, ${range.endInclusive}${if (upperExclusive) ")" else "]"}"
    }

    data class AnyOf(val options: List<Constraint>) : Constraint {
        override fun allows(v: Version) = options.any { it.allows(v) }
        override fun toString() = options.joinToString(" || ")
    }

    object Any : Constraint {
        override fun allows(v: Version) = v.pre == null
        override fun toString() = "*"
    }

    companion object {
        fun parse(text: String): Constraint {
            val alternatives = text.split("||").map { it.trim() }
            if (alternatives.size > 1) return AnyOf(alternatives.map(::parse))
            val s = alternatives.single()
            return when {
                s == "*" -> Any
                s.startsWith("^") -> s.drop(1).toVersion().let { v -> Range(v..v.bump(Version.Part.MAJOR), true) }
                s.startsWith("~") -> s.drop(1).toVersion().let { v -> Range(v..v.bump(Version.Part.MINOR), true) }
                s.startsWith(">=") -> Range(s.removePrefix(">=").toVersion()..Version(Int.MAX_VALUE), false)
                " - " in s -> s.split(" - ").let { (lo, hi) -> Range(lo.toVersion()..hi.toVersion(), false) }
                else -> Exact(s.removePrefix("=").toVersion())
            }
        }
    }
}

class Registry {
    private val packages = HashMap<String, java.util.SortedMap<Version, Map<String, Constraint>>>()

    fun publish(name: String, version: String, vararg deps: Pair<String, String>) {
        val versions = packages.getOrPut(name) { sortedMapOf() }
        val v = version.toVersion()
        check(v !in versions) { "$name@$v already published" }
        versions[v] = deps.associate { (n, c) -> n to Constraint.parse(c) }
    }

    fun candidates(name: String, c: Constraint): List<Version> =
        packages[name]?.keys?.reversed()?.filter(c::allows) ?: throw NoSuchElementException("unknown package '$name'")

    fun deps(name: String, v: Version): Map<String, Constraint> = packages.getValue(name).getValue(v)

    fun latest(name: String): Version? = packages[name]?.keys?.lastOrNull()
    fun before(name: String, v: Version): Version? = packages[name]?.keys?.lastOrNull { it < v }
}

class ResolutionException(msg: String) : RuntimeException(msg)

class Resolver(private val registry: Registry) {
    var attempts = 0
        private set

    fun resolve(root: Map<String, String>): Map<String, Version> {
        val pending = root.map { (n, c) -> Triple("<root>", n, Constraint.parse(c)) }
        return solve(sortedMapOf(), pending) ?: throw ResolutionException("no solution for $root after $attempts attempts")
    }

    private fun solve(chosen: Map<String, Version>, pending: List<Triple<String, String, Constraint>>): Map<String, Version>? {
        attempts++
        val (from, name, constraint) = pending.firstOrNull() ?: return chosen
        val rest = pending.drop(1)
        chosen[name]?.let { picked ->
            return if (constraint.allows(picked)) solve(chosen, rest) else null
        }
        for (v in registry.candidates(name, constraint)) {
            val newDeps = registry.deps(name, v).map { (n, c) -> Triple("$name@$v", n, c) }
            val result = solve(chosen + (name to v), rest + newDeps)
            if (result != null) return result
        }
        if (from == "<root>") return null
        return null
    }
}

fun lockFile(solution: Map<String, Version>, registry: Registry): String = buildString {
    appendLine("# generated lock file")
    for ((name, v) in solution) {
        appendLine("$name = \"$v\"")
        registry.deps(name, v).toSortedMap().forEach { (dep, c) -> appendLine("  $dep $c -> ${solution[dep]}") }
    }
}.trimEnd()

fun main() {
    val versions = listOf("1.0.0", "1.0.0-alpha", "1.0.0-beta", "0.9", "1.2", "1.10.0", "1.2.3", "2").map(String::toVersion)
    println("sorted: ${versions.sorted()}")
    println("max=${versions.max()} min=${versions.min()} distinct majors=${versions.map { it.major }.toSortedSet()}")
    println("1.2.3 in 1.0..2.0: ${"1.2.3".toVersion() in "1.0".toVersion().."2.0".toVersion()}")
    println("bumps: ${Version.Part.entries.map { "1.4.7".toVersion().bump(it) }}")
    println(runCatching { "1.x".toVersion() }.exceptionOrNull())
    for (c in listOf("^1.2.0", "~1.2.0", ">=1.10", "1.0 - 1.2", "=2.0.0", "*", "^0.9 || ^2.0")) {
        val parsed = Constraint.parse(c)
        println("${c.padEnd(12)} $parsed allows ${versions.filter(parsed::allows).sorted()}")
    }

    val reg = Registry()
    reg.publish("app-core", "1.0.0", "log" to "^1.0", "json" to "^2.1")
    reg.publish("app-core", "1.1.0", "log" to "^1.2", "json" to "^2.3", "http" to "~0.4")
    reg.publish("log", "1.0.0")
    reg.publish("log", "1.2.0")
    reg.publish("log", "1.3.0", "fmt" to "^3.0")
    reg.publish("log", "2.0.0", "fmt" to "^4.0")
    reg.publish("fmt", "3.1.0")
    reg.publish("fmt", "4.0.0")
    reg.publish("json", "2.1.0")
    reg.publish("json", "2.3.1", "fmt" to "^3.0")
    reg.publish("json", "2.4.0-rc.1")
    reg.publish("http", "0.4.2", "log" to ">=1.3", "json" to "2.1.0 - 2.9.9")
    reg.publish("http", "0.5.0", "log" to "^2.0")
    try {
        reg.publish("log", "1.2")
    } catch (e: IllegalStateException) {
        println("publish failed: ${e.message}")
    }
    println("latest log=${reg.latest("log")} before 1.3.0=${reg.before("log", "1.3.0".toVersion())} latest nope=${reg.latest("nope")}")
    println("json candidates for ^2.0: ${reg.candidates("json", Constraint.parse("^2.0"))}")

    val resolver = Resolver(reg)
    val solution = resolver.resolve(mapOf("app-core" to "^1.0", "log" to "<1.3 || ^1.0".substringAfter("|| ")))
    println("solution after ${resolver.attempts} attempts: $solution")
    println(lockFile(solution, reg))

    val strict = Resolver(reg)
    val failure = runCatching { strict.resolve(mapOf("app-core" to "=1.1.0", "fmt" to "^4.0")) }
    println("strict: ${failure.exceptionOrNull()?.message}")
    println(runCatching { Resolver(reg).resolve(mapOf("left-pad" to "*")) }.exceptionOrNull())

    val usage = reg.candidates("log", Constraint.Any).associateWith { v -> reg.deps("log", v).keys.ifEmpty { setOf("-") } }
    println("log deps by version: $usage")
    val grouped = versions.groupBy { if (it.pre != null) "pre" else if (it.major == 0) "unstable" else "stable" }
    println("grouped: ${grouped.toSortedMap()}")
}
