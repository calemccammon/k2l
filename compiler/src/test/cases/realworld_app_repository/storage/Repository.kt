package shop.storage

import shop.domain.Entity
import shop.domain.Versioned

/** Read side of a store; `out` so a repository of products can be read as a repository of entities. */
interface ReadRepository<out T : Entity<ID>, ID : Comparable<ID>> {
    fun find(id: ID): T?
    fun all(): List<T>
    val size: Int get() = all().size
}

interface WriteRepository<in T : Entity<*>> {
    fun save(entity: T)
}

class ConflictException(val entityId: Any, message: String) : IllegalStateException(message)

/**
 * Template method: [save] validates, checks versions and then calls [store]; subclasses decide how to store.
 */
abstract class Repository<T : Entity<ID>, ID : Comparable<ID>>(val kind: String) :
    ReadRepository<T, ID>,
    WriteRepository<T> {
    protected val events = mutableListOf<String>()
    private var saves = 0

    protected abstract fun store(entity: T)
    protected abstract fun load(id: ID): T?
    protected open fun validate(entity: T): String? = null

    final override fun save(entity: T) {
        validate(entity)?.let { throw IllegalArgumentException("invalid $kind ${entity.id}: $it") }
        val old = load(entity.id)
        if (old is Versioned && entity is Versioned && entity.version <= old.version) {
            throw ConflictException(entity.id, "stale $kind ${entity.id}: v${entity.version} <= v${old.version}")
        }
        store(entity)
        saves++
        events += (if (old == null) "insert " else "update ") + entity.id
    }

    override fun find(id: ID): T? = load(id)

    fun history(): List<String> = events.toList()

    override fun toString(): String = "$kind repository ($size items, $saves saves)"
}

/** Keeps entities sorted by id. */
open class SortedRepository<T : Entity<ID>, ID : Comparable<ID>>(kind: String) : Repository<T, ID>(kind) {
    private val items = sortedMapOf<ID, T>()

    override fun store(entity: T) {
        items[entity.id] = entity
    }

    override fun load(id: ID): T? = items[id]

    override fun all(): List<T> = items.values.toList()

    override val size: Int get() = items.size

    fun range(from: ID, to: ID): List<T> = items.filterKeys { it >= from && it < to }.values.toList()
}

/** Remembers insertion order, and limits capacity by evicting the oldest. */
class BoundedRepository<T : Entity<ID>, ID : Comparable<ID>>(kind: String, private val capacity: Int) : Repository<T, ID>(kind) {
    private val items = LinkedHashMap<ID, T>()

    override fun store(entity: T) {
        items.remove(entity.id)
        items[entity.id] = entity
        while (items.size > capacity) {
            val oldest = items.keys.first()
            items.remove(oldest)
            events += "evict $oldest"
        }
    }

    override fun load(id: ID) = items[id]
    override fun all() = items.values.toList()
}

fun <T : Entity<ID>, ID : Comparable<ID>> ReadRepository<T, ID>.require(id: ID): T =
    find(id) ?: throw NoSuchElementException("no entity $id")

fun ReadRepository<*, *>.describe(): String = "repo with $size entities"

/** Copies every entity of [from] into [to]; the variance lets a sorted repo of products feed a writer of entities. */
fun <T : Entity<*>> copyAll(from: ReadRepository<T, *>, to: WriteRepository<T>): Int {
    var n = 0
    for (e in from.all()) {
        to.save(e)
        n++
    }
    return n
}
