package host.builtin

import host.api.Configurable
import host.api.CountingPlugin
import host.api.Plugin
import host.api.Registry
import host.api.initLog

class UpperPlugin private constructor(priority: Int) : CountingPlugin("upper", priority) {
    init {
        initLog += "UpperPlugin.init"
    }

    override fun process(input: String) = if (input.any { it.isLowerCase() }) input.uppercase() else null

    override fun onStart() = "upper ready"

    companion object {
        init {
            initLog += "UpperPlugin.Companion.init"
        }

        fun create(settings: Map<String, String>): UpperPlugin = UpperPlugin(settings["priority"]?.toInt() ?: 5)
    }
}

class ReplacePlugin(override val settings: Map<String, String>) : CountingPlugin("replace", 3), Configurable {
    private val from = setting("from", "foo")
    private val to = setting("to", "bar")

    init {
        initLog += "ReplacePlugin.init $from->$to"
    }

    override val displayName: String
        get() = "Replace($from->$to)"

    override fun process(input: String): String? = if (from in input) input.replace(from, to) else null

    override fun stats() = super.stats() + " (from=$from)"

    override fun describe(): String = "Replace:" + super.describe()
}

/** Rejects inputs longer than a limit by throwing; the host wraps the failure. */
class GuardPlugin(private val limit: Int) : Plugin("guard", 10) {
    override val tag = "guard"

    override fun handle(input: String): String? {
        require(input.length <= limit) { "input too long (${input.length} > $limit)" }
        return null
    }

    override val displayName get() = "Guard<=$limit"
}

/** A plugin built from an object expression inside a function: anonymous subclass with captured state. */
fun counterPlugin(prefix: String): Plugin {
    var calls = 0
    return object : Plugin("counter", 1) {
        override fun handle(input: String): String? {
            calls++
            return if (input.startsWith(prefix)) "$prefix#$calls" else null
        }

        override val displayName = "Counter($prefix)"
    }
}

/** Installs the builtin factories; called once by the host. */
fun installBuiltins() {
    Registry.register("upper", UpperPlugin::create)
    Registry.register("replace") { ReplacePlugin(it) }
    Registry.register("guard") { GuardPlugin(it["limit"]?.toIntOrNull() ?: 20) }
    Registry.register("counter") { counterPlugin(it.getOrDefault("prefix", "#")) }
}
