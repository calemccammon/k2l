package sim.ecs

import kotlin.reflect.KClass

/** Marker for component data. */
interface Component

@JvmInline
value class Entity(val id: Int) {
    override fun toString() = "e$id"
}

/** Storage for one component type: sparse map from entity id to component. */
class Store<C : Component> internal constructor(val type: KClass<C>) {
    private val items = sortedMapOf<Int, C>()
    val size get() = items.size
    operator fun get(e: Entity): C? = items[e.id]
    operator fun set(e: Entity, c: C) {
        items[e.id] = c
    }
    fun remove(e: Entity) = items.remove(e.id) != null
    fun ids(): Set<Int> = items.keys
    override fun toString() = "${type.simpleName}x$size"
}

abstract class System(val name: String) {
    var runs = 0
        private set

    internal fun tick(world: World, dt: Int) {
        runs++
        update(world, dt)
    }

    protected abstract fun update(world: World, dt: Int)

    override fun toString() = "$name($runs)"
}

class World {
    private var nextId = 1
    private val alive = linkedSetOf<Int>()
    @PublishedApi
    internal val stores = linkedMapOf<KClass<out Component>, Store<out Component>>()
    private val systems = mutableListOf<System>()
    private val pendingRemoval = mutableListOf<Entity>()
    var tick = 0
        private set
    val log = mutableListOf<String>()

    fun spawn(vararg components: Component): Entity {
        val e = Entity(nextId++)
        alive += e.id
        components.forEach { add(e, it) }
        return e
    }

    fun <C : Component> add(e: Entity, c: C) {
        @Suppress("UNCHECKED_CAST")
        val store = stores.getOrPut(c::class) { Store(c::class) } as Store<C>
        store[e] = c
    }

    @Suppress("UNCHECKED_CAST")
    fun <C : Component> store(type: KClass<C>): Store<C> = stores.getOrPut(type) { Store(type) } as Store<C>

    inline fun <reified C : Component> get(e: Entity): C? = store(C::class)[e]

    inline fun <reified C : Component> has(e: Entity): Boolean = get<C>(e) != null

    inline fun <reified A : Component> query(): List<Pair<Entity, A>> {
        val s = store(A::class)
        return s.ids().filter { isAlive(it) }.map { Entity(it) to s[Entity(it)]!! }
    }

    inline fun <reified A : Component, reified B : Component> query2(): List<Triple<Entity, A, B>> {
        val a = store(A::class)
        val b = store(B::class)
        return a.ids().filter { it in b.ids() && isAlive(it) }.map { id -> Entity(id).let { Triple(it, a[it]!!, b[it]!!) } }
    }

    fun isAlive(id: Int) = id in alive

    fun destroy(e: Entity) {
        pendingRemoval += e
    }

    fun addSystem(system: System) = apply { systems += system }

    fun step(dt: Int = 1) {
        tick++
        for (s in systems) s.tick(this, dt)
        for (e in pendingRemoval) {
            if (alive.remove(e.id)) {
                stores.values.forEach { it.remove(e) }
                log += "t$tick: $e destroyed"
            }
        }
        pendingRemoval.clear()
    }

    val population get() = alive.size
    fun systems(): List<System> = systems
    override fun toString() = "World(tick=$tick, alive=$alive, stores=${stores.values})"
}
