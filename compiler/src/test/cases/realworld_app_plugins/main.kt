package host

import host.api.Configurable
import host.api.CountingPlugin
import host.api.Describable
import host.api.Lifecycle
import host.api.Plugin
import host.api.PluginException
import host.api.Registry
import host.api.initLog
import host.builtin.installBuiltins
import host.builtin.UpperPlugin as Upper

// A text-processing host that loads plugins from a registry, orders them by priority and runs inputs through them.

class Host(private val name: String) {
    private val plugins = sortedSetOf<Plugin>()
    private val failures = mutableListOf<String>()

    /** Each run remembers what happened; inner, so it can reach the host's plugins and name. */
    inner class Run(val input: String) {
        val steps = mutableListOf<String>()

        fun execute(): String {
            var current = input
            for (p in plugins) {
                val out = try {
                    p.handle(current)
                } catch (e: IllegalArgumentException) {
                    val wrapped = PluginException(p.id, e)
                    failures += wrapped.message!!
                    this@Host.failures += "cause: ${wrapped.cause?.javaClass?.simpleName}"
                    return "rejected by $p"
                }
                if (out != null) {
                    steps += "${p.id}: $current -> $out"
                    current = out
                }
            }
            return "$name: $current"
        }
    }

    class Report(val lines: List<String>) {
        override fun toString() = lines.joinToString("\n") { "  | $it" }
    }

    fun load(vararg specs: Pair<String, Map<String, String>>) {
        for ((plugin, settings) in specs) {
            val p = try {
                Registry.create(plugin, settings)
            } catch (e: NoSuchElementException) {
                failures += e.message ?: "?"
                continue
            }
            plugins += p
            println("loaded $p: ${p.start()} / ${p.describe()}")
        }
    }

    fun run(input: String): Pair<String, List<String>> {
        val r = Run(input)
        return r.execute() to r.steps
    }

    fun report() = Report(
        plugins.map { p ->
            when (p) {
                is CountingPlugin -> p.stats()
                is Configurable -> "configurable ${p.id}"
                else -> "${p.id} (${if (p.started) "started" else "idle"})"
            }
        } + failures,
    )

    val order: List<String> get() = plugins.map { it.id }
}

object Version : Comparable<Version> {
    const val MAJOR = 1
    const val MINOR = 4
    override fun compareTo(other: Version) = 0
    override fun toString() = "v$MAJOR.$MINOR"
}

enum class Level : Describable {
    LOW {
        override val id = "low"
    },
    HIGH {
        override val id = "high"
        override fun describe() = "HIGH!"
    },
}

class Both : Describable, Lifecycle {
    override val id = "both"
    override fun describe() = "both: " + super<Lifecycle>.describe() + "/" + super<Describable>.describe()
}

fun check(x: Any): String = buildString {
    append(if (x is Comparable<*>) "comparable" else "not comparable")
    if (x is Describable) append(", describable ${x.id}")
    if (x is Lifecycle) append(", lifecycle")
}

fun main() {
    println("before install: $initLog")
    installBuiltins()
    println("after install: $initLog")
    initLog.clear()

    val host = Host("main")
    host.load(
        "guard" to mapOf("limit" to "16"),
        "replace" to mapOf("from" to "cat", "to" to "dog"),
        "upper" to emptyMap(),
        "missing" to emptyMap(),
        "counter" to mapOf("prefix" to "!"),
    )
    println("init order:")
    initLog.forEach { println("  $it") }
    println("order: ${host.order}")

    for (input in listOf("the cat sat", "!cat", "NO CHANGE", "a very long input line", "cat cat")) {
        val (result, steps) = host.run(input)
        println("$input => $result")
        steps.forEach { println("    $it") }
    }
    println("report:\n${host.report()}")
    println("lookups: ${Registry.lookups}, registered: ${Registry.names}")

    try {
        Registry.register("upper") { Upper.create(it) }
    } catch (e: IllegalStateException) {
        println("error: ${e.message}")
    }

    val another = Upper.create(mapOf("priority" to "7"))
    println("$another ${another.displayName} ${another.describe()} ${another.compareTo(Registry.create("upper"))}")
    println("${Version} ${check(Version)} | ${check(Level.HIGH)} ${Level.HIGH.describe()} ${Level.LOW.describe()}")
    println("${check(Both())} ${Both().describe()} | ${check(another)} | ${check("text")} | ${check(listOf(1))}")
    val comparables = listOf<Any>(Version, 3, "s", another, Level.LOW, Both(), 2.5).filterIsInstance<Comparable<*>>()
    println("comparables: ${comparables.size}")
}
