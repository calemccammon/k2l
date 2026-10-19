package shop.query

import shop.domain.Entity
import shop.domain.Named
import shop.storage.ReadRepository

/** A predicate that can be combined; `in T` so a Spec<Named> can filter products. */
fun interface Spec<in T> {
    fun test(t: T): Boolean

    operator fun not(): Spec<T> = Spec { !test(it) }
}

infix fun <T> Spec<T>.and(other: Spec<T>): Spec<T> = Spec { test(it) && other.test(it) }

infix fun <T> Spec<T>.or(other: Spec<T>): Spec<T> = Spec { test(it) || other.test(it) }

fun <T : Named> nameStarts(prefix: String): Spec<T> = Spec { it.name.startsWith(prefix, ignoreCase = true) }

class Query<T : Entity<ID>, ID : Comparable<ID>> internal constructor(private val source: ReadRepository<T, ID>) {
    private val specs = mutableListOf<Spec<T>>()
    private var order: Comparator<in T>? = null
    private var limit = Int.MAX_VALUE

    fun where(spec: Spec<T>) = apply { specs += spec }
    fun <R : Comparable<R>> orderBy(selector: (T) -> R) = apply { order = compareBy(selector) }
    fun orderByDescending(cmp: Comparator<in T>) = apply { order = cmp.reversed() }
    fun limit(n: Int) = apply { limit = n }

    fun run(): List<T> {
        val matching = source.all().filter { e -> specs.all { it.test(e) } }
        val sorted = order?.let { matching.sortedWith(it) } ?: matching
        return sorted.take(limit)
    }

    fun first(): T? = limit(1).run().firstOrNull()
}

fun <T : Entity<ID>, ID : Comparable<ID>> ReadRepository<T, ID>.query(): Query<T, ID> = Query(this)

/** The largest value of [selector] among the entities, with a `where` clause on two type parameters. */
fun <T, R> Iterable<T>.maxValue(selector: (T) -> R): R? where T : Named, R : Comparable<R> {
    var best: R? = null
    for (item in this) {
        val v = selector(item)
        if (best == null || v > best) best = v
    }
    return best
}

fun <K : Comparable<K>, V> Map<K, V>.firstByKey(): Pair<K, V>? = keys.minOrNull()?.let { it to getValue(it) }

/** Group entities into buckets keyed by a comparable; buckets print in key order. */
inline fun <T, K : Comparable<K>> Iterable<T>.bucket(key: (T) -> K): Map<K, List<T>> {
    val result = sortedMapOf<K, MutableList<T>>()
    for (item in this) result.getOrPut(key(item)) { mutableListOf() } += item
    return result
}

internal fun <T> List<T>.page(size: Int, index: Int): List<T> = drop(size * index).take(size)

fun <T> List<T>.pages(size: Int): List<List<T>> = (0 until (this.size + size - 1) / size).map { page(size, it) }
