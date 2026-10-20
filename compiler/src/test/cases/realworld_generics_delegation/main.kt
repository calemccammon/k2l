package generics.delegation

// A repository layer built from generic interfaces with default methods, class delegation (`by`) to add caching,
// auditing and read-only views, and generic extension functions and properties.

interface Identified<ID : Comparable<ID>> {
    val id: ID
}

interface Repository<ID : Comparable<ID>, E : Identified<ID>> {
    fun findById(id: ID): E?
    fun findAll(): List<E>
    fun save(entity: E): E
    fun delete(id: ID): Boolean

    fun require(id: ID): E = findById(id) ?: throw NoSuchElementException("no entity with id $id")
    fun saveAll(entities: Iterable<E>): List<E> = entities.map { save(it) }
    fun count(): Int = findAll().size
    fun exists(id: ID): Boolean = findById(id) != null
    fun findWhere(predicate: (E) -> Boolean): List<E> = findAll().filter(predicate)
}

open class InMemoryRepository<ID : Comparable<ID>, E : Identified<ID>> : Repository<ID, E> {
    private val store = sortedMapOf<ID, E>()
    var reads = 0
        private set

    override fun findById(id: ID): E? = store[id].also { reads++ }
    override fun findAll(): List<E> = store.values.toList().also { reads++ }
    override fun save(entity: E): E = entity.also { store[it.id] = it }
    override fun delete(id: ID): Boolean = store.remove(id) != null
}

class CachingRepository<ID : Comparable<ID>, E : Identified<ID>>(private val inner: Repository<ID, E>) : Repository<ID, E> by inner {
    private val cache = HashMap<ID, E?>()
    var hits = 0
        private set

    override fun findById(id: ID): E? {
        if (id in cache) {
            hits++
            return cache[id]
        }
        return inner.findById(id).also { cache[id] = it }
    }

    override fun save(entity: E): E = inner.save(entity).also { cache[entity.id] = it }

    override fun delete(id: ID): Boolean = inner.delete(id).also { cache.remove(id) }
}

class AuditingRepository<ID : Comparable<ID>, E : Identified<ID>>(
    private val inner: Repository<ID, E>,
    private val log: MutableList<String>,
) : Repository<ID, E> by inner {
    override fun save(entity: E): E {
        log += "${if (inner.exists(entity.id)) "update" else "insert"} ${entity.id}"
        return inner.save(entity)
    }

    override fun delete(id: ID): Boolean = inner.delete(id).also { log += "delete $id -> $it" }
}

interface ReadOnly<ID : Comparable<ID>, out E : Identified<ID>> {
    fun findById(id: ID): E?
    fun findAll(): List<E>
}

fun <ID : Comparable<ID>, E : Identified<ID>> Repository<ID, E>.readOnly(): ReadOnly<ID, E> {
    val repo = this
    return object : ReadOnly<ID, E> {
        override fun findById(id: ID) = repo.findById(id)
        override fun findAll() = repo.findAll()
    }
}

class Labeled<T>(private val items: MutableList<T>, val label: String) : MutableList<T> by items {
    override fun add(element: T): Boolean {
        println("  [$label] add $element")
        return items.add(element)
    }

    override fun toString() = "$label$items"
}

data class User(override val id: Int, val name: String, val role: String) : Identified<Int>
data class Product(override val id: String, val price: Double, val stock: Int) : Identified<String>

val <ID : Comparable<ID>, E : Identified<ID>> Repository<ID, E>.ids: List<ID> get() = findAll().map { it.id }

val <T> List<T>.middle: T? get() = if (isEmpty()) null else this[size / 2]

fun <ID : Comparable<ID>, E : Identified<ID>> Repository<ID, E>.update(id: ID, change: (E) -> E): E? = findById(id)?.let { save(change(it)) }

fun <K, V : Comparable<V>> Map<K, V>.keyOfMax(): K? = entries.maxByOrNull { it.value }?.key

fun <T, K> Iterable<T>.countBy(key: (T) -> K): Map<K, Int> = groupingBy(key).eachCount()

fun main() {
    println("== users")
    val log = mutableListOf<String>()
    val base = InMemoryRepository<Int, User>()
    val users: Repository<Int, User> = AuditingRepository(CachingRepository(base), log)
    users.saveAll(listOf(User(3, "carol", "admin"), User(1, "alice", "dev"), User(2, "bob", "dev")))
    users.save(User(2, "bob", "lead"))
    println("count=${users.count()} ids=${users.ids} exists(4)=${users.exists(4)}")
    println("devs=${users.findWhere { it.role == "dev" }.map { it.name }}")
    println("update=${users.update(1) { it.copy(name = it.name.uppercase()) }} missing=${users.update(9) { it }}")
    println("require(3)=${users.require(3).name} again=${users.require(3).role}")
    try {
        users.require(42)
    } catch (e: NoSuchElementException) {
        println("error: ${e.message}")
    }
    println("delete(2)=${users.delete(2)} delete(2)=${users.delete(2)} ids=${users.ids}")
    println("base reads=${base.reads}")
    log.forEach { println("  audit: $it") }

    println("== products")
    val products = CachingRepository(InMemoryRepository<String, Product>())
    products.saveAll(listOf(Product("kb", 49.5, 10), Product("mouse", 19.99, 0), Product("cable", 4.25, 120)))
    repeat(3) { products.findById("kb") }
    products.findById("none")
    products.findById("none")
    println("hits=${products.hits} ids=${products.ids} middle=${products.findAll().middle?.id}")
    val view: ReadOnly<String, Identified<String>> = products.readOnly()
    println("view=${view.findAll().map { it.id }} kb=${(view.findById("kb") as? Product)?.price}")
    val stock = products.findAll().associate { it.id to it.stock }
    println("most stocked=${stock.keyOfMax()} empty=${emptyMap<String, Int>().keyOfMax()}")
    println("in stock by price band=${products.findWhere { it.stock > 0 }.countBy { if (it.price > 10) "high" else "low" }}")

    println("== delegated list")
    val tags = Labeled(mutableListOf("a"), "tags")
    tags.add("b")
    tags += "c"
    tags.addAll(listOf("d", "e"))
    tags.removeAt(0)
    println("$tags size=${tags.size} middle=${tags.middle} contains(c)=${"c" in tags} sorted=${tags.sortedDescending()}")
    println("empty middle=${emptyList<Int>().middle}")
}
