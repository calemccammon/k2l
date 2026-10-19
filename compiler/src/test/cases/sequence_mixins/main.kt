import kotlin.coroutines.AbstractCoroutineContextElement
import kotlin.coroutines.CoroutineContext

open class Base(val tag: String) {
    open fun describe() = "Base($tag)"
}

class Evens(val limit: Int) : Base("evens"), Sequence<Int> {
    override fun iterator(): Iterator<Int> = EvenIterator(limit)
}

class EvenIterator(val limit: Int) : Iterator<Int> {
    var at = 0
    override fun hasNext() = at < limit
    override fun next(): Int { val v = at; at += 2; return v }
}

class Oops(val n: Int) : RuntimeException("oops"), Sequence<Int> {
    override fun iterator(): Iterator<Int> = (1..n).iterator()
}

open class Named(val label: String) : AbstractCoroutineContextElement(Named) {
    companion object Key : CoroutineContext.Key<Named>
}

class Sub(label: String) : Named(label), Sequence<String> {
    override fun iterator(): Iterator<String> = listOf(label, label).iterator()
}

interface Shape { fun area(): Int }
class Sq(val s: Int) : Base("sq"), Shape, Sequence<Int> {
    override fun area() = s * s
    override fun iterator(): Iterator<Int> = (1..s).iterator()
}

class Both(val n: Int) : AbstractCoroutineContextElement(Both), Sequence<Int> {
    companion object Key : CoroutineContext.Key<Both>

    override fun iterator(): Iterator<Int> = (1..n).iterator()
}

fun main() {
    val both = Both(3)
    println(both.toList())
    println((both as CoroutineContext)[Both]?.let { (it as Both).n })
    println(both.key === Both)
    val e = Evens(10)
    println(e.describe())
    println(e.toList())
    println(e.map { it + 1 }.filter { it > 3 }.toList())
    println(e.sum())
    for (x in e) print(x)
    println()
    val o = Oops(3)
    println(o.message)
    println(o.toList())
    val s = Sub("hi")
    println(s.toList())
    println(s.key === Named)
    println(s.label)
    val q = Sq(3)
    println(q.area())
    println(q.toList())
    println(q.describe())
    println(q.map { it * 2 }.toList())
}
