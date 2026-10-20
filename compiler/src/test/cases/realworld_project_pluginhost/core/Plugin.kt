package arena.core

// The plugin API every plugin package implements, and the registry plugins are discovered through.

interface Plugin {
    val id: String
    val dependsOn: List<String> get() = emptyList()

    fun install(ctx: Context)

    fun onTick(tick: Int, world: World) {}

    fun onEvent(event: Event, world: World): Boolean = false
}

/** Plugin classes register a factory, usually their companion object. */
interface PluginFactory {
    val pluginId: String

    fun create(): Plugin
}

abstract class BasePlugin(final override val id: String, private vararg val deps: String) : Plugin {
    override val dependsOn: List<String> get() = deps.toList()

    protected lateinit var ctx: Context
        private set

    override fun install(ctx: Context) {
        this.ctx = ctx
        ctx.log("install $id" + if (deps.isEmpty()) "" else " after ${deps.joinToString()}")
        setup()
    }

    protected open fun setup() {}

    override fun toString() = "Plugin($id)"
}

class PluginException(val pluginId: String, cause: Throwable) : RuntimeException("plugin $pluginId failed: ${cause.message}", cause)

object PluginRegistry {
    private val factories = linkedMapOf<String, PluginFactory>()
    var lookups = 0
        private set

    init {
        println("registry ready")
    }

    fun register(factory: PluginFactory): PluginRegistry {
        check(factory.pluginId !in factories) { "duplicate plugin ${factory.pluginId}" }
        factories[factory.pluginId] = factory
        return this
    }

    val ids: Set<String> get() = factories.keys

    /** Creates every plugin, dependencies first; unknown dependencies and cycles are errors. */
    fun discover(): List<Plugin> {
        val created = factories.mapValues { (_, f) -> f.create() }
        val ordered = LinkedHashMap<String, Plugin>()
        val visiting = mutableSetOf<String>()

        fun visit(id: String, from: String?) {
            lookups++
            if (id in ordered) return
            val plugin = created[id] ?: throw IllegalArgumentException("unknown plugin $id needed by $from")
            check(visiting.add(id)) { "dependency cycle at $id" }
            plugin.dependsOn.sorted().forEach { visit(it, id) }
            visiting.remove(id)
            ordered[id] = plugin
        }
        created.keys.sorted().forEach { visit(it, null) }
        return ordered.values.toList()
    }

    fun clear() = factories.clear()
}
