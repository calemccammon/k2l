package generics.properties

import kotlin.properties.ReadOnlyProperty
import kotlin.properties.ReadWriteProperty
import kotlin.reflect.KProperty

// A settings model built from generic property delegates, generic fun interfaces, a generic value class for typed ids,
// generic type aliases, a reified array helper and a generic observable store.

fun interface Validator<in T> {
    fun validate(value: T): String?

    fun describe(value: T): String = validate(value) ?: "valid"
}

infix fun <T> Validator<T>.and(other: Validator<T>): Validator<T> = Validator { v -> validate(v) ?: other.validate(v) }

fun interface Mapper<in A, out B> {
    fun map(a: A): B
}

fun <A, B, C> Mapper<A, B>.then(next: Mapper<B, C>): Mapper<A, C> = Mapper { next.map(map(it)) }

typealias Listener<T> = (old: T, new: T) -> Unit
typealias Table<K> = MutableMap<K, MutableList<String>>

class Validated<T>(private var value: T, private val validator: Validator<T>, private val errors: MutableList<String>) :
    ReadWriteProperty<Any?, T> {
    override fun getValue(thisRef: Any?, property: KProperty<*>): T = value

    override fun setValue(thisRef: Any?, property: KProperty<*>, value: T) {
        val error = validator.validate(value)
        if (error != null) errors += "${property.name}: $error" else this.value = value
    }
}

class Observed<T>(initial: T, private val listeners: MutableList<Listener<Any?>>) : ReadWriteProperty<Any?, T> {
    private var value = initial
    override fun getValue(thisRef: Any?, property: KProperty<*>) = value
    override fun setValue(thisRef: Any?, property: KProperty<*>, value: T) {
        val old = this.value
        this.value = value
        if (old != value) listeners.forEach { it(old, value) }
    }
}

fun <T> computed(compute: () -> T): ReadOnlyProperty<Any?, T> = ReadOnlyProperty { _, _ -> compute() }

val positive = Validator<Int> { if (it > 0) null else "must be positive, was $it" }
fun atMost(n: Int) = Validator<Int> { if (it <= n) null else "must be at most $n, was $it" }
val notBlank = Validator<CharSequence> { if (it.isBlank()) "must not be blank" else null }
fun <T> oneOf(vararg allowed: T) = Validator<T> { if (it in allowed) null else "must be one of ${allowed.toList()}, was $it" }

class Settings {
    val errors = mutableListOf<String>()
    val changes = mutableListOf<Listener<Any?>>()

    var threads: Int by Validated(4, positive and atMost(64), errors)
    var name: String by Validated("app", notBlank, errors)
    var mode: String by Validated("dev", oneOf("dev", "prod"), errors)
    var debug: Boolean by Observed(false, changes)
    var tags: List<String> by Observed(emptyList(), changes)
    val summary: String by computed { "$name[$mode] threads=$threads debug=$debug tags=$tags" }
}

@JvmInline
value class Id<T>(val raw: Int) : Comparable<Id<T>> {
    override fun compareTo(other: Id<T>) = raw.compareTo(other.raw)
    override fun toString() = "#$raw"
}

data class Author(val id: Id<Author>, val name: String)
data class Book(val id: Id<Book>, val title: String, val author: Id<Author>)

class Store<T, K : Comparable<K>>(private val key: (T) -> K) {
    private val items = sortedMapOf<K, T>()
    private val listeners = mutableListOf<(String, T) -> Unit>()

    fun onChange(l: (String, T) -> Unit) {
        listeners += l
    }

    fun put(item: T) {
        val event = if (items.put(key(item), item) == null) "added" else "replaced"
        listeners.forEach { it(event, item) }
    }

    operator fun get(k: K): T? = items[k]
    fun values(): Collection<T> = items.values
}

inline fun <reified T> arrayOfN(n: Int, init: (Int) -> T): Array<T> = Array(n) { init(it) }

inline fun <reified T> List<*>.typedArray(): Array<T> = filterIsInstance<T>().toTypedArray()

fun <K> Table<K>.record(k: K, line: String) = getOrPut(k) { mutableListOf() }.add(line)

fun main() {
    println("== delegates")
    val s = Settings()
    s.changes += { old, new -> println("  changed $old -> $new") }
    s.threads = 16
    s.threads = 0
    s.threads = 100
    s.name = "  "
    s.name = "api"
    s.mode = "test"
    s.mode = "prod"
    s.debug = true
    s.debug = true
    s.tags = listOf("a", "b")
    println(s.summary)
    s.errors.forEach { println("  error: $it") }

    println("== fun interfaces")
    val parse = Mapper<String, Int> { it.trim().toInt() }
    val square = Mapper<Int, Int> { it * it }
    val show = Mapper<Any, String> { "<$it>" }
    val pipeline = parse.then(square).then(show)
    println(listOf(" 3", "12 ", "-5").map(pipeline::map))
    val lengthCheck: Validator<String> = notBlank and Validator { if (it.length > 5) "too long" else null }
    println(listOf("", "ok", "toolong").map { lengthCheck.describe(it) })

    println("== typed ids")
    val tolkien = Author(Id(1), "Tolkien")
    val books = Store<Book, Id<Book>> { it.id }
    val log = mutableListOf<String>()
    books.onChange { event, b -> log += "$event ${b.id} ${b.title}" }
    books.put(Book(Id(20), "The Hobbit", tolkien.id))
    books.put(Book(Id(10), "Silmarillion", tolkien.id))
    books.put(Book(Id(20), "The Hobbit (2nd ed.)", tolkien.id))
    println("values=${books.values().map { it.title }} get=${books[Id(10)]?.title} missing=${books[Id(99)]}")
    println("log=$log")
    val ids = listOf(Id<Book>(3), Id(1), Id(2)).sorted()
    println("ids=$ids max=${ids.max()} raw sum=${ids.sumOf { it.raw }} equal=${Id<Book>(1) == Id<Book>(1)}")
    println("by author=${books.values().groupBy({ it.author }, { it.id })}")

    println("== arrays and aliases")
    val squares: Array<Int> = arrayOfN(5) { it * it }
    val labels = arrayOfN(3) { "L$it" }
    println("${squares.contentToString()} ${labels.joinToString()} ${squares.size + labels.size}")
    val mixed = listOf(1, "a", 2, "b", 3.5)
    val ints: Array<Int> = mixed.typedArray()
    val strs = mixed.typedArray<String>()
    println("ints=${ints.contentToString()} sum=${ints.sum()} strs=${strs.contentToString()}")
    val table: Table<Char> = sortedMapOf()
    for (w in listOf("apple", "avocado", "banana", "blueberry", "cherry")) table.record(w.first(), w)
    println(table)
}
