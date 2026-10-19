import kotlin.coroutines.Continuation
import kotlin.coroutines.EmptyCoroutineContext
import kotlin.coroutines.startCoroutine

// `Unit` used as a value prints as kotlin.Unit, like on the JVM.

var calls = 0

fun u() {
    calls++
}

fun <T> id(x: T): T = x

fun <T> twice(f: () -> T): List<T> = listOf(f(), f())

fun describe(x: Any?): String = when (x) {
    null -> "null"
    is Unit -> "the Unit object"
    is String -> "a String"
    else -> "something else"
}

fun asAny(): Any = u()

fun returnsUnitCall() {
    return u()
}

fun returnsUnitObject(): Unit {
    when (calls) {
        0 -> Unit
        else -> u()
    }
    return Unit
}

// expanded in place because of the `return`
fun expanded(limit: Int): String {
    val units = listOf(1, 2).map { if (it > limit) return "stopped"; u() }
    val result = Result.success(1).map { if (it > limit) return "stopped"; u() }
    return "$units $result"
}

fun maybe(c: Boolean): Unit? = if (c) u() else null

class Holder {
    val p: Unit get() = u()
}

class Box<T>(val value: T) {
    override fun toString() = "Box($value)"
}

fun main() {
    println(u())
    println("${u()}")
    println("value: " + u())
    println(Unit)
    println(Unit.toString())
    val a: Any = Unit
    println(a)
    val b = u()
    println(b)
    println(listOf(Unit, u(), 1))
    println(runCatching { u() })
    println(runCatching { "text".length })
    println(id(u()))
    println(twice { u() })
    println(describe(u()))
    println(describe(Unit))
    println(describe(null))
    println(asAny())
    returnsUnitCall()
    println(returnsUnitObject())
    println(u() == Unit)
    println(Unit == a)
    println(Unit.hashCode() == a.hashCode())
    println(Box(u()))
    println(mapOf(1 to Unit))
    println(listOf(1, 2).map { u() })
    val x: String? = "x"
    val y: String? = null
    println(x?.let { u() })
    println(y?.let { u() })
    println(if (calls > 0) u() else Unit)
    val f: () -> Any = { u() }
    println(f())
    val r = Result.success(Unit)
    println(r)
    println(r.getOrNull())
    println(listOf(Unit).contains(Unit))
    println(setOf(Unit, Unit).size)
    val lazyUnit by lazy { u() }
    println(lazyUnit)
    println(u().toString() + "!")
    println(Unit::class.simpleName)
    val block: suspend () -> Unit = { u() }
    block.startCoroutine(Continuation(EmptyCoroutineContext) { println("completed: $it") })
    val v: Any = when (calls) {
        0 -> "none"
        else -> u()
    }
    println(v)
    println(runCatching(::u))
    val g: (Int) -> Unit = { u() }
    println(listOf(1).map(g))
    println(maybe(true))
    println(maybe(false))
    println(Holder().p)
    val m = mutableMapOf<Int, Unit>()
    m[1] = Unit
    println(m.getOrPut(2) { u() })
    println(m)
    println(sequenceOf(1).map { u() }.toList())
    println(listOf(1).associateWith { u() })
    println(expanded(5))
    println(expanded(0))
    println("calls: $calls")
    convertedReferences()
}

class Hooks(val onStart: () -> Unit)

fun pick(): () -> Any = ::u

/** Function values returning Unit converted to a function type with a result other than by passing them as an argument. */
fun convertedReferences() {
    val h: () -> Any = ::u
    println(h())
    println(pick()())
    val plain: () -> Unit = ::u
    val widened: () -> Any? = plain
    println(widened())
    println(listOf<() -> Any>(::u, { "lambda" }).map { it() })
    val hooks = Hooks(::u)
    val started: () -> Any = hooks.onStart
    println(started())
    var late: () -> Any = { 1 }
    late = plain
    println(late())
}
