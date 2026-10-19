package host.api

val initLog = mutableListOf<String>()

internal fun trace(what: String) {
    initLog += what
}

interface Describable {
    val id: String
    fun describe(): String = "Describable($id)"
}

interface Lifecycle {
    fun start(): String = "start"
    fun stop(): String = "stop"
    fun describe(): String = "Lifecycle"
}

interface Configurable {
    val settings: Map<String, String> get() = emptyMap()
    fun setting(key: String, default: String): String = settings[key] ?: default
}

/** A plugin: both interfaces have a default `describe`, so every plugin must resolve the diamond. */
abstract class Plugin(final override val id: String, val priority: Int = 0) : Describable, Lifecycle, Comparable<Plugin> {
    open val displayName: String get() = id.uppercase()
    protected open val tag = "plugin"
    var started = false
        private set

    init {
        trace("Plugin.init($id) tag=$tag")
    }

    abstract fun handle(input: String): String?

    override fun describe(): String = "${super<Describable>.describe()}+${super<Lifecycle>.describe()}"

    final override fun start(): String {
        started = true
        return onStart() ?: super.start()
    }

    protected open fun onStart(): String? = null

    override fun compareTo(other: Plugin): Int = compareValuesBy(other, this, Plugin::priority).let { if (it != 0) it else id.compareTo(other.id) }

    override fun toString() = "$displayName[$priority]"
}

/** Plugins that keep a counter; shows a second level of the hierarchy and of init order. */
abstract class CountingPlugin(id: String, priority: Int) : Plugin(id, priority) {
    protected var count = 0
    private val createdAt = initLog.size

    init {
        trace("CountingPlugin.init($id) createdAt=$createdAt")
    }

    override val tag = "counting"

    final override fun handle(input: String): String? {
        val r = process(input)
        if (r != null) count++
        return r
    }

    protected abstract fun process(input: String): String?

    open fun stats() = "$id handled $count"
}

class PluginException(val plugin: String, cause: Throwable) : Exception("plugin $plugin failed: ${cause.message}", cause)

typealias Factory = (Map<String, String>) -> Plugin

object Registry {
    private val factories = linkedMapOf<String, Factory>()
    var lookups = 0
        private set

    init {
        trace("Registry.init")
    }

    fun register(name: String, factory: Factory) {
        check(factories.put(name, factory) == null) { "plugin $name registered twice" }
    }

    fun create(name: String, settings: Map<String, String> = emptyMap()): Plugin {
        lookups++
        val f = factories[name] ?: throw NoSuchElementException("unknown plugin '$name'; known: ${factories.keys.joinToString()}")
        return f(settings)
    }

    val names: Set<String> get() = factories.keys
}
